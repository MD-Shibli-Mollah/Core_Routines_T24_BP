* @ValidationCode : MjoxODYyNTg0NzE1OkNwMTI1MjoxNjA5MjQ1MzE5MDc4Om1qZWJhcmFqOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMTEtMTIxMDozNjQ6MjU2
* @ValidationInfo : Timestamp         : 29 Dec 2020 18:05:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 256/364 (70.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.NOFILE.AA.LOAN.OVERVIEW(LOAN.ARR)
*--------------------------------------------------------------------------------------------------------------
* Description:
* -----------
* This Enquiry(Nofile) routine is to provide a loan overview details(Schedules, different balances and interest details)
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.AA.LOAN.OVERVIEW using the Standard selection NOFILE.TC.AA.LOAN.OVERVIEW
* IN Parameters      : Arrangement Id, date from, date to and balance type
* Out Parameters     : Array of Loan values such as Arrangement Id, currency, different dates of loans, schedule counts,
*                      due amounts, next payment details and interest details returned.
*-----------------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 11/12/20 - Enhancement : 3930802
*            Task        : 3930805
*            Nofile enquiry routine to get the loan overview details
*
*-------------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
  
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Security
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.Interest
    $USING AC.AccountOpening
    $USING EB.API
    $USING MDLPTY.Party
    $USING MDLMKT.MarketData
    $USING EB.DataAccess
    $USING AC.SoftAccounting
    $USING EB.Interface
    $USING AA.Channels
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
    GOSUB INITIALISE          ;* Initialise Variables here
    IF R.ARRANGEMENT THEN
        GOSUB BUILD.BASIC.DATA    ;* Build the Schedule Details by calling the Projection Routine
        GOSUB GET.PAYOFF.DETAILS   ;* Check if PAYOFF property class is available for the arrangement
        GOSUB BUILD.ARRAY.DETAILS ;* Format the Details according to Enquiry requirements
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise Variables>
INITIALISE:
*---------
    DUE.DATES = ''  ;* Holds the list of Schedule due dates
    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts
    DUE.PROPS = ''  ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   ;* Oustanding Bal for the date
    DUE.METHODS = '' ; CYCLE.DATE = ''; CHRG.TYPE =''; SCHD.PROPERTY.RECORD = ''; IS.BAL.TYPE.GIVEN = ''; SIM.REF = '';
    INT.PROPERTY.CLASS = 'INTEREST'         ;* Initialise INTEREST property class
    INT.PROPERTY.RECORD = ''        ;* Initialise property record
    SCHD.PROPERTY.CLASS = 'SCHEDULE' ;* Initialise SCHEDULE Property class
    NEXT.PAY.AMT ='' ;* Initialise Next Payment Amount
    ARR.ID = '' ; DATE.REQD = '' ; LOAN.ARR = '';
    TODAY.DATE = EB.SystemTables.getToday()
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN   ;* If External User Language is not available
        ExtLang = 1         ;* Assigning Default Language position to read language multi value fields
    END
    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getDFields()<1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getDRangeAndValue()<ARRPOS>          ;* Pick the Arrangement Id
    END

    BAL.TYPES = ""
    FUTURE.DATE = "" ;* if stated, pick the Start date from when Schedules are required
    PAID.DATE = ""   ;* If stated, pick the End date till when Schedules are required

    IF ARR.ID[1,2] NE 'AA' THEN
        R.ACCOUNT = AC.AccountOpening.Account.Read(ARR.ID, ERR.ACCOUNT) ;* Read account details
        ARR.ID = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>  ;* Get Arrangement ID from ACCOUNT
    END
    
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARR.ID,ARR.ERR)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Project the Schedule>
BUILD.BASIC.DATA:
*---------------
  
    CURRENCY = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>
    ARR.STATUS = R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>
    ARR.START.DATE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>
    ACCT.NO = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
    
    R.ACCOUNT.DETAILS = AA.PaymentSchedule.AccountDetails.Read(ARR.ID,AC.ERR)
    MATURITY.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
    EB.API.MatDateEnrichment(MATURITY.DATE,TODAY.DATE,MATURITY.DAYS)
    MATURES.IN = MATURITY.DAYS
    EB.API.MatDateEnrichment(MATURITY.DATE,ARR.START.DATE,TERM.IN.DAYS)
    ARR.TERM = TERM.IN.DAYS
    COOLING.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdCoolingDate>
    ARR.BASE.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    IF ARR.BASE.DATE THEN    ;* Set base date as effective date if availble else set start date
        ARR.EFFECTIVE.DATE = ARR.BASE.DATE
    END ELSE
        ARR.EFFECTIVE.DATE = ARR.START.DATE
    END
    IF NOT(R.ACCOUNT) AND ACCT.NO[1,2] NE "AA" THEN
        R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.NO, ERR.ACCOUNT) ;* Read account details
    END
    GOSUB GET.NEXT.PAY.DETAILS
    GOSUB GET.INTEREST.DETAILS
    GOSUB SET.BASIC.BAL.DETAILS
