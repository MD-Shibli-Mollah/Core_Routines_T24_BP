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
    $PACKAGE OP.ModelBank
    SUBROUTINE COLL.ID.UPD

* 04-03-16 - 1653120
*            Incorporation of components

    $USING CO.Contract
    $USING OP.ModelBank
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:
    RETURN

PROCESS:
    Y.COLL.ID = EB.SystemTables.getComi()

    R.COLLATERAL = ''; COLL.ERR = ''
    R.COLLATERAL = CO.Contract.Collateral.Read(Y.COLL.ID, COLL.ERR)
* Before incorporation : CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,COLL.ERR)
    IF COLL.ERR EQ '' THEN
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrColType, R.COLLATERAL<CO.Contract.Collateral.CollCollateralType>)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrColCcy, R.COLLATERAL<CO.Contract.Collateral.CollCurrency>)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrColNomValue, R.COLLATERAL<CO.Contract.Collateral.CollNominalValue>)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrColExeValue, R.COLLATERAL<CO.Contract.Collateral.CollExecutionValue>)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrColValDate, R.COLLATERAL<CO.Contract.Collateral.CollValueDate>)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrColExpDate, R.COLLATERAL<CO.Contract.Collateral.CollExpiryDate>)
    END
    RETURN
