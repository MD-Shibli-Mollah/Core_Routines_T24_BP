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
* <Rating>26346</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Delivery
    SUBROUTINE CONV.SW.DELIVERY
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.DELIVERY                                           *
* Duplicate of SW.DELIVERY for conversion purposes.
*************************************************************************
*                                                                       *
*  Description :  This routine will generate all delivery messages for  *
*                 a swap contract and it will handoff six standard      *
*                 records to the delivery system which can be used by   *
*                 DE.MAPPING.                                           *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*                                                                       *
*
* 14/06/07 - BG_100014209
*            Changes to called routines with incorrect number of arguments / non-existent routine.
*
* 05/02/08 - BG_100016891
*            CACHE.READ on CUSTOMER is changed to F.READ
*
* 26/05/11 - Defect-214848/Task-215737
*            Tag22C of MT360, MT361 and MT362 messages
*            are not updated as per the swift standards.
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.COMPANY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.DATES
    $INSERT I_F.MARKET.RATE.TEXT
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.SWAP.ACTIVITY
    $INSERT I_F.SWAP.ADVICES
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_F.USER
    $INSERT I_SW.COMMON
    $INSERT I_F.SWAP.AGREEMENT.TYPE
    $INSERT I_F.COUNTRY
    $INSERT I_F.REGION
    $INSERT I_F.DE.EU.SWIFT.LIST        ;* EN_10002225 S/E
    $INSERT I_F.CURRENCY      ;* CI_10030847 - S/E
*
*******************************************
*
***********
* main body
***********
    IF R$SWAP<SW.ACTIVITY> THEN
        * Handle Message processing, only if SW.ACTIVITY is found - EN_10002475 - S
        GOSUB INITIALISATION
        GOSUB BUILD.FULL.SCHEDULE.LIST  ;* EN_10002475 - E

        * generate delivery messages for each activity
        ACNT = 1
        LOOP
            ACTIVITY.CODE = R$SWAP<SW.ACTIVITY, ACNT>
        WHILE ACTIVITY.CODE DO
            NET.VALUE = R$SWAP<SW.NET.AMOUNT, ACNT>
            ACT.LEG.TYPE = R$SWAP<SW.ACT.LEG.TYPE, ACNT>
            ACT.SCHED.INDEX = R$SWAP<SW.ACT.SCHED.INDEX, ACNT>
            GOSUB PROCESS.MSG.FOR.ACT.OR.NETVALUE
            * read activity record and advices record
            CALL CACHE.READ('F.SWAP.ACTIVITY',ACTIVITY.CODE,R.ACTIVITY,"")      ;* EN_10002475 S/E
            GOSUB GET.ADVICES.REC
            NO.OF.MESSAGES = DCOUNT(R.ADVICES<SW.ADV.MESSAGE.TYPE>, VM)
            GOSUB PROCESS.MESSAGE
            ACNT += 1
        REPEAT
    END   ;* if SW.ACTIVITY <> ''
    RETURN
*
********************
*
* localc subroutines
*
********************
*
***************
INITIALISATION:
***************
*
* open files
*
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)
*
    FN.SWAP = 'F.SWAP'
    F.SWAP = ''
    CALL OPF(FN.SWAP, F.SWAP)
*
* Removed CALL OPF of static tables like CUSTOMER, SWAP.ACTIVITY, ; * EN_10002475 - S
* SWAP.ADVICES and MARKET.RATE.TEXT. Replaced F.READ & F.READV with
* CACHE.READ for these four tables
    R.MARKET.RATE.TEXT = '' ; R.ACTIVITY = '' ; R.ADVICES = ''
    R.CUSTOMER = '' ;* EN_10002475 - E

* read the last version of the authorised swap contract
    R.OLD.SWAP = ''
    CALL F.READ(FN.SWAP, C$SWAP.ID, R.OLD.SWAP, F.SWAP, '')
*
    DIM R.NEW.SAVE(500)
*
    R$SW.BALANCES = ''
    SCHEDULE.LIST = ''
*
* leg info variables
*
    LEG.CCY = ''
    AMOUNT.DUE = ''
    VALUE.DATE = ''
    ACT.SCHED.TYPE = ''
    SCHED.NARR = ''
*
* settlement info variables
*
    R.ACCOUNT = ''  ;* BG_100008999 S/E
    ACCOUNT.NUMBER = ''
    INTERMEDIARY = ''
    ACCT.WITH.BANK = ''
    BEN.ACCOUNT = ''
    BANK.INFO = ''
*
** Full contract schedule details
*
    ENQUIRY.MODE = 1
    FULL.ASSET.BALANCES = ""
    FULL.LIAB.BALANCES = ""
*
    Y.START.PERIOD = ""
    Y.END.PERIOD = ""
    Y.CCY.AMOUNT = ""
    Y.AS.START.PERIOD = ""
    Y.AS.END.PERIOD = ""
    Y.AS.CCY.AMOUNT = ""
    Y.LI.START.PERIOD = ""
    Y.LI.END.PERIOD = ""
    Y.LI.CCY.AMOUNT = ""
    Y.RULE.C17 = ""
    Y.14F = ""
    Y.CAP.FLO.COL = ""
    Y.WE.PAY.RCV = ""
    Y.CAP.RATE = ""
    Y.FLOOR.RATE = ""
    Y.SEQ.H.BUS.CITIES.1 = ""
    Y.SEQ.H.BUS.CITIES.2 = ""
    Y.SEQ.H.DAY.CON = ""
    Y.SEQ.I.BUS.CITIES = ""
    Y.SEQ.I.DAY.CON = ""
    Y.SEQ.J.BUS.CITIES = ""
    Y.SEQ.J.DAY.CON = ""
    Y.SEQ.K.BUS.CITIES = ""
    Y.SEQ.K.DAY.CON = ""
    Y.SEQ.L.BUS.CITIES = ""
    Y.SEQ.M.BUS.CITIES = ""
    Y.LIAB.PM = ""
    Y.LIAB.RV = ""
    Y.ASSET.PM = ""
    Y.ASSET.RV = ""
    Y.BUS.CITIES = ""
* Offset for each sequence.
    Y.SEQ.B.OFFSET = 0
    Y.SEQ.C.OFFSET = 30
    Y.SEQ.E.OFFSET = 80
    Y.SEQ.F.OFFSET = 110
    Y.SEQ.J.PRIN = 0
    Y.SEQ.K.PRIN = 0
    PAY.PERIOD.O = ''         ;* CI_10016799 S/E
    INT.RATE.KEY = 0          ;* BG_100007335 - S
    Y.CUR.RATE = 0
    SPREAD = 0      ;* BG_100007335 - E
*
    Y.BUS.VM = ''   ;* CI_10035793 - S
    IF R$SWAP<SW.AS.BUS.CENTRES> AND R$SWAP<SW.LB.BUS.CENTRES> THEN
        Y.BUS.VM = VM         ;* CI_10035793 - E
    END
*
    RETURN
*
************************
BUILD.FULL.SCHEDULE.LIST:
*************************
* Cycle the schedules to ensure that all future events are available
* in the balances record for delivery
*
    CALL SW.SAVE.COMMON
    SCHEDULE.LIST = '' ; Y.PROCESS.SCHEDULES = 1  ;* CI_10032652 - S
    LOOP
    WHILE (SCHEDULE.LIST OR Y.PROCESS.SCHEDULES)
        SCHEDULE.LIST = '' ;  Y.PROCESS.SCHEDULES = 0       ;* CI_10032652 - E
        CALL CONV.SW.CYCLE.SCHEDULES(ENQUIRY.MODE)
        CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,'')  ;* EN_10002475 S/E
        CALL CONV.SW.SCHEDULE.PROCESSING(SCHEDULE.LIST, ENQUIRY.MODE)
    REPEAT

    FULL.ASSET.BALANCES = R$SW.ASSET.BALANCES
    FULL.LIAB.BALANCES = R$SW.LIABILITY.BALANCES
*
    CALL SW.RESTORE.COMMON
    SCHEDULE.LIST = 'DEL'
    CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,'')      ;* EN_10002475 S/E

    RETURN
*
*************************
PROCESS.MSG.FOR.ACT.OR.NETVALUE:
*************************
    IF ACT.SCHED.INDEX OR NET.VALUE THEN
        * this is from a normal schedule - just requires data relating to this schedule
        THIS.LEG.TYPE = ACT.LEG.TYPE
        GOSUB DETERMINE.LEG.INFO
        ACT.SCHED.TYPE = R$SWAP<SWAP$TYPE, ACT.SCHED.INDEX>[1,2]
        FINAL.SCHED = R$SWAP<SWAP$FINAL.SCHED, ACT.SCHED.INDEX>
        * determine amount due
        BEGIN CASE
            CASE NET.VALUE
                AMOUNT.DUE = ABS(NET.VALUE) ;* amount.due is unsigned
            CASE ACT.SCHED.TYPE = 'IP'
                * To get the Interest Amount for IP dynamically from SWAP.BALANCES ;* EN_10002475 - S
                GOSUB GET.INTEREST.AMOUNT.DUE         ;* EN_10002475 - E
            CASE ACT.SCHED.TYPE = 'AP'
                AMOUNT.DUE = R$SWAP<SWAP$AMOUNT, ACT.SCHED.INDEX>
                IF AMOUNT.DUE < R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT> THEN
                    AMOUNT.DUE = R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT>
                END
            CASE ACT.SCHED.TYPE = 'PX'      ;* EN_10002475 - S
                AMOUNT.DUE = R$SW.BALANCES<SW.BAL.PRINCIPAL, 1>
            CASE ACT.SCHED.TYPE = 'RX'
                * To get the Principal Amount for RX dynamically from SWAP.BALANCES
                AMOUNT.DUE = FUTURE.BALANCES<SW.BAL.PRINCIPAL, 1>         ;* EN_10002475 - E
            CASE 1
                AMOUNT.DUE = R$SWAP<SWAP$AMOUNT, ACT.SCHED.INDEX>
        END CASE

        SCHED.NARR = R$SWAP<SWAP$NARR, ACT.SCHED.INDEX>
        * get value date of schedule
        SCHED.DATE.FREQ = R$SWAP<SWAP$DATE.FREQ, ACT.SCHED.INDEX>
        VALUE.DATE = ''
        SCHED.DATE = SCHED.DATE.FREQ[1,8]

        IF ACT.SCHED.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN   ;* CI_10016799 S/E
            BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>         ;* CI_10035793 - S/E
        END ELSE
            BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
        END

        IF R$SWAP<SWAP$INT.SET.DATE, ACT.SCHED.INDEX> THEN  ;* CI_10022317/S
            REF.DATE = R$SWAP<SWAP$INT.SET.DATE, ACT.SCHED.INDEX>
        END ELSE
            REF.DATE = SCHED.DATE.FREQ[1,8]
        END

        CALL CONV.EB.DETERMINE.PROCESS.DATE(REF.DATE, BUSINESS.CENTRES,
        R$SWAP<SWAP$DAY.CONVENTION>, R$SWAP<SWAP$DATE.ADJUSTMENT>,
        '', VALUE.DATE,'')
    END ELSE
        * must either be CI, CM, amendment or reversal
        * each of them requires data relating to all schedules specified on the contract
        IF SCHEDULE.LIST = '' THEN
            SCHEDULE.LIST = 'DEL'       ;* CI_10013033
            CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,'')        ;* EN_10002475 S/E
        END
    END
    RETURN
*******************
DETERMINE.LEG.INFO:
*******************
*
    CALL CONV.SW.DETERMINE.FIELDS(THIS.LEG.TYPE)
    LEG.CCY = R$SWAP<SWAP$CURRENCY>
*
    IF THIS.LEG.TYPE = 'A' THEN
        R$SW.BALANCES = R$SW.ASSET.BALANCES
        FUTURE.BALANCES = FULL.ASSET.BALANCES
    END ELSE
        R$SW.BALANCES = R$SW.LIABILITY.BALANCES
        FUTURE.BALANCES = FULL.LIAB.BALANCES
    END
*
    RETURN
*
************************
GET.INTEREST.AMOUNT.DUE:      * EN_10002475 - S
************************
* To get the Interest Amount for IP dynamically from SWAP.BALANCES
    Y.KEY.INDEX = R$SWAP<SWAP$TYPE,ACT.SCHED.INDEX>:R$SWAP<SWAP$DATE.FREQ,ACT.SCHED.INDEX>[1,8]
    Y.TYPE =  FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE>
    Y.DATE.FREQ = FUTURE.BALANCES<SW.BAL.PROCESS.DATE>
    NUM.SCHED.TYPES = DCOUNT(Y.TYPE,VM)
    FOR Y.IDX = 1 TO NUM.SCHED.TYPES
        Y.SEARCH.IDX = Y.TYPE<1,Y.IDX>:Y.DATE.FREQ<1,Y.IDX>[1,8]
        IF Y.SEARCH.IDX EQ Y.KEY.INDEX THEN
            AMOUNT.DUE = FUTURE.BALANCES<SW.BAL.CCY.AMOUNT,Y.IDX>
            EXIT
        END
    NEXT Y.IDX      ;* EN_10002475 - E
    RETURN

*
****************
GET.ADVICES.REC:
****************
* read SWAP.ADVICES first with activity code and swap type
* then just the activity code
    ADVICES.ID = ACTIVITY.CODE:'-':R$SWAP<SW.SWAP.TYPE>
    ERRFLAG = ''
    CALL CACHE.READ('F.SWAP.ADVICES',ADVICES.ID,R.ADVICES,ERRFLAG)    ;* EN_10002475 S/E
*
    IF ERRFLAG THEN ;* try with just activity code
        ADVICES.ID = ACTIVITY.CODE
        ERRFLAG = ''
        CALL CACHE.READ('F.SWAP.ADVICES',ADVICES.ID,R.ADVICES,ERRFLAG)          ;* EN_10002475 S/E
    END
*
    IF NOT(ERRFLAG) THEN
        IF R.ADVICES<SW.ADV.USE.RECORD> THEN      ;* use record specified
            ADVICES.ID = R.ADVICES<SW.ADV.USE.RECORD>
            R.ADVICES = ''
            CALL CACHE.READ('F.SWAP.ADVICES',ADVICES.ID,R.ADVICES,ERRFLAG)      ;* EN_10002475 S/E
        END
    END
*
    IF ERRFLAG THEN
        R.ADVICES = ''
    END
    RETURN
*
****************
PROCESS.MESSAGE:
****************
* process each message type specified on the advices record
    FOR MCNT = 1 TO NO.OF.MESSAGES
        MESSAGE.TYPE = R.ADVICES<SW.ADV.MESSAGE.TYPE, MCNT>

        IF ACTIVITY.CODE EQ '107' THEN
            IF MESSAGE.TYPE EQ '362' THEN
                SW.PAY.DATE = ''
                CALL F.READ('F.SWAP.PAYMENT.DATE',ID.NEW,SW.PAY.DATE,F.SWAP.PAYMENT.DATE,'')
                IF SW.PAY.DATE EQ '' THEN
                    CONTINUE
                END
            END
        END

        IF ACT.SCHED.INDEX OR NET.VALUE THEN      ;*CI_10001424
            THIS.SCHED.TYPE = ACT.SCHED.TYPE
            THIS.LEG.CCY = LEG.CCY
            GOSUB GET.SETTLEMENT.INFO   ;* for this message type
        END
        GOSUB DETERMINE.MESSAGE.TYPE    ;* message could have been suppressed
        *
        IF MESSAGE.TYPE THEN
            PRINT.FORMAT = R.ADVICES<SW.ADV.PRINT.FORMAT, MCNT>
            GOSUB BUILD.HEADER
            GOSUB BUILD.ADDITIONAL.INFO
            GOSUB BUILD.SPECIAL.REC
            GOSUB CALL.APPLICATION.HANDOFF
            *
            DEAL.SLIP = R.ADVICES<SW.ADV.DEAL.SLIP, MCNT>
            IF DEAL.SLIP THEN
                GOSUB PRODUCE.DEAL.SLIP
            END

            * update delivery reference
            IF ACT.SCHED.INDEX THEN     ;*CI_10001424 ;* CI_10035111 S/E
                IF THIS.LEG.TYPE EQ 'A' THEN      ;* CI_10021825/S
                    R$SWAP<SW.AS.ADVICE.SENT, ACT.SCHED.INDEX> = 'Y'
                END ELSE
                    R$SWAP<SW.LB.ADVICE.SENT, ACT.SCHED.INDEX> = 'Y'
                END ;* CI_10021825/E
            END

            IF MCNT > 1 THEN
                INS R$SWAP<SW.ACTIVITY, ACNT> BEFORE R$SWAP<SW.ACTIVITY, ACNT>
                INS R$SWAP<SW.ACT.LEG.TYPE, ACNT> BEFORE R$SWAP<SW.ACT.LEG.TYPE, ACNT>
                INS R$SWAP<SW.ACT.SCHED.INDEX, ACNT> BEFORE R$SWAP<SW.ACT.SCHED.INDEX, ACNT>
                ACNT += 1
            END
            R$SWAP<SW.MESSAGE, ACNT> = MESSAGE.TYPE
            R$SWAP<SW.MSG.DATE, ACNT> = TODAY
            R$SWAP<SW.MSG.REF, ACNT> = DELIVERY.REF
        END ELSE
            R$SWAP<SW.MSG.DATE, ACNT> = 'NOT PRODUCED'
        END
    NEXT MCNT
    RETURN
