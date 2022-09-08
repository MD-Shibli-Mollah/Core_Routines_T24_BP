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
* <Rating>1311</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Delivery
    SUBROUTINE CONV.SW.DETERMINE.ACTIVITY(SCHEDULE.LIST)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.DETERMINE.ACTIVITY                                 *
* Duplicate of SW.DETERMINE.ACTIVITY for conversion process.
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :  This routine examines all schedules on the current    *
*                 contract and updates the delivery fields when a       *
*                 delivery activity is due.  It will be called online   *
*                 when a contract is changed.  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Parameters  :  SCHEDULE.LIST - mandatory                         IN  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 18/06/09 - EN_10004169
*            Restructing of SW.EOD.SCHEDULE job for performance.
*            Merging of SW.SOD.MATURITY and SW.SOD.PROCESSING to SW.SOD.PROCESS.
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.SWAP.ACTIVITY
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_SW.COMMON
    $INSERT I_F.CURRENCY
    $INSERT I_F.SWAP.SCHEDULES
*
*************************************************************************
*
***********
* main body
***********
* initialisation

    R.SW.SCHEDULES = ''
    Y.SW.SCHED.ID = ID.NEW:'.':R$SWAP<SW.MATURITY.DATE>
    CALL F.READ(FN.SWAP.SCHEDULES, Y.SW.SCHED.ID, R.SW.SCHEDULES, F.SWAP.SCHEDULES, '')

    NET.PAYMENT.AMOUNT = ''   ;* for net payment
    LEG.TYPE = ''
    SCHEDULE.INDEX = ''
*
    SCHEDULES.TO.PROCESS = 'CI,PX,IS,IP,AP,RR,PI,PD,PM,RV,RX,CM,NI,ND'
    CONVERT ',' TO VM IN SCHEDULES.TO.PROCESS
*
    EOD.SCHEDULES = 'IP,AP,RX,CM'
    CONVERT ',' TO VM IN EOD.SCHEDULES
*
    Y.BUS.VM = ''
    IF R$SWAP<SW.AS.BUS.CENTRES> AND R$SWAP<SW.LB.BUS.CENTRES> THEN
        Y.BUS.VM = VM
    END
* clear delivery fields
    FOR I = SW.ACTIVITY TO SW.MSG.REF
        R$SWAP<I> = ''
    NEXT I
* clear SWAP.PAYMENT.DATE workfile
    CALL F.DELETE('F.SWAP.PAYMENT.DATE',ID.NEW)
*
*
* check amendment/reversal and set current date
* current date = TODAY when run online; otherwise period end date
*
    IF NOT(RUNNING.UNDER.BATCH) THEN    ;* it is online
        CURRENT.DATE = TODAY
        IF V$FUNCTION = 'R' OR R$SWAP<SW.RECORD.STATUS>[1,1] EQ 'R' THEN        ;* reversal
            ACTIVITY.DUE.DATE = TODAY
            ACTIVITY.CODE = 107         ;* contract reversal
            GOSUB UPDATE.ADVICE
        END ELSE
            IF V$FUNCTION = 'I' THEN    ;* amendment
                GOSUB CHECK.AMENDMENT
            END
        END
    END ELSE
        IF SWAP$SCHEDULE.STAGE EQ "SW.SOD.PROCESS" THEN
            CURRENT.DATE = TODAY
        END ELSE
            CURRENT.DATE = R.DATES(EB.DAT.PERIOD.END)
        END
    END
*
* process each schedule and update delivery fields if activity is due
*
    GOSUB PROCESS.SCHEDULE
*
    RETURN
*
*
****************
CHECK.AMENDMENT:
****************
*
* check for amendment and update delivery fields if change is found
*
    GOSUB BUILD.CHANGE.FIELD.LIST
*
    BASE.REC = R$SWAP         ;* this is R.NEW
    GOSUB BUILD.CHANGE.FIELD.REC
    NEW.REC = CHANGE.FIELD.REC
*
    BASE.REC = ''
    MATBUILD BASE.REC FROM R.OLD
*

    IF BASE.REC THEN          ;*  not a new entry
        GOSUB BUILD.CHANGE.FIELD.REC
        OLD.REC = CHANGE.FIELD.REC
*
        IF NEW.REC <> OLD.REC THEN
            ACTIVITY.DUE.DATE = TODAY
            ACTIVITY.CODE = 104         ;* contract amendment
            GOSUB UPDATE.ADVICE
        END
    END
*
    RETURN
*
*
************************
BUILD.CHANGE.FIELD.LIST:
************************
    CHANGE.FIELD.LIST = ''

