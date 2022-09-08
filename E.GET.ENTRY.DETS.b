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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.ENTRY.DETS
*-----------------------------------------------------------------------------
* MODIFICATIONS:
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AC.EntryCreation
*
* This routine will return the full entry records for the entry ids
* held in the record. Each entry field will be separated by a >
*
* O.DATA supplied Type:key
*
    ENT.TYPE = EB.Reports.getOData()[1,1]
    ENT.KEY = EB.Reports.getOData()[2,99]
*
    ENTRY.REC = ''
    BEGIN CASE
        CASE ENT.TYPE = 'A'
            ENTRY.REC = AC.EntryCreation.tableStmtEntry(ENT.KEY, ERR)
        CASE ENT.TYPE = 'R'
            ENTRY.REC = AC.EntryCreation.tableReConsolSpecEntry(ENT.KEY, ERR)
        CASE ENT.TYPE = 'P'
            ENTRY.REC = AC.EntryCreation.tableCategEntry(ENT.KEY, ERR)
        CASE 1
            EB.Reports.setOData('')
            RETURN
    END CASE
*
    OUT.DATA = CONVERT(@FM,'>', ENTRY.REC)
    EB.Reports.setOData(OUT.DATA)
*
    RETURN
*-----------------------------------------------------------------------------
    END
