* @ValidationCode : Mjo3NTEzOTUxMDI6Q3AxMjUyOjE2MDUwMTQ1MTkzNjA6amF5YXNocmVldDozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA3LjIwMjAwNzAxLTA2NTc6MjQzOjE3MQ==
* @ValidationInfo : Timestamp         : 10 Nov 2020 18:51:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 171/243 (70.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPNPCT.Foundation
SUBROUTINE PPNPCT.CHANNEL.VALIDATION.API(iChannelDetails, iRSCreditDets, oChannelResponse)
*------------------------------------------------------------------------------
* Public method
*
*
** Generated Service Adaptor
* @stereotype subroutine
* @package pp
*!
* In/out parameters:
* iChannelDetails - ChannelDetails (Single), IN
* iRSCreditDets - RSCreditDets (List), IN
* oChannelResponse - PaymentResponse (Single), OUT
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*23/10/2020 - Enhancement 3852940/Task 4017144  - NORDIC - API for validating the channel for Nordic CT Payments
*-----------------------------------------------------------------------------

    $USING PPNPCT.Foundation
    $USING PP.PaymentWorkflowDASService
    $USING PP.DebitAuthorityService
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowGUI
    $USING PP.InboundCodeWordService
    $USING PP.DuplicateCheckService
*------------------------------------------------------------------------------
*
    GOSUB initialise
    GOSUB process
*
RETURN
*------------------------------------------------------------------------------
initialise:
*
    oChannelResponse = '' ; scenarioCode = '' ; iCreditPartyDet = '' ; settlementDate = '' ; reqCollectionDate = ''
    relatedIBAN = '' ; mainOrChargeAccType = ''
*
RETURN
*------------------------------------------------------------------------------
process:
* retrieve the payment details
    GOSUB getPorTransInfo
* retrieve the debit party details
    GOSUB debitPartyInfo
* retrieve the credit party details
    GOSUB creditPartyInfo
* validate the remittance info, length should not be more than 140
    GOSUB additionalInfo
* validate the retrieved information
    GOSUB validateFields
RETURN
*------------------------------------------------------------------------------
getPorTransInfo:
* retrieve the payment details
    iPaymentID                          = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber>      = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID>     = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    IF oReadErr<PP.CreditPartyDeterminationService.DASError.error> NE "" THEN
        messageInfo = 'Payment Transaction Record Not Found'
        scenarioCode = 1
        GOSUB updateResponseAndExit
    END

* 33B
    GOSUB getDebitInstructedAmt
    instructedCcyValue = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.instructedCurrencyCode>
*If DebitInstructedAmount is present and InstructedCurrency is present and if it is not DKK/SEK Currency, then
    IF debitInstructAmtPresent AND instructedCcyValue AND (instructedCcyValue NE "DKK" OR instructedCcyValue NE "SEK")  THEN
        IF iChannelDetails<PPNPCT.Foundation.ChannelDetails.rsOutputChannelImposed> EQ 'Y' THEN  ;* If the Output channel 'P27NP' is imposed on OE Screen,
            LogEventType = 'ERR'
            LogEventDescription = ''
            LogErrorCode = 'LCL00013'
            LogAdditionalInfo = 'PPNPCT.Foundation'
            GOSUB updateHistoryLog
        END
        messageInfo = 'Instructed Currency is not DKK/SEK Currency'
        scenarioCode = 8
        GOSUB updateResponseAndExit
    END
* 33B
*
RETURN
*------------------------------------------------------------------------------
debitPartyInfo:
;*debit side mapping for OE
    mainOrChargeAccType = "D"
    GOSUB getAccInfoDetails
    oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine> = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.relatedIBAN>
    oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitPartyLine1>
    oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAddressLine1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitPartyLine2>
    oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAddressLine2> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitPartyLine3>
    oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyCountry> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.orderingPartyResidency>
*
RETURN
*------------------------------------------------------------------------------
creditPartyInfo:
*   Calling Debit Party Determination Service Component.
    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    oCreditPartyDet = ""
    oGetCreditError = ""
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)
    IF oGetCreditError<PP.CreditPartyDeterminationService.DASError.error> NE "" THEN
        messageInfo = 'Credit Party Record Not Found'
        scenarioCode = 3
        GOSUB updateResponseAndExit
    END ELSE
* Fetching the output values
        crtPtyPos = 1
        totalcreditPartyRoles = DCOUNT(oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>, @VM)
        LOOP
        WHILE (crtPtyPos LE totalcreditPartyRoles)
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRole,crtPtyPos>           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,crtPtyPos>    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,crtPtyPos>    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine1,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine2,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine3,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine4,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyInformationTag,crtPtyPos> = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyInformationTag,crtPtyPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyName,crtPtyPos>           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crName,crtPtyPos>
            crtPtyPos = crtPtyPos + 1
        REPEAT
    END
    IF NOT (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> MATCHES 'RF':@VM:'RD':@VM:'DD':@VM:'RV') THEN
        IF iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRole> NE '' THEN
            GOSUB checkPartyCreditRole
        END
    END
