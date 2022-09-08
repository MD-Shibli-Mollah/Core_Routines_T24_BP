* @ValidationCode : MjotMTk5NjUzNzY0NTpDcDEyNTI6MTYxMjUxMjEyODEyNTpzLnNvbWlzZXR0eWxha3NobWk6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMi4yMDIxMDEyMS0xMzE2OjE4OToxNzk=
* @ValidationInfo : Timestamp         : 05 Feb 2021 13:32:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 179/189 (94.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>242</Rating>
*-----------------------------------------------------------------------------
* Version 5 18/05/01  GLOBUS Release No. G12.0.00 29/06/01
*
$PACKAGE AC.ModelBank

SUBROUTINE E.ACCOUNT.FWD.ENTRIES(ID.LIST)
*
*------------------------------------------------------------------------
* Enquiry/Standard Selection routine to return all entries forward
* valued from today.
* The actual start date for search will be today - the
* forward value maximum. Ie they could have put in an entry value
* tomorrow booked 60 days ago - unlikely but you never know. This
* routine will return all entry ids from that start date and
* yesterdays value dated balance.
*
*
* D.FIELDS          - Selection Fields
* D.OPERANDS        - EQ, GT etc
* D.RANGE.AND.VALUE - Data to match
*
* O.DATA            - Yesterdays value dated balance.
*
* 10/08/93 - GB9301269
*            STMT.PRINTED records can be null if a statement is produced
*            regardless of movements.
*
* 03/01/96 - GB96000005
*            Use STMT.VAL.ENTRY to extract TODAY entries when value dated
*            accounting is in use.
*
* 25/01/05 - CI_10026665
*            ENQUIRY PGM.FWD.BAL is not returning data in jBase.
*            Hence the conversion format of OCONV is changed,
*            to work in both jBase and Universe.
*
* 17/03/05 - BG_100008381
*            Transactions are doubled in ENQ NOSTRO.FWD.BAL b'cos of
*            ACCT.STMT.ENTRY updated online.
*
* 07/10/05 - CI_10032366
*            Enquiry NOSTRO.FWD.BAL doesn't display all the fwd entries,when it
*            got already printed. To solve this issue,
*            1)conversion format for Start.date in OCONV is changed,
*            2)Start.date is assigned the value of Last.working.date,if the calculated start.date
*            is GT Last.working.date(this happens after weekend).
*            3)And finally DATE.EXPOSURE is read, in which the stmt.ids exist till the value.date,
*            and thus all the forward entries are taken for enquiry display.
*            Also the entries that got realised during start.of.day is added to the balance
*            which is brought forward, when running the enquiry, instead of displaying it in the
*            enquiry result without having added to the balance brought forward(followed previously).
*
* 25/10/05 - BG_100009585
*            As STMT.PRINTED is updated online , no need ADD.ENTRIES.TO.BE.PRINTED
*            section which reads ACCT.STMT.ENTRY which no longer exists.
*
* 18/07/05 - EN_10003010
*            Remove of ENT.TODAY/LWORK.DAY files
*            Ref : SAR-2005-05-20-005
*
* 28/02/07 - EN_10003231
*            Replaced select statement with programatic filter as the
*            select was incompatible with DAS.
*
* 07/05/09 - CI_10062655
*            In value dated system,future value dated real entries are not displayed in NOSTRO.FWD.BAL enq
*            Changes done in ADD.FWD.AND.TODAYS.ENTRIES such that to include those entries from ACCT.ENT.TODAY
*
* 01/07/09 - CI_10063230(CSS REF:HD0918565)
*            Since ACCT.ENT.TODAY can be switched off,replaced it with a call to EB.ACCT.ENTRY.LIST.
*
* 29/12/09 - BG_100026370
*            NOSTRO.FWD.BAL enquiry is not displayed for future dated entries in 200912.
*            In the upgraded area (G132 to 200912), Enquiry is getting fatal out.
*
* 05/08/11 - ENHANCEMENT 211024 / TASK 211300
*            For HVT.ACCT get ACCT.ENT.FWD record from AC.HVT.TRIGGER file
*            so call EB.READ.HVT to the required record
*
* 09/08/11 - ENHANCEMENT 211041 / TASK 211313
*              ACCT.ENT.TODAY and STMT.VAL.ENTRY update and merger for high volume accounts
*
* 10/08/11 - EN 211023 / Task 211287
*           Coding to do special processing for HVT accounts.
*
* 15/08/2011 - ENHANCEMENT 211024 / TASK 279325
*              DATE.EXPOSURE merger and update for HVT accounts
*
* 08/12/11 - Defect 320332 / Task 321287
*            Enqiries related to STMT.ENTRY is not working.
*
* 27/12/11 - Defect 323305 /Task 330324
*            Initializing uninitialized variables
*
* 09/01/12 - Defect 336186 / Task 336189
*            Uninitialised variable error correction.
*
* 24/01/12 - Defect 323305 / Task 342045
*            Changes done to get correct entries for HVT accounts.
*
* 5/12/12 -  Defect 530508 / Task 534757
*            When FORWARD.MVMT.REQ is set to YES then the forward entries produced in previous
*            statement period is not displayed in the enquiry NOSTRO.FWD.BAL. So need
*            to call EB.ACCT.ENTRY.LIST with START.DATE equal to today minus maximum forward days
*            so that all entries between START.DATE and END.DATE will be returned and the entries
*            with processing date less than today date will be further filtered out by CONCAT.LIST.PROCESSOR
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 21/07/14 - Enhancement 956920 / Task 1033589
*            Changes done to use EB.READ.HVT core API inorder to get the latest record
*            for HVT accounts.
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/12/16 - Defect 1959373 / Task 1971034
*            Changes done to return all forward valued entries from today's date instead of reading
*            all the previous month entries from today's date.
*
* 05/07/17 - Defect 2168552 / Task 2184047
*            STMT.VAL.ENTRY has to be read only if UPD.STMT.VAL.ENTRY in Account Parameter is set.
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
* 19/06/2020 - Defect 3710886 / Task 3807443
*              NOSTRO.FWD.BAL enquiry is not displaying entries properly when the system is mixed.
*              For example whole system is value dated and particular application is trade dated.
*              Entries are properly displayed by getting all the STMT.VAL.ENTRY for the account.
*
* 15/07/2020 - Defect 3855298 / Task 3856463
*              When there are multiple entries listed from DAS, only the first entry is considered
*              for checking value date resulting in entries not displayed properlly while running
*              the enquiry. Modifications done to display the all entries properly.
*
*
* 05/02/21- Enhancement 3760081 / Task 4133519
*          New routine AC.READ.ACCT.STMT.PRINT to read the records from STMT.PRINTED and STMT2.PRINTED
*          instead of STMT.PRINTED.READ and STMT2.PRINTED.READ and AC.SPLIT.ACCT.STMT.PRINT to update
*          STMT.PRINTED and STMT2.PRINTED.
*------------------------------------------------------------------------------------------------------------------------
*
    $USING AC.AccountOpening
    $USING AC.HighVolume
    $USING AC.EntryCreation
    $USING AC.CashFlow
    $USING EB.Utility
    $USING AC.Config
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.ModelBank
    $USING AC.AccountStatement
    $USING EB.DataAccess
    $INSERT I_DAS.STMT.VAL.ENTRY
    $INSERT I_DAS.STMT.VAL.ENTRY.NOTES
