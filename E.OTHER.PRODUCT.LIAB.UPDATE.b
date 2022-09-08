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
* <Rating>-30</Rating>
*
* 25/07/13 - Defect-733413/Task-739337
*            Fatal error in OPF for the core template CR.OTHER.PRODUCTS is thrown
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE E.OTHER.PRODUCT.LIAB.UPDATE

    $USING OP.ModelBank
    $USING CR.Analytical
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:

    LIAB.ID = ''
    LIAB.TYPE = ''
    LIAB.INST = ''
    LIAB.CCY = ''
    LIAB.AMT = ''
    LIAB.START.DATE = ''
    LIAB.END.DATE = ''
    LIAB.FQY = ''
    RETURN

    RETURN

PROCESS:
    FIELD.COUNT = DCOUNT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabId),@VM)
    FOR I = 1 TO FIELD.COUNT
        LIAB.ID = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabId)<1,I>
        R.CR.OTHER.PRODUCTS = CR.Analytical.OtherProducts.Read(LIAB.ID, Y.ERR)
        LIAB.TYPE = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpProductName>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabType); tmp<1,I>=LIAB.TYPE; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabType, tmp)

        LIAB.INST = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpInstitutionDesc>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabInst); tmp<1,I>=LIAB.INST; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabInst, tmp)

        LIAB.CCY = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpCurrency>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabCcy); tmp<1,I>=LIAB.CCY; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabCcy, tmp)

        LIAB.AMT = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpLocalRef,2>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabAmt); tmp<1,I>=LIAB.AMT; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabAmt, tmp)

        LIAB.FQY = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpLocalRef,1>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFqyInMonths); tmp<1,I>=LIAB.FQY; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFqyInMonths, tmp)

        LIAB.START.DATE = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpStartDate>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabStaDate); tmp<1,I>=LIAB.START.DATE; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabStaDate, tmp)

        LIAB.END.DATE = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpEndDate>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabEndDate); tmp<1,I>=LIAB.END.DATE; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabEndDate, tmp)
    NEXT I
    RETURN
    END
