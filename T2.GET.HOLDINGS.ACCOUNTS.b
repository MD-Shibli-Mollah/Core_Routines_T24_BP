* @ValidationCode : MjotMTY2ODk1NTU3NjpDcDEyNTI6MTYxNTMyNDMxODU3NDpzaXZhY2hlbGxhcHBhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDoyNTU6MTcw
* @ValidationInfo : Timestamp         : 10 Mar 2021 02:41:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 170/255 (66.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*--------------------------------------------------------------------------------------------------------------------

$PACKAGE T2.ModelBank
SUBROUTINE T2.GET.HOLDINGS.ACCOUNTS(selectionArray,customerArrangement,configArray,returnArray,totalAccountBalances)
*----------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To list the holdings of the external user
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > T2.API.NOF.HOLDINGS.1.0.0 using the Standard selection NOFILE.API.HOLDINGS
* IN Parameters      : Customer Id (CUSTOMER.NO)
* Out Parameters     : Array of holding array values such as
*                      productLineId, arrangementId, productGroupId, accountId, productDescription/preferredLabel, currency, sortCode,
*                      accountIBAN, workingBalance, preferredProduct and preferredPosition (HOLDINGS.ARRAY)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
*
* 10/03/19 - Enhancement 2875480 / Task 3018257
*            IRIS-R18 T24 changes - Retrieving customer account details
*
* 12/11/19 - Enhancement 2875478 / Task 3431799
*            IRIS_R18 Corporate API - Adding preferences id in holdings enquiry&Displaying active product
*
* 06/04/20 - Enhancement 342896 / Task 3680076
*            US Saas Integration - Adding customerReference id in holdings
*
* 10/03/20 - ADP-1716
*            Infinity Wealth - Portfolio Id field changes for Investment Accounts
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
    $USING EB.ErrorProcessing
    $USING AA.Framework
    $USING T2.ModelBank
    $USING EB.Reports
    $USING EB.DataAccess
    $USING AC.ModelBank
    $USING AC.Channels
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING T2.Preferences
    $USING EB.Interface
    $USING EB.Security
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING AA.Account
    $USING AA.Statement
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>
*
    GOSUB Initialise
    GOSUB Process
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise variables used in this routine</desc>
Initialise:
*----------
*
    DEFFUN System.getVariable()
 
    fnAaProduct = 'F.AA.PRODUCT'
    fAaProduct = ''
    EB.DataAccess.Opf(fnAaProduct, fAaProduct)

    fnAaProductGroup = 'F.AA.PRODUCT.GROUP'
    fAaProductGroup = ''
    EB.DataAccess.Opf(fnAaProductGroup, fAaProductGroup)
    
    fnAaProductLine = 'F.AA.PRODUCT.LINE'
    fAaProductLine = ''
    EB.DataAccess.Opf(fnAaProductLine, fAaProductLine)

    fnCategory = 'F.CATEGORY'
    fCategory = ''
    EB.DataAccess.Opf(fnCategory, fCategory)
    
    FN.TC.USER.PREFERENCES = 'F.TC.USER.PREFERENCES'
    F.TC.USER.PREFERENCES = ''
    EB.DataAccess.Opf(FN.TC.USER.PREFERENCES, F.TC.USER.PREFERENCES)
 
    CONVERT "|" TO @FM IN selectionArray
    selCustomerId = selectionArray<1>
    selProductLabel = selectionArray<2>
    selProductFilter = selectionArray<3>
    selPreferredHoldings = selectionArray<4>
    
    configProductLabel   = configArray<T2.ModelBank.HoldingsParameter.HpProductLine>
    configProductGroup   = configArray<T2.ModelBank.HoldingsParameter.HpProductGroup>
    configProductId      = configArray<T2.ModelBank.HoldingsParameter.HpProduct>
    configSecurityFilter = configArray<T2.ModelBank.HoldingsParameter.HpSecurityFilter>

    externalUserId = ''
    maxAccountList = ''
    returnIds = ''
    

    externalUserId = EB.ErrorProcessing.getExternalUserId()
    IF externalUserId THEN
        IF NOT(selProductFilter)     THEN selProductFilter     = 'EXT.SMS.ACCOUNTS.SEE'
        IF NOT(configSecurityFilter) THEN configSecurityFilter = 'EXT.SMS.ACCOUNTS.SEE'
        GOSUB readPreferences
        GOSUB getExtVariables
    END
    IF externalUserId AND (selPreferredHoldings EQ 'YES' OR selPreferredHoldings EQ 'Y') THEN
        IF NOT(selProductFilter)     THEN selProductFilter     = 'EXT.PRF.ACCOUNTS'
        configSecurityFilter = 'EXT.PRF.ACCOUNTS'
    END
    IF NOT(selProductFilter) AND customerArrangement THEN
        ProductLineList = customerArrangement<AA.Framework.CustomerArrangement.CusarrProductLine>
        productLine = 'ACCOUNTS'
        GOSUB getIdsFromConcat
        selProductFilter = returnIds
    END
    productLineId = '';  arrangementId = ''  ;  productGroupId = ''  ;  accountId = ''      ;  productDescription = '' ;  currency = ''   ; sortCode = ''; portfolioId = '';
    accountIBAN = ''  ;  workingBalance = '' ;  preferredProduct = '';  preferredLabel = '' ;  preferredPosition = ''  ;  productId = ''  ; coCode = '';
    productArray = '' ;  productSel = ''     ;  accountIdSel = ''    ;  loanIdSel = ''      ;  depositIdSel = ''       ;  customerId = '' ;
    productGroupName = ''  ;  productLineName = ''  ; outstandingAmount = ''; paidOutAmount = ''; onlineActualBalance = '';depositsBalance = '';loansBalance = '';
*
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Get holdings details for process</desc>
Process:
*--------
*
    BEGIN CASE
        CASE selProductFilter[1,1] EQ '!'
            accountList = System.getVariable(selProductFilter[2,99])
            CONVERT @SM TO @VM IN  accountList
        CASE selProductFilter[1,3] EQ 'EXT'
            accountList = System.getVariable(selProductFilter)
            CONVERT @SM TO @VM IN  accountList
        CASE selProductFilter NE ''
            accountList = selProductFilter
            CONVERT ' ' TO @VM IN  accountList
    END CASE

    BEGIN CASE
        CASE configSecurityFilter[1,1] EQ '!'
            maxAccountList = System.getVariable(configSecurityFilter[2,99])
            CONVERT @SM TO @VM IN  maxAccountList
        CASE configSecurityFilter[1,3] EQ 'EXT'
            maxAccountList = System.getVariable(configSecurityFilter)
            CONVERT @SM TO @VM IN  maxAccountList
        CASE configSecurityFilter NE ''
            maxAccountList = configSecurityFilter
            CONVERT ' ' TO @VM IN  maxAccountList
    END CASE
*
    GOSUB getAccountDetails
    returnArray = productArray
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getAccountDetails>
*** <desc>Get Account details by reading the Account record</desc>
getAccountDetails:
*-----------------
*
    LOOP
        REMOVE accountId FROM accountList SETTING accountPos
    WHILE accountId:accountPos
        IF accountId[1,2] EQ 'AA' THEN
            arrangementId = accountId
            AA.Framework.GetArrangementAccountId(arrangementId, accountId, "", "");* Get account of current arrangement
        END

        productLineId = '';  arrangementId = '';  productGroupId = '';   productDescription = ''; currency = '';           sortCode = '';   coCode = ''; portfolioId = '' ;
        accountIBAN = '';    workingBalance = ''; preferredProduct = ''; preferredLabel = ''; accountRecord = '';  preferredPosition = '';  productId = '';  arrangementStatus = '';
        RecUserPreferences = '';totalPrincipal = ''; propertyRecord = ''; customerRef = ''; propertyIDs = '' ; Err = ''
        GOSUB readAccount
        arrangementId = accountRecord<AC.AccountOpening.Account.ArrangementId>
        GOSUB readArrangementAndProduct
        IF productLineId NE 'ACCOUNTS' THEN CONTINUE
        IF externalUserId THEN
            FINDSTR accountId IN maxAccountList SETTING accountPos ELSE CONTINUE
            oData = accountId:"-":productLineId
            GOSUB getPreferences
            IF RecUserPreferences THEN
                preferredProductId = accountId
                preferredProductVarName = "EXT.PRF.ACCOUNTS"
                preferredLabelVarName = "EXT.PRF.ACCOUNTS.LABEL"
                GOSUB getPreferredLabel
            END
            IF preferredLabel THEN
                productDescription = preferredLabel
            END
        END
        sortCode = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComIbanBranchId)
        companyName = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCompanyName)

        oData = accountId
        EB.Reports.setOData(oData)
        AC.Channels.ETcConvIbanId()
        accountIBAN = EB.Reports.getOData()

        accountBalances=''
        
        GOSUB calculateAccountBalances
        
        AA.Framework.GetArrangementConditions(arrangementId,'ACCOUNT','','',propertyIDs,propertyRecord,Err) ;* Get Account arrangement condition record
        propertyRecord = RAISE(propertyRecord)                                      ;* Account property record
        customerRef = propertyRecord<AA.Account.Account.AcCustomerReference>           ;*CustomerReference
        AA.Framework.GetArrangementConditions(arrangementId,'STATEMENT','','',propertyIDs,propertyRecord,Err) ;* Get Account arrangement condition record
        propertyRecord = RAISE(propertyRecord)                                      ;* Account property record
        LOCATE 'Printing.Option' IN propertyRecord<AA.Statement.Statement.StaAttributeName,1> SETTING printPos THEN
            printOption=propertyRecord<AA.Statement.Statement.StaAttributeValue,printPos>
        END
