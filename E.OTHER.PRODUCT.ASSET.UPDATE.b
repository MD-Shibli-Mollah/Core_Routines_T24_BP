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
*   25/07/13 -  Defect-733413/Task-739337
*               Fatal error in OPF for the core template CR.OTHER.PRODUCTS is thrown
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE E.OTHER.PRODUCT.ASSET.UPDATE

    $USING OP.ModelBank 
    $USING CR.Analytical
    $USING EB.SystemTables

 
    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:

    ASSET.ID = ''
    ASSET.TYPE = ''
    ASSET.INST = ''
    ASSET.CCY = ''
    ASSET.AMT = ''
    ASSET.START.DATE = ''
    ASSET.END.DATE = ''
    RETURN


PROCESS:

    FIELD.COUNT = DCOUNT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetId),@VM)
    FOR I = 1 TO FIELD.COUNT
        ASSET.ID = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetId)<1,I>
        R.CR.OTHER.PRODUCTS = CR.Analytical.OtherProducts.Read(ASSET.ID, Y.ERR)
        ASSET.TYPE = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpProductName>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetType); tmp<1,I>=ASSET.TYPE; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetType, tmp)

        ASSET.INST = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpInstitutionDesc>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetInst); tmp<1,I>=ASSET.INST; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetInst, tmp)

        ASSET.CCY = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpCurrency>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetCcy); tmp<1,I>=ASSET.CCY; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetCcy, tmp)

        ASSET.AMT = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpBalance>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetAmt); tmp<1,I>=ASSET.AMT; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetAmt, tmp)

        ASSET.START.DATE = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpStartDate>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetStaDate); tmp<1,I>=ASSET.START.DATE; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetStaDate, tmp)

        ASSET.END.DATE = R.CR.OTHER.PRODUCTS<CR.Analytical.OtherProducts.OpEndDate>
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetEndDate); tmp<1,I>=ASSET.END.DATE; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetEndDate, tmp)
    NEXT I
    RETURN
    END
