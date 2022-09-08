* @ValidationCode : MjoxNzY3ODIxMDY5OkNwMTI1MjoxNTk5NjM3ODM2NjE0OmpheWFzaHJlZXQ6MjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA3MDEtMDY1Nzo0MDE6Mjc0
* @ValidationInfo : Timestamp         : 09 Sep 2020 13:20:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 24
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 274/401 (68.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPEWSP.Foundation
SUBROUTINE PPEWSP.CHANNEL.VALIDATE.CT.API(iTransDets, iPrtyDbtDets, iCreditPartyDets, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
*------------------------------------------------------------------------------
* Private method
* The method validates the payments fields against PPEWSP.Foundation clearing requirements
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
* 01/09/2020 - Enhancement 3831744 / Task 3910362 - EWSEPA - API for validating the channel for CT Payments
*-----------------------------------------------------------------------------
*
    $INSERT I_CountryIBANStructureService_PotentialIBAN
    $USING PP.BankCodeService
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    $USING PP.CountryIBANStructureService
    $USING PP.DebitPartyDeterminationService

*------------------------------------------------------------------------------
*
    GOSUB initialise
    GOSUB process
*
RETURN
*------------------------------------------------------------------------------
initialise:
    oValidChannelFlag = ''
    oValidateResponse = ''
    iNCCContext=''
    clgTxnType = iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType>
    oValidChannelFlag<PPEWSP.Foundation.ValidChannelFlag.validChannelFlag> = "N"
RETURN
*------------------------------------------------------------------------------
process:
*
    GOSUB validateEndToEndReference
    GOSUB validateFTNumber
    GOSUB validateTransactionAmount
    GOSUB validateTransactionCurrencyCode
    IF iOriginatingSource EQ "OE" THEN
        GOSUB validateDebitPartyAccountLineForOE
    END ELSE
        IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> NE "" THEN
            GOSUB validateDebitPartyFreeLine1
            GOSUB validateDebitPartyAccountLine
            GOSUB validateDebitPartyIdentifierCode
        END
    END
    GOSUB validateCreditPartyIdentifierCode
    GOSUB validateCreditPartyFreeLine1
    GOSUB validateCreditPartyAccountLine
*   Address check to be performed for payments direction O/R.
    IF iTransDets<PPEWSP.Foundation.TransDets.pmtDirection> EQ 'O' OR iTransDets<PPEWSP.Foundation.TransDets.pmtDirection> EQ 'R' THEN
        GOSUB validateAddress
    END
    oValidChannelFlag<PPEWSP.Foundation.ValidChannelFlag.validChannelFlag> = "Y"
*
RETURN
*------------------------------------------------------------------------------
validateEndToEndReference:
RETURN
*------------------------------------------------------------------------------
validateFTNumber:
    IF iTransDets<PPEWSP.Foundation.TransDets.ftNumber> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "FTNumber NOT FOUND"
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
validateTransactionCurrencyCode:
    IF iTransDets<PPEWSP.Foundation.TransDets.transactionCurrencyCode> EQ "" THEN
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "TransactionCurrencyCode NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateDebitPartyFreeLine1:
    FMp = ''; VMp = '';Pos=''
    
    FIND "ORDPTY" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyFreeLine1,VMp> EQ "" AND iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyName,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "debitPartyFreeLine1 NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "ORDPTY in debitPartyRole NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateDebitPartyAccountLineForOE:
    IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine> NE "" THEN
        iPotentialIBAN = ""
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine>,"/","")
*
        oIBANDetail = ""
        oDetIBANResponse = ""
        PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
        IF oDetIBANResponse<PPEWSP.Foundation.PaymentResponse.returnCode> NE "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine is invalid IBAN"
            GOSUB finalise
        END
    END
RETURN
*------------------------------------------------------------------------------
validateDebitPartyAccountLine:
    FIND "ORDPTY" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT FOUND"
            GOSUB finalise
        END
*
        IF clgTxnType NE 'RT' THEN
            iPotentialIBAN = ""
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine,VMp>,"/","")
*
            oIBANDetail = ""
            oDetIBANResponse = ""
            PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
            IF oDetIBANResponse<PPEWSP.Foundation.PaymentResponse.returnCode> NE "" THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT IBAN"
                GOSUB finalise
            END
        END
    END
