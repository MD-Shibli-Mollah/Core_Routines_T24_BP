* @ValidationCode : MjotMTI5NjM5ODAwMjpDcDEyNTI6MTU0MzkzMjkwNzgzMTpic2F1cmF2a3VtYXI6NjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MjEtMTEzMDoxMDI6OTU=
* @ValidationInfo : Timestamp         : 04 Dec 2018 19:45:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 95/102 (93.1%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180921-1130
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-46</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
 
SUBROUTINE E.MB.AVAIL.LMT.UPD
*-----------------------------------------------------------------------------
* PURPOSE     : Routine to display Available Limit in ACCOUNT.DETAILS.SCV Enquiry
* AUTHOR      : Abinanthan K B
* CREATED ON  : 08/12/2010
*
*---------------------------------------------------------------------------------------
* Modification History:
* ---------------------
*
* 14/04/14 - Task: 971296
*            Defect: 954738
*            Overdraft limit not reflected (and accruately) on Financial Summary
*
* 28/04/15 - Task   : 1330986
*            Defect : 1309350
*            'Available Overdraft' balance is not reflected of an Account
*            if there are not txns on the Account
*
* 05/05/15 - Defect 1299638 / Task 1336345
*            Code changes has been done such that to check for the available marker in
*            the limit record, the AVAILABLE flag is set and passed to GET.ACCOUNT.LIMIT.AMTS
*
* 22/12/15 - Defect 1537426 / Task 1544029
*            Available overdraft amount is displayed wrongly on the AR overview screen.
*            Code changes has been done to format amount based on decimals specified in
*            corresponding currency table by calling EB.ROUND.AMOUNT
*
* 15/09/17   EN 2228630 / Task 2272554
*            Facilitate new limit key with LIMIT.CHECK
*            pass new format key if exists
*
* 16/04/18 - Task 2552637
*            Support Secondary Limit & Conditionally return actual limit availability.
*
* 14/08/18 - Defect 2686806 / Task 2721738
*            If the account being queried upon has no limit configuration then
*            O.DATA is set as "NOLIMIT".
*
* 24/10/18 - Enhancement 2794332 / Task 2794449
*            Limit checks are not done if limit reference is NOSTRO
*
* 05/12/18 - Defect 2880756 / Task 2887344
*            Merge balances for HVT accounts and write it in cache to fetch correct working balances if notional
*            merge has not happened at time enquiry is executed
*---------------------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING EB.Reports
    $USING LI.LimitTransaction
    $INSERT I_CustomerService_Parent
    $USING EB.API
    $USING AC.API
    $USING AC.CashFlow
    $USING EB.SystemTables
    $USING AC.HighVolume

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

PROCESS:

    IF NOT(EB.Reports.getOData()) THEN
        GOSUB GET.ACCT.ID
    END ELSE
        IN.ODATA = EB.Reports.getOData()
        ACCT.ID = IN.ODATA['~',1,1]
        SUPRESS.NEG.LIMIT.AVAIL = IN.ODATA['~',2,1]
    END

    R.ACCOUNT = '' ; ERR.ACCOUNT = ''
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.ID, ERR.ACCOUNT)
    AC.HighVolume.CheckHvt(ACCT.ID, R.ACCOUNT, '', '', HVT.PROCESS, '', '', ERR)
    IF HVT.PROCESS EQ "YES" THEN
        GOSUB CLEAR.CACHE         ;* Clear R.EB.CONTRACT.BALANCES on entry
        RESPONSE = ''
        AC.HighVolume.HvtMergeECB(ACCT.ID, RESPONSE)
        IF RESPONSE EQ 1 THEN
            CACHE.LOADED = 1
        END
    END
    LIMIT.REF = R.ACCOUNT<AC.AccountOpening.Account.LimitRef>
    LIMIT.KEY = R.ACCOUNT<AC.AccountOpening.Account.LimitKey>
    IF LIMIT.KEY[1,2] EQ "LI" THEN
        LIMIT.REF = LIMIT.KEY
    END
    IF LIMIT.REF AND LIMIT.REF NE "NOSTRO" THEN
        LIAB.NO = ""
        CUST.NO = R.ACCOUNT<AC.AccountOpening.Account.Customer>
        CCY = R.ACCOUNT<AC.AccountOpening.Account.Currency>

        customerKey = CUST.NO
        customerParent = ''
        CALL CustomerService.getParent(customerKey,customerParent)
        LIAB.NO = customerParent<Parent.customerLiability>

        ALLOCATED = ''
        AVAILABLE = ''
        IF LIAB.NO EQ '' THEN
            LIAB.NO.CHK = 1
        END

