* @ValidationCode : MjoxNDEyNzk2MjM2OkNwMTI1MjoxNDg4MjU2Njg1NzcwOmFyY2hhbmFyYWdoYXZpOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6Mjc0OjE2Nw==
* @ValidationInfo : Timestamp         : 28 Feb 2017 10:08:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaraghavi
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 167/274 (60.9%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 7 07/06/01  GLOBUS Release No. 200507 03/06/05
*-----------------------------------------------------------------------------
* <Rating>202</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PC.Contract
    SUBROUTINE PC.ACCT.ACTIVITY(ID)

* Arguments : 1. ID of the file PC.STMT.ADJUSTMENT
*
* Entries in STMT.ENTRY will be flagged as posted , per period to
* prevent the same entry being applied to the PC database again

* This routine will apply Post Closing movements to accounts in the
* Post Closing database/s . May be run online(dry-run) or in EOD
* Based on the standard routine : EOD.ACCT.ACTIVITY

* 18/09/01 - GB0100350
*            Fatal Error in Job EOD.RE.SUSP.HOLD - INVALID
*            APPLICATION (RE.UPDATE.LINK.FILE).

*-----------------------------------------------------------------*
*
* Modifications:
* --------------
*
* 25/09/00 - GB0002268
*            Rewrite this program to just raise consol entries
*            and update position.
*            Also set to 'B'atch mode temporary to effect the
*            Position update immediately.
*            The rest should be done at normal EOD batch.
*
* 02/10/01 - EN_10000056
*            Phase II of non utilisation fee in limits
*
* 08/05/2002 - GLOBUS_EN_10000658
*              1) Updates daily balances in BOOK.DATED.BALANCE file if
*              BUILD.BD.BALANCES on MI.PARAMETER is set to 'Yes'
*              2) YR.ENTRY earlier dimensioned as 79 now replaced with
*              C$SYSDIM
*
* 21/09/02 - EN_10001196
*            Conversion of error messages to error codes.
* 22/11/02 - CI_10004844
*          - Included the insert of STANDARD.SELECTION & DAO
*06/01/2003 - EN_10001563
*             I_RE.INIT.CON insert routine is made obsolete
*             modifications are done to make a call to
*             RE.INIT.CON
*
* 20/02/03 - GLOBUS_BG_100003483
*            Converted '$' to '_' in routine name.
*
* 07/04/03 - GLOBUS_EN_10001655
*            Value/trade date now by product and category range
*
* 04/06/03 - GLOBUS_BG_100004358
*            Conversion "$" & "_"  to "."  in routine name.
*            (overwrite/ignore the previous conversion of  "$" to "_").
*            This is to ensure that routines will compile and work in
*            jBASE 4.1 and on non ASCII platforms.
*
* 26/02/04 - BG_10006339
*            Set RUNNING.UNDER.BATCH rather than OP.MODE to force updates
*
* 24/05/04 - CI_10020077
*            Locking of Account record during PC.UPDATE.REQUEST is fixed.
*
* 24/06/05 - EN_10002593
*            Now the argument of this routine is Id of the file PC.STMT.ADJUSTMENT
*            (instead of PERIOD.END) should read STMT.ENTRY with the incoming Id and
*            do the usual processing. The load and select portion have been moved to
*            PC.ACCT.ACTIVITY.LOAD & PC.ACCT.ACTIVITY.SELECT respectively.
*            Ref: SAR-2005-05-06-0014
*
* 15/05/06 - EN_10002924
*            Use core routine and set the flag ENT.TODAY.UPDATE in
*            in ACCOUNT.PARAMETER to get OPEN.ACTUAL.BAL and OPEN.CLEARED.BAL
*            to avoid the usage of OPEN balances fields in ACCOUNT application
*            and hence allow removal of ACCT.ENT.TODAY .
*
* 10/06/08 - CI_10055968
*            Check made to update the correct asset type for contingent accounts.
*
* 24/11/09 - BG_100025885
*            Code for Multiple currency markets, asset type determination & Consol key
*            generation removed.
*
* 26/03/2011 - DEFECT 177467 / TASK 179443
*              1. Skip the position account entry.
*              2. Pass the value date, if value dated entry, to update POSITION
*
* 09/05/11 - Task 205595 / Defect 204164
*            Process the entries which belongs to the current loaded company. Earlier it was
*            done in PC.ACCT.ACTIVITY.SELECT Moved the logic to record routine to improve performance.
*
* 19/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 16/11/11 - Defect - 296676 / Task - 306731
*            Moved the job PC.ACCT.ACTIVITY to FIN level from FRP level.
*
* 03/09/2012 - DEFECT 460654 / TASK 970085
*              When POSITION.ENTRY is set as ACCOUNT , then for PC
*              No need to update POSITION file for position accounts
*
* 06/08/15 - Defect - 1415236 / Task - 1430799
*            PC transaction was updating to wrong asset type in CONSOL key
*            Instead of getting the balance of account for last working day of pc.period date
*            pc.period date balance is taken for deciding the correct asset type.
*
* 08/12/15 - Defect 1538440 / Task 1546458
*            System functions properly when it tries to process the first PC adjustment entry whose
*            corresponding account record is closed in the current LIVE environment.
*
* 17/06/16 - Enhancement 1705373 / Task 1731024
*            Update Data Framework tables when Post closing is run when FIN.DETAILS.REQ field is in
*            Account Parameter
*
* 27/02/17 - Defect 1999010 / Task 2033170
*            Account ID variable re-initialised after read from history since it
*            appends the current number of the record to the ID
*
*------------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING EB.Utility
    $USING AC.EntryCreation
    $USING ST.CompanyCreation
    $USING PC.Contract
    $USING EB.SystemTables
    $USING MI.Entries
    $USING MI.AverageBalances
    $USING EB.TransactionControl
    $USING AC.BalanceUpdates
    $USING RE.Consolidation
    $USING AC.API
    $USING ST.CurrencyConfig
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING PC.IFConfig