*
        IF productArray THEN
            productLineId = ''
        END
        productArray<-1> = productLineId:"*":productLineName:"*":arrangementId:"*":productGroupId:"*":productGroupName:"*":productId:"*":productDescription:"*":accountId:"*":shortTitle:"*":category:"*":coCode:"*":currency
        productArray:="*":sortCode:"*":accountIBAN:"*":workingBalance:"*":openingDate:"*":companyName:"*":preferredProduct:"*":preferredPosition:"*":preferredLabel:"*":permission:"*":onlineActualBalance:"*":availableBalance:"*":availableBalanceLimit
        productArray:="*":outstandingAmount:"*":paidOutAmount:"*":arrangementStatus:"*":totalPrincipal:"*":customerRef:"*":printOption:"*": portfolioId
        
        
    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------

*** <region name = readAccount>
*** <desc>Read Account record</desc>
readAccount:
*-----------
*
    accountRecord = '';
    accounrError  = ''
    accountRecord = AC.AccountOpening.Account.Read(accountId, accounrError)      ;* Try reading the Account record
    currency      = accountRecord<AC.AccountOpening.Account.Currency>            ;* To get account currency
    coCode        = accountRecord<AC.AccountOpening.Account.CoCode>              ;* To get the company code
    category      = accountRecord<AC.AccountOpening.Account.Category>           ;* To get category of account
    openingDate   = accountRecord<AC.AccountOpening.Account.OpeningDate>
    languageId    = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>
    shortTitle    = accountRecord<AC.AccountOpening.Account.ShortTitle,languageId>
    portfolioId   = accountRecord<AC.AccountOpening.Account.PortfolioNo>        ;* Get portfolio id to identify investment accounts
    IF shortTitle EQ '' THEN
        shortTitle = accountRecord<AC.AccountOpening.Account.AccountTitleOne>
    END
 
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = readArrangementAndProduct>
*** <desc>Read Arrangement record</desc>
readArrangementAndProduct:
*------------------------
*
    arrangementRecord = ''
    arrangementError  = ''
    arrangementRecord = AA.Framework.Arrangement.Read(arrangementId, arrangementError)
    productLineId     = arrangementRecord<AA.Framework.Arrangement.ArrProductLine>
    productGroupId    = arrangementRecord<AA.Framework.Arrangement.ArrProductGroup>
    productId         = arrangementRecord<AA.Framework.Arrangement.ArrActiveProduct>    ;*getting the acive product
    arrangementStatus = arrangementRecord<AA.Framework.Arrangement.ArrArrStatus>

    productRecord = ''
    productError  = ''
    EB.DataAccess.FRead(fnAaProduct, productId, productRecord, fAaProduct, procuctError)
    productDescription = productRecord<AA.ProductManagement.Product.PdtDescription>
    
    productGroupRecord = ''
    productGroupError  = ''
    EB.DataAccess.FRead(fnAaProductGroup, productGroupId, productGroupRecord, fAaProductGroup, procuctError)
    productGroupName = productGroupRecord<AA.ProductFramework.ProductGroup.PgDescription>

    productLineRecord = ''
    productLineError  = ''
    EB.DataAccess.FRead(fnAaProductLine, productLineId, productLineRecord, fAaProductLine, procuctLineError)
    productLineName = productLineRecord<AA.ProductFramework.ProductLine.PlDescription>
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getPreferences>
*** <desc>Get External User Preferences</desc>
getPreferences:
*--------------
*
    permission = ''
    EB.Reports.setOData(oData)
    T2.ModelBank.ETcConvGetVariables()
    oDataRetrun       = EB.Reports.getOData()
    transactionRights = FIELD(oDataRetrun,'*',1)
    preferredProduct  = FIELD(oDataRetrun,'*',2)
    preferredLabel    = FIELD(oDataRetrun,'*',3)
    preferredPosition = FIELD(oDataRetrun,'*',4)
    seeRights         = FIELD(oDataRetrun,'*',5)
    IF seeRights EQ 'YES' THEN
        permission = "See"
    END
    IF transactionRights EQ 'YES' THEN
        permission = "Transact"
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getIdsFromConcat>
*** <desc>Get Id Array from Concat Record</desc>
getIdsFromConcat:
*----------------
*
    returnIds = ''
    LOCATE productLine IN ProductLineList<1,1> SETTING POS THEN                                   ;*take only ACCOUNTS product line Arrangements
        ArrangementList = customerArrangement<AA.Framework.CustomerArrangement.CusarrArrangement,POS>
        CONVERT @SM TO @VM IN ArrangementList
        returnIds = ArrangementList
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = readPreferences>
readPreferences:
*---------------
*** <desc>Read Preferences</desc>
*
    CURRENT.ARRANGEMENT = ''
    CURRENT.ARRANGEMENT = System.getVariable('Arrangement') ;* Getting Arrangement Value
    CURRENT.PREFERENCE.ID = System.getVariable('PreferenceId') ;* Getting Preferences Id Value
    UserPreferencesId = externalUserId:"*":CURRENT.ARRANGEMENT:"*":CURRENT.PREFERENCE.ID
    RecUserPreferences = ''
