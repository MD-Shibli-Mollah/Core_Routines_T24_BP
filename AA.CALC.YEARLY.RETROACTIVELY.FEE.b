* @ValidationCode : MjotODg2MjIzNTkxOkNwMTI1MjoxNTIyMjM3NzY5OTkxOmFyb29wYTo0OjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNC4yMDE4MDMxMi0wMjAwOjM4MDoyNjI=
* @ValidationInfo : Timestamp         : 28 Mar 2018 17:19:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : aroopa
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 262/380 (68.9%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180312-0200
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.Fees

SUBROUTINE AA.CALC.YEARLY.RETROACTIVELY.FEE(ChargeProperty, ChargeRecord, ArrBaseAmount, ChargeAmount)
*
* This charge calculate API for the yearly schedule retroactively fee for the bunlde arrangements.
* This calculate the charge amount based on the active accounts in AA.BUNDLE.HIERARCHY.DETAILS
* and tier values defined in Charge property.
*
*-----------------------------------------------------------------------------
*
* @uses AA.CALC.CHARGE
* @package retailaccounts.AA
* @stereotype subroutine
* @author psabari@temenos.com
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* In - ChargeProperty - Charge Property Id.
* In - ChargeRecord   - Charge Property Record.
* In - ArrBaseAmount  - Base amount for charge property if any.
**
* Out - ChargeAmount  - Charge amount calculated in the routine.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modification History </desc>
*
* 05/02/18 - Enhancement: 2370650
*            Task: 2447530
*            This new api used to calculate the retroactively fee for yearly schedule charges.
*
* 05/02/18 - Defect: 2510935
*            Task: 2523308
*            Count CT and MA in the charge amount
*
*** </region>
*----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

    $USING AA.Fees
    $USING AA.Framework
    $USING AA.ActivityCharges
    $USING AA.BundleHierarchy
    $USING AA.PaymentSchedule
    $USING AA.ProductBundle

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    RetroactiveMonthPeriod = ''
    CurrentProcessingDate = ''
    YearToCheck = ''
    ArrangementId = AA.Framework.getArrId()
    PreviousMonthAccounts = ''
    PreviousProcessingDate = ''
    ArrCcy = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrCurrency>
    ArrStartDate = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate>
    ChgCcy = ChargeRecord<AA.Fees.Charge.Currency>
    
    FinalChargeAmount = ''
    ActualProcessingDate = ''
    AA.Framework.GetSystemDate(ActualProcessingDate)        ;*Get current system date
    FinalMonthCnt = 13

    GOSUB GetLastPaymentDate  ;* Get the last process schedule date

    FOR IntMonthCnt = 1 TO FinalMonthCnt

        GOSUB Initialise
        GOSUB DetermineCurrentProcessingDate
        IF CurrentProcessingDate LE ActualProcessingDate AND CurrentProcessingDate GE LastPaymentDate THEN ;* Don't continue the process when the current process date as greater than the actual schedule process date or less than last payment date
            GOSUB GetBundleHierarchyAccounts

            GOSUB GetCurrencyTopAndMasterAccounts
            GOSUB GetTierDetails

            GOSUB FindCalculationType

            IF NOT(RetError) THEN       ;* Process only if not Error
                GOSUB CalculateCharge
                GOSUB GetRetroactiveMonthPeriod
                GOSUB CalculateFinalChargeAmount
            END

            IF AccountLists THEN
                PreviousMonthAccounts = AccountLists
            END
        END ELSE
            IntMonthCnt = FinalMonthCnt
        END
        PreviousProcessingDate = CurrentProcessingDate ;* save the previous month calcuation date, applied to compare for CT accounts increased.
    NEXT IntMonthCnt

    ChargeAmount = FinalChargeAmount    ;* Return overall charge calculate for the entire month present in a year.

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> </desc>
Initialise:

    ChargeAmount = ''
    
    RetError = ''
    LastBandAmt = ''

    BandCalc = ''
    LevelCalc = ''
    MixedCalc = ''

    CalcValue = ''
    MaxAmount = ''
    MinAmount = ''

    NoOfBands = ''
    RemAmt = ''
    MaxAmt = ''
    LevelPos = ''
    BandPos = ''
    TierPos = ''

    NextTierType = ''
    NextTierAmount = ''
    NextCalcValue = ''
    NextCalcType = ''

    TierGroups = ''
    TIER.AMOUNTS = ''
    CalcValues = ''
    CalcTypes = ''
    CalcValueType = ''
    MaxAmounts = ''
    MinAmounts = ''

    ChgAmt = ''
    ChargeCalcDetails = ''

    DefaultSource = ''        ;* Default Source - Arr Base Amount
    TierSource = '' ;* Tier Base Source

    ChargePos = 1

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Determine Current Processing Date>
*** <desc> </desc>
DetermineCurrentProcessingDate:
    
** Get the exact year to form the current processing date, may be last process and current processing year falls different.
    BEGIN CASE
        CASE ActualProcessingDate[1,4] EQ LastPaymentDate[1,4]
            YearToCheck = ActualProcessingDate[1,4]
        CASE CurrentProcessingDate[5,2] EQ 12 AND ActualProcessingDate[1,4] NE LastPaymentDate[1,4]
            YearToCheck = CurrentProcessingDate[1,4] + 1
        CASE CurrentProcessingDate AND (CurrentProcessingDate[1,4] EQ ActualProcessingDate[1,4] OR CurrentProcessingDate[1,4] LT ActualProcessingDate[1,4])
            YearToCheck = CurrentProcessingDate[1,4]
        CASE 1
            YearToCheck = LastPaymentDate[1,4]
    END CASE

** Get the exact month to form the current processing date, may be last process and current processing year falls different and month needs to reset accordingly
    BEGIN CASE
        CASE CurrentProcessingDate[5,2]+1 GT 12
            IF CurrentProcessingDate[7,2] LT '31' THEN
                CurrentProcessingDate = CurrentProcessingDate[1,4]:CurrentProcessingDate[5,1]:CurrentProcessingDate[6,1]:'31'
            END ELSE
                CurrentProcessingDate = CurrentProcessingDate[1,4] + 1:'01':'31'
            END
        CASE CurrentProcessingDate
            IF CurrentProcessingDate[5,2] LT 9 THEN
                CurrentProcessingDate = YearToCheck:CurrentProcessingDate[5,1]:CurrentProcessingDate[6,1]+1:'31'
            END ELSE
                CurrentProcessingDate = YearToCheck:CurrentProcessingDate[5,2]+1:'31'
            END
        CASE LastPaymentDate[5,2]+1 GT 12
            IF LastPaymentDate[7,2] LT '31' THEN
                CurrentProcessingDate = LastPaymentDate[1,4]:LastPaymentDate[5,1]:LastPaymentDate[6,1]:'31'
            END ELSE
                CurrentProcessingDate = LastPaymentDate[1,4]+1:'01':'31'
            END
        CASE 1
            BEGIN CASE
                CASE LastPaymentDate[5,2] MATCHES '01':@VM:'03':@VM:'05':@VM:'07':@VM:'08':@VM:'10':@VM:'12' AND LastPaymentDate[7,2] LT '31'
                    CurrentProcessingDate = YearToCheck:LastPaymentDate[5,1]:LastPaymentDate[6,1]:'31'
                CASE LastPaymentDate[5,2] MATCHES '04':@VM:'06':@VM:'09':@VM:'11' AND LastPaymentDate[7,2] LT '30'
                    CurrentProcessingDate = YearToCheck:LastPaymentDate[5,1]:LastPaymentDate[6,1]:'31'
                CASE LastPaymentDate[5,2] MATCHES '02' AND (LastPaymentDate[7,2] LT '28' OR LastPaymentDate[7,2] LT '29')
                    CurrentProcessingDate = YearToCheck:LastPaymentDate[5,1]:LastPaymentDate[6,1]:'31'
                CASE 1
                    CurrentProcessingDate = YearToCheck:LastPaymentDate[5,1]:LastPaymentDate[6,1]+1:'31'
            END CASE
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> </desc>
GetLastPaymentDate:

    LastPaymentDate = ''
    LastPaymentActualDate = ''
    LastPaymentFinDate = ''
    AA.PaymentSchedule.GetLastPaymentDate(ArrangementId, '', ChargeProperty, 'CURRENT', LastPaymentDate, LastPaymentActualDate, LastPaymentFinDate, '')         ;* get the processing date of the previous month from the AA.ACCOUNT.DETAILS

    IF NOT(LastPaymentDate) THEN
        LastPaymentDate = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetBundleHierarchyAccounts>
*** <desc> </desc>
GetBundleHierarchyAccounts:

    ProcessType = 'LOAD'
    RBundleHierarchyRecord = ''
    RBundleHierarchyDetails = ''
    AccountLists = ""
    AA.BundleHierarchy.ProcessBundleHierarchyDetails(ProcessType, ArrangementId, CurrentProcessingDate, RBundleHierarchyRecord, RBundleHierarchyDetails, AccountLists, RET.ERROR)

    AccountCount = DCOUNT(RBundleHierarchyDetails<1>,@VM)
    FOR Pos = 1 TO AccountCount
        IF (RBundleHierarchyDetails<3,Pos> EQ "LINK") AND (RBundleHierarchyDetails<4,Pos> EQ "LIVE") THEN     ;* only take linked and live accounts
            IF AccountLists THEN
                AccountLists<1> := @VM :RBundleHierarchyDetails<1,Pos>          ;*All the account numbers should be returned with VM sep.
            END ELSE
                AccountLists<1> = RBundleHierarchyDetails<1,Pos>      ;* and store the values in AccountLists for one account
            END
        END

        BEGIN CASE
            CASE RBundleHierarchyDetails<3,Pos> EQ "DELINK"     ;*if the account is delinked from BUNDLE in any following dates, then we have to delete the account from account list
                LOCATE RBundleHierarchyDetails<1,Pos> IN AccountLists<1,1> SETTING AccPos THEN
                    DEL AccountLists<1,AccPos>
                END
            CASE 1
        END CASE
    NEXT Pos

    GOSUB GetNewAccountsAdded

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetNewAccountsAdded>
*** <desc> </desc>
GetNewAccountsAdded:

    ActualAccounts = ''
    CurrentMonthCnt = ''
    TrAccountCnt = ''
    TierBaseAmount = ''
    BaseAmount = ''
    AccountsCnt = ''

** if accounts present in previous month, then we need to locate the current accounts in previous month accounts to get the newly added accounts
    IF PreviousMonthAccounts THEN
        CurrentMonthCnt = DCOUNT(AccountLists<1>,@VM)

        FOR AccountStartCnt = 1 TO CurrentMonthCnt
            LOCATE AccountLists<1,AccountStartCnt> IN PreviousMonthAccounts<1,1> SETTING AcctPos ELSE
                IF ActualAccounts THEN
                    ActualAccounts<1> := @VM :AccountLists<1,AccountStartCnt>   ;*All the account numbers should be returned with VM sep.
                END ELSE
                    ActualAccounts<1> = AccountLists<1,AccountStartCnt>         ;* and store the values in ActualAccounts for one account
                END
            END

        NEXT AccountStartCnt
        TrAccountCnt = DCOUNT(ActualAccounts<1>,@VM)
        BaseAmount = TrAccountCnt
    END ELSE
        TrAccountCnt = DCOUNT(AccountLists<1>,@VM)
        BaseAmount = TrAccountCnt
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Tier Details>
*** <desc> </desc>
GetTierDetails:

*** Get all the required tier details for calculation of charges

    TierGroup = ChargeRecord<AA.Fees.Charge.TierGroups>
    TierType = ChargeRecord<AA.Fees.Charge.CalcTierType>
    TierMaxAmount = ChargeRecord<AA.Fees.Charge.TierMaxCharge>
    TierMinAmount = ChargeRecord<AA.Fees.Charge.TierMinCharge>

    GOSUB GetTierAmountExclusive

    CalcType = ChargeRecord<AA.Fees.Charge.CalcType>

    NoOfCalcTypes = DCOUNT(CalcType,@VM)

    FOR InitalCnt = 1 TO NoOfCalcTypes
        CalcValue<1,InitalCnt> = ChargeRecord<AA.Fees.Charge.ChgAmount,InitalCnt>
    NEXT InitalCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------
***<region name = Get Tier Amount Exclusive>
***<desc> Get the udpated Tier amount based on Tier Exclusive Flag</desc>
GetTierAmountExclusive:

    ActTierAmount       = ChargeRecord<AA.Fees.Charge.TierAmount>
    ActTierCount        = ChargeRecord<AA.Fees.Charge.TierCount>
    ActTierTerm         = ChargeRecord<AA.Fees.Charge.TierTerm>
    ActTierExcl         = ChargeRecord<AA.Fees.Charge.TierExclusive>
    FinalTierAmount     = ''
    RetErr              = ''

    AA.Fees.ChargeApplyTierExclusive(ActTierAmount,ActTierCount,ActTierTerm,ActTierExcl,CurrentProcessingDate,ArrCcy,ChgCcy,FinalTierAmount,RetErr)

    TierAmount = FinalTierAmount

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= Find Calculation Type>
*** <desc> </desc>
FindCalculationType:

*** Find out if the calculation is Band, level or mixed.

    LOCATE "BAND" IN TierType<1,1> SETTING BandCalc ELSE
        BandCalc = ''
        TierBaseAmount = BaseAmount ;* assign value for tier base amount only for level type calculation
    END

    LOCATE "LEVEL" IN TierType<1,1> SETTING LevelCalc ELSE
        LevelCalc = ''
    END

    BEGIN CASE
        CASE BaseAmount AND TierBaseAmount  ;* Calculation based on tier source, if both TIERBASE and normal BASE are present
            DefaultSource =  BaseAmount     ;* Default source
            TierSource = TierBaseAmount     ;* Tier source
*** If tier calculation is opt then default source and tier source have value. For tier based calculation, we support LEVEL calculation alone.
*** unless we need to raise an error
            IF BandCalc THEN
                RetError = "AA.RTN.CHARGE.CALC.NOT.SUPPORTED"
            END

        CASE BaseAmount AND NOT(TierBaseAmount)       ;* Calculation without tier source, if TIERBASE is not present
            DefaultSource = ''    ;* Not need base source
            TierSource = BaseAmount         ;* Assign default source to tier source
    END CASE

    IF BandCalc AND LevelCalc THEN
        MixedCalc = 1
        BandCalc = ''
        LevelCalc = ''
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Actual Process>
*** <desc> </desc>
CalculateCharge:

    BEGIN CASE
        CASE BandCalc
            GOSUB BandCalculation ;* Band Calculation

        CASE LevelCalc
            GOSUB LevelCalculation          ;* Level Calculation

        CASE MixedCalc
            GOSUB MixedCalculation          ;* Both Band and Level Calculation needs to be done
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Band Calculation>
*** <desc> </desc>
BandCalculation:

*** If only band is defined then simple band calculation will be carried out.
*** If both band and level is defined then both has to be handled.

*** REM.AMT will be the amount on top of which calculation is to be done.
*** LAST.BAND.AMT will be null for the first time and from next loop
*** this will have the difference between previous tier amount and the current
*** tier amount.

*** When last multi value of tier type is reached REM.AMT should be the difference
*** between the base amount and the previous band amt.

    GOSUB GetBaseAmountPosition         ;* Get Base amount position
    BandPos = TierPos

    FOR IntBandPos = 1 TO BandPos

        IF NOT(TierAmount<1,IntBandPos>) OR TierAmount<1,IntBandPos> GT TierSource THEN   ;* This is the last set in multivalue
            RemAmt = TierSource - LastBandAmt
        END ELSE
            RemAmt = TierAmount<1,IntBandPos> - LastBandAmt ;* Current tier amount minus previous tier amount
        END

*** If its simple band calculation then CALC.TYPE, CALC.VALUE, MAX.AMOUNT, MIN.AMOUNT will be from
*** calling routine

*** If its mixed calculation then value will be from MIXED.CALCULATION para

        TypeOfCalc = CalcType<1,IntBandPos>
        CalcValueType = CalcValue<1,IntBandPos>
        TierMaxAmount = MaxAmount<1,IntBandPos>
        TierMinAmount = MinAmount<1,IntBandPos>

        GOSUB CalculateAmount ;* Calculate actual charge amount based on type of calc

        LastBandAmt = TierAmount<1,IntBandPos>    ;* Needed for next time calculation
    NEXT IntBandPos

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Level Calculation>
*** <desc> </desc>
LevelCalculation:

*** Level calculation is done by finding where the base amount would fit in the
*** level group.

*** Get the base amount position and check if there is tier amount. If there is
*** no tier amount then that is the last multivalue. If the tier amount is greater
*** than base amount again that will be the last multvalue for calculation.

    GOSUB GetBaseAmountPosition
    LevelPos = TierPos

    IF NOT(TierAmount<1,LevelPos>) OR TierAmount<1,LevelPos> GT TierSource THEN ;* This is the last multivalue
        RemAmt = TierSource - LastBandAmt
    END ELSE
        RemAmt = TierAmount<1,LevelPos> - LastBandAmt       ;* Current tier amount minus previous tier amount
        LastBandAmt = TierAmount<1, LevelPos>
    END

*** Get the required details for calculation

    TypeOfCalc = CalcType<1,LevelPos>
    CalcValueType = CalcValue<1,LevelPos>
    TierMaxAmount = MaxAmount<1,LevelPos>
    TierMinAmount = MinAmount<1,LevelPos>

    GOSUB CalculateAmount     ;* Calculate actual charge amount

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Mixed Calculation>
*** <desc> </desc>
MixedCalculation:

*** Group band and level and then start calculations.

    GOSUB GroupBandAndLevel

    FOR InitGrpCnt = 1 TO GrpCnt

        TierType = TierGroups<InitGrpCnt>
        TierAmount = TierAmounts<InitGrpCnt>
        CalcValue = CalcValues<InitGrpCnt>
        CalcType = CalcTypes<InitGrpCnt>
        MaxAmount = MaxAmounts<InitGrpCnt>
        MinAmount = MinAmounts<InitGrpCnt>

        BEGIN CASE
            CASE TierGroup = "LEVELS"
                GOSUB GroupLevelCalculation

            CASE TierGroup = "BANDS"
                GOSUB GroupBandCalculation
        END CASE

    NEXT InitGrpCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Base amount position>
*** <desc> </desc>
GetBaseAmountPosition:

*** Loop around tier amounts to find out where the base amount would fit.

    TierPos = ''
    LOOP
        TierPos += 1          ;* Incremented to find out where the base amount would fit
    UNTIL TierSource LE TierAmount<1,TierPos> OR TierAmount<1,TierPos> EQ ''
    REPEAT

*** During mixed calculation if loop condition is not satisfied then TIER.POS will
*** be of position on which there will not be any value. So decrement the position

    IF NOT(TierType<1,TierPos>) THEN
        TierPos -= 1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Group Band and Level>
*** <desc> </desc>
GroupBandAndLevel:

*** Group Band and level for calculation purpose. Once it is grouped then
*** all needed to do is perform Band calculation or Level calculation depending
*** upon tier group type.

*** If the subsequent tier type is same as previous it is added with value marker
*** inbetween. If subsequent tier type is not same it is added with field marker
*** inbetween.

*** Once grouping is done all that is need to do is to call either band calculation
*** or level calculation

    GrpCnt = ""     ;* To form groups of same tier type
    AddToGrp = 1    ;* Just to put the same tier type in the same group
    LastTierType = ''

    LOOP
        REMOVE NextTierType FROM TierType SETTING TtPos
        REMOVE NextTierAmount FROM TierAmount SETTING TaPos
        REMOVE NextCalcValue FROM CalcValue SETTING CvPos
        REMOVE NextCalcType FROM CalcType SETTING CtPos
        REMOVE NextMaxAmount FROM MaxAmount SETTING MxPos
        REMOVE NextMinAmount FROM MinAmount SETTING MnPos
    UNTIL NextTierType EQ ''

        IF NextTierType NE LasrTierType THEN      ;* Subsequent tier types are not the same
            GrpCnt += 1       ;* To group same tier types seperated by VM
            AddToGrp = 1
            TierGroups<GrpCnt> = NextTierType
            TierAmounts<GrpCnt> = NextTierAmount
            CalcValues<GrpCnt> = NextCalcValue
            CalcTypes<GrpCnt> = NextCalcType
            MaxAmounts<GrpCnt> = NextMaxAmount
            MinAmounts<GrpCnt> = NextMinAmount
        END ELSE
            AddToGrp += 1     ;* Since on first position already a value is added group should be from 2nd position
            TierGroups<GrpCnt, AddToGrp> = NextTierType     ;* Same tier types are grouped
            TierAmounts<GrpCnt, AddToGrp> = NextTierAmount  ;* Corresponding tier amount are grouped
            CalcValues<GrpCnt, AddToGrp> = NextCalcValue    ;* Corresponding calc values are grouped
            CalcTypes<GrpCnt, AddToGrp> = NextCalcType      ;* Corresponding calc types are grouped
            MaxAmounts<GrpCnt, AddToGrp> = NextMaxAmount    ;* Corresponding max tier amount are grouped
            MinAmounts<GrpCnt, AddToGrp> = NextMinAmount    ;* Corresponding min tier amount are grouped
        END
        LasrTierType = NextTierType

        IF NextTierAmount GE TierSource THEN
            EXIT    ;* Stop grouping if base amount is greater than tier amount
        END
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Tier Group Level Calculation>
*** <desc> </desc>
GroupLevelCalculation:

*** Do corresponding calculation if tier groups is levels
*
*** Only band calculation is needed till the final tier set is reached

    IF TierType<1,1> = "BAND" THEN
        GOSUB BandCalculation
    END

*** If in final tier level is defined then do level calculation

    IF TierType<1,1> = "LEVEL" AND InitGrpCnt = GrpCnt THEN
        GOSUB LevelCalculation
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Tier Group Band Calculation>
*** <desc> </desc>
GroupBandCalculation:

*** Do corresponding calculation if tier groups is bands

    IF TierType<1,1> = "BAND" THEN
        GOSUB BandCalculation
    END ELSE
        GOSUB LevelCalculation
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Group Band and Level>
*** <desc> </desc>
CalculateAmount:

*** Calculate amount based on type of calc defined

    BEGIN CASE
        CASE TypeOfCalc EQ 'PERCENTAGE'
            IF DefaultSource THEN ;* Tier base calculation! Final charge amount derived based on rate * default source
                UpdateAmount = DefaultSource * CalcValueType / 100
            END ELSE    ;* It not tier base calculation
                UpdateAmount = RemAmt * CalcValueType / 100
            END
            TempCalcValueType = CalcValueType:' %'

        CASE TypeOfCalc EQ 'FLAT'
            UpdateAmount = CalcValueType
            TempCalcValueType = CalcValueType
        CASE 1

            IF DefaultSource THEN ;* Tier base calculation! Final charge amount derived based on rate * default source
                UpdateAmount = DefaultSource * CalcValueType
            END ELSE    ;* It not tier base calculation
                UpdateAmount = RemAmt * CalcValueType
            END
            TempCalcValueType = CalcValueType:' Units'

    END CASE

*** For flat tier max amount or tier min amount will not be defined

    ChgCalcAmt = UpdateAmount

    IF TypeOfCalc NE "FLAT" THEN
        GOSUB CheckMinMaxAmount
    END

    ChargeAmount += UpdateAmount

    GOSUB BuildChargeCalcArray

RETURN
*** </region>
*-----------------------------------------------------------------------------
***<region name = Build CHarge CALC ARRAY>
***<desc> To build charge details </desc>
BuildChargeCalcArray:

    ChargeCalcDetails<1, AA.ActivityCharges.ChgTierBalance, ChargePos> = RemAmt
    ChargeCalcDetails<1, AA.ActivityCharges.ChgTierRateOrAmt, ChargePos> = TempCalcValueType
    ChargeCalcDetails<1, AA.ActivityCharges.ChgCalcAmt, ChargePos> = ChgCalcAmt
    ChargeCalcDetails<1, AA.ActivityCharges.ChgTierMaxAmt, ChargePos> = TierMaxAmount
    ChargeCalcDetails<1, AA.ActivityCharges.ChgTierMinAmt, ChargePos> = TierMinAmount
    ChargeCalcDetails<1, AA.ActivityCharges.ChgTierCalcAmt, ChargePos> = UpdateAmount

    ChargePos += 1

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= Group Band and Level>
*** <desc> </desc>
CheckMinMaxAmount:

*** Find out if the charge amount for that band falls between tier max and min
*** amount.

    IF TierMaxAmount NE '' AND UpdateAmount GT TierMaxAmount THEN
        UpdateAmount = TierMaxAmount
    END

    IF TierMinAmount AND UpdateAmount LT TierMinAmount THEN
        UpdateAmount = TierMinAmount
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetRetroactiveMonthPeriod>
*** <desc> </desc>
GetRetroactiveMonthPeriod:

** We have 12 month's in period and we get the remaining Retroactive period when we reduce the month from actual
** processing date month plus 1.

    IF NOT(RetroactiveMonthPeriod) THEN
        RetroactiveMonthPeriod = 12
    END ELSE
        RetroactiveMonthPeriod = RetroactiveMonthPeriod - 1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetRetroactiveMonthPeriod>
*** <desc> </desc>
CalculateFinalChargeAmount:

    FinalChargeAmount += ChargeAmount * RetroactiveMonthPeriod        ;* No.of.accounts added in each month along with charge amount

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetCurrencyTopAndMasterAccounts>
*** <desc> </desc>
GetCurrencyTopAndMasterAccounts:
    CtAccountCnt = ''
    
    AA.ProductBundle.CountAddedCurrencyTopAccounts(ArrangementId, PreviousProcessingDate, CurrentProcessingDate, CtAccountCnt)
    
    IF (CtAccountCnt AND CurrentProcessingDate[5,2] EQ '01') OR (ArrStartDate[1,6] EQ CurrentProcessingDate[1,6]) THEN ;* the first part of OR logic: arrangements already created last year. second part: newly created in the middle of the year.
        BaseAmount += CtAccountCnt + 1 ;* add CT and MA
    END ELSE
        BaseAmount += CtAccountCnt ;* add CT
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
