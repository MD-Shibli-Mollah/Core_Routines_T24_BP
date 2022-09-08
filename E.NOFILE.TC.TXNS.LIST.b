* @ValidationCode : MjotNjkzNzM3NjIxOkNwMTI1MjoxNjA2MzA2MTg2ODAyOnNpdmFjaGVsbGFwcGE6MTM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDozMzI6Mjg0
* @ValidationInfo : Timestamp         : 25 Nov 2020 17:39:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 13
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 284/332 (85.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*---------------------------------------------------------------------------------------------------------------------
$PACKAGE AC.Channels
SUBROUTINE E.NOFILE.TC.TXNS.LIST(TXN.ARR)
*---------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This routine used to display the transactions list based on the selection parameters. The various transaction types prvoided by this routine are
* Recent customer transactions, Completed account transactions, Pending account transactions and Search account transactions.
* This routine uses GetCustomerRecentTxnsIds and GetAccountTxnsIds to provide the data.
* The core API EStmtEntList is used to retrieve the statement entry list
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TC.TXNS.LIST, ENQUIRY>TC.NOF.TXNS.LIST
* IN Parameters      : Account no, List Type, Pay Type, Txn Count, Date From, Date To, Minimum Amount, Maximum Amount, Description, Transaction Code and Statement reference
* Out Parameters     : TXN.ARR(StmtId, BookingDate, Narrative, StmtAccount, StmtAmount, StmtCurrency, AcctTitle, CompBranchCode, ImDocId, Notes, ImageId and TransReference)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1648966 / Task - 1843348
*            TCIB Retail : Transactions Detail (Recent Transaction )
*
* 22/11/16 - Defect - 1932453 / Task - 1932457
*          - Dummy record in completed transaction list of TCIB
*
* 03/02/17 - Defect - 1959764 / Task - 2007945
*          - Search the transaction with Transaction type selected and then after search results are fetched,
*            edit the search by selecting any other Transaction type from the dropdown, it is re-directing to saved payee page
* 12/06/17 - Defect - 2087259 / Task - 2157736 - Transactions - BOI - Order of the account statement
*          - The system must display the COMPLETED transactions ordered by most recent at top by time order.
*
* 18/08/17 - Defect - 2240273 / Task - 2240275
*          - PFM Integration - BFW coding
*
* 07/02/18 - Defect - 2432544 / Task - 2441940
*          - Narrative field shown should be same as displayed in STMT.ENT.BOOK enquiry
*
* 03/04/18 - Defect - 2501248 / Task - 2534144
*          - System must display completed transactions when pending transactions exist
*
* 06/07/17 - Defect - 2116841 / Task - 2124947
*            TCIB2.0 Retail : Recent transaction list
*            If Short title is present for accont, AccountTitle is assigned short title else assign account title.
*
* 12/03/19 - Enhancement - 2875480 / Task - 3030764
*            TCIB2.0 Retail IRIS R18 Migration
*
* 20/03/19 - Defect - 3034138 / Task - 3044426
*          - IRIS service enqTcNofTxnsList causing java.text.ParseException: Unparseable date error
*
* 17/05/19 - Defect 3099901 / Task 3133852
*            External accounts recent transactions in TCIB Home page
*
* 29/10/19 - Defect 3403370 / Task 3408978
*            Narrative field should support multi language
*
* 11/12/19 - Defect 3474331 / Task 3482604
*            The RECENT transaction listing is not displaying the correct order in TCIB screen
*
* 04/03/20 - Enhancement 3492893 / Task 3622075
*            Add statement code and calculate opening balance for Pending transactions.
*
* 25/07/20 - Defect 3871085 / Task 3876107
*            Infinity - Download Transaction statement changes.
*
* 18/09/20 - Defect 3976543 / Task 3976536
*            Infinity - Transaction Description and narrative splitted into 2 different response fields
*
* 09/11/20  - Infinity Wealth Development
*            ADP-1720
*
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING AC.ModelBank
    $USING AC.Channels
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING EB.API
    $USING ST.CompanyCreation
    $USING IM.Foundation
    $USING ST.Config
    $USING EB.Security
    $USING SC.SctTrading
    $USING SC.SctOrderCapture
    $USING SC.SctOffMarketTrades
    $USING SC.SctPositionTransfer
    $USING SC.ScoSecurityMasterMaintenance
    $USING DX.Trade
    $USING DX.Order
    $USING DX.Configuration
*-------------------------------------------------------------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB GET.INPUTS
    GOSUB PROCESS

RETURN
*-------------------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*-----------
* Initialise all variables
    DEFFUN System.getVariable()
    AccountNo = ''; ListType = ''; TxnCount = ''; PayType = ''; StartDate = ''; EndDate = ''; MinimumAmount = ''; MaximumAmount = ''; Narrative = ''; TransactionCode = '';
    AC.POS = ''; LS.POS = ''; COUNT.POS = ''; PAY.POS = ''; DF.POS = ''; DT.POS = ''; MN.POS = ''; MX.POS = ''; DS.POS = ''; TC.POS = '';
    IdList = ''; StmtBalance = ''; EntryBalance = ''; OpeningBalance = ''; StmtId = ''; LIST.POS = ''; TX.POS =''; StatementReference = ''; TransReference = '';CustomerId=''; IsImInstalled = ''; IsDXInstalled = ''; IsSCInstalled = '';
    ExtLang = ''
    
RETURN
*--------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.INPUTS>
*** <desc>Initialise variables used in this routine</desc>
GET.INPUTS:
*-----------
** Get input parameter values from enquiry selection

    LOCATE 'ACCOUNT.NO' IN EB.Reports.getDFields()<1> SETTING AC.POS THEN   ;*Check condition for getting account no
        AccountNo = EB.Reports.getDRangeAndValue()<AC.POS>
    END

    LOCATE 'LIST.TYPE' IN EB.Reports.getDFields()<1> SETTING LS.POS THEN    ;*Check condition for getting List type
        ListType = EB.Reports.getDRangeAndValue()<LS.POS>
    END

    LOCATE 'TXN.COUNT' IN EB.Reports.getDFields()<1> SETTING COUNT.POS THEN ;*Check condition for getting Transaction count
        TxnCount = EB.Reports.getDRangeAndValue()<COUNT.POS>
    END

    LOCATE 'PAY.TYPE' IN EB.Reports.getDFields()<1> SETTING PAY.POS THEN    ;*Check condition for getting Pay Type
        PayType = EB.Reports.getDRangeAndValue()<PAY.POS>
    END

    LOCATE 'DATE.FROM' IN EB.Reports.getDFields()<1> SETTING DF.POS THEN    ;*Check condition for getting Start date
        StartDate = EB.Reports.getDRangeAndValue()<DF.POS>
    END

    LOCATE 'DATE.TO' IN EB.Reports.getDFields()<1> SETTING DT.POS THEN  ;*Check condition for getting End Date
        EndDate = EB.Reports.getDRangeAndValue()<DT.POS>
    END

    LOCATE 'MINIMUM.AMOUNT' IN EB.Reports.getDFields()<1> SETTING MN.POS THEN   ;*Check condition for getting Minimum amount
        MinimumAmount = EB.Reports.getDRangeAndValue()<MN.POS>
    END

    LOCATE 'MAXIMUM.AMOUNT' IN EB.Reports.getDFields()<1> SETTING MX.POS THEN   ;*Check condition for getting Maximum amount
        MaximumAmount = EB.Reports.getDRangeAndValue()<MX.POS>
    END

    LOCATE 'DESCRIPTION' IN EB.Reports.getDFields()<1> SETTING DS.POS THEN  ;*Check condition for getting Description
        Narrative = EB.Reports.getDRangeAndValue()<DS.POS>
        CHANGE @SM TO " " IN Narrative
    END

    LOCATE 'TRANSACTION.CODE' IN EB.Reports.getDFields()<1> SETTING TC.POS THEN ;*Check condition for getting Transaction code
        TransactionCode = EB.Reports.getDRangeAndValue()<TC.POS>
    END

    LOCATE 'STATEMENT.REFERENCE' IN EB.Reports.getDFields()<1> SETTING TX.POS THEN ;*Check condition for getting Transaction code
        StatementReference = EB.Reports.getDRangeAndValue()<TX.POS>
    END
    
    LOCATE 'CUSTOMER.NO' IN EB.Reports.getDFields()<1> SETTING CUS.POS THEN
        CustomerId = EB.Reports.getDRangeAndValue()<CUS.POS> ;* Check condition for getting customer number
    END
    
    Today =  EB.SystemTables.getToday() ;*Get the today date value
    
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN                                                       ;* If External User Language is not available
        ExtLang =1                                                              ;* Assigning Default Language position to read language multi value fields
    END

RETURN
*--------------------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Case statements to route to appropraite transactions list type</desc>
PROCESS:
*--------

    BEGIN CASE
        CASE ListType EQ 'RECENT'   ;*Case for getting recent customer transactions
            GOSUB RECENT.PROCESS
        CASE ListType EQ 'COMPLETED'    ;*Case for getting completed account transactions
            GOSUB COMPLETED.PROCESS
        CASE ListType EQ 'SEARCH'   ;*Case for getting Search account transactions
            GOSUB SEARCH.PROCESS
        CASE ListType EQ 'PENDING'  ;*Case for getting Pending account transactions
            GOSUB PENDING.PROCESS
        CASE ListType EQ 'INDIVIDUAL'
            GOSUB INDIVIDUAL.PROCESS    ;*Case for getting a particular transaction
    END CASE

RETURN
*----------------------------------------------------------------------------------------------------------------------------------
*** <region name= RECENT>
*** <desc>To get the Recent customer transactions lists for all of his accounts</desc>
RECENT.PROCESS:
*---------------
    ID.ARR = ''; ApiCount = '';TransCode='';
    
    TransCode = TransactionCode;
    
    CHANGE @SM TO @FM IN TransCode

    LOOP
        REMOVE AccId FROM AccountNo SETTING AC.POS      ;*Get the customer accounts of external user
    WHILE AccId:AC.POS
        IF AccId EQ '!EXT.SMS.ACCOUNT.SEE' THEN
            AccountList<1,1,-1> =  System.getVariable('EXT.SMS.ACCOUNTS.SEE')
        END ELSE
            AccountList<1,1,-1> = AccId
        END
    REPEAT

    AC.Channels.GetCustomerRecentTxnsIds(AccountList,TxnCount, StartDate, EndDate, IdList, CustomerId)  ;*Call routine to retrieve the statement entry id's for customer accounts with transaction count

    IF IdList NE '' THEN
        LOOP
            REMOVE StmtId FROM IdList SETTING LIST.POS      ;*Loop to get the transaction details
        WHILE StmtId:LIST.POS
            GOSUB COMMON.DETAILS                ;*Get the common transaction details from statement entry and IM applications
            GOSUB WEALTH.DETAILS   ; *Get the Wealth transaction details
            IF TransCode NE '' THEN
                LOCATE StmtCode IN TransCode SETTING POS THEN   ;* Do nothing
                END ELSE
                    CONTINUE
                END
            END
            AccRec = AC.AccountOpening.Account.Read(StmtAccount, ErrAcct)           ;*Read the account
            BEGIN CASE
                CASE AccRec EQ ''                                                         ;* If Account Record is Null Do Nothing
                CASE AccRec<AC.AccountOpening.Account.ShortTitle,ExtLang> NE ''           ;* If Short Title is present in User Preferred Language
                    AcctTitle = AccRec<AC.AccountOpening.Account.ShortTitle,ExtLang>      ;* Read Short Title in User Preferred Language
                CASE AccRec<AC.AccountOpening.Account.ShortTitle,1> NE ''                 ;* Else
                    AcctTitle = AccRec<AC.AccountOpening.Account.ShortTitle,1>            ;* Read Short Title in Default Language
                CASE AccRec<AC.AccountOpening.Account.AccountTitleOne,ExtLang> NE ''      ;* If Account Title is present in User Preferred Language
                    AcctTitle = AccRec<AC.AccountOpening.Account.AccountTitleOne,ExtLang> ;* Read Account Title in User Preferred Language
                CASE 1                                                                    ;* Case Otherwise
                    AcctTitle = AccRec<AC.AccountOpening.Account.AccountTitleOne,1>       ;* Read Account Title in Default Language
            END CASE
            CompBranchCode = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComIbanBranchId)  ;*Get the company branch code
            IF BookingDate NE '' AND ExposureDate <= Today THEN
                ID.ARR<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":Narrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity   ;*Form final array
            END
        REPEAT
    END

    ID.ARR = SORT(ID.ARR)
    ApiCount = DCOUNT(ID.ARR,@FM)               ;*Retrieved Ids's count from API
    GOSUB GET.EXACT.COUNT