START.THE.UPDATE:

* Process one entry at a time and process all databases that this entry
* will hit in the PC database within the DBASE loop. There may be more
* than just one ! The period being processed must be < PERIOD.END
* in DATES , else we know that the DB does not exist yet

* eg. entry 123456789.0001 affects periods 20000131,20000228

*     process this entry and the related account in the PC database
*     for both these open periods by opening the relevant PC files

* in the loop that follows , we set C$PC.CLOSING.DATE to the period
* being processed in DBASE.ARRAY . It is important that we set it back
* to it's original value before we quit this routine

* Let's start with the no of stmt entries to process


    WRITE.FLG = ''  ;* GB0001559
    PC.Contract.clearYrEntry()         ;* Dimensioned in load

    STMT.ADJ.LOOP  = ID
    YID.ACCT = TRIM(FIELD(STMT.ADJ.LOOP,'-',1))   ;* get the account.id
    YID.STMT = TRIM(FIELD(STMT.ADJ.LOOP,'-',3))   ;* get smmt.entry.id


    GOSUB GET.STMT.REC        ;* read stmt record


* Now , we process each period found in the <PC.PERIOD.END> field on the
* stmt entry in question

    FOR DBASE.LOOP = 1 TO DBASE.CNT     ;* no of open periods
        DBASE.ID = DBASE.ARRAY<1,DBASE.LOOP>      ;* actual period

        * Only if dbase exists do we process further

        IF DBASE.ID LE EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd) THEN      ;* GB0001559

            * set common variable C$PC.CLOSING.DATE to DBASE.ID as this is the
            * period we want to update. Look at entries that are not flagged as
            * processed .

            IF PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.StePcApplied)<1,DBASE.LOOP> NE 'Y' THEN
                EB.SystemTables.setCPcClosingDate(DBASE.ID)
                *  EN_10000658 /S
                LOCATE "MI" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POS THEN
                * Check whether BUILD.PL.ENTRIES  is set to  ACCOUNTING in MI.PARAMETER.
                ERR = ''
                R.MI.PARAMETER = ''
                BUILD.PL.ENTRIES = ''
                R.MI.PARAMETER = MI.Entries.Parameter.Read("SYSTEM", ERR)
                BUILD.PL.ENTRIES = R.MI.PARAMETER<MI.Entries.Parameter.ParamBuildPlEntries>
                IF BUILD.PL.ENTRIES ='ACCOUNTING' THEN
                    DIM YR.ENTRY.TEMP(EB.SystemTables.SysDim)
                    YR.ENTRY.DYN = PC.Contract.getDynArrayFromYrEntry()
                    MATPARSE YR.ENTRY.TEMP FROM YR.ENTRY.DYN
                    MI.AverageBalances.BookDatePcEntriesBuild(MAT YR.ENTRY.TEMP)
                    MATBUILD YR.ENTRY.TEMP.DYN FROM YR.ENTRY.TEMP
                    PC.Contract.setDynArrayToYrEntry(YR.ENTRY.TEMP.DYN)
                END
            END
            * EN_10000658 /E
            GOSUB OPEN.RELEVANT.FILES         ;* open files again to suit new C$PC.CLOSING.DATE
            GOSUB DO.UPDATE
            *
            IF NOT(ALPHA(YID.ACCT[1,6])) THEN
                * No need to update for position accounts, when system has position account setup
                GOSUB UPDATE.POSITION   ;* GB0002063
            END
            *
        END
    END ELSE
        EXIT    ;* dBASE cannot exist yet
    END

    NEXT DBASE.LOOP

    IF WRITE.FLG THEN
        GOSUB UPDATE.POST.FLAG          ;* write back stmt entry
    END

    EB.SystemTables.setCPcClosingDate(PC.Contract.getPeriodEnd());* set to original value

    RETURN

