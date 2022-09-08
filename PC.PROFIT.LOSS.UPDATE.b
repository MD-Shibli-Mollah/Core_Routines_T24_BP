* @ValidationCode : MToxMjgyMjQxNTIxOmNwMTI1MjoxNDcxNjA0NjQ5NTY1OmRpdnlhbGFrc2htaXY6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDguMA==
* @ValidationInfo : Timestamp         : 19 Aug 2016 16:34:09
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : divyalakshmiv
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------------- 
* <Rating>-120</Rating>
*-----------------------------------------------------------------------------
* Version 5 06/06/01  GLOBUS Release No. 200507 03/06/05

    $PACKAGE PC.Contract
    SUBROUTINE PC.PROFIT.LOSS.UPDATE(ID)

* Arguments  1. ID : (Id of the file PC.CATEG.ADJUSTMENT)

* Routine is called from PC.UPDATE.REQUEST.RUN , presumably with the
* common C$PC.CLOSING.DATE already set.

* This routine will apply Post Closing movements to profit-loss in the
* Post Closing database/s . May be run online(dry-run) or in EOD

* Individual entries will be flagged as being posted to the PC data-
* base , once they have been successfully updated. This will prevent
* the same entry being duplicated in the PC Database
* The flag mentioned will be stored on the CATEG entry record

* Based on the routine : EOD.RE.PROFIT.LOSS

* 08/05/2002 - GLOBUS_EN_10000658
*              If Accounting Date is specified in BUILD.PL.ENTRIES
*              of MI.PARAMETER, CATEG.PC.MONTH will be built to identify
*              CATEG.ENTRIES with a PC.PERIOD.END of the month specified
* 12/06/2002 - GLOBUS_BG_100001370
*              Bug Fix for correct updation of CATEG.PC.MONTH
* 03/09/2002 - GLOBUS_CI_10003456
*              While verifying PC.UPDATE.REQUEST the error TXN.REF - vari
*              able undefined is fixed.
* 21/09/02 - EN_10001196
*            Conversion of error messages to error codes.
* 22/11/02 - CI_10004844
*          - Included the insert of STANDARD.SELECTION & DAO
*06/01/2003 - EN_10001563
*             I_RE.INIT.CON insert routine is made obsolete
*             modifications are done to make a call to
*             RE.INIT.CON
*
* 06/02/03 - BG_100003394
*  Included I_F.DEALER.DESK.
*
* 20/02/03 - GLOBUS_BG_100003483
*            Converted '$' to '_' in routine name.
*
* 09/04/03 - BG_100004009
*            Bug Fix - OPF to be done only if 'MI' is installed
*
* 04/06/03 - GLOBUS_BG_100004358
*            Conversion "$" & "_"  to "."  in routine name.
*            (overwrite/ignore the previous conversion of  "$" to "_").
*            This is to ensure that routines will compile and work in
*            jBASE 4.1 and on non ASCII platforms.
*
*14/05/04  - CI_10019860/CI_10019847
*            While verifying, PC.UPDATE.REQUEST hangs due to record locking.
*            MATREADU  changed to MATREAD to avoid the same.
*
*24/05/2004 -CI_10020104/CI_10020056
*            YR.CAT.ENT earlier dimensioned as 70 now replaced with
*            C$SYSDIM
*
* 05/01/05 - CI_10025952
*            Cross compilation for changes in I_GOSUB.RE.GEN.PL.KEY
*            related to SL with DC.
*
* 24/06/05 - EN_10002593
*            Now the argument of this routine is Id of the file
*            PC.CATEG.ADJUSTMENT (instead of PERIOD.END). This should read CATEG.ENTRRY
*            with the incoming Id and do the usual processing.  The load and select
*            portion have been moved to PC.PROFIT.LOSS.UPDATE.LOAD
*            & PC.PROFIT.LOSS.UPDATE.SELECT respectively.
*            Ref: SAR-2005-05-06-0014
*
* 29/07/05 - BG_100009139
*            Change in the way PC.CATEG.ACCOUNTING is called.
*
* 20/08/06 - EN_10003043 / REF:SAR-2006-05-30-0001
*            Remove the reference of RE.OLD.CONSOL.KEY
**
* 3/6/09  - CI_10063375
*           Inputting  CONSOLIDATE.COND applications PROFIT&LOSS record when we specify the CRF
*           key contains CUSTOMER application @ID then we inputting the fields CONSOL.ON.FILE,
*           CONSOL.ON.FIELD and CONSOL.START An error message "Array subscript out of range" is produced.
*           CROSS COMPILATION   I_GOSUB.RE.GEN.PL.KEY
*
* 13/01/10 - RTC WI 13371
*            No need for assigning the consol key back to the entry.
*
* 30/05/11 - Task 217660
*            The filtering condition(to check whether the CATEG Records belong to current company or not)
*            has been moved from .SELECT routine to .RECORD routine to improve performance
*
* 16/11/11 - Defect - 296676 / Task - 306731
*            Moved the job PC.PROFIT.LOSS.UPDATE to FIN level from FRP level.
*
* 17/06/16 - Enhancement 1705374 / Task 1731026
*            Update Data Framework tables when Post closing is run when FIN.DETAILS.REQ field is in 
*            Account Parameter
*-------------------------------------------------------------------------------------


    $USING AC.EntryCreation
    $USING EB.Utility
    $USING PC.Contract
    $USING MI.Entries
    $USING ST.CompanyCreation
    $USING MI.Reports
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING PC.IFConfig


    GOSUB INITIALISE
    GOSUB START.THE.UPDATE

    RETURN
