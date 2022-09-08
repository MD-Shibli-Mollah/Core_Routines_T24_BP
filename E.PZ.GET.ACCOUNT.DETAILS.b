* @ValidationCode : MjoxNTAyODE0MzE2OkNwMTI1MjoxNTg0NTA3NDUyNTYxOmtoYXJpbmk6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4xOjExMzoxMTM=
* @ValidationInfo : Timestamp         : 18 Mar 2020 10:27:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kharini
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 113/113 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.GET.ACCOUNT.DETAILS(AccData)
*-----------------------------------------------------------------------------
*New NOFILE enquiry routine to return values for account details enquiry.
*
*In/OutParam:
*=========
*AccData         -   Input/Output for the enquiry
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/01/2019 - Enhancement  2741200 / Task 2927603
*              Access to Accounts API Enhancement - Account details API - PSD2
*              Introduce new enquiry API.
*
* 11/03/19 - Defect 3634770 / Task 3635091
*           Changes to include debtor Name in account and payment status APIs
*-----------------------------------------------------------------------------
*  <region name= Inserts>
    $USING AC.AccountOpening
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $INSERT I_DDAService_TransactionDetails
    $INSERT I_DDAService_RestrictionDetails
    $USING ST.Customer
    $USING EB.Security
* </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>Program control</desc>
*
    GOSUB Initialise                                ;* Initialise the variables
    IF AcisInstalled THEN
        GOSUB BuildAccData                          ;* Build the account related details
    END ELSE
        EB.SystemTables.setEtext('')
        EnqError = "PZ-PRODUCT.AC.NOT.INSTALLED"    ;* EB.ERROR record
        EB.Reports.setEnqError(EnqError)            ;* If AC product not installed set error
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*** Initialise the enquiry data variables
    AccountId = ''
    AcDes = ''
    AcType =''
    AcCcy = ''
    LedgBal = ''
    AvailBal = ''
    Status = ''
    WithBalance = ''
    Details = ''
*** Initialise the AC.CHECK.ACCOUNT in parameters
    AcRec = ''
    CheckData = ''
    CheckData<AC.AccountOpening.AccountValidity> = 'Y'
    CheckData<AC.AccountOpening.AccountBalance> = 'Y'
    CheckData<AC.AccountOpening.HisAccount> = 'Y'
    CheckData<AC.AccountOpening.AccountIban> = 'Y'
    CheckData<AC.AccountOpening.AccountBic> = 'Y'
    CheckData<AC.AccountOpening.AccountArrangement> = 'Y'
    CheckData<AC.AccountOpening.AccountType> = 'Y'
    CallMode = 'ONLINE'
    OverrideCode = ''
    ErrorCode = ''
    AcEntryRec = ''
    CheckDataResult = ''
*** Initialise variables for IBAN & BIC
    iBan = ''
    Bic =''
*** Initialise variables for Balance check
    AvailBalance = ''
*** Get the Account ID
    LOCATE 'ACCOUNTREFERENCE' IN EB.Reports.getDFields()<1> SETTING AcPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        AccountId = EB.Reports.getDRangeAndValue()<AcPos>                           ;* Get the account id using the position
    END
*** Product installaion check
    EB.API.ProductIsInCompany('AC', AcisInstalled)
    
    LOCATE 'WITH.BALANCE' IN EB.Reports.getDFields()<1> SETTING BalPos THEN    ;* locate WITH.BALANCE in enquiry data and get position
        WithBalance = EB.Reports.getDRangeAndValue()<BalPos>
    END
    BEGIN CASE
        CASE WithBalance EQ "YES"
        CASE WithBalance EQ "NO"
        CASE WithBalance EQ ""
        CASE 1
            EB.Reports.setEnqError("PZ-VALUE.NOT.ALLOWED")
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildEnqData>
*** <desc>Build the data for enquiry output</desc>
BuildEnqData:
***
    AccData = AccountId:'*':iBan:'*':AcCcy:'*':LedgBal:'*':AcType:'**':AcDes:'*':Bic:'*':StatusOut:'*':Details:'*':AvailBal    ;* Form the enquiry output
