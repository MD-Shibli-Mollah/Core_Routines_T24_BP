* @ValidationCode : MjoxODk4Nzc3NzE2OkNwMTI1MjoxNTYwODU4MTAxNDk4OmhhcnNoYXNpbmdoOjc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDoxNzU6MTE4
* @ValidationInfo : Timestamp         : 18 Jun 2019 17:11:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harshasingh
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 118/175 (67.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.CHANNEL.VALIDATION(iChannelDetails, iRSCreditDets, oChannelResponse)
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
** Module method
* The method validates the payment against COELSA ACH clearing requirements as a part of routing and
* and settlement for the payment sent to Clearing. This API will be attached in the ValidateApi field of PP.CLEARING.SETTING
*
** Generated Service Adaptor
* @stereotype subroutine
* @package payments.ppaach
*!
* In/out parameters
* iChannelDetails - ChannelDetails (Single), IN
* iRSCreditDets - RSCreditDets (List), IN
* oChannelResponse - PaymentResponse (Single), OUT
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 13/05/2019 - Enhancement 2959657 / Task 2959618
*              API to perform the Channel validations for the Argentina DD and CT payments
* 22/05/2019 - Enhancement 3131179 / Task 3149366
*              Payments-Openbank-Local Transfer - CT
*              Corrected input parameters for POR.TRANSACTION record read.
* 18/06/2019 - Enhancement 2959503 / Task 3140225 Payments-Openbank Local Transfer and Domestic Payments
*              Code fixes
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentFrameworkService
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $USING PP.InboundCodeWordService
    
    GOSUB initialise ;* initialise the variables
    GOSUB getPorTransInfo ; *retrieve the payment details
    GOSUB getDebitPartyInfo ; *retrieve the Debit Party details
    GOSUB getCreditPartyInfo ; *retrieve the Credit Party details
    GOSUB performValidations
    
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= initialise>
initialise:
*** <desc>initialise the variables</desc>

    oChannelResponse = ''
    scenarioCode = ''
    iCreditPartyDet = ''
    relatedIBAN = ''
    mainOrChargeAccType = ''
    messageInfoVal = ''
    CrValueDt = ''
*
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= getPorTransInfo>
getPorTransInfo:
*** <desc>retrieve the payment details </desc>

    iPaymentID                          = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.companyID>
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.ftNumber>
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr) ;* from the FtNumber get the POR TRANSACTION record
;* if the POR TRANSACTION record is not available, update the log and exit
    IF oReadErr NE "" THEN
        messageInfoVal = 'POR.TRANSACTION RECORD NOT FOUND'
        GOSUB updateResponseAndExit
    END
    
    ClrngTxnType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>  ;*Clearing Transaction Type
    TxnAmount = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount> ;* Transaction Amount
    ClrngNatureCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode> ;* Clearing Nature code
    CrValueDt = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.creditValueDate> ;* credit Value Date
    DbValueDt = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitValueDate> ;* Debit Value Date
    TxnCurrencyCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= getDebitPartyInfo>
getDebitPartyInfo:
*** <desc>retrieve the Debit Party details from Por Supplementary Info </desc>
    
    iDebitPartyRole = ""
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.companyID>
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.ftNumber>
    oPrtyDbtDetails = ""
    oGetPrtyDbtError = ""
    
    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError) ;* get the POR.PARTY.DEBIT details.
    
;* if the POR.PARTY.DEBIT record is not available, update the log and exit
        
    IF oGetPrtyDbtError<PP.DebitPartyDeterminationService.DASError.error> NE "" THEN
        messageInfoVal = 'POR.PARTYDEBIT RECORD NOT FOUND'
        GOSUB updateResponseAndExit
    END
    
    dbPartyRole = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole> ;* debitPartyRole
    roleIndicator = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRoleIndicator> ;*debitPartyRoleIndicator
    nationalId = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyNationalID>    ;*debitPartyNationalID
    partyAccLine = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine>  ;*debitPartyAccountLine
    prvIdOthrId = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyPrvIdOtherId>  ;*debitPartyPrvIdOtherId
    
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= getCreditPartyInfo>
getCreditPartyInfo:
*** <desc>retrieve the Credit Party details from the Por Supplementary Info </desc>

    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.ftNumber>
    oCreditPartyDet = ""
    oGetCreditError = ""
    
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError);* get the POR.PARTY.CREDIT details.
    
