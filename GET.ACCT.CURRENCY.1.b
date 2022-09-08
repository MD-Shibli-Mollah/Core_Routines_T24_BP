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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MO.ModelBank
    SUBROUTINE GET.ACCT.CURRENCY.1

    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING FT.Contract

*GETTING DEBIT CURRENCY TYPE

*    DEBUG
*    Y.ACCOUNT.NUM = R.NEW(FT.DEBIT.ACCT.NO)
    Y.ACCOUNT.NUM = EB.SystemTables.getComi()

    R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(Y.ACCOUNT.NUM, READ.ERR)

    Y.ACCOUNT.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>

    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitCurrency, Y.ACCOUNT.CCY)

    RETURN

    END
