* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-190</Rating>
*-----------------------------------------------------------------------------
* Version 24 04/12/00  GLOBUS Release No. G11.1.01 11/12/00
*
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.SCHEDULE.PROCESSING(SCHED.LIST, ENQUIRY.MODE)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.SCHEDULE.PROCESSING                           *
* Duplicate of SW.SCHEDULE.PROCESSING - for running during Conversion.  *
* Purpose - Not to have any inconsistency between data and routines     *
* while running conversions.                                            *
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :  This routine will process all schedules, both asset   *
*                 and liability, for the current swap contract.         *
*                 It will be called online when a contract is first     *
*                 input or changed and at End Of Day when a schedule    *
*                 is due.                                               *
*                 If called in enquiry mode the all schedules will be   *
*                 processed but no accouting will be performed.         *
*                                                                       *
*                 Supplied arguments :                                  *
*                                                                       *
*                 SCHED.LIST         Sorted list of all swap schedules. *
*                 ENQUIRY.MODE       0  Normal processing.              *
*                                    1  Enquiry mode (no a/c).          *
*                                                                       *
*************************************************************************
*                                                                       *
* Modifications :                                                       *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
*
* 14/06/07 - BG_100014209
*            Changes to called routines with incorrect number of arguments
*            / non-existent routine.
*
* 19/09/08 - BG_100020046
*            Rate Reduction for SWAP routines.
*
*************************************************************************
*
******************
*  Insert Files.
******************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.EB.ACCRUAL.DATA
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_SW.COMMON
    $INSERT I_F.STMT.ENTRY
    $INSERT I_BATCH.FILES
*
*************************************************************************
*
*************
MAIN.PROCESS:
*************
*
    GOSUB INITIALISATION
*
*  Null the ccy pos fields
*
    R$SW.ASSET.BALANCES<SW.BAL.POSITION.DATE> = ''
    R$SW.ASSET.BALANCES<SW.BAL.POSITION.LCY> = ''
    R$SW.ASSET.BALANCES<SW.BAL.POSITION.FCY> = ''
    R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.DATE> = ''
    R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.LCY> = ''
    R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.FCY> = ''
*
    GOSUB PROCESS.CURRENT.SCHEDULES
*
    IF ENQUIRY.MODE = 1 THEN  ;* Enquiry mode.
        RETURN      ;* Don't do any real accounting.
    END
*
    GOSUB PROCESS.FORWARD.SCHEDULES
*
*  Call routine to detect whether Position Management is an active
*  Globus application and Swaps has been defined on the PM.PARAMETER
*  SYSTEM record, then routine will perform PM processing.
*
    CALL PM.CONTROL.SW        ;*- Not required for Conversion
*
* Update the position fields....
*
    SAV.SW.ASST.BALS<SW.BAL.POSITION.DATE> = R$SW.ASSET.BALANCES<SW.BAL.POSITION.DATE>
    SAV.SW.ASST.BALS<SW.BAL.POSITION.LCY> = R$SW.ASSET.BALANCES<SW.BAL.POSITION.LCY>
    SAV.SW.ASST.BALS<SW.BAL.POSITION.FCY> = R$SW.ASSET.BALANCES<SW.BAL.POSITION.FCY>
*
    SAV.SW.LIAB.BALS<SW.BAL.POSITION.DATE> = R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.DATE>
    SAV.SW.LIAB.BALS<SW.BAL.POSITION.LCY> = R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.LCY>
    SAV.SW.LIAB.BALS<SW.BAL.POSITION.FCY> = R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.FCY>
*
    R$SW.ASSET.BALANCES = SAV.SW.ASST.BALS        ;* Restore common bal vars.
    R$SW.LIABILITY.BALANCES = SAV.SW.LIAB.BALS
    R$SWAP = SAV.SWAP         ;* Restore common contract.
    ENQUIRY.MODE = SAV.ENQUIRY.MODE

    IF ENQUIRY.MODE = 0 THEN
        CALL SW.UPDATE.LIMITS('POS')    ;* Update positions
    END
*

* Process ASSET leg
    IF R.OLD(1) AND "IP" MATCH R.OLD(SW.AS.TYPE) AND NOT("IP" MATCH R$SWAP<SW.AS.TYPE>) THEN
        CALL SW.REV.ACCRUALS("A")
    END
* Then process LIAB leg
    IF R.OLD(1) AND "IP" MATCH R.OLD(SW.LB.TYPE) AND NOT("IP" MATCH R$SWAP<SW.LB.TYPE>) THEN
        CALL SW.REV.ACCRUALS("L")
    END
*
    GOSUB CALL.EB.ACCOUNTING
*
MAIN.PROCESS.EXIT:
*
    RETURN
*
*************************************************************************
*
***************
INITIALISATION:
***************
    EOD.SCHEDULES = "IP,AP,RX,CM"
    CONVERT "," TO VM IN EOD.SCHEDULES
*
    NEW.AS.END.INT.PERIOD = ""
    NEW.LB.END.INT.PERIOD = ""
    SAV.SW.ASST.BALS = ""
    SAV.SW.LIAB.BALS = ""
    EFF.IN.BETWEEN.IP = 0 ; Y.MKT.EXCH.CALC = 0

    Y.STATUS.FLAG = 0 ; Y.LB.ASSET.TYPES = '' ; Y.CURRENT.DATE = ''   ;
    Y.AS.ASSET.TYPES = '' ; Y.AS.SCHED.DATE = '' ; Y.LB.SCHED.DATE = ''
    MKT.PROCESS.VALUE = ''

    IF RUNNING.UNDER.BATCH THEN
        Y.CURRENT.DATE = CONTROL.LIST<1,1>        ;* Current processing date
    END
*
*  Save SCHED.LIST cos it will be changed in this routine.
*
    SCHEDULE.LIST = SCHED.LIST
*
*  Build a sorted list of all schedules if SCHED.LIST is null.
*  The list of schedules are all the schedules defined
*  on the swap contract record (both asset and liability)
*  plus two system generated schedules, CI and CM.
*
    IF SCHEDULE.LIST = "" THEN
        CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,'')
    END
*
*  If the contract has not yet started then check/adjust the
*  start of the interest period.
*
    IF R$SWAP<SW.ASSET.STATUS> = "" THEN
        Y.STATUS.FLAG = 1
        R$SW.ASSET.BALANCES<SW.BAL.START.INT.PERIOD> = R$SWAP<SW.AS.INT.EFFECTIVE>
    END