;*  if the POR.PARTY.CREDIT record is not available, update the log and exit
    IF oGetCreditError<PP.CreditPartyDeterminationService.DASError.error> NE "" THEN
        messageInfoVal = 'POR.PARTYCREDIT RECORD NOT FOUND'
        GOSUB updateResponseAndExit
    END
    
    crPartyRole = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole> ;* Credit Party role
    crRoleIndicator = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic> ;* Credit Party ROle indicator
    crPrvIdOthId = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPrvIdOtherId> ;* Private ID other Id in POR.PARTY.CREDIT
    crPartyAccountLine = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine>
    orgIdOtherId = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crOrgIdOtherId> ;*crOrgIdOtherId
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
getPaymentInformation:
    
    iPaymentID = ''
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.companyID>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber>  = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.ftNumber>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.informationCode> = 'INSSDR'
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.instructionCode> = 'TXPURPPY'
    oPaymentInfoError = ''
    oPaymentInformation = ''
    PP.InboundCodeWordService.getPaymentOrderInformation(iPaymentID, oPaymentInformation, oPaymentInfoError)
    IF oPaymentInfoError<PP.InboundCodeWordService.DASError.error> NE "" THEN
        messageInfoVal = 'POR.INFORMATION RECORD NOT FOUND'
        GOSUB updateResponseAndExit
    END
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
performValidations:
    
    GOSUB commonValidations   ;* This validation will get executed for both CT and DD COELSA payments.
    
    BEGIN CASE
        CASE ClrngTxnType EQ 'CT'
            GOSUB getPaymentInformation ;* retrieved por information details
            GOSUB validateCreditTransactionDetails
            
        CASE ClrngTxnType EQ 'DD'
            GOSUB validateDebitTransactionDetails
            
    END CASE
    
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
commonValidations:
    
    IF ClrngTxnType EQ '' THEN ;* Clearing Transaction type has to be present in the payment
        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Payment does not have a Clearing Transaction Type'
        GOSUB updateResponseAndExit
    END
    
    IF TxnAmount EQ '' OR TxnAmount LE '0' THEN ;* the transaction amount should be a positive, non zero amount
        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Payment should have a non zero positive transaction amount'
        GOSUB updateResponseAndExit
    END
 
    IF ClrngNatureCode EQ '' THEN  ;* clearing nature code should be present in the transaction
        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Payment does not have a clearing nature code'
        GOSUB updateResponseAndExit
    END
    
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
validateCreditTransactionDetails:
*   initialise pos values here.
    crPos = ''
    crPos1 = ''
    
    LOCATE "BENFCY" IN crPartyRole<1,1> SETTING crPos THEN
        IF crRoleIndicator<1,crPos> EQ 'R' AND crPartyAccountLine<1,crPos> EQ "" THEN
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Credit Account is not available in the payment'
            GOSUB updateResponseAndExit
        END
    
        IF crRoleIndicator<1,crPos>  EQ 'R' AND orgIdOtherId<1,crPos> EQ "" THEN
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Beneficiary Identification of the payment is not available'
            GOSUB updateResponseAndExit
        END
    END
    
    LOCATE "ACWINS" IN crPartyRole<1,1> SETTING crPos1 THEN
        IF crRoleIndicator<1,crPos1> EQ 'G' AND crPartyAccountLine<1,crPos1> EQ "" THEN
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = "Payment should have a Creditor entity"
            GOSUB updateResponseAndExit
        END
    END
       
*    IF CrValueDt EQ '' THEN ;* Credit value date should be present
*        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Credit value date of a payment should not be blank'
*        GOSUB updateResponseAndExit
*    END

    IF TxnCurrencyCode MATCHES 'USD':@VM:'ARS':@VM:'EUR' ELSE    ;* Only mentioned three currencies are allowed for CT COELSA payment.
        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'TransactionCurrencyCode of payment is invalid'
        GOSUB updateResponseAndExit
    END
    
    IF oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationLine> EQ '' THEN
        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = "InformationLine of the payment is missing"
        GOSUB updateResponseAndExit
    END
    
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
validateDebitTransactionDetails:
    
    RolePos = ''
    CrRolePos1 = ''
    LOCATE 'DBTAGT' IN dbPartyRole<1,1> SETTING RolePos THEN  ;* the debtor entity should be updated under the role DBTAGT in Supplement Info
        
        IF roleIndicator<1,RolePos>  EQ 'R' AND  nationalId<1,RolePos> EQ 'Y' AND partyAccLine<1,RolePos> EQ '' THEN
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Payment does not have a debtor entity'
            GOSUB updateResponseAndExit
        END
    END
    
    RolePos = ''
    
    LOCATE 'DEBTOR' IN dbPartyRole<1,1> SETTING RolePos THEN ;* debtor account details should be present in the party account line of DEBTOR
        
        IF roleIndicator<1,RolePos>  EQ 'R' AND partyAccLine<1,RolePos> EQ '' THEN
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Debit Account is not available in the payment'
            GOSUB updateResponseAndExit
        END
        
        IF roleIndicator<1,RolePos>  EQ 'R' AND prvIdOthrId<1,RolePos> EQ '' THEN ;* payer identification should be available in private /Other Id of DEBTOR
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Payer identification is not available in the payment'
            GOSUB updateResponseAndExit
        END
    END
    
    LOCATE 'ORDPTY' IN crPartyRole<1,1> SETTING CrRolePos1  THEN ;* Credit party identification should be present in the private Id other Id tag of ORDPTY cerdit party role
        IF crRoleIndicator<1,CrRolePos1>  EQ 'R' AND crPrvIdOthId<1,CrRolePos1> EQ '' THEN
            oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'CUIT details of the Originating customer is not available'
            GOSUB updateResponseAndExit
        END
    END
    
*    IF DbValueDt EQ '' THEN ;* Debit value date should be present
*        oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>    = 'Debit value date of a payment should not be blank'
*        GOSUB updateResponseAndExit
*    END
        
       
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
updateResponseAndExit:
    
    oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.returnCode>                                    = 'FAILURE'
    oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.serviceName>                                   = 'PPAACH.Clearing'
    oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageCode>    = 'ARG10002' ;*'Failure due to incorrect or missing values in the mandatory fields'
    oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageInfo>    = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.outputChannel>:' Reason: ':messageInfoVal
    oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'

*Tracer added to update HistoryLog for CLF10005 error
    LogEventType = 'INF'
    LogEventDescription = ''
    LogErrorCode = oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageCode>
    LogEventDescription = oChannelResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText>
    LogAdditionalInfo = messageInfoVal
    GOSUB updateHistoryLog
    GOSUB exit
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------
updateHistoryLog:
    
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = iChannelDetails<PPAACH.ClearingFramework.ChannelDetails.ftNumber>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = LogEventType
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = LogEventDescription
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = LogErrorCode
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = LogAdditionalInfo
    
    oPORHistoryLogError = ''
    
    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table
    
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
exit:
    
RETURN TO exit
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------

