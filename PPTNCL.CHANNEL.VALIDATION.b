* @ValidationCode : MjotMTg4NzM5ODYwNTpDcDEyNTI6MTYwMDI0NTk2MTAzMTpzYXJtZW5hczoyNDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjI1NDoxOTI=
* @ValidationInfo : Timestamp         : 16 Sep 2020 14:16:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 24
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 192/254 (75.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.CHANNEL.VALIDATION(iChannelDetails, iRSCreditDets, oChannelResponse)
*-----------------------------------------------------------------------------
* This API is attached in PP.CLEARING.SETTING to validate the outgoing CT and DD payments
*-----------------------------------------------------------------------------
* Modification History :
*24/06/2020 - Enhancement 3538850/Task 3816876-Payments-BHTunsian-Issued Direct Debit / Received Direct Debit
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowDASService
    $USING PP.LocalClearingService
    $USING PP.PaymentFrameworkService
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $USING PP.PaymentWorkflowGUI
    $USING PP.DebitAuthorityService
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
*
RETURN
*------------------------------------------------------------------------------
initialise:
*
    oChannelResponse = '' ;
    oPaymentRecord = ""
    oAdditionalPaymentRecord = ""
    oReadErr = ""
    ftNumber = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>
    errorCode=''
    messageInfoVal=''
    iPaymentID = ''
*
RETURN
*------------------------------------------------------------------------------
process:
    
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>[1,3]
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode> NE 'TND' THEN
        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText>    = 'Invalid Currency'
        GOSUB updateResponseAndExit
    END
    
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ 'CT' THEN
        GOSUB checkCreditInfo
        GOSUB checkLocalFields ; *
        GOSUB validatRIB ; *
    END
    
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ 'DD' THEN
        iInputDebitAuthority<PP.DebitAuthorityService.InputDADetails.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
        iInputDebitAuthority<PP.DebitAuthorityService.InputDADetails.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>

        PP.DebitAuthorityService.getDebitAuthInfo(iInputDebitAuthority,oDebAuthDetails,oGetDAInfoError)
        IF oDebAuthDetails<PP.DebitAuthorityService.DebAuthDetails.mandateReference> EQ '' THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Mandate Reference is null'
            GOSUB updateResponseAndExit
        END
        GOSUB checkDebitInfo
    END
    
    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType> EQ 'CC' THEN
        GOSUB checkPresentmentType ; *checks  cheque presentment Type
        GOSUB checkCreditAccountLine
        GOSUB checkDebitDetailsForCC
        
        chequeNumber = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.chequeNumber>
        IF chequeNumber EQ '' THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Cheque Number is Blank'
            GOSUB updateResponseAndExit
        END

    END
    
RETURN
checkDebitDetailsForCC:
*---------------------

    GOSUB getDebitDetails

    IF oGetPrtyDbtError<PP.LocalClearingService.DASError.error> NE "" THEN
        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Debit Party Record Not Found'
        GOSUB updateResponseAndExit
    END ELSE
        noOfTypes = DCOUNT(oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>,@VM)
        FOR type=1 TO noOfTypes
            BEGIN CASE
                CASE oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'DEBTOR'
                    debtorAccount = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,type>
                    IF debtorAccount EQ '' THEN
                        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Debtor account is blank'
                        GOSUB updateResponseAndExit
                    END ELSE
                        IF LEN(debtorAccount) NE '20' THEN
                            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Length of Debtor account is invalid'
                            GOSUB updateResponseAndExit
                        END
                    END
                CASE oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'DBTAGT'
                    clearingMemberId = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyClearingMemberId,type>
                    IF clearingMemberId EQ '' THEN
                        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Debtor agent clearing member Id is blank'
                        GOSUB updateResponseAndExit
                    END
            END CASE
        NEXT type
    END
    
RETURN

checkCreditAccountLine:
*----------------------

    GOSUB getCreditDetails

    noOfTypes = DCOUNT(oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>,@VM)
      
    FOR type=1 TO noOfTypes
        partyRole = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,type>
        
        IF partyRole EQ 'ORDPTY' THEN
            creditPartyAccount = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,type>
            IF creditPartyAccount EQ '' THEN
                oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'ORDPTY account is blank'
                GOSUB updateResponseAndExit
            END ELSE
                IF LEN(creditPartyAccount) NE '20' THEN
                    oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Length of creditor account is invalid'
                    GOSUB updateResponseAndExit
                END
            END
        END
    NEXT type
    
RETURN

getCreditDetails:
*----------------
    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iChannelDetails<PPTNCL.Foundation.ChannelDetails.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>
    oCreditPartyDet = ""
    oGetCreditError = ""
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)

