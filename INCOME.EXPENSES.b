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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE TO VALIDATE VERSION EB.MORTGAGE.FORM1,INC.EXP

    $PACKAGE OP.ModelBank
    SUBROUTINE INCOME.EXPENSES

    $USING OP.ModelBank
    $USING EB.SystemTables
    
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

INITIALISE:

    Y.INCOME = ''
    Y.EXPENSE = ''

    RETURN
PROCESS:

*ADDING ALL TYPES OF INCOMES
    Y.INC.COUNT = DCOUNT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeType),@VM)   ;*COUNTING NUMBER OF INCOMES GIVEN
    FOR Y.ICOUNT = 1 TO Y.INC.COUNT
        Y.INCOME = Y.INCOME+(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeAmount)<1,Y.ICOUNT>*12/EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeFqy)<1,Y.ICOUNT>)       ;*ADDING ALL INCOMES
    NEXT Y.ICOUNT
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeTotal, Y.INCOME)

*ADDING ALL TYPES OF EXPENSES
    Y.EXP.COUNT = DCOUNT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrExpenseType),@VM)  ;*COUNTING NUMBER OF EXPENSES GIVEN
    FOR Y.ECOUNT = 1 TO Y.EXP.COUNT
        Y.EXPENSE = Y.EXPENSE+(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrExpenseAmount)<1,Y.ECOUNT>*12/EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrExpenseFqy)<1,Y.ECOUNT>)   ;* ADDING ALL EXPENSES
    NEXT Y.ECOUNT
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrExpenseTotal, Y.EXPENSE)

*CALCULATING THE NET AMOUNT

    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNetIncome, EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeTotal)-EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrExpenseTotal))

    RETURN          ;*TO MAIN

    END
