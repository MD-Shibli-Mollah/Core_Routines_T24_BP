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
* <Rating>-103</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.PaymentSchedule
    SUBROUTINE AA.LOCAL.PAYMENT.TYPE.ROUTINE(ARRANGEMENT.ID, PAYMENT.PROPERTIES, R.PAYMENT.SCHEDULE, PAYMENT.DATE, PAYMENT.AMOUNTS, RET.ERR)
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This routine the routine used for calculate the payment interest and
** principle amount for the period.
** For example in this routine we are divided the interest by 2 and pass
** this as a interest amount, for principle we are not doing anything
** This mechanism is a defererrd interest and the remaining interest amount goes to
** RES account type.
** For a final payment schedule we add a defererred interest amount and calculated interest amount.
*-----------------------------------------------------------------------------
* @package retaillending.AA
* @class AA.PaymentSchedule
* @stereotype subroutine
* @link AA.BUILD.PAYMENT.SCHEDULE.SCHEDULES
* @author sivakumark@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param  Arrangement id             Arrangement contract id
* @param  Payment property           It's contain a property name
* @param  Paymentschedule            Repayment property for which schedule dates are required
* @param  Payment date               If property and property date are not passed
* @param  Payment amount             The calculated amount passed(Used as a incoming and outgoing)
* @param  RET.ERROR                  Error code
* New set of values are being passed through common variables instead of adding in the argument
* @param  final payment date         contains the payment end date (used to find the payment amount value for each property)
* @param  previouspaydate            contains the previous payment date
* @param  paymenttype                contains the payment types for the arrangement
* @param  paymentpropertieslist      contains the whole property list for all payment types
* @param  paymentpropertyamounts     returns the property amount
* @param  lastaccdate                contains the last accrual date
* @param  presentvalue               contain the outstanding balance
* @param  defintdetail               contain the RES balance
*
* Output
*
* @return Payment amount    The calculated amount passed(Used as a incoming and outgoing)
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*

* 28/01/14 - Ref 480649
*            Task 741288
*            Newe argument for AA.CALC.INTEREST.
*
* 12/05/14  - Enhancement : 713751
*             Task : 1003629
*             Charge-off Interest accrual processing. New argument added for chargeoff type
*
* 21/05/15 - Task : 1352503
*            Defect : 1352489
*            Residual setup has been moved to LOANINTEREST1, hence changed the hardcoded INTEREST property.
*
* 03/11/15 - Task : 1521032
*            Defect : 1518719 
*            Compilation Issue in TAFC
*
* For previous modification history refere to older revision 1.23
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Interest
    $USING EB.API
    $USING AC.Fees
    $USING AA.PaymentSchedule
    
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS.INTEREST
    GOSUB PROCESS.PRINCIPAL

    RETURN

*** </region>
*-----------------------------------------------------------------------------
INITIALISE:

    R.ACCRUAL.DATA = ""       ;*Variable to hold the interest accrual record
    CALC.INTEREST.AMOUNT = "" ;* Variable hold the new calculated interest amount(i.e User defined)
    PAYMENT.PROPERTY = 'LOANINTEREST1'   ;* Value hard coded for the testing purpose(It should be on property name for which property amount we need to store RES)
    PRINCIPAL.PROPERTY = 'LOANACCOUNT'  ;* Value hard coded for the testing purpose
    ARR.CCY = "USD" ;* Value hardcoded for testing purpose, it should be an arrangement currency
    Y.INT.AMOUNT = ""         ;* Variable hold the interest accrual amount
    SMI.POS = ""    ;* used to find the corresponding position to store the payment amount
    SMP.POS = ""    ;* used to find the corresponding position to store the payment amount
    CALC.PRINCIPAL.AMOUNT = ""          ;* Variable hold the new calculated principal amount
    Y.CURR.INT.AMOUNT = ""
    Y.RET.ERROR = ""

    RETURN
*-----------------------------------------------------------------------------

*** <region name= Interest Process Gosub>
*** <desc>Interest calculate Process logic in the sub-routine</desc>
PROCESS.INTEREST:


    IF AA.PaymentSchedule.getLastAccDate() THEN     ;* Do not create un-ncessary vm (value marker)
        R.ACCRUAL.DATA<AC.Fees.EbAcToDate,1> = AA.PaymentSchedule.getLastAccDate()
    END

    tmp.PREVIOUS.PAY.DATE = AA.PaymentSchedule.getPreviousPayDate()
    AA.Interest.CalcInterest(ARRANGEMENT.ID, PAYMENT.PROPERTY, "", "" , tmp.PREVIOUS.PAY.DATE, PAYMENT.DATE, R.ACCRUAL.DATA, Y.INT.AMOUNT, Y.CURR.INT.AMOUNT, "",Y.RET.ERROR)     ;* interest amount to be calculated for every period
    AA.PaymentSchedule.setPreviousPayDate(tmp.PREVIOUS.PAY.DATE)

    IF PAYMENT.DATE EQ AA.PaymentSchedule.getFinalPaymentDate() THEN
        CALC.INTEREST.AMOUNT =  Y.INT.AMOUNT + AA.PaymentSchedule.getDefIntDetail()         ;* for a last period the whole interest should be taken along with Interest Stock any
    END ELSE
        CALC.INTEREST.AMOUNT = Y.INT.AMOUNT /2    ;* for all periods except last period we can calculate new interest amount
    END

    IF CALC.INTEREST.AMOUNT THEN
        EB.API.RoundAmount(ARR.CCY, CALC.INTEREST.AMOUNT, '', '')
    END

    LOCATE PAYMENT.PROPERTY IN AA.PaymentSchedule.getPaymentPropertiesList()<1,1,1> SETTING SMI.POS THEN
    tmp=AA.PaymentSchedule.getPaymentPropertyAmounts(); tmp<1,1,SMI.POS>=CALC.INTEREST.AMOUNT; AA.PaymentSchedule.setPaymentPropertyAmounts(tmp);* to store a amount for the corresponding property in the corresponding payment type
    END

    RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Principal process Gosub>
*** <desc>Calculate principal Process logic in the sub-routine</desc>
PROCESS.PRINCIPAL:

    IF PAYMENT.DATE NE AA.PaymentSchedule.getFinalPaymentDate() THEN
        CALC.PRINCIPAL.AMOUNT = PAYMENT.AMOUNTS - CALC.INTEREST.AMOUNT          ;* For every periods except last payment date the principle amount should be an current principle subtract to new interest amount
    END ELSE
        CALC.PRINCIPAL.AMOUNT = AA.PaymentSchedule.getPresentValue()     ;* for last repayment date it should take the current principle , used to avoid routing value
    END

    LOCATE PRINCIPAL.PROPERTY IN AA.PaymentSchedule.getPaymentPropertiesList()<1,1,1> SETTING SMP.POS THEN
    tmp=AA.PaymentSchedule.getPaymentPropertyAmounts(); tmp<1,1,SMP.POS>=CALC.PRINCIPAL.AMOUNT; AA.PaymentSchedule.setPaymentPropertyAmounts(tmp);* to store a amount for the corresponding property in the corresponding payment type
    END

*Make Sure that the payment amount is sum of individual property amounts
* as there may be rounding difference between system passed amount and individual property amounts on payment end date
    PAYMENT.AMOUNTS = SUM(AA.PaymentSchedule.getPaymentPropertyAmounts())

    RETURN

*** </region>
*-----------------------------------------------------------------------------
    END
