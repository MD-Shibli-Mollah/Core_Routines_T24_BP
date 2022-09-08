* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-186</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Fees
    SUBROUTINE AA.LOCAL.CALC.CHARGE.AMOUNT(CHARGE.PROPERTY,R.PROPERTY.RECORD,BASE.AMOUNT,CHARGE.AMOUNT)
* ----------------------------------------------------------------------------------------------------------
* This is a sample API with a simple calculation method to apply charge as early redemption penalty.
* Sample calculation method:
*   Principal Amount - 10000
*   Interest Period Start date - 1st June 2010
*   Interest Period End date - 15th June 2010
*   Current Date - 10th June 2010
*   Withdrawal Amount - 4000
*   Day basis - E
*   Interest Rate - 6%
*                  ==================================
*      Charge Amount = (4000 * 10 * 6%) / 365 = 5.47
*                  ==================================
* Incoming arguments
* 1.   Charge property - Property name for charge property class
* 2.   Charge record - Charge record of the corresponding charge property
* 3.   Base Amount - Base amount on top of which charge is calculated
*                  As per our example
*                  Base amount <1> = 10000 (TOTAL COMMITMENT)
*                  Base amount <2> = 6000  (COMMITMENT AFTER REPAYMENT)
*                  Base amount <3> = 2500  (REPAYMENT BEYOND TOLERANCE %)
* Assuming a rule break charge with 15% tolerance for repayment is set, the third argument will carry
* the (repayment.amount - tolerance % amount ) which is (4000 - 1500) = 2500. In our example interest
* will be calculated above this amount.
*
* Outgoing
* 4.    Charge amount - Charge amount calculated
*
*----------------------------------------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 22/05/15 - Enhancement - 1277976
*            Task - 1300622
*            New argument added for the routine AA.BUILD.INTEREST.INFO
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AC.Fees
    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.ProductFramework


*** </region>
*-----------------------------------------------------------------------------
*
*
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*
*-----------
INITIALISE:
*-----------
*initialisation of variables from local common

    ARRANGEMENT.ID =  AA.Framework.getC_aalocarrid()      ;* Arrangement contract Id
    EFFECTIVE.DATE =  AA.Framework.getC_aalocactivityeffdate()      ;* Arrangement Activity effective date
    PROPERTY =  AA.Framework.getC_aalocactivityid()<AA.Framework.ActObject>  ;*payment rule property
    PRODUCT.RECORD = AA.Framework.getC_aalocproductrecord()         ;*product record
    R.ACCOUNT.DETAILS = AA.Framework.getC_aalocaccountdetails()     ;*AA.ACCOUNT.DETAILS
    ACCOUNT.ID = AA.Framework.getC_aaloclinkedaccount()   ;* Account Id
    TXN.AMOUNT = AA.Framework.getC_aalocarractivityrec()<AA.Framework.ArrangementActivity.ArrActTxnAmount>
    ARR.CURRENCY = AA.Framework.getC_aalocarrcurrency()   ;* Arrangement currency
* Get the amount
    BASE.AMOUNT  = BASE.AMOUNT<3>

    RETURN
*-----------
PROCESS:
*-----------
* As this example routine levies the charge as interest till today
* we first calculate the interest
    BEGIN CASE
            * Add more cases according to the requirement
        CASE 1
            GOSUB GET.INTEREST.PROPERTY
            GOSUB BUILD.INTEREST.DETAILS
            GOSUB CALCULATE.CHARGE
    END CASE

    RETURN

*---------------------
GET.INTEREST.PROPERTY:
*---------------------
* Identify the PRINCIPLE interest property name.
* Schedules are defined only for Principle interest, so identify the principle
* interest property name from the PAYMENT.SCHEDULE property record.
* AA.GET.ARRANGEMENT.CONDITIONS is called with arrangement id and property /property class
* and the return value is as follows
* i.    If property class alone is passed then property record for all the properties are
*        returned separated by field marker
* ii.   If property is passed then property record for the particular property is returned.
* iii.  If effective date is passed then property record as on effective date is passed.
* iv.   If effective date is not passed latest record for the property is returned.



    THIS.PROPERTY.CLASS = "PAYMENT.SCHEDULE"      ;*  OPTIONAL ARGUMENT. Property class to be supplied if Property not passed.
    THIS.PROPERTY = ""        ;*  OPTIONAL ARGUMENT. Property require must be supplied, if PropertyClass is not passed.
    PROPERTY.LIST = ""        ;*  OUT ARGUMENT -- returns list of property ids sep by FM.
    PROPERTY.RECORD = ""      ;*  OUT ARGUMENT -- returns LOWERed records associated with returnIds.
    PROPERTY.ERROR      = ""  ;*  OUT ARGUMENT -- returns if any error conditions found


    GOSUB GET.ARRANGEMENT.CONDITIONS

    PR.CLASS.POS = '';
*
    R.SCHEDULE.PROPERTY = RAISE(PROPERTY.RECORD)
    SCH.PROPERTY.LIST = R.SCHEDULE.PROPERTY<AA.PaymentSchedule.PaymentSchedule.PsProperty>
*
    PROP.CNT = 1 ; PROP.CNT.FOUND = 1
    LOOP
    WHILE (SCH.PROPERTY.LIST<1,1,PROP.CNT> AND PROP.CNT.FOUND)
        SCH.PROPERTY = SCH.PROPERTY.LIST<1,1,PROP.CNT>
        SCH.PROPERTY.CLASS = ""

        * AA.GET.PROPERTY.CLASS gets the input argument as PROPERTY.NAME and RETURNS the PROPERTY.CLASS.NAME

        GOSUB GET.PROPERTY.CLASS

        IF SCH.PROPERTY.CLASS = "INTEREST" THEN
            PROP.CNT.FOUND = 0
        END
        PROP.CNT += 1
    REPEAT
    INTEREST.PROPERTY = SCH.PROPERTY

    RETURN

