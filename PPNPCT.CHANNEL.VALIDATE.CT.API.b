* @ValidationCode : Mjo3NDE2MzA4OkNwMTI1MjoxNjAzNDUwMDAxMzM0OmpheWFzaHJlZXQ6MjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA3MDEtMDY1NzozODk6Mjcz
* @ValidationInfo : Timestamp         : 23 Oct 2020 16:16:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 24
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 273/389 (70.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPNPCT.Foundation
SUBROUTINE PPNPCT.CHANNEL.VALIDATE.CT.API(iTransDets, iPrtyDbtDets, iCreditPartyDets, iOriginatingSource, iDebitAuthDets, iInformationDets, oValidChannelFlag, oValidateResponse)
*------------------------------------------------------------------------------
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
*enhancement/task/functionality covered*add here
*23/10/2020 - Enhancement 3852940/Task 4017144 - NORDIC - API for validating the channel for CT Payments
*-----------------------------------------------------------------------------
*
    $INSERT I_CountryIBANStructureService_PotentialIBAN
    $USING PP.BankCodeService
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    $USING PP.CountryIBANStructureService
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $USING PP.LocalClearingService

*------------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process
    
RETURN
*------------------------------------------------------------------------------
initialise:
    oValidChannelFlag = ''
    oValidateResponse = ''
    iNCCContext=''
    clgTxnType = iTransDets<PPNPCT.Foundation.TransDets.clearingTransactionType>
    oValidChannelFlag<PPNPCT.Foundation.ValidChannelFlag.validChannelFlag> = "N"
    
RETURN
*------------------------------------------------------------------------------
process:
*
    
    GOSUB validateFTNumber
    GOSUB validateTransactionAmount
    GOSUB validateTransactionCurrencyCode
    IF iOriginatingSource EQ "OE" THEN
        GOSUB validateDebitPartyAccountLineForOE
    END ELSE
        IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> NE "" THEN
            GOSUB validateDebitPartyFreeLine1
            GOSUB validateDebitPartyAccountLine
            GOSUB validateDebitPartyIdentifierCode
        END
    END
    GOSUB validateCreditPartyIdentifierCode
    GOSUB validateCreditPartyFreeLine1
    GOSUB validateCreditPartyAccountLine
*   Address check to be performed for payments direction O/R.
  
    IF iTransDets<PPNPCT.Foundation.TransDets.pmtDirection> EQ 'O' OR iTransDets<PPNPCT.Foundation.TransDets.pmtDirection> EQ 'R' THEN
        GOSUB validateAddress
    END
    oValidChannelFlag<PPNPCT.Foundation.ValidChannelFlag.validChannelFlag> = "Y"
*
RETURN
*------------------------------------------------------------------------------
validateFTNumber:
    IF iTransDets<PPNPCT.Foundation.TransDets.ftNumber> EQ "" THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "FTNumber NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateTransactionAmount:
    IF iTransDets<PPNPCT.Foundation.TransDets.transactionAmount> EQ "" THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "TransactionAmount NOT FOUND"
        GOSUB finalise
    END

* Transaction Amount must be 0.01 or more and 999999999.99 or les and the fractional part has a maximum of two digits.
    IF iTransDets<PPNPCT.Foundation.TransDets.transactionAmount> <= 0 THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "TransactionAmount OUT OF RANGE Value"
        GOSUB finalise
    END
    IF iTransDets<PPNPCT.Foundation.TransDets.transactionAmount> >= 1000000000 THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "TransactionAmount OUT OF RANGE Value"
        GOSUB finalise
    END

    Decimal = FIELD(iTransDets<PPNPCT.Foundation.TransDets.transactionAmount>, ".", 2)
    IF LEN(Decimal) > 2 THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "TransactionAmount TOO MANY DECIMALS Value"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateTransactionCurrencyCode:
    IF iTransDets<PPNPCT.Foundation.TransDets.transactionCurrencyCode> EQ "" THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "TransactionCurrencyCode NOT FOUND"
        GOSUB finalise
    END
        
    IF NOT(iTransDets<PPNPCT.Foundation.TransDets.transactionCurrencyCode> MATCHES 'SEK':@VM:'DKK') THEN
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "TransactionCurrencyCode NOT FOUND"
        GOSUB finalise
    END
    
RETURN
*------------------------------------------------------------------------------
validateDebitPartyFreeLine1:
    FMp = ''; VMp = '';Pos=''
    
    FIND "ORDPTY" IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyFreeLine1,VMp> EQ "" AND iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyName,VMp> EQ "" THEN
            oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "debitPartyFreeLine1 NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "ORDPTY in debitPartyRole NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateDebitPartyAccountLineForOE:
    IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyAccountLine> NE "" THEN
        iPotentialIBAN = ""
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPNPCT.Foundation.TransDets.companyID>
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyAccountLine>,"/","")
*
        oIBANDetail = ""
        oDetIBANResponse = ""
        PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
        IF oDetIBANResponse<PP.DebitPartyDeterminationService.PaymentResponse.returnCode> NE "" THEN
            oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine is invalid IBAN"
            GOSUB finalise
        END
    END
