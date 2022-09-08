* @ValidationCode : MjozNzEyMjIzMzg6Q3AxMjUyOjE1NjgxMTUzNjUxODU6c3RhbnVzaHJlZToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzIzLTAyNTE6MjY5OjE4Ng==
* @ValidationInfo : Timestamp         : 10 Sep 2019 17:06:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 186/269 (69.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-290</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.RMB1.LAST.N.TXNS(RETURN.ARRAY)
*-----------------------------------------------------------------------------
*
* Subroutine Type : ENQUIRY
* Attached to     : STANDARD.SELECTION>STMT.ENTRY>ENTRY.IDS field
* Attached as     : R type Idescriptor
* Primary Purpose : Get the list of months when there has been any activity on the account,
*                   then loop through each month and get entry list until we have reached
*                   the number requested for by user or we have scanned through maximum
*                   history as indicated in Fixed Selection setup.
*                   Ex, Last 10 transactions and these could have been done just yesterday
*                   or in the last 6 months
*
* Incoming:
* ---------
* D.FIELDS, D.LOGICAL.OPERAND, D.RANGE.AND.VALUE (I_ENQUIRY.COMMON Variables)
*
* Outgoing:
* ---------
* RETURN.ARRAY   :  List of Stmt. Entry IDs
*
* Error Variables:
* ----------------
* ENQ.ERROR      :  As appropriate
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 10 NOV 2010 - Sathish PS
*               Development for SI RMB1
*
* 04/05/11 - Task 203358 / Defect 154512
*            RMB1.LAST.N.TXNS.AA enquiry is not working for AA accounts
*
* 20/08/11 - ENHANCEMENT 211022 / TASK 211273
*            Acct Activity Merger for High Volume Account
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 05/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 18/11/16 - EN_1917843 / TASK_1930455
*            Support HVT for Arrangement Accounts, Incorrect account number used for
*            reading account.
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*-----------------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.API
    $USING ST.CompanyCreation
    $USING AC.AccountStatement
    $USING AC.AccountOpening
    $USING AC.HighVolume
    $USING AA.Framework

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
    IF NOT(EB.Reports.getEnqError()) AND STORED.ENTRIES.LIST THEN
        RETURN.ARRAY = STORED.ENTRIES.LIST
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    BEGIN CASE
        CASE IN.START.DATE AND IN.END.DATE
            GOSUB PROCESS.BY.DATE.RANGE

        CASE 1
            GOSUB PROCESS.BY.ACTIVITY.MONTHS
    END CASE

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
PROCESS.BY.DATE.RANGE:

    START.DATE = IN.START.DATE
    END.DATE = IN.END.DATE
    GOSUB GET.ENTRY.LIST

RETURN
*-----------------------------------------------------------------------------------
PROCESS.BY.ACTIVITY.MONTHS:

    ACCT.ACTVITY.LOOP.CNT = 0

    NO.OF.ACTIVITY.MONTHS = DCOUNT(ACCT.ACTIVITY.MONTHS,@FM)
    FOR ACT.MONTH.COUNT = NO.OF.ACTIVITY.MONTHS TO 1 STEP -1
        ACCT.ACTIVITY.MONTH = ACCT.ACTIVITY.MONTHS<ACT.MONTH.COUNT>

        IF ACCT.ACTIVITY.MONTH THEN
            GOSUB BUILD.START.AND.END.DATE
            ACCT.ACTIVITY.LOOP.CNT = ACCT.ACTIVITY.LOOP.CNT + 1       ;! Counter to keep track of how many months have we scanned
            GOSUB GET.ENTRY.LIST
            IF NOT(PROCESS.GOAHEAD) THEN
                BREAK
            END
        END

    NEXT ACT.MONTH.COUNT

RETURN
*-----------------------------------------------------------------------------------
BUILD.START.AND.END.DATE:

    START.DATE = ACCT.ACTIVITY.MONTH : "01"
*    ! Now we need to derive the Last Calendar Date for the month which could be 30 or 31 or 28 or 29
*    ! Supply an invalid date with a -1C displacement to CDT and it will give us the real last calendar
*    ! date for the month.
    END.DATE = ACCT.ACTIVITY.MONTH : "32"
    END.DATE.DISPL = "-1C"
    MY.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)
    EB.API.Cdt(MY.REGION, END.DATE, END.DATE.DISPL)