*-----------------------
BUILD.INTEREST.DETAILS:
*-----------------------
* Get interest rate and interest day basis by calling AA.BUILD.INTEREST.INFO

* The routine AA.BUILD.INTEREST.INFO takes arrangement id and interest property name as incoming argumnet
* and returns the output argument as explained against the argument names below.

    INT.DATA = ""   ;* OUT ARGUMENT Returns interest data (rates, keys, spreads, band/level info, etc)
    INT.BASIS.DATA = ""       ;* OUT ARGUMENT Returns interest basis data
    ACCRUAL.RULE  = ""        ;* OUT ARGUMENT Accrual rule defined in interest property

    GOSUB BUILD.INTEREST.INFO

    DATA.POS = 0

* get interest rate
    LOCATE EFFECTIVE.DATE IN INT.DATA<AC.Fees.EbAciIntEffDate,1> SETTING DATE.POS THEN
    INTEREST.RATE = INT.DATA<AC.Fees.EbAciIntRate,DATE.POS,1>
    END

* get interest day basis from interest record
    INT.DAY.BASIS = R.INTEREST<1,AA.Interest.Interest.IntDayBasis>

* Get periodic start date by calling AA.GET.INTEREST.ACCRUALS
    REQUEST.TYPE = "VAL"

    GOSUB GET.INTEREST.ACCRUALS

    LOCATE EFFECTIVE.DATE IN R.ACCRUAL.DETAILS<AA.Interest.InterestAccruals.IntAccPeriodEnd, 1> BY 'AR' SETTING CURR.PERIOD ELSE
    NULL
    END
    PERIOD.START.DATE=R.ACCRUAL.DETAILS<AA.Interest.InterestAccruals.IntAccPeriodStart, CURR.PERIOD>

    RETURN

*-------------------
CALCULATE.CHARGE:
*------------------
** EB.INTEREST.CALC routine will return an interest amount based on a given
** base amount at a specified rate.
** It will also return the rounded amount if the currency code is
** passed.
** PARAMETERS:
** IN - START.DATE :- Start date of interest period
**      END.DATE   :- End date of interest period
**      RATES      :- Interest Rate
**      BASE.AMTS  :- Principal amount
**      DAY.BASIS  :- Interest DAY BASIS currently ABEF
**             <2> :- Alternative Days in Year
**             <3> :- Compound Calculation
**      CCY        :- Currency for rounding
**      ROUND.TYPE :- The parameter to be used for EB.ROUND.AMOUNT
**                 :  1 for currency, 2 for cash, null for no decimals
**
**             <2> :  Some applications calls EB.ROUND.AMOUNT with 'U' for round-up
**                 :  'D' or 'L' for round-down, if this is not set it will use
**                 :  natural rounding, unless a rounding type is specified at
**                 :  the currency.
**
**             <3> :  If the rounding rule to be used is not linked to the currency
**                 :  definition, then the ID to EB.ROUNDING.RULE should be passed.
***
**      CUSTOMER   :- Customer no (future use)
*       ACCR.DAYS  :- No of days to be added to interest calculation, may
*                     be null
*       INT.AMTS   :- Accrued interest to date (for use in compound calc)
**
** OUT -ACCR.DAYS  :- No of days between start and end date
**      INT.AMTS   :- The interest amount calculated unrounded
**      ROUND.AMTS :- The rounded int amt if CCY is passed
**
** If an error is found then ETEXT

    IF NOT(BASE.AMOUNT) THEN
        BASE.AMOUNT = 0
    END

    ACCR.DAYS = "";ROUND.TYPE = "";CUSTOMER = ""

    AC.Fees.EbInterestCalc(PERIOD.START.DATE,EFFECTIVE.DATE,INTEREST.RATE,BASE.AMOUNT,INT.AMOUNT,ACCR.DAYS,INT.DAY.BASIS,ARR.CURRENCY,ROUND.INT.AMOUNT, ROUND.TYPE, CUSTOMER)

    CHARGE.AMOUNT = ROUND.INT.AMOUNT

    RETURN
*--------------------------
GET.ARRANGEMENT.CONDITIONS:
*--------------------------
* Get interest rate and interest day basis by calling AA.BUILD.INTEREST.INFO

    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID,THIS.PROPERTY.CLASS,THIS.PROPERTY,EFFECTIVE.DATE,PROPERTY.LIST,PROPERTY.RECORD,PROPERTY.ERROR)

    RETURN
*------------------
GET.PROPERTY.CLASS:
*------------------
* AA.GET.PROPERTY.CLASS gets the input argument as PROPERTY.NAME and RETURNS the PROPERTY.CLASS.NAME

    AA.ProductFramework.GetPropertyClass(SCH.PROPERTY,SCH.PROPERTY.CLASS)

    RETURN
*-------------------
BUILD.INTEREST.INFO:
*-------------------
* Get interest rate and interest day basis by calling AA.BUILD.INTEREST.INFO

    AA.Interest.BuildInterestInfo(ARRANGEMENT.ID,INTEREST.PROPERTY,"",EFFECTIVE.DATE,R.INTEREST,INT.DATA,INT.BASIS.DATA,ACCRUAL.RULE,"")

    RETURN

*---------------------
GET.INTEREST.ACCRUALS:
*----------------------
* Get periodic start date by calling AA.GET.INTEREST.ACCRUALS

    AA.Interest.GetInterestAccruals(REQUEST.TYPE, ARRANGEMENT.ID, INTEREST.PROPERTY, "", "", R.ACCRUAL.DETAILS, '', "")

    RETURN

    END