*
***********************
DETERMINE.MESSAGE.TYPE:
***********************
*
* determine which message is to be sent
*
    BEGIN CASE
        CASE MESSAGE.TYPE MATCHES 202:VM:210          ;* actual payment
            IF R$SWAP<SW.SEND.PAYMENT> = 'NO' THEN
                MESSAGE.TYPE = ''
            END ELSE
                *
                * check for nostro, cos message is not required when not a nostro
                * also determine if the counterparty is a bank if not the message is a
                * 103
                *
                IF R.ACCOUNT<AC.LIMIT.REF> <> 'NOSTRO' THEN
                    MESSAGE.TYPE = ''       ;* suppress message
                END ELSE
                    IF MESSAGE.TYPE = "202" THEN
                        ETEXT = ""
                        RET.CODE =""
                        CALL CHECK.ACCOUNT.CLASS("BANK", "", R$SWAP<SW.CUSTOMER>, "", RET.CODE)
                        IF RET.CODE NE "YES" THEN     ;* Not a bank
                            MESSAGE.TYPE = "103"      ;* BG_100004515
                            ETEXT = ""
                        END
                    END
                END
                *
            END
            *
        CASE MESSAGE.TYPE MATCHES "360":VM:"361"
            IF R$SWAP<SW.SEND.CONFIRMATION> = 'NO' THEN
                MESSAGE.TYPE = ''
            END
            *
        CASE 1
            IF R$SWAP<SW.SEND.ADVICE> = "NO" THEN
                MESSAGE.TYPE = ""
            END
            *
    END CASE
*
    RETURN
*
*
********************
GET.SETTLEMENT.INFO:
********************
*
    PAY.REC = ''


    SAVE.SCHED.TYPE = THIS.SCHED.TYPE
    IF THIS.SCHED.TYPE EQ 'RR' THEN
        THIS.SCHED.TYPE = 'IP'
    END

    IF MESSAGE.TYPE MATCHES "202":VM:"103" THEN   ;* BG_100004515
        PAY.REC = 'PAYMENT'
    END ELSE
        IF MESSAGE.TYPE = 210 THEN
            PAY.REC = 'RECEIPT'
        END ELSE
            CALL SW.DETERMINE.PAY.RECEIPT(THIS.SCHED.TYPE, THIS.LEG.TYPE, PAY.REC)
            IF PAY.REC = 'P' THEN
                PAY.REC = 'PAYMENT'
            END
            IF PAY.REC = 'R' THEN
                PAY.REC = 'RECEIPT'
            END
        END
    END
*
    SET.TYPE = ''
    CALL SW.DETERMINE.SETTLEMENT.TYPE(THIS.SCHED.TYPE, SET.TYPE)
*
    SET.INFO = ''
    CALL CONV.SW.DETERMINE.SETTLEMENT.INFO(THIS.LEG.CCY, PAY.REC, SET.TYPE, SET.INFO)
*
** Store the PRINCIPAL / INTEREST details for comparison, as certain SWIFT
** details are only required if they differ
*
    IF SET.TYPE = "PRINCIPAL" THEN
        OTH.SET.TYPE = "INTEREST"
    END ELSE
        OTH.SET.TYPE = "PRINCIPAL"
    END
    OTH.SET.INFO = ""
    CALL CONV.SW.DETERMINE.SETTLEMENT.INFO(THIS.LEG.CCY, PAY.REC, OTH.SET.TYPE, OTH.SET.INFO)
    IF OTH.SET.INFO = SET.INFO THEN
        SAME.PI.SETTLE = 1
    END ELSE
        SAME.PI.SETTLE = ""
    END
*
* set the settlement fields
*
    ACCOUNT.NUMBER = SET.INFO<1>
    EXT.ACC.NO = SET.INFO<8>
*
    INTERMEDIARY = SET.INFO<2>
    IF NOT(INTERMEDIARY) THEN
        INTERMEDIARY = SET.INFO<3>
    END
*
    ACCT.WITH.BANK = SET.INFO<4>
    IF NOT(ACCT.WITH.BANK) THEN
        ACCT.WITH.BANK = SET.INFO<5>
    END
*
    BEN.ACCOUNT = SET.INFO<6>
    BANK.INFO = SET.INFO<7>
*
* read the settlement account record
*
    R.ACCOUNT = ''
    CALL F.READ(FN.ACCOUNT, ACCOUNT.NUMBER, R.ACCOUNT, F.ACCOUNT, '')
*
    THIS.SCHED.TYPE = SAVE.SCHED.TYPE   ;* CI_10009773 s/e
    RETURN
*
*
*************
BUILD.HEADER:
*************
*
    HEADER.REC = ''
*
* mandatory fields required by DE.MAPPING
*
    HEADER.REC<1> = ID.COMPANY          ;* TAG 82A, SEQ A
    HEADER.REC<2> = R.COMPANY(EB.COM.CUSTOMER.COMPANY)
    HEADER.REC<3> = PRINT.FORMAT
    IF HEADER.REC<3> = '' THEN
        HEADER.REC<3> = 1     ;* this is the default
    END
*
    HEADER.REC<4> = MESSAGE.TYPE
    HEADER.REC<5> = LEG.CCY
    IF HEADER.REC<5> = '' THEN
        HEADER.REC<5> = R$SWAP<SW.AS.CURRENCY>    ;* default
    END
*
    HEADER.REC<6> = R.USER<EB.USE.DEPARTMENT.CODE>
    HEADER.REC<7> = C$SWAP.ID ;* transaction reference. TAG 20, 21N, SEQ A
*
* optional fields
*
    CUST.NO = R$SWAP<SW.CUSTOMER>
    IF MESSAGE.TYPE MATCHES 202:VM:210:VM:103 THEN          ;* BG_100004515
        HEADER.REC<10> = ACCOUNT.NUMBER
        CUST.NO = R.ACCOUNT<AC.CUSTOMER>
        IF CUST.NO = '' THEN
            CUST.NO = ID.COMPANY
        END
    END
    HEADER.REC<8> = CUST.NO
*
    F.CUSTOMER = '' ;* BG_100016891
    CUST.LANG = R.COMPANY(EB.COM.LANGUAGE.CODE)
    IF CUST.NO <> ID.COMPANY THEN
        CALL F.READ('F.CUSTOMER',CUST.NO,R.CUSTOMER,F.CUSTOMER,"")    ;* EN_10002475 - S      ;* BG_100016891
        CUST.LANG = R.CUSTOMER<EB.CUS.LANGUAGE>   ;* EN_10002475 - E
    END
    HEADER.REC<9> = CUST.LANG
    IF MESSAGE.TYPE MATCHES 202:VM:210:VM:103 THEN          ;* CI_10013033 S ;* CI_10014897 S/E - Added 103
        HEADER.REC<11> = VALUE.DATE
    END ELSE        ;* CI_10013033 E

        COUNTRY.CODE = ''     ;**CI_10003707S
        COUNTRY.CODE=R.COMPANY(EB.COM.LOCAL.COUNTRY)
        RETURN.CODE = ""      ;*--- CI_10004554 S/E
        IF ACT.SCHED.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN   ;* CI_10016799 - S
            COUNTRY.CODE = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>   ;* CI_10035793 - S/E
        END         ;* CI_10016799 - E
        CALL WORKING.DAY('',R$SWAP<SW.MATURITY.DATE>,'','','',COUNTRY.CODE,'','',RETURN.CODE,'')
        IF RETURN.CODE = 0 THEN
            HEADER.REC<11> = R$SWAP<SW.MATURITY.DATE>
        END ELSE
            IF R$SWAP<SWAP$DATE.ADJUSTMENT> EQ '' AND R$SWAP<SWAP$DAY.CONVENTION> EQ '' THEN        ;* CI_10016799 - S
                HEADER.REC<11> = R$SWAP<SW.MATURITY.DATE>
            END ELSE          ;* CI_10016799 - E
                ADJ.MAT.DATE = R$SWAP<SW.MATURITY.DATE>
                CALL CDT('',ADJ.MAT.DATE,'+1W')
                HEADER.REC<11> = ADJ.MAT.DATE
            END     ;* CI_10016799 S/E
        END         ;**CI_10003707E
    END   ;*CI_10013033 S/E
    HEADER.REC<12> = AMOUNT.DUE         ;* from main loop
*
    HEADER.REC<13> = INTERMEDIARY
    HEADER.REC<14> = ACCT.WITH.BANK
    HEADER.REC<15> = R$SWAP<SW.CUSTOMER>          ;* beneficiary institution
    HEADER.REC<16> = BEN.ACCOUNT        ;* beneficiary account number
    HEADER.REC<17> = BANK.INFO          ;* bank to bank information
*
    SCHEDULE.DATE = R$SWAP<SW.VALUE.DATE>         ;*CI_7027 S
    PROCESS.DATE = ''
    ENTRY.DATE = ''
    EFFECTIVE.DATE = ''
    BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
    DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
    PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>
* CI_10014611-S
    IF ACT.SCHED.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN       ;* CI_10016799 S/E
        BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>   ;* CI_10035793 - S/E
    END
* CI_10014611-E
    CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,
    DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,
    EFFECTIVE.DATE)
*
    HEADER.REC<18> = PROCESS.DATE       ;*CI_7027 E
*
    RETURN
*
**********************
BUILD.ADDITIONAL.INFO:
**********************
*
    ADDITIONAL.REC = ''
    INTEREST.REC = ""         ;* Contains interest related information
    PRINCIPAL.REC = ""        ;* Contains principal repayment information
    SW.ASSET.PI = 0 ;*CI_10013033 S
    SW.ASSET.PD = 0
    SW.LIAB.PI = 0
    SW.LIAB.PD = 0  ;*CI_10013033 E

    GOSUB BUILD.CONTRACT.DETAILS
*
    IF ACT.SCHED.INDEX OR NET.VALUE THEN          ;* just need information for this schedule
        *
        * determine this schedule is payable or receivable
        *
        SCHED.TYPE = ACT.SCHED.TYPE     ;**CI_10003825 S
        THIS.SCHED.TYPE = SCHED.TYPE
        LEG.TYPE = ACT.LEG.TYPE
        THIS.LEG.TYPE = LEG.TYPE        ;**CI_10003825 E
        PAY.RCV = ''
        CALL SW.DETERMINE.PAY.RECEIPT(THIS.SCHED.TYPE, THIS.LEG.TYPE, PAY.RCV)
        *
        * fill in the relevant fields
        *
        GOSUB BUILD.PAYMENT.FIELDS
        GOSUB BUILD.INTEREST.FIELDS
        GOSUB BUILD.PRINCIPAL.FIELDS
        GOSUB ADD.FUTURE.SCHEDULE
        *
    END ELSE
        *
        * this loop works backward to make sure that the first occurence of each
        * schedule type will not be overwritten
        * !!! needs changing when the delivery system can handle associated fields !!!
        *
        NO.OF.SCHED = DCOUNT(SCHEDULE.LIST<1>, VM)
        *--- EN_10000572 S
        Y.SEQ.J.PRIN = 0
        Y.SEQ.K.PRIN = 0
        *--- EN_10000572 E
        FOR SIDX = NO.OF.SCHED TO 1 STEP -1       ;* loop backward
            SCHED.DATE = SCHEDULE.LIST<2, SIDX>
            SCHED.TYPE = SCHEDULE.LIST<1, SIDX>
            VALUE.DATE = SCHEDULE.LIST<3, SIDX>
            AMOUNT.DUE = SCHEDULE.LIST<6, SIDX>
            SCHED.NARR = SCHEDULE.LIST<7, SIDX>
            LEG.TYPE = SCHEDULE.LIST<8, SIDX>
            SCHED.INDEX = SCHEDULE.LIST<9, SIDX>
            *
            * determine this schedule is payable or receivable
            * sign amount.due if receivable
            *
            THIS.SCHED.TYPE = SCHED.TYPE
            THIS.LEG.TYPE = LEG.TYPE
            PAY.RCV = ''
            CALL SW.DETERMINE.PAY.RECEIPT(THIS.SCHED.TYPE, THIS.LEG.TYPE, PAY.RCV)
            *
            * get leg info and settlement info
            *
            GOSUB DETERMINE.LEG.INFO
            THIS.LEG.CCY = LEG.CCY
            GOSUB GET.SETTLEMENT.INFO
            SCHED.DATE.FREQ = R$SWAP<SWAP$DATE.FREQ, SCHED.INDEX>
            FINAL.SCHED = R$SWAP<SWAP$FINAL.SCHED, SCHED.INDEX>
            *
            * fill in the relevant fields
            *
            GOSUB BUILD.PAYMENT.FIELDS
            GOSUB BUILD.INTEREST.FIELDS
            GOSUB BUILD.PRINCIPAL.FIELDS
            GOSUB ADD.FUTURE.SCHEDULE
        NEXT SIDX
        * EN_10000461 S
        *--- EN_10000572 S
        * Add business cities to field tag 72 seq A if field tag 22B of seq H,I,J,K,L,M = OTHR.
        IF Y.SEQ.H.BUS.CITIES.1 NE "" THEN        ;* PARTY B
            Y.BUS.CITIES<1,1> = Y.SEQ.H.BUS.CITIES.1
        END
        *
        IF MESSAGE.TYPE EQ "360" THEN   ;* For MT360 only.
            IF Y.SEQ.H.BUS.CITIES.2 NE "" THEN    ;* PARTY A
                Y.BUS.CITIES<1,2> = Y.SEQ.H.BUS.CITIES.2
            END
        END
        *
        IF MESSAGE.TYPE EQ "361" THEN   ;* For MT361 only
            IF Y.SEQ.I.BUS.CITIES NE "" THEN      ;* PARTY A
                Y.BUS.CITIES<1,2> = Y.SEQ.I.BUS.CITIES
            END
        END
        *
        IF Y.SEQ.L.BUS.CITIES NE "" THEN          ;* PARTY B
            Y.BUS.CITIES<1,1> = Y.SEQ.L.BUS.CITIES
        END
        *
        IF Y.SEQ.M.BUS.CITIES NE "" THEN          ;* PARTY A
            Y.BUS.CITIES<1,2> = Y.SEQ.M.BUS.CITIES
        END
        *
        IF Y.SEQ.J.BUS.CITIES NE "" THEN          ;* PARTY B
            Y.BUS.CITIES<1,1> = Y.SEQ.J.BUS.CITIES
        END
        *
        IF Y.SEQ.K.BUS.CITIES NE "" THEN          ;* PARTY A
            Y.BUS.CITIES<1,2> = Y.SEQ.K.BUS.CITIES
        END
        *
        IF Y.BUS.CITIES<1,1> NE "" THEN
            ADDITIONAL.REC<26,-1> = Y.BUS.CITIES<1,1>
        END
        *
        IF Y.BUS.CITIES<1,2> NE "" AND Y.BUS.CITIES<1,2> NE Y.BUS.CITIES<1,1> THEN
            ADDITIONAL.REC<26,-1> = Y.BUS.CITIES<1,2>
        END
        *
        * Add business day convention to field tag 72 seq A
        IF Y.SEQ.H.DAY.CON NE "" OR Y.SEQ.I.DAY.CON NE "" OR Y.SEQ.J.DAY.CON NE "" OR Y.SEQ.K.DAY.CON NE "" THEN
            ADDITIONAL.REC<26> = "/NONE/":VM:ADDITIONAL.REC<26>
        END
        *--- EN_10000572 E
        * EN_10000461 E
        *
    END