*
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= COMPLETED>
*** <desc>To get the Completed account transactions list ignoring future and pending transactions</desc>
COMPLETED.PROCESS:
*-----------------
    ID.ARR = ''; CurrListCount = '';
*
    AC.Channels.GetAccountTxnsIds(AccountNo, ListType, TxnCount, PayType, StartDate, EndDate, MinimumAmount, MaximumAmount, Narrative, TransactionCode, IdList) ;*Call routine to retrieve the statement entry id's based on the account no, start date and end date
*
    EB.Reports.setOData(AccountNo)      ;*Set ODATA for the below call routine
    AC.ModelBank.ECalcOpenBalance()     ;*Call routine to get the opening balance for the account
    OpeningBalance=EB.Reports.getOData()    ;*Assign the output value for opening balance to a variable
*
    IF IdList NE '' THEN
        LOOP
            REMOVE StmtId FROM IdList SETTING LIST.POS  ;*Loop statement to get the transaction details
        WHILE StmtId:LIST.POS
            GOSUB COMMON.DETAILS        ;*Get the common transaction details from statement entry and IM applications
            GOSUB WEALTH.DETAILS   ; *Get the Wealth transaction details
            GOSUB BALANCE.CALCULATE     ;*Do the balance calculation for the statment entries.
            IF BookingDate NE '' AND ExposureDate <= Today THEN   ;*Check to ignore the future dated and pending transactions
                ID.ARR<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":Narrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity   ;*Form final array
            END
        REPEAT
    END
    