*-----------------------------------------------------------------*
GET.STMT.REC:

* generic check to see if initial DIM statement was sufficient

    PC.Contract.clearYrEntry()         ;* init
    ERR = ''
    YR.ENTRY.DYN = AC.EntryCreation.StmtEntry.Read(YID.STMT, ERR)
    PC.Contract.setDynArrayToYrEntry(YR.ENTRY.DYN)
    IF ERR THEN
        EB.SystemTables.setE('PC.RTN.STMT.ENTRY.MISS.':@FM:YID.STMT);* if record not there
        GOSUB FATAL.ERROR
    END

    DBASE.ARRAY = ''
    DBASE.ARRAY = PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.StePcPeriodEnd)
    DBASE.CNT = DCOUNT(DBASE.ARRAY,@VM)

    RETURN

*-----------------------------------------------------------------*

UPDATE.POST.FLAG:

* Stamp the periods processed in the stmt entry as complete

    YR.ENTRY.DYN = PC.Contract.getDynArrayFromYrEntry()
    AC.EntryCreation.StmtEntryWrite(YID.STMT, YR.ENTRY.DYN,'')

    RETURN

*-----------------------------------------------------------------*
DO.UPDATE:

    GOSUB PROCESS.STMT.ENTRY

* Finished with stmt entry and account for first open period here
* Get another affected period if there is one from DBASE.ARRAY and
* apply the same posting to that database after opening the relevant
* database files

    RETURN

*-----------------------------------------------------------------*
PROCESS.STMT.ENTRY:

    WRITE.FLG = ''
    STMT.FLAG = ""

    ERR = ''
    YR.ACCOUNT.DYN = AC.AccountOpening.Account.Read(YID.ACCT, ERR)
    PC.Contract.setDynArrayToYrAccount(YR.ACCOUNT.DYN)
    IF ERR THEN
        YERR = ""
        SAVE.YID.ACCT = YID.ACCT ;* save the account ID before read from history
        
        AC.AccountOpening.AccountHistRead(YID.ACCT,R.ACC,YERR)
       
        YID.ACCT = SAVE.YID.ACCT ;* re-initialise the account ID after read from history
        
        IF YERR THEN
            PC.Contract.clearYrAccount()
            EB.SystemTables.setE("PC.RTN.MISS.FILE.F.ACCOUNT.ID":@FM:YID.ACCT)
            GOSUB FATAL.ERROR
        END
        PC.Contract.setDynArrayToYrAccount(R.ACC)
    END
