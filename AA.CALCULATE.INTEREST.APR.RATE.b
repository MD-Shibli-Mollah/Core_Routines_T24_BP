* @ValidationCode : MjoxNzAzMjMwNDE6Q3AxMjUyOjE2MDQ5OTgwMTM4Nzc6bm1hcnVuOjMzOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6MzQxOjM0MQ==
* @ValidationInfo : Timestamp         : 10 Nov 2020 14:16:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nmarun
* @ValidationInfo : Nb tests success  : 33
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 341/341 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Reporting
SUBROUTINE AA.CALCULATE.INTEREST.APR.RATE(ArrangementId, ActivityEffDate, ActivityLevel, AprType, LinkedIntProperty, AprRate)
*-----------------------------------------------------------------------------
* This local API will be attached in a AA.APR.TYPE record
* It will calculate the interest specific APR rates for the particular APR types passed
* based on this formula: APR = ((1+(R/N))^N)-1
* Always compound frequency will be consdired first, then PS frequency, then renewal date and finally maturity date.
* It assumes simple PS schedule definition for interest property alone without multiple start and end date and without num payments.
*
*-----------------------------------------------------------------------------
* @author aroopa@temenos.com
*-----------------------------------------------------------------------------
*** </region>
************************************************************************************
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* ArrangementId         - Arrangement for which APR is to be calculated
* ActivityEffDate       - Date on which current activity is executing
* ActivityLevel         - Whether activity is running at arrangement level or simulation level
* AprType               - Apr type for which rate has to be calculated.
* LinkedIntProperty     - Interest property corresponding apr type passed
*
* Output
*
* AprRate               - Interest rate based APR rate for the apr type passed.
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*
* 28/03/19 - Task  : 3048605
*            Enhan : 3048602
*            Local Api to calculate the interest Apr rate for the Apr type passed
*
* 17/04/19 - Task  : 3048694
*            Enhan : 3048686
*            Last day i.e, Renewal/Maturity Date not required to be taken for calculating term period
*            for Apr rate calculation
*
* 13/05/19 - Task  : 3126518
*            Enhan : 3125885
*            Value Date is used for getting arrangement start date instead of Contract date from Account details.
*            Fixed Calculation mismatch for takeover contracts
*
* 28/04/19 - Task  : 3107054
*            Enhan : 3107051
*            Banded interest APR calculation supported as part of CBS
*
* 09/10/20 - Task        - 3930713
*            Enhancement - 3930710
*            Get interest basis record using MDAL Reference data API
*
*-----------------------------------------------------------------------------

    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AC.Fees
    $USING ST.RateParameters
    $USING AA.Account
    $USING AA.Util
    $USING AA.ProductManagement
    $USING MDLREF.ReferenceData
    $USING EB.SystemTables
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    GOSUB Initialise
    GOSUB CheckTerm
    GOSUB CalculateApr

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise Variables</desc>
Initialise:
        
    RAccountDetails = ""
    PropertyDates = ""
    InterestRecords = ""
    RetError = ""
    CurInterestRecord = "" ;* record to be passed to band rate rotuine
    
    RArrangement = ""
    AA.Framework.GetArrangement(ArrangementId, RArrangement, RetError) ;* get the AA.ARRANGEMENT record
    
    OriginalContractDate = RArrangement<AA.Framework.Arrangement.ArrOrigContractDate> ;* get the date of contract creation in legacy
    
    CalculateAprFlag = 1
    
    PropertyClass = "INTEREST"
    PropertyId = LinkedIntProperty
    PropertyDates<1>= ActivityEffDate
    PropertyDates<2>= ActivityEffDate
    GOSUB BuildPropertyRecord ;* get the current interest condition
    CurrentInterestRecord = RAISE(RPropertyRecords)
    
    Product = RArrangement<AA.Framework.Arrangement.ArrActiveProduct> ;* get current product for the arrangement
    
    TierSetup = "" ;* flag to indicate it is band or level setup
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckTerm>
*** <desc> Check whether term or non term based contract</desc>
CheckTerm:
    
    AA.PaymentSchedule.ProcessAccountDetails(ArrangementId, "GET", "", RAccountDetails, RetError)      ;* Just load the record
 
    MaturityDate = RAccountDetails<AA.PaymentSchedule.AccountDetails.AdMaturityDate>  ;* get the maturity date of the contract
    RenewalDate  = RAccountDetails<AA.PaymentSchedule.AccountDetails.AdRenewalDate> ;* get the renewal date for the contract
    ContractDate = RAccountDetails<AA.PaymentSchedule.AccountDetails.AdValueDate> ;* get the date on which arrangement was created
    LastRenewalDate = RAccountDetails<AA.PaymentSchedule.AccountDetails.AdLastRenewDate> ;* get the date on which it was renewed last
    TotalRenewals = DCOUNT(LastRenewalDate,@VM)
    LastRenewalDate = RAccountDetails<AA.PaymentSchedule.AccountDetails.AdLastRenewDate,TotalRenewals>
    
    IF MaturityDate OR RenewalDate  THEN ;* if maturity or renewal date present then it is a term based contract
        TermBasedContract = 1
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateApr>
*** <desc> Do the APR calculation</desc>
CalculateApr:
    
    PropertyClass = "PAYMENT.SCHEDULE"
    PropertyId = ""
    GOSUB GetArrangementConditions ;* get the current payment schedule condition
    PaymentScheduleRecord = RAISE(Returnconditions)
    
    PropertyClass = "ACCOUNT"
    PropertyId = ""
    GOSUB GetArrangementConditions ;* get the current account condition
    AccountRecord = RAISE(Returnconditions)
        
    CompoundFrequency = CurrentInterestRecord<AA.Interest.Interest.IntCompoundType> ;* get the compound frequency
    CurrentInterestBasis = CurrentInterestRecord<AA.Interest.Interest.IntDayBasis> ;* get the interest day basis
    SaveEText = ""
    RIntBasis = ""
    SaveEText = EB.SystemTables.getEtext()     ;* Save EText Values to restore it later
    EB.SystemTables.setEtext("")  ;* set Error text to Null
    RIntBasis = MDLREF.ReferenceData.getInterestDayBasisDetails(CurrentInterestBasis)    ;* Read the Interest Basis Record
    EB.SystemTables.setEtext(SaveEText)     ;* Restore EText values after using MDAL API
    DaysInYear = FIELD(RIntBasis<MDLREF.ReferenceData.InterestDayBasisDetails.interestBasis>,"/",2) ;* days in a year based on day basis
    RateTierType = CurrentInterestRecord<AA.Interest.Interest.IntRateTierType> ;* get the tier type
    
    IF (RateTierType EQ "BAND" OR RateTierType EQ "LEVEL") THEN
        TierSetup = 1
    END
    
    TotPaymentType = DCOUNT(PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>,@VM) ;* loop through each payment type to locate the interest property
    PaymentTypeCnt = 1
    LOOP
    WHILE PaymentTypeCnt LE TotPaymentType
        LOCATE LinkedIntProperty IN PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsProperty, PaymentTypeCnt,1> SETTING DuePos THEN
            DueFrequency = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsDueFreq, PaymentTypeCnt, DuePos> ;* get the frequency for the interest property
            
            PsStartDate = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsStartDate, PaymentTypeCnt,1> ;* get the start date to be considered for this frequency
            formDate = PsStartDate
            GOSUB GetRelativeDate ;* convert to normal date in case relative date given
            PsStartDate = relativeEffDate
            
            PsEndDate = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsEndDate, PaymentTypeCnt,1> ;* get the end date to be considered for this frequency
            formDate = PsEndDate
            GOSUB GetRelativeDate ;* convert to normal date in case relative date given
            PsEndDate = relativeEffDate
            
        END
        PaymentTypeCnt = PaymentTypeCnt+1
    REPEAT
    
    GOSUB DetermineNValue ;* determine the n value to use for the calculation
    
    IF NVal THEN ;* calculation required only if n value is determined , otherwise APR will be same as contract rate
        
        IF NOT(TermBasedContract) THEN
            GOSUB NonTermCalculation ;* if it is not a term based contract then weighted method is not supported
        END ELSE
            GOSUB TermBasedCalculation ;* if it is a term based contract then weighted method is used
        END
    
        GOSUB CalculateInterestApr ;* calculate APR
        
    END ELSE
    
        IF TierSetup THEN
            GOSUB GetRateBandLevel
            AprRate = IntRate
        END ELSE
            AprRate = CurrentInterestRecord<AA.Interest.Interest.IntEffectiveRate>
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetRelativeDate>
*** <desc> Change the relative date to normal date</desc>
GetRelativeDate:
    
    relativeEffDate = ""
    AA.Util.GetArrangementRelativeDate(ArrangementId, formDate, RAccountDetails, RArrangement, Product, '', relativeEffDate, '')

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetArrangementConditions>
*** <desc> Fetch the current activity effective conditions for a property class</desc>
GetArrangementConditions:
    
    Returnconditions = ""
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass, PropertyId, ActivityEffDate, "", Returnconditions, RetError)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildPropertyRecord>
*** <desc> Get the condition record for a property</desc>
BuildPropertyRecord:
    
    RPropertyRecords = ""
    ContractId<1> = ArrangementId
    ContractId<2> = ActivityLevel
    AA.Framework.BuildPropertyRecords(ContractId, PropertyId, PropertyClass, PropertyDates, RPropertyRecords)
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= NonTermCalculation>
*** <desc> Do calculation for non term based contracts</desc>
NonTermCalculation:
    
    IF TierSetup THEN ;* for band/level interest we have to do take interest rate based on separate calculation
        CurInterestRecord = CurrentInterestRecord
        GOSUB GetBandedInterestRate
        InterestRate = BandInterestRate
    END ELSE
        InterestRate = CurrentInterestRecord<AA.Interest.Interest.IntEffectiveRate> ;* get the effective interest rate for the contract
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= TermBasedCalculation>
*** <desc> Do calculation for term based contracts</desc>
TermBasedCalculation:

