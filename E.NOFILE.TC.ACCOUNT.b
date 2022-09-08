* @ValidationCode : MjotMTQzOTM1OTA4ODpDcDEyNTI6MTYxNjE0OTQzMTk0OTpyc3VkaGE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTA0LjIwMjEwMzEzLTA2MTk6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Mar 2021 15:53:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202104.20210313-0619
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE AA.Channels
SUBROUTINE E.NOFILE.TC.ACCOUNT(ACCOUNT.ARR)
*--------------------------------------------------------------------------------------------------------------
* Description :
*--------------
* This Enquiry(Nofile) routine is to provide an account overview details (Opening date, Tax, Interest, Shared account groups, Balances, Overdraft limit, Primary & Secondary account identifiers)
*--------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.ACCOUNT using the Standard selection NOFILE.TC.ACCOUNT
* IN Parameters      : Arrangement Id
* Out Parameters     : Array of deposit details such as Opening date, Tax, Interest, Shared account groups, Balances, Overdraft limit, Primary & Secondary account identifiers
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 28/09/16 - Enhancement 1648970 / Task 1897346
*            TCIB Retail : Account Details
* 24/11/16 - Defect 1935634 / Task 1935806
*            Code Reversal - E.NOFILE.TC.ACCOUNT
* 15/12/16 - Defect 1915388 / Task 1954775
*            Available overdraft value is wrongly updated
* 28/02/17 - Defect 2032653 / Task 2034594
*            Account service API is not having all the balance fields as per the account details BRD
*
* 13/06/17 - Enhancement : 2148615
*            Task : 2231452
*            Value markers in BunArrangements in PRODUCT.BUNDLE is changed to SM
*
* 31/10/17 - Enhancement : 2262448
*            Task        : 2262451
*            Changes made as part of Joint Owned Loans SI
*            Call the GetAccountLimitAmts with the LimitKey if available
*
* 03/08/17 - Defect 2083086 / Task 2092156
*            Adding start date parameter to get arrangement conditions from interest charge schedule API
*
* 12/12/17 - Task 2343439
*             To access Record parent of a limit record using an API LI.GET.LIMIT.RECORD.PARENT
*
* 24/03/19 - Defect 3044903/ Task 3050598
*            IRIS service enqTcNofTxnsList causing java.text.ParseException: Unparseable date error
*
* 04/03/20 - Enhancement 3492893 / Task 3622075
*            Retrive bic, customer, payment details.
*
* 17/07/20 - Enhancement 3492899/ Task 3861124
*            Infinity Retail API new header changes
*
* 10/09/20 - Enhancement 3764899/ Task 3960280
*            Default Today date if future date and paid date are not provided.
*
* 24/09/20 - Enhancement 3934727 / Task 3977150
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*
* 30/09/20 - Defect 3963213 / Task 3998081
*            The values for the limit related details are not show in the enquiry AA.API.NOF.ACCOUNT.ARRANGEMENT.DETAILS.1.1.0 for the arrangement with joint owners.
*
* 20/10/20 - Defect 3195712 / Task 3196084
*            API Privilege escalation
*
* 18/03/21 - Task 4293496
*            Accrual interest - New field added
*--------------------------------------------------------------------------------------------------------------
*** <region name = Inserts>
    $INSERT I_DAS.LIMIT
    $INSERT I_DAS.BASIC.INTEREST
    $INSERT I_CustomerService_Parent
    $INSERT I_CustomerService_NameAddress
    $USING AA.Channels
    $USING AC.CashFlow
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductBundle
    $USING AA.PaymentSchedule
    $USING AC.AccountOpening
    $USING AC.BalanceUpdates
    $USING AC.EntryCreation
    $USING AC.ModelBank
    $USING AC.HighVolume
    $USING AC.Channels
    $USING AR.ModelBank
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.Reports
    $USING LI.Config
    $USING LI.LimitTransaction
    $USING EB.Interface
    $USING IN.Config
    $USING EB.SystemTables
    $USING EB.Security
    $USING ST.CompanyCreation
    $USING EB.Browser
    $USING EB.ErrorProcessing
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main Process>
    GOSUB INITIALISE                                    ;* Initialise variables
    IF SECURITY.ERR THEN
        ACCOUNT.ARR =''
        RETURN
    END
    GOSUB ARRANGEMENT.PROPERTIES                        ;* Initialise arrangement property values
    GOSUB ARRANGEMENT.DETAILS                           ;* Retrive the arrangement details informations
    GOSUB RETRIVE.ACCOUNT.DETAILS                       ;* Retrive the account details informations
    GOSUB RETRIVE.AVAILABLE.BALANCE                     ;* Retrive the available balance for the account
    GOSUB RETRIVE.LIMIT.DETAILS                         ;* Retrive the limit details
    GOSUB RETRIVE.INTEREST.DETAILS                      ;* Retrive the interest details
    GOSUB RETRIVE.INTEREST.SHARED.ACCOUNTS.DETAILS      ;* Retrive the interest shared account details
    GOSUB RETRIVE.TAX.CONDITIONS.DETAILS                ;* Retrive the tax conditions details
    GOSUB INTEREST.CHARGE.SCHEDULE
    GOSUB RETRIVE.BIC.FROM.IBAN                         ;* Retrive interest and charge schedule details
    
    IF latestEnquiryFlag THEN
        GOSUB RETRIEVE.CUST.DETAILS                     ;* Retreive customer details
        GOSUB GET.TOTAL.PAYMENT.DETAILS                 ;* Get completed total no. of debits and credits performed
        GOSUB INTEREST.RATE.AND.DATE.DETAILS            ;* Get interest rate and last paid date details
        GOSUB GET.LAST.PAID.DETAILS
        GOSUB GET.COMMITMENT.AMOUNT
    END

    GOSUB BUILD.ACCOUNT.ARRAY.DETAILS                   ;* Build final output array

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialise Variables>
INITIALISE:
*----------
*****Initialise the variables*****
    ACCOUNT.ARR = '' ; ExtLang = ''; latestEnquiryFlag = ''; SECURITY.ERR = '';
    
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN   ;* To avoid reading Descriptions in all languages in case External Language is not available
        ExtLang = 1         ;* Assigning Default Language position to read language multi value fields
    END

    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getDFields()<1> SETTING ARRPOS THEN
        ARRANGEMENT.ID = EB.Reports.getDRangeAndValue()<ARRPOS>
    END
    
    LOCATE "START.DATE" IN EB.Reports.getDFields()<1> SETTING DATEPOS THEN
        START.DATE = EB.Reports.getDRangeAndValue()<DATEPOS>
    END