* Get balances
    GOSUB GET.ACCOUNT.BALANCES
    YOPEN.ACTUAL.BAL = YBALANCE + 0
*
* process statement entry starts here
*
* extracts from I_GOSUB.ACCT.ACTIVITY
*************************************
*
    IF PC.Contract.getYrAccount(AC.AccountOpening.Account.Currency) = EB.SystemTables.getLccy() THEN
        YAMT = PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.SteAmountLcy)
    END ELSE
        YAMT = PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.SteAmountFcy)
    END

*** Default to ACCOUNT MKT if no market is passed - should not happen
    IF PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.SteCurrencyMarket) = '' THEN
        PC.Contract.setYrEntry(AC.EntryCreation.StmtEntry.SteCurrencyMarket, PC.Contract.getYrAccount(AC.AccountOpening.Account.CurrencyMarket))
    END
*
* Create entries for consolidation reporting

    RE.Consolidation.setYkeyCon(PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.SteConsolKey))

    IF YOPEN.ACTUAL.BAL <> 0 THEN
        ACC.BAL = YOPEN.ACTUAL.BAL
    END ELSE
        ACC.BAL = YAMT
    END

    YTYPE = ''
    AC.BalanceUpdates.DetermineInitAssetType(YID.ACCT,R.ACCT,YTYPE,ACC.BAL)

    YKEY.CON.VAL = RE.Consolidation.getYkeyCon()
    YMKT.NO = FIELD(YKEY.CON.VAL,'.',2,1)

    RE.Consolidation.setYrConNew('')
    tmp=RE.Consolidation.getYrConNew(); tmp<1>=RE.Consolidation.getYkeyCon(); RE.Consolidation.setYrConNew(tmp)
    tmp=RE.Consolidation.getYrConNew(); tmp<2>=PC.Contract.getYrAccount(AC.AccountOpening.Account.Currency); RE.Consolidation.setYrConNew(tmp)
    tmp=RE.Consolidation.getYrConNew(); tmp<3>=YTYPE:'.':YMKT.NO; RE.Consolidation.setYrConNew(tmp)

    IF YAMT NE '' THEN
        BEGIN CASE
            CASE YAMT > 0
                tmp=RE.Consolidation.getYrConNew(); tmp<5>=YAMT; RE.Consolidation.setYrConNew(tmp)
                IF NOT(PC.Contract.getYrAccount(AC.AccountOpening.Account.Currency) = EB.SystemTables.getLccy()) THEN
                    tmp=RE.Consolidation.getYrConNew(); tmp<7>=PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.SteAmountLcy); RE.Consolidation.setYrConNew(tmp)
                END
            CASE YAMT < 0
                tmp=RE.Consolidation.getYrConNew(); tmp<4>=YAMT; RE.Consolidation.setYrConNew(tmp)
                IF NOT(PC.Contract.getYrAccount(AC.AccountOpening.Account.Currency) = EB.SystemTables.getLccy()) THEN
                    tmp=RE.Consolidation.getYrConNew(); tmp<6>=PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.SteAmountLcy); RE.Consolidation.setYrConNew(tmp)
                END
        END CASE
    END

    IF YOPEN.ACTUAL.BAL = 0 THEN     ;* Opening balance is zero.
        tmp=RE.Consolidation.getYrConNew(); tmp<15>=YID.ACCT; RE.Consolidation.setYrConNew(tmp)
    END

    YR.CON.NEW.VAL = RE.Consolidation.getYrConNew()
    RE.Consolidation.ConsolUpdate(YR.CON.NEW.VAL,'','')

    EB.SystemTables.setLocalSev('')
