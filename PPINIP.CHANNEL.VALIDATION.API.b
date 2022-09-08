* @ValidationCode : MjotMTEyMjM0NjM4OklTTy04ODU5LTE6MTYwNjgzMzY4ODQ0Mzp1bWFtYWhlc3dhcmkubWI6OTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjI2MjoyMDA=
* @ValidationInfo : Timestamp         : 01 Dec 2020 20:11:28
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 200/262 (76.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPINIP.Foundation
SUBROUTINE PPINIP.CHANNEL.VALIDATION.API(iChannelDetails, iRSCreditDets, oChannelResponse)
*------------------------------------------------------------------------------
* Public method
* The method validates the payment against PPINIP clearing requirements
*
** Generated Service Adaptor
* @stereotype subroutine
* @package PPINIP.Foundation
*!
* In/out parameters
* iChannelDetails - ChannelDetails (Single), IN
* iRSCreditDets - RSCreditDets (List), IN
* oChannelResponse - PaymentResponse (Single), OUT
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 30-Oct-2020 - Enhancement -3852895-This method validate message and field level validation for P27INST clearing
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
*    $INSERT I_PaymentWorkflowDASService_PaymentID
*    $INSERT I_PaymentWorkflowDASService_PaymentRecord
*    $INSERT I_PaymentWorkflowDASService_AdditionalPaymentRecord
**
*    $INSERT I_DebitAuthorityService_InputDADetails
*    $INSERT I_DebitAuthorityService_DebAuthDetails
**
*    $INSERT I_InboundCodeWordService_PaymentInfoKeys
*    $INSERT I_InboundCodeWordService_PaymentInformation
**
*    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
*    $INSERT I_DebitPartyDeterminationService_PartyDebitDetails
*    $INSERT I_DebitPartyDeterminationService_DASError
*    $INSERT I_DebitPartyDeterminationService_AccInfoDetails
*    $INSERT I_DebitPartyDeterminationService_InputTransactionAccDetails
**
*    $INSERT I_CreditPartyDeterminationService_CreditPartyKey
*    $INSERT I_CreditPartyDeterminationService_CreditPartyDetails
*    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsReq
*    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsList
*
*    $INSERT I_PaymentFrameworkService_PORHistoryLog
    
    $USING PP.LocalClearingService
    $USING PP.InboundCodeWordService
    $USING PP.PaymentWorkflowDASService
    $USING PP.CreditPartyDeterminationService
    $USING PP.DebitPartyDeterminationService
    $USING PP.PaymentFrameworkService
*------------------------------------------------------------------------------
*
    CALL TPSLogging("Start","PPINIP.CHANNEL.VALIDATION.API","","")
    CALL TPSLogging("Version","PPINIP.CHANNEL.VALIDATION.API","Task - 3852895, Date - 15-OCT-2020","")
    CALL TPSLogging("Input Parameters","PPINIP.CHANNEL.VALIDATION.API","iChannelDetails : <":iChannelDetails:">, iRSCreditDets : <":iRSCreditDets:">","")
*
    GOSUB initialise
    GOSUB process
*
    CALL TPSLogging("Output Parameters - END","PPINIP.CHANNEL.VALIDATION.API","oChannelResponse:<":oChannelResponse:">","")
*
RETURN
*------------------------------------------------------------------------------
initialise:
*
    oChannelResponse = '' ; scenarioCode = '' ; iCreditPartyDet = '' ; settlementDate = '' ; reqCollectionDate = ''
    relatedIBAN = '' ; mainOrChargeAccType = ''
    messageInfoVal = ''
*
RETURN
*------------------------------------------------------------------------------
process:
*   retrieve the payment details
    GOSUB getPorTransInfo
*   check whether the charge option
    GOSUB checkChargeOptionSha ; *Paragraph to check that Charge option is SHA for P27INST
*   retrieve the debit party details
    GOSUB debitPartyInfo
*   retrieve the credit party details
    GOSUB creditPartyInfo
    IF clearingTransactionType EQ 'RT' THEN
*       retrieve the Payment Order Information
        GOSUB paymentInformation
*       validate Clearing Return Code
        GOSUB validateClearingReturnCode
    END
*   validate the retrieved information
    GOSUB validateFields
*
RETURN
*------------------------------------------------------------------------------
getPorTransInfo:
* retrieve the payment details
    iPaymentID                          = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber>      = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID>     = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    IF oReadErr<PP.LocalClearingService.DASError.error> NE "" THEN
        messageInfoVal = 'POR.TRANSACTION RECORD NOT FOUND'
        GOSUB updateResponseAndExit
    END
* 33B
    instructedCcyValue = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.instructedCurrencyCode>
    clearingTransactionType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    IF clearingTransactionType NE 'RT' THEN
        GOSUB getDebitInstructedAmt
*       If DebitInstructedAmount is present and InstructedCurrency is present and if it is not Euro Currency, then
*IF debitInstructAmtPresent AND instructedCcyValue AND instructedCcyValue NE "SEK" OR instructedCcyValue NE "DKK"  THEN
        IF debitInstructAmtPresent AND instructedCcyValue AND  NOT(instructedCcyValue MATCHES 'SEK':@VM:'DKK') THEN
            IF iChannelDetails<PP.LocalClearingService.ChannelDetails.rsOutputChannelImposed> EQ 'Y' THEN  ;* If the Output channel 'P27INST' is imposed on GUI Screen
                LogEventType = 'ERR'
                LogEventDescription = ''
                LogErrorCode = 'LCL00013'
                LogAdditionalInfo = iChannelDetails<PP.LocalClearingService.ChannelDetails.outputChannel>
                messageInfoVal = 'Inst Ccy code differ from Transaction Ccy code'
                GOSUB updateHistoryLog
            END
            GOSUB updateResponseAndExit
        END
    END ELSE
        instructedCcyValue = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.instructedCurrencyCode>
        IF NOT(instructedCcyValue MATCHES 'SEK':@VM:'DKK') THEN
*IF instructedCcyValue NE "EUR" THEN
            messageInfoVal = 'Invalid Transaction Currency'
            GOSUB updateResponseAndExit
        END
    
    END
* 33B
*
RETURN
*------------------------------------------------------------------------------
validateClearingReturnCode:
*   Validate Clearing Return Code
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode> NE "" THEN
        validClrReturnCodes = "AC01":@FM:"AC04":@FM:"AC06":@FM:"AG01":@FM:"AG02":@FM:"AM05":@FM:"MD01":@FM:"BE04":@FM:"FOCR":@FM:"MD07":@FM:"MS02":@FM:"MS03":@FM:"RC01":@FM:"RR01":@FM:"RR02":@FM:"RR03":@FM:"RR04"
        LOCATE oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode> IN validClrReturnCodes SETTING Pos ELSE
            messageInfoVal = "ClearingReturnCode NOT VALID for RT"
            GOSUB updateResponseAndExit
        END
    END ELSE
        messageInfoVal = "ClearingReturnCode NOT FOUND for RT"
        GOSUB updateResponseAndExit
    END
RETURN
*------------------------------------------------------------------------------
getPaymentInformation:
*   get the Payment Information data
    oPaymentInfoError = ''
    oPaymentInformation = ''
    PP.InboundCodeWordService.getPaymentOrderInformation(iPaymentID, oPaymentInformation, oPaymentInfoError)
    informationLine = ''
    infCodeRecords = ''
    countInf = ''
    
    IF oPaymentInfoError EQ '' AND oPaymentInformation THEN
*Since oPaymentInformation is retrieved only for a particular informationCode and instructionCode, No need to loop
        IF oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationLine,1> NE '' THEN
            informationLine = oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationLine,1>
        END
    END
RETURN
*------------------------------------------------------------------------------
paymentInformation:
*   get the Payment Information data
    bulkSendersReference = oAdditionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.bulkSendersReference>
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.paymentDirection> EQ 'O' THEN
        IF bulkSendersReference EQ "" THEN
            messageInfoVal = 'Bulk Senders Reference NOT FOUND'
            GOSUB updateResponseAndExit
        END
    END ELSE
        iPaymentID = ''
        iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
        iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
        iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.informationCode> = 'INSBNK'
        iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.instructionCode> = 'ORGMSGID'  ;* Original Message ID
        GOSUB getPaymentInformation
        IF bulkSendersReference EQ '' OR informationLine EQ '' THEN
            messageInfoVal = 'Bulk Senders Reference NOT FOUND OR Original Message ID NOT FOUND for InformationCode INSBNK and InsturctionCode ORGMSGID'
            GOSUB updateResponseAndExit
        END
    END
    iPaymentID = ''
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.informationCode> = 'INSBNK'
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.instructionCode> = 'ORGSTDT' ;* Original Settlement Date
    GOSUB getPaymentInformation
    IF informationLine EQ '' THEN
        messageInfoVal = 'Original Transaction Interbank SettlementDate NOT FOUND for InformationCode INSBNK and InsturctionCode ORGSTDT'
        GOSUB updateResponseAndExit
    END

RETURN
*------------------------------------------------------------------------------
debitPartyInfo:
*   Calling Debit Party Determination Service Component.
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource> NE "OE" OR (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource> EQ "OE" AND (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ "DD" OR oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ "RV")) THEN
        iDebitPartyRole                             = ""
        iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
        iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
        oPrtyDbtDetails                             = ""
        oGetPrtyDbtError                            = ""
        PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
        IF oGetPrtyDbtError<PP.LocalClearingService.DASError.error> NE "" THEN
            messageInfoVal = 'POR.PARTYDEBIT RECORD NOT FOUND'
            GOSUB updateResponseAndExit
        END
    END
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
        messageInfoVal = 'POR.PARTYCREDIT RECORD NOT FOUND'
        GOSUB updateResponseAndExit
    END ELSE
* Fetching the output values
        crtPtyPos = 1
        totalcreditPartyRoles = DCOUNT(oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>, @VM)
        LOOP
        WHILE (crtPtyPos LE totalcreditPartyRoles)
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRole,crtPtyPos>           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRoleIndic,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyIdentifCode,crtPtyPos>    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyAccountLine,crtPtyPos>    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine1,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine2,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine3,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine4,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyInformationTag,crtPtyPos> = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyInformationTag,crtPtyPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyName,crtPtyPos>           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crName,crtPtyPos>
            crtPtyPos = crtPtyPos + 1
        REPEAT
    END
    IF NOT (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> MATCHES 'RF':@VM:'RD':@VM:'DD':@VM:'RV') THEN
        IF iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRole> NE '' THEN
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
    totalcreditPartyRoles = DCOUNT (iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRole>, @VM)
    rsCrParDetPos = 1
    LOOP
    WHILE (rsCrParDetPos LE totalcreditPartyRoles)
        crPartyRole = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRole, rsCrParDetPos>
        LOCATE crPartyRole IN iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRole> SETTING crtPtyDetPos THEN
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRole,crtPtyDetPos>        = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRole,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRoleIndic,crtPtyDetPos>   = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRoleIndic,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyIdentifCode,crtPtyDetPos> = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyIdentifCode,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyAccountLine,crtPtyDetPos> = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyAccountLine,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine1,crtPtyDetPos>   = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine1,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine2,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine3,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine4,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyInformationTag,crtPtyPos> = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyInformationTag,rsCrParDetPos>
        END ELSE
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRole,crtPtyPos>           = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRole,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyRoleIndic,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyRoleIndic,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyIdentifCode,crtPtyPos>    = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyIdentifCode,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyAccountLine,crtPtyPos>    = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyAccountLine,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine1,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine1,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine2,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine3,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyFreeLine4,rsCrParDetPos>
            iCreditPartyDet<PP.LocalClearingService.CreditPartyDets.crPartyInformationTag,crtPtyPos> = iRSCreditDets<PP.LocalClearingService.RSCreditDets.crPartyInformationTag,rsCrParDetPos>
            crtPtyPos = crtPtyPos + 1
        END
        rsCrParDetPos++
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------
validateFields:
*
    IF clearingTransactionType NE 'RT' THEN
        IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.singleMultipleIndicator> EQ 'C' THEN ;*  When the payment is from Clearing and forwarding to IP, then skip format validation
            oChannelResponse = ''
            RETURN
        END
    END
    iTransDetails = "" ; iPrtyDbtDetails = "" ; iOriginatingSource = "" ; iDebitAuthDets = "" ; iInformationDets = ""
    oValidChannelFlag = "" ; oValidateResponse = ""
* filling the payment details
    iTransDetails<PP.LocalClearingService.TransDets.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iTransDetails<PP.LocalClearingService.TransDets.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iTransDetails<PP.LocalClearingService.TransDets.transactionAmount> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>
    iTransDetails<PP.LocalClearingService.TransDets.transactionCurrencyCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    iTransDetails<PP.LocalClearingService.TransDets.clearingTransactionType> = clearingTransactionType
* filling the debit party details
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyRole> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyRoleIndicator> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRoleIndicator>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyInformationTag> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyInformationTag>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyNationalID> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyNationalID>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyIdentifierCode> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyIdentifierCode>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyAccountLine> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyFreeLine1> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyFreeLine2> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine2>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyFreeLine3> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine3>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyFreeLine4> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine4>
    iPrtyDbtDetails<PP.LocalClearingService.PartyDebitDets.debitPartyName> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName>
* filling the originatingSource
    iOriginatingSource = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
*
*      calling the credit transfer validation method

    PPINIP.Foundation.PPINIPvalidateFieldsForP27NIP(iTransDetails, iPrtyDbtDetails, iCreditPartyDet, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
    IF oValidateResponse NE '' AND iChannelDetails<PP.LocalClearingService.ChannelDetails.rsOutputChannelImposed> EQ 'Y' THEN ;* If there are errors and the Output channel 'P27INST' is imposed on GUI Screen
        LogEventType = 'ERR'
        LogEventDescription = ''
        LogErrorCode = oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>
        messageInfoVal = oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>
        LogAdditionalInfo = oValidateResponse<PP.LocalClearingService.PaymentResponse.serviceName>
        GOSUB updateHistoryLog
    END
   
* checking the output returned
    IF oValidChannelFlag<PP.LocalClearingService.ValidChannelFlag.validChannelFlag> NE "Y" THEN
        messageInfoVal = oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>
        GOSUB updateResponseAndExit
    END
*
RETURN
*-----------------------------------------------------------------------------
updateResponseAndExit:
    oChannelResponse<PP.LocalClearingService.PaymentResponse.returnCode>                                    = 'FAILURE'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.serviceName>                                   = 'PPINIP.Service'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageText>    = ''
    oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>    = 'NIP10001'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>    = iChannelDetails<PP.LocalClearingService.ChannelDetails.outputChannel>:' Reason: ':messageInfoVal
    oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'
    
*Tracer added to update HistoryLog for CLF10005 error
    LogEventType = 'INF'
    LogEventDescription = ''
    LogErrorCode = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>
    LogEventDescription = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>:'-':iTransDetails<PP.LocalClearingService.TransDets.companyID>
    LogAdditionalInfo = messageInfoVal:'-':iTransDetails<PP.LocalClearingService.TransDets.companyID>
    GOSUB updateHistoryLog
 
    CALL TPSLogging("Output Parameters - END","LocalClearingService.validateMessage","oChannelResponse:<":oChannelResponse:">","")
    GOSUB exit
*
RETURN
*-----------------------------------------------------------------------------
* The below paragraph should get the DebitInstructAmount from POR.PAYMENTFLOWDETAILS, If value present, then
* Instructed Currency value to be get from POR.TRANSACTION, the value should not contains the currency EUR.
* If it is EUR, then this channel is considered to be invalid - 33B
getDebitInstructedAmt:
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>

    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)  ;* To read POR.PAYMENTFLOWDETAILS table

    IF oPORPmtFlowDetailsGetError EQ '' THEN  ;* If record present, then
        debitInstructAmtPresent = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.debitInstructAmount>  ;*Assign the DebitInstructAmount value
    END

* 33 B
RETURN
*------------------------------------------------------------------------------
updateHistoryLog:
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
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
*** <region name= checkChargeOptionSha>
checkChargeOptionSha:
*** <desc>Paragraph to check that Charge option is SHA for P27INST </desc>
    detailsOfCharge = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.detailsOfCharges>
    IF detailsOfCharge NE 'SHA' AND clearingTransactionType NE 'RT' THEN  ;* If not SHA for clearingTransactionType other than 'RT', then set the error response
        messageInfoVal = 'detailsOfCharges is not SHA for P27INST'
        GOSUB updateResponseAndExit
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END