*** No need to load again & again.
    IF NOT(AC.BALANCES.TYPE.DETAILS<1>) THEN
        GOSUB BUILD.AC.BALANCES.LIST
    END
    GOSUB GET.BALANCE.TYPES
    GOSUB ADD.BALANCES
    GOSUB GET.SCHEDULE.COUNTS
    GOSUB GET.INTEREST.CHARGE.SCHD

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Interest details>
GET.INTEREST.DETAILS:
*-------------------
    AA.Framework.GetArrangementConditions(ARR.ID,INT.PROPERTY.CLASS,'','',INT.PROPERTY.IDS,INT.PROPERTY.RECORD,RET.ERR)      ;* Get arrangement condition for Interest Property class
    INT.REC.CNT = DCOUNT(INT.PROPERTY.RECORD,@FM)
    FOR INT.REC = 1 TO INT.REC.CNT
        RATE.INDEX = ''
        R.INT.PROPERTY = ''
        PROPERTY.RECORD = INT.PROPERTY.RECORD<INT.REC>      ;* Get arrangement record
        PROPERTY.RECORD = RAISE(PROPERTY.RECORD)
        INT.EFFECTIVE.RATE = PROPERTY.RECORD<AA.Interest.Interest.IntEffectiveRate,1>       ;* Get Interest Rate
        INT.EFF.RATE.CNT = DCOUNT(INT.EFFECTIVE.RATE,@VM)
        FOR RATE.CNT = 1 TO INT.EFF.RATE.CNT
            EFFECTIVE.RATE<1,-1> = INT.EFFECTIVE.RATE<1,RATE.CNT>:"%"
        NEXT RATE.CNT
        INT.PROPERTY.REC = PROPERTY.RECORD<AA.Interest.Interest.IntIdCompTwo>
        INT.PROPERTY<1,-1> = INT.PROPERTY.REC
        R.INT.PROPERTY = AA.ProductFramework.Property.Read(INT.PROPERTY.REC,INT.ERR)
        BEGIN CASE                                                                                          ;* Get interest property description
            CASE R.INT.PROPERTY EQ ''                                                                       ;* If the Property Record is Empty Do Nothing
            CASE R.INT.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang> NE ''                ;* Case when description is available in External User Preferred Language
                INT.PROPERTY.DESC<1,-1> = R.INT.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang>  ;* Get the description in External User Language
            CASE 1                                                                                          ;* Case Otherwise executed when description is NOT available in Preferred Language
                INT.PROPERTY.DESC<1,-1> = R.INT.PROPERTY<AA.ProductFramework.Property.PropDescription, 1>   ;* Get the description in default Language
        END CASE
        COMPOUND.TYPE<1,-1> = PROPERTY.RECORD<AA.Interest.Interest.IntCompoundType>
        TIER.TYPE<1,-1> = PROPERTY.RECORD<AA.Interest.Interest.IntRateTierType>
        TMP.FLOATING.INDEX = PROPERTY.RECORD<AA.Interest.Interest.IntFloatingIndex>
        TMP.FIXED.RATE = PROPERTY.RECORD<AA.Interest.Interest.IntFixedRate>
        TMP.PERIODIC.INDEX = PROPERTY.RECORD<AA.Interest.Interest.IntPeriodicIndex>
        GOSUB GET.INDEX.DETAILS
        GOSUB GET.MARGIN.DETAILS
        IF TMP.FIXED.RATE THEN
            INTEREST.RATE<1,-1> =  INT.EFFECTIVE.RATE :"%"
        END ELSE
            INTEREST.RATE<1,-1> =  INT.EFFECTIVE.RATE :"% (":RATE.INDEX :" ": MARGIN.RATE:")"
        END
    NEXT INT.REC
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Index details>
GET.INDEX.DETAILS:
*----------------
    BEGIN CASE
        CASE TMP.FLOATING.INDEX
            FLOATING.INDEX<1,-1> = TMP.FLOATING.INDEX
            RATE.TYPE<1,-1> = "Variable"
            R.BASIC.RATE.TEXT = MDLMKT.MarketData.getBasicInterestName(TMP.FLOATING.INDEX)
                                                                                                     
            RATE.INDEX = R.BASIC.RATE.TEXT<MDLMKT.MarketData.BasicInterestName.rateNames.rateName> ;* Read description in ext user language if available
              
        CASE TMP.FIXED.RATE
            FIXED.RATE<1,-1> = TMP.FIXED.RATE
            RATE.TYPE<1,-1> = "Fixed"
        CASE TMP.PERIODIC.INDEX
            PERIODIC.INDEX<1,-1> = TMP.PERIODIC.INDEX
            RATE.TYPE<1,-1> = "Periodic"
            TODAY.DATE = EB.SystemTables.getToday()   ;* Take TODAY as Holiday.
            PERIODIC.INDEX.ID = TMP.PERIODIC.INDEX : CURRENCY : TODAY.DATE
            R.PERIODIC.INTEREST = MDLMKT.MarketData.getPeriodicInterest(PERIODIC.INDEX.ID)
                                                                                                        
            RATE.INDEX = R.PERIODIC.INTEREST<MDLMKT.MarketData.PeriodicInterest.rateNames.rateName>   ;* Read description in ext user language if available
                                                                                                                                                                                                        
        CASE 1
            RATE.TYPE<1,-1> = "Linked"
            LINKED.ARR = PROPERTY.RECORD<AA.Interest.Interest.IntLinkedArrangement>
            LINKED.PROPERTY = PROPERTY.RECORD<AA.Interest.Interest.IntLinkedProperty>
            AA.Interest.GetLinkedInterestRate(LINKED.ARR, LINKED.PROPERTY, '', LINKED.RATE, RetError) ;* API to find the linked interest rate
            R.LINK.PROPERTY = AA.ProductFramework.Property.Read(PROPERTY.ID,INT.ERR)
            IF R.LINK.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang> NE '' THEN
                L.PROP.DESC = R.LINK.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang>  ;* If description is available in External Language
            END ELSE
                L.PROP.DESC = R.LINK.PROPERTY<AA.ProductFramework.Property.PropDescription, 1>        ;* Read in default language if desc not available in preferred language
            END
            RATE.INDEX = LINKED.ARR:" ":L.PROP.DESC
            IF LINKED.RATE THEN
                EFFECTIVE.RATE = LINKED.RATE:"%"
            END
    END CASE
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Margin details>
GET.MARGIN.DETAILS:
*-----------------
    MARGIN.RATE = ""
    TOT.RATE = ""
    MARGIN.OPER = PROPERTY.RECORD<AA.Interest.Interest.IntMarginOper,EB.Reports.getVc()>          ;* Selection based on the multivalue field
    MARGIN.RATE = PROPERTY.RECORD<AA.Interest.Interest.IntMarginRate,EB.Reports.getVc()>
    NO.OF.REC = DCOUNT(MARGIN.OPER,@SM)
    FOR I =1 TO NO.OF.REC
        IF MARGIN.RATE<1,1,I> EQ "" THEN
            MARGIN.RATE<1,1,I> = "0"
        END
        BEGIN CASE
            CASE MARGIN.OPER<1,1,I> EQ "ADD"
                TOT.RATE := " +" : " " : MARGIN.RATE<1,1,I> :"%"
            CASE MARGIN.OPER<1,1,I> EQ "SUB"
                TOT.RATE := " -" : " " : MARGIN.RATE<1,1,I> :"%"
            CASE MARGIN.OPER<1,1,I> EQ "MULTIPLY"
                TOT.RATE := " *" : " " : MARGIN.RATE<1,1,I> :"%"
        END CASE
    NEXT I
    MARGIN.RATE = TOT.RATE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Basic balance details>