RETURN
*-----------------------------------------------------------------------------------
GET.ENTRY.LIST:

    IF START.DATE AND END.DATE THEN
        ERR.MSG = "" ; THIS.MONTH.ENTRY.LIST = ""
        SUPPLY.ACCOUNT.NUMBER = ACCOUNT.NUMBER
*        ! If the results are to be returned based on actual PROCESSING.DATE instead of BOOKING.DATE
        SUPPLY.ACCOUNT.NUMBER<2> = TXN.DATE
        AC.AccountStatement.EbAcctEntryList(SUPPLY.ACCOUNT.NUMBER, START.DATE, END.DATE, THIS.MONTH.ENTRY.LIST, OPEN.BALANCE, ERR.MSG)

        BEGIN CASE
            CASE ERR.MSG
                EB.Reports.setEnqError(ERR.MSG)
                PROCESS.GOAHEAD = 0

            CASE THIS.MONTH.ENTRY.LIST
                GOSUB STORE.THIS.MONTH.ENTRY.LIST

        END CASE

    END

RETURN
*-----------------------------------------------------------------------------------
STORE.THIS.MONTH.ENTRY.LIST:

    LAST.END.DATE = END.DATE  ;* Keep Overwriting this...

    GOSUB SORT.THIS.MONTH.ENTRY.LIST

    IF STORED.ENTRIES.LIST THEN
        STORED.ENTRIES.LIST := @FM: THIS.MONTH.ENTRY.LIST
    END ELSE
        STORED.ENTRIES.LIST = THIS.MONTH.ENTRY.LIST
    END
*
    GOSUB DETERMINE.IF.WE.SHOULD.QUIT

RETURN
*-----------------------------------------------------------------------------------
SORT.THIS.MONTH.ENTRY.LIST:

    TEMP.ENTRY.LIST = "" ; TEMP.ENTRY.COUNT = 1
    NO.OF.ENTRIES.THIS.MONTH = DCOUNT(THIS.MONTH.ENTRY.LIST,@FM)
    FOR THIS.MONTH.COUNT = NO.OF.ENTRIES.THIS.MONTH TO 1 STEP -1
        TEMP.ENTRY.LIST<TEMP.ENTRY.COUNT> = THIS.MONTH.ENTRY.LIST<THIS.MONTH.COUNT>
        TEMP.ENTRY.COUNT = TEMP.ENTRY.COUNT + 1
    NEXT THIS.MONTH.COUNT

    THIS.MONTH.ENTRY.LIST = TEMP.ENTRY.LIST

RETURN
*-----------------------------------------------------------------------------------
DETERMINE.IF.WE.SHOULD.QUIT:

    NO.OF.ENTRIES.RETRIEVED = DCOUNT(STORED.ENTRIES.LIST,@FM)

    BEGIN CASE
        CASE IN.START.DATE AND IN.END.DATE  ;! No Looping...Only one iteration. Quit after the first one.
            GOSUB FINALISE.STORED.ENTRIES
            PROCESS.GOAHEAD = 0

        CASE NO.OF.ENTRIES.RETRIEVED GE REQUIRED.ENTRY.COUNT
            GOSUB FINALISE.STORED.ENTRIES
            PROCESS.GOAHEAD = 0

        CASE (ACCT.ACTIVITY.LOOP.CNT+0) GE (MAX.HISTORY.MONTHS+0)
            GOSUB FINALISE.STORED.ENTRIES
            PROCESS.GOAHEAD = 0

    END CASE