;* Processing logic to form an array of transactions in an order from recent to older
    CurrListCount = DCOUNT(ID.ARR,@FM)               ;*Retrieve number of transactions
    IF CurrListCount GT '0' THEN
        LOOP
        UNTIL CurrListCount EQ '0'
            TXN.ARR<-1> = ID.ARR<CurrListCount>     ;*Form the result array
            CurrListCount = CurrListCount -1        ;*Decrement the current list count by 1
        REPEAT
    END
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= IM.DETAILS>
*** <desc>Get the IM details for each transaction</desc>
IM.DETAILS:
*-----------
* Image details
    ImDocId = ''; Notes = ''; ImageId = ''; ImageType = ''  ;*Intialising IM variables
    ImageDetailsRec = IM.Foundation.ImImageDetails.Read(StmtId,ErrRec) ;* To read tc image details records
    IF ImageDetailsRec NE '' THEN
        ImDocId = ImageDetailsRec<IM.Foundation.ImImageDetails.ImImageId> ;*To get the Im document Id
        ImageId = ImageDetailsRec<IM.Foundation.ImImageDetails.ImImageName>   ;*To get the Im Image name
        ImageType = ImageDetailsRec<IM.Foundation.ImImageDetails.ImImageType> ;*To get the Im Image type
        Notes = ImageDetailsRec<IM.Foundation.ImImageDetails.ImNotes> ;*To get the Im Notes
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= COMMON.DETAILS>
*** <desc>Get the transaction details by reading statement entry and also IM details</desc>
COMMON.DETAILS:
*---------------
    StmtRec = ''; StatementDateTime = ''; BookingDate = ''; Narrative = '';  AmtLcy = ''; AmtFcy = ''; StmtAmount = ''; StmtCurrency = ''; ErrStmt = '';
    StmtAccount = ''; AccRec = ''; AcctTitle = ''; CompBranchCode = ''; ErrAcct = ''; ExposureDate = ''; StmtBalance = ''; TransReference = '';StmtCode='';
