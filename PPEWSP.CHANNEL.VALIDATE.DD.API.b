* @ValidationCode : MjotMTU3ODgxODYwMDpDcDEyNTI6MTU5OTU2MTI4NzI0MDpqYXlhc2hyZWV0OjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA3MDEtMDY1Nzo0Mjk6MjMx
* @ValidationInfo : Timestamp         : 08 Sep 2020 16:04:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 231/429 (53.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------
$PACKAGE PPEWSP.Foundation
SUBROUTINE PPEWSP.CHANNEL.VALIDATE.DD.API(iTransDets, iPrtyDbtDets, iCreditPartyDets, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
*------------------------------------------------------------------------------
* Private method
* The method validates the direct debit payments fields against EWSEPA clearing requirements
*
* @stereotype subroutine
* @package pp
*!
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
* Modification History :
*-----------------------------------------------------------------------------
* 01/09/2020 - Enhancement 3831744 / Task 3910362 - EWSEPA - API for validating the channel for DD Payments
*-----------------------------------------------------------------------------
    $USING PP.PaymentFrameworkService
    $USING PP.BankCodeService
    $USING PP.CountryIBANStructureService
*------------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process

RETURN
*------------------------------------------------------------------------------
initialise:
    oValidChannelFlag = '' ; oValidateResponse = '' ; oValidChannelFlag<PPEWSP.Foundation.ValidChannelFlag.validChannelFlag> = "N" ; validClrReturnCodes = '' ; pos = ''
*
RETURN
*-----------------------------------------------------------------------------
process:
*
    BEGIN CASE
        CASE iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> MATCHES 'RF':@VM:'RD'
            GOSUB returnRefundValidation
        CASE iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RV'                ;* Do reversal validation for ClearingTransactionType RV
            GOSUB reversalValidation
        CASE 1
            GOSUB ddiValidation
    END CASE
*
    oValidChannelFlag<PPEWSP.Foundation.ValidChannelFlag.validChannelFlag> = "Y"
*
RETURN
*-----------------------------------------------------------------------------
returnRefundValidation:
*
    GOSUB validateFTNumber
    GOSUB validateBulkSendersRef
    GOSUB validateCustomerSpecifiedRef
    GOSUB validateSendersRefIncoming
    GOSUB validateTransactionAmount
    GOSUB validateCurrencyEUR
    GOSUB validateClrReturnCode
    GOSUB validateClrNatureCode
    GOSUB validateCreditorID
    GOSUB validateMandateRef
    GOSUB validateDateOfSignature
    GOSUB validateInformationLine
    GOSUB validateCreditPartyDetails
    GOSUB validateDebitPartyDetails
*
RETURN
*------------------------------------------------------------------------------
reversalValidation:
*
    GOSUB validateFTNumber
    GOSUB validateBulkSendersRef
    GOSUB validateCustomerSpecifiedRef
    GOSUB validateTransactionAmount
    GOSUB validateCurrencyEUR
    GOSUB validateClrReturnCode
    GOSUB validateClrNatureCode
    GOSUB validateMandateRef
    GOSUB validateDateOfSignature
    GOSUB validateCreditPartyDetails
    GOSUB validateDebitPartyDetails
*
RETURN
*------------------------------------------------------------------------------
ddiValidation:
*
    GOSUB validateBankOptCode
    GOSUB validateClrNatureCode
    GOSUB validateTransactionAmount
    GOSUB validateCurrencyEUR
    GOSUB validateDetailsOfCharges
    GOSUB validateReqCollectionDate
    GOSUB validateMandateRef
    GOSUB validateDateOfSignature
    GOSUB validateCreditorID
    GOSUB validateCreditPartyDetailsDDI
    GOSUB validateDebitPartyDetails
    IF iTransDets<PPEWSP.Foundation.TransDets.pmtDirection> EQ 'O' OR iTransDets<PPEWSP.Foundation.TransDets.pmtDirection> EQ 'R' THEN
        GOSUB validateAddress
    END
*
RETURN
*------------------------------------------------------------------------------
validateFTNumber:
    IF iTransDets<PPEWSP.Foundation.TransDets.ftNumber> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "FTNumber NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateBulkSendersRef:
    IF iTransDets<PPEWSP.Foundation.TransDets.bulkSendersReference> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "BulkSendersReference NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateSendersRefIncoming:
    IF iTransDets<PPEWSP.Foundation.TransDets.sendersReferenceIncoming> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "SendersReferenceIncoming NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateCustomerSpecifiedRef:
    IF iTransDets<PPEWSP.Foundation.TransDets.customerSpecifiedReference> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CustomerSpecifiedReference NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateTransactionAmount:
    IF iTransDets<PPEWSP.Foundation.TransDets.transactionAmount> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "TransactionAmount NOT FOUND"
        GOSUB finalise
    END

* Transaction Amount must be 0.01 or more and 999999999.99 or les and the fractional part has a maximum of two digits.
    IF iTransDets<PPEWSP.Foundation.TransDets.transactionAmount> <= 0 THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "TransactionAmount OUT OF RANGE Value"
        GOSUB finalise
    END
    IF iTransDets<PPEWSP.Foundation.TransDets.transactionAmount> >= 1000000000 THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "TransactionAmount OUT OF RANGE Value"
        GOSUB finalise
    END

    Decimal = FIELD(iTransDets<PPEWSP.Foundation.TransDets.transactionAmount>, ".", 2)
    IF LEN(Decimal) > 2 THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "TransactionAmount TOO MANY DECIMALS Value"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateCurrencyEUR:
    IF iTransDets<PPEWSP.Foundation.TransDets.transactionCurrencyCode> NE "EUR" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "TransactionCurrencyCode NOT EUR"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateClrReturnCode:
    BEGIN CASE
        CASE iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RF'
            validClrReturnCodes = "AC01":@FM:"AC04":@FM:"AC06":@FM:"AC13":@FM:"AG01":@FM:"AG02":@FM:"AM04":@FM:"AM05":@FM:"MD01":@FM:"MD07":@FM:"MS02":@FM:"MS03":@FM:"RC01":@FM:"RR01":@FM:"RR02":@FM:"RR03":@FM:"RR04":@FM:"SL01":@FM:"BE05":@FM:"FF05"
            LOCATE iTransDets<PPEWSP.Foundation.TransDets.clearingReturnCode> IN validClrReturnCodes SETTING Pos ELSE
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ClearingReturnCode NOT VALID for RF"
                GOSUB finalise
            END
        CASE iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RD'
            IF iTransDets<PPEWSP.Foundation.TransDets.clearingReturnCode> NE "MD06" THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ClearingReturnCode NOT VALID for RD"
                GOSUB finalise
            END
        CASE iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RV'
            IF NOT (iTransDets<PPEWSP.Foundation.TransDets.clearingReturnCode> MATCHES 'AM05':@VM:'MS02':@VM:'MS03') THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ClearingReturnCode NOT VALID for RV"
                GOSUB finalise
            END
    END CASE
*
RETURN
*-----------------------------------------------------------------------------
validateClrNatureCode:
    IF iTransDets<PPEWSP.Foundation.TransDets.clearingNatureCode> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ClearingNatureCode NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateBankOptCode:
    IF iTransDets<PPEWSP.Foundation.TransDets.bankOperationCode> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "BankOperationCode NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateDetailsOfCharges:
    IF iTransDets<PPEWSP.Foundation.TransDets.detailsOfCharges> NE "SHA" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DetailsOfCharges NOT SHA"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateReqCollectionDate:
    IF iTransDets<PPEWSP.Foundation.TransDets.requestedCollectionDate> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "RequestedCollectionDate NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateCreditorID:
    IF iDebitAuthDets<PPEWSP.Foundation.DebitAuthDets.creditorID> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditorID NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateMandateRef:
    IF iDebitAuthDets<PPEWSP.Foundation.DebitAuthDets.mandateReference> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "MandateReference NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateDateOfSignature:
    IF iDebitAuthDets<PPEWSP.Foundation.DebitAuthDets.signatureDate> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "SignatureDate NOT FOUND"
        GOSUB finalise
    END
RETURN
*-----------------------------------------------------------------------------
validateInformationLine:
* validate the settlement date of the original transaction
    IF iInformationDets<PPEWSP.Foundation.InformationDets.informationLine,1> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "InformationLine representing the settlementDate NOT FOUND"
        GOSUB finalise
    END
* validate the requested collection date of the original transaction
    IF iInformationDets<PPEWSP.Foundation.InformationDets.informationLine,2> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "InformationLine representing the requestedCollectionDate NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyDetails:
*
* determine the credit parties that should be interrogated based on clearing transaction type
    IF iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RF' OR iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RD' THEN
        crParty1 = "ORDPTY"
        crParty2 = "ORDINS"
    END
    IF iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RV' THEN
        crParty1 = "BENFCY"
        crParty2 = "ACWINS"
    END
*
    FMp = "" ; VMp = ""
    FIND crParty1 IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyName,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyName NOT FOUND"
            GOSUB finalise
        END
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = dbParty1 : " in creditPartyRole NOT FOUND"
        GOSUB finalise
    END
*
    FMp = ""; VMp = ""
    FIND crParty2 IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = dbParty2 : " in creditPartyRole NOT FOUND"
        GOSUB finalise
    END
*
RETURN
*-----------------------------------------------------------------------------
validateCreditPartyDetailsDDI:
*

    FMp = "" ; VMp = ""
    FIND "ORDPTY" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyName,VMp> EQ "" AND iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine1,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyName and CreditPartyFreeLine1 NOT FOUND"
            GOSUB finalise
        END
        IF iOriginatingSource NE 'OE' THEN
    

*       check the CreditPartyAccountLine to be a valid IBAN
            IF iTransDets<PPEWSP.Foundation.TransDets.batchIndicator> EQ "C" THEN
                IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp> EQ "" THEN
                    oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT FOUND"
                    GOSUB finalise
                END
                iPotentialIBAN = "" ; oIBANDetail = "" ; oDetIBANResponse = ""
                iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
                iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp>,"/","")
                PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
                IF oDetIBANResponse<PPEWSP.Foundation.PaymentResponse.returnCode> NE "" THEN
                    oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine is invalid IBAN"
                    GOSUB finalise
                END
            END
        END
    END ELSE
  
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ORDPTY in creditPartyRole NOT FOUND"
        GOSUB finalise
    END
*
    FMp = "" ; VMp = ""
    IF iOriginatingSource NE 'OE' AND iTransDets<PPEWSP.Foundation.TransDets.pmtDirection> EQ 'R' THEN
        FIND "ORDINS" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
            IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
                GOSUB finalise
            END
        END ELSE
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ORDINS in creditPartyRole NOT FOUND"
            GOSUB finalise
        END
    END
*
RETURN
*-----------------------------------------------------------------------------
validateDebitPartyDetails:
* determine the debit parties that should be interrogated based on clearing transaction type
    IF iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> MATCHES 'RF':@VM:'RD':@VM:'DD' THEN
        dbParty1 = "DEBTOR"
        dbParty2 = "DBTAGT"
    END
    IF iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'RV' THEN
        dbParty1 = "ORDPTY"
        dbParty2 = "ORDINS"
    END
*
    FMp = "" ; VMp = ""
    FIND dbParty1 IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyName,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyName NOT FOUND"
            GOSUB finalise
        END
        IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT FOUND"
            GOSUB finalise
        END
        IF iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'DD' THEN
            iPotentialIBAN = "" ; oIBANDetail = "" ; oDetIBANResponse = ""
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine,VMp>,"/","")
            PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
            IF oDetIBANResponse<PPEWSP.Foundation.PaymentResponse.returnCode> NE "" THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine is invalid IBAN"
                GOSUB finalise
            END
        END
    END ELSE
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = dbParty1 : " in debitPartyRole NOT FOUND"
        GOSUB finalise
    END
