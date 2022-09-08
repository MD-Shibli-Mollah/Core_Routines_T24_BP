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
* <Rating>503</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.CYCLE.SCHEDULES(ENQUIRY.MODE)
*
************************************************************************
*                                                                      *
*  Routine     :  CONV.SW.CYCLE.SCHEDULES                                   *
* Duplicate of SW.CYCLE.SCHEDULES.
************************************************************************
*                                                                      *
*  Description :  This routine is called during authorisation or from  *
*                 the End Of Day schedule processing.                  *
*                                                                      *
*                 It cycles all schedules that have been processed     *
*                 and prepares the contract for the next event.        *
*                                                                      *
*                 If no schedules have been processed then this        *
*                 routine is exited.                                   *
*                                                                      *
* It can also be called in ENQUIRY.MODE in which case the schedules    *
* are cycled but no history records are written.                       *
*                                                                      *
************************************************************************
*                                                                      *
*  Modifications :                                                     *
*                                                                      *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*                                                                      *
*
* 14/06/07 - BG_100014209
*            Changes to called routines with incorrect number of arguments / non-existent routine.
*
* 18/06/09 - EN_10004169
*            Restructing of SW.EOD.SCHEDULE job for performance.
*            Merging of SW.SOD.MATURITY and SW.SOD.PROCESSING to SW.SOD.PROCESS.
*
************************************************************************
*
****************
* Insert files.
****************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_SW.COMMON
    $INSERT I_BATCH.FILES
    $INSERT I_F.DATES
*
************************************************************************
*
*************
MAIN.PROCESS:
*************
*
    GOSUB INITIALISATION
*
*  See if the contract has matured or not
*  Check the asset side first
*
    PAST.SCHEDULE.TYPES = R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE>
    LOCATE 'CM' IN PAST.SCHEDULE.TYPES<1,1> SETTING SPOS THEN
        R$SWAP<SW.ASSET.STATUS> = "MAT"
    END
*
*  Then the liability side
*
    PAST.SCHEDULE.TYPES = R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE>
    LOCATE 'CM' IN PAST.SCHEDULE.TYPES<1,1> SETTING SPOS THEN
        R$SWAP<SW.LIABILITY.STATUS> = "MAT"
    END
*
*  If no schedules have been processed then exit this routine.
*
    ANY.PROCESSED = R$SWAP<SW.AS.PROCESSED>:VM:R$SWAP<SW.LB.PROCESSED>
    CONVERT VM TO " " IN ANY.PROCESSED
    ANY.PROCESSED = TRIM(ANY.PROCESSED) ;* Will contain something if processed
*
    IF NOT(ANY.PROCESSED) THEN
        GOSUB UPDATE.CONTRACT.STATUS    ;* also update swap.ent.today on maturity
        RETURN
    END
*
    IF NOT(ENQUIRY.MODE) THEN ;* The real thing
        GOSUB PROCESS.CONTRACT
    END
*
    SCHED.LEG.TYPE = "A"      ;*  Asset leg.
    CALL CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
    R$SW.BALANCES = R$SW.ASSET.BALANCES
    LEG.STATUS.FIELD = SW.ASSET.STATUS
    IF R$SWAP<SWAP$PROCESSED> <> "" THEN
        GOSUB PROCESS.SCHEDULES
    END
    R$SW.ASSET.BALANCES = R$SW.BALANCES
*
    SCHED.LEG.TYPE = "L"      ;*  Liability leg.
    CALL CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
    R$SW.BALANCES = R$SW.LIABILITY.BALANCES
    LEG.STATUS.FIELD = SW.LIABILITY.STATUS
    IF R$SWAP<SWAP$PROCESSED> <> "" THEN
        GOSUB PROCESS.SCHEDULES
    END
    R$SW.LIABILITY.BALANCES = R$SW.BALANCES
*
*  Finally, ensure contract.status is in sync with leg.status
*
    GOSUB UPDATE.CONTRACT.STATUS
*
    RETURN
*
************************************************************************
*
***************
INITIALISATION:
***************
*
    F.SWAP = ""
    FN.SWAP = "F.SWAP"
    CALL OPF(FN.SWAP,F.SWAP)
*
    F.SWAP$HIS = ""
    FN.SWAP$HIS = "F.SWAP$HIS"
    CALL OPF(FN.SWAP$HIS,F.SWAP$HIS)
*
    F.SWAP.ENT.TODAY = ""
    FN.SWAP.ENT.TODAY = "F.SWAP.ENT.TODAY"
    CALL OPF(FN.SWAP.ENT.TODAY,F.SWAP.ENT.TODAY)
