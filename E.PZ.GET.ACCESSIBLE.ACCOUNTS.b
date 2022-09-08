* @ValidationCode : MjotMTkyOTEyMTg3MTpjcDEyNTI6MTYxMjc5MTMwMDIxODpzYWlrdW1hci5tYWtrZW5hOjg6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoyMTY6MjE0
* @ValidationInfo : Timestamp         : 08 Feb 2021 19:05:00
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 214/216 (99.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.GET.ACCESSIBLE.ACCOUNTS(ACC.DATA)
*-----------------------------------------------------------------------------
* NOFILE routine to check whether it is a call for accessbile accounts or available
* accounts and return the respective accounts and balances
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/04/19 - Enhancement 2741269 / Task 3053313
*            Routine to get all available/accessible accounts for a given consent
*
*
* 25/05/2019 - Task 3149860
*              Fix given for regression failure, to resolve the error Consent does not exist, even if AAA record exists.
*
* 30/08/19 - SI 3242848 / Task 3314598
*            Last committed txn details in enquiry output
*            Accounts with online access only are displayed in the enquiry output
*
* 11/03/19 - Defect 3634770 / Task 3635091
*           Changes to include debtor Name in account and payment status APIs
*
* 02/06/2020 - Defect 3771155 / Task 3778517
*              Task to fetch product id based on language code in user record.
*
* 20/12/20 - EN 3874070 / Task 4143098
*            PSD2 Eurobank changes.
* 15/12/20 - Enhancement 3760081 / Task 4133585
*          -  New routine implementation AC.READ.ACCT.STMT.PRINT to facilitate READ on STMT.PRINTED and STMT2.PRINTED files
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING PZ.Consent
    $USING PZ.ModelBank
    $USING AC.AccountOpening
    $USING AC.CashFlow
    $USING ST.Config
    $USING AA.ProductManagement
    $USING EB.API
    $USING AC.API
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING AC.HighVolume
    $USING AC.EntryCreation
    $USING ST.Customer
    $USING EB.Security
    $USING AC.AccountStatement
    $USING PZ.Config
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE                                ;* Initialise the variables
    IF NOT(EB.Reports.getEnqError()) THEN
        GOSUB BUILD.ACC.DATA                          ;* Build the account related details
    END

RETURN
*-----------------------------------------------------------------------------
INITIALISE:

    ACC.DATA = ''
    POS = ''
    ID.POS = ''
    BAL.POS = ''
    ARRANGEMENT.ID = ''
    CONSENT.RECORD = ''
    CONSENT.ERR = ''
    ENQ.ERROR = ''
    PROPERTY.RECORD = ''
    REC.ERR = ''
    ACCOUNTS.LIST = ''
    ERROR.CODE = ''
    ACC.ERR = ''
    CAT.ERR = ''
    AA.ARR.ERR = ''
    PRD.ERR = ''
    BALANCE.INDICATOR = ''
    TRANSACTION.INDICATOR = ''
    HIS.ERR = ''
    BAL.POS = ''
    ARR.ERR = ''
    CONS.ERR = ''
    CNT = ''
    AVAILABLE.ACCOUNTS.FLAG = ''
    ACCESSIBLE.ACCOUNT.FLAG = ''
    REF.DATE = EB.SystemTables.getToday()
    EB.API.Cdt("", REF.DATE, "-1C") ;*Reference date should be the previous day for Closing booked balance
    PREV.DAY = REF.DATE
    REC.STATUS = ''
    PRODUCT.DESC = ''
    ARRANGEMENT.ACT.REC = ''
    CONERR = ''
    PROPERTY.CLASS = "ACCOUNT.CONSENT"
    TODAY.DATE = EB.SystemTables.getToday()
    ONLINE.POS = ''
    
;*Locate Consent Id
    LOCATE 'CONSENT.ID' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN    ;* locate CONSENT.ID in enquiry data and get position
        CONSENT.ID = EB.Reports.getDRangeAndValue()<ID.POS>
    END
    
;*Locate with Balance
    LOCATE 'WITH.BALANCE' IN EB.Reports.getDFields()<1> SETTING BAL.POS THEN    ;* locate CONSENT.ID in enquiry data and get position
        WITH.BALANCE = EB.Reports.getDRangeAndValue()<BAL.POS>
    END
    
;*Validations on ConsentId
    PZ.ModelBank.PzReadConsent(CONSENT.ID,PROPERTY.CLASS,REC.STATUS,ARRANGEMENT.ID,ARRANGEMENT.ACT.REC,CONSENT.RECORD,CONERR,PRODUCT.DESC,'')

    IF NOT(ARRANGEMENT.ACT.REC) THEN ;*If such an arrangement does not exist, throw error
        EB.SystemTables.setEtext('')
        ENQ.ERROR = "PZ-INVALID.CONSENT"
        EB.Reports.setEnqError(ENQ.ERROR)
        RETURN
    END ELSE
        IF NOT(CONSENT.RECORD) THEN
            EB.SystemTables.setEtext('')
            ENQ.ERROR = "PZ-INVALID.CONSENT"
            EB.Reports.setEnqError(ENQ.ERROR)
            RETURN
        END
        EXPIRY.DATE = CONSENT.RECORD<PZ.Consent.AccConsent.ExpiryDate>         ;*Get expiry date from that record
        IF EXPIRY.DATE AND EXPIRY.DATE LT EB.SystemTables.getToday() THEN ;*If consent is expired, throw error
            EB.SystemTables.setEtext('')
            ENQ.ERROR = "PZ-CONSENT.EXPIRED"
            EB.Reports.setEnqError(ENQ.ERROR)
            RETURN
        END
    END

RETURN
*-----------------------------------------------------------------------------
BUILD.ACC.DATA:

    GOSUB GET.ACCOUNTS.LIST ;*Get list of accounts to be processed
    EXTERNAL.USER.ID = CONSENT.RECORD<PZ.Consent.AccConsent.EbExternalUserId>
  
    IF EXTERNAL.USER.ID THEN
        
*** Check online access for TRANSACT flow alone.
        FnPzParameter = 'F.PZ.PARAMETER'
        FvPzParameter = ''
        PzParam = ''
        Er = ''
        ST.CompanyCreation.EbReadParameter(FnPzParameter, '', '', PzParam, '', FvPzParameter, Er)
        permissionCheck = PzParam<PZ.Config.PzParameter.permissionsCheck>
        IF permissionCheck NE "EXTERNAL" THEN
            GOSUB CHECK.ONLINE.ACCESS ;*Get list of accounts which have online access
        END
    END

    ACC.CNT = DCOUNT(ACCOUNTS.LIST, @FM)
    FOR CNT = 1 TO ACC.CNT ; *For all returned accounts, get balances and product
        IF EXTERNAL.USER.ID AND permissionCheck NE "EXTERNAL" THEN    ;* check if online accessible account when logged in via external user
            LOCATE ACCOUNTS.LIST<CNT> IN ONLINE.ACCOUNTS<1,1,1> SETTING ONLINE.POS ELSE CONTINUE
        END
* exclude blocked accounts if today's date is within the given block period
        IF ACC.BLOCKED<CNT> = "YES" AND BLOCKED.FROM.DATES<CNT> LE TODAY.DATE AND (NOT(BLOCKED.TILL.DATES<CNT>) OR BLOCKED.TILL.DATES<CNT> GE TODAY.DATE) THEN CONTINUE
    
        GOSUB REINITIALISE ;* Reset flags for every account
        
        AC.AccountOpening.CheckAccount(ACCOUNT.ID, '', CHECK.DATA, 'ONLINE', AC.ARRAY, CHECK.DATA.RESULT, OVERRIDE.CODE, ERROR.CODE)       ;* Validate the account
        IBAN = CHECK.DATA.RESULT<AC.AccountOpening.AccountIban,1>
        IS.ARR.ACCOUNT = CHECK.DATA.RESULT<AC.AccountOpening.AccountArrangement,1>  ;* Arrangement id returned
    
        GOSUB GET.PRODUCT  ;*Get product and name
        GOSUB GET.CONSENT ;*Get consent type
        GOSUB GET.LAST.COMMITTED.TXN ;* Get last committed txn details

        IF WITH.BALANCE[1,1] EQ 'Y' AND BALANCE.INDICATOR EQ 'YES' THEN
            GOSUB GET.BALANCES ;*Get balances for accessible accounts if account consent is balances
        END
        
        GOSUB BUILD.ENQ.DATA ;*Build final enquiry result
    
    NEXT CNT

RETURN
*-----------------------------------------------------------------------------
GET.BALANCES:

;*Get online actual balance
    ONLINE.ACTUAL.BALANCE = CHECK.DATA.RESULT<AC.AccountOpening.AccountBalance,1>   ;* OnlineActualBal returned
    LIMIT.AMOUNT = CHECK.DATA.RESULT<AC.AccountOpening.AccountBalance,4>    ;* LimitAmt returned
    LOCKED.AMOUNT = CHECK.DATA.RESULT<AC.AccountOpening.AccountBalance,3>   ;* LockedAmt returned
 
;* Get interin available with limit
    AC.CashFlow.AccountserviceGetworkingbalance(ACCOUNT.ID, WORKING.BALANCE, "") ;*To get the Working balance of the account
    INTERIM.AVAILABLE.WITH.LIMIT = (WORKING.BALANCE - LOCKED.AMOUNT) + LIMIT.AMOUNT

;* Get closing balance for the previous day
    AC.API.EbGetAcctBalance(ACCOUNT.ID, '', "BOOKING", PREV.DAY, "", CLOSING.BOOKED.BAL, "", "", OUT.ERR) ;*To get the Closing balance for the previous day

RETURN
*-----------------------------------------------------------------------------
GET.PRODUCT:

    ACCOUNT.RECORD = AC.AccountOpening.Account.Read(ACCOUNT.ID, ACC.ERR)
    IF NOT(ACCOUNT.RECORD) THEN
        EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
        ACCOUNT.ID.HIS = ACCOUNT.ID
        EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS, ACCOUNT.ID.HIS, ACCOUNT.RECORD, HIS.ERR)
    END
    NAME = ACCOUNT.RECORD<AC.AccountOpening.Account.ShortTitle> ;*get Name as short title as the account
    AC.CCY = ACCOUNT.RECORD<AC.AccountOpening.Account.Currency> ;*get the currency of the account
    CUS.ERR = ''
    ACC.CUS = ACCOUNT.RECORD<AC.AccountOpening.Account.Customer> ;*Assign Customer name otherwise
    CUSTOMER.REC = ST.Customer.Customer.Read(ACC.CUS, CUS.ERR)
    LANGUAGE.ID = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>
    DETAILS = CUSTOMER.REC<ST.Customer.Customer.EbCusNameOne,LANGUAGE.ID>

    BEGIN CASE
        CASE IS.ARR.ACCOUNT ;*Incase of arrangement account
            AA.ARR.RECORD = AA.Framework.Arrangement.Read(IS.ARR.ACCOUNT, AA.ARR.ERR)
            PROD.ID = AA.ARR.RECORD<AA.Framework.Arrangement.ArrProduct>
            PROD.RECORD = AA.ProductManagement.Product.Read(PROD.ID, PRD.ERR)
            PRODUCT.ID = PROD.RECORD<AA.ProductManagement.Product.PdtDescription,LANGUAGE.ID> ;*get product from description of AA.PRODUCT
            IF NOT(PRODUCT.ID) THEN
                PRODUCT.ID = PROD.RECORD<AA.ProductManagement.Product.PdtDescription,1>
            END
        CASE 1 ;*Incase of normal accounts
            ACC.CATEGORY = ACCOUNT.RECORD<AC.AccountOpening.Account.Category>
            CATEGORY.RECORD = ST.Config.Category.Read(ACC.CATEGORY, CAT.ERR)
            PRODUCT.ID = CATEGORY.RECORD<ST.Config.Category.EbCatDescription,LANGUAGE.ID> ;*Get product from description of category
            IF NOT(PRODUCT.ID) THEN
                PRODUCT.ID = CATEGORY.RECORD<ST.Config.Category.EbCatDescription,1>
            END
    END CASE

