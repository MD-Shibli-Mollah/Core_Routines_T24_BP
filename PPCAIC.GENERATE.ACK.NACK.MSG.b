* @ValidationCode : MjotNDk0OTI3MjQzOkNwMTI1MjoxNjE3MTA3NTE2OTQ0OmxhdmFueWFzdDoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6MjIxOjIxMA==
* @ValidationInfo : Timestamp         : 30 Mar 2021 18:01:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lavanyast
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 210/221 (95.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-------------------------------------------------------------------------------------------------------------------------
$PACKAGE PPCAIC.Foundation
SUBROUTINE PPCAIC.GENERATE.ACK.NACK.MSG(iStatusActionLoc, iResponse)
*-------------------------------------------------------------------------------------------------------------------------
* @author vaibhav.gupta@temenos.com
*-------------------------------------------------------------------------------------------------------------------------
* Modification History :
*12/02/21 - Enhancement 3988389/ Task 4224945 -Code changes for pacs.003 Debtor flow
*-------------------------------------------------------------------------------------------------------------------------
    $USING EB.API
    $USING PP.PaymentSTPFlowService
    $USING PP.PaymentFinalisationService
    $USING PP.PaymentFrameworkService
    $USING PP.OutwardMappingFramework
    $USING PP.LocalClearingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentGenerationService
    $INSERT I_LocalClearingService_ClrRequest
    $USING EB.SystemTables
    
    
    GOSUB initialize
    IF clearingName EQ 'C1INTRC'THEN
        GOSUB process
    END
RETURN
*-------------------------------------------------------------------------------------------------------------------------
initialize:
*local variables are initialised
    
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    productVAL=''
    proPos=''
    ftNum=''
    productVAL  = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts>
    LOCATE "SE" IN productVAL<1,1> SETTING proPos THEN                          ;* Check if SE is installed
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = FIELD(iStatusActionLoc, ',', 4)
        ftNum = FIELD(iStatusActionLoc, ',', 5)
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = FIELD(ftNum, '/', 1)
    END ELSE
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = FIELD(iStatusActionLoc, ',', 4)
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = FIELD(iStatusActionLoc, ',', 5)
    END
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    iPaymentFlowDets=''
    iPORPmtFlowDetailsReq=''
    oPORPmtFlowDetailsList=''
    oPORPmtFlowDetailsGetError = ''
    companyID=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    paymentFTNumber=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    transactionType=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    clearingName=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingChannel>
    iMapCreditTransfer = ''
    oMapCreditError = ''
    oClrDetails=''
    iClrRequest=''
    iFTNumber=''
    iMsgDirection=''
    oMaxInstTimeOut=''
    isSvcRunning = PPCAIC.Foundation.getsvcRunningStatus()
    
RETURN
*-------------------------------------------------------------------------------------------------------------------------
process:
 
* If the response is NOK, the payment will be cancelled and IF will be emitted and returned
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.GENERATE.ACK.NACK.MSG","iResponse  : <":iResponse:">","")
    IF iResponse EQ 'NOK' THEN
        PPCAIC.Foundation.setsvcRunningStatus('Y')
        GOSUB cancelPayment ; *
        GOSUB updatePayment ; *
        GOSUB updateHistoryLog ; *
        RETURN
    END
    
    IF clearingName EQ 'C1INTRC' AND (transactionType MATCHES 'CT':@VM:'DD':@VM:'RT') THEN
        iTransactionContext<PP.PaymentFrameworkService.TransactionContext.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>[1,3]
        iTransactionContext<PP.PaymentFrameworkService.TransactionContext.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
        iTransactionContext<PP.PaymentFrameworkService.TransactionContext.businessDate> = EB.SystemTables.getToday()
        GOSUB getMaxInstTimeOut
        IF oWithinTimeOut EQ "Y" AND isSvcRunning NE 'Y' THEN
            GOSUB sendInstEventToClearing
        END
    END
    
RETURN
*--------------------------------------------------------------------------------------------------------------------------------
getPORPaymentFlowDetails:
*to get the POR.SUPPLEMENTARY.INFO table details for the payment
    iPORPmtFlowDetailsReq=''
    oPORPmtFlowDetailsList=''
    oPORPmtFlowDetailsGetError=''
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = companyID
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> =  paymentFTNumber
    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError);* To read POR.PAYMENTFLOWDETAILS table
    
RETURN
*--------------------------------------------------------------------------
getMaxInstTimeOut:
* gosub to get the maxInstTimeOut value for timeout check.
    oMaxInstTimeOut=''
    GOSUB getPORPaymentFlowDetails
    IF NOT(oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.acceptedDateTimeStamp>) THEN ;* If this field is blank, this means the processing payment is not applicable to check overall processing is within the time
        oWithinTimeOut = 'Y'
        RETURN
    END
    iFTNumber = iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.ftNumber>
    iMsgDirection = 'R'
    PP.PaymentFrameworkService.getMaxInstTimeOut(iFTNumber, iMsgDirection, oMaxInstTimeOut)
    
    IF oMaxInstTimeOut EQ '' THEN ;* Do timeout check only if the maximum timeout limit is configured in the table else consider the payment is with in the time limit and continue processing it.
        oWithinTimeOut = 'Y'
    END ELSE
        GOSUB checkIfWithinTimeOut ;* To check if AML response is received within timeout or not.
    END
    