*
    RETURN
*
*
******************
BUILD.SPECIAL.REC:
******************
*
    SPECIAL.REC = ''
    IF R.ACTIVITY<SW.ACT.HANDOFF.ROUTINE> THEN
        HANDOFF.ROUTINE = R.ACTIVITY<SW.ACT.HANDOFF.ROUTINE>
        CALL @HANDOFF.ROUTINE(SPECIAL.REC)
    END
*
    RETURN
*
*
*************************
CALL.APPLICATION.HANDOFF:
*************************
*
    RECORD1 = R$SWAP
    RECORD2 = R.OLD.SWAP
    RECORD3 = R$SW.ASSET.BALANCES
    RECORD4 = R$SW.LIABILITY.BALANCES
    RECORD5 = HEADER.REC
    RECORD6 = ADDITIONAL.REC
    RECORD7 = SPECIAL.REC
    RECORD8 = INTEREST.REC
    RECORD9 = PRINCIPAL.REC
*
    MAPPING.KEY = MESSAGE.TYPE:'.SW.1'
    DELIVERY.REF = ''
    YERR = ''
    CALL APPLICATION.HANDOFF(RECORD1,
    RECORD2,
    RECORD3,
    RECORD4,
    RECORD5,
    RECORD6,
    RECORD7,
    RECORD8,
    RECORD9,
    MAPPING.KEY,
    DELIVERY.REF,
    YERR)
*
    RETURN
*
*
******************
PRODUCE.DEAL.SLIP:
******************
*
    DEAL.SLIP = RAISE(DEAL.SLIP)
    IF DEAL.SLIP THEN
        MAT R.NEW.SAVE = MAT R.NEW
        ID.NEW.SAVE = ID.NEW
        APPLICATION.SAVE = APPLICATION
        *
        IF R$SWAP<SW.SEND.CONFIRMATION> = 'Y' THEN
            MATPARSE R.NEW FROM R$SWAP
            ID.NEW = C$SWAP.ID
            APPLICATION = 'SWAP'
            CALL DEAL.SLIP.PRINT(DEAL.SLIP, '')
        END
        *
        MAT R.NEW = MAT R.NEW.SAVE
        ID.NEW = ID.NEW.SAVE
        APPLICATION = APPLICATION.SAVE
    END
*
    RETURN
*
*
***************************************
*
* subroutines for BUILD.ADDITIONAL.INFO
*
***************************************
*
***********************
BUILD.CONTRACT.DETAILS:
***********************
*
* related reference is either 'FIRST' for first rate reset or
* 'NEW' for new contract confirmation
* otherwise, must be the previous contract id
*
    NEXT.RESET = ''
    RELATED.REF = C$SWAP.ID
*
** Store the base schedule types
*
    AS.SCHED.LIST = SUBSTRINGS(R$SWAP<SW.AS.TYPE>,1,2)
    LB.SCHED.LIST = SUBSTRINGS(R$SWAP<SW.LB.TYPE>,1,2)
    FULL.SCHED.LIST = AS.SCHED.LIST:VM:LB.SCHED.LIST
*
    IF ACT.SCHED.TYPE = 'RR' OR ACT.SCHED.TYPE = 'IP' THEN
        SWIFT.CODE = 'NEWT'
    END ELSE
        SWIFT.CODE = 'AMND'
        IF ACTIVITY.CODE = 101 THEN
            SWIFT.CODE = 'NEWT'
        END ELSE
            IF ACTIVITY.CODE = 107 THEN
                SWIFT.CODE = 'CANC'
            END
        END
    END

    IF ACTIVITY.CODE = '114' THEN
        SWIFT.CODE = 'NEWT'
    END
    IF ACTIVITY.CODE = '115' THEN
        SWIFT.CODE = 'AMND'
    END

    ADDITIONAL.REC<26, -1> = R$SWAP<SW.BANK.INFO> ;*TAG 72, SEQ A

* code/common reference
    COMMON.REF = ''
    Y.MAT.DATE = ''
    Y.MAT.DATE<1> = R$SWAP<SW.MATURITY.DATE>[3,4]
* Flag to Indentify the "YYMM" format in the EB.GET.SWIFT.COMMON.REF routine.
    Y.MAT.DATE<2> = '1'
    CALL EB.GET.SWIFT.COMMON.REF(R$SWAP<SW.CUSTOMER>, Y.MAT.DATE, COMMON.REF)
    ADDITIONAL.REC<2> = SWIFT.CODE:'/':COMMON.REF
    ADDITIONAL.REC<24> = SWIFT.CODE     ;* MT360,361,362 TAG 22A, SEQ A
    ADDITIONAL.REC<25> = COMMON.REF     ;* TAG 22C, SEQ A
    ADDITIONAL.REC<1> = RELATED.REF     ;* TAG 21 SEQ A

    IF MESSAGE.TYPE MATCHES '360':VM:'361':VM:'362' AND SWIFT.CODE = 'NEWT' THEN
        ADDITIONAL.REC<1> = '' ;
    END

* further identification is either FIXEDFIXED, FIXEDFLOAT or FLOATFLOAT
* This also includes CAP, FLOOR or COLLAR. CAP, COLLAR FLOOR are n=only set if there is a
* premium payment ** This code is currently commented out
* followed by NET/GROSS
    IF R$SWAP<SW.AS.FIXED.RATE> <> '' OR R$SWAP<SW.AS.FIXED.INTEREST> = 'Y' THEN
        FURTHER.ID2 = 'FIXED'
    END ELSE
        FURTHER.ID2 = "FLOAT" ;* Check for CAP and FLOOR
        * CHECK CAP FLOOR COLLAR
        IF 'PMPR' MATCH FULL.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE>:VM:R$SWAP<SW.AS.TYPE> THEN
            Y.ASSET.PM = 1
        END
        *
        IF 'RV' MATCH FULL.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE>:VM:R$SWAP<SW.AS.TYPE> THEN
            Y.ASSET.RV = 1
        END
        *
        BEGIN CASE
            CASE R$SWAP<SW.AS.CAP.RATE> NE "" AND R$SWAP<SW.LB.FLOOR.RATE> NE ""
                Y.CAP.FLO.COL = 'COLLAR'
            CASE R$SWAP<SW.LB.CAP.RATE> NE "" AND R$SWAP<SW.AS.FLOOR.RATE> NE ""
                Y.CAP.FLO.COL = 'COLLAR'
            CASE R$SWAP<SW.AS.CAP.RATE> NE ""
                Y.CAP.FLO.COL = 'CAP':VM:'A'
            CASE R$SWAP<SW.AS.FLOOR.RATE> NE ""
                Y.CAP.FLO.COL = 'FLOOR':VM:'A'
        END CASE
    END
*
    IF R$SWAP<SW.LB.FIXED.RATE> <> '' OR R$SWAP<SW.LB.FIXED.INTEREST> = 'Y' THEN
        FURTHER.ID1 = 'FIXED'
    END ELSE
        FURTHER.ID1 = 'FLOAT'
        * CHECK CAP FLOOR COLLAR
        IF 'PMPR' MATCH FULL.LIAB.BALANCES<SW.BAL.SCHEDULE.TYPE>:VM:R$SWAP<SW.LB.TYPE> THEN
            Y.LIAB.PM = 1
        END
        *
        IF 'RV' MATCH FULL.LIAB.BALANCES<SW.BAL.SCHEDULE.TYPE>:VM:R$SWAP<SW.LB.TYPE> THEN
            Y.LIAB.RV = 1
        END
        *
        * If we find any CAP, FOLLR RATE set for AS, don't consider LB
        *
        IF Y.CAP.FLO.COL EQ "" THEN
            BEGIN CASE
                CASE R$SWAP<SW.LB.CAP.RATE> NE "" AND R$SWAP<SW.AS.FLOOR.RATE> NE ""
                    Y.CAP.FLO.COL = 'COLLAR'
                CASE R$SWAP<SW.AS.CAP.RATE> NE "" AND R$SWAP<SW.LB.FLOOR.RATE> NE ""
                    Y.CAP.FLO.COL = 'COLLAR'
                CASE R$SWAP<SW.LB.CAP.RATE> NE ""
                    Y.CAP.FLO.COL = 'CAP':VM:'L'
                CASE R$SWAP<SW.LB.FLOOR.RATE> NE ""
                    Y.CAP.FLO.COL = 'FLOOR':VM:'L'
            END CASE
        END
    END
*
** Now decide on the final format
** Use the following decision table:
** Side 1 or 2 is FIXED and the other side is CAP or FLOOR set to FLOOR
** If both sides are CAP then set to COLLAR
** If both sides are FLOOR then set to COLLAR
** If both sides are COLLAR then set to COLLAR
* CHECK CAP FLOOR COLLAR
    IF Y.CAP.FLO.COL NE "" THEN
        BEGIN CASE
            CASE Y.CAP.FLO.COL<1,2> EQ 'A'
                BEGIN CASE
                    CASE Y.CAP.FLO.COL<1,1> EQ 'CAP' AND Y.LIAB.PM
                        FURTHER.ID1 = 'CAP'
                        FURTHER.ID2 = 'BUYER'
                    CASE Y.CAP.FLO.COL<1,1> EQ 'FLOOR' AND Y.LIAB.PM
                        FURTHER.ID1 = 'FLOOR'
                        FURTHER.ID2 = 'BUYER'
                END CASE
            CASE Y.CAP.FLO.COL<1,2> EQ 'L'
                BEGIN CASE
                    CASE Y.CAP.FLO.COL<1,1> EQ 'CAP' AND Y.ASSET.RV
                        FURTHER.ID1 = 'CAP'
                        FURTHER.ID2 = 'SELLER'
                    CASE Y.CAP.FLO.COL<1,1> EQ 'FLOOR' AND Y.ASSET.RV
                        FURTHER.ID1 = 'FLOOR'
                        FURTHER.ID2 = 'SLLER'
                END CASE
            CASE Y.CAP.FLO.COL<1,2> EQ ""
                BEGIN CASE
                    CASE Y.CAP.FLO.COL<1,1> EQ 'COLLAR' AND Y.LIAB.PM
                        FURTHER.ID1 = 'COLLAR'
                        FURTHER.ID2 = 'BYER'
                    CASE Y.CAP.FLO.COL<1,1> EQ 'COLLAR' AND Y.ASSET.RV
                        FURTHER.ID1 = 'COLLAR'
                        FURTHER.ID2 = 'SLLR'
                END CASE
        END CASE
    END
    BEGIN CASE
        CASE 1
            FURTHER.ID = FURTHER.ID1:FURTHER.ID2      ;* Should not happen
    END CASE
*
    IF R$SWAP<SW.NET.PAYMENTS> = 'Y' THEN
        FURTHER.ID := '/NET'
    END ELSE
        FURTHER.ID := '/GROSS'
    END
    ADDITIONAL.REC<3> = FURTHER.ID      ;* TAG 23A, SEQ A
*
* contract agreement/amendment date
    IF SWIFT.CODE = 'NEWT' OR TODAY GT R$SWAP<SW.TRADE.DATE> THEN     ;* * CI_10002521 S/E
        ADDITIONAL.REC<4> = R$SWAP<SW.TRADE.DATE> ;* contract date. TAG 30T, SEQ A
        ACTION.DATE = R$SWAP<SW.TRADE.DATE>
    END ELSE
        ADDITIONAL.REC<4> = TODAY       ;* amendment date. TAG 30T, SEQ A
        ACTION.DATE = TODAY
    END
*
**
* contract conditions
* If the AGREEMENT.TYPE contains xxxx/ddddd//nn then pass this
* other wise set it to other and pass the CONDITIONS field
*
* EN_10000461 S
*
    Y.AGREEMENT.TYPE = FIELD(R$SWAP<SW.AGREEMENT.TYPE>,'/',1)
    Y.AGREEMENT.DATE = FIELD(R$SWAP<SW.AGREEMENT.TYPE>,'/',2)
    Y.AGREEMENT.VERSION = FIELD(R$SWAP<SW.AGREEMENT.TYPE>,'/',4)
* Check agreement type match AFB,BBAIRS,ISDA or not
    BEGIN CASE
        CASE Y.AGREEMENT.TYPE EQ "BBAIRS"
            ADDITIONAL.REC<22> = Y.AGREEMENT.TYPE     ;* TAG 77H, SEQ A
            ADDITIONAL.REC<5> = R$SWAP<SW.CONDITIONS> ;* TAG 77D, SEQ A
        CASE Y.AGREEMENT.TYPE EQ "ISDA" OR Y.AGREEMENT.TYPE EQ "AFB"
            * Default value if date and version is blank
            IF Y.AGREEMENT.DATE EQ "" THEN
                Y.AGREEMENT.DATE = '19910101'
            END
            *
            IF Y.AGREEMENT.VERSION EQ "" THEN
                Y.AGREEMENT.VERSION = '1991'
            END
            *
            ADDITIONAL.REC<22> = Y.AGREEMENT.TYPE:'/':Y.AGREEMENT.DATE:'//':Y.AGREEMENT.VERSION         ;* TAG 77H, SEQ A
            ADDITIONAL.REC<5> = R$SWAP<SW.CONDITIONS> ;* TAG 77D, SEQ A
        CASE 1
            ADDITIONAL.REC<22> = 'OTHER'    ;* TAG 77H, SEQ A
            CONDITIONS = "/":R$SWAP<SW.AGREEMENT.TYPE>:"/"
            IF R$SWAP<SW.CONDITIONS> THEN
                NUM.CONDS = DCOUNT(R$SWAP<SW.CONDITIONS>, VM)
                FOR I = 1 TO NUM.CONDS
                    CONDITIONS := VM:"//":R$SWAP<SW.CONDITIONS, I>
                NEXT I
            END
            ADDITIONAL.REC<5> = CONDITIONS  ;* TAG 77D, SEQ A
    END CASE
*
** Set up the Agreement Year from the AGREEMENT TYPE record for the
** base type. If Null , use 1991 as a default
    BEGIN CASE
        CASE Y.AGREEMENT.TYPE EQ "BBAIRS" OR Y.AGREEMENT.TYPE EQ "AFB"
            ADDITIONAL.REC<23> = "0000"     ;* TAG 14C, SEQ A
        CASE 1
            SWAT.REC = "" ; SWAT.ID = R$SWAP<SW.AGREEMENT.TYPE>["/",1,1]
            CALL CACHE.READ('F.SWAP.AGREEMENT.TYPE', SWAT.ID, SWAT.REC, "")         ;* GLOBUS_BG_100007219 S/E
            ADDITIONAL.REC<23> = SWAT.REC<SW.AGR.TYP.ISDA.DEF.DATE>[1,4]  ;* Year only ; * TAG 77D, SEQ A
            IF ADDITIONAL.REC<23> = "" THEN ADDITIONAL.REC<23> = Y.AGREEMENT.VERSION          ;* TAG 77D, SEQ A CI_10002510 S/E
    END CASE

* account identification is our nostro account number from agency
* If not present pass the customer number instead
*
    IF ACCOUNT.NUMBER THEN
        OUR.NOSTRO = ''
        CALL GET.EXT.ACC.NO(R.ACCOUNT<AC.CUSTOMER>, ACCOUNT.NUMBER, OUR.NOSTRO)
        ADDITIONAL.REC<6> = OUR.NOSTRO
        IF NOT(OUR.NOSTRO) THEN
            ADDITIONAL.REC<7> = R.ACCOUNT<AC.CUSTOMER>
        END
    END