*
    FMp = ""; VMp = ""
    FIND dbParty2 IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = dbParty2 : " in debitPartyRole NOT FOUND"
        GOSUB finalise
    END
*
RETURN
*------------------------------------------------------------------------------
finalise:
*
    GOSUB exit
*
RETURN
*------------------------------------------------------------------------------
exit:
RETURN TO exit
*------------------------------------------------------------------------------
validateAddress:
*   Below condition is added for DD transactions
*   Here we peform address validation which is similar to FATF validation.
    FMp = ''
    VMp = ''
    iPaymentDirection = ''
    iPaymentDirection = iTransDets<PPEWSP.Foundation.TransDets.pmtDirection>
    debtorAddress = ''
    GOSUB getCompanyProperties
    IF iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'DD' THEN
        FIND "DEBTOR" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
            debtorAddress = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAddressLine1,VMp>
        END
        IF debtorAddress EQ '' THEN
            GOSUB FindFATFCreditorBankCountryDD
            IF (CreditorCG EQ '') OR (CreditorCG NE 'EU' AND CreditorCG NE 'EEA') THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "Creditor Bank not in EU/EEA region"
                GOSUB finalise
            END
            GOSUB FindFATFDebtorBankCountryDD
            IF (debtorCG EQ '') OR (debtorCG NE 'EU' AND debtorCG NE 'EEA') THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "Debtor Bank not in EU/EEA region"
                GOSUB finalise
            END
        END
    END
    
