* @ValidationCode : MjotNjQ4NzQyNjQzOkNwMTI1MjoxNTM5NTg0NDEwNDAwOmtoYXJpbmk6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 15 Oct 2018 11:50:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kharini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>417</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CE.CrsReporting
SUBROUTINE CRS.LUX.MERGE.XML.SAMPLE
*-----------------------------------------------------------------------------
* Modification History :
*
* 17/07/2018 - Enhancement 2644065 / Task 2644112
*              Merge Routine written locally to merge the country specific xml records.
*
* 25/09/2018 - Defect / Task
*              To include merger functionality. 
*-----------------------------------------------------------------------------
   
    $USING EB.SystemTables
    $USING CE.CrsReporting
    $USING EB.DataAccess
    $USING CD.Config
    $USING EB.API
    $USING EB.Utility
    $USING EB.LocalReferences
    $USING CD.CustomerIdentification
     
*-----------------------------------------------------------------------------

    GOSUB Initialise
    GOSUB PROCESS

*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
    ErrorComp = ""
    crsReportingParameterrec = ""
    crsReportingParameterrec = CE.CrsReporting.CrsReportingParameter.Read(EB.SystemTables.getIdCompany(), ErrorComp)

    FnCrsXmlDir = crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpXmlDir>
    FCrsXmlDir = ''
    EB.DataAccess.Opf(FnCrsXmlDir, FCrsXmlDir)

    ErrorCrsParam = ""
    crsParameterRec = ""
    crsParameterRec = CD.Config.CrsParameter.Read(EB.SystemTables.getIdCompany(), ErrorCrsParam)

    ebTransformKeys = ''
    IF ErrorCrsParam = '' THEN
        IF crsParameterRec<CD.Config.CrsParameter.CdCpEbTransfmKey> NE '' THEN
            ebTransformKeys = crsParameterRec<CD.Config.CrsParameter.CdCpEbTransfmKey>
        END
    END
    
    countryExclusionPos = '' ; countryExclusionList = ''
    EB.LocalReferences.GetLocRef('CRS.PARAMETER','COUNTRY.EXCL',countryExclusionPos)
    
    IF countryExclusionPos NE '' THEN
        countryExclusionList = crsParameterRec<CD.Config.CrsParameter.CdCpLocalRef,countryExclusionPos>
        CHANGE @SM TO @FM IN countryExclusionList  ;* Add the country to be excluded under the CRS.PARAMETER record.
    END
    
    JulianDate = ''
    EB.API.Juldate(EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay), JulianDate)
    
    XML.IDS = ''
    THE.LIST = EB.DataAccess.DasAllIds
    EB.DataAccess.Das('CRS.XML.REQUEST', THE.LIST, THE.ARGS, '')
    
    rCrsXmlRequest = '' ; ErrorCrsXmlRequest = ''
    rCrsXmlRequest = CE.CrsReporting.CrsXmlRequest.Read(THE.LIST<1>, ErrorCrsXmlRequest)
    idToDelete = THE.LIST<1>
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    GOSUB FORMAT.HEADER
    GOSUB FRAME.OUTPUT.XML.ID
    GOSUB FORMAT.FOOTER
    GOSUB SELECT.AND.MERGE

    CE.CrsReporting.CrsXmlRequest.Delete(idToDelete) ;* Delete the CRS.XML.REQUEST record

RETURN
*-----------------------------------------------------------------------------
FORMAT.HEADER:
*-----------------------------------------------------------------------------
    xmlRecord = ''
*
    UniqueTime = ''
    EB.API.AllocateUniqueTime(UniqueTime)
    UniqueTime=FIELD(UniqueTime,'.',1):FIELD(UniqueTime,'.',2)

    IF crsParameterRec<CD.Config.CrsParameter.CdCpEin> THEN
        AEOI_RefId = 'LU':EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)[1,4]:'LU_HC_':crsParameterRec<CD.Config.CrsParameter.CdCpEin>:'_':JulianDate:UniqueTime
    END ELSE                                       ;* AEOI Reference Id by adding Luxembourg specific values
        AEOI_RefId = 'LU':EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)[1,4]:'LU_HC':'_':JulianDate:UniqueTime
    END
*
    
    UniqueTime = ''
    EB.API.AllocateUniqueTime(UniqueTime)
    UniqueTime=FIELD(UniqueTime,'.',1):FIELD(UniqueTime,'.',2)
    
    IF crsParameterRec<CD.Config.CrsParameter.CdCpEin> THEN  ;* If the EIN value is specified then append with the message reference Id.
        MessageRefId  = 'LU':EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)[1,4]:'LU_HL_':crsParameterRec<CD.Config.CrsParameter.CdCpEin>:'_':JulianDate:UniqueTime
    END ELSE
        MessageRefId  = 'LU':EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)[1,4]:'LU_HL':'_':JulianDate:UniqueTime
    END