*
RETURN
*------------------------------------------------------------------------------
validateDebitPartyIdentifierCode:
    IF iTransDets<PPEWSP.Foundation.TransDets.pmtDirection> EQ 'R' THEN
        FIND "ORDINS" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
            IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
                GOSUB finalise
            END
        END ELSE
            FIND "SENDER" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
                IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
                    oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
                    GOSUB finalise
                END
            END ELSE
                IF iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
                    oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
                    GOSUB finalise
                END
            END
        END
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyIdentifierCode:
    FIND "ACWINS" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
*to determine BIC from NCC for PPEWSP.Foundation payments as PPEWSP.Foundation clearing accepts only BIC
            iNCCContext<PP.BankCodeService.NCCContext.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
            iNCCContext<PP.BankCodeService.NCCContext.nationalID> = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp>
            PP.BankCodeService.determineBICFromNCC(iNCCContext,oBICDetails,oBICFromNCCError)
            IF oBICFromNCCError NE '' THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
                GOSUB finalise
            END
        END
    END ELSE
        FIND "RECVER" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
            IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
*to determine BIC from NCC for PPEWSP.Foundation payments as PPEWSP.Foundation clearing accepts only BIC
                iNCCContext<PP.BankCodeService.NCCContext.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
                iNCCContext<PP.BankCodeService.NCCContext.nationalID> = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp>
                PP.BankCodeService.determineBICFromNCC(iNCCContext,oBICDetails,oBICFromNCCError)
                IF oBICFromNCCError NE '' THEN
                    oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
                    GOSUB finalise
                END
            END
        END ELSE
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo>= "ACWINS/RECVER in crPartyRole NOT FOUND"
            GOSUB finalise
        END
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyFreeLine1:
* Checking if the crPartyName is null along with partyfreeline for BENFCY
    FIND "BENFCY" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyFreeLine1,VMp> EQ "" AND iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyName,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyFreeLine1 NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "BENFCY in crPartyRole NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyAccountLine:
    FIND "BENFCY" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp> EQ "" THEN
            oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT FOUND"
            GOSUB finalise
        END
* No validation happens for an RT payment specially IBAN validation.
        IF clgTxnType NE 'RT' THEN
            iPotentialIBAN = ""
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPEWSP.Foundation.TransDets.companyID>
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp>,"/","")
            oIBANDetail = ""
            oDetIBANResponse = ""
*
            PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
*
            IF oDetIBANResponse<PPEWSP.Foundation.PaymentResponse.returnCode> NE "" THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT IBAN"
                GOSUB finalise
            END
        END
    END
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
*   Here we peform address validation which is similar to FATF validation.
    FMp = ''
    VMp = ''
    iPaymentDirection = ''
    iPaymentDirection = iTransDets<PPEWSP.Foundation.TransDets.pmtDirection>
    debtorAddress = ''
    customerAddress = ''
    GOSUB getCompanyProperties
    GOSUB getAccInfoDetails

*   Below condition is added for CT transactions
    IF (iTransDets<PPEWSP.Foundation.TransDets.clearingTransactionType> EQ 'CT') THEN
        IF iPaymentDirection EQ 'O' THEN
            debtorAddress = customerAddress
        END ELSE
*           Below mapping is for redirect payments.
            FIND "ORDPTY" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
                debtorAddress = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAddressLine1,VMp>
            END
        END
    
        IF debtorAddress EQ '' THEN
            GOSUB FindFATFOriginatingBankCountry
            IF (origninatingCG EQ '') OR (origninatingCG NE 'EU' AND origninatingCG NE 'EEA') THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "Originating Bank not in EU/EEA region"
                GOSUB finalise
            END
            GOSUB FindFATFBeneficiaryBankCountry
            IF (BeneficiaryCG EQ '') OR (BeneficiaryCG NE 'EU' AND BeneficiaryCG NE 'EEA') THEN
                oValidateResponse<PPEWSP.Foundation.PaymentResponse.responseMessages,1,PPEWSP.Foundation.ResponseMessage.messageInfo> = "Beneficiary Bank not in EU/EEA region"
                GOSUB finalise
            END
        END
    END
        