RETURN
*-----------------------------------------------------------------------------
GET.ACCOUNTS.LIST:

    DEFAULT.CONSENT.TYPE = CONSENT.RECORD<PZ.Consent.AccConsent.DefConsentType>
    ARR.CUSTOMER = ARRANGEMENT.ACT.REC<AA.Framework.ArrangementActivity.ArrActCustomer>
    ACCOUNTS.LIST = RAISE(CONSENT.RECORD<PZ.Consent.AccConsent.AccountId>) ;* If accounts already exist in the consent
    ACC.BLOCKED = RAISE(CONSENT.RECORD<PZ.Consent.AccConsent.AccBlock>)
    BLOCKED.FROM.DATES = RAISE(CONSENT.RECORD<PZ.Consent.AccConsent.AccBlockFrom>)
    BLOCKED.TILL.DATES = RAISE(CONSENT.RECORD<PZ.Consent.AccConsent.AccBlockTill>)
            
RETURN
*-----------------------------------------------------------------------------
GET.CONSENT:

    ACCOUNT.CONSENT = CONSENT.RECORD<PZ.Consent.AccConsent.AccConsentType,CNT>
    ACCOUNT.CONSENT.RAISED = RAISE(ACCOUNT.CONSENT)
    
    IF "balances" MATCHES ACCOUNT.CONSENT.RAISED OR "allPsd2" MATCHES DEFAULT.CONSENT.TYPE THEN ;*If balances consent is given, pass to enquiry output
        BALANCE.INDICATOR = "YES"
    END
    
    IF "transactions" MATCHES ACCOUNT.CONSENT.RAISED OR "allPsd2" MATCHES DEFAULT.CONSENT.TYPE THEN ;*If transactions consent is given, pass to enquiry output
        TRANSACTION.INDICATOR = "YES"
    END

