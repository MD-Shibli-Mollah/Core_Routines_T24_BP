* @ValidationCode : MjotMTAxNDMzMzI5ODpDcDEyNTI6MTYwODU4MDMwMjI3ODp1bWFtYWhlc3dhcmkubWI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Dec 2020 01:21:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE PPINIP.Foundation
SUBROUTINE PPINIP.GET.PAYMENT.INFO.FROM.GENERIC.XML(iIncomingMessage, ioFileData, ioBulkData,ioGenericData, oAction,oResponse)
*-----------------------------------------------------------------------------
* API to extract currency from oiginal transaction and enrich in inward pacs.002, camt.056 and pacs.004 for Nordic Instant CT
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.InwardMappingFramework
    $USING EB.DataAccess
    $INSERT I_PaymentWorkflowDASService_PaymentRecord
    $INSERT I_PaymentWorkflowDASService_PaymentID
*-----------------------------------------------------------------------------
    
    GOSUB initialise
    GOSUB enrichDetails
    GOSUB mapOutput
       
RETURN
*-----------------------------------------------------------------------------
initialise:
    CALL TPSLogging("DB Input","InwardMappingFramework.getPaymentInfoFromGenericXml","ioFileData : <":ioFileData:">","")
    CALL TPSLogging("DB Input","InwardMappingFramework.getPaymentInfoFromGenericXml","ioBulkData : <":ioBulkData:">","")
    CALL TPSLogging("DB Input","InwardMappingFramework.getPaymentInfoFromGenericXml","iIncomingMessage : <":iIncomingMessage:">","")
    CALL TPSLogging("DB Input","InwardMappingFramework.getPaymentInfoFromGenericXml","ioGenericData : <":ioGenericData:">","")
    CONVERT @VM TO @FM IN ioFileData
    CONVERT @VM TO @FM IN ioBulkData
RETURN
*-----------------------------------------------------------------------------
mapOutput:
    CONVERT @FM TO @VM IN ioFileData
    CONVERT @FM TO @VM IN ioBulkData
    CALL TPSLogging("DB Output","InwardMappingFramework.getPaymentInfoFromGenericXml","ioFileData : <":ioFileData:">","")
    CALL TPSLogging("DB Output","InwardMappingFramework.getPaymentInfoFromGenericXml","ioBulkData : <":ioBulkData:">","")
    CALL TPSLogging("DB Output","InwardMappingFramework.getPaymentInfoFromGenericXml","iIncomingMessage : <":iIncomingMessage:">","")
    CALL TPSLogging("DB Output","InwardMappingFramework.getPaymentInfoFromGenericXml","ioGenericData : <":ioGenericData:">","")
    CALL TPSLogging("DB Output","InwardMappingFramework.getPaymentInfoFromGenericXml","payCcy : <":oPaymentOrder<PaymentRecord.transactionCurrencyCode>:">","")
    
RETURN

*-------------------------------------------------------------------------------------
enrichDetails:
    
   
    tagTxn = '<Transaction>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<OriginalTransactionIdentification>'
    GOSUB extract
    GOSUB getPORTranConcat
    GOSUB getPaymentRecord
    GOSUB extractbulkFormat
    IF ioBulkData<PP.InwardMappingFramework.BulkDataObject.grpHdrTotItbkSttlAmCcy> EQ '' THEN
        ioBulkData<PP.InwardMappingFramework.BulkDataObject.grpHdrTotItbkSttlAmCcy> = oPaymentOrder<PaymentRecord.transactionCurrencyCode>
    END
   
    IF bulkFrmt EQ "pacs.004" THEN
        CHANGE orgnltxnref TO  R.TRANSACTION.CONCAT<2> IN iIncomingMessage
    END

RETURN

*-------------------------------------------------------------------------------------
extract:
    tagContent = ""
    tagValue = ""
    tagContent = FIELD(Content,tag,pos)
    tagValue = FIELD(tagContent,"<",1,1)
RETURN
*-------------------------------------------------------------------------------------
extractbulkFormat:
    tagHdr = '<BulkHeader>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagHdr,pos)
    tagbulkFrmt = "<BulkClearingStatusReportOriginalBulkFormat>"
    tagContent = ""
    tagValue = ""
    tagContent = FIELD(Content,tagbulkFrmt,pos)
    bulkFrmt = FIELD(tagContent,"<",1,1)
RETURN
*-----------------------------------------------------------------------------
getPORTranConcat:
*   In this GOSUB, Process the confirmation for the payment that was sent out.
    FN.POR.TRANSACTION.CONCAT = 'F.POR.TRANSACTION.CONCAT'
    F.POR.TRANSACTION.CONCAT = ''
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    iOriginatingSource=ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
    IDVAL = tagValue:'-':iOriginatingSource
    orgnltxnref = tagValue
    EB.DataAccess.FRead(FN.POR.TRANSACTION.CONCAT,IDVAL,R.TRANSACTION.CONCAT,F.POR.TRANSACTION.CONCAT,ERR.CONCAT)
    
RETURN
*-----------------------------------------------------------------------------
getPaymentRecord:
*   In this GOSUB get the Payment Record
    oPaymentOrder = ""
    oReadErr = ""
    iPaymentID = ""
    oAdditionalPaymentRecord = ""
    iPaymentID=''
    iPaymentID<PaymentID.companyID> = R.TRANSACTION.CONCAT[1,3]
    iPaymentID<PaymentID.ftNumber>  = R.TRANSACTION.CONCAT
* If relevant POR.TRANSACTION.CONCAT is not found,FT number is used to get payment record
    IF iPaymentID<PaymentID.ftNumber> EQ '' THEN
        iPaymentID<PaymentID.ftNumber> = tagValue
    END
    CALL PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentOrder,oAdditionalPaymentRecord,oReadErr)
RETURN
*-----------------------------------------------------------------------------
END

