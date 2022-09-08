* @ValidationCode : MjotMTE0Nzg1NDQ1NzpDcDEyNTI6MTYxMTc1MzY2OTg0NzpzamFyaW5hYmFudToxMjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3OjE3NzoxNzc=
* @ValidationInfo : Timestamp         : 27 Jan 2021 18:51:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sjarinabanu
* @ValidationInfo : Nb tests success  : 12
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 177/177 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Fees
SUBROUTINE AA.CALCULATE.BREAK.COST(ChargeProperty,PropertyRecord,BaseAmount,ChargeAmount)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
**This method returns the break cost/break gain during prepayment
* and the routine will be attached to the charge property.
* Formula for breakcost/gain calculations:
* (Early Repayment x Days till next reset date x Differential Rate) / Days in Year
*** </region>
*-----------------------------------------------------------------------------
* @access       : public
* @stereotype   : subroutine
* @author       : karthikeyankandasamy@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
*** Arguments
* Incoming arguments
* 1.   Charge property - Property name for charge property class
* 2.   Property record   - Property record of the charge property
* 3.   Base Amount     - Base amount
*
* Outgoing
* 4.    Charge amount - Calculated Charge amount
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
* 07/12/2020 - Enhancement -4113809
*              Task - 4113812
*              New method to calculate break cost/gain during prepayment of the loan
*
* 27/01/2021 - Defect - 4198585
*              Task   - 4198991
*              Fix for tafc compilation issue.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AA.Fees
    $USING AC.Fees
    $USING AA.Interest
    $USING AA.PeriodicCharges
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING MDLREF.ReferenceData
    $USING AF.Framework
    $USING AC.BalanceUpdates
    $USING AA.ProductManagement
    $USING AA.Account
    $USING AA.Rules
    $USING AA.PaymentSchedule
    $USING EB.API
    $USING AA.ChangeProduct
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc></desc>
    
    GOSUB Initialise
 
    GOSUB MainProcess

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initilaise the variables from local commons</desc>
Initialise:
*-----------

    ArrangementId = AA.Framework.getC_aalocarrid()      ;* Arrangement contract Id
    EffectiveDate = AA.Framework.getC_aalocactivityeffdate()      ;* Arrangement Activity effective date
    RArrProduct   = AA.Framework.getC_aalocproductrecord()  ;* Product Record
    ArrActivityId = AA.Framework.getC_aalocarractivityid() ;* Arrangementactivity id
    ArrValueDate  = AA.Framework.getC_aalocarrangementrec()<AA.Framework.Arrangement.ArrStartDate> ;* Arrangement value date
    ProductLine   = AA.Framework.getC_aalocarrangementrec()<AA.Framework.Arrangement.ArrProductLine> ;* Product line
    ArrMaturityDate  = AA.Framework.getC_aalocaccountdetails()<AA.PaymentSchedule.AccountDetails.AdMaturityDate> ;* Arrangement maturity date
    CurProperty   = AA.Framework.getC_aalocpropertyid() ;* Currrent property
    
    contractId = ''
    propertyClassId = ''
    DEFFUN AA.GET.PROPERTY.IDS(contractId,propertyClassId)
    ChargeAmount = 0
    CalcCharge = ''

    InterestProperty =''

    StartDayInclusive = ""
    EndDayInclusive = ""
         
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MainProcess>
*** <desc></desc>
MainProcess:

    IF EffectiveDate GT ArrValueDate AND EffectiveDate LT ArrMaturityDate THEN ;* Do not calculate the charges on arrangement date and after maturity date
        GOSUB LoadPropertyValue ;* Load the charge property values in variables
        GOSUB BuildInterestInfo ;* get the interest details and charge calculation flag
        GOSUB GetRollOverDate ;* get the rollover date
    END
    
    IF CalcCharge THEN ;* Calculate break cost only for periodic interest and if interest property is available
        GOSUB CalcChargeAmount ;* Calcualte break cost
    END
      
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalcChargeAmount>
*** <desc>Calculate the charge amount as Early Repayment x Days till next reset date x Differential Rate / Days in Year</desc>
CalcChargeAmount:
 
    GOSUB CalcEarlyRepayAmount ;* Calculate early repayment amount based on source amount and it should be always greater than zero!
    
    IF EarlyRepayAmount GT 0 THEN ;* Excess payment than the source balance!
        
        GOSUB CalcDaysTillNextReset   ;* Get interest reset days
        IF NoOfDays GT 0 THEN
            GOSUB CalcDiffRate ;*Calculate the differential rate of current period rate and period rate till next reset date
            GOSUB GetDaysInYear ;* Calculate Days In Year based on Int Day Basis
            ChargeAmount = (EarlyRepayAmount* NoOfDays* DiffRate)/DaysInYear ;* Calculate break gain/cost
        END
    
    END
 
    BEGIN CASE
        CASE PropertyTypeValue EQ 'DEBIT' AND ChargeAmount LT 0 ;* Its break gain should not collect the charge because charge is in negative
            ChargeAmount = 0
        CASE PropertyTypeValue EQ 'CREDIT' AND ChargeAmount GT 0 ;* Its break cost should not collect the charge because charge is in positive
            ChargeAmount = 0
        CASE 1
            ChargeAmount = ABS(ChargeAmount)
    END CASE

       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetProperty>