RETURN
*-------------------------------------------------------------------------------
FindFATFCreditorBankCountryDD:
    BankBIC = ''
    CreditorCG = ''
    BankBIC = iCompanyBIC
    GOSUB determineCountryGroup
    CreditorCG = ReturnedCG
    
RETURN
*------------------------------------------------------------------------------
FindFATFDebtorBankCountryDD:
    BankBIC = ''
    ordDbtAgtPos = ''
    debtorCG = ''
    ibanAcctNo = ''
    FIND "DBTAGT" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordDbtAgtPos THEN
        BankBIC = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,ordDbtAgtPos>
        IF BankBIC NE '' THEN
            GOSUB determineCountryGroup
            debtorCG = ReturnedCG
        END ELSE
            ordDbtAgtPos =''
        END
    END ELSE
        ordDbtAgtPos = ''
    END
    IF ordDbtAgtPos EQ '' THEN
        FIND 'DEBTOR' IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordDbtAgtPos THEN
            ibanAcctNo = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,ordDbtAgtPos>
            GOSUB findBICNCCfromIBAN
            debtorCG = ReturnedCG
        END ELSE
            debtorCG = ''
        END
    END
    
RETURN
*------------------------------------------------------------------------------
getCompanyProperties:
*   Determine Company Properties
    iCompanyBIC = ''
    iCompanyPropKey = ''
    oCompanyProperties = ''
    oGetCompPropsError = ''
    iCompanyPropKey = iTransDets<PPEWSP.Foundation.TransDets.companyID>
    PP.PaymentFrameworkService.getCompanyProperties(iCompanyPropKey, oCompanyProperties, oGetCompPropsError)
    iCompanyBIC =  oCompanyProperties<PP.PaymentFrameworkService.CompanyProperties.companyBIC>
    