RETURN
*------------------------------------------------------------------------------
validateDebitPartyAccountLine:
      
    FIND "ORDPTY" IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
        IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyAccountLine,VMp> EQ "" THEN
            oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT FOUND"
            GOSUB finalise
        END
*
        IF clgTxnType NE 'RT' THEN
            iPotentialIBAN = ""
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPNPCT.Foundation.TransDets.companyID>
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyAccountLine,VMp>,"/","")
*
            oIBANDetail = ""
            oDetIBANResponse = ""
            PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
            IF oDetIBANResponse<PP.DebitPartyDeterminationService.PaymentResponse.returnCode> NE "" THEN
                oDetIBANResponse = ""
                iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iTransDets<PPNPCT.Foundation.TransDets.relatedIBAN>,"/","")
                PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
                IF oDetIBANResponse<PP.DebitPartyDeterminationService.PaymentResponse.returnCode> NE "" THEN
                    oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "DebitPartyAccountLine NOT IBAN"
                    GOSUB finalise
                END
            END
        END
    END
*
RETURN
*------------------------------------------------------------------------------
validateDebitPartyIdentifierCode:
    IF iTransDets<PPNPCT.Foundation.TransDets.pmtDirection> EQ 'R' THEN
        FIND "ORDINS" IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
            IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
                oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
                GOSUB finalise
            END
        END ELSE
            FIND "SENDER" IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
                IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
                    oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
                    GOSUB finalise
                END
            END ELSE
                IF iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyIdentifierCode,VMp> EQ "" THEN
                    oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "DebitPartyIdentifierCode NOT FOUND"
                    GOSUB finalise
                END
            END
        END
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyIdentifierCode:
    FIND "ACWINS" IN iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
*to determine BIC from NCC for step2 payments as STEP2 clearing accepts only BIC
            iNCCContext<PP.BankCodeService.NCCContext.companyID> = iTransDets<PPNPCT.Foundation.TransDets.companyID>
            iNCCContext<PP.BankCodeService.NCCContext.nationalID> = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,VMp>
            PP.BankCodeService.determineBICFromNCC(iNCCContext,oBICDetails,oBICFromNCCError)
            IF oBICFromNCCError NE '' THEN
                oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
                GOSUB finalise
            END
        END
    END ELSE
        FIND "RECVER" IN iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
            IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp> EQ "" THEN
*to determine BIC from NCC for step2 payments as STEP2 clearing accepts only BIC
                iNCCContext<PP.BankCodeService.NCCContext.companyID> = iTransDets<PPNPCT.Foundation.TransDets.companyID>
                iNCCContext<PP.BankCodeService.NCCContext.nationalID> = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,VMp>
                PP.BankCodeService.determineBICFromNCC(iNCCContext,oBICDetails,oBICFromNCCError)
                IF oBICFromNCCError NE '' THEN
                    oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "CreditPartyIdentifierCode NOT FOUND"
                    GOSUB finalise
                END
            END
        END ELSE
            oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo>= "ACWINS/RECVER in crPartyRole NOT FOUND"
            GOSUB finalise
        END
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyFreeLine1:
* Checking if the crPartyName is null along with partyfreeline for BENFCY
    FIND "BENFCY" IN iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyFreeLine1,VMp> EQ "" AND iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyName,VMp> EQ "" THEN
            oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "CreditPartyFreeLine1 NOT FOUND"
            GOSUB finalise
        END
    END ELSE
        oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "BENFCY in crPartyRole NOT FOUND"
        GOSUB finalise
    END
RETURN
*------------------------------------------------------------------------------
validateCreditPartyAccountLine:
    FIND "BENFCY" IN iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,VMp> EQ "" THEN
            oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT FOUND"
            GOSUB finalise
        END
* No validation happens for an RT payment specially IBAN validation.
        IF clgTxnType NE 'RT' THEN
            iPotentialIBAN = ""
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPNPCT.Foundation.TransDets.companyID>
            iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = EREPLACE(iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,VMp>,"/","")
            oIBANDetail = ""
            oDetIBANResponse = ""
*
            PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
*
            IF oDetIBANResponse<PPNPCT.Foundation.PaymentResponse.returnCode> NE "" THEN
                oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "CreditPartyAccountLine NOT IBAN"
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
    iPaymentDirection = iTransDets<PPNPCT.Foundation.TransDets.pmtDirection>
    debtorAddress = ''
    customerAddress = ''
    GOSUB getCompanyProperties
    GOSUB getAccInfoDetails

*   Below condition is added for CT transactions
    IF (iTransDets<PPNPCT.Foundation.TransDets.clearingTransactionType> EQ 'CT') THEN
        IF iPaymentDirection EQ 'O' THEN
            debtorAddress = customerAddress
        END ELSE
