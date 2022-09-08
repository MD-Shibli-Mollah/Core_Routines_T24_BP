* @ValidationCode : MjoxMjk2OTUxMDc1OkNwMTI1MjoxNjExMjA5MDY4MTU5OnByZWV0aGlzOjE0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6Mjk4OjI4NA==
* @ValidationInfo : Timestamp         : 21 Jan 2021 11:34:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : preethis
* @ValidationInfo : Nb tests success  : 14
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 284/298 (95.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-292</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.ACCOUNT.STATEMENT
*-------------------------------------------------------------------------
*
* Enquiry subroutine to return account statement information based on
* a selected account, statement date and statement frequency number. This
* is passed in the selection criteria.
*
* It returns the following information:
*
* DE.ADDRESS RECORD          The appropriate address record
* HANDOFF RECORD             The current AC.STMT.HANDOFF record
*
* with ">" as a separator ie ADDRESS>HANDOFF
*
* The handoff record can be from AC.STMT.HANDOFF$HIS
* Any errors are returned in ENQ.ERROR<-1>
*
* 16/03/94 - GB9400341
*            Locate by "AL" to get correct opening balance
*
* 05/09/94 - GB9400996
*            Frequency should not extract the part after the ";" for
*            reprints
*
* 18/03/95 - GB9500100 & GB9501283
*            Extract the correct language value according to that
*            defined in the AC.STMT.HANDOFF record
*            E. Kutepov   AviComp Services
*
* 18/12/95 - GB9501505
*            Extract OPENING BALANCE for the last statement from the
*            ACCOUNT.STATEMENT record and not the ACCT.STMT.PRINT
*
* 01/05/96 - GB9600544
*            Extract carrier from element 4 of the key not 3
*
* 05/01/00 - GB9901859
*            Where ACCOUNT.STATEMENT has frequency 1 and frequency 2,
*            and the relationship is COMBINED, the system prints
*            statement with incorrect order and incorrect dates.
*
* 03/09/01 - CI-101072
*            Drilldown on Enquiry ACCT.STMT.HIST produces wrong result
*
* 12/04/02 - CI-10001081
*            Transcation not shown at the date of Account get closed
*
* 21/10/02 - GLOBUS_EN_10001477
*            Changes done to adapt additional frequencies for the account
*            statement.
*
* 03/12/02 - GLOBUS_BG_100002917
*            Variable undefined error "AC.STA.FREQ.RELATIONSHIP"
*            Also shortened few field names.
*
* 22/02/03 - BG_100003504
*            Changes made to display correct frequency date for
*            additional frequencies.
*
* 12/05/05 - CI_10030134
*            Account statement is print with wrong OPEN.DATE and TO.DATE
*            when the FREQ.NO field in ACCOUNT.STATMENT is > 2, during online.
*            This is fixed now.
*
* 29/09/05 - CI_10035054
*            While printing statement for closed account through PRINT.STATEMENT,
*            (only)the closure statement entry doesn't get populated in the
*            PRINT.STATEMENT output. Changes done to solve this.
*
* 07/12/05 - CI_10036642
*            Special stmt not generated.
*
* 04/08/06 - BG_100011816 / REF:TTS0680955
*            When running ACCOUNT.STATEMNT enquiry system display an error
*            message of missing handoff record.
*
* 25/08/06   BG_100011920 / REF:TTS0681042
*            When we run the ACCOUNT.STATEMENT enquiry to produce online
*            Account Stmt, the system is showing the Opening Balance as 0.
*
* 20/09/06 - CI_10044210
*            Missing handoff record message when printing account
*            closing statement.
*
* 18/01/07 - BG_100012775 /REF: TTS0705416
*            Opening and closing balances are wrong in ENQ ACCOUNT.STATEMENT.
*
* 13/09/07 - CI_10051357
*            Check introduced for internal acct to eliminate the error
*            "Missing DE.ADDRESS" for such accounts.
*
* 27/11/08 - BG_100021032
*            A check is introduced so that in the enquiry ACCOUNT.STATEMENT
*            if the date is supplied account balance information should be
*            obtained from HANDOFF record and not from the ACCT.STMT.PRINT.
*
* 01/04/10 - Task 36398
*            Replacing READ statement by T24 API F.READ
* 30/11/10 - Task - 84421
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 01/04/11 - DEFECT 182136 // TASK 183742
*            Inorder to avoid error during enquiry ,use correct variable to assign customer number.
*
* 20/12/11 - Defect 325533 / Task 327440
*            Changes done to get correct value for DATE to print account.statement.
*
* 14/03/12 - Defect 367388 / Task 372044
*            For HVT accounts merge ACCT.STMT.PRINT before getting dates.
*
*
* 17/04/12 - D 381220/ T 390270
*            R.DE.ADDRESS variable initialized
*
* 04/09/12 - Defect 472868 / Task 474925
*            When date is passed as null in selection criteria then restore to the old date.
*
* 24/01/12 - Defect - 553930/ Task - 566934
*            If there is a value in MDR customer, then system should send the
*            account statement copies to that customer also. So, If CUSTOMER is
*            passed, then use that customer for reading DE.ADDRESS
*
* 07/02/13 - DEFECT 576628 / TASK 582950
*              Retrieve the ACCT.STMT.PRINT record correctly for HVT accounts.
*
* 06/09/13 - Defect 718611 / Task 721933
*            While running the enquiry �ACCOUNT.STATEMENT� system shows the field �STMT.NO� value which
*            is incremented by �1� when compare to �ACCOUNT.STATEMENT� record of closed accounts
*
* 12/03/14 - Defcet 927037 / Task 932448
*            FROM.DATE and TO.DATE is displaying wrongly while running the enquiry
*            ACCOUNT.STATEMENT
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 18/02/15 - Defect 1255151/Task 1258381
*            The STATEMENT start date and opening balance is wrong in the Account statement for frequency
*            greater than 2.
*
* 12/02/15 - Defect 120871/Task 1252778
*            !MINIMUM is not supported in TAFJ, hence changed to use MINIMUM()
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 10/09/15 - Defect 1432048/Task 1465432
*            while runing ENQUIRY of ACCOUNT.STATEMENT.SCRN displays wrong brought forward Balance
*            when there is no entries present on that date. System picks the last ACCOUNT.STATEMENT frequency
*            date balance instead of given ACCOUNT.STATEMENT frequency date balance.
*
* 01/10/16 - Defect 1858566/ Task 1879015
*            Account movements missing in certain enquiry after the fix through defect 1432048.
*
* 23/08/17 - Defect 2240298 / Task 2246894
*            Code changes done such that the FROM.DATE should be displayed correctly while
*            running the ACCOUNT.STATEMENT.ENQUIRY. Period end date of previous statement should
*            not be included in the current statement.
*
* 23/04/18 - Defect 2553518 / Task 2561337
*            Code changes done such that the FROM.DATE should be displayed correctly while
*            running the ACCOUNT.STATEMENT ENQUIRY for statement frequency greater than one.
*
* 26/06/18 - Defect 2553518 / Task 2649767
*            Code changes done under 2561337 extended for any number of additional
*            frequencies added in Stmt Fqu 2 in ACCOUNT.STATEMENT.
*
* 30/10/18 - EN 2828914 / Task 2828966
*            Assign customer id,carrier and print customer from the DRANGE value based on the length of the DRANGE
*            for the Statement id part
*            changes made to Read handoff record as per new id format
*
* 02/08/19 - Enhancement 3257457 / Task 3257461
*            Direct access to DE.ADDRESS removed
*
* 26/08/19 - Enhancement 3106214 / Task 3305411
*            Correction for accessing DE.ADDRESS according to PRINT.CUSTOMER
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
* 20/01/21 - Defect 4180800 / Task 4188330
*            Retrieve the customer number properly when history records are selected
*-------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING AC.AccountStatement
    $USING AC.Config
    $USING AC.HighVolume
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.API
    $USING DE.Config
    $USING ST.CompanyCreation
    $USING AC.API
    $USING ST.Customer
    $USING ST.CustomerService

*------------------------------------------------------------------------
*
    GOSUB INITIALISATION
    GOSUB GET.HANDOFF.RECORD
    GOSUB GET.ADDRESS         ;* Need handoff to determine address
*
    CONVERT @FM TO "~" IN R.DE.ADDRESS  ;* Separate fields by ~
    CONVERT @FM TO "~" IN R.AC.STMT.HANDOFF
    EB.Reports.setOData(R.DE.ADDRESS:">":R.AC.STMT.HANDOFF)
*
RETURN
*
*-------------------------------------------------------------------------
INITIALISATION:
***************
* Open the correct statement frequency files etc.
*
    R.DE.ADDRESS = ''
    CUST.ID = ''
    
    D.FIELDS = EB.Reports.getDFields()
    LOCATE "STATEMENT.ID" IN D.FIELDS<1> SETTING STMT.POS ELSE
        STMT.POS = ""
    END
    ID.LEN = DCOUNT(EB.Reports.getDRangeAndValue()<STMT.POS>,".")
    
    IF EB.Reports.getDRangeAndValue()<STMT.POS> THEN                   ;* to process the enquiry of ACCOUNT.STATEMENT
        ACCOUNT.KEY = EB.Reports.getDRangeAndValue()<STMT.POS>[".",1,1]
        REQUESTED.DATE = EB.Reports.getDRangeAndValue()<STMT.POS>[".",2,1]
        FREQUENCY = EB.Reports.getDRangeAndValue()<STMT.POS>[".",3,1]

        IF ID.LEN EQ 6 THEN
            CUST.ID = EB.Reports.getDRangeAndValue()<STMT.POS>[".",4,1]
            CUST.ID = FIELD(CUST.ID,';',1)  ;* in case of history records, 4th part will have curr no also - so extract customer number alone
            CARRIER = EB.Reports.getDRangeAndValue()<STMT.POS>[".",5,1]
            PRINT.CUSTOMER = EB.Reports.getDRangeAndValue()<STMT.POS>[".",6,1]
        END ELSE
            CARRIER = EB.Reports.getDRangeAndValue()<STMT.POS>[".",4,1]
            PRINT.CUSTOMER = EB.Reports.getDRangeAndValue()<STMT.POS>[".",5,1]
        END
        

    END ELSE
*
** Look for the account number and date and frequency to build the key
*
        LOCATE "SELECT.ACCOUNT" IN EB.Reports.getDFields()<1> SETTING YAC.POS THEN
            ACCOUNT.KEY = EB.Reports.getDRangeAndValue()<YAC.POS>
        END ELSE
            ACCOUNT.KEY = ""
        END
        LOCATE "STMT.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS THEN
            REQUESTED.DATE = EB.Reports.getDRangeAndValue()<DATE.POS>
        END ELSE
            REQUESTED.DATE = ""
        END

        LOCATE "STMT.FREQ" IN EB.Reports.getDFields()<1> SETTING FREQ.POS THEN
            FREQUENCY = EB.Reports.getDRangeAndValue()<FREQ.POS>
        END ELSE
            FREQUENCY = 1
        END
        CARRIER = ""
    END

    FREQUENCY = FREQUENCY[";",1,1]      ;* Strip off end bit
    FREQUENCY = FREQUENCY[1,1]
*
    HVT = ''

    IF NOT(FREQUENCY) THEN
        FREQUENCY = 1         ;* Default
    END
*
    IF NOT(CARRIER) THEN
        CARRIER = 1 ;* Default
    END

    READ.HANDOFF.FLAG = ''    ;* This falg will be set while readding Already availbale Handoff Record.

*
RETURN
*
*-------------------------------------------------------------------------
GET.HANDOFF.RECORD:
*******************
* Read handoff record - if not on live try the history file
* The statement date is determined by locating in the ACCT.STMT.PRINT
* record. If the date supplied is beyond the current list then we need
* to supply a dummy handoff record back to the enquiry.  This enquiry
* can be used for printing/reprinting valid statements or for showing
* entries since the last statement.
*
    GOSUB GET.DATES
    IF STATEMENT.DATE AND REQUESTED.DATE THEN     ;* Valid date
        LANG = EB.SystemTables.getLngg() ;* Use passed setting from PRINT.STATENENTS
* If statement id, has customer id in then read handoff record with customer id appended
        IF CUST.ID THEN
            HANDOFF.KEY = ACCOUNT.KEY:".":STATEMENT.DATE:".":FREQUENCY:".":CUST.ID
        END ELSE
            HANDOFF.KEY = ACCOUNT.KEY:".":STATEMENT.DATE:".":FREQUENCY
        END
* CI_10044210 S
* Attempt to read statement handoff record from live file then from
* history file. If is cannot be found, attempt to read the account
* closing record from live then history. If that fails too, build
* the handoff record.
        GOSUB READ.HANDOFF.RECORD
        IF R.AC.STMT.HANDOFF = "" THEN
            SAVE.HANDOFF.KEY = HANDOFF.KEY
            GOSUB READ.CLOSURE.HANDOFF
            
            IF R.AC.STMT.HANDOFF = "" THEN
                HANDOFF.KEY = SAVE.HANDOFF.KEY
* SI-2797952
* If executed directly from enquiry running under batch is not set, then append customer id from account
* with handoff id to read the handoff record, if not found attempt to read closing record, if that too fails,
* build handoff record
                IF EB.SystemTables.getRunningUnderBatch() NE "1" AND CUST.ID EQ "" THEN
                    CUST.ID = R.ACCOUNT<AC.AccountOpening.Account.Customer>
                    HANDOFF.KEY = ACCOUNT.KEY:".":STATEMENT.DATE:".":FREQUENCY:".":CUST.ID
                    GOSUB READ.HANDOFF.RECORD
                    IF R.AC.STMT.HANDOFF = "" THEN
                        GOSUB READ.CLOSURE.HANDOFF
                        IF R.AC.STMT.HANDOFF = "" THEN
                            HANDOFF.KEY = SAVE.HANDOFF.KEY
                            GOSUB BUILD.HANDOFF.RECORD
                        END
                    END
                END ELSE
                    GOSUB BUILD.HANDOFF.RECORD
                END
            END
        END
* CI_10044210 E
    END ELSE
        OPENING.BALANCE = ""
        GOSUB BUILD.HANDOFF.RECORD
        LANG = R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthLanguage> ;* Use default  = customer
    END
*
RETURN
* CI_10044210 S
*-----------------------------------------------------------------------------
GET.DATES:
**********
*
    LOCATE "PROCESSING.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS THEN
        OLD.REQ.DATE = REQUESTED.DATE   ;* Store date
        REQUESTED.DATE = RAISE(RAISE(EB.Reports.getDRangeAndValue()<DATE.POS>))
        DAT.CNT = DCOUNT(REQUESTED.DATE ,@FM)
        REQUESTED.DATE = REQUESTED.DATE<DAT.CNT>
        IF NOT(REQUESTED.DATE) THEN     ;* Reassign the old date when date is null
            REQUESTED.DATE = OLD.REQ.DATE
        END
    END ELSE
        REQUESTED.DATE = ""
    END

    AC.STMT.PRINT.ID = ACCOUNT.KEY
    IF FREQUENCY GT 2 THEN
        AC.STMT.PRINT.ID = ACCOUNT.KEY:'.':FREQUENCY
    END

    GOSUB READ.ASP.RECORD

    LOCATE REQUESTED.DATE IN R.ACCT.STMT.PRINT<1> BY "AL" SETTING POS ELSE
        NULL        ;* Look for statement date
    END
    STATEMENT.DATE = R.ACCT.STMT.PRINT<POS>["/",1,1]        ;* Remove closing balance bit
    PREVIOUS.STATEMENT.DATE = R.ACCT.STMT.PRINT<POS-1>["/",1,1]       ;* & one before
    OPENING.BALANCE = R.ACCT.STMT.PRINT<POS>["/",2,1]       ;* Could be null

RETURN
*------------------------------------------------------------------------------
READ.ASP.RECORD:
****************
*
    R.ACCOUNT = AC.AccountOpening.tableAccount(ACCOUNT.KEY, READ.ERR)
* SI-2797952
* For closed accounts, read from history
    IF READ.ERR THEN
        R.ACCOUNT = AC.AccountOpening.Account.ReadHis(ACCOUNT.KEY:";1", READ.ERR)
    END
* Replaced the read for ACCT.STMT.PRINT with EB.READ.HVT common API whcih will check for HVT flag
* and return notionally merged record for HVT accounts otherwise return the record from disc.
    R.ACCT.STMT.PRINT = ''
* The Account Statement Print Id (AC.STMT.PRINT.ID) is to be populated while calling
* EB.READ.HVT instead of ACCOUNT.
    InDetails=''
    InDetails<2>=AC.STMT.PRINT.ID
    RequestMode='MERGE.HVT'
    AcctStmtRecord=''
    StmtSeqIndicator=''

    IF FREQUENCY[1,1] # "1" THEN
        InDetails<1>='ACCT.STMT2.PRINT'
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, RequestMode, '', '', '', AcctStmtRecord, StmtSeqIndicator, '', '')  ;* Call the core api to get the merged info for HVT accounts
    END ELSE
        InDetails<1>='ACCT.STMT.PRINT'
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, RequestMode, '', '', '', AcctStmtRecord, StmtSeqIndicator, '', '')    ;* Call the core api to get the merged info for HVT accounts
    END
    R.ACCT.STMT.PRINT=AcctStmtRecord
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= READ.HANDOFF.RECORD>
READ.HANDOFF.RECORD:
********************
*** <desc>Attempt to read handoff record from live, then history</desc>
    READ.ERR = ""


    R.AC.STMT.HANDOFF = AC.AccountStatement.AcStmtHandoff.Read(HANDOFF.KEY, READ.ERR)

    IF READ.ERR THEN

        R.AC.STMT.HANDOFF = AC.AccountStatement.AcStmtHandoff.ReadHis(HANDOFF.KEY:";1", Y.ERR)

        IF Y.ERR THEN
            R.AC.STMT.HANDOFF = ""
        END
    END

    IF R.AC.STMT.HANDOFF THEN
        READ.HANDOFF.FLAG = 1
        OPENING.DATE = R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningDate>         ;* Last Frequency Date
        IF OPENING.DATE NE '' THEN
            EB.API.Cdt('' , OPENING.DATE ,'+1C')    ;* Add one calander date with Last Freq sate to get the next statement start date
        END
        R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = OPENING.DATE         ;*Next Statement start date (Ex 30nov+1 cander day-01dec2000)
        GOSUB GET.TO.DATE
    END