*Convert account id to arrangement id if account id given
    IF ARRANGEMENT.ID[1,2] EQ 'AA' THEN
        ARR.RECORD               = AA.Framework.Arrangement.Read(ARRANGEMENT.ID,ARR.ERR)
        ACC.NUMBER              = ARR.RECORD<AA.Framework.Arrangement.ArrLinkedApplId>
    END ELSE
        ACC.NUMBER = ARRANGEMENT.ID
        ACCOUNT.RECORD = AC.AccountOpening.Account.Read(ACC.NUMBER, accounrError)      ;* Try reading the Account record
        ARRANGEMENT.ID = ACCOUNT.RECORD<AC.AccountOpening.Account.ArrangementId>
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID THEN
        EXT.ACCOUNTS.LIST = EB.Browser.SystemGetvariable('EXT.SMS.ACCOUNTS.SEE') ;*get ext accounts
        
        FIND ACC.NUMBER IN EXT.ACCOUNTS.LIST SETTING ACCPOS ELSE
            SECURITY.ERR = 'TRUE'   ;*If acccount not found then return empty array
            RETURN
        END
    END
    AUTH.ARR.ID    = ARRANGEMENT.ID:'//AUTH'  ;*Take the authorised arrangement of the active channel
    
    Today =  EB.SystemTables.getToday() ;*Get the today date value
    
    enquiriesVersionNo = RIGHT(EB.Reports.getEnqSelection()<1>,5)    ;* get enquiry name and then get its version. eg: 1.0.0
    CHANGE '.'TO '' IN enquiriesVersionNo
    IF enquiriesVersionNo GT 100 THEN
        latestEnquiryFlag = 1
    END
    
    R.ARRANGEMENT = ''; CURRENCY = ''; CUSTOMER.NUMBER = ''; ACCOUNT.NUMBER = ''
    R.ACCOUNT = ''; OPENING.DATE = ''; LIMIT.REFERENCE = ''; LIMIT.PRODUCT = ''
    THE.LIST = ''; THE.ARGS = ''; TOT.LIMIT.REC.CNT = ''; CNT.LIMIT.RECORD = ''; LIMIT.ID = ''; R.LIMIT = ''; LIMIT.ACCOUNT = ''; LIMIT.INTERNAL.AMOUNT = ''; LIMIT.ONLINE.LIMIT = ''; LIMIT.EXPIRY.DATE = ''; ACC.NO = ''; SHARED.LIMIT.ACCOUNTS = ''; SHARED.LIMIT.ACCOUNTS.TYPE = ''; SHARED.ACCOUNT.TYPE = ''
    PRD.BUNDLE.PROPERTY.RECORDS = ''; PRD.BUNDLE.ARRANGEMENTS = ''; PRD.BUNDLE.PRODUCT.GRP = ''; TOT.PRD.BUNDLE.ARR.CNT = ''; CNT.PRD.BUNDLE.ARR = ''; PRD.BUNDLE.ARR.ID = ''; R.PRD.BUNDLE.ARRANGEMENT = ''; PRD.BUNDLE.ACCOUNT.NUMBER = ''; SHARED.INT.ACCOUNTS = ''; SHARED.INT.ACCOUNTS.TYPE = ''
    INTEREST.DETAILS.ARR = ''; TAX.DETAILS.ARR = ''; INTEREST.CHARGE.SCHEDULE.ARR = ''; CONSOLIDATE.SHARED.INT.ACCOUNTS = ''; CONSOLIDATE.SHARED.INT.ACCOUNTS.TYPE = ''; LINK.TYPE.VAL = ''; LINK.ARRANGEMENT.VAL = ''; PRIMARY.ACCT.HOLDER = ''; JOINT.ACCT.HOLDER = ''; INT.PROPERTY.CLASS = "INTEREST"; DIVIDENT.PAID.YTD = "";
    AVAIL.BALANCE = ''; APP.OD.FLAG = ''; ALLOW.NETTING.ACC = ''; AVAIL.OVERDRAFT.LIMIT = ''; APP.OVERDRAFT.LIMIT = ''; OPEN.CLEARED.BALANCE = ''; RESPONSE = ''; ONLINE.CLEARED.BALANCE = '';ACCOUNT.BIC = '';ONLINE.ACTUAL.BALANCE = ''; PENDING.DEPOSIT = ''; TOTAL.CREDITS = ''; TOTAL.DEBITS = ''; PERIOD.ENDING = ""; LAST.PAID.DIVIDENT = "";TOTAL.ACCRUED.INTEREST=""
    PENDING.WITHDRAWALS = "";
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialize Arrangement property Details>
ARRANGEMENT.PROPERTIES:
*--------------------------------
*****Initialise the arrangement property details*****
    PRD.BUNDLE.PROPERTY.CLASS    = 'PRODUCT.BUNDLE'     ;* Initialise product bundle property class
    PRD.BUNDLE.PROPERTY.RECORDS  = ''                   ;* Initialise product bundle property record
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Arrangement Details>
ARRANGEMENT.DETAILS:
*-------------------
*****Get the deposit details from arrangement*****

    IF ARRANGEMENT.ID[1,2] NE 'AA' THEN
        R.ACCOUNT = AC.AccountOpening.Account.Read(ARRANGEMENT.ID, ACT.ERR) ;* Read account details
        ARRANGEMENT.ID = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>  ;* Get Arrangement ID from ACCOUNT
        AUTH.ARR.ID    = ARRANGEMENT.ID:'//AUTH'  ;*Take the authorised arrangement of the active channel
    END
    R.ARRANGEMENT               = AA.Framework.Arrangement.Read(ARRANGEMENT.ID,ARR.ERR)   ;*Read the arragement details
    CURRENCY                    = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>     ;*Get the currecy of the deposit
    CUSTOMER.NUMBER             = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer>     ;*Get the customer number of the deposit
    ACCOUNT.NUMBER              = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId> ;*Get the account number of the deposit
    LINK.ARRANGEMENT            = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkArrangement> ;*Get the linked arrangement ids
    LINK.TYPE                   = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkType>     ;*Get the linked arrangements type
    ARR.START.DATE             = R.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>     ;*Get the start date of the deposit
    CUSTOMER.ROLES = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomerRole>
    ROLE.COUNT = DCOUNT(CUSTOMER.ROLES, @VM)
    
    JOINT.CUSTOMER = ''
    FOR ROLE = 1 TO ROLE.COUNT
        IF (CUSTOMER.ROLES<1,ROLE> EQ "JOINT.OWNER") THEN
            JOINT.CUSTOMER<1,-1> = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer,ROLE>
            CUST.NAME.ADDR = ''
            CALL CustomerService.getNameAddress(R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer,ROLE>,ExtLang,CUST.NAME.ADDR)
            JOINT.ACCT.HOLDER<1,-1>= CUST.NAME.ADDR<NameAddress.shortName>
        END
    NEXT ROLE

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the account details>
RETRIVE.ACCOUNT.DETAILS:
*--------------------------------
*****Retrive the account details*****
*Get open actual balance*
    AC.BalanceUpdates.AccountserviceGetopenactualbalance(ACCOUNT.NUMBER, OPEN.ACTUAL.BALANCE, ACT.BAL.ERR)