* To check for the available marker in the limit record, the available flag is set and passed to GET.ACCOUNT.LIMIT.AMTS
        AVAILABLE = 1
        LI.LimitTransaction.GetAccountLimitAmts(LIAB.NO, CUST.NO, LIMIT.REF, CCY, ALLOCATED, AVAILABLE)

* Check for secondary limit
        GOSUB GET.SECONDARY.LIMIT
 
* Find the least available between secondary and primary limit
        IF SEC.LIMIT.AVAILABLE NE '' AND SEC.LIMIT.AVAILABLE LT AVAILABLE THEN
            AVAILABLE = SEC.LIMIT.AVAILABLE
        END
    
        GOSUB FORMAT.RETURN.INFO

    END ELSE
* Check for secondary limit
        AVAILABLE = ''
        LIAB.NO.CHK = 1
        GOSUB GET.SECONDARY.LIMIT
        IF SEC.LIMIT.AVAILABLE NE '' THEN
            AVAILABLE = SEC.LIMIT.AVAILABLE
        END
        GOSUB FORMAT.RETURN.INFO
    END
    
    IF CACHE.LOADED THEN
        GOSUB CLEAR.CACHE         ;* Clear R.EB.CONTRACT.BALANCES on exit
    END

RETURN
*-----------------------------------------------------------------------------
OPEN.FILES:

    LIMIT.REF.CHK = ''
    AVAILABLE.CHK = ''
    LIAB.NO.CHK = ''
    SUPRESS.NEG.LIMIT.AVAIL = ''
    DIM R.DIM.ACCOUNT(EB.SystemTables.SysDim)

    SEC.LIMIT.APPLICABLE = @FALSE
    SEC.LIMIT.AMOUNT = ''
    SEC.LIMIT.AVAILABLE = ''
    
    HVT.PROCESS = ''
    CACHE.LOADED = 0        ;* Flag to indicate if ECB is updated in cache
        
RETURN
*-----------------------------------------------------------------------------
GET.ACCT.ID:

    LOCATE "@ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ACCT.POS THEN
        ACCT.ID = EB.Reports.getEnqSelection()<4,ACCT.POS>
    END

RETURN
*-----------------------------------------------------------------------------
GET.SECONDARY.LIMIT:
*-------------------
* Check for existance of Seconday Limit for the requested account & if applicable check availability based on secondary limit
    AC.API.GetSecondaryLimit(ACCT.ID, R.ACCOUNT, '', SEC.LIMIT.APPLICABLE, SEC.LIMIT.AMOUNT, ERR)

* If secondary limit is applicable, check get the secondary limit available but subtracting account balance from secondary limit.
    IF SEC.LIMIT.APPLICABLE THEN
        ACCOUNT.BAL = ''
        MAT R.DIM.ACCOUNT = ''
        MATPARSE R.DIM.ACCOUNT FROM R.ACCOUNT
        AC.CashFlow.GetWorkingAvailBal('', ACCT.ID, MAT R.DIM.ACCOUNT, '', ACCOUNT.BAL, '')
        SEC.LIMIT.AVAILABLE = SEC.LIMIT.AMOUNT + ACCOUNT.BAL
    END

RETURN
*-----------------------------------------------------------------------------
FORMAT.RETURN.INFO:
*------------------
* Format the available amount before returning the same in O.DATA

    IF AVAILABLE EQ '' THEN
        AVAILABLE.CHK = 1
    END
    
    IF AVAILABLE LE 0 AND NOT(SUPRESS.NEG.LIMIT.AVAIL) THEN
        AVAILABLE = 0
    END
    
    IF AVAILABLE.CHK AND LIAB.NO.CHK THEN
        EB.Reports.setOData('NOLIMIT')
    END ELSE
        EB.API.RoundAmount(CCY,AVAILABLE,'','') ;* Formatting is done based on decimals specified in Currency table.
        EB.Reports.setOData(AVAILABLE)
    END
    
RETURN
*-----------------------------------------------------------------------------
CLEAR.CACHE:
*-----------

    ACTION = "Delete"
    R.EB.CONTRACT.BALANCES = ''
    RESPONSE = ''   ;* can be returned as RECORD NOT FOUND, INVALID ID, INVALID ACTION CODE, etc
    AC.API.EbCacheContractBalances(ACCT.ID, ACTION, R.EB.CONTRACT.BALANCES, RESPONSE)

RETURN
*-----------------------------------------------------------------------------
END