*
    MessageTypeIndic = "CRS70":rCrsXmlRequest<CE.CrsReporting.CrsXmlRequest.CeCxReportType>[5,1]
*
    ReportingPeriod = crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpRepExtractDate>[1,4]:'-':crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpRepExtractDate>[5,2]:'-':crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpRepExtractDate>[7,2]
*
    bulkCurrDate = OCONV(DATE(),'D-')
    bulkCurrDate = bulkCurrDate['-',3,1]:bulkCurrDate['-',1,1]:bulkCurrDate['-',2,1]
    bulkCurrDate = FMT(bulkCurrDate['-',3,1]:bulkCurrDate['-',1,1]:bulkCurrDate['-',2,1],'####-##-##')
    bulkCurrTime = TIMEDATE()[1,8]
    Timestamp = bulkCurrDate:'T':bulkCurrTime
*
    xmlError = ""
    xmlRecord = '<row id=""><AEOI_RefId>':AEOI_RefId:'</AEOI_RefId><MessageRefId>': MessageRefId:'</MessageRefId><MessageTypeIndic>':MessageTypeIndic:'</MessageTypeIndic><ReportingPeriod>':ReportingPeriod:'</ReportingPeriod><Timestamp>':Timestamp:'</Timestamp></row>'
    xmlIdVal = ebTransformKeys<1,2> ;* 
    EB.API.TransformXml(xmlRecord,xmlIdVal,'',xmlError)   ;* Transformation of the header into the Xml record.
    
    xmlRecord = FIELD(xmlRecord,"</crs:CRS_OECD>",1)

RETURN
*-----------------------------------------------------------------------------
FRAME.OUTPUT.XML.ID:
*-----------------------------------------------------------------------------

    timeVal = TIMEDATE()
    dateTime = EB.SystemTables.getToday():timeVal[1,2]:timeVal[4,2]:timeVal[7,2]
    IF crsParameterRec<CD.Config.CrsParameter.CdCpEin> THEN
        finalXmlId = "CRS_":dateTime:"_":MessageTypeIndic:"_":crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpRepExtractDate>[1,4]:"_":crsParameterRec<CD.Config.CrsParameter.CdCpEin>:"_P.xml"
    END ELSE
        finalXmlId = "CRS_":dateTime:"_":MessageTypeIndic:"_":crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpRepExtractDate>[1,4]:"_P.xml"
    END
    OPENSEQ crsReportingParameterrec<CE.CrsReporting.CrsReportingParameter.CrpXmlDir>,finalXmlId TO vOutFile ELSE
        CREATE vOutFile ELSE NULL
    END

RETURN
*-----------------------------------------------------------------------------
FORMAT.FOOTER:
*-----------------------------------------------------------------------------

    payloadFooter = ''

    payloadFooter<-1> = '</crs:CRS_OECD>'
    payloadFooter<-1> = '</aeoi_lux_crs:ReportContent>'
    payloadFooter<-1> = '</aeoi_lux_crs:AEOI_CRS>'
    payloadFooter<-1> = '</aeoi_lux_crs:AEOI_LUX>'
    payloadFooter = CHANGE(payloadFooter,@FM,'')

