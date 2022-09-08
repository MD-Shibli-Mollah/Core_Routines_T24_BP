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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.GET.LAST.RENEW.DATE
*---------------------------------------------------------------------------
* To get last multi value of LAST.RENEW.DATE
*------------------------------------------------

    $USING AA.PaymentSchedule
    $USING EB.Reports


** Get the renew date from the account details record
** in some cases Renewal date field will have multiple dates. But in over view screen we need to display the latest date.
** So DCOUNT the number of dates and take the last date from this multi value field.

    LAST.RENEW.DATE = EB.Reports.getRRecord()<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
    NO.DATES = DCOUNT(LAST.RENEW.DATE,@VM)
    EB.Reports.setOData(LAST.RENEW.DATE<1,NO.DATES>)

    RETURN

    END
