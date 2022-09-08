* @ValidationCode : MjotNjE1MDMwNjU0OkNwMTI1MjoxNjE1Mjk3ODk1NDIxOnN2YW1zaWtyaXNobmE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjIzMDoyMDc=
* @ValidationInfo : Timestamp         : 09 Mar 2021 19:21:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 207/230 (90.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE T2.GET.EXTERNAL.ACCOUNTS(selectionArray,customerArrangement,configArray,returnArray,totalExtAccountBalances)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To list the external accounts of the external user
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
* Modification History:
*---------------------
*
* 18/03/19  - Enhancement - 2867757 / Task 3039079
*               Fetch the details of external accounts for TCIB
*
* 09/04/19  - Defect - 3051760 / Task 3077077
*             Warning in T2_ModelBank in 201904 TAFC Primary Compilation
*
* 06/04/20 - Enhancement 342896 / Task 3680076
*            US Saas Integration - Adding customerReference id in holdings
*
* 09/03/2021 - En 4020994 / task 4274225
*              Changing ST.OpenBanking to RT.OpenBanking
*
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
    $USING EB.API
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING RT.OpenBanking
    $USING ST.Customer
    $USING PA.Consent
    $USING PA.Contract    
    
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
    fnAaProduct = 'F.AA.PRODUCT'
    fAaProduct = ''
    EB.DataAccess.Opf(fnAaProduct, fAaProduct)

    fnAaProductGroup = 'F.AA.PRODUCT.GROUP'
    fAaProductGroup = ''
    EB.DataAccess.Opf(fnAaProductGroup, fAaProductGroup)
    
    fnAaProductLine = 'F.AA.PRODUCT.LINE'
    fAaProductLine = ''
    EB.DataAccess.Opf(fnAaProductLine, fAaProductLine)

    fnPaConnectionTracker = 'F.PA.CONNECTION.TRACKER'
    fPaConnectionTracker = ''
    EB.DataAccess.Opf(fnPaConnectionTracker,fPaConnectionTracker)

    fnOpenBankingDir = 'F.PZ.OPEN.BANKING.DIR'
    fOpenBankingDir = ''
    EB.DataAccess.Opf(fnOpenBankingDir, fOpenBankingDir)
    
    fnCustomer = 'F.CUSTOMER'
    fCustomer = ''
    EB.DataAccess.Opf(fnCustomer,fCustomer)
    
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
    customerRec = ST.Customer.Customer.Read(selCustomerId, cusError)
    ProductLineList = customerArrangement<AA.Framework.CustomerArrangement.CusarrProductLine>
    productLine = 'XEXTERNAL.ACCOUNTS'

    productLineId = '';  arrangementId = ''  ;  productGroupId = ''  ;  accountId = ''      ;  productDescription = '' ;  currency = ''   ; sortCode = '';
    accountIBAN = ''  ;  workingBalance = '' ;  preferredProduct = '';  preferredLabel = '' ;  preferredPosition = ''  ;  productId = ''  ; coCode = '';
    productArray = '' ;  productSel = ''     ;  accountIdSel = ''    ;  loanIdSel = ''      ;  depositIdSel = ''       ;  customerId = '' ;
    productGroupName = ''  ;  productLineName = ''  ; outstandingAmount = ''; paidOutAmount = ''; onlineActualBalance = '';depositsBalance = '';loansBalance = '';
*
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Get external accounts details for process by reading connection records</desc>
Process:
*------
* Get the active connection records for the customer to fetch the external account details

    connectionList = PA.Contract.dasActiveCustomerConnections    ;* Assigning Input for the DAS call to find the active customer connections
    THE.ARGS = selCustomerId:@FM:"'ACTIVE' 'RECONNECTING' 'REFRESHING'":@FM:'INITIALLOAD':@FM:"'ACCOUNTLISTRECEIVED' 'POSTINGREADY'" ;* Assigning Input Parameter for the DAS to find the active customer connections
    
    EB.DataAccess.Das('PA.CONNECTION.TRACKER',connectionList,THE.ARGS,'') ;* DAS call to find the connection tracker records

    LOOP
        REMOVE connectionId FROM connectionList SETTING connectionPos
    WHILE connectionId:connectionPos
        connectionRec = ''; connectionStatus = ''; extConnectionSubStatuses =''; nextRefreshAt = ''; extAccountList = ''; extBankCode = '';
        extAccountStatusList = ''; companyName = ''; extAccoutTxnsUpdatedList =''; extAccountBalsUpdatedList = '';extBankId = ''; extBankUrn = ''
        connectionRec =  PA.Contract.PAConnectionTracker.Read(connectionId, Error)
        connectionStatus = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerConnectionStatus>
        connectionSubStatus = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerSubStatus>
        nextRefreshAt = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerNextRefAvail>
        extAccountList = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerArrId>
        extAccountStatusList = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerObcpStatus>
        companyName = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerBankName>
        extAccoutTxnsUpdatedList = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerTxnsLastUpdated>
        extAccountBalsUpdatedList = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerBalLastUpdated>
        extBankId = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerBankId>
        extBankCode = connectionRec<PA.Contract.PAConnectionTracker.ConnTrackerBankCode>
        extBankUrn = extBankId:"-":extBankCode
        GOSUB getBankDetails
        GOSUB getActiveAccounts
        GOSUB getAccountDetails
    REPEAT

    returnArray = productArray
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getBankDetails>
*** <desc>Get Bank details</desc>
getBankDetails:
*-------------
*
    bankLogo = ''; extSrcProvider = ''; paymentTemplates ='';  externCusId = '';
    openBankId = RT.OpenBanking.dasDirectoryByUrn    ;* Assigning Input for the DAS call to find the open banking directory
    OPEN.BANK.ARGS<1> = extBankUrn ;* Assigning Input Parameter for the DAS
    
    EB.DataAccess.Das('PZ.OPEN.BANKING.DIR',openBankId,OPEN.BANK.ARGS,'') ;* DAS call to find the open banking directory id

    openBankRec = RT.OpenBanking.PzOpenBankingDir.Read(openBankId, Error)
    bankLogo = openBankRec<RT.OpenBanking.PzOpenBankingDir.PzOLogoUrl>
    extSrcProvider = openBankRec<RT.OpenBanking.PzOpenBankingDir.PzOExtSrcProvider>
    paymentTemplates = openBankRec<RT.OpenBanking.PzOpenBankingDir.PzOPaymentTemplates>
    cusExternSysId = customerRec<ST.Customer.Customer.EbCusExternSysId>
    LOCATE extSrcProvider IN cusExternSysId<1,-1> SETTING extSysPos THEN
        externCusId = customerRec<ST.Customer.Customer.EbCusExternCusId,extSysPos>
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getActiveAccounts>
*** <desc>Filter active accounts considering the status</desc>
getActiveAccounts:
*-----------------
*
*    LOOP
*        REMOVE extAccountId FROM extAccountList SETTING extAccountPos
*    WHILE extAccountId:extAccountPos
    accountList = ''; companyNameList = ''
    acCnt = DCOUNT(extAccountList,@VM)
    FOR extAccountPos = 1 TO acCnt
        IF extAccountStatusList<1,extAccountPos> EQ 'ACTIVE' THEN
            accountList<-1> = extAccountList<1,extAccountPos>
            accoutTxnsUpdatedList<-1> = extAccoutTxnsUpdatedList<1,extAccountPos>
            accountBalsUpdatedList<-1> = extAccountBalsUpdatedList<1,extAccountPos>
        END
    NEXT extAccountPos
*    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = getAccountDetails>
*** <desc>Get Account details by reading the Account record</desc>
getAccountDetails:
*-----------------
*
*    LOOP
*        REMOVE accountId FROM accountList SETTING accountPos
*    WHILE accountId:accountPos
    extAcCnt = DCOUNT(accountList,@FM)
    FOR accountPos = 1 TO extAcCnt
        accountId = accountList<accountPos>
        IF accountId[1,2] EQ 'AA' THEN
            arrangementId = accountId
            AA.Framework.GetArrangementAccountId(arrangementId, accountId, "", "");* Get account of current arrangement
        END

        productLineId = '';  productGroupId = '';   productDescription = ''; currency = '';           sortCode = '';   coCode = '';
        accountIBAN = '';    workingBalance = ''; preferredProduct = ''; preferredLabel = ''; accountRecord = '';  preferredPosition = '';  productId = '';  arrangementStatus = '';
        RecUserPreferences = '';totalPrincipal = '';
* Set details from connection record for the account
        balanceLastUpdated = accountBalsUpdatedList<accountPos>
        txnsLastUpdated = accoutTxnsUpdatedList<accountPos>
* Fetch account details
        GOSUB readAccount
        GOSUB readAccoutAttributes
        GOSUB readArrangementAndProduct
        IF productLineId NE 'XEXTERNAL.ACCOUNTS' THEN CONTINUE
        
* Fetch account balances
        accountBalances=''
        GOSUB calculateAccountBalances

* Set account details
        IF productArray THEN
            productLineId = ''
        END
        connectionDetails = connectionId:"*":balanceLastUpdated:"*":txnsLastUpdated:"*":bankLogo:"*":extSrcProvider:"*":paymentTemplates:"*":externCusId:"*":connectionStatus:"*":connectionSubStatus:"*":nextRefreshAt:"*":acctSwiftRef:"*":extAccountNumber
        productArray<-1> = productLineId:"*":productLineName:"*":arrangementId:"*":productGroupId:"*":productGroupName:"*":productId:"*":productDescription:"*":accountId:"*":shortTitle:"*":category:"*":coCode:"*":currency
        productArray:="*":sortCode:"*":accountIBAN:"*":workingBalance:"*":openingDate:"*":companyName:"*":preferredProduct:"*":preferredPosition:"*":preferredLabel:"*":permission:"*":onlineActualBalance:"*":availableBalance:"*":availableBalanceLimit
        productArray:="*":outstandingAmount:"*":paidOutAmount:"*":arrangementStatus:"*":totalPrincipal:"*":"*":"*":"*":"*":connectionDetails
        
    NEXT accountPos
*    REPEAT
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
    languageId = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>
    shortTitle    = accountRecord<AC.AccountOpening.Account.ShortTitle,languageId>
    alt.acct.types = accountRecord<AC.AccountOpening.Account.AltAcctType>
    LOCATE 'T24.IBAN' IN alt.acct.types<1,1> SETTING ALT.POS THEN
        accountIBAN = accountRecord<AC.AccountOpening.Account.AltAcctId,ALT.POS>
    END
 
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = readAccoutAttributes>
*** <desc>Read account Supplemetary attributes record</desc>
readAccoutAttributes:
*--------------------
    acctSwiftRef = ''
    AA.Framework.GetArrangementConditions(arrangementId,'XSUPPLEMENTARY.ATTRIBS','',openingDate,'',sAttrPropertyRec,sAttrErr)      ;* Get arrangement condition for supplementary attribute Property class
    SS.RECORD = ''
    APPLICATION.NAME = 'AA.ARR.XSUPPLEMENTARY.ATTRIBS'
    FIELD.NAMES = 'SORT.CODE':@FM:'CLIENT.NAME':@FM:'SWIFT.REF':@FM:'ACCOUNT.NUMBER':@FM:'BALANCE.UPDATED.AT'
    EB.API.GetStandardSelectionDets(APPLICATION.NAME, SS.RECORD) ;* Read the SS record for this property class to read the field data
    FOR FIELD.POS = 1 TO DCOUNT(FIELD.NAMES,@FM)
        FIELD.NAME = FIELD.NAMES<FIELD.POS>
        GOSUB GET.FIELD.NO
        FIELD.DATA<FIELD.POS> = sAttrPropertyRec<1,FIELD.NO>
    NEXT FIELD.POS
    sortCode = FIELD.DATA<1> ;* Set external account sort code
    accountName = FIELD.DATA<2> ;*Set external account client name
    IF shortTitle EQ '' THEN
        shortTitle = accountName
    END
    acctSwiftRef = FIELD.DATA<3> ;* Set external account swift ref
    extAccountNumber = FIELD.DATA<4> ;*Set external account number
    IF balanceLastUpdated EQ '' THEN
        balanceLastUpdated = FIELD.DATA<5> ;* Set balance last updated for the account
    END

*
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------*
* <region name= Get Field Number>
* <desc> Get Field number</desc>
GET.FIELD.NO:
*-----------
    FIELD.NO = ""           ;* Initialise the field number
    EB.API.FieldNamesToNumbers(FIELD.NAME, SS.RECORD, FIELD.NO, "", "", "", "", ERR.MSG)
        
RETURN
* </region>
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
    
    totalExtAccountBalances = finalAmount + totalExtAccountBalances
*-----------------------------------------------------------------------------------------------------------------------
RETURN

END