*Get basic account details*
    IF NOT(R.ACCOUNT) THEN
        R.ACCOUNT                  = AC.AccountOpening.Account.Read(ACCOUNT.NUMBER, ACT.NO.ERR) ;* Read account details
    END
    OPENING.DATE               = R.ACCOUNT<AC.AccountOpening.Account.OpeningDate>           ;* Get the opening date
    LIMIT.REFERENCE            = R.ACCOUNT<AC.AccountOpening.Account.LimitRef>              ;* Get the limit reference
    LIMIT.PRODUCT              = FIELD(LIMIT.REFERENCE, ".", 1)                             ;* Limit product
    ALLOW.NETTING.ACC          = R.ACCOUNT<AC.AccountOpening.Account.AllowNetting>          ;* Get the allow netting
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the available balance details>
RETRIVE.AVAILABLE.BALANCE:
*--------------------------------
*****Retrive the available balance details*****
    oData = ACCOUNT.NUMBER
    EB.Reports.setOData(oData)
    AC.ModelBank.EGetAcWorkingBalance()
    workingBalance = EB.Reports.getOData()

    oData = ACCOUNT.NUMBER
    EB.Reports.setOData(oData)
    AC.ModelBank.ETotalLockAmt()
    lockedAmount = EB.Reports.getOData()

    availableBalance = workingBalance - lockedAmount
    
    AC.HighVolume.EbReadHvt('EB.CONTRACT.BALANCES',ACCOUNT.NUMBER,ECB.RECORD,'')
    AVAIL.BALANCE          = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>      ;*Assign the output value for available balance to a variable
    ONLINE.CLEARED.BALANCE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineClearedBal>    ;*Assign the output value for online cleared balance to a variable
    ONLINE.ACTUAL.BALANCE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineActualBal>    ;*Assign the output value for online actual balance to a variable
    
*Get pending Withdrawals
    PENDING.WITHDRAWALS = ONLINE.CLEARED.BALANCE - AVAIL.BALANCE
    
*Get the open cleared balance
    AC.CashFlow.AccountserviceGetopenclearedbalance(ACCOUNT.NUMBER, OPEN.CLEARED.BALANCE, RESPONSE)     ;*Assign the output value for open cleared balance to a variable
    PENDING.DEPOSIT = ONLINE.ACTUAL.BALANCE - ONLINE.CLEARED.BALANCE    ;* Get Pending deposit amount
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the limit details>
RETRIVE.LIMIT.DETAILS:
*--------------------------------
    custNo = R.ACCOUNT<AC.AccountOpening.Account.Customer>
    CUST.PARENT = ''
    ! getting the customer.liability by customer service api getRecord
    CALL CustomerService.getParent(custNo, CUST.PARENT)
    ORIG.LIAB = CUST.PARENT<Parent.customerLiability>
    
    LIMIT.REF = FMT(FIELD(R.ACCOUNT<AC.AccountOpening.Account.LimitRef>,'.',1),'7"0"R')
    LIMIT.REF2 = FIELD(R.ACCOUNT<AC.AccountOpening.Account.LimitRef>,'.',2)
    IF ORIG.LIAB THEN
        CUS.LIAB = ORIG.LIAB
        LIMIT.ID = CUS.LIAB:'.':LIMIT.REF:'.':LIMIT.REF2:'.':custNo
    END ELSE
        CUS.LIAB = custNo
        LIMIT.ID = CUS.LIAB:'.':LIMIT.REF:'.':LIMIT.REF2
    END
    IF R.ACCOUNT<AC.AccountOpening.Account.LimitKey> THEN   ;* New LimitKey available get it
        LIMIT.ID = R.ACCOUNT<AC.AccountOpening.Account.LimitKey>
    END
