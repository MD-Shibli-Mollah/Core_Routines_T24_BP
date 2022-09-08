* @ValidationCode : MjotNTc1NjEyNjMyOkNwMTI1MjoxNTMzMjgxNzk0MzU3OnJhamFrOjEzOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOjIyNjoxOTk=
* @ValidationInfo : Timestamp         : 03 Aug 2018 13:06:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rajak
* @ValidationInfo : Nb tests success  : 13
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 199/226 (88.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.CHECK.FUNDS(ACC.DATA)
*-----------------------------------------------------------------------------
* New NOFILE enquiry routine to return values for confirmation of funds enquiry,
* returning account data with values if account is verified/ balance available.
*
*In/OutParam:
*=========
*ACC.DATA         -   Input/Output for the enquiry
*
*-----------------------------------------------------------------------------
* Modification History :
* 22/06/2017 - Enhancement  2140003/ Task 2174486
*              Access to Accounts API Enhancement - Balance verification - PSD2
*              Introduce new enquiry API.
*
* 07/11/2017 - Defect 2330363/ Task 2333751
*            - Return account verified as Yes for AA accounts. This will be overwritten
*              by iris after simulation.
*            - Check posting restriction for AR accounts like AC accounts
*
* 31/07/18 - Enhancement 2675466 / Task 2675535
*          - "OFS Clearing support for NSF processing"- Changes made to pass the TxnCode
*            along with the account number to check the balance.
*
*-----------------------------------------------------------------------------
*  <region name= Inserts>
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Template
    $USING EB.ErrorProcessing
    $USING ST.CompanyCreation
    $USING ST.CurrencyConfig
    $USING ST.Config
    $USING AA.ProductFramework
    $INSERT I_responseDetails
    $INSERT I_DDAService_TransactionDetails
    $INSERT I_DDAService_RestrictionDetails
    $INSERT I_DDAService_FundDetails
    $INSERT I_DDAService_FundsAvailable

* </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>Program control</desc>
*
    
    GOSUB Initialise                                ;* Initialise the variables
    IF AcisInstalled AND NOT(EnqError) THEN
        saveComi = EB.SystemTables.getComi()        ;* Save Comi to local variable
        GOSUB ValidateData                          ;* Validate the incoming param values
        EB.SystemTables.setComi(saveComi)           ;* Restore Comi
        GOSUB BuildAccData                          ;* Build the account related details
    END
    IF NOT(AcisInstalled) THEN
        EnqError = "PZ-PRODUCT.AC.NOT.INSTALLED"
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)            ;* If AC product not installed set error
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*** Product installaion check
    EB.API.ProductIsInCompany('AC', AcisInstalled)
*** Initialise the enquiry data variables
    EnqError = ''
    AccountId = ''
    Product =''
    AcCcy = ''
    AcVerified = ''
    BalanceAvailable = ''
    Status = ''
    ApiDate = ''
    ApiTime = ''
    ApiTimeZone = ''
    ApiDateTime = ''
    ArrId = ''
    Amt = ''
    Activity = ''
    AvailFlag = ''
*** Initialise the AC.CHECK.ACCOUNT in parameters
    AcRec = ''
    CheckData = ''
    CheckData<AC.AccountOpening.AccountValidity> = 'Y'
    CheckData<AC.AccountOpening.HisAccount> = 'Y'
    CheckData<AC.AccountOpening.AccountIban> = 'Y'
    CheckData<AC.AccountOpening.AccountArrangement> = 'Y'
    CheckData<AC.AccountOpening.AccountType> = 'Y'
    CallMode = 'ONLINE'
    OverrideCode = ''
    ErrorCode = ''
    AcEntryRec = ''
    CheckDataResult = ''
*** Initialise variables for IBAN
    iBan = ''
*** Initialise variables for accountrestricts
    transactionInfo = ''
    accountCompany = ''
    accountRestrict = ''
*** Initialise variables for check funds
    inCheckFunds = ''
    outCheckFunds = ''
