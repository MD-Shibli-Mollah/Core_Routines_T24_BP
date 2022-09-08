* @ValidationCode : MjoxMjEyNzEzNzY5OmNwMTI1MjoxNjE3MzMyMTA3MDE2OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 02 Apr 2021 08:25:07
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.CustomerIdentification
SUBROUTINE QI.CHECK.ACCOUNT.PREFERENCES(CUSTOMER.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, RESOUT2, RESOUT3)
*-----------------------------------------------------------------------------
* Sample API to check for Address Conflict in Account preferences
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* MESSAGE.GROUP              (IN)    - Message groups to be excluded for Address Conflict check
*
* CARRIER                    (IN)    - Carrier to be checked for Address
*
* TAX.RESIDENCE              (IN)    - Customer's tax residence
*
* US.ADDR.CONFLICT           (OUT)   - YES/NO, US Address Conflict Result
*
* COUNTRY.FIELD.DETS         (IN)    - <1> Field to check for PRINT.1 address
*                                      <2> Field to check for other addresses
*
* RES.OUT2,RES.OUT3          (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/12/20 - SI 3436249 / Task 4104932
*            Sample API to check for Address Conflict in Account preferences
*
* 10/03/21 - Defect 4275520 / Task 4276266
*            Changes done to consider Portfolio level and Other Customer Preferences
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING EB.API
    $USING AA.Framework
    $USING AA.Customer
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING ST.CustomerService
    $USING ST.Customer
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    US.ADDR.CONFLICT = 'NO'
    ARRANGEMENTS = ''
    CUST.ROLES = ''

* Check for AA product installation
    AA.INSTALLED = ''
    IF NOT(AA.INSTALLED) THEN
        EB.API.ProductIsInCompany('AA', AA.INSTALLED)
    END

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    GOSUB GET.FIN.COMP      ;* fetch all FIN companies
    
    TOT.CNT = DCOUNT(COMP.LIST,@FM)
    COMP.CNT = ''
    FOR COMP.CNT = 1 TO TOT.CNT  ;* loop for all FIN companies to read the AA customer arrangement record
        IF AA.INSTALLED THEN
            GOSUB AA.PROCESS
        END
        GOSUB AC.PROCESS
        IF US.ADDR.CONFLICT NE 'NO' THEN
            COMP.CNT = TOT.CNT + 1     ;* terminate the loop
        END
    NEXT COMP.CNT
    
RETURN
*-----------------------------------------------------------------------------
AA.PROCESS:
    
    MNE = COMP.LIST<COMP.CNT>
    FN.AA.CUST.ARRANGEMENT = 'F':MNE:'.AA.CUSTOMER.ARRANGEMENT'
    FV.AA.CUST.ARRANGEMENT = ''
    R.AA.CUST.ARRANGEMENT = ''
    AA.CUS.ERR = ''
    EB.DataAccess.Opf(FN.AA.CUST.ARRANGEMENT, FV.AA.CUST.ARRANGEMENT)
    EB.DataAccess.FRead(FN.AA.CUST.ARRANGEMENT, CUSTOMER.ID, R.AA.CUST.ARRANGEMENT, FV.AA.CUST.ARRANGEMENT, AA.CUS.ERR)  ;* Read AA customer Arrangement record
    IF R.AA.CUST.ARRANGEMENT THEN
        GOSUB PROCESS.ARRANGEMENTS  ;* get the arrangement records if AA Customer Arrangement record is present in that company
    END

RETURN
*-----------------------------------------------------------------------------
PROCESS.ARRANGEMENTS:

* Return if Account arrangements are not found for the customer
    LOCATE 'ACCOUNTS' IN R.AA.CUST.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrProductLine,1> SETTING PROD.POS ELSE
        RETURN
    END
    
    ARRANGEMENTS = RAISE(R.AA.CUST.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrArrangement,PROD.POS>)   ;* get all the Account arrangements for the customer
    CUST.ROLES = RAISE(R.AA.CUST.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrCustomerRole,PROD.POS>)

    TOT.ARR.CNT = DCOUNT(ARRANGEMENTS,@VM)

    FOR ARR.CNT = 1 TO TOT.ARR.CNT
        ARR.ID = ARRANGEMENTS<1,ARR.CNT>
        CUSTOMER.ROLE = CUST.ROLES<1,ARR.CNT>
        BEN.OWNER = ''
        AA.Customer.CheckCustomerBeneficialStatus(CUSTOMER.ROLE, BEN.OWNER, '')
        IF BEN.OWNER THEN   ;* process only when the customer's role is beneficial owner
            GOSUB CHECK.EACH.ARRANGEMENT
        END
        IF US.ADDR.CONFLICT NE 'NO' THEN
            ARR.CNT = TOT.ARR.CNT + 1     ;* terminate the loop
        END
    NEXT ARR.CNT

RETURN
*-----------------------------------------------------------------------------
CHECK.EACH.ARRANGEMENT:
    
    DE.CUST.PREF.ID = ''

* Read the particular arrangement record
    FN.AA.ARRANGEMENT = 'F':MNE:'.AA.ARRANGEMENT'   ;*use the company mnemonic to read the arrangement record
    FV.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMNT = ''
    AA.ERR = ''
    EB.DataAccess.Opf(FN.AA.ARRANGEMENT, FV.AA.ARRANGEMENT)
    EB.DataAccess.FRead(FN.AA.ARRANGEMENT, ARR.ID, R.AA.ARRANGEMNT, FV.AA.ARRANGEMENT, AA.ERR)     ;* read the arrangement record
    
    LOCATE 'ACCOUNT' IN R.AA.ARRANGEMNT<AA.Framework.Arrangement.ArrLinkedAppl,1> SETTING APP.POS THEN
        AC.ID = R.AA.ARRANGEMNT<AA.Framework.Arrangement.ArrLinkedApplId,APP.POS>
        GOSUB READ.ACCOUNT
        DE.CUST.PREF.ID<1> = 'A-':AC.ID    ;* form DCP Id = A-AccountId
        DE.CUST.PREF.ID<2> = R.ACCOUNT<AC.AccountOpening.Account.Customer>      ;* Account customer
        QI.CustomerIdentification.QIPerformCustPrefCheck(DE.CUST.PREF.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')
    END

RETURN
*-----------------------------------------------------------------------------
READ.ACCOUNT:

* Read Account record
    FN.ACCOUNT = 'F':MNE:'.ACCOUNT'
    FV.ACCOUNT = ''
    R.ACCOUNT = ''
    AC.ERR = ''
    EB.DataAccess.Opf(FN.ACCOUNT, FV.ACCOUNT)   ;* do opf before reading
    
    EB.DataAccess.FRead(FN.ACCOUNT, AC.ID, R.ACCOUNT, FV.ACCOUNT, AC.ERR)

RETURN
*-----------------------------------------------------------------------------
AC.PROCESS:
    
    IF US.ADDR.CONFLICT NE 'NO' THEN
        RETURN
    END
    
* Read Customer Account record to get all the accounts of the customer
    MNE = COMP.LIST<COMP.CNT>
    FN.CUSTOMER.ACCOUNT = 'F':MNE:'.CUSTOMER.ACCOUNT'
    FV.CUSTOMER.ACCOUNT = ''
    R.CUSTOMER.ACCOUNT = ''
    CUS.ACC.ERR = ''
    EB.DataAccess.Opf(FN.CUSTOMER.ACCOUNT, FV.CUSTOMER.ACCOUNT)
    EB.DataAccess.FRead(FN.CUSTOMER.ACCOUNT, CUSTOMER.ID, R.CUSTOMER.ACCOUNT, FV.CUSTOMER.ACCOUNT, CUS.ACC.ERR)

    ACCT.IDS = R.CUSTOMER.ACCOUNT<AC.AccountOpening.CustomerAccount.EbCacAccountNumber>
    TOT.ACCT.IDS = DCOUNT(ACCT.IDS,@VM)
    FOR AC = 1 TO TOT.ACCT.IDS
        DE.CUST.PREF.ID = ''
        AC.ID = ACCT.IDS<1,AC>
        GOSUB READ.ACCOUNT
        IF R.ACCOUNT<AC.AccountOpening.Account.ArrangementId> ELSE      ;* Process only for non-AA accounts
            DE.CUST.PREF.ID<1> = 'A-':AC.ID    ;* form DCP Id = A-AccountId
            DE.CUST.PREF.ID<2> = CUSTOMER.ID   ;* main customer will be the account customer
            QI.CustomerIdentification.QIPerformCustPrefCheck(DE.CUST.PREF.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')
        END
        IF US.ADDR.CONFLICT NE 'NO' THEN
            AC = TOT.ACCT.IDS + 1     ;* terminate the loop
        END
    NEXT AC
    
RETURN
*-----------------------------------------------------------------------------
GET.FIN.COMP:
    
    R.COMP.CHK.CUS = ST.CompanyCreation.CompanyCheck.CacheRead("CUSTOMER", "")  ;* Read customer company check record
    R.COMP.CHK.FIN = ST.CompanyCreation.CompanyCheck.CacheRead("FIN.FILE", "")  ;* Read Fin company check record
    
    CUS.COMP.POS = ''
    COMP.LIST = ''
    LOCATE EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany) IN R.COMP.CHK.CUS<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING CUS.COMP.POS THEN
        USING.COMP.LIST = R.COMP.CHK.CUS<ST.CompanyCreation.CompanyCheck.EbCocUsingCom,CUS.COMP.POS>    ;* list of companies that share the customer files
        USING.COMP.LIST<1,1,-1> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
        TOT.CNT = DCOUNT(USING.COMP.LIST,@SM)
        FOR COMP = 1 TO TOT.CNT
            FIN.COMP.POS = ''
            LOCATE USING.COMP.LIST<1,1,COMP> IN R.COMP.CHK.FIN<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING FIN.COMP.POS THEN
                COMP.LIST<-1> = R.COMP.CHK.FIN<ST.CompanyCreation.CompanyCheck.EbCocCompanyMne,FIN.COMP.POS>  ;* list of fin companies
            END
        NEXT COMP
    END
    
RETURN
*-----------------------------------------------------------------------------
END

