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
*Subroutine to check LTV values in EB.MORTGAGE.FORM1,PR.ELIGIBILITY

    $PACKAGE OP.ModelBank
    SUBROUTINE LTV.VALUE.CHECK

    $USING OP.ModelBank
    $USING EB.SystemTables

 
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN


INITIALISE:
    LTV.VALUE = ''
    LTV.THRESHOLD = ''
    R.EB.PRODUCT.INFO = ''
    EB.PRODUCT.INFO.ERR = ''
    RETURN
PROCESS:
    LTV.VALUE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLtvValue)
    LOAN.TYPE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanType)
    R.EB.PRODUCT.INFO = OP.ModelBank.EbProductInfo.Read(LOAN.TYPE, EB.PRODUCT.INFO.ERR)         ;*reading record EB.PRODUCT.INFO to get LTV.THRESHOLD
    LTV.THRESHOLD = R.EB.PRODUCT.INFO<OP.ModelBank.EbProductInfo.EbProTwoNinLtv>

    IF LTV.VALUE GT LTV.THRESHOLD THEN  ;*check for the LTV.VALUE
        EB.SystemTables.setEtext('LTV VALUE SHOULD BE LESS THAN THE LTV THRESHOLD')
    END
    RETURN
    END