RETURN
*** </region>
*---------------------------------------------------------------------------
GET.TO.DATE:
***********

    SYS.ID.IN = ''
    ANY.VD = ''     ;* 1 if any sys id has v.d. accounting set
    VD.SYS = ''     ;* 1 for value dated, 0 for trade dated

    AC.API.ValueDatedAcctng(SYS.ID.IN, '', '', '', ANY.VD, VD.SYS)
*
    IF READ.HANDOFF.FLAG THEN
        R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthToDate> = REQUESTED.DATE  ;* While reading already available Handoff record TO.DATE should be the Last Frequency date
    END ELSE
        IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng>[1,1] NE "Y" AND NOT(ANY.VD) THEN          ;* if ANY.VD is set then TO.DATE is Period end date
            R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthToDate> = EB.SystemTables.getToday()       ;* While building new Handoff record system should assign the TODAY value in TO.DATE field
        END ELSE
            R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthToDate> = EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)      ;* For value dated accounting TO.DATE should be PERIOD.END datew
        END
    END

RETURN
*--------------------------------------------------------------------------
READ.ACCOUNT.STMT.RECORD:
************************
** Read the history file if it doesn't exists in live.
*
    READ.ERR = ""

    R.ACCOUNT.STATEMENT = AC.AccountStatement.AccountStatement.Read(ACCOUNT.KEY, READ.ERR)

    IF READ.ERR THEN
        AS.ID = ACCOUNT.KEY
        AC.AccountStatement.AccountStatementHistRead(AS.ID, AS.HIST.REC, AS.ERR)
        R.ACCOUNT.STATEMENT = AS.HIST.REC
        IF AS.ERR THEN
            tmp=EB.Reports.getEnqError(); tmp<-1>="Missing ACCOUNT.STATEMENT record ":ACCOUNT.KEY; EB.Reports.setEnqError(tmp)
            GOSUB PROGRAM.ABORT
        END
    END
