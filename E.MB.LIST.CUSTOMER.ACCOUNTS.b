* @ValidationCode : Mjo0NDY2ODMzNjA6Y3AxMjUyOjE1OTk2Nzc0NDM3MDA6c2Fpa3VtYXIubWFra2VuYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MTM3OjEwMw==
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:20:43
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 103/137 (75.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-134</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.LIST.CUSTOMER.ACCOUNTS(AC.LIST)
*-----------------------------------------------------------------------------
* This is the nofile enquiry routine attached to STANDARD.SELECTION record
* NOFILE.CUSTOMER.AC.LIST for the enquiry CUST.ACCT.FULL. This subroutine will
* fetch all accounts that belong to the customer as well as the accounts
* where the customer is the joint holder Read CUSTOMER.ACCOUNT and
* JOINT.CONTRACTS.XREF. One additional functionality is to either show all
* accounts within the set of books or only in the current book based on the
* setting in the enquiry
*------------------------------------------------------------------------------
* Modification History
* 22/10/08 - BG_100019949
*            Routie Standardisation
* 26/10/10 - Task - 102029
*            The enquiry must display only the primary and joint account details related
*            to the customer and not the other contract details, which are present in the
*            concat file JOINT.CONTRACTS.XREF file
* 26/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 16/09/11 - Defect - 270574 /  Task - 278355
*            The records from other companies are listed as per COMP.FOR.ENQ
*            set up in CUST.ACCT.FULL enquiry.
*
* 24/01/13 - Defect 565093 / CI_10076241
*            Locked Amount not calculated properly.
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 31/05/17 - Defect 2101430 / Task 2141827
*            Changes done to get the account balance using EB.READ.HVT routine
*            instead of AccountService.getWorkingBalance
*
* 18/01/2018 - Enhancement 2321342 / Task 2321345
*              Modified to get locked amount details from ECB
*              Modified direct read from account to AC.CashFlow.GetLockedDetails
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*------------------------------------------------------------------------------
*
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING AC.CashFlow
    $USING AC.BalanceUpdates
    $USING BF.ConBalanceUpdates
    $USING AC.HighVolume

    GOSUB INITIALISE
    SAVE.COMPANY = EB.SystemTables.getIdCompany()

    LOOP
        REMOVE COMP.NAME FROM COMP.LIST SETTING POSN
    WHILE COMP.NAME:POSN
        GOSUB CALL.LOAD.COMPANY
        GOSUB OPEN.FILES
        GOSUB PROCESS
    REPEAT

    COMP.NAME = SAVE.COMPANY
    GOSUB CALL.LOAD.COMPANY

RETURN

************************************************************************
CALL.LOAD.COMPANY:
******************
    IF EB.SystemTables.getIdCompany() NE COMP.NAME THEN
        ST.CompanyCreation.LoadCompany(COMP.NAME)
    END
*
RETURN
*
***********
INITIALISE:
***********
*
* Get the Customer Id from the enquiry selection. Return if no Customer Id to process
* If the Customer have some joint accounts, then read JOINT.CONTRACTS,XREF and get the joint accounts for the customer
*
    LOCATE 'MB.CUSTOMER.ID' IN EB.Reports.getDFields()<1> SETTING CUSTOMER.ID.POS THEN
        CUSTOMER.ID=EB.Reports.getDRangeAndValue()<CUSTOMER.ID.POS>
    END ELSE
        EB.SystemTables.setEndError('EB-CUSTOMER.ID.MANDATORY')
    END
    LOCATE 'JOINT.ONLY' IN EB.Reports.getDFields()<1> SETTING JOINT.ONLY.POS THEN
        JOINT.ONLY=EB.Reports.getDRangeAndValue()<JOINT.ONLY.POS>
    END ELSE
        JOINT.ONLY=''
    END
*
    IF EB.SystemTables.getEndError() THEN
        RETURN      ;* END PROGRAM
    END
    COMP.FOR.ENQ  = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqCompForEnq>
    COMP.LIST = ''
    AC.LIST = ''
    PRIME.AC=''

    IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqCompanySelect> THEN
        ALL.COMPANIES=1
    END ELSE
        ALL.COMPANIES=''
    END

    BEGIN CASE
        CASE COMP.FOR.ENQ = 'ALL.COMPANY'
            COMP.CHECK.REC = ''
            COMP.CHECK.REC =  ST.CompanyCreation.tableCompanyCheck("FIN.FILE", Err)
            COMPANY.LIST = COMP.CHECK.REC<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode>
            COMP.LIST = RAISE(COMPANY.LIST)

        CASE COMP.FOR.ENQ = ''
            COMP.LIST = EB.SystemTables.getIdCompany()

        CASE COMP.FOR.ENQ<1,1>[1,1] = '@'   ;*  USER.ROUTINE
            ENQ.ROUTINE = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqCompForEnq,1>[2,99]
            CALL @ENQ.ROUTINE(ENQ.RTN.LIST)
            COMP.LIST = ENQ.RTN.LIST

        CASE 1  ;*  LIST OF ID'S
            COMP.LIST = RAISE(COMP.FOR.ENQ)

    END CASE

RETURN

*****************************************************
OPEN.FILES:
**********

*
    R.JOINT.AC = ST.Customer.tableJointContractsXref(CUSTOMER.ID,JOINT.ERR)
*
RETURN

********
PROCESS:
********
* Check for the primary and joint account
    IF NOT(JOINT.ONLY) THEN
        R.PRIME.AC = AC.AccountOpening.tableCustomerAccount(CUSTOMER.ID,PRIME.ERR)
        IF R.PRIME.AC THEN
            GOSUB CHK.PRIME.ACC
        END
    END
    IF R.JOINT.AC THEN
        GOSUB CHK.JOINT.ACC
    END
RETURN
*
*************
FILL.THE.REC:
*************

* For each of the accounts in the CUSTOMER.ACCOUNT and JOINT.CONTRACTS.XREF, get the accounts details from the ACCOUNT file
    GOSUB GET.BALANCES
    GOSUB GET.AMT.LOCKED.TODAY          ;* Get the amount locked for today
    OUTREC=''
    OUTREC=AC.ID:'*':FILL.VALUE:'*':R.AC.REC<AC.AccountOpening.Account.AccountTitleOne>:'*':R.AC.REC<AC.AccountOpening.Account.Category>:'*':R.AC.REC<AC.AccountOpening.Account.Currency>
    OUTREC:='*':R.AC.REC<AC.AccountOpening.Account.LimitRef>:'*': workingBal:'*':onlineActualBal:'*':onlineClearedBal:'*':AMT.LOCKED
    AC.LIST<-1>=OUTREC
    
RETURN
*************
GET.BALANCES:
*************
*get balances using EB.READ.HVT routine.
    
    accountKey = AC.ID
    workingBal = ''
    onlineClearedBal = ''
    onlineActualBal = ''

    rEbContractBalances = ''
        
    AC.HighVolume.EbReadHvt('EB.CONTRACT.BALANCES',accountKey,rEbContractBalances,'')
        
    workingBal = rEbContractBalances<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>
    onlineClearedBal = rEbContractBalances<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineClearedBal>
    onlineActualBal = rEbContractBalances<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineActualBal>
    

RETURN
**********************
GET.AMT.LOCKED.TODAY:
**********************
* Get the Amount locked for the Account for today date.
*
    AMT.LOCKED = ''
    LOCK.DATES = ''
    LOCK.AMTS = ''
    LAST.LOCK.DATE = ''
    DATE.POS = ''
*---
    LOCKED.DETAILS = ''
    RESPONSE.DETAILS = ''
    AC.CashFlow.GetLockedDetails(AC.ID, LOCKED.DETAILS,RESPONSE.DETAILS)
    IF LOCKED.DETAILS<2> THEN  ;* Do proces only when AC.LOCKED.EVENTS defined for that Account.
        LOCK.DATES = LOCKED.DETAILS<1>       ;* Get the list of days for which lock is defined.
        LOCK.AMTS = LOCKED.DETAILS<2>    ;* Get the list ok amount locked for each date.
        CONVERT @VM TO @FM IN LOCK.DATES
        CONVERT @VM TO @FM IN LOCK.AMTS
*--
        LOCATE EB.SystemTables.getToday() IN LOCK.DATES<1> BY "AR" SETTING DATE.POS THEN   ;* Locate the amount locked on today.
            AMT.LOCKED = LOCK.AMTS<DATE.POS>
        END ELSE
            LAST.LOCK.DATE = LOCK.DATES<DATE.POS-1>         ;* Check whether lock is defined for today before itself.
*-
            IF LAST.LOCK.DATE THEN      ;* If lock exists then get the locked amount from the corresponding position.
                AMT.LOCKED = LOCK.AMTS<DATE.POS-1>
            END
*-
        END
*--
    END
*---
    IF AMT.LOCKED = 0 THEN    ;* When nothing is locked then make it as null so that enquiry will display accordingly.
        AMT.LOCKED = ''
    END

RETURN
*
**************
CHK.PRIME.ACC:
**************
* Check for primary account record.
    LOOP
        AC.ID = ''
        R.AC.REC = ''
        REMOVE AC.ID FROM R.PRIME.AC SETTING POS1
    WHILE AC.ID:POS1
        R.AC.REC = AC.AccountOpening.tableAccount(AC.ID,AC.ERR)
        FILL.VALUE='PRIME'
        IF ALL.COMPANIES THEN
            GOSUB FILL.THE.REC
        END ELSE
            IF R.AC.REC<AC.AccountOpening.Account.CoCode>=EB.SystemTables.getIdCompany() THEN
                GOSUB FILL.THE.REC
            END
        END
    REPEAT
RETURN
**************
CHK.JOINT.ACC:
**************
* Check for joint account records
    LOOP
        AC.ID = ''
        R.AC.REC = ''
        REMOVE AC.ID FROM R.JOINT.AC SETTING POS2
    WHILE AC.ID:POS2
        FILL.VALUE='JOINT'
        R.AC.REC = AC.AccountOpening.tableAccount(AC.ID,AC.ERR)
        IF (ALL.COMPANIES OR (R.AC.REC<AC.AccountOpening.Account.CoCode> EQ EB.SystemTables.getIdCompany())) AND NOT(AC.ERR) THEN
            GOSUB FILL.THE.REC
        END
    REPEAT
RETURN

    