RETURN
*-----------------------------------------------------------------------------
SELECT.AND.MERGE:
*-----------------------------------------------------------------------------

    LST.XmlMsg = '' ; LST.Country = ''
    SelectStatement = 'SELECT ':FnCrsXmlDir   
    crsXmlDirList = ''
    listName = ''
    selected = ''
    systemReturnCode = ''
    EB.DataAccess.Readlist(SelectStatement, crsXmlDirList, listName, selected, systemReturnCode)

    Ctr = 0
    LOOP
        REMOVE KEY.File FROM crsXmlDirList SETTING crsXmlDirList.MARK
    WHILE KEY.File : crsXmlDirList.MARK
        IF KEY.File[1,2] = 'LU' THEN      ;* Select the Xml Records from the directory only when the id starts with "LU"
            Ctr +=1
            EB.API.Ocomo("Processing ":Ctr:" of ":selected:" - ":KEY.File)
            
            TDY.Xml = '' ; yErr = ''
            EB.DataAccess.FRead(FnCrsXmlDir, KEY.File, TDY.Xml, FCrsXmlDir, yErr)
	
            IF TDY.Xml THEN
                IF INDEX(TDY.Xml,'<ReportingGroup/>',1) ELSE
                KEY.Customer = FIELD(KEY.File['_',1,1],"LU-",2)
                STR.ReadErr = ""
                TDY.Ccsi = CD.CustomerIdentification.CrsCustSuppInfo.Read(KEY.Customer, STR.ReadErr)
                IF NOT(STR.ReadErr) THEN
                    KEY.ReportBase = CHANGE(KEY.File['_',1,2],'_','.')
                    KEY.ReportBase = KEY.ReportBase[".",1,2]
                    TDY.ReportBase = CE.CrsReporting.CrsReportBase.Read(KEY.ReportBase, STR.ReadErr)
                    IF NOT(STR.ReadErr) THEN
                        KEY.RepCtry = TDY.ReportBase<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction,1>
                        TDY.Xml = CHANGE(TDY.Xml,'<CRS_OECD xmlns:aeoi_lux_crs="urn:lu:etat:acd:aeoi_crs:v1.0" xmlns="urn:oecd:ties:crs:v1" xmlns:cfc="urn:oecd:ties:commontypesfatcacrs:v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:stf="urn:oecd:ties:stf:v4" xmlns:ftc="urn:oecd:ties:fatca:v1" xmlns:aeoi="urn:lu:etat:acd:aeoi_lux:v2.0" version="1.0"','<CRS_OECD>')
                        TDY.Xml = CHANGE(TDY.Xml,'<?xml version="1.0" encoding="UTF-8"?>','')
                        GOSUB PARSE.XML
                    END
                END
                END
            END
            EB.DataAccess.FDelete(FnCrsXmlDir,KEY.File)
        END
    REPEAT
    
    WRITESEQ xmlRecord TO vOutFile ELSE ABORT "ERROR WRITING HEADER"
    TOT.Ctry = DCOUNT(LST.Country,@FM)
    FOR I = 1 TO TOT.Ctry
        countryExclude = ''
        LOCATE LST.Country<I> IN countryExclusionList<1> SETTING countryExclude ELSE   ;* Exclude the Country list specified in CRS.PARAMETER's COUNTRY.EXCL local reference field.
            TDY.XmlMsg =  ''
            IF INDEX(LST.XmlMsg<I>,"<ReportingGroup/>",1) THEN
                TDY.XmlMsg = LST.XmlMsg<I>:'</CrsBody>'
		    END ELSE
                TDY.XmlMsg = LST.XmlMsg<I>:'</ReportingGroup></CrsBody>'   
		    END
            
            WRITESEQ TDY.XmlMsg TO vOutFile ELSE ABORT "ERROR WRITING PAYLOAD"
        END
    NEXT I
    WRITESEQ payloadFooter TO vOutFile ELSE ABORT "ERROR WRITING FOOTER"
    CLOSESEQ vOutFile

RETURN
*-----------------------------------------------------------------------------
PARSE.XML:
*-----------------------------------------------------------------------------
    TDY.TagValue = ''
    TDY.Tag = ''
    TDY.Tag<1> = 'CRS_OECD'
    TDY.Tag<2> = 'CrsBody'
    CE.CrsReporting.CrsGetTagValue(TDY.Xml,TDY.Tag,TDY.TagValue)
    STR.CrsBodyTag1 = TDY.TagValue
    TDY.TagValue = CHANGE(TDY.TagValue,'</ReportingGroup>','')
    TDY.TagValue = CHANGE(TDY.TagValue,'</CrsBody>','')
    
    GOSUB UPDATE.XML

RETURN
*-----------------------------------------------------------------------------
UPDATE.XML:
*-----------------------------------------------------------------------------
    LOCATE KEY.RepCtry IN LST.Country<1> SETTING CtryPos THEN
        TDY.TagValue = ''
        TDY.Tag = ''
        TDY.Tag<1> = 'CrsBody'
        TDY.Tag<2> = 'ReportingGroup'
        CE.CrsReporting.CrsGetTagValue(STR.CrsBodyTag1,TDY.Tag,TDY.TagValue)   ;* Append the Account Details also.
        IF TDY.TagValue AND INDEX(TDY.TagValue,'<AccountReport>',1) THEN
            TDY.TagValue = CHANGE(TDY.TagValue,'<ReportingGroup>','')
            TDY.TagValue = CHANGE(TDY.TagValue,'</ReportingGroup>','')
            LST.XmlMsg<CtryPos> := TDY.TagValue
        END ELSE
            STR.LOG<-1> = KEY.Customer:' Missing Account Report tag'
        END
    END ELSE
        IF TDY.TagValue THEN
            LST.Country<-1> = KEY.RepCtry
            LST.XmlMsg<-1> = TDY.TagValue
        END
    END
 
RETURN
*-----------------------------------------------------------------------------
END