*           Below mapping is for redirect payments.
            FIND "ORDPTY" IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,VMp THEN
                debtorAddress = iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyAddressLine1,VMp>
            END
        END

        IF debtorAddress EQ '' THEN
            GOSUB FindFATFOriginatingBankCountry
            IF (origninatingCG EQ '') OR (origninatingCG NE 'EU' AND origninatingCG NE 'EEA') THEN
                oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "Originating Bank not in EU/EEA region"
                GOSUB finalise
            END
            GOSUB FindFATFBeneficiaryBankCountry
            IF (BeneficiaryCG EQ '') OR (BeneficiaryCG NE 'EU' AND BeneficiaryCG NE 'EEA') THEN
                oValidateResponse<PPNPCT.Foundation.PaymentResponse.responseMessages,1,PPNPCT.Foundation.ResponseMessage.messageInfo> = "Beneficiary Bank not in EU/EEA region"
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
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.ftNumber> = iTransDets<PPNPCT.Foundation.TransDets.ftNumber>
    
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
    iCompanyPropKey = iTransDets<PPNPCT.Foundation.TransDets.companyID>
    PP.PaymentFrameworkService.getCompanyProperties(iCompanyPropKey, oCompanyProperties, oGetCompPropsError)
    iCompanyBIC =  oCompanyProperties<PP.PaymentFrameworkService.CompanyProperties.companyBIC>
    
RETURN
*------------------------------------------------------------------------------
FindFATFOriginatingBankCountry:
*   when the FATF flag is E then check for the origination Bank country to be in EU EEA region.
*   This block is to determine origination Country Group for Redirect and outgoing payments.
    BankBIC = ''
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
        FIND "ORDINS" IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordInsPos THEN
            BankBIC = iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyIdentifierCode,ordInsPos>
            IF BankBIC NE '' THEN
                GOSUB determineCountryGroup
                origninatingCG = ReturnedCG
            END ELSE
                ordInsPos = ''
            END
        END ELSE
            FIND 'SENDER' IN iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordInsPos THEN
                BankBIC = iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyIdentifierCode,ordInsPos>
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
            FIND 'ORDPTY' IN  iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyRole> SETTING FMp,ordInsPos THEN
                ibanAcctNo = iPrtyDbtDets<PPNPCT.Foundation.PartyDebitDets.debitPartyAccountLine,ordInsPos>
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
*   If BankBIC
    IF BankBIC NE '' THEN
        GOSUB determineCtyFromBIC
    END
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
                RETURN
            END
            LOCATE "EU" IN oCountryGroupList SETTING EuPos THEN ;*Check if the returned list of CountryGroup contains EEA/EU in it
                ReturnedCG = oCountryGroupList<EuPos>
                BankBIC=''
                RETURN
            END ELSE
                LOC.POS = ''
            END
        END
    END
    BankBIC=''
    
RETURN
*------------------------------------------------------------------------------
determineCtyFromBIC:
*   This block is to determine the countryCode based on the provided BIC
    iCountryCode = ''
    iCountryCode = BankBIC[5,2]
    
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

    iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = iTransDets<PPNPCT.Foundation.TransDets.companyID>
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
    iIBANContext<PP.BankCodeService.IBANContext.companyID> =  iTransDets<PPNPCT.Foundation.TransDets.companyID>
    iIBANContext<PP.BankCodeService.IBANContext.ibanCountryCode> = oIBANDetail<PP.CountryIBANStructureService.IBANDetail.ibanCountryCode>
    iIBANContext<PP.BankCodeService.IBANContext.ibanNationalID> =  oIBANDetail<PP.CountryIBANStructureService.IBANDetail.ibanNationalID>

    PP.BankCodeService.determineBICNCCFromIBAN(iIBANContext,oBICNCCDetails,oBICNCCError)

    IF oBICNCCError NE '' THEN
        ReturnedCG = 'E'
    END ELSE
        BankBIC = oBICNCCDetails<PP.BankCodeService.BICNCCDetail.bicCode>
        GOSUB determineCountryGroup
    END
    
RETURN
*------------------------------------------------------------------------------
FindFATFBeneficiaryBankCountry:
    
    FIND "ACWINS" IN iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
        IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'G' THEN
            iACWINSBicG = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
            GOSUB AssignBICAndNCC
            BeneficiaryCG = ReturnedCG
        END ELSE
            IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'R' THEN
                iACWINSBicG = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
            END
            ReturnedCG ='E'
        END
    END
    
    IF ReturnedCG EQ 'E' THEN
        IF iACWINSBicG NE '' THEN
            GOSUB AssignBICAndNCC
            RETURN
        END
        FIND "RECVER" IN iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRole> SETTING FMp,VMp THEN
            IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'G' THEN
                iRecvrG = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
                IF iRecvrG NE '' THEN
                    GOSUB AssignBICAndNCC
                    BeneficiaryCG = ReturnedCG
                END
            END
        END ELSE
            IF iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyRoleIndic,VMp> EQ 'D' THEN
                iRecvrD = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
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
*   This block is to assign BankBIC for creditParty
    BankBIC = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyIdentifCode,VMp>
    BankNCC = iCreditPartyDets<PPNPCT.Foundation.CreditPartyDets.crPartyAccountLine,VMp>
    GOSUB determineCountryGroup
    BeneficiaryCG = ReturnedCG
    
RETURN
*------------------------------------------------------------------------------
END