*
    IF R$SWAP<SW.LIABILITY.STATUS> = "" THEN
        Y.STATUS.FLAG = 1
        R$SW.LIABILITY.BALANCES<SW.BAL.START.INT.PERIOD> = R$SWAP<SW.LB.INT.EFFECTIVE>
    END
*
* Recalculate the end of the interest period as they could have changed an IP
* schedule.
*
    GOSUB GET.AS.END.INT.PERIOD
*
    GOSUB GET.LB.END.INT.PERIOD
*
    RETURN
*
*************************************************************************
*
**************************
PROCESS.CURRENT.SCHEDULES:
**************************
*
*  Process all CURRENT entries (ie. not forward).
*
    CURR.SCHD = 1
    GOSUB PROCESS.SCHEDULE.LIST         ;* Process entries.
*
    IF ENQUIRY.MODE = 0 THEN  ;* Maintain customer limits.
        CALL SW.UPDATE.LIMITS('VAL')    ;* Authorise.
        IF TEXT = 'NO' THEN
            RETURN TO MAIN.PROCESS.EXIT
        END
    END
*
    IF R$SWAP<SW.NET.PAYMENTS> = "Y" THEN         ;* Net any resulting payments.
        ENTRIES = C$ACCOUNTING.ENTRIES  ;* Real entries only.
        CALL SW.NET.PAYMENTS(ENTRIES)
        C$ACCOUNTING.ENTRIES = ENTRIES
    END
    CURR.SCHD = 0
*
    RETURN
*
*************************************************************************
*
**************************
PROCESS.FORWARD.SCHEDULES:
**************************
*
*  Process all FORWARD entries.
*  (This will include forward schedules of the next interest period if
*   necessary).
*
    SAV.SW.ASST.BALS = R$SW.ASSET.BALANCES        ;* Save common bal vars.
    SAV.SW.LIAB.BALS = R$SW.LIABILITY.BALANCES
    SAV.SWAP = R$SWAP         ;* Save swap contract.
    SAV.ENQUIRY.MODE = ENQUIRY.MODE
*
    Y.FULL.AS.BALANCES = ''
    Y.FULL.LB.BALANCES = ''
*
*  Raise all forward entries (upto Contract Maturity).
*
    LOOP
    UNTIL SCHEDULE.LIST = "" DO
*
        ENQUIRY.MODE = 1
        CALL SW.CYCLE.SCHEDULES(ENQUIRY.MODE)
*
        SCHEDULE.LIST = ""
        CALL SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,'')       ;* Rebuild list.
*
        IF SCHEDULE.LIST THEN
            GOSUB PROCESS.SCHEDULE.LIST ;* Process entries.
        END
*
    REPEAT
*
* Used to store Full Balances record in common variables which is used to
* get the Net RX amount in SW.UPDATE.SCHEDULES routine.
    Y.FULL.AS.BALANCES = R$SW.ASSET.BALANCES
    Y.FULL.LB.BALANCES = R$SW.LIABILITY.BALANCES
*
    IF R$SWAP<SW.NET.PAYMENTS> = "Y" THEN         ;* Net any resulting payments.
        ENTRIES = C$FORWARD.ENTRIES     ;* Forward entries.
        CALL SW.NET.PAYMENTS(ENTRIES)
        C$FORWARD.ENTRIES = ENTRIES
    END
*
    RETURN
*
*************************************************************************
*
*******************
CALL.EB.ACCOUNTING:
*******************
*
    GOSUB SET.ACCT.TYPE
*
    MATPARSE R.NEW FROM R$SWAP          ;* make sure they are identical
*
    IF ENQUIRY.MODE = 0 THEN
        GOSUB RAISE.ACCOUNTING
    END

    IF C$ACCOUNTING.ENTRIES <> "" AND ENQUIRY.MODE = 0 THEN
        CALL EB.ACCOUNTING("SW",EB.ACCT.TYPE,C$ACCOUNTING.ENTRIES,"0")          ;* Accounting
    END
*
    MATBUILD R$SWAP FROM R.NEW          ;* update R$SWAP
*
    RETURN
*
******************
SET.ACCT.TYPE:
******************
    IF NOT(RUNNING.UNDER.BATCH) THEN
        EB.ACCT.TYPE = "VAL"  ;* On-line input of accounting entries
        IF C$FORWARD.ENTRIES = "" THEN
            FWD.ACCT.TYPE = "REV"       ;* On-line reversal of forward entries
        END ELSE
            FWD.ACCT.TYPE = "ADD"       ;* On-line input of forward entries
        END
    END ELSE
        EB.ACCT.TYPE = "SAO"  ;* EOD accounting entries - automatically authorised
        IF C$FORWARD.ENTRIES = "" THEN
            FWD.ACCT.TYPE = "REV.AUT"   ;* EOD forward entries - automatically reversed
        END ELSE
            FWD.ACCT.TYPE = "ADD.AUT":FM:"STORE.OVERRIDES"  ;* EOD forward entries - automatically authorised
        END
    END

    RETURN

********************
RAISE.ACCOUNTING:
********************

    IF FWD.ACCT.TYPE EQ "REV.AUT" THEN
        FWD.ACCT.TYPE = "REV"
        CALL EB.ACCOUNTING("SW",FWD.ACCT.TYPE,C$FORWARD.ENTRIES,"1")  ;* Forward Accounting 1
        FWD.ACCT.TYPE = "AUT"
        CALL EB.ACCOUNTING("SW",FWD.ACCT.TYPE,C$FORWARD.ENTRIES,"1")  ;* Forward Accounting 2
    END ELSE
        CALL EB.ACCOUNTING("SW",FWD.ACCT.TYPE,C$FORWARD.ENTRIES,"1")  ;* Forward Accounting 3
    END

    RETURN

*************************************************************************
*
*********************************
DETERMINE.EARLIEST.SCHEDULE.DATE:
*********************************
*
    EARLIEST.SCHEDULE.DATE = "99999999"
*
    T.IDX = 0
    LOOP T.IDX+=1 UNTIL SCHEDULE.LIST<1,T.IDX> = ""
*
        PROCESS.DATE = SCHEDULE.LIST<4,T.IDX>
*
        IF PROCESS.DATE LT EARLIEST.SCHEDULE.DATE THEN
            EARLIEST.SCHEDULE.DATE = PROCESS.DATE
        END
*
    REPEAT
*
    RETURN
