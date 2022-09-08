* @ValidationCode : MjoxOTQxOTc5MjYxOkNwMTI1MjoxNTk5NTY2ODI4MDIwOmpheWFzaHJlZXQ6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3OjM4MDoyMjI=
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:37:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 222/380 (58.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPEWSP.Foundation
SUBROUTINE PPEWSP.CHANNEL.VALIDATION.API(iChannelDetails, iRSCreditDets, oChannelResponse)
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
* 01/09/2020 - Enhancement 3831744 / Task 3910362 - EWSEPA - API for validating the channel for EWSEPA Payments
*-----------------------------------------------------------------------------

    $USING PPEWSP.Foundation
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
* retrieve the mandate details and the information details of a Direct Debit payment
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> MATCHES 'RF':@VM:'RD':@VM:'RV' THEN
        GOSUB getPorDebitAuthInfo
        GOSUB getPorInformation
    END
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ 'DD' THEN
        GOSUB getPorDebitAuthInfo
    END
* validate the remittance info, length should not be more than 140
    GOSUB additionalInfo
* validate the retrieved information
    GOSUB validateFields
    GOSUB validateRemittanceInformation ; *Paragraph to check whether the Remittance Information is with in the length as part Sepa 2019 RB
*
RETURN
*------------------------------------------------------------------------------
getPorTransInfo:
* retrieve the payment details
    iPaymentID                          = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber>      = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID>     = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
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
*If DebitInstructedAmount is present and InstructedCurrency is present and if it is not Euro Currency, then
    IF debitInstructAmtPresent AND instructedCcyValue AND instructedCcyValue NE "EUR" THEN
        IF iChannelDetails<PPEWSP.Foundation.ChannelDetails.rsOutputChannelImposed> EQ 'Y' THEN  ;* If the Output channel 'RPSSCL' is imposed on OE Screen,
            LogEventType = 'ERR'
            LogEventDescription = ''
            LogErrorCode = 'LCL00013'
            LogAdditionalInfo = 'PPEWSP.Foundation'
            GOSUB updateHistoryLog
        END
        messageInfo = 'Instructed Currency is not EUR Currency'
        scenarioCode = 8
        GOSUB updateResponseAndExit
    END
* 33B
*
RETURN
*------------------------------------------------------------------------------
debitPartyInfo:
*   Calling Debit Party Determination Service Component.
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource> NE "OE" OR (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource> EQ "OE" AND (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ "DD" OR oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ "RV")) THEN
        iDebitPartyRole                             = ""
        iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
        iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
        oPrtyDbtDetails                             = ""
        oGetPrtyDbtError                            = ""
        PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
        IF oGetPrtyDbtError<PP.CreditPartyDeterminationService.DASError.error> NE "" THEN
            messageInfo = 'Payment Transaction Record Not Found'
            scenarioCode = 2
            GOSUB updateResponseAndExit
        END
        IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ 'DD' THEN
            mainOrChargeAccType = "C"
            GOSUB getAccInfoDetails
            relatedIBAN = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.relatedIBAN>
        END
    END ELSE
;*debit side mapping for OE
        mainOrChargeAccType = "D"
        GOSUB getAccInfoDetails
        oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine> = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.relatedIBAN>
        oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitPartyLine1>
        oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAddressLine1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitPartyLine2>
        oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAddressLine2> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.debitPartyLine3>
        oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyCountry> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.orderingPartyResidency>
    END
*
RETURN
*------------------------------------------------------------------------------
creditPartyInfo:
*   Calling Debit Party Determination Service Component.
    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
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
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRole,crtPtyPos>           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,crtPtyPos>    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,crtPtyPos>    = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine1,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine2,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine3,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine4,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyInformationTag,crtPtyPos> = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyInformationTag,crtPtyPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyName,crtPtyPos>           = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crName,crtPtyPos>
            crtPtyPos = crtPtyPos + 1
        REPEAT
    END
    IF NOT (oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> MATCHES 'RF':@VM:'RD':@VM:'DD':@VM:'RV') THEN
        IF iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRole> NE '' THEN
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
    totalcreditPartyRoles = DCOUNT (iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRole>, @VM)
    rsCrParDetPos = 1
    LOOP
    WHILE (rsCrParDetPos LE totalcreditPartyRoles)
        crPartyRole = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRole, rsCrParDetPos>
        LOCATE crPartyRole IN iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING crtPtyDetPos THEN
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRole,crtPtyDetPos>        = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRole,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,crtPtyDetPos>   = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRoleIndic,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,crtPtyDetPos> = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyIdentifCode,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,crtPtyDetPos> = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyAccountLine,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine1,crtPtyDetPos>   = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine1,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine2,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine3,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine4,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyInformationTag,crtPtyPos> = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyInformationTag,rsCrParDetPos>
        END ELSE
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRole,crtPtyPos>           = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRole,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyRoleIndic,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,crtPtyPos>    = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyIdentifCode,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,crtPtyPos>    = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyAccountLine,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine1,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine1,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine2,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine2,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine3,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine3,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine4,crtPtyPos>      = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyFreeLine4,rsCrParDetPos>
            iCreditPartyDet<PPEWSP.Foundation.CreditPartyDets.crPartyInformationTag,crtPtyPos> = iRSCreditDets<PPEWSP.Foundation.RSCreditDets.crPartyInformationTag,rsCrParDetPos>
            crtPtyPos = crtPtyPos + 1
        END
        rsCrParDetPos++
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------
getPorDebitAuthInfo:
* retrieve the mandate details
    iInputDebitAuthority = ''; oDebAuthDetails = ''; oGetDAInfoError = ''
*
    iInputDebitAuthority<PP.DebitAuthorityService.InputDADetails.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iInputDebitAuthority<PP.DebitAuthorityService.InputDADetails.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
*
    PP.DebitAuthorityService.getDebitAuthInfo(iInputDebitAuthority,oDebAuthDetails,oGetDAInfoError)
    IF oGetDAInfoError NE "" THEN
        messageInfo = 'Debit Auth Record Not Found'
        scenarioCode = 6
        GOSUB updateResponseAndExit
    END
*
RETURN
*-----------------------------------------------------------------------------
getPorInformation:
* retrieve the payment information details
    iPaymentID = ''; oPaymentInformation = ''; oPaymentInfoError = ''
*
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.informationCode> = "INSBNK"
    PP.InboundCodeWordService.getPaymentOrderInformation(iPaymentID, oPaymentInformation, oPaymentInfoError)
    IF oPaymentInfoError NE "" THEN
        messageInfo = 'POR_Information Record Not Found'
        scenarioCode = 7
        GOSUB updateResponseAndExit
    END
* retrieve the settlement date of original transaction
    orgstdtFMPOS = ''; orgstdtVMPOS = ''
    FIND 'ORGSTDT' IN oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.instructionCode> SETTING orgstdtFMPOS,orgstdtVMPOS THEN
        settlementDate = oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationLine,orgstdtVMPOS>
    END
* retrieve the requested collection date of original transaction
    orgrcldtFMPOS = ''; orgrcldtVMPOS = ''
    FIND 'ORGRCLDT' IN oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.instructionCode> SETTING orgrcldtFMPOS,orgrcldtVMPOS THEN
        reqCollectionDate = oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationLine,orgrcldtVMPOS>
    END
*
RETURN
*------------------------------------------------------------------------------
validateFields:
*
    iTransDetails = "" ; iPrtyDbtDetails = "" ; iOriginatingSource = "" ; iDebitAuthDets = "" ; iInformationDets = ""
    oValidChannelFlag = "" ; oValidateResponse = ""
* filling the payment details
    iTransDetails<PPEWSP.Foundation.TransDets.companyID> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iTransDetails<PPEWSP.Foundation.TransDets.ftNumber> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iTransDetails<PPEWSP.Foundation.TransDets.transactionAmount> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>
    iTransDetails<PPEWSP.Foundation.TransDets.transactionCurrencyCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    iTransDetails<PPEWSP.Foundation.TransDets.pmtDirection> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.paymentDirection>
    iTransDetails<PPEWSP.Foundation.TransDets.clearingTransactionType> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
* filling the debit party details
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyRoleIndicator> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRoleIndicator>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyInformationTag> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyInformationTag>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyNationalID> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyNationalID>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyIdentifierCode>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyFreeLine1> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyFreeLine2> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine2>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyFreeLine3> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine3>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyFreeLine4> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine4>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyName> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName>
    iPrtyDbtDetails<PPEWSP.Foundation.PartyDebitDets.debitPartyAddressLine1> = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAddressLine1>
* filling the originatingSource
    iOriginatingSource = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
*
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> MATCHES 'RF':@VM:'RD':@VM:'DD':@VM:'RV' THEN
*      filling some additional payment details
        iTransDetails<PPEWSP.Foundation.TransDets.bulkSendersReference> = oAdditionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.bulkSendersReference>
        iTransDetails<PPEWSP.Foundation.TransDets.customerSpecifiedReference> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.customerSpecifiedReference>
        iTransDetails<PPEWSP.Foundation.TransDets.sendersReferenceIncoming> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceIncoming>
        iTransDetails<PPEWSP.Foundation.TransDets.clearingReturnCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>
        iTransDetails<PPEWSP.Foundation.TransDets.requestedCollectionDate> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.requestedCollectionDate>
        iTransDetails<PPEWSP.Foundation.TransDets.clearingNatureCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode>
        iTransDetails<PPEWSP.Foundation.TransDets.bankOperationCode> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.bankOperationCode>
        iTransDetails<PPEWSP.Foundation.TransDets.detailsOfCharges> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.detailsOfCharges>
        iTransDetails<PPEWSP.Foundation.TransDets.batchIndicator> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.batchIndicator>
        iTransDetails<PPEWSP.Foundation.TransDets.relatedIBAN> = relatedIBAN
*      filling the mandate details
        iDebitAuthDets<PPEWSP.Foundation.DebitAuthDets.creditorID> = oDebAuthDetails<PP.DebitAuthorityService.DebAuthDetails.creditorID>
        iDebitAuthDets<PPEWSP.Foundation.DebitAuthDets.mandateReference> = oDebAuthDetails<PP.DebitAuthorityService.DebAuthDetails.mandateReference>
        iDebitAuthDets<PPEWSP.Foundation.DebitAuthDets.signatureDate> = oDebAuthDetails<PP.DebitAuthorityService.DebAuthDetails.signatureDate>
*      filling the information details
        iInformationDets<PPEWSP.Foundation.InformationDets.informationLine> = settlementDate:@VM:reqCollectionDate
*      calling the direct debit validation method
        PPEWSP.Foundation.fieldValidationDD(iTransDetails, iPrtyDbtDetails, iCreditPartyDet, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
        IF oValidateResponse NE '' THEN
            LogEventType = 'ERR'
            LogEventDescription = ''
            LogErrorCode = 'LCL00013'
            LogAdditionalInfo = iChannelDetails<PPEWSP.Foundation.ChannelDetails.outputChannel>:' Reason: ':oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>
            GOSUB updateHistoryLog
        END
    END ELSE
*      calling the credit transfer validation method
        PPEWSP.Foundation.fieldValidationCT(iTransDetails, iPrtyDbtDetails, iCreditPartyDet, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
        IF oValidateResponse NE '' THEN
            LogEventType = 'ERR'
            LogEventDescription = ''
            LogErrorCode = 'LCL00013'
            LogAdditionalInfo = iChannelDetails<PPEWSP.Foundation.ChannelDetails.outputChannel>:' Reason: ':oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>
            GOSUB updateHistoryLog
        END
    END
* checking the output returned
    IF oValidChannelFlag<PPEWSP.Foundation.ValidChannelFlag.validChannelFlag> NE "Y" THEN
        scenarioCode = 4
        GOSUB updateResponseAndExit
    END
*
RETURN
*-----------------------------------------------------------------------------
updateResponseAndExit:
    oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.returnCode>                                    = 'FAILURE'
    oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.serviceName>                                   = 'PPEWSP.Foundation'
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
            oChannelResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>    = iChannelDetails<PPEWSP.Foundation.ChannelDetails.outputChannel>:' Reason: ':oValidateResponse<PP.CreditPartyDeterminationService.PaymentResponse.responseMessages,1,PP.CreditPartyDeterminationService.ResponseMessage.messageInfo>
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
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.mainOrChargeAccType> = mainOrChargeAccType
*
    PP.DebitPartyDeterminationService.getAccInfoDetails(iTransAccDetails, oAccInfoDetails, oGetAccError)
*
*
RETURN
*-----------------------------------------------------------------------------
* The below paragraph should get the DebitInstructAmount from POR.PAYMENTFLOWDETAILS, If value present, then
* Instructed Currency value to be get from POR.TRANSACTION, the value should not contains the currency EUR.
* If it is EUR, then this channel is considered to be invalid - 33B
getDebitInstructedAmt:

    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>

    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)  ;* To read POR.PAYMENTFLOWDETAILS table

    IF oPORPmtFlowDetailsGetError EQ '' THEN  ;* If record present, then
        debitInstructAmtPresent = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.debitInstructAmount>  ;*Assign the DebitInstructAmount value
    END

* 33 B
RETURN
*------------------------------------------------------------------------------
updateHistoryLog:
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
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
*** <region name= validateRemittanceInformation>
validateRemittanceInformation:
*** <desc>Paragraph to check whether the Remittance Information is with in the length as part Sepa 2019 RB </desc>
    IF oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.paymentMethod> MATCHES "INST":@VM:"NRINST" THEN
        RETURN      ;* The below validation is not applicable for Instant or Near real Instant payments
    END
    
    Vpos = ''
    LOCATE 'RemittanceStrdLength' IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING Vpos THEN
        remittanceStrdln = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,Vpos>
    END
    Vpos = ''
    LOCATE 'RemittanceUstrdLength' IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING Vpos THEN
        remittanceUstrdln = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,Vpos>
    END
    
    Vpos = ''
    aosList = ''
    LOCATE 'BenBankAOSList' IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING Vpos THEN
        aosList =  oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,Vpos>
    END
    IF aosList EQ '' THEN       ;* When this aosList is null, then skip further processing in this paragraph
        RETURN                  ;* go out of this paragraph
    END
**
    recPORInformation = ''
    errPORInformation = ''

    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.INFORMATION', iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>, '', recPORInformation, errPORInformation)
    
    BEGIN CASE
        CASE recPORInformation      ;* If record is present, then
            infoCode = recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Informationcode>
            instructCode = recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Instructioncode>
            
        
            LOCATE "LCLINSCD" IN instructCode<1,1> SETTING lclPos THEN
                clInsCodeValue = recPORInformation<PP.PaymentWorkflowGUI.PorInformation.Informationline,lclPos>
            END
            IF clInsCodeValue NE "PERI" AND aosList EQ "ERI" THEN
                clInsCodeValue = "PERI"
                GOSUB updatePorInformation      ; *Paragraph to update POR Information to update PERI in Information line
            END
           
            IF clInsCodeValue EQ "PERI" AND aosList EQ "ERI" AND remittanceStrdln AND remittanceStrdln GT "280" THEN
                GOSUB setErrorScenario9
            END
        
        CASE aosList EQ "ERI"   ;* When the record is not present, the but the receiving bic is supports ERI
            clInsCodeValue = "PERI"
            GOSUB updatePorInformation ; *Paragraph to update POR Information to update PERI in Information line
            IF clInsCodeValue EQ "PERI" AND aosList EQ "ERI" AND remittanceStrdln AND remittanceStrdln GT "280" THEN
                GOSUB setErrorScenario9
            END
    
    END CASE
        
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= updatePorInformation>
updatePorInformation:
*** <desc>Paragraph to update POR Information to update PERI in Information line </desc>
    iPaymentID = ''
    oPaymentInformation = ''
    oPaymentInfoError = ''
    iPaymentOrderInfo = ''
    oInsertInfoErr = ''

    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.informationCode> = "INSBNK"
    
    PP.InboundCodeWordService.getPaymentOrderInformation(iPaymentID, oPaymentInformation, oPaymentInfoError)
    
    IF oPaymentInformation NE '' THEN
        countPorInfTypelineSeq = DCOUNT(oPaymentInformation<PP.InboundCodeWordService.PaymentInformation.informationTypeLineSequence>,@SM)
        countPorInfTypelineSeq = countPorInfTypelineSeq + 1
    END ELSE
        countPorInfTypelineSeq = 1
    END
        
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.companyID> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.ftNumber> = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.informationCode> = "INSBNK"
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.instructionCode> = "LCLINSCD"
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.informationTypeLineSequence> = countPorInfTypelineSeq
    iPaymentOrderInfo<PP.InboundCodeWordService.PaymentOrderInfo.informationLine> = clInsCodeValue  ;* Ex: PERI
    PP.InboundCodeWordService.insertPORInformation(iPaymentOrderInfo, oInsertInfoErr) ;* To update POR.INFORMATION in POR.SUPPLEMETARY.INFO

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= setErrorScenario9>
setErrorScenario9:
*** <desc> </desc>
    messageInfo = 'Remittance Structured tag length exceed 280 characters &'
    scenarioCode = 9
    IF iChannelDetails<PPEWSP.Foundation.ChannelDetails.rsOutputChannelImposed> EQ 'Y' THEN  ;* If the Output channel 'RPSSCL' is imposed on OE Screen,
        LogEventType = 'ERR'
        LogEventDescription = 'clInsCodeValue / aosList ':clInsCodeValue:' / ':aosList
        LogErrorCode = 'LCL00013'
        LogAdditionalInfo = 'PPEWSP.Foundation'
        GOSUB updateHistoryLog
    END
    GOSUB updateResponseAndExit
RETURN
*** </region>
*-----------------------------------------------------------------------------
additionalInfo:
* read the additional info
    iAdditionalInf<PP.DuplicateCheckService.PORAdditionalInf.companyID>     = iChannelDetails<PPEWSP.Foundation.ChannelDetails.companyID>
    iAdditionalInf<PP.DuplicateCheckService.PORAdditionalInf.ftNumber>      = iChannelDetails<PPEWSP.Foundation.ChannelDetails.ftNumber>
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