*
RETURN
*--------------------------------------------------------------------------------------------------
BUILD.HANDOFF.RECORD:
*********************
*
* Date beyond printed statements - so this must be for an enquiry since the
* last statement. Build a dummy handoff record so the enquiry will still
* work.
*
    GOSUB READ.ACCOUNT.STMT.RECORD
    GOSUB GET.CUSTOMER.DETAILS
*
    R.AC.STMT.HANDOFF = ""
*
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthCarrierAddrNo> = "PRINT.1"
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthLanguage> = R.CUSTOMER<ST.Customer.Customer.EbCusLanguage>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthCustomer> = CustomerKey
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthSectorCode> =  R.CUSTOMER<ST.Customer.Customer.EbCusSector>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthCompanyCode> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthAccountOfficer> = R.ACCOUNT<AC.AccountOpening.Account.AccountOfficer>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthCurrency> = R.ACCOUNT<AC.AccountOpening.Account.Currency>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthAcctCategory> = R.ACCOUNT<AC.AccountOpening.Account.Category>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthAcctLimitRef> = R.ACCOUNT<AC.AccountOpening.Account.LimitRef>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthStatementNo> = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaLastStatementNo> + 1      ;* Next number
*
    IF PREVIOUS.STATEMENT.DATE THEN
        
            
