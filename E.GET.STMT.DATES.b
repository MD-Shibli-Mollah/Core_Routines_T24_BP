* @ValidationCode : MjotMTM4ODI4NTg3MTpDcDEyNTI6MTU5OTY0MTAyNjE0MTpzLnNvbWlzZXR0eWxha3NobWk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4wOjk4Ojc5
* @ValidationInfo : Timestamp         : 09 Sep 2020 14:13:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 79/98 (80.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 2 29/09/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-140</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.GET.STMT.DATES
*-----------------------------------------------------------------------------
*
** This will return the contents of ACCT.STMT.PRINT
** concatfile as 2 multi value fields for use in the enquiry
** It will also add the current statement period
*
* 06/01/02 - GLOBUS_EN_10000302
*            Changes made to include forward value dated statement
*            entries in the enquiry
*
* 17/11/05 - GLOBUS_BG_100009702
*            Changes done to display output corretly due to
*            online updation of account statement concat files.
*
* 16/11/10 - Task 108371
*            Output of the ACCT.STMT.HIST enquiry includes even the future date
*            with today's balance and also displays same date twice.
*
* 20/12/10 - Task 120096
*            System is producing incorrect stmt for the closed account
*
*10/02/11 - Task 149253
*           IF.NO.MOVEMENT set to Y in the ACCOUNT.STATEMENT and there is
*           no movement for the last frequency and some movements for the current frequency
*           then the system shows the incorrect closing balance in ENQ ACCT.STMT.HIST
*
* 25/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 10/0811 - EN 211023 / Task 211287
*           Coding to do special processing for HVT accounts.
*
* 20/12/11 - Defect 317815 / Task 321606
*            The enquiry ACCT.STMT.HIST is not showing current period balance.
*
*04/02/12 - Defect 33118 / Task 333656
*           Changes done to correct compliation error.
*
* 17/01/12 - DEFECT 339165 / TASK 340566
*            The enquiry ACCT.STMT.HIST is hanging when it is run for an account which
*            does not have transaction for the current period.
*
* 30/01/12 - Defect 323305 / Task - 347350
*            Uninitialised variables error correction.
*
* 02/02/12 - DEFECT 339165 / TASK 365379
*            ACCT.STMT.HIST does not produces correct results if account does not have any transactions
*
* 10/05/13 - Defect 666204 / Task 673007
*            Changes done to show the current frequncy (Today's date) information
*            when there are no entries for the current frequency period
*
* 4/09/13 -  Defect  766355 / Task 774370
*             For closed Accounts, the Account details will be moved the History file
*             (ACCOUNT$HIS, ACCOUNT.STATEMENT$HIS) and so the Variable CURR.FQU.DATES will
*             not be set and showing the null record in the Enquiry Output.
*
* 13/03/14 - Defect 929011/ TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/08/18 - Defect 2736533 / TASK 2746834
*            Enquiry MB.ACCT.STMT.HIST is not displaying results for passbook accounts
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*-------------------------------------------------------------------------
*
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.AccountStatement
    $USING AC.HighVolume
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB READ.ACCOUNT.FILES  ;*Read required account files
    GOSUB GET.CURRENT.FREQ
    GOSUB PROCESS.ACC.STMT.PRINT

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*----------
    
    ACCOUNT.NO = EB.Reports.getOData()

    R.TEMP.RECORD = ''
 
    EB.Reports.setRRecord('')
    
    Y.STMT.DATE = ''
    Y.STMT.BAL = ''
    R.ACCT.STMT.PRINT = ''
    ACCT.STMT.PRINT.ERR = ''
    ACC.ERR = ''
    R.ACCOUNT = ''
    R.ACCOUNT.STATEMENT = ''
    ACCOUNT.STATEMENT.ERR = ''
    HVT = ''
    HVT.INFO = ''
    CURR.FQU.DATES = ''
    CURR.FREQ = ''
    SUB.MARK.COUNT = ''
RETURN
*-------------------------------------------------------------------------------------
OPEN.FILES:
*----------

RETURN
*----------------------------------------------------------------------------------
READ.ACCOUNT.FILES:
*------------------
*Read ACCT.STMT.PRINT, ACCOUNT.STATEMENT, and ACCOUNT record for the given account no.
*
* Removed the direct check for HVT.FLAG in account record, use the common routine
* to check the HVT flag, since the when the AC.HVT.PARAMETER is setup HVT.FLAG will not be
* defaulted by the system in the account, dynamically HVT flag is decided based on parameter
* EB.READ.HVT has the logic to check the HVT flag and return the required information

    R.ACCT.STMT.PRINT = ''

*CALLING AC.READ.ACCT.STMT.PRINT INSTEAD OF ACCT.STMT.PRINT
    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=ACCOUNT.NO
    InDetails<3>=''
    RequestMode='MERGE.HVT'
    LockRecord='No'
    AddlInfo=''
    ReservedIn=''
    AcctStmtRecord=''
    StmtSeqIndicator=''
    ErrorDetails=''
    ReservedOut=''
    AC.AccountStatement.acReadAcctStmtPrint(InDetails, RequestMode, LockRecord, AddlInfo, ReservedIn, AcctStmtRecord, StmtSeqIndicator, ErrorDetails, ReservedOut)
    R.ACCT.STMT.PRINT=AcctStmtRecord


    R.ACCOUNT.STATEMENT = AC.AccountStatement.tableAccountStatement(ACCOUNT.NO,  ACCOUNT.STATEMENT.ERR)

    IF R.ACCOUNT.STATEMENT EQ '' THEN
        YERROR = ''
        AC.AccountStatement.AccountStatementHistRead(ACCOUNT.NO,R.ACCOUNT.STATEMENT, YERROR)
    END

RETURN
*-------------------------------------------------------------------------------
GET.CURRENT.FREQ:
*---------------
* Get Minimum Frequency date ,if there is more than one AccountStatement
    FQU.CNT = DCOUNT(R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaStmtFquOne>,@VM)
    FOR FQU.ID = 1 TO FQU.CNT
        CURR.FQU.DATES<-1> = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaStmtFquOne,FQU.ID>[1,8]
    NEXT FQU.ID
    CURR.FREQ = MINIMUM(CURR.FQU.DATES)

* When PASSBOOK for an account is changed to Y and the ACCOUNT.STATEMENT frequency is BSNSS
* then during COB the current frequent in ACCOUNT.STATEMENT is set to NULL. During such case CURR.FREQ is set as Last Date of Freq.1

    IF CURR.FREQ EQ 0 THEN
        CURR.FREQ = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastDate>
    END

RETURN
*----------------------------------------------------------------------------------
PROCESS.ACC.STMT.PRINT:
*----------------------
    
    R.TEMP.RECORD<1> = LOWER(FIELDS(R.ACCT.STMT.PRINT,"/",1))         ;* Dates
    R.TEMP.RECORD<2> = LOWER(FIELDS(R.ACCT.STMT.PRINT,"/",2))         ;* Opening balance

    Y.STMT.CNT = DCOUNT(R.TEMP.RECORD<1>,@VM)      ;*No of dates
    LAST.CLOSE.BAL = 0

    LOOP.I = 0
    LOOP
        LOOP.I += 1
    UNTIL R.TEMP.RECORD<1, LOOP.I> EQ ''
        IF R.TEMP.RECORD<1, LOOP.I> LE CURR.FREQ THEN
            Y.STMT.DATE = R.TEMP.RECORD<1, LOOP.I>
            Y.STMT.BAL = R.TEMP.RECORD<2, LOOP.I>
            GOSUB FORM.R.RECORD
        END
    REPEAT
    VM.CNT = DCOUNT(EB.Reports.getRRecord()<1>,@VM)
    EB.Reports.setVmCount(VM.CNT)


    IF EB.Reports.getVmCount() THEN          ;* Get the last closing balance
        LAST.CLOSE.BAL = EB.Reports.getRRecord()<3,EB.Reports.getVmCount()>
    END

    IF EB.Reports.getRRecord()<1,EB.Reports.getVmCount()> LT EB.SystemTables.getToday() THEN         ;* When there no current frequency information
        tmp=EB.Reports.getRRecord(); tmp<1,-1>=EB.SystemTables.getToday(); EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<2,-1>=LAST.CLOSE.BAL; EB.Reports.setRRecord(tmp);* Last closing balance is used for todays opening balance
        tmp=EB.Reports.getRRecord(); tmp<3,-1>=''; EB.Reports.setRRecord(tmp);* Closing balance will not be shown for current frequency period, drill down option to be used
        EB.Reports.setVmCount(EB.Reports.getVmCount()+ 1)
    END

RETURN

*-------------------------------------------------------------------------------
FORM.R.RECORD:
*-------------
*Form R.RECORD with date, opening balance and closing balance
*
    IF Y.STMT.DATE AND (Y.STMT.DATE LT EB.SystemTables.getToday() OR Y.STMT.DATE EQ 'PASSBOOK') THEN
        tmp=EB.Reports.getRRecord(); tmp<1,-1>=Y.STMT.DATE; EB.Reports.setRRecord(tmp);*Stmt date
        tmp=EB.Reports.getRRecord(); tmp<2,-1>=Y.STMT.BAL; EB.Reports.setRRecord(tmp);*Opening Balance
        GOSUB GET.CLOSING.BALANCE
    END ELSE
        tmp=EB.Reports.getRRecord(); tmp<1,-1>=EB.SystemTables.getToday(); EB.Reports.setRRecord(tmp);* Changes done to handle value dated system where there will be future valued information updated in ACCT.STMT.PRINT
        tmp=EB.Reports.getRRecord(); tmp<2,-1>=Y.STMT.BAL; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<3,-1>=''; EB.Reports.setRRecord(tmp);* Closing balance will not be shown for current frequency period, drill down option to be used
    END

RETURN
*---------------------------------------------------------------------------------
GET.CLOSING.BALANCE:
*-------------------
* To arrive at closing balance, check if opening balance exist for the next period else get
* the account statements last frequency balance
*
* In a Value dated system when there are future dated transactions and if Forward movement required is set,
* then the online actual balance will not be the actual closing balance for the last period.
* Take the last balance from account statement.

    BEGIN CASE
        CASE R.TEMP.RECORD<2, LOOP.I+1> NE ''         ;* If next opening balance exist
            tmp=EB.Reports.getRRecord(); tmp<3,-1>=R.TEMP.RECORD<2, LOOP.I+1>; EB.Reports.setRRecord(tmp);* Add it as closing balance

        CASE R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance>      ;* When last balance is available in account statement
            tmp=EB.Reports.getRRecord(); tmp<3,-1>=R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance>; EB.Reports.setRRecord(tmp);* Add it as closing balance for the last frequency

        CASE 1
            tmp=EB.Reports.getRRecord(); tmp<3,-1>=0; EB.Reports.setRRecord(tmp)
    END CASE

RETURN
*-----------------------------------------------------------------------
END

