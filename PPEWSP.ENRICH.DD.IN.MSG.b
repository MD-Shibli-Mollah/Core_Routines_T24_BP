* @ValidationCode : MjotMzQ3NjIzMzM2OkNwMTI1MjoxNjAyNTczODAxMTIzOnNrYXlhbHZpemhpOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTktMDQ1OTo4Nzo4MA==
* @ValidationInfo : Timestamp         : 13 Oct 2020 12:53:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 80/87 (91.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPEWSP.Foundation
SUBROUTINE PPEWSP.ENRICH.DD.IN.MSG(iIncomingMessage, ioFileData, ioBulkData,ioGenericData, oAction,oResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

    $USING PP.LocalClearingService
    $USING PP.InwardMappingFramework
    $USING EB.SystemTables
    $USING PP.PaymentFrameworkService
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB mapRejectMsg
    
    ioFileData = LOWER(ioFileData)

RETURN
*-----------------------------------------------------------------------------
initialise:

    ioFileData = RAISE(ioFileData)

RETURN
*-----------------------------------------------------------------------------
mapRejectMsg:
    
    tagTxn = '<FileHeader>'
    pos = 2
    Content = ''
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<FileHeaderReceivingInstitution>'
    GOSUB extract
    ReceivingBic= tagValue

    tagTxn = '<BulkHeader>'
    pos = 2
    Content = ''
    
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<StatusReasonInformationOriginator>'
    
    GOSUB extract
    
    tag = '<BICOrBEI>'
    GOSUB extract
    originatorBic = tagValue
    tag = '<BulkClearingStatusReportOriginalBulkFormat>'
    GOSUB extract
    orgMsgId = tagValue
    
    tag = '<BulkAmountCurrency>'
    GOSUB extract
    bulkCcy= tagValue
    
    tag = '<BulkInstructingAgentFinancialInstitutionIdentificationBICFI>'
    GOSUB extract
    bulkOriginatorBic= tagValue
    
    GOSUB populateCompanyId
    GOSUB getClearing
    IF ((originatorBic NE '' AND originatorBic NE clearingBic) OR (bulkOriginatorBic NE '' AND bulkOriginatorBic NE clearingBic)) AND (orgMsgId EQ 'pacs.003' OR orgMsgId EQ 'pacs.003.001.02') THEN
        ioFileData<PP.InwardMappingFramework.FileDataObject.hdrFileType> = "DNF"
    END
    
RETURN


*-------------------------------------------------------------------------------------
populateCompanyId:
    
    R.TRANSACTION.CONCAT = ''
    tagTxn = '<Transaction>'
    pos = 2
    Content = ''
    Content = FIELD(iIncomingMessage,tagTxn,pos)
    tag = '<OriginalTransactionIdentification>'
    
    GOSUB extract
    
    GOSUB getPORTranConcat

    IF R.TRANSACTION.CONCAT<1> NE '' THEN
        oldVal = '<OriginalTransactionIdentification>NA</OriginalTransactionIdentification>'
        newValue = '<OriginalTransactionIdentification>':R.TRANSACTION.CONCAT<1>:'</OriginalTransactionIdentification>'
        CHANGE oldVal TO newValue IN iIncomingMessage
    END
    IF iFTNumber[1,3] NE '' THEN
        ioFileData<PP.InwardMappingFramework.FileDataObject.companyID>=iFTNumber[1,3]
    END ELSE
        iFileBulkDets<PP.InwardMappingFramework.FileBulkDets.hdrReceivingInst> = ReceivingBic
        PP.InwardMappingFramework.determineCompanyId(iFileBulkDets,oCompanyId,oCompanyResponse)
        ioFileData<PP.InwardMappingFramework.FileDataObject.companyID> = oCompanyId
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
getClearing:
    
*   In this GOSUB, Process the confirmation for the paynt that was sent out.
    iClrRequest = ''
    oClrDetails = ''
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = ioFileData<PP.InwardMappingFramework.FileDataObject.companyID>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = bulkCcy
    
    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
    IF oClrError EQ '' THEN
        clearingBic = oClrDetails<PP.LocalClearingService.ClrDetails.clearingBIC>
    END
    
RETURN
*-------------------------------------------------------------------------------------
getPORTranConcat:
    
*   In this GOSUB, Process the confirmation for the payment that was sent out.
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    iOriginatingSource=ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
    IDVAL = tagValue:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
    BEGIN CASE
        CASE R.TRANSACTION.CONCAT<2> NE ""
            iFTNumber = R.TRANSACTION.CONCAT<2> ;* if POR.TRANSACTION.CONCAT is having multiple records with same SendersReferenceIncoming and OriginatingSource
        CASE R.TRANSACTION.CONCAT<1> NE ""
            iFTNumber = R.TRANSACTION.CONCAT<1> ;* if POR.TRANSACTION.CONCAT is having  record with same SendersReferenceIncoming and OriginatingSource
        CASE 1
            iFTNumber = tagValue
    END CASE
    
RETURN
*-------------------------------------------------------------------------------------

END