*
*************************************************************************
*
*  Process all entries.
*  This subroutine is called twice, once to process all live (current)
*  entries and once to process all forward entries (this may include
*  forward entries for the next interest period).
*
**********************
PROCESS.SCHEDULE.LIST:
**********************
*
    GOSUB DETERMINE.EARLIEST.SCHEDULE.DATE
*
    IDX = 0
    LOOP IDX+=1 UNTIL SCHEDULE.LIST<1,IDX> = ""
*
        GOSUB GET.SCHEDULE.DETAILS
* To get the Schedule Index dynamically
        GOSUB GET.SCHEDULE.INDEX
        Y.MKT.EXCH.CALC = 0 ;  EFF.IN.BETWEEN.IP = 0
*
* The COB processing of SW.EOD.SCHEDULE.SELECT has been modified and hence
* changed the CURRENT.ENTRY check with respective to the COB processing date
        IF RUNNING.UNDER.BATCH THEN
            CURRENT.ENTRY = (PROCESS.DATE LE Y.CURRENT.DATE)
        END ELSE
            CURRENT.ENTRY = (PROCESS.DATE LE TODAY)
        END

        DO.PROCESS = 1
*
* PROCESS.VALUE is now being populated if REVALUATION.TYPE is specified
* Need to use INPUT.RATE to determine processing RR or not
*
        Y.TRSRY.RATE = 0
        IF SCHED.LEG.TYPE = 'A' THEN
            INPUT.RATE = R$SWAP<SW.AS.RATE,SCHED.IDX>
            Y.TRSRY.RATE = R$SWAP<SW.AS.TRSRY.RATE,SCHED.IDX>
        END ELSE
            INPUT.RATE = R$SWAP<SW.LB.RATE,SCHED.IDX>
            Y.TRSRY.RATE = R$SWAP<SW.LB.TRSRY.RATE,SCHED.IDX>
        END
*
        IF SCHEDULE.TYPE[1,2] EQ "RR" AND NOT(INPUT.RATE) AND NOT(ENQUIRY.MODE) THEN
            DO.PROCESS = 0    ;* do not process RR when no rate
        END
*
* 1. Calculate interest amount if interest period changed or interest amount EQ ""
* 2. For FIXED.INTEREST amount contracts, need to re-calc interest and re-do accruals
*    if interest period changed and/or interest amount changed
*
        RECALC.CURRENT.INTEREST = ""
        ADJUSTMENT.DATE = ""
*
        GOSUB GET.INTEREST.DETAILS
*
        IF SCHEDULE.TYPE[1,2] EQ "IP" AND EFFECTIVE.DATE EQ CURRENT.INT.PERIOD THEN
            RECALC.CURRENT.INTEREST = (NEW.INT.PERIOD OR (CURRENT.INT.AMOUNT EQ ""))
* re-do accruals for FIXED.INTEREST contract only
*          GOSUB RECALC.ACCR.FOR.FIXED.INT
        END
*
*  make sure schedules are processed in process.date order
*  when ENQUIRY.MODE is set
*
        IF ENQUIRY.MODE AND (PROCESS.DATE GT EARLIEST.SCHEDULE.DATE) OR (SCHEDULE.LIST<10,IDX>) THEN
            DO.PROCESS = 0    ;* delay processing of this schedule
        END
*
        IF DO.PROCESS AND (CURRENT.ENTRY) OR (ENQUIRY.MODE) OR (RECALC.CURRENT.INTEREST) THEN
            GOSUB PROCESS.SCHEDULE
            GOSUB CHECK.SCHEDULES.FOR.ACCOUNTING
        END

* To populate the PROCESS.VALUE for IP, which is used to store in SWAP.SCHEDULES
        IF CURR.SCHD AND SCHEDULE.TYPE[1,2] EQ "IP" THEN
            SCHED.LIST<6,IDX> = 0
            GOSUB UPDATE.IP.AMOUNT
        END
    REPEAT
*
PROCESS.SCHEDULE.LIST.EXIT:
*
    RETURN
*******************
UPDATE.IP.AMOUNT:
*******************
    IF PROCESS.VALUE THEN
        SCHED.LIST<6,IDX> = PROCESS.VALUE
    END ELSE
        SCHED.LIST<6,IDX> = CURRENT.INT.AMOUNT
    END

    RETURN

****************************
GET.SCHEDULE.DETAILS:
****************************
    SCHEDULE.TYPE = SCHEDULE.LIST<1,IDX>
    SCHEDULE.DATE = SCHEDULE.LIST<2,IDX>
    ENTRY.DATE = SCHEDULE.LIST<3,IDX>
    PROCESS.DATE = SCHEDULE.LIST<4,IDX>
    ORIG.VALUE.DATE = SCHEDULE.DATE

    EFFECTIVE.DATE = SCHEDULE.LIST<5,IDX>
    PROCESS.VALUE = SCHEDULE.LIST<6,IDX>          ;* An amount or rate (RR).
    NARRATIVE = SCHEDULE.LIST<7,IDX>
    SCHED.LEG.TYPE = SCHEDULE.LIST<8,IDX>

    RETURN
****************************
GET.INTEREST.DETAILS:
****************************

    IF SCHED.LEG.TYPE = "A" THEN
        START.INT.PERIOD.DATE = R$SW.ASSET.BALANCES<SW.BAL.START.INT.PERIOD>
        CURRENT.INT.PERIOD = R$SW.ASSET.BALANCES<SW.BAL.END.INT.PERIOD>
        CURRENT.INT.AMOUNT = R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT>
        NEW.INT.PERIOD = NEW.AS.END.INT.PERIOD
        FIXED.INTEREST = (R$SWAP<SW.AS.FIXED.INTEREST> EQ 'Y')
    END ELSE
        START.INT.PERIOD.DATE = R$SW.LIABILITY.BALANCES<SW.BAL.START.INT.PERIOD>
        CURRENT.INT.PERIOD = R$SW.LIABILITY.BALANCES<SW.BAL.END.INT.PERIOD>
        CURRENT.INT.AMOUNT = R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT>
        NEW.INT.PERIOD = NEW.LB.END.INT.PERIOD
        FIXED.INTEREST = (R$SWAP<SW.LB.FIXED.INTEREST> EQ 'Y')
    END

    RETURN