*
* determine if amortisation flag is to be set. If a PI or PD schedule is
* defined set to Y
    SAVE.FULL.SCHED.LIST = FULL.SCHED.LIST
    IF SWIFT.CODE EQ "AMND" THEN
        FULL.SCHED.LIST = SCHEDULE.LIST
    END

    LOCATE "PI" IN FULL.SCHED.LIST<1,1> SETTING AMORT.POS ELSE
        LOCATE "PD" IN FULL.SCHED.LIST<1,1> SETTING AMORT.POS ELSE
            LOCATE "NI" IN FULL.SCHED.LIST<1,1> SETTING AMORT.POS ELSE
                LOCATE "ND" IN FULL.SCHED.LIST<1,1> SETTING AMORT.POS ELSE
                    AMORT.POS = ""
                END
            END
        END
    END
*
    FULL.SCHED.LIST = SAVE.FULL.SCHED.LIST        ;* BG_100006092 S/E

    IF AMORT.POS THEN
        AMORTISATION = "Y"
    END ELSE
        AMORTISATION = "N"
    END
    ADDITIONAL.REC<20> = AMORTISATION

** If AS DAY CONVENTION = LB DAY CONVENTION pass the contract convention
    IF R$SWAP<SW.AS.DAY.CONVENTION> = R$SWAP<SW.LB.DAY.CONVENTION> THEN
        ADDITIONAL.REC<21> = R$SWAP<SW.AS.DAY.CONVENTION>   ;* TAG 41A ,SEQ A
    END
*
    IF MESSAGE.TYPE EQ "103" THEN
        ADDITIONAL.REC<31> = "CRED"
        ADDITIONAL.REC<32> = "SHA"
        *
        SW.CUST.NO = ''
        CURR.AMT.REQ = ''
        *
        SENDER.COUNTRY = R.COMPANY(EB.COM.LOCAL.COUNTRY)
        *
        IF R.ACCOUNT<AC.CUSTOMER> THEN
            SW.CUST.NO = R.ACCOUNT<AC.CUSTOMER>
        END
        *
        CUST.ADDR = ''
        CALL DBR("CUSTOMER":FM:EB.CUS.RESIDENCE: FM:".A",SW.CUST.NO,CUST.ADDR)
        RECEIVER.COUNTRY = CUST.ADDR
        *
        * Hard coding of European Union countires and verifing of sender and
        * receiver countries are removed from this routine and the same has been
        * achieved by calling DE.CHECK.EU.CTRY.
        CALL DE.CHECK.EU.CTRY(SENDER.COUNTRY,RECEIVER.COUNTRY,CURR.AMT.REQ)
        IF NOT(CURR.AMT.REQ) THEN
            ADDITIONAL.REC<33> = ''
            ADDITIONAL.REC<34> = ''
        END ELSE
            ADDITIONAL.REC<33> = R.NEW(SW.AS.CURRENCY)
            ADDITIONAL.REC<34> = R.NEW(SW.AS.PRINCIPAL)
        END
    END
*
    ADDITIONAL.REC<36> = R.NEW(SW.AS.CURRENCY)
    ADDITIONAL.REC<37> = R.NEW(SW.AS.PRINCIPAL)
    ADDITIONAL.REC<33> = R.NEW(SW.LB.CURRENCY)
    ADDITIONAL.REC<34> = R.NEW(SW.LB.PRINCIPAL)
    RETURN
*
*********************
BUILD.PAYMENT.FIELDS:
*********************
* only for PM or RV schedules
    IF (THIS.SCHED.TYPE MATCHES 'PM':VM:'RV') AND PAY.RCV THEN
        IF PAY.RCV = 'R' THEN
            OFFSET = 50
            AMOUNT.DUE = '-':AMOUNT.DUE ;* because of 33X
        END ELSE
            OFFSET = 70       ;* may need changing if no. of fields in this section changed
        END
        *
        Z = 0       ;* payment fields start at 0
        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = 1      ;* Sequence indicator
        * Sequence L and M
        Z += 1      ;* TAG 30F, SEQ L,M
        IF PRINCIPAL.REC<Z+OFFSET> EQ "" THEN
            PRINCIPAL.REC<Z+OFFSET> = VALUE.DATE
        END ELSE
            PRINCIPAL.REC<Z+OFFSET> = VALUE.DATE:VM:PRINCIPAL.REC<Z+OFFSET>
        END
        *
        Z += 1      ;* TAG 32M, SEQ L,M
        IF PRINCIPAL.REC<Z+OFFSET> EQ "" THEN
            PRINCIPAL.REC<Z+OFFSET> = LEG.CCY
        END ELSE
            PRINCIPAL.REC<Z+OFFSET> = LEG.CCY:VM:PRINCIPAL.REC<Z+OFFSET>
        END
        *
        Z += 1      ;* TAG 32M, SEQ L,M
        IF PRINCIPAL.REC<Z+OFFSET> EQ "" THEN
            PRINCIPAL.REC<Z+OFFSET> = AMOUNT.DUE
        END ELSE
            PRINCIPAL.REC<Z+OFFSET> = AMOUNT.DUE:VM:PRINCIPAL.REC<Z+OFFSET>
        END
        *
        IF NOT(SAME.PI.SETTLE) THEN
            Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = INTERMEDIARY
            Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = ACCT.WITH.BANK
            Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = BANK.INFO
            Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = EXT.ACC.NO
        END ELSE
            Z += 4
        END
        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> += 1     ;* TAG 18A, SEQ L,M

        IF MESSAGE.TYPE EQ "360" THEN
            Z += 1 ; PRINCIPAL.REC<Z+OFFSET, -1> = 'PRMP'   ;* TAG 22E, SEQ L,M
        END
        ELSE IF MESSAGE.TYPE EQ "361" THEN
        Z += 1 ; PRINCIPAL.REC<Z+OFFSET, -1> = 'FEES'   ;* TAG 22E, SEQ L,M
    END
*
    GOSUB PROCESS.22B
    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = R$SWAP<SWAP$DAY.CONVENTION>          ;* TAG
    IF PRINCIPAL.REC<Z+OFFSET> EQ "" THEN
        PRINCIPAL.REC<Z+OFFSET> = 'OTHER'     ;* TAG 14A, SEQ L,M
    END
    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = NO.BUS.CENTRES   ;* TAG 18A, SEQ L,M
    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = BUS.CITIES       ;* TAG 22B, SEQ L,M
*
    IF OFFSET EQ 70 THEN  ;* SEQ M
        Y.SEQ.M.BUS.CITIES = BUS.ADDITIONAL.INFO
    END
    ELSE IF OFFSET EQ 50 THEN       ;* SEQ L
    Y.SEQ.L.BUS.CITIES = BUS.ADDITIONAL.INFO
    END
    END
    RETURN
*
**********************
BUILD.INTEREST.FIELDS:
**********************
* MT360, 361, 362 all share this section
    IF THIS.SCHED.TYPE EQ 'IP' OR THIS.SCHED.TYPE EQ 'RR' THEN        ;*** CI_10009773 s/e
        IF R$SWAP<SW.AS.FIXED.RATE> EQ '' THEN
            ASSET.FLOATING = 1
        END ELSE
            ASSET.FLOATING = 0
        END
        IF R$SWAP<SW.LB.FIXED.RATE> EQ '' THEN
            LIAB.FLOATING = 1
        END ELSE
            LIAB.FLOATING = 0
        END

        Y.WE.PAY.RCV = "" ;
        * for contract confirmation, use the rate key + spread
        * otherwise, use the current.rate when the rate is known
        * if ACT.SCHED.TYPE = 'RR' then it must be a MT362 message
        * so use the current.rate
        IF R$SWAP<SWAP$FIXED.RATE> OR ACT.SCHED.TYPE = 'RR' THEN
            NUMERIC.FIELD = R$SWAP<SWAP$CURRENT.RATE>
            GOSUB SWIFT.FORMAT.NUMERIC
            INT.RATE = NUMERIC.FIELD
            SPREAD = ""
            MARKET.RATE.DESC = ""
            RR.SCHED = 1 ; IP.SCHED = ""
        END ELSE    ;* contract confirmation of floating leg
            INT.RATE.KEY = R$SWAP<SWAP$RATE.KEY>
            INT.RATE = ''
            MARKET.RATE.DESC = ''
            CALL CACHE.READ('F.MARKET.RATE.TEXT',INT.RATE.KEY,R.MARKET.RATE.TEXT,"")      ;* EN_10002475 - S
            MARKET.RATE.DESC = R.MARKET.RATE.TEXT<EB.MRT.RATE.TEXT>   ;* EN_10002475 - E
            GOSUB GET.SPREAD
            IP.SCHED = 1 ; RR.SCHED = ""
        END
        *
        IF THIS.SCHED.TYPE = 'IP' THEN
            FREQ.CODE = SCHED.DATE.FREQ[9,3]
            GOSUB DETERMINE.PAYMENT.PERIOD
            GOSUB DETERMINE.PAYMENT.SCHEDULE
        END
        *
        IF NEXT.RESET THEN
            DATE.RESET = NEXT.RESET
        END ELSE
            *
            * get the first rate reset date on the same leg
            *
            DATE.RESET = ''
            FOR I = 1 TO DCOUNT(SCHEDULE.LIST<1>, VM)
                IF SCHEDULE.LIST<1, I> = 'RR' AND SCHEDULE.LIST<8, I> = THIS.LEG.TYPE THEN
                    DATE.RESET = SCHEDULE.LIST<2, I>
                    EXIT      ;* this should exit the for loop
                END
            NEXT I
        END
        *
        * PAY.RCV is not set for 'RR'
        *
        IF THIS.SCHED.TYPE = 'RR' THEN
            IF THIS.LEG.TYPE = 'A' THEN
                PAY.RCV = 'R'
            END ELSE
                PAY.RCV = 'P'
            END
        END
        *
        ** We now have to build the information for the sequences B,C,E,F
        ** These are conditional upon ASSET / LIAB and FLOAT and FIXED
        ** Interest Details are held in the follwoing additional fields
        *
        FOR AL.FLOATFIX = 1 TO 2        ;* 1 = Fixed, 2 = Float
            IF PAY.RCV = 'R' THEN
                IF AL.FLOATFIX = 1 THEN
                    * Check network validated rule C10 for seq B
                    BEGIN CASE
                        CASE FURTHER.ID2 EQ "FIXED"
                        CASE 1
                            GOTO NEXT.AL.FLOATFIX
                    END CASE
                    OFFSET = 0          ;* SEQ B OFFSET
                END ELSE
                    * Check network validated rule C10 for seq C
                    BEGIN CASE
                        CASE FURTHER.ID2 EQ "FLOAT"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "CAPBUYER"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "FLOORBUYER"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "COLLARBYER"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "COLLARSLLR"
                            *
                        CASE 1
                            GOTO NEXT.AL.FLOATFIX     ;* Fixed Contract
                    END CASE
                    OFFSET = 30         ;* SEQ C OFFSET
                END
                PAY.DETS.OFFSET = 60    ;* SEQ D OFFSET
                INT.DETAILS.FLD = SW.AS.INTEREST.DET
            END ELSE
                IF AL.FLOATFIX = 1 THEN
                    * Check network validated rules C10 for SEQ E
                    BEGIN CASE
                        CASE FURTHER.ID1 EQ "FIXED"
                        CASE 1
                            GOTO NEXT.AL.FLOATFIX
                    END CASE
                    * SEQ E OFFSET
                    OFFSET = 80         ;* may need changing if no. of fields in this section changed
                END ELSE
                    * Check network validated rules C10 for SEQ F
                    BEGIN CASE
                        CASE FURTHER.ID1 EQ "FLOAT"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "CAPSELLER"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "FLOORSLLER"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "COLLARBYER"
                        CASE FURTHER.ID1:FURTHER.ID2 EQ "COLLARSLLR"
                        CASE 1
                            GOTO NEXT.AL.FLOATFIX
                    END CASE
                    OFFSET = 110        ;* SEQ F OFFSET
                END
                PAY.DETS.OFFSET = 140   ;* SEQ G OFFSET
                INT.DETAILS.FLD = SW.LB.INTEREST.DET
            END
            *
            Z = 0   ;* interest fields start at 19
            *
            Z += 1 ; INTEREST.REC<Z+OFFSET> = 1   ;* Sequence indicator
            Z += 1
            IF INT.RATE < 0 ELSE        ;* CI_10010451
                INTEREST.REC<Z+OFFSET> = INT.RATE ;* TAG 37U, SEQ B, E
            END

            Z += 1 ;
            IF (OFFSET EQ '0' OR OFFSET EQ '80') AND INT.RATE NE '' THEN
                INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$BASIS> ;* TAG 14D, SEQ B,E
            END ELSE
                IF (OFFSET EQ '30' OR OFFSET EQ '110') AND INT.RATE.KEY NE '' THEN
                    INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$BASIS>       ;* TAG 14D, SEQ C,F
                END
            END     ;* CI_10016799 - E
            Z += 1 ; INTEREST.REC<Z+OFFSET> = RAISE(SCHED.NARR)       ;* interest details where applicable
            Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>      ;* interest effective date
            Z += 1 ; INTEREST.REC<Z+OFFSET> = LEG.CCY
            *
            IF ACTIVITY.CODE = 101 THEN ;* Contract Initiation
                CURRENT.PRINCIPAL = R$SWAP<SWAP$PRINCIPAL>  ;* the original principal
            END ELSE
                CURRENT.PRINCIPAL = R$SW.BALANCES<SW.BAL.PRINCIPAL, 1>          ;* outstanding princiapl
            END
            Z += 1 ; INTEREST.REC<Z+OFFSET> = CURRENT.PRINCIPAL       ;* the current calculation amount
            *
            IF THIS.SCHED.TYPE = 'IP' THEN
                Z += 1 ; INTEREST.REC<Z+OFFSET> = PAY.PERIOD          ;* TAG 38E, SEQ C, F
                Z += 1 ; INTEREST.REC<Z+OFFSET> = PAY.SCHED ;* TAG 30F, SEQ B,C,E,F
                Z += 1 ; INTEREST.REC<Z+OFFSET> = PAY.SCHED.IDX       ;* TAG 18A, SEQ B,C,E,F
                Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$DAY.CONVENTION>   ;* TAG 14A, SEQ B,C,E,F
                * Default "OTHER" to field tag 14A
                IF INTEREST.REC<Z+OFFSET> EQ "" THEN
                    INTEREST.REC<Z+OFFSET> = 'OTHER'
                END
            END ELSE
                Z += 4        ;* skip the payment fields
            END
            *
            Z += 1 ; INTEREST.REC<Z+OFFSET> = VALUE.DATE
            Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT>
            Z += 1 ; INTEREST.REC<Z+OFFSET> = DATE.RESET
            *
            ** Extract the principal business centre for the countries /regions
            ** used
            * Field tag 22B
            GOSUB PROCESS.22B
            Z += 1 ; INTEREST.REC<Z+OFFSET> = NO.BUS.CENTRES          ;* TAG 18A, SEQ B,C,E,F
            Z += 1 ; INTEREST.REC<Z+OFFSET> = BUS.CITIES    ;* TAG 22B, SEQ B,C,E,F
            ** For Floating contracts add the FLOAT day option. This is calculated
            ** as the combination of CURRENCY /  MARKET RATE TYPE / MASTER AGRREMENT TYPE
            IF MARKET.RATE.DESC MATCHES "1X0X'-'1X0X'-'1X0X" THEN     ;* CI_10017101 S/E
                FLOAT.RATE.OPTION = MARKET.RATE.DESC
                ADDITIONAL.INT.DETS = ""
            END ELSE
                FLOAT.RATE.OPTION = "OTHER"
                ADDITIONAL.INT.DETS = MARKET.RATE.DESC
            END
            Z += 1 ; INTEREST.REC<Z+OFFSET> = FLOAT.RATE.OPTION       ;* TAG 14F, SEQ C,F

            * Check network validated rule C17 for SEQ C,F
            GOSUB CHECK.C17
            IF Y.RULE.C17 EQ 1 THEN
                * Position of field tag 37U
                Y.37U.POS = 2
                IF OFFSET EQ Y.SEQ.C.OFFSET THEN
                    * Flating rate is SEQ C. Field 37U in SEQ B is mandatory
                    INTEREST.REC<Y.SEQ.B.OFFSET> = 1
                    INTEREST.REC<Y.SEQ.B.OFFSET+Y.37U.POS> = INT.RATE
                    GOSUB CLEAR.SEQ.C1.F1
                END ELSE IF OFFSET EQ Y.SEQ.F.OFFSET THEN
                    * Flating rate is SEQ F. Field 37U in SEQ E is mandatory
                    INTEREST.REC<Y.SEQ.E.OFFSET> = 1
                    INTEREST.REC<Y.SEQ.E.OFFSET+Y.37U.POS> = INT.RATE
                    GOSUB CLEAR.SEQ.C1.F1
                END
            END
            ** Cap / Floor Rates / Spread
            Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$CAP.RATE>         ;* TAG 37J, SEQ C,F
            Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$FLOOR.RATE>       ;* TAG 37L, SEQ C
            * RULE C16, C17
            IF Y.RULE.C17 NE 1 AND Y.AGREEMENT.TYPE NE "AFB" THEN
                Z += 1 ; INTEREST.REC<Z+OFFSET> = SPREAD          ;* TAG 37R, SEQ C,F
            END ELSE
                Z += 1
            END

            ** Get the RESET specification
            * RULE C17
            IF Y.RULE.C17 NE 1 THEN
                RESET.SPEC = "FIRST"          ;* CI_10002507 S/E
                Z += 1 ; INTEREST.REC<Z+OFFSET> = RESET.SPEC      ;* TAG 14J, SEQ C,F
            END ELSE
                Z += 1
            END

            Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$CURRENT.RATE>     ;* Latest rate   ; * Initial Floating rate
            IF ADDITIONAL.INT.DETS THEN
                INT.DETS = ADDITIONAL.INT.DETS
                IF R$SWAP<INT.DETAILS.FLD> THEN
                    INT.DETS := VM:R$SWAP<INT.DETAILS.FLD>
                    IF DATE.RESET THEN INT.DETS<1,-1> = "RESET DATE ":DATE.RESET
                END
                Z += 1 ; INTEREST.REC<Z+OFFSET> = INT.DETS        ;* TAG 37N, SEQ B,C,E,F
            END ELSE
                Z += 1 ;
                INTEREST.REC<Z+OFFSET> = R$SWAP<INT.DETAILS.FLD>  ;* TAG 37N, SEQ B,C,E,F
                IF DATE.RESET THEN INTEREST.REC<Z+OFFSET> = "RESET DATE ":DATE.RESET
            END
            * If 22B = OTHR then business centre will be add in tag 37N
            IF BUS.ADDITIONAL.INFO THEN
                INTEREST.REC<Z+OFFSET,-1> = BUS.ADDITIONAL.INFO   ;* TAG 37N, SEQ B,C,E,F
            END
            * If business day convention is null then 1st line of 37N must has value 'NONE'
            IF R$SWAP<SWAP$DAY.CONVENTION> EQ "" THEN
                IF INTEREST.REC<Z+OFFSET,1> NE 'NONE' THEN
                    IF INTEREST.REC<Z+OFFSET> EQ "" THEN
                        INTEREST.REC<Z+OFFSET> = 'NONE' ;* TAG 37N, SEQ B,C,E,F
                    END ELSE
                        INTEREST.REC<Z+OFFSET> = 'NONE':VM:INTEREST.REC<Z+OFFSET>     ;* TAG 37N, SEQ B,C,E,F
                    END
                END
            END
            * Check period end date adjustment indicator
            IF Y.RULE.C17 NE 1 THEN
                Z += 1    ;*CI_10013891
                IF (OFFSET EQ '0' OR OFFSET EQ '80') AND INT.RATE NE '' THEN          ;*CI_10013891 ; * CI_10016799 - S
                    IF R$SWAP<SWAP$DATE.ADJUSTMENT> EQ "" OR R$SWAP<SWAP$DATE.ADJUSTMENT> EQ "VALUE" THEN ;* CI_10013239
                        INTEREST.REC<Z+OFFSET> = 'N'    ;* TAG 17F, SEQ B,C,E,F
                    END ELSE
                        INTEREST.REC<Z+OFFSET> = 'Y'    ;* TAG 17F, SEQ B,C,E,F
                    END
                END ELSE
                    IF (OFFSET EQ '30' OR OFFSET EQ '110') AND INT.RATE.KEY NE '' THEN
                        IF R$SWAP<SWAP$DATE.ADJUSTMENT> EQ "" OR R$SWAP<SWAP$DATE.ADJUSTMENT> EQ "VALUE" THEN       ;* CI_10013236
                            INTEREST.REC<Z+OFFSET> = 'N'          ;* TAG 17F, SEQ C,F
                        END ELSE
                            INTEREST.REC<Z+OFFSET> = 'Y'          ;* TAG 17F, SEQ C,F
                        END
                    END   ;* CI_10016799 - E
                END       ;*CI_10013891
            END ELSE
                Z += 1
            END
            *
            IF THIS.SCHED.TYPE EQ 'IP' AND Y.WE.PAY.RCV NE "" THEN
                Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.WE.PAY.RCV
            END ELSE
                Z += 1 ;
            END

            IF (OFFSET EQ 0) THEN
                IF R$SWAP<SW.AS.RATE.KEY> EQ '' THEN
                    LOCATE 'IP' IN R$SWAP<SW.AS.TYPE,1> SETTING AS.POS ELSE AS.POS = ''
                        IF AS.POS AND R$SWAP<SW.AS.AMOUNT,AS.POS> THEN
                            * MT361 [32M] [SEQU B CCY] [25]
                            IF R$SWAP<SW.AS.AMOUNT,AS.POS> LT 0 THEN
                                Z += 1 ; INTEREST.REC<Z+OFFSET> = "N":R$SWAP<SW.AS.CURRENCY>
                            END ELSE
                                Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SW.AS.CURRENCY>
                            END
                            * MT361 [32M] [SEQU B PAY AMT] [26]
                            Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SW.AS.AMOUNT,AS.POS>
                        END ELSE
                            Z += 1
                        END
                    END
                END
                IF (OFFSET EQ 80) THEN
                    IF R$SWAP<SW.LB.RATE.KEY> EQ '' THEN
                        LOCATE 'IP' IN R$SWAP<SW.LB.TYPE,1> SETTING LB.POS ELSE LB.POS = ''
                            IF LB.POS AND R$SWAP<SW.LB.AMOUNT,LB.POS> THEN
                                * MT361 [32M] [SEQU E CCY] [105]
                                IF R$SWAP<SW.LB.AMOUNT,LB.POS> LT 0 THEN
                                    Z += 1 ; INTEREST.REC<Z+OFFSET> = "N":R$SWAP<SW.LB.CURRENCY>
                                END ELSE
                                    Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SW.LB.CURRENCY>
                                END
                                * MT361 [32M] [SEQU E PAY AMT] [106]
                                Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SW.LB.AMOUNT,LB.POS>
                            END ELSE
                                Z += 1
                            END
                        END
                    END
                    * CI_10016799 - E
                    *