** first get all the records for interest property that are present from last renewal date till maturity date or next renewal date
    IF LastRenewalDate THEN
        PropertyDates<1> = LastRenewalDate ;* fetch records from last renewal date if present
    END ELSE
        PropertyDates<1> = ContractDate ;* fetch records from contract date if renewal did not happen
    END

    IF RenewalDate THEN
        PropertyDates<2> = RenewalDate ;* fetch records till renewal date if present
    END ELSE
        PropertyDates<2> = MaturityDate ;* fetch records till maturity date if renewal is not supposed to happen
    END
    
    PropertyClass = "INTEREST"
    PropertyId = LinkedIntProperty
    GOSUB BuildPropertyRecord ;* go ahead and get the condition records
    InterestRecords =  RPropertyRecords
    
    TotIntDates = DCOUNT(PropertyDates,@FM) ;* count the number of dates for interest property
    
    SumRateForDays = ""
    BEGIN CASE
        CASE TotIntDates GT "1"  ;* weigted rate to be taken for multiple dates
            GOSUB CalculateForMultipleDates
       
        CASE TotIntDates EQ "1" AND NOT(OriginalContractDate)
        
            IF TierSetup THEN ;* for band/level interest we have to do take interest rate based on separate calculation
                CurInterestRecord = CurrentInterestRecord
                GOSUB GetBandedInterestRate
                InterestRate = BandInterestRate
            END ELSE
                InterestRate = CurrentInterestRecord<AA.Interest.Interest.IntEffectiveRate> ;* for single interest record just take current rate
            END
        
        CASE TotIntDates EQ "1" AND OriginalContractDate ;* case of takeover activity
            GOSUB CalculateForSingleDateTakeover
        
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DetermineNValue>
*** <desc> Determine the n value for different compound frequencies</desc>
DetermineCompoundFrequencyNValue:
    
    BEGIN CASE
        CASE CompoundFrequency EQ "DAILY"
            NVal = DaysInYear
        CASE CompoundFrequency[1,4] EQ "WEEK"
            NVal = "52"/CompoundFrequency[5,1]
        CASE CompoundFrequency[1,1] EQ "M"
            NVal = "12"/CompoundFrequency[2,2]
        CASE CompoundFrequency EQ "TWMTH"
            NVal = "24"
        CASE CompoundFrequency[1,1] EQ "N"
            NVal = CompoundFrequency[2,3]
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DeterminePSFrequencyNValue>
*** <desc> Determine the n value when due frequency/start date/end date is available</desc>
DeterminePSFrequencyNValue:
    
    BEGIN CASE
        
        CASE PsStartDate AND PsEndDate AND (ActivityEffDate GE PsStartDate AND ActivityEffDate LE PsEndDate) ;* ok activity falls inbetween start and end dates , take the frequency
            GOSUB UseDueFrequency
            
        CASE PsStartDate AND ActivityEffDate GE PsStartDate ;* ok activity falls on or after start date , take the frequency
            GOSUB UseDueFrequency
            
        CASE PsStartDate AND ActivityEffDate LT PsStartDate ;* activity falls before start date, take n value based on start date period
            IF OriginalContractDate THEN ;* for takeover contracts we need the full period from original contract date
                StartDate = OriginalContractDate
            END ELSE
                StartDate = ContractDate
            END
            EndDate = PsStartDate
            GOSUB CalculateDaysDifference
            NVal = DaysInYear/DaysDifference ;* n value will be number of days in a year divided by the days difference
            
        CASE PsEndDate AND ActivityEffDate GT PsEndDate ;* activity falls after end date, do not take n value based on PS
    
        CASE (NOT(PsStartDate) AND NOT(PsEndDate)) OR (PsEndDate AND ActivityEffDate LE PsEndDate)  ;* if start and end dates not given then just use the frequency
            GOSUB UseDueFrequency
        
    END CASE
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UseDueFrequency>
*** <desc> Determine the n value using due frequency itself</desc>
UseDueFrequency:
    
    BEGIN CASE
        CASE FIELD(DueFrequency,' ',1)[2,1] NE '0'
            YearsInDays = FIELD(DueFrequency,' ',1)[2,1]*DaysInYear
            NVal = DaysInYear/FIELD(DueFrequency,' ',1)[2,1]
        CASE FIELD(DueFrequency,' ',1)[2,1] EQ '0' AND FIELD(DueFrequency,' ',2)[2,1] NE '0'
            NVal = "12"/FIELD(DueFrequency,' ',2)[2,1]
        CASE FIELD(DueFrequency,' ',1)[2,1] EQ '0' AND FIELD(DueFrequency,' ',2)[2,1] EQ '0' AND FIELD(DueFrequency,' ',3)[2,1] NE '0'
            NVal = "52"/FIELD(DueFrequency,' ',3)[2,1]
        CASE FIELD(DueFrequency,' ',1)[2,1] EQ '0' AND FIELD(DueFrequency,' ',2)[2,1] EQ '0' AND FIELD(DueFrequency,' ',3)[2,1] EQ '0' AND FIELD(DueFrequency,' ',4)[2,1] NE '0'
            NVal = DaysInYear/FIELD(DueFrequency,' ',4)[2,1]
        CASE FIELD(DueFrequency,' ',1)[2,1] EQ '0' AND FIELD(DueFrequency,' ',2)[2,1] EQ '0' AND FIELD(DueFrequency,' ',3)[2,1] EQ '0' AND FIELD(DueFrequency,' ',4)[2,1] EQ '0' AND FIELD(DueFrequency,' ',5)[2,1] NE '0'
            GOSUB DetermineSpecialPSFrequencyNValue
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DetermineRenewalDateNValue>
*** <desc> Determine the n value when maturity date is given</desc>
DetermineRenewalDateNValue:
    
    IF OriginalContractDate THEN ;* for takeover contracts we need the full term from original contract date
        StartDate = OriginalContractDate
    END ELSE
        StartDate = ContractDate
    END
    EndDate = RenewalDate
    GOSUB CalculateDaysDifference ;*get the number of days between current activity effective date and renewal date based on day basis
    
    NVal = DaysInYear/DaysDifference ;* n value will be number of days in a year divided by the days difference