*** Get the Account ID
    LOCATE 'ACCOUNTREFERENCE' IN EB.Reports.getDFields()<1> SETTING AcPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        AccountId = EB.Reports.getDRangeAndValue()<AcPos>                           ;* Get the account id using the position
    END ELSE
        EnqError = "PZ-ACCOUNT.REF.NOT.PROVIDED"
        EB.Reports.setEnqError(EnqError)                                            ;* If not located then no account id passed set error
        RETURN
    END
****** Get the Amount
    LOCATE 'AMOUNT' IN EB.Reports.getDFields()<1> SETTING AmtPos THEN    ;* locate AMOUNT in enquiry data and get position
        Amt = EB.Reports.getDRangeAndValue()<AmtPos>                           ;* Get the amount using the position
    END ELSE
        EnqError = "PZ-AMOUNT.NO.INPUT"
        EB.Reports.setEnqError(EnqError)                                            ;* If not located then no amount input set error
        RETURN
    END
****** Get the currency
    LOCATE 'CURRENCY' IN EB.Reports.getDFields()<1> SETTING CcyPos THEN    ;* locate CURRENCY in enquiry data and get position
        AcCcy = EB.Reports.getDRangeAndValue()<CcyPos>                           ;* Get the currency using the position
    END ELSE
        EnqError = "PZ-CURRENCY.NO.INPUT"
        EB.Reports.setEnqError(EnqError)                                            ;* If not located then no currency input set error
    END
****** Get the Transaction Code
    LOCATE 'TXN.CODE' IN EB.Reports.getDFields()<1> SETTING TxnCodePos THEN    ;* locate TRANSACTION CODE in enquiry data and get position
        TxnCode = EB.Reports.getDRangeAndValue()<TxnCodePos>                   ;* Get the transaction code using the position
    END
****** Get the Debit or Credit indicator
    LOCATE 'DR.CR.IND' IN EB.Reports.getDFields()<1> SETTING DrCrPos THEN    ;* locate debit or credit indicator in enquiry data and get position
        DebitCreditIndicator = EB.Reports.getDRangeAndValue()<DrCrPos>       ;* Get the debit/credit using the position
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildEnqData>
*** <desc>Build the data for enquiry output</desc>
BuildEnqData:
***

    ACC.DATA = AccountId:'*':iBan:'*':AcVerified:'*':BalanceAvailable:'*':ApiDateTime:'*':ArrId:'*':Product:'*':Activity    ;* Form the enquiry output
***
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildAccData>
BuildAccData:
*** <desc> Validate the account related data such as i) restrictions , ii) balance , iii) time , iv) activity.
***        For the account provided in the enquiry.</desc>

    IF EnqError THEN        ;* If no account id passed/amount or currency format not proper then no need to proceed
        RETURN
    END
*** get Account record/Arrangement Id & determine STATUS
    AccountId<5> = TxnCode
    AC.AccountOpening.CheckAccount(AccountId, AcRec, CheckData, CallMode, AcEntryRec, CheckDataResult, OverrideCode, ErrorCode)       ;* Validate the account
***
    Status = CheckDataResult<AC.AccountOpening.AccountValidity,1>
    iBan = CheckDataResult<AC.AccountOpening.AccountIban,1>
    ArrId = CheckDataResult<AC.AccountOpening.AccountArrangement,1>
    Product = CheckDataResult<AC.AccountOpening.AccountType,1>
    accountCompanyId = AcRec<AC.AccountOpening.Account.CoCode>
***
    IF Status = 'INVALID' THEN
        EnqError = 'AC-INVALID.AC.NO'        ;* If account is invalid no need to proceed further
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)    ;* Set enquiry error and return
        RETURN
    END