*
***************************
RECALC.ACCR.FOR.FIXED.INT:
***************************
    IF FIXED.INTEREST THEN
        RECALC.CURRENT.INTEREST += (PROCESS.VALUE+0 NE CURRENT.INT.AMOUNT+0)
        IF RECALC.CURRENT.INTEREST THEN
            ADJUSTMENT.DATE = START.INT.PERIOD.DATE
        END
    END

    RETURN

********************************
CHECK.SCHEDULES.FOR.ACCOUNTING:
********************************
    IF NOT(SCHEDULE.TYPE[1,2] MATCHES EOD.SCHEDULES) OR (RUNNING.UNDER.BATCH) OR (ENQUIRY.MODE) THEN
        GOSUB CALL.SW.ACCOUNTING        ;* raise real/forward entries
    END

    RETURN
*************************************************************************
*
*******************
GET.SCHEDULE.INDEX:
*******************
* To get the Schedule Index dynamically
    SCHED.IDX = ''
    Y.TYPE = '' ; Y.DATE.FREQ = '' ; Y.SEARCH.IDX = ''
    Y.KEY.INDEX = SCHEDULE.TYPE:SCHEDULE.DATE
    IF SCHEDULE.TYPE = 'CI' OR SCHEDULE.TYPE = 'CM' THEN
        RETURN
    END
    IF SCHED.LEG.TYPE = 'A' THEN
        Y.TYPE = R$SWAP<SW.AS.TYPE>
        Y.DATE.FREQ = R$SWAP<SW.AS.DATE.FREQ>
    END ELSE
        Y.TYPE = R$SWAP<SW.LB.TYPE>
        Y.DATE.FREQ = R$SWAP<SW.LB.DATE.FREQ>
    END

    NUM.SCHED.TYPES = DCOUNT(Y.TYPE,VM)
    FOR Y.IDX = 1 TO NUM.SCHED.TYPES
        Y.SEARCH.IDX = Y.TYPE<1,Y.IDX>:Y.DATE.FREQ<1,Y.IDX>[1,8]
        IF Y.SEARCH.IDX EQ Y.KEY.INDEX THEN
            SCHED.IDX = Y.IDX
            RETURN
        END
    NEXT Y.IDX
    RETURN
*
*************************************************************************
*
*******************
CALL.SW.ACCOUNTING:
*******************
    IF NOT(CURRENT.ENTRY) AND NOT(ENQUIRY.MODE) THEN
        CRT "DON'T UPDATE SWAP.BALANCES AND NO ACCTG ENTRIES WHEN STILL FORWARD"
        RETURN
    END
*
    CHARGE.DETAILS = ""
    LCY.AMOUNT = ""
*
    IF SCHEDULE.TYPE[1,2] <> "RR" AND PROCESS.VALUE THEN    ;* No accounting for rate resets
        REVERSAL = 0
        AMOUNT = PROCESS.VALUE
        SAVE.SCHED.LEG.TYPE = SCHED.LEG.TYPE
        PROCESS.DATE = PROCESS.DATE:VM:ORIG.VALUE.DATE
        CALL CONV.SW.ACCOUNTING(SCHEDULE.TYPE,SCHED.LEG.TYPE,AMOUNT,ENTRY.DATE,PROCESS.DATE,NARRATIVE,REVERSAL,LCY.AMOUNT,CHARGE.DETAILS)
        SCHED.LEG.TYPE = SAVE.SCHED.LEG.TYPE
        LCY.AMOUNT = ABS(LCY.AMOUNT)    ;*  Amount should be unsigned.
    END
*
    GOSUB UPDATE.SCHEDULE.AND.CHARGE.FIELDS
*
    RETURN
*
*************************************************************************
*
*****************
PROCESS.SCHEDULE:
*****************
*
    AMOUNT.DIFF = ""          ;* for the amount difference in IS and AP
    MKT.PROCESS.VALUE = ''
*
    GOSUB SET.COMMON.SWAP.BALANCES
    IF SCHED.LEG.TYPE = "A" THEN
        AP.EXISTS = INDEX(R$SWAP<SW.AS.TYPE>, "AP", 1)
        ORIGINAL.PRINCIPAL = R$SWAP<SW.AS.PRINCIPAL>
    END ELSE
        AP.EXISTS = INDEX(R$SWAP<SW.LB.TYPE>, "AP", 1)
        ORIGINAL.PRINCIPAL = R$SWAP<SW.LB.PRINCIPAL>
    END
*
    OUTSTANDING.PRINCIPAL = R$SW.BALANCES<SW.BAL.PRINCIPAL, 1>
*
    BEGIN CASE
*
*  Set status to CUR if CI
*
    CASE SCHEDULE.TYPE[1,2] = "CI"
        R$SWAP<SW.CONTRACT.STATUS> = "CUR"
        BEGIN CASE
        CASE SCHED.LEG.TYPE = "A"
            R$SWAP<SW.ASSET.STATUS> = "CUR"
        CASE SCHED.LEG.TYPE = "L"
            R$SWAP<SW.LIABILITY.STATUS> = "CUR"
        END CASE
*
*  Set NOTIONAL to NO if PX/IS
*
    CASE SCHEDULE.TYPE[1,2] MATCHES "PX":VM:"IS"
        R$SW.BALANCES<SW.BAL.NOTIONAL> = "NO"
*
        IF SCHEDULE.TYPE[1,2] = "IS" THEN
            AMOUNT.DIFF = ORIGINAL.PRINCIPAL - PROCESS.VALUE
            IF SCHED.LEG.TYPE = "L" THEN
                AMOUNT.DIFF = -AMOUNT.DIFF        ;* signed
            END
        END
*
**
*  Since principal movement can happen after sw.build.schedule.list
*  make sure that "RX" and "CM" have the latest outstanding principal
*
    CASE SCHEDULE.TYPE[1,2] MATCHES "RX":VM:"CM"
        PROCESS.VALUE = OUTSTANDING.PRINCIPAL
*
*  Insert/overwrite the new rate into the swap balances rate fields
*  and remove any rates with an effective date greater than the
*  effective date of the new rate.
*
    CASE SCHEDULE.TYPE[1,2] = "RR"
        IF PROCESS.VALUE NE '' THEN
            GOSUB UPDATE.RATE.FIELDS
            IF AP.EXISTS THEN
                GOSUB UPDATE.ANNUITY.AMOUNT
            END
            CALL CONV.SW.CALCULATE.INTEREST(SCHED.LEG.TYPE)
        END