*
    Y.SCHED.TYPE = '' ; Y.SCHED.DATE = '' ; Y.LEG.TYPE = '' ; SCHEDULE.LIST = ''
*
    IF RUNNING.UNDER.BATCH THEN
        IF SWAP$SCHEDULE.STAGE EQ "SW.SOD.PROCESS" THEN
            Y.CURRENT.DATE = TODAY
        END ELSE
            Y.CURRENT.DATE = R.DATES(EB.DAT.PERIOD.END)
        END
    END ELSE
        Y.CURRENT.DATE = TODAY
    END
*
    RETURN
*
************************************************************************
*
***********************
UPDATE.CONTRACT.STATUS:
***********************
*
*  It must be one-legged swap if leg currency is not known
*
    ASSET.LEG.ONLY = (R$SWAP<SW.AS.CURRENCY> AND NOT(R$SWAP<SW.LB.CURRENCY>))
    LIABILITY.LEG.ONLY = (R$SWAP<SW.LB.CURRENCY> AND NOT(R$SWAP<SW.AS.CURRENCY>))
*
    BEGIN CASE
    CASE ASSET.LEG.ONLY
        IF R$SWAP<SW.ASSET.STATUS> = "MAT" THEN
            R$SWAP<SW.CONTRACT.STATUS> = "MAT"
        END
*
    CASE LIABILITY.LEG.ONLY
        IF R$SWAP<SW.LIABILITY.STATUS> = "MAT" THEN
            R$SWAP<SW.CONTRACT.STATUS> = "MAT"
        END
*
    CASE OTHERWISE
        IF R$SWAP<SW.ASSET.STATUS> = "MAT" AND R$SWAP<SW.LIABILITY.STATUS> = "MAT" THEN
            R$SWAP<SW.CONTRACT.STATUS> = "MAT"
        END
    END CASE
*
* GB9700625
    IF NOT(ENQUIRY.MODE) AND R$SWAP<SW.CONTRACT.STATUS> = "MAT" THEN
        CALL SW.UPDATE.LIMITS("REV")
    END
*
* update SWAP.ENT.TODAY with a copy of R$SWAP for static change processing
* only when ENQUIRY.MODE is not set, i.e. the real thing
* if a record exists already, then don't bother
*
    IF NOT(ENQUIRY.MODE) AND ((R$SWAP<SW.ASSET.STATUS> = "MAT") OR (R$SWAP<SW.LIABILITY.STATUS> = "MAT")) THEN
        YERR = ''
        CALL F.READV(FN.SWAP.ENT.TODAY, C$SWAP.ID, '', 0, F.SWAP.ENT.TODAY, YERR)
        IF YERR THEN
            CALL F.WRITE(FN.SWAP.ENT.TODAY, C$SWAP.ID, R$SWAP)
        END
    END
*
    RETURN
*
************************************************************************
*
*****************
PROCESS.CONTRACT:
*****************
*
*  Write live contract to swap history file.
*
    R.SWAP = ""
    ERR.TXT = ""
    CALL F.READ(FN.SWAP,C$SWAP.ID,R.SWAP,F.SWAP,ERR.TXT)
    IF NOT(ERR.TXT) THEN
        SW.HIST.ID = C$SWAP.ID:";":R.SWAP<SW.CURR.NO>
        CALL F.WRITE(FN.SWAP$HIS,SW.HIST.ID,R.SWAP)
    END
*
*  Write current contract held in common to swap live file.
*  This is with the processed schedules.
*
    R$SWAP<SW.RECORD.STATUS> = ''       ;* record status should be blank in live
    CALL F.WRITE(FN.SWAP,C$SWAP.ID,R$SWAP)
*
*  Increment curr.no for the new live record.
*
    R$SWAP<SW.CURR.NO> = R$SWAP<SW.CURR.NO> + 1
*
*  Clear entry.ids and override fields.
*
    R$SWAP<SW.ENTRY.IDS> = ""
    R$SWAP<SW.OVERRIDE> = ""
*
*  The new live record will have the latest CURR.NO
*  but without the processed schedules, ENTRY.IDS and OVERRIDE
*
    RETURN
*
************************************************************************
*
******************
PROCESS.SCHEDULES:
******************
*
    CYCLE.INTEREST.PERIOD = 0
    IP.COUNT = 0
    IP.PROCESSED = ''
    IP.AP.IDX = ''
