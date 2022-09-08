* @ValidationCode : MjotMTI0OTcwNTU3NjpDcDEyNTI6MTU3MzU1MjM3ODk4MTpzbXVnZXNoOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzoyMzk6MTUz
* @ValidationInfo : Timestamp         : 12 Nov 2019 15:22:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 153/239 (64.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE T2.ModelBank
SUBROUTINE T2.GET.HOLDINGS.LOANS(selectionArray,customerArrangement,configArray,returnArray,totalLoanBalances)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To list the holdings of the external user
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > AC.API.NOFILE.HOLDINGS.1.0.0 using the Standard selection NOFILE.API.HOLDINGS
* IN Parameters      : Customer Id (CUSTOMER.NO)
* Out Parameters     : Array of holding array values such as
*                      productLineId, arrangementId, productGroupId, loanId, productDescription/preferredLabel, currency, sortCode,
*                      accountIBAN, workingBalance, preferredProduct and preferredPosition (HOLDINGS.ARRAY)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
*
* 10/03/19 - Enhancement 2875480 / Task 3018257
*            IRIS-R18 T24 changes - Retrieving customer loan details
*---------------------------------------------------------------------------------------------------------------------
* 12/11/19 - Enhancement 2875478 / Task 3431799
*            Displaying active product
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.ErrorProcessing
    $USING AA.Framework
    $USING T2.ModelBank
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AA.Channels
    $USING T2.Preferences
    $USING EB.Interface
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING EB.DataAccess
    $USING EB.Security
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING AC.Channels
    $USING ST.ExchangeRate
    $USING AC.BalanceUpdates
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
    openingDate = ''; shortTitle = ''; availableBalanceLimit = ''; availableBalance= ''; onlineActualBalance = ''; category = '';companyName = '';
    
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
    maxLoanList = ''
    
    externalUserId = EB.ErrorProcessing.getExternalUserId()
    IF externalUserId THEN
        IF NOT(selProductFilter)     THEN selProductFilter     = 'EXT.SMS.LOANS.SEE'
        IF NOT(configSecurityFilter) THEN configSecurityFilter = 'EXT.SMS.LOANS.SEE'
        GOSUB readPreferences
        GOSUB getExtVariables
    END
    IF externalUserId AND (selPreferredHoldings EQ 'YES' OR selPreferredHoldings EQ 'Y') THEN
        IF NOT(selProductFilter)     THEN selProductFilter     = 'EXT.PRF.LOANS'
        configSecurityFilter = 'EXT.PRF.LOANS'
    END
    IF NOT(selProductFilter) AND customerArrangement THEN
        ProductLineList = customerArrangement<AA.Framework.CustomerArrangement.CusarrProductLine>
        productLine = 'LENDING'
        GOSUB getIdsFromConcat
        selProductFilter = returnIds
    END
    productLineId = '';  arrangementId = '';  productGroupId = '';   accountId = '';      productDescription = ''; currency = ''; sortCode = '';
    accountIBAN = '';    workingBalance = ''; preferredProduct = ''; preferredLabel = ''; preferredPosition = '';  productId = ''; coCode = '';
    productArray = ''; productSel = '';     accountIdSel = '';     loanIdSel = '';      loanIdSel = '';       customerId = ''; depositsBalance = '';
    
    productGroupName = ''  ;  productLineName = ''  ;
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
            loanList = System.getVariable(selProductFilter[2,99])
            CONVERT @SM TO @VM IN  loanList
        CASE selProductFilter[1,3] EQ 'EXT'
            loanList = System.getVariable(selProductFilter)
            CONVERT @SM TO @VM IN  loanList
        CASE selProductFilter NE ''
            loanList = selProductFilter
            CONVERT ' ' TO @VM IN  loanList
    END CASE

    BEGIN CASE
        CASE configSecurityFilter[1,1] EQ '!'
            maxLoanList = System.getVariable(configSecurityFilter[2,99])
            CONVERT @SM TO @VM IN  maxLoanList
        CASE configSecurityFilter[1,3] EQ 'EXT'
            maxLoanList = System.getVariable(configSecurityFilter)
            CONVERT @SM TO @VM IN  maxLoanList
        CASE configSecurityFilter NE ''
            maxLoanList = configSecurityFilter
            CONVERT ' ' TO @VM IN  maxLoanList
    END CASE
*
    GOSUB getLoanDetails
    returnArray = productArray
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getLoanDetails>
*** <desc>Get Loan details by reading the Arrangement record</desc>
getLoanDetails:
*--------------
    LOOP
        REMOVE arrangementId FROM loanList SETTING loanPos
    WHILE arrangementId:loanPos

        productLineId = '';     productGroupId = ''; accountId = '';        productDescription = ''; currency = '';           sortCode = '';  coCode = '';
        accountIBAN = '';       approvedAmount = ''; preferredProduct = ''; preferredLabel = '';     preferredPosition = '';  productId = ''; arrangementStatus = '';
        outstandingAmount = ''; paidOutAmount = ''; accountsBalance = '';
    
        IF arrangementId[1,2] NE 'AA' THEN
            accountId = arrangementId
            GOSUB readAccount
            arrangementId = accountRecord<AC.AccountOpening.Account.ArrangementId>
        END
        GOSUB readArrangementAndProduct
        IF productLineId NE 'LENDING' THEN CONTINUE
        IF arrangementStatus MATCHES 'UNAUTH':@VM:'CANCELLED':@VM:'MATURED':@VM:'CLOSE' THEN CONTINUE
        IF NOT(accountId) THEN
            AA.Framework.GetArrangementAccountId(arrangementId, accountId, "", "");* Get account of current arrangement
            GOSUB readAccount
        END
        IF externalUserId THEN
            FINDSTR arrangementId IN maxLoanList SETTING arrangementPos ELSE CONTINUE
            oData = arrangementId:"-":productLineId
            GOSUB getPreferences
            IF RecUserPreferences THEN
                preferredProductId = accountId
                preferredProductVarName = "EXT.PRF.LOANS"
                preferredLabelVarName = "EXT.PRF.LOANS.LABEL"
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
        
        oDataReturn = ''
        oData = accountId:"*":arrangementId
        EB.Reports.setOData(oData)
        AA.Channels.ETcConvAaLoanDetails()
        oDataReturn = EB.Reports.getOData()
        paidOutAmount  = ABS(FIELD(oDataReturn,"*",1))
        approvedAmount = ABS(FIELD(oDataReturn,"*",2))
        outstandingAmount = ABS(FIELD(oDataReturn,"*",3))
        totalPrincipal = ABS(FIELD(oDataReturn,"*",4))
        IF productArray THEN
            productLineId = ''
        END
        productArray<-1> = productLineId:"*":productLineName:"*":arrangementId:"*":productGroupId:"*":productGroupName:"*":productId:"*":productDescription:"*":accountId:"*":shortTitle:"*":category:"*":coCode:"*":currency
        productArray:="*":sortCode:"*":accountIBAN:"*":approvedAmount:"*":openingDate:"*":companyName:"*":preferredProduct:"*":preferredPosition:"*":preferredLabel:"*":permission:"*":onlineActualBalance:"*":availableBalance:"*":availableBalanceLimit
        productArray:="*":outstandingAmount:"*":paidOutAmount:"*":arrangementStatus:"*":totalPrincipal
    REPEAT
    totalLoanBalances = ABS(totalLoanBalances)
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
    currency      = accountRecord<AC.AccountOpening.Account.Currency>
    coCode        = accountRecord<AC.AccountOpening.Account.CoCode>
    category      = accountRecord<AC.AccountOpening.Account.Category>           ;* To get category of account
    openingDate   = accountRecord<AC.AccountOpening.Account.OpeningDate>
    languageId    = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>
    localCurrency = accountRecord<AC.AccountOpening.Account.Currency>          ;* Get the account currency
    shortTitle    = accountRecord<AC.AccountOpening.Account.ShortTitle,languageId>
    IF shortTitle EQ '' THEN
        shortTitle = accountRecord<AC.AccountOpening.Account.AccountTitleOne>
    END
    GOSUB calculateTotalAccountBalances

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
    productId         = arrangementRecord<AA.Framework.Arrangement.ArrProduct,1>
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
    LOCATE productLine IN ProductLineList<1,1> SETTING POS THEN                                   ;*take only LOANS product line Arrangements
        ArrangementList = customerArrangement<AA.Framework.CustomerArrangement.CusarrArrangement,POS>
        ArrCount = DCOUNT(ArrangementList,@SM)
        FOR Count=1 TO ArrCount
            ArrangementID = customerArrangement<AA.Framework.CustomerArrangement.CusarrArrangement,POS,Count>
            returnIds<-1> = ArrangementID
        NEXT Count
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

calculateTotalAccountBalances:
*----------------------------------------
*** <desc>Calculate Total Account Balances</desc>

    localCurrency = accountRecord<AC.AccountOpening.Account.Currency>          ;* Get the account currency
    baseCurrency   = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCurrency) ;* To get the Logged in company currency from R.COMPANY common Variable.
    AC.BalanceUpdates.AccountserviceGetonlineactualbalance(accountId, onlineActualBalance, ErrActBal) ;*Get online actual balance
   
    localAmount   = onlineActualBalance
    IF baseCurrency NE localCurrency THEN
        convertedAmount = ""
        ST.ExchangeRate.Exchrate('1',localCurrency,localAmount,baseCurrency,convertedAmount,'','','','','')  ;* Get the exchange rate value
        finalAmount = convertedAmount
    END ELSE
        finalAmount = localAmount
    END
    
    totalLoanBalances = finalAmount + totalLoanBalances
*
RETURN

END