*  Insert/overwrite the principal fields on the swap balances record.
*  Increment/decrement all 'future' principal amounts.
*  Don't decrease more than the outstanding principal
    CASE SCHEDULE.TYPE[1,2] MATCHES "PI":VM:"PD"
        GOSUB UPDATE.PRINCIPAL
        IF AP.EXISTS THEN
            GOSUB UPDATE.ANNUITY.AMOUNT
        END
    CASE SCHEDULE.TYPE[1,2] MATCHES "NI":VM:"ND"
        GOSUB UPDATE.PRINCIPAL
        IF AP.EXISTS THEN
            GOSUB UPDATE.ANNUITY.AMOUNT
        END
*  If real IP/AP then call SW.PERFORM.ACCRUAL to post the final accrual.
*  This will also correct the interest amount if necessary.
*  Otherwise, just calculate the interest amount
*  If AP then need to decrease principal of the surplus repayment amount
*  Don't decrease more than the outstanding principal
    CASE SCHEDULE.TYPE[1,2] MATCHES "IP":VM:"AP"
        IF SCHEDULE.TYPE[1,2] EQ "IP" AND EFFECTIVE.DATE GT R$SWAP<SW.VALUE.DATE> THEN
            GOSUB CHECK.ACCRUALS
*
* INTEREST.AMOUNT is set in the actual BALANCES record in COMMON
*
            GOSUB SET.COMMON.SWAP.BALANCES
*
* set up PROCESS.VALUE before calling SW.ACCOUNTING
*
            GOSUB SET.UP.PROCESS.VALUE
        END
    END CASE
    GOSUB SET.REAL.SWAP.BALANCES
*
    RETURN

******************
CHECK.ACCRUALS:
******************
    IF (CURRENT.ENTRY) AND (RUNNING.UNDER.BATCH) THEN
        ACCRUAL.TO.DATE = EFFECTIVE.DATE
        CALL CDT("", ACCRUAL.TO.DATE, "-1C")      ;* eff.date - 1
        CALL CONV.SW.PERFORM.ACCRUAL(ACCRUAL.TO.DATE,ADJUSTMENT.DATE,SCHED.LEG.TYPE)
    END ELSE
        IF (ADJUSTMENT.DATE) AND (ADJUSTMENT.DATE LE R$SW.BALANCES<SW.BAL.ACCR.TO.DATE,1>) THEN
            SAVE.SCHED.DATE = SCHEDULE.DATE
            SCHEDULE.DATE = ADJUSTMENT.DATE       ;* re-do accrual
            GOSUB ADJUST.ACCRUALS
            SCHEDULE.DATE = SAVE.SCHED.DATE       ;* restore schedule.date
        END ELSE
            CALL CONV.SW.CALCULATE.INTEREST(SCHED.LEG.TYPE)
        END
    END

    RETURN
*************************************************************************
*
*****************************************************
* update rate fields on the swap.balances record    *
*****************************************************
*
*******************
UPDATE.RATE.FIELDS:
*******************
*
    Y.MKT.EXCH.CALC = 0 ; Y.MKT.EXCH.RATE = ''
    IF SCHED.LEG.TYPE = "A" THEN
        LOCATE "IP" IN R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING MPOS THEN
            EFF.IN.BETWEEN.IP = EFFECTIVE.DATE GE START.INT.PERIOD.DATE AND EFFECTIVE.DATE LT CURRENT.INT.PERIOD
        END
        RATE.KEY = R$SWAP<SW.AS.RATE.KEY>
        CURRENT.RATE = PROCESS.VALUE + R$SWAP<SW.AS.SPREAD>

        IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SW.AS.FIXED.RATE> THEN
            Y.MKT.EXCH.CALC = 1
        END
    END ELSE
        RATE.KEY = R$SWAP<SW.LB.RATE.KEY>
        CURRENT.RATE = PROCESS.VALUE + R$SWAP<SW.LB.SPREAD>

        LOCATE "IP" IN R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING MPOS THEN
            EFF.IN.BETWEEN.IP = EFFECTIVE.DATE GE START.INT.PERIOD.DATE AND EFFECTIVE.DATE LT CURRENT.INT.PERIOD
        END
        IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SW.LB.FIXED.RATE> THEN
            Y.MKT.EXCH.CALC = 1
        END
    END

    GOSUB GET.BALANCES        ;* setup PRIN.DATA and INT.DATA from current BALANCES record
* Assign & Pass the Market Exchange Interest rate in the dummy field to SW.UPDATE.BALANCES
    IF R$SW.BALANCES<SW.BAL.MKT.INT.RATE> THEN
        INT.DATA<EB.ACI.INT.SPRD> = R$SW.BALANCES<SW.BAL.MKT.INT.RATE>
    END

    IF Y.MKT.EXCH.CALC THEN
        IF Y.TRSRY.RATE THEN
            Y.MKT.EXCH.RATE = ABS(CURRENT.RATE - Y.TRSRY.RATE)
        END ELSE
            IF R$SW.BALANCES<SW.BAL.MKT.INT.RATE,1> THEN
                Y.MKT.EXCH.RATE = R$SW.BALANCES<SW.BAL.MKT.INT.RATE,1>          ;* Get the current Market Exchange rate
            END
        END
        IF Y.MKT.EXCH.RATE THEN
            CURRENT.RATE = CURRENT.RATE : '/' : Y.MKT.EXCH.RATE       ;* Append the Market Exchange rate with Customer rate
        END
        IF EFF.IN.BETWEEN.IP THEN
* Change the effective and the value date to start.date for amendments in between IPs.
            EFFECTIVE.DATE = START.INT.PERIOD.DATE
            ENTRY.DATE = START.INT.PERIOD.DATE
        END
    END

    CALL SW.UPDATE.BALANCES(SCHEDULE.TYPE[1,2],EFFECTIVE.DATE,CURRENT.RATE,RATE.KEY,PRIN.DATA,INT.DATA)
    GOSUB SET.BALANCES        ;* update current BALANCES record with PRIN.DATA and INT.DATA

    IF Y.MKT.EXCH.CALC AND INT.DATA<EB.ACI.INT.SPRD> THEN
