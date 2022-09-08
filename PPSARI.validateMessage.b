* @ValidationCode : MjotMTg2NjAwNTIxOTpDcDEyNTI6MTYxODkxNTQwMzY3ODpqYXlhc2hyZWV0OjEwOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTA0LjI6MTQwOjEwNg==
* @ValidationInfo : Timestamp         : 20 Apr 2021 16:13:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 106/140 (75.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202104.2
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE PPSARI.Foundation
 
SUBROUTINE PPSARI.validateMessage(iChannelDetails, iRSCreditDets, oSARIEResponse)
*-----------------------------------------------------------------------------
* This routine is channel validation routine for SARIE RTGS clearing. This API is attached in PP.CLEARING.SETTING>SARIE.SAR.S.103.CT record in validateapi field.
* Channel Validations:
* 1. Suppose payment initated from payment order then ordering party account number should be present.
* 2. Payment currency should be in SAR
* 3. Payment's charge type should be 'SHA'
* 4. Validate message against MT103 swift validation
* 5. When payment purpose is 'PAY' OR '/DIV/' then remittance information should start with /PAYROLL/ or /DIVIDEND/ respectively
* 6. When payment purpose is not 'PAY' neither '/DIV/' then remittance information should not start with /PAYROLL/ or /DIVIDEND/
* 7. Payment purpose code maximum length is three characters
* 8. Instruction codes - PHOB and TELB are mutaully exclusive
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*20/04/2021 - Task 4347179 - Regression fix for ORDPTY role changes
*-----------------------------------------------------------------------------
    $USING PP.SwiftOutService
    $USING PP.PaymentWorkflowDASService
    $USING PP.DebitPartyDeterminationService
    $USING PP.LocalClearingService
    $USING PP.PaymentWorkflowGUI
    
    CALL TPSLogging("In Parameter","PPSARI.validateMessage","iChannelDetails:":iChannelDetails,"")
    GOSUB initialise ; * Initialise the variables
    GOSUB process ; * perform the validations of SARIE RTGS
    CALL TPSLogging("Out Parameter","PPSARI.validateMessage","oSARIEResponse:":oSARIEResponse,"")

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initilise all the variables </desc>
    
    oSARIEResponse = ''
    errorPos = 0
    creditTansCompanyID = iChannelDetails<PP.SwiftOutService.ChannelDetails.companyID>
    creditTansFTNumber  = iChannelDetails<PP.SwiftOutService.ChannelDetails.ftNumber>
    outputChannel       = iChannelDetails<PP.SwiftOutService.ChannelDetails.outputChannel>
    outgoingMessageType = iChannelDetails<PP.SwiftOutService.ChannelDetails.outgoingMessageType>
    sourceProduct = ''
RETURN

*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc>Perform the validations for SARIE RTGS</desc>
    GOSUB getPaymentInfo ; * get payment record details
    GOSUB getPaymentDets ; *
    GOSUB validateTag50 ; * Tag 50 validation
    GOSUB validateTag71A ; * Tag 71A validation
    GOSUB validateSwiftMT103 ; * Trigger swift validation
    GOSUB validateInstCode ; *Instruction code should contain either PHOB or TELB, not both.
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= updateResponse>
updateResponse:
*** <desc> </desc>
    
    oSARIEResponse<PP.LocalClearingService.PaymentResponse.returnCode>                                    = 'FAILURE'
    oSARIEResponse<PP.LocalClearingService.PaymentResponse.serviceName>                                   = 'PPSARI.Service'
    oSARIEResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageText>    = messageText
    oSARIEResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo>    = iChannelDetails<PP.SwiftOutService.ChannelDetails.outputChannel>:' Reason: ':messageText
    oSARIEResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'
    oSARIEResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageCode>    = 'SAR10001'
    messageText = ''
    GOSUB PRGEXIT
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= validateTag50>'
validateTag50:
*** <desc> </desc>
    
    IF sourceProduct EQ 'POA' THEN
        IF orderingAcDbtPrty EQ '' THEN
            messageText = 'Account number should be present if source is Payment Order'
            GOSUB updateResponse ; *
        END
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= validateTag50>
validateTag71A:
*** <desc>
* Payment currency should be in SAR
* Payment's charge type should be 'SHA'
*** </desc>
    
    IF tag71AChgbrr NE 'SHA' THEN
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
*** <region name= validateTag50>
validateSwiftMT103:
*** <desc>Call SwiftOut vlidateOutputChannel API to perform swift validations
* Validate message against MT103 swift validation
*** </desc>

    storeIncomingMsgType = iChannelDetails<PP.SwiftOutService.ChannelDetails.incomingMessageType>
    iChannelDetails<PP.SwiftOutService.ChannelDetails.incomingMessageType> = '103'
    oSwiftResponse = ''
    PP.SwiftOutService.validateOutputChannel(iChannelDetails, iRSCreditDets, oSwiftResponse)
    iChannelDetails<PP.SwiftOutService.ChannelDetails.incomingMessageType>  = storeIncomingMsgType
    IF oSwiftResponse<PP.LocalClearingService.PaymentResponse.returnCode> EQ 'FAILURE' THEN
        oSARIEResponse = oSwiftResponse
        messageText = ''
        GOSUB PRGEXIT
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= getPaymentInfo>
getPaymentInfo:
*** <desc> </desc>
* Fetch the values from Payment Generation Subflow component by passing the neccassary Inputs
**/ Passing values to input arguments.
    iTransaction = ''
    iTransaction<PP.PaymentWorkflowDASService.PaymentID.companyID> = creditTansCompanyID
    iTransaction<PP.PaymentWorkflowDASService.PaymentID.ftNumber>  = creditTansFTNumber
**/
    oTransDetails = ''; oGetTransError = ''
    
    PP.PaymentWorkflowDASService.getSwiftOutPaymentRecord(iTransaction, oTransDetails, oGetTransError)
    
    IF oGetTransError EQ '' THEN
**/ Fetching the output values
        GOSUB getTagValues ; *Get required tag values
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getTagValues>
getTagValues:
*** <desc>Get required tag values </desc>
    
    tag71AChgbrr = oTransDetails<PP.PaymentWorkflowDASService.TransDetails.detailsOfCharges>
    sourceProduct = oTransDetails<PP.PaymentWorkflowDASService.TransDetails.originatingSource>
    paymentCcy = oTransDetails<PP.PaymentWorkflowDASService.TransDetails.transactionCurrency>
    CALL TPSLogging("test Parameter","PPSARI.validateMessage","tag71AChgbrr:":tag71AChgbrr,"")
    CALL TPSLogging("test Parameter","PPSARI.validateMessage","sourceProduct:":sourceProduct,"")
    CALL TPSLogging("test Parameter","PPSARI.validateMessage","paymentCcy:":paymentCcy,"")
    GOSUB getDebitPartyInfo ; *

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getDebitPartyInfo>
getDebitPartyInfo:
*** <desc> </desc>
* Fetch the values from Debit Party Determination component by passing the neccassary Inputs.

**/ Passing values to input arguments.

    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID> = creditTansCompanyID
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber> = creditTansFTNumber
**/
    oPrtyDbtDetails = ''; oGetPrtyDbtError = ''
    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
    CALL TPSLogging("test Parameter","PPSARI.validateMessage","oPrtyDbtDetails:":oPrtyDbtDetails,"")
    IF oGetPrtyDbtError EQ '' THEN
        LOCATE 'ORDPTY' IN oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,1> SETTING OrdPtyPos THEN ;* Extract account number of ORDPTY role
            
            orderingAcDbtPrty = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine, OrdPtyPos>
        END
        LOCATE 'ORDINS' IN oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,1> SETTING OrdPtyPos THEN ;* Extract account number of ORDINS role
            IF orderingAcDbtPrty NE '' AND oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine, OrdPtyPos> NE '' THEN
                orderingAcDbtPrty = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine, OrdPtyPos>
            END
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= getPaymentDets>
getPaymentDets:
*** <desc> </desc>
    
    PP.PaymentWorkflowGUI.getSupplementaryInfo("POR.INFORMATION", creditTansFTNumber, ReadWithLock, PorInfoRecord, Error)
    PP.PaymentWorkflowGUI.getSupplementaryInfo("POR.ADDITIONALINF", creditTansFTNumber, ReadWithLock, PorAddInfoRecord, Error)
    CALL TPSLogging("test Parameter","PPSARI.validateMessage","PorInfoRecord:":PorInfoRecord,"")
    CALL TPSLogging("test Parameter","PPSARI.validateMessage","PorAddInfoRecord:":PorAddInfoRecord,"")
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= validateInstCode>
validateInstCode:
*** <desc>
* When payment purpose is 'PAY' OR '/DIV/' then remittance information should start with /PAYROLL/ or /DIVIDEND/ respectively
* When payment purpose is not 'PAY' neither '/DIV/' then remittance information should not start with /PAYROLL/ or /DIVIDEND/
* Instruction codes - PHOB and TELB are mutaully exclusiveInstruction code should contain either PHOB or TELB, not both.
*** </desc>

    iInfoCodes = PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationcode>


    infoCodeCount = 0
    phoneFlag = 0
    telbFlag = 0
    LOOP
        REMOVE iInfoCode FROM iInfoCodes SETTING infoPos
    WHILE iInfoCode:infoPos
        infoCodeCount = infoCodeCount + 1
        IF iInfoCode EQ 'INSSDR' AND PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,infoCodeCount> EQ 'TXPURPCD' THEN
            BEGIN CASE
                CASE PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationline,infoCodeCount> EQ 'PAY'
                    IF PorAddInfoRecord<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinfline>[1,9] NE '/PAYROLL/' THEN
                        messageText = 'Remittance information should begin with /PAYROLL/'
                        GOSUB updateResponse ; *
             
                    END
                CASE PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationline,infoCodeCount> EQ 'DIV'
                    IF PorAddInfoRecord<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinfline>[1,10] NE '/DIVIDEND/' THEN
                        messageText = 'Remittance information should begin with /DIVIDEND/'
                        GOSUB updateResponse ; *
                    END
                CASE PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationline,infoCodeCount> NE ''
                    IF PorAddInfoRecord<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinfline>[1,10] EQ '/DIVIDEND/' OR PorAddInfoRecord<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinfline>[1,9] EQ '/PAYROLL/' THEN
                        messageText = 'Remittance information should NOT begin with /PAYROLL/ or /DIVIDEND/'
                        GOSUB updateResponse ; *
                    END
                    IF LEN(PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Informationline,infoCodeCount>) GT 3 THEN
                        messageText = 'Payment purpose code is greater than three characters'
                        GOSUB updateResponse ; *
                    END
            END CASE
        END
        IF iInfoCode EQ 'INSBNK' THEN
            
            BEGIN CASE
                CASE PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,infoCodeCount> EQ 'PHOB'
                    phoneFlag = 1
                CASE  PorInfoRecord<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,infoCodeCount> EQ 'TELB'
                    telbFlag = 1
            END CASE
        END
    REPEAT
    IF phoneFlag AND telbFlag THEN
        messageText = 'Instruction code - PHOB and TELB are mutually exclusive'
        GOSUB updateResponse ; *
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
PRGEXIT:
RETURN TO PRGEXIT
END
     