* contract details
    CHANGE.FIELD.LIST<-1> = SW.MATURITY.DATE
    CHANGE.FIELD.LIST<-1> = SW.NET.PAYMENTS
    CHANGE.FIELD.LIST<-1> = SW.AGREEMENT.TYPE
    CHANGE.FIELD.LIST<-1> = SW.CONDITIONS

* asset details
    CHANGE.FIELD.LIST<-1> = SW.AS.PRINCIPAL
    CHANGE.FIELD.LIST<-1> = SW.AS.INT.EFFECTIVE
    CHANGE.FIELD.LIST<-1> = SW.AS.FIXED.RATE
    CHANGE.FIELD.LIST<-1> = SW.AS.RATE.KEY
    CHANGE.FIELD.LIST<-1> = SW.AS.SPREAD
    CHANGE.FIELD.LIST<-1> = SW.AS.FIXED.INTEREST
    CHANGE.FIELD.LIST<-1> = SW.AS.BASIS
    CHANGE.FIELD.LIST<-1> = SW.AS.DAY.CONVENTION
    CHANGE.FIELD.LIST<-1> = SW.AS.DATE.ADJUSTMENT
    CHANGE.FIELD.LIST<-1> = SW.AS.BUS.CENTRES
    CHANGE.FIELD.LIST<-1> = SW.AS.INTEREST.DET

* liability details
    CHANGE.FIELD.LIST<-1> = SW.LB.PRINCIPAL
    CHANGE.FIELD.LIST<-1> = SW.LB.INT.EFFECTIVE
    CHANGE.FIELD.LIST<-1> = SW.LB.FIXED.RATE
    CHANGE.FIELD.LIST<-1> = SW.LB.RATE.KEY
    CHANGE.FIELD.LIST<-1> = SW.LB.SPREAD
    CHANGE.FIELD.LIST<-1> = SW.LB.FIXED.INTEREST
    CHANGE.FIELD.LIST<-1> = SW.LB.BASIS
    CHANGE.FIELD.LIST<-1> = SW.LB.DAY.CONVENTION
    CHANGE.FIELD.LIST<-1> = SW.LB.DATE.ADJUSTMENT
    CHANGE.FIELD.LIST<-1> = SW.LB.BUS.CENTRES
    CHANGE.FIELD.LIST<-1> = SW.LB.INTEREST.DET

* settlement instructions
    PAYMENT.FIELD.LIST = ''

    RETURN
*
***********************
BUILD.CHANGE.FIELD.REC:
***********************
*
    CHANGE.FIELD.REC = ''
    FULL.SCHED.DETS = ''
    SORT.SCHED.DETS = ''
    SORT.INDEX = ''
    NO.OF.FIELDS = DCOUNT(CHANGE.FIELD.LIST, FM)
*
    FOR I = 1 TO NO.OF.FIELDS
        CHANGE.FIELD.REC<I> = BASE.REC<CHANGE.FIELD.LIST<I>>
    NEXT I
*
    SCHED.TYPE.ORDER = "CI,PX,IS,IP,AP,PI,NI,PD,ND,PM,RV,CC,RX,CM"
    CONVERT "," TO VM IN SCHED.TYPE.ORDER
    OFFSET = SW.LB.TYPE - SW.AS.TYPE
    FOR I = SW.AS.TYPE TO SW.AS.NARR
        FULL.SCHED.DETS<I-(SW.AS.TYPE-1)> = BASE.REC<I>:VM:BASE.REC<I+OFFSET>
    NEXT I
    NO.OF.TYPES = DCOUNT(FULL.SCHED.DETS<1>,VM)
    FOR I = 1 TO NO.OF.TYPES
        SCH.TYPE = FULL.SCHED.DETS<1,I>[1,2]
        SCH.DATE = FULL.SCHED.DETS<2,I>[1,8]
        LOCATE SCH.TYPE IN SCHED.TYPE.ORDER<1,1> SETTING TYP.IDX ELSE
            CONTINUE          ;* ignore invalid schedule type
        END
        SORT.KEY = SCH.DATE:FMT(TYP.IDX,"2'0'R")
        LOCATE SORT.KEY IN SORT.INDEX<1,1> BY "AR" SETTING POS ELSE
            NULL
        END
        INS SORT.KEY BEFORE SORT.INDEX<1,POS>
        FOR J = SW.AS.TYPE TO SW.AS.NARR
            INS FULL.SCHED.DETS<J-(SW.AS.TYPE-1),I> BEFORE SORT.SCHED.DETS<J-(SW.AS.TYPE-1),POS>
        NEXT J
    NEXT I
    IF SORT.SCHED.DETS THEN
        CHANGE.FIELD.REC<-1> = SORT.SCHED.DETS
    END
    RETURN