* Update SWAP.BALANCES with the current Market Exchange rate
        R$SW.BALANCES<SW.BAL.MKT.INT.RATE> = INT.DATA<EB.ACI.INT.SPRD>
        INT.DATA<EB.ACI.INT.SPRD> = ''  ;* Clear off the dummy variable
    END   ;* EN_10002630 - E

    IF SCHED.LEG.TYPE = "A" THEN
        R$SWAP<SW.AS.CURRENT.RATE> = INT.DATA<EB.ACI.INT.RATE,1>
        IF Y.TRSRY.RATE THEN
            R$SWAP<SW.AS.CUR.TRSRY.RATE> = Y.TRSRY.RATE
        END
    END ELSE
        R$SWAP<SW.LB.CURRENT.RATE> = INT.DATA<EB.ACI.INT.RATE,1>
        IF Y.TRSRY.RATE THEN
            R$SWAP<SW.LB.CUR.TRSRY.RATE> = Y.TRSRY.RATE
        END
    END
*
    GOSUB ADJUST.ACCRUALS     ;*  If backdated.
*
    RETURN
*
*
************************************************************
* update principal fields on the swap.balances record      *
************************************************************
*
*****************
UPDATE.PRINCIPAL:
*****************
*
    RATE.KEY = ""

    IF SCHED.LEG.TYPE = "A" THEN
        LOCATE "IP" IN R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING MPOS THEN
            EFF.IN.BETWEEN.IP = EFFECTIVE.DATE GE START.INT.PERIOD.DATE AND EFFECTIVE.DATE LT CURRENT.INT.PERIOD
        END

        IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SW.AS.FIXED.RATE> THEN
            Y.MKT.EXCH.CALC = 1
        END
    END ELSE
        LOCATE "IP" IN R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING MPOS THEN
            EFF.IN.BETWEEN.IP = EFFECTIVE.DATE GE START.INT.PERIOD.DATE AND EFFECTIVE.DATE LT CURRENT.INT.PERIOD
        END
        IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SW.LB.FIXED.RATE> THEN
            Y.MKT.EXCH.CALC = 1
        END

    END
    GOSUB GET.BALANCES        ;* setup PRIN.DATA and INT.DATA from current BALANCES record
*
*
*   IF SCHEDULE.TYPE[1,2] = "PD" AND PROCESS.VALUE > OUTSTANDING.PRINCIPAL THEN
    IF (SCHEDULE.TYPE[1,2] = "PD" OR SCHEDULE.TYPE[1,2] = "ND") AND PROCESS.VALUE > OUTSTANDING.PRINCIPAL THEN
*
        PROCESS.VALUE = OUTSTANDING.PRINCIPAL
    END
    IF  Y.MKT.EXCH.CALC AND  EFF.IN.BETWEEN.IP THEN
        EFFECTIVE.DATE = START.INT.PERIOD.DATE
        ENTRY.DATE = START.INT.PERIOD.DATE
    END
    CALL SW.UPDATE.BALANCES(SCHEDULE.TYPE[1,2],EFFECTIVE.DATE,PROCESS.VALUE,RATE.KEY,PRIN.DATA,INT.DATA)
    GOSUB SET.BALANCES        ;* update current BALANCES record with PRIN.DATA and INT.DATA
*
    GOSUB ADJUST.ACCRUALS     ;*  If backdated.
*
    RETURN
*
*
******************************
PROCESS.AP.PRINCIPAL.DECREASE:
******************************
*
    SAVE.SCHEDULE.TYPE = SCHEDULE.TYPE
    SAVE.PROCESS.VALUE = PROCESS.VALUE
*
    SCHEDULE.TYPE = "PD"      ;* decrease principal
    PROCESS.VALUE -= INTEREST.AMOUNT
    GOSUB UPDATE.PRINCIPAL
*
    AMOUNT.DIFF = PROCESS.VALUE         ;* to be stored in SWAP.BALANCES
*
    SCHEDULE.TYPE = SAVE.SCHEDULE.TYPE
    PROCESS.VALUE = SAVE.PROCESS.VALUE
*
    RETURN
*
*
**********************
UPDATE.ANNUITY.AMOUNT:
**********************
*
    CALL CONV.SW.CALCULATE.INTEREST(SCHED.LEG.TYPE)
*
    IF SCHED.LEG.TYPE = 'A' THEN
        FIRST.INTEREST = R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT>
*
* work out index to the AP schedule
*
        SWAP.TYPE.LIST = R$SWAP<SW.AS.TYPE>
        AP.IDX = ''
        GOSUB GET.AP.INDEX
        FREQ = R$SWAP<SW.AS.DATE.FREQ, AP.IDX>[9,5]
*
    END ELSE
*
        FIRST.INTEREST = R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT>
*
* work out index to the AP schedule
*
        SWAP.TYPE.LIST = R$SWAP<SW.LB.TYPE>
        AP.IDX = ''
        GOSUB GET.AP.INDEX
        FREQ = R$SWAP<SW.LB.DATE.FREQ, AP.IDX>[9,5]
    END
*
    IF NOT(AP.IDX) THEN
        RETURN      ;* just in case
    END
*
    CCY = R$SW.BALANCES<SW.BAL.CURRENCY>
    OS.PRIN = R$SW.BALANCES<SW.BAL.PRINCIPAL, 1>
    INTEREST.RATE = R$SW.BALANCES<SW.BAL.INTEREST.RATE, 1>
*
* calculate number of payments outstanding
*
    START.DATE = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
    END.DATE = R$SWAP<SW.MATURITY.DATE>
    NYEARS = END.DATE[1,4] - START.DATE[1,4]
    NMONTHS = END.DATE[5,2] - START.DATE[5,2]
    NO.OF.MONTHS = NYEARS * 12 + NMONTHS
    LIFE = NO.OF.MONTHS / FREQ[2,2]
*
* calculate annuity
*
    DAY.BASIS = ""
    CALC.AMOUNT = ''
    ROUNDING = ""
    CALL EB.CALC.REPAYMENT(OS.PRIN,CCY,INTEREST.RATE,LIFE,FREQ,'ANNUITY',
    FIRST.INTEREST,0,0,DAY.BASIS,ROUNDING,CALC.AMOUNT)
*
    IF SCHED.LEG.TYPE = 'A' THEN
        R$SWAP<SW.AS.AMOUNT, AP.IDX> = CALC.AMOUNT
    END ELSE
        R$SWAP<SW.LB.AMOUNT, AP.IDX> = CALC.AMOUNT
    END
*
    RETURN
*
*************************************************************************
*
*************************
SET.COMMON.SWAP.BALANCES:
*************************
*
    IF SCHED.LEG.TYPE = "A" THEN
        R$SW.BALANCES = R$SW.ASSET.BALANCES
    END ELSE
        R$SW.BALANCES = R$SW.LIABILITY.BALANCES
    END
