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

*-----------------------------------------------------------------------------
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
* Version 46 25/10/00 GLOBUS Release No. 200511 21/10/05
*
*************************************************************************
*
    $PACKAGE PM.Config
    SUBROUTINE CONV.PMD.TXN.REF.R8(PMD.ID,PMD.REC,FILE)
*
*************************************************************************
* This routine populates PM.DRILL.DOWN key only file with an @id of
* PM.DLY.POSN.CLASS.KEY ( ',',1,6) - transaction reference
***************************************************************************
* Modifications:
* =============
* 26/04/07 - CI_10048701
*            change f.write to write to avoid filling up the io cache
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*************************************************************************
*

    GOSUB INITIALISE

    GOSUB UPDATE.DRILL.DOWN

    RETURN
*
*************************************************************************
INITIALISE:
***********

    EQUATE PM.DPC.TXN.REFERENCE TO 8
    FN.PM.DRILL.DOWN = "F.PM.DRILL.DOWN"
    PMDD.ID = PMD.ID['.',1,6]
    IF PMD.ID['.',8,1] THEN   ;* booking date populated, should not happen unless re run
        PMDD.ID := ".":PMD.ID['.',8,1]
    END
    CALL OPF("F.PM.DRILL.DOWN", F.PM.DRILL.DOWN)

    RETURN

*************************************************************************
UPDATE.DRILL.DOWN:
******************

    TXN.IDS = RAISE(PMD.REC<PM.DPC.TXN.REFERENCE>)
    LOOP
        REMOVE ID FROM TXN.IDS SETTING POS
    WHILE ID:POS
        DD.ID = PMDD.ID:"-":ID
        WRITE "" ON F.PM.DRILL.DOWN, DD.ID
    REPEAT
    PMD.REC<PM.DPC.TXN.REFERENCE> = ""

    RETURN

*******************************************************************************

END
