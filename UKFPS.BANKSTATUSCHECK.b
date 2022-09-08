* @ValidationCode : MjoyMTI5MTI1Nzg5OkNwMTI1MjoxNTY4MDEyNzQzOTg1OmtlZXJ0aGFuYWQ6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOS4yMDE5MDgyMy0wMzA1OjE3OjE3
* @ValidationInfo : Timestamp         : 09 Sep 2019 12:35:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : keerthanad
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 17/17 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.20190823-0305
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPUFPS.Foundation
SUBROUTINE UKFPS.BANKSTATUSCHECK(iTxnContext,output,oResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History : 05/09/2019 - Enh 3236643 / Task 3320790
*                                     Handled logic to form the institution id.
*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowGUI
*-----------------------------------------------------------------------------
    
    GOSUB process
    
RETURN
*-----------------------------------------------------------------------------
process:
    iDbtCdtDetails = RAISE(iTxnContext<1>)
    companyID = iDbtCdtDetails<PPUFPS.Foundation.DbtCdtDetails.companyID>
    ftNumber = iDbtCdtDetails<PPUFPS.Foundation.DbtCdtDetails.ftNumber>
    
    output = ''
    oResponse = ''
* Read the payment flow details table and fetch the value of HandlingBankConnection and HandlingBankCode from the local ref fields to form the institution id
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS',ftNumber,'',R.POR.SUPP.INFO,Error)
        
    IF R.POR.SUPP.INFO NE '' THEN
        LOCATE "HandlingBankConnection" IN R.POR.SUPP.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname,1> SETTING VmPos THEN
            output = R.POR.SUPP.INFO <PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue,VmPos>
        END
        LOCATE "HandlingBankCode" IN R.POR.SUPP.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname,1> SETTING VmPos THEN
            output = output:R.POR.SUPP.INFO <PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue,VmPos>
        END
    END

RETURN
*-----------------------------------------------------------------------------
END