*
    StmtRec = AC.EntryCreation.StmtEntry.Read(StmtId,ErrStmt)      ;* To read statement entry Id
    IF StmtRec NE '' THEN
        BookingDate= StmtRec<AC.EntryCreation.StmtEntry.SteBookingDate>   ;* To get booking date
        StmtAccount = StmtRec<AC.EntryCreation.StmtEntry.SteAccountNumber>    ;*To get the account number
        StmtCode = StmtRec<AC.EntryCreation.StmtEntry.SteTransactionCode>   ;*To get the transaction code
        AmtLcy = StmtRec<AC.EntryCreation.StmtEntry.SteAmountLcy>       ;*To get Local currency amount
        AmtFcy = StmtRec<AC.EntryCreation.StmtEntry.SteAmountFcy>       ;*To get foreign currency amount
        TransReference = StmtRec<AC.EntryCreation.StmtEntry.SteTransReference>  ;*To get the payment reference
        IF StmtRec<AC.EntryCreation.StmtEntry.SteSystemId> EQ "PP" THEN
            TransReference = StmtRec<AC.EntryCreation.StmtEntry.SteTheirReference>  ;*To get the payment reference
        END
        IF AmtFcy NE '' THEN
            StmtAmount = AmtFcy     ;*Assigning to StatmentAmount variable
        END ELSE
            StmtAmount = AmtLcy     ;*Assigning to StatmentAmount variable
        END
        StmtCurrency = StmtRec<AC.EntryCreation.StmtEntry.SteCurrency>  ;*To get the Statment currency
        StatementDateTime = StmtRec<AC.EntryCreation.StmtEntry.SteDateTime> ;*To read audit date time
        ExposureDate = StmtRec<AC.EntryCreation.StmtEntry.SteExposureDate> ;*To read exposure date
        GOSUB GET.NARRATIVE.DETAILS      ;*To get the narrative value
        LOCATE 'IM' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING IsImInstalled THEN
            GOSUB IM.DETAILS    ;*To get the Im details
        END
    END
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= WEALTH.DETAILS>
*** <desc>To get the SC and DX field Details</desc>
WEALTH.DETAILS:
*------------------
    SystemId=''; ValueDate=''; SecTradeRecord=''; SecCode=''; SecMasterRecord=''; ShortName=''; ExchangeId=''; ExchangeRecord=''; Exchange=''; ISIN=''; Quantity='';
    IF StmtRec NE '' THEN
        ValueDate= StmtRec<AC.EntryCreation.StmtEntry.SteValueDate>
        SystemId= StmtRec<AC.EntryCreation.StmtEntry.SteSystemId>
        EB.API.ProductIsInCompany("SC", IsSCInstalled) ;* check for SC product availability in company
        EB.API.ProductIsInCompany("DX", IsDXInstalled) ;* check for DX product availability in company
        BEGIN CASE
            CASE SystemId[1,2] EQ 'SC' AND IsSCInstalled
                BEGIN CASE
                    CASE TransReference[1,6] EQ 'SCTRSC'
                        SecTradeRecord=SC.SctTrading.SecTrade.Read(TransReference, Error);
                        SecCode=SecTradeRecord<SC.SctTrading.SecTrade.SbsSecurityCode>;
                        Quantity=SecTradeRecord<SC.SctTrading.SecTrade.SbsCustNoNom>;
                    CASE TransReference[1,6] EQ 'OPODSC'
                        SecTradeRecord=SC.SctOrderCapture.SecOpenOrder.Read(TransReference, Error);
                        SecCode=SecTradeRecord<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityNo>;
                        Quantity=SecTradeRecord<SC.SctOrderCapture.SecOpenOrder.ScSooNoNominal>;
                    CASE TransReference[1,6] EQ 'SECTSC'
                        SecTradeRecord=SC.SctOffMarketTrades.SecurityTransfer.Read(TransReference, Error);
                        SecCode=SecTradeRecord<SC.SctOffMarketTrades.SecurityTransfer.ScStrSecurityNo>;
                        Quantity=SecTradeRecord<SC.SctOffMarketTrades.SecurityTransfer.ScStrNoNominal>;
                    CASE TransReference[1,6] EQ 'POSTSC'
                        SecTradeRecord=SC.SctPositionTransfer.PositionTransfer.Read(TransReference, Error);
                        SecCode=SecTradeRecord<SC.SctPositionTransfer.PositionTransfer.ScPstSecurityCode>;
                        Quantity=SecTradeRecord<SC.SctPositionTransfer.PositionTransfer.ScPstCustNominal>;
                END CASE
                SecMasterRecord=SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SecCode, Error);
                ShortName=SecMasterRecord<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmShortName>;
                Exchange=SecMasterRecord<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmStockExchange>;
                ISIN=SecMasterRecord<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmISIN>;
            CASE SystemId[1,2] EQ 'DX' AND IsDXInstalled
                BEGIN CASE
                    CASE TransReference[1,5] EQ 'DXTRA'
                        SecTradeRecord=DX.Trade.Trade.Read(TransReference, Error);
                        SecCode=SecTradeRecord<DX.Trade.Trade.TraContractCode>;
                        Quantity=SecTradeRecord<DX.Trade.Trade.TraPriLots>;
                    CASE TransReference[1,5] EQ 'DXORD'
                        SecTradeRecord=DX.Order.Order.Read(TransReference, Error);
                        SecCode=SecTradeRecord<DX.Order.Order.OrdContractCode>;
                        Quantity=SecTradeRecord<DX.Order.Order.OrdPriLots>;
                END CASE
                SecMasterRecord=DX.Configuration.ContractMaster.Read(SecCode, Error)
                ShortName=SecMasterRecord<DX.Configuration.ContractMaster.CmShortName>;
                ExchangeId=SecMasterRecord<DX.Configuration.ContractMaster.CmExchange>;
                ExchangeRecord=DX.Configuration.ExchangeMaster.Read(ExchangeId, Error);
                Exchange=ExchangeRecord<DX.Configuration.ExchangeMaster.EmMnemonic>;
        END CASE
    END