* While generating previous statement, TO.DATE will always include period end date. So PREVIOUS.STATEMENT.DATE should
* not include period end date.
*
        EB.API.Cdt('' , PREVIOUS.STATEMENT.DATE , '+1W')      ;* Add one working date to get correct statement start date
        
        R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = PREVIOUS.STATEMENT.DATE
    END ELSE
        LOCATE FREQUENCY IN R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFreqNo,1> SETTING FREQ.POS THEN ;* Check if the freuqncy is there in ACCOUNT.STATEMENT
            PREVIOUS.STATEMENT.DATE = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquTwoLastDate,FREQ.POS>   ;* Take Fqu2 Last Date if additional freuqncy is defined
            EB.API.Cdt('' , PREVIOUS.STATEMENT.DATE , '+1W')      ;* Add one working date to get correct statement start date
            R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = PREVIOUS.STATEMENT.DATE
        END ELSE
            R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = R.ACCOUNT<AC.AccountOpening.Account.OpeningDate>    ;* Only if no previous date found both in ASP/ASP2 and Fqu2 Last Date in ACCOUNT.STATEMENT, account's opening date to be considered
        END
    END
*
    IF OPENING.BALANCE = '' THEN
        R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningBalance> = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastBalance>   ;* Last bala/BAL nce on record
    END ELSE
        R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthOpeningBalance> = OPENING.BALANCE
    END
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthDescriptiveStmt> = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaDescriptStatement>
*
* Since frequency dates are multi valued get the nearest frequency
* date for processing.
    IF FREQUENCY = 1 THEN     ;* Frequency 1
        FQU.DATES = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaStmtFquOne>
    END ELSE        ;* Additional frequencies.
        LOCATE FREQUENCY IN R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFreqNo> SETTING FREQ.POS ELSE
            FREQ.POS = 0
        END
        FQU.DATES = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaStmtFquTwo,FREQ.POS>
        FQU.DATES = RAISE(FQU.DATES)
    END
    GOSUB GET.NEAR.FQU        ;* Get the nearest fqu to process.
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthStmtFrequ> = LATEST.FQU[5]
*
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthAcctTitleTwo> = R.ACCOUNT<AC.AccountOpening.Account.AccountTitleTwo>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthConditionGroup> = R.ACCOUNT<AC.AccountOpening.Account.ConditionGroup>
    R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthShortTitle> = R.ACCOUNT<AC.AccountOpening.Account.ShortTitle>

    GOSUB GET.TO.DATE