RETURN
*--------------------------------------------------------------------------------
getAccInfoDetails:
*   To get payment record details
    iTransAccDetails = ''
    oAccInfoDetails = ''
    oGetAccError = ''
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.mainOrChargeAccType> = 'D'
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.ftNumber> = iTransDets<PPEWSP.Foundation.TransDets.ftNumber>
    
    PP.DebitPartyDeterminationService.getAccInfoDetails(iTransAccDetails, oAccInfoDetails, oGetAccError)
    customerAddress = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.customerAddress>
    
RETURN
*--------------------------------------------------------------------------------
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
FindFATFOriginatingBankCountry:
*   when the FATF flag is E then check for the origination Bank country to be in EU EEA region.
*   This block is to determine origination Country Group for Redirect and outgoing payments.
    BankBIC = ''
    BankNCC = ''
    origninatingCG = ''
    ordInsPos = ''
    ordPtyPos = ''
    senderPos = ''
    ibanAcctNo=''
    FMp = ''
    ordInsPos = ''
*   For outgoing payment the companny Bic is itself the origination country
    IF iPaymentDirection EQ 'O' THEN
        BankBIC = iCompanyBIC
        GOSUB determineCountryGroup
        origninatingCG = ReturnedCG
    END ELSE
        FIND "ORDINS" IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordInsPos THEN
            BankBIC = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,ordInsPos>
            IF BankBIC NE '' THEN
                GOSUB determineCountryGroup
                origninatingCG = ReturnedCG
            END ELSE
                ordInsPos = ''
            END
        END ELSE
            FIND 'SENDER' IN iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordInsPos THEN
                BankBIC = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyIdentifierCode,ordInsPos>
                IF BankBIC NE '' THEN
                    GOSUB determineCountryGroup
                    origninatingCG = ReturnedCG
                END ELSE
                    ordInsPos = ''
                END
            END ELSE
                ordInsPos = ''
            END
        END
        IF ordInsPos EQ '' THEN
            FIND 'ORDPTY' IN  iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordInsPos THEN
                ibanAcctNo = iPrtyDbtDets<PPEWSP.Foundation.PartyDebitDets.debitPartyAccountLine,ordInsPos>
                GOSUB findBICNCCfromIBAN
                origninatingCG = ReturnedCG
            END ELSE
                origninatingCG = ''
            END
        END
    END
    
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
FindFATFBeneficiaryBankCountry:
    
    FIND "ACWINS" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'G' THEN
            iACWINSBicG = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
            GOSUB AssignBICAndNCC
            BeneficiaryCG = ReturnedCG
        END ELSE
            IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'R' THEN
                iACWINSBicG = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
            END
            ReturnedCG ='E'
        END
    END
    
    IF ReturnedCG EQ 'E' THEN
        IF iACWINSBicG NE '' THEN
            GOSUB AssignBICAndNCC
            RETURN
        END
        FIND "RECVER" IN iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
            IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'G' THEN
                iRecvrG = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
                IF iRecvrG NE '' THEN
                    GOSUB AssignBICAndNCC
                    BeneficiaryCG = ReturnedCG
                END
            END
        END ELSE
            IF iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'D' THEN
                iRecvrD = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
                IF iRecvrD NE '' THEN
                    GOSUB AssignBICAndNCC
                    BeneficiaryCG = ReturnedCG
                END
            END
        END
    END
    
RETURN
*------------------------------------------------------------------------------
AssignBICAndNCC:
*   This block is to assign BankBIC and BankNCC for creditParty
    BankBIC = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
    BankNCC = iCreditPartyDets<PPEWSP.Foundation.CreditPartyDets.crPartyAccountLine,VMp>
    GOSUB determineCountryGroup
    BeneficiaryCG = ReturnedCG
    
RETURN
*------------------------------------------------------------------------------
END