* Form ID & retrive the details of TC USER PREFERENCES
    READ RecUserPreferences FROM F.TC.USER.PREFERENCES, UserPreferencesId ELSE
        RecUserPreferences = ''
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getExtVariables>
getExtVariables:
*---------------
*** <desc>Get Ext Variables</desc>
*
    User.variableNames = ''
    User.variableValues = ''
    variablesNo = ''
    IF RecUserPreferences THEN ;
        User.variableNames = RecUserPreferences<T2.Preferences.TcUserPreferences.TcUserPrfPrefName> ;* User Prf variables
        User.variableValues = RecUserPreferences<T2.Preferences.TcUserPreferences.TcUserPrfPrefValue> ;* User Prf values
        variablesNo = DCOUNT( User.variableNames, @VM )
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getPreferredLabel>
getPreferredLabel:
*-----------------
*** <desc>Get Preferred Label</desc>

    productsValue = ''
    labelValue = ''
    preferredLabel = ''
    LOCATE preferredProductVarName IN User.variableNames<1,1> SETTING productPos THEN
        productsValue = RAISE(RAISE(User.variableValues<1,productPos>))
    END
    LOCATE preferredLabelVarName IN User.variableNames<1,1> SETTING labelPos THEN
        labelValue = RAISE(RAISE(User.variableValues<1,labelPos>))
    END
    LOCATE preferredProductId IN productsValue<1,1> SETTING preferredProductPos THEN
        preferredLabel = labelValue<1,preferredProductPos>
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------