*
RETURN
*------------------------------------------------------------------------------
checkPartyCreditRole:
*--------------------
* This para checks crPartyRole is present in the RSCreditDets and map the output valiables accordingly.
* Assign the output values iRSCreditDets to iCreditPartyDet
    totalcreditPartyRoles = DCOUNT (iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRole>, @VM)
    rsCrParDetPos = 1
    LOOP
    WHILE (rsCrParDetPos LE totalcreditPartyRoles)
        crPartyRole = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRole, rsCrParDetPos>
        LOCATE crPartyRole IN iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING crtPtyDetPos THEN
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRole,crtPtyDetPos>       = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRole,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,crtPtyDetPos>   = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRoleIndic,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,crtPtyDetPos> = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyIdentifCode,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,crtPtyDetPos> = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyAccountLine,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine1,crtPtyDetPos>   = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine1,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine2,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine3,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine4,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyInformationTag,crtPtyPos> = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyInformationTag,rsCrParDetPos>
        END ELSE
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRole,crtPtyPos>           = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRole,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyRoleIndic,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,crtPtyPos>    = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyIdentifCode,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,crtPtyPos>    = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyAccountLine,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine1,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine1,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine2,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine3,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyFreeLine4,rsCrParDetPos>
            iCreditPartyDet<PPNPCT.Foundation.CreditPartyDets.crPartyInformationTag,crtPtyPos> = iRSCreditDets<PPNPCT.Foundation.RSCreditDets.crPartyInformationTag,rsCrParDetPos>
            crtPtyPos = crtPtyPos + 1
        END
        rsCrParDetPos++
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------
validateFields:
*
    iTransDetails = "" ; iPrtyDbtDetails = "" ; iOriginatingSource = "" ; iDebitAuthDets = "" ; iInformationDets = ""
    oValidChannelFlag = "" ; oValidateResponse = ""
* filling the payment details
    iTransDetails<PPNPCT.Foundation.TransDets.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iTransDetails<PPNPCT.Foundation.TransDets.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iTransDetails<PPNPCT.Foundation.TransDets.transactionAmount> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>
    iTransDetails<PPNPCT.Foundation.TransDets.transactionCurrencyCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    iTransDetails<PPNPCT.Foundation.TransDets.pmtDirection> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.paymentDirection>
    iTransDetails<PPNPCT.Foundation.TransDets.clearingTransactionType> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
* filling the debit party details
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyRoleIndicator> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRoleIndicator>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyInformationTag> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyInformationTag>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyNationalID> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyNationalID>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyIdentifierCode> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyIdentifierCode>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyAccountLine> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyFreeLine1> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyFreeLine2> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine2>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyFreeLine3> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine3>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyFreeLine4> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine4>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyName> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName>
    iPrtyDbtDetails<PPNPCT.Foundation.PartyDebitDets.debitPartyAddressLine1> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAddressLine1>
* filling the originatingSource
    iOriginatingSource = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
*      calling the credit transfer validation method
    PPNPCT.Foundation.ppnpctChannelValidateCTApi(iTransDetails, iPrtyDbtDetails, iCreditPartyDet, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
    IF oValidateResponse NE '' THEN
        LogEventType = 'ERR'
        LogEventDescription = ''
        LogErrorCode = 'LCL00013'
        LogAdditionalInfo = iChannelDetails<PPNPCT.Foundation.ChannelDetails.outputChannel>:' Reason: ':oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>
        GOSUB updateHistoryLog
    END
* checking the output returned
    IF oValidChannelFlag<PPNPCT.Foundation.ValidChannelFlag.validChannelFlag> NE "Y" THEN
        scenarioCode = 4
        GOSUB updateResponseAndExit
    END
*
RETURN
*-----------------------------------------------------------------------------
updateResponseAndExit:
    oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.returnCode>                                    = 'FAILURE'
    oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.serviceName>                                   = 'PPNPCT.Foundation'
    oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageText>    = ''
    BEGIN CASE
        CASE scenarioCode = 1
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageCode>    = 'LCL00013'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>    = messageInfo
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageType>    = 'FATAL_ERROR'
        CASE scenarioCode = 2 OR scenarioCode = 3 OR scenarioCode = 5 OR scenarioCode = 6 OR scenarioCode = 7 OR scenarioCode = 8
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageCode>    = 'LCL00013'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>    = messageInfo
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'
        CASE scenarioCode = 4
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.returnCode>                                        = oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.returnCode>
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.serviceName>                                       = oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.serviceName>
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageCode>    = oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageCode>
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>    = iChannelDetails<PPNPCT.Foundation.ChannelDetails.outputChannel>:' Reason: ':oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageType>    = oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageType>
        CASE scenarioCode = 9
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageCode>  = 'LCL00013'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>  = messageInfo
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageType>  = 'NON_FATAL_ERROR'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageText>  = "FF01" ;* When this is the last channel defined in PP.CONTRACT, then this error will also get update into Payment response object
        CASE scenarioCode = 10
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageCode>  = 'LCL00013'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageText>  = 'Additional Info length cannot be more than 140'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageType>  = 'NON_FATAL_ERROR'
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>  = messageInfo
    END CASE
*
    
    GOSUB exit
*
RETURN
*------------------------------------------------------------------------------
getAccInfoDetails:
** Assign input and output for the method getAccInfoDetails in order to get relatedIBAN value
    iTransAccDetails = '' ; oAccInfoDetails = '' ; oGetAccError = ''
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.companyID> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.ftNumber> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.mainOrChargeAccType> = mainOrChargeAccType
*
    PP.DebitPartyDeterminationService.getAccInfoDetails(iTransAccDetails, oAccInfoDetails, oGetAccError)
*
*
RETURN
*-----------------------------------------------------------------------------
* The below paragraph should get the DebitInstructAmount from POR.PAYMENTFLOWDETAILS, If value present, then
* Instructed Currency value to be get from POR.TRANSACTION, the value should not contains the currency DKK/SEK.
* If it is DKK/SEK, then this channel is considered to be invalid - 33B
getDebitInstructedAmt:

    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>

    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)  ;* To read POR.PAYMENTFLOWDETAILS table

    IF oPORPmtFlowDetailsGetError EQ '' THEN  ;* If record present, then
        debitInstructAmtPresent = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.debitInstructAmount>  ;*Assign the DebitInstructAmount value
    END

