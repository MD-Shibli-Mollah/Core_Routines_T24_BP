* @ValidationCode : MjoxMjU2NDYwMjg5OkNwMTI1MjoxNjA1NzAyMDk0MTU5OnJha3NoYXJhOjc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMDozOTc6MzEw
* @ValidationInfo : Timestamp         : 18 Nov 2020 17:51:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 310/397 (78.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.NOFILE.AA.PENDING.ACTIVITIES(PendingActivity)
*-----------------------------------------------------------------------------
* Routine Description:
*---------------------
* This NOFILE routine will facilitate to view the pending activities as well as to instigate the workflow based
* on data in AA.USER.ACTIVITY as well as AA.SCHEDULED.ACTIVITY.
*
*Ouput :-
*
*PendingActivity Array will contain the following output for enquiry : -
*
* DRAWDOWN.REF  CUSTOMER    TITLE    CURRENCY  REQUEST.TYPE  REQUEST.DATE  EXCH.RATE.FIX.DATE  INTEREST.RATE.FIX.DATE  COMPLETION.DATE       STATUS           INITIATION     DRILLDOWN
*-------------  --------    -----    --------  ------------  ------------  ------------------  ----------------------  ---------------       ------           ----------     ---------
*
*AA09357LBSKW    100100   Fixed Rate   USD    New Drawdown   01 JAN 2009        N/A                05 JAN 2009           05 JAN 2009    Pending Exchange Rate    Auto       Contains array will all details separated by '!'
*                                                                                                                                       Pending Interest Rate   Manual
*
*AA09357SFKWN    100200   Fixed Rate   GBP    Rollover       01 JAN 2009      10 JAN 2009          05 JAN 2009           05 JAN 2009    Pending Exchange Rate    Auto
*
*PendingActivity array be in returned by the routine in the following format : -
*
*DRAWDOWN.REF*REQUEST.TYPE*REQUEST.DATE*EXCH.RATE.FIX.DATE*INTEREST.RATE.FIX.DATE*COMPLETION.DATE*STATUS*INITIATION*DRILLDOWN
*
*Example: -
*-------
*
*AA093582J8C3*New Drawdown*20091224***20091228*LENDING-NEW-ARRANGEMENT*AUTO*AA093582J8C3!New Drawdown!20091224!!!20091228!LENDING-NEW-ARRANGEMENT!AUTO
*
*-----------------------------------------------------------------------------
* @uses I_ENQUIRY.COMMON varibles
* @package ModelBank.AA
* @stereotype NOFILE Routine
* @author rakshara@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*
* 26/10/20 - Task- 4044949
*            Enhancement - 4030912
*            NOFILE enquiry routine for advance rate fix.
*
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING AF.Framework
    $USING EB.DataAccess
    $USING AA.ProductFramework
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AA.PaymentSchedule
    $USING AA.Account
    $USING AA.ExchangeRate
    $USING AA.ChangeProduct
    $USING AA.Interest
    
    GOSUB Initialise ;* Initialise variables.
    GOSUB EnqSelectionValues  ;* Fetch values from selections.
    GOSUB Process   ;* Main process
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialising variables </desc>
Initialise:

    ArrangementRef = ''
    Customer = ''
    FacilityRef = ''
    Currency = ''
    InRequestDate = ''
    RequestDateOperand = ''
    InExchRunDate = ''
    ExchRateDateOperand = ''
    InIntRunDate = ''
    InterestDateOperand = ''
    InCompletionDate = ''
    CompletionDateOperand = ''
    
    ExchangeRateProperty = ''
    InterestProperty = ''
    PendingActivity = ''
      
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= EnqSelectionValues>
*** <desc>Fetch values from selections </desc>
EnqSelectionValues:

*Get arrangement reference
    ArrPos = ''
    LOCATE "ARRANGEMENT.REF" IN EB.Reports.getDFields()<1> SETTING ArrPos THEN
        ArrangementRef = EB.Reports.getDRangeAndValue()<ArrPos>
    END
*Get facility reference
    FacPos = ''
    LOCATE "FACILITY.REF" IN EB.Reports.getDFields()<1> SETTING FacPos THEN
        FacilityRef = EB.Reports.getDRangeAndValue()<FacPos>
        FacArrangement = ''
        AA.Framework.GetArrangement(FacilityRef, FacArrangement, ArrError)   ;* Facility arrangement record
        ArrangementRef = FacArrangement<AA.Framework.Arrangement.ArrSubArrangement>
        CONVERT @VM TO @FM IN ArrangementRef
    END
*Get customer
    CusPos = ''
    LOCATE "CUSTOMER" IN EB.Reports.getDFields()<1> SETTING CusPos THEN
        Customer = EB.Reports.getDRangeAndValue()<CusPos>
    END
*Get currency
    CcyPos = ''
    LOCATE "CURRENCY" IN EB.Reports.getDFields()<1> SETTING CcyPos THEN
        Currency = EB.Reports.getDRangeAndValue()<CcyPos>
    END
*Get request date
    ReqDatePos = ''
    LOCATE "REQUEST.DATE" IN EB.Reports.getDFields()<1> SETTING ReqDatePos THEN
        InRequestDate = EB.Reports.getDRangeAndValue()<ReqDatePos>
        RequestDateOperand = EB.Reports.getDLogicalOperands()<ReqDatePos>
    END
*Get exchange rate date
    ExchRateDatePos = ''
    LOCATE "EXCH.RATE.DATE" IN EB.Reports.getDFields()<1> SETTING ExchRateDatePos THEN
        InExchRunDate = EB.Reports.getDRangeAndValue()<ExchRateDatePos>
        ExchRateDateOperand = EB.Reports.getDLogicalOperands()<ExchRateDatePos>
    END
*Get interest date
    IntDatePos = ''
    LOCATE "INTEREST.DATE" IN EB.Reports.getDFields()<1> SETTING IntDatePos THEN
        InIntRunDate = EB.Reports.getDRangeAndValue()<IntDatePos>
        InterestDateOperand = EB.Reports.getDLogicalOperands()<IntDatePos>
    END
*Get completion date
    CompDatePos = ''
    LOCATE "COMPLETION.DATE" IN EB.Reports.getDFields()<1> SETTING CompDatePos THEN
        InCompletionDate = EB.Reports.getDRangeAndValue()<CompDatePos>
        CompletionDateOperand = EB.Reports.getDLogicalOperands()<CompDatePos>
    END
    
    IF NOT(ArrangementRef) THEN
        IF NOT(FacilityRef) THEN
            fnPdc = "F.AA.ARRANGEMENT"
            fPdc = ""
            EB.DataAccess.Opf(fnPdc,fPdc)
            selCmd="SELECT ":fnPdc:' WITH PRODUCT.LINE EQ "LENDING"'  ;* select AA.ARRANGEMENT records for product line LENDING
            EB.DataAccess.Readlist(selCmd,ArrangementRef,'',noofRecords,'')  ;* get Arrangement references
        END
    END
    GOSUB GetFixedSelection   ;* Get values from fixed selection.
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFixedSelection>
*** <desc> Get values from fixed selection</desc>
GetFixedSelection:
    
    FixedSelection = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>    ;* Get the Fixed selection for the enquiry
    TotalFixedSelection =  DCOUNT(FixedSelection, @VM) ;* Count the number of fixed selections defined for the enquiry
    FOR SelectionCnt = 1 TO TotalFixedSelection  ;* Loop the fixed selection
        ProcessFlag = 0
        CurrentFixedSelection = FixedSelection<1,SelectionCnt>
        CurSelCnt = DCOUNT(CurrentFixedSelection, " ")
        CurrentFieldName    = FIELD(CurrentFixedSelection," ",1)    ;* get the field value
        CurrentFieldOperand = FIELD(CurrentFixedSelection," ",2)    ;* get the operand value
        CurrentFieldValue   = FIELD(CurrentFixedSelection," ",3,CurSelCnt)    ;* get the selection value
        IF CurrentFieldName EQ "PROPERTY" AND CurrentFieldOperand EQ "EQ" THEN
            CHANGE " " TO @VM IN CurrentFieldValue
            CurrFieldValueCnt = DCOUNT(CurrentFieldValue, @VM)
            FOR FielValPos = 1 TO CurrFieldValueCnt
                AA.ProductFramework.GetPropertyClass(CurrentFieldValue<1,FielValPos>, PropertyClass)   ;*Get property class for the property
                BEGIN CASE
                    CASE PropertyClass EQ "INTEREST"
                        InterestProperty = CurrentFieldValue<1,FielValPos>
                    CASE PropertyClass EQ "EXCHANGE.RATE"
                        ExchangeRateProperty = CurrentFieldValue<1,FielValPos>
                END CASE
            NEXT FielValPos
            SelectionCnt = TotalFixedSelection  ;* Exit Loop once property is fetched
        END
    NEXT SelectionCnt
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc> Main process</desc>
Process:
    
    DrawingsCnt = DCOUNT(ArrangementRef, @FM)   ;* Get no of arrangements
    
    FOR DrgPos = 1 TO DrawingsCnt
        ArrangementId = ArrangementRef<DrgPos>
        CurrencyFlag = ''
        CustFlag = ''
        CompletionDate = ''
        RequestDate = ''
        StopProcessFlag = ''
        StopExchRunDate = ''
        StopIntRunDate = ''
        ExchProcessFlag = ''
        IntProcessFlag = ''
        Status = ''
        Inititation = ''
        AA.Framework.GetArrangement(ArrangementId, RArrangement, ArrError)       ;* Arrangement record
        ArrangementStatus  = RArrangement<AA.Framework.Arrangement.ArrArrStatus> ;* Arrangement status
        ProductLine = RArrangement<AA.Framework.Arrangement.ArrProductLine>      ;* Arrangement product line
        ArrangementCcy = RArrangement<AA.Framework.Arrangement.ArrCurrency>      ;* Arrangement currency
        ArrangementCust = RArrangement<AA.Framework.Arrangement.ArrCustomer>     ;* Arrangement customer
        
        IF ArrangementStatus EQ "NEW.OFFER" THEN
            EffectiveDate = RArrangement<AA.Framework.Arrangement.ArrStartDate> ;* Arrangement Start Date
        END ELSE
            EffectiveDate = EB.SystemTables.getToday()
        END
        
        IF Currency AND (Currency NE ArrangementCcy) THEN
            StopProcessFlag = 1
        END
        IF Customer AND (Customer NE ArrangementCust) THEN
            StopProcessFlag = 1
        END
    
        IF NOT(StopProcessFlag) THEN
            GOSUB GetArrangementCondition  ;* Get arrangement conditions.
            ExchangeRateInitType = RExchangeRate<AA.ExchangeRate.ExchangeRate.ExcInitiationType>
            InterestInitType = RInterest<AA.Interest.Interest.IntInitiationType>
            PropertyId = ''
            IF ExchangeRateProperty THEN
                PropertyId<-1> = ExchangeRateProperty
            END
            IF InterestProperty THEN
                PropertyId<-1> = InterestProperty
            END
            PropCnt = DCOUNT(PropertyId, @FM)   ;* Get count of properties
        
            IF ArrangementStatus EQ "NEW.OFFER" THEN
                GOSUB GetNewOfferDetails ; *Get details of New offer arrangement
            END
            IF NOT(ArrangementStatus MATCHES "NEW.OFFER":@VM:"PENDING.CLOSURE":@VM:"CLOSED") THEN
                GOSUB GetIntentDetails ; *To get the arrangement details for which intent is initiated
            END
        END
    NEXT DrgPos

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetNewOfferDetails>
GetNewOfferDetails:
*** <desc>Get details of New offer arrangement </desc>

    RequestType = "New Drawdown"
    RAccountDetails = ''
    AA.PaymentSchedule.ProcessAccountDetails(ArrangementId, "GET", "", RAccountDetails, RetError) ;* to get the account details of the arrangement
    CompletionDate = RArrangement<AA.Framework.Arrangement.ArrStartDate> ;* Arrangement Start Date
    RequestDate = RAccountDetails<AA.PaymentSchedule.AccountDetails.AdOfferDate>
    StopCompletionDate = ''
    StopRequestDate = ''
    IF InCompletionDate THEN
        InValue = InCompletionDate
        ActualValue = CompletionDate
        Operand = CompletionDateOperand
        GOSUB CheckOperand  ;* Filter selections
        StopCompletionDate = StopFlag
    END
    IF InRequestDate THEN
        InValue = InRequestDate
        ActualValue = RequestDate
        Operand = RequestDateOperand
        GOSUB CheckOperand  ;* Filter selections
        StopRequestDate = StopFlag
    END
                
    IF NOT(StopCompletionDate OR StopRequestDate) THEN    ;* Filtering arrangements based on incoming selections
        OfferExecution = RAccount<AA.Account.Account.AcOfferExecution>
        ActivityName = ''
        CompletionFlag = ''
        GOSUB GetDetails ; *To get the new arrangement details
        IF NOT(StopExchRunDate OR StopIntRunDate) THEN
            IF NOT(ExchProcessFlag) AND NOT(IntProcessFlag) THEN
                GOSUB ProcessCompletionActivity   ;* Get effective date for completion activity.
            END ELSE
                GOSUB FormPendingActivityDetails  ;* Return output array
            END
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetDetails>
GetDetails:
*** <desc>To get the new arrangement details </desc>

    FOR PropPos = 1 TO PropCnt
        GOSUB ProcessExchangeRateDetails ; *Get the details of Exchange Rate Property
        GOSUB ProcessInterestDetails ; *Get the details of Interest Property
    NEXT PropPos
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ProcessCompletionActivity>
ProcessCompletionActivity:
*** <desc>Get effective date for completion activity </desc>

    CompletionFlag = 1
    Status = 'LENDING-NEW-ARRANGEMENT'
    Inititation = OfferExecution
    ActivityEffDate = ''
    BEGIN CASE
        CASE OfferExecution EQ 'AUTO'
            AA.Framework.GetScheduledActivityDate(ArrangementId, Status, "NEXT", ActivityRunDate, ActivityEffDate, RetErr)
        CASE OfferExecution EQ 'MANUAL'
            AA.Framework.GetNextUserActivityDate(ArrangementId, Status, ActivityRunDate, ActivityEffDate, ReturnError)
    END CASE
    IF ActivityEffDate THEN
        GOSUB FormPendingActivityDetails  ;* Return output array
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetIntentDetails>
GetIntentDetails:
*** <desc>To get the arrangement details for which intent is initiated </desc>
    
    RequestType = "Rollover"
    ChangePdtInitType = RChangeProduct<AA.ChangeProduct.ChangeProduct.CpInitiationType>
    ChangeActivity = RChangeProduct<AA.ChangeProduct.ChangeProduct.CpChangeActivity>
    PriorDays = RChangeProduct<AA.ChangeProduct.ChangeProduct.CpPriorDays>
    GOSUB GetLiveActivity  ;* Get live activity for change activity
    GOSUB GetChangeProductDates  ;* Get completion date and request date for change product.
    CompletionDate = ActivityEffDate
    RequestDate = EventDate
    StopCompletionDate = ''
    StopRequestDate = ''
    IF InCompletionDate THEN
        InValue = InCompletionDate
        ActualValue = CompletionDate
        Operand = CompletionDateOperand
        GOSUB CheckOperand  ;* Filter selections
        StopCompletionDate = StopFlag
    END
    IF InRequestDate THEN
        InValue = InRequestDate
        ActualValue = RequestDate
        Operand = RequestDateOperand
        GOSUB CheckOperand  ;* Filter selections
        StopRequestDate = StopFlag
    END
    IF NOT(StopCompletionDate OR StopRequestDate) THEN    ;* Filtering arrangements based on incoming selections
        ActivityName = ''
        CompletionFlag = ''
        GOSUB GetDetails ; *To get the new arrangement details
        IF NOT(StopExchRunDate OR StopIntRunDate) THEN
            IF NOT(ExchProcessFlag) AND NOT(IntProcessFlag) THEN
                CompletionFlag = 1
                Status = LiveActivity
                Inititation = ChangePdtInitType
                GOSUB GetChangeProductDates  ;* Get completion date and request date for change product.
                IF ActivityEffDate THEN
                    GOSUB FormPendingActivityDetails  ;* Return output array
                END
            END ELSE
                GOSUB FormPendingActivityDetails  ;* Return output array
            END
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetChangeProductDates>
*** <desc> Get completion date and request date for change product</desc>
GetChangeProductDates:
    
    ActivityRunDate = ''
    ActivityEffDate = ''
    EventDate = ''
    
    IF ChangePdtInitType EQ 'AUTO' THEN
        AA.Framework.GetScheduledActivityDate(ArrangementId, LiveActivity, 'NEXT', ActivityRunDate, ActivityEffDate, RetError)
        AA.Framework.GetEventDate(ActivityEffDate, PriorDays, "", EventDate, ReturnError)
    END
    IF ChangePdtInitType EQ 'MANUAL' THEN
        AA.Framework.GetNextUserActivityDate(ArrangementId, LiveActivity, ActivityRunDate, ActivityEffDate, RetError)
        AA.Framework.GetEventDate(ActivityEffDate, PriorDays, "", EventDate, ReturnError)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetArrangementCondition>
*** <desc> Get arrangement conditions</desc>
GetArrangementCondition:

*Get ACCOUNT arrangement condition
    RAccount = ''
    PropertyClass = "ACCOUNT"
    Property = ''
    GOSUB GetCondition
    RAccount = RAISE(ProductCondition)
*Get EXCHANGE.RATE arrangement condition
    RExchangeRate = ''
    PropertyClass = "EXCHANGE.RATE"
    Property = ExchangeRateProperty
    GOSUB GetCondition
    RExchangeRate = RAISE(ProductCondition)
*Get INTEREST arrangement condition
    RInterest = ''
    PropertyClass = "INTEREST"
    Property = InterestProperty
    GOSUB GetCondition
    RInterest = RAISE(ProductCondition)
*Get CHANGE.PRODUCT arrangement condition
    RChangeProduct = ''
    PropertyClass = "CHANGE.PRODUCT"
    Property = ''
    GOSUB GetCondition
    RChangeProduct = RAISE(ProductCondition)
 
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetCondition>
*** <desc> Get arrangement conditions</desc>
GetCondition:

    ProductCondition = ''
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass, Property, EffectiveDate, "", ProductCondition, RecError)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckOperand>
*** <desc> Filter selections</desc>
CheckOperand:

    StopFlag = ''
    BEGIN CASE
        CASE Operand EQ 1       ;* When Operand is EQ
            IF NOT(ActualValue EQ InValue) THEN
                StopFlag = 1
            END
        CASE Operand EQ 3       ;* When Operand is LT
            IF NOT(ActualValue LT InValue) THEN
                StopFlag = 1
            END
        CASE Operand EQ 8       ;* When Operand is LE
            IF NOT(ActualValue LE InValue) THEN
                StopFlag = 1
            END
        CASE Operand EQ 4       ;* When Operand is GT
            IF NOT(ActualValue GT InValue) THEN
                StopFlag = 1
            END
        CASE Operand EQ 9       ;* When Operand is GE
            IF NOT(ActualValue GE InValue) THEN
                StopFlag = 1
            END
        CASE Operand EQ 2       ;* When Operand is BETWEEN
            IF NOT((ActualValue GT InValue<1,1,1>) AND (ActualValue LT InValue<1,1,2>)) THEN
                StopFlag = 1
            END
        
        CASE 1
            StopFlag = 1
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FormPendingActivityDetails>
*** <desc>Return output array</desc>
FormPendingActivityDetails:
    
    CONVERT @FM TO '~' IN Status
    CONVERT @FM TO '~' IN Inititation
    IF ExchProcessFlag OR IntProcessFlag OR CompletionFlag THEN
        StatusCnt = DCOUNT(Status,'~')
        DrillDownData = ArrangementId:'!':RequestType:'!':RequestDate:'!':ExchRunDate:'!':IntRunDate:'!':CompletionDate:'!':FIELD(Status,'~',1):'!':FIELD(Inititation,'~',1)
        PendingActivity<-1> = ArrangementId:'*':RequestType:'*':RequestDate:'*':ExchRunDate:'*':IntRunDate:'*':CompletionDate:'*':FIELD(Status,'~',1):'*':FIELD(Inititation,'~',1):'*':DrillDownData
        IF StatusCnt GT 1 THEN
            FOR StatusIndex = 2 TO StatusCnt
                DrillDownData = ArrangementId:'!':RequestType:'!':RequestDate:'!':ExchRunDate:'!':IntRunDate:'!':CompletionDate:'!':FIELD(Status,'~',StatusIndex):'!':FIELD(Inititation,'~',StatusIndex)
                PendingActivity<-1> = '':'*':'':'*':'':'*':'':'*':'':'*':'':'*':FIELD(Status,'~',StatusIndex):'*':FIELD(Inititation,'~',StatusIndex):'*':DrillDownData
            NEXT StatusIndex
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetLiveActivity>
*** <desc> Get live activity for change activity</desc>
GetLiveActivity:

    ChkChangeAct    = FIELD(ChangeActivity, AA.Framework.Sep, 2)
    LiveActivity = ''
    BEGIN CASE
        CASE ChkChangeAct EQ "ROLLOVER.INTENT"    ;* For rollover activities
            LiveActivity = ProductLine:AA.Framework.Sep:'ROLLOVER':AA.Framework.Sep: 'ARRANGEMENT' ;* set the rollover arrangement activity
            
        CASE ChkChangeAct EQ "CHANGE.PRODUCT.INTENT"    ;* for change product activities
            LiveActivity = ProductLine:AA.Framework.Sep:'CHANGE.PRODUCT':AA.Framework.Sep: 'ARRANGEMENT' ;* set the Chnageproduct arrangement activity
            
        CASE ChkChangeAct EQ "RESET.INTENT" ;* for reset activities
            LiveActivity = ProductLine:AA.Framework.Sep:'RESET':AA.Framework.Sep: 'ARRANGEMENT' ;* set the reset arrangement activity
            
        CASE 1
            LiveActivity = ProductLine:AA.Framework.Sep:ChkChangeAct:AA.Framework.Sep: 'ARRANGEMENT'
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ProcessExchangeRateDetails>
ProcessExchangeRateDetails:
*** <desc>Get the details of Exchange Rate Property </desc>

    IF PropertyId<PropPos> EQ ExchangeRateProperty THEN
        ActivityName = ProductLine:AA.Framework.Sep:"RATE.FIX":AA.Framework.Sep:ExchangeRateProperty
        ActivityRunDate = ''
        ActivityEffDate = ''
        ExchRunDate = ''
        StopExchRunDate = ''
        StopExchProcess = ''
        BEGIN CASE
            CASE ExchangeRateInitType EQ "AUTO"
                AA.Framework.GetScheduledActivityDate(ArrangementId, ActivityName, "NEXT", ActivityRunDate, ActivityEffDate, RetErr)
            CASE ExchangeRateInitType EQ "MANUAL"
                AA.Framework.GetNextUserActivityDate(ArrangementId, ActivityName, ActivityRunDate, ActivityEffDate, ReturnError)
            CASE 1
                StopExchProcess = 1
        END CASE

        IF NOT(StopExchProcess) AND ActivityEffDate AND ActivityEffDate EQ CompletionDate THEN
            ExchRunDate = ActivityRunDate
            IF InExchRunDate THEN
                InValue = InExchRunDate
                ActualValue = ExchRunDate
                Operand = ExchRateDateOperand
                GOSUB CheckOperand  ;* Filter selections
                StopExchRunDate = StopFlag
            END
            Status<-1> = ActivityName
            Inititation<-1> = ExchangeRateInitType
            ExchProcessFlag = 1
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ProcessInterestDetails>
ProcessInterestDetails:
*** <desc>Get the details of Interest Property </desc>

    IF PropertyId<PropPos> EQ InterestProperty THEN
        ActivityName = ProductLine:AA.Framework.Sep:"RATE.FIX":AA.Framework.Sep:InterestProperty
        ActivityRunDate = ''
        ActivityEffDate = ''
        IntRunDate = ''
        StopIntRunDate = ''
        StopIntProcess = ''
        BEGIN CASE
            CASE InterestInitType EQ "AUTO"
                AA.Framework.GetScheduledActivityDate(ArrangementId, ActivityName, "NEXT", ActivityRunDate, ActivityEffDate, RetErr)
            CASE InterestInitType EQ "MANUAL"
                AA.Framework.GetNextUserActivityDate(ArrangementId, ActivityName, ActivityRunDate, ActivityEffDate, ReturnError)
            CASE 1
                StopIntProcess = 1
        END CASE
        
        IF NOT(StopIntProcess) AND ActivityEffDate AND ActivityEffDate EQ CompletionDate THEN
            IntRunDate = ActivityRunDate
            IF InIntRunDate THEN
                InValue = InIntRunDate
                ActualValue = IntRunDate
                Operand = InterestDateOperand
                GOSUB CheckOperand  ;* Filter selections
                StopIntRunDate = StopFlag
            END
            Status<-1> = ActivityName
            Inititation<-1> = InterestInitType
            IntProcessFlag = 1
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