SET.BASIC.BAL.DETAILS:
*--------------------
    ARR.RECORD = R.ARRANGEMENT
    IF ST.DT EQ '' THEN
        ST.DT = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdValueDate>
    END
    IF END.DT EQ '' THEN
        END.DT = EB.SystemTables.getToday()
        IF ST.DT GT END.DT THEN         ;* can be true for fwd dated arrangement
            END.DT = ST.DT
        END
    END
    BALANCE.TYPE.POS = 50     ;* Balance type field in record
    BALANCE.BK.AMT.POS = 51   ;* Booking dated balance for balance type
    BALANCE.VD.AMT.POS = 52   ;* Value Dated balance for balance type
    EFF.DATE = EB.SystemTables.getToday()
    IF ST.DT GT EFF.DATE THEN ;* can be true for fwd dated arrangement
        EFF.DATE = ST.DT
    END
    PROP.CLS.LIST = ''
    PROP.LIST = ''
    REQD.BAL.LIST = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Build basic details to get balances>
BUILD.AC.BALANCES.LIST:
*---------------------
** Get a list AC.BALANCE.TYPES and store a separate list of virtual balances
    BAL.LIST = EB.DataAccess.DasAllIds
    EB.DataAccess.Das("AC.BALANCE.TYPE",BAL.LIST, '', '')
    BAL.IDX = ''
    LOOP
        REMOVE BALANCE.NAME FROM BAL.LIST SETTING BAL.POS
    WHILE BALANCE.NAME:BAL.POS
        BALANCE.TYPE.REC = ''
        BALANCE.TYPE.REC = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.NAME, "")
        BAL.IDX += 1
        AC.BALANCES.TYPE.DETAILS<1,BAL.IDX> = BALANCE.NAME
        AC.BALANCES.TYPE.DETAILS<2,BAL.IDX> = LOWER(BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtVirtualBal>)
        AC.BALANCES.TYPE.DETAILS<3,BAL.IDX> = BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtActivityUpdate>
    REPEAT
