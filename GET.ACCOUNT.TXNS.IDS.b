* @ValidationCode : MjotMzQwNzAwODEyOkNwMTI1MjoxNjA2MzA2MTg2NzU1OnNpdmFjaGVsbGFwcGE6MTk6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDozODg6MzQw
* @ValidationInfo : Timestamp         : 25 Nov 2020 17:39:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 19
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 340/388 (87.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AC.Channels
SUBROUTINE GET.ACCOUNT.TXNS.IDS(ACCOUNT.NO,LIST.TYPE,TXN.COUNT,PAY.TYPE,START.DATE,END.DATE,MINIMUM.AMOUNT,MAXIMUM.AMOUNT,NARRATIVE,TRANSACTION.CODE,ID.LIST)
*---------------------------------------------------------------------------------------------------------------------
* Description
*-------------
* This routine used to display the transactions list for the account. The various transactions list produced by this routine are
* Completed account transactions, Pending account transactions and Search account transactions.
* The core API EStmtEntList is used to retrieve the statement entry list
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Call API
* Attached To        : Attached to any API. {e.g. E.NOF.TC.TXNS.LIST}
* IN Parameters      : Account no, List Type, Pay Type, Txn Count, Date From, Date To, Minimum Amount, Maximum Amount, Description and Transaction Code
* Out Parameters     : TXN.ARR(Stmt Id's) or TXN.ARR(StmtId, BookingDate, Narrative, StmtAccount, StmtAmount, StmtCurrency, AcctTitle, CompBranchCode, ImDocId, Notes, ImageId and TransReference)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1648966 / Task - 1843348
*            TCIB Retail : Transactions Detail (Recent Transaction )
*
* 18/08/17 - Defect - 2240273 / Task - 2240275
*          - PFM Integration - BFW coding
*
* 18/08/17 - Defect - 2432544 / Task - 2441940
*          - Narrative field shown should be same as displayed in STMT.ENT.BOOK enquiry
*
* 29/10/19 - Defect 3403370 / Task 3408978
*            Narrative field should support multi language
*
* 11/12/19 - Defect 3474331 / Task 3482604
*            The RECENT transaction listing is not displaying the correct order in TCIB screen
*
* 04/03/20 - Enhancement 3492893 / Task 3622075
*            Calculate balance for each transaction based on the opening balance.
*
* 04/03/20 - Enhancement 3492893 / Task 3650363
*            Search transactions with multiple Transaction codes.
*
* 18/09/20 - Defect 3976543 / Task 3976536
*            Infinity - Minimum/Maximum amount check validated against the statement amount without negative/postive sign
*
* 01/10/20 - Task 3999654
*            Statement balance and transaction reference update during search.
*
*09/11/20  - Infinity Wealth Development
*            ADP-1720
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING AC.ModelBank
    $USING AC.EntryCreation
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.Reports
    $USING IM.Foundation
    $USING ST.Config
    $USING EB.Security
    $USING ST.CompanyCreation
    $USING SC.SctTrading
    $USING SC.SctOrderCapture
    $USING SC.SctOffMarketTrades
    $USING SC.SctPositionTransfer
    $USING SC.ScoSecurityMasterMaintenance
    $USING DX.Trade
    $USING DX.Order
    $USING DX.Configuration
*-----------------------------------------------------------------------------
    
    IF (LIST.TYPE NE '') AND (ACCOUNT.NO NE '') AND (START.DATE NE '') THEN     ;*Mandatory check to proceed with the api
        GOSUB INIT
        GOSUB PROCESS           ;*Get the statement entry id's
    END

RETURN
*------------------------------------------------------------------------------------------------------------
*** <region name= INIT>
*** <desc>Initialise required variables and open files</desc>
INIT:
    ExtLang = '';EntryBalance='';
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN                                                       ;* If External User Language is not available
        ExtLang =1                                                              ;* Assigning Default Language position to read language multi value fields
    END
    
RETURN
*------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>To re-direct to the appropriate method for getting statment entry id's</desc>
PROCESS:
*--------
    ID.LIST = '';
    TRANS.CODE.LIST = TRANSACTION.CODE
    CHANGE @SM TO @VM IN TRANS.CODE.LIST

    BEGIN CASE
        CASE LIST.TYPE EQ 'COMPLETED'   ;*Case for completed statement entry id's
            IF TRANSACTION.CODE NE '' AND MINIMUM.AMOUNT EQ '' AND MAXIMUM.AMOUNT EQ '' AND NARRATIVE EQ '' AND PAY.TYPE EQ '' THEN
                GOSUB GET.SEARCH.LIST
            END ELSE
                GOSUB GET.COMPLETE.LIST
                GOSUB FORM.ARRAY
            END
        CASE LIST.TYPE EQ 'SEARCH'      ;*Case for search account statement entry id's
            GOSUB GET.SEARCH.LIST
        CASE LIST.TYPE EQ 'PENDING'     ;*Case for pending account statement entry id's
            IF TRANSACTION.CODE NE '' AND MINIMUM.AMOUNT EQ '' AND MAXIMUM.AMOUNT EQ '' AND NARRATIVE EQ '' AND PAY.TYPE EQ '' THEN
                GOSUB GET.SEARCH.LIST
            END ELSE
                GOSUB GET.COMPLETE.LIST
                GOSUB FORM.ARRAY
            END
    END CASE

RETURN
*------------------------------------------------------------------------------------------------------------
*** <region name= GET.COMPLETE.LIST>
*** <desc>Get the statement entry id's based on the date range</desc>
GET.COMPLETE.LIST:
*-----------------
    BEGIN CASE
        CASE LIST.TYPE EQ 'COMPLETED'
            IF END.DATE EQ '' THEN
                END.DATE = EB.SystemTables.getToday()   ;*Assign today date to end date if it is null
            END
        CASE LIST.TYPE EQ 'PENDING'
            IF END.DATE EQ '' THEN
                END.DATE = EB.SystemTables.getToday()       ;*get today date
                EB.API.Cdt('',END.DATE,'+30C')              ;*Assign end date as one month forward
            END
        CASE LIST.TYPE EQ 'SEARCH'
            IF END.DATE EQ '' THEN
                END.DATE = EB.SystemTables.getToday()       ;*get today date
            END
    END CASE
*
    TXN.ARR = '';
    tmp=EB.Reports.getDFields(); tmp<1>='ACCT.ID'; EB.Reports.setDFields(tmp)       ;*Account input parameter
    tmp=EB.Reports.getDFields(); tmp<2>='BOOKING.DATE'; EB.Reports.setDFields(tmp)      ;*Booking date input parameter
    EB.Reports.setDLogicalOperands(1:@FM:2)

    tmp=EB.Reports.getDRangeAndValue(); tmp<1>=ACCOUNT.NO; EB.Reports.setDRangeAndValue(tmp)        ;*Get the account account value
    tmp=EB.Reports.getDRangeAndValue(); tmp<2>=START.DATE:@VM:END.DATE; EB.Reports.setDRangeAndValue(tmp)       ;*Get the date range value

    AC.ModelBank.EStmtEntList(TXN.ARR)      ;*Call api to get the statement entry id's

RETURN
*---------------------------------------------------------------------------------------------------------------
*** <region name= GET.SEARCH.LIST>
*** <desc>To re-direct to the appropriate search method to get the statement entry id's</desc>
GET.SEARCH.LIST:
*---------------
*Reference search parameters - MINIMUM.AMOUNT,MAXIMUM.AMOUNT,NARRATIVE,TRANSACTION.CODE
    AMOUNT.RANGE = '';
    
    IF MAXIMUM.AMOUNT NE '' OR MINIMUM.AMOUNT NE '' THEN   ;*Set Amount range variable for case statements
        AMOUNT.RANGE = '1'
    END

    BEGIN CASE
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 1000 - Pay type NE null
            GOSUB PAY.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 1001 - Pay type and Transaction code NE null
            GOSUB PAY.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''       ;*Case for 1010 - Pay type and Narrative NE null
            GOSUB PAY.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''       ;*Case for 1011 - Pay type, narrative and transaction code NE null
            GOSUB PAY.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 1100 - Pay type and amount range NE null
            GOSUB AMOUNT.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 1101 - Pay type, amount range and transaction code NE null
            GOSUB AMOUNT.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''       ;*Case for 1110 - Pay type, amount range and narrative NE null
            GOSUB AMOUNT.TYPE.PROCESS
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''       ;*Case for 1111 - Pay type, amount range, transaction code and narrative ne null
            GOSUB AMOUNT.TYPE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 0100 - Amount range NE null
            GOSUB NARRATIVE.TYPE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 0101 - Amount range and transaction code NE null
            GOSUB NARRATIVE.TYPE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''       ;*Case for 0110 - Amount range and narrative NE null
            GOSUB NARRATIVE.TYPE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''       ;*Case for 0111 - Amount range, narrative and transaction code NE null
            GOSUB NARRATIVE.TYPE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''       ;*Case for 0010 - Narrative NE null
            GOSUB TXN.CODE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''       ;*Case for 0011 - Narrative and transaction code NE null
            GOSUB TXN.CODE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 0001 - Transaction code NE null
            GOSUB TXN.CODE.PROCESS
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 0000 - Date range NE null
            GOSUB TXN.CODE.PROCESS
    END CASE

RETURN
*-------------------------------------------------------------------------------------------------------------
*** <region name= FORM.ARRAY>
*** <desc>To assign the returned array to the final array</desc>
FORM.ARRAY:
*-----------

    ID.LIST<-1> = TXN.ARR

RETURN
*---------------------------------------------------------------------------------------------------------------
*** <region name= PAY.TYPE.PROCESS>
*** <desc>To get the statement entry id's for binaries such as 1000,1001,1010 and 1011</desc>
PAY.TYPE.PROCESS:
*-----------------
    
    GOSUB GET.COMPLETE.LIST         ;*Get the statment entry id's based on the date range filter
    IF TXN.ARR NE '' THEN
        LOOP
            REMOVE StmtId FROM TXN.ARR SETTING LIST.POS
        WHILE StmtId:LIST.POS
            GOSUB GET.COMMON.DETAILS    ;*Get the common transaction details
            GOSUB WEALTH.DETAILS
            GOSUB PAY.TYPE.CASE.STMTS   ;*Filter further with additional input parameters passed

        REPEAT
    END
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= AMOUNT.TYPE.PROCESS>
*** <desc>To get the statement entry id's for binaries such as 1100,1101,1110,1111</desc>
AMOUNT.TYPE.PROCESS:
*----------------
    
    GOSUB GET.COMPLETE.LIST         ;*Get the statment entry id's based on the date range filter
    IF TXN.ARR NE '' THEN
        LOOP
            REMOVE StmtId FROM TXN.ARR SETTING LIST.POS
        WHILE StmtId:LIST.POS
            GOSUB GET.COMMON.DETAILS        ;*Get the common transaction details
            GOSUB WEALTH.DETAILS
            GOSUB AMOUNT.TYPE.CASE.STMTS       ;*Filter further with additional input parameters passed
        REPEAT
    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= NARRATIVE.TYPE.PROCESS>
*** <desc>To get the statement entry id's for binaries such as 0100, 0101,0110, 0111</desc>
NARRATIVE.TYPE.PROCESS:
*-------------------
    
    GOSUB GET.COMPLETE.LIST         ;*Get the statment entry id's based on the date range filter
    IF TXN.ARR NE '' THEN

        LOOP
            REMOVE StmtId FROM TXN.ARR SETTING LIST.POS
        WHILE StmtId:LIST.POS
            GOSUB GET.COMMON.DETAILS                ;*Get the common transaction details
            GOSUB WEALTH.DETAILS
            GOSUB NARRATIVE.TYPE.CASE.STMTS             ;*Filter further with additional input parameters passed
        REPEAT
    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= TXN.CODE.PROCESS>
*** <desc>To get the statement entry id's for binaries such as 0000, 0001, 0010, 0011</desc>
TXN.CODE.PROCESS:
*-------------------
    
    GOSUB GET.COMPLETE.LIST             ;*Get the statment entry id's based on the date range filter
    IF TXN.ARR NE '' THEN
        LOOP
            REMOVE StmtId FROM TXN.ARR SETTING LIST.POS
        WHILE StmtId:LIST.POS
            GOSUB GET.COMMON.DETAILS            ;*Get the common transaction details
            GOSUB WEALTH.DETAILS
            GOSUB TXN.CODE.CASE.STMTS          ;*Filter further with additional input parameters passed
        REPEAT
    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= AMOUNT.CHECK>
*** <desc>To get the amount input parameter filtered</desc>
AMOUNT.CHECK:
*------------
    
    paymentAmount=StmtAmount ;* assign the statement amount
    IF StmtAmount[1,1] EQ "-" THEN
        paymentAmount=paymentAmount[2,99] ;* extract the amount without sign(negative)
    END
    BEGIN CASE
        CASE MAXIMUM.AMOUNT NE '' AND MINIMUM.AMOUNT NE ''      ;*Case for both maximum and minimum amount is passed as input parameters
            IF paymentAmount <= MAXIMUM.AMOUNT AND paymentAmount >= MINIMUM.AMOUNT THEN
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity        ;* To assign statement entry Id
            END
        CASE MAXIMUM.AMOUNT NE '' OR MINIMUM.AMOUNT EQ ''       ;*Case for maximum amount alone passed as input parameters
            IF paymentAmount <= MAXIMUM.AMOUNT THEN
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
        CASE MINIMUM.AMOUNT NE '' OR MAXIMUM.AMOUNT EQ ''       ;*Case for minimum amount alone passed as input parameters
            IF paymentAmount >= MINIMUM.AMOUNT THEN
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
    END CASE

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= GET.COMMON.DETAILS>
*** <desc>To get the common transaction details along with IM details</desc>
GET.COMMON.DETAILS:
*------------------
    StmtRec = ''; StatementDateTime = ''; BookingDate = ''; StmtNarrative = '';  AmtLcy = ''; AmtFcy = ''; StmtAmount = ''; StmtCurrency = ''; ErrStmt = '';
    StmtAccount = ACCOUNT.NO; AccRec = ''; AcctTitle = ''; CompBranchCode = ''; ErrAcct = ''; CreditAmount = ''; DebitAmount = ''; NarrativeFound = '';
    StmtBalance = ''; TransReference = '';IsImInstalled = ''; IsDXInstalled = ''; IsSCInstalled = '';
*
    EB.Reports.setOData(ACCOUNT.NO)      ;*Set ODATA for the below call routine
    AC.ModelBank.ECalcOpenBalance()     ;*Call routine to get the opening balance for the account
    OpeningBalance=EB.Reports.getOData()    ;*Assign the output value for opening balance to a variable
    StmtRec = AC.EntryCreation.StmtEntry.Read(StmtId,ErrStmt)      ;* To read statement entry Id
    IF StmtRec NE '' THEN
        BookingDate= StmtRec<AC.EntryCreation.StmtEntry.SteBookingDate>   ;* To get booking date
        AmtLcy = StmtRec<AC.EntryCreation.StmtEntry.SteAmountLcy>           ;*To get the Amount local currency
        AmtFcy = StmtRec<AC.EntryCreation.StmtEntry.SteAmountFcy>           ;*To get the Amount foriegn currency
        StmtCode = StmtRec<AC.EntryCreation.StmtEntry.SteTransactionCode>   ;*To get the transaction code
        StmtCode = TRIM(StmtCode)
        StmtCurrency = StmtRec<AC.EntryCreation.StmtEntry.SteCurrency>      ;*To get the statement currency
        TransReference = StmtRec<AC.EntryCreation.StmtEntry.SteTransReference>  ;*To get the payment reference
        IF StmtRec<AC.EntryCreation.StmtEntry.SteSystemId> EQ "PP" THEN
            TransReference = StmtRec<AC.EntryCreation.StmtEntry.SteTheirReference>  ;*To get the payment reference
        END
        StatementDateTime = StmtRec<AC.EntryCreation.StmtEntry.SteDateTime> ;*To read audit date time
        GOSUB BALANCE.CALCULATE
        GOSUB GET.NARRATIVE.DETAILS      ;*To get the narrative value
        IF AmtFcy NE '' THEN
            StmtAmount = AmtFcy     ;*Set credit currency
        END ELSE
            StmtAmount = AmtLcy     ;*Set local currency
        END

        IF StmtAmount GT 0 THEN
            CreditAmount = StmtAmount       ;*If amount is positive, then assign it to credit amount
        END ELSE
            CreditAmount=''
        END

        IF (StmtAmount NE '') AND (StmtAmount LT 0) THEN        ;*If amount is negative, then assign it to debit amount
            DebitAmount = StmtAmount
        END ELSE
            DebitAmount=''
        END

        FINDSTR NARRATIVE IN StmtNarrative SETTING NR.POS THEN     ;*Locate narrative from the statement narrative
            NarrativeFound = "1"        ;*Set narrative found variable
        END

        GOSUB IM.DETAILS            ;*Get the IM details of the transaction
    END
*
RETURN
*----------------------------------------------------------------------------------------------------------------
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

*** <region name= IM.DETAILS>
*** <desc>To get the Im details of the transaction</desc>
IM.DETAILS:
*-----------

* Image details
    ImDocId = ''; Notes = ''; ImageId = ''; ImageType = '';*intialising IM variables
    ImageDetailsRec = IM.Foundation.ImImageDetails.Read(StmtId,ErrRec)      ;*To read tc image details records
    ImDocId = ImageDetailsRec<IM.Foundation.ImImageDetails.ImImageId>     ;*Get the Im document id
    ImageId = ImageDetailsRec<IM.Foundation.ImImageDetails.ImImageName>   ;*Get the Im image id
    ImageType = ImageDetailsRec<IM.Foundation.ImImageDetails.ImImageType> ;*Get the Im image type
    Notes = ImageDetailsRec<IM.Foundation.ImImageDetails.ImNotes>         ;*Get the Im notes

RETURN
*----------------------------------------------------------------------------------------------------------------------
*** <region name= PAY.TYPE.CASE.STMTS>
*** <desc>To filter further for the binaries such as 1000,1001,1010 and 1011</desc>
PAY.TYPE.CASE.STMTS:
*--------------------
    
    BEGIN CASE
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 1000 - Pay type NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount THEN  ;* Filter for credit payments
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount THEN  ;* Filter for debit payment
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2 :"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity       ;* To assign statement entry Id
            END
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 1001 - Pay type and Transaction code NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN  ;* Filter for credit payments
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN  ;* Filter for debit payment
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity        ;* To assign statement entry Id
            END
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''           ;*Case for 1010 - Pay type and Narrative NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount AND (NarrativeFound NE '') THEN  ;* Filter for credit payments
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount AND (NarrativeFound NE '') THEN  ;* Filter for debit payment
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity        ;* To assign statement entry Id
            END
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''           ;*Case for 1011 - Pay type, narrative and transaction code NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount AND (NarrativeFound NE '') AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN  ;* Filter for credit payments
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount AND (NarrativeFound NE '') AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN  ;* Filter for debit payment
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity        ;* To assign statement entry Id
            END
    END CASE
RETURN
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= AMOUNT.TYPE.CASE.STMTS>
*** <desc>To filter further for the binaries such as 1100,1101,1110,1111</desc>
AMOUNT.TYPE.CASE.STMTS:
*--------------------
    
    BEGIN CASE
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 1100 - Pay type and amount range NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount THEN  ;* Filter for credit payments
                GOSUB AMOUNT.CHECK
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount THEN  ;* Filter for debit payment
                GOSUB AMOUNT.CHECK
            END
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 1101 - Pay type, amount range and transaction code NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN ;* Filter for credit payments
                GOSUB AMOUNT.CHECK
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN  ;* Filter for debit payments
                GOSUB AMOUNT.CHECK
            END
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''           ;*Case for 1110 - Pay type, amount range and narrative NE null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount AND (NarrativeFound NE '') THEN  ;* Filter for credit payments
                GOSUB AMOUNT.CHECK
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount AND (NarrativeFound NE '') THEN  ;* Filter for debit payment
                GOSUB AMOUNT.CHECK
            END
        CASE PAY.TYPE NE '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''           ;*Case for 1111 - Pay type, amount range, transaction code and narrative ne null
            IF PAY.TYPE EQ 'PAIDOUT' AND DebitAmount AND (NarrativeFound NE '') AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN ;* Filter for credit payments
                GOSUB AMOUNT.CHECK
            END
            IF PAY.TYPE EQ 'PAIDIN' AND CreditAmount AND (NarrativeFound NE '') AND (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN  ;* Filter for debit payment
                GOSUB AMOUNT.CHECK
            END
    END CASE
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= NARRATIVE.TYPE.CASE.STMTS>
*** <desc>To filter further for the binaries such as 0100, 0101,0110, 0111</desc>
NARRATIVE.TYPE.CASE.STMTS:
*------------------------

    BEGIN CASE
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''       ;*Case for 0100 - Amount range NE null
            GOSUB AMOUNT.CHECK
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''       ;*Case for 0101 - Amount range and transaction code NE null
            IF (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) THEN
                GOSUB AMOUNT.CHECK
            END
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''       ;*Case for 0110 - Amount range and narrative NE null
            IF (NarrativeFound NE '') THEN
                GOSUB AMOUNT.CHECK
            END
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE NE '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''       ;*Case for 0111 - Amount range, narrative and transaction code NE null
            IF (TRANSACTION.CODE EQ StmtCode OR StmtCode MATCHES TRANS.CODE.LIST) AND (NarrativeFound NE '') THEN
                GOSUB AMOUNT.CHECK
            END
    END CASE

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= TXN.CODE.CASE.STMTS>
*** <desc>To filter further for the binaries such as 0000, 0001, 0010, 0011</desc>
TXN.CODE.CASE.STMTS:
*---------------------

    BEGIN CASE
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE EQ ''            ;*Case for 0010 - Narrative NE null
            IF (NarrativeFound NE '') THEN
                ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
            END
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE NE '' AND TRANSACTION.CODE NE ''            ;*Case for 0011 - Narrative and transaction code NE null
            IF (NarrativeFound NE '') AND (StmtCode MATCHES TRANS.CODE.LIST OR TRANSACTION.CODE EQ StmtCode) THEN
                IF LIST.TYPE EQ 'COMPLETED' OR LIST.TYPE EQ 'PENDING' THEN
                    ID.LIST<-1> = StmtId
                END ELSE
                    ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
                END
            END
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE NE ''             ;*Case for 0001 - Transaction code NE null
            IF StmtCode MATCHES TRANS.CODE.LIST OR TRANSACTION.CODE EQ StmtCode THEN
                IF LIST.TYPE EQ 'COMPLETED' OR LIST.TYPE EQ 'PENDING' THEN
                    ID.LIST<-1> = StmtId
                END ELSE
                    ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
                END
            END
        CASE PAY.TYPE EQ '' AND AMOUNT.RANGE EQ '' AND NARRATIVE EQ '' AND TRANSACTION.CODE EQ ''              ;*Case for 0000 - Date range NE null
            ID.LIST<-1> = StatementDateTime:"*":BookingDate:"*":StmtId:"*":StmtNarrative:"*":StmtAccount:"*":StmtAmount:"*":StmtCurrency:"*":AcctTitle:"*":CompBranchCode:"*":ImDocId:"*":Notes:"*":ImageId:"*":StmtBalance:"*":TransReference:"*":StmtCode:"*":NarrTmp1:"*":NarrTmp2:"*":ShortName:"*":Exchange:"*":ISIN:"*":ValueDate:"*":Quantity         ;* To assign statement entry Id
    END CASE

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
    StmtNarrative=NarrTmp2:' ':NarrTmp1                         ;* Append Narrative value from Transaction Description and value derived from EGetSpecialNarr
    EB.Reports.setOData('')
    EB.Reports.setRRecord('')
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END

