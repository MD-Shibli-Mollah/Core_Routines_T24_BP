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

* Version 2 02/06/00  GLOBUS Release No. G10.2.02 29/03/00
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CONSTRUCT.ENTRY
*-----------------------------------------------------------------------------
*
** This routine will turn ENTRY.HOLD and FWD.ENTRY.HOLD records from being
** one field per entry, to multi valued fields per entry
*
* 03/08/05 CI_10033050
*          To remove the last line of Balance Details from R.RECORD for FWD.ENTRY.HOLD
*
* 14/09/06 CI_10044108
*          Add all entry fields up to and including AA.ITEM.REF
*
* 20/02/08 - CI_10053758
*            Unnecessary lines displayed while running NAU.ENTRY enquiry.
*            In the routine ENQ.BUILD.PAGE, the variable SM.COUNT is defined as the number of SM in the line refered
*            by the OPERATION defined in the ENQIURY for NAU.ENTRY.If SM.COUNT is not 1 while triggering the routine
*            E.CONSTRUCT.ENTRY,then unwanted lines are displayed.
*
*---------------------------------------------------------------------------------------------------------------
*
*
    $USING EB.Reports
    $USING AC.EntryCreation

    EB.Reports.setSmCount(1);* Reinitialised to 1 to avoid unwanted lines.
    IN.RECORD = EB.Reports.getRRecord()
    FMC = DCOUNT(IN.RECORD,@FM)
    IF EB.Reports.getFullFileName()[".",2,99] = "ENTRY.HOLD" OR EB.Reports.getFullFileName()[".",2,99] = "FWD.ENTRY.HOLD" THEN
        DEL IN.RECORD<FMC>    ;* Remove balance details
        FMC -= 1
    END
    OUT.RECORD = ""
*
    FOR YI = 1 TO FMC
        FOR FLD.ID = AC.EntryCreation.StmtEntry.SteAccountNumber TO AC.EntryCreation.StmtEntry.SteAaItemRef
            OUT.RECORD<FLD.ID,YI> = IN.RECORD<YI,FLD.ID>
        NEXT FLD.ID
    NEXT YI
*
    EB.Reports.setRRecord(OUT.RECORD)
    EB.Reports.setVmCount(FMC)
*
    RETURN
*
    END