NEXT.AL.FLOATFIX:
                NEXT AL.FLOATFIX
                *
                ** Interest pay / receceive details
                *
                OFFSET = PAY.DETS.OFFSET
                Z = 0
                Z += 1 ; INTEREST.REC<Z+OFFSET> = INTERMEDIARY

**** CI_10009773 starts
                GOSUB GET.SETTLEMENT.INFO
**** CI_10009773 ends

                IF OFFSET = 140 THEN        ;**CI_10003707S
                    IF ACCT.WITH.BANK THEN  ;**CI_10003707E
                        Z += 1 ; INTEREST.REC<Z+OFFSET> = ACCT.WITH.BANK
                    END ELSE      ;**CI_10003707S
                        Z += 1 ; INTEREST.REC<Z+OFFSET> = ID.COMPANY
                    END
                END ELSE
                    YR.ACCT = ''
                    CHECK.CUST.ID = ''
                    CALL F.READ(FN.ACCOUNT, ACCOUNT.NUMBER, YR.ACCT, F.ACCOUNT, '')
                    IF YR.ACCT<AC.LIMIT.REF> = 'NOSTRO' THEN
                        CHECK.CUST.ID = YR.ACCT<AC.CUSTOMER>
                        Z += 1 ; INTEREST.REC<Z+OFFSET> = CHECK.CUST.ID
                    END ELSE
                        Z += 1 ; INTEREST.REC<Z+OFFSET> = ID.COMPANY
                    END
                END     ;**CI_10003707E
                * EN_10000461 S
                * In case of CAPBUYER ,FLOORBUYER, CAPSELLER, FLOORSLLER, 57a must have value = 'NONE'
                * See rule C10 of MT360
                BEGIN CASE
                    CASE FURTHER.ID['/',1,1] EQ 'CAPBUYER' OR FURTHER.ID['/',1,1] EQ 'FLOORBUYER'
                        INTEREST.REC<Z+140> = 'NONE'      ;* OFFSET OF SEQ G = 140
                    CASE FURTHER.ID['/',1,1] EQ 'CAPSELLER' OR FURTHER.ID['/',1,1] EQ 'FLOORSLLER'
                        INTEREST.REC<Z+60> = 'NONE'       ;* OFFSET OF SEQ D = 60
                END CASE
                * EN_10000461 E
                Z += 1 ; INTEREST.REC<Z+OFFSET> = BANK.INFO
                Z += 1 ; INTEREST.REC<Z+OFFSET> = EXT.ACC.NO

*** EN_10001752 starts
                SW.PAY.DATE = ''  ;* CI_17703 S/E
                CALL F.READ('F.SWAP.PAYMENT.DATE',ID.NEW,SW.PAY.DATE,F.SWAP.PAYMENT.DATE,'')
                SAVE.PERIOD.END = R.DATES(EB.DAT.PERIOD.END)
                IF SW.PAY.DATE<2> THEN R.DATES(EB.DAT.PERIOD.END) = SW.PAY.DATE<2>
                SAVE.ASSET.BALANCES = R$SW.ASSET.BALANCES
                SAVE.LIAB.BALANCES = R$SW.LIABILITY.BALANCES
                SAVE.SWAP = R$SWAP
                SAVE.SCHEDULE.LIST = SCHEDULE.LIST
                SCHEDULE.LIST = ''

                IF SW.PAY.DATE<2> AND RUNNING.UNDER.BATCH THEN  ;* CI_17703 S/E
                    Y.R$SWAP.SAVE = R$SWAP
                    Y.SAVE.LEG.TYPE = ACT.LEG.TYPE    ;* BG_100009171 - S

                    CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,'')    ;* EN_10002475 S/E
                    CALL CONV.SW.SCHEDULE.PROCESSING(SCHEDULE.LIST,2)
                    CALL CONV.SW.CYCLE.SCHEDULES(1)

                    ACT.LEG.TYPE = Y.SAVE.LEG.TYPE
                    R$SWAP = Y.R$SWAP.SAVE
                    CALL CONV.SW.DETERMINE.FIELDS(ACT.LEG.TYPE) ;* BG_100009171 - E
                END
                *
                ** Since message type 360 is not split by FLOAT/FIXED we need to
                ** details per leg for MT 362
                *
                IF (ACTIVITY.CODE = "114" OR ACTIVITY.CODE = "115") THEN  ;* CI_10030847 - S
                    * To get the Next span of IP schedule using common variable C$SW.NDAYS
                    * which is assigned from SW.DETERMINE.ACTIVITY

                    Y.WORKING.DAY = R$SWAP<SWAP$DATE.FREQ,ACT.SCHED.INDEX>[1,8]
                    IF NOT(C$SW.NDAYS) THEN GOSUB GET.DAYS.DELIVERY  ;    ;* CI_10030847 - E
                    CALL CDT("",Y.WORKING.DAY, C$SW.NDAYS)

                    AS.CNT = DCOUNT(FULL.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE>,VM)
                    LI.CNT = DCOUNT(FULL.LIAB.BALANCES<SW.BAL.SCHEDULE.TYPE>,VM)
                    Y.CNT = MAXIMUM(AS.CNT:VM:LI.CNT)
                    FOR I = 1 TO Y.CNT
                        IF FULL.ASSET.BALANCES<SW.BAL.PERIOD.START, I> =< Y.WORKING.DAY AND FULL.ASSET.BALANCES<SW.BAL.PERIOD.END, I> >= Y.WORKING.DAY AND FULL.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE, I> = "IP" THEN   ;* CI_10030492 S/E
                            Y.AS.START.PERIOD = FULL.ASSET.BALANCES<SW.BAL.PERIOD.START, I>
                            Y.AS.END.PERIOD = FULL.ASSET.BALANCES<SW.BAL.PERIOD.END, I>
                            Y.AS.CCY.AMOUNT = FULL.ASSET.BALANCES<SW.BAL.CCY.AMOUNT, I>
                        END
                        IF FULL.LIAB.BALANCES<SW.BAL.PERIOD.START, I> =< Y.WORKING.DAY AND FULL.LIAB.BALANCES<SW.BAL.PERIOD.END, I> >= Y.WORKING.DAY AND FULL.LIAB.BALANCES<SW.BAL.SCHEDULE.TYPE, I> = "IP" THEN      ;* CI_10030492 S/E
                            Y.LI.START.PERIOD = FULL.LIAB.BALANCES<SW.BAL.PERIOD.START, I>
                            Y.LI.END.PERIOD = FULL.LIAB.BALANCES<SW.BAL.PERIOD.END, I>
                            Y.LI.CCY.AMOUNT = FULL.LIAB.BALANCES<SW.BAL.CCY.AMOUNT, I>
                        END
                        IF FUTURE.BALANCES<SW.BAL.PERIOD.START, I> =< Y.WORKING.DAY AND FUTURE.BALANCES<SW.BAL.PERIOD.END, I> >= Y.WORKING.DAY AND FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE, I> = "IP" THEN     ;* CI_10030492 S/E
                            Y.START.PERIOD = FUTURE.BALANCES<SW.BAL.PERIOD.START, I>
                            Y.END.PERIOD = FUTURE.BALANCES<SW.BAL.PERIOD.END, I>
                            Y.CCY.AMOUNT = FUTURE.BALANCES<SW.BAL.CCY.AMOUNT, I>
                        END
                    NEXT I
                    *--- CI_10004731 E
                END
                ELSE
                Y.AS.START.PERIOD = R$SW.ASSET.BALANCES<SW.BAL.START.INT.PERIOD>
                Y.AS.END.PERIOD = R$SW.ASSET.BALANCES<SW.BAL.END.INT.PERIOD>
                Y.AS.CCY.AMOUNT = R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT>
                Y.LI.START.PERIOD = R$SW.LIABILITY.BALANCES<SW.BAL.START.INT.PERIOD>
                Y.LI.END.PERIOD = R$SW.LIABILITY.BALANCES<SW.BAL.END.INT.PERIOD>
                Y.LI.CCY.AMOUNT = R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT>
                Y.START.PERIOD = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
                Y.END.PERIOD = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
                Y.CCY.AMOUNT = R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT>
            END

            * If IP dates are the same, we will produce MT362 for both AS and LB legs.
            IF Y.AS.END.PERIOD EQ Y.LI.END.PERIOD THEN
                Y.INT.DIFF = Y.LI.CCY.AMOUNT - Y.AS.CCY.AMOUNT        ;*--- CI_10004731 S/E

                * Save some common variable
                Y.SAVE.LEG.TYPE = THIS.LEG.TYPE
                Y.SAVE.SW.BALANCES = R$SW.BALANCES

                * Build seq B (ASSET)
                OFFSET = 160
                Y.FIXED = R$SWAP<SW.AS.FIXED.RATE> <> '' OR R$SWAP<SW.AS.FIXED.INTEREST> = 'Y'
                CALL CONV.SW.DETERMINE.FIELDS('A')
                R$SW.BALANCES = R$SW.ASSET.BALANCES
                Y.CCY.AMOUNT = Y.AS.CCY.AMOUNT
                Y.START.PERIOD = Y.AS.START.PERIOD
                Y.END.PERIOD = Y.AS.END.PERIOD
                * CI_10016799 S/E - Removed the condition applied under CI_10013891
                THIS.LEG.CCY = R$SWAP<SWAP$CURRENCY>
                Y.INT.AMT = Y.AS.CCY.AMOUNT       ;*CI_10013891
