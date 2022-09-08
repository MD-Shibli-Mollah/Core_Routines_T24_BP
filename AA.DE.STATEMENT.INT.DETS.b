* @ValidationCode : MjoyMDMxNDA1Nzg3OkNwMTI1MjoxNTU5NTYyNzA4Mzg1OnN1ZGhhcmFtZXNoOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDIuMjAxOTAxMTctMDM0NzoyMzA6MTg4
* @ValidationInfo : Timestamp         : 03 Jun 2019 17:21:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 188/230 (81.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190117-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-75</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Statement
    SUBROUTINE AA.DE.STATEMENT.INT.DETS(MAT HAND.REC,ERR.MSG) ;* there is a limit for the routine name
******************************************************************
*This is a delivery mapping routine which will return the
*complete schedule details used for delivery messages
*
*Arguments
*
*Input
* HAND.REC
*    - Handoff Records passed as input
*
* Output
*    - the schedule details are passed in the Handoff Record 9.
*      Error Message is returned in case of any mishappenings.
*
* 05/01/17 - Enhancement  : 1981394
*            Task : 1981390
*            New Creation
* 05/01/17 - Enhancement  : 1981394
*            Task : 2009145
*            Fix issue with
* 20/02/17 - Enhancement  : 1981394
*            Task : 2026389
*            Fix regression error after TEC, and set the AA.ACTIVITY.CLASS with external 
*
******************************************************************

    $USING AA.Statement
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING ST.RateParameters
    $USING AA.Interest
    $USING EB.API
    $USING AC.Fees
    $USING EB.SystemTables
    $USING AF.Framework

    EQUATE ACC.PAY.TYPE TO 1,
    ACC.PAY.DATE TO 2,
    ACC.FROM.DATE TO 3,  ;* 1 R.ACCRUAL.DATA field idx
    ACC.TO.DATE TO 4,  ;* 2 R.ACCRUAL.DATA field idx
    ACC.DAYS TO 5,  ;* 3 R.ACCRUAL.DATA field idx
    ACC.PRIN TO 6,   ;* 4 R.ACCRUAL.DATA field idx
    ACC.RATE TO 7,  ;* 5 R.ACCRUAL.DATA field idx
    ACC.ACCRUAL TO 8,
    ACC.ACCRUAL.ACT TO 9,  ;* 7 R.ACCRUAL.DATA field idx
    ACC.BASIS TO 10,  ;* 8 R.ACCRUAL.DATA field idx
    ACC.COMPOUND TO 13, ;* 11 R.ACCRUAL.DATA field idx
    ACC.NOM.RATE TO 14,        ;*Store the nominal rate ;* 12 R.ACCRUAL.DATA field idx
    ACC.COMPOUND.YIELD TO 15,   ;* 13 R.ACCRUAL.DATA field idx
    LAST.FIELD.IDX TO 15

*
    GOSUB INITIALISE
    GOSUB BUILD.ARRAY.DETAILS
    GOSUB FORM.HANDOFF.9

*
    RETURN

******************************************************************
*** <region name= Initialise Variables>
***
INITIALISE:

    ARR.ID = HAND.REC(2)<AA.Framework.ArrangementActivity.ArrActArrangement>
    CURR.ACTIVITY = HAND.REC(2)<AA.Framework.ArrangementActivity.ArrActActivity> ;*  e.g. <PL>-PRODUCE-STATEMENT*<INTEREST> or <PL>-PRODUCE-STATEMENT*<INTEREST>*<INT.FREQ.NAME>

* Note: this is a quick fix, when TEC introduce 'external' in ACTIVITY.CLASS, then INITIATION.TYPE in AAA will become 'transaction', not 'user' any more.
* then we have to figure out if this is Adhoc or just running as normal Capitalization or frequency defined cases. 
* Remember, even if Adhoc, it could has been scheduled in cob to run.
* Because no document will be generated in reverse and replay, then effective date less then service date is only the case for Adhoc.    
    RETURN.DATE = ''
    AA.Framework.GetSystemDate(RETURN.DATE)
    IF RETURN.DATE GT AF.Framework.getActivityEffDate() THEN  
        INITIATION.TYPE = 'USER'
    END 

    PROPERTY = CURR.ACTIVITY['*',2,1] ;* get the property name

    INT.FREQ.NAME = CURR.ACTIVITY['*',3,1] ;* get the freq name

    INT.STMT.ARR = ''
    RET.INT.INFO = ''

    SEARCH.PROP = ''
    IF INT.FREQ.NAME THEN
        SEARCH.PROP = PROPERTY:AA.Framework.Sep:INT.FREQ.NAME
    END ELSE
        SEARCH.PROP = PROPERTY
    END

    DATE.FROM = ''
    DATE.TO = ''

    BEGIN CASE
        CASE INITIATION.TYPE EQ 'USER' OR NOT(INT.FREQ.NAME);* when generate statement by user activity (could use any produce statement activity) or capitalization case.
            GOSUB GET.CAPITALISATION.OR.ADHOC.DATES

        CASE 1 ;* default way of getting last statement date
            LOCATE SEARCH.PROP IN HAND.REC(3)<AA.PaymentSchedule.AccountDetails.AdIntStatementType, 1> SETTING TYPE.POS THEN
            DATE.FROM = HAND.REC(3)<AA.PaymentSchedule.AccountDetails.AdLastStatementDate, TYPE.POS>
            DATE.TO = AF.Framework.getActivityEffDate()
        END
    END CASE

    INTEREST.DETAILS = ''     ;* Array of calculation details returned

    MERGE.FLG = ''
    MERGE.DETAILS = 'YES'

    CHECK.ITEM.LIST = ACC.PAY.TYPE:@FM:ACC.PAY.DATE:@FM:ACC.PRIN:@FM:ACC.RATE:@FM:ACC.BASIS:@FM:ACC.COMPOUND:@FM:ACC.COMPOUND.YIELD

    START.DATE = DATE.FROM
    END.DATE = DATE.TO

    RETURN
*** </region>

*** <region name= Build the Array according to Enquiry requirements>
***
BUILD.ARRAY.DETAILS:

*
** Take the returned accrual calculation details and return them so that one line
** of the enquiry is a set of calculation detials
*
    R.ACCRUAL.DATA = ''
    R.ACCRUAL.DETAILS = ''
    INT.KEYS = ''
    SUB.TYPE = ''

    AA.Interest.GetInterestAccruals("VAL", ARR.ID, PROPERTY, START.DATE, R.ACCRUAL.DATA, R.ACCRUAL.DETAILS, INT.KEYS, SUB.TYPE)


    VMC = DCOUNT(R.ACCRUAL.DATA<AC.Fees.EbAcToDate>,@VM)

    INT.ACC.PERIOD.END = R.ACCRUAL.DETAILS<AA.Interest.InterestAccruals.IntAccPeriodEnd>  ;* Acending order
    TOT.PERIOD.END = 0
    IF INT.ACC.PERIOD.END THEN
        TOT.PERIOD.END = COUNT(INT.ACC.PERIOD.END, @VM) + 1
    END

    PERIOD.IDX = 1

    FOR VIDX = VMC TO 1 STEP -1

        LOOP
        WHILE R.ACCRUAL.DATA<AC.Fees.EbAcToDate, VIDX> GE INT.ACC.PERIOD.END<1,PERIOD.IDX> AND PERIOD.IDX LT TOT.PERIOD.END
            PERIOD.IDX++
        REPEAT

        IF START.DATE LE INT.ACC.PERIOD.END<1,PERIOD.IDX> AND INT.ACC.PERIOD.END<1,PERIOD.IDX> LE END.DATE  THEN  ;**only include data Which belongs to this period
            GOSUB POPULATE.ACCRUAL.WORK
        END
        ;*PERIOD.IDX++
    NEXT VIDX

*    ACCRUAL.WORK<-1> = AA.Interest.getRProjectedAccruals() ;* stop using projectedAccruals, it is for the future and performance heavy

*
    LAST.CHECK.VALUE = ''     ;* Store key elements so that we can merge splits together
    INTEREST.CNT = ''
    IDX = 0
    LOOP
        IDX += 1
    WHILE ACCRUAL.WORK<IDX>
        WORK.ITEM = ACCRUAL.WORK<IDX>
        ACCRUE.TO.DATE = WORK.ITEM["*",ACC.TO.DATE,1]
        ACCRUE.FROM.DATE = WORK.ITEM["*",ACC.FROM.DATE,1]
        INT.PROPERTY = WORK.ITEM["*",ACC.PAY.TYPE,1]
        GOSUB INCLUDE.ITEM
        IF INCLUDE.ITEM THEN
            GOSUB BUILD.CHECK.VALUE
            *
            ** We can merge together amounts in the same period with the same
            ** basic calculation info: Rate, Prin, Amount, Basis and Compound Type
            *
            IF CHECK.VALUE = LAST.CHECK.VALUE AND MERGE.DETAILS = "YES" THEN
                CALC.DETAIL = INTEREST.DETAILS<INTEREST.CNT>
                CONVERT "*" TO @FM IN CALC.DETAIL
                CONVERT "*" TO @FM IN WORK.ITEM
                CALC.DETAIL<ACC.TO.DATE> = WORK.ITEM<ACC.TO.DATE>
                CALC.DETAIL<ACC.DAYS> += WORK.ITEM<ACC.DAYS>
                CALC.DETAIL<ACC.ACCRUAL> = ADDS(CALC.DETAIL<ACC.ACCRUAL>, WORK.ITEM<ACC.ACCRUAL>)
                CALC.DETAIL<ACC.ACCRUAL.ACT> = ADDS(CALC.DETAIL<ACC.ACCRUAL.ACT>, WORK.ITEM<ACC.ACCRUAL.ACT>)
                CONVERT @FM TO "*" IN CALC.DETAIL
                CONVERT @FM TO "*" IN WORK.ITEM
                MERGE.FLG = 1
                GOSUB ADD.NOMINAL.RATE
                INTEREST.DETAILS<INTEREST.CNT> = CALC.DETAIL
            END ELSE
                INTEREST.CNT += 1
                GOSUB ADD.NOMINAL.RATE
                INTEREST.DETAILS<-1> = WORK.ITEM
            END
            LAST.CHECK.VALUE = CHECK.VALUE
        END
    REPEAT

    RET.INT.INFO = INTEREST.DETAILS ;*

    RETURN

*** </region>
*-----------------------------------------------------------------------------
ADD.NOMINAL.RATE:
*--------------------
*This paragraph gets the Nominal Rate based on the Interest Amount
*
    NOM.BASIS = WORK.ITEM["*",ACC.BASIS,1]
    TEMP.ITEM = ''
    IF MERGE.FLG THEN         ;*Take from CALC.DETAIL
        TEMP.ITEM = CALC.DETAIL
    END ELSE        ;*Take from WORK.ITEM
        TEMP.ITEM = WORK.ITEM
    END
    NOM.DAYS = TEMP.ITEM["*",ACC.DAYS,1]
    NOM.PRIN = TEMP.ITEM["*",ACC.PRIN,1]
    NOM.INT = TEMP.ITEM["*",ACC.ACCRUAL.ACT,1]
    NOM.FR.DATE = TEMP.ITEM["*",ACC.FROM.DATE,1]
    NOM.TO.DATE = TEMP.ITEM["*",ACC.TO.DATE,1]
    EB.API.Cdt("",NOM.FR.DATE,"-1C")
    NOM.RATE = ''
    AC.Fees.EbGetEqIntRate(NOM.PRIN,NOM.INT,NOM.FR.DATE,NOM.TO.DATE,NOM.BASIS,NOM.RATE)  ;*New routine that returns equivalen
    IF NOM.RATE ELSE
        NOM.RATE = ''
    END
    CONVERT "*" TO @FM IN TEMP.ITEM
    TEMP.ITEM<ACC.NOM.RATE> = NOM.RATE
    CONVERT @FM TO "*" IN TEMP.ITEM
    IF MERGE.FLG THEN
        CALC.DETAIL = TEMP.ITEM
    END ELSE
        WORK.ITEM = TEMP.ITEM
    END
*
    RETURN
*-----------------------------------------------------------------------------

BUILD.CHECK.VALUE:
*
** Build a list of values to compare
*
    CHECK.VALUE = ''
    CHK.CNT = 0
    LOOP
        CHK.CNT +=1
        ACCRUAL.FIELD = CHECK.ITEM.LIST<CHK.CNT>
    WHILE ACCRUAL.FIELD
        IF CHECK.VALUE THEN
            CHECK.VALUE := "*":WORK.ITEM["*",ACCRUAL.FIELD,1]
        END ELSE
            CHECK.VALUE = WORK.ITEM["*",ACCRUAL.FIELD,1]
        END
    REPEAT
*
    RETURN
*
*-----------------------------------------------------------------------------
INCLUDE.ITEM:
*
    BEGIN CASE
        CASE PROPERTY AND INT.PROPERTY NE PROPERTY
            INCLUDE.ITEM = ''
        CASE START.DATE AND END.DATE
            * commented out compare with E.AA.INTEREST.PROJECTOR           IF ACCRUE.TO.DATE GT START.DATE AND ACCRUE.FROM.DATE LT END.DATE THEN
            * CAPI every 2 days, Stmt Freq every 3 days, 0101 (new), 0102, 0103 (capi), 0104 (stmt freq), 0105 (capi), 0106, 0107 (capi & stmt freq)
            * on 0104, then only accruals for 0101 & 0102, but last stmt date will be 0104,
            * on 0107, then try to find from 0104 to 0107, ACCRUE.TO.DATE (0104) GT START.DATE(0104) gives false, then only accruals 0105 & 0106 be provided.
            * Then update to inlcude equals.
            IF ACCRUE.TO.DATE GE START.DATE AND ACCRUE.FROM.DATE LE END.DATE THEN ;*
                INCLUDE.ITEM = 1
            END ELSE
                INCLUDE.ITEM = ''
            END
        CASE START.DATE AND ACCRUE.TO.DATE GT START.DATE
            INCLUDE.ITEM = 1
        CASE START.DATE
            INCLUDE.ITEM = ''
        CASE END.DATE AND ACCRUE.FROM.DATE LT END.DATE
            INCLUDE.ITEM =1
        CASE END.DATE
            INCLUDE.ITEM = ''
        CASE 1
            INCLUDE.ITEM =1
    END CASE
*
    RETURN

******************************************************************
*** <region name= Build basic data>
***
* Data returned from projector routine, looks like
* RET.INT.INFO<1> = ... date.from.1 :@VM: date.to.1 :@VM: ...
* RET.INT.INFO<1> = ... date.from.2 :@VM: date.to.2 :@VM: ...
* need to be converted to
* INT.STMT.AR<1> = ...
* INT.STMT.AR<2> = date.from.1 :@VM: date.from.2 :@VM: ...
* INT.STMT.AR<3> = date.to.1 :@VM: date.to.2 :@VM: ...
* it is similar to rotate the matrix between field dimension and mv dimension.
FORM.HANDOFF.9:

    TOT.ENTRY = 0
    IF RET.INT.INFO THEN
        TOT.ENTRY = COUNT(RET.INT.INFO, @FM) + 1
    END

    FOR CNT.ENTRY = 1 TO TOT.ENTRY
        ONE.ENTRY = RET.INT.INFO<CNT.ENTRY>

        IF ONE.ENTRY THEN
            CONVERT '*' TO @FM IN ONE.ENTRY
            TOT.COL = COUNT(ONE.ENTRY, @FM) + 1

            FOR CNT.COL = 1 TO TOT.COL
                INT.STMT.ARR<CNT.COL, CNT.ENTRY> = ONE.ENTRY<CNT.COL>
            NEXT CNT.COL
        END
    NEXT CNT.ENTRY

    GOSUB UPDATE.INTEREST.BASIS ;* update interest basis with text for display

    IF NOT(INT.STMT.ARR) THEN
        GOSUB UPDATE.EMPTY.RECORD
    END

    HAND.REC(9) = INT.STMT.ARR

    RETURN

*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPDATE.INTEREST.BASIS>
*** <desc> </desc>
UPDATE.INTEREST.BASIS:
* display only one interest basis, not populate it everywhere.
    IF INT.STMT.ARR THEN
        INTEREST.BASIS.TEXT = ''
        ST.RateParameters.EbInterestBasis(INT.STMT.ARR<ACC.BASIS, 1>, INTEREST.BASIS.TEXT)
        INT.STMT.ARR<ACC.BASIS> = INTEREST.BASIS.TEXT
    END

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPDATE.EMPTY.RECORD>
*** <desc> </desc>
UPDATE.EMPTY.RECORD:

    FOR CNT.IDX = 1 TO LAST.FIELD.IDX
        INT.STMT.ARR<CNT.IDX> = 'N/A'
    NEXT CNT.IDX

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.CAPITALISATION.OR.ADHOC.DATES>
*** <desc> </desc>
GET.CAPITALISATION.OR.ADHOC.DATES:

    SCHEDULE.TYPE = HAND.REC(3)<AA.PaymentSchedule.AccountDetails.AdScheduleType>
    PAYMENT.DATE = HAND.REC(3)<AA.PaymentSchedule.AccountDetails.AdPaymentDate>
    DATE.FROM = AF.Framework.getActivityEffDate() ;* initialize to effective date, but it will be set to some date equals or before this date, to figure out the nearest past capitalization date.

    TOT.SCHEDULE.TYPE = 0
    IF SCHEDULE.TYPE THEN
        TOT.SCHEDULE.TYPE = COUNT(SCHEDULE.TYPE, @VM) + 1
    END

    SCHEDULE.TYPE.POS = 0
    FOR CNT.SCHEDULE.TYPE = 1 TO TOT.SCHEDULE.TYPE
        IF SCHEDULE.TYPE<1, CNT.SCHEDULE.TYPE>[AA.Framework.Sep, 2, 3] EQ PROPERTY THEN
            SCHEDULE.TYPE.POS = CNT.SCHEDULE.TYPE
            BREAK
        END
    NEXT CNT.SCHEDULE.TYPE

    LOCATE AF.Framework.getActivityEffDate() IN PAYMENT.DATE<1, SCHEDULE.TYPE.POS, 1> BY 'DN' SETTING PAYMENT.POS THEN
    IF PAYMENT.DATE<1, SCHEDULE.TYPE.POS, PAYMENT.POS+1> THEN
        DATE.FROM = PAYMENT.DATE<1, SCHEDULE.TYPE.POS, PAYMENT.POS+1>
    END
    END ELSE
    IF PAYMENT.DATE<1, SCHEDULE.TYPE.POS, PAYMENT.POS> THEN
        DATE.FROM = PAYMENT.DATE<1, SCHEDULE.TYPE.POS, PAYMENT.POS>
    END
    END

    IF INITIATION.TYPE EQ 'USER' THEN
        DATE.TO = EB.SystemTables.getToday() ;* for Adhoc should be system date
    END ELSE
        DATE.TO = AF.Framework.getActivityEffDate() ;* for capitalization, should be the effective date, because if it is scheduled on holiday, then today's date will be the previous nearest working day
    END
    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= POPULATE.ACCRUAL.WORK>
*** <desc> </desc>
POPULATE.ACCRUAL.WORK:

    TOT.SV = 1
    TOT.SV = COUNT(R.ACCRUAL.DATA<AC.Fees.EbAcRate, VIDX>, @SM) + 1

    FOR CNT.SV = 1 TO TOT.SV
        ACCRUAL.ITEM = PROPERTY:"*":INT.ACC.PERIOD.END<1,PERIOD.IDX>
        FOR IDX = AC.Fees.EbAcFromDate TO AC.Fees.EbAcCompoundYield
            IF IDX MATCHES AC.Fees.EbAcPrincipal:@VM:AC.Fees.EbAcRate:@VM:AC.Fees.EbAcAccrAmt:@VM:AC.Fees.EbAcAccrActAmt THEN ;* the list of fields that could be SV field
                ACCRUAL.ITEM := "*":R.ACCRUAL.DATA<IDX,VIDX,CNT.SV>
            END ELSE
                ACCRUAL.ITEM := "*":R.ACCRUAL.DATA<IDX,VIDX>
            END
        NEXT IDX
        ACCRUAL.WORK<-1> = ACCRUAL.ITEM
    NEXT CNT.SV
    RETURN
*** </region>

    END