* 33 B
RETURN
*------------------------------------------------------------------------------
updateHistoryLog:
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = LogEventType
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = LogEventDescription
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = LogErrorCode
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = LogAdditionalInfo

    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table

RETURN
*------------------------------------------------------------------------------
exit:
RETURN TO exit
*-----------------------------------------------------------------------------
*** <region name= updatePorInformation>
updatePorInformation:
*** <desc>Paragraph to update POR Information to update PERI in Information line </desc>
    iPaymentID = ''
    oPaymentInformation = ''
    oPaymentInfoError = ''
    iPaymentOrderInfo = ''
    oInsertInfoErr = ''

    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.informationCode> = "INSBNK"
    
    PP.InboundCodeWordService.getPaymentOrderInformation(iPaymentID, oPaymentInformation, oPaymentInfoError)
    
    IF oPaymentInformation NE '' THEN
        countPorInfTypelineSeq = DCOUNT(oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationTypeLineSequence>,@SM)
        countPorInfTypelineSeq = countPorInfTypelineSeq + 1
    END ELSE
        countPorInfTypelineSeq = 1
    END
        
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.companyID> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.ftNumber> = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.informationCode> = "INSBNK"
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.instructionCode> = "LCLINSCD"
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.informationTypeLineSequence> = countPorInfTypelineSeq
    PP.InboundCodeWordService.insertPORInformation(iPaymentOrderInfo, oInsertInfoErr) ;* To update POR.INFORMATION in POR.SUPPLEMETARY.INFO

RETURN
*** </region>
*-----------------------------------------------------------------------------
additionalInfo:
* read the additional info
    iAdditionalInf<PP.DuplicateCheckService.PORAdditionalInf.companyID>     = iChannelDetails<PPNPCT.Foundation.ChannelDetails.companyID>
    iAdditionalInf<PP.DuplicateCheckService.PORAdditionalInf.ftNumber>      = iChannelDetails<PPNPCT.Foundation.ChannelDetails.ftNumber>
    iAdditionalInf<PP.DuplicateCheckService.PORAdditionalInf.additionalInformationCode>  = "RMTINF"
    PP.DuplicateCheckService.getPORAdditionalInf(iAdditionalInf, oAdditionalInf, oAdditionalInfError)
* retrieve the additional info and check the length
    additionalInfLine = oAdditionalInf<PP.DuplicateCheckService.AdditionalInfDetails.additionalInfLine>
    addinfline =''
    CHANGE @FM TO @VM IN additionalInfLine
    LOOP
        REMOVE additionalInfLine.VAL FROM additionalInfLine SETTING ADDINF.POS
    WHILE additionalInfLine.VAL:ADDINF.POS
        IF addinfline EQ '' THEN
            addinfline = addinfline:additionalInfLine.VAL
        END ELSE
            addinfline = addinfline:' ':additionalInfLine.VAL ;* adding space inbetween, each info line
        END
    REPEAT
    addinflen = LEN(addinfline)
* if length is more then 140 throw an error to the user
    IF addinflen GT '140' THEN
        messageInfo = 'Additional Info length cannot be more than 140'
        scenarioCode = 10
        GOSUB updateResponseAndExit
    END
    
RETURN
*------------------------------------------------------------------------------
END