RETURN
*-----------------------------------------------------------------------------
checkCreditInfo:
*   Calling credit Party Determination Service Component.
    
    GOSUB getCreditDetails
        
    noOfTypes = DCOUNT(oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>,@VM)
      
    FOR type=1 TO noOfTypes
        partyRole = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,type>
        BEGIN CASE
            CASE partyRole EQ 'BENFCY'
                benAccount = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,type>
                IF benAccount EQ '' THEN
                    oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'BENFCY account is blank'
                    GOSUB updateResponseAndExit
                END
            CASE partyRole EQ 'ACWINS'
                acwinsAccount = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,type>
                IF acwinsAccount EQ '' THEN
                    oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'ACWINS account is blank'
                    GOSUB updateResponseAndExit
                END
        
        END CASE
        
    NEXT type
RETURN
*------------------------------------------------------------------------------
getDebitDetails:
*---------------

    iDebitPartyRole                             = ""
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = iChannelDetails<PPTNCL.Foundation.ChannelDetails.companyID>
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>
    oPrtyDbtDetails                             = ""
    oGetPrtyDbtError                            = ""
    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)

RETURN
*-------------------------------------------------------------------------------
checkDebitInfo:
*--------------
    
    GOSUB getDebitDetails
    
    IF oGetPrtyDbtError<PP.LocalClearingService.DASError.error> NE "" THEN
        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Debit Party Record Not Found'
        GOSUB updateResponseAndExit
    END ELSE
        noOfTypes = DCOUNT(oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>,@VM)
        FOR type=1 TO noOfTypes
            BEGIN CASE
                CASE oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'DEBTOR'
                    debtorAccount = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,type>
                    IF debtorAccount EQ '' THEN
                        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Debtor account is blank'
                        GOSUB updateResponseAndExit
                    END ELSE
                        IF LEN(debtorAccount) NE '20' THEN
                            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Length of Debtor account is invalid'
                            GOSUB updateResponseAndExit
                        END
                    END
                CASE oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'DBTAGT'
                    clearingMemberId = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyClearingMemberId,type>
                    IF clearingMemberId EQ '' THEN
                        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Debtor agent clearing member Id is blank'
                        GOSUB updateResponseAndExit
                    END ELSE
                        IF SUBSTRINGS(clearingMemberId,1,2) EQ '//' THEN
                            clearingMemberId = SUBSTRINGS(clearingMemberId,3,2)
                        END ELSE IF SUBSTRINGS(clearingMemberId,1,1) EQ '/' THEN
                            clearingMemberId = SUBSTRINGS(clearingMemberId,2,2)
                        END
                    END
            END CASE
        NEXT type
        IF debtorAccount NE '' AND clearingMemberId NE '' AND (clearingMemberId NE SUBSTRINGS(debtorAccount,1,2)) THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Invalid RIB account'
            GOSUB updateResponseAndExit
        END
    END
    
    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iChannelDetails<PPTNCL.Foundation.ChannelDetails.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>
    oCreditPartyDet = ""
    oGetCreditError = ""
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)
    
    noOfTypes = DCOUNT(oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>,@VM)
      
    FOR type=1 TO noOfTypes
        partyRole = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,type>
        IF partyRole EQ 'ORDPTY' THEN
            benAccount = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,type>
            Orgid = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crOrgIdOtherId,type>
            IF benAccount EQ '' THEN
                oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'ORDPTY account is blank'
                GOSUB updateResponseAndExit
            END
            IF Orgid EQ '' THEN
                oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'ORDPTY OrgIdOtherId is blank'
                GOSUB updateResponseAndExit
            END
        END
    NEXT type
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
updateResponseAndExit:
    
    messageInfoVal = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageText>
    oChannelResponse<PPTNCL.Foundation.PaymentResponse.returnCode>                                    = 'FAILURE'
    oChannelResponse<PPTNCL.Foundation.PaymentResponse.serviceName>                                   = 'PPTNCL.Clearing'
    oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageCode>    = 'TUN10001' ;*'Failure due to incorrect or missing values in the mandatory fields'
    oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageInfo>    = iChannelDetails<PPTNCL.Foundation.ChannelDetails.outputChannel>:' Clearing Channel validation failed.Reason : ':messageInfoVal
    oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageType>    = 'NON_FATAL_ERROR'