*
*------------------------------------------------------------------------
*
*
    GOSUB INITIALISATION
    GOSUB BUILD.STMT.PRINTED.LIST
    GOSUB SELECT.FUTURE.ENTRIES
    GOSUB ADD.TODAY.ENTRIES
    GOSUB ADD.FWD.ENTRIES
    GOSUB ADD.DATE.EXPOSURE
*
    GOTO PROGRAM.END
*
*------------------------------------------------------------------------
*
INITIALISATION:
*
*
    FORWARD.MVMT.REQ = ''
    R.AC.PARAM = '' ; AC.PARAM.ERR = ''
    R.AC.PARAM = AC.AccountStatement.tableAcStmtParameter("SYSTEM", AC.PARAM.ERR)
    IF R.AC.PARAM<AC.AccountStatement.AcStmtParameter.AcStpFwdMvmtReqd>[1,1] = 'Y' THEN
        FORWARD.MVMT.REQ = 1
    END
    FROM.DATE = ''
    ENTRY.POS = ''
    EXIST.POS = ''
    STMT.ID = ''
    HVT =''
    HVT.INFO = ''
*
    LOCATE "ACCOUNT.ID" IN EB.Reports.getDFields()<1> SETTING POS THEN
        ACCOUNT.NUM = EB.Reports.getDRangeAndValue()<POS>          ;* Only one account AND MUST be EQ
    END
