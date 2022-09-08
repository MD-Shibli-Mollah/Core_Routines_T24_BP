* @ValidationCode : MjoyMTE1ODY3MDk3OkNwMTI1MjoxNjAwMTY0MTMxODg4Om1hbmltZWdhbGFpazoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MTA1OjU3
* @ValidationInfo : Timestamp         : 15 Sep 2020 15:32:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manimegalaik
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 57/105 (54.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPUFPS.Foundation
SUBROUTINE InwardMappingFramework.checkRepeatPaypentForUKFPS(ioPaymentObject,ftNumber,statusCode,errorCode)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 05/07/2019 - Task 3197959 / Enhancement 3197956 - UKFPS - Creation - routine to check the existing CT payment with incoming payment
* 16/07/2019 - Task 3232342 - Don't throw error for original payment if originalPmtAPI sends 'Exit' signal
*15/09/2020 - Enhancement 3886687 / Task 3949511: Coding Task - Generic cleanup process for Archival read in PP dependent modules
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.DebitPartyDeterminationService
    $USING PP.PaymentWorkflowGUI
    $USING PP.PaymentGenerationService
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentFrameworkService
    $USING EB.DataAccess
    $USING PP.InwardMappingFramework
    GOSUB init
    GOSUB readConcatAndPaymentRecs ;*Get the FT number for this Repeat message
    IF errConcat EQ '' THEN
        GOSUB compareExistingPayment ;*Compare the incoming message and existing paymet is matching or not
        IF samePaymentRecord THEN
            GOSUB sendInstMsg ;*Send Confirmation message if it same payment
        END ELSE
            ftNumber = '' ;*Payment record not matching so we should create new Payment
        END
    END
    IF ftNumber EQ '' THEN
        ftNumber = 'Exit' ;*Send signal to executemessagelevel to not throw any original payment error
    END
RETURN
*------------------------------------------------------------------------------
init:
    originalPaymentRecord = ''
    ftNumber = ''
RETURN
*------------------------------------------------------------------------------
readConcatAndPaymentRecs:
*Read concat table using paymentIdentificationNumber and get the existing FT number
    FN.POR.TRANSACTION.CONCAT = 'F.POR.TRANSACTION.CONCAT'
    F.POR.TRANSACTION.CONCAT = ''
    R.TRANSACTION.CONCAT = ''
    errConcat = ''
    orgAdditionalPaymentRecord = ''
    originalPaymentRecord = ''
    orgReadErr = ''
    txnId = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.sendersReferenceIncoming>
    concatId = txnId:'-':ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    PP.InwardMappingFramework.getPORTransactionConcat(concatId, R.TRANSACTION.CONCAT, errConcat)
    
    ftNumber = R.TRANSACTION.CONCAT<1>

RETURN
*------------------------------------------------------------------------------
compareExistingPayment:
    
* Read the Payment Details for the Transaction
    iPaymentId<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    iPaymentId<PP.PaymentWorkflowDASService.PaymentID.companyID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentId, originalPaymentRecord, orgAdditionalPaymentRecord, orgReadErr)
    GOSUB getSendingInstitution
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.INFORMATION', ftNumber, '', recPORInformation, errPORInformation) ;* call to get the information record from the merged table
    proprietary = ''
    noOfInfCodes= DCOUNT(recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Informationcode,VM)
    
    FOR mvPos=1 TO noOfInfCodes
        IF recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Informationcode,mvPos> EQ 'INSBNK' AND recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,mvPos> EQ 'LCLINSPY' THEN
            proprietary = recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Informationline,mvPos>
        END
    NEXT mvPos

*Check FPID of the existing record matching with incoming message
*FPID - SendingInstitution, Currency, Propretary, Trnasaction Reference Number and Accepted Date
    samePaymentRecord = ''
    BEGIN CASE
        CASE originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode> NE ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionCurrencyCode>
        CASE originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceIncoming> NE txnId
        CASE proprietary AND (proprietary NE ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.bankOperationCode>)
        CASE sendingInstitution AND (sendingInstitution NE incomingSendingInstitution)
        CASE ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,1,PP.MessageMappingService.PORPmtFlowDetailsList.acceptedDateTimeStamp>[1,8] NE originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.processingDate>
        CASE 1
            samePaymentRecord = 1
    END CASE
    
RETURN
*------------------------------------------------------------------------------
sendInstMsg:
    
*Send positive or negative pacs.002 withoug creating duplicate payment record
    iMapCreditTransfer = ''
    oMapCreditError = ''
    ioAdditionalPaymentRecord = ''
    GOSUB setProcessingDate
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.companyID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.ftNumber> = ftNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.currentBusinessDate> = processingDate
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileReference> = 'SFD-':ftNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.bulkReference> = 'SBD-':ftNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileFormat>= 'ICF' ;* For CT
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.date> = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.creditValueDate>
    IF originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode> MATCHES '656':@VM:'658' THEN
        iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingTransactionType> = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    END
    GOSUB updatePORHistoryLog ;*Update Audit trail that repeat Pacs.002 confimation is being sent
    PP.PaymentGenerationService.sendInstEventToClearing(iMapCreditTransfer,originalPaymentRecord,ioAdditionalPaymentRecord,oMapCreditError)
      
RETURN
*------------------------------------------------------------------------------
setProcessingDate:
    
    iCompanyKey = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    PP.PaymentFrameworkService.getCurrBusinessDate(iCompanyKey, oBusinessDate, oGetCurDateError)
    processingDate = oBusinessDate<PP.PaymentFrameworkService.BusinessDate.currBusinessDate>
RETURN
*-----------------------------------------------------------------------------
getSendingInstitution:
*   Calling Debit Party Determination Service Component to get the sendingInstitution member Id
    iDebitPartyRole                             = ""
    iChannelDetails = ''
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = ftNumber
    oPrtyDbtDetails                             = ""
    oGetPrtyDbtError                            = ""
    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
    noOfTypes = DCOUNT(oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>,@VM)
    FOR type=1 TO noOfTypes
        IF oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'SENDER' AND oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRoleIndicator,type> EQ 'R' THEN
            sendingInstitution = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,type>
        END
    NEXT type
    
    incomingSendingInstitution = ''
    noOfDbtPty = DCOUNT(ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>,@VM)
    FOR pty=1 TO noOfDbtPty
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pty,PP.MessageMappingService.PartyDebit.debitPartyRole> EQ 'SENDER' AND ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pty,PP.MessageMappingService.PartyDebit.debitPartyRoleIndicator> EQ 'R' THEN
            incomingSendingInstitution = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pty,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>
        END
    NEXT pty
    
RETURN
*-----------------------------------------------------------------------------
updatePORHistoryLog:
    
    iPORHistoryLog = ''
    oPORHistoryLogErr = ''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = ftNumber
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = ftNumber
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'INF'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = 'Status response sent to Clearing for the repeat payment message received'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = ''
    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogErr)
    
RETURN
*-----------------------------------------------------------------------------
END

