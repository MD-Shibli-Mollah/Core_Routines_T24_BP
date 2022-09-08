* @ValidationCode : MjotMTUxNTg0NTc0NzpJU08tODg1OS0xOjE2MDgwMTkyMjc2MjI6dW1hbWFoZXN3YXJpLm1iOjExOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6MjE5Ojk3
* @ValidationInfo : Timestamp         : 15 Dec 2020 13:30:27
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 97/219 (44.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPINIP.Foundation
SUBROUTINE PPINIP.validateFieldsForP27NIP(iTransDets, iPrtyDbtDets, iCreditPartyDets, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
*------------------------------------------------------------------------------
* Private method
* The method validates the payments fields against Nordic Instant clearing requirements
*
* In/out parameters:
* iTransDets - TransDets (Single), IN
* iPrtyDbtDets - PartyDebitDets (List), IN
* iCreditPartyDets - CreditPartyDets (List), IN
* iOriginatingSource - String (Single), IN
* iDebitAuthDets - DebitAuthDets (List), IN
* iInformationDets - InformationDets (List), IN
* oValidChannelFlag - ValidChannelFlag (Single), OUT*
* oValidateResponse - PaymentResponse (Single), OUT
*-----------------------------------------------------------------------------
* Method description:
*
* This routine will be attached as an API in PP.CLEARING table for Instant payments (rtgsSystem is I)
*-----------------------------------------------------------------------------
* Modification History :
*
*-----------------------------------------------------------------------------
*    $INSERT I_EQUATE
*
    $USING PP.PaymentFrameworkService

    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsReq
    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsList
    $INSERT I_PaymentWorkflowDASService_PaymentRecord
    $INSERT I_PaymentWorkflowDASService_PaymentID

    $INSERT I_CountryIBANStructureService_PotentialIBAN
    $INSERT I_CountryIBANStructureService_IBANDetail
    
    $USING PP.CountryIBANStructureService
    $USING PP.LocalClearingService
*------------------------------------------------------------------------------
*
    CALL TPSLogging("Start","PPINIP.validateFields","","")
    CALL TPSLogging("Version","PPINIP.validateFields","Task - 2226120 , Date - 28-Aug-2017","")
    CALL TPSLogging("Input parameter","PPINIP.validateFields","iTransDets : <":iTransDets:">","")
    CALL TPSLogging("Input parameter","PPINIP.validateFields","iPrtyDbtDets : <":iPrtyDbtDets:">","")
    CALL TPSLogging("Input parameter","PPINIP.validateFields","iCreditPartyDets : <":iCreditPartyDets:">","")
    CALL TPSLogging("Input parameter","PPINIP.validateFields","iOriginatingSource : <":iOriginatingSource:">","")
    CALL TPSLogging("Input parameter","PPINIP.validateFields","iDebitAuthDets : <":iDebitAuthDets:">","")
    CALL TPSLogging("Input parameter","PPINIP.validateFields","iInformationDets : <":iInformationDets:">","")
*
    GOSUB initialise
    GOSUB process
*
    CALL TPSLogging("Output Parameters","PPINIP.validateFields","oValidChannelFlag : <":oValidChannelFlag:">, oValidateResponse : <":oValidateResponse:">","")
*
RETURN
*------------------------------------------------------------------------------
initialise:
    oValidChannelFlag = ''
    oValidateResponse = ''
    oValidChannelFlag<PP.LocalClearingService.ValidChannelFlag.validChannelFlag> = "N"
    clearingTransactionType = iTransDets<PP.LocalClearingService.TransDets.clearingTransactionType>
RETURN
*------------------------------------------------------------------------------
process:
*
    GOSUB validateFTNumber
    GOSUB getPorTransInfo
    IF clearingTransactionType NE 'RT' THEN
        GOSUB validateEndToEndReference
    END
    GOSUB validateTransactionAmount
    GOSUB validateTransactionCurrencyCode
 
    IF iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyRole> NE "" THEN
        GOSUB validateDebitPartyAccountLine
        GOSUB validateDebitPartyIdentifierCode
        GOSUB validateDebitPartyName
     
    END
   
    GOSUB validateCreditPartyIdentifierCode
    GOSUB validateCreditPartyAccountLine
    GOSUB validateCreditPartyName
    
    GOSUB validateOriginatorBankRef
    oValidChannelFlag<PP.LocalClearingService.ValidChannelFlag.validChannelFlag> = "Y"
*
RETURN
*------------------------------------------------------------------------------
validateEndToEndReference:
    
    IF oPaymentRecord<PaymentRecord.customerSpecifiedReference> EQ '' THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "CustomerSpecifiedReference NOT FOUND"
        GOSUB finalise
    END
    
RETURN
*------------------------------------------------------------------------------
validateFTNumber:
    IF iTransDets<PP.LocalClearingService.TransDets.ftNumber> EQ "" THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "FTNumber NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateTransactionAmount:
    IF iTransDets<PP.LocalClearingService.TransDets.transactionAmount> EQ "" THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "TransactionAmount NOT FOUND"
        GOSUB finalise
    END

* Transaction Amount must be 0.01 or more and 999999999.99 or les and the fractional part has a maximum of two digits.
    IF iTransDets<PP.LocalClearingService.TransDets.transactionAmount> <= 0 THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "TransactionAmount OUT OF RANGE Value"
        GOSUB finalise
    END
    IF iTransDets<PP.LocalClearingService.TransDets.transactionAmount> >= 1000000000 THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "TransactionAmount OUT OF RANGE Value"
        GOSUB finalise
    END

    Decimal = FIELD(iTransDets<PP.LocalClearingService.TransDets.transactionAmount>, ".", 2)
    IF LEN(Decimal) > 2 THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "TransactionAmount TOO MANY DECIMALS Value"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateTransactionCurrencyCode:
    IF iTransDets<PP.LocalClearingService.TransDets.transactionCurrencyCode> EQ "" THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "TransactionCurrencyCode NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateDebitPartyIdentifierCode:
    FIND "ORDINS" IN iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction CreditorAgent PartyIdentifierCode NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
            END
            GOSUB finalise
        END
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyAccountLine:
    FIND "BENFCY" IN iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyAccountLine,VMp> EQ "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction Debtor Account IBAN NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT FOUND"
            END
            GOSUB finalise
        END
        iPotentialIBAN = ""
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PP.LocalClearingService.TransDets.companyID>
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyAccountLine,VMp>,"/","")
        oIBANDetail = ""
        oDetIBANResponse = ""
*
        PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
*
        IF oDetIBANResponse<PP.LocalClearingService.PaymentResponse.returnCode> NE "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction Debtor Account NOT IBAN"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT IBAN"
            END
            GOSUB finalise
        END
    END
RETURN

*----------------------------------------------------------------------------
validateCreditPartyName:
    
    FIND "BENFCY" IN iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyName,VMp> EQ "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction Debtor Name NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "creditPartyName NOT FOUND"
            END
            GOSUB finalise
        END
    END ELSE
        IF oDetIBANResponse<PP.LocalClearingService.PaymentResponse.returnCode> NE "" THEN
            oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "BENFCY in creditPartyName NOT IBAN"
            GOSUB finalise
        END
    END
RETURN
*-----------------------------------------------------------------------------
validateDebitPartyName:
    FIND "ORDPTY" IN iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyName,VMp> EQ "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction Creditor Name NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "debitPartyName NOT FOUND"
            END
            GOSUB finalise
        END
    END ELSE
        IF clearingTransactionType EQ 'RT' THEN
            oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "ORDPTY in Original Transaction Creditor Name NOT FOUND"
        END ELSE
            oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "ORDPTY in debitPartyName NOT FOUND"
        END
        GOSUB finalise
    END
    
RETURN
*-----------------------------------------------------------------------------
validateOriginatorBankRef:
* Paragraph to validate whether the sender's reference is present in the message, if not present, throw an error
    
    IF oPaymentRecord<PaymentRecord.sendersReferenceIncoming> EQ '' THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "sendersReference NOT FOUND"
        GOSUB finalise
    END
    
RETURN
*-----------------------------------------------------------------------------
validateCreditPartyIdentifierCode:
    FIND "ACWINS" IN iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction Debtor Agent BIC NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
            END
            GOSUB finalise
        END
    END ELSE
        FIND "RECVER" IN iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
            IF iCreditPartyDets<PP.LocalClearingService.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
                GOSUB finalise
            END
        END ELSE
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction Debtor Agent BIC in crPartyRole NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>= "ACWINS/RECVER in crPartyRole NOT FOUND"
            END
            GOSUB finalise
        END
    END
RETURN
*------------------------------------------------------------------------------
getPorTransInfo:
* retrieve the payment details
    iPaymentID                          = ""
    iPaymentID<PaymentID.ftNumber>      = iTransDets<PP.LocalClearingService.TransDets.ftNumber>
    iPaymentID<PaymentID.companyID>     = iTransDets<PP.LocalClearingService.TransDets.companyID>
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    CALL PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr) ;* To read POR.TRANSACTION table
    IF oReadErr NE "" THEN
        oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>= "POR.TRANSACTION RECORD NOT FOUND"
        GOSUB finalise
    END
    