*
RETURN
*-------------------------------------------------------------------------------------------------
GET.CUSTOMER.DETAILS:
*********************
*
    CustomerKey = R.ACCOUNT<AC.AccountOpening.Account.Customer>
    R.CUSTOMER = ''
    IF CustomerKey THEN
        READ.ERR = ""
        customerRecord = ''
        ST.CustomerService.getRecord(CustomerKey, customerRecord)
        IF NOT(customerRecord) THEN
            tmp=EB.Reports.getEnqError(); tmp<-1>="Missing CUSTOMER record ":CustomerKey; EB.Reports.setEnqError(tmp)
            GOSUB PROGRAM.ABORT
        END
        R.CUSTOMER = customerRecord
    END ELSE
        R.CUSTOMER<ST.Customer.Customer.EbCusLanguage> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLanguageCode) ;* Use company for internal A/c
    END

RETURN
*-----------------------------------------------------------------------------------------------------
GET.NEAR.FQU:
*************
* Return the nearest frequency date for processing.
    LATEST.FQU = '' ; DATE.LIST = ''
    IF FQU.DATES THEN
        FQU.DATE.CNT = DCOUNT(FQU.DATES,@VM)
        IF FQU.DATE.CNT = 1 THEN        ;* If only one addl fqu exists.
            LATEST.FQU = FQU.DATES
        END ELSE
            FOR FDATE = 1 TO FQU.DATE.CNT
                DATE.LIST<-1> = FQU.DATES[1,8]    ;* Strip the date part.
            NEXT FDATE
            LATEST.DATE = MINIMUM(DATE.LIST) ;* Get the nearest date.

            LOCATE LATEST.DATE IN DATE.LIST<1> SETTING FDATE.POS ELSE
                FDATE.POS = 1
            END
            LATEST.FQU = DATE.LIST<1,FDATE.POS>   ;* Return nearest freq.
        END
    END