*
    IF AC.BALANCES.TYPE.DETAILS = '' THEN
        AC.BALANCES.TYPE.DETAILS = "NONE"       ;* Stop repeated selection
    END
RETURN
*-----------------------------------------------------------------------------
GET.BALANCE.TYPES:
*----------------
** Get the list of properties from the arrangement record then from the property class get the prefixes
** also get a list of all balance types so that we can look for virtual balances and any that are created by soft accounting
* Forcefully append null values into ARR.INFO, so that, values are not picked from common in AA.GET.ARRANGEMENT.PROPERTIES
* This is done to avoid common variables of some other arrangement getting assinged from cache, when multiple arrangment details are accessed within
* the same session
    PROPERTY.LIST = ""
    ARR.INFO = ARR.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, EFF.DATE, ARR.RECORD, PROPERTY.LIST)     ;* Get properties associated with the arrangement for the effective date

    BALANCE.LIST = CHANGE(BAL.TYPES,@VM,@FM)
    REQD.BAL.LIST = BAL.TYPES
RETURN
*-----------------------------------------------------------------------------
ADD.BALANCES:
*-----------
** Now for each balance in the list call EB.GET.ACCT.BALANCE to retrieve the balance we want
    NEXT.BAL = 0
    IDX = 0
    REQUEST.TYPE<3> = 'ALL'
    REQUEST.TYPE<2> = 'ALL'
    BAL.DETAILS = ''
    LOOP
        IDX += 1
        BALANCE.TYPE = BALANCE.LIST<IDX>
        PROPERTY = PROP.LIST<IDX>
        PROPERTY.CLASS = PROP.CLS.LIST<IDX>
    WHILE BALANCE.TYPE
        LOCATE BALANCE.TYPE IN AC.BALANCES.TYPE.DETAILS<1,1> SETTING BAL.POS THEN
            INTEREST.FOUND = ''
            VIRTUAL.BALANCES = AC.BALANCES.TYPE.DETAILS<2,BAL.POS>
            IF VIRTUAL.BALANCES THEN    ;* Get the balance from the values we've already calculated
                VIRTUAL.BAL = 'YES'
                SAVE.BALANCE.TYPE =  BALANCE.TYPE
                GOSUB CALCULATE.VIRTUAL.BALANCE
                BALANCE.TYPE = SAVE.BALANCE.TYPE
                BD.BAL = TOTAL.BAL.AMT
            END ELSE
                VIRTUAL.BAL = ''
                GOSUB GET.PERIOD.BALANCES
            END
            GOSUB SET.BALANCE.DETAILS
        END
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Virtual balance calcuations>
CALCULATE.VIRTUAL.BALANCE:
*------------------------
** We'll calculate this from the balances that we will have already extracted
** We do this as although EB.GET.ACCT.BALANCE handles virtual balances it only
** does so if the balance is in ACCT.ACTIVITY which may not always be the case
** for some balances
    BAL.AMT = ''
    LOOP
        REMOVE BAL.NAME FROM VIRTUAL.BALANCES SETTING YD
    WHILE BAL.NAME:YD
        LOCATE BAL.NAME IN ARR.RECORD<BALANCE.TYPE.POS,1> SETTING BAL.POS THEN
            BAL.AMT += ARR.RECORD<BALANCE.BK.AMT.POS, BAL.POS>
        END ELSE
            BALANCE.TYPE = BAL.NAME
            BD.BAL = 0.00
            GOSUB GET.PERIOD.BALANCES
            BAL.AMT + = BD.BAL
            TOTAL.BAL.AMT+ = BAL.AMT
        END
        IF BALANCE.TYPE AND BAL.AMT THEN
            R.BALANCE.TYPE = AC.SoftAccounting.BalanceType.Read(BAL.NAME,BAL.ERR)
            IF R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtDescription, ExtLang> NE '' THEN              ;* If Description available in Ext Language
                BALANCE.TYPES<1,-1> = R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtDescription, ExtLang> ;* Read Description  in Ext Language
            END ELSE
                BALANCE.TYPES<1,-1> = R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtDescription, 1>        ;* Read in default language
            END
            BAL.AMOUNT<1,-1> = BAL.AMT
            BAL.AMT = 0.00
        END
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= perioic balance details>
GET.PERIOD.BALANCES:
*------------------
    IF INTEREST.FOUND NE 1 THEN
        REQUEST.TYPE<6> = CHRG.TYPE
        AA.Framework.GetPeriodBalances(ACCT.NO,BALANCE.TYPE,REQUEST.TYPE,ST.DT,END.DT,'',BAL.DETAILS,'')
        NO.OF.DT = DCOUNT(BAL.DETAILS<1>,@VM)
        BD.BAL = BAL.DETAILS<4,NO.OF.DT>
    END
