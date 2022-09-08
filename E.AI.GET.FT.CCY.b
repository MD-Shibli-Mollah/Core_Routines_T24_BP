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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE AI.ModelBank
    SUBROUTINE E.AI.GET.FT.CCY
*-----------------------------------------------------------------------------
* Modifications:
* -------------
*
* 13/07/15 - Enhancement 1326996 / Task 1399903
*			  Incorporation of AI component	
*----------------------------------------------------------------------------
   
	$USING AC.AccountOpening
	$USING EB.SystemTables
	$USING FT.Contract
	
    GOSUB INITIALISE
    GOSUB PROCESS

PROCESS:
    Y.DEBIT.ACCOUNT.NUMBER = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    Y.CREDIT.ACCOUNT.NUMBER = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    R.DEBIT.ACCOUNT = AC.AccountOpening.Account.Read(Y.DEBIT.ACCOUNT.NUMBER, READ.ERR1)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitCurrency, R.DEBIT.ACCOUNT<AC.AccountOpening.Account.Currency>)
    R.CREDIT.ACCOUNT = AC.AccountOpening.Account.Read(Y.CREDIT.ACCOUNT.NUMBER, READ.ERR2)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditCurrency, R.CREDIT.ACCOUNT<AC.AccountOpening.Account.Currency>)

   RETURN	

INITIALISE:
  
   RETURN
END
