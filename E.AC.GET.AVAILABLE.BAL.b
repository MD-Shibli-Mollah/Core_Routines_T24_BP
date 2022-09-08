* @ValidationCode : MjoyMDgxNTc2NjYwOkNwMTI1MjoxNTk4NjAxMzAwNDc3OnByZWV0aGlzOjc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMDo4Njo4MQ==
* @ValidationInfo : Timestamp         : 28 Aug 2020 13:25:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : preethis
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 81/86 (94.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.API
SUBROUTINE E.AC.GET.AVAILABLE.BAL(AcctId,AccountBal,LockedAmt,LimitAmt,AvailBal)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* * 26/02/2020 - Defect 3495589 / Task 3609758
*                New routine introduced to fetch account balance considering
*                locked amounts and limit amounts
*
*   08/05/2020 - Defect 3883067/Task 3894997
*              Consider the least of main limit and secondary limit.
*              If main limit limit is not present, consider the secondary limit.
*
* 26/08/2020 - Defect 3926527 / Task 3936255
*              Retrieve available and limit balances suitably in case of component credit check
*-----------------------------------------------------------------------------
*IN.ARGUMENT:
* AcctId - Account number
*
*OUT.ARGUMENTS:
*
* AccountBal - <1> Open Actual Balance
*            - <2> Open Cleared Balance
*            - <3> Online Actual Balance
*            - <4> Online Cleared Balance
*            - <5> Working Balance
* LockedAmt  - locked amount defined for the account
* LimitAmt   - LimitAmount
* AvailBal   - Account Usable Balance +/- Limit Available,
*              Where Account Usable Balance represents,
*              Account Available Balance as per credit setup applicable including component based credit check +
*              Any Payable or Receivable for the account as per setup applicable +
*              Excluded Balances as applicable to the account based on balance type.
*
* Note: All amounts will be returned in account's currency
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AC.API
    $USING AC.AccountOpening
    $USING AC.CashFlow
    $USING EB.SystemTables
    
    GOSUB INITIALISE
    GOSUB PROCESS
    AvailBal += 0
    
RETURN
*-------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc> Initialise </desc>
INITIALISE:
    exitflag = 0
    IF AcctId EQ '' THEN ;* no account number, return
        exitflag = 1
        RETURN
    END
    
    acctError = ''
    RAccountDyn =  AC.AccountOpening.Account.Read(AcctId, acctError) ;* get account record
    IF acctError THEN    ;* no account record, return
        exitflag = 1
        RETURN
    END
    DIM RAccount(AC.AccountOpening.Account.AuditDateTime)
    MATPARSE RAccount FROM RAccountDyn
    
    AccountBal = ''
    LimitAmt = ''
    AvailBal = ''
             
RETURN
*-------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Get account and limit balances </desc>
PROCESS:
    IF exitflag THEN
        RETURN
    END

    GOSUB GET.ACC.BAL
    
    IF RAccountDyn<AC.AccountOpening.Account.CreditCheck> EQ 'COMPONENT' THEN ;* in case of component credit check
        AvailBal = TotalBal        ;* the limit,locked funds... balances will be included suitably
        LimitAmt = AccountBal<6>   ;* retrieve the limit amount alone
        DEL AccountBal<6>
        RETURN
    END
    
    GOSUB GET.LIMIT.AMT
    GOSUB DETERMINE.TOTAL.BAL
    
RETURN
*-------------------------------------------------------------------------
*** <region name= GET.ACC.BAL>
*** <desc>Get the Account's balance</desc>
GET.ACC.BAL:
    
    BalType = ''              ;* determined based on credit check parameter setup
    BalDate = ''              ;* will be defaulted to TODAY
    AvailWorkBal = ''         ;* holds available/working balance depending on setup
    LockedAmt = ''            ;* locked amounts
    TotalBal = ''             ;* AvailWorkBal - locked amount (account usable balance)
    ErrDetails = ''
    AccountBalances = ''      ;* contains open,online and working balances
    AC.API.AcGetBalWithLock(AcctId, BalType, BalDate, ReservedIn, AvailWorkBal, LockedAmt, TotalBal, AccountBal, ErrDetails)
    LockedAmt += 0

RETURN
*** </region>
*-------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Get the Account number</desc>
GET.LIMIT.AMT:
    LimitRef = RAccountDyn<AC.AccountOpening.Account.LimitRef>
    LimitKey = RAccountDyn<AC.AccountOpening.Account.LimitKey>
    IF LimitKey[1,2] EQ "LI" THEN
        LimitRef = LimitKey
    END
    
    LimitAmt = ''
    IF LimitRef AND LimitRef NE "NOSTRO" THEN ;* if there is no limit linked to the account, no need to fetch limit amounts
        acctError = ''
        AfDate = ''
        LimitExpiry = ''
        LimitAdmExtnDate = ''

* returns limit amount considering ALLOW.NETTING setup
        AC.CashFlow.GetOnlineLimit(AcctId, MAT RAccount, AfDate, LimitAmt, LimitExpiry, LimitAdmExtnDate)
        LimitAmt = LimitAmt<1>               ;* get the calculated limit amount alone

*If expired it should take the worst case scenario, take only a/cs with -ve balance and
*ignore the online.limit and a/cs with credit balance. Here it is taking the limit available if -ve.
        IF LimitExpiry AND LimitExpiry < EB.SystemTables.getToday() AND LimitAmt > 0 THEN
            LimitAmt = 0
        END
    END
    
    LimitAvailBal = TotalBal + LimitAmt  ;* (avail bal - locked amount) + limit amount

    SecLimAvail = ''
    SecLimAmount = ''
    Err = ''
    SecLimAvailBal = ''

* Check for existance of Seconday Limit for the requested account & if applicable check availability based on secondary limit
    AC.API.GetSecondaryLimit(AcctId, RAccountDyn, '', SecLimAvail, SecLimAmount, Err)

* If secondary limit is applicable, check get the secondary limit available
    IF SecLimAvail THEN
        SecLimAvailBal = SecLimAmount + TotalBal
    END
 
RETURN
*** </region>
*-------------------------------------------------------------------------
*** <region name= DETERMINE.TOTAL.BAL>
DETERMINE.TOTAL.BAL:
*** <desc>Get the Account's TOTAL balance</desc>
    BEGIN CASE
        CASE LimitAmt NE '' AND SecLimAvail   ;* both main and secondary limits available, consider the least amount
            IF SecLimAvailBal NE '' AND SecLimAvailBal LT LimitAvailBal THEN
                AvailBal = SecLimAvailBal
                LimitAmt = SecLimAmount
            END ELSE
                AvailBal = LimitAvailBal
            END
        CASE SecLimAvail               ;* only secondary limit avaiable, consider the same
            AvailBal = SecLimAvailBal
            LimitAmt = SecLimAmount
        CASE 1                         ;* only main limit/no limit
            AvailBal = LimitAvailBal
    END CASE

RETURN
*** </region>
*-------------------------------------------------------------------------
END