*** <desc>Get the property name </desc>
GetProperty:

    Property = AA.GET.PROPERTY.IDS(ArrangementId,PropertyClass) ;* get the property name
    Property = LOWER(LOWER(Property))

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildInterestInfo>
*** <desc>Get interest property, day basis and perodic interest values </desc>
BuildInterestInfo:
 
    PropertyClass = "ACCOUNT"
    GOSUB GetProperty
    AcProperty = Property

    PropertyClass = "INTEREST"
    GOSUB GetProperty
    InterestPropertyList = Property

    IntPropCnt = DCOUNT(InterestPropertyList, @VM)
   
    FOR IntPos = 1 TO IntPropCnt

        LOCATE InterestPropertyList<1,IntPos> IN RArrProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1>  SETTING PropPos THEN ;* Get the source details from the product
            BalanceName = RArrProduct<AA.ProductManagement.ProductCatalog.PrdSourceBalance,PropPos>  ;* Source Balance
            PropertyId = BalanceName[4,LEN(BalanceName)]
            IF PropertyId = AcProperty THEN ;* To decide its a pricipal interest property!!
                InterestProperty = InterestPropertyList<1,IntPos>
                GOSUB GetInterestDayBasis
                IntPos = IntPropCnt + 1 ;* To exit the loop
            END
        END
    
    NEXT IntPos
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetInterestDayBasis>
*** <desc>Get the interest record and interest day basis</desc>
GetInterestDayBasis:

    RetError = ''
    AA.Framework.GetArrangementConditions(ArrangementId, 'INTEREST', InterestProperty, EffectiveDate, '', RInterest, RecErr)
    RInterest = RAISE(RInterest)
    
    RfrConvention = RInterest<AA.Interest.Interest.IntRfrConvention>
    IF NOT(RfrConvention) AND RInterest<AA.Interest.Interest.IntPeriodicIndex> THEN ;* Do not calculate break fee for RFR convention
        CalcCharge = 'YES'
        IntDayBasis = RInterest<AA.Interest.Interest.IntDayBasis>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalcEarlyRepayAmount>
*** <desc>Calculate early repayment amount</desc>
CalcEarlyRepayAmount:
  
    RetErr = ''
    AA.ProductFramework.PropertyGetBalanceName(ArrangementId,AcProperty, 'CUR', "", "", PropertyBalance)
    AA.Framework.ProcessActivityBalances(ArrangementId, "GET",  "", ArrActivityId, AcProperty,PropertyBalance, EarlyRepayAmount,RetErr)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalcDaysTillNextReset>
