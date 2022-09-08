* @ValidationCode : MjoxMTQyMzIwNDYzOkNwMTI1MjoxNTg3MTEyMDMwOTI4OnNhcm1lbmFzOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjoxMzE6Nzk=
* @ValidationInfo : Timestamp         : 17 Apr 2020 13:57:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 79/131 (60.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.VALIDATE.OUT.MESSAGE(iChannelDetails, iRSCreditDets, oChannelResponse)
*------------------------------------------------------------------------------
* Public method
* The method validates the payment against SIC clearing requirements
*
** Generated Service Adaptor
* author: maparna@temenos.com
* @stereotype subroutine
* @package payments.pp
*!
* In/out parameters
* iChannelDetails - ChannelDetails (Single), IN
* iRSCreditDets - RSCreditDets (List), IN
* oChannelResponse - PaymentResponse (Single), OUT
*-----------------------------------------------------------------------------
* Modification History :
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*
    $USING PP.LocalClearingService
    $USING PP.CreditPartyDeterminationService
    $USING PP.PaymentFrameworkService
    $USING PP.DebitPartyDeterminationService
    $USING PP.PaymentWorkflowDASService
*------------------------------------------------------------------------------
*
    GOSUB initialise
    GOSUB process
*

RETURN
*------------------------------------------------------------------------------
initialise:
*
    oChannelResponse = '' ; scenarioCode = '' ; iCreditPartyDet = '' ;
    validationResult = ''
    beneficiaryAccount = ''
    
*
RETURN
*------------------------------------------------------------------------------
process:
    
    iPaymentID                          = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    ClrngTxnType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    IF ClrngTxnType EQ 'DD' THEN
        iDebitPartyRole                             = ""
        iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
        iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
        oPrtyDbtDetails                             = ""
        oGetPrtyDbtError                            = ""
        PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
        IF oGetCreditError<PP.LocalClearingService.DASError.error> NE "" THEN
            eventDesc = 'Debit Party Record Not Found'
            GOSUB updateHistoryLog
            GOSUB updateResponse
            GOSUB exit
        END ELSE
            noOfTypes = DCOUNT(oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>,@VM)
            FOR type=1 TO noOfTypes
                IF oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'DEBTOR' AND oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRoleIndicator,type> EQ 'R' THEN
                    beneficiaryAccount = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,type>
                    GOSUB checkValidRIB
                END
            NEXT type
        END
        RETURN
    END
* retrieve the credit party details
    GOSUB creditPartyInfo
*
RETURN
*------------------------------------------------------------------------------
creditPartyInfo:
*   Calling Debit Party Determination Service Component.
    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    oCreditPartyDet = ""
    oGetCreditError = ""
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)
    IF oGetCreditError<PP.LocalClearingService.DASError.error> NE "" THEN
        eventDesc = 'Credit Party Record Not Found'
        GOSUB updateHistoryLog
        GOSUB updateResponse
        GOSUB exit
    END ELSE
* Fetching the output values
        creditPartyRole           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>
        creditPartyRoleIndicator  = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic>
        creditPartyIdentifierCode = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode>
        creditPartyAccountLine    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine>
        creditPartyFreeLine1      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1>
        creditPartyFreeLine2      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine2>
        creditPartyFreeLine3      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine3>
        creditPartyFreeLine4      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine4>
        creditPartyInformationTag = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyInformationTag>
        creditPartyName           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crName>
        IF (creditPartyRole NE '') AND (creditPartyAccountLine NE '') THEN
            LOCATE 'BENFCY' IN creditPartyRole<1,1> SETTING position THEN
                creditPartyRoleInd = creditPartyRole<1,position>
                IF creditPartyRoleInd EQ 'BENFCY' THEN
                    beneficiaryAccount = creditPartyAccountLine<1,position>
                    IF beneficiaryAccount[1,1] EQ '/' THEN
                        beneficiaryAccount = FIELD(beneficiaryAccount,"/",2)
                    END
                    GOSUB checkValidRIB
                END
            END
        END
    END
*
RETURN
*------------------------------------------------------------------------------
checkValidRIB:
*-------------
    PPSYTC.ClearingFramework.ppsystcRibValidation(beneficiaryAccount,validationResult)
    
	BEGIN CASE
        CASE validationResult  EQ '3'
            scenarioCode = 2
            messageText = "Length of Beneficiary RIB is Invalid"
            GOSUB updateResponse
            errorCode = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>
            messageInfoVal = iChannelDetails<PP.LocalClearingService.ChannelDetails.outputChannel>:' Reason: ':messageText
            GOSUB updateHistoryLog
            GOSUB exit
    
        CASE validationResult  EQ '4'
            scenarioCode = 3
			messageText = "Invalid Bank code"
			GOSUB updateResponse
			errorCode = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>
			messageInfoVal = iChannelDetails<PP.LocalClearingService.ChannelDetails.outputChannel>:' Reason: ':messageText
			GOSUB updateHistoryLog
            GOSUB exit
	
        CASE validationResult  EQ '2'
            scenarioCode = 1
            messageText = "Invalid RIB"
            GOSUB updateResponse
            errorCode = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>
            messageInfoVal = iChannelDetails<PP.LocalClearingService.ChannelDetails.outputChannel>:' Reason: ':messageText
            GOSUB updateHistoryLog
            GOSUB exit
        
    END CASE
    
*
RETURN

*-----------------------------------------------------------------------------
updateResponse:
    
    oChannelResponse<PP.LocalClearingService.PaymentResponse.returnCode>                                    = 'FAILURE'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.serviceName>                                   = 'LocalClearingService'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageText>    = messageText
    BEGIN CASE
        CASE scenarioCode = 1
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>    = 'SYT10001'
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>    = ''
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType>    = 'FATAL_ERROR'
        CASE scenarioCode = 2
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>    = 'SYT10002'
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>    = ''
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'
		CASE scenarioCode = 3
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>    = 'SYT10003'
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>    = ''
            oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'
    END CASE
    
RETURN
*------------------------------------------------------------------------------
updateHistoryLog:

    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'ERR'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = ''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = errorCode
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = messageInfoVal

    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table

RETURN
*------------------------------------------------------------------------------
exit:
RETURN TO exit
*-----------------------------------------------------------------------------
END