RETURN
*** </region>
*----------------------------------------------------------------------------
***  <region name= set output for balance details>
SET.BALANCE.DETAILS:
*------------------
    IF BD.BAL THEN
        NEXT.BAL +=1
        ARR.RECORD<BALANCE.TYPE.POS, NEXT.BAL> = BALANCE.TYPE
        ARR.RECORD<BALANCE.BK.AMT.POS, NEXT.BAL> = BD.BAL
        LOCATE BALANCE.TYPE IN REQD.BAL.LIST<1> SETTING REQ.POS THEN
            CHANGE @SM TO @VM IN VIRTUAL.BALANCES
            VIRTUAL.BALANCE = VIRTUAL.BAL
            ARR.POS<-1> = REQ.POS
            BALANCE.TYPES<1,-1> = BALANCE.TYPE
            BAL.AMOUNT<1,-1> = BD.BAL
        END
    END
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= Next payment details>
GET.NEXT.PAY.DETAILS:
*-------------------
*Get Next Payment Amount/Next Payment Date
    CURRENT.SEL.CRITERIA=EB.Reports.getEnqSelection()   ;*Storing old enq selection values
    EB.Reports.setEnqSelection('')   ;*Clearing new enq selection values
    EB.Reports.setOData(ARR.ID);*Passing arrangement id to enquiry selection
    AA.ModelBank.EAaGetArrNextPayment()      ;*Calling routine for getting next payment date.
    EB.Reports.setEnqSelection(CURRENT.SEL.CRITERIA)   ;*setting old enq selection values
    NEXT.PAY.DATE = EB.Reports.getOData()    ;*Get the Next payment date from the above routine
    NEXT.PAYMENT.DATE = NEXT.PAY.DATE
    FROM.DATE=EB.SystemTables.getToday() ;* Get today date
    DATE.RANGE = FROM.DATE:@FM:NEXT.PAYMENT.DATE ;* To find next payment amount alone from Payment Schedule Projector by passing date range value from TODAY to NEXT.PAYMENT.DATE
    NO.RESET<2> = ""
    IF FROM.DATE NE NEXT.PAYMENT.DATE THEN
        NO.RESET<2>=1
    END
    AA.PaymentSchedule.ScheduleProjector(ARR.ID,SIMULATION.REF,NO.RESET,DATE.RANGE,TOT.PAYMENT,DUE.DATES,"",DUE.TYPES,DUE.METHODS,DUE.TYPE.AMTS,DUE.PROPS,DUE.PROP.AMTS,DUE.OUTS)     ;* Get Next payment Amount from sehedule projector
    CHANGE @VM TO @FM IN TOT.PAYMENT
    LOCATE NEXT.PAYMENT.DATE IN DUE.DATES SETTING POS THEN  ;*Locating the position of next payment date
        NEXT.PAY.AMOUNT = TOT.PAYMENT<POS> ;* Get the next payment amt based on the next payment date.
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Schedule counts>
GET.SCHEDULE.COUNTS:
*------------------
* Initialise the required variables
  
    FUTURE.SCHD.COUNT = 0; PAID.SCHD.COUNT = 0; DUE.SCHD.COUNT = 0;
    IF NOT(FUTURE.DATE) THEN
        FUTURE.DATE=TODAY.DATE
    END
    IF NOT(PAID.DATE) THEN
        PAID.DATE=@FM:TODAY.DATE
    END
    IF ARR.START.DATE GT FUTURE.DATE THEN ;* Set arrangement start date if it is greater than the future date
        ARR.FUTURE.DATE = ARR.START.DATE
    END ELSE
        ARR.FUTURE.DATE = FUTURE.DATE
    END
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",ARR.FUTURE.DATE, FUTR.PAY.AMOUNT, FUTURE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Call routine to get the list of schedules to be paid from the date given
    FUTR.SCHD.COUNT = DCOUNT(FUTURE.DATES,@FM)     ;* Total Number of Schedule dates
    SAVE.FUTR.SCHD.COUNT = FUTR.SCHD.COUNT

    FOR FUT.SCHD = 1 TO SAVE.FUTR.SCHD.COUNT
        PAYMENT.DATE = FUTURE.DATES<FUT.SCHD>      ;* Read the payment date for the schedule dates
        BILL.STATUS = 'SETTLED'
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the settled bill generated
        PAID.SCHD.COUNT+ = SCHD.COUNT              ;* Count the schedule which is paid
        FUTR.SCHD.COUNT = FUTR.SCHD.COUNT - SCHD.COUNT      ;* Count of future schedules to be paid
        
        BILL.STATUS = "AGING":@VM:"DUE":@VM:"DEFER"
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the due bills generated
        FUTR.SCHD.COUNT = FUTR.SCHD.COUNT - SCHD.COUNT
    NEXT FUT.SCHD

    LAST.PAYMENT.DATE =  FUTURE.DATES<SAVE.FUTR.SCHD.COUNT>   ;* Read the last payment date of the future schedule date
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",PAID.DATE, PAID.AMOUNT, PAID.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Call routine to get paid out schedules till the date given
    PAID.SCHEDULES = DCOUNT(PAID.DATES,@FM)     ;* Total Number of Schedule dates
    FOR SCHD = 1 TO PAID.SCHEDULES
        PAYMENT.DATE = PAID.DATES<SCHD>
        BILL.STATUS = "AGING":@VM:"DUE":@VM:"DEFER"
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the aged bill generated
        DUE.SCHD.COUNT+ =  SCHD.COUNT            ;* Count the schedule which is due
    NEXT SCHD
    PAID.SCHD.COUNT+ = PAID.SCHEDULES - DUE.SCHD.COUNT   ;* Count of schedule paid
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get overdue schedule count by reading the aged bills>
GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT:
*----------------------------------
*Get the Bill Id which has status as AGING for a date lt today/ SETTLED for a date gt today

    BILL.REFERENCES = ''; SCHD.COUNT = 0;
    AA.PaymentSchedule.GetBill(ARR.ID,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)        ;* Call routine to get bill details based on status
    IF BILL.REFERENCES THEN
        SCHD.COUNT =  DCOUNT(BILL.REFERENCES,@VM)   ;* Count of bill ids
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Interest and Charge schedule>
GET.INTEREST.CHARGE.SCHD:
*-----------------------
* Get interest and charge schedule details
    AA.Channels.AaGetInterestChargeSchedule(ARR.ID,ARR.START.DATE,PAYMENT.SCHD.ARR) ;* Get the interest and charge schedule
    CHANGE "*" TO @FM IN PAYMENT.SCHD.ARR
    SCHD.PAYMENT.TYPE = PAYMENT.SCHD.ARR<2>
    SCHD.PAYMENT.METHOD = PAYMENT.SCHD.ARR<4>
    SCHD.PROP = PAYMENT.SCHD.ARR<3>
    SCHD.PAYMENT.AMT = PAYMENT.SCHD.ARR<5>
    SCHD.PAYMENT.FREQ = PAYMENT.SCHD.ARR<1>
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= check if property class is available in arrangement>
GET.PAYOFF.DETAILS:
*------------------------
* Check whether there is property conditions that apply to arrangement
    PAYOFF.PROPERTY.CLASS = 'PAYOFF'
    PAYOFF.PROPERTY.RECORD = ''
    PAYOFF.REQUEST = ''
    PAYOFF.PROPERTY.IDS = ''
    AA.Framework.GetArrangementConditions(ARR.ID,PAYOFF.PROPERTY.CLASS,'',ARR.START.DATE,PAYOFF.PROPERTY.IDS,PAYOFF.PROPERTY.RECORD,RET.ERR)    ;* Get arrangement condition for PAYOFF Property class
    IF PAYOFF.PROPERTY.RECORD AND (ARR.STATUS EQ "CURRENT" OR ARR.STATUS EQ "EXPIRED") THEN
        PAYOFF.REQUEST = 'Y'
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
BUILD.ARRAY.DETAILS:
*------------------
* Convert VM to pipe symbol to avoid spaces in return array for these details and build loan array details
    
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) ELSE
        CHANGE @VM TO "|" IN INTEREST.RATE
        CHANGE @VM TO "|" IN INT.PROPERTY
        CHANGE @VM TO "|" IN INT.PROPERTY.DESC
        CHANGE @VM TO "|" IN COMPOUND.TYPE
        CHANGE @VM TO "|" IN RATE.TYPE
        CHANGE @VM TO "|" IN EFFECTIVE.RATE
        CHANGE @VM TO "|" IN TIER.TYPE
        CHANGE @VM TO "|" IN BALANCE.TYPES
        CHANGE @VM TO "|" IN BAL.AMOUNT
    END

    LOAN.ARR<-1> = ARR.ID:'*':CURRENCY:'*':ARR.EFFECTIVE.DATE:'*':MATURITY.DATE:'*':MATURES.IN:'*':COOLING.DATE:'*':NEXT.PAY.AMOUNT:'*':NEXT.PAY.DATE:'*':INTEREST.RATE:'*':INT.PROPERTY:'*':INT.PROPERTY.DESC:'*':COMPOUND.TYPE:'*':RATE.TYPE:'*':EFFECTIVE.RATE:'*':TIER.TYPE:'*':VIRTUAL.BALANCE:'*':BALANCE.TYPES:'*':BAL.AMOUNT:'*':PAID.SCHD.COUNT:'*':DUE.SCHD.COUNT:'*':FUTR.SCHD.COUNT:'*':SCHD.PAYMENT.TYPE:'*':SCHD.PAYMENT.METHOD:'*':SCHD.PROP:'*':SCHD.PAYMENT.AMT:'*':SCHD.PAYMENT.FREQ:'*':LAST.PAYMENT.DATE:'*':ARR.TERM:'*':PAYOFF.REQUEST
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