*
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= BALANCE.CALCULATE>
*** <desc>To calculate the balance for each transaction based on the opening balance</desc>
BALANCE.CALCULATE:
*------------------
    EntryAmount = '';
*
    IF StmtCurrency EQ EB.SystemTables.getLccy() THEN   ;*Check to assign appropriate amount for EntryAmount variable from Paid In/Paid Out
        EntryAmount=AmtLcy  ;*EntryAmount assigned with Paid In amount
    END ELSE
        EntryAmount=AmtFcy  ;*EntryAmount assigned with Paid Out amount
    END
*
    EntryBalance=EntryAmount + EntryBalance ;*Add the entry amount with previous amount
    StmtBalance=OpeningBalance + EntryBalance   ;*Add the Entry balance with Statement Balance
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= SEARCH.PROCESS>
*** <desc>To get the transactions list based on the search filters</desc>
SEARCH.PROCESS:
*--------------

    AC.Channels.GetAccountTxnsIds(AccountNo, ListType, TxnCount, PayType, StartDate, EndDate, MinimumAmount, MaximumAmount, Narrative, TransactionCode, IdList) ;*Call routine to retrieve the account transactions based on search parameters passed

    IF IdList NE '' THEN
        TXN.ARR<-1> = IdList    ;*Assigning to Transaction array
    END
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= PENDING.PROCESS>
*** <desc>To get the Pending account transactions list from call API</desc>
PENDING.PROCESS:
*----------------
*
    IF StartDate EQ '' THEN     ;*Check to assign today date as Start date if end date is null
        StartDate = Today
        EB.API.Cdt('',StartDate,'-30C') ;*Minus 30 calendar days to set Start date
    END