;*Retrive the liabitiy number
    GOSUB READ.LIMIT                                           ;* Read the limit record
;*Other required fields
    LIMIT.EXPIRY.DATE     = R.LIMIT<LI.Config.Limit.ExpiryDate>       ;* Expiry Date
    LIMIT.ACTS            = R.LIMIT<LI.Config.Limit.Account>          ;* Account number
    TOT.LIMIT.SHD.ACTS    = DCOUNT(LIMIT.ACTS,@VM)

    IF TOT.LIMIT.SHD.ACTS GT 1 THEN
        FOR CNT.LIMIT.SHD.ACTS = 1 TO TOT.LIMIT.SHD.ACTS
            LIMIT.ACCOUNT      = LIMIT.ACTS<1,CNT.LIMIT.SHD.ACTS>     ;*Check for shared limit accounts for the customer
            ACC.NO             = LIMIT.ACCOUNT
            GOSUB RETRIVE.ACCOUNT.TYPE                                ;* Get the account type
            SHARED.LIMIT.ACCOUNTS<1,-1>      = LIMIT.ACCOUNT          ;* Consolidated shared limit accounts
            SHARED.LIMIT.ACCOUNTS.TYPE<1,-1> = SHARED.ACCOUNT.TYPE    ;* Consolidated shared limit accounts type
        NEXT CNT.LIMIT.SHD.ACTS
    END ELSE
        ACC.NO                           = LIMIT.ACTS
        GOSUB RETRIVE.ACCOUNT.TYPE
        SHARED.LIMIT.ACCOUNTS            = LIMIT.ACTS                  ;* Consolidated shared limit accounts
        SHARED.LIMIT.ACCOUNTS.TYPE       = SHARED.ACCOUNT.TYPE         ;* Consolidated shared limit accounts type
    END
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the interest details>
READ.LIMIT:
*--------------------------------
*****Retrive the limt details*****
;*Initialize the variables used inside the loop if it is exists.
    ALLOW.NETTING.LIMIT = ''; PRODUCT.LIMIT = ''; REF.LIMIT.PRODUCT = ''; LIMIT.REFERENCE = '';
    APPROVED.OVERDRAFT.LIMIT = ''; AVAILABLE.OVERDRAFT.LIMIT =''; LIMIT.RECORD.PARENT.ID = ''; AVAILABLE.FUNDS = ''
    R.LIMIT               = LI.Config.Limit.Read(LIMIT.ID, LIMIT.ERR)   ;*Read the limit record
    
    recordParent = ''
    retError = ''
    reservedIn = ''
    reservedOut = ''
    LI.LimitTransaction.LiGetLimitRecordParent(LIMIT.ID, '', R.LIMIT, recordParent, retError, reservedIn, reservedOut)
            
;*Allow netting
    ALLOW.NETTING.LIMIT = R.LIMIT<LI.Config.Limit.AllowNetting>         ;* Allow netting from limit
;*Retrive the approved & available overdraft limit values
    PRODUCT.LIMIT      = R.LIMIT<LI.Config.Limit.LimitProduct>          ;* Limit product
    
    IF LIMIT.ID[1,2] EQ "LI" THEN
        LIMIT.REFERENCE    = LIMIT.ID                                       ;* if new limit then limit reference equals limit id
    END ELSE
        REF.LIMIT.PRODUCT  = FIELD(LIMIT.ID, ".", 3)                        ;* Limit reference value from limit id
        LIMIT.REFERENCE    = PRODUCT.LIMIT:".":REF.LIMIT.PRODUCT            ;* Form the limit reference
    END
;*Get the approved & avialable overdraft limit values
    LI.LimitTransaction.GetAccountLimitAmts(ORIG.LIAB, custNo, LIMIT.REFERENCE, CURRENCY, APPROVED.OVERDRAFT.LIMIT, AVAILABLE.OVERDRAFT.LIMIT)
;*Approved Overdraft Limit
    IF APP.OD.FLAG NE 'YES' THEN                                        ;* Flag check to assign the approved overdraft value
        APP.OVERDRAFT.LIMIT = APPROVED.OVERDRAFT.LIMIT
    END