RETURN
*** </region>
*-----------------------------------------------------------------------------
DetermineMaturityDateNValue:

    IF OriginalContractDate THEN ;* for takeover contracts we need the full term from original contract date
        StartDate = OriginalContractDate
    END ELSE
        StartDate = ContractDate
    END
    EndDate = MaturityDate
        
    GOSUB CalculateDaysDifference ;*get the number of days between current activity effective date and maturity date based on day basis
    
    NVal = DaysInYear/DaysDifference ;* n value will be number of days in a year divided by the days difference

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DetermineSpecialPSFrequencyNValue>
*** <desc> Determine the n value when special PS frequency is given</desc>
DetermineSpecialPSFrequencyNValue:
    
    BEGIN CASE
        CASE FIELD(DueFrequency,' ',5)[2,5] EQ 'LQUAT'
            NVal = "4"
        CASE FIELD(DueFrequency,' ',5)[2,5] EQ 'LYEAR'
            NVal = "1"
        CASE FIELD(DueFrequency,' ',5)[2,5] EQ 'LHFYR'
            NVal = "2"
        CASE FIELD(DueFrequency,' ',5)[2,5] EQ 'LMNTH'
            NVal = "12"
        CASE FIELD(DueFrequency,' ',5)[2,5] EQ 'LWEEK'
            NVal = "52"
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateInterestApr>
*** <desc> Do the APR calculation using the determined N value</desc>
CalculateInterestApr:
    
    IF NVal THEN
        AprRateDecimal = ((1+InterestRate/(100*NVal))^NVal)-1 ;*Apply the APR calculation formula and return the APR for corresponding Apr type
        AprRate = AprRateDecimal*100
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateDaysDifference>
*** <desc> Get the difference between two dates based on interest day basis</desc>
CalculateDaysDifference:
    
    DaysDifference = ""
    AC.Fees.BdCalcDays(StartDate, EndDate, CurrentInterestBasis, DaysDifference) ;*get the number of days between two dates based on day basis
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateInterestRateFromApr>
*** <desc> Do the contract rate calculation from a given APR</desc>
CalculateInterestRateFromApr:
    
    IF NVal THEN
        IntRateFromApr = ((1+(LegacyAPR/100))^(1/NVal)-1)*NVal*100 ;* get the interest rate from APR calculated in legacy
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= DetermineNValue>
*** <desc> Determine the n value based on various parameters</desc>
DetermineNValue:

