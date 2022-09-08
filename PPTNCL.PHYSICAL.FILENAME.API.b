* @ValidationCode : MjotMTUyMjYxNTk0NjpDcDEyNTI6MTYwMzI4OTkwMDU5NjpzYXJtZW5hczo3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6ODU6ODI=
* @ValidationInfo : Timestamp         : 21 Oct 2020 19:48:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/85 (96.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------

$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.PHYSICAL.FILENAME.API(iPaymentRecord,iAdditionalPaymentRecord,iGenericInfo,oFileName)
*-----------------------------------------------------------------------------
*This API generated the Unique Physical file name for CT,DD and RJ transaction
*-----------------------------------------------------------------------------

* Modification History :
*24/06/2020 - Enhancement 3538850/Task 3816876-Payments-BHTunsian-Issued Direct Debit / Received Direct Debit
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------

 

*-----------------------------------------------------------------------------

    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentFrameworkService
    $USING PP.LocalClearingService
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentWorkflowGUI

 

    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process
    GOSUB finalise ;* Finalise the output value

RETURN

*-----------------------------------------------------------------------------

 

Initialise:

 

    CHANGE @VM TO @FM IN iPaymentRecord
    CHANGE @VM TO @FM IN iGenericInfo
    CHANGE @VM TO @FM IN iAdditionalPaymentRecord

    oClrError = ''
    oClrDetails = ''
    iClrRequest = ''
    clearingNcc = ''
    sendingNcc = ''
    oSentFileDetils = ''
    Error = ''
    fileRef = ''
    oTimestamp = ''
    oTimestampResponse = ''
    oTimestampDate = ''
    oTimestampTime = ''

    oFileName = ''
    outFileName = ''
    fileReference = ''

    fileid = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileName>
    clearingTxnType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    fileReference = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileName>
    outgoingMsgType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    retRejCode = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>
    incomingMsgType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.incomingMessageType>
    ftNumber = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>

RETURN

*-----------------------------------------------------------------------------
Process:

*get clearing ncc from PP.CLEARING

    PP.OutwardMappingFramework.ppGetSentfileFilename(fileReference, outFileName)
    IF outFileName<1> NE '' THEN
        oFileName = outFileName<1>
    END ELSE

        iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
        IF iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType> EQ 'TNCGDDRJ' OR iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType> EQ 'TUCGCQ84' OR iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType> EQ 'TUCGCQ82' THEN
            iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
        END ELSE
            iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outputChannel>
        END

        IF iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outTransactionCurrencyCode> EQ ''THEN
            iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
        END ELSE
            iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outTransactionCurrencyCode>
        END
        
        IF clearingTxnType EQ 'CC' THEN
            GOSUB getPaymentDetails
        END

        PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)

        clearingNcc = oClrDetails<PP.LocalClearingService.ClrDetails.clearingNCC>
        sendingNcc =  oClrDetails<PP.LocalClearingService.ClrDetails.sendingNcc>

* Get the current Time Stamp

        PP.PaymentFrameworkService.createTimestamp(oTimestamp, oTimestampResponse)

        oTimestampDate = oTimestamp[1,8]
        oTimestampDate = oTimestampDate[7,2]:oTimestampDate[5,2]:oTimestampDate[1,4]
        oTimestampTime = oTimestamp[9,6]

        BEGIN CASE

            CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'TUNCLGDD'
                oFileName = clearingNcc[1,2]:'-999-20-21-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
            
            CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'TNCGDDRJ'
                oFileName = clearingNcc[1,2]:'-999-20-22-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
        
            CASE clearingTxnType EQ 'CT'
                oFileName = sendingNcc[1,2]:'-999-10-21-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
        
            CASE clearingTxnType EQ 'RT'
                oFileName = sendingNcc[1,2]:'-999-10-22-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
            
            CASE clearingTxnType EQ 'CC'
                oFileName = clearingNcc[1,2]:'-999-':chequePresentMentType:'-21-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
        
            CASE clearingTxnType EQ 'CD' AND (retRejCode EQ '00000001' OR retRejCode EQ '00000002' OR retRejCode EQ '00000003' OR retRejCode EQ '00000004') AND incomingMsgType EQ 'TUCGCQ30'
                oFileName = clearingNcc[1,2]:'-999-82-21-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
            
            CASE clearingTxnType EQ 'CD' AND (retRejCode NE '00000001' OR retRejCode NE '00000002' OR retRejCode NE '00000003' OR retRejCode NE '00000004') AND incomingMsgType EQ 'TUCGCQ30'
                oFileName = clearingNcc[1,2]:'-999-84-21-':fileid:'-':oTimestampDate:'-':oTimestampTime:'-788.ENV'
        
        END CASE
    END

RETURN
*-----------------------------------------------------------------------------
getPaymentDetails:
*------------------
    chequePresentMentType = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS', ftNumber, '', R.POR.PAYMENTFLOWDETAILS, Error)
    locFieldName = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname>
    locFieldValue = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue>

    LOCATE 'CHEQUE.PRESENTMENT.TYPE' IN locFieldName<1,1> SETTING POS THEN
        chequePresentMentType = locFieldValue<1,POS>
    END

RETURN
*-----------------------------------------------------------------------------

finalise:

    CHANGE @FM TO @VM IN iPaymentRecord
    CHANGE @FM TO @VM IN iGenericInfo
    CHANGE @FM TO @VM IN iAdditionalPaymentRecord

RETURN

*-----------------------------------------------------------------------------

END
