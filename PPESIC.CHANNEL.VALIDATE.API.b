* @ValidationCode : Mjo4ODAyNzU4MzI6Q3AxMjUyOjE2MTE4MjgwMTQxNTA6bGF2YW55YXN0Ojg6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDEuMjAyMDEyMjYtMDYxODoyMTQ6MTcx
* @ValidationInfo : Timestamp         : 28 Jan 2021 15:30:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lavanyast
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 171/214 (79.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPESIC.Foundation
SUBROUTINE PPESIC.CHANNEL.VALIDATE.API(iChannelDetails, iRSCreditDets, oChannelResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*30/11/2020 - Enhancement 3777154 / Task 4043972 - API added as a part of EUROSIC Clearing.
*28/01/2021 - Enhancement 3777154 / Task 4193523 - channel validation added for Instruction for next agent and service level code fields
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.LocalClearingService
    $USING PP.InboundCodeWordService
    $USING PP.ClearingFrameworkService
    $USING PP.PaymentWorkflowGUI
    $INSERT I_PaymentWorkflowDASService_PaymentID
    $INSERT I_PaymentWorkflowDASService_PaymentRecord
    $INSERT I_PaymentWorkflowDASService_AdditionalPaymentRecord
    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
    $INSERT I_DebitPartyDeterminationService_PartyDebitDetails
    $INSERT I_DebitPartyDeterminationService_DASError
    $INSERT I_DebitPartyDeterminationService_AccInfoDetails
    $INSERT I_DebitPartyDeterminationService_InputTransactionAccDetails
    $INSERT I_CreditPartyDeterminationService_CreditPartyKey
    $INSERT I_CreditPartyDeterminationService_CreditPartyDetails
    $INSERT I_DebitAuthorityService_InputDADetails
    $INSERT I_DebitAuthorityService_DebAuthDetails
    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsReq
    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsList
    $INSERT I_PaymentFrameworkService_PORHistoryLog
    $INSERT I_PaymentFrameworkService_BusinessDate
*------------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process

RETURN
*------------------------------------------------------------------------------
initialise:
    oChannelResponse = '' ; scenarioCode = '' ;
    ErrorCode = ''
*
RETURN
*------------------------------------------------------------------------------
process:
* validating FTnumber
    GOSUB validateFTNumber
* retrieve the payment details
    GOSUB getPorTransInfo
* retrieve the POR.Supplementary Info details, skip checking PORInformation for cover payments
    IF NOT(coverFlag EQ 'Y' OR validationFlag EQ 'COV') THEN
        GOSUB getPorInformation
    END
    GOSUB validateCreditValueDate
    GOSUB validateTransactionAmount
    GOSUB validateTransactionCurrencyCode
    GOSUB validatePaymentType ; * If Payment Type is SLRPMT move the payment to repair queue
    GOSUB validateInstructionForNxtAgt ; * Only CONF or LIQU is allowed
    GOSUB validateServiceLvlCd ; *validation based on payment mehod
RETURN
*------------------------------------------------------------------------------
validateFTNumber:
    IF iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber> EQ "" THEN
        messageInfoVal = "FTNumber NOT FOUND"
        GOSUB finalise
    END
    
RETURN
*------------------------------------------------------------------------------
validateCreditValueDate:
    currBusinessDate = ''
    iCompanyKey = iChannelDetails<PP.LocalClearingService.TransDets.companyID>
    CALL PaymentFrameworkService.getCurrBusinessDate(iCompanyKey, oBusinessDate, oGetCurDateError)
    currBusinessDate =  oBusinessDate<BusinessDate.currBusinessDate>
    
RETURN
*------------------------------------------------------------------------------
getPorTransInfo:
* retrieve the payment details
    iPaymentID                          = ""
    iPaymentID<PaymentID.ftNumber>      = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    iPaymentID<PaymentID.companyID>     = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    oPaymentRecord                      = ""
    oAdditionalPaymentRecord            = ""
    oReadErr                            = ""
    CALL PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    coverFlag = iChannelDetails<PP.ClearingFrameworkService.ChannelDetails.coverFlag>
    validationFlag = oPaymentRecord<PaymentRecord.validationFlag>
    IF oReadErr<PP.LocalClearingService.DASError.error> NE "" THEN
        scenarioCode = 1
        GOSUB updateResponseAndExit
    END

RETURN
*------------------------------------------------------------------------------
getPorInformation:
* retrieve the payment information details
    iPaymentID = ''; oPaymentInformation = ''; oPaymentInfoError = ''
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPaymentID<PP.InboundCodeWordService.PaymentInfoKeys.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    PP.InboundCodeWordService.getPaymentOrderInformation(iPaymentID, oPaymentInformation, oPaymentInfoError)
    
RETURN
*------------------------------------------------------------------------------
validateTransactionAmount:
    iChannelDetails<PP.LocalClearingService.TransDets.transactionAmount> = oPaymentRecord<PaymentRecord.transactionAmount>
    IF iChannelDetails<PP.LocalClearingService.TransDets.transactionAmount> EQ "" THEN
        messageInfoVal = "TransactionAmount NOT FOUND"
        GOSUB finalise
    END

* Transaction Amount must be 0.01 or more and 999999999.99 or les and the fractional part has a maximum of two digits.
    IF iChannelDetails<PP.LocalClearingService.TransDets.transactionAmount> <= 0 THEN
        messageInfoVal = "TransactionAmount is equal to zero"
        GOSUB finalise
    END
    
*retrive the POR.Supplementary Additional Info
    GOSUB getPorAdditionalInfo
    infCode = ''
    countPorInf = ''
    cnt=1
    infRecord=oPaymentRecord<PaymentRecord.bankOperationCode>
    LOOP
        REMOVE infCode FROM infRecord SETTING countPorInf
    WHILE infCode:countPorInf
        IF oPaymentRecord<PaymentRecord.bankOperationCode,cnt> EQ 'ESRPMT' THEN
            IF (iChannelDetails<PP.LocalClearingService.TransDets.transactionAmount> GT 99999999.99) AND (iAdditionalInformationDets<PP.LocalClearingService.PorAdditionalInf.additionalInfLine> EQ "/SICPTCOD/712") THEN
                messageInfoVal = "TransactionAmount OUT OF RANGE Value"
                GOSUB finalise
            END
        END
        cnt++
    REPEAT

RETURN
*------------------------------------------------------------------------------
validateTransactionCurrencyCode:
    iChannelDetails<PP.LocalClearingService.TransDets.transactionCurrencyCode> = oPaymentRecord<PaymentRecord.transactionCurrencyCode>
    IF iChannelDetails<PP.LocalClearingService.TransDets.transactionCurrencyCode> EQ "" THEN
        messageInfoVal = "TransactionCurrencyCode NOT FOUND"
        GOSUB finalise
    END
    
RETURN
*------------------------------------------------------------------------------
updateResponseAndExit:
    messageInfoVal = oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageText>
*Tracer added to update HistoryLog for CLF10005 error
    LogEventType = 'INF'
    LogEventDescription = ''
    LogErrorCode = ErrorCode
    LogEventDescription = ''
    LogAdditionalInfo = messageInfoVal
    GOSUB updateHistoryLog
    
RETURN
*------------------------------------------------------------------------------
updateHistoryLog:
    iPORHistoryLog<PORHistoryLog.companyID> = iChannelDetails<PP.LocalClearingService.ChannelDetails.companyID>
    iPORHistoryLog<PORHistoryLog.ftNumber> = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    iPORHistoryLog<PORHistoryLog.eventType> = 'ERR'
    iPORHistoryLog<PORHistoryLog.eventDescription> = LogEventDescription
    iPORHistoryLog<PORHistoryLog.errorCode> = 'LCL00013'
    iPORHistoryLog<PORHistoryLog.additionalInfo> = messageInfoVal
    CALL PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)  ;* To update POR.HISTORYLOG table

RETURN
*------------------------------------------------------------------------------
*** <region name= getPorAdditionalInfo>
getPorAdditionalInfo:
*** <desc>retrive the POR.Supplementary Additional Info </desc>
    oAdditionalInfo = ''
    Error = ''
    ftnum = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.ADDITIONALINF', ftnum, '', oAdditionalInfo, Error)
    addInfCodeRec = oAdditionalInfo<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinformationcode>
    addInfCode = ''
    addInfPos = ''
    aPos = 1
    LOOP
        REMOVE addInfCode FROM addInfCodeRec SETTING addInfPos
    WHILE addInfCode:addInfPos
        IF addInfCode EQ 'RMTINF' THEN
            iAdditionalInformationDets<PP.LocalClearingService.PorAdditionalInf.additionalInfLine> = oAdditionalInfo<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinfline,aPos>
        END
        aPos = aPos + 1
    REPEAT
  
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= validatePaymentType>
validatePaymentType:
*** <desc> </desc>
    posInf = ''
    infRecord=RAISE(oPaymentRecord<PaymentRecord.bankOperationCode>)
    LOCATE 'SLRPMT' IN infRecord SETTING posInf THEN
        messageInfoVal = "SLRPMT is not allowed as a Payment Type"
        GOSUB finalise
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
validateInstructionForNxtAgt:
    porInformationRec = ''
    RecordID =''
    TableName = 'POR.INFORMATION'
    RecordID  = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    PP.PaymentWorkflowGUI.getSupplementaryInfo(TableName, RecordID, ReadWithLock, porInformationRec, Error)
    IF Error EQ '' THEN
        IN.CNT  = 1
        IN.CNTR = DCOUNT(porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Instructioncode>, @VM)
        LOOP
        WHILE IN.CNT LE IN.CNTR
            IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationcode,IN.CNT> EQ "INSSDR" THEN
                IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,IN.CNT> EQ "CTI" THEN
*only CONF or LIQU is allowed
                    IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationline,IN.CNT> NE "/CONF/" OR porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationline,IN.CNT> NE "/LIQU/" THEN
                        messageInfoVal = "Allowed values for instruction for next agent are only CONF or LIQU"
                        GOSUB finalise
                    END
                END
            END
            IN.CNT++
        REPEAT
    END
RETURN
*------------------------------------------------------------------------------
validateServiceLvlCd:
    GOSUB getPymtMethod
    porInformationRec = ''
    RecordID =''
    
    TableName = 'POR.INFORMATION'
    RecordID  = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    PP.PaymentWorkflowGUI.getSupplementaryInfo(TableName, RecordID, ReadWithLock, porInformationRec, Error)
    IF Error EQ '' THEN
        IN.CNT  = 1
        IN.CNTR = DCOUNT(porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Instructioncode>, @VM)
        LOOP
        WHILE IN.CNT LE IN.CNTR
            IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationcode,IN.CNT> EQ 'INSBNK' THEN
                IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,IN.CNT> EQ 'SVCLVL' THEN
                    BEGIN CASE
*validation based on payment type
                        CASE pmtMethod MATCHES 'CSTPMT':@VM:'ESRDEB':@VM:'IPIDEB'
                            IF  porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationline,IN.CNT> NE 'URGP' THEN
                                messageInfoVal = 'Only URGP allowed for this payment type'
                                GOSUB finalise
                            END
                        CASE pmtMethod MATCHES 'SEPPMT'
                            IF  porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationline,IN.CNT> NE 'SEPA' THEN
                                messageInfoVal = 'Only SEPA allowed for this payment type'
                                GOSUB finalise
                            END
                    END CASE
                END
            END
            IN.CNT++
        REPEAT
    END
RETURN
*-----------------------------------------------------------------------------
getPymtMethod:
    RecordID =''
    pmtMethod=''
    TableName = 'POR.INFORMATION'
    RecordID  = iChannelDetails<PP.LocalClearingService.ChannelDetails.ftNumber>
    PP.PaymentWorkflowGUI.getSupplementaryInfo(TableName, RecordID, ReadWithLock, porInformationRec, Error)
    IF Error EQ '' THEN
        IN.CNT  = 1
        IN.CNTR = DCOUNT(porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Instructioncode>, @VM)
        LOOP
        WHILE IN.CNT LE IN.CNTR
            IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationcode,IN.CNT> EQ 'INSBNK' THEN
                IF porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Instructioncode,IN.CNT> EQ 'LCLINSPY' THEN
                    pmtMethod = porInformationRec<PP.PaymentWorkflowGUI.PorInformation.Informationline,IN.CNT> ;*get payment method from POR.INFORMATION table
                END
            END
            IN.CNT++
        REPEAT
    END
RETURN
*------------------------------------------------------------------------------
finalise:
    GOSUB updateHistoryLog ; *
    oChannelResponse<PP.LocalClearingService.PaymentResponse.returnCode> = 'FAILURE'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.serviceName> = 'LocalClearingService'
    oChannelResponse<PP.LocalClearingService.PaymentResponse.responseMessages,1,PP.LocalClearingService.ResponseMessage.messageInfo> = messageInfoVal
    GOSUB exit

RETURN
*------------------------------------------------------------------------------
exit:
RETURN TO exit
*------------------------------------------------------------------------------
END
