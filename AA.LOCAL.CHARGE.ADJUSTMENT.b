* @ValidationCode : Mjo1MTg1Nzg2MDc6Q3AxMjUyOjE1NTM2ODE2NzIwODE6c3VkaGFyYW1lc2g6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMi4yMDE5MDExNy0wMzQ3OjUxOjQz
* @ValidationInfo : Timestamp         : 27 Mar 2019 15:44:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 43/51 (84.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190117-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


    $PACKAGE AA.Fees

    SUBROUTINE AA.LOCAL.CHARGE.ADJUSTMENT(ARRANGEMENT.ID, ARR.CCY, EFFECTIVE.DATE, CHARGE.PROPERTY, CHARGE.TYPE, R.CHARGE.RECORD, BASE.AMOUNT, PERIOD.START.DATE, PERIOD.END.DATE, SOURCE.ACTIVITY, CHARGE.AMOUNT, ADJUSTED.CHARGE.AMOUNT, NEW.CHARGE.AMOUNT, ADJUSTMENT.REASON)

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This program will calculate the charge amount on pro-rata basis
** Sample API to adjust the charge calculated by the core engine.
*
** In order to adjust the calculated charge this routine should be attached in the field
** CHARGE.OVERRIDE.ROUTINE in the AA.XXX.CHARGE application.
*
*-----------------------------------------------------------------------------
* @class AA.ActivityMessaging
* @package retaillending.AA
* @stereotype subroutine
* @author shyamjith@temenos.com
*-----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
* Input
*
* ARRANGEMENT.ID           - Arrangement ID of the contract.
* EFFECTIVE.DATE           - Activity effective date
* CHARGE.PROPERTY          - Charge property on which the adjustment has to be done.
* CHARGE.TYPE              - Charge property type
* R.CHARGE.RECORD          - Arrangement charge condition
* BASE.AMOUNT              - Arrangement base balance or count
* PERIOD.START.DATE        - Start of the period within which charges have to be calculated
* PERIOD.END.DATE          - End of the period
* SOURCE.ACTIVITY          - Activity references
* CHARGE.AMOUNT - Core calculated charge amount
*
* Output
*
* ADJUSTED.CHARGE.AMOUNT   - Adjusted charge amount based on this routine's logic.
* NEW.CHARGE.AMOUNT        - Return the new Amount after doing the adjustment, this will be treated as the new charge amount by core.
* ADJUSTMENT.REASON        - Reason for the charge adjustment, if not reason specified then send back the API's description or API name (from EB.API)
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Modification History>
*** <desc>Changes done in the sub-routine</desc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 16/02/16 - Task : 1649927
*            Enhancement : 1033356
*            New local API routine to adjust the calculated charge.
*
* 29/04/16 - Defect : 1715806
*            Task : 1716411
*            TAFC Compilation Errors
*
*-----------------------------------------------------------------------------

    $USING AA.ProductFramework
    $USING EB.API
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.Fees
    $USING AF.Framework
    
*-----------------------------------------------------------------------------

    GOSUB INITIALISE ;*Initialise the local variables

    IF CHARGE.AMOUNT THEN
        GOSUB DO.ADJUSTMENT ;*Adjust the charge amount based on pro-rata calculation
    END

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the local variables </desc>

    ADJUSTED.CHARGE.AMOUNT = ""
    NEW.CHARGE.AMOUNT = ""
    ADJUSTMENT.REASON = ""

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= DO.ADJUSTMENT>
DO.ADJUSTMENT:
*** <desc>Adjust the charge amount based on pro-rata calculation </desc>

    GOSUB BUILD.SCHEDULE.INFO ;* Find the Payment Schedule property.
    GOSUB GET.NEXT.SCHEDULE.DATE ;* Find the next schedule date.
    GOSUB CALCULATE.CHARGE ;* Calculate the charge based on Pro-Rata calculation.

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.NEXT.SCHEDULE.DATE>
CALCULATE.CHARGE:
*** <desc> Calculate the charge based on the Pro-Rata calculation </desc>

    NO.OF.MONTHS = 1 ;* 0 or "" => do not process for broken month, 1 => process for broken month

    CALL EB.NO.OF.MONTHS(EFFECTIVE.DATE, NEXT.SCHEDULE.DATE, NO.OF.MONTHS) ;*Calculate the Number of months between these 2 dates.

    IF NO.OF.MONTHS NE "12" THEN ;* Charge has already been calculated for 12 months, so no need to adjust it again.
        NEW.CHARGE.AMOUNT = (CHARGE.AMOUNT * NO.OF.MONTHS) / 12
        GOSUB ROUND.CHARGE.AMOUNT
        ADJUSTED.CHARGE.AMOUNT = CHARGE.AMOUNT - NEW.CHARGE.AMOUNT
        ADJUSTMENT.REASON = "Pro-rated for ":NO.OF.MONTHS:" Months"
    END ELSE
        NEW.CHARGE.AMOUNT = CHARGE.AMOUNT
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= Round charge amount>
*** <desc> </desc>
ROUND.CHARGE.AMOUNT:
        
    IF R.CHARGE.RECORD<AA.Fees.Charge.RoundingRule> THEN    
        ROUNDING.RULE = R.CHARGE.RECORD<AA.Fees.Charge.RoundingRule>    
        EB.API.RoundAmount(R.CHARGE.RECORD<AA.Fees.Charge.Currency>, NEW.CHARGE.AMOUNT, "", ROUNDING.RULE)
    END ELSE
        EB.API.RoundAmount(ARR.CCY, NEW.CHARGE.AMOUNT, "", "")
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.NEXT.SCHEDULE.DATE>
GET.NEXT.SCHEDULE.DATE:
*** <desc> Get the next schedule date for the given charge property </desc>

    NO.OF.CYCLES = 2
    CHECK.CHARGE.PROPERTY = CHARGE.PROPERTY
    AA.PaymentSchedule.BuildPaymentScheduleDates(SCHEDULE.INFO, EFFECTIVE.DATE, "", NO.OF.CYCLES, "", PAYMENT.DATES, "", "", "", "", "", CHECK.CHARGE.PROPERTY, "", "", "", "", RET.ERROR)

    TOT.DATES = DCOUNT(PAYMENT.DATES,@FM)

    FOR DATE.CNT = 1 TO TOT.DATES UNTIL NEXT.SCHEDULE.DATE
        IF PAYMENT.DATES<DATE.CNT> GT EFFECTIVE.DATE THEN
            NEXT.SCHEDULE.DATE = PAYMENT.DATES<DATE.CNT> ;* Dates would be in ascending order, so loop through the dates and find the nearest schedule date for the Charge property
        END
    NEXT DATE.CNT

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.PAYMENT.SCHEDULE.PROPERTY>
BUILD.SCHEDULE.INFO:
*** <desc> Get the payment schedule record </desc>

    SCHEDULE.INFO<1> = ARRANGEMENT.ID
    SCHEDULE.INFO<2> = EFFECTIVE.DATE

    IF AA.Framework.getPropertyClassId() EQ "PAYMENT.SCHEDULE" THEN      ;* If Property Class equal to payment schedule then get the property id from the common variable
        SCHEDULE.INFO<3> = AF.Framework.getPropertyId()
    END ELSE
        * Get the payment schedule property name

        R.PRODUCT.RECORD = AF.Framework.getProductRecord()
        AA.ProductFramework.GetPropertyName(R.PRODUCT.RECORD, "PAYMENT.SCHEDULE", PS.PROPERTY.NAME)
        SCHEDULE.INFO<3> = PS.PROPERTY.NAME
    END

    RETURN

*** </region>

    END