* Set flag to posted on the stmt entry record
    tmp=PC.Contract.getYrEntry(AC.EntryCreation.StmtEntry.StePcApplied); tmp<1,DBASE.LOOP>='Y'; PC.Contract.setYrEntry(AC.EntryCreation.StmtEntry.StePcApplied, tmp)
    WRITE.FLG = 1

    GOSUB UPDATE.DF.FINANCIAL.DETAILS

    RETURN
*-----------------------------------------------------------------*
OPEN.RELEVANT.FILES:
*------------------
    IF EB.SystemTables.getCPcClosingDate()<> PC.Contract.getCPcClosingDatePrevStmt() THEN          ;* only if pre PERIOD.END date diff from current PERIOD.END dat
        PC.Contract.setCPcClosingDatePrevStmt(EB.SystemTables.getCPcClosingDate());* set it here
        PC.Contract.AcctActivityLoad()      ;* open the files with correct PC date
    END

    RETURN
******************************************************************************************************
GET.ACCOUNT.BALANCES:
********************
* Get OPEN.ACTUAL.BAL using the core routine
;*pc database is created after deciding the closing balance and asset type for the day.
;*so for pc process, considering opening balance of today instead of last working day.
    BALANCE.DATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
    YBALANCE = ""
    CR.MVMT = ""
    DR.MVMT = ""
    ERR = ""
    R.ACCT = PC.Contract.getDynArrayFromYrAccount()
    AC.API.EbGetAcctBalance(YID.ACCT,R.ACCT,"BOOKING",BALANCE.DATE,"",YBALANCE,CR.MVMT,DR.MVMT,ERR)
*
    RETURN