RETURN
*-----------------------------------------------------------------------------------
FINALISE.STORED.ENTRIES:

    ENTRY.START.COUNT = 1
    IF IN.START.DATE THEN
        ENTRY.END.COUNT = NO.OF.ENTRIES.RETRIEVED ;* Don't limit to the txn threshold...
    END ELSE
        ENTRY.END.COUNT = REQUIRED.ENTRY.COUNT
    END

    FOR ENTRY.LOOP.CNT = ENTRY.START.COUNT TO ENTRY.END.COUNT
        TEMP.ENTRIES.LIST<ENTRY.LOOP.CNT> = STORED.ENTRIES.LIST<ENTRY.LOOP.CNT>
        TEMP.ENTRY.COUNT = TEMP.ENTRY.COUNT + 1
    NEXT ENTRY.LOOP.CNT

    STORED.ENTRIES.LIST = ""
    STORED.ENTRIES.LIST = TEMP.ENTRIES.LIST
*
RETURN
*----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    RETURN.ARRAY = ""
    STORED.ENTRIES.LIST = ""
    ENTRY.START.COUNT = ""
    ENTRY.END.COUNT = ""
    LOCATE.FIELD.MANDATORY = ""
    LOCATE.DEFAULT.VALUE = ""
    LOCATE.FIELD.NUMERIC = ""
    TXN.DATE = ""
    ORIG.ACCOUNT.NUMBER = ""

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    FN.AC = "F.ACCOUNT" ; F.AC = ""

RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 8
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                GOSUB GET.ACCOUNT

            CASE LOOP.CNT EQ 2
                GOSUB GET.REQUIRED.ENTRY.COUNT

            CASE LOOP.CNT EQ 3
                GOSUB GET.MAX.HISTORY.MONTHS

            CASE LOOP.CNT EQ 4
                GOSUB CHECK.PROCESSING.DATE.FLAG

            CASE LOOP.CNT EQ 5
                GOSUB GET.IN.START.DATE
                GOSUB VALIDATE.IN.START.DATE          ;! Against the Max threshold we can go back in history

            CASE LOOP.CNT EQ 6
                GOSUB GET.IN.END.DATE

            CASE LOOP.CNT EQ 7
                GOSUB LOAD.ACCOUNT.RECORD

            CASE LOOP.CNT EQ 8
                GOSUB GET.ACTIVITY.MONTHS

        END CASE

        IF EB.Reports.getEnqError() THEN
            PROCESS.GOAHEAD = 0
        END

        LOOP.CNT += 1

    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.ACCOUNT:

    LOCATE.FIELD = "RMB1.ACCOUNT"
    LOCATE.FIELD.MANDATORY = 1
    GOSUB GET.VALUE

    IF NOT(EB.Reports.getEnqError()) THEN
        ACCOUNT.NUMBER = LOCATE.VALUE
    END

RETURN
*-----------------------------------------------------------------------------------
GET.REQUIRED.ENTRY.COUNT:

    LOCATE.FIELD = "NO.OF.ENTRIES"
    LOCATE.FIELD.NUMERIC = 1
    LOCATE.DEFAULT.VALUE = 10
    GOSUB GET.VALUE

    IF NOT(EB.Reports.getEnqError()) THEN
        REQUIRED.ENTRY.COUNT = LOCATE.VALUE
    END

RETURN
*------------------------------------------------------------------------------------
GET.MAX.HISTORY.MONTHS:

    LOCATE.FIELD = "MAX.HISTORY.MONTHS"
    LOCATE.FIELD.NUMERIC = 1
    LOCATE.DEFAULT.VALUE = 12
    GOSUB GET.VALUE

    IF NOT(EB.Reports.getEnqError()) THEN
        MAX.HISTORY.MONTHS = LOCATE.VALUE
    END

RETURN
*-----------------------------------------------------------------------------------
CHECK.PROCESSING.DATE.FLAG:

* In case the list needs to be returned based on PROCESSING.DATE
    LOCATE.FIELD = "TXN.DATE"
    LOCATE.DEFAULT.VALUE = "BOOK"
    GOSUB GET.VALUE
    IF NOT(EB.Reports.getEnqError()) THEN
        TXN.DATE = LOCATE.VALUE
    END