*
    RETURN
*
*
***********************
SET.REAL.SWAP.BALANCES:
***********************
*
    IF SCHED.LEG.TYPE = "A" THEN
        R$SW.ASSET.BALANCES = R$SW.BALANCES
    END ELSE
        R$SW.LIABILITY.BALANCES = R$SW.BALANCES
    END
*
    RETURN
*
*
******************************************************************
* setup PRIN.DATA and INT.DATA before call to SW.UPDATE.BALANCES *
******************************************************************
*
*************
GET.BALANCES:
*************
*
    PRIN.DATA = ""
    PRIN.DATA<EB.ACP.PRIN.EFF.DATE> = R$SW.BALANCES<SW.BAL.PRIN.DATE>
    PRIN.DATA<EB.ACP.PRIN.AMOUNT> = R$SW.BALANCES<SW.BAL.PRINCIPAL>
*
    INT.DATA = ""
    INT.DATA<EB.ACI.INT.EFF.DATE> = R$SW.BALANCES<SW.BAL.EFFECTIVE.DATE>
    INT.DATA<EB.ACI.INT.KEY> = R$SW.BALANCES<SW.BAL.INTEREST.KEY>
    INT.DATA<EB.ACI.INT.RATE> = R$SW.BALANCES<SW.BAL.INTEREST.RATE>
*
    RETURN
*
*
*******************************************************************
* update current BALANCES record after call to SW.UPDATE.BALANCES *
*******************************************************************
*
*************
SET.BALANCES:
*************
*
    R$SW.BALANCES<SW.BAL.PRIN.DATE> = PRIN.DATA<EB.ACP.PRIN.EFF.DATE>
    R$SW.BALANCES<SW.BAL.PRINCIPAL> = PRIN.DATA<EB.ACP.PRIN.AMOUNT>
*
    R$SW.BALANCES<SW.BAL.EFFECTIVE.DATE> = INT.DATA<EB.ACI.INT.EFF.DATE>
    R$SW.BALANCES<SW.BAL.INTEREST.KEY> = INT.DATA<EB.ACI.INT.KEY>
    R$SW.BALANCES<SW.BAL.INTEREST.RATE> = INT.DATA<EB.ACI.INT.RATE>
*
    RETURN
*
*
************************************************************
*  If there is a backdated schedule then adjust accruals.  *
************************************************************
*
****************
ADJUST.ACCRUALS:
****************
*
    IF APPLICATION EQ 'ENQUIRY.SELECT' THEN
        RETURN
    END
* Check only SCHED.DATE AND ACCT.TO.DATE
    FORW.SCH = SCHEDULE.DATE GT TODAY

* Don't proceed for accrual adjustment for forward dated schedules. This will be handled during the EOD
* on the schedule date

    IF (SCHEDULE.DATE LE R$SW.BALANCES<SW.BAL.ACCR.TO.DATE,1>) OR ((SCHEDULE.TYPE[1,2] EQ 'RR' OR Y.MKT.EXCH.CALC) AND EFF.IN.BETWEEN.IP AND NOT(FORW.SCH) ) THEN
        GOSUB SET.REAL.SWAP.BALANCES
*
        ACCRUAL.TO.DATE = R$SW.BALANCES<SW.BAL.ACCR.TO.DATE,1>
        IF Y.MKT.EXCH.CALC AND EFF.IN.BETWEEN.IP THEN
* Adjustments of accruals will take place from the first day of the start interest date
* of the current interest period, if an IP has already been processed.
            ADJUSTMENT.DATE = EFFECTIVE.DATE
        END ELSE
            ADJUSTMENT.DATE = SCHEDULE.DATE
        END

        CALL CONV.SW.PERFORM.ACCRUAL(ACCRUAL.TO.DATE,ADJUSTMENT.DATE,SCHED.LEG.TYPE)
*
        GOSUB SET.COMMON.SWAP.BALANCES
    END
*
    RETURN
*
*
*************
GET.AP.INDEX:
*************
*
    FOR YI = 1 TO DCOUNT(SWAP.TYPE.LIST, VM)
        IF SWAP.TYPE.LIST<1, YI>[1,2] = "AP" THEN
            AP.IDX = YI
            RETURN
        END
    NEXT YI
*
    RETURN
*
*************************************************************************
*
************************************************************
*  Update the processed date on the swap contract and the  *
*  schedules past fields on the swap balances record for   *
*  all schedules that are not forward.                     *
************************************************************
*
**********************************
UPDATE.SCHEDULE.AND.CHARGE.FIELDS:
**********************************
*
    GOSUB SET.COMMON.SWAP.BALANCES
*
* update the normal schedules
*
    CHARGE.CODE = ""
    GOSUB UPDATE.SCHEDULE.FIELDS
*
* update swap.balances with charge details
*
    SCHED.IDX = ''
    VMC = DCOUNT(CHARGE.DETAILS<1>, VM)
    FOR YI = 1 TO VMC
        CHARGE.CODE = CHARGE.DETAILS<1, YI>
        LCY.AMOUNT = CHARGE.DETAILS<2, YI>
        PROCESS.VALUE = CHARGE.DETAILS<3, YI>     ;* charge is +ve and fee is -ve
        IF NOT(PROCESS.VALUE) THEN
            PROCESS.VALUE = LCY.AMOUNT
        END
        GOSUB UPDATE.SCHEDULE.FIELDS
    NEXT YI
*
    GOSUB SET.REAL.SWAP.BALANCES
*
    RETURN
*
****************************
FIND.NEXT.AVAILABLE.IP.DATE:
****************************
* To find the next available IP schedule
    YIDX = 0
    LOOP YIDX+=1 UNTIL Y.ASSET.TYPES<1,YIDX> = ""
        IF Y.ASSET.TYPES<1,YIDX> = 'IP' AND Y.SCHED.DATE<1,YIDX> GT TODAY THEN
            END.INT.PERIOD = Y.SCHED.DATE<1,YIDX>
            EXIT
        END ELSE
            CONTINUE
        END
    REPEAT
    RETURN
*
***********************
UPDATE.SCHEDULE.FIELDS:
***********************
*
    START.INT.PERIOD = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
    IF SCHEDULE.TYPE[1,2] = 'CI' THEN
        END.INT.PERIOD = ''
    END ELSE
        END.INT.PERIOD = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
    END
