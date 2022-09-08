* @ValidationCode : Mjo5NjgxMDI2Njc6Q3AxMjUyOjE1MDgyMzQxMTI5ODE6a2pvaG5zb246MTM6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzEwLjIwMTcwOTE1LTAwMDg6MTI1OjExMw==
* @ValidationInfo : Timestamp         : 17 Oct 2017 10:55:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kjohnson
* @ValidationInfo : Nb tests success  : 13
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 113/125 (90.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.20170915-0008
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.Payments
SUBROUTINE BN.TRANSFER.RULE(AccountList,ProcessingDate,ValueDateDR,ValueDateCR,ErrorCode)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/07/17 - EN 2026316 / Task 2169603
*            Internal Transactions - EN1 New Field
*
* 21/08/17 - Defect 2242056 / Task 2242159
*            Remove the "/BNK" from the pool id returned from AA.GET.POOL.INFO.
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING AA.Account
    $USING EB.Utility
    $USING ST.CompanyCreation
    $USING EB.API

*-----------------------------------------------------------------------------
*
* Subroutine to accept a list of accounts and validate that they all belong to the same
* Balance Netting Pool.  The routine will also validate that all TR accounts involved in a
* Funds Transfer have the same value date when the transaction is processed.
* All the accounts need to have membership of the pool when both the Processing and
* Valuation dates occur.
*
* AccountList    - IN  - List of accounts to be checked
* ProcessingDate - IN  - The date on which the transfer is to be done
* ValueDateDR    - IN  - Value date of the debit
* ValueDateCR    - IN  - Value date of the credit
* ErrorCode      - OUT - Return error message

    GOSUB Initialise
    GOSUB ValidateValueDate
    IF NOT(ErrorCode) THEN
        GOSUB ProcessAccountList
    END
    
    IF ErrorCode NE "" AND AccountId NE "" THEN
        ErrorCode<2> = AccountId
    END
    
RETURN

*** <region name= Initialise>
*** <desc>Initialise variables </desc>
Initialise:
*----------
    AccountId = ""
    ErrorCode = ""
    ValueDate = ValueDateDR
    IF ValueDate = "" THEN
        ValueDate = ProcessingDate
    END
    
    IdCompany = EB.SystemTables.getIdCompany()
    CheckProcessing = ProcessingDate
    IF CheckProcessing = '' THEN
        CheckProcessing = EB.SystemTables.getToday()
    END

    BATCH.MODE = 0
    IF EB.SystemTables.getRunningUnderBatch() AND EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ 'B' THEN
        BATCH.MODE = 1
    END
    
RETURN

*** </region>

*----------------------------------------------------------------

*** <region name= ValidateValueDate>
*** <desc>Validate Value Dates passed in are the same </desc>

ValidateValueDate:
*------------------

    IF ValueDateDR NE ValueDateCR THEN
        ErrorCode = "ST-BN.TRANS.RULE.INVALID.VALUE.DATE"
    END
    
RETURN

*** </region>

*----------------------------------------------------------------

*** <region name= ProcessAccountList>
*** <desc>Processs each account in the list </desc>

ProcessAccountList:
*------------------

    StoreBalancePool = ""
    MaxAccCnt = DCOUNT(AccountList,@FM)
    FOR AcctCnt = 1 TO MaxAccCnt UNTIL ErrorCode NE ""
        AccountId = AccountList<AcctCnt>
        IF AccountId = "" THEN
            CONTINUE
        END
        GOSUB ReadAccount
        IF ErrorCode = '' THEN
            GOSUB CheckBalancePool
        END
        IF ErrorCode = "" THEN
            GOSUB CheckAccountDetails
        END
    NEXT AcctCnt
    
RETURN

*** </region>


*----------------------------------------------------------------

*** <region name= CheckBalancePool>
*** <desc>Check Balance Pool matches </desc>
CheckBalancePool:
*----------------

    CheckDate = ProcessingDate
    
    GOSUB StoreAccountPool
    
* Check the account is still in the same pool for the ValueDate (only if different to
* the ProcessingDate)
  
    IF ErrorCode = "" AND ProcessingDate NE ValueDate THEN
        CheckDate = ValueDate
        GOSUB StoreAccountPool
    END
    
RETURN

StoreAccountPool:
*----------------

    BalancePool    = ""
    AccountStatus = ""
    AA.Account.GetAccountPoolInfo(AccountId,CheckDate,BalancePool,AccountStatus,"","","","")
    BalancePool = FIELD(BalancePool,'/',1)
    BEGIN CASE
        CASE BalancePool = ""
            ErrorCode = "ST-BN.TRANS.RULE.INVALID.POOL"
        CASE AccountStatus = "LIVE"
            IF StoreBalancePool = "" THEN
                StoreBalancePool = BalancePool
            END ELSE
                IF BalancePool NE StoreBalancePool THEN
                    ErrorCode = "ST-BN.TRANS.RULE.INVALID.POOL"
                END
            END
        CASE 1
            ErrorCode = "ST-BN.TRANS.RULE.INVALID.POOL"
    END CASE

RETURN

*** </region>

*----------------------------------------------------------------

*** <region name= ReadAccount>
*** <desc>Read Account </desc>
ReadAccount:
*-----------
    
    AcctReadError = ""
    AccountRec = AC.AccountOpening.Account.Read(AccountId, AcctReadError)
          
RETURN

*** </region>

*----------------------------------------------------------------


*** <region name= CheckAccountDetails>
*** <desc>General Account Check </desc>
CheckAccountDetails:
    
    BEGIN CASE
        CASE AccountRec<AC.AccountOpening.Account.ExternalPosting> = "NO"
            ErrorCode = "AC-INVALID.SUMMARY.ENTRY"
        CASE AccountRec<AC.AccountOpening.Account.AutoPayAcct> = ""
            ErrorCode = "ST-BN.TRANS.RULE.BV.NO.AUTO.PAY"
        CASE 1
            ErrorCode = ""
    END CASE
    
    IF ErrorCode = "" AND AccountRec<AC.AccountOpening.Account.AllowedBvDate> NE "" THEN
        AllowedBvDate = AccountRec<AC.AccountOpening.Account.AllowedBvDate>
        IF AllowedBvDate GT ProcessingDate THEN
            ErrorCode = "ST-BN.TRANS.RULE.BV.PROCESSING.DATE"
        END
    
        IF ErrorCode = ""  AND AllowedBvDate GT ValueDateDR THEN
            ErrorCode = "ST-BN.TRANS.RULE.BV.VALUE.DATE"
        END
    END
    
    IF ErrorCode = '' AND NOT(BATCH.MODE) THEN
        GOSUB CheckProcessingDate ; *Validate the processing date
    END
    
RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= CheckProcessingDate>
CheckProcessingDate:
*** <desc>Validate the processing date </desc>

* No need to check Input company as this has already been validated by calling Applications

    IF AccountRec<AC.AccountOpening.Account.CoCode> # IdCompany THEN
        GOSUB ReadDates ; *Read Account Company Dates record

        IF CheckProcessing < R.AcctCompDate<EB.Utility.Dates.DatToday> THEN
            ErrorCode = "ST-BN.TRANS.BOOKING.LESS.TODAY"
        END
    
        IF ErrorCode = '' THEN
            GOSUB CheckWorkingDay ; *Check if Processing Date is a Working Day in Account Company
        END
    
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ReadDates>
ReadDates:
*** <desc>Read Account Company Dates record </desc>

    RecId = AccountRec<AC.AccountOpening.Account.CoCode>
    R.AcctCompDate = EB.Utility.Dates.CacheRead(RecId, Error)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ReadCompany>
ReadCompany:
*** <desc>Read Account Company record </desc>

    RecId = AccountRec<AC.AccountOpening.Account.CoCode>
    R.AcctCompany = ST.CompanyCreation.Company.CacheRead(RecId, Error)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CheckWorkingDay>
CheckWorkingDay:
*** <desc>Check if Processing Date is a Working Day in Account Company </desc>

    GOSUB ReadCompany ; *Read Account Company record
    REGION = R.AcctCompany<ST.CompanyCreation.Company.EbComLocalCountry>:R.AcctCompany<ST.CompanyCreation.Company.EbComLocalRegion>
    IF LEN(REGION) = 2 THEN
        REGION = REGION:'00'
    END
    PROCESS.DATE = CheckProcessing
    EB.API.Awd (REGION,PROCESS.DATE,DAYTYPE)
    BEGIN CASE
        CASE DAYTYPE = "N"
            ErrorCode = "EB-HOLIDAY.TABLE.MISS"
        CASE DAYTYPE # 'W'
            ErrorCode = "ST-BN.TRANS.NOT.WORKING.DAY"
    END CASE

RETURN
*** </region>

END