**** EN_10001752 starts
                *                THIS.LEG.CCY = R$SWAP<SWAP$CURRENCY>
**** EN_10001752 ends

                GOSUB BUILD.362.SEQ.B.D

                * Build seq C (ASSET)
                IF NOT(R$SWAP<SW.NET.PAYMENTS> EQ 'Y' AND Y.INT.DIFF >= 0) THEN ;* Party B pay interest.
                    IF R$SWAP<SW.NET.PAYMENTS> EQ 'Y' THEN
                        Y.INT.AMT = ABS(Y.INT.DIFF)
                    END ELSE
                        Y.INT.AMT = Y.AS.CCY.AMOUNT
                    END
                    GOSUB BUILD.362.SEQ.C.E
                END

                * Build seq D (LIAB)
                OFFSET = 180
                Y.FIXED = R$SWAP<SW.LB.FIXED.RATE> <> '' OR R$SWAP<SW.LB.FIXED.INTEREST> = 'Y'
                CALL CONV.SW.DETERMINE.FIELDS('L')
                R$SW.BALANCES = R$SW.LIABILITY.BALANCES
                Y.CCY.AMOUNT = Y.LI.CCY.AMOUNT
                Y.START.PERIOD = Y.LI.START.PERIOD
                Y.END.PERIOD = Y.LI.END.PERIOD
                GOSUB BUILD.362.SEQ.B.D

                * Build seq E (LIAB)
                IF NOT(Y.INT.DIFF < 0 AND R$SWAP<SW.NET.PAYMENTS> EQ 'Y') THEN  ;* Party A pay interest.
                    IF R$SWAP<SW.NET.PAYMENTS> EQ 'Y' THEN
                        Y.INT.AMT = Y.INT.DIFF
                    END ELSE
                        Y.INT.AMT = Y.LI.CCY.AMOUNT
                    END
                    GOSUB BUILD.362.SEQ.C.E
                END

                *--- Restore common variable
                THIS.LEG.TYPE = Y.SAVE.LEG.TYPE
                CALL CONV.SW.DETERMINE.FIELDS(THIS.LEG.TYPE)
                R$SW.BALANCES = Y.SAVE.SW.BALANCES
            END ELSE          ;* If IP dates are not the same, we should generate MT362 for each side.
                IF THIS.LEG.TYPE = "A" THEN
                    OFFSET = 160
                END ELSE
                    OFFSET = 180
                END
                Y.FIXED = R$SWAP<SWAP$FIXED.RATE> <> '' OR R$SWAP<SWAP$FIXED.INTEREST> = 'Y'

                Y.INT.AMT = Y.CCY.AMOUNT
                IF Y.AS.END.PERIOD LT Y.LI.END.PERIOD THEN
                    OFFSET = 160
                    Y.END.PERIOD = Y.AS.END.PERIOD
                    Y.START.PERIOD = Y.AS.START.PERIOD
                    SAVE.LEG.TYPE = THIS.LEG.TYPE
                    THIS.LEG.TYPE = 'A'
                    CALL CONV.SW.DETERMINE.FIELDS('A')
                    Y.FIXED = R$SWAP<SWAP$FIXED.RATE> <> '' OR R$SWAP<SWAP$FIXED.INTEREST> = 'Y'
                    Y.CCY.AMOUNT = Y.AS.CCY.AMOUNT
                    R$SW.BALANCES = R$SW.ASSET.BALANCES
                    Y.INT.AMT = Y.CCY.AMOUNT
                    GOSUB BUILD.362.SEQ.C.E
                    GOSUB BUILD.362.SEQ.B.D
                    THIS.LEG.TYPE = SAVE.LEG.TYPE
                END ELSE
                    OFFSET = 180
                    Y.END.PERIOD = Y.LI.END.PERIOD
                    Y.START.PERIOD = Y.LI.START.PERIOD
                    Y.CCY.AMOUNT = Y.LI.CCY.AMOUNT
                    SAVE.LEG.TYPE = THIS.LEG.TYPE
                    THIS.LEG.TYPE = 'L'
                    CALL CONV.SW.DETERMINE.FIELDS('L')
                    Y.FIXED = R$SWAP<SWAP$FIXED.RATE> <> '' OR R$SWAP<SWAP$FIXED.INTEREST> = 'Y'
                    R$SW.BALANCES = R$SW.LIABILITY.BALANCES
                    Y.INT.AMT = Y.CCY.AMOUNT
                    GOSUB BUILD.362.SEQ.C.E
                    GOSUB BUILD.362.SEQ.B.D
                    THIS.LEG.TYPE = SAVE.LEG.TYPE
                END
                Y.INT.AMT = Y.CCY.AMOUNT
            END
            R$SWAP = SAVE.SWAP
            R.DATES(EB.DAT.PERIOD.END) = SAVE.PERIOD.END
            R$SW.ASSET.BALANCES = SAVE.ASSET.BALANCES
            R$SW.LIABILITY.BALANCES = SAVE.LIAB.BALANCES
            *Restore back the SCHEDULE.LIST
            SCHEDULE.LIST = SAVE.SCHEDULE.LIST
        END
        RETURN
        *
        * To get Days delivery for RR schedule - CI_10030847 - S
******************
GET.DAYS.DELIVERY:
******************
        * Priority 1 - Get DAYS.DELIVERY from SWAP contract
        C$SW.NDAYS = 0 ; R.SWAP.ACTIVITY = '' ; R.CURRENCY = '' ; LEG.CCY = ''

        LEG.CCY = R$SWAP<SWAP$CURRENCY>

        C$SW.NDAYS = R$SWAP<SW.DAYS.DELIVERY>

        * Priority 2 - Get DAYS.DELIVERY from SWAP.ACTIVITY record
        IF NOT(C$SW.NDAYS) THEN
            CALL CACHE.READ('F.SWAP.ACTIVITY',ACTIVITY.CODE,R.SWAP.ACTIVITY,"")
            C$SW.NDAYS = R.SWAP.ACTIVITY<SW.ACT.DAYS.PRIOR.EVENT>
        END
        *
        * Priority 3 - Get DAYS.DELIVERY from CURRENCY record
        IF NOT(C$SW.NDAYS) THEN
            CALL CACHE.READ('F.CURRENCY',LEG.CCY,R.CURRENCY,"")
            C$SW.NDAYS = R.CURRENCY<EB.CUR.DAYS.DELIVERY>
        END
        RETURN      ;* CI_10030847 - E
        *
***********************
BUILD.PRINCIPAL.FIELDS:
***********************
        IF THIS.SCHED.TYPE MATCHES 'PX':VM:'PI':VM:'PD':VM:'RX':VM:'NI':VM:'ND' THEN
            FREQ.CODE = SCHED.DATE.FREQ[9,3]
            GOSUB DETERMINE.PAYMENT.PERIOD
            GOSUB DETERMINE.PAYMENT.SCHEDULE
            GOSUB BUILD.AMORTISING.SCHEDULE

            IF PAY.RCV THEN
                IF PAY.RCV = 'R' THEN   ;*CI_10013033 S
                    OFFSET = 0
                END ELSE
                    OFFSET = 20         ;* may need changing if no. of fields in this section changed
                END ;*CI_10013033 E

                Z = 0
                Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = 1        ;* Sequence indicator
                Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = VALUE.DATE
                Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = LEG.CCY
                Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = AMOUNT.DUE
                Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = PAY.PERIOD
                Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = PAY.SCHED
                *
                IF NOT(SAME.PI.SETTLE) THEN
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = INTERMEDIARY
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = ACCT.WITH.BANK
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = BANK.INFO
                END ELSE
                    Z += 3
                END
                *
                IF AMORTISATION = "Y" THEN        ;* Ie PI/PD schedule defined
                    * MT360 [15H] [SEQU H IND] [10]
                    * MT361 [15H, 15I] [SEQU H, I IND] [10, 30]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = 1    ;* Sequence indicator
                    * MT360 [18A] [SEQU H NO PR SCH] [11]
                    * MT361 [18A] [SEQU H, I NO PR SCH] [11, 31]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = AMORT.IDX      ;* Number of amortisations
                    * MT360 [30G] [SEQU H START DATE] [12]
                    * MT361 [30G] [SEQU H, I START DATE] [12, 32]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = AMORT.DETAILS<1>         ;* Start Date
                    * MT360 [30G] [SEQU H END DATE] [13]
                    * MT361 [30G] [SEQU H, I END DATE] [13, 33]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = AMORT.DETAILS<2>         ;* End Date
                    * MT360 [32U] [SEQU H OTS PRIN] [14]
                    * MT361 [32U] [SEQU H, I OTS PRIN] [14, 34]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = AMORT.DETAILS<3>         ;* Ots Amount
                    * MT360 [32U] [SEQU H CCY] [15]
                    * MT361 [32U] [SEQU H, I CCY] [15, 35]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = AMORT.DETAILS<4>         ;* Assoc CCY
                    IF R$SW.BALANCES<SW.BAL.NOTIONAL>[1,1] = "N" THEN
                        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = "Y"        ;* Principal exchange allowed
                    END ELSE
                        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = "N"        ;* All notional
                    END
                    *--- EN10000584 S
                    * MT360 [14A] [SEQU H BUS DAY CON] [17]
                    * MT361 [14A] [SEQU H, I BUS DAY CON] [17, 37]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = R$SWAP<SWAP$DAY.CONVENTION>        ;* DAY CONVENTION
                    * Default "OTHER" to field tag 14A
                    Y.DAY.CON = ""
                    IF PRINCIPAL.REC<Z+OFFSET> EQ "" THEN
                        PRINCIPAL.REC<Z+OFFSET> = "OTHER"
                        Y.DAY.CON = "NONE"
                    END
                    * TAG 18A
                    GOSUB PROCESS.22B
                    * MT360 [18A] [SEQU H BUS CEN NO] [18]
                    * MT361 [18A] [SEQU H, I BUS CEN NO] [18, 38]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = NO.BUS.CENTRES
                    * MT360 [22B] [SEQU H BUS CENTRE] [19]
                    * MT361 [22B] [SEQU H, I BUS CENTRE] [19, 39]
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = BUS.CITIES
                    IF MESSAGE.TYPE EQ "360" THEN ;* For MT360.
                        Y.SEQ.H.BUS.CITIES.1 = BUS.ADDITIONAL.INFO
                        Y.SAVE.DEL.REGION = Y.DELIVERY.REGION
                    END ELSE  ;* For MT361.
                        IF (THIS.SCHED.TYPE EQ "PI" AND PAY.RCV EQ 'P') OR (THIS.SCHED.TYPE EQ "PD" AND PAY.RCV EQ 'R') THEN
                            * Seq I
                            Y.SEQ.I.BUS.CITIES = BUS.ADDITIONAL.INFO
                            IF Y.DAY.CON NE "" THEN
                                Y.SEQ.I.DAY.CON = Y.DAY.CON
                            END
                        END
                        ELSE IF (THIS.SCHED.TYPE EQ "PI" AND PAY.RCV EQ 'R') OR (THIS.SCHED.TYPE EQ "PD" AND PAY.RCV EQ 'P') THEN
                        * Seq H
                        Y.SEQ.H.BUS.CITIES.1 = BUS.ADDITIONAL.INFO
                        IF Y.DAY.CON NE "" THEN
                            Y.SEQ.H.DAY.CON = Y.DAY.CON
                        END
                    END
                END
                * Find business cities for opposite leg (MT360 only)
                IF MESSAGE.TYPE EQ '360' THEN
                    IF SWAP$BUS.CENTRES EQ SW.AS.BUS.CENTRES THEN
                        CALL CONV.SW.DETERMINE.FIELDS('L')        ;* Change leg
                        GOSUB PROCESS.22B
                        CALL CONV.SW.DETERMINE.FIELDS('A')        ;* Restore leg
                    END ELSE
                        CALL CONV.SW.DETERMINE.FIELDS('A')        ;* Change leg
                        GOSUB PROCESS.22B
                        CALL CONV.SW.DETERMINE.FIELDS('L')        ;* Restore leg
                    END
                    *
                    Y.SAVE.DEL.REGION<1,-1> = Y.DELIVERY.REGION
                    * Sort business centre
                    BUS.CITIES = PRINCIPAL.REC<Z+OFFSET>
                    Y.DELIVERY.REGION = Y.SAVE.DEL.REGION
                    GOSUB SORT.BUS.CENTRE
                    PRINCIPAL.REC<Z+OFFSET> = BUS.CITIES
                    *
                    PRINCIPAL.REC<Z+OFFSET-1> += NO.BUS.CENTRES
                    Y.SEQ.H.BUS.CITIES.2 = BUS.ADDITIONAL.INFO
                END
                * EN_10000461 E
                *--- EN_10000572 E
            END
            *
            *--- EN_10000572 S
            BEGIN CASE
                CASE LEG.TYPE EQ 'A'
                    IF THIS.SCHED.TYPE EQ 'RX' THEN
                        OFFSET = 100    ;* SEQ J
                    END ELSE
                        IF THIS.SCHED.TYPE EQ 'PD' THEN     ;**CI_10003825 S
                            OFFSET = 100          ;* SEQ J
                        END ELSE        ;**CI_10003825 E
                            OFFSET = 120          ;* SEQ K
                        END
                    END       ;**CI_10003825 S/E
                CASE LEG.TYPE EQ 'L'
                    IF THIS.SCHED.TYPE EQ 'PX' THEN
                        OFFSET = 100    ;* SEQ J
                    END ELSE
                        IF THIS.SCHED.TYPE EQ 'PI' THEN     ;**CI_10003825 S
                            OFFSET = 100          ;* SEQ J
                        END ELSE        ;**CI_10003825 E
                            OFFSET = 120          ;* SEQ K
                        END
                    END       ;**CI_10003825 S/E
            END CASE
            * EN_10000761 - S
            *            IF PAY.RCV = 'R' THEN
            *               OFFSET = 100
            *            END ELSE
            *               OFFSET = 120              ; * may need changing if no. of fields in this section changed
            *            END
            * EN_10000761 -  E
            *
            ** Add the Initial and Final Exchange Details
            *
            IF THIS.SCHED.TYPE = 'PI' AND LEG.TYPE = 'A' AND SW.ASSET.PI = 1 THEN     ;* CI_10013033 S
                RETURN
            END
            IF THIS.SCHED.TYPE = 'PI' AND LEG.TYPE = 'L' AND SW.LIAB.PI = 1 THEN
                RETURN
            END
            IF THIS.SCHED.TYPE = 'PD' AND LEG.TYPE = 'A' AND SW.ASSET.PD = 1 THEN
                RETURN
            END
            IF THIS.SCHED.TYPE = 'PD' AND LEG.TYPE = 'L' AND SW.LIAB.PD = 1 THEN
                RETURN
            END ;* * CI_10013033 E
            Z = 0
            *--- EN_10000572 S
            IF THIS.SCHED.TYPE MATCHES "PX":VM:"RX":VM:"PI":VM:"PD" THEN    ;**CI_10003825 S/E

                NO.OF.TIMES = 1     ;* CI_10013033 S
                IF THIS.SCHED.TYPE EQ 'PI' THEN
                    IF LEG.TYPE = 'A' THEN SW.ASSET.PI = 1        ;* CI_10011928 /s
                    IF LEG.TYPE = 'L' THEN SW.LIAB.PI = 1         ;* CI_10011928 /e
                    NO.OF.TIMES = DCOUNT(PI.SCHED<1>,VM)
                END
                IF THIS.SCHED.TYPE EQ 'PD' THEN
                    IF LEG.TYPE = 'A' THEN SW.ASSET.PD = 1        ;* CI_10011928 /s
                    IF LEG.TYPE = 'L' THEN SW.LIAB.PD = 1         ;* CI_10011928 /e
                    NO.OF.TIMES = DCOUNT(PD.SCHED<1>,VM)
                END
                CURRENT = 1
                LOOP
                    Z = 0
                    IF THIS.SCHED.TYPE EQ 'PI' THEN
                        VALUE.DATE = PI.SCHED<2,CURRENT>
                        AMOUNT.DUE = PI.SCHED<3,CURRENT>
                    END
                    IF THIS.SCHED.TYPE EQ 'PD' THEN
                        VALUE.DATE = PD.SCHED<2,CURRENT>
                        AMOUNT.DUE = PD.SCHED<3,CURRENT>
                    END
                WHILE NO.OF.TIMES GE CURRENT DO         ;*CI_10013033 E

                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = 1          ;* Sequence J,K indicator
                    Z += 1
                    *
                    LOCATE VALUE.DATE IN PRINCIPAL.REC<Z+OFFSET,1> BY "A" SETTING SEQ.POS THEN
                        *
                    END
                    *
                    INS VALUE.DATE BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>  ;* TAG 30F, SEQ J,K
                    Z += 1
                    INS LEG.CCY BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>     ;* TAG 32M, SEQ J,K
                    Z += 1
                    IF THIS.SCHED.TYPE EQ "RX" THEN
                        AMOUNT.DUE = FUTURE.BALANCES<SW.BAL.PRINCIPAL, 1>   ;*--- CI_10004554 S/E
                    END
                    IF THIS.SCHED.TYPE EQ 'PX' THEN     ;* CI_10013033 S
                        AMORT.IDX = DCOUNT(FUTURE.BALANCES<SW.BAL.PRIN.DATE>,VM)
                        IF AMORT.IDX GT 1 THEN
                            AMOUNT.DUE = FUTURE.BALANCES<SW.BAL.PRINCIPAL,AMORT.IDX>
                        END
                    END   ;*CI_10013033 E
                    INS AMOUNT.DUE BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>  ;* TAG 32M, SEQ J,K

                    *
                    IF NOT(SAME.PI.SETTLE) THEN
                        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = INTERMEDIARY
                        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = ACCT.WITH.BANK
                        Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = BANK.INFO
                    END ELSE
                        Z += 3
                    END
                    *
                    Z += 1
                    IF PRINCIPAL.REC<Z+OFFSET> = "" THEN PRINCIPAL.REC<Z+OFFSET> = 0  ;* BG_100000813
                    PRINCIPAL.REC<Z+OFFSET> += 1        ;* TAG 18A, SEQ J,K
                    *
                    Z += 1
                    *
                    IF THIS.SCHED.TYPE EQ 'PX' THEN
                        INS 'INLX' BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>  ;* TAG 22X, SEQ J,K
                    END ELSE IF THIS.SCHED.TYPE EQ 'RX' THEN
                        INS 'FINX' BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>        ;* TAG 22X, SEQ J,K
                    END ELSE    ;*--- CI_10004554 S/E
                        INS 'INTX' BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>        ;* TAG 22X, SEQ J,K
                    END
                    *
                    GOSUB PROCESS.22B
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = R$SWAP<SWAP$DAY.CONVENTION>
                    Y.DAY.CON = ""
                    IF PRINCIPAL.REC<Z+OFFSET> EQ "" THEN
                        PRINCIPAL.REC<Z+OFFSET> = 'OTHER'     ;* TAG 14A, SEQ J,K
                        Y.DAY.CON = 'NONE'
                    END
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = NO.BUS.CENTRES   ;* TAG 18A, SEQ J,K
                    Z += 1 ; PRINCIPAL.REC<Z+OFFSET> = BUS.CITIES       ;* TAG 22B, SEQ J,K
                    *
                    Z += 1      ;**CI_10002922S
                    YR.ACCT = ''
                    CHECK.CUST.ID = ''
                    CALL F.READ(FN.ACCOUNT, ACCOUNT.NUMBER, YR.ACCT, F.ACCOUNT, '')         ;**CI_10002922E
                    IF OFFSET EQ 100 THEN ;* SEQ J
                        Y.SEQ.J.BUS.CITIES = BUS.ADDITIONAL.INFO
                        Y.SEQ.J.DAY.CON = Y.DAY.CON
                        IF YR.ACCT<AC.LIMIT.REF> = 'NOSTRO' THEN        ;**CI_10002922S
                            CHECK.CUST.ID = YR.ACCT<AC.CUSTOMER>
                            INS CHECK.CUST.ID BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>
                        END ELSE
                            INS ID.COMPANY BEFORE PRINCIPAL.REC<Z+OFFSET,SEQ.POS>
                        END
                    END         ;**CI_10002922E
                    ELSE IF OFFSET EQ 120 THEN      ;* SEQ K
                    Y.SEQ.K.BUS.CITIES = BUS.ADDITIONAL.INFO
                    Y.SEQ.K.DAY.CON = Y.DAY.CON
                    IF YR.ACCT<AC.LIMIT.REF> = 'NOSTRO' THEN        ;**CI_10002922S
                        INS ACCT.WITH.BANK BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>
                    END ELSE
                        INS ID.COMPANY BEFORE PRINCIPAL.REC<Z+OFFSET, SEQ.POS>
                    END
                END         ;**CI_10002922E
                CURRENT = CURRENT + 1 ;*CI_10013033 S
            REPEAT          ;*CI_10013033 E
            *
        END
        *--- EN_10000572 E
    END