RETURN
*-----------------------------------------------------------------------------------
GET.IN.START.DATE:

    IN.START.DATE = ""
    LOCATE.FIELD = "IN.START.DATE"
    GOSUB GET.VALUE
    IF NOT(EB.Reports.getEnqError()) THEN
        IN.START.DATE = LOCATE.VALUE
    END

RETURN
*-----------------------------------------------------------------------------------
VALIDATE.IN.START.DATE:

    IF IN.START.DATE THEN
*         Assuming TODAY is 2000 05 11 and IN.START.DATE is 1999 10 31
*
*         2000
        MAX.HISTORY.YYYY = EB.SystemTables.getToday()[1,4]
*         05
        MAX.HISTORY.MM = EB.SystemTables.getToday()[5,2]
*         -1
        MAX.HISTORY.MM = MAX.HISTORY.MM - 6
        IF MAX.HISTORY.MM LE 0 THEN
*            1999
            MAX.HISTORY.YYYY = MAX.HISTORY.YYYY - 1
*             12 + (-1) = 11
            MAX.HISTORY.MM = 12 + MAX.HISTORY.MM
*             (19)99 GT (20)10
            IF MAX.HISTORY.YYYY[3,2] GT EB.SystemTables.getToday()[3,2] THEN
*                 20 - 1 = 19
                MAX.HISTORY.YYYY[1,2] = MAX.HISTORY.YYYY[1,2] - 1
            END
        END
*         1999 11 11
        MAX.HISTORY.DATE = MAX.HISTORY.YYYY : STR("0",2-LEN(MAX.HISTORY.MM)) : MAX.HISTORY.MM : EB.SystemTables.getToday()[7,2]
*         1999 10 31 LT 1999 11 11 and will result in an error
        IF IN.START.DATE LT MAX.HISTORY.DATE THEN
            EB.Reports.setEnqError("EB-RMB1.START.DATE.OUT.OF.RANGE")
            tmp=EB.Reports.getEnqError(); tmp<2,1>=MAX.HISTORY.MONTHS; EB.Reports.setEnqError(tmp)
        END
    END

RETURN
*-----------------------------------------------------------------------------------
GET.IN.END.DATE:

    IN.END.DATE = ""
    LOCATE.FIELD = "IN.END.DATE"
    GOSUB GET.VALUE
    IF NOT(EB.Reports.getEnqError()) THEN
        IN.END.DATE = LOCATE.VALUE
        IF NOT(IN.END.DATE) AND IN.START.DATE THEN
            IN.END.DATE = EB.SystemTables.getToday()
        END
    END

RETURN
*-----------------------------------------------------------------------------------
GET.VALUE:

    LOCATE.VALUE = ""
    LOCATE LOCATE.FIELD IN EB.Reports.getDFields()<1> SETTING FLD.FOUND.POS THEN
        IF EB.Reports.getDLogicalOperands()<FLD.FOUND.POS> EQ 1 THEN
            LOCATE.VALUE = EB.Reports.getDRangeAndValue()<FLD.FOUND.POS>
        END ELSE
            EB.Reports.setEnqError("EB-RMB1.OPERAND.MUST.BE.EQ.FOR.":LOCATE.FIELD)
        END
    END ELSE
        IF LOCATE.FIELD.MANDATORY THEN
            EB.Reports.setEnqError("EB-RMB1.":LOCATE.FIELD:".MANDATORY")
        END
    END
*
    BEGIN CASE
        CASE LOCATE.FIELD.NUMERIC
            IF LOCATE.VALUE AND NOT(NUM(LOCATE.VALUE)) THEN
                EB.Reports.setEnqError("EB-RMB1.":LOCATE.FIELD:".NOT.NUMERIC")
            END

        CASE NOT(LOCATE.VALUE)
            LOCATE.VALUE = LOCATE.DEFAULT.VALUE
    END CASE

    LOCATE.FIELD.MANDATORY = ""
    LOCATE.FIELD.NUMERIC = ""
    LOCATE.DEFAULT.VALUE = ""

