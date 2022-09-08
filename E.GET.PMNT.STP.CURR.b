* @ValidationCode : MjotMTkyNTkxMjg2MTpjcDEyNTI6MTU5MTk3MjA5MzE4ODppbmRodW1hdGhpczozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA0LjIwMjAwNDAyLTA1NDk6NDQ6Mzk=
* @ValidationInfo : Timestamp         : 12 Jun 2020 19:58:13
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 39/44 (88.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200402-0549
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.ModelBank

 
SUBROUTINE E.GET.PMNT.STP.CURR

* New routine to return the Payment Stop record's currency.
* This routine will return the value only if the Payment stop for
* that particular account is active.
* Based on this value, the stop payment icon will be displayed in the enquiry

*---------------------------------------------------------------------------------------
* Modification History:
* ---------------------
*
* 27/06/16 - Defect 1715907 / Task 1777382
*            New routine to determine whether the stop payment icon should be displayed or not
*
* 01/09/16 - Defect 1715907 / Task 1847019
*            The return value to not to display the stop payment icon is not returned for cheque revoke
*
* 24/06/19 - Enhancement 3186772 / Task 3186773
*            Product Installation check for CQ.
*
* 12/06/20 - Defect 3777907 / Task 3796459 
*            The stop payment icon must be displayed even if one cheque remains stopped for the account.
*---------------------------------------------------------------------------------------

    $USING EB.Reports
    $USING CQ.ChqPaymentStop
    $USING EB.API
    $USING EB.DataAccess
    $INSERT I_DAS.CHEQUE.REGISTER.SUPPLEMENT
    
    GOSUB CHECK.CQ.INSTALLED
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

*-----------------------------------------------------------------------------

PROCESS:

    IF NOT(EB.Reports.getOData()) THEN
        GOSUB GET.ACCT.ID
    END ELSE
        ACCT.ID = EB.Reports.getOData()
    END


* Check whether the payment stop record is available for the particular account
* If the record is available, check for the history record (PAYMENT.STOP.HIS).
* i.e. If the stop end flag is set in payment.stop record, then the his record
* will be updated
*

    IF CQInstalled THEN
        R.PAYMENT.STOP = CQ.ChqPaymentStop.PaymentStop.Read(ACCT.ID, PAYMNT.STOP.ERR)
        PAYMT.STOP.CURR = R.PAYMENT.STOP<CQ.ChqPaymentStop.PaymentStop.AcPayCurrency>

        EB.Reports.setOData(PAYMT.STOP.CURR)

        IF NOT(PAYMNT.STOP.ERR) AND NOT(R.PAYMENT.STOP<CQ.ChqPaymentStop.PaymentStop.AcPayPaymStopType>) THEN
            GOSUB CHECK.PAYMNT.STOP.HIST
        END
    END

RETURN

*-----------------------------------------------------------------------------

CHECK.PAYMNT.STOP.HIST:

* Check whether the account has any stopped cheque in cheque register supplement to indicate the stop payment icon in enquiry

    TABLE.NAME = 'CHEQUE.REGISTER.SUPPLEMENT'
    TABLE.SUFFIX = ''
    CRS.LIST = dasChequeRegisterSupplement$AccountWithStatus
    THE.ARGS = ACCT.ID :@FM:"STOPPED"
    
    EB.DataAccess.Das(TABLE.NAME,CRS.LIST,THE.ARGS,TABLE.SUFFIX)
    
* Check for the stop end flag in PAYMENT.STOP.HIS record
*
    
    R.PAY.STP.HIS = CQ.ChqPaymentStop.PaymentStopHist.Read(ACCT.ID, PAYM.HIS.ERR)

    IF R.PAY.STP.HIS AND R.PAY.STP.HIS<CQ.ChqPaymentStop.PaymentStopHist.AcPayHistApplyDate> NE "" AND NOT(CRS.LIST) THEN
        EB.Reports.setOData("")
    END

RETURN

*-----------------------------------------------------------------------------

INITIALISE:

    R.PAYMENT.STOP = ''
    PAYMNT.STOP.ERR = ''
    ACCT.POS = ''
    ACCT.ID = ''
    R.PAY.STP.HIS = ''
    PAYM.HIS.ERR = ''

RETURN

*-----------------------------------------------------------------------------

GET.ACCT.ID:

    LOCATE "@ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ACCT.POS THEN
        ACCT.ID = EB.Reports.getEnqSelection()<4,ACCT.POS>
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.CQ.INSTALLED:
*-----------------------------------------------------------------------------
    
    productId = 'CQ'
    CQInstalled = ''
    EB.API.ProductIsInCompany(productId, CQInstalled)
RETURN
*-----------------------------------------------------------------------------

END