RETURN
*------------------------------------------------------------------------------
determineCountryGroup:
*   This block is to determine the Country Group
*   Initialise ReturnedCG is 'N'
    ReturnedCG = 'N'
    iCountryCode = ''
    oCountryGroupList = ''
    oGetCountryGrpError = ''
    BEGIN CASE
*       If BankBIC
        CASE BankBIC NE ''
            GOSUB determineCtyFromBIC
*       If BankNCC
        CASE BankNCC[1,2] EQ '//'
            GOSUB determineCtyFromNCC
    END CASE
*   To find the Country Group
    IF iCountryCode NE '' THEN
        oCountryGroupList = ''
        oGetCountryGrpError = ''
        PP.PaymentFrameworkService.getCountryGroupList(iCountryCode, oCountryGroupList, oGetCountryGrpError)
        IF oGetCountryGrpError EQ '' THEN
            CONVERT @VM TO @FM IN oCountryGroupList
            LOCATE 'EEA' IN oCountryGroupList SETTING EeaPos THEN
                ReturnedCG = oCountryGroupList<EeaPos>
                BankBIC=''
                BankNCC=''
                RETURN
            END
            LOCATE "EU" IN oCountryGroupList SETTING EuPos THEN ;*Check if the returned list of CountryGroup contains EEA/EU in it
                ReturnedCG = oCountryGroupList<EuPos>
                BankBIC=''
                BankNCC=''
                RETURN
            END ELSE
                LOC.POS = ''
            END
        END
    END
    BankBIC=''
    BankNCC=''
    
