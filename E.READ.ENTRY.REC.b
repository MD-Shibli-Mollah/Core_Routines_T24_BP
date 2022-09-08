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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.READ.ENTRY.REC
*
** Build the STMT, CATEG, SPEC entry record from the entry
** converts FM to >, VM to ]
*
*********************************************************************
* 07/11/02 - GLOBUS_CI_10004573
*            The Case Check for STMT.ENTRY is Changed from 'S' to 'A'
*            as the enquiry LINE.BAL.DET fatals out
*
* 19/04/06 - BG_100010679
*            Modified to work with changes to the RE.STAT.LINE.MVMT
*            file structure.
*
*********************************************************************
    $USING EB.SystemTables
    $USING EB.Reports
    $USING RE.ModelBank
    $USING EB.DataAccess
*
    tmp.O.DATA = EB.Reports.getOData()
    ENTRY.TYPE = FIELD(tmp.O.DATA, "*", 1) ; * BG_100010679
    BEGIN CASE
        CASE ENTRY.TYPE = 'R'
            YFILE = 'F.RE.CONSOL.SPEC.ENTRY'
        CASE ENTRY.TYPE = 'A'           ; * GLOBUS_CI_10004573
            YFILE = 'F.STMT.ENTRY'
        CASE ENTRY.TYPE = 'P'
            YFILE = 'F.CATEG.ENTRY'
    END CASE
*
    YFILE.VAR = ''
    EB.DataAccess.Opf(YFILE, YFILE.VAR)
*
    YID = FIELD(tmp.O.DATA, "*", 2)
    YREC = ''
    EB.DataAccess.FRead(YFILE, YID, YREC, YFILE.VAR, '')
    CONVERT @FM:@VM TO '>]' IN YREC
    EB.Reports.setOData(YREC)
*
    RETURN
    END