RETURN
*--------------------------------------------------------------------------------------------------
GET.ADDRESS:
************
* Determine the correct address from delivery, based on the carrier
* The company id (for the customer), the customer id & the carrier.
*
    INT.FLAG = ''
    AC.AccountOpening.IntAcc(ACCOUNT.KEY,INT.FLAG)
    IF INT.FLAG = 1 THEN
        RETURN
    END

    CARRIER.NAME = "PRINT.": CARRIER    ;* Ie PRINT.1
    IF PRINT.CUSTOMER THEN
        DE.ADDRESS.KEY= EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany):".C-":PRINT.CUSTOMER:".":CARRIER.NAME
        keyDetails<ST.CustomerService.AddressIDDetails.customerKey> = PRINT.CUSTOMER ;* Customer id
    END ELSE
        DE.ADDRESS.KEY= EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany):".C-":R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthCustomer>:".":CARRIER.NAME
        keyDetails<ST.CustomerService.AddressIDDetails.customerKey> = R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthCustomer> ;* Customer id
    END
*
    READ.ERR = ""
    addressRec = ''
    keyDetails<ST.CustomerService.AddressIDDetails.companyCode> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany) ;*Company Id
    keyDetails<ST.CustomerService.AddressIDDetails.preferredLang> = R.AC.STMT.HANDOFF<AC.AccountStatement.AcStmtHandoff.AcSthLanguage> ;* Language
    keyDetails<ST.CustomerService.AddressIDDetails.addressNumber> = CARRIER  ;* set the Address number
    keyDetails<ST.CustomerService.AddressIDDetails.getDefault> = 'NO' ;* Default is set to NO
    ST.CustomerService.getPhysicalAddress(keyDetails, addressRec) ;* API call getPhysicalAddress
    READ.ERR = EB.SystemTables.getEtext() ;* get the error msg.
    
    IF READ.ERR THEN
        tmp=EB.Reports.getEnqError(); tmp<-1>="Missing DE.ADDRESS record ":DE.ADDRESS.KEY; EB.Reports.setEnqError(tmp)
    END
    
    GOSUB MAP.FIELDS.INTO.DE
    
