* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Reports
    SUBROUTINE E.GET.DE.HANDOFF.DETS
*******************************************************************************
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*******************************************************************************
    $USING DE.Config
    $USING EB.SystemTables
    $USING EB.API
    $USING DE.Reports
    $USING EB.Reports

*
* For the passed handoff record extract the specified HEADER details
* as defined in the mapping record from the HANDOFF (R.RECORD)
* IN   O.DATA = name of field e.g "TRANS.REF"
*      O.DATA = contents
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    REQD.FIELD = EB.Reports.getOData()
*
    tmp.R.RECORD = EB.Reports.getRRecord()
    MAP.KEY = FIELD(tmp.R.RECORD,CHARX(251),1)["*",1,1]
    MAP.KEY = MAP.KEY[".",1,1]:".":FIELD(MAP.KEY,".",2,1)[1,2]:".":MAP.KEY[".",3,1]
    YR.MAPPING = DE.Config.Mapping.Read(MAP.KEY, ER)
    IF YR.MAPPING THEN
        LOCATE REQD.FIELD IN YR.MAPPING<DE.Config.Mapping.MapHeaderName,1> SETTING TXN.POS THEN
        REC.NO = YR.MAPPING<DE.Config.Mapping.MapInputPosition, TXN.POS>[".",1,1]
        FIELD.NO = YR.MAPPING<DE.Config.Mapping.MapInputPosition,TXN.POS>[".",2,3]
        INPUT.NAME = YR.MAPPING<DE.Config.Mapping.MapInputName, TXN.POS>
        GOSUB GET.INPUT.FILE        ;* BG_100013037 - S / E
        tmp.R.RECORD = EB.Reports.getRRecord()
        TEMP.REC = FIELD(tmp.R.RECORD,CHARX(251),REC.NO+1)
        IF FIELD.NO THEN
            EB.Reports.setOData(TEMP.REC<FIELD.NO>)
        END ELSE
            EB.Reports.setOData("UNABLE TO RESOLVE FIELD")
        END
    END ELSE
        EB.Reports.setOData("TXN REF NOT DEFINED IN MAPPING")
    END
*
    END ELSE
    EB.Reports.setOData("NO MAPPING RECORD")
    END
*
******************************************************************************
* BG_100013037 - S
*==============
GET.INPUT.FILE:
*==============
    IF NOT(FIELD.NO) THEN     ;* Translate name
        LOCATE REC.NO IN YR.MAPPING<DE.Config.Mapping.MapInputRecNo,1> SETTING POS THEN
        INPUT.FILE = YR.MAPPING<DE.Config.Mapping.MapInputFile, POS>
        SS.REC = ""
        EB.API.GetStandardSelectionDets(INPUT.FILE, SS.REC)
        LOCATE INPUT.NAME IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
        FIELD.NO = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, POS>
    END
    END
    END
    RETURN          ;* BG_100013037 - E
******************************************************************************
    END
