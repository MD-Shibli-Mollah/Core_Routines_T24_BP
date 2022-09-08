* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE CHECK.FT.ACCT.OWNER
*------------------------------------------------------------------------------
* Modification History
*
* 13/07/15 - Enhancement 1326996 / Task 1399903
*			  Incorporation of AI component	
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING FT.Contract


    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

PROCESS:

*The customer currently signed in to ARC IB
    Y.CUSTOMER = EB.ErrorProcessing.getExternalCustomer()

*Checking if the Debit Account entered belongs to the Customer
    Y.DEBIT.ACCOUNT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    R.DEBIT.ACCOUNT = AC.AccountOpening.Account.Read(Y.DEBIT.ACCOUNT, READ.ERR.1)
    Y.DEBIT.CUSTOMER = R.DEBIT.ACCOUNT<AC.AccountOpening.Account.Customer>
    IF Y.CUSTOMER = Y.DEBIT.CUSTOMER THEN
        Y.OWN.DEBIT.ACCOUNT = 1
    END

*Checking if the Credit Account entered belongs to the Customer
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, EB.SystemTables.getComi())
    Y.CREDIT.ACCOUNT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    R.CREDIT.ACCOUNT = AC.AccountOpening.Account.Read(Y.CREDIT.ACCOUNT, READ.ERR.2)
    Y.CREDIT.CUSTOMER = R.CREDIT.ACCOUNT<AC.AccountOpening.Account.Customer>
    IF Y.CUSTOMER = Y.CREDIT.CUSTOMER THEN
        Y.OWN.CREDIT.ACCOUNT = 1
    END

*Error messages
    IF Y.OWN.CREDIT.ACCOUNT = 0 AND Y.OWN.DEBIT.ACCOUNT = 1 THEN
        EB.SystemTables.setEtext("Credit Account specified does not belong to the Customer")
        EB.ErrorProcessing.StoreEndError()
    END
    IF Y.OWN.CREDIT.ACCOUNT = 1 AND Y.OWN.DEBIT.ACCOUNT = 0 THEN
        EB.SystemTables.setEtext("Debit Account specified does not belong to the Customer")
        EB.ErrorProcessing.StoreEndError()
    END
    IF Y.OWN.CREDIT.ACCOUNT = 0 AND Y.OWN.DEBIT.ACCOUNT = 0 THEN
        EB.SystemTables.setEtext("Both Debit and Credit Accounts specified do not belong to the Customer")
        EB.ErrorProcessing.StoreEndError()
    END

    RETURN

INITIALISE:
    Y.OWN.DEBIT.ACCOUNT = 0
    Y.OWN.CREDIT.ACCOUNT = 0

    RETURN

    END
