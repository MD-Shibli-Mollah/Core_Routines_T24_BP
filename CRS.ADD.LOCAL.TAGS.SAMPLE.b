* @ValidationCode : MjotMTI1NTg5MDExNjpjcDEyNTI6MTYxODkwNDY1NTM2ODprcmFtYXNocmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Apr 2021 13:14:15
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE CE.CrsReporting
SUBROUTINE CRS.ADD.LOCAL.TAGS.SAMPLE(CRS.REPORT.BASE.ID,ACTION,R.CRS.REPORT.BASE,SPARE.1,SPARE.2,SPARE.3)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/04/21 - Defect 3752077 / Task 4345287
*            New api to update local tags & values in CRS Report base
*-----------------------------------------------------------------------------
    $USING CE.CrsReporting
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.LocalReferences
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    
    CUSTOMER.ID = FIELD(CRS.REPORT.BASE.ID,'.',1)
    IF ACTION EQ 'NEW' AND NUM(CUSTOMER.ID) THEN    ;* skip if nil report
        GOSUB INITIALISE
        GOSUB UPDATE.CRS.REPORT.BASE
    END

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    TABLE.NAME = 'CUSTOMER'
    LOCAL.FIELD.NAME = 'MIDDLE.NAME'
    
    LOCAL.REF.POS = ''
    SS.REC = ''
    EB.API.GetStandardSelectionDets(TABLE.NAME, SS.REC)
    LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
        LOCAL.REF.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
    END
    
    R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbLocalTag> = ''
    R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbLocalValue> = ''
    
RETURN
*-----------------------------------------------------------------------------
UPDATE.CRS.REPORT.BASE:

    FN.TABLE.NAME = 'F.':TABLE.NAME
    FV.TABLE.NAME = ''
    R.REC = ''
    READ.ERR = ''
    EB.DataAccess.Opf(FN.TABLE.NAME, FV.TABLE.NAME)
    EB.DataAccess.FRead(FN.TABLE.NAME, CUSTOMER.ID, R.REC, FV.TABLE.NAME, READ.ERR)
    
    EB.LocalReferences.GetLocRef(TABLE.NAME, LOCAL.FIELD.NAME, LOC.POS)
    R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbLocalTag,-1> = 'MiddleName'
    R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbLocalValue,-1> = R.REC<LOCAL.REF.POS,LOC.POS>
    
RETURN
*-----------------------------------------------------------------------------
END