RETURN
*-----------------------------------------------------------------------------------
LOAD.ACCOUNT.RECORD:

    R.ACCOUNT.RECORD = "" ; ERR.AC = ""
    R.ACCOUNT.RECORD = AC.AccountOpening.tableAccount(ACCOUNT.NUMBER,ERR.AC)
    IF ERR.AC THEN
        EB.Reports.setEnqError("EB-RMB1.REC.MISS.FILE")
        tmp=EB.Reports.getEnqError(); tmp<2,1>=ACCOUNT.NUMBER; EB.Reports.setEnqError(tmp)
        tmp=EB.Reports.getEnqError(); tmp<2,2>=FN.AC; EB.Reports.setEnqError(tmp)
    END

RETURN
*-----------------------------------------------------------------------------------
GET.ACTIVITY.MONTHS:

    IF NOT(IN.START.DATE) THEN
        ACCT.ACTIVITY.MONTHS = ""
*        !
*        ! This will return the list of YYYYMMs when there has been any activity on the account
*        ! in an FM delimited array (as stored in EB.CONTRACT.BALANCES)
*        !

        IF R.ACCOUNT.RECORD<AC.AccountOpening.Account.ArrangementId> THEN ;*For arrangement account
            ARRANGEMENT.ID = R.ACCOUNT.RECORD<AC.AccountOpening.Account.ArrangementId>
            DUMMY.AA.ITEM.REF = "*****DIRECT*" ;* Arguments of AA.GET.BALANCE.TYPE is changed, so added the required arguments
            AA.Framework.GetBalanceType('ACCOUNT', ARRANGEMENT.ID, BALANCE.TYPE, DUMMY.AA.ITEM.REF,'','',RET.ERROR)  ;* Get the CUR Balance type for Account property class
            IF BALANCE.TYPE THEN
                ORIG.ACCOUNT.NUMBER = ACCOUNT.NUMBER
                ACCOUNT.NUMBER = ACCOUNT.NUMBER:'.':BALANCE.TYPE
            END
        END

        GOSUB GET.ACCT.ACTIVITY.DATES
        IF NOT(ACCT.ACTIVITY.MONTHS) THEN
            PROCESS.GOAHEAD = 0
        END

        IF ORIG.ACCOUNT.NUMBER THEN
            ACCOUNT.NUMBER = ORIG.ACCOUNT.NUMBER  ;*Resume the original account number
        END
    END

RETURN
*------------------------------------------------------------------------
GET.ACCT.ACTIVITY.DATES:
*----------------------

    ACCT.ACTIVITY.MONTHS = '' ; REC.ACCOUNT = ''
    REC.ACCOUNT = AC.AccountOpening.Account.Read(ORIG.ACCOUNT.NUMBER,YERR)

    HVT.PROCESS = ''
    AC.HighVolume.CheckHvt(ORIG.ACCOUNT.NUMBER,REC.ACCOUNT, '', '', HVT.PROCESS, '', '', ERR)

* Removed the direct check for HVT.FLAG in account record, use the common routine
* to check the HVT flag, since the when the AC.HVT.PARAMETER is setup HVT.FLAG will not be
* defaulted by the system in the account, dynamically HVT flag is decided based on parameter

    IF HVT.PROCESS EQ 'YES' THEN
        ACTIVITY.DETAILS = ''
        ACTIVITY.DETAILS = 'ALL'    ;* Set this flag to return all the acct activity details
        AC.HighVolume.EbReadHvt('ACCT.ACTIVITY', ACCOUNT.NUMBER, ACTIVITY.DETAILS, '')       ;* Call the core api to get the merged info for HVT accounts
        ACCT.ACTIVITY.MONTHS = RAISE(ACTIVITY.DETAILS<3>)
    END ELSE
        EB.API.GetActivityDates(ACCOUNT.NUMBER,ACCT.ACTIVITY.MONTHS)
    END

RETURN
*-----------------------------------------------------------------------------------

END