** compound frequency has the highest preference followed by due frequency, renewal date and then maturity date
    YearsInDays = ""
    NVal = ""
    BEGIN CASE
        CASE CompoundFrequency
            GOSUB DetermineCompoundFrequencyNValue
        CASE DueFrequency OR PsStartDate OR PsEndDate
            GOSUB DeterminePSFrequencyNValue
        CASE RenewalDate
            GOSUB DetermineRenewalDateNValue
        CASE MaturityDate
            GOSUB DetermineMaturityDateNValue
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= CalculateLegacyRateForDays>
*** <desc> Calculate the contract rate for days in legacy</desc>
CalculateLegacyRateForDays:
    
    LOCATE AprType IN AccountRecord<AA.Account.Account.AcAprType,1> SETTING AprPos THEN
        LegacyAPR = AccountRecord<AA.Account.Account.AcAprRate,AprPos> ;* get the legacy apr rate for current apr type which would be given by user
    END
            
    GOSUB CalculateInterestRateFromApr ;* get the legacy interest rate from the APR
            
    StartDate = OriginalContractDate
    EndDate = ContractDate
            
    GOSUB CalculateDaysDifference ;* get the days for which contract was in legacy
            
    LegacyRateForDays = IntRateFromApr*DaysDifference ;* ;* multiple this rate with number of days between legacy contract date and t24 contract date for calculating weighted rate
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= CalculateForMultipleDates>
*** <desc> Calculate the weighted interest rate for multiple property dates</desc>
CalculateForMultipleDates:
    
    FOR IntDateCnt = TotIntDates TO 1 STEP -1
        
        CurTierType = ''
        StartDate = PropertyDates<IntDateCnt> ;* current date set as start date
        IF IntDateCnt EQ 1 THEN ;* when we reach the last date , we have to take next date as maturity or renewal date
            IF RenewalDate THEN
                EndDate = RenewalDate
            END ELSE
                EndDate = MaturityDate
            END
        END ELSE
            EndDate = PropertyDates<IntDateCnt-1> ;* next date set as end date
        END
            
        CurIntRecord = RAISE(InterestRecords<IntDateCnt>) ;* get the current date's interest record
        IF CurIntRecord THEN
            CurTierType = CurIntRecord<AA.Interest.Interest.IntRateTierType> ;* Get the effective date's interest tier type
            IF CurTierType EQ "BAND" OR CurTierType EQ "LEVEL" THEN ;* for band/level interest we have to do take interest rate based on separate calculation
                CurInterestRecord = CurIntRecord
                GOSUB GetBandedInterestRate
                CurrentIntRate = BandInterestRate
            END ELSE
                CurrentIntRate = CurIntRecord<AA.Interest.Interest.IntEffectiveRate> ;* this is the rate on the current date
            END
            GOSUB CalculateDaysDifference ;* get the difference in days between current date and next date
      
            RateForDays = CurrentIntRate*DaysDifference ;* multiple this rate with number of days between current and next date for calculating weighted rate
        
            SumRateForDays = SumRateForDays + RateForDays ;* add the above to this array to use this array later to get weighted rate
            TotalDays = TotalDays + DaysDifference ;* save total number of days as well
        END
        
    NEXT IntDateCnt
    
    IF OriginalContractDate THEN ;* if original contract date present, it is a takeover contract ,hence legacy interest rate to be calculated from APR
            
        GOSUB CalculateLegacyRateForDays
            
        SumRateForDays = SumRateForDays+LegacyRateForDays ;* add the above value to array already calculated
        TotalDays = TotalDays + DaysDifference ;* add the days difference as well
    END
    
    IF TotalDays THEN
        WeigtedInterestRate =  SumRateForDays/TotalDays ;* calculate the weigted interest rate
    END
    InterestRate = WeigtedInterestRate ;* take this new rate as interest rate R to calculate APR
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= CalculateForSingleDateTakeover>
*** <desc> Calculate the weighted interest rate for takeover activity</desc>
CalculateForSingleDateTakeover:
    
    GOSUB CalculateLegacyRateForDays ;* calculate the legacy contract rate from legacy APR
    TotalDays = TotalDays + DaysDifference  ;* add the days difference as well
    SumRateForDays = SumRateForDays+LegacyRateForDays ;* add the above value to array already calculated
            
    StartDate = PropertyDates
    IF RenewalDate THEN
        EndDate = RenewalDate
    END ELSE
        EndDate = MaturityDate
    END
            
    GOSUB CalculateDaysDifference ;* calculate days difference between current property date and renewal or maturity date
    
    IF TierSetup THEN ;* for band/level interest we have to do take interest rate based on separate calculation
        CurInterestRecord = CurrentInterestRecord
        GOSUB GetBandedInterestRate
        RateForDays = BandInterestRate*DaysDifference
    END ELSE
        RateForDays = CurrentInterestRecord<AA.Interest.Interest.IntEffectiveRate>*DaysDifference
    END

    SumRateForDays = SumRateForDays+RateForDays
    TotalDays = TotalDays + DaysDifference  ;* add the days difference as well
            
    IF TotalDays THEN
        WeigtedInterestRate =  SumRateForDays/TotalDays ;* calculate the weigted interest rate
    END
    InterestRate = WeigtedInterestRate ;* take this new rate as interest rate R to calculate APR
            
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= GetBandedInterestRate>
*** <desc> For banded/level interest rate we have to call separate routine to calculate the current effective interest rate</desc>
GetBandedInterestRate:
    
    BandInterestRate = ""
    AA.Reporting.CalculateBandedInterestRate(ArrangementId, Product, ActivityEffDate, CurInterestRecord, LinkedIntProperty, BandInterestRate)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetRateBandLevel>