*** <desc>get the next periodic reset date and calculate days till next reset</desc>
CalcDaysTillNextReset:
     
    GOSUB GetNextPeriodicResetDate ;*Get the next periodic reset date from aa scheduled activity
    
    IF NOT(NextResetDate) THEN ;* If next reset activity is not schedule get next schedule date from projection to calculate the charge!
        GOSUB GetNextCycleDate
        NextResetDate = NextCycleDate
    END
 
    IF NextResetDate GT ArrMaturityDate THEN ;* If next reset is GT arrangement maturity date, then calculate charge only till maturity date
        NextResetDate = ArrMaturityDate
    END

    GOSUB GetRestDays ;*Calculate no of days till next reset date
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetNextPeriodicResetDate>
*** <desc>get the next periodic reset date from aa scheduled activity</desc>
GetNextPeriodicResetDate:

    RetErr = ""
    ActivityRunDate = ""
    LiveActivity = ProductLine:AA.Framework.Sep:'PERIODIC.RESET':AA.Framework.Sep:InterestProperty;* Get the periodic activity
    AA.Framework.GetScheduledActivityDate(ArrangementId, LiveActivity, 'NEXT', ActivityRunDate, NextResetDate, RetErr)
  
    IF EffectiveDate GT NextResetDate AND RInterest<AA.Interest.Interest.IntPeriodicReset,1> THEN ;* Get the next cycle date when effective date is greater than next reset date
        GOSUB GetRestCycleDate
        NextResetDate = NextCycleDate
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetRestDays>
*** <desc>Calculate no of days till next reset date</desc>
GetRestDays:
   
    AC.Fees.BdCalcDays(EffectiveDate, NextResetDate, IntDayBasis, RestNoOfDays) ;* Calculate no of days till next reset
    NoOfDays = RestNoOfDays
    
    AccrualParamId = RInterest<AA.Interest.Interest.IntAccrualRule>
    AA.Interest.GetInterestAccrualParamDetails(AccrualParamId, StartDayInclusive, EndDayInclusive, "")
    
    IF NoOfDays AND StartDayInclusive EQ 'YES' AND EndDayInclusive EQ 'YES' THEN ;* When accrual rule is both, increase no of days by 1
        NoOfDays += 1
    END