calculateAccountBalances:
*-----------------
*** <desc>Get Preferred Label</desc>

    oData = accountId
    EB.Reports.setOData(oData)
    AC.ModelBank.EGetAcWorkingBalance()
    workingBalance = EB.Reports.getOData()
        
    oData = accountId
    EB.Reports.setOData(oData)
    AC.ModelBank.EGetAcOnlineActualBalance()
    onlineActualBalance = EB.Reports.getOData()
    GOSUB calculateTotalAccountBalances
    
    oData = accountId
    EB.Reports.setOData(oData)
    AC.ModelBank.ETotalLockAmt()
    lockedAmount = EB.Reports.getOData()

    availableBalance = workingBalance - lockedAmount

    oData = accountId
    EB.Reports.setOData(oData)
    AC.ModelBank.EMbAvailLmtUpd()
    availableLimit = EB.Reports.getOData()

    balanceWithLimit = availableBalance + availableLimit - workingBalance

    IF availableBalance GT 0 THEN
        availableBalanceLimit = balanceWithLimit
    END ELSE
        availableBalanceLimit = availableLimit
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------

calculateTotalAccountBalances:
*----------------------------------------
*** <desc>Calculate Total Account Balances</desc>

    localCurrency = accountRecord<AC.AccountOpening.Account.Currency>          ;* Get the account currency
    baseCurrency   = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCurrency) ;* To get the Logged in company currency from R.COMPANY common Variable.
   
    localAmount   = onlineActualBalance
    IF baseCurrency NE localCurrency THEN
        convertedAmount = ""
        ST.ExchangeRate.Exchrate('1',localCurrency,localAmount,baseCurrency,convertedAmount,'','','','','')  ;* Get the exchange rate value
        finalAmount = convertedAmount
    END ELSE
        finalAmount = localAmount
    END
    
    totalAccountBalances = finalAmount + totalAccountBalances
*
RETURN

END
