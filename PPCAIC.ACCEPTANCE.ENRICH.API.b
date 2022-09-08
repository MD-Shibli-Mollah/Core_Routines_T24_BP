* @ValidationCode : MjoxNTEyNTY1NzgyOkNwMTI1MjoxNjE2NTc4NjYxMDE5OmxhdmFueWFzdDowOjE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6MTUwOjg0
* @ValidationInfo : Timestamp         : 24 Mar 2021 15:07:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lavanyast
* @ValidationInfo : Nb tests success  : 0
* @ValidationInfo : Nb tests failure  : 1
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 84/150 (56.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPCAIC.Foundation
SUBROUTINE PPCAIC.ACCEPTANCE.ENRICH.API(iIncomingMessage, ioFileData, ioBulkData,ioGenericData, oAction,oResponse)
*-----------------------------------------------------------------------------
* API to enrich in inward pacs.002
*-----------------------------------------------------------------------------
* Modification History : 04/03/2021 Enhancement-3988349 /Task - 4225703 API to enrich in inward pacs.002
* Modification History : 04/03/2021 Enhancement-3988349 /Task - 4225703 replace the rel reference with the Original FT Number
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.InwardMappingFramework
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentWorkflowGUI
    $INSERT I_PaymentWorkflowDASService_PaymentRecord
    $INSERT I_PaymentWorkflowDASService_PaymentID
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB enrichDetails
    GOSUB mapOutput
       
RETURN
*-----------------------------------------------------------------------------
initialise:
   
    CONVERT @VM TO @FM IN ioFileData
    CONVERT @VM TO @FM IN ioBulkData
    originalFTNumber=''
    
RETURN
*-----------------------------------------------------------------------------
mapOutput:
    CONVERT @FM TO @VM IN ioFileData
    CONVERT @FM TO @VM IN ioBulkData
    
RETURN
*-------------------------------------------------------------------------------------
enrichDetails:
   
   
    tagTxn = '<BulkHeader>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<BulkClearingStatusReportOriginalBulkReference>'
    GOSUB extract
    GOSUB getPORTranConcatOfBulkRef
    tagTxn = '<Transaction>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<OriginalTransactionIdentification>'
    GOSUB extract
    txnID=tagValue
    GOSUB getPORTranConcat
    IF originalFTNumber EQ '' THEN
    
        tagTxn = '<Transaction>'
        pos = 2
        Content = ''
    
        Content = FIELD(iIncomingMessage,tagTxn,pos)
        tag = '<OriginalTransactionIdentification>'
        GOSUB extract
        txnID=tagValue
        GOSUB getPaymentRecord
        IF oReadErr NE '' THEN
            GOSUB getPORTranConcat  ;*If payment record is not found, read the POR.TRANSACTION concat
        END
    END
    GOSUB getPaymentMethod ;*get the value to assign the payment method
    GOSUB getPorPmtFlowDets
    IF oPORPmtFlowDetailsGetError EQ '' THEN
        returnId = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>
    END
    IF pmtMethod EQ '' THEN
        GOSUB getGroupStatus
        IF grpStatus NE 'RJCT' THEN
            GOSUB getPorPmtFlowDets
            IF oPORPmtFlowDetailsGetError EQ '' THEN
                returnId = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>
                GOSUB getPaymentMethod
            END
        END
    END
    
    messageContent = FIELD(iIncomingMessage, '</Transaction>',1 )
    messageContent1 = FIELD(iIncomingMessage, '</Transaction>',2 )
    
    iIncomingMessage=messageContent:'<PaymentTypeInformationLocalInstrument><Proprietary>':pmtMethod:'</Proprietary></PaymentTypeInformationLocalInstrument>':messageContent1
    IF rtnId EQ '' THEN
        iIncomingMessage= EREPLACE(iIncomingMessage,txnID,originalFTNumber);* replace the rel reference with the Original FT Number
    END ELSE
        iIncomingMessage= EREPLACE(iIncomingMessage,txnID,rtnId);* replace the rel reference with the Original FT Number
    END

    
RETURN
*------------------------------------------------------------------------------
extract:
    
    tagContent = ""
    tagValue = ""
    tagContent = FIELD(Content,tag,pos)
    tagValue = FIELD(tagContent,"<",1,1)
    
RETURN
*-----------------------------------------------------------------------------
getPORTranConcat:
    
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    relRef = ''
    iOriginatingSource= ''
    IDVAL= ''
    iOriginatingSource=ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
    relRef=tagValue
    IDVAL = tagValue:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)  ;*get POR.TRANSACTION record
    originalFTNumber = R.TRANSACTION.CONCAT<1>
    
RETURN
*-----------------------------------------------------------------------------
getPaymentRecord:
*   In this GOSUB get the Payment Record

    oPaymentOrder = ""
    oReadErr = ""
    iPaymentID = ""
    oAdditionalPaymentRecord = ""
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = originalFTNumber
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = originalFTNumber[1,3]
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr) ;* Get Payment record
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= getPaymentMethod>
getPaymentMethod:
    
    RecordID =''
    pmtMethod=''
    porInformationRec=''
    TableName=''
    Error=''
    pmtMethod=''
    TableName = 'POR.INFORMATION'
    IF returnId EQ '' THEN
        RecordID = originalFTNumber
    END ELSE
        RecordID = returnId
    END
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
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPorPmtFlowDets>
getPorPmtFlowDets:
*** <desc> </desc>
    
    oPORPmtFlowDetailsList = ''
    oPORPmtFlowDetailsGetError = ''
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = originalFTNumber[1,3]
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = originalFTNumber
    
    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPorPmtFlowDets>
getGroupStatus:
*** <desc> </desc>
    grpStatus= ''
    tagTxn = '<BulkHeader>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<BulkClearingStatusReportGroupStatus>'
    GOSUB extract
    grpStatus = tagValue
       
RETURN
*** </region>

*-----------------------------------------------------------------------------
getPORTranConcatOfBulkRef:
    
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    relRef = ''
    iOriginatingSource= ''
    IDVAL= ''
    iOriginatingSource=ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
    relRef=tagValue
    IDVAL = tagValue:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)  ;*get POR.TRANSACTION record
    rtnId = R.TRANSACTION.CONCAT<1>
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= getPorPmtFlowDets>
extractBulkFormat:
    tagTxn = '<BulkHeader>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<BulkFormat>'
    GOSUB extract
    bulkFormat= tagValue
       
RETURN
*-----------------------------------------------------------------------------
END