*
    END
*
    RETURN
*
*
*************************
DETERMINE.PAYMENT.PERIOD:
*************************
*
    PAY.PERIOD = ''
*
    BEGIN CASE
        CASE FREQ.CODE = "BSN"
            PAY.PERIOD = "1D"       ;* Business Days
            *
        CASE FREQ.CODE = "DAI"      ;* Daily
            PAY.PERIOD = "1D"
            *
            * CI_10002510 S
        CASE FREQ.CODE = "WEE"
            PAY.PERIOD = 'W'
            * CI_10002510 E
            *
        CASE FREQ.CODE[1,1] = "M"
            NO.MONTHS = FREQ.CODE[2,2]
            IF MOD(NO.MONTHS,12) = 0 THEN     ;* Yearly
                PAY.PERIOD = NO.MONTHS / 12
                PAY.PERIOD := "Y"
            END ELSE
                PAY.PERIOD = FREQ.CODE[2,2]+0:"M"
            END
            *
        CASE 1
            PAY.PERIOD = 'O'        ;* other
    END CASE
*
    RETURN
*
*
***************************
DETERMINE.PAYMENT.SCHEDULE:
***************************
*
    PAY.SCHED = ''
* EN_10000461 S
    PAY.SCHED.IDX = 0
* EN_10000461 E
    PAY.DETS.IDX = ""
    PAY.DETAILS = ""  ;* Field 1 = AMOUNT, Field 2 = Value Date
    LAST.YEAR = ""
* CI_10004731 S
    THIS.DUE.DATE = ""
* CI_10004731 E
* EN_10000461 S
    FOR YCNT = DCOUNT(FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE>,VM) TO 1 STEP -1
        IF FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE, YCNT> EQ THIS.SCHED.TYPE THEN
            * Count schedule and pass value to field tag 18a
            PAY.SCHED.IDX += 1
            * Put schedule date into field tag 30f
            PAY.SCHED<1,-1> = FUTURE.BALANCES<SW.BAL.PROCESS.DATE, YCNT>          ;* CI_10002538 S/E
            * EN_10000761 - S WE PAY RECEIVE
            * Find we pay & receive amount
            IF THIS.SCHED.TYPE EQ "IP" AND Y.WE.PAY.RCV EQ "" THEN
                * CI_10004731 S
                BEGIN CASE
                    CASE MESSAGE.TYPE MATCHES "360":VM:"361"
                        IF FUTURE.BALANCES<SW.BAL.SCHEDULE.DATE, YCNT> GT TODAY THEN
                            Y.WE.PAY.RCV = FUTURE.BALANCES<SW.BAL.CCY.AMOUNT, YCNT>
                        END
                    CASE MESSAGE.TYPE EQ "362"
                        IF THIS.DUE.DATE = "" AND FUTURE.BALANCES<SW.BAL.SCHEDULE.DATE, YCNT> GT TODAY THEN
                            THIS.DUE.DATE = FUTURE.BALANCES<SW.BAL.SCHEDULE.DATE, YCNT>
                        END
                        IF THIS.DUE.DATE <> "" AND FUTURE.BALANCES<SW.BAL.SCHEDULE.DATE, YCNT> GT THIS.DUE.DATE THEN
                            Y.WE.PAY.RCV = FUTURE.BALANCES<SW.BAL.CCY.AMOUNT, YCNT>
                        END
                END CASE
                * CI_10004731 E
            END
            * EN_10000761 - E WE PAY RECEIVE
            PAY.DETS.IDX += 1
            INS FUTURE.BALANCES<SW.BAL.VALUE.DATE, YCNT> BEFORE PAY.DETAILS<1,1>
            INS FUTURE.BALANCES<SW.BAL.CCY.AMOUNT, YCNT> BEFORE PAY.DETAILS<2, 1>
        END
    NEXT YCNT
    RETURN
*
*----------------------------------------------------------------------------------------
**************************
BUILD.AMORTISING.SCHEDULE:
**************************
** Build the schedule for principal increases / decrease termed amortising
** by SWIFT
** Basically show the future principal movements from the scehdule date in ascending order
** Look at the principal balances in turn. Build up a list of start and end dates and the
** principal at the start of the period. For the first period we may have the same date
** so ignore this
*
* EN_10000461 S
* New method
* Reset variable
    AMORT.DETAILS = ""
    AMORT.IDX = DCOUNT(FUTURE.BALANCES<SW.BAL.PRIN.DATE>,VM)
*
* Save R.NEW and build new content from SWAP.BALANCES
*
    MAT R.NEW.SAVE = MAT R.NEW
    MATPARSE R.NEW FROM FUTURE.BALANCES
* Save COMI
    Y.SAVE.COMI = COMI
*
    FOR Y.INDEX = AMORT.IDX TO 1 STEP -1
        SCHEDULE.DATE = FUTURE.BALANCES<SW.BAL.PRIN.DATE,Y.INDEX>       ;*CI_7027 S
        PR.DATE = ''
        EN.DATE = ''
        EF.DATE = ''
        BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
        DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
        PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>
        * CI_10014611-S
        IF ACT.SCHED.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN     ;* CI_10016799 S/E
            BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES> ;* CI_10035793 - S/E
        END
        * CI_10014611-E
        CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,
        DAY.CONVENTION,PERIOD.ADJUSTMENT,PR.DATE,EN.DATE,EF.DATE)
        AMORT.DETAILS<1,-1> = PR.DATE     ;*CI_7027 E

        *
        IF Y.INDEX GT 1 THEN    ;* GET END DATE
        AMORT.DETAILS<2,-1> = FUTURE.BALANCES<SW.BAL.PRIN.DATE, Y.INDEX - 1>
        END ELSE      ;* IF Y.INDEX = 1 THEN USE MATURITY DATE INSTEAD.
    SCHEDULE.DATE = R$SWAP<SW.MATURITY.DATE>          ;*CI_7027 S
    BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
    DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
    PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>
    PROCESS.DATE = ''
    ENTRY.DATE = ''
    EFFECTIVE.DATE = ''
* CI_10014611-S
    IF ACT.SCHED.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN ;* CI_10016799 S/E
        BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>       ;* CI_10035793 - S/E
    END
* CI_10014611-E
    CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
    AMORT.DETAILS<2,-1> = PROCESS.DATE      ;*CI_7027 E
    END
*
* Add decimal point to amount
*
* CI_10016799 - S
    TEMP.AMT = ABS(FUTURE.BALANCES<SW.BAL.PRINCIPAL, Y.INDEX>)
    TEMP.CCY = FUTURE.BALANCES<SW.BAL.CURRENCY>
    CALL SC.FORMAT.CCY.AMT(TEMP.CCY,TEMP.AMT)
    AMORT.DETAILS<3,-1> = TEMP.AMT    ;* PRINCIPAL
* CI_10016799 - E
    AMORT.DETAILS<4,-1> = LEG.CCY     ;* CURRENCY
*
    NEXT Y.INDEX
*
    PI.SCHED = ''     ;*CI_10013033 S
    PD.SCHED = ''
    NO.OF.SCHED = DCOUNT(FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE>,VM)
    FOR CURR.SCHED = 1 TO NO.OF.SCHED
        FUT.SCHED = FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE,CURR.SCHED>
        IF FUT.SCHED EQ 'PI' THEN
            PI.SCHED<1,-1> = FUT.SCHED
            PI.SCHED<2,-1> = FUTURE.BALANCES<SW.BAL.PROCESS.DATE,CURR.SCHED>
            PI.SCHED<3,-1> = FUTURE.BALANCES<SW.BAL.CCY.AMOUNT,CURR.SCHED>
        END
        IF FUT.SCHED EQ 'PD' THEN
            PD.SCHED<1,-1> = FUT.SCHED
            PD.SCHED<2,-1> = FUTURE.BALANCES<SW.BAL.PROCESS.DATE,CURR.SCHED>
            PD.SCHED<3,-1> = FUTURE.BALANCES<SW.BAL.CCY.AMOUNT,CURR.SCHED>
        END
    NEXT CURR.SCHED   ;*CI_10013033 E

* Restore variable
    COMI = Y.SAVE.COMI
    MAT R.NEW = MAT R.NEW.SAVE
    RETURN
*
*------------------------------------------------------------------------------------------
**********************
ADD.FUTURE.SCHEDULE:
**********************
*
** Handoff full future schedule as this may prove useful for printed
** advices
*
    IF PAY.RCV = "R" THEN       ;* Asset Side
        OFFSET = 60   ;* CI_10016799 - Changed 40 to 60
        FUTURE.BALANCES = FULL.ASSET.BALANCES
    END ELSE
        OFFSET = 80   ;* CI_10016799 - Changed 60 to 80
        FUTURE.BALANCES = FULL.LIAB.BALANCES
    END
    FUT.SCHED.IDX = ""
*
    NO.SCHEDS = DCOUNT(FUTURE.BALANCES<SW.BAL.SCHEDULE.TYPE>,VM)
    FUT.SCHED.IDX += 1          ;* Next schedule item
    FOR YCNT = NO.SCHEDS TO 1 STEP -1     ;* Process the oldest first
        IF FUTURE.BALANCES<SW.BAL.SCHEDULE.DATE,YCNT> GT ACTION.DATE THEN         ;* Ignore anything after the schedule
            FOR Z = 1 TO (SW.BAL.VALUE.DATE-SW.BAL.SCHEDULE.TYPE)
                ADDITIONAL.REC<Z+OFFSET, FUT.SCHED.IDX> = FUTURE.BALANCES<SW.BAL.AMORT.TO.DATE+Z, YCNT>
            NEXT Z
        END
    NEXT YCNT
*
    RETURN
*
*------------------------------------------------------------------------------------------
*********************
SWIFT.FORMAT.NUMERIC:
*********************
*
    CONVERT ',' TO '' IN NUMERIC.FIELD    ;* remove thousand separator
    CONVERT '.' TO ',' IN NUMERIC.FIELD   ;* convert dp to ','
    IF INDEX(NUMERIC.FIELD, ',', 1) = 0 THEN
        NUMERIC.FIELD := ','
    END
*
    RETURN
*
*------------------------------------------------------------------------------------------
* EN_10000461 S
* New paragraph for EN_10000461
**********
CHECK.C17:
**********
* Refer to swift 2001 handbook network validated rule C17
    BEGIN CASE
        CASE Y.AGREEMENT.TYPE EQ "ISDA"
            Y.14F<1,-1> = 'FRF-TAM-CDC'
            Y.14F<1,-1> = 'FRF-T4M-CDC'
            Y.14F<1,-1> = 'FRF-T4M-CDCCOMP'
            Y.14F<1,-1> = 'FRF-TAG-CDC'
            Y.14F<1,-1> = 'FRF-TAG-CDCCOMP'
            Y.14F<1,-1> = 'FRF-TMP-CDCAVERAG'
        CASE Y.AGREEMENT.TYPE EQ "AFB"
            Y.14F<1,-1> = 'FRF-SWAP-AMR'
            Y.14F<1,-1> = 'FRF-SWAP-TMP-IF'
            Y.14F<1,-1> = 'FRF-SWAP-TMP-M'
            Y.14F<1,-1> = 'FRF-SWAP-TMP-AMR'
            Y.14F<1,-1> = 'FRF-CAP-TAM'
            Y.14F<1,-1> = 'FRF-CAP-T4M'
            Y.14F<1,-1> = 'FRF-FLOOR-TAM'
            Y.14F<1,-1> = 'FRF-FLOOR-T4M'
        CASE 1
            Y.14F = ""
    END CASE