RETURN
*** <region name= CalcDiffRate>
*-----------------------------------------------------------------------------
*** <desc>Calculate the differential rate of current period rate and period rate till next reset date</desc>
CalcDiffRate:

    PriorDays           = RInterest<AA.Interest.Interest.IntPriorDays>
    CurrentPeriodicRate = RInterest<AA.Interest.Interest.IntPeriodicRate,1>
    PeriodicIndex       = RInterest<AA.Interest.Interest.IntPeriodicIndex,1>
    PeriodicMethod      = RInterest<AA.Interest.Interest.IntPeriodicMethod,1>

    AF.Framework.setPropertyId(InterestProperty) ;* Set the interest property to get the source balance type
    
    IntRestPeriod = RestNoOfDays : "D"
    AA.Interest.GetInterestPeriodicRate(PeriodicIndex, "", EffectiveDate, PriorDays, IntRestPeriod, PeriodicMethod, PeriodicRate, "", "")

    AF.Framework.setPropertyId(CurProperty) ;* Reinstate the current property

    DiffRate = (CurrentPeriodicRate-PeriodicRate)/100
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetDaysInYear>
*** <desc>Calculate Days In Year based on Int Day Basis</desc>
GetDaysInYear:

    DayBasisRec = MDLREF.ReferenceData.getInterestDayBasisDetails(IntDayBasis)    ;* Read the Interest Basis Record
    DayBasis    = DayBasisRec<MDLREF.ReferenceData.InterestDayBasisDetails.interestBasis>
    DaysInYear  = DayBasis['/',2,1]
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= LoadtPropertyValue>
*** <desc>Load charge Property values</desc>
LoadPropertyValue:

    AA.Framework.LoadStaticData("F.AA.PROPERTY", ChargeProperty, AaProperty, "");*Load the property from AA.PROPERTY using AA.Framework.LoadStaticData
    PropertyType = AaProperty<AA.ProductFramework.Property.PropPropertyType>
           
    LOCATE "CREDIT" IN PropertyType<1,1> SETTING Pos THEN
        PropertyTypeValue = "CREDIT"
    END ELSE
        PropertyTypeValue = "DEBIT"
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetNextCycleDate>
*** <desc>If next reset activity is not scheduled, then get next schedule date from reset period to calculate the charge</desc>
GetNextCycleDate:

    GOSUB DeterminePeriod   ;* Get the rest period
    
    BEGIN CASE
        CASE RIGHT(RestPeriod,1) EQ 'M'
            AA.Framework.TransformDays(RestPeriod,"",ArrValueDate,Days,"")
        CASE RIGHT(RestPeriod,1) EQ 'D'
            Days =  FIELD(RestPeriod,'D',1)
    END CASE
    NextCycleDate = ArrValueDate
    EB.API.Cdt('',NextCycleDate,"+":Days:"C")
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DeterminePeriod>
*** <desc>Determine rest period</desc>
DeterminePeriod:

    PiInterestInfo = ""
    PiInterestInfo<1> = RInterest<AA.Interest.Interest.IntPeriodicPeriodType,1>
    PiInterestInfo<2> = RInterest<AA.Interest.Interest.IntInitialResetDate,1>
    PiInterestInfo<3> = RInterest<AA.Interest.Interest.IntPeriodicPeriod,1>
    PiInterestInfo<4> = RInterest<AA.Interest.Interest.IntPeriodicReset,1>
    PiInterestInfo<5> = RInterest<AA.Interest.Interest.IntDateConvention>
    PiInterestInfo<6> = RInterest<AA.Interest.Interest.IntPeriodicIndex,1>
    PiInterestInfo<7> = RInterest<AA.Interest.Interest.IntIdCompThr>
    PiInterestInfo<8> = EffectiveDate
              
    AA.Interest.DeterminePeriodicPeriod(PiInterestInfo, RestPeriod) ;* get the rest period
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
GetRestCycleDate:
   
    RetErr = ""
    RAccount = ""
    AA.ProductFramework.GetPropertyRecord("" , ArrangementId, "", EffectiveDate, "ACCOUNT", "", RAccount, RetErr)
    IF NOT(RetErr) THEN
        DateConvention = RAccount<AA.Account.Account.AcDateConvention>
        DateAdjustment = RAccount<AA.Account.Account.AcDateAdjustment>
        BusDayCentres  = RAccount<AA.Account.Account.AcBusDayCentres>
        BaseDateType = RAccount<AA.Account.Account.AcBaseDateType>
        BaseDateKey  = RAccount<AA.Account.Account.AcBaseDateKey>
    END
    
    PeriodicIndex       = RInterest<AA.Interest.Interest.IntPeriodicIndex,1>
    IntInitialResetDate = RInterest<AA.Interest.Interest.IntInitialResetDate,1>
    IntDateConvention   = RInterest<AA.Interest.Interest.IntDateConvention>
    IntPeriodicReset    = RInterest<AA.Interest.Interest.IntPeriodicReset,1>
            
    NextCycleDate = ""
    ActualNextCycleDate = ""
    AA.Interest.GetPeriodicRecalcDate(ArrangementId, EffectiveDate, 'CYCLE', PeriodicIndex, '', "", InterestProperty, IntInitialResetDate,IntPeriodicReset, IntDateConvention, DateConvention, DateAdjustment, BusDayCentres,BaseDateType, BaseDateKey, NextCycleDate, ActualNextCycleDate,RetErr)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetRollOverDate>
*** <desc> Get Rollover date of the arrangement</desc>
GetRollOverDate:

    LastRenewalDates   = AA.Framework.getC_aalocaccountdetails()<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
    LastRenewalDateCnt = DCOUNT(LastRenewalDates, @VM)
    LastRenewalDate    = LastRenewalDates<1,LastRenewalDateCnt>
   
    IF LastRenewalDate AND EffectiveDate EQ LastRenewalDate THEN ;* Break Fee should not be calculated on rollover date
        CalcCharge = ''
    END
  
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