RETURN
*-----------------------------------------------------------------------------
CHECK.ONLINE.ACCESS:

    ONLINE.ARRANGEMENT = CONSENT.RECORD<PZ.Consent.AccConsent.OnlineArrangement>
    ONLINE.ACCOUNTS = ''
    PZ.ModelBank.PzGetExternalAccounts(CONSENT.ID, EXTERNAL.USER.ID, ONLINE.ARRANGEMENT, ONLINE.ACCOUNTS, '', '') ;*Routine to get accounts that have online access

RETURN
*-----------------------------------------------------------------------------
REINITIALISE:

    AC.ARRAY = ''
    CHECK.DATA = ''
    OVERRIDE.CODE = ''
    ACC.ERR = ''
    CHECK.DATA<AC.AccountOpening.AccountBalance> = 'Y'
    CHECK.DATA<AC.AccountOpening.AccountIban> = 'Y'
    CHECK.DATA<AC.AccountOpening.AccountArrangement> = 'Y'
    CHECK.DATA<AC.AccountOpening.AccountValidity> = 'Y'
    WORKING.BALANCE = ""
    CLOSING.BOOKED.BAL = ""
    OUT.ERR = ""
    ACCOUNT.ID = ACCOUNTS.LIST<CNT>
    ONLINE.ACTUAL.BALANCE = ''
    CLOSING.BOOKED.BAL = ''
    INTERIM.AVAILABLE.WITH.LIMIT = ''
    F.ACCOUNT$HIS = ''
    BALANCE.INDICATOR = ''
    TRANSACTION.INDICATOR = ''
    LAST.COMMITTED.TXN = ''
    LAST.CHANGED.DT = ''
    REFERENCE.DATE = ''
    ACCT.STMT.PRINTED.REC = ""
    ASP.ERR = ""
    STMT.PRINTED.REC = ""
    SP.ERR = ""
    STMT.ERR = ""