*
*
******************
GET.DAYS.DELIVERY:
******************
* Priority 1 - Get DAYS.DELIVERY from SWAP contract
    NDAYS = 0 ; R.SWAP.ACTIVITY = '' ; R.CURRENCY = '' ; LEG.CCY = ''
    IF LEG.TYPE EQ 'L' THEN
        COUNTRY.CODE = R$SWAP<SW.LB.BUS.CENTRES>
        LEG.CCY = R$SWAP<SW.LB.CURRENCY>
    END ELSE
        COUNTRY.CODE = R$SWAP<SW.AS.BUS.CENTRES>
        LEG.CCY = R$SWAP<SW.AS.CURRENCY>
    END

    NDAYS = R$SWAP<SW.DAYS.DELIVERY>

* Priority 2 - Get DAYS.DELIVERY from SWAP.ACTIVITY record
    IF NOT(NDAYS) THEN
        Y.ACT.CODE = ''
        IF PAYMENT.ACTIVITY.CODE THEN
            Y.ACT.CODE = PAYMENT.ACTIVITY.CODE
        END ELSE
            Y.ACT.CODE = ADVICE.ACTIVITY.CODE
        END
        CALL CACHE.READ('F.SWAP.ACTIVITY',Y.ACT.CODE,R.SWAP.ACTIVITY,"")
        NDAYS = R.SWAP.ACTIVITY<SW.ACT.DAYS.PRIOR.EVENT>
    END
*
* Priority 3 - Get DAYS.DELIVERY from CURRENCY record
    IF NOT(NDAYS) THEN
        CALL CACHE.READ('F.CURRENCY',LEG.CCY,R.CURRENCY,"")
        NDAYS = R.CURRENCY<EB.CUR.DAYS.DELIVERY>
    END
    RETURN
*
**********************
GET.ACTIVITY.DUE.DATE:
**********************
    NOSTRO.ACC = '' ; Y.DISP = ''
    CALL CDD('',CURRENT.DATE,PROCESS.DATE,Y.DISP)
    IF (Y.DISP < (NDAYS + 0) OR Y.DISP LT 0 OR ADVICE.ACTIVITY.CODE EQ '101') AND NOT(RUNNING.UNDER.BATCH) THEN
        ACTIVITY.DUE.DATE = CURRENT.DATE
    END ELSE
        IF SCHEDULE.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN
            COUNTRY.CODE = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>
        END
        CALL EB.DETERMINE.ACTIVITY.DATE(PROCESS.DATE, NDAYS, COUNTRY.CODE, LEG.CCY, ACTIVITY.DUE.DATE, NOSTRO.ACC)
        IF RUNNING.UNDER.BATCH THEN
            CALL CDT('', ACTIVITY.DUE.DATE, '+1C')
        END
    END
    RETURN
*
*********************
UPDATE.SCHEDULE.LIST:
*********************
* To populate Activity code & date, which are used to store in SWAP.SCHEDULES
    IF PAYMENT.ACTIVITY.CODE THEN
        SCHEDULE.LIST<10,SIDX> = PAYMENT.ACTIVITY.CODE
    END ELSE
        SCHEDULE.LIST<10,SIDX> = ADVICE.ACTIVITY.CODE
    END

    Y.ACTIVITY.DUE.DATE = ACTIVITY.DUE.DATE
    IF R$SWAP<SW.SOD.MAT> NE "YES" THEN
        CALL CDT('', Y.ACTIVITY.DUE.DATE, '-1W')
    END
    SCHEDULE.LIST<11,SIDX> = Y.ACTIVITY.DUE.DATE

    IF (RUNNING.UNDER.BATCH AND R$SWAP<SW.SOD.MAT> NE "YES") THEN
        ACTIVITY.DUE.DATE = Y.ACTIVITY.DUE.DATE
    END

    IF ((SCHEDULE.TYPE MATCHES EOD.SCHEDULES) AND (Y.ACTIVITY.DUE.DATE LT TODAY)) THEN
        SCHEDULE.LIST<11,SIDX> = CURRENT.DATE
    END
    IF NOT(RUNNING.UNDER.BATCH) AND (SCHEDULE.TYPE = 'CI' OR (R$SWAP<SW.SOD.MAT> EQ "YES" AND SCHEDULE.LIST<11,SIDX> EQ TODAY)) THEN
        IF NOT(SCHEDULE.TYPE MATCHES EOD.SCHEDULES) THEN
            SCHEDULE.LIST<10,SIDX> = ""
            SCHEDULE.LIST<11,SIDX> = ""
        END ELSE
            Y.ACTIVITY.DUE.DATE = SCHEDULE.LIST<11,SIDX>
            CALL CDT('', Y.ACTIVITY.DUE.DATE, '+1C')
            SCHEDULE.LIST<11,SIDX> = Y.ACTIVITY.DUE.DATE
        END
    END

    RETURN
