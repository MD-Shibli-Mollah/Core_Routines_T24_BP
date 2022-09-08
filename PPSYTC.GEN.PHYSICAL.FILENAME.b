* @ValidationCode : MjoxMDkxMjI3NjM3OkNwMTI1MjoxNjAyMjU1MTA4ODU5OnNrYXlhbHZpemhpOjg6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo4NTo4Mg==
* @ValidationInfo : Timestamp         : 09 Oct 2020 20:21:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/85 (96.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.GEN.PHYSICAL.FILENAME(iPaymentRecord,iAdditionalPaymentRecord,iGenericInfo,oFileName)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*2/3/2020 - Enhancement 3131018/ Task 3130941 - Routine to form the physical file name based on the clearing transaction type.
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
*15/04/2020 - Enhancement 3540611/Task 3685871 - NCC mapping for format SYSTACDDRJ
* 6/4/2020 - Enhancement 3457582/Task 3457545 - Payments-Afriland - SYSTAC (CEMAC) - Cheque payments
* 3/8/2020 - Enhancement 3614846/Task 3854892 -Afriland - SYSTAC (CEMAC) - Resubmission of Direct Debits - Clearing
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentFrameworkService
    $USING PP.OutwardMappingFramework
    $USING PP.LocalClearingService
    
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process
    GOSUB finalise ;* Finalise the output value
RETURN
*-----------------------------------------------------------------------------

Initialise:

    CHANGE @VM TO @FM IN iPaymentRecord
    CHANGE @VM TO @FM IN iGenericInfo
    CHANGE @VM TO @FM IN iAdditionalPaymentRecord
    
    prefixValue = ''
    oTimestampDate = ''
    oTimestampTime = ''
    oTimestamp = ''
    oTimestampResponse = ''
    iClrRequest = ''
    oClrDetails = ''
    oClrError = ''
    sendingNcc = ''
    outFileName = ''
    clearingTxnType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    outgoingMsgType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    countryCode = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyCountryCode>
    clearingNatureCode = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode>
    fileReference = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileName>
    
RETURN

*-----------------------------------------------------------------------------

Process:
*** <desc></desc>
*get remittance bank code from PP.CLEARING
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outputChannel>
    IF iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outTransactionCurrencyCode> EQ ''THEN
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    END ELSE
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outTransactionCurrencyCode>
    END
    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
    sendingNcc = oClrDetails<PP.LocalClearingService.ClrDetails.sendingNcc>
    clearingCountryCode = oClrDetails<PP.LocalClearingService.ClrDetails.clearingCountryCode>
* Get the current Time Stamp
    PP.PaymentFrameworkService.createTimestamp(oTimestamp, oTimestampResponse)
    oTimestampDate = oTimestamp[1,8]
    oTimestampTime = oTimestamp[9,6]
    PP.OutwardMappingFramework.ppGetSentfileFilename(fileReference, outFileName)
    IF outFileName<1> NE '' THEN
        oFileName = outFileName<1>
    END ELSE
        BEGIN CASE
            CASE clearingTxnType EQ 'CT'
                prefixValue = '01-CM-10005-00001-'
                suffixValue = '-10-21-950.ENV'
        
            CASE clearingTxnType EQ 'RT'
                prefixValue = '01-CM-10005-00001-'
                suffixValue = '-10-22-950.ENV'
    
            CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'SYSTACDD' AND clearingNatureCode EQ ''
                prefixValue = '01-CM-':sendingNcc:'-'
                suffixValue = '-20-21-950.ENV'
    
            CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'SYSTACDDRJ'
                IF sendingNcc EQ '' THEN
                    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
                    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
                    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
                    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
                    sendingNcc = oClrDetails<PP.LocalClearingService.ClrDetails.sendingNcc>
                END
                prefixValue = '01-CM-':sendingNcc:'-'
                suffixValue = '-20-22-950.ENV'
            
            CASE clearingTxnType EQ 'CC' OR clearingTxnType EQ 'RF'
                prefixValue = '01-':clearingCountryCode:'-':sendingNcc:'-'
                suffixValue = '-':outgoingMsgType[4,2]:'-':outgoingMsgType[6,2]:'-950.ENV'
                oTimestampDate = oTimestampDate[7,2]:oTimestampDate[5,2]:oTimestampDate[1,4]
            
            CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'SYSTACDD' AND clearingNatureCode EQ 'REP'
                prefixValue = '01-CM-':sendingNcc:'-'
                suffixValue = '-23-21-950.ENV'
            
            CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'SYTCRDDR'
                IF sendingNcc EQ '' THEN
                    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
                    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
                    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
                    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
                    sendingNcc = oClrDetails<PP.LocalClearingService.ClrDetails.sendingNcc>
                END
                prefixValue = '01-CM-':sendingNcc:'-'
                suffixValue = '-23-22-950.ENV'
        END CASE
    
        oFileName = prefixValue:oTimestampDate:'-':oTimestampTime:suffixValue
    END
     

        
RETURN

*-----------------------------------------------------------------------------
finalise:
********
    CHANGE @FM TO @VM IN iPaymentRecord
    CHANGE @FM TO @VM IN iGenericInfo
    CHANGE @FM TO @VM IN iAdditionalPaymentRecord
RETURN
*------------------------------------------------------------------------------
END