RETURN
*-----------------------------------------------------------------------------
GET.LAST.COMMITTED.TXN:


    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=ACCOUNT.ID
    InDetails<3>=''
    LockRecord="No"
    RequestMode="CURRENT.HVT"
    AddInfo=''
    ReservedIn=''
    AcctStmtRecord=''
    StmtSeqIndicator=''
    
    ReservedOut=''

    AC.AccountStatement.acReadAcctStmtPrint(InDetails,RequestMode,LockRecord,AddlInfo,ReservedIn,AcctStmtRecord,StmtSeqIndicator,ASP.ERR,ReservedOut)
    ACCT.STMT.PRINTED.REC= AcctStmtRecord
    
    IF ASP.ERR THEN
        RETURN
    END
    
    ACCT.STMT.PRINTED.CNT = DCOUNT(ACCT.STMT.PRINTED.REC,@FM)
    STMT.PRINTED.ID = ACCOUNT.ID:"-":FIELD(ACCT.STMT.PRINTED.REC<ACCT.STMT.PRINTED.CNT>,'/',1)
    Indetails<1>='STMT.PRINTED'
    Indetails<2>=STMT.PRINTED.ID
    Indetails<3>=''
    
    AC.AccountStatement.acReadAcctStmtPrint(Indetails,"MERGE.HVT" ,"NO",'','',STMT.PRINTED.REC,'', SP.ERR,'')
    
    STMT.ENTRY.CNT = DCOUNT(STMT.PRINTED.REC,@FM)
    LAST.COMMITTED.TXN = STMT.PRINTED.REC<STMT.ENTRY.CNT>
    STMT.REC = AC.EntryCreation.StmtEntry.Read(LAST.COMMITTED.TXN, STMT.ERR)
    
    TIME.DATE = STMT.REC<AC.EntryCreation.StmtEntry.SteDateTime>
    YEAR = 2000 + TIME.DATE[1,2]
    LAST.CHANGED.DT = YEAR:'-':TIME.DATE[3,2]:'-':TIME.DATE[5,2]:'T':TIME.DATE[7,2]:':':TIME.DATE[9,2]:':00' ;* converting the DateTime to ISO format
    REFERENCE.DATE = TODAY.DATE

RETURN
*-----------------------------------------------------------------------------
BUILD.ENQ.DATA:

    ACC.DATA<-1> = ACCOUNT.ID:'*':IBAN:'*':AC.CCY:'*':CLOSING.BOOKED.BAL:'*':ONLINE.ACTUAL.BALANCE:'*':INTERIM.AVAILABLE.WITH.LIMIT:'*':PRODUCT.ID:'*':NAME:'*':BALANCE.INDICATOR:'*':TRANSACTION.INDICATOR:'*':LAST.COMMITTED.TXN:'*':LAST.CHANGED.DT:'*':REFERENCE.DATE:'*':DETAILS

RETURN
*-----------------------------------------------------------------------------
END
