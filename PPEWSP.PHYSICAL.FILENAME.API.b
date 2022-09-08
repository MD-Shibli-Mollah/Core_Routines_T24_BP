* @ValidationCode : Mjo0OTY2NTAxODE6Q3AxMjUyOjE2MDQzMTI5OTA1MDY6c2theWFsdml6aGk6MTM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTktMDQ1OTo3NDo3MQ==
* @ValidationInfo : Timestamp         : 02 Nov 2020 15:59:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 13
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 71/74 (95.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPEWSP.Foundation
*
* Implementation of PPEWSP.ClearingFramework.ppewspPhysicalFilenameApi
*
* iPaymentRecord(IN) :In parameter contains payment details.
* iAdditionalPaymentRecord(IN) :In parameter holds additional payment details.
* iGenericInfo(IN) :In parameter of the routine
* oFileName(OUT) :Out parameter of the routine will carry the filename of the file which is going to be generated for outgoing payments.
*
*Program Description:
* Program used to get the file name for the outgoing payments of the EWSEPA clearing and will be called from routine "mapCreditTransfer" of the OutwardMappingFramework component.
SUBROUTINE PPEWSP.PHYSICAL.FILENAME.API(iPaymentRecord,iAdditionalPaymentRecord,iGenericInfo,oFileName)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 01/09/2020 - Enhancement 3831744 / Task 3910362 - For determining Physical File name
*01/10/2020 - Enhancement 3831888/Task 4000154 - Payments- NN bank - Equens DD � Cancellation and R-messages
*21/10/2020 - Task 4036072 - Regression Issue - Same fileName in sentfileDetails
*-----------------------------------------------------------------------------
    $USING PP.LocalClearingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.OutwardMappingFramework
   
    GOSUB intialise ; *
    GOSUB process ; *
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= intialise>
intialise:
*** <desc> </desc>
    CONVERT @VM TO @FM IN iPaymentRecord
    CONVERT @VM TO @FM IN iAdditionalPaymentRecord
    CONVERT @VM TO @FM IN iGenericInfo
    
    oFileName = ''
    outFileName = ''
    clearingId = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.clearingId>
    iCompanyID = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    txnCur = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    msgType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    txnType = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.clearingTransactionType>
    IF iGenericInfo<PP.OutwardMappingFramework.GenericInfo.outMsgType> NE '' THEN
        outMsgType = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.outMsgType>
    END ELSE
        outMsgType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    END
    fileReference = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileName>
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>
    GOSUB readPpClearingComapany ; *
  
    PP.OutwardMappingFramework.ppGetSentfileFilename(fileReference, outFileName)
    IF outFileName<1> NE '' THEN
        oFileName = outFileName<1>
    END ELSE
        iLockingId = 'PPEWSP.FILENAME.UNIREF' ;* locking file record id
        iAgentDigits = '2';* length of the seq no from agent's relative position
        iRandomDigitsLen = '6' ;* length of the unique reference number  from locking record
        traceNumP2 = ''
        PPEWSP.Foundation.ppewspGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen,'' ,traceNumP2,'')
        uniqueRef = traceNumP2
        BEGIN CASE

            CASE outMsgType EQ 'pacs.008' AND txnType EQ 'CT'
                oFileName = SendingBic[1,8]:'SFT':'CTPI':uniqueRef:'.XML'
            
            CASE outMsgType EQ 'pacs.004' AND txnType EQ 'RT'
                oFileName = SendingBic[1,8]:'SFT':'CTRT':uniqueRef:'.XML'
        
            CASE outMsgType EQ 'camt.056' AND txnType EQ 'CR'
                oFileName = SendingBic[1,8]:'SFT':'CTRFB':uniqueRef:'.XML'
        
            CASE outMsgType EQ 'pacs.028' AND (txnType EQ 'SR' OR txnType EQ 'SR-CA' OR txnType EQ 'SR-CM')
                oFileName = SendingBic[1,8]:'SFT':'CTSRFB':uniqueRef:'.XML'
        
            CASE outMsgType EQ 'camt.029' AND txnType EQ 'RI'
                oFileName = SendingBic[1,8]:'SFT':'CTRNFB':uniqueRef:'.XML'
        
            CASE outMsgType EQ 'camt.029' AND (txnType EQ 'RI-CA' OR txnType EQ 'RI-CM')
                oFileName = SendingBic[1,8]:'SFT':'CTCRFB':uniqueRef:'.XML'
        
            CASE outMsgType EQ 'camt.027' AND txnType EQ 'CA'
                oFileName = SendingBic[1,8]:'SFT':'CTCNFB':uniqueRef:'.XML'
        
            CASE outMsgType EQ 'camt.087' AND txnType EQ 'CM'
                oFileName = SendingBic[1,8]:'SFT':'CTCVFB':uniqueRef:'.XML'
            
            CASE outMsgType EQ 'pacs.003' AND txnType EQ 'DD'
                oFileName = SendingBic[1,8]:'SFT':'DCFB':uniqueRef:'.XML'
            
            CASE outMsgType EQ 'pacs.004' AND (txnType EQ 'RF' OR txnType EQ 'RD')
                oFileName = SendingBic[1,8]:'SFT':'DRFB':uniqueRef:'.XML'
            
            CASE outMsgType EQ 'camt.056' AND txnType EQ 'CR-DD'
                oFileName = SendingBic[1,8]:'SFT':'DLFB':uniqueRef:'.XML'
            
            CASE outMsgType EQ 'pacs.007' AND txnType EQ 'RV'
                oFileName = SendingBic[1,8]:'SFT':'DVFB':uniqueRef:'.XML'
            
            CASE outMsgType EQ 'pacs.002' AND txnType EQ 'DD'
                oFileName = SendingBic[1,8]:'SFT':'DJFB':uniqueRef:'.XML'
                
        END CASE
    END
    
    GOSUB finalise ; *
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= readPpClearingComapany>
readPpClearingComapany:
*** <desc> </desc>
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iCompanyID
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = clearingId
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = txnCur
    
    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
    IF oClrError EQ '' THEN
        SendingBic = oClrDetails<PP.LocalClearingService.ClrDetails.sendingBIC>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= finalise>
finalise:
*** <desc> </desc>
    CONVERT @FM TO @VM IN iPaymentRecord
    CONVERT @FM TO @VM IN iAdditionalPaymentRecord
    CONVERT @FM TO @VM IN iGenericInfo

RETURN
*** </region>

END
