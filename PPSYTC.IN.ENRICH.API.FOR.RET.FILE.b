* @ValidationCode : MjoyNDU3OTI5NDI6Q3AxMjUyOjE1ODkyMDQ4NDIwNzY6a2VlcnRoYW5hZDozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAxLjIwMTkxMjEzLTA1NDA6Nzc6NzU=
* @ValidationInfo : Timestamp         : 11 May 2020 19:17:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : keerthanad
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 75/77 (97.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.IN.ENRICH.API.FOR.RET.FILE(iIncomingMessage, ioFileData, ioBulkData,ioGenericData, oAction,oResponse)
    
    $USING PP.PaymentWorkflowGUI
    $INSERT I_PaymentWorkflowDASService_PaymentRecord
    $INSERT I_PaymentWorkflowDASService_PaymentID
    $USING PP.InwardMappingFramework
    $USING PP.PaymentWorkflowDASService
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*2/3/2020 - Enhancement 3131018/ Task 3130941 - Routine to get the companyID of the payment and map it to companyID field in file level.
*2/3/2020 - Enhancement 3131018/ Task 3137821 - Mapping of file header reference for SYSTACRJ message is handled to avoid duplicate issue.
*15/04/2020 - Enhancement 3540611/Task 3685871-Added fileGeaderReference mapping for format SYSTACDDRJ
*06/05/2020 - Task 3730032 - Inwarad cheque reject file is handled.
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB extractBulkFormat
    
    ioFileData = LOWER(ioFileData)

RETURN
*-----------------------------------------------------------------------------
initialise:

    ioFileData = RAISE(ioFileData)

RETURN
*-----------------------------------------------------------------------------
extractBulkFormat:

    tagTxn = '<BulkHeader>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<BulkFormat>'
    
    GOSUB extract
    
    messageType = tagValue
    IF tagValue EQ 'SYSTACRJ' OR tagValue EQ 'SYSTACDDRJ' OR tagValue[1,4] EQ 'SRJT' THEN
        GOSUB populateFileRef
    END
   
    GOSUB populateCompanyId
    
RETURN


*-------------------------------------------------------------------------------------
populateCompanyId:
    
    
    tagTxn = '<Transaction>'
    pos = 2
    Content = ''
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<OriginalTransactionIdentification>'
    
    GOSUB extract
    
    IF tagValue EQ 'NA' OR tagValue EQ '' THEN
        IF messageType[1,4] NE 'SRJT' THEN
            tag = '<OriginalEndtoEndIdentification>'
        END ELSE
            tag = '<OriginalEndToEndIdentification>'
        END
        GOSUB extract
        chequeNumber = tagValue
        
        IF messageType[1,4] NE 'SRJT' THEN
            tag = '<ReturnedInterbankSettlementAmount>'
        END ELSE
            tag = '<OriginalInterbankSettlementAmount>'
        END
        GOSUB extract
        txnAmt = tagValue
        
        tag = '<OriginalCreditorAccountIdentification>'
        Content = FIELD(Content,tag,pos)
        tag = '<OtherIdentification>'
        GOSUB extract
        debitAcct = tagValue
        
        tagValue = chequeNumber:'-':txnAmt:'-':debitAcct
    END
    GOSUB getPORTranConcat
    
    IF messageType[1,4] EQ 'SRJT' AND R.TRANSACTION.CONCAT<1> NE '' THEN
        oldVal = '<OriginalTransactionIdentification>NA</OriginalTransactionIdentification>'
        newValue = '<OriginalTransactionIdentification>':R.TRANSACTION.CONCAT<1>:'</OriginalTransactionIdentification>'
        CHANGE oldVal TO newValue IN iIncomingMessage
    END
    ioFileData<PP.InwardMappingFramework.FileDataObject.companyID>=R.TRANSACTION.CONCAT<1>[1,3]
    
RETURN
*-------------------------------------------------------------------------------------
extract:
    tagContent = ""
    tagValue = ""
    
    tagContent = FIELD(Content,tag,pos)
    tagValue = FIELD(tagContent,"<",1,1)
    
RETURN

*-------------------------------------------------------------------------------------
getPORTranConcat:
    
*   In this GOSUB, Process the confirmation for the payment that was sent out.
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    iOriginatingSource=ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
    IDVAL = tagValue:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
    
RETURN


*-------------------------------------------------------------------------------------

populateFileRef:

    tagTxn1 = '<FileInfo>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn1,pos)
    tag = '<UniqueReference>'
    
    GOSUB extract
    IF ioFileData<PP.InwardMappingFramework.FileDataObject.hdrFileReference> EQ '' THEN
        ioFileData<PP.InwardMappingFramework.FileDataObject.hdrFileReference> = tagValue
    END
RETURN


*-------------------------------------------------------------------------------------
END
   

