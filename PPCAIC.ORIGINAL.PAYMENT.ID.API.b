* @ValidationCode : MjoyMjI3MDQwOTU6Q3AxMjUyOjE2MTY4NTg2NzM1Mzk6Z3ZhaXRoaXNod2FyYW46MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjEyNzoxMjM=
* @ValidationInfo : Timestamp         : 27 Mar 2021 20:54:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gvaithishwaran
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 123/127 (96.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPCAIC.Foundation
SUBROUTINE PPCAIC.ORIGINAL.PAYMENT.ID.API(ioPaymentObject,originalFTNumber,statusCode,errorCode)
*-----------------------------------------------------------------------------
*  Original Payment Identification API
*  Attached in PP.MSGMSGMAPPINGPARAMETER table
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 11/02/2021 - Enhancement-3988349 /Task - 4225703 - API to identify the original transaction.
* 04/03/2021 - Enhancement-3988349 /Task - 4225703 - Assign Payment Direction.
* 17/03/2021 - Enhancement-3988349 /Task - 4225703 - Send pacs.002 confirmation message based on the status.
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.InwardMappingFramework
    $USING PP.PaymentFrameworkService
    $USING PP.OutwardMappingFramework
    $USING EB.SystemTables
    $USING PP.PaymentSTPFlowService
    $USING PP.LocalClearingService
    $USING PP.PaymentGenerationService
        
    GOSUB initialise    ; *Initialise the variables
    GOSUB process       ; *Find the original FTNumber
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
    
*** <desc>initialise the variables </desc>
    originalFTNumber = ''
    statusCode = ''
    errorCode = ''
    tempOriginalFTnumber = ''
    iOriginatingSource=''
    transactionType=''
    statusCode=''
    errorCode=''
    pmtMehod=''
    sendersReference=''
    tempOriginalFTnumber= ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>
    transactionType= ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.clearingTransactionType>
    iOriginatingSource=ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    sendersReference=ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.sendersReferenceIncoming>
    returnId=''
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
    
*** <desc>Find the original FTNumber </desc>
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    IDVAL=''
    IDVAL = tempOriginalFTnumber:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)  ;*get POR.TRANSACTION record
    originalFTNumber = R.TRANSACTION.CONCAT<1>
    IF ERR.CONCAT EQ '' THEN
        IF iOriginatingSource EQ 'C1INTRC' AND (transactionType EQ 'RT' OR transactionType EQ 'RV')THEN
            GOSUB getPaymentRecordForOrigFT ;*get Original payment record
            GOSUB AssignPaymentDirection    ;*Assign Payment Direction
            IF oPaymentRecord THEN
                statusCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
                errorCode = ''
            END
        END
    END ELSE
        errorCode = 'CNT00001'
    END
    GOSUB getSupplementaryInfo
    IF returnId NE '' THEN
        GOSUB getPaymentRecord
        clrgTxnType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
        statusCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
        IF clrgTxnType EQ 'RT' AND statusCode EQ '656' THEN
            GOSUB sendInstEventToClearing           ;*send pacs.002 confirmation message
        END
    END
    IF returnId EQ '' AND isReturnReceived EQ '1' THEN
        R.TRANSACTION.CONCAT = ''
        ERR.CONCAT = ''
        IDVAL=''
        IDVAL = sendersReference:'-':iOriginatingSource
        PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
        ftNumber = R.TRANSACTION.CONCAT<1>
        IF ERR.CONCAT EQ '' THEN
            GOSUB getPaymentRecord              ;*get payment record
            clrgTxnType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
            statusCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
            IF clrgTxnType EQ 'RT' AND statusCode EQ '235' THEN
                oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>='999'
                oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription>='Unspecified Application Error'
                GOSUB sendInstEventToClearing
            END
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPaymentRecordForOrigFT>
getPaymentRecordForOrigFT:
***************************

    iPaymentID =''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = originalFTNumber
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = originalFTNumber[1,3]
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr) ;* Get Payment record
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AssignPaymentDirection>
AssignPaymentDirection:
***************************
*Assign payment Direction
    
    ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.paymentDirection> = "I"
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
getPaymentRecord:
*   In this GOSUB get the Payment Record
    IF returnId EQ '' THEN
        returnId=ftNumber
    END
    oPaymentRecord = ""
    oReadErr = ""
    iPaymentID = ""
    oAdditionalPaymentRecord = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = returnId
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = returnId[1,3]
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr) ;* Get Payment record
    
RETURN
*---------------------------------------------------------------------------------------------------------------
sendInstEventToClearing:
* To emit pacs.002 as a response
    iTransactionContext=''
    iTransactionContext<PP.PaymentFrameworkService.TransactionContext.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>[1,3]
    iTransactionContext<PP.PaymentFrameworkService.TransactionContext.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iTransactionContext<PP.PaymentFrameworkService.TransactionContext.businessDate> = EB.SystemTables.getToday()
    GOSUB getPPTClearing
    IF oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.paymentDirection> EQ 'I' THEN
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.originatingSource>
    END
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.companyID> = returnId[1,3]
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.ftNumber> = returnId
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.currentBusinessDate> = iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.businessDate>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileReference> = 'SFD-':returnId
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.bulkReference> = 'SBD-':returnId
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileFormat>= 'ICF' ;* For CT
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingID> = iClrRequest<PP.LocalClearingService.ClrRequest.clearingID>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.date> = oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.creditValueDate>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingTransactionType> = oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.clearingTransactionType>
    
    PP.PaymentGenerationService.sendInstEventToClearing(iMapCreditTransfer,oPaymentRecord,oAdditionalPaymentRecord,oMapCreditError)
    originalFTNumber = 'Exit'
    ioPaymentObject=''
    
RETURN
*-------------------------------------------------------------------------------------------------------------------------
getPPTClearing:
*   Read PP.CLEARING table to fetch clearingInvestigationMsgType field value.
    iClrRequest = ''
    oClrDetails = ''
    oClrError = ''
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> =returnId[1,3]
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = oPaymentRecord<PP.PaymentGenerationService.PaymentRecord.originatingSource>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = oPaymentRecord<PP.PaymentGenerationService.PaymentRecord.transactionCurrencyCode>
    PP.LocalClearingService.getPPTClearing(iClrRequest,oClrDetails,oClrError)
    
RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= getSupplementaryInfo>
getSupplementaryInfo:
    
*** <desc>Get Ssupplementary info of the payment </desc>
   
    oPaymentFlowDetails         = ''
    oPORPmtFlowDetailsGetError  = ''
    iPORPmtFlowDetailsReq       = ''
    isReturnReceived= ''
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID>    = originalFTNumber[1,3]
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber>     = originalFTNumber
    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPaymentFlowDetails, oPORPmtFlowDetailsGetError)
    
    returnId = oPaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>
    
    LOCATE "RETURN RECEIVED" IN oPaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING pos1 THEN
        isReturnReceived = '1'
    END
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
