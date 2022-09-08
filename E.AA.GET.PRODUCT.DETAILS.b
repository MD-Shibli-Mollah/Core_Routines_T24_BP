* @ValidationCode : MjotMzg0NDMwMTg0OkNwMTI1MjoxNjA1ODY0Njc0MzEyOnZrcHJhdGhpYmE6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjYzODozMTk=
* @ValidationInfo : Timestamp         : 20 Nov 2020 15:01:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 319/638 (50.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.PRODUCT.DETAILS(EnqData)
*-----------------------------------------------------------------------------
*<region name= subroutine Description>
*<desc>To Give the Purpose of the subroutine </desc>
*
* This routine will accept a Product Id and Currency and return the following details.
* Returns ProductGroup, ProductLine, CreditInterest and Debit Interest Properties and its respective interest types,
* interest rate and its Minimum & Maximum tier balance and Interest margin, Term Amount, Term, Charges with its Charge
* Amount and its frequency in Payment schedule, Overdraft Amount, NrAttributes having Amount, Minimum and Maximum Amount,
* Minimum Term and Maximum Term, Notict Period from Balance Availability condition and Product Descripion.
*
*
* For Example :
* Incoming are PRODUCT.ID EQ NEGOTIABLE.LOAN
*              CURRENCY   EQ USD
*
* @uses I_ENQUIRY.COMMON
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @author vkprathiba@temenos.com
*
*</region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
*
*  Incoming Argument
*
*  EnqData      - PRODUCT.ID - It will accept a Product ID
*
*  Outgoing Argument
*
*  EnqData      - Return the Enquiry data containing Product's Property condition details
*                 including Interest Condition, Charge and NrAttribute field values
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*
*  05/06/19 - Task  : 3170622
*             Enhan : 3170615
*             NoFile Enquiry to fetch Product details
* 28/08/20 - Task : 3936866
*            Enhanced the nofile enquiry with STATEMENT and FACILITY property details
*-----------------------------------------------------------------------------
** <region name = inserts>
    
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING AA.Interest
    $USING AA.TermAmount
    $USING AA.Fees
    $USING AA.Statement
    $USING AA.Facility
    $USING AA.PaymentSchedule
    $USING AA.BalanceAvailability
    $USING AA.Reporting
    $USING AA.ActivityCharges
    $USING AA.MarketingCatalogue
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Template
    $USING EB.API
    $USING ST.RateParameters
    $USING AC.SoftAccounting
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name = MainProcess>

    GOSUB Initialise                    ;* To initialise the required variables
    GOSUB GetProductDetails             ;* Get the Product information
      
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>To initialise the required variables</desc>
Initialise:
    
    ProductId = ''     ;* Arrangement Id
    CcyId = ''
    RProduct = ''
    PrdGroup = ''
    PrdDesc = ''
    TotCcy = ''
    FinalCcy = ''
    SingleCcy = ''
    RProductGroup = ''
    ProductLine =''
    OutPropertyClassList = ''
    RProductConditions = ''
    PropertyClass = ''
    RetErr = ''
    Err = ''
    prefLang =''
    GroupErr =''
    LineError =''
    RProductLine = ''
    PrdCoCode = ''
    availableFromDate = ''
    availableToDate = ''
    RProducts = ''
    
    LOCATE 'PRODUCT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING PrdPos THEN
        ProductId = EB.Reports.getEnqSelection()<4,PrdPos>          ;* Product Id
    END
    
    LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING PrdPos THEN
        CcyId = EB.Reports.getEnqSelection()<4,PrdPos>          ;* Product Id
    END
        
    prefLang = EB.SystemTables.getLngg()
    IF NOT(prefLang) THEN
        prefLang = 1
    END
    
    EffectiveDate =  EB.SystemTables.getToday()
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetProductDetails>
*** <desc>To get the product details</desc>
GetProductDetails:
    
    AA.ProductFramework.GetPublishedRecord('PRODUCT', "", ProductId, "", RProduct, "")    ;* fetch the published product record
    RProducts = AA.ProductManagement.Product.CacheRead(ProductId, ProductError)
    
    IF RProducts THEN
        availableFromDate = RProducts<AA.ProductManagement.Product.PdtCatAvailableDate>
        availableToDate = RProducts<AA.ProductManagement.Product.PdtCatExpiryDate>
    END

    IF RProduct THEN
        PrdGroup = RProduct<AA.ProductManagement.ProductDesigner.PrdProductGroup>  ;* Get the Product group of the incoming product
        
        TotCcy = RProduct<AA.ProductManagement.ProductDesigner.PrdCurrency>
        PrdDesc = RProduct<AA.ProductManagement.ProductDesigner.PrdDescription>
        PrdCoCode = RProduct<AA.ProductManagement.ProductDesigner.PrdCoCode>
        RProductGroup = AA.ProductFramework.ProductGroup.CacheRead(PrdGroup, GroupErr)
        IF NOT(GroupErr) THEN
            ProductLine = RProductGroup<AA.ProductFramework.ProductGroup.PgProductLine> ;* Get the Product line for the group
            ProductGroupDescription = RProductGroup<AA.ProductFramework.ProductGroup.PgDescription, prefLang>
        END
        RProductLine = AA.ProductFramework.ProductLine.CacheRead(ProductLine, LineError)
        IF NOT(LineError) THEN
            ProductLineDescription = RProductLine<AA.ProductFramework.ProductLine.PlDescription, prefLang>
        END
       
        BEGIN CASE
            
            CASE CcyId
                
                LOCATE CcyId IN TotCcy<1,1> SETTING CcyPos THEN
                    SingleCcy = 1
                    GOSUB GetDetailsProductCurrency
                    
                    EnqData = ProductId:'^':FinalCcy:'^':PrdGroup:'^':ProductLine:'^':OverdraftAmt:'^':NrMinAmt:'^':NrMaxAmt:'^':TermAmt:'^':NoticePeriod:'^':Term:'^':PrdDesc:'^':NrMinTerm:'^':NrMaxTerm:'^':ProductLineDescription:'^':ProductGroupDescription:'^':PrdCoCode:'^':availableFromDate:'^':availableToDate:'^':ScheduleId:'^':PaymentTypes:'^':PaymentMethod:'^':PaymentFrequency:'^':Property:'^':StartDate:'^':EndDate:'^':InterestId:'^':DayBasis:'^':Description:'^':FixedRate:'^':FloatingIndex:'^':PeriodicIndex:'^':PeriodType:'^':PeriodMethod:'^':PeriodReset:'^':MarginRate:'^':MarginOperand:'^':TierAmount:'^':ChargeId:'^':ChargeType:'^':FixedAmount:'^':TierType:'^':CalcType:'^':ChargeRate:'^':ChargeAmount:'^':TierMinCharge:'^':TierMaxCharge:'^':ChargeTierAmount:'^':FeeType:'^':AprTypes:'^':ExcludeProperties:'^':ChargeCurrency:'^':InterestType:'^':CompoundType:'^':CompoundYieldMethod:'^':ReportingId:'^':printOption:'^':printOptionPos:'^':facilityServices:'^':serviceAvailability:'^':defaultOption:'^':customerOptions:'^':serviceAvailabilityOptions:'^':RateTierType:'^':MarginType:'^':CommitmentId
                END ELSE
                    EnqData = ''
                END
            
            CASE 1
            
                GOSUB GetDetailsProductCurrency
                
                EnqData = ProductId:'^':FinalCcy:'^':PrdGroup:'^':ProductLine:'^':OverdraftAmt:'^':NrMinAmt:'^':NrMaxAmt:'^':TermAmt:'^':NoticePeriod:'^':Term:'^':PrdDesc:'^':NrMinTerm:'^':NrMaxTerm:'^':ProductLineDescription:'^':ProductGroupDescription:'^':PrdCoCode:'^':availableFromDate:'^':availableToDate:'^':ScheduleId:'^':PaymentTypes:'^':PaymentMethod:'^':PaymentFrequency:'^':Property:'^':StartDate:'^':EndDate:'^':InterestId:'^':DayBasis:'^':Description:'^':FixedRate:'^':FloatingIndex:'^':PeriodicIndex:'^':PeriodType:'^':PeriodMethod:'^':PeriodReset:'^':MarginRate:'^':MarginOperand:'^':TierAmount:'^':ChargeId:'^':ChargeType:'^':FixedAmount:'^':TierType:'^':CalcType:'^':ChargeRate:'^':ChargeAmount:'^':TierMinCharge:'^':TierMaxCharge:'^':ChargeTierAmount:'^':FeeType:'^':AprTypes:'^':ExcludeProperties:'^':ChargeCurrency:'^':InterestType:'^':CompoundType:'^':CompoundYieldMethod:'^':ReportingId:'^':printOption:'^':printOptionPos:'^':facilityServices:'^':serviceAvailability:'^':defaultOption:'^':customerOptions:'^':serviceAvailabilityOptions:'^':RateTierType:'^':MarginType:'^':CommitmentId
        END CASE
        
       
    END ELSE
        
        EnqData = ''
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetDetailsProductCurrency>
GetDetailsProductCurrency:
    
    IF SingleCcy THEN
        TotCcyPos = 1
    END ELSE
        TotCcyPos = DCOUNT(TotCcy, @VM)
    END
    
    GOSUB InitialiseVariable    ;* Initialise the local variables
            
    FOR CcyPos = 1 TO TotCcyPos
   
        AA.ProductFramework.GetProductConditionRecords(ProductId, TotCcy<1,CcyPos>, '', "", OutPropertyClassList, "", RProductConditions, RetErr)    ;* Get product condition record
        
        BEGIN CASE
            CASE CcyPos EQ 1
                FinalCcy<1,FinalCnt> = TotCcy<1,CcyPos>
            CASE 1      ;* Get the maximum of the interest/charge/schedule/reporting condition available
                TempPos = DCOUNT(FinalCcy<1>,@VM)+1
                FinalCnt = TempPos + MAXIMUM(DCOUNT(ScheduleId<1,CcyPos-1>,@SM):@FM:DCOUNT(InterestId<1,CcyPos-1>,@SM):@FM:DCOUNT(ChargeId<1,CcyPos-1>,@SM):@FM:DCOUNT(AprTypes<1,CcyPos-1>,@SM))
                FinalCcy<1,FinalCnt> = TotCcy<1,CcyPos>     ;* Append the next currency details after the first currency to have it aligned
        END CASE
        
        GOSUB GetPaymentScheduleDetails     ;* Fetch Payment schedule condition
        
        GOSUB GetInterestDetails            ;* Fetch Interest condition
        
        GOSUB GetActChargesDetails          ;* Fetch Activity Charges condition
        
        GOSUB GetChargeDetails              ;* Fetch Charge condition
       
        GOSUB GetTerm                       ;* Fetch Term amount condition
        
        GOSUB GetFacilityDetails            ;* Fetch Facility condition
        
        GOSUB GetStatementDetails           ;* Fetch Statement condition
        
        GOSUB GetReportingDetails           ;* Fetch Reporting condition
        
    NEXT CcyPos
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= InitialiseVariable>
*** <desc> Initialise the required variables </desc>
InitialiseVariable:
    
* Initialise Commitment related fields
    RTermAmount = ''
    Term = ''
    TermAmt = ''
    NrMinTerm = ''
    NrMaxTerm = ''
    RBalAvail = ''
    NoticePeriod = ''
    OverdraftAmt = ''
    CommitmentId = ''

* Initialise Schedule related fields
    ScheduleId = ''
    PaymentTypes = ''
    PaymentMethod = ''
    PaymentFrequency = ''
    Property = ''
    StartDate = ''
    EndDate = ''

* Initialise Interest related fields
    IntProperty = ''
    InterestId = ''
    DayBasis = ''
    Description = ''
    FixedRate = ''
    FloatingIndex = ''
    PeriodicIndex = ''
    PeriodType = ''
    PeriodMethod = ''
    PeriodReset = ''
    MarginRate = ''
    MarginOperand = ''
    TierAmount = ''
    TierNegativeRate = ''
    CompoundType = ''
    CompoundYieldMethod = ''
    InterestType = ''
    RateTierType = ''
    MarginType = ''

* Initialise Charge related fields
    ChargeId = ''
    ChargeType = ''
    FixedAmount = ''
    TierType = ''
    CalcType = ''
    ChargeRate = ''
    ChargeAmount = ''
    TierMinCharge = ''
    TierMaxCharge = ''
    ChargeTierAmount = ''
    FeeType = ''

* Initialise Reporting related fields
    ReportingId = ''
    AprTypes = ''
    ExcludeProperties = ''
    
* Initialise Facility related fields
    facilityServices = ''
    serviceAvailability = ''
    customerOption = ''
    defaultOption = ''
    serviceAvailabilityOptions = ''
    LookupId = ''
    
* Initialise Statement related fields
    printOption = ''
    printOptionPos = ''
    PrintingAttributeValue = ''
    
    FinalCnt = 1
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetInterestDetails>
*** <desc>Get the Interest Property Details </desc>
GetInterestDetails:
    
    PropertyClass = 'INTEREST'
    
    GOSUB GetProductProperty
    
    IntProperty = PropertyList
    
    TotIntProp = DCOUNT(IntProperty, @FM)      ;*Total number of interest property
 
    FOR IntCnt = 1 TO TotIntProp
         
        CurProperty = ''
        RInterest = ''
        CurProperty = IntProperty<IntCnt>
        
        IF CurProperty MATCHES ScheduledInterest THEN   ;* Get details for interest calculated from Cur Principal
            GOSUB GetInterestTypes      ;* Check if the interest is of type Debit/Credit
            GOSUB GetScheduledInterestDetails    ;* Get interest condition
        END
            
    NEXT IntCnt
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetProductProperty>
*** <desc>Get the Properties of the Product </desc>
GetProductProperty:
    
    PropertyList = ''
    AA.ProductFramework.GetPropertyName(RProduct, PropertyClass, PropertyList)    ;* Get all the interest property name
      
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetScheduledInterestDetails>
*** <desc>Get the Scheduled Interest details </desc>
GetScheduledInterestDetails:
    
    InProperty = CurProperty
    GOSUB GetForwardDatedCondition    ;* Check if the incoming property has forward dated condition
    
    IncrCnt = 0
    FwdDate = ''
    FwdPos = ''
    
    LOOP
        REMOVE FwdDate FROM ForwardDates SETTING FwdPos
    WHILE FwdDate:FwdPos
        TempDates = ScheduledIntDate    ;* Scheduled Interest dates including Forward dated
        GOSUB CheckDates    ;* Check if the current interest property is scheduled in the current incoming period
        
        IF ScheduledInterest<1,ReqPosition> EQ CurProperty THEN     ;* Get details only if the scheduled on this particular period
            IncrCnt++
            RInterest = ''
            RetErr = ''
            ConditionId = ''
            AA.ProductFramework.GetProductPropertyRecord('PROPERTY', '', ProductId, CurProperty, ConditionId, TotCcy<1,CcyPos>, RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>, FwdDate, RInterest, RetErr)
        
            TempRecord = ''
            TempRecord<-1> = ProductId:AA.Framework.Sep:CurProperty:AA.Framework.Sep:TotCcy<1,CcyPos>:AA.Framework.Sep:ForwardPeriods<IncrCnt>:AA.Framework.Sep:RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntDayBasis>
            RInterestBasis = ST.RateParameters.InterestBasis.CacheRead(RInterest<AA.Interest.Interest.IntDayBasis>, '')
            TempRecord<-1> = RInterestBasis<ST.RateParameters.InterestBasis.IbDescription,1>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntFixedRate>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntFloatingIndex>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntPeriodicIndex>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntPeriodicPeriodType>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntPeriodicMethod>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntPeriodicReset>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntMarginRate>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntMarginOper>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntTierAmount>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntTierNegativeRate>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntCompoundType>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntCompoundYieldMethod>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntRateTierType>
            TempRecord<-1> = RInterest<AA.Interest.Interest.IntMarginType>
            
            GOSUB CustomizeDelimiters       ;* Change the delimiters to support multi level hierarchy in T24
    
            InterestId<1,FinalCnt,IncrCnt> = TempRecord<1>
            DayBasis<1,FinalCnt,IncrCnt> = TempRecord<2>
            Description<1,FinalCnt,IncrCnt> = TempRecord<3>
            FixedRate<1,FinalCnt,IncrCnt> = TempRecord<4>
            FloatingIndex<1,FinalCnt,IncrCnt> = TempRecord<5>
            PeriodicIndex<1,FinalCnt,IncrCnt> = TempRecord<6>
            PeriodType<1,FinalCnt,IncrCnt> = TempRecord<7>
            PeriodMethod<1,FinalCnt,IncrCnt> = TempRecord<8>
            PeriodReset<1,FinalCnt,IncrCnt> = TempRecord<9>
            MarginRate<1,FinalCnt,IncrCnt> = TempRecord<10>
            MarginOperand<1,FinalCnt,IncrCnt> = TempRecord<11>
            TierAmount<1,FinalCnt,IncrCnt> = TempRecord<12>
            TierNegativeRate<1,FinalCnt,IncrCnt> = TempRecord<13>
            CompoundType<1,FinalCnt,IncrCnt> = TempRecord<14>
            CompoundYieldMethod<1,FinalCnt,IncrCnt> = TempRecord<15>
            InterestType<1,FinalCnt,IncrCnt> = SourceBalanceType
            RateTierType<1,FinalCnt,IncrCnt> = TempRecord<16>
            MarginType<1,FinalCnt,IncrCnt> = TempRecord<17>
            
        END
    
    REPEAT
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckDates>
*** <desc> Check if the current interest property is scheduled in the current incoming period </desc>
CheckDates:

* Get the date to check whether the current property is scheduled on the particular period
    
    ReqDate = ''
    ReqPosition = ''
    FOR DCnt = DCOUNT(TempDates<1>,@VM) TO 1 STEP-1
        
        IF FwdDate GE TempDates<1,DCnt> THEN    ;* From the dates available,fetch the date which applies to the current interest period date
            IF NOT(ReqDate) THEN
                ReqDate = TempDates<1,DCnt>
                ReqPosition = DCnt
            END ELSE
                IF TempDates<1,DCnt> GE ReqDate THEN
                    ReqDate = TempDates<1,DCnt>
                    ReqPosition = DCnt          ;* Fetch the date which is either the same date or after it
                END
            END
        END
    
    NEXT DCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetInterestTypes>
*** <desc> Check if the interest is of type Debit/Credit </desc>
GetInterestTypes:
    
    SourceType = ''
    TierSourceType =''
    ReadSource =''
    
    LOCATE CurProperty IN RProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1> SETTING CalcPropPos THEN
        RTempProduct = RProduct
        GOSUB GetCalculationSource      ;* Get the calculation source to find the type
    END ELSE
        IF NOT(RParentProduct) THEN
            RParentProduct = ''
            CalcPropPos = ''
            AA.ProductFramework.GetPublishedRecord('PRODUCT', '', RProduct<AA.ProductManagement.ProductDesigner.PrdParentProduct>, '', RParentProduct, '')    ;* fetch the published product record
        END
        LOCATE CurProperty IN RParentProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1> SETTING CalcPropPos THEN
            RTempProduct = RParentProduct
            GOSUB GetCalculationSource      ;* Get the calculation source to find the type
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetCalculationSource>
*** <desc> Get the Source balance type of the incoming interest property </desc>
GetCalculationSource:
    
    SourceType = RTempProduct<AA.ProductManagement.ProductDesigner.PrdSourceType, CalcPropPos> ;* get the source type for current interest property
    TierSourceType = RTempProduct<AA.ProductManagement.ProductDesigner.TierSourceType, CalcPropPos> ;* get the tier source type for current interest property
        
    IF TierSourceType THEN ;* if tier source type is specified then that will be considered , otherwise source type will be considered
        ReadSource = TierSourceType
        GOSUB GetSourceBalanceType
    END ELSE
        ReadSource = SourceType
        GOSUB GetSourceBalanceType
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetSourceBalanceType>
*** <desc> Fetch the balance type by reading AA.SOURCE.CALC.TYPE</desc>
GetSourceBalanceType:
    
    SourceCalcTypeRec = ''
    SourceBalanceType = ''
    RetError =''
    
    SourceCalcTypeRec = AA.Framework.SourceCalcType.CacheRead(ReadSource, RetError) ;* read AA.SOURCE.CALC.TYPE record
    SourceBalanceType = SourceCalcTypeRec<AA.Framework.SourceCalcType.SrcBalanceType> ;* get the balance type value

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetActChargesDetails>
*** <desc>Get the Activity Charges Property Details </desc>
GetActChargesDetails:

* Check for the Opening type of fees such as New Arrangement/disubursement fee
  
    RActCharges = ''
    PropertyClass = 'ACTIVITY.CHARGES'
    GOSUB GetProductProperty
    AcChgProperty = PropertyList
    
    RActCharges = ''
    ConditionId = ''
    RetErr = ''
    AA.ProductFramework.GetProductPropertyRecord("PROPERTY",'', ProductId, AcChgProperty, ConditionId, TotCcy<1,CcyPos>, EffectiveDate, '', RActCharges, RetErr)
            
    AdHocCharges = ''
    AdCnt = 0
    ActivityId = ''
    ActCharges = ''
    ActivityId = RActCharges<AA.ActivityCharges.ActivityCharges.ActChgActivityId>
    FOR ActCnt = 1 TO DCOUNT(ActivityId,@VM)
        IF FIELD(ActivityId<1,ActCnt>,AA.Framework.Sep,2) MATCHES 'NEW':@VM:'DISBURSE':@VM:'AUTO.DISBURSE' THEN
            ActCharges = RActCharges<AA.ActivityCharges.ActivityCharges.ActChgCharge,ActCnt>
            CHANGE @SM TO @VM IN ActCharges
            AdCnt = DCOUNT(AdHocCharges<1>,@VM)+1
            AdHocCharges<1,AdCnt> = ActCharges      ;* Add the opening charges
        END
    NEXT ActCnt
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetChargeDetails>
*** <desc>Get the Charge Property Details </desc>
GetChargeDetails:
    
    RSchedule = ''
    LOCATE 'PAYMENT.SCHEDULE' IN OutPropertyClassList<1> SETTING SchPos THEN
        RSchedule = RAISE(RProductConditions<SchPos>)
    END
    
    PropertyClass = 'CHARGE'
    
    GOSUB GetProductProperty
    
    ChgProperty = ''
    ChgProperty = PropertyList
    
    TotChgProp = DCOUNT(ChgProperty, @FM)
        
    FOR ChgCnt = 1 TO TotChgProp
        
        IF ChgProperty<ChgCnt> MATCHES AdHocCharges THEN    ;* Form charge condition only for adhoc charges because scheduled charge details are already formed at schedule processing
                      
            InProperty = ChgProperty<ChgCnt>
            GOSUB GetForwardDatedCondition    ;* Check if the incoming property has forward dated condition
            
            IncrCnt = DCOUNT(ChargeId<1>,@VM)   ;* Append the adhoc charges next to scheduled charge if any
            LOOP
                REMOVE FwdDate FROM ForwardDates SETTING FwdPos
                REMOVE FwdPeriod FROM ForwardPeriods SETTING PerPos
            WHILE FwdDate:FwdPos
                IncrCnt++
                RCharge = ''
                ConditionId = ''
                RetErr = ''
                AA.ProductFramework.GetProductPropertyRecord("PROPERTY",'', ProductId, ChgProperty<ChgCnt>, ConditionId, TotCcy<1,CcyPos>, RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>, FwdDate, RCharge, RetErr)
            
                TempRecord = ''
                TempRecord<-1> = ProductId:AA.Framework.Sep:ChgProperty<ChgCnt>:AA.Framework.Sep:TotCcy<1,CcyPos>:AA.Framework.Sep:FwdPeriod:AA.Framework.Sep:RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>
                TempRecord<-1> = RCharge<AA.Fees.Charge.ChargeType>
                TempRecord<-1> = RCharge<AA.Fees.Charge.FixedAmount>
                TempRecord<-1> = RCharge<AA.Fees.Charge.CalcTierType>
                TempRecord<-1> = RCharge<AA.Fees.Charge.CalcType>
                TempRecord<-1> = RCharge<AA.Fees.Charge.ChargeRate>
                TempRecord<-1> = RCharge<AA.Fees.Charge.ChgAmount>
                TempRecord<-1> = RCharge<AA.Fees.Charge.TierMinCharge>
                TempRecord<-1> = RCharge<AA.Fees.Charge.TierMaxCharge>
                TempRecord<-1> = RCharge<AA.Fees.Charge.TierAmount>
                TempRecord<-1> = RCharge<AA.Fees.Charge.Currency>
                TempRecord<-1> = 'Adhoc'
        
                GOSUB CustomizeDelimiters       ;* Change the delimiters to support multi level hierarchy in T24
    
                ChargeId<1,FinalCnt,IncrCnt> = TempRecord<1>
                ChargeType<1,FinalCnt,IncrCnt> = TempRecord<2>
                FixedAmount<1,FinalCnt,IncrCnt> = TempRecord<3>
                TierType<1,FinalCnt,IncrCnt> = TempRecord<4>
                CalcType<1,FinalCnt,IncrCnt> = TempRecord<5>
                ChargeRate<1,FinalCnt,IncrCnt> = TempRecord<6>
                ChargeAmount<1,FinalCnt,IncrCnt> = TempRecord<7>
                TierMinCharge<1,FinalCnt,IncrCnt> = TempRecord<8>
                TierMaxCharge<1,FinalCnt,IncrCnt> = TempRecord<9>
                ChargeTierAmount<1,FinalCnt,IncrCnt> = TempRecord<10>
                ChargeCurrency<1,FinalCnt,IncrCnt> = TempRecord<11>
                FeeType<1,FinalCnt,IncrCnt> = TempRecord<12>
            
            REPEAT
        END
    NEXT ChgCnt
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetTerm>
*** <desc>Get the Term Amount Property Details </desc>
GetTerm:
    
    NrAttribute = ''
    NrTerm = ''
    
    LOCATE 'TERM.AMOUNT' IN OutPropertyClassList<1> SETTING TerPos THEN
        RTermAmount = RAISE(RProductConditions<TerPos>)
        Term<1,FinalCnt> = RTermAmount<AA.TermAmount.TermAmount.AmtTerm>
        TermAmt<1,FinalCnt> = RTermAmount<AA.TermAmount.TermAmount.AmtAmount>
    END
        
    NrAttribute = RTermAmount<AA.TermAmount.TermAmount.AmtNrAttribute>
    
    LOCATE 'TERM' IN NrAttribute<1,1> SETTING NrPos THEN
        NrTerm<-1> = RTermAmount<AA.TermAmount.TermAmount.AmtNrType,NrPos>
    END
    
    LOCATE 'MINPERIOD' IN NrTerm<1,1,1> SETTING NtoPos THEN
        NrMinTerm<1,FinalCnt> = RTermAmount<AA.TermAmount.TermAmount.AmtNrValue,NrPos,NtoPos>
    END
    
    LOCATE 'MAXPERIOD' IN NrTerm<1,1,1> SETTING Nto1Pos THEN
        NrMaxTerm<1,FinalCnt> = RTermAmount<AA.TermAmount.TermAmount.AmtNrValue,NrPos,Nto1Pos>
    END
    
    NrPos = ''
    NtoPos = ''
    Nto1Pos = ''
    
    LOCATE 'AMOUNT' IN NrAttribute<1,1> SETTING NrPos THEN
        NrAmt<-1> = RTermAmount<AA.TermAmount.TermAmount.AmtNrType,NrPos>
    END
    
    LOCATE 'MINIMUM' IN NrAmt<1,1,1> SETTING NtoPos THEN
        NrMinAmt<1,FinalCnt> = RTermAmount<AA.TermAmount.TermAmount.AmtNrValue,NrPos,NtoPos>
    END
    
    LOCATE 'MAXIMUM' IN NrAmt<1,1,1> SETTING Nto1Pos THEN
        NrMaxAmt<1,FinalCnt> = RTermAmount<AA.TermAmount.TermAmount.AmtNrValue,NrPos,Nto1Pos>
    END
    
    LOCATE 'BALANCE.AVAILABILITY' IN OutPropertyClassList<1> SETTING BalPos THEN
        RBalAvail = RAISE(RProductConditions<BalPos>)   ;* Accounting condition record
        NoticePeriod<1,FinalCnt> = RBalAvail<AA.BalanceAvailability.BalanceAvailability.BaNoticePeriod>
    END
    
    PropertyClass = 'TERM.AMOUNT'
    GOSUB GetProductProperty
    CommitmentId<1,FinalCnt> = ProductId:AA.Framework.Sep:PropertyList:AA.Framework.Sep:TotCcy<1,CcyPos>:AA.Framework.Sep:'':AA.Framework.Sep:RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFacilityDetails>
*** <desc>Get the FACILITY Property Details </desc>
GetFacilityDetails:
    
    FacilityPos=''
    RFacility=''
    FieldPos=''
    ServiceFieldPos=''
    SsRec=''
    
    LOCATE 'FACILITY' IN OutPropertyClassList<1> SETTING FacilityPos THEN
        RFacility = RAISE(RProductConditions<FacilityPos>)
        IF ((RFacility) AND (FinalCnt =1 ))THEN
            facilityServices=RFacility<AA.Facility.Facility.facService> ;* Get facility services and the respective customerOptions.
            defaultOption=RFacility<AA.Facility.Facility.facCustomerOption>
            serviceAvailability=RFacility<AA.Facility.Facility.facServiceAvailability>
            EB.API.GetStandardSelectionDets("AA.PRD.DES.FACILITY", SsRec)
            
            LOCATE 'CUSTOMER.OPTION' IN SsRec<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING FieldPos THEN
                customerOptions=SsRec<EB.SystemTables.StandardSelection.SslSysValProg,FieldPos>
                customerOptions=FIELD(customerOptions,'&',2)
            END
            LOCATE 'SERVICE.AVAILABILITY' IN SsRec<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING ServiceFieldPos THEN
                serviceAvailabilityOptions=SsRec<EB.SystemTables.StandardSelection.SslSysValProg,ServiceFieldPos>
                serviceAvailabilityOptions=FIELD(serviceAvailabilityOptions,'&',2)
            END
        END
        CHANGE @VM TO @SM IN facilityServices
        CHANGE @VM TO @SM IN defaultOption
        CHANGE @VM TO @SM IN serviceAvailability
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetStatementDetails>
*** <desc>Get the STATEMENT Property Details </desc>
GetStatementDetails:
    
    printPos=''
    StatementPos=''
    LOCATE 'STATEMENT' IN OutPropertyClassList<1> SETTING StatementPos THEN
        RStatement = RAISE(RProductConditions<StatementPos>)
        IF ((RStatement) AND (FinalCnt=1)) THEN
            LOCATE 'Printing.Option' IN RStatement<AA.Statement.Statement.StaAttributeName,1> SETTING printPos THEN ;* Find out the 'printing.option' attribute
                printOption=RStatement<AA.Statement.Statement.StaAttributeValue,printPos>
                printOptionPos=printPos
                printingOption="Printing.Option"
                EB.Template.LookupList(printingOption) ;* Get lookup list for 'Printing.Option'
                LookupId=printingOption<2>
                printingAttributeValue=printingOption<11>
                
                IF facilityServices THEN
                    facilityServices=facilityServices:@SM:"Printing.Option" ;* Adding print option as part of facility services
                    printServicePos=DCOUNT(facilityServices,@SM)
                    FOR ServicePOS=2 TO printServicePos-1
                        customerOptions<1,1,ServicePOS>=customerOptions<1,1,1> ;* Adding customer option and service availability options for all facility services. Getting it from SS and repeating same for all facility services.
                        serviceAvailabilityOptions<1,1,ServicePOS>=serviceAvailabilityOptions<1,1,1>
                    NEXT ServicePOS
                    customerOptions<1,1,printServicePos>=printingAttributeValue
                END ELSE
                    facilityServices="Printing.Option" ;* Adding print option as part of facility services
                    customerOptions=printingAttributeValue
                END
                
            END
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetPaymentScheduleDetails>
*** <desc>Get the Payment Schedule Details </desc>
GetPaymentScheduleDetails:
   
    PropertyClass = 'PAYMENT.SCHEDULE'
    
    GOSUB GetProductProperty
    
    ScheduleProperty = PropertyList
    InProperty = ScheduleProperty
    
    GOSUB GetForwardDatedCondition    ;* Check if the incoming property has forward dated condition
    
    ScheduledInterest = ''
    ScheduledIntDate = ''
    ScheduledCharge = ''
    
    IncrCnt = 0
    LOOP
        REMOVE FwdDate FROM ForwardDates SETTING FwdPos     ;* Loop thro the dates to get the particular date's condition
    WHILE FwdDate:FwdPos
        IncrCnt++
        ConditionId = ''
        RSchedule = ''
        RetErr = ''
        AA.ProductFramework.GetProductPropertyRecord('PROPERTY', '', ProductId, ScheduleProperty, ConditionId, TotCcy<1,CcyPos>, RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>, FwdDate, RSchedule, RetErr)
        
        GOSUB GetPayments       ;* Get the Payment type's position to get the Interest/charge property
        
        TempRecord = ''
        TempRecord<-1> = ProductId:AA.Framework.Sep:ScheduleProperty:AA.Framework.Sep:TotCcy<1,CcyPos>:AA.Framework.Sep:ForwardPeriods<IncrCnt>:AA.Framework.Sep:RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>
        TempRecord<-1> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
        TempRecord<-1> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod>
        TempRecord<-1> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq>
        TempRecord<-1> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsProperty>
        TempRecord<-1> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsStartDate>
        TempRecord<-1> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsEndDate>
        
        GOSUB CustomizeDelimiters       ;* Change the delimiters to support multi level hierarchy in T24
 
*  Append the schedule details to the corresponding currency's effective date; FinalCnt denotes currency position; IncrCnt denotes the position of dates
        ScheduleId<1,FinalCnt,IncrCnt> = TempRecord<1>
        PaymentTypes<1,FinalCnt,IncrCnt> = TempRecord<2>
        PaymentMethod<1,FinalCnt,IncrCnt> = TempRecord<3>
        PaymentFrequency<1,FinalCnt,IncrCnt> = TempRecord<4>
        Property<1,FinalCnt,IncrCnt> = TempRecord<5>
        StartDate<1,FinalCnt,IncrCnt> = TempRecord<6>
        EndDate<1,FinalCnt,IncrCnt> = TempRecord<7>
            
        GOSUB GetScheduledInterest      ;* Check if the scheduled interest is calculated from the Principal Amount
        GOSUB GetScheduledCharge        ;* Check if any charge scheduled
            
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetForwardDatedCondition>
*** <desc> Get the Forward Dated condition for property </desc>
GetForwardDatedCondition:
    
    LOCATE InProperty IN RProduct<AA.ProductManagement.ProductDesigner.PrdProperty,1> SETTING PPos THEN
        ForwardDates = ''
        ForwardPeriods = ''
        HardForwardDates = ''
        RetErr = ''
        IF RProduct<AA.ProductManagement.ProductDesigner.PrdEffective,PPos,2> THEN
            AA.MarketingCatalogue.GetPropertyForwardDates(RProduct, ScheduleProperty, TotCcy<1,CcyPos>, '', ForwardDates, ForwardPeriods, HardForwardDates, RetErr)
        END
        INS RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate> BEFORE ForwardDates<1>
        INS '' BEFORE ForwardPeriods<1>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CustomizeDelimiters>
*** <desc> Change the delimiters to support multi level hierarchy in T24 </desc>
CustomizeDelimiters:
    
    Delimiter = '\'
    FOR TempCnt = 1 TO DCOUNT(TempRecord,@FM)
        
        IF CHANGE(TempRecord<TempCnt>,@VM,'') NE '' THEN    ;* Remove the markers, if there are null values
            CHANGE @VM TO ']' IN TempRecord<TempCnt>
        END ELSE
            TempRecord<TempCnt> = ''
        END
        
        IF CHANGE(TempRecord<TempCnt>,Delimiter,'') NE '' THEN      ;* Remove the markers, if there are null values
            CHANGE @SM TO Delimiter IN TempRecord<TempCnt>
        END ELSE
            TempRecord<TempCnt> = ''
        END
    
    NEXT TempCnt
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetPayments>
*** <desc> Get the Payment types </desc>
GetPayments:
    
    AllPaymentTypes = ''
    AllPaymentTypes = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
    SavePos = ''
    ChargePos = ''
    
    FOR PtCnt = 1 TO DCOUNT(AllPaymentTypes,@VM)
        IF DCOUNT(RSchedule<AA.PaymentSchedule.PaymentSchedule.PsProperty,PtCnt>,@SM) GT 1 THEN
            SavePos = PtCnt     ;* Save the Payment type position, if it has multiple property to get its respective interest details
        END ELSE
            Properties = ''
            PropertyClass = ''
            Properties = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsProperty,PtCnt>
            CHANGE @SM TO @VM IN Properties
            AA.ProductFramework.GetPropertyClass(Properties, PropertyClass)
            IF 'CHARGE' MATCHES PropertyClass THEN
                ChargePos = PtCnt       ;* Save the Payment type position, if the property belongs to Charge PC to append the frequency to the charge details
            END
        END
    NEXT PtCnt
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetScheduledInterest>
*** <desc> Check if the scheduled interest is calculated from the Principal Amount </desc>
GetScheduledInterest:

    TempProperty = ''
    TempProperty = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsProperty,SavePos>     ;* Get the property for the constant type alone
    CHANGE @SM TO @VM IN TempProperty
    PropertyClasses = ''
    AA.ProductFramework.GetPropertyClass(TempProperty, PropertyClasses)
    LOCATE 'INTEREST' IN PropertyClasses<1,1> SETTING IntPos THEN
        ScheduledInterest<1,IncrCnt> = TempProperty<1,IntPos>       ;* Save the interest along with dates
        ScheduledIntDate<1,IncrCnt> = ForwardDates<IncrCnt>
    END
    
    PropertyClass = 'ACCOUNT'
    GOSUB GetProductProperty
    AccProperty = PropertyList
    
* Check if the interest is calculated using the balance CurAccount
    Skip = 1
    LOCATE ScheduledInterest<1,IncrCnt> IN RProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1> SETTING ScrPos THEN
        RTempProduct = RProduct
        GOSUB CheckSourceBalance    ;* Check the Source balance
    END ELSE    ;* If property not located, then check in the Parent product
        IF NOT(RParentProduct) THEN
            RParentProduct = ''
            ScrPos = ''
            AA.ProductFramework.GetPublishedRecord('PRODUCT', '', RProduct<AA.ProductManagement.ProductDesigner.PrdParentProduct>, '', RParentProduct, '')    ;* fetch the published product record
        END
        LOCATE ScheduledInterest<1,IncrCnt> IN RParentProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1> SETTING ScrPos THEN
            RTempProduct = RParentProduct
            GOSUB CheckSourceBalance    ;* Check the Source balance
        END
    END
    
    IF Skip THEN    ;* If the current interest property isnt calculated from the Cur principal, then ignore
        ScheduledInterest<1,IncrCnt> = ''
    END
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckSourceBalance>
*** <desc> Check the source balance of the current property </desc>
CheckSourceBalance:
    
    CurAccount = 'CUR':AccProperty
    IF RTempProduct<AA.ProductManagement.ProductDesigner.PrdSourceBalance,ScrPos> EQ CurAccount THEN    ;* Check the balance type from the source balance
        Skip = 0
    END ELSE    ;* it can be a virtual balance, so read the respective balance type record to find the balances involved
        ErrMsg = ''
        RBalanceType = AC.SoftAccounting.BalanceType.Read(RTempProduct<AA.ProductManagement.ProductDesigner.PrdSourceBalance,ScrPos>, ErrMsg)
* IF RBalanceType<AC.SoftAccounting.BalanceType.BtReportingType> EQ 'VIRTUAL' THEN
        IF CurAccount MATCHES RBalanceType<AC.SoftAccounting.BalanceType.BtVirtualBal> THEN
            Skip = 0    ;* if the cur principal is part of the balance type, then dont skip the interest property
        END
* END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetScheduledCharge>
*** <desc> Check if any charge scheduled </desc>
GetScheduledCharge:
    
    IF ChargePos THEN       ;* If any charge scheduled, then expose the charge including the frequency
        ScheduledCharge<1,IncrCnt> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsProperty,ChargePos>
    
        RCharge = ''
        ConditionId = ''
        RetErr = ''
        AA.ProductFramework.GetProductPropertyRecord("PROPERTY",'', ProductId, ScheduledCharge<1,IncrCnt>, ConditionId, TotCcy<1,CcyPos>, RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>, ForwardDates<IncrCnt>, RCharge, RetErr)
            
        TempRecord = ''
        TempRecord<-1> = ProductId:AA.Framework.Sep:ScheduledCharge<1,IncrCnt>:AA.Framework.Sep:TotCcy<1,CcyPos>:AA.Framework.Sep:ForwardPeriods<IncrCnt>:AA.Framework.Sep:RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>
        TempRecord<-1> = RCharge<AA.Fees.Charge.ChargeType>
        TempRecord<-1> = RCharge<AA.Fees.Charge.FixedAmount>
        TempRecord<-1> = RCharge<AA.Fees.Charge.CalcTierType>
        TempRecord<-1> = RCharge<AA.Fees.Charge.CalcType>
        TempRecord<-1> = RCharge<AA.Fees.Charge.ChargeRate>
        TempRecord<-1> = RCharge<AA.Fees.Charge.ChgAmount>
        TempRecord<-1> = RCharge<AA.Fees.Charge.TierMinCharge>
        TempRecord<-1> = RCharge<AA.Fees.Charge.TierMaxCharge>
        TempRecord<-1> = RCharge<AA.Fees.Charge.TierAmount>
        TempRecord<-1> = RCharge<AA.Fees.Charge.Currency>
        TempRecord<-1> = 'Scheduled'
        
        GOSUB CustomizeDelimiters       ;* Change the delimiters to support multi level hierarchy in T24
    
        ChargeId<1,FinalCnt,IncrCnt> = TempRecord<1>
        ChargeType<1,FinalCnt,IncrCnt> = TempRecord<2>
        FixedAmount<1,FinalCnt,IncrCnt> = TempRecord<3>
        TierType<1,FinalCnt,IncrCnt> = TempRecord<4>
        CalcType<1,FinalCnt,IncrCnt> = TempRecord<5>
        ChargeRate<1,FinalCnt,IncrCnt> = TempRecord<6>
        ChargeAmount<1,FinalCnt,IncrCnt> = TempRecord<7>
        TierMinCharge<1,FinalCnt,IncrCnt> = TempRecord<8>
        TierMaxCharge<1,FinalCnt,IncrCnt> = TempRecord<9>
        ChargeTierAmount<1,FinalCnt,IncrCnt> = TempRecord<10>
        ChargeCurrency<1,FinalCnt,IncrCnt> = TempRecord<11>
        FeeType<1,FinalCnt,IncrCnt> = TempRecord<12>
            
    END
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetReportingDetails>
*** <desc>Get the Reporting Property Details </desc>
GetReportingDetails:

* Expose only Cashflow type of apr types for now

    LOCATE 'REPORTING' IN OutPropertyClassList<1> SETTING RepPos THEN
        RReporting = RAISE(RProductConditions<RepPos>)
    END
    
    TotAprTypes = ''
    TotAprTypes = RReporting<AA.Reporting.Reporting.RepAprType>     ;* Fetch the apr types if any
    RepCnt = 0
    
    FOR AprCnt = 1 TO DCOUNT(TotAprTypes<1>,@VM)    ;* Loop thro the apr type to get the cashflow one
        RAprType = ''
        Error = ''
        AprType = TotAprTypes<1,AprCnt>
        AA.Reporting.ReadAprType(AprType, RAprType, Error)
        IF RAprType<AA.Reporting.AprType.AtSourceType> EQ 'CASHFLOW' THEN   ;* If cashflow, then go for exclude properties if any
            RepCnt++
            AprTypes<1,FinalCnt,RepCnt> = AprType       ;* Add the cashflow apr types to it's respective currency
            TempExcludeProperties = ''
            IF DCOUNT(RReporting<AA.Reporting.Reporting.RepExcludeProperty,AprCnt>,@SM) THEN
                TempExcludeProperties = RReporting<AA.Reporting.Reporting.RepExcludeProperty,AprCnt>
                CHANGE @SM TO ']' IN TempExcludeProperties
                ExcludeProperties<1,FinalCnt,RepCnt> = TempExcludeProperties    ;* Add the exclude properties to it's respective currency
            END
        END
    NEXT AprCnt
    
    IF AprTypes THEN
        PropertyClass = 'REPORTING'
        GOSUB GetProductProperty
        ReportingId<1,FinalCnt> = ProductId:AA.Framework.Sep:PropertyList:AA.Framework.Sep:TotCcy<1,CcyPos>:AA.Framework.Sep:'':AA.Framework.Sep:RProduct<AA.ProductManagement.ProductDesigner.PrdEffectiveDate>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
