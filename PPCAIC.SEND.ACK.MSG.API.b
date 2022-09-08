* @ValidationCode : MjotODE0MTcwNDE4OkNwMTI1MjoxNjE2ODU5OTY3MjQxOmd2YWl0aGlzaHdhcmFuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDoxODY6MTEz
* @ValidationInfo : Timestamp         : 27 Mar 2021 21:16:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gvaithishwaran
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 113/186 (60.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-------------------------------------------------------------------------------------------------------------------------
$PACKAGE PPCAIC.Foundation
SUBROUTINE PPCAIC.SEND.ACK.MSG.API(iStatusActionLoc)
*-------------------------------------------------------------------------------------------------------------------------
* @author stuti.singh@temenos.com
*-------------------------------------------------------------------------------------------------------------------------
* Modification History :
* 03/03/21 - Enhancement 3988389/ Task 4262927  - New API for Canada Intrc
* 16/03/21 - Enhancement 3988389/ Task 4284364  - Copyright update
*-------------------------------------------------------------------------------------------------------------------------
    $USING EB.API
    $USING PP.PaymentSTPFlowService
    $USING PP.PaymentFinalisationService
    $USING PP.PaymentFrameworkService
    $USING PP.OutwardMappingFramework
    $USING PP.LocalClearingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentGenerationService
    $USING PP.InwardMappingFramework
    $USING EB.SystemTables
    $USING PP.DirectDebitChequeService
    $INSERT I_LocalClearingService_ClrRequest
    $INSERT I_PaymentFrameworkService_PORHistoryLog
    
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","","")
    GOSUB initialize
    GOSUB process
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","","")
 
RETURN
*-------------------------------------------------------------------------------------------------------------------------
initialize:
*local variables are initialised
    paymentRecord=RAISE(iStatusActionLoc<8>)
    additionalPaymentRecord=RAISE(iStatusActionLoc<9>)
    iPaymentFlowDets=''
    iPORPmtFlowDetailsReq=''
    oPORPmtFlowDetailsList=''
    oPORPmtFlowDetailsGetError = ''
    companyID=paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    paymentFTNumber=paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    transactionType=paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    clearingName=paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingChannel>
    statusCode=paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
    iMapCreditTransfer = ''
    oMapCreditError = ''
    oClrDetails=''
    iClrRequest=''
    iFTNumber=''
    iMsgDirection=''
    oMaxInstTimeOut=''
    ISOReasonCode = ''
    errorText = ''
    
RETURN
*-------------------------------------------------------------------------------------------------------------------------
process:

    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","paymentRecord  : <":paymentRecord:">","")
 
    IF clearingName EQ 'C1INTRC' AND (transactionType EQ 'CT' OR transactionType EQ 'DD') THEN
        GOSUB getMaxInstTimeOut
        IF oWithinTimeOut EQ "Y" THEN
            GOSUB sendInstEventToClearing
        END
    END
    
    IF statusCode EQ '631' AND transactionType EQ 'DD' THEN
        GOSUB updateStatusPaymentRecord
    END
    IF transactionType EQ 'RT' THEN
        statusCode=RAISE(iStatusActionLoc<2>)
        IF statusCode EQ '235' THEN
            GOSUB getErrorCode
            GOSUB sendInstEventToClearing
            GOSUB updateHistoryLog
        END
    
        IF statusCode EQ '656' THEN
            GOSUB sendInstEventToClearing
            GOSUB updatePorTxnConcat
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
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","oPORPmtFlowDetailsList  : <":oPORPmtFlowDetailsList:">","")
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","oWithinTimeOut  : <":oWithinTimeOut:">","")
 
RETURN
*--------------------------------------------------------------------------------------------------------------------------------
getPPTClearing:
*   Read PP.CLEARING table to fetch clearingInvestigationMsgType field value.
    iClrRequest = ''
    oClrDetails = ''
    oClrError = ''
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = companyID
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = paymentRecord<PP.PaymentGenerationService.PaymentRecord.originatingSource>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = paymentRecord<PP.PaymentGenerationService.PaymentRecord.transactionCurrencyCode>
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
    IF paymentRecord<PP.PaymentSTPFlowService.PaymentRecord.paymentDirection> EQ 'I' THEN
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = paymentRecord<PP.PaymentSTPFlowService.PaymentRecord.originatingSource>
    END
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.companyID> = companyID
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.ftNumber> = paymentFTNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.currentBusinessDate> = iTransactionContext<PP.PaymentSTPFlowService.TransactionContext.businessDate>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileReference> = 'SFD-':paymentFTNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.bulkReference> = 'SBD-':paymentFTNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileFormat>= 'ICF' ;* For CT
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingID> = iClrRequest<PP.LocalClearingService.ClrRequest.clearingID>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.date> = paymentRecord<PP.PaymentSTPFlowService.PaymentRecord.creditValueDate>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingTransactionType> = paymentRecord<PP.PaymentSTPFlowService.PaymentRecord.clearingTransactionType>
*   For StatusCode 999/998/997, Emit PACS.002 (Confirmation Message back to the CMS or Clearing)
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","iMapCreditTransfer  : <":iMapCreditTransfer:">","")
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","paymentRecord  : <":paymentRecord:">","")
    PP.PaymentSTPFlowService.tpsLogging("Input Parameter","PPCAIC.SEND.ACK.MSG.API","additionalPaymentRecord  : <":additionalPaymentRecord:">","")
    IF statusCode EQ '656' AND transactionType EQ 'RT' THEN
        paymentRecord<PP.PaymentSTPFlowService.PaymentRecord.clearingReturnCode>=''
        paymentRecord<PP.PaymentSTPFlowService.PaymentRecord.reasonDescription>=''
    END
    IF errorCode NE '' THEN
        GOSUB getClgReturnCode
    END
    PP.PaymentGenerationService.sendInstEventToClearing(iMapCreditTransfer,paymentRecord,additionalPaymentRecord,oMapCreditError)
RETURN
*-------------------------------------------------------------------------------------------------------------------------
updateStatusPaymentRecord:

    iPaymentStatus = ''
    iPaymentStatus<PP.PaymentWorkflowDASService.PaymentTxnStatus.ftNumber> = paymentFTNumber
    iPaymentStatus<PP.PaymentWorkflowDASService.PaymentTxnStatus.companyID> = companyID
    iPaymentStatus<PP.PaymentWorkflowDASService.PaymentTxnStatus.statusCode> = '998'
    iPaymentStatus<PP.PaymentWorkflowDASService.PaymentTxnStatus.stpEntryPoint> = ''

    PP.PaymentWorkflowDASService.updateStatusPaymentRecord(iPaymentStatus, oUpdateErr)

RETURN
*-----------------------------------------------------------------------------
updatePorTxnConcat:

    IDVAL = ''
    ERR.CONCAT = ''
    R.TRANSACTION.CONCAT = ''
    IDVAL = additionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.bulkSendersReference>:'-':'C1INTRC'
*        CALL TPSLogging("Input Parameter","Transaction details IDVAL ","IDVAL:<":IDVAL:">","")
*PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
    R.TRANSACTION.CONCAT<-1> = paymentFTNumber
    PPCAIC.Foundation.insertPorTransactionConcat('PP.InwardMappingFramework.insertPORTranConcatEuro', IDVAL, R.TRANSACTION.CONCAT)
*        CALL TPSLogging("Input Parameter","Transaction concat details ","R.TRANSACTION.CONCAT:<":R.TRANSACTION.CONCAT:">","")
RETURN
*-----------------------------------------------------------------------------
*** </region>
*------------------------------------------------------------------------------
updateHistoryLog:
    iPORHistoryLog=''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'ERR'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = 'NACK Confirmation message is sent out-':paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription>:' with return code ':paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = errorCode
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = ''
    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table

RETURN
*-----------------------------------------------------------------------------

getErrorCode:
    errorCode=''
    iGetErrorFlags=''
    
    iGetErrorFlags<PP.PaymentFrameworkService.ErrorFlagsState.companyID> = paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iGetErrorFlags<PP.PaymentFrameworkService.ErrorFlagsState.ftNumber> = paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iGetErrorFlags<PP.PaymentFrameworkService.ErrorFlagsState.activeFlag> = 'Y'
* fetch the active error flags
    PP.PaymentFrameworkService.getPORErrorFlags(iGetErrorFlags, oPORErrorFlags, oGetErrorFlagsErr)
    
    errorCode= oPORErrorFlags<PP.PaymentFrameworkService.PORErrorFlags.errorCode,1>
RETURN
*-----------------------------------------------------------------------------
getClgReturnCode:
    BEGIN CASE
        CASE errorCode EQ 'CPD10003'
            paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>='22'
            paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription>='Account does not exist'
            
        CASE errorCode EQ 'CNT00001'
            GOSUB getISOReasonCode ; *
            paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>=ISOReasonCode
            paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription>=errorText
        CASE 1
            paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>='999'
            paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription>='Unspecified Application Error'
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
    
*** <region name= getISOReasonCode>
getISOReasonCode:
*** <desc> </desc>
    errorText = ''
    iErrorReasonKey = ''
    iErrorReasonKey<PP.PaymentFrameworkService.ErrorReasonKey.source> = paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
    iErrorReasonKey<PP.PaymentFrameworkService.ErrorReasonKey.msgPmtType> = paymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.incomingMessageType>

    iErrorReasonKey<PP.PaymentFrameworkService.ErrorReasonKey.errorCode> = errorCode

    PP.PaymentFrameworkService.getPpErrorReasonCode(iErrorReasonKey, oPpErrorReasonCode, oDASError)

    IF oDASError EQ '' AND oPpErrorReasonCode NE '' THEN
        ISOReasonCode = oPpErrorReasonCode<PP.PaymentFrameworkService.OutErrorReasonCode.ercReasonCode>
        errorText = oPpErrorReasonCode<PP.PaymentFrameworkService.OutErrorReasonCode.ercReasonCodeDesc>
    END
RETURN
*** </region>

END
