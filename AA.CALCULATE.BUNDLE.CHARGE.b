* @ValidationCode : MjoxMzQyNjIzODQ0OkNwMTI1MjoxNTMyMDY0MTE3MTE5OnlnYXlhdHJpOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA3LjIwMTgwNjIxLTAyMjE6MjgwOjE2OQ==
* @ValidationInfo : Timestamp         : 20 Jul 2018 10:51:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygayatri
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 169/280 (60.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------------
* <Rating>-261</Rating>
*----------------------------------------------------------------------------
$PACKAGE AA.Fees
SUBROUTINE AA.CALCULATE.BUNDLE.CHARGE(CHARGE.PROPERTY,R.PROPERTY.RECORD,BASE.AMOUNT,CHARGE.AMOUNT)
        
*** <region name= Program Description>
*** <desc> </desc>
*** This routine will return the charge amount based on the TIER details defined in charge property record.
*** It will get the number of accounts in BUNDLE pool and calculate charge for them
*** Logic is so formed such that if BAND alone is defined then simple band calculation will be performed.
*** Same is the case for LEVEL. When TIER.TYPE is combined with Band and Level then band or level will be
*** grouped such that when the amount is located in the group the corresponding tier type can be found.
*** New Input Variable TIER BASE AMOUNT is used when TIER SOURCE is defined. This TIER BASE AMOUNT is used
*** to get the calc value using which the charge amount is calculated.
*** When TIER BASE AMOUNT and ARR BASE AMOUNT are present, CALC.VALUE is located using TIER BASE AMOUNT for Charge calculation
*** When only ARR BASE AMOUNT is present, CALC.VALUE is located using ARR BASE AMOUNT for charge calculation
*** System will throw error when TIER BASE AMOUNT is present and ARR BASE AMOUNT is null
*** Current behaviour of this routine for mixed calc type needs some tweaking since few cases doesnt yield expected result.
***
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Arguments for the subroutine </desc>
* Arguments:
*
* Input
* CHARGE.PROPERTY - the charge property
* R.PROPERTY.RECORD - the condition record for charge
* BASE.AMOUNT - the base amount for which charge is needed
* Output
* CHARGE.AMOUNT - the calculated charge amount
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification history>
*** <desc> </desc>
*** MODIFICATION HISTORY
*
* 06/02/18 - Enhancement : 2370650
*            Task : 2447530
*            New local routine to calculate charge amount for bundle based on tier details.
*
* 05/02/18 - Defect: 2510935
*            Task: 2523308
*            Count CT and MA in the charge amount
*
* 13/07/18 - Task : 2672801
*            Defect : 2671077
*            Calculate charge based on number of accounts in dated, non dated bundle hierarchy record, number of CT and bundle
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
 
    $USING AA.ActivityCharges
    $USING AA.BundleHierarchy
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AA.ProductBundle
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Logic>
*** <desc> </desc>

    GOSUB INITIALISE
    
    GOSUB GET.BUNDLE.HIERARCHY.ACCOUNTS
    
    GOSUB GET.CURRENCY.TOP.AND.MASTER.ACCOUNTS
    
    GOSUB GET.TIER.DETAILS
    
    GOSUB FIND.CALCULATION.TYPE
    
    IF NOT(RET.ERROR) THEN          ;* Process only if not Error
        GOSUB CALCULATE.CHARGE
    END
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> </desc>
INITIALISE:
    
    ARRANGEMENT.ID = AA.Framework.getArrId()
    EFFECTIVE.DATE = ''
    AA.Framework.GetSystemDate(EFFECTIVE.DATE)     ;*Get current system date
    ARR.CCY = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrCurrency>
    CHG.CCY = R.PROPERTY.RECORD<AA.Fees.Charge.Currency>
    RET.ERROR = ''
    LAST.BAND.AMT = ''

    BAND.CALC = ''
    LEVEL.CALC = ''
    MIXED.CALC = ''

    NO.OF.BANDS = ''
    REM.AMT = ''
    MAX.AMT = ''
    LEVEL.POS = ''
    BAND.POS = ''
    TIER.POS = ''

    NEXT.TIER.TYPE = ''
    NEXT.TIER.AMOUNT = ''
    NEXT.CALC.VALUE = ''
    NEXT.CALC.TYPE = ''

    TIER.GROUPS = ''
    TIER.AMOUNTS = ''
    CALC.VALUES = ''
    CALC.TYPES = ''
    CALC.VALUE.TYPE = ''
    MAX.AMOUNTS = ''
    MIN.AMOUNTS = ''

    CHG.AMT = ''
    RET.ERROR = ''
    CHARGE.CALC.DETAILS  = ''
    
    DEFAULT.SOURCE = ''             ;* Default Source - Arr Base Amount
    TIER.SOURCE = ''                ;* Tier Base Source
    
    CHARGE.POS = 1
    
    NUM.ACCOUNTS = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.BUNDLE.HIERARCHY.ACCOUNTS>
*** <desc> </desc>
GET.BUNDLE.HIERARCHY.ACCOUNTS:

** get the number of accounts in the pool and set it as the base amount
    PROCESS.TYPE = 'LOAD'
    R.BUNDLE.HIERARCHY.RECORD = ''
    R.BUNDLE.HIERARCHY.DETAILS = ''
    ACCOUNT.LISTS = ""
    AA.BundleHierarchy.ProcessBundleHierarchyDetails(PROCESS.TYPE, ARRANGEMENT.ID, EFFECTIVE.DATE, R.BUNDLE.HIERARCHY.RECORD, R.BUNDLE.HIERARCHY.DETAILS, ACCOUNT.LISTS, RET.ERROR)
    ACCOUNT.COUNT = DCOUNT(R.BUNDLE.HIERARCHY.DETAILS<1>,@VM)
    FOR POS = 1 TO ACCOUNT.COUNT
        IF (R.BUNDLE.HIERARCHY.DETAILS<3,POS> EQ "LINK") AND (R.BUNDLE.HIERARCHY.DETAILS<4,POS> EQ "LIVE") THEN ;* only take linked and live accounts
            IF ACCOUNT.LISTS THEN
                ACCOUNT.LISTS<1> := @VM :R.BUNDLE.HIERARCHY.DETAILS<1,POS> ;*All the account numbers should be returned with VM sep.
            END ELSE
                ACCOUNT.LISTS<1> = R.BUNDLE.HIERARCHY.DETAILS<1,POS>;* and store the values in ACCOUNT.LISTS for one account
            END
        END
    
        BEGIN CASE
            CASE R.BUNDLE.HIERARCHY.DETAILS<3,POS> EQ "DELINK" ;*if the account is delinked from BUNDLE in any following dates, then we have to delete the account from account.list
                LOCATE R.BUNDLE.HIERARCHY.DETAILS<1,POS> IN ACCOUNT.LISTS<1,1> SETTING ACC.POS THEN
                    DEL ACCOUNT.LISTS<1,ACC.POS>
                END
            CASE 1
        END CASE
    NEXT POS
    
    PrelimBundleHierarchyRec = AA.BundleHierarchy.BundleHierarchyDetails.Read(ARRANGEMENT.ID, Error)
    TotPrelimTRAccounts = DCOUNT(PrelimBundleHierarchyRec<AA.BundleHierarchy.BundleHierarchyDetails.BhdAccountRef>,@VM)
    FOR PrelimAccountCnt = 1 TO TotPrelimTRAccounts
        IF PrelimBundleHierarchyRec<AA.BundleHierarchy.BundleHierarchyDetails.BhdLinkType,PrelimAccountCnt> EQ "LINK" THEN
            IF PRELIM.ACCOUNT.LISTS THEN
                PRELIM.ACCOUNT.LISTS<1> := @VM :PrelimBundleHierarchyRec<AA.BundleHierarchy.BundleHierarchyDetails.BhdAccountRef,PrelimAccountCnt>
            END ELSE
                PRELIM.ACCOUNT.LISTS<1> = PrelimBundleHierarchyRec<AA.BundleHierarchy.BundleHierarchyDetails.BhdAccountRef,PrelimAccountCnt>
            END
        END
    NEXT PrelimAccountCnt
    
    TR.ACCOUNTS.COUNT = DCOUNT(ACCOUNT.LISTS<1>,@VM) + DCOUNT(PRELIM.ACCOUNT.LISTS<1>,@VM)
    BASE.AMOUNT = TR.ACCOUNTS.COUNT
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Tier Details>
*** <desc> </desc>
GET.TIER.DETAILS:

*** Get all the required tier details for calculation of charges

    TIER.GROUP = R.PROPERTY.RECORD<AA.Fees.Charge.TierGroups>
    TIER.TYPE = R.PROPERTY.RECORD<AA.Fees.Charge.CalcTierType>
    TIER.MAX.AMOUNT = R.PROPERTY.RECORD<AA.Fees.Charge.TierMaxCharge>
    TIER.MIN.AMOUNT = R.PROPERTY.RECORD<AA.Fees.Charge.TierMinCharge>

    GOSUB GET.TIER.AMOUNT.EXCLUSIVE

    CALC.TYPE = R.PROPERTY.RECORD<AA.Fees.Charge.CalcType>

    NO.OF.CALC.TYPES = DCOUNT(CALC.TYPE,@VM)

    FOR I = 1 TO NO.OF.CALC.TYPES
        CALC.VALUE<1,I> = R.PROPERTY.RECORD<AA.Fees.Charge.ChgAmount,I>
    NEXT I

RETURN
*** </region>
*-----------------------------------------------------------------------------
***<region name = Get Tier Amount Exclusive>
***<desc> Get the udpated Tier amount based on Tier Exclusive Flag</desc>
GET.TIER.AMOUNT.EXCLUSIVE:

    ACT.TIER.AMOUNT     = R.PROPERTY.RECORD<AA.Fees.Charge.TierAmount>
    ACT.TIER.COUNT      = R.PROPERTY.RECORD<AA.Fees.Charge.TierCount>
    ACT.TIER.TERM       = R.PROPERTY.RECORD<AA.Fees.Charge.TierTerm>
    ACT.TIER.EXCL       = R.PROPERTY.RECORD<AA.Fees.Charge.TierExclusive>
    FINAL.TIER.AMOUNT   = ""
    RETERR              = ""
    
    AA.Fees.ChargeApplyTierExclusive(ACT.TIER.AMOUNT,ACT.TIER.COUNT,ACT.TIER.TERM,ACT.TIER.EXCL,EFFECTIVE.DATE,ARR.CCY,CHG.CCY,FINAL.TIER.AMOUNT,RETERR)

    TIER.AMOUNT = FINAL.TIER.AMOUNT
    
RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= Find Calculation Type>
*** <desc> </desc>
FIND.CALCULATION.TYPE:
    
*** Find out if the calculation is Band, level or mixed.

    LOCATE "BAND" IN TIER.TYPE<1,1> SETTING BAND.CALC ELSE
        BAND.CALC = ''
        TIER.BASE.AMOUNT = BASE.AMOUNT ;* assign value for tier base amount only for level type calculation
    END

    LOCATE "LEVEL" IN TIER.TYPE<1,1> SETTING LEVEL.CALC ELSE
        LEVEL.CALC = ''
    END

    BEGIN CASE
        CASE BASE.AMOUNT AND TIER.BASE.AMOUNT                ;* Calculation based on tier source, if both TIERBASE and normal BASE are present
            DEFAULT.SOURCE =  BASE.AMOUNT                   ;* Default source
            TIER.SOURCE = TIER.BASE.AMOUNT                  ;* Tier source
*** If tier calculation is opt then default source and tier source have value. For tier based calculation, we support LEVEL calculation alone.
*** unless we need to raise an error
            IF BAND.CALC THEN
                RET.ERROR = "AA.RTN.CHARGE.CALC.NOT.SUPPORTED"
            END
            
        CASE BASE.AMOUNT AND NOT(TIER.BASE.AMOUNT)               ;* Calculation without tier source, if TIERBASE is not present
            DEFAULT.SOURCE = ''                                 ;* Not need base source
            TIER.SOURCE = BASE.AMOUNT                           ;* Assign default source to tier source
    END CASE
    
    IF BAND.CALC AND LEVEL.CALC THEN
        MIXED.CALC = 1
        BAND.CALC = ''
        LEVEL.CALC = ''
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Actual Process>
*** <desc> </desc>
CALCULATE.CHARGE:

    BEGIN CASE
        CASE BAND.CALC
            GOSUB BAND.CALCULATION          ;* Band Calculation

        CASE LEVEL.CALC
            GOSUB LEVEL.CALCULATION         ;* Level Calculation

        CASE MIXED.CALC
            GOSUB MIXED.CALCULATION         ;* Both Band and Level Calculation needs to be done

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Band Calculation>
*** <desc> </desc>
BAND.CALCULATION:

*** If only band is defined then simple band calculation will be carried out.
*** If both band and level is defined then both has to be handled.

*** REM.AMT will be the amount on top of which calculation is to be done.
*** LAST.BAND.AMT will be null for the first time and from next loop
*** this will have the difference between previous tier amount and the current
*** tier amount.

*** When last multi value of tier type is reached REM.AMT should be the difference
*** between the base amount and the previous band amt.

    GOSUB GET.BASE.AMOUNT.POSITION      ;* Get Base amount position
    BAND.POS = TIER.POS

    FOR J = 1 TO BAND.POS

        IF NOT(TIER.AMOUNT<1,J>) OR TIER.AMOUNT<1,J> GT TIER.SOURCE THEN        ;* This is the last set in multivalue
            REM.AMT = TIER.SOURCE - LAST.BAND.AMT
        END ELSE
            REM.AMT = TIER.AMOUNT<1,J> - LAST.BAND.AMT      ;* Current tier amount minus previous tier amount
        END

*** If its simple band calculation then CALC.TYPE, CALC.VALUE, MAX.AMOUNT, MIN.AMOUNT will be from
*** calling routine

*** If its mixed calculation then value will be from MIXED.CALCULATION para

        TYPE.OF.CALC = CALC.TYPE<1,J>
        CALC.VALUE.TYPE = CALC.VALUE<1,J>
        TIER.MAX.AMOUNT = MAX.AMOUNT<1,J>
        TIER.MIN.AMOUNT = MIN.AMOUNT<1,J>

        GOSUB CALCULATE.AMOUNT          ;* Calculate actual charge amount based on type of calc

        LAST.BAND.AMT = TIER.AMOUNT<1,J>          ;* Needed for next time calculation
    NEXT J

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Level Calculation>
*** <desc> </desc>
LEVEL.CALCULATION:

*** Level calculation is done by finding where the base amount would fit in the
*** level group.

*** Get the base amount position and check if there is tier amount. If there is
*** no tier amount then that is the last multivalue. If the tier amount is greater
*** than base amount again that will be the last multvalue for calculation.

    GOSUB GET.BASE.AMOUNT.POSITION
    LEVEL.POS = TIER.POS

    IF NOT(TIER.AMOUNT<1,LEVEL.POS>) OR TIER.AMOUNT<1,LEVEL.POS> GT TIER.SOURCE THEN      ;* This is the last multivalue
        REM.AMT = TIER.SOURCE - LAST.BAND.AMT
    END ELSE
        REM.AMT = TIER.AMOUNT<1,LEVEL.POS> - LAST.BAND.AMT  ;* Current tier amount minus previous tier amount
        LAST.BAND.AMT = TIER.AMOUNT<1, LEVEL.POS>
    END

*** Get the required details for calculation

    TYPE.OF.CALC = CALC.TYPE<1,LEVEL.POS>
    CALC.VALUE.TYPE = CALC.VALUE<1, LEVEL.POS>
    TIER.MAX.AMOUNT = MAX.AMOUNT<1, LEVEL.POS>
    TIER.MIN.AMOUNT = MIN.AMOUNT<1, LEVEL.POS>

    GOSUB CALCULATE.AMOUNT    ;* Calculate actual charge amount

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Mixed Calculation>
*** <desc> </desc>
MIXED.CALCULATION:

*** Group band and level and then start calculations.

    GOSUB GROUP.BAND.AND.LEVEL

    FOR I = 1 TO GRP.CNT

        TIER.TYPE = TIER.GROUPS<I>
        TIER.AMOUNT = TIER.AMOUNTS<I>
        CALC.VALUE = CALC.VALUES<I>
        CALC.TYPE = CALC.TYPES<I>
        MAX.AMOUNT = MAX.AMOUNTS<I>
        MIN.AMOUNT = MIN.AMOUNTS<I>

        BEGIN CASE
            CASE TIER.GROUP = "LEVELS"
                GOSUB GROUP.LEVEL.CALCULATION

            CASE TIER.GROUP = "BANDS"
                GOSUB GROUP.BAND.CALCULATION

        END CASE

    NEXT I

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Base amount position>
*** <desc> </desc>
GET.BASE.AMOUNT.POSITION:

*** Loop around tier amounts to find out where the base amount would fit.

    TIER.POS = ''
    LOOP
        TIER.POS += 1         ;* Incremented to find out where the base amount would fit
    UNTIL TIER.SOURCE LE TIER.AMOUNT<1,TIER.POS> OR TIER.AMOUNT<1,TIER.POS> EQ ''
    REPEAT

*** During mixed calculation if loop condition is not satisfied then TIER.POS will
*** be of position on which there will not be any value. So decrement the position

    IF NOT(TIER.TYPE<1,TIER.POS>) THEN
        TIER.POS -= 1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Group Band and Level>
*** <desc> </desc>
GROUP.BAND.AND.LEVEL:

*** Group Band and level for calculation purpose. Once it is grouped then
*** all needed to do is perform Band calculation or Level calculation depending
*** upon tier group type.

*** If the subsequent tier type is same as previous it is added with value marker
*** inbetween. If subsequent tier type is not same it is added with field marker
*** inbetween.

*** Once grouping is done all that is need to do is to call either band calculation
*** or level calculation

    GRP.CNT = ""    ;* To form groups of same tier type
    ADD.TO.GRP = 1  ;* Just to put the same tier type in the same group
    LAST.TIER.TYPE = ''

    LOOP
        REMOVE NEXT.TIER.TYPE FROM TIER.TYPE SETTING TT.POS
        REMOVE NEXT.TIER.AMOUNT FROM TIER.AMOUNT SETTING TA.POS
        REMOVE NEXT.CALC.VALUE FROM CALC.VALUE SETTING CV.POS
        REMOVE NEXT.CALC.TYPE FROM CALC.TYPE SETTING CT.POS
        REMOVE NEXT.MAX.AMOUNT FROM MAX.AMOUNT SETTING MX.POS
        REMOVE NEXT.MIN.AMOUNT FROM MIN.AMOUNT SETTING MN.POS
    UNTIL NEXT.TIER.TYPE EQ ''

        IF NEXT.TIER.TYPE NE LAST.TIER.TYPE THEN  ;* Subsequent tier types are not the same
            GRP.CNT += 1      ;* To group same tier types seperated by VM
            ADD.TO.GRP = 1
            TIER.GROUPS<GRP.CNT> = NEXT.TIER.TYPE
            TIER.AMOUNTS<GRP.CNT> = NEXT.TIER.AMOUNT
            CALC.VALUES<GRP.CNT> = NEXT.CALC.VALUE
            CALC.TYPES<GRP.CNT> = NEXT.CALC.TYPE
            MAX.AMOUNTS<GRP.CNT> = NEXT.MAX.AMOUNT
            MIN.AMOUNTS<GRP.CNT> = NEXT.MIN.AMOUNT
        END ELSE
            ADD.TO.GRP += 1   ;* Since on first position already a value is added group should be from 2nd position
            TIER.GROUPS<GRP.CNT, ADD.TO.GRP> = NEXT.TIER.TYPE         ;* Same tier types are grouped
            TIER.AMOUNTS<GRP.CNT, ADD.TO.GRP> = NEXT.TIER.AMOUNT      ;* Corresponding tier amount are grouped
            CALC.VALUES<GRP.CNT, ADD.TO.GRP> = NEXT.CALC.VALUE        ;* Corresponding calc values are grouped
            CALC.TYPES<GRP.CNT, ADD.TO.GRP> = NEXT.CALC.TYPE          ;* Corresponding calc types are grouped
            MAX.AMOUNTS<GRP.CNT, ADD.TO.GRP> = NEXT.MAX.AMOUNT        ;* Corresponding max tier amount are grouped
            MIN.AMOUNTS<GRP.CNT, ADD.TO.GRP> = NEXT.MIN.AMOUNT        ;* Corresponding min tier amount are grouped
        END
        LAST.TIER.TYPE = NEXT.TIER.TYPE

        IF NEXT.TIER.AMOUNT GE TIER.SOURCE THEN
            EXIT    ;* Stop grouping if base amount is greater than tier amount
        END
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Tier Group Level Calculation>
*** <desc> </desc>
GROUP.LEVEL.CALCULATION:

*** Do corresponding calculation if tier groups is levels
*
*** Only band calculation is needed till the final tier set is reached

    IF TIER.TYPE<1,1> = "BAND" THEN
        GOSUB BAND.CALCULATION
    END

*** If in final tier level is defined then do level calculation

    IF TIER.TYPE<1,1> = "LEVEL" AND I = GRP.CNT THEN
        GOSUB LEVEL.CALCULATION
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Tier Group Band Calculation>
*** <desc> </desc>
GROUP.BAND.CALCULATION:

*** Do corresponding calculation if tier groups is bands

    IF TIER.TYPE<1,1> = "BAND" THEN
        GOSUB BAND.CALCULATION
    END ELSE
        GOSUB LEVEL.CALCULATION
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Group Band and Level>
*** <desc> </desc>
CALCULATE.AMOUNT:

*** Calculate amount based on type of calc defined

    BEGIN CASE
        CASE TYPE.OF.CALC EQ 'PERCENTAGE'
            IF DEFAULT.SOURCE THEN                  ;* Tier base calculation! Final charge amount derived based on rate * default source
                UPDATE.AMOUNT = DEFAULT.SOURCE * CALC.VALUE.TYPE / 100
            END ELSE                                ;* It not tier base calculation
                UPDATE.AMOUNT = REM.AMT * CALC.VALUE.TYPE / 100
            END
            TEMP.CALC.VALUE.TYPE = CALC.VALUE.TYPE:' %'

        CASE TYPE.OF.CALC EQ 'FLAT'
            UPDATE.AMOUNT = CALC.VALUE.TYPE
            TEMP.CALC.VALUE.TYPE = CALC.VALUE.TYPE
        CASE 1
            
            IF DEFAULT.SOURCE THEN      ;* Tier base calculation! Final charge amount derived based on rate * default source
                UPDATE.AMOUNT = DEFAULT.SOURCE * CALC.VALUE.TYPE
            END ELSE                    ;* It not tier base calculation
                UPDATE.AMOUNT = REM.AMT * CALC.VALUE.TYPE
            END
            TEMP.CALC.VALUE.TYPE = CALC.VALUE.TYPE:' Units'

    END CASE

*** For flat tier max amount or tier min amount will not be defined

    CHG.CALC.AMT = UPDATE.AMOUNT

    IF TYPE.OF.CALC NE "FLAT" THEN
        GOSUB CHECK.MIN.MAX.AMOUNT
    END

    CHARGE.AMOUNT += UPDATE.AMOUNT

    GOSUB BUILD.CHARGE.CALC.ARRAY

RETURN
*** </region>
*-----------------------------------------------------------------------------
***<region name = Build CHarge CALC ARRAY>
***<desc> To build charge details </desc>
BUILD.CHARGE.CALC.ARRAY:


    CHARGE.CALC.DETAILS<1, AA.ActivityCharges.ChgTierBalance, CHARGE.POS> = REM.AMT
    CHARGE.CALC.DETAILS<1, AA.ActivityCharges.ChgTierRateOrAmt, CHARGE.POS> = TEMP.CALC.VALUE.TYPE
    CHARGE.CALC.DETAILS<1, AA.ActivityCharges.ChgCalcAmt, CHARGE.POS> = CHG.CALC.AMT
    CHARGE.CALC.DETAILS<1, AA.ActivityCharges.ChgTierMaxAmt, CHARGE.POS> = TIER.MAX.AMOUNT
    CHARGE.CALC.DETAILS<1, AA.ActivityCharges.ChgTierMinAmt, CHARGE.POS> = TIER.MIN.AMOUNT
    CHARGE.CALC.DETAILS<1, AA.ActivityCharges.ChgTierCalcAmt, CHARGE.POS> = UPDATE.AMOUNT

    CHARGE.POS + = 1

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= Group Band and Level>
*** <desc> </desc>
CHECK.MIN.MAX.AMOUNT:

*** Find out if the charge amount for that band falls between tier max and min
*** amount.

    IF TIER.MAX.AMOUNT NE '' AND UPDATE.AMOUNT GT TIER.MAX.AMOUNT THEN
        UPDATE.AMOUNT = TIER.MAX.AMOUNT
    END

    IF TIER.MIN.AMOUNT AND UPDATE.AMOUNT LT TIER.MIN.AMOUNT THEN
        UPDATE.AMOUNT = TIER.MIN.AMOUNT
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.CURRENCY.TOP.AND.MASTER.ACCOUNTS>
*** <desc> </desc>
GET.CURRENCY.TOP.AND.MASTER.ACCOUNTS:

    AA.ProductBundle.CountAddedCurrencyTopAccounts(ARRANGEMENT.ID, '', EFFECTIVE.DATE, NUM.ACCOUNTS)
    
    BASE.AMOUNT += NUM.ACCOUNTS + 1 ;*  add CT and MA

RETURN
*** </region>

END