*
*********************
GET.NOTIONAL.DETAILS:
*********************
* To find the contract is NOTIONAL
    NOTIONAL = 1 ; Y.FIELD.POSN = 0 ; Y.VALUE.POSN = 0
    Y.SCHED.TYPE = R$SWAP<SWAP$TYPE>

* Priority 1 - Find from SWAP contract
    FIND 'PX' IN Y.SCHED.TYPE SETTING Y.FIELD.POSN, Y.VALUE.POSN THEN
        NOTIONAL = 0
    END

* Priority 2 - Find from SWAP.BALANCES
    IF NOTIONAL THEN
        IF LEG.TYPE = 'A' THEN
            NOTIONAL = (R$SW.ASSET.BALANCES<SW.BAL.NOTIONAL> = 'Y')
        END ELSE
            NOTIONAL = (R$SW.LIABILITY.BALANCES<SW.BAL.NOTIONAL> = 'Y')
        END
    END
    RETURN
*
*******************
GET.SCHEDULE.INDEX:
*******************
* To get the Schedule Index dynamically from the SWAP contract
    SCHEDULE.INDEX = ''
    Y.TYPE = '' ; Y.DATE.FREQ = '' ; Y.SEARCH.IDX = ''
    Y.KEY.INDEX = SCHEDULE.LIST<1,SIDX>:PROCESS.DATE
    IF SCHEDULE.TYPE = 'CI' OR SCHEDULE.TYPE = 'CM' THEN
        RETURN
    END
    IF LEG.TYPE = 'A' THEN
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
            SCHEDULE.INDEX = Y.IDX
            RETURN
        END
    NEXT Y.IDX
    RETURN
*
*****************
PROCESS.SCHEDULE:
*****************
*
    Y.NET.PAYMENT.AMOUNT = '' ; Y.PAYMENT.AMOUNT = ''

    Y.NP.ACT.LEG.TYPE = ''
    Y.NP.ACT.INDEX = ''

    SIDX = 0
    LOOP
        SIDX += 1
        SCHEDULE.TYPE = SCHEDULE.LIST<1,SIDX>[1,2]
    UNTIL SCHEDULE.TYPE = '' DO
        VALUE.DATE = SCHEDULE.LIST<3, SIDX>       ;* net payment is based on value date
        PROCESS.DATE = SCHEDULE.LIST<4, SIDX>
        LEG.TYPE = SCHEDULE.LIST<8, SIDX>
* To skip the Message Processing, if it is a Process Schedule -
        IF RUNNING.UNDER.BATCH AND SCHEDULE.LIST<10,SIDX> = '' THEN
            CONTINUE
        END
        GOSUB GET.SCHEDULE.INDEX
*
        IF SCHEDULE.TYPE MATCHES SCHEDULES.TO.PROCESS THEN
            ADVICE.ACTIVITY.CODE = ''
            PAYMENT.ACTIVITY.CODE = ''
            Y.UPDATE.SCHEDULE.LIST = 1
            GOSUB GET.NOTIONAL.DETAILS
            GOSUB DETERMINE.ACTIVITY.CODES
            GOSUB GET.DAYS.DELIVERY
            GOSUB GET.ACTIVITY.DUE.DATE
            GOSUB CHECK.ADVICE.SENT

            IF SCHEDULE.TYPE EQ 'RR' THEN
                IF LEG.TYPE = 'A' THEN
                    Y.RATE = R$SWAP<SW.AS.RATE, SCHEDULE.INDEX>
                END ELSE
                    Y.RATE = R$SWAP<SW.LB.RATE, SCHEDULE.INDEX>
                END
                IF Y.RATE EQ '' THEN
                    Y.UPDATE.SCHEDULE.LIST = 0
                END
            END
* Update SWAP.SCHEDULES, only if ADVICE is not already sent for that schedule
            IF ADVICE.SENT = '' AND Y.UPDATE.SCHEDULE.LIST THEN
                GOSUB UPDATE.SCHEDULE.LIST
            END

* don't process IP/AP/RX/CM if not EOD
            IF NOT(SCHEDULE.TYPE MATCHES EOD.SCHEDULES) OR (RUNNING.UNDER.BATCH) THEN
                IF ADVICE.SENT = '' THEN          ;* don't send again if already sent
                    GOSUB UPD.ADVICE.ACTIVITY.CODE
* ignore those non-payment schedules and NOTIONAL principal movements
                    IF PAYMENT.ACTIVITY.CODE THEN
                        IF NOT(RUNNING.UNDER.BATCH) THEN
                            IF ACTIVITY.DUE.DATE LT CURRENT.DATE THEN
                                ACTIVITY.DUE.DATE = CURRENT.DATE
                            END
                        END
                        IF ACTIVITY.DUE.DATE LE CURRENT.DATE THEN
                            IF R$SWAP<SW.NET.PAYMENTS> = 'Y' THEN