***

    GOSUB GetActivity                       ;* Get the activity
    GOSUB CheckAaAccountType
   
    BEGIN CASE
        CASE Status = 'ACTIVE'
            IF AcAccount THEN
                GOSUB CheckRestrictions             ;* Check the account/activity restrictions
            END ELSE
                AcVerified = 'YES'                  ;* If AA account then simulation will happen so we are setting it here as YES
            END
            GOSUB CheckBalance                      ;* Check balance
        CASE Status = 'INACTIVE'
            AcVerified = 'NO'
            GOSUB CheckBalance                      ;* Check balance
        CASE Status = 'CLOSED'
            EnqError = 'AC-ACCOUNT.CLOSED.STATUS'        ;* If account is closed no need to proceed further
            EB.SystemTables.setEtext('')
            EB.Reports.setEnqError(EnqError)        ;* Set enquiry error and return
            RETURN
    END CASE

    GOSUB CheckTime                         ;* Check the time
    EB.SystemTables.setEtext('')            ;* Clear the Etext
***
    GOSUB BuildEnqData                      ;* Build enquiry data
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ValidateData>
ValidateData:
*** <desc>Validate the data came from enquiry.</desc>
***
*** Amount format
    EB.SystemTables.setComi(Amt)                ;* Set Comi as AMOUNT
    EB.Template.In2amt("16","AMT")              ;* Validate the amount
    Amt = EB.SystemTables.getComi()             ;* Assign back the formated Comi value to AMOUNT
    EnqError = EB.SystemTables.getEtext()         ;* Get the errors if any
    IF EnqError THEN
        EB.SystemTables.setEtext('')            ;* We are retunring back EnqError. Clearing Etext to prevent getting carried over.
        EB.Reports.setEnqError(EnqError)          ;* If amount is not in proper format set error
        RETURN
    END
*** Currency format
    EB.SystemTables.setComi(AcCcy)                ;* Set Comi as CURRENCY
    EB.Template.In2ccy("3","CCY")               ;* Validate the currency
    AcCcy = EB.SystemTables.getComi()             ;* Assign back the formated Comi value to CURRENCY
    EnqError = EB.SystemTables.getEtext()         ;* Get the errors if any
    IF EnqError THEN
        EB.SystemTables.setEtext('')            ;* We are retunring back EnqError. Clearing Etext to prevent getting carried over.
        EB.Reports.setEnqError(EnqError)          ;* If amount is not in proper format set error
        RETURN
    END ELSE
        Error = ''
        ST.CurrencyConfig.Currency.CacheRead(AcCcy, Error)
        IF Error THEN
            EnqError = 'AC-CCY.MISS'        ;* If currency is invalid no need to proceed further
            EB.SystemTables.setEtext('')
            EB.Reports.setEnqError(EnqError)    ;* Set enquiry error and return
            RETURN
        END
    END
*** Transaction code availability
    IF TxnCode THEN
        Error = ''
        TxnRec = ST.Config.Transaction.Read(TxnCode, Error)                             ;* read the TRANSACTION record
        IF Error THEN
            EnqError = 'AC-MISS.TRANSACTION.CODE'                              ;* If transaction code is invalid no need to proceed further
            EB.SystemTables.setEtext('')
            EB.Reports.setEnqError(EnqError)                                   ;* Set enquiry error and return
            RETURN
        END
    END