*
    R.ACCOUNT.RECORD = ''
    R.ACCOUNT.RECORD = AC.AccountOpening.tableAccount(ACCOUNT.NUM, AC.ERR)
*
* Removed the direct check for HVT.FLAG in account record, use the common routine
* to check the HVT flag, since the when the AC.HVT.PARAMETER is setup HVT.FLAG will not be
* defaulted by the system in the account, dynamically HVT flag is decided based on parameter
    HVT.PROCESS = ''
    AC.HighVolume.CheckHvt(ACCOUNT.NUM, R.ACCOUNT.RECORD, '', '', HVT.PROCESS, '', '', ERR)
*
    ID.LIST = ""    ;* List of keys returned
    SAVED.LIST.KEY = "NFB": EB.SystemTables.getTno()         ;* Used for preselection
*

    AC.ModelBank.AcGetStartDate(ACCOUNT.NUM, FORWARD.MVMT.REQ, ENQ.START.DATE,AC.ERR)
    
    VD.SINCE = EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedSince>          ;* Start of value dating
*
RETURN
*
*------------------------------------------------------------------------
*
BUILD.STMT.PRINTED.LIST:
*
* Get a list of all entries (already on a statement) from and
* including the start date.
* If the calculated start date is after the value dated since date we can
* simply read STMT.VAL.ENTRY for today's date for the account. In a non value
* dated, or recently switched on value dated system there may be forward value
* entries already printed so we must still use the standard concat files
*
* Only when UPD.STMT.VAL.ENTRY is switched on in ACCOUNT.PARAMETER, STMT.VAL.ENTRY will
* be updated. Otherwise STMT.VAL.ENTRY will be null. So at that case, entries has to be
* fetched from ACCT.STMT.PRINT.
*
* There can be mixed system as well (i.e.) whole system in one system and particular
* application in one system in which case some entries will not be displayed properly.
* Thus all the STMT.VAL.ENTRY is retrieved and displayed as per value date accordingly.

    UPD.STMT.VAL.ENTRY = EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParUpdStmtValEntry>

    IF VD.SINCE AND VD.SINCE LT ENQ.START.DATE AND UPD.STMT.VAL.ENTRY EQ 'YES' THEN
        GOSUB GET.STMT.VAL.ENTRY
    END ELSE
        GOSUB GET.ACCT.STMT.PRINT
*
        LOOP
            REMOVE ACCT.STMT.DATE FROM R.ACCT.STMT.PRINT SETTING POS
        WHILE ACCT.STMT.DATE:POS
            EB.Reports.setId(ACCT.STMT.DATE)
            GOSUB GET.STMT.PRINTED

            IF R.STMT.PRINTED THEN      ;* Could be null
                ID.LIST<-1> =  R.STMT.PRINTED
            END

        REPEAT
*
    END
*
RETURN
*
*------------------------------------------------------------------------
GET.STMT.VAL.ENTRY:
*
* Get all the STMT.VAL.ENTRY records for the account and get the respective entry Ids.

    TABLE.NAME = 'STMT.VAL.ENTRY'
    TABLE.SUFFIX = ''
    SELECTED.LIST = dasStmtValEntryIdLike
    THE.ARGS = ACCOUNT.NUM
    EB.DataAccess.Das(TABLE.NAME, SELECTED.LIST, THE.ARGS, TABLE.SUFFIX)
    
