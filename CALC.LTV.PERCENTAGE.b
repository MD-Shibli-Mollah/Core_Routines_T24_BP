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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE CALC.LTV.PERCENTAGE
* Validation subroutine attached in the version EB.MORTGAGE.FORM1,PR.ELIGIBILITY for the field CALC.LTV
* 04-03-16 - 1653120
*            Incorporation of components

    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB CALCULATE
    RETURN
INITIALISE:
    INPUT.MODE = "NOINPUT"
    LOAN.TYPE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanType)
    RETURN
CALCULATE:
*** check if loan amount and mortgage value are present and then calculate the LTV percentage
    IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanAmount) AND EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMortgageValue) THEN
        LOAN.AMOUNT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanAmount)
        MORTGAGE.VALUE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMortgageValue)
        LTV.PERCENTAGE = DROUND((LOAN.AMOUNT/MORTGAGE.VALUE)*100 ,2)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLtvValue, LTV.PERCENTAGE); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLtvValue); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLtvValue, tmp)
    END
    RETURN
    END