*
    IF FLOAT.RATE.OPTION MATCH Y.AGREEMENT.TYPE THEN
        Y.RULE.C17 = 1
    END ELSE
        Y.RULE.C17 = 0
    END
*
    RETURN
*
*------------------------------------------------------------------------------------------
****************
CLEAR.SEQ.C1.F1:
****************
* Clear seq C1 or F1. (Rule C17)
    INTEREST.REC<OFFSET+3> = "" ;* TAG 14D
    INTEREST.REC<OFFSET+8> = "" ;* TAG 38E
    INTEREST.REC<OFFSET+9> = "" ;* TAG 30F
    INTEREST.REC<OFFSET+10> = ""          ;* TAG 18A
    INTEREST.REC<OFFSET+11> = ""          ;* TAG 14A
    INTEREST.REC<OFFSET+15> = ""          ;* TAG 18A
    INTEREST.REC<OFFSET+16> = ""          ;* TAG 22B
*
    RETURN
*
*------------------------------------------------------------------------------------------
************
PROCESS.22B:
************
    BUS.CITIES = ""
    BUS.ADDITIONAL.INFO = ""
    Y.DELIVERY.REGION = ""

    NO.BUS.CENTRES = DCOUNT(R$SWAP<SWAP$BUS.CENTRES>, VM)

    FOR YI = 1 TO NO.BUS.CENTRES
        IF LEN(R$SWAP<SWAP$BUS.CENTRES, YI>) = 2 THEN
            Y.DE.REGION = R$SWAP<SWAP$BUS.CENTRES, YI>:"01"   ;*CI_10004554
        END ELSE
            Y.DE.REGION = R$SWAP<SWAP$BUS.CENTRES, YI>        ;*CI_10004554
        END
        * Read delivery region from REGION file.
        Y.BUS.LOCC = ""
        CALL DBR("REGION":FM:EB.REG.DELIVERY.REGION:FM:"L", Y.DE.REGION, Y.BUS.LOCC)        ;*CI_10004554
        *
        IF ETEXT OR Y.BUS.LOCC EQ 'OTHR' THEN
            * Use country name or region name instead when there is no record
            * in region or value of field DELIVERY.REGION is equal to OTHR.
            * And add business centre in tag 37N
            BUS.CITIES<1,-1> = 'OTHR'
            Y.DELIVERY.REGION<1,-1> = 'OTHR'
            *
            BEGIN CASE
                CASE ETEXT          ;* No record in region file.
                    CALL DBR("COUNTRY":FM:EB.COU.COUNTRY.NAME:FM:"L", R$SWAP<SWAP$BUS.CENTRES, YI>, Y.BUS.LOCC)
                CASE Y.BUS.LOCC EQ 'OTHR'     ;* Field DELIVERY.REGION = OTHR
                    CALL DBR("REGION":FM:EB.REG.REGION.NAME:FM:"L", Y.DE.REGION, Y.BUS.LOCC)    ;*CI_10004554
            END CASE
            *
            IF BUS.ADDITIONAL.INFO EQ "" THEN
                BUS.ADDITIONAL.INFO = '/LOCC/':Y.BUS.LOCC
            END ELSE
                BUS.ADDITIONAL.INFO := '/':Y.BUS.LOCC
            END
            *
        END ELSE
            BUS.CITIES<1,-1> = Y.DE.REGION          ;*CI_10013033
            Y.DELIVERY.REGION<1,-1> = Y.BUS.LOCC
        END
        *
    NEXT YI
*
    GOSUB FORMAT.BUS.ADDITIONAL.INFO      ;* CI_10016704 S/E
    GOSUB SORT.BUS.CENTRE
*
    RETURN
*
*------------------------------------------------------------------------------------------
* CI_10016704 - S
***************************
FORMAT.BUS.ADDITIONAL.INFO:
***************************
    STR.LENGTH = 35
    REST = BUS.ADDITIONAL.INFO
    FIN.STR = ''
    L.COUNT = 0
    MAX.LINES = 6
    LOOP
    UNTIL REST = '' OR REST[STR.LENGTH,1] EQ '' OR L.COUNT GE MAX.LINES
        X = STR.LENGTH
        LOOP
            Y.SPACE = REST[X,1]
        UNTIL Y.SPACE EQ ' ' OR X EQ 0
            X -= 1
        REPEAT

        IF X=0 THEN
            FIN.STR := REST[1,STR.LENGTH]:VM
            REST = REST[STR.LENGTH+1,999]
        END ELSE
            FIN.STR := REST[1,X-1]:VM
            REST = REST[X+1,999]
        END
        L.COUNT += 1
    REPEAT

    IF L.COUNT LT MAX.LINES THEN
        BUS.ADDITIONAL.INFO = FIN.STR:REST
    END ELSE
        BUS.ADDITIONAL.INFO = FIN.STR
    END
    RETURN  ;* CI_10016704 - E
*
*------------------------------------------------------------------------------------------
****************
SORT.BUS.CENTRE:
****************
*
* Sort Business centres.
* Please put business centre into BUS.CITIES variable and DELIVERY.REGION into
* Y.DELIVERY.REGION variable.
*
    Y.TEMP.BUS = ""
*
    Y.NO.OF.BUS = DCOUNT(BUS.CITIES, VM)
    FOR YI=1 TO Y.NO.OF.BUS - 1
        FOR YJ=YI+1 TO Y.NO.OF.BUS
            IF Y.DELIVERY.REGION<1,YI> GT Y.DELIVERY.REGION<1,YJ> THEN
                Y.TEMP.BUS = BUS.CITIES<1,YI>
                BUS.CITIES<1,YI> = BUS.CITIES<1,YJ>
                BUS.CITIES<1,YJ> = Y.TEMP.BUS
                *
                Y.TEMP.BUS = Y.DELIVERY.REGION<1,YI>
                Y.DELIVERY.REGION<1,YI> = Y.DELIVERY.REGION<1,YJ>
                Y.DELIVERY.REGION<1,YJ> = Y.TEMP.BUS
            END
        NEXT YJ
    NEXT YI
*
    RETURN
*
*------------------------------------------------------------------------------------------
* EN_10000461 E
*--- EN_10000572 S
************
GET.SPREAD:
************
    SPREAD = R$SWAP<SWAP$SPREAD> + 0
    IF SPREAD THEN
        NUMERIC.FIELD = SPREAD
        GOSUB SWIFT.FORMAT.NUMERIC
        SPREAD = NUMERIC.FIELD
        * EN_10000461 S
        IF SPREAD[1,1] EQ '-' THEN
            CONVERT "-" TO "N" IN SPREAD
        END
        * EN_10000461 E
    END ELSE
        SPREAD := ',' ;* Add decimal comma when spread = 0
    END
    RETURN  ;* CI_10002136 S/E
*--- EN_10000572 E
*------------------------------------------------------------------------------------------
* EN_10001511 S
******************
BUILD.362.SEQ.B.D:
******************

    THIS.LEG.CCY = R$SWAP<SWAP$CURRENCY>  ;* EN_10001752 s/e

    Z = 0
* MT362 [15B, 15D] [SEQU B, D IND] [161]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = 1
* MT362 [] [SEQU B, D FRACTION] [169, 189]
    Z += 8 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$BASIS>
* MT362 [30X] [START DATE REC] [170], [SEQU D START DATE] [190]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.START.PERIOD
* MT362 [30Q] [SEQU B, D PERIOD END] [171, 191]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.END.PERIOD

    IF NOT(Y.FIXED) THEN
        * This leg is float.
        LOCATE "RR" IN R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING POS THEN
            Y.CUR.RATE = R$SW.BALANCES<SW.BAL.RESET.RATE, POS>          ;* "raw" rate
        END ELSE
            LOCATE 'RR' IN R$SWAP<SWAP$TYPE,1> SETTING POS THEN
                Y.CUR.RATE = R$SWAP<SWAP$RATE,POS>
            END
        END ;**CI_10002719E
        IF (ACTIVITY.CODE = "114" OR ACTIVITY.CODE = "115") THEN        ;* CI_10030847 - S
            Y.CUR.RATE = R$SWAP<SWAP$RATE,ACT.SCHED.INDEX>
        END ;* CI_10030847 - E
        NUMERIC.FIELD = Y.CUR.RATE
        GOSUB SWIFT.FORMAT.NUMERIC
        * MT362 [37G] [SEQU B, D INT RATE] [172, 192]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = NUMERIC.FIELD

        IF INTEREST.REC<Z+OFFSET>[1,1] EQ '-' THEN
            CONVERT "-" TO "N" IN INTEREST.REC<Z+OFFSET>
        END

        * MT362 [37J] [SEQU B, D CAP RATE] [173, 193]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$CAP.RATE>
        * MT362 [37L] [SEQU B, D FLOOR RATE] [174, 194]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SWAP<SWAP$FLOOR.RATE>
        GOSUB GET.SPREAD
        * MT362 [37R] [SEQU B, D SPREAD] [175, 185]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = SPREAD
        * Calculate total rate
        CONVERT 'N' TO '-' IN SPREAD
        CONVERT ',' TO '.' IN SPREAD
        CONVERT ',' TO '.' IN Y.CUR.RATE  ;* BG_100007335 S/E
        Y.CUR.RATE += SPREAD
        CONVERT '-' TO 'N' IN Y.CUR.RATE
        IF INDEX(Y.CUR.RATE, '.', 1) THEN
            CONVERT '.' TO ',' IN Y.CUR.RATE
        END ELSE
            Y.CUR.RATE := ','
        END
        * MT362 [37M] [SEQU B, D TOTAL RATE] [176, 196]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.CUR.RATE
    END ELSE
        * This leg is fixed. 37G and 37R = 0. 37J and 37L are not allowed.
        Y.CUR.RATE = R$SWAP<SWAP$CURRENT.RATE>
        CONVERT '-' TO 'N' IN Y.CUR.RATE
        IF INDEX(Y.CUR.RATE, '.', 1) THEN
            CONVERT '.' TO ',' IN Y.CUR.RATE
        END ELSE
            Y.CUR.RATE := ','
        END
        * MT362 [37G] [SEQU B, D INT RATE] [172, 192]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.CUR.RATE
        * MT362 [37J] [SEQU B, D CAP RATE] [173, 193]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = ""
        * MT362 [37L] [SEQU B, D FLOOR RATE] [174, 194]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = ""
        * MT362 [37R] [SEQU B, D SPREAD] [175, 185]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = "0,"
        * MT362 [37M] [SEQU B, D TOTAL RATE] [176, 196]
        Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.CUR.RATE
    END

* MT362 [30F] [VALUE DATE REC] [177], [SEQU D PAY DATE] [197]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.END.PERIOD  ;* Value date of IP schedule
* MT362 [32H] [INTEREST AMT REC] [178], [SEQU D INT AMT] [198]
*-* BG_10004364
    IF Y.CCY.AMOUNT < 0 THEN
        Z += 1 ; INTEREST.REC<Z+OFFSET> = "N":THIS.LEG.CCY:ABS(Y.CCY.AMOUNT)      ;* First Interest amount
    END ELSE
        Z += 1 ; INTEREST.REC<Z+OFFSET> = THIS.LEG.CCY:ABS(Y.CCY.AMOUNT)          ;* First Interest amount
    END
* MT362 [33F] [CURRENCY IR] [179], [SEQU D CALC CCY] [199]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = THIS.LEG.CCY
* MT362 [33F] [CALC AMOUNT REC] [180], [SEQU D NOTION AMT] [200]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = R$SW.BALANCES<SW.BAL.PRINCIPAL,1> ;*Current Principal
* CI_10016799 S/E - Removed the fix applied for CI_10013891 and CI_10014743
    RETURN
*------------------------------------------------------------------------------------------
******************
BUILD.362.SEQ.C.E:
******************

    THIS.LEG.CCY = R$SWAP<SWAP$CURRENCY>  ;* EN_10001752 s/e
    Z = 0
    GOSUB GET.SETTLEMENT.INFO   ;* EN_10001752 s/e

* MT362 [15C, 15E] [SEQU C,E IND] [162, 182]
    Z += 2 ; INTEREST.REC<Z+OFFSET> = 1
* MT362 [30F] [SEQU C VALUE DATE] [163], [SEQU E VAL DATE] [183]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = Y.END.PERIOD
* BG_100004467
* CI_10016799 - S
* Removed the fix applied for CI_10013891 and CI_10014743
* Tag 32M will be populated in the message 362 when floating in either asset side or liability side.
    IF OFFSET EQ '180' OR OFFSET EQ '160' THEN      ;* CI_10023118/S ; CI_10028303 S/E
        IF NOT(Y.FIXED) THEN    ;* CI_10028303 S/E
            * MT361 [32M] [SEQU E CCY] [164,184]
            Z += 1 ; INTEREST.REC<Z+OFFSET> = THIS.LEG.CCY
            * MT361 [32M] [SEQU E PAY AMT] [165,185]
            Z += 1 ; INTEREST.REC<Z+OFFSET> = ABS(Y.INT.AMT)
        END ELSE      ;* EN_10002475 - S
            Z += 2
        END ;* EN_10002475 - E
    END     ;* CI_10023118/E
* CI_10016799 - E
* MT362 [56A] [INTERMEDIARY IR] [166], [INTERMEDIARY IP] [186]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = INTERMEDIARY

* BG_100004467  S/
    BEGIN CASE
        CASE OFFSET = 160 AND Y.INT.AMT GE 0  ;**CI_10003707S
            YR.ACCT = ''
            CHECK.CUST.ID = ''
            CALL F.READ(FN.ACCOUNT, ACCOUNT.NUMBER, YR.ACCT, F.ACCOUNT, '')
            * MT362 [57A] [ACCT WITH BANK IR] [167]
            IF YR.ACCT<AC.LIMIT.REF> = 'NOSTRO' THEN
                CHECK.CUST.ID = YR.ACCT<AC.CUSTOMER>
                Z += 1 ; INTEREST.REC<Z+OFFSET> = CHECK.CUST.ID
            END ELSE
                Z += 1 ; INTEREST.REC<Z+OFFSET> = ID.COMPANY
            END
        CASE OFFSET NE 160 AND Y.INT.AMT GE 0
            * MT362 [57A] [ACCT WITH BANK IP] [187]
            IF ACCT.WITH.BANK THEN  ;**CI_10003707E
                Z += 1 ; INTEREST.REC<Z+OFFSET> = ACCT.WITH.BANK
            END ELSE      ;**CI_10003707S
                Z += 1 ; INTEREST.REC<Z+OFFSET> = ID.COMPANY
            END
        CASE OFFSET NE 160 AND Y.INT.AMT LT 0 ;**CI_10003707S
            YR.ACCT = ''
            CHECK.CUST.ID = ''
            CALL F.READ(FN.ACCOUNT, ACCOUNT.NUMBER, YR.ACCT, F.ACCOUNT, '')
            * MT362 [57A] [ACCT WITH BANK IR] [167]
            IF YR.ACCT<AC.LIMIT.REF> = 'NOSTRO' THEN
                CHECK.CUST.ID = YR.ACCT<AC.CUSTOMER>
                Z += 1 ; INTEREST.REC<Z+OFFSET> = CHECK.CUST.ID
            END ELSE
                Z += 1 ; INTEREST.REC<Z+OFFSET> = ID.COMPANY
            END
        CASE OFFSET = 160 AND Y.INT.AMT LT 0
            * MT362 [57A] [ACCT WITH BANK IP] [187]
            IF ACCT.WITH.BANK THEN  ;**CI_10003707E
                Z += 1 ; INTEREST.REC<Z+OFFSET> = ACCT.WITH.BANK
            END ELSE      ;**CI_10003707S
                Z += 1 ; INTEREST.REC<Z+OFFSET> = ID.COMPANY
            END
    END CASE          ;**CI_10003707E
* BG_100004467  /E
* MT362 [18A] [SEQU C, E NO OF REPS] [168, 188]
    Z += 1 ; INTEREST.REC<Z+OFFSET> = "1"

    RETURN
*------------------------------------------------------------------------------------------
* EN_10001511 E
    END