*** DEBIT/CREDIT validity
    BEGIN CASE
        CASE NOT(DebitCreditIndicator)                                      ;* not provided any indicator take it DEBIT default
            DebitCreditIndicator = 'DEBIT'
        CASE DebitCreditIndicator AND NOT(DebitCreditIndicator ='CREDIT' OR DebitCreditIndicator ='DEBIT')
            EnqError = 'PZ-NOT.ALLOWED.DR.CR.IND'                              ;* If not inputt with DEBIT/CREDIT no need to proceed further
            EB.SystemTables.setEtext('')
            EB.Reports.setEnqError(EnqError)                                   ;* Set enquiry error and return
            RETURN
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckRestrictions>
CheckRestrictions:
*** <desc>Check the account/customer restricts & mass block details.</desc>
    transactionInfo<TransactionDetails.accountNumber> = AccountId
    transactionInfo<TransactionDetails.amount> = Amt
    transactionInfo<TransactionDetails.sourceSystem> = 'PI'
    accountCompanyRec = ST.CompanyCreation.Company.CacheRead(accountCompanyId, Error)
    accountCompany = accountCompanyRec<ST.CompanyCreation.Company.EbComMnemonic>   ;* 'BNK' ;*
    CALL DDAService.getAccountRestrict(transactionInfo, accountCompany, accountRestrict)    ;* get the restriction details
    IF DebitCreditIndicator ='DEBIT' THEN
        DebitCreditRestriction = accountRestrict<RestrictionDetails.debitRestrictType>
    END ELSE
        DebitCreditRestriction = accountRestrict<RestrictionDetails.creditRestrictType>
    END
    IF DebitCreditRestriction THEN
        AcVerified = 'NO'
        
    END ELSE
        AcVerified = 'YES'
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckBalance>
CheckBalance:
*** <desc> </desc>
***
    inCheckFunds<FundDetails.accountCurrency> = AcCcy
    inCheckFunds<FundDetails.paymentCurrency> = AcCcy
    inCheckFunds<FundDetails.accountNumber> = AccountId
    inCheckFunds<FundDetails.accountCompany> = accountCompanyId     ;* 'US0010001' ;*
    inCheckFunds<FundDetails.paymentAmount> = Amt
    inCheckFunds<FundDetails.transactionCode> = TxnCode
    CALL DDAService.checkFunds(inCheckFunds, outCheckFunds)
    IF NOT(EB.SystemTables.getEtext()) THEN                             ;* If no error
        AvailFlag = outCheckFunds<FundsAvailable.fundsAvailableFlag>    ;* whether the provided amount available in account or not. YES/NO
        IF AvailFlag ='YES' THEN                                        ;* If available balance verified yes
            BalanceAvailable = 'YES'
        END ELSE
            BalanceAvailable = 'NO'                                     ;* If not available balance verified no
        END
    END ELSE
        BalanceAvailable = 'NO'                                         ;* If error set balance verified no
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckTime>
CheckTime:
*** <desc>Calculate the local time </desc>
    ApiDate = OCONV(LOCALDATE(TIMESTAMP(),@TIMEZONE),'D4-')
    ApiTime = OCONV(LOCALTIME(TIMESTAMP(),@TIMEZONE),'MTS')
    ApiTimeZone = ''
    IF FIELD(@TIMEZONE,'-',2) THEN
        ApiTimeZone = '+': FIELD(@TIMEZONE,'-',2)
    END
    IF  FIELD(@TIMEZONE,'+',2) THEN
        ApiTimeZone = '-': FIELD(@TIMEZONE,'+',2)
    END
    ApiDateTime = ApiDate['-',3,1]:'-': ApiDate['-',1,1]:'-': ApiDate['-',2,1]:'T': ApiTime: ApiTimeZone    ;* date time separated by '-'
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetActivity>
GetActivity:
*** <desc>Get the activity related to the account </desc>
    IF Status NE 'CLOSED' AND ArrId THEN
        TxnDate = EB.SystemTables.getToday()
        AA.Framework.GetTransactionActivity("",ArrId, TxnDate, TxnCode,DebitCreditIndicator, Activity,"")  ;* It returns the Activity id based on the transaction code passed
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckAaAccountType>
CheckAaAccountType:
    
*** <desc>Check the type of arrangement account </desc>
    AcAccount = '1' ;* set all accounts as AC accounts
    IF ArrId AND Activity THEN
        AA.ProductFramework.GetActivityClass(Activity, ActivityClassID, ActivityClassRecord) ;* Get Activity class
        LOCATE "DIRECT.ACCOUNTING" IN ActivityClassRecord<AA.ProductFramework.ActivityClass.AccActivityType, 1> SETTING DIRECT.ACCTNG ELSE ;* just like AC Accounts
            AcAccount = '' ;* if not AR account, then restrictions will be checked in simulation. Reset the flag
        END ;* end Direct Accounting Locate
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END

