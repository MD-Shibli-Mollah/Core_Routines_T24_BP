* @ValidationCode : MjoxOTAyNzk1MzQ3OkNwMTI1MjoxNTQyMzYxMjA1MjczOnN1ZGhhcmFtZXNoOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MjEtMTEzMDo3Njo3Mw==
* @ValidationInfo : Timestamp         : 16 Nov 2018 15:10:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 73/76 (96.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180921-1130
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AB.ModelBank
SUBROUTINE E.AA.GET.AC.STMT.ENT.LIST(AccountId, BundleArrangement, DateFrom, DateTo, BalanceArray)
*-----------------------------------------------------------------------------
*<region name= subroutine Description>
*<desc>To Give the Purpose of the subroutine </desc>
*
* This routine returns the statement entry id's for TR/SA/CS accounts
*
* @package AB.ModelBank
* @class GetAcStmtEntList
* @stereotype subroutine
* @author sudharamesh@temenos.com
*
*</region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
*
*  Input Arguments:
*   AccountId           - Account ID to get Stmt list
*   BundleArrangement   - Bundle Arrangement id not mandatory when account id is passed
*   DateFrom            - Get entries from which date
*   DateTo              - Get entries until which date
*
*  Output Argument:
*   BalanceArray        - Return the statement entry ids
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*
*  03/08/18 -        Task : 2688560
*             Enhancement : 2688557
*             Rountine to return statement entry id list for TR/SA/CS accounts.
*
*  17/08/18 -        Task : 2772062
*             Enhancement : 2688557
*             To fetch the statement entry ids for accounts in other company
*-----------------------------------------------------------------------------
** <region name = inserts>

    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.Account
    $USING AA.BundleHierarchy
    $USING ST.CompanyCreation
    $USING AA.ModelBank
    $USING AA.Framework
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name = MainProcess>

    GOSUB Initialise                ;* To initialise the required variables
    GOSUB Process
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>To initialise the required variables </desc>
Initialise:

    AccountRecord = ""
    REAL.ACCOUNT  = ""
    ALLOW.EXTERNAL.POSTING = ""
    ChildAccounts = ""
    AllowBvDate = ""
    DATE.FROM = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
***
Process:
    
    AA.Account.GetAccountType('', AccountId, AccountRecord, '', '', REAL.ACCOUNT, ALLOW.EXTERNAL.POSTING, '')
    
    BEGIN CASE

        CASE NOT(REAL.ACCOUNT) AND ALLOW.EXTERNAL.POSTING     ;* for TR account
            GOSUB SaveAndRestoreCompany     ;* To save and restore company while fetching stmt ids
                        
        CASE NOT(REAL.ACCOUNT) AND NOT(ALLOW.EXTERNAL.POSTING)     ;* for SA/CS account return the stmt entry id's of child accounts
        
            IF NOT(BundleArrangement) THEN
                BundleArrangement = AccountRecord<AA.Account.Account.AcBundleArrangement>
            END
          
            AA.BundleHierarchy.GetChildAccounts(BundleArrangement, AccountId, ChildAccounts, "", "", "")  ;* get the child accounts
            
            IF ChildAccounts THEN
                TotChildAccounts = DCOUNT(ChildAccounts,@VM)
                FOR ChildAccountCnt = 1 TO TotChildAccounts
                    tempAccount = ChildAccounts<1,ChildAccountCnt>  ;* current account
                    ChildAcc = ""
                    AA.BundleHierarchy.GetChildAccounts(BundleArrangement, tempAccount, ChildAcc, "", "", "")     ;* get child accounts
                    IF ChildAcc THEN
                        ChildAccounts<1,-1> = ChildAcc
                        TotChildAccounts = DCOUNT(ChildAccounts,@VM)
                    END
                NEXT ChildAccountCnt
            END
        
            FOR ChildCnt = 1 TO DCOUNT(ChildAccounts,@VM)
                AccountId = ChildAccounts<1,ChildCnt>
                AccountRecord = ""
                REAL.ACCOUNT = ""
                ALLOW.EXTERNAL.POSTING = ""
                AA.Account.GetAccountType('', AccountId, AccountRecord, '', '', REAL.ACCOUNT, ALLOW.EXTERNAL.POSTING, '')
                GOSUB SaveAndRestoreCompany     ;* To save and restore company while fetching stmt ids
            NEXT ChildCnt

    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetStmtIds>
*** <desc>To get the statement entry id </desc>
GetStmtIds:

    EB.Reports.setDFields("ACCT.ID":@FM:"BOOKING.DATE":@FM:"CO.CODE")
    EB.Reports.setDLogicalOperands(1:@FM:2:@FM:1)
    EB.Reports.setDRangeAndValue(AccountId:@FM:DATE.FROM:@SM:DateTo:@FM:EB.SystemTables.getIdCompany())
    Y.ID.LIST = ''
    AC.ModelBank.EStmtEntList(Y.ID.LIST)
    FOR ENT.I = 1 TO DCOUNT(Y.ID.LIST,@FM)
        ENTRY.ID = Y.ID.LIST<ENT.I>
        IF ENTRY.ID[1,5] NE "DUMMY" THEN
            LOCATE ENTRY.ID IN TEMP.TRANS.REF<1> SETTING TRANS.POS ELSE
                BalanceArray<-1> = ENTRY.ID
                TEMP.TRANS.REF<-1> = ENTRY.ID
            END
        END
    NEXT ENT.I
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Save Company>
*** <desc> </desc>
SaveCompany:

    AccountCompany = AccountRecord<AA.Account.Account.AcCoCode>
    OriginalCompany = EB.SystemTables.getIdCompany()
    
    IF AccountCompany AND AccountCompany NE OriginalCompany THEN   ;* Check if the company mnemonic is same as the signed in company
        ST.CompanyCreation.LoadCompany(AccountCompany)             ;* If both the companies are different, then load the company
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Restore Company>
*** <desc> </desc>
RestoreCompany:

    IF OriginalCompany AND OriginalCompany NE EB.SystemTables.getIdCompany() THEN
        ST.CompanyCreation.LoadCompany(OriginalCompany)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SaveAndRestoreCompany>
SaveAndRestoreCompany:
*** <desc>To save and restore company while fetching stmt ids </desc>

    GOSUB SaveCompany  ;* Load the company details of the incoming data
    AllowBvDate = AccountRecord<AA.Account.Account.AcAllowedBvDate>
    IF DateFrom LT AllowBvDate AND AllowBvDate THEN
        DATE.FROM = AllowBvDate
    END ELSE
        DATE.FROM = DateFrom
    END
    GOSUB GetStmtIds
    GOSUB RestoreCompany  ;* Reload the Original company
    
RETURN
*** </region>
END
