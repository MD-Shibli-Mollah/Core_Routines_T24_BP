* @ValidationCode : Mjo3ODMyNzAwNDQ6Q3AxMjUyOjE2MTI1MTIxMjgxNTA6cy5zb21pc2V0dHlsYWtzaG1pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDIuMjAyMTAxMjEtMTMxNjo5MzI6MzA0
* @ValidationInfo : Timestamp         : 05 Feb 2021 13:32:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 304/932 (32.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 17 08/02/01  GLOBUS Release No. 200507 28/06/05
*-----------------------------------------------------------------------------
* <Rating>3069</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
 
SUBROUTINE E.STMT.ENQ.BY.CONCAT(Y.ID.LIST)
*-----------------------------------------------------------------------------
*
* 23/12/91 - GB9100506
*            ACCT.STMT.PRINT can have null balance instead of zero. This
*            when <-1>d on the balance array causes the next balance to
*            be used as the opening balance.
*
* 21/01/92 - HY9200577
*            Replace -1 with := when building arrays
*
* 11/11/91 - HY9100310
*            Remove the addition of 1 to the booking date when matching
*            for EQ.
*
* 16/03/92 - HY9200699
*            Read the history file (ACCOUNT.STATEMENT), if the account
*            is missing (it may have been closed), to determine the account
*            currency.
*
* 01/04/92 - HY9200755
*            Only use FQU2 balance for combined statements.
*
* 07/02/01 - GB0100297
*            Check for duplicate entry id's - can happen when running under
*            batch.
*
* 05/01/02 - GLOBUS_EN_10000302
*            Changes made to include forward value dated statement
*            entries in the enquiry
*
* 11/10/02 - GLOBUS_CI_10004129
*            Correction made to rectify the error when running  the enq
*            by selecting the BOOKING.DATE with EQ operand.
*
* 21/10/02 - GLOBUS_EN_10001477
*            Changes made to adapt additional freqencies for the
*            account.statement.
* 19/12/02 - BG_100002917
*          - Shortened the name of STMT.FREQU.2 & FQU2.LAST.BAL.
*
* 27/02/03 - BG_100003504
*            Changes made for Multiple frequency account statement
*            enhancement.Existing code using the relationship field
*            is removed since statement-2 frequency made independent
*            of statement-1 frequency.
*
* 08/04/03 - CI_10008120
*            Wrong sorting of entries by BOOKING.DATE.
*
* 23/06/03 - BG_100004605
*            Bug fixes for the enquiry STMT.ENT.BOOK related to
*            multiple frequencies of account statement.
*
* 01/04/05 - BG_100008493
*            Double entries, remove the use of ACCT.ENT.TODAY as
*            ACCT.STMT.ENTRY is updated online.
*
* 19/04/05 - CI_10029376
*            Changes done to restrict the user to view only those
*            accounts thro STMT.ENT.BOOK enquiry which are pertaining
*            to the OTH.BOOK.ACCESS in USER profile.
*
* 11/07/05 - EN_10002592
*            Online Update of Statement concat files
*
* 25/10/05 - BG_100009585
*            Cheking for duplicate entries with ACCT.STMT.ENTRY in READ.EXTRA.IDS
*            section is removed as STMT.PRINTED is updated online itself.
*
* 24/11/06 - CI_10045618
*            Enq STMT.ENT.BOOK doesn't show correct opening balance for Passbook
*            accounts when giving booking.date conditions as GT/GE/EQ
*            Today/any date greater than booking date of the last printed transaction
*
* 01/03/07 - EN_10003231
*            Modified to call DAS to select data.
*
* 27/04/07 - EN_10003339
*            Pull in sub accounts for a master account
*
* 11/09/07 - CI_10051320
*            Enq STMT.ENT.BOOK doesn't show correct opening balance for Passbook
*            accounts when giving booking.date condition RG given.
*
* 13/11/07 - CI_10052434
*            Enq STMT.ENT.BOOK doesn't show correct opening balance for closed
*            accounts in some cases. Fix done to resolve this.
*
* 08/02/2008 - CI_10053652
*              On running enq , when requested date is GT the ACCOUNT.STATEMENT
*              frequency, wrong opening balance is fetched. So changes done to get
*              the opening balance from entry .
*
* 0-4/07/08 - CI_10056511(CSS REF:HD0815178)
*            When there are special statments printed,the last printed bal would get updated
*            with the latest balance in account statement. So when the requested date
*            is GT the ACCOUNT.STATEMENT frequency in the enquiry, now the balance is obtained
*            by calling the para GET.ENTRIES. Changes done such that if there are no more
*            entries to the account after the last updated freq bal, no need to process
*            the entries in STMT.PRINTED
*
* 30/09/08 - BG_100020208
*            While running the enquiry if we give the invalid account then it check if it is
*            valid account or not if it is not then it throws an error message.
*
* 28/11/08 - BG_100019132
*            Drill down is not working when there is a net entry.
*
* 08/06/09 - CI_10063509(CSS REF:HD0920618)
*            Changes done to get the entries for sub accounts correctly when STMT.ENT.BOOK is requested for master account.
*
* 08/10/09 - EN_10004354
*            New criteria PROCESSING.DATE is introduced, changes done to show the entries based on the processing date
*            code cleanup done to improve ratings.
*
* 20/11/09 - CI_10067716
*            When an account has sub accounts all the entries in YR.ENTRY.FILE
*            should be processed. Also the values in YOPEN.BAL has to be summed up
*            to display the 'BALANCE AT PERIOD START' in STMT.ENT.BOOK correctly.
*
* 15/02/10 - RTC Work Item 22477
*            Performance related changes
*
* 15/04/10 - Defect 30658 / Task 40617
*            The opening balance shown in the STMT.ENT.BOOK enquiry does not tally
*            with the total of actual opening balances in all the sub accounts. If ACCT.STMT.PRINT
*            is not updated then take balance from ACCOUNT.STATEMENT.
*            Revamp of code is done.
*
* 29/04/10 - defect 29553 / task 44998
*            Entries are not in sorted order in the Enquiry STMT.ENT.BOOK for the Account which is
*            having  SUB.ACCOUNT setup. And client does not maintain STMT.ENTRY.DETAIL file by setting
*            AC.CONSOLIDATE.COND application.For this setup while executing the enquiry some of the
*            entries are not fetched from the STMT.ENTRY.DETAIL since enquiry balances not matched
*            with the ACCOUNT balance.
*            Enquiry STMT.ENT.BOOK duplicates the entries when the system does not maintain the
*            STMT.ENTRY.DETAIL. Because System Loops the STMT.ENTRY.DETAIL.XREF until get all entry ids
*            then build the display array with amount, final looping iteration will always set the error variable,
*            if error variable set then display array fetched amounts from STMT.ENTRY itself which is duplicates.
*
* 27/05/10 - Defect 30658 / Task 52532
*            When IF.NO.MOVEMENT is set as NO in account statement for a NOSTRO account having sub accounts
*            opening balance is not shown correctly.
*
* 02/06/10 - Defect 51272 / task 52248
*            Modified to take the STMT.ENTRY.DETAIL ID into the variable Y.CONCAT.REC.SEP.ID and
*            used this ID in E.READ.STMT.ENTRY routine.
*
* 28/07/10 - Defect 70530 / CI_10070980
*            Amount of IC.CHARGE transaction is not shown if TRANS.REF contains '*'
*            Modified to take the TRANS.REF from STMT.ENTRY for normal entries &
*            STMT.ENTRY.DETAIL for netted entries.
*
* 18/06/10 - Defect 29733 / Task 60021
*            Before calculating the opening balance, Sorting based on booking date
*            or processing date has been done to display the opening balance correctly.
*            With the NS transaction setup.
*
* 29/10/10 - Defect 102048 / Task 103144
*            CACHE.READ on the table AC.STMT.PARAMETER performed wrongly.
*
* 13/12/10 - Defect 114195 / Task 115164
*            Account opening balance is not shown correclty when there is sub account for an account
*            with AC.SUB.ACCOUNT record updated with descending order of sub account ids.
*
* 21/12/10 - Defect 120998 / Task 121021
*            When account statement is not generated for a sub account with IF.NO.MOVEMENT set as NO and
*            after crossing some frequencies, if tried to check enquiry with booking date for that period
*            incorrect opening balance is shown.
*
* 07/03/11 - Defect 166074 / Task 167409
*            Sub account processing is set default for NOSTRO, Internal & Position accounts.
*
* 14/04/11 - DEFECT 188325 / TASK 193066
*            ENQ STMT.ENT.BOOK shows the incorrect OPENING.BALANCE for the transactions
*            which is the VALUE.DATE GE BOOKING.DATE AND LE NEXT.WORKING.DAY.
*
* 13/06/11 - DEFECT 188325 - TASK 226319
*            ACCOUNT balance dose not match enquiry result
*            while we run enquiry with booking date the transactions with value date above period end also displayed
*            account balance will be updated online only if the value date is within period end in VD system
*            hence process the entries only if the processing date is LE period end
*
* 04/09/2011 - DEFECT 270735 / TASK 270897
*              Changes done to calculate the PERIOD START DATE/ END DATE and to show the respective entries.
*
* 26/09/2011 - DEFECT 279760 / TASK 282539
*              Changes done in DEFECT 270735 has been corrected to calculate PERIOD in month end.
*
* 10/08/11 - EN 211023 / Task 211287
*            Coding to do special processing for HVT accounts.
*
* 02/05/11 - Defect 221298 / Task 287120
*            Problem with the enquiry STMT.ENT.BOOK for AA Accounts:
*            The core enquiry STMT.ENT.BOOK has been designed to display the balances based on
*            ACCT.STMT.PRINT and FQU1.LAST.BALANCE in ACCOUNT.STATEMENT.
*
*            For AA Accounts, ACCT.STMT.PRINT and FQU1.LAST.BALANCE are not updated properly.
*            As FQU1.LAST.BALANCE doesn't have correct balance, EB.ACCT.ENTRY.LIST API is used to
*            fetch the correct balance for requested period.
*
* 19/11/12 - Task 520949
*            For non-HVT account, the enquiry STMT.ENT.BOOK.BF gives incorrect output.
*            When checking whether the account is HVT account or not. Condition is modified to check
*            whether the HVT.FLAG value is 'YES' or 'NO'
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 05/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 24/07/17 - Defect 2198300 / Task 2207584
*            For the Netted entry we have to read from STMT.ENTRY.DETAIL not from STMT.ENTRY
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*
* 05/02/21- Enhancement 3760081 / Task 4133519
*          New routine AC.READ.ACCT.STMT.PRINT to read the records from STMT.PRINTED and STMT2.PRINTED
*          instead of STMT.PRINTED.READ and STMT2.PRINTED.READ and AC.SPLIT.ACCT.STMT.PRINT to update
*          STMT.PRINTED and STMT2.PRINTED.
*----------------------------------------------------------------------
*
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.API
    $USING AC.EntryCreation
    $USING AC.Config
    $USING AC.AccountStatement
    $USING AC.HighVolume
    $USING AC.API
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
    $USING EB.Security

*-----------------------------------------------------------------------
MAIN.PARA:
*=========
*
* Find the position of ACCOUNT and BOOKING.DATE or PROCESSING.DATE
*
    END.FLAG = "END"
    YDATE.POS = '' ; BOOK.FLAG = '' ; PROCESS.FLAG = ''
    SORT.POS = ''  ; SORT.FLAG = '' ; SORT.VALUE = ''

    LOCATE "ACCOUNT" IN EB.Reports.getDFields()<1> SETTING YACCOUNT.POS ELSE
        RETURN
    END

    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING YBOOK.POS THEN
        BOOK.FLAG = 1
        YDATE.POS = YBOOK.POS
    END

    LOCATE "PROCESSING.DATE" IN EB.Reports.getDFields()<1> SETTING YPROCESS.POS THEN
        PROCESS.FLAG = 1
        YDATE.POS = YPROCESS.POS
    END
*
    LOCATE "SORT.REQ" IN EB.Reports.getDFields()<1> SETTING SORT.POS THEN
        SORT.VALUE = EB.Reports.getDRangeAndValue()<SORT.POS>
        IF SORT.VALUE = "YES" THEN
            SORT.FLAG = 1
        END
    END
*
    IF BOOK.FLAG EQ '' AND PROCESS.FLAG EQ '' THEN          ;*Do not proceed if there is no date specified.
        RETURN
    END

    IF BOOK.FLAG NE '' AND PROCESS.FLAG NE '' THEN          ;*Do not process further if both the dates are specified, only one date should be specified.
        RETURN
    END

    STMT.ENTRY.DETAIL.ID = ''
    YSORT.DETS = EB.Reports.getREnq()<4,1>
    SORT.FLD = FIELD(YSORT.DETS,' ',1,1)
    SORT.BY = FIELD(YSORT.DETS,' ',2,1)

*
    IF EB.Reports.getDLogicalOperands()<YDATE.POS> = '' OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "" OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "ALL" THEN
        RETURN
    END
    GOSUB OPEN.REQD.FILES
    GOSUB LIST.ACCT.NOS
    Y.CONCAT.REC = ""
    YOPEN.BAL = ""
    Y.AMOUNT = ""
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    YENQ.LIST.COPY = EB.Reports.getDRangeAndValue()<YDATE.POS>
    YENQ.LIST = ""
    ENTRYID.LIST = ""         ;* Stores entry ids to check for duplicates
    YR.ENTRY.FILE = ""
    LOOP
        REMOVE YVALUE FROM YENQ.LIST.COPY SETTING YCODE
    UNTIL YVALUE = ''
        LOCATE YVALUE IN YENQ.LIST<1,1> BY 'AR' SETTING YPOS ELSE
            NULL
        END
        INS YVALUE BEFORE YENQ.LIST<1,YPOS>
    REPEAT
    GOSUB POPULATE.CHECK.DATE
    LOOP
        Y.AC.NO = YACCT.LIST<1>
    UNTIL Y.AC.NO = "" DO
        DEL YACCT.LIST<1>
        GOSUB CHECK.OTH.BOOK.ACCESS
        IF NOT(NEXT.ACCT.FLAG) THEN
            GOSUB BUILD.CONCAT.LIST
        END
    REPEAT
*

    Y.CONCAT.REC.SEP.ID = ""
    GOSUB CHECK.NET.ENTRY
    Y.ID.LIST = Y.CONCAT.REC.SEP.ID
RETURN
*
*------------------------------------------------------------------------
*
POPULATE.CHECK.DATE:
* Entries within current period end should be processed
* so check the given date and decide the check.date
*
    YCHECK.START.DATE = YENQ.LIST<1,1>  ;* Start range
    YCHECK.END.DATE   = YENQ.LIST<1,2>  ;* end range
    IF NOT(YCHECK.END.DATE) THEN
        YCHECK.END.DATE=YENQ.LIST<1,1>  ;* if end range not exists then take start range
    END

    PERIODSTART.DATE  = YCHECK.START.DATE
    EB.API.Cdt('',PERIODSTART.DATE,'-01W')

    IF PERIODSTART.DATE[5,2] NE YCHECK.START.DATE[5,2] THEN
        PERIODSTART.DATE = YCHECK.START.DATE[1,6]:'01'
    END ELSE
        YCHECK.WORKING.DATE = PERIODSTART.DATE
        EB.API.Cdt('',YCHECK.WORKING.DATE,'+1W')
        IF YCHECK.WORKING.DATE EQ YCHECK.START.DATE THEN
            PERIODSTART.DATE = YCHECK.START.DATE  ;* Take the given working day
        END ELSE
            EB.API.Cdt('',PERIODSTART.DATE,'+01C')  ;* Take the period start date if it is holiday
        END
    END

    PERIODEND.DATE  = YCHECK.END.DATE
    EB.API.Cdt('',PERIODEND.DATE,'+01W')

    IF PERIODEND.DATE[5,2] NE YCHECK.END.DATE[5,2] THEN
        PERIODEND.DATE = YCHECK.END.DATE[1,6]:'32'
    END

    EB.API.Cdt('',PERIODEND.DATE,'-01C')

RETURN
*-------------------------------------------
CHECK.NET.ENTRY:
*==============
*
* Check net entry, if not then form the concat list and return
*
    LOOP
        Y.CONCAT.REC.ID = Y.CONCAT.REC<1>
    UNTIL Y.CONCAT.REC.ID = '' DO
        DEL Y.CONCAT.REC<1>
        Y.ENTRY.ID = FIELD(Y.CONCAT.REC.ID,'*',2)
        Y.ENTRY.CHECK = COUNT(Y.ENTRY.ID,'!')
        IF Y.ENTRY.CHECK THEN
            GOSUB READ.STMT.ENTRY.DETAIL.XREF
        END ELSE
            R.STMT.ENTRY = ''
            YERR = ''
            R.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(Y.ENTRY.ID, YERR)
            GOSUB BUILD.RETURN.LIST
        END
    REPEAT
RETURN
*
*------------------------------------------------------------------------
*
BUILD.RETURN.LIST:
*=================

    IF R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAmountFcy> THEN
        Y.AMOUNT = R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAmountFcy>
    END ELSE
        Y.AMOUNT = R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAmountLcy>
    END
* Removed R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteTransReference> from Y.CONCAT.REC.SEP.ID as the ID for IC.CHARGE.PRODUCT
* contains '*' and the amount is not shown for that entry. Instead TRANS.REF is taken directly from
* 23rd pos of STMT.ENTRY in ENQUIRY.
    IF DCOUNT(Y.CONCAT.REC.ID,'*') EQ 5 THEN
        Y.CONCAT.REC.SEP.ID<-1> = Y.CONCAT.REC.ID:'*':Y.AMOUNT:'*':STMT.ENTRY.DETAIL.ID
    END ELSE
        Y.CONCAT.REC.SEP.ID<-1> = Y.CONCAT.REC.ID:'***':Y.AMOUNT:'*':STMT.ENTRY.DETAIL.ID
    END
    STMT.ENTRY.DETAIL.ID = '' ;* Every time nullify this to avoid duplication
RETURN
*
*------------------------------------------------------------------------
*
READ.STMT.ENTRY.DETAIL.XREF:
*==========================
*
* Remove the id from list and read the record from stmt.entry.detail.xref file
*
    STMT.CNT = 1
    LOOP
        STMT.XREF.ID = Y.ENTRY.ID:'-':STMT.CNT
        R.STMT.ENTRY.DETAIL.XREF = ''
        YERR = ''
        R.STMT.ENTRY.DETAIL.XREF = AC.EntryCreation.tableStmtEntryDetailXref(STMT.XREF.ID, YERR)
    WHILE NOT(YERR)
        STMT.CNT + = 1
        GOSUB READ.STMT.ENTRY.DETAIL
    REPEAT

* if the system does not maintain the STMT.ENTRY.DETAIL file by setting up AC.CONSOLIDATE.COND application
* then shows the entry from stmt.entry itself.
* In the above loop if Netted entries available in detail file the build the entry to an array then last
* iteration is definitely set YERR variable then it will shows the consolidated entry from Stmt.entry file.
    IF STMT.CNT  EQ '1' AND YERR THEN
        R.STMT.ENTRY = ''
        YERR = ''
        R.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(Y.ENTRY.ID,YERR)
        GOSUB BUILD.RETURN.LIST
    END

RETURN
*------------------------------------------------------------------------
*
READ.STMT.ENTRY.DETAIL:
*=====================
*
* Remove the id from list and read the record from stmt.entry.detail file
*
    LOOP
        REMOVE STMT.ENTRY.DETAIL.ID FROM R.STMT.ENTRY.DETAIL.XREF SETTING POS
    WHILE STMT.ENTRY.DETAIL.ID:POS
        R.STMT.ENTRY = ''
        YERR = ''
        R.STMT.ENTRY = AC.EntryCreation.tableStmtEntryDetail(STMT.ENTRY.DETAIL.ID,YERR)
        GOSUB BUILD.RETURN.LIST
    REPEAT

RETURN
*
*------------------------------------------------------------------------
*
OPEN.REQD.FILES:
*===============
*
    FWD.MVMT.FLAG = "" ; STMT.DATE.FIELD = "" ; FWD.STMT1.LIST = ""
    R.AC.STMT.PARAM = ""
    IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng> EQ 'Y' THEN
        R.AC.STMT.PARAM = AC.AccountStatement.AcStmtParameter.CacheRead('SYSTEM', '')
* Before incorporation : CALL CACHE.READ('F.AC.STMT.PARAMETER', 'SYSTEM', R.AC.STMT.PARAM, '')
        IF R.AC.STMT.PARAM<AC.AccountStatement.AcStmtParameter.AcStpFwdMvmtReqd> THEN
            FWD.MVMT.FLAG = 1 ;* Set forward movement flag
        END
    END

RETURN
*
*------------------------------------------------------------------------
*
LIST.ACCT.NOS:
*=============
    YACCT.LIST = ""
    YOPERAND = EB.Reports.getDLogicalOperands()<YACCOUNT.POS>
    YENQ.LIST = EB.Reports.getDRangeAndValue()<YACCOUNT.POS>
*
    IF YOPERAND = 1 AND YENQ.LIST <> "ALL" THEN
        YACCT.LIST = YENQ.LIST
        CONVERT @SM TO @FM IN YACCT.LIST
    END
*
RETURN
*
*-----------------------------------------------------------------------
*
READ.ACCT.STMT:
*--------------
* Read ACCOUNT.STATEMENT record

    R.ACCT.STMT = ''
    YERR = ''
    R.ACCT.STMT = AC.AccountStatement.tableAccountStatement(SUB.ACCT.NO, YERR)
    IF YERR THEN
        YERR = ''
        AC.AccountStatement.AccountStatementHistRead(SUB.ACCT.NO, R.ACCT.STMT, YERR)
    END

RETURN
*
*-----------------------------------------------------------------------
*
GET.SUB.ACCT.BALANCE:
*--------------------
* Get last balance from master accounts, all sub accounts and entries also to get
* opening balance
* CHECK.ACCT.LIST has only master account or master & sub accounts list.

    LOOP
        REMOVE SUB.ACCT.NO FROM CHECK.ACCT.LIST SETTING POS
    WHILE SUB.ACCT.NO:POS
        GOSUB READ.ACCT.STMT
        GOSUB GET.ACC.STMT.BAL
    REPEAT
 
RETURN
*
*-----------------------------------------------------------------------
*
GET.ACC.STMT.BAL:
*----------------
    YOPEN.BAL += R.ACCT.STMT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance> + 0
    IF Y.DATE GT YACCT.STMT.DATES<YPOS-1> AND YACCT.STMT.DATES<YPOS-1> GT R.ACCT.STMT<AC.AccountStatement.AccountStatement.AcStaFquOneLastDate> THEN

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

        YENTRY.IDS = ''
        R.STMT.PRINTED = ''
        STMT.PRINTED.ID = SUB.ACCT.NO:'-':YACCT.STMT.DATES<YPOS-1>
        InDetails<1>='STMT.PRINTED'
        InDetails<2>=STMT.PRINTED.ID
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',R.STMT.PRINTED , '','', '')
        YENTRY.IDS = R.STMT.PRINTED

        LOOP
            REMOVE YENTRY.ID FROM YENTRY.IDS SETTING ENT.POS
        UNTIL YENTRY.ID = ''
            GOSUB READ.ENTRY
            GOSUB OPENING.BALANCE
        REPEAT
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.EQUAL:
*================
*
*
    YSTORE.BAL.DATE = ''
    IF YSTORE.BAL.DATE = '' THEN
        YSTORE.BAL.DATE = YR.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastDate>
    END
    YENQ.LIST = YENQ.LIST

*
* Find the date nearest to the BOOKING DATE in ACCT.STMT.PRINTED
*
    Y.DATE = PERIODSTART.DATE
    LOCATE Y.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YPOS ELSE
        NULL
    END
    CLOSING.DATE = PERIODSTART.DATE
    IF YACCT.STMT.DATES<YPOS> = '' THEN
* Existing code to refer fqu-2 if the relationship is combined is
* removed since each frequency is made independent and relationship
* field is made obsolate.
        IF SUB.ACCT.PROCESS THEN
            GOSUB GET.SUB.ACCT.BALANCE
        END ELSE
            GOSUB GET.ENTRIES
        END
*
* Enquiry is for entries since the last statement, get entries from
* ACCT.STMT.ENTRY
*
    END ELSE
        IF YACCT.STMT.DATES<YPOS> LT YSTORE.BAL.DATE OR YSTORE.BAL.DATE = '' THEN
            YSTORE.BAL.DATE = YACCT.STMT.DATES<YPOS>
        END

        IF YACCT.STMT.DATES<YPOS> = "PASSBOOK" THEN
            GOSUB GET.LAST.PRINT.BAL
        END ELSE
            GOSUB CHECK.OPEN.BAL
        END
*
* Use this date to read the STMT.PRINTED record
*
        LOOP
            GOSUB READ.ENTRY.IDS
            GOSUB GET.ENTRIES.EQ
            YPOS +=1
        UNTIL YACCT.STMT.DATES<YPOS> = ''
        REPEAT
    END

    GOSUB GET.ENTRIES.EQ

RETURN
*
GET.ENTRIES.EQ:
*==============
    Y.END = ""
    LOOP
*
* Read in each entry and check the booking date against the chosen date
* THIS CAN BE MODIFIED TO FIND THE OPENING BALANCE
*
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YTYPE
    UNTIL YENTRY.ID = '' OR Y.END = "END"
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE GE PERIODSTART.DATE AND PROCESSING.DATE LE PERIODEND.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END ELSE
                IF PROCESSING.DATE GT PERIODEND.DATE THEN
                    Y.END = END.FLAG
                END ELSE
                    CLOSING.DATE = PERIODSTART.DATE
                    GOSUB OPENING.BALANCE
                END
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.RANGE:
*================
*
    START.DATE = PERIODSTART.DATE
    END.DATE = PERIODEND.DATE

    Y.END = ""
    LOCATE START.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YPOS ELSE
        NULL
    END
    CLOSING.DATE = PERIODSTART.DATE
    IF YACCT.STMT.DATES<YPOS> = '' THEN
        Y.DATE = START.DATE
        IF SUB.ACCT.PROCESS THEN
            GOSUB GET.SUB.ACCT.BALANCE
        END ELSE
            GOSUB GET.ENTRIES
        END
    END ELSE
        IF YACCT.STMT.DATES<YPOS> = "PASSBOOK" THEN
            GOSUB GET.LAST.PRINT.BAL
        END ELSE
            GOSUB CHECK.OPEN.BAL
        END
        LOOP
            GOSUB READ.ENTRY.IDS
            GOSUB GET.ENTRIES.RG
            YPOS += 1
        UNTIL YACCT.STMT.DATES<YPOS> = '' OR Y.END = "END"
        REPEAT
        IF Y.END = '' THEN
            GOSUB GET.ENTRIES.RG
        END
    END
RETURN
*
GET.ENTRIES.RG:
*==============
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = '' OR Y.END = 'END'
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE GT END.DATE THEN
                Y.END = END.FLAG
            END ELSE
                IF PROCESSING.DATE GE START.DATE THEN
                    ENTRY.FOUND = 1
                    GOSUB UPDATE.CONCAT.REC
                END ELSE
                    CLOSING.DATE = PERIODSTART.DATE
                    GOSUB OPENING.BALANCE
                END
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.LESS.THAN:
*====================
*
    IF YACCT.STMT.DATES = "" THEN
        GOSUB GET.LAST.PRINT.BAL
        GOSUB GET.ENTRIES.LT
    END ELSE
        YLT.DATE = PERIODSTART.DATE
        LOCATE YLT.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YCOUNT ELSE
            NULL
        END
        YOPEN.BAL = 0
        FOR YPOS = 1 TO YCOUNT
            GOSUB READ.ENTRY.IDS
            IF YCOUNT NE YPOS THEN
                GOSUB EXTRACT.ENTRY.IDS
            END ELSE
                GOSUB GET.ENTRIES.LT
            END
        NEXT YPOS
    END
RETURN
*
GET.ENTRIES.LT:
*==============
    Y.END = ""
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"
        GOSUB READ.ENTRY

        IF YR.STMT.ENTRY NE '' THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE LT PERIODSTART.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END ELSE
                Y.END = END.FLAG
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.NOT:
*==============
*
    IF YACCT.STMT.DATES<1> = "" THEN
        GOSUB GET.LAST.PRINT.BAL
    END ELSE
        YOPEN.BAL = SUM(YACCT.STMT.BAL<1>)
    END
    YNO.STMTS = COUNT(YACCT.STMT.DATES,@FM) + (YACCT.STMT.DATES NE '')
    FOR YPOS = 1 TO YNO.STMTS
        GOSUB READ.ENTRY.IDS
        GOSUB GET.ENTRIES.NOT
    NEXT YPOS
    GOSUB GET.ENTRIES.NOT
RETURN
*
GET.ENTRIES.NOT:
*===============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        GOSUB READ.ENTRY

        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            LOCATE PROCESSING.DATE IN YENQ.LIST<1,1> SETTING YCOUNT ELSE
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.LIKE:
*===============
*
RETURN
*
MATCH.DATE.UNLIKE:
*=================
*
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.LE:
*=============
*
    IF YACCT.STMT.DATES = "" THEN
        GOSUB GET.LAST.PRINT.BAL
        GOSUB GET.ENTRIES.LE
    END ELSE

        YLE.DATE = PERIODSTART.DATE
        LOCATE YLE.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YCOUNT ELSE
            NULL
        END

        YOPEN.BAL = 0
        FOR YPOS = 1 TO YCOUNT
            GOSUB READ.ENTRY.IDS
            IF YCOUNT NE YPOS THEN
                GOSUB EXTRACT.ENTRY.IDS
            END ELSE
                GOSUB GET.ENTRIES.LE
            END
        NEXT YPOS
    END
RETURN
*
GET.ENTRIES.LE:
*==============
*
    Y.END = ""
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY NE '' THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE LE PERIODEND.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END ELSE
                Y.END = END.FLAG
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.GREATER.THAN:
*=======================
*
    Y.DATE = PERIODSTART.DATE
    LOCATE Y.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YPOS ELSE
        NULL
    END
    CLOSING.DATE = PERIODEND.DATE
    EB.API.Cdt('',CLOSING.DATE,'+01C')
    IF YACCT.STMT.DATES<YPOS> = "" THEN
        IF SUB.ACCT.PROCESS THEN
            GOSUB GET.SUB.ACCT.BALANCE
        END ELSE
            GOSUB GET.ENTRIES
        END
    END ELSE
        IF YACCT.STMT.DATES<YPOS> = "PASSBOOK" THEN
            GOSUB GET.LAST.PRINT.BAL
        END ELSE
            GOSUB CHECK.OPEN.BAL
        END
        YCOUNT = YPOS
        LOOP
            GOSUB READ.ENTRY.IDS
            IF YCOUNT NE YPOS THEN
                GOSUB EXTRACT.ENTRY.IDS
            END ELSE
                GOSUB GET.ENTRIES.GT
            END
            YPOS += 1
        UNTIL YACCT.STMT.DATES<YPOS> EQ ""
        REPEAT
    END
    GOSUB GET.ENTRIES.GT
RETURN
*
GET.ENTRIES.GT:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ""
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE GT PERIODEND.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END ELSE
                CLOSING.DATE = PERIODEND.DATE
                EB.API.Cdt('',CLOSING.DATE,'+01C')
                GOSUB OPENING.BALANCE
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.GE:
*=============
*
    LOCATE PERIODSTART.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YPOS ELSE
        NULL
    END
    CLOSING.DATE = PERIODSTART.DATE
    IF YACCT.STMT.DATES<YPOS> = "" THEN
        Y.DATE = PERIODSTART.DATE
        IF SUB.ACCT.PROCESS THEN
            GOSUB GET.SUB.ACCT.BALANCE
        END ELSE
            GOSUB GET.ENTRIES
        END
    END ELSE
        IF YACCT.STMT.DATES<YPOS> = "PASSBOOK" THEN
            GOSUB GET.LAST.PRINT.BAL
        END ELSE
            GOSUB CHECK.OPEN.BAL
        END
        YCOUNT = YPOS
        LOOP
            GOSUB READ.ENTRY.IDS
            IF YCOUNT NE YPOS THEN
                GOSUB EXTRACT.ENTRY.IDS
            END ELSE
                GOSUB GET.ENTRIES.GE
            END
            YPOS += 1
        UNTIL YACCT.STMT.DATES<YPOS> EQ ""
        REPEAT
    END
    GOSUB GET.ENTRIES.GE
RETURN
*
GET.ENTRIES.GE:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ""
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE GE PERIODSTART.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END ELSE
                CLOSING.DATE = PERIODSTART.DATE
                GOSUB OPENING.BALANCE
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.NR:
*=============
*
    START.DATE = PERIODSTART.DATE
    END.DATE = PERIODEND.DATE

    IF YACCT.STMT.DATES = "" THEN
        GOSUB GET.LAST.PRINT.BAL
    END ELSE
        LOCATE START.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YCOUNT ELSE
            NULL
        END
        YOPEN.BAL = SUM(YACCT.STMT.BAL<1>)
        YCOUNT -= 1
        FOR YPOS = 1 TO YCOUNT
            GOSUB READ.ENTRY.IDS
            GOSUB EXTRACT.ENTRY.IDS
        NEXT YPOS
        YPOS = YCOUNT + 1
        GOSUB READ.ENTRY.IDS
        GOSUB GET.ENTRIES.NR.PRE
        LOCATE END.DATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YPOS ELSE
            NULL
        END
        GOSUB READ.ENTRY.IDS
        GOSUB GET.ENTRIES.NR.POST
        YPOS += 1
        LOOP
        UNTIL YACCT.STMT.DATES<YPOS> = ''
            GOSUB READ.ENTRY.IDS
            GOSUB EXTRACT.ENTRY.IDS
            YPOS += 1
        REPEAT
    END
    GOSUB GET.ENTRIES.NR.PRE
    GOSUB GET.ENTRIES.NR.POST
RETURN
*
GET.ENTRIES.NR.PRE:
*==================
*
    Y.END = ''
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = '' OR Y.END = 'END'
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE LT START.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END ELSE
                Y.END = END.FLAG
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
GET.ENTRIES.NR.POST:
*===================
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        GOSUB READ.ENTRY
        IF YR.STMT.ENTRY THEN
            GOSUB GET.PROCESSING.DATE
            IF PROCESSING.DATE GT END.DATE THEN
                ENTRY.FOUND = 1
                GOSUB UPDATE.CONCAT.REC
            END
        END
    REPEAT
    IF SORT.FLD = "BOOKING.DATE" THEN
        GOSUB SORT.ENT.BY.BOOKING.DATE
    END
RETURN
*
*-----------------------------------------------------------------------
*
EXTRACT.ENTRY.IDS:
*=================
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        YSTMT.CHK = 1
        R.ENTRY = ''
        R.ENTRY = AC.EntryCreation.tableStmtEntry(YENTRY.ID, ERR)
        IF R.ENTRY THEN
            IF BOOK.FLAG THEN
                PROCESSING.DATE = R.ENTRY<AC.EntryCreation.StmtEntry.SteBookingDate>
            END ELSE
                PROCESSING.DATE = R.ENTRY<AC.EntryCreation.StmtEntry.SteProcessingDate>
            END

            ENTRY.FOUND = 1
            ADD.DET = Y.AC.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":PROCESSING.DATE:"*":R.ENTRY<AC.EntryCreation.StmtEntry.SteAccountNumber>
            IF Y.CONCAT.REC THEN
                Y.CONCAT.REC := @FM:ADD.DET
            END ELSE
                Y.CONCAT.REC = ADD.DET
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
GET.ENTRIES:
***********
    GOSUB GET.LAST.PRINT.BAL
    YCONT=1
    LOOP
    WHILE Y.DATE GT YACCT.STMT.DATES<YPOS-YCONT> AND YACCT.STMT.DATES<YPOS-YCONT> GT YR.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastDate>

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

        YENTRY.IDS = ''
        R.STMT.PRINTED = ''
        STMT.PRINTED.ID = Y.AC.NO:'-':YACCT.STMT.DATES<YPOS-YCONT>
        InDetails<1>='STMT.PRINTED'
        InDetails<2>=STMT.PRINTED.ID
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',R.STMT.PRINTED , '', '', '')
        YENTRY.IDS = R.STMT.PRINTED

        LOOP
            REMOVE YENTRY.ID FROM YENTRY.IDS SETTING ENT.POS
        UNTIL YENTRY.ID = ''
            GOSUB READ.ENTRY
            GOSUB OPENING.BALANCE
        REPEAT
        YCONT=YCONT+1
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
BUILD.CONCAT.LIST:
*=================
*
*
* Read the ACCOUNT.STATEMENT record and ACCT.STMT.PRINTED
*
*
* Extract the dates only from YR.ACCT.STMT.PRINT to allow locate to work
*
    YR.ACCOUNT.STATEMENT = '' ; YERR = '' ; YACCT.NO = ''
    YR.ACCOUNT.STATEMENT = AC.AccountStatement.tableAccountStatement(Y.AC.NO,YERR)
    IF YERR THEN
        YERR = ''
        YACCT.NO = Y.AC.NO
        AC.AccountStatement.AccountStatementHistRead(YACCT.NO,YR.ACCOUNT.STATEMENT,YERR)
    END
    IF NOT(YERR) THEN
        IF YR.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaCurrency> = EB.SystemTables.getLccy() THEN
            YAMOUNT.POS = AC.EntryCreation.StmtEntry.SteAmountLcy
        END ELSE
            YAMOUNT.POS = AC.EntryCreation.StmtEntry.SteAmountFcy
        END
    END ELSE
        YR.ACCOUNT.STATEMENT = ''
        YAMOUNT.POS=0         ;* eg. account closed; can be determined later by stmt entry
    END

    YACCT.STMT.DATES = "" ; YACCT.STMT.TYPE = "" ; YACCT.STMT.BAL = ""
    YLAST.DATE = "" ; YACCT.AC.NO = ""
    SAVE.Y.AC.NO = Y.AC.NO

    SUB.ACC.LIST = SORT(SUB.ACC.LIST)
    CHECK.ACCT.LIST = ''

    LOOP
        REMOVE ACC.NO FROM SUB.ACC.LIST SETTING POS
    WHILE ACC.NO:POS
        IF ACC.NO THEN        ;* There may be some null values skip them
            GOSUB BUILD.CONCAT
            CHECK.ACCT.LIST<-1> = ACC.NO
        END
    REPEAT

    NO.OF.ACCT = COUNT(CHECK.ACCT.LIST, @FM)       ;* For check of sub account balances
*
* Existing code to refer stmt-2 fqu files removed since the frequencies
* are made independent and relationship concept is changed to allow
* multiple frequencies.
*
    IF FWD.MVMT.FLAG THEN
        STMT.DATE.FIELD = AC.EntryCreation.StmtEntry.SteStmtOneDate
    END
    ENTRY.FOUND = 0
    ON YOPERAND GOSUB MATCH.DATE.EQUAL,
    MATCH.DATE.RANGE,
    MATCH.DATE.LESS.THAN,
    MATCH.DATE.GREATER.THAN,
    MATCH.DATE.NOT,
    MATCH.DATE.LIKE,
    MATCH.DATE.UNLIKE,
    MATCH.DATE.LE,
    MATCH.DATE.GE,
    MATCH.DATE.NR
*
* CB8800866. If no entries found then pass a null value for the account
*
    Y.AC.NO = SAVE.Y.AC.NO
    IF NOT(ENTRY.FOUND)AND R.ACCT THEN
        Y.CONCAT.REC<-1> = Y.AC.NO:"*":"*":YOPEN.BAL
    END

RETURN

************************************************************8
BUILD.CONCAT:
*************
*
* This was causing problems viz...
* Local currency accounts were having YAMOUNT.POS set to AC.EntryCreation.StmtEntry.SteAmountFcy
* and thus opening balance was Allways Zero.

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

    YR.ACCT.STMT.PRINT = ''

    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=ACC.NO
    InDetails<3>=''
    LockRecord="No"
    RequestMode="MERGE.HVT"
    AddInfo=''
    ReservedIn=''
    AcctStmtRecord=''
    StmtSeqIndicator=''
    ErrorDetails=''
    ReservedOut=''
    AC.AccountStatement.acReadAcctStmtPrint(InDetails,RequestMode,LockRecord,AddlInfo,ReservedIn,AcctStmtRecord,StmtSeqIndicator,ErrorDetails,ReservedOut)
    YR.ACCT.STMT.PRINT=AcctStmtRecord
    LOOP
    UNTIL YR.ACCT.STMT.PRINT<1> = ''
*
* EB8800923. If a special statement has been produced on the same day as
* the frequency 1 statement there will be 2 entries on ACCT.STMT.PRINT
* for the same date. Do not include the second in the date array.
*
        YDATE = FIELD(YR.ACCT.STMT.PRINT<1>,"/",1)
* needs to be a locate

* need an array of dates and account numbers

        LOCATE YDATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING POS THEN
            YACCT.AC.NO<POS,-1> = ACC.NO
            YACCT.STMT.BAL<POS,-1> = FIELD(YR.ACCT.STMT.PRINT<1>,"/",2) *1
            YACCT.STMT.TYPE<POS,-1> = 1
        END ELSE
            INS YDATE BEFORE YACCT.STMT.DATES<POS>
            INS FIELD(YR.ACCT.STMT.PRINT<1>,"/",2) BEFORE YACCT.STMT.BAL<POS>
            INS 1 BEFORE YACCT.STMT.TYPE<POS>
            INS ACC.NO BEFORE YACCT.AC.NO<POS>
        END
*
        DEL YR.ACCT.STMT.PRINT<1>

    REPEAT

RETURN

*-----------------------------------------------------------------------
*
READ.ENTRY.IDS:
*==============
*
    YR.ENTRY.FILE = ""
    AC.COUNT = DCOUNT(YACCT.AC.NO<YPOS>,@VM)
    FOR AC.CNT = 1 TO AC.COUNT
        GOSUB READ.ENTRY.ID
    NEXT AC.CNT

    IF (PROCESS.FLAG OR (BOOK.FLAG AND SORT.FLAG)) AND YR.ENTRY.FILE THEN       ;*If processing date is in the criteria sort the entries based on the processing date.
        GOSUB SORT.ENT.BY.DATE
    END
*
RETURN

*------------------------------------------------------------------------
READ.ENTRY.ID:
*=============

    ACC.NO =  YACCT.AC.NO<YPOS,AC.CNT>
    IF YACCT.STMT.TYPE<YPOS,AC.CNT> = 1 THEN
*
*** Change key to use '-' instead of '.' GB7900049
*

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

        ID.STMT.PRINTED = ACC.NO:'-':YACCT.STMT.DATES<YPOS>
        HVT.ENTRIES = ''
        YR.ENTRY.LIST = ''
        InDetails<1>='STMT.PRINTED'
        InDetails<2>=ID.STMT.PRINTED
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',HVT.ENTRIES , '', '', '')
        YR.ENTRY.LIST = HVT.ENTRIES

        IF YR.ENTRY.LIST THEN
            IF YR.ENTRY.FILE THEN
                YR.ENTRY.FILE<-1> = YR.ENTRY.LIST
            END ELSE
                YR.ENTRY.FILE = YR.ENTRY.LIST
            END
        END

* Add stmt entries from FWD.STMT1.PRINTED
* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.


        IF FWD.MVMT.FLAG THEN
            FWD.STMT.PRINTED.ID = ACC.NO:'-':YACCT.STMT.DATES<YPOS>
            HVT.ENTRIES = ''
            FWD.STMT1.LIST = ''
            AC.HighVolume.EbReadHvt('FWD.STMT1.PRINTED', FWD.STMT.PRINTED.ID, HVT.ENTRIES, '')   ;* Call the core api to get the merged info for HVT accounts
            FWD.STMT1.LIST = HVT.ENTRIES
            IF FWD.STMT1.LIST THEN
                YR.ENTRY.FILE<-1> = FWD.STMT1.LIST
            END
        END

    END

RETURN
*-----------------------------------------------------------------------
*

GET.LAST.PRINT.BAL:
*==================
*
* Existing code to refer fqu-2 if the relationship is combined is
* removed since each frequency is made independent and relationship
* field is made obsolate.
*
    BEGIN CASE
        CASE R.ACCT<AC.AccountOpening.Account.ArrangementId> NE '' AND YR.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance> EQ 0    ;* For arrangement accounts get opening balance by calling EB.ACCT.ENTRY.LIST instead of FQU1.LAST.BALANCE as it would be '0'
            FROM.DATE = YENQ.LIST<1,1> ; TO.DATE = YENQ.LIST<1,1> ; ENTRY.IDS = '' ; YBALANCE = '' ; Y.ERR = ''
            AC.AccountStatement.EbAcctEntryList(Y.AC.NO, FROM.DATE, TO.DATE, ENTRY.IDS, YOPEN.BAL, Y.ERR)

        CASE 1
            YOPEN.BAL = YR.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance>
    END CASE
*
* EB8800496. If there is no last balance set this to zero
*
    IF YOPEN.BAL = "" THEN
        YOPEN.BAL = 0
    END
RETURN
*
*-----OPENING BALANCE----------------------------------------------------
*
OPENING.BALANCE:
    IF NOT(YAMOUNT.POS) THEN
        BEGIN CASE
            CASE YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteCurrency>=EB.SystemTables.getLccy()
                YAMOUNT.POS=AC.EntryCreation.StmtEntry.SteAmountLcy
            CASE YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteCurrency>=''
                YAMOUNT.POS=AC.EntryCreation.StmtEntry.SteAmountLcy
            CASE 1
                YAMOUNT.POS=AC.EntryCreation.StmtEntry.SteAmountFcy
        END CASE
    END

* Amount of only those stmt entries which are not already printed
* should only be added to the opening balance because this would
* have already been added to account statement last balance.

    BEGIN CASE
        CASE FWD.MVMT.FLAG
            IF YR.STMT.ENTRY<STMT.DATE.FIELD> EQ "" THEN
                YOPEN.BAL +=YR.STMT.ENTRY<YAMOUNT.POS>
            END
        CASE 1
* add the amount only if the transaction is within period end
            IF YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteProcessingDate> < CLOSING.DATE THEN
                YOPEN.BAL += YR.STMT.ENTRY<YAMOUNT.POS>
            END
    END CASE
RETURN
*
*----------------------------------------------------------
READ.ENTRY:
* Read entry and check for duplicates which can happen during the eod.
*
    YR.STMT.ENTRY = ""        ;* Return null if can't read
    YR.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(YENTRY.ID, ERR)
    IF ENTRYID.LIST THEN
        ENTRYID.LIST:=@FM: YENTRY.ID
    END ELSE
        ENTRYID.LIST = YENTRY.ID
    END


RETURN
*-----------------------------------------------------------------------------
*
SORT.ENT.BY.BOOKING.DATE:
*------------------------
*
    BOOK.DATES = ""
    CONCAT.REC = Y.CONCAT.REC
    STMT.CNT = DCOUNT(CONCAT.REC,@FM)
    FOR K = 1 TO STMT.CNT
        STMT.ID = FIELD(CONCAT.REC<K>,"*",2)
        STMT.ENT.REC = ""
        STMT.ENT.REC = AC.EntryCreation.tableStmtEntry(STMT.ID, ERR)
        IF STMT.ENT.REC THEN
            IF BOOK.DATES THEN
                BOOK.DATES<-1> = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteBookingDate>
            END ELSE
                BOOK.DATES = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteBookingDate>
            END
        END
    NEXT K
*
    IF SORT.BY # 'DSND' THEN
        FOR I = 1 TO STMT.CNT-1
            FOR J = I+1 TO STMT.CNT
                IF BOOK.DATES<I> GT BOOK.DATES<J> THEN
                    TEMP.CONCAT.REC = CONCAT.REC<I>
                    TEMP.DATE = BOOK.DATES<I>
                    CONCAT.REC<I> = CONCAT.REC<J>
                    BOOK.DATES<I> = BOOK.DATES<J>
                    CONCAT.REC<J> = TEMP.CONCAT.REC
                    BOOK.DATES<J> = TEMP.DATE
                END
            NEXT J
        NEXT I
    END ELSE
        FOR I = 1 TO STMT.CNT-1
            FOR J = I+1 TO STMT.CNT
                IF BOOK.DATES<I> LT BOOK.DATES<J> THEN
                    TEMP.CONCAT.REC = CONCAT.REC<I>
                    TEMP.CONCAT.REC = CONCAT.REC<I>
                    TEMP.DATE = BOOK.DATES<I>
                    CONCAT.REC<I> = CONCAT.REC<J>
                    BOOK.DATES<I> = BOOK.DATES<J>
                    CONCAT.REC<J> = TEMP.CONCAT.REC
                    BOOK.DATES<J> = TEMP.DATE
                END
            NEXT J
        NEXT I
    END
*
    Y.CONCAT.REC = CONCAT.REC
RETURN
*
*-----------------------------------------------------------------------------------------
*
CHECK.OTH.BOOK.ACCESS:
*---------------------
*
    SUB.ACCT.PROCESS = ''     ;* Flag for sub account
    END.FLAG = "END"
    NEXT.ACCT.FLAG = ''
    R.ACCT = '' ; AC.POS = '' ; SUB.ACC.LIST = Y.AC.NO
    R.ACCT = AC.AccountOpening.tableAccount(Y.AC.NO, AC.ERR)
    IF R.ACCT THEN
        IF R.ACCT<AC.AccountOpening.Account.CoCode> NE EB.SystemTables.getIdCompany() THEN
            LOCATE R.ACCT<AC.AccountOpening.Account.CoCode> IN EB.SystemTables.getRUser()<EB.Security.User.UseOthBookAccess,1> SETTING AC.POS ELSE
                Y.AC.POS = ''
                Y.COMPANY.ID = EB.SystemTables.getRUser()<EB.Security.User.UseOthBookAccess,1>
                R.CSG = ST.CompanyCreation.tableCompanySmsGroup(Y.COMPANY.ID, ERR)
                IF R.CSG THEN
                    LOCATE R.ACCT<AC.AccountOpening.Account.CoCode> IN R.CSG<ST.CompanyCreation.CompanySmsGroup.CoSmsCompanyCode,1> SETTING Y.AC.POS ELSE
                        Y.CONCAT.REC <-1>= Y.AC.NO:"**":0
                        NEXT.ACCT.FLAG = 1
                    END
                END ELSE
                    Y.CONCAT.REC <-1>= Y.AC.NO:"**":0
                    NEXT.ACCT.FLAG = 1
                END
            END
        END
        IF R.ACCT<AC.AccountOpening.Account.MaxSubAccount> OR NOT(NUM(Y.AC.NO)) OR R.ACCT<AC.AccountOpening.Account.LimitRef> EQ 'NOSTRO' THEN ;* Sub account is default for internal & NOSTRO accounts
            R.SUB.ACC.LIST = AC.HighVolume.tableAcSubAccount(Y.AC.NO,ER)
            IF R.SUB.ACC.LIST THEN
                SUB.ACCT.PROCESS = 1    ;* Set a flag if record is there
                SUB.ACC.LIST := @FM:R.SUB.ACC.LIST
                END.FLAG = ""
            END
        END
        IF EB.Reports.getEnqSelection()<9> = "BOOKING.DATE" THEN
            SORT.FLD = "BOOKING.DATE"
        END
    END ELSE
        EB.Reports.setEnqError("AC.ACS.AC.DOES.NOT.EXIST.COMP")
    END
*
RETURN
*-----------------------------------------------------------------------------------------
GET.PROCESSING.DATE:
*
    PROCESSING.DATE = ''

    IF BOOK.FLAG THEN
        PROCESSING.DATE = YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteBookingDate>
    END ELSE
        PROCESSING.DATE = YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteProcessingDate>
    END

RETURN
*------------------------------------------------------------------------------------------
* Sort the entries based on the processing date before building the entries based on the selection criteria.
*
SORT.ENT.BY.DATE:

    GOSUB GET.DATE.FROM.ENTRIES

    FOR ENT.I = 1 TO ENTRIES.CNT
        FOR  ENT.J = 1 TO ENTRIES.CNT
            IF PROCESS.DATE.LIST<ENT.I> LT PROCESS.DATE.LIST<ENT.J> THEN
                TEMP.STMT.ID = YR.ENTRY.FILE<ENT.I>
                YR.ENTRY.FILE<ENT.I> = YR.ENTRY.FILE<ENT.J>
                YR.ENTRY.FILE<ENT.J> = TEMP.STMT.ID
                TEMP.PROCESS.DATE = PROCESS.DATE.LIST<ENT.I>
                PROCESS.DATE.LIST<ENT.I> = PROCESS.DATE.LIST<ENT.J>
                PROCESS.DATE.LIST<ENT.J> = TEMP.PROCESS.DATE
            END
        NEXT ENT.J
    NEXT ENT.I

RETURN

*---------------------------------------------------------------------------------------------
* Build Processing Date list from entries...
*
GET.DATE.FROM.ENTRIES:

    PROCESS.DATE.LIST = ''
    ENTRY.DATE = ''
    ENTRIES.CNT =  DCOUNT(YR.ENTRY.FILE, @FM)

    FOR ENT.CNT = 1 TO ENTRIES.CNT

        ENTRY.ID = YR.ENTRY.FILE<ENT.CNT>
        YR.STMT.ENTRY = ''
        YR.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(ENTRY.ID, ERR)

        IF BOOK.FLAG THEN
            ENTRY.DATE = YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteBookingDate>
        END ELSE
            ENTRY.DATE = YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteProcessingDate>
        END

        IF PROCESS.DATE.LIST THEN
            PROCESS.DATE.LIST<-1> = ENTRY.DATE
        END ELSE
            PROCESS.DATE.LIST = ENTRY.DATE
        END

    NEXT ENT.CNT
RETURN
*-----------------------------------------------------------------------------------------------------------
UPDATE.CONCAT.REC:
* if the transaction is within period end Add in the list to display

    BEGIN CASE
        CASE Y.CONCAT.REC
            Y.CONCAT.REC := @FM:Y.AC.NO:"*":YENTRY.ID:"*":YOPEN.BAL
        CASE 1
            Y.CONCAT.REC = Y.AC.NO:"*":YENTRY.ID:"*":YOPEN.BAL
    END CASE

RETURN
*------------------------------------------------------------------------------------------
*
CHECK.OPEN.BAL:
*--------------
* Check no of sub accounts is equal to balances retrieved from
* ACCT.STMT.PRINT else there is no activity in a sub account, so want
* to include that account balance too in calculating open balance.

    NO.OF.BAL = COUNT(YACCT.STMT.BAL<YPOS>, @VM)
    ACCT.LAST.BAL = 0
    IF SUB.ACCT.PROCESS AND NO.OF.ACCT NE NO.OF.BAL THEN
        GOSUB GET.NET.OPEN.BAL
    END ELSE
        YOPEN.BAL = YACCT.STMT.BAL<YPOS>
        IF YOPEN.BAL EQ '' THEN
            GOSUB GET.ENTRIES
        END
    END

RETURN
*------------------------------------------------------------------------------------------
*
GET.NET.OPEN.BAL:
*----------------
* Get the sub account balances and add with master account
* to arrive for a net balance

    LOOP
        REMOVE SUB.ACCT.NO FROM CHECK.ACCT.LIST SETTING POS
    WHILE SUB.ACCT.NO:POS
        LOCATE SUB.ACCT.NO IN YACCT.AC.NO<YPOS,1> SETTING AC.POS THEN
            ACCT.LAST.BAL += YACCT.STMT.BAL<YPOS,AC.POS>
        END ELSE
            GOSUB READ.ACCT.STMT
            IF R.ACCT.STMT<AC.AccountStatement.AccountStatement.AcStaFquOneLastDate> LE YACCT.STMT.DATES<YPOS-1> THEN
                ACCT.LAST.BAL += R.ACCT.STMT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance>
            END ELSE
                BALANCE.DATE = YACCT.STMT.DATES<YPOS>       ;* If criteria date is crossed in account statement
                BALANCE = ''  ;* then get balance from acct.activity
                ACCT.NO = SUB.ACCT.NO
                AC.API.EbGetAcctBalance(ACCT.NO, '', 'BOOKING', BALANCE.DATE, '', BALANCE, '', '', '')
                ACCT.LAST.BAL += BALANCE
            END
        END
    REPEAT
    YOPEN.BAL = ACCT.LAST.BAL
    CHECK.ACCT.LIST = CHECK.ACCT.LIST   ;* Reset the pointer

RETURN
*------------------------------------------------------------------------------------------
*
END
