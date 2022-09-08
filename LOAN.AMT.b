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
*SUBROUTINE FOR VALIDATION OF LOAN AMOUNT IN EB.MORTGAGE.FORM1,PR.ELIGIBILITY

    $PACKAGE OP.ModelBank
    SUBROUTINE LOAN.AMT

    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN


INITIALISE:
    LOAN.TYPE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanType)
    MIN.PROD.AMT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMinProdAmt)
    MAX.PROD.AMT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaxProdAmt)
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanAmount, EB.SystemTables.getComi())
    RETURN
PROCESS:
    IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanAmount) THEN
        LOAN.AMOUNT = EB.SystemTables.getComi()
        MIN.PROD.AMT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMinProdAmt)
        MAX.PROD.AMT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaxProdAmt)
        IF (LOAN.AMOUNT LT MIN.PROD.AMT) OR (LOAN.AMOUNT GT MAX.PROD.AMT) THEN  ;*Validating the loan amount so that it is in between the range
            EB.SystemTables.setEtext('LOAN AMOUNT NOT WITHIN THE PRODUCTS PERMISSABLE RANGE')
        END
    END
    RETURN
    END
 