*
    NUM.SCHED.TYPES = DCOUNT(R$SWAP<SWAP$TYPE>,VM)
    FOR SCHED.IDX = NUM.SCHED.TYPES TO 1 STEP -1
        Y.EOD.SCHEDULE = 0
        IF R$SWAP<SWAP$PROCESSED,SCHED.IDX> THEN
            IF R$SWAP<SWAP$DATE.FREQ,SCHED.IDX>[9,5] THEN
                GOSUB CYCLE.FREQ

* To write SWAP.SCHEDULES record for the newly cycled Schedule date
                IF NOT(ENQUIRY.MODE) THEN
                    GOSUB UPDATE.SCHEDULES
                END

*  If next interest period is beyond maturity then set it to the maturity date
                IF CYCLE.INTEREST.PERIOD AND Y.EOD.SCHEDULE THEN
                    IF COMI[1,8] > R$SWAP<SW.MATURITY.DATE> THEN
                        R$SWAP<SWAP$DATE.FREQ,SCHED.IDX> = R$SWAP<SW.MATURITY.DATE>
                        EARLIEST.DATE = ""
                        CALL CONV.SW.DETERMINE.END.INT.PERIOD(EARLIEST.DATE)
                        IF EARLIEST.DATE <= R$SW.BALANCES<SW.BAL.END.INT.PERIOD> THEN
                            CYCLE.INTEREST.PERIOD = 0
                            GOSUB REMOVE.SCHEDULE
                        END
                    END ELSE
                        IF COMI[1,8] <= R$SW.BALANCES<SW.BAL.END.INT.PERIOD> THEN
                            CYCLE.INTEREST.PERIOD = 0
                        END
                    END
                END ELSE
                    IF COMI[1,8] >= R$SWAP<SW.MATURITY.DATE> THEN
                        GOSUB REMOVE.SCHEDULE
                    END
                END
            END ELSE
* Allow multiple IP
                IF R$SWAP<SWAP$TYPE,SCHED.IDX>[1,2] = 'IP' THEN
                    IP.COUNT += 1
                    IP.PROCESSED = 1
                END

                GOSUB REMOVE.SCHEDULE   ;*  Remove schedule if no frequency code
            END
*  Remove schedules where the next eff date is GT the maturity date or
*  final sched date.
            IF (R$SWAP<SWAP$DATE.FREQ,SCHED.IDX>[1,8] > R$SWAP<SW.MATURITY.DATE>) OR (R$SWAP<SWAP$FINAL.SCHED,SCHED.IDX> AND R$SWAP<SWAP$DATE.FREQ,SCHED.IDX>[1,8] > R$SWAP<SWAP$FINAL.SCHED,SCHED.IDX>) THEN
                GOSUB REMOVE.SCHEDULE
            END
        END ELSE    ;* schedule not processed
            IF R$SWAP<SWAP$TYPE,SCHED.IDX>[1,2] = 'IP' THEN
                IP.COUNT += 1
            END
        END
    NEXT SCHED.IDX

*  Set the INTEREST.AMOUNT to null if a contract is matured
    IF R$SWAP<LEG.STATUS.FIELD> = "MAT" THEN
        R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT> = ""
        R$SW.BALANCES<SW.BAL.MKT.INT.AMOUNT> = ""
    END
*
*  Perform additional updates if an Interest Payment schedule
*  has been cycled.
*
    IF CYCLE.INTEREST.PERIOD OR (IP.PROCESSED AND IP.COUNT > 1) THEN
        GOSUB UPD.INTR.PERIOD.DETS
    END
*
    RETURN
*
*------------
CYCLE.FREQ:
*------------
    IF R$SWAP<SWAP$TYPE,SCHED.IDX>[1,2] MATCHES 'IP':VM:'AP' THEN
        Y.EOD.SCHEDULE = 1
        IF R$SW.BALANCES<SW.BAL.END.INT.PERIOD> < R$SWAP<SW.MATURITY.DATE> THEN
            CYCLE.INTEREST.PERIOD = 1
            IP.AP.IDX = SCHED.IDX       ;* reference back to the IP/AP schedule
        END
    END