RETURN
*------------------------------------------------------------------------------
determineCtyFromBIC:
*   This block is to determine the countryCode based on the provided BIC
    iCountryCode = ''
    iCountryCode = BankBIC[5,2]
    
RETURN
*------------------------------------------------------------------------------
determineCtyFromNCC:
*   This block is to determine the countryCode based on the provided NCC
    nationalIdLength = LEN(BankNCC)-2
    iCountryCode = ''
    iNCCContext<PP.BankCodeService.NCCContext.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
    iNCCContext<PP.BankCodeService.NCCContext.nationalID> = BankNCC[3,nationalIdLength]
    oBICDetails = ""
    oBICFromNCCError = ""
    PP.BankCodeService.determineBICFromNCC(iNCCContext, oBICDetails, oBICFromNCCError)
    IF oBICFromNCCError EQ '' THEN
        iCountryCode = oBICDetails<PP.BankCodeService.BICDetail.countryCode>
    END
    
RETURN
*------------------------------------------------------------------------------
findBICNCCfromIBAN:
*   Determine IBAN details from PPT.COUNTRYIBANTABLE
    oIBANDetail = ''
    oDetIBANResponse = ''
    iPotentialIBAN =''
    ReturnedCG=''
    actibanAcctNo=''
    lenOfAcctNo=''
    acctLinePosValue=''

    lenOfAcctNo = LEN(ibanAcctNo)
    acctLinePosValue = ibanAcctNo[1,1]
    IF  acctLinePosValue EQ '/' THEN
        actibanAcctNo =  ibanAcctNo[2,lenOfAcctNo-1]
    END ELSE
        actibanAcctNo =  ibanAcctNo
    END

    iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
    iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = actibanAcctNo
    PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)

*   If the account number is Not an IBAN, return to the calling Method
    IF oDetIBANResponse NE '' THEN
        ReturnedCG = 'E'
        RETURN
    END

    iIBANContext=''
    oBICNCCDetails=''
    oBICNCCError=''
    iIBANContext<PP.BankCodeService.IBANContext.companyID> =  iTransDets<PPEWSP.Foundation.TransDets.companyID>
    iIBANContext<PP.BankCodeService.IBANContext.ibanCountryCode> = oIBANDetail<PP.CountryIBANStructureService.IBANDetail.ibanCountryCode>
    iIBANContext<PP.BankCodeService.IBANContext.ibanNationalID> =  oIBANDetail<PP.CountryIBANStructureService.IBANDetail.ibanNationalID>

    PP.BankCodeService.determineBICNCCFromIBAN(iIBANContext,oBICNCCDetails,oBICNCCError)

    IF oBICNCCError NE '' THEN
        ReturnedCG = 'E'
    END ELSE
        BankBIC = oBICNCCDetails<PP.BankCodeService.BICNCCDetail.bicCode>
        BankNCC = oBICNCCDetails<PP.BankCodeService.BICNCCDetail.nationalID>
        GOSUB determineCountryGroup
    END
    
RETURN
*------------------------------------------------------------------------------
END