;*Available Overdraft Limit
    IF AVAIL.OVERDRAFT.LIMIT EQ '' THEN
        AVAIL.OVERDRAFT.LIMIT = AVAILABLE.OVERDRAFT.LIMIT               ;*Assign the available od value to the final available od limit variable
    END ELSE
        IF AVAIL.OVERDRAFT.LIMIT > AVAILABLE.OVERDRAFT.LIMIT THEN       ;* Check the existing avail od value with current to get the least value
            AVAIL.OVERDRAFT.LIMIT = AVAILABLE.OVERDRAFT.LIMIT           ;* Final avail od limit value
        END
    END
    IF ALLOW.NETTING.LIMIT EQ 'YES' AND ALLOW.NETTING.ACC EQ 'YES' THEN ;* Check the allow netting in both account & limit record to find the available funds
        AVAILABLE.FUNDS             = AVAIL.OVERDRAFT.LIMIT
        IF AVAIL.BALANCE > 0 THEN
            AVAIL.OVERDRAFT.LIMIT       = AVAILABLE.FUNDS - AVAIL.BALANCE         ;* Avilable od limit
        END ELSE
            AVAIL.OVERDRAFT.LIMIT       = AVAILABLE.FUNDS
        END
        IF APP.OD.FLAG NE 'YES' THEN
            OUTSTANDING.OVERDRAFT.LIMIT = APPROVED.OVERDRAFT.LIMIT - AVAIL.OVERDRAFT.LIMIT
        END
    END ELSE
        IF AVAIL.BALANCE > 0 THEN
            AVAILABLE.FUNDS = AVAIL.OVERDRAFT.LIMIT + AVAIL.BALANCE         ;* Available funds
        END ELSE
            AVAILABLE.FUNDS = AVAIL.OVERDRAFT.LIMIT                         ;* Available funds
        END
        IF APP.OD.FLAG NE 'YES' THEN
            OUTSTANDING.OVERDRAFT.LIMIT = APPROVED.OVERDRAFT.LIMIT - AVAILABLE.OVERDRAFT.LIMIT
        END
    END
;*Retrive the record parent value
    LIMIT.RECORD.PARENT.ID = recordParent      ;* Id of parent record
    IF LIMIT.RECORD.PARENT.ID NE '' THEN                                ;* Check for parent hierarchy loop
        APP.OD.FLAG = "YES"                                             ;* Flag to stop assigning the approved od limit value in successive loops
        LIMIT.ID = LIMIT.RECORD.PARENT.ID
        GOSUB READ.LIMIT                                                ;* Read the limit
    END
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the interest details>
RETRIVE.INTEREST.DETAILS:
*--------------------------------
*****Retrive the interest details*****
    AA.Channels.AaGetInterestDetails(AUTH.ARR.ID, CURRENCY, INTEREST.DETAILS.ARR) ;* Interest details for the passed arrangement
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the interest shared account details>
RETRIVE.INTEREST.SHARED.ACCOUNTS.DETAILS:
*--------------------------------
*****Retrive the interest shared account details*****
    TOT.LINK.TYPE         = DCOUNT(LINK.TYPE,@VM)
    FOR CNT.LINK.TYPE = 1 TO TOT.LINK.TYPE
        LINK.TYPE.VAL = LINK.TYPE<1,CNT.LINK.TYPE>
        IF LINK.TYPE.VAL EQ 'BUNDLE' THEN
            LINK.ARRANGEMENT.VAL<1,-1> = LINK.ARRANGEMENT<1,CNT.LINK.TYPE>
        END
    NEXT CNT.LINK.TYPE

    TOT.LINK.ARRANGEMENT.VAL         = DCOUNT(LINK.ARRANGEMENT.VAL,@VM)
    FOR CNT.LINK.ARRANGEMENT.VAL = 1 TO TOT.LINK.ARRANGEMENT.VAL
        SHARED.INT.ACCOUNTS = ''; SHARED.INT.ACCOUNTS.TYPE = ''
        BUNDLE.ARR.ID = LINK.ARRANGEMENT.VAL<1,CNT.LINK.ARRANGEMENT.VAL>
        AA.Framework.GetArrangementConditions(BUNDLE.ARR.ID,PRD.BUNDLE.PROPERTY.CLASS,'','',PRD.BUNDLE.PROPERTY.IDS,PRD.BUNDLE.PROPERTY.RECORDS,PRD.BUNDLE.ERR) ;* Get product bundle arrangement condition record
        PRD.BUNDLE.PROPERTY.RECORDS            = RAISE(PRD.BUNDLE.PROPERTY.RECORDS)
        PRD.BUNDLE.ARRANGEMENTS                = PRD.BUNDLE.PROPERTY.RECORDS<AA.ProductBundle.ProductBundle.BunArrangement>    ;* Shared accounts arrangememt id
        PRD.BUNDLE.PRODUCT.GRP                 = PRD.BUNDLE.PROPERTY.RECORDS<AA.ProductBundle.ProductBundle.BunProductGroup>   ;* Shared accounts product group
        TOT.PRODUCT.GRP.CNT = DCOUNT(PRD.BUNDLE.PRODUCT.GRP, @VM);*to fetch the total no of Product Groups
        FOR CNT.PRODUCT.GRP = 1 TO  TOT.PRODUCT.GRP.CNT
*In each Product Group -Product section, arrangements are now seperated by SM
            GOSUB RETRIVE.ARRANGEMENTS
        NEXT CNT.PRODUCT.GRP
        
        CONSOLIDATE.SHARED.INT.ACCOUNTS<1,-1> = SHARED.INT.ACCOUNTS
        CONSOLIDATE.SHARED.INT.ACCOUNTS.TYPE<1,-1> = SHARED.INT.ACCOUNTS.TYPE
    NEXT CNT.LINK.ARRANGEMENT.VAL
RETURN

*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the ARRANGEMENT details>
RETRIVE.ARRANGEMENTS:
    TOT.PRD.BUNDLE.ARR.CNT = DCOUNT(PRD.BUNDLE.ARRANGEMENTS<1,CNT.PRODUCT.GRP>, @SM)   ;*To get all arrangements in each Product Group
    FOR CNT.PRD.BUNDLE.ARR = 1 TO  TOT.PRD.BUNDLE.ARR.CNT;*To get count of all arrangements in each Product Group
        PRD.BUNDLE.ARR.ID  = PRD.BUNDLE.ARRANGEMENTS<1, CNT.PRODUCT.GRP ,CNT.PRD.BUNDLE.ARR>
