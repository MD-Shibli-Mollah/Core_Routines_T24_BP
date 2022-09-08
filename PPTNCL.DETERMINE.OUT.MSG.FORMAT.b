* @ValidationCode : MjotMTU4Nzk1MTQxNzpDcDEyNTI6MTYwMzI4NDI2MDg0ODpzYXJtZW5hczo2OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6Mzg6Mzg=
* @ValidationInfo : Timestamp         : 21 Oct 2020 18:14:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 38/38 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.DETERMINE.OUT.MSG.FORMAT(iTransDetails, oMessageFormat, oMessageFormatResponse)
*-----------------------------------------------------------------------------
* Modification History :
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowGUI
    $USING PP.PaymentWorkflowDASService

    GOSUB initialise
    GOSUB process

RETURN

initialise:
*----------
 
    ftNumber = iTransDetails<PPTNCL.Foundation.TransDetails.ftNumber>
    clrtxnType = iTransDetails<PPTNCL.Foundation.TransDetails.clearingTransactionType>
    POS = ''
    fieldVal = ''
    
    GOSUB getPaymentRecord
    
    incomingMessageType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.incomingMessageType>
    returnRejCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>
        
RETURN

getPaymentRecord:
*----------------
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = ftNumber[1,3]
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    
RETURN

process:
*-------

    IF clrtxnType EQ 'CC' THEN
        PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS', ftNumber, '', R.POR.PAYMENTFLOWDETAILS, Error)
        locFieldName = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname>
        locFieldValue = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue>

        LOCATE 'CHEQUE.PRESENTMENT.TYPE' IN locFieldName<1,1> SETTING POS THEN
            fieldVal = locFieldValue<1,POS>
        END
    END
    
    BEGIN CASE
        CASE fieldVal EQ '30'
            oMessageFormat<PPTNCL.Foundation.MsgFormat.messageFormat> = 'TUCGCQ30'
        CASE fieldVal EQ '31'
            oMessageFormat<PPTNCL.Foundation.MsgFormat.messageFormat> = 'TUCGCQ31'
        CASE fieldVal EQ '32'
            oMessageFormat<PPTNCL.Foundation.MsgFormat.messageFormat> = 'TUCGCQ32'
        CASE fieldVal EQ '33'
            oMessageFormat<PPTNCL.Foundation.MsgFormat.messageFormat> = 'TUCGCQ33'
        CASE clrtxnType EQ 'RJ' AND (returnRejCode EQ '00000001' OR returnRejCode EQ '00000002' OR returnRejCode EQ '00000003' OR returnRejCode EQ '00000004' OR returnRejCode EQ '00000010' OR returnRejCode EQ '00000011' OR returnRejCode EQ '00000012') AND incomingMessageType EQ 'TUCGCQ30'
            oMessageFormat<PPTNCL.Foundation.MsgFormat.messageFormat> = 'TUCGCQ82'
        CASE clrtxnType EQ 'RJ' AND (returnRejCode NE '00000001' OR returnRejCode NE '00000002' OR returnRejCode NE '00000003' OR returnRejCode NE '00000004' OR returnRejCode NE '00000010' OR returnRejCode NE '00000011' OR returnRejCode NE '00000012') AND incomingMessageType EQ 'TUCGCQ30'
            oMessageFormat<PPTNCL.Foundation.MsgFormat.messageFormat> = 'TUCGCQ84'
    END CASE
RETURN

END

