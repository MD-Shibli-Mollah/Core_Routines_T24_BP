* @ValidationCode : MjoyMDI2MzcxMTE0OkNwMTI1MjoxNTkwMDYxMjMxMjYxOmtlZXJ0aGFuYWQ6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMS4yMDE5MTIxMy0wNTQwOjI2OjI0
* @ValidationInfo : Timestamp         : 21 May 2020 17:10:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : keerthanad
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/26 (92.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.DETERMINE.OUT.MSG.FORMAT(iTransDetails, oMessageFormat, oMessageFormatResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 6/4/2020 - Enhancement 3457582/Task 3457545 - Handled determination of outgoing message type for Cheque payments
* 18/05/2020 - Task 3723505 - Message type for RF payments is handled
*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowGUI
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------
initialise:
* fetch the required values

    ftNumber = iTransDetails<PPSYTC.ClearingFramework.TransDetails.ftNumber>
    clrtxnType = iTransDetails<PPSYTC.ClearingFramework.TransDetails.clearingTransactionType>
    incomingMsgType = iTransDetails<PPSYTC.ClearingFramework.TransDetails.incomingMessageType>
    POS = ''
    fieldVal = ''
    
RETURN
*-----------------------------------------------------------------------------
process:
* read supplementary info to get the presentment type of the cheque
* based on the value assign the output message format

    IF clrtxnType EQ 'CC' OR clrtxnType EQ 'RF' THEN
        PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS', ftNumber, '', R.POR.PAYMENTFLOWDETAILS, Error)
        locFieldName = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname>
        locFieldValue = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue>

        LOCATE 'CHEQUE.PRESENTMENT.TYPE' IN locFieldName<1,1> SETTING POS THEN
            fieldVal = locFieldValue<1,POS>
        END
    END

    BEGIN CASE
        CASE fieldVal EQ '30' AND clrtxnType EQ 'CC'
            oMessageFormat<PPSYTC.ClearingFramework.MsgFormat.messageFormat> = 'SYS3021'
        CASE fieldVal EQ '33' AND clrtxnType EQ 'CC'
            oMessageFormat<PPSYTC.ClearingFramework.MsgFormat.messageFormat> = 'SYS3321'
        CASE clrtxnType EQ 'RF'
            oMessageFormat<PPSYTC.ClearingFramework.MsgFormat.messageFormat> = 'SYS':incomingMsgType[4,2]:'22'
    END CASE
    
RETURN
*-----------------------------------------------------------------------------

END
