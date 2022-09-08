* @ValidationCode : MjotMTIxODMzNTQ2MTpDcDEyNTI6MTYwNzA3NDk4MTQzODp2a3ByYXRoaWJhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0Oi0xOi0x
* @ValidationInfo : Timestamp         : 04 Dec 2020 15:13:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.MS.PRODUCT.DETAILS(EnqData)
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
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Template
    $USING EB.API
    
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
    OverdraftAmt = ''
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
                    
                    EnqData = ProductId:'^':FinalCcy:'^':PrdGroup:'^':ProductLine:'^':CreditInterest:'^':CrInterestType:'^':CrInterestTierAmount:'^':CrInterestPercent:'^':CrInterestRate:'^':CrInterestMinimumBalance:'^':CrInterestMaximumBalance:'^':CrInterestMargin:'^':DebitInterest:'^':DrInterestType:'^':DrInterestTierAmount:'^':DrInterestPercent:'^':DrInterestRate:'^':DrInterestMinimumBalance:'^':DrInterestMaximumBalance:'^':DrInterestMargin:'^':OverdraftAmt:'^':NrMinAmt:'^':NrMaxAmt:'^':TermAmt:'^':NoticePeriod:'^':Term:'^':Fees:'^':FeeAmount:'^':FeeFrequency:'^':PrdDesc:'^':NrMinTerm:'^':NrMaxTerm:'^':ProductLineDescription:'^':ProductGroupDescription:'^':periodicIndex:'^':printOption:'^':printOptionPos:'^':LookupId:'^':printingAttributeValue:'^':facilityServices:'^':defaultOption:'^':serviceAvailability:'^':customerOptions:'^':serviceAvailabilityOptions:'^':PrdCoCode:'^':availableFromDate:'^':availableToDate
                END ELSE
                    EnqData = ''
                END
            
            CASE 1
            
                GOSUB GetDetailsProductCurrency
                
                EnqData = ProductId:'^':FinalCcy:'^':PrdGroup:'^':ProductLine:'^':CreditInterest:'^':CrInterestType:'^':CrInterestTierAmount:'^':CrInterestPercent:'^':CrInterestRate:'^':CrInterestMinimumBalance:'^':CrInterestMaximumBalance:'^':CrInterestMargin:'^':DebitInterest:'^':DrInterestType:'^':DrInterestTierAmount:'^':DrInterestPercent:'^':DrInterestRate:'^':DrInterestMinimumBalance:'^':DrInterestMaximumBalance:'^':DrInterestMargin:'^':OverdraftAmt:'^':NrMinAmt:'^':NrMaxAmt:'^':TermAmt:'^':NoticePeriod:'^':Term:'^':Fees:'^':FeeAmount:'^':FeeFrequency:'^':PrdDesc:'^':NrMinTerm:'^':NrMaxTerm:'^':ProductLineDescription:'^':ProductGroupDescription:'^':periodicIndex:'^':printOption:'^':printOptionPos:'^':LookupId:'^':printingAttributeValue:'^':facilityServices:'^':defaultOption:'^':serviceAvailability:'^':customerOptions:'^':serviceAvailabilityOptions:'^':PrdCoCode:'^':availableFromDate:'^':availableToDate
                
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
    
    IntProperty = ''
    CreditInterest = ''
    CrInterestType = ''
    CrInterestRate =''
    CrInterestMinimumBalance = ''
    CrInterestMaximumBalance = ''
    DebitInterest = ''
    DrInterestType = ''
    DrInterestRate =''
    DrInterestMinimumBalance = ''
    DrInterestMaximumBalance = ''
    CrInterestMargin = ''
    DrInterestMargin = ''
    CrCnt = ''
    
    ChgProperty = ''
    Fees = ''
    FeeFrequency = ''
    ChgCount = ''
    
    RTermAmount = ''
    Term = ''
    TerCnt = ''
    TermAmt = ''
    NrMinTerm = ''
    NrMaxTerm = ''
    RBalAvail = ''
    NoticePeriod = ''
    
    printOption=''
    printOptionPos=''
    facilityServices=''
    serviceAvailability=''
    customerOptions=''
    defaultOption=''
    serviceAvailabilityOptions=''
    LookupId=''
    PrintingAttributeValue=''
    periodicIndex=''
    FinalCnt = 1
    
    FOR CcyPos = 1 TO TotCcyPos
   
        AA.ProductFramework.GetProductConditionRecords(ProductId, TotCcy<1,CcyPos>, '', "", OutPropertyClassList, "", RProductConditions, RetErr)    ;* Get product condition record
        
        UseCnt = ''
        BEGIN CASE
            CASE CcyPos EQ 1
                FinalCcy<1,FinalCnt> = TotCcy<1,CcyPos>
            CASE 1
                IF TotIntProp GE TotChgProp THEN
                    UseCnt = TotIntProp
                END ELSE
                    UseCnt = TotChgProp
                END
                FinalCnt+= UseCnt
                FinalCcy<1,FinalCnt> = TotCcy<1,CcyPos>
        END CASE
    
        GOSUB GetInterestDetails
        
        GOSUB GetChargeDetails
       
        GOSUB GetTerm
        
        GOSUB GetFacilityDetails
        
        GOSUB GetStatementDetails
        
    NEXT CcyPos
    
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
        
        AA.ProductFramework.GetProductPropertyRecord("PROPERTY",'', ProductId, CurProperty,'', TotCcy<1,CcyPos>, '', '', RInterest, RetErr)
        
        periodicIndex<1,FinalCnt>=RInterest<AA.Interest.Interest.IntPeriodicIndex> ;* Get periodic index value
        
        GOSUB GetInterestTypes
            
        BEGIN CASE
            
            CASE SourceBalanceType EQ "CREDIT"
                CreditInterest<1,FinalCnt> = CurProperty
                CrInterestType<1,FinalCnt> = RInterest<AA.Interest.Interest.IntRateTierType>
                CrInterestMargin<1,FinalCnt> = MAXIMUM(RInterest<AA.Interest.Interest.IntMarginRate>)
            
                GOSUB UpdateTierTypeProperties
                
                CrInterestRate<1,FinalCnt> = SaveRate
                CrInterestTierAmount<1,FinalCnt> = SaveTierAmount
                CrInterestPercent<1,FinalCnt> = SavePercent
                CrInterestMinimumBalance<1,FinalCnt> = InterestMinimumBalance
                CrInterestMaximumBalance<1,FinalCnt> = InterestMaximumBalance
                
            CASE SourceBalanceType EQ "DEBIT"
                DebitInterest<1,FinalCnt> = CurProperty
                DrInterestType<1,FinalCnt> = RInterest<AA.Interest.Interest.IntRateTierType>
                DrInterestMargin<1,FinalCnt> = MINIMUM(RInterest<AA.Interest.Interest.IntMarginRate>)
                
                GOSUB UpdateTierTypeProperties
                
                DrInterestRate<1,FinalCnt> = SaveRate
                DrInterestTierAmount<1,FinalCnt> = SaveTierAmount
                DrInterestPercent<1,FinalCnt> = SavePercent
                DrInterestMinimumBalance<1,FinalCnt> = InterestMinimumBalance
                DrInterestMaximumBalance<1,FinalCnt> = InterestMaximumBalance
    
        END CASE
        
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
*** <region name= GetInterestTypes>
*** <desc>Get the Participant arrangement details </desc>
GetInterestTypes:
    
    SourceType = ''
    TierSourceType =''
    ReadSource =''
    
    LOCATE CurProperty IN RProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty, 1> SETTING CalcPropPos THEN

        SourceType = RProduct<AA.ProductManagement.ProductDesigner.PrdSourceType, CalcPropPos> ;* get the source type for current interest property
        TierSourceType = RProduct<AA.ProductManagement.ProductDesigner.TierSourceType, CalcPropPos> ;* get the tier source type for current interest property
        
        IF TierSourceType THEN ;* if tier source type is specified then that will be considered , otherwise source type will be considered
            ReadSource = TierSourceType
            GOSUB GetSourceBalanceType
        END ELSE
            ReadSource = SourceType
            GOSUB GetSourceBalanceType
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UpdateTierTypeProperties>
*** <desc>Update Credit/Debit Interest details </desc>
UpdateTierTypeProperties:
    
    InterestMinimumBalance = ''
    InterestMaximumBalance = ''
    SaveRate = ''
    SaveTierAmount = ''
    SavePercent = ''
    
    BEGIN CASE
        
        CASE RInterest<AA.Interest.Interest.IntRateTierType> MATCHES 'BAND':@VM:'LEVEL'
            
            IF RInterest<AA.Interest.Interest.IntFixedRate,1> THEN
                SaveRate = RInterest<AA.Interest.Interest.IntFixedRate>
                CHANGE @VM TO @SM IN SaveRate
            END
        
            IF RInterest<AA.Interest.Interest.IntTierAmount,1> THEN
                
                SaveTierAmount = RInterest<AA.Interest.Interest.IntTierAmount>
                CHANGE @VM TO @SM IN SaveTierAmount
                    
                InterestMinimumBalance = MINIMUM(RInterest<AA.Interest.Interest.IntTierAmount>)
                InterestMaximumBalance = MAXIMUM(RInterest<AA.Interest.Interest.IntTierAmount>)
                
            END ELSE
                IF RInterest<AA.Interest.Interest.IntTierPercent,1> THEN
                    SavePercent = RInterest<AA.Interest.Interest.IntTierPercent>
                    CHANGE @VM TO @SM IN SavePercent
                END
            END
            
        CASE 1
            
            SaveRate = RInterest<AA.Interest.Interest.IntFixedRate>
            
    END CASE
    
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
*** <region name= GetChargeDetails>
*** <desc>Get the Charge Property Details </desc>
GetChargeDetails:
    
    ChgCount = ''
    IF CcyPos EQ 1 THEN
    END ELSE
        ChgCount = FinalCnt-1
    END
    
    PropertyClass = 'CHARGE'
    
    GOSUB GetProductProperty
    
    ChgProperty = PropertyList
    
    TotChgProp = DCOUNT(ChgProperty, @FM)
    
    FOR ChgCnt = 1 TO TotChgProp
                
        RCharge = ''
        RSchedule = ''
        
        ChgCount+=1
            
        AA.ProductFramework.GetProductPropertyRecord("PROPERTY",'', ProductId, ChgProperty<ChgCnt>,'', TotCcy<1,CcyPos>, '', '', RCharge, RetErr)
        
        Fees<1,ChgCount> = ChgProperty<ChgCnt>
        FeeAmount<1,ChgCount> = RCharge<AA.Fees.Charge.FixedAmount>
        FeeType<1,ChgCount> = RCharge<AA.Fees.Charge.ChargeType>
        
        LOCATE 'PAYMENT.SCHEDULE' IN OutPropertyClassList<1> SETTING SchPos THEN
            RSchedule = RAISE(RProductConditions<SchPos>)
        END
        
        LOCATE ChgProperty<ChgCnt> IN RSchedule<AA.PaymentSchedule.PaymentSchedule.PsProperty,1> SETTING PsPos THEN
            FeeFrequency<1,ChgCount> = RSchedule<AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq,PsPos>
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
    
    TerCnt+=1
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
END