* Store the schedule index and the leg type in a temporary array incase of
* NET.PAYMENTS set to YES. This is to set the ADVICE.SENT flag for delivery
* messages that are to be sent during the EOD.
                                Y.NP.ACT.LEG.TYPE<1,-1> = LEG.TYPE
                                Y.NP.ACT.INDEX<1,-1> = SCHEDULE.INDEX
* For net payment set to YES, amount is taken from SCHEDULE.LIST for which
* value is supplied from the process value of SWAP.SCHEDULES
                                IF PAYMENT.ACTIVITY.CODE EQ 210 THEN
                                    Y.PAYMENT.AMOUNT = -SCHEDULE.LIST<6, SIDX>
                                END ELSE
                                    Y.PAYMENT.AMOUNT = SCHEDULE.LIST<6, SIDX>
                                END
                                Y.NET.PAYMENT.AMOUNT += Y.PAYMENT.AMOUNT
                                SAVE.ACTIVITY.DUE.DATE = ACTIVITY.DUE.DATE      ;* save for later use
                            END ELSE
                                ACTIVITY.CODE = PAYMENT.ACTIVITY.CODE
                                GOSUB UPDATE.DELIVERY
                            END
                        END
                    END       ;* if payment.activity.code
                END ;* if advice.sent = ''
            END     ;* if not(IP/AP/RX/CM) or running.under.batch

* To handle Amendment message for RR type Schedule
            IF SCHEDULE.TYPE EQ 'RR' THEN
                GOSUB PROCESS.MT362.AMEND
            END
        END         ;* if schedule to process
    REPEAT

    GOSUB PROCESS.NET.PAYMENTS
    RETURN
*
*-----------------------
CHECK.ADVICE.SENT:
*-----------------------
    ADVICE.SENT = ''
    IF LEG.TYPE = 'A' THEN
        IF SCHEDULE.INDEX THEN
            ADVICE.SENT = R$SWAP<SW.AS.ADVICE.SENT, SCHEDULE.INDEX>
        END
    END ELSE
        IF SCHEDULE.INDEX THEN
            ADVICE.SENT = R$SWAP<SW.LB.ADVICE.SENT, SCHEDULE.INDEX>
        END
    END

    RETURN

*************************
DETERMINE.ACTIVITY.CODES:
*************************
*
* determine advice/confirmation activity
*
    BEGIN CASE
    CASE SCHEDULE.TYPE = 'CI' ;* contract initialisation
        ADVICE.ACTIVITY.CODE = 101
* Activity code 102 generation for forward CIRS - SWAP contracts removed.
*
    CASE SCHEDULE.TYPE MATCHES 'PI':VM:'PD':VM:'NI':VM:'ND' ;* principal increase/decrease
* To check whether PRINCIPAL has been changed before triggering the message
        GOSUB CHECK.CM.AMOUNT
        IF Y.PROCESS.MSG THEN
            ADVICE.ACTIVITY.CODE = 103
        END
*
    CASE SCHEDULE.TYPE = 'CM' ;* contract maturity
        ADVICE.ACTIVITY.CODE = 106
*
    CASE SCHEDULE.TYPE = 'RR' ;* rate reset
        ADVICE.ACTIVITY.CODE = 108
*
    CASE SCHEDULE.TYPE = 'PM' ;* payment
        ADVICE.ACTIVITY.CODE = 110      ;* payment of premium
*
    CASE SCHEDULE.TYPE = 'RV' ;* receipt
        ADVICE.ACTIVITY.CODE = 111      ;* receipt of premium
*
    CASE SCHEDULE.TYPE = 'IS' ;* issue price
        ADVICE.ACTIVITY.CODE = 112
*
    CASE SCHEDULE.TYPE = 'AP' ;* annuity payment
        ADVICE.ACTIVITY.CODE = 113
    END CASE
*

* notional should only apply to principal increase/decrease
    NOTIONAL = (SCHEDULE.TYPE MATCHES 'PI':VM:'PD':VM:'NI':VM:'ND' AND NOTIONAL)
*
    IF SCHEDULE.TYPE MATCH 'PI':VM:'PD' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
