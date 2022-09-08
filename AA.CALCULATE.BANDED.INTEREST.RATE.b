* @ValidationCode : MjoxMDE5OTU2OTQzOkNwMTI1MjoxNTU4OTQwNTE0MzU2OnZrcHJhdGhpYmE6MTE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDQuMjAxOTA0MTAtMDIzOToxMDg6MTA4
* @ValidationInfo : Timestamp         : 27 May 2019 12:31:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 108/108 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Reporting
SUBROUTINE AA.CALCULATE.BANDED.INTEREST.RATE(ArrangementId, Product, ActivityEffDate, InterestCondition, IntProperty, WeightedIntRate)
*-----------------------------------------------------------------------------
* This routine assumes that the incoming interest condition has band or level setup and will calculate weighted interest rate for this setup.
* The balance will be considered as the commitment amount given in term amount condition for lending and deposits.
* Band calculation:
* Interest rate taken separately first for each band for the balance that applies for that band.
* Then weighted average for these interest rates will be taken as final weighted rate.
* For Accounts we need to check what is the source type attached for this interest property in product designer.
* For this source type if balance type is credit, then the maximum rate out of the band effective rates will be taken
* and returned.For this source type if balance type is debit,
* then the minimum rate out of the band effective rates will be taken and returned.
* Level calculation:
* It will be checked in which level the commitment amount falls and the corresponding effective rate
* will be returned directly.
* For Accounts the calculation is same as band calculation.
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
* ArrangementId         - current processing arrangement id
* ActivityEffDate       - Date on which current activity is executing
* InterestCondition     - current interest condition having band or level setup
* IntProperty           - interest property for which interest condition passed is applicable
*
* Output
*
* WeightedIntRate       - Weighted interest rate for banded or level setup
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*
* 28/04/19 - Task  : 3117293
*            Enhan : 3107051
*            Calculate the weighted interest rate for band/level interest condition passed
*
* 22/05/19 - Task  : 3142114
*            Enhan : 3107051
*            Calculate the weighted interest rate for band/level interest condition using the Source/TierSourceType
*            if term amount is null
*
* 23/05/19 - Task  : 3145561
*            Enhan : 3107051
*            For Level Setup, if the Committment amt doesnt fall under any level, last tier rate will be taken for calculation
*-----------------------------------------------------------------------------

    $USING AA.Interest
    $USING AA.Framework
    $USING AA.TermAmount
    $USING AA.ProductFramework
    $USING AA.ProductManagement

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    GOSUB Initialise
    GOSUB CalculateWeightedInterest

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise Variables</desc>
Initialise:

    TermAmountRecord = ""
    RetError = ""
    SumRateForBands = ""
    RProduct = ""

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateWeightedInterest>
*** <desc> Do the weighted interest rate calculation</desc>
CalculateWeightedInterest:

    RateTierType = InterestCondition<AA.Interest.Interest.IntRateTierType> ;* get the tier type
    TierRates = InterestCondition<AA.Interest.Interest.IntEffectiveRate> ;* get all effective rates to determine number of bands
    
    GOSUB GetTermAmount     ;* Get the Term amount Condition Record
    
    IF RateTierType EQ "BAND" THEN
        GOSUB CalculateWeightedInterestBand
    END ELSE
        GOSUB CalculateWeightedInterestLevel
    END

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
*** <region name= GetSourceBalanceType>
*** <desc> Fetch the balance type by reading AA.SOURCE.CALC.TYPE</desc>
GetSourceBalanceType:

    SourceCalcTypeRec = AA.Framework.SourceCalcType.CacheRead(ReadSource, RetError) ;* read AA.SOURCE.CALC.TYPE record
    SourceBalanceType = SourceCalcTypeRec<AA.Framework.SourceCalcType.SrcBalanceType> ;* get the balance type value

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateWeightedInterestBand>
*** <desc> Do the weighted interest rate calculation for band setup</desc>
CalculateWeightedInterestBand:
    
      
    BEGIN CASE

        CASE TermAmountRecord<AA.TermAmount.TermAmount.AmtAmount>   ;* If term amount exits, use this way of calculation
            
            CommittmentAmount = TermAmountRecord<AA.TermAmount.TermAmount.AmtAmount> ;* get the committment amount for the contract
            TrackTierAmount = CommittmentAmount ;* we need to take remaining amount for last tier so we need to keep track of all band amounts

            TotTierRates = DCOUNT(TierRates,@VM) ;* fetch the number of bands
            IF TotTierRates GT 1 THEN
                FOR TierCnt = 1 TO TotTierRates
                    TierPercent = InterestCondition<AA.Interest.Interest.IntTierPercent,TierCnt> ;* get the current tier percentage
                    TierAmount = InterestCondition<AA.Interest.Interest.IntTierAmount,TierCnt> ;* get the current tier amount
                    BandEffectiveRate = TierRates<1,TierCnt> ;* effective interest rate for this band

                    GOSUB DetermineCurrentTierAmount
                    
                    SumRateForBands = SumRateForBands + (BandEffectiveRate*CurrentTierAmount) ;* store interest rate multiplied by amount to take weighted interest rate later

                NEXT TierCnt
                WeightedIntRate = SumRateForBands/CommittmentAmount ;* calculate final weighted interest rate and return
            END ELSE
                WeightedIntRate = InterestCondition<AA.Interest.Interest.IntEffectiveRate> ;* directly take effective rate as weighted rate as we have only one band
            END

        CASE 1      ;* If term amount is null, use Source/TierSourceType details for calculation
        
            GOSUB CalculateInterestRateAccounts
   
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateWeightedInterestLevel>
*** <desc> Do the weighted interest rate calculation for level setup</desc>
CalculateWeightedInterestLevel:

    BEGIN CASE

        CASE TermAmountRecord<AA.TermAmount.TermAmount.AmtAmount>
            
            CommittmentAmount = TermAmountRecord<AA.TermAmount.TermAmount.AmtAmount> ;* get the committment amount for the contract
            TrackTierAmount = CommittmentAmount ;* we need to take remaining amount for last tier so we need to keep track of all level amounts
            
            TotTierRates = DCOUNT(TierRates,@VM) ;* fetch the number of bands
            IF TotTierRates GT 1 THEN
                FOR TierCnt = 1 TO TotTierRates
                    TierPercent = InterestCondition<AA.Interest.Interest.IntTierPercent,TierCnt> ;* get the current tier percentage
                    TierAmount = InterestCondition<AA.Interest.Interest.IntTierAmount,TierCnt> ;* get the current tier amount
                    BandEffectiveRate = TierRates<1,TierCnt> ;* effective interest rate for this band

                    GOSUB DetermineCurrentTierAmount
                    
                    IF CommittmentAmount LE CurrentTierAmount THEN
                        WeightedIntRate = BandEffectiveRate ;*committment amounts falls in this level, return the corresponding interest rate
                        TierCnt = TotTierRates ;* no need to process rest of the loop
                    END ELSE
                        IF TierCnt EQ TotTierRates THEN
                            WeightedIntRate = BandEffectiveRate     ;* Default the last rate if the amt doesnt fall under any of the level
                        END
                    END

                NEXT TierCnt
                
            END ELSE
                WeightedIntRate = InterestCondition<AA.Interest.Interest.IntEffectiveRate> ;* directly take effective rate as weighted rate as we have only one band
            END
            
        CASE 1
        
            GOSUB CalculateInterestRateAccounts
        
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetTermAmount>
*** <desc> fetch the TERM.AMOUNT condition</desc>
GetTermAmount:

    PropertyClass = "TERM.AMOUNT"
    PropertyId = ""
    GOSUB GetArrangementConditions ;* get the current term amount condition
    TermAmountRecord = RAISE(Returnconditions)
            
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DetermineCurrentTierAmount>
*** <desc> fetch the amount for current tier</desc>
DetermineCurrentTierAmount:
   
    BEGIN CASE
        CASE TierPercent
            CurrentTierAmount = (TierPercent/100)*CommittmentAmount ;*  what is the amount applicable for this band/level
            TrackTierAmount =  TrackTierAmount-CurrentTierAmount ;* subtract current tier amount from total committment amount to process last tier later
        CASE TierAmount
            CurrentTierAmount = TierAmount ;* in case tier amount given, directly take it as the band/level amount
            TrackTierAmount =  TrackTierAmount-CurrentTierAmount ;* subtract current tier amount from total committment amount to process last tier later
        CASE 1
            CurrentTierAmount = TrackTierAmount ;* this is last tier, by now we would have got remaining amount in TrackTierAmount, take that
    END CASE
            
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateInterestRateAccounts>
*** <desc> Fetch the interest rate for band or level setup for ACCOUNTS line</desc>
CalculateInterestRateAccounts:
    
    AA.ProductFramework.GetPublishedRecord('PRODUCT', "", Product, "", RProduct, "") ;* fetch the published product record

    SourceBalanceType = ""

    LOCATE IntProperty IN RProduct<AA.ProductManagement.ProductDesigner.PrdCalcProperty, 1> SETTING CalcPropPos THEN

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
            InterestRate = MAXIMUM(TierRates) ;* take maximum of all tier effective rates if source balance type is credit

        CASE SourceBalanceType EQ "DEBIT"
            InterestRate = MINIMUM(TierRates) ;* take minimum of all tier effective rates if source balance type is debit
    END CASE

    WeightedIntRate = InterestRate
            
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