* Loop through the number of records and get value date to update ID.LIST accordingly.

    NO.OF.RECS = DCOUNT(SELECTED.LIST, @FM)
    FOR CNT = 1 TO NO.OF.RECS
        VAL.DATE = FIELD(SELECTED.LIST<CNT>, "-", 2)
        GOSUB UPDATE.ID.LIST   ;* To update ID.LIST based on value date
    NEXT CNT

RETURN
*
*------------------------------------------------------------------------
*
UPDATE.ID.LIST:
*
* Get the records with Value date greater than or equal to today

    RET.ID.LIST = ""
    IF VAL.DATE GE EB.SystemTables.getToday() THEN
        AC.HighVolume.EbReadHvt('STMT.VAL.ENTRY', ACCOUNT.NUM:"-":VAL.DATE, RET.ID.LIST, '')
    END

* Check for duplicate entries and add to the ID.LIST

    IF RET.ID.LIST THEN
        LOCATE RET.ID.LIST IN ID.LIST<1> SETTING AVL.POS ELSE
            ID.LIST<-1> = RET.ID.LIST
        END
    END
    
RETURN
*
*-----------------------------------------------------------------------------
*
SELECT.FUTURE.ENTRIES:
*
    FWD.ID.LIST = ID.LIST
    ID.LIST = ""
    LOOP
        REMOVE ID.STMT.ENTRY FROM FWD.ID.LIST SETTING FWD.ID.MARK
    WHILE ID.STMT.ENTRY : FWD.ID.MARK DO
        R.STMT.ENTRY = ""
        YERR = ""
        R.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(ID.STMT.ENTRY, YERR)
        IF R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteValueDate> GE EB.SystemTables.getToday() THEN
            ID.LIST<-1> = ID.STMT.ENTRY
        END
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
*
ADD.TODAY.ENTRIES:
*
* Add entries raised today.
*
* For value dated system entries are obtained from STMT.VAL.ENTRY with the id as ACCOUNT-TODAY
* which holds only today's dated entries.
* Hence,entries with value date as future and booking date as today is not included.
* Changes done here to include those entries.
* Since ACCT.ENT.TODAY can be switched off,code to get the entries from ACCT.ENT.TODAY is
* replaced with a call to EB.ACCT.ENTRY.LIST with the type as "PROCESS" to get the entries with
* processing date greater than or equal to TODAY.
    ACCOUNT.NUMBER = ""
    ACCOUNT.NUMBER<1> = ACCOUNT.NUM
    ACCOUNT.NUMBER<2> = "PROCESS"
    ACCOUNT.NUMBER<3> = 'FWD.VD.ENTRY'
    ENQ.END.DATE = ""
    OPENING.BAL = ""
    ER = ""
    IF FORWARD.MVMT.REQ THEN
*
* When forward movement reqd is set then pass START.DATE as FROM.DATE so that forward dated txns
* done in previos statement period will also be selected.
*
        FROM.DATE = ENQ.START.DATE
    END ELSE
        FROM.DATE = EB.SystemTables.getToday()
    END

    AC.AccountStatement.EbAcctEntryList(ACCOUNT.NUMBER,FROM.DATE,ENQ.END.DATE,AET.LIST,OPENING.BAL,ER)

    LOOP
        REMOVE STMT.ID FROM AET.LIST SETTING ENTRY.POS
    WHILE STMT.ID:ENTRY.POS
        IF ID.LIST THEN
            LOCATE STMT.ID IN ID.LIST<1> SETTING EXIST.POS ELSE
                ID.LIST := @FM:STMT.ID
            END
        END ELSE
            ID.LIST = STMT.ID
        END
    REPEAT

