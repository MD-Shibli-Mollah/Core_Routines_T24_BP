* @ValidationCode : MjoxODQzMTkyMDkxOkNwMTI1MjoxNjAyNzUxMDUwOTM2OnVtYW1haGVzd2FyaS5tYjo5OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MTEwOjEwMQ==
* @ValidationInfo : Timestamp         : 15 Oct 2020 14:07:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 101/110 (91.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPISIP.Foundation
SUBROUTINE PPISIP.VALIDATE.CHANNEL(iChannelDetails, iRSCreditDets, oSAINSTResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 27/09/2020 - Enhancement 3675355 / Task 3929661 - SAINST
*-----------------------------------------------------------------------------
    $USING PP.SwiftOutService
    $USING PP.PaymentWorkflowDASService
    $USING PP.CreditPartyDeterminationService
    $USING PP.LocalClearingService
    $USING PP.PaymentWorkflowGUI
    $USING EB.SystemTables
    
    
    CALL TPSLogging("In Parameter","PPISIP.VALIDATE.CHANNEL","iChannelDetails:":iChannelDetails,"")
    GOSUB initialise ; * Initialise the variables
    GOSUB process ; * perform the validations of SA INST
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
initialise:
*** <desc>Initialise the variables </desc>

    creditTansCompanyID = iChannelDetails<PP.SwiftOutService.ChannelDetails.companyID>
    creditTansFTNumber  = iChannelDetails<PP.SwiftOutService.ChannelDetails.ftNumber>
    outputChannel       = iChannelDetails<PP.SwiftOutService.ChannelDetails.outputChannel>
    listOfPurposeCodes = 'BONU':@VM:'DIVI':@VM:'OTHR':@VM:'SALA'
    listOfPropCodes = 'BEN':@VM:'CIT':@VM:'MOF':@VM:'WEL'
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Perform the validations of SAINST </desc>
    GOSUB getPaymentDets ; *Get POR Supplementary details
    GOSUB getPaymentRecord ; *get Payment Record
    GOSUB getPartyCreditDets ; *Get party Credit Details, for Benfcy Validation
    GOSUB validatePurposeProprietary ; *Check payment purpose or proprietary code is present and possible values
    GOSUB validateTransDetails ; *Validate charge options, Payment Currency, IBAN should be saudi IBAN
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= getPaymentDets>
getPaymentDets:
*** <desc>Get POR Supplementary details </desc>
    PP.PaymentWorkflowGUI.getSupplementaryInfo("POR.INFORMATION", creditTansFTNumber, ReadWithLock, PorInfoRecord, Error)
    CALL TPSLogging("test Parameter","PPISIP.validateMessage","PorInfoRecord:":PorInfoRecord,"")
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPaymentRecord>
getPaymentRecord:
*** <desc>get Payment Record </desc>

    iPaymentID                          = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber>      = creditTansFTNumber
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID>     = creditTansCompanyID
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
   
    paymentCcy = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    chargeOption = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.detailsOfCharges>
    paymentAmt = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>

    processingDate = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.processingDate>
    todayDate = EB.SystemTables.getToday()
  
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getPartyCreditDets>
getPartyCreditDets:
*** <desc>Get party Credit Details, for Benfcy Validation </desc>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID> = creditTansCompanyID
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber> = creditTansFTNumber
**/
    oCreditPartyDet = ''; oGetPrtyCrdError = ''
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetPrtyCrdError)
    crPrtyRoles = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>
    crRolePos = 0
    
    LOOP
        REMOVE crPrtyRole FROM crPrtyRoles SETTING RolePos
    WHILE crPrtyRole:RolePos
        crRolePos = crRolePos + 1
        IF crPrtyRole EQ 'BENFCY' THEN
            BENFCYiban = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine ,crRolePos>
            IF  BENFCYiban[1,2] NE 'SA' THEN
                messageText = 'Beneficiary IBAN should be Saudi IBAN'
                GOSUB updateResponse ; *
            END
        END
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= validatePurposeProprietary>
validatePurposeProprietary:
*** <desc>Check payment purpose or proprietary code is present and possible values </desc>

    iInfoCodes = PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationcode>


    infoCodeCount = 0
    purposeFlag = 0
    proprietaryFlag = 0
    LOOP
        REMOVE iInfoCode FROM iInfoCodes SETTING infoPos
    WHILE iInfoCode:infoPos
        infoCodeCount = infoCodeCount + 1
        IF iInfoCode EQ 'INSSDR' AND PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,infoCodeCount> EQ 'TXPURPCD' THEN
            purposeCode = PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationline,infoCodeCount>
            IF purposeCode MATCHES listOfPurposeCodes THEN
                purposeFlag = 1
            END ELSE
                messageText = 'Invalid Payment Purpose Code'
                GOSUB updateResponse ; *
            END
        END
    
        IF iInfoCode EQ 'INSSDR' AND PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,infoCodeCount> EQ 'TXPURPPY' THEN
            propCode = PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationline,infoCodeCount>
            IF propCode MATCHES listOfPropCodes THEN
                proprietaryFlag = 1
            END ELSE
                messageText = 'Invalid Purpose Proprietary Code'
                GOSUB updateResponse ; *
            END
        END
    REPEAT
    IF (purposeFlag AND proprietaryFlag) OR (purposeFlag EQ 0 AND proprietaryFlag EQ 0) THEN
        messageText = 'Either Payment purpose or Purpose Proprietary Code is Mandatory'
        GOSUB updateResponse ; *
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= validateTransDetails>
validateTransDetails:
*** <desc>Validate charge options, Payment Currency, IBAN should be saudi IBAN </desc>
   
    IF processingDate LT todayDate THEN
        messageText = 'Prcoessing date is back dated'
        GOSUB updateResponse ; *
    END


    IF paymentAmt LE 0 THEN
        messageText = 'Transaction Amount is less than or equal to zero'
        GOSUB updateResponse ; *
    END

    IF chargeOption NE 'SHA' THEN
        messageText = 'Charge Bearer/Details of Charge should be SHA'
        GOSUB updateResponse ; *
    END
    
    IF paymentCcy NE 'SAR' THEN
        messageText = 'Payment currency should be SAR'
        GOSUB updateResponse ; *
    END
  
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= updateResponse>
updateResponse:
*** <desc> </desc>
    
    oSAINSTResponse<PP.LocalClearingService.PaymentResponse.returnCode>                                    = 'FAILURE'
    oSAINSTResponse<PP.LocalClearingService.PaymentResponse.serviceName>                                   = 'PPISIP.Service'
    oSAINSTResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageText>    = messageText
    oSAINSTResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>    = iChannelDetails<PP.SwiftOutService.ChannelDetails.outputChannel>:' Reason: ':messageText
    oSAINSTResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'
    oSAINSTResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>    = 'SIP10001'
    CALL TPSLogging("Out Parameter","PPISIP.validateMessage","oSAINSTResponse:":oSAINSTResponse,"")
    GOSUB PRGEXIT
RETURN
*** </region>


*-----------------------------------------------------------------------------
PRGEXIT:
RETURN TO PRGEXIT

END





