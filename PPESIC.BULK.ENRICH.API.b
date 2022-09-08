* @ValidationCode : Mjo0OTk1NDcxNjM6Q3AxMjUyOjE2MTA5NzU5Mjc3MDc6bXIuc3VyeWFpbmFtZGFyOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMTo3Nzo2MA==
* @ValidationInfo : Timestamp         : 18 Jan 2021 18:48:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 60/77 (77.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPESIC.Foundation
SUBROUTINE PPESIC.BULK.ENRICH.API(ioIncomingMessage,ioFileData,ioBulkData,ioGenericData,oAction,oResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*30/11/2020 - Enhancement 3777154 / Task 4043972 - API added as a part of EUROSIC Clearing.
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.InwardMappingFramework
    $USING PP.MessageAcceptanceService
    $USING EB.DataAccess
    $INSERT I_DAS.EB.QUERIES.ANSWERS
    $USING DE.Messaging
    $USING EB.SystemTables
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    
    GOSUB initialise ; *
    GOSUB EnrichDetails ; *
    GOSUB loadCompany ; *
    GOSUB mapOutput ; *
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>

    CONVERT @VM TO @FM IN ioFileData
    CONVERT @VM TO @FM IN ioBulkData
    
    iConcatId = ''
    oConcatRecord = ''
    oPaymentOrder = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    tableName = ''
    theList = ''
    theArgs = ''
    ebqaID = ''
    ebqaRec = ''
    READ.ER = ''
    relRef = ''
    replacerelRef = ''
    oError =''
    oReadErr = ''
    porRelRef = ''
    
    iCompanyCode = EB.SystemTables.getIdCompany()
    oCompanyID = ""
    oGetCompError = ""
    PP.PaymentFrameworkService.getCompany(iCompanyCode, oCompanyID, oGetCompError)
    NEW.ID.COMPANY = ''
    companyID = ''
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= loadCompany>
loadCompany:
*** <desc> </desc>
   
    companyID = ioFileData<PP.InwardMappingFramework.FileDataObject.companyID>

* Determined company is loaded irrespective of the Current company
    IF (oCompanyID NE companyID) AND companyID NE '' THEN
        NEW.ID.COMPANY = companyID
        CALL LOAD.COMPANY(NEW.ID.COMPANY)
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= EnrichDetails>
EnrichDetails:
*** <desc> </desc>
    

* We have to enrich original bulk format with EBQA Reject msg type
* For that, we need to fetch the EBQA id from original bulk reference of inward camt.025 and match it with sent reference in EBQA
* So EBQA das is used to fetch the EBQA id by matching the OriginalBulkReference present in Orig.Msg.Ref in EBQA table
   
    IF ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportOrglFormat> EQ 'camt.029' THEN
        IDVAL = ''
        ERR.CONCAT = ''
        R.TRANSACTION.CONCAT = ''
        IDVAL = ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportOrglRef>:'-':ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
*     CALL TPSLogging("Input Parameter","Bulk Enrich Api IDVAL","IDVAL:<":IDVAL:">","")
        PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
        relRef = R.TRANSACTION.CONCAT<1>
*     CALL TPSLogging("Input Parameter","Bulk Enrich Api RelRef","relRef:<":relRef:">","")
    END

    IF ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportOrglFormat> MATCHES 'camt.056':@VM:'camt.027':@VM:'camt.087' THEN
        relRef = FIELD(ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportOrglRef>,'-',2)
    END
* Once the status is updated, making the group status as PART since it has to be processed as transaction level(T) which will be impacted in determineActionType

    PP.PaymentWorkflowDASService.getPaymentRecord(relRef,oPaymentOrder,oAdditionalPaymentRecord,oReadErr)
    IF ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportOrglFormat> EQ 'camt.056' THEN
        porRelRef =  oAdditionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.bulkReferenceOutgoing>
        IF porRelRef EQ ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportOrglRef> ELSE
            relRef = ''
        END
    END
    IF oReadErr THEN
        iConcatId = relRef:'-':ioFileData<PP.InwardMappingFramework.FileDataObject.originatingChannel>
        PP.InwardMappingFramework.getPORTransactionConcat(iConcatId, oConcatRecord, oError)
        IF oError ='' THEN
            oReadErr = ''
            PP.PaymentWorkflowDASService.getPaymentRecord(oConcatRecord<1>,oPaymentOrder,oAdditionalPaymentRecord,oReadErr)
            IF oReadErr = '' THEN
                ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCompanyId>=oConcatRecord<1>[1,3]
                ioFileData<PP.InwardMappingFramework.FileDataObject.companyID> = oConcatRecord<1>[1,3]
            END
        END
    END ELSE
        ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCompanyId>=relRef[1,3]
        ioFileData<PP.InwardMappingFramework.FileDataObject.companyID> = relRef[1,3]
    END
    
* RelRef is made as original transaction identification. As the inward file does not have any reference, xslt level its hardcoded with .
* In acceptance level, . is replaced with RelRef as below

    ioBulkData<PP.InwardMappingFramework.BulkDataObject.bulkCgStsReportGroupStatus>='PART'
    replacerelRef='<OriginalTransactionIdentification>':relRef:'</OriginalTransactionIdentification>'
    ioIncomingMessage=EREPLACE(ioIncomingMessage,'<OriginalTransactionIdentification>.</OriginalTransactionIdentification>',replacerelRef)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= mapOutput>
mapOutput:
*** <desc> </desc>

    CONVERT @FM TO @VM IN ioFileData
    CONVERT @FM TO @VM IN ioBulkData
RETURN

*** </region>

END
*-----------------------------------------------------------------------------