*
* To populate the START and END PERIOD of Schedules in SWAP.BALANCES correctly
    IF NOT(Y.STATUS.FLAG) AND SCHEDULE.TYPE[1,2] = 'RR' THEN
        Y.ASSET.TYPES = '' ; Y.SCHED.DATE = ''
        IF SCHED.LEG.TYPE = "A" THEN
            Y.ASSET.TYPES = Y.AS.ASSET.TYPES
            Y.SCHED.DATE = Y.AS.SCHED.DATE
        END ELSE
            Y.ASSET.TYPES = Y.LB.ASSET.TYPES
            Y.SCHED.DATE = Y.LB.SCHED.DATE
        END
        GOSUB FIND.NEXT.AVAILABLE.IP.DATE
    END

    IF PROCESS.DATE GT R.DATES(EB.DAT.PERIOD.END) AND ENQUIRY.MODE = 2 THEN
        RETURN
    END
*  (SCHED.IDX = Schedule index back to the swap contract
*   schedule - held in SCHEDULE.LIST)
    IF SCHED.IDX THEN         ;* Do not stem process date for CI and CM scheds.
        IF SCHED.LEG.TYPE = "A" THEN
            R$SWAP<SW.AS.PROCESSED,SCHED.IDX> = PROCESS.DATE
        END ELSE
            R$SWAP<SW.LB.PROCESSED,SCHED.IDX> = PROCESS.DATE
        END
    END
*
*  change PROCESS.VALUE to RESET.RATE if "RR"
*
    RESET.RATE = ''
    IF SCHEDULE.TYPE[1,2] = 'RR' THEN
        RESET.RATE = PROCESS.VALUE
        PROCESS.VALUE = ''
    END
*
    GOSUB UPDATE.SWAP.BALANCES
*
    RETURN
*
*************************************************************************
*
************
FATAL.ERROR:
************
*
    TEXT = ETEXT
    CALL FATAL.ERROR("SW.SCHEDULE.PROCESSING")
*
    RETURN
*
*************************************************************************
***********************
GET.AS.END.INT.PERIOD:
***********************
    IF R$SWAP<SW.AS.CURRENCY> THEN
        LEG.TYPE = "A"
        CALL CONV.SW.DETERMINE.FIELDS(LEG.TYPE)   ;* Asset leg
        Y.AS.ASSET.TYPES = R$SWAP<SWAP$TYPE>
        Y.AS.SCHED.DATE = R$SWAP<SWAP$DATE.FREQ>[1,8]
        EARLIEST.DATE = ""
        CALL CONV.SW.DETERMINE.END.INT.PERIOD(EARLIEST.DATE)
*
* either perform accrual adjustment or re-calc interest if interest period is changed
        IF EARLIEST.DATE NE R$SW.ASSET.BALANCES<SW.BAL.END.INT.PERIOD> THEN
            NEW.AS.END.INT.PERIOD = EARLIEST.DATE
        END
*
        R$SW.ASSET.BALANCES<SW.BAL.END.INT.PERIOD> = EARLIEST.DATE
    END

    RETURN
*
***********************
GET.LB.END.INT.PERIOD:
***********************
    IF R$SWAP<SW.LB.CURRENCY> THEN
        LEG.TYPE = "L"
        CALL CONV.SW.DETERMINE.FIELDS(LEG.TYPE)   ;* Liability leg
        Y.LB.ASSET.TYPES = R$SWAP<SWAP$TYPE>
        Y.LB.SCHED.DATE = R$SWAP<SWAP$DATE.FREQ>[1,8]
        EARLIEST.DATE = ""
        CALL CONV.SW.DETERMINE.END.INT.PERIOD(EARLIEST.DATE)
*
        IF EARLIEST.DATE NE R$SW.LIABILITY.BALANCES<SW.BAL.END.INT.PERIOD> THEN
            NEW.LB.END.INT.PERIOD = EARLIEST.DATE
        END
*
        R$SW.LIABILITY.BALANCES<SW.BAL.END.INT.PERIOD> = EARLIEST.DATE
    END

    RETURN
*************************
SET.UP.PROCESS.VALUE:
*************************
    INTEREST.AMOUNT = R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT> ;* Interest to post
    IF SCHEDULE.TYPE[1,2] = "AP" AND PROCESS.VALUE > INTEREST.AMOUNT THEN
        GOSUB PROCESS.AP.PRINCIPAL.DECREASE
    END ELSE
        PROCESS.VALUE = INTEREST.AMOUNT ;* ensure that it's sufficient to pay off the interest of an "AP"

        IF R$SW.BALANCES<SW.BAL.MKT.INT.AMOUNT> THEN
            MKT.PROCESS.VALUE = R$SW.BALANCES<SW.BAL.MKT.INT.AMOUNT>
        END
    END

    RETURN
**************************
UPDATE.SWAP.BALANCES:
**************************
    INS SCHEDULE.TYPE BEFORE R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,1>
    INS CHARGE.CODE BEFORE R$SW.BALANCES<SW.BAL.CHARGE.CODE,1>
    INS SCHEDULE.DATE BEFORE R$SW.BALANCES<SW.BAL.SCHEDULE.DATE,1>
    INS PROCESS.DATE BEFORE R$SW.BALANCES<SW.BAL.PROCESS.DATE,1>
    INS START.INT.PERIOD BEFORE R$SW.BALANCES<SW.BAL.PERIOD.START,1>
    INS END.INT.PERIOD BEFORE R$SW.BALANCES<SW.BAL.PERIOD.END,1>
    INS EFFECTIVE.DATE BEFORE R$SW.BALANCES<SW.BAL.SCHED.EFF.DATE,1>
    INS PROCESS.VALUE BEFORE R$SW.BALANCES<SW.BAL.CCY.AMOUNT,1>       ;* signed if charge.code presents
    INS RESET.RATE BEFORE R$SW.BALANCES<SW.BAL.RESET.RATE,1>
    INS LCY.AMOUNT BEFORE R$SW.BALANCES<SW.BAL.LCL.AMOUNT,1>
    INS AMOUNT.DIFF BEFORE R$SW.BALANCES<SW.BAL.AMOUNT.DIFF,1>        ;* amount difference in IS and AP
    INS ENTRY.DATE BEFORE R$SW.BALANCES<SW.BAL.VALUE.DATE,1>
    INS MKT.PROCESS.VALUE BEFORE R$SW.BALANCES<SW.BAL.MKT.CCY.AMT,1>

    RETURN
*
END