;*Read arrangement details
        IF PRD.BUNDLE.ARR.ID NE '' THEN
            R.PRD.BUNDLE.ARRANGEMENT       = AA.Framework.Arrangement.Read(PRD.BUNDLE.ARR.ID,ARR.ERR)
            PRD.BUNDLE.ACCOUNT.NUMBER      = R.PRD.BUNDLE.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
            ACC.NO = PRD.BUNDLE.ACCOUNT.NUMBER
            GOSUB RETRIVE.ACCOUNT.TYPE                                      ;* Get the account type
            SHARED.INT.ACCOUNTS<1,1,-1>      = PRD.BUNDLE.ACCOUNT.NUMBER      ;* Shared interest account details
            SHARED.INT.ACCOUNTS.TYPE<1,1,-1> = SHARED.ACCOUNT.TYPE            ;* Shared interest accounts type
        END
    NEXT CNT.PRD.BUNDLE.ARR
       
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the interest details>
RETRIVE.ACCOUNT.TYPE:
*--------------------------------
*****Retrive the account type details*****
    SHARED.ACCOUNT.TYPE = '';
    R.SHARED.ACCOUNT      = AC.AccountOpening.Account.Read(ACC.NO, ACT.NO.ERR)          ;* Read the account application
    BEGIN CASE
        CASE R.SHARED.ACCOUNT EQ ''                                                                      ;* If the Account Record is Empty Do Nothing
        CASE R.SHARED.ACCOUNT<AC.AccountOpening.Account.AccountTitleOne, ExtLang> NE ''                  ;* Case when Account Title is available in External User Preferred Language
            SHARED.ACCOUNT.TYPE = R.SHARED.ACCOUNT<AC.AccountOpening.Account.AccountTitleOne, ExtLang>   ;* Get the account title in External User Language
        CASE 1                                                                                           ;* Case Otherwise executed when Account Title is NOT available in Preferred Language
            SHARED.ACCOUNT.TYPE = R.SHARED.ACCOUNT<AC.AccountOpening.Account.AccountTitleOne, 1>         ;* Get the account title in default Language
    END CASE
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Rertive the interest details>
RETRIVE.TAX.CONDITIONS.DETAILS:
*--------------------------------
*****Retrive the tax condition details*****
    AA.Channels.AaGetTaxConditionsDetails(AUTH.ARR.ID, TAX.DETAILS.ARR) ;* Read the tax property condition details
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Tax Rate>
INTEREST.CHARGE.SCHEDULE:
*------------------------
*****Retrive the interest and charge schedule details*****
    AA.Channels.AaGetInterestChargeSchedule(AUTH.ARR.ID, ARR.START.DATE, INTEREST.CHARGE.SCHEDULE.ARR)   ;* Get the interest and charge schedule details of the arrangement
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
RETRIVE.BIC.FROM.IBAN:
*------------------------
*****Retrive the BIC id details for the IBAN number attached with the Account*****
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) THEN
        IBAN.VAR = "T24.IBAN" ;*Initialise the account variable
****Get the Iban Id from Arrangement*****
        ALT.ACCT.TYPE = R.ACCOUNT<AC.AccountOpening.Account.AltAcctType>    ;*Account type

        LOCATE IBAN.VAR IN ALT.ACCT.TYPE<1,1> SETTING POS THEN
            IBAN.ID = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId,POS>
            IF IBAN.ID NE '' THEN
                ACCOUNT.IBAN = IBAN.ID;*Re-assigning the IBAN account number as result data
            END ELSE
                ACCOUNT.IBAN = "NA"
            END
        
            IF ACCOUNT.IBAN NE "NA" THEN
                IN.Config.Getbicfromiban(ACCOUNT.IBAN,RET.DATA,RET.CODE)
                ACCOUNT.BIC = RET.DATA
            END ELSE
                ACCOUNT.BIC = "NA"
            END
        END
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get customer details>
RETRIEVE.CUST.DETAILS:
*------------------------
*****Retrive the interest and charge schedule details*****

    CUST.NAME.ADDR = ''
    CALL CustomerService.getNameAddress(CUSTOMER.NUMBER,ExtLang,CUST.NAME.ADDR)
    PRIMARY.ACCT.HOLDER = CUST.NAME.ADDR<NameAddress.shortName>
    

            
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TOTAL.PAYMENT.DETAILS>
*** <desc>To get the Completed account transactions list ignoring future and pending transactions</desc>
GET.TOTAL.PAYMENT.DETAILS:
*-----------------
    ID.LIST = ''
    START.DATE = Today
    EB.API.Cdt('',START.DATE,'-30C') ;*Minus 30 calendar days to set Start date
*Call routine to retrieve the Credit payment statement entry id's based on the account no, start date and end date
    AC.Channels.GetAccountTxnsIds(ACCOUNT.NUMBER, 'SEARCH', '', 'PAIDOUT', START.DATE, '', '', '', '', '', ID.LIST)
    GOSUB TOTAL.PAYMENT.DETAILS
    TOTAL.CREDITS = totalPayment
    
*Call routine to retrieve the Debit payment statement entry id's based on the account no, start date and end date
    ID.LIST = ''
    AC.Channels.GetAccountTxnsIds(ACCOUNT.NUMBER, 'SEARCH', '', 'PAIDIN', START.DATE, '', '', '', '', '', ID.LIST)
    GOSUB TOTAL.PAYMENT.DETAILS
    TOTAL.DEBITS = totalPayment
*
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= TOTAL.PAYMENT.DETAILS>
*** <desc>Get the total Credit payment details and total Debit payment details</desc>
TOTAL.PAYMENT.DETAILS:
*---------------
    totalPayment = 0; StmtRec = ''; BookingDate = ''; ErrStmt = ''; ExposureDate = '';
    IF ID.LIST NE '' THEN
        LOOP
            REMOVE StmtId FROM ID.LIST SETTING LIST.POS  ;*Loop statement to get the transaction details
        WHILE StmtId:LIST.POS
