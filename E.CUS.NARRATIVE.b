* @ValidationCode : Mjo2NTE0MTg1NTU6Q3AxMjUyOjE1NjQ5ODY1MjUzMTI6c3RhbnVzaHJlZTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMjAxOTA3MDUtMDI0NzotMTotMQ==
* @ValidationInfo : Timestamp         : 05 Aug 2019 11:58:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190705-0247
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*
$PACKAGE ST.ModelBank

SUBROUTINE E.CUS.NARRATIVE
*-----------------------------------------------------------------------------
* Modified
* 15/09/10 Defect 86775/ Task 86915
*          To display the DISPLAY.NARRATIVE field directly for the external file.
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 26/07/19 - Enhancement 3246808 / Task 3246810
*            Changes in the routine for Moving account statement components and tables from ST to Account
*
*-----------------------------------------------------------------------------

    $USING EB.API
    $USING EB.Reports
    $USING AC.StmtPrinting
*
** For the Narrative type passed down in O.DATA, this returns
** the narrative field in field 42 of R.RECORD
*
    NARR.TYPE = EB.Reports.getOData()
*
    IF NARR.TYPE THEN
        GOSUB BUILD.NARRATIVE
    END
*
RETURN
*-----------------------------------------------------------------
BUILD.NARRATIVE:
*===============
** Call EB.BUILD.NARRATIVE
*
    NARRATIVE = ""
* Display the NARRATIVE directly for the external file
    IF EB.Reports.getId()["*",10,1] EQ 'EXTERNAL' THEN
        FLD.NO = ''
        FIELD.NAME = 'DISPLAY.NARRATIVE'
        EB.API.GetStandardSelectionDets('CUSTOMER.POSITION',SS.REC)
        EB.API.FieldNamesToNumbers(FIELD.NAME, SS.REC, FLD.NO, "", "", "", FLD.TYPE, YERR)
        NARRATIVE = EB.Reports.getRRecord()<FLD.NO>
    END ELSE
        TXN.ID = EB.Reports.getId():"\":EB.Reports.getId()["*",4,1]
        AC.StmtPrinting.EbBuildNarrative(NARR.TYPE,TXN.ID,"","","",NARRATIVE)
    END
*
    tmp=EB.Reports.getRRecord(); tmp<42>=NARRATIVE; EB.Reports.setRRecord(tmp)
    EB.Reports.setVmCount(DCOUNT(NARRATIVE,@VM))
*
RETURN
*
*-----------------------------------------------------------------------------
END