*
RETURN
*
*--------------------------------------------------------------------------------------------------
READ.CLOSURE.HANDOFF:
************
*

    IF CUST.ID THEN
        HANDOFF.KEY = ACCOUNT.KEY:".":STATEMENT.DATE:".":FREQUENCY:"C":".":CUST.ID
    END ELSE
        HANDOFF.KEY := "C"
    END
    GOSUB READ.HANDOFF.RECORD
    
RETURN
*-------------------------------------------------------------------------
MAP.FIELDS.INTO.DE:
***************
*<desc>map the values from getPhysicalAddress API response to DE.Config.</desc>

    R.DE.ADDRESS<AC.ModelBank.AcDeAddBranchnameTitle> = addressRec<ST.CustomerService.Address.shortName>
    R.DE.ADDRESS<AC.ModelBank.AcDeAddName1> = addressRec<ST.CustomerService.Address.name1>
    R.DE.ADDRESS<AC.ModelBank.AcDeAddName2> = addressRec<ST.CustomerService.Address.name2>
    R.DE.ADDRESS<AC.ModelBank.AcDeAddStreetAddress> = addressRec<ST.CustomerService.Address.streetAddress>
    R.DE.ADDRESS<AC.ModelBank.AcDeAddTownCountry> = addressRec<ST.CustomerService.Address.townCounty>
    R.DE.ADDRESS<AC.ModelBank.AcDeAddPostCode> = addressRec<ST.CustomerService.Address.postCode>
    R.DE.ADDRESS<AC.ModelBank.AcDeAddCountry> = addressRec<ST.CustomerService.Address.country>

RETURN
*--------------------------------------------------------------------------------------------------
PROGRAM.ABORT:
* This should be the last para always and there should not be return statement so the program terminates here
END