*-----------------------------------------------------------------------
INITIALISE:
*---------

    FIRST.PC.PERIOD.END = ''
    PC.Contract.clearYrCatEnt()

    RETURN
*-----------------------------------------------------------------------
START.THE.UPDATE:

* Process one entry at a time and process all databases that this entry
* will hit in the PC database within the DBASE loop. There may be more
* than just one !
* eg. entry 123456789.0001 affects periods 20000131,20000228

*     process this entry  in the PC database for both these open periods
* by opening the relevant PC files with appropriate suffix
*     eg. F.<filename>.PC20000131 and F.<filename>.PC20000228

* The OPF routine should do this if we pass the correct value in
* C$PC.CLOSING.DATE

* Start with the categ entry

    CAT.ADJ.LOOP = ID

    CATEGORY.LOC = TRIM(FIELD(CAT.ADJ.LOOP,'-',1))
    YID.CAT.ENT = TRIM(FIELD(CAT.ADJ.LOOP,'-',3))
    YID.CAT.MTH = CATEGORY.LOC:'.':PC.Contract.getYearMth()
    GOSUB GET.CATEG.REC

* Loop on the periods affected by this entry, but only apply updates
* to periods up to and including the requested period . In theory ,
* this period should always be < R.DATES(EB.DAT.PERIOD.END)

    FOR DBASE.LOOP = 1 TO DBASE.CNT     ;* no of open periods
        DBASE.ID = DBASE.ARRAY<1,DBASE.LOOP>
        IF DBASE.ID LE EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd) THEN      ;* GB0001559
            IF PC.Contract.getYrCatEnt(AC.EntryCreation.CategEntry.CatPcApplied)<1,DBASE.LOOP> NE 'Y' THEN

                EB.SystemTables.setCPcClosingDate(DBASE.ID)

                GOSUB OPEN.RELEVANT.FILES
                GOSUB DO.UPDATE
                *
            END
        END ELSE
            EXIT    ;* dBASE cannot exist yet
        END
    NEXT DBASE.LOOP

    EB.SystemTables.setCPcClosingDate(PC.Contract.getPeriodEnd())

    RETURN

*--------------------------------------------------------------

GET.CATEG.REC:


    PC.Contract.clearYrCatEnt()
    YR.CAT.ENT.DYN = AC.EntryCreation.CategEntry.Read(YID.CAT.ENT, ER)
    PC.Contract.setDynArrayToYrCatEnt(YR.CAT.ENT.DYN)
    IF ER NE '' THEN
        EB.SystemTables.setE('PC.RTN.CATEG.ENTRY.MISS.':@FM:YID.CAT.ENT)
        GOSUB FATAL.ERROR
    END

    DBASE.ARRAY = ''
    DBASE.ARRAY = PC.Contract.getYrCatEnt(AC.EntryCreation.CategEntry.CatPcPeriodEnd)
    DBASE.CNT = DCOUNT(DBASE.ARRAY,@VM)

    RETURN

*-------------------------------------------------------------

DO.UPDATE:

    GOSUB PROCESS.CATEG.ENTRY

* Finished with categ entry for first open period here
* Get another affected period if there is one from DBASE.ARRAY and
* apply the same posting to that database as well

    RETURN

*-------------------------------------------------------------

PROCESS.CATEG.ENTRY:

* This section applies to a particular categ entry
* Note----We have already read the categ entry at this point, so we
* can just carry on with processing required for the entry

    PC.Contract.setYidCatEntry(YID.CAT.ENT);* I_GOSUB.RE.GEN.PL.KEY in PC.CATEG.ACCOUNTING might need this
    CATEG.STMT = ''
    CATEG.STMT = PC.Contract.getDynArrayFromYrCatEnt()
    CATEG.STMT = LOWER(CATEG.STMT)
    PC.Contract.CategAccounting(CATEG.STMT)          ;* to update the 'CONSOLIDATION.PRFT.LOSS.PCXXX file

* Stamp the key back on the entry
    tmp=PC.Contract.getYrCatEnt(AC.EntryCreation.CategEntry.CatPcApplied); tmp<1,DBASE.LOOP>='Y'; PC.Contract.setYrCatEnt(AC.EntryCreation.CategEntry.CatPcApplied, tmp)

    GOSUB UPDATE.DF.FINANCIAL.DETAILS
    YR.CAT.ENT.DYN = PC.Contract.getDynArrayFromYrCatEnt()
    AC.EntryCreation.CategEntryWrite(YID.CAT.ENT, YR.CAT.ENT.DYN,'')
*
* Check whether MI is installed for the company.
* and  BUILD.PL.ENTRIES  is set to  ACCOUNTING in MI.PARAMETER.
*
    LOCATE "MI" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POS THEN
    MI.PARAMETER.REC = MI.Entries.Parameter.Read("SYSTEM", ER)
    BUILD.PL.ENTRIES = MI.PARAMETER.REC<MI.Entries.Parameter.ParamBuildPlEntries>
    IF BUILD.PL.ENTRIES ='ACCOUNTING' THEN
        * Pick the first PC.PERIOD.END date from CATEG.ENTRY record.
        FIRST.PC.PERIOD.END = PC.Contract.getYrCatEnt(AC.EntryCreation.CategEntry.CatPcPeriodEnd)<1,1>[1,6]
        *
        * Read the CATEG.PC.MONTH file and check if this PC.PERIOD.END exists
        * If found, check for the CATEG.ENTRY id under this PC.PERIOD.END,
        * if not found write this CATEG.ENTRY.ID into the file for this PC.PERIOD.END.
        *
        R.CATEG.PC.MONTH = MI.Reports.CategPcMonth.Read(FIRST.PC.PERIOD.END, ER)
        IF NOT(R.CATEG.PC.MONTH) THEN
            R.CATEG.PC.MONTH<-1> = YID.CAT.ENT
        END ELSE
            * If there is PC.PERIOD.END  but no  CATEG.ENTRY.ID then write the CATEG.ENTRY.ID
            LOCATE YID.CAT.ENT IN R.CATEG.PC.MONTH<1,1> BY 'AR' SETTING POS1 ELSE
            R.CATEG.PC.MONTH<-1> = YID.CAT.ENT
        END
    END
    MI.Reports.CategPcMonthWrite(FIRST.PC.PERIOD.END, R.CATEG.PC.MONTH,'')

    END
    END

    RETURN
*-------------------------------------------------------------
OPEN.RELEVANT.FILES:
*------------------
    IF EB.SystemTables.getCPcClosingDate() <> PC.Contract.getCPcClosingDatePrevCateg()  THEN        ;* only if doing for diff PC.CLOSING.DATES
        PC.Contract.setCPcClosingDatePrevCateg(EB.SystemTables.getCPcClosingDate());* diff from the last date
        PC.Contract.ProfitLossUpdateLoad() ;* open the correct PC files
    END

    RETURN
*--------------------------------------------------------------
FATAL.ERROR:

    EB.SystemTables.setText(EB.SystemTables.getE()); EB.ErrorProcessing.FatalError ("PC.PROFIT.LOSS.UPDATE")

    RETURN

*-----------------------------------------------------
UPDATE.DF.FINANCIAL.DETAILS:
** Updates the DF tables - FinancialDetailsPostClosing for the entries 
    EntryType = 'C'     ;* entry type is always C
    EntryId = YID.CAT.ENT
    EntryRec = CATEG.STMT       ;* get the entry record and Id, CATEG.STMT is already lowered and hence passed as it is
    EntryFlag = 'CATEG'     ;* pass the flag as CATEG to update financial details post closing

    PC.IFConfig.DzEntryFinDetPostClose(EntryType, EntryId, EntryRec, EntryFlag, '', '')

    RETURN
*-----------------------------------------------------
    END