* determine payment/receipt activity only if not NOTIONAL
        PAY.RECEIPT = ''
        CALL SW.DETERMINE.PAY.RECEIPT(SCHEDULE.TYPE, LEG.TYPE, PAY.RECEIPT)
        IF PAY.RECEIPT = 'P' THEN
            PAYMENT.ACTIVITY.CODE = 202 ;* payment
        END ELSE
            IF PAY.RECEIPT = 'R' THEN
                PAYMENT.ACTIVITY.CODE = 210       ;* advice to receive
            END
        END
        RETURN
    END

    IF NOT(NOTIONAL) OR SCHEDULE.TYPE EQ 'IP' THEN
        IF LEG.TYPE = 'A' THEN
            CHECK.INT.AMT = R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT>
        END ELSE
            CHECK.INT.AMT = R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT>
        END

        PAY.RECEIPT = ''
        CALL SW.DETERMINE.PAY.RECEIPT(SCHEDULE.TYPE, LEG.TYPE, PAY.RECEIPT)
        IF PAY.RECEIPT = 'P' THEN
            PAYMENT.ACTIVITY.CODE = 202 ;* payment
        END ELSE
            IF PAY.RECEIPT = 'R' THEN
                PAYMENT.ACTIVITY.CODE = 210       ;* advice to receive
            END
        END

        IF SCHEDULE.TYPE = 'IP' AND CHECK.INT.AMT < 0 THEN
            IF PAYMENT.ACTIVITY.CODE = 202 AND LEG.TYPE = 'L' THEN
                PAYMENT.ACTIVITY.CODE = 210
            END
            IF PAYMENT.ACTIVITY.CODE = 210 AND LEG.TYPE = 'A' THEN
                PAYMENT.ACTIVITY.CODE = 202
            END
        END
    END
    RETURN
*
*-------------------------
UPD.ADVICE.ACTIVITY.CODE:
*-------------------------
    IF ADVICE.ACTIVITY.CODE THEN        ;* advice/confirmation
        ACTIVITY.CODE = ADVICE.ACTIVITY.CODE
        IF NOT(RUNNING.UNDER.BATCH) THEN
            IF ACTIVITY.DUE.DATE LT CURRENT.DATE THEN
                ACTIVITY.DUE.DATE = CURRENT.DATE
            END
        END
        IF ACTIVITY.DUE.DATE LE CURRENT.DATE AND ACTIVITY.DUE.DATE GE TODAY THEN
            GOSUB UPDATE.ADVICE
        END
    END

    RETURN

****************
CHECK.CM.AMOUNT:
****************
    Y.PROCESS.MSG = 1 ; Y.NEW.CM.AMT = 0 ; Y.SEARCH.POSN = 1 ; Y.OLD.CM.AMT = 0
    POS = 0

* Get the PRINCIPAL Repayment from SWAP.SCHEDULES record
    IF R.SW.SCHEDULES THEN
        IF NOTIONAL THEN
            LOCATE 'CM' IN R.SW.SCHEDULES<1,Y.SEARCH.POSN> SETTING POS THEN
                Y.SEARCH.POSN = POS + 1
                Y.LEG.TYPE = R.SW.SCHEDULES<SW.SCHED.LEG.TYPE,POS>
                IF LEG.TYPE = Y.LEG.TYPE THEN
                    Y.OLD.CM.AMT = R.SW.SCHEDULES<SW.SCHED.PROCESS.VALUE,POS>
                END ELSE
                    POS = 0
                    LOCATE 'CM' IN R.SW.SCHEDULES<1,Y.SEARCH.POSN> SETTING POS THEN
                        Y.OLD.CM.AMT = R.SW.SCHEDULES<SW.SCHED.PROCESS.VALUE,POS>
                    END
                END
            END
        END ELSE
            LOCATE 'RX' IN R.SW.SCHEDULES<1,Y.SEARCH.POSN> SETTING POS THEN
                Y.SEARCH.POSN = POS + 1
                Y.LEG.TYPE = R.SW.SCHEDULES<SW.SCHED.LEG.TYPE,POS>
                IF LEG.TYPE = Y.LEG.TYPE THEN
                    Y.OLD.CM.AMT = R.SW.SCHEDULES<SW.SCHED.PROCESS.VALUE,POS>
                END ELSE
                    POS = 0
                    LOCATE 'RX' IN R.SW.SCHEDULES<1,Y.SEARCH.POSN> SETTING POS THEN
                        Y.OLD.CM.AMT = R.SW.SCHEDULES<SW.SCHED.PROCESS.VALUE,POS>
                    END
                END
            END
        END

* Get the Net PRINCIPAL from the Full Balances record which is available
* in a common variable(assigned from SW.SCHEDULE.PROCESSING)
        IF LEG.TYPE EQ 'A' THEN
            Y.NEW.CM.AMT = Y.FULL.AS.BALANCES<SW.BAL.PRINCIPAL,1>
        END ELSE
            Y.NEW.CM.AMT = Y.FULL.LB.BALANCES<SW.BAL.PRINCIPAL,1>
        END
    END

* If PRINCIPAL is not changed, then stop triggering of message, Also
* Message processing for PI/PD is not required, when called from EOD.
    IF (Y.NEW.CM.AMT = Y.OLD.CM.AMT) OR RUNNING.UNDER.BATCH THEN
        Y.PROCESS.MSG = 0
    END
    RETURN