*Get the common transaction details from statement entry and IM applications
            StmtId = FIELD(StmtId, '*', 2)
            AC.HighVolume.EbReadHvt('STMT.ENTRY',StmtId,StmtRec,'')    ;* To read statement entry Id
            IF StmtRec NE '' THEN
                BookingDate= StmtRec<AC.EntryCreation.StmtEntry.SteBookingDate>   ;* To get booking date
                ExposureDate = StmtRec<AC.EntryCreation.StmtEntry.SteExposureDate> ;*To read exposure date
            END
            IF BookingDate NE '' AND ExposureDate <= Today THEN   ;*Check to ignore the future dated and pending transactions
                totalPayment += 1   ;*Form Total credit payments
            END
        REPEAT
    END
    
RETURN
*---------------------------------------------------------------------------------------------------------------
*** <region name = Get customer details>
GET.COMMITMENT.AMOUNT:
*------------------------
*****Retrive the interest and charge schedule details*****
    BALANCE.DETAILS = ''; COMMITMENT.BAL = ''; NO.OF.DETAILS = '';
    REQUEST.TYPE = ''; REQUEST.TYPE<3> = 'ALL'; REQUEST.TYPE<2> = 'ALL'
    AA.Framework.GetPeriodBalances(ACCOUNT.NUMBER,"TOTCOMMITMENT",REQUEST.TYPE,START.DATE,'','',BALANCE.DETAILS,'')
    NO.OF.DETAILS = DCOUNT(BALANCE.DETAILS<1>,@VM)
    COMMITMENT.BAL = BALANCE.DETAILS<4,NO.OF.DETAILS>
    IF COMMITMENT.BAL LT 0 THEN
        COMMITMENT.BAL = FIELD(COMMITMENT.BAL,'-',2)
    END
            
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get customer details>
GET.LAST.PAID.DETAILS:
*------------------------
*****Retrive the interest and charge schedule details*****
    FUTURE.SCHD.COUNT = 0; PAID.SCHD.COUNT = 0; DUE.SCHD.COUNT = 0; ARR.START.DATE = ''; DEFER.DATES = ''; SIM.REF = ''
    DUE.TYPES = ''; DUE.METHODS = ''; DUE.TYPE.AMTS = ''; DUE.PROPS = ''; DUE.PROP.AMTS = ''; DUE.OUTS = ''
    AA.PaymentSchedule.ScheduleProjector(ARRANGEMENT.ID, SIM.REF, '',ARR.START.DATE, FUTR.PAY.AMOUNT, FUTURE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Call routine to get the list of schedules to be paid from the date given
    FUTR.SCHD.COUNT = DCOUNT(FUTURE.DATES,@FM)     ;* Total Number of Schedule dates
    SAVE.FUTR.SCHD.COUNT = FUTR.SCHD.COUNT
    BILL.ID = ''
    FOR FUT.SCHD = 1 TO SAVE.FUTR.SCHD.COUNT
        PAYMENT.DATE = FUTURE.DATES<FUT.SCHD>      ;* Read the payment date for the schedule dates
        BILL.STATUS = 'SETTLED'
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the settled bill generated
    NEXT FUT.SCHD
    R.BILL.DETAILS = AA.PaymentSchedule.BillDetails.Read(BILL.ID, BILL.DET.ERR)
    LAST.PAID.AMOUNT=R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
    LAST.PAID.DATE=R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
    
    BILL.ID = ''; TOTAL.DUE.AMOUNT = 0;
    LAST.PAYMENT.DATE =  FUTURE.DATES<SAVE.FUTR.SCHD.COUNT>   ;* Read the last payment date of the future schedule date
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",PAID.DATE, PAID.AMOUNT, PAID.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Call routine to get paid out schedules till the date given
    PAID.SCHEDULES = DCOUNT(PAID.DATES,@FM)     ;* Total Number of Schedule dates
    FOR SCHD = 1 TO PAID.SCHEDULES
        PAYMENT.DATE = PAID.DATES<SCHD>
        BILL.STATUS = "AGING":@VM:"DUE":@VM:"DEFER"
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the aged bill generated
        IF SCHD.COUNT THEN
            R.BILL.DETAILS = AA.PaymentSchedule.BillDetails.Read(BILL.ID, BILL.DET.ERR)
            TOTAL.DUE.AMOUNT += R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
        END
    NEXT SCHD
    
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Get overdue schedule count by reading the aged bills>
GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT:
*----------------------------------
*Get the Bill Id which has status as AGING for a date lt today/ SETTLED for a date gt today

    BILL.REFERENCES = ''; SCHD.COUNT = 0;
    AA.PaymentSchedule.GetBill(ARRANGEMENT.ID,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)        ;* Call routine to get bill details based on status
    IF BILL.REFERENCES THEN
        BILL.ID = BILL.REFERENCES
        SCHD.COUNT = DCOUNT(BILL.REFERENCES,@VM)   ;* Count of bill ids
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get interest rate and last paid date details>
INTEREST.RATE.AND.DATE.DETAILS:
*-------------------------
*****Retrive the interest details*****
    ODATAVAL = ''
    LAST.YEAR = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLastYearEnd)
    AA.Framework.GetArrangementConditions(AUTH.ARR.ID,INT.PROPERTY.CLASS,'','',INT.PROPERTY.IDS,INT.PROPERTY.RECORDS,INTEREST.ERR) ;* Get interest arrangement condition records
    
    TOT.INT.PROPERTY.RECORDS = DCOUNT(INT.PROPERTY.RECORDS,@FM)                                                                 ;* Total number of interest records
    FOR CNT.INT.PROPERTY.RECORDS = 1 TO TOT.INT.PROPERTY.RECORDS
        PROPERTY = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntIdCompTwo>                ;* Interest property
        CO.CODE = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntCoCode>
        ODATA.VAL = ARRANGEMENT.ID:'-':PROPERTY:'~':LAST.YEAR
        GOSUB GET.ACCRUED.INTEREST
        DIVIDENT.PAID.YTD<1,-1> = FIELD(ODATA.VAL,'*',1)
        
        ODATA.VAL = ''
        ODATA.VAL = ARRANGEMENT.ID:'-':PROPERTY:'~':'PREVIOUS'
        GOSUB GET.ACCRUED.INTEREST
        LAST.PAID.DIVIDENT<1,-1> = FIELD(ODATA.VAL,'*',1)
        PERIOD.ENDING<1,-1> = FIELD(ODATA.VAL,'*',3)
        
        ODATA.VAL = ARRANGEMENT.ID:'-':PROPERTY
        GOSUB GET.ACCRUED.INTEREST
        TOTAL.ACCRUED.INTEREST<1,-1>=FIELD(ODATA.VAL,'*',1)
    NEXT CNT.INT.PROPERTY.RECORDS
    
RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = Interest calculation Details>
GET.ACCRUED.INTEREST:
*-------------------------
    EB.Reports.setOData(ODATA.VAL)
    AR.ModelBank.EAaAccruedInterest()
    ODATA.VAL = EB.Reports.getOData()
*
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Build the array according to enquiry requirements>
BUILD.ACCOUNT.ARRAY.DETAILS:
*--------------------------------
*****Build the array according to enquiry requirements*****
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) ELSE
        CHANGE @VM TO "|" IN SHARED.LIMIT.ACCOUNTS
        CHANGE @VM TO "|" IN SHARED.LIMIT.ACCOUNTS.TYPE
        CHANGE @SM TO "#" IN CONSOLIDATE.SHARED.INT.ACCOUNTS
        CHANGE @SM TO "#" IN CONSOLIDATE.SHARED.INT.ACCOUNTS.TYPE
        CHANGE @VM TO "|" IN CONSOLIDATE.SHARED.INT.ACCOUNTS
        CHANGE @VM TO "|" IN CONSOLIDATE.SHARED.INT.ACCOUNTS.TYPE
        CHANGE @VM TO "|" IN DIVIDENT.PAID.YTD
        CHANGE @VM TO "|" IN LAST.PAID.DIVIDENT
        CHANGE @VM TO "|" IN TOTAL.ACCRUED.INTEREST
        CHANGE @VM TO "|" IN PERIOD.ENDING
    END
    IF ACCOUNT.IBAN EQ 'NA' THEN
        ACCOUNT.IBAN = ""
    END
    
    IF latestEnquiryFlag THEN
        ACCOUNT.ARR<-1> = OPEN.ACTUAL.BALANCE:"*":AVAIL.OVERDRAFT.LIMIT:"*":OPENING.DATE:"*":APP.OVERDRAFT.LIMIT:"*":LIMIT.EXPIRY.DATE:"*":SHARED.LIMIT.ACCOUNTS:"*":SHARED.LIMIT.ACCOUNTS.TYPE:"*":TAX.DETAILS.ARR:"*":INTEREST.DETAILS.ARR:"*":CONSOLIDATE.SHARED.INT.ACCOUNTS:"*":CONSOLIDATE.SHARED.INT.ACCOUNTS.TYPE:"*":INTEREST.CHARGE.SCHEDULE.ARR:"*":AVAILABLE.FUNDS:"*":OUTSTANDING.OVERDRAFT.LIMIT:"*":availableBalance:"*":OPEN.CLEARED.BALANCE:"*":ACCOUNT.BIC:"*":PENDING.DEPOSIT:"*":PRIMARY.ACCT.HOLDER:"*":TOTAL.CREDITS:"*":TOTAL.DEBITS:"*":JOINT.ACCT.HOLDER:"*":JOINT.CUSTOMER:"*":DIVIDENT.PAID.YTD:"*":LAST.PAID.DIVIDENT:"*":PERIOD.ENDING:"*":COMMITMENT.BAL:"*":LAST.PAID.AMOUNT:"*":LAST.PAID.DATE:"*":TOTAL.DUE.AMOUNT:"*":PENDING.WITHDRAWALS:"*":lockedAmount:"*":ACCOUNT.IBAN:"*":TOTAL.ACCRUED.INTEREST
    END ELSE
        ACCOUNT.ARR<-1> = OPEN.ACTUAL.BALANCE:"*":AVAIL.OVERDRAFT.LIMIT:"*":OPENING.DATE:"*":APP.OVERDRAFT.LIMIT:"*":LIMIT.EXPIRY.DATE:"*":SHARED.LIMIT.ACCOUNTS:"*":SHARED.LIMIT.ACCOUNTS.TYPE:"*":TAX.DETAILS.ARR:"*":INTEREST.DETAILS.ARR:"*":CONSOLIDATE.SHARED.INT.ACCOUNTS:"*":CONSOLIDATE.SHARED.INT.ACCOUNTS.TYPE:"*":INTEREST.CHARGE.SCHEDULE.ARR:"*":AVAILABLE.FUNDS:"*":OUTSTANDING.OVERDRAFT.LIMIT:"*":ONLINE.CLEARED.BALANCE:"*":OPEN.CLEARED.BALANCE:"*":ACCOUNT.BIC
    END

RETURN
*** </region>
END
