* @ValidationCode : MjoxOTM2OTYwMDYyOmNwMTI1MjoxNjA5OTI3MTg3MzI3Om1zc2hydXRoaTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6Njg6Njg=
* @ValidationInfo : Timestamp         : 06 Jan 2021 15:29:47
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : msshruthi
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 68/68 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PZ.ModelBank
SUBROUTINE PZ.GET.AVAILABLE.ACCOUNTS(customerId,accountsList,reserved1,reserved2)
*-----------------------------------------------------------------------------
* Routine to return all the available accounts of the given customer
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/04/19 - Enhancement 2998883 / Task 2998884
*            Routine to get all available accounts for the given customer
*
* 30/08/19 - Task 3312891
*            Account Ids with category mentioned in AVAIL.CATEG should be returned.
*
* 16/12/20 - SI 4049761 / Task 4146711
*            Company reference attached to accounts and PSD2 eligibility check are removed
*  
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING PZ.Config
    $USING AC.AccountOpening
    $USING IN.IbanAPI
    $USING AC.BalanceUpdates
    $USING EB.DataAccess
    $USING EB.Reports
    $USING ST.Customer
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB Initialise ;* Initialise variables and product installation checks
    GOSUB GetAccountIds ;* get account Ids from all companies
    GOSUB GetJointAndAaAccounts ;* get joint and AA account Ids
    accountsList = accountIds

RETURN
*-----------------------------------------------------------------------------
Initialise:

    accountsList = ""
    accountIds = ""

    isAcInstalled = 0
    isAaInstalled = 0

* product installed
    EB.API.ProductIsInCompany('AC', isAcInstalled)
    EB.API.ProductIsInCompany('AA', isAaInstalled)

RETURN
*-----------------------------------------------------------------------------
GetAccountIds:

    GOSUB GetCompanyMnemonics ;*to fetch all financial companies
    compPos = 0
    LOOP
        REMOVE compMne FROM compMneList SETTING mnePos
    WHILE compMne:mnePos ;*read account with each company mnemonic fetched
        fnCustomerAccount = "F":compMne:".CUSTOMER.ACCOUNT"
        fCustomerAccount = ""
        rCustomerAccount = ""
        EB.DataAccess.Opf(fnCustomerAccount, fCustomerAccount)
        EB.DataAccess.FRead(fnCustomerAccount, customerId, rCustomerAccount, fCustomerAccount, "")
        tempAccountIds = ""
        compPos = compPos+1
        IF rCustomerAccount THEN ;*If the account exists, add it to a list
            tempAccountIds<-1> = rCustomerAccount
        END
        CHANGE @VM TO @FM IN tempAccountIds
        accountIds<-1> = tempAccountIds
    REPEAT
    
RETURN
*-----------------------------------------------------------------------------
GetJointAndAaAccounts:

    IF isAcInstalled THEN
        aaOrJointFlag = "JOINT"
        accountList = ""
        PZ.Config.GetJointHolderAaAccounts(customerId, aaOrJointFlag, accountList, "") ;*to get joint accounts
        IF accountList THEN ;*list of account/company is returned
            accountIds<-1> = accountList
        END
    END

    IF isAaInstalled THEN
        aaOrJointFlag = "AA"
        accountList = ""
        PZ.Config.GetJointHolderAaAccounts(customerId, aaOrJointFlag, accountList, "") ;*get all AA accounts for the customer
        LOOP
            REMOVE accId FROM accountList SETTING accPos
        WHILE accId:accPos ;*check if the account is not already present in the list
            LOCATE accId IN accountIds<1> SETTING existAccPos ELSE
                accountIds<-1> = accId ;*add AA accounts to the list
            END
        REPEAT
    END
    
RETURN
*-----------------------------------------------------------------------------
GetCompanyMnemonics:

    compChkCusRec = ST.CompanyCreation.CompanyCheck.CacheRead("CUSTOMER", "")
    compChkFinRec = ST.CompanyCreation.CompanyCheck.CacheRead("FIN.FILE", "")
    cusComPos = ""
    LOCATE EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany) IN compChkCusRec<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING comPos THEN
        usingCompList = compChkCusRec<ST.CompanyCreation.CompanyCheck.EbCocUsingCom,comPos>
        usingCompList<1,1,-1> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
        usingCompTotCnt = DCOUNT(usingCompList,@SM)
        FOR usingCompCnt = 1 TO usingCompTotCnt
            finComPos = ""
            LOCATE usingCompList<1,1,usingCompCnt> IN compChkFinRec<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING finComPos THEN
                compMneList<-1> = compChkFinRec<ST.CompanyCreation.CompanyCheck.EbCocCompanyMne,finComPos>
                compList<-1> = compChkFinRec<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,finComPos>
            END
        NEXT usingCompCnt
    END
    
RETURN
*-----------------------------------------------------------------------------
END