*
*********************
PROCESS.NET.PAYMENTS:
*********************
*
    IF R$SWAP<SW.NET.PAYMENTS> = 'Y' THEN
        SCHEDULE.INDEX = ''   ;* irrelevant if net payment
        NET.PAYMENT.AMOUNT = Y.NET.PAYMENT.AMOUNT
* determine payment or receipt by the sign of the amount
        IF NET.PAYMENT.AMOUNT THEN
            IF NET.PAYMENT.AMOUNT < 0 THEN
                ACTIVITY.CODE = 210     ;* receipt
                LEG.TYPE = 'A'
            END ELSE
                ACTIVITY.CODE = 202     ;* payment
                LEG.TYPE = 'L'
            END
*
            ACTIVITY.DUE.DATE = SAVE.ACTIVITY.DUE.DATE
            GOSUB UPDATE.DELIVERY
* Except for the payment messages generated with NET.PAYMENTS set to YES, for all other
* delivery messages, the ADVICE.SENT flag is updated in the routine SW.DELIVERY.

* Incase of NET.PAYMENTS set to YES for a swap contract, the payment messages are
* generated for the difference in amount between asset and liab sides. The ADVICE.SENT flag
* for this case is updated here as the value for the variable SCHEDULE.INDEX is assigned here.

            YCNT = 1
            LOOP
                Y.NP.ACT.INDEX.VAL = Y.NP.ACT.INDEX<1,YCNT>
            UNTIL Y.NP.ACT.INDEX.VAL = ""
                IF Y.NP.ACT.LEG.TYPE<1,YCNT> = "A" THEN
                    R$SWAP<SW.AS.ADVICE.SENT, Y.NP.ACT.INDEX.VAL> = "Y"
                END ELSE
                    R$SWAP<SW.LB.ADVICE.SENT, Y.NP.ACT.INDEX.VAL> = "Y"
                END
                YCNT += 1
            REPEAT
        END
    END
    RETURN
*
**************
UPDATE.ADVICE:
**************
* Don't update delivery again if 101_104_107 already exist
* i.e. 'CI', amendment and reversal
    IF ACTIVITY.CODE EQ '101' THEN
        IF R$SW.ASSET.BALANCES<SW.BAL.CONF.SENT> EQ 'Y' THEN
            RETURN
        END
    END

    IF ACTIVITY.CODE = '108' THEN
        ACTIVITY.CODE = '114'
        ADVICE.ACTIVITY.CODE = '114'
    END

    IF ACTIVITY.CODE EQ '114' OR ACTIVITY.CODE EQ '115' THEN
        C$SW.NDAYS = NDAYS    ;* Store the Days Delivery in common variable

        CALL F.READ('F.SWAP.PAYMENT.DATE',ID.NEW,SW.PAY.DATE,F.SWAP.PAYMENT.DATE,'')
        IF ACTIVITY.CODE EQ '114' THEN
            IF SW.PAY.DATE AND SW.PAY.DATE<2> EQ PROCESS.DATE THEN
                RETURN
            END
        END
        SW.PAY.DATE<1> = ACTIVITY.DUE.DATE
        SW.PAY.DATE<2> = PROCESS.DATE

        ADV.FOUND = ''
        LOCATE ACTIVITY.CODE IN R$SWAP<SW.ACTIVITY,1> SETTING ADV.FOUND ELSE
            ADV.FOUND = ''
        END
        IF ACTIVITY.CODE EQ '115' THEN
            LOCATE '114' IN R$SWAP<SW.ACTIVITY,1> SETTING NEW.MSG.FOUND ELSE
                NEW.MSG.FOUND = ''
            END
            IF NEW.MSG.FOUND THEN
                RETURN
            END
        END

        IF NOT(ADV.FOUND) THEN
            IF ACTIVITY.DUE.DATE LE CURRENT.DATE THEN
                CALL F.WRITE('F.SWAP.PAYMENT.DATE',ID.NEW,SW.PAY.DATE)
                GOSUB UPDATE.DELIVERY
                RETURN
            END
        END
    END

    IF ACTIVITY.CODE MATCHES "108":VM:"105" THEN  ;* Always send RR and IP advices
        IF R$SW.ASSET.BALANCES<SW.BAL.END.INT.PERIOD> = R$SW.LIABILITY.BALANCES<SW.BAL.END.INT.PERIOD> THEN
            LOCATE "108" IN R$SWAP<SW.ACTIVITY, 1> SETTING RR.IP.POS ELSE
                LOCATE "105" IN R$SWAP<SW.ACTIVITY, 1> SETTING RR.IP.POS ELSE
                    GOSUB UPDATE.DELIVERY
                END
            END
        END ELSE
            GOSUB UPDATE.DELIVERY
        END
    END ELSE
        LOCATE 101 IN R$SWAP<SW.ACTIVITY, 1> SETTING APOS ELSE
            LOCATE 104 IN R$SWAP<SW.ACTIVITY, 1> SETTING APOS ELSE
                LOCATE 107 IN R$SWAP<SW.ACTIVITY, 1> SETTING APOS ELSE
                    GOSUB UPDATE.DELIVERY
                END
            END
        END
    END
    RETURN