*** <desc> Fetch the interest rate for band or level setup </desc>
GetRateBandLevel:
    
    AA.ProductFramework.GetPublishedRecord('PRODUCT', "", Product, "", RProduct, "") ;* fetch the published product record

    SourceBalanceType = ""
    SourceType = ''
    TierSourceType = ''
    IntRate =''
    
    LOCATE LinkedIntProperty IN RProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty, 1> SETTING CalcPropPos THEN

        SourceType = RProduct<AA.ProductManagement.ProductDesigner.PrdSourceType, CalcPropPos> ;* get the source type for current interest property
        TierSourceType = RProduct<AA.ProductManagement.ProductDesigner.TierSourceType, CalcPropPos> ;* get the tier source type for current interest property
    END

    IF TierSourceType THEN ;* if tier source type is specified then that will be considered , otherwise source type will be considered
        ReadSource = TierSourceType
        GOSUB GetSourceBalanceType
    END ELSE
        ReadSource = SourceType
        GOSUB GetSourceBalanceType
    END

    BEGIN CASE
        CASE SourceBalanceType EQ "CREDIT"
            IntRate = MAXIMUM(CurrentInterestRecord<AA.Interest.Interest.IntEffectiveRate>) ;* take maximum of all tier effective rates if source balance type is credit

        CASE SourceBalanceType EQ "DEBIT"
            IntRate = MINIMUM(CurrentInterestRecord<AA.Interest.Interest.IntEffectiveRate>) ;* take minimum of all tier effective rates if source balance type is debit
    END CASE
            
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetSourceBalanceType>
*** <desc> Fetch the balance type by reading AA.SOURCE.CALC.TYPE</desc>
GetSourceBalanceType:
    
    SourceCalcTypeRec = ''
    SourceCalcTypeRec = AA.Framework.SourceCalcType.CacheRead(ReadSource, RetError) ;* read AA.SOURCE.CALC.TYPE record
    SourceBalanceType = SourceCalcTypeRec<AA.Framework.SourceCalcType.SrcBalanceType> ;* get the balance type value

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