RETURN
*--------------------------------------------------------------------------------------------------------------------------------
getPPTClearing:
*   Read PP.CLEARING table to fetch clearingInvestigationMsgType field value.
    iClrRequest = ''
    oClrDetails = ''
    oClrError = ''
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = companyID
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = oPaymentRecord<PP.PaymentGenerationService.PaymentRecord.originatingSource>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = oPaymentRecord<PP.PaymentGenerationService.PaymentRecord.transactionCurrencyCode>
    PP.LocalClearingService.getPPTClearing(iClrRequest,oClrDetails,oClrError)
    
RETURN
*------------------------------------------------------------------------------------------------------------------------
checkIfWithinTimeOut:
* Timout check will be handled for INST payment in all the cases.
    iPaymentMethod=oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.paymentMethod>
    IF iPaymentMethod EQ "INST" OR (iPaymentMethod EQ "NRINST") THEN
*       This gets the current Business Date and calls getUTCUsingTimeStamp to get the withInTimeOut
        iInTimeDetails = ""
        oOutCalcTimeDetails = ""
        oCalcTimeResponse = ""
        GOSUB getPPTClearing;
        GOSUB getCurrentBusinessDate;
*       Get the withInTimeOut based on maxInstTimeOut and acceptedDateTimeStamp
        iInTimeDetails<PP.PaymentFrameworkService.InTimeDetails.clrTimeZone> = oClrDetails<PP.LocalClearingService.ClrDetails.timeZone>
        iInTimeDetails<PP.PaymentFrameworkService.InTimeDetails.clrRTGSSystem> = oClrDetails<PP.LocalClearingService.ClrDetails.rtgsSystem>
        iInTimeDetails<PP.PaymentFrameworkService.InTimeDetails.compOffSet> = ""
        iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.companyID> = companyID
        iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.businessDate> = iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.businessDate>
*       To Check whether the AML response is received within overall time out or not.
        iInTimeDetails<PP.PaymentFrameworkService.InTimeDetails.acceptOrOrigination> = "A"
        iInTimeDetails<PP.PaymentFrameworkService.InTimeDetails.acceptedDateTimeStamp> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.acceptedDateTimeStamp>
        iInTimeDetails<PP.PaymentFrameworkService.InTimeDetails.clrSetMaxInstTimeOut> = oMaxInstTimeOut

        PP.PaymentFrameworkService.getUTCUsingTimeStamp(iTransactionContext, iInTimeDetails, oOutCalcTimeDetails, oCalcTimeResponse)
        oWithinTimeOut = oOutCalcTimeDetails<PP.PaymentFrameworkService.OutCalcTimeDetails.withInTimeOut>

    END

RETURN
*-------------------------------------------------------------------------------------------------------------------------
getCurrentBusinessDate:
    
    inpCompanyID = companyID
    currentBusinessDate = ""
    oGetCurDateError = ""
    PP.PaymentFrameworkService.getCurrBusinessDate(inpCompanyID, currentBusinessDate, oGetCurDateError)
    
RETURN
*---------------------------------------------------------------------------------------------------------------
sendInstEventToClearing:
* To emit pacs.002 as a response
    IF oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.paymentDirection> EQ 'I' THEN
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.originatingSource>
    END
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.companyID> = companyID
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.ftNumber> = paymentFTNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.currentBusinessDate> = iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.businessDate>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileReference> = 'SFD-':paymentFTNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.bulkReference> = 'SBD-':paymentFTNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileFormat>= 'ICF' ;* For CT
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingID> = iClrRequest<PP.LocalClearingService.ClrRequest.clearingID>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.date> = oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.creditValueDate>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingTransactionType> = oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.clearingTransactionType>
*   For StatusCode 999/998/997, Emit PACS.002 (Confirmation Message back to the CMS or Clearing)
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>='999' THEN
        oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.clearingReturnCode>=''
        oPaymentRecord<PP.PaymentSTPFlowService.PaymentRecord.reasonDescription>=''
    END
    PP.PaymentGenerationService.sendInstEventToClearing(iMapCreditTransfer,oPaymentRecord,oAdditionalPaymentRecord,oMapCreditError)
RETURN
*-------------------------------------------------------------------------------------------------------------------------