****************************************************************************************************
* GB0002063 S
UPDATE.POSITION:
*
* Net positions by currency, mkt & value date action merker (ie '', or 'D'
* for all entries (including
* entries being backed out from the entry hold file (change on change).
*
    ENTRY = PC.Contract.getDynArrayFromYrEntry()
    ENTRY = LOWER(ENTRY)
*
    DD = ENTRY<1,AC.EntryCreation.StmtEntry.SteDealerDesk>
    IF NOT(DD) THEN
        DD = '00'
    END
*
    SYS.ID.IN = ENTRY<1,AC.EntryCreation.StmtEntry.SteSystemId>
    ENTRY.IN = PC.Contract.getDynArrayFromYrEntry()
    BLANK.PARAM = ''
    VD.SYS = ''
    AC.API.ValueDatedAcctng(SYS.ID.IN, ENTRY.IN, '', '', BLANK.PARAM, VD.SYS)

    CCY = ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency>
    MKT = ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrencyMarket>
    VAL = ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountingDate>
    FGN = ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy>
    LCL = ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountLcy>
    SYSID = ENTRY<1,AC.EntryCreation.StmtEntry.SteSystemId>
    CRF.CCY = ENTRY<1,AC.EntryCreation.StmtEntry.SteCrfCurrency>
    CRF.TYPE = ENTRY<1,AC.EntryCreation.StmtEntry.SteCrfType>
    SUPPRESS.FORCE = ENTRY<1,AC.EntryCreation.StmtEntry.SteSuppressPosition>      ;* Y=supp C=force
    ORIG.CCY = ENTRY<1,AC.EntryCreation.StmtEntry.SteOriginalCcy>       ;* May need position anyway
    TRANS.REF.NO = ENTRY<1,AC.EntryCreation.StmtEntry.SteOurReference>  ;* required by currency.position
    PGM = TRANS.REF.NO[1,2]   ;* required by currency.position
*
    LIVE.CRF = ""   ;* Contingent crf movement
    IF CRF.TYPE THEN
        LOCATE CRF.TYPE IN PC.Contract.getContingentTypes()<1> SETTING D ELSE
        LIVE.CRF = 1      ;* Live crf movement
    END
    END
*
* Load positions if the entry is foreign. Not required if it's accounting
* entry with a crf movement (ie one cancels the other) - the crf movement
* must be live. You can suppress the a/c position with "Y" and force a P&L
* position with "C". These little flags will eventually be dropped.
*
    BEGIN CASE
        CASE NOT(NUM(ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber>[4,3]))
            * Skip if it is POSITION ACCOUNT entry
        CASE SUPPRESS.FORCE = 'Y' AND ORIG.CCY        ;* Raise position for conversion
            IF ORIG.CCY NE EB.SystemTables.getLccy() THEN        ;* We need to reverse the position
                CCY = ORIG.CCY
                FGN = -ENTRY<1,AC.EntryCreation.StmtEntry.SteOriginalAmount>
                IF ENTRY<1,AC.EntryCreation.StmtEntry.SteOrigAmountLcy> NE '' THEN
                    LCL = -ENTRY<1,AC.EntryCreation.StmtEntry.SteOrigAmountLcy>      ;* Use the original local amount from the application
                END ELSE
                    LCL = -LCL
                END
                GOSUB CALL.CURRENCY.POSITION
            END
            *
            CCY.ID = EB.SystemTables.getLccy()
            IF NOT(ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> MATCHES "":@VM:CCY.ID) THEN
                CCY = ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency>
                FGN = ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy>
                LCL = ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountLcy>
                GOSUB CALL.CURRENCY.POSITION
            END
            *
        CASE ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber> AND LIVE.CRF AND ORIG.CCY     ;* Potential position
            IF CCY NE EB.SystemTables.getLccy() THEN   ;* Raise position for the account
                GOSUB CALL.CURRENCY.POSITION
            END
            *
            IF ORIG.CCY NE EB.SystemTables.getLccy() THEN        ;* Raise position for the CRF
                CCY = ORIG.CCY
                FGN = -ENTRY<1,AC.EntryCreation.StmtEntry.SteOriginalAmount>
                LCL = -LCL
                GOSUB CALL.CURRENCY.POSITION
            END
            *
        CASE CCY MATCHES "":@VM:EB.SystemTables.getLccy() OR SUPPRESS.FORCE = "Y"     ;* No position for local or suppressed
            NULL

        CASE LIVE.CRF   ;* CRF only entry
            GOSUB CALL.CURRENCY.POSITION
            *
        CASE ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber> ;* Accounting entry
            IF NOT(LIVE.CRF) THEN ;* Live crf movement cancels out position
                GOSUB CALL.CURRENCY.POSITION
            END
            *
        CASE ENTRY<1,AC.EntryCreation.StmtEntry.StePlCategory>    ;* P&L entry
            IF SUPPRESS.FORCE = "C" OR LIVE.CRF THEN
                FGN = FGN *-1     ;* Other side for position
                LCL = LCL *-1
                GOSUB CALL.CURRENCY.POSITION
            END
    END CASE
*
    RETURN
*
*------------------------------------------------------------------------
CALL.CURRENCY.POSITION:
*======================
*
    IF MKT = "" THEN
        MKT = 1
    END
*
    IF FGN OR LCL THEN        ;* Foreign or Local amount so

        * Change to 'B'atch to flush update immediately
        * Otherwise Position will not agree with CAL
        SAVE.RUB = EB.SystemTables.getRunningUnderBatch()
        EB.SystemTables.setRunningUnderBatch(1)

        NARRATIVE = PGM
        NARRATIVE<1,2> = SYSID
        CCY.ID = EB.SystemTables.getLccy()
        ID.CMPNY = EB.SystemTables.getIdCompany()
        ACT.MARKER.LOC = PC.Contract.getActMarker()
        ST.CurrencyConfig.CurrencyPosition("",ACT.MARKER.LOC,"","",ID.CMPNY,"TR","TR",DD,MKT,CCY,CCY.ID,FGN,-LCL,VAL,VAL,TRANS.REF.NO,"",LCL,-LCL,NARRATIVE,"",ER)
        PC.Contract.setActMarker(ACT.MARKER.LOC)
        EB.SystemTables.setIdCompany(ID.CMPNY)

        * Restore variable back
        EB.SystemTables.setRunningUnderBatch(SAVE.RUB)

        IF ER THEN
            EB.SystemTables.setE(ER)
            GOTO FATAL.ERROR
        END

    END
*
    RETURN
* GB0002063 E

*-----------------------------------------------------------------*
ERROR.PRINT.AND.LOG:

* print balance error messages and write exception log records
* before calling FATAL.ERROR.

    YEXCEPT.TYPE="S"
    YEXCEPT.APPLICATION = "PC"
    YEXCEPT.ROUTINE = 'PC.ACCT.ACTIVITY'
    YEXCEPT.MODULE = "PC.ACCT.ACTIVITY"
    YEXCEPT.CODE="900"
    YEXCEPT.FILE="F.ACCOUNT"
    YEXCEPT.CURR.NO=""
    YEXCEPT.OFFICER.DEPT = ""
    YERR.STATIC = " BALANCES DO NOT AGREE"
    LOOP
    UNTIL YBAL.ERR.MESS = "" DO
        YERR.ACCT = YBAL.ERR.MESS<1,1>
        YERR.BAL = YBAL.ERR.MESS<1,2>
        YEXCEPT.VALUE = YERR.BAL:YERR.STATIC
        YERR.MESS = "ACCOUNT ":YERR.ACCT:" ":YERR.BAL:YERR.STATIC
        IF YERR.BAL = "ACTUAL" THEN
            YEXCEPT.MESSAGE = "ONLINE ACTL = ":YBAL.ERR.MESS<1,3>
            YEXCEPT.MESSAGE = YEXCEPT.MESSAGE:" OPEN ACTL = ":YBAL.ERR.MESS<1,4>
        END ELSE
            IF YERR.BAL = "CLEARED" THEN
                YEXCEPT.MESSAGE = "ONLINE CLRD = ":YBAL.ERR.MESS<1,3>
                YEXCEPT.MESSAGE = YEXCEPT.MESSAGE:" OPEN CLRD = ":YBAL.ERR.MESS<1,4>
            END ELSE
                YEXCEPT.MESSAGE = "ONLINE CLRD = ":YBAL.ERR.MESS<1,3>
                YEXCEPT.MESSAGE = YEXCEPT.MESSAGE:" WORKING = ":YBAL.ERR.MESS<1,4>
            END
        END
        YEXCEPT.KEY = YERR.ACCT
        EB.ErrorProcessing.ExceptionLog(YEXCEPT.TYPE,YEXCEPT.APPLICATION,YEXCEPT.ROUTINE,YEXCEPT.MODULE,YEXCEPT.CODE,YEXCEPT.VALUE,YEXCEPT.FILE,YEXCEPT.KEY,YEXCEPT.CURR.NO,YEXCEPT.MESSAGE,YEXCEPT.OFFICER.DEPT)

        YBAL.ERR.MESS = DELETE(YBAL.ERR.MESS,1,0,0)

    REPEAT

    RETURN

FATAL.ERROR:

    EB.SystemTables.setText(EB.SystemTables.getE()); EB.ErrorProcessing.FatalError ("PC.ACCT.ACTIVITY")

    RETURN
*-----------------------------------------------------------------*
UPDATE.DF.FINANCIAL.DETAILS:
** Updates the DF tables - FinancialDetailsPostClosing for the entries
    EntryType = 'S'     ;* the entry type is always stmt
    EntryId = YID.STMT
    DfEntry = PC.Contract.getDynArrayFromYrEntry()      ;* get the entry record and ID
*    MATBUILD DfEntry FROM YrEntry      ;* matbuild to be replaced for common variable
    DfEntry<AC.EntryCreation.StmtEntry.SteCrfType> = YTYPE      ;* asset type is required for calculating the GL line

    EntryRec = LOWER(DfEntry)
    EntryFlag = 'STMT'      ;* Flag STMT is pass to PC.DZ.ENTRY.FINDET.POSTCLOSE.

    PC.IFConfig.DzEntryFinDetPostClose(EntryType, EntryId, EntryRec, EntryFlag, '', '')

    RETURN

    END