*
****************
UPDATE.DELIVERY:
****************
    IF ACTIVITY.DUE.DATE <= CURRENT.DATE THEN
        LOCATE ACTIVITY.CODE IN R$SWAP<SW.ACTIVITY, 1> SETTING POS THEN
* if CI/CM is already in SW.ACTIVITY don't add to list again
            IF ACTIVITY.CODE MATCHES 101:VM:106:VM:114:VM:115 THEN
                RETURN
            END
            IF NET.PAYMENT.AMOUNT THEN
                IF ACTIVITY.CODE MATCHES 202:VM:210 THEN
                    RETURN
                END
            END
        END
*
        INS ACTIVITY.CODE BEFORE R$SWAP<SW.ACTIVITY, POS>
        INS NET.PAYMENT.AMOUNT BEFORE R$SWAP<SW.NET.AMOUNT, POS>      ;* should be null if not net payment
*
* the following two fields are to reference back to the schedule list
*
        INS LEG.TYPE BEFORE R$SWAP<SW.ACT.LEG.TYPE, POS>
        INS SCHEDULE.INDEX BEFORE R$SWAP<SW.ACT.SCHED.INDEX, POS>

        IF ACTIVITY.CODE EQ '101' THEN
            R$SW.ASSET.BALANCES<SW.BAL.CONF.SENT> = 'Y'
        END
    END
    RETURN
*
********************
PROCESS.MT362.AMEND:
********************

    IF NOT(RUNNING.UNDER.BATCH) AND ((V$FUNCTION EQ 'I') OR C$SW.RATE.CHANGED) THEN
        GOSUB BUILD.PAYMENT.FIELD.LIST
        PAYMENT.CHANGED = ''
        OLD.REC = ''
        MATBUILD OLD.REC FROM R.OLD
        IF OLD.REC THEN
            NO.OF.PAYMENT.FIELDS = DCOUNT(PAYMENT.FIELD.LIST,FM)
            FOR I = 1 TO NO.OF.PAYMENT.FIELDS
                FIELD.POSITION = PAYMENT.FIELD.LIST<I>
                IF R$SWAP<FIELD.POSITION> NE OLD.REC<FIELD.POSITION> THEN
                    PAYMENT.CHANGED = 1
                    PROCESS.DATE = TODAY
                END
            NEXT I

            IF PAYMENT.CHANGED THEN
                ACTIVITY.DUE.DATE = TODAY
                ACTIVITY.CODE = 104     ;* contract amendment
                GOSUB UPDATE.ADVICE
            END

            IF NOT(PAYMENT.CHANGED) THEN
                IF C$SW.RATE.CHANGED THEN
                    PAYMENT.CHANGED = 1
                    PROCESS.DATE = C$SW.RATE.CHANGE.DATE
                END
            END

            IF PAYMENT.CHANGED THEN
                ACTIVITY.CODE = '115'
                ADVICE.ACTIVITY.CODE = '115'
                ACTIVITY.DUE.DATE = PROCESS.DATE
                GOSUB GET.DAYS.DELIVERY
                GOSUB GET.ACTIVITY.DUE.DATE
                GOSUB GET.SCHEDULE.INDEX
                GOSUB UPDATE.ADVICE
            END
        END
    END
    RETURN
*
*************************
BUILD.PAYMENT.FIELD.LIST:
*************************
    PAYMENT.FIELD.LIST<-1> = SW.SET.CURRENCY
    PAYMENT.FIELD.LIST<-1> = SW.SET.PAY.RECEIPT
    PAYMENT.FIELD.LIST<-1> = SW.SET.TYPE
    PAYMENT.FIELD.LIST<-1> = SW.ACCOUNT.NUMBER
    PAYMENT.FIELD.LIST<-1> = SW.INTERMEDIARY
    PAYMENT.FIELD.LIST<-1> = SW.INTERM.ADD
    PAYMENT.FIELD.LIST<-1> = SW.ACCT.WITH.BANK
    PAYMENT.FIELD.LIST<-1> = SW.ACC.WITH.ADD
    PAYMENT.FIELD.LIST<-1> = SW.BEN.ACCOUNT
    PAYMENT.FIELD.LIST<-1> = SW.BANK.NARR
    RETURN
END
