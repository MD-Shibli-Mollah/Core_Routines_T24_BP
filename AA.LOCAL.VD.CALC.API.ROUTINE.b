* @ValidationCode : MjotMTQwNjAzMzUxMDpDcDEyNTI6MTU4Njc3NzcxMDc1MDp2dmlqYXlhcmFzdTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2020 17:05:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vvijayarasu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-126</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.PaymentRules
SUBROUTINE AA.LOCAL.VD.CALC.API.ROUTINE(ARRANGEMENT.ID,BILL.ID,R.AA.BILL.DETAILS,ADJUSTED.VALUE.DATE)
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This routine is developed to test the value dated adjustement SAR done for WLB.
** This routine will be fired from Apply Payment activity to adjust the value date of accounting entries
** that are raised for repayment of an EXPECTED bill type.
** Routine Mechanism:-
** When a payment of a expected bill is made within the grace period then this payment's value date will be
** adjusted to due date of the bill.
** When a payment of a expected bill is made after the grace period then this payment's value date will be
** adjusted to next due date of the bill.
** This is purely for the Interest calculation of Pleasure savings deposit type.
** -------------------------------------------------------------
** Scenario 1
** --------------------------------------------------------------
** Today's Date : 04/08/2012
** Grace        : 5 Days
** Due Date     : 01/08/2012
** Amount Due   : 1,000.00
** Bill Status  : Due
** Value Date of the Repayment for 1,000.00 in AA will be 01/08/2012 though the payment was made on 04/08/2012
** -------------------------------------------------------------
** Scenario 2
** --------------------------------------------------------------
** Today's Date : 04/09/2012
** Grace        : 5 Days
** Due Date     : 01/08/2012
** Amount Due   : 1,000.00
** Bill Status  : Overdue
** Due Date     : 01/09/2012
** Amount Due   : 1,000.00
** Bill Status  : Due
** Value Date of the Repayment for 2,000.00 in AA will be 01/09/2012 though the payment was made on 04/09/2012
** -------------------------------------------------------------
** Scenario 3
** --------------------------------------------------------------
** Today's Date : 07/09/2012
** Grace        : 5 Days
** Due Date     : 01/08/2012
** Amount Due   : 1,000.00
** Bill Status  : Overdue
** Next Due Date: 01/10/2012
** Value Date of the Repayment for 1,000.00 in AA will be 01/10/2012 though the payment was made on 04/09/2012
*-----------------------------------------------------------------------------
* @package retaillending.AA
* @class AA.PaymentRules
* @stereotype subroutine
* @link AA.APPLY.PAYMENT.RULES
* @author vaigaivalavan@temenos.com
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
* @param  Bill Reference             Bill Reference that is processed during applypayment activity.
* @param  Bill Details               Bill Details record of the bill reference
*
* Output
*
* @return Adjusted Value Date    Returns adjusted value date that will be used for accounting instead of activity effective date.
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Overdue
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.Framework


*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise Gosub>
*** <desc>Value date calculation logic defined here</desc>
INITIALISE:
***********

    EFFECTIVE.DATE = AA.Framework.getC_aalocactivityeffdate()       ;* Activity Effective Date.
    R.AA.ACCOUNT.DETAILS = AA.Framework.getC_aalocaccountdetails()  ;* AA Account Details of the Arrangement.
    BILL.TYPE.CNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillType>,@VM)
    ADJUSTED.VALUE.DATE = ""
    R.PAYMENT.SCHEDUE = ""
    R.OVERDUE = ""

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Gosub>
*** <desc>Value date calculation logic defined here</desc>
PROCESS:
********

    LOOP
    WHILE BILL.TYPE.CNT GT 0
        BILL.TYPE = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillType,BILL.TYPE.CNT>
        PAYMENT.TYPE = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType,BILL.TYPE.CNT>
        AA.PaymentSchedule.GetSysBillType(BILL.TYPE, SYS.BILL.TYPE, RET.ERROR)
        IF SYS.BILL.TYPE EQ "EXPECTED" THEN
            GOSUB GET.OVERDUE.SETUP
            IF OD.STATUS THEN
                GOSUB CHECK.VALUE.DATE.ADJUSTMENT
            END
        END
        BILL.TYPE.CNT--
    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Overdue Setup Gosub>
*** <desc>Paragraph to get the Overdue conditions of the arrangement</desc>
GET.OVERDUE.SETUP:
******************

    PROPERTY.CLASS = "OVERDUE"
    GOSUB GET.PROPERTY.RECORD
    R.OVERDUE = R.PROPERTY.RECORD

    LOCATE BILL.TYPE IN R.OVERDUE<AA.Overdue.Overdue.OdBillType,1> SETTING BILLTYPEPOS THEN
        OD.STATUS = R.OVERDUE<AA.Overdue.Overdue.OdOverdueStatus,BILLTYPEPOS,1>
    END ELSE
        OD.STATUS = ""
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Calc Repayment Value Date Gosub>
*** <desc>Paragraph to get the Latest Bill's payment date of EXPECTED bill Type from the AA Account Details</desc>
CALC.REPAY.VALUE.DATE:
**********************

    IF BILL.STATUS EQ "AGING" THEN
        PROPERTY.CLASS = "PAYMENT.SCHEDULE"
        GOSUB GET.PROPERTY.RECORD
        R.PAYMENT.SCHEDULE = R.PROPERTY.RECORD
        SCHEDULE.INFO<1> = ARRANGEMENT.ID
        SCHEDULE.INFO<2> = EFFECTIVE.DATE
        SCHEDULE.INFO<4> = LOWER(R.PAYMENT.SCHEDULE)
        NEXT.PAYMENT.DATE = ""
        AA.PaymentSchedule.BuildNextPaymentScheduleDate(SCHEDULE.INFO, PAYMENT.TYPE, "", "", NEXT.PAYMENT.DATE, "", RET.ERROR)
        ADJUSTED.VALUE.DATE = NEXT.PAYMENT.DATE
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check Value date Adjustment Gosub>
*** <desc>Paragraph to set the calculated value date in the return argument</desc>
CHECK.VALUE.DATE.ADJUSTMENT:
****************************

    BILL.CNT = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillPayDate>,@VM)

    LOOP
    WHILE BILL.CNT GT 0
        LOCATE BILL.TYPE IN R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillType,BILL.CNT,1> SETTING BILLTYPEPOS THEN
            BILL.STATUS = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillStatus,BILL.CNT,BILLTYPEPOS>
            ADJUSTED.VALUE.DATE = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillPayDate,BILL.CNT>
            GOSUB CALC.REPAY.VALUE.DATE
            BILL.CNT = 0
        END
        BILL.CNT --
    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Property Record Gosub>
*** <desc>Common Paragraph to get the Property record of the arrangement.</desc>
GET.PROPERTY.RECORD:
********************

    R.PROPERTY.RECORD = ""
    REC.ERROR = ""
    AA.ProductFramework.GetPropertyRecord("", ARRANGEMENT.ID, "", EFFECTIVE.DATE, PROPERTY.CLASS, "", R.PROPERTY.RECORD, REC.ERROR)

RETURN

*** </region>
*-----------------------------------------------------------------------------
END