RETURN


*------------------------------------------------------------------------------
validateDebitPartyAccountLine:
    
    FIND "ORDPTY" IN iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyAccountLine,VMp> EQ "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction CreditPartyAccountLine NOT FOUND"
            END ELSE
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT FOUND"
            END
            GOSUB finalise
        END
*
        iPotentialIBAN = ""
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PP.LocalClearingService.TransDets.companyID>
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iPrtyDbtDets<PP.LocalClearingService.PartyDebitDets.debitPartyAccountLine,VMp>,"/","")
*
        oIBANDetail = ""
        oDetIBANResponse = ""
        PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
        IF oDetIBANResponse<PP.LocalClearingService.PaymentResponse.returnCode> NE "" THEN
            IF clearingTransactionType EQ 'RT' THEN
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "Original Transaction CreditPartyAccountLine NOT IBAN"
            END ELSE
* Added a tracer to check message code being returned from determine IBAN.
                oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT IBAN":'-':oDetIBANResponse<PP.CountryIBANStructureService.PaymentResponse.responseMessages,1,PP.CountryIBANStructureService.ResponseMessage.messageCode>:'-':iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber>
            END
            GOSUB finalise
        END
    END
*
RETURN


*------------------------------------------------------------------------------
finalise:
*
    oValidateResponse<PP.LocalClearingService.PaymentResponse.returnCode> = 'FAILURE'
    oValidateResponse<PP.LocalClearingService.PaymentResponse.serviceName> = 'LocalClearingService'
    oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode> = 'NIP00013'
    oValidateResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType> = 'NON_FATAL_ERROR'
*
    CALL TPSLogging("Output Parameter - END","PPINIP.validateFieldsForP27NIP","oValidChannelFlag : <":oValidChannelFlag:">, oValidateResponse : <":oValidateResponse:">","")
    GOSUB exit
*
RETURN
*------------------------------------------------------------------------------
exit:
RETURN TO exit
*------------------------------------------------------------------------------

END