*
    AC.Channels.GetAccountTxnsIds(AccountNo, ListType, TxnCount, PayType, StartDate, EndDate, MinimumAmount, MaximumAmount, Narrative, TransactionCode, IdList) ;*Call routine to retreive the statement entry Id's based on the date range passed for the account
*
    EB.Reports.setOData(AccountNo)      ;*Set ODATA for the below call routine
    AC.ModelBank.ECalcOpenBalance()     ;*Call routine to get the opening balance for the account
    OpeningBalance=EB.Reports.getOData()    ;*Assign the output value for opening balance to a variable
    
    IF IdList NE '' THEN
        LOOP
            REMOVE StmtId FROM IdList SETTING LIST.POS  ;*loop to get transaction details
        WHILE StmtId:LIST.POS
            GOSUB COMMON.DETAILS    ;*To get the common transaction details
            GOSUB WEALTH.DETAILS   ; *Get the Wealth transaction details
            GOSUB BALANCE.CALCULATE     ;*Do the balance calculation for the statment entries.
            IF BookingDate NE '' AND ExposureDate > Today THEN    ;*Check to list only pending transactions
                TXN.ARR<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":Narrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity   ;*Form final array
            END
        REPEAT
    END
*
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.EXACT.COUNT>
*** <desc>To get the eaxct transactions list from call API</desc>
GET.EXACT.COUNT:

    CurrListCount = ''; tempCount = ''  ;*Initialising variables

    CurrListCount = ApiCount ;*Assign the API count to curr count for exact count calculation

    tempCount = CurrListCount - TxnCount ;*Subtract to get the reminder
    
    IF tempCount GT '0' THEN
        LOOP
        UNTIL CurrListCount EQ tempCount        ;*Loop until current count is equals to transaction count
            TXN.ARR<-1> = ID.ARR<CurrListCount>     ;*Assigning to a new variable
            CurrListCount = CurrListCount -1        ;*Reduce the curr instance to minus 1
        REPEAT
    END ELSE
        LOOP
        UNTIL CurrListCount EQ '0'
            TXN.ARR<-1> = ID.ARR<CurrListCount>     ;*Assigning to a new variable
            CurrListCount = CurrListCount -1        ;*Reduce the curr instance to minus 1
        REPEAT
    END
