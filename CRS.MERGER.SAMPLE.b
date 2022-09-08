* @ValidationCode : MjotNDQxODA1MTM5OkNwMTI1MjoxNTM5MjM0MzM5MTI0OnZyYWphbGFrc2htaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDkuMjAxODA4MjEtMDIyNDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Oct 2018 10:35:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vrajalakshmi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201809.20180821-0224
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE CE.CrsReporting
SUBROUTINE CRS.MERGER.SAMPLE
*-----------------------------------------------------------------------------
* Modification History :
* 29-Jun-18     Job to merge all customer specific XMLs into a single consolidated
*               XML.
*-----------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.API
    $USING CE.CrsReporting
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    R.CRS.REPORTING.PARAMETER = ''
    CRS.REPORTING.PARAMETER.ID = EB.SystemTables.getIdCompany()
    R.CRS.REPORTING.PARAMETER = CE.CrsReporting.CrsReportingParameter.Read(CRS.REPORTING.PARAMETER.ID, YERR)

    FN.CRS.XML.DIR = R.CRS.REPORTING.PARAMETER<CE.CrsReporting.CrsReportingParameter.CrpXmlDir>
    F.CRS.XML.DIR = ''
    EB.DataAccess.Opf(FN.CRS.XML.DIR,F.CRS.XML.DIR)

    XML.IDS = ''

RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    GOSUB FRAME.OUTPUT.XML.ID
    GOSUB FORMAT.FOOTER
    GOSUB SELECT.AND.MERGE

RETURN

*-----------------------------------------------------------------------------
FRAME.OUTPUT.XML.ID:
*-----------------------------------------------------------------------------
    EB.SystemTables.setTimeStamp(TIMEDATE())
    TIME.VAL = EB.SystemTables.getTimeStamp()
    TODAY.DATE = EB.SystemTables.getToday()
    DATE.TIME = TODAY.DATE:TIME.VAL[1,2]:TIME.VAL[4,2]:TIME.VAL[7,2]
    FINAL.XML.ID = "CRS_":DATE.TIME:"_P.xml"

RETURN
*-----------------------------------------------------------------------------
FORMAT.FOOTER:
*-----------------------------------------------------------------------------
    PAYLOAD.FOOTER = ''
    PAYLOAD.FOOTER<-1> = '</crs:ReportingGroup>'
    PAYLOAD.FOOTER<-1> = '</crs:CrsBody>'
    PAYLOAD.FOOTER<-1> = '</crs:CRS_OECD>'
    PAYLOAD.FOOTER = CHANGE(PAYLOAD.FOOTER,@FM,'')

RETURN
*-----------------------------------------------------------------------------
SELECT.AND.MERGE:
*-----------------------------------------------------------------------------

    LST.XmlMsg = '' ; LST.Country = ''
    SELECT.STATEMENT = 'SELECT ':FN.CRS.XML.DIR
    CRS.XML.DIR.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''

    EB.DataAccess.Readlist(SELECT.STATEMENT,CRS.XML.DIR.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

    OPENSEQ R.CRS.REPORTING.PARAMETER<CE.CrsReporting.CrsReportingParameter.CrpXmlDir>,FINAL.XML.ID TO V.OUT.FILE ELSE
        CREATE V.OUT.FILE ELSE NULL
    END

    CTR = 0
    LOOP
        REMOVE KEY.File FROM CRS.XML.DIR.LIST SETTING CRS.XML.DIR.LIST.MARK
    WHILE KEY.File : CRS.XML.DIR.LIST.MARK
        CTR +=1
        EB.API.Ocomo("Processing ":CTR:" of ":SELECTED:" - ":KEY.File)

        TDY.Xml = '' ; YERR = ''
        EB.DataAccess.FRead(FN.CRS.XML.DIR,KEY.File,TDY.Xml,F.CRS.XML.DIR,YERR)

        IF TDY.Xml THEN
            IF CTR = 1 THEN
                IF INDEX(TDY.Xml,'<crs:ReportingGroup>',1) THEN
                    HEADER.VALU = FIELD(TDY.Xml,'<crs:ReportingGroup>',1)
                END ELSE
                    HEADER.VALU = FIELD(TDY.Xml,'<crs:ReportingGroup/>',1)
                END
                PAYLOAD.HEADER = HEADER.VALU:'':"<crs:ReportingGroup>"
                WRITESEQ PAYLOAD.HEADER TO V.OUT.FILE ELSE ABORT "ERROR WRITING HEADER"
            END
            IF KEY.File[1,3] = 'RJ-' THEN
                GOSUB PARSE.XML
                EB.DataAccess.FDelete(FN.CRS.XML.DIR,KEY.File)
            END
        END
    REPEAT
    IF PAYLOAD.HEADER NE '' THEN
        WRITESEQ PAYLOAD.FOOTER TO V.OUT.FILE ELSE ABORT "ERROR WRITING FOOTER"
    END
    CLOSESEQ V.OUT.FILE

RETURN
*-----------------------------------------------------------------------------
PARSE.XML:
*-----------------------------------------------------------------------------

    IF NOT(INDEX(TDY.Xml,"<crs:ReportingGroup/>",1)) AND INDEX(TDY.Xml,"<crs:AccountReport>",1) THEN
        PAYLOAD.CUST = FIELD(TDY.Xml,'<crs:ReportingGroup>',2)
        PAYLOAD.CUST = FIELD(PAYLOAD.CUST,'</crs:ReportingGroup>',1)
        WRITESEQ PAYLOAD.CUST TO V.OUT.FILE ELSE ABORT "ERROR WRITING HEADER"
    END

RETURN

END