RETURN
*
*------------------------------------------------------------------------
*
ADD.FWD.ENTRIES:
*
* Add fwd entries
*
* For HVT account call merger to get the latest info
*Call generic EB.READ.HVT to get the ACCT.ENT.FWD record
    AC.HighVolume.EbReadHvt('ACCT.ENT.FWD', ACCOUNT.NUM, R.ACCT.ENT.FWD,ERR)
    IF R.ACCT.ENT.FWD THEN
        IF ID.LIST THEN
            ID.LIST := @FM: R.ACCT.ENT.FWD
        END ELSE
            ID.LIST = R.ACCT.ENT.FWD
        END
    END
*
*------------------------------------------------------------------------
*
PROGRAM.END:
*
RETURN
*
*------------------------------------------------------------------------
*
ADD.DATE.EXPOSURE:

    IF VD.SINCE THEN
        RETURN
    END

    accountExposureDates = ''
    responseDetails = ''
    accountKey = ACCOUNT.NUM
    AC.CashFlow.AccountserviceGetexposuredetails(accountKey, accountExposureDates, responseDetails)

    EXP.DATE = '' ; EXP.DELIM = '' ; EXP.KEY = ''
    EXPOSURE.DATES = accountExposureDates<AC.CashFlow.ExposuredetailsExposuredates>

    IF EXPOSURE.DATES ELSE
        RETURN
    END

    CONVERT @VM TO @FM IN EXPOSURE.DATES

    LOOP
        REMOVE EXP.DATE FROM EXPOSURE.DATES SETTING EXP.DELIM
    WHILE EXP.DATE:EXP.DELIM

        IF EXP.DATE >= ENQ.START.DATE THEN
            EXP.KEY = ACCOUNT.NUM:'-':EXP.DATE
            EB.SystemTables.setEtext(''); R.DATE.EXPOSURE = '' ; RET.ERR = ''
            STMT.ID = '' ; NUM.DELIM = ''
* For HVT account call merger to get the latest info
*Call generic EB.READ.HVT to get the DATE.EXPOSURE record
            AC.HighVolume.EbReadHvt('DATE.EXPOSURE',EXP.KEY, R.DATE.EXPOSURE,RET.ERR)
            IF RET.ERR THEN
                EB.SystemTables.setEtext('AC.RTN.REC.MISS')
                R.DATE.EXPOSURE = ''
            END
            LOOP
                REMOVE STMT.ID FROM R.DATE.EXPOSURE SETTING NUM.DELIM
            WHILE STMT.ID:NUM.DELIM
                LOCATE STMT.ID IN ID.LIST SETTING STMT.POS THEN
                    EB.Reports.setIdFound(STMT.POS)
                END ELSE
                    EB.Reports.setIdFound(0)
                END
                IF NOT(EB.Reports.getIdFound()) THEN
                    IF ID.LIST THEN
                        ID.LIST := @FM: STMT.ID
                    END ELSE
                        ID.LIST = STMT.ID
                    END
                END
            REPEAT
        END
    REPEAT

RETURN

*------------------------------------------------------------------------
GET.ACCT.STMT.PRINT:
*******************

    R.ACCT.STMT.PRINT = ""
*HVT.INFO = ''

    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=ACCOUNT.NUM
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
    R.ACCT.STMT.PRINT = AcctStmtRecord

    Y.DATES = FIELDS(R.ACCT.STMT.PRINT,"/",1)

    LOCATE ENQ.START.DATE IN Y.DATES BY "AL" SETTING POS ELSE
        NULL
    END

    R.ACCT.STMT.PRINT = R.ACCT.STMT.PRINT[@FM,POS,9999]

RETURN
*------------------------------------------------------------------------
GET.STMT.PRINTED:
*****************

    STMT.PRINTED.ID = ACCOUNT.NUM:"-": EB.Reports.getId()["/",1,1]    ;* Account.Date
    R.STMT.PRINTED = '' ;

    HVT.INFO = ''
    InDetails<1>='STMT.PRINTED'
    InDetails<2>=STMT.PRINTED.ID
    AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',HVT.INFO , '',ER, '')
    R.STMT.PRINTED = HVT.INFO

RETURN
*------------------------------------------------------------------------
END