*  Calculate new date.
    COMI = R$SWAP<SWAP$DATE.FREQ,SCHED.IDX>
    CALL CFQ

    IF ENQUIRY.MODE AND RUNNING.UNDER.BATCH THEN
        C$SW.NEW.INTEREST.PERIOD = COMI[1,8]
    END

    R$SWAP<SWAP$DATE.FREQ,SCHED.IDX> = COMI
    IF R$SWAP<SWAP$TYPE,SCHED.IDX>[1,2] EQ 'RR' THEN
        R$SWAP<SWAP$RATE,SCHED.IDX> = ""          ;* Clear previous RR Value when cycled to new date
    END

    R$SWAP<SWAP$ADVICE.SENT,SCHED.IDX> = ""
    R$SWAP<SWAP$PROCESSED,SCHED.IDX> = ""

    RETURN

************************************************************************
*
*****************
UPDATE.SCHEDULES:
*****************
    Y.SCHED.TYPE = R$SWAP<SWAP$TYPE,SCHED.IDX>[1,2]
    Y.SCHED.DATE = COMI[1,8]

    IF Y.SCHED.DATE GE R$SWAP<SW.MATURITY.DATE> THEN
        IF NOT(Y.EOD.SCHEDULE) THEN
            RETURN
        END ELSE
            IF NOT(RUNNING.UNDER.BATCH) THEN
                RETURN
            END
            Y.SCHED.DATE = R$SWAP<SW.MATURITY.DATE>
            R$SWAP<SWAP$DATE.FREQ,SCHED.IDX> = Y.SCHED.DATE
        END
    END

    Y.LEG.TYPE = SCHED.LEG.TYPE
    Y.FILTER.LIST = Y.SCHED.DATE:'..':Y.LEG.TYPE:'.':Y.SCHED.TYPE

    CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,Y.FILTER.LIST)
    IF Y.SCHED.TYPE NE 'RR' THEN
        SCHEDULE.LIST<10,1> = TODAY     ;* To handle Message related processing during COB
    END
*
    IF Y.EOD.SCHEDULE THEN
        GOSUB GET.UPDATED.IP.AMOUNT
    END
*
    CALL CONV.SW.DETERMINE.ACTIVITY(SCHEDULE.LIST)

* Send message only if Activity due date is today
    IF SCHEDULE.LIST<11,1> AND (SCHEDULE.LIST<11,1> LE Y.CURRENT.DATE) THEN
        Y.SAVE.COMI = COMI
        Y.SAVE.LEG.TYPE = SCHED.LEG.TYPE
        Y.SAVE.OLD.SCHED.DATE = Y.OLD.SCHED.DATE
        Y.SAVE.SCHED.TYPE = Y.SCHED.TYPE
        Y.SAVE.SCHED.DATE = Y.SCHED.DATE

        CALL CONV.SW.DELIVERY ;* Need to call, if the cycled schedule falls on TODAY

        SCHEDULE.LIST<10,1> = ''
        SCHEDULE.LIST<11,1> = ''

        COMI = Y.SAVE.COMI
        SCHED.LEG.TYPE = Y.SAVE.LEG.TYPE
        Y.OLD.SCHED.DATE = Y.SAVE.OLD.SCHED.DATE
        Y.SCHED.TYPE = Y.SAVE.SCHED.TYPE
        Y.SCHED.DATE = Y.SAVE.SCHED.DATE
        CALL CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
    END
*
    IF Y.SCHED.TYPE EQ 'RR' THEN
        SCHEDULE.LIST<6> = ''
    END

    CALL CONV.SW.UPDATE.SCHEDULES.200507(SCHEDULE.LIST,0)
* Code related to store the COMI Value in DATE FREQ removed - S/E
    RETURN
*
************************************************************************
*

**********************
GET.UPDATED.IP.AMOUNT:
**********************
* To get the updated process value for newly cycled IP schedule
    Y.SEARCH.IDX = ''
    Y.KEY.INDEX = Y.SCHED.TYPE:Y.SCHED.DATE

* Get the updated value from the Full Balances record which is available
* in a common variable(assigned from SW.SCHEDULE.PROCESSING)
    IF Y.LEG.TYPE = 'A' THEN
        Y.TYPE = Y.FULL.AS.BALANCES<SW.BAL.SCHEDULE.TYPE>
        Y.DATE = Y.FULL.AS.BALANCES<SW.BAL.SCHEDULE.DATE>
        Y.AMT = Y.FULL.AS.BALANCES<SW.BAL.CCY.AMOUNT>
    END ELSE
        Y.TYPE = Y.FULL.LB.BALANCES<SW.BAL.SCHEDULE.TYPE>
        Y.DATE = Y.FULL.LB.BALANCES<SW.BAL.SCHEDULE.DATE>
        Y.AMT = Y.FULL.LB.BALANCES<SW.BAL.CCY.AMOUNT>
    END

    NUM.SCHED.TYPES = DCOUNT(Y.TYPE,VM)
    FOR Y.IDX = 1 TO NUM.SCHED.TYPES
        Y.SEARCH.IDX = Y.TYPE<1,Y.IDX>:Y.DATE<1,Y.IDX>[1,8]
        IF Y.SEARCH.IDX EQ Y.KEY.INDEX THEN