*** <region name= cancelPayment>
cancelPayment:
*** <desc> </desc>
    iTransactionContext<PP.PaymentFrameworkService.TransactionContext.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>[1,3]
    iTransactionContext<PP.PaymentFrameworkService.TransactionContext.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iTransactionContext<PP.PaymentFrameworkService.TransactionContext.businessDate> = EB.SystemTables.getToday()

    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.statusCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.specificWeightCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.specificWeightCode>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.weightCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.weightCode>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.transactionCurrencyCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.originatingSource> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.incomingMessageType> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.incomingMessageType>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.batchIndicator> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.batchIndicator>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.batchReference> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.batchReference>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.clearingNatureCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.clearingTransactionType> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.orderingPartyResidency> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.orderingPartyResidency>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.orderingPartyResidencyFlag> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.orderingPartyResidencyFlag>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.beneficiaryPartyResidency> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.beneficiaryPartyResidency>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.beneficiaryPartyResidencyFlag> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.beneficiaryPartyResidencyFlag>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.repairFlag> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.repairFlag>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reverseMappingIndicator> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reverseMappingIndicator>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.cancelFlag> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.cancelFlag>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.cancelDescription> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.cancelDescription>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.rejectFlag> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.rejectFlag>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.rejectDescription> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.rejectDescription>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.entryUserID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.entryUserID>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.authPrincipleIndicator> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.authPrincipleIndicator>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.approverUserID1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.approverUserID1>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.approverUserID2> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.approverUserID2>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.actionFlag> = ""
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.acceptWarning> = ""
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.invokedBy> = ""
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.paymentDirection> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.paymentDirection>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.singleMultipleIndicator> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.singleMultipleIndicator>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.outputChannel> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outputChannel>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.fileReferenceIncoming> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.fileReferenceIncoming>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reservationAmount> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reservationAmount>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reservationKey> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reservationKey>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reservationDebitAccCompanyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reservationDebitAccCompanyID>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reservationDebitAccount> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reservationDebitAccount>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reservationDebitAccCurrCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reservationDebitAccCurrCode>
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.reservationReqDate> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reservationReqDate>
    
    iPaymentErrors = ""
    iPaymentErrors<PP.PaymentFinalisationService.InOutPaymentErrors.errorCode> = 'IMF10022'
*   Payment will be cancelled as cancellation received for Original payment
    ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.statusCode> = '997'
    PP.PaymentFinalisationService.cancelPayment(iTransactionContext, iPaymentErrors, ioPaymentCancelDetails, oCancelResponse)
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ 'RT' THEN
        GOSUB updateOrigTxn
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= updatePayment>
updatePayment:
*** <desc> </desc>
    iServiceName = 'OutwardMappingFramework'
    iPaymentRecord = oPaymentRecord
    iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode> = ioPaymentCancelDetails<PP.PaymentFinalisationService.InOutTransactionDetails.statusCode>
    iAdditionalPaymentRecord = oAdditionalPaymentRecord
    oWriteErr = ''
    
    PP.PaymentWorkflowDASService.updatePaymentRecord(iServiceName, iPaymentRecord, iAdditionalPaymentRecord, oWriteErr)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= updateOrigTxn>
updateOrigTxn:
*** <desc>Update Status and Return Transaction id in original transaction </desc>

    GOSUB getPORPaymentFlowDetails
*Retrieve original transaction details and update status as 999
    companyID=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>

    iPaymentIDOrig = ''
    iPaymentIDOrig<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>
    iPaymentIDOrig<PP.PaymentWorkflowDASService.PaymentID.companyID> = companyID

    oPaymentRecordOrig = ''
    oAdditionalPaymentRecordOrig = ''
    oReadErrOrig = ''
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentIDOrig, oPaymentRecordOrig, oAdditionalPaymentRecordOrig, oReadErrOrig) ;* To read POR.TRANSACTION

    IF oReadErrOrig EQ '' THEN
        oPaymentRecordOrig<PP.PaymentWorkflowDASService.PaymentRecord.statusCode> = '999'
        iServiceName = 'OutwardMappingFramework'
        PP.PaymentWorkflowDASService.updatePaymentRecord(iServiceName,oPaymentRecordOrig,oAdditionalPaymentRecordOrig,oTxnWriteErrOrg)

        iPORPmtFlowDetailsReqOrig = ''
*OrgnlOrReturnId should be set as blank in Oringal transaciton when retur transaction get cancelled
        iPORPmtFlowDetailsReqOrig<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = companyID
        iPORPmtFlowDetailsReqOrig<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>

        oPORPmtFlowDetailsListOrig = ''
        oPORPmtFlowDetailsGetErrorOrig = ''
        PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReqOrig, oPORPmtFlowDetailsListOrig, oPORPmtFlowDetailsGetErrorOrig)  ;* To read POR.PAYMENTFLOWDETAILS table
        oPORPmtFlowDetailsListOrig<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId> = ''
        LOCATE 'RETURN RECEIVED' IN oPORPmtFlowDetailsListOrig<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING fPos THEN
            oPORPmtFlowDetailsListOrig<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,fPos> = ''
            oPORPmtFlowDetailsListOrig<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,fPos> = ''
        END
        PP.PaymentFrameworkService.updatePORPaymentFlowDetails(oPORPmtFlowDetailsListOrig, oPORPmtFlowDetailsUpdErrorOrig) ;* To update POR.PAYMENTFLOWDETAILS
    END

RETURN
*-----------------------------------------------------------------------------
*** <region name= updateHistoryLog>
updateHistoryLog:
*** <desc> </desc>
    iPORHistoryLog=''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'ERR'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = 'NACK Confirmation message is sent out- Unspecified Application Error with return code 999'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = ''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = ''
    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table

RETURN
*** </region>

END