*Tracer added to update HistoryLog for CLF10005 error
    LogEventType = 'INF'
    LogEventDescription = ''
    LogErrorCode = oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageCode>
    LogEventDescription = oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText>
    LogAdditionalInfo = messageInfoVal
    GOSUB updateHistoryLog
    GOSUB exit
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------
updateHistoryLog:

    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = iChannelDetails<PPTNCL.Foundation.ChannelDetails.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = iChannelDetails<PPTNCL.Foundation.ChannelDetails.ftNumber>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'ERR'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = ''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = errorCode
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = messageInfoVal

    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table

RETURN
*-----------------------------------------------------------------------------
getPaymentDetails:
*-----------------

    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS', ftNumber, '', R.POR.PAYMENTFLOWDETAILS, Error)
    locFieldName = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname>
    locFieldValue = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue>

RETURN
*------------------------------------------------------------------------------
*** <region name= checkLocalFields>
checkLocalFields:
*** <desc> </desc>

    GOSUB getPaymentDetails
   
    LOCATE 'OrginatorResidency' IN locFieldName<1,1> SETTING POS THEN
        fieldVal = locFieldValue<1,POS>
        IF fieldVal EQ '' THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'OrginatorResidency is blank'
            GOSUB updateResponseAndExit
        END
    END
        
    LOCATE 'OrginatorAcctNature' IN locFieldName<1,1> SETTING POS THEN
        fieldVal = locFieldValue<1,POS>
        IF fieldVal EQ '' THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'OrginatorAcctNature is blank'
            GOSUB updateResponseAndExit
        END
    END
    
    LOCATE 'OrginatorAcctType' IN locFieldName<1,1> SETTING POS THEN
        fieldVal = locFieldValue<1,POS>
        IF fieldVal EQ '' THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'OrginatorAcctType is blank'
            GOSUB updateResponseAndExit
        END
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= validatRIB>
validatRIB:
**** <desc> </desc>
    checkDigits = benAccount[19,2]
    accntRIB = benAccount[1,18]:'00'
    RIBKey = 97 - (MOD(accntRIB,97))
    IF RIBKey NE checkDigits THEN
        oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Invalid RIB account'
        GOSUB updateResponseAndExit
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*------------------------------------------------------------------------------
exit:
RETURN TO exit
*-----------------------------------------------------------------------------
*** <region name= checkPresentmentType>
checkPresentmentType:
*** <desc>checks  cheque presentment Type </desc>

    GOSUB getPaymentDetails

    LOCATE 'CHEQUE.PRESENTMENT.TYPE' IN locFieldName<1,1> SETTING POS THEN
        fieldVal = locFieldValue<1,POS>
        IF fieldVal EQ '' THEN
            oChannelResponse<PPTNCL.Foundation.PaymentResponse.responseMessages,1,PPTNCL.Foundation.ResponseMessage.messageText> = 'Cheque Presentment Type is blank'
            GOSUB updateResponseAndExit
        END
    END

RETURN
*** </region>

END