***
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildAccData>
BuildAccData:
*** <desc> Build the account related data such as i) get Account record/Arrangement Id ii) determine STATUS , iii) get IBAN , iv) get BIC ,
***         v) get Currency&Description, vi) get Balances and vi) get Type. For the account provided in the enquiry.</desc>
*** get Account record/Arrangement Id & determine STATUS
    IF EB.Reports.getEnqError() THEN
        RETURN
    END
    AC.AccountOpening.CheckAccount(AccountId, AcRec, CheckData, CallMode, AcEntryRec, CheckDataResult, OverrideCode, ErrorCode)       ;* Validate the account
***
    Status = CheckDataResult<AC.AccountOpening.AccountValidity,1>
    AvailBal = CheckDataResult<AC.AccountOpening.AccountBalance,5>
    iBan = CheckDataResult<AC.AccountOpening.AccountIban,1>
    Bic = CheckDataResult<AC.AccountOpening.AccountBic,1>
    AcType = CheckDataResult<AC.AccountOpening.AccountType,1>
    AccountCompanyId = AcRec<AC.AccountOpening.Account.CoCode>
***
    IF Status = 'INVALID' THEN
        EnqError = 'AC-INVALID.AC.NO'
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)
        RETURN
    END
***
*** get Currency,Description
*** Get account currency from live account record/history record Currency field. Get LANG from Lngg of EB.SystemTables &
*** Get account description from live account record/history record ShortTitle of position LANG and if not present get ShortTitle in position 1.
    Lang = EB.SystemTables.getLngg()
    IF AcRec THEN
        AcCcy = AcRec<AC.AccountOpening.Account.Currency>
        AcDes = AcRec<AC.AccountOpening.Account.ShortTitle,Lang>
        IF NOT(AcDes) THEN
            AcDes = AcRec<AC.AccountOpening.Account.ShortTitle,1>
        END
    END
    GOSUB CheckBalRequired ; *
    GOSUB CheckRestrictions ; *
    GOSUB UpdateStatus ; *
***
    GOSUB BuildEnqData              ;* Build enquiry data
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckRestrictions>
CheckRestrictions:
*** <desc> </desc>
*** <desc>Check the account/customer restricts & mass block details.</desc>
    AccountRestrict = ""
    TransactionInfo<TransactionDetails.accountNumber> = AccountId
    TransactionInfo<TransactionDetails.sourceSystem> = 'PI'
    AccountCompanyRec = ST.CompanyCreation.Company.CacheRead(AccountCompanyId, Error)
    AccountCompany = AccountCompanyRec<ST.CompanyCreation.Company.EbComMnemonic>   ;* 'BNK' ;*
    CALL DDAService.getAccountRestrict(TransactionInfo, AccountCompany, AccountRestrict)    ;* get the restriction details
    DebitRestriction = AccountRestrict<RestrictionDetails.debitRestrictType>
    CreditRestriction = AccountRestrict<RestrictionDetails.creditRestrictType>
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UpdateStatus>
UpdateStatus:
*** <desc> </desc>
    cusErr = ''
    accCus = AcRec<AC.AccountOpening.Account.Customer> ;*Assign Customer name otherwise
    customerRec = ST.Customer.Customer.Read(accCus, cusErr)
    languageId = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>
    Details = customerRec<ST.Customer.Customer.EbCusNameOne,languageId>

    BEGIN CASE
    
        CASE Status EQ "CLOSED"
            StatusOut = "DELETED"

        CASE DebitRestriction AND CreditRestriction
            StatusOut = "BLOCKED"

        CASE Status EQ "ACTIVE"
            StatusOut = "ENABLED"

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckBalRequired>
CheckBalRequired:
*** <desc> </desc>
    IF WithBalance EQ "YES" THEN
        LedgBal = CheckDataResult<AC.AccountOpening.AccountBalance,1>
        IF LedgBal EQ "" THEN
            LedgBal = 0
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