* Assign the updated IP amount in the SCHEDULE.LIST
            SCHEDULE.LIST<6,1> = Y.AMT<1,Y.IDX>
            RETURN
        END
    NEXT Y.IDX
    RETURN
*
************************************************************************
*
****************
REMOVE.SCHEDULE:
****************
*
*  Once an RX sched has been processed and removed, then no other
*  schedules are allowed for that leg.
*  Also set the ASSET/LIABILITY.STATUS to 'MAT'
*
    IF IP.PROCESSED AND IP.COUNT > 1 THEN
        R$SW.BALANCES<SW.BAL.START.INT.PERIOD> = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
    END

    IF R$SWAP<SWAP$TYPE,SCHED.IDX>[1,2] = "RX" THEN
        FOR YI = SWAP$TYPE TO SWAP$PROCESSED
            R$SWAP<YI> = ""
        NEXT YI
        R$SWAP<LEG.STATUS.FIELD> = "MAT"
    END
*
    FOR YI = SWAP$TYPE TO SWAP$PROCESSED
        DEL R$SWAP<YI, SCHED.IDX>
    NEXT YI
*
    RETURN
*
************************************************************************
*
***************************************************
*  If an Interest Payment schedule has been       *
*  cycled, then the next interest period details  *
*  must be stored on the balances record.         *
***************************************************
*
*********************
UPD.INTR.PERIOD.DETS:
*********************
*  Move the end.int.period date to start.int.period.
    R$SW.BALANCES<SW.BAL.START.INT.PERIOD> = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>

*  Set the end.int.period to the effective date of the earliest interest
*  payment or the effective date of the maturity/rx schedule,
*  whichever is earliest.
    EARLIEST.DATE = ""
    CALL CONV.SW.DETERMINE.END.INT.PERIOD(EARLIEST.DATE)
    R$SW.BALANCES<SW.BAL.END.INT.PERIOD> = EARLIEST.DATE
    R$SW.BALANCES<SW.BAL.CRB.INTEREST.DATE> = EARLIEST.DATE ;* static change not required

*  Calculate interest for the new interest period
    IF SCHED.LEG.TYPE = 'A' THEN
        R$SW.ASSET.BALANCES = R$SW.BALANCES
    END ELSE
        R$SW.LIABILITY.BALANCES = R$SW.BALANCES
    END
    CALL CONV.SW.CALCULATE.INTEREST(SCHED.LEG.TYPE)
*
    Y.MKT.EXCH.INT.AMT = ''
    IF SCHED.LEG.TYPE = 'A' THEN
        INTEREST.AMOUNT = R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT>
        Y.MKT.EXCH.INT.AMT = R$SW.ASSET.BALANCES<SW.BAL.MKT.INT.AMOUNT>
    END ELSE
        INTEREST.AMOUNT = R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT>
        Y.MKT.EXCH.INT.AMT = R$SW.LIABILITY.BALANCES<SW.BAL.MKT.INT.AMOUNT>
    END
    R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT> = INTEREST.AMOUNT
    R$SW.BALANCES<SW.BAL.MKT.INT.AMOUNT> = Y.MKT.EXCH.INT.AMT

*  Need to update annuity amount if FINAL 'AP' period
    IF IP.AP.IDX AND R$SWAP<SWAP$TYPE,IP.AP.IDX>[1,2] = 'AP' AND EARLIEST.DATE = R$SWAP<SW.MATURITY.DATE> THEN
*  The final repayment must be INTEREST.AMOUNT + OUTSTANDING.PRINCIPAL
        OUTSTANDING.PRINCIPAL = R$SW.BALANCES<SW.BAL.PRINCIPAL, 1>
        FINAL.REPAYMENT = INTEREST.AMOUNT + OUTSTANDING.PRINCIPAL
        R$SWAP<SWAP$AMOUNT, IP.AP.IDX> = FINAL.REPAYMENT
    END
    RETURN
*
************************************************************************
*
************
FATAL.ERROR:
************
    TEXT = ETEXT
    CALL FATAL.ERROR("SW.CYCLE.SCHEDULES")
    RETURN
END