*
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= INDIVIDUAL>
*** <desc>To get a particular transaction details </desc>
INDIVIDUAL.PROCESS:
*--------------------
    
    StmtId = StatementReference     ;*Assign the retrieved statement entry record from selection field to Statment entry Id variable
    GOSUB COMMON.DETAILS
    GOSUB WEALTH.DETAILS   ; *Get the Wealth transaction details
    AccRec = AC.AccountOpening.Account.Read(StmtAccount, ErrAcct)           ;*Read the account
    BEGIN CASE
        CASE AccRec EQ ''                                                           ;* If Account Record is Null Do Nothing
        CASE AccRec<AC.AccountOpening.Account.AccountTitleOne,ExtLang> NE ''        ;* Check if description is present in the External User Language
            AcctTitle = AccRec<AC.AccountOpening.Account.AccountTitleOne, ExtLang>  ;* Read the Account Title in the External User Language
        CASE 1                                                                      ;* If Description is not available in the External User Preferred Language
            AcctTitle = AccRec<AC.AccountOpening.Account.AccountTitleOne, 1>        ;* Read the Account Title in the default language.
    END CASE
    CompBranchCode = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComIbanBranchId)  ;*Get the company branch code
    StartDate = AccRec<AC.AccountOpening.Account.OpeningDate, 1>
    
    GOSUB GET.BALANCE.SNAP.FOR.STMT
    TXN.ARR<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":Narrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity  ;*To get the payment reference   ;*Form final array
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.NARRATIVE.DETAILS>
*** <desc>To Form NARRATIVE for each stmt Id passed</desc>
GET.NARRATIVE.DETAILS:
    NarrTmp1=''
    NarrTmp2=''
    RTransaction=''
    EB.Reports.setOData(StmtId)         ;* To pass the StmtId to EGetNarrative
    EB.Reports.setRRecord(StmtRec)      ;* To pass StmtRec to EGetNarrative
    AC.ModelBank.EGetNarrative()        ;* Making api call to retrieve derive narrative field
    AC.ModelBank.EGetSpecialNarr()      ;* Making api call to append the Narrative derived from EGetNarrative with STMT.ENTRY Narrative field if exists
    RRecord=EB.Reports.getRRecord();        ;* Reads STMT.ENTRY rec set in EGetSpecialNarr
    NarrTmp1=RRecord<AC.EntryCreation.StmtEntry.SteNarrative>;                  ;* Read Narrative field updated in STMT.ENTRY in EGetSpecialNarr
    CHANGE @VM TO ' ' IN NarrTmp1
    TransactionCode = EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteTransactionCode>                 ;* Extract Transaction code form STMT>ENTRY record
    RTransaction = ST.Config.tableTransaction(TransactionCode,ERR)     ;* Read Transaction record
    NarrTmp2=RTransaction<1,ExtLang>                                    ;* Extract Description value from Transaction table
    Narrative=NarrTmp2:' ':NarrTmp1                         ;* Append Narrative value from Transaction Description and value derived from EGetSpecialNarr
    EB.Reports.setOData('')
    EB.Reports.setRRecord('')
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GET.BALANCE.SNAP.FOR.STMT:
    AC.Channels.GetAccountTxnsIds(StmtAccount, 'COMPLETED', TxnCount, PayType, StartDate, EndDate, MinimumAmount, MaximumAmount, Narrative, TransactionCode, IdList) ;*Call routine to retrieve the statement entry id's based on the account no, start date and end date
*
    EB.Reports.setOData(StmtAccount)      ;*Set ODATA for the below call routine
    AC.ModelBank.ECalcOpenBalance()     ;*Call routine to get the opening balance for the account
    OpeningBalance=EB.Reports.getOData()    ;*Assign the output value for opening balance to a variable
*
    StmtFound = ''
    IF IdList NE '' THEN
        LOOP
            REMOVE SId FROM IdList SETTING LIST.POS  ;*Loop statement to get the transaction details
        WHILE SId:LIST.POS
            StmtRec = AC.EntryCreation.StmtEntry.Read(SId,ErrStmt)
            AmtLcy = StmtRec<AC.EntryCreation.StmtEntry.SteAmountLcy>       ;*To get Local currency amount
            AmtFcy = StmtRec<AC.EntryCreation.StmtEntry.SteAmountFcy>       ;*To get foreign currency amount
            IF StmtFound EQ '1' THEN
                BREAK
            END ELSE
                GOSUB BALANCE.CALCULATE     ;*Do the balance calculation for the statment entries.
            END
            IF StmtId EQ SId THEN
                StmtFound = '1'
            END
        REPEAT
    END
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END
