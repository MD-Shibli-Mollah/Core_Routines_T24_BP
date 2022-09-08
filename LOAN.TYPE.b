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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE TO VALIDATE VERSION EB.MORTGAGE.FORM1,PR.ELIGIBILITY

    $PACKAGE OP.ModelBank
    SUBROUTINE LOAN.TYPE

    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE 
    GOSUB PROCESS
    RETURN

PROCESS:
    Y.PROD.ID = EB.SystemTables.getComi()
    R.EB.PROD = OP.ModelBank.EbProductInfo.Read(Y.PROD.ID, '')

    Y.MIN.AMT = R.EB.PROD<OP.ModelBank.EbProductInfo.EbProTwoNinMinAmount>
    Y.MAX.AMT = R.EB.PROD<OP.ModelBank.EbProductInfo.EbProTwoNinMaxAmount>
    Y.MIN.TERM = R.EB.PROD<OP.ModelBank.EbProductInfo.EbProTwoNinMinTerm>
    Y.MAX.TERM = R.EB.PROD<OP.ModelBank.EbProductInfo.EbProTwoNinMaxTerm>
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMinProdAmt, Y.MIN.AMT)
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaxProdAmt, Y.MAX.AMT)
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMinProdTerm, Y.MIN.TERM)
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaxProdTerm, Y.MAX.TERM)


    RETURN

INITIALISE:

    Y.PROD.ID=''
    R.EB.PROD = ''
    RETURN
    END
