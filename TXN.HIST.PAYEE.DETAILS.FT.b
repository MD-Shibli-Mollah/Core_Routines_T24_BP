* @ValidationCode : MjoxOTYwNjY0Nzk3OkNwMTI1MjoxNjAzMjc0ODk3OTc3OnByYXZpbnZpZ25lc2g6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkyOS0xMjEwOjcyOjcy
* @ValidationInfo : Timestamp         : 21 Oct 2020 15:38:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pravinvignesh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 72/72 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PZ.ModelBank
SUBROUTINE TXN.HIST.PAYEE.DETAILS.FT(ApplicationId, ApplicationRecord, StmtEntryId, StmtEntryRec, OutText)
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* Hook routine attached to STMT.NARR.FORMAT - FT.TXHIS.
* This routine determines the beneficiary details(payee account and payee
* customer)of an underlying FT transaction.
*-----------------------------------------------------------------------------
*
* @uses EB.API
* @uses FT.Contract
* @package PZ.ModelBank
* @class TXN.HIST.PAYEE.DETAILS.FT
* @stereotype subroutine
* @author rdhepikha@temenos.com
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* @param ApplicationId     -    Transaction Reference (FT id)
* @param ApplicationRecord -    Transaction Record (Record of an FT transaction)
* @param StmtEntryId       -    ID of STMT.ENTRY
* @param StmtEntryRec      -    STMT.ENTRY record
*
* Outgoing Arguments:
*
* @param OutText           -    Payee account and payee name seperated by "#"
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*-----------------------------------------------------------------------------
*
* 06/09/17 - Enhancement 2140052 / Task 2261830
*            Hook routine attached to STMT.NARR.FORMAT - FT.TXHIS, to determine
*            the beneficiary details(payee account and payee customer) of
*            an underlying FT transaction.
*
* 22/01/19  Enhancement 2741263 / Task 2978712
*           Changes made to return debit account and debitor name of the underlying FT transaction
*
* 21/10/20 - Defect 4031818 / Task 4036557
*            Changes made in assigning bencustomer value to payeeName
*
*** </region>
*
*-----------------------------------------------------------------------------

*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING EB.API
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING FT.Contract
    $USING AC.EntryCreation
    $USING EB.DataAccess
    

*** </region>

*-----------------------------------------------------------------------------

*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    GOSUB initialise ;* Initialise the required values
    GOSUB process ;* Main process

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initialise the required values </desc>

    rAccount = ""
    errAccount = ""
    AccountId = ""
    payeeAccount = ""
    payeeName = ""
    accCustomer = ""
    custErr = ""
    OutText = ""
    benAcctNo = ApplicationRecord<FT.Contract.FundsTransfer.BenAcctNo>
    benIban = ApplicationRecord<FT.Contract.FundsTransfer.IbanBen>
    benName = ApplicationRecord<FT.Contract.FundsTransfer.BenName>
    benCustomer = ApplicationRecord<FT.Contract.FundsTransfer.BenCustomer,1>
    benBank = ApplicationRecord<FT.Contract.FundsTransfer.BenBank>

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> Main process </desc>
    AccountId = ApplicationRecord<FT.Contract.FundsTransfer.DebitAcctNo>
    GOSUB getAccountRecord ;* To read the account record
    GOSUB getDebitDetais
    
    AccountId = ApplicationRecord<FT.Contract.FundsTransfer.CreditAcctNo>
    GOSUB getAccountRecord ;* To read the account record
    GOSUB getPayeeAccount ;* To determine the payee account of an underlying FT transaction
    GOSUB getPayeeName ;* To determine the payee's name of an underlying FT transaction

    OutText = payeeAccount :"#": payeeName :"#": debitAccount :'#': debitName


RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getPayeeAccount>
getPayeeAccount:
*** <desc> To determine the payee account of an underlying FT transaction </desc>

* if the transaction is internal then payee account will be credit account
* if the transaction is external then payee account will be either BEN.ACCT.NO
* or IBAN.BEN based on the presence of values

    BEGIN CASE

        CASE benAcctNo
            payeeAccount = benAcctNo

        CASE benIban
            payeeAccount = benIban

        CASE AccountId
            payeeAccount = AccountId

    END CASE

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getPayeeName>
getPayeeName:
*** <desc> To determine the payee's name of an underlying FT transaction </desc>

* if the transaction is internal then payee's name will be the customer name
* (name of the customer to whom amount is credited)
* if the transaction is external then payee account will be either BEN.NAME
* or BEN.CUSTOMER based on the presence

    BEGIN CASE

        CASE benName
            payeeName = benName

        CASE benCustomer
            IF benCustomer[1,3] EQ 'SW-' THEN
                payeeName = benCustomer[4,99] ;* BEN.CUSTOMER will have "SW-" prefixed to it, prefix must not be returned
            END ELSE
                payeeName = benCustomer ;* BEN.CUSTOMER with no prefix 'SW-'
            END

        CASE benBank
            payeeName = benBank
            
        CASE 1 ;* determine the customer name by reading the customer record
            GOSUB getAccountRecord
            accCustomer = rAccount<AC.AccountOpening.Account.Customer>
            CALL CustomerService.getRecord(accCustomer, rCustomer)
            payeeName = rCustomer<ST.Customer.Customer.EbCusNameOne>

    END CASE

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getAccountRecord>
getAccountRecord:
*** <desc> To read the account record </desc>

* API called to get the account reference
    rAccount = ""
    errAccount = ""
    rAccount = AC.AccountOpening.Account.Read(AccountId,errAccount)  ;* Get the account record
    
    IF NOT(rAccount) THEN
        F.ACCOUNT$HIS = ''
        rAccount = ''
        errAccount = ''
        EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
        EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS,AccountId,rAccount, errAccount)
        AccountId = FIELD(AccountId ,';' ,1)
    END

RETURN
*** </region>
getDebitDetais:

    debitAccount = AccountId

    IF rAccount THEN;* determine the customer name by reading the customer record
        accCustomer = rAccount<AC.AccountOpening.Account.Customer>
        CALL CustomerService.getRecord(accCustomer, rCustomer)
        debitName = rCustomer<ST.Customer.Customer.EbCusNameOne>
    END

RETURN


END

