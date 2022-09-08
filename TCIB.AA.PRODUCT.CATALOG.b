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
* <Rating>60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T3.ModelBank
    
    SUBROUTINE TCIB.AA.PRODUCT.CATALOG
*-----------------------------------------------------------------------------
* This routine is used to return the list of eligible products for
* the applying customer.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 07/11/14 - Task : 1121937(Enhancement : 1034649)
*            Analyse use of AA in TCIB and discuss alternatives
*
* 14/07/15 - Enhancement 1326996 / Task 1399915
*			 Incorporation of T components
*-----------------------------------------------------------------------------
	$USING AA.ProductManagement
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.CurrencyConfig

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*----------------------------------------------------------------------------
INITIALISE:
*----------------------------------------------------------------------------
* Open required files and initialise the variables

    YR.INPUT = EB.Reports.getOData()
    YR.INPUT.VAR.1 = FIELD(YR.INPUT,'*',1)
    YR.INPUT.VAR.2 = FIELD(YR.INPUT,'*',2)

    YR.OUTPUT = ''

    RETURN

*----------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------
*To retrive the product currency and other details of the product

    YR.AA.PRODUCT.CATALOG.ID = YR.INPUT.VAR.2

    YR.AA.PRODUCT.CATALOG.REC = AA.ProductManagement.ProductCatalog.Read(YR.AA.PRODUCT.CATALOG.ID, YR.ERR.1)
    IF NOT(YR.ERR.1) THEN
        YR.AA.PRODUCT.CATALOG.CURRENCY = YR.AA.PRODUCT.CATALOG.REC<AA.ProductManagement.ProductCatalog.PrdCurrency>
        GOSUB PROCESS.SUB
    END

    EB.Reports.setOData(YR.OUTPUT)

    RETURN

*----------------------------------------------------------------------------
PROCESS.SUB:
*----------------------------------------------------------------------------
* Build an array with the currency and currency description for the selected product 

    BEGIN CASE
    CASE YR.INPUT.VAR.1 = 'VALUE'
        YR.AA.PRODUCT.CATALOG.CURRENCY = CHANGE(YR.AA.PRODUCT.CATALOG.CURRENCY,@VM,'|')
        YR.OUTPUT = YR.AA.PRODUCT.CATALOG.CURRENCY
    CASE YR.INPUT.VAR.1 = 'DESCR'
        YR.AA.PRODUCT.CATALOG.CURRENCY.DCOUNT = DCOUNT(YR.AA.PRODUCT.CATALOG.CURRENCY,@VM)
        FOR YR.V002 = 1 TO YR.AA.PRODUCT.CATALOG.CURRENCY.DCOUNT
            YR.CURRENCY.ID = YR.AA.PRODUCT.CATALOG.CURRENCY<1,YR.V002>
            YR.CURRENCY.REC = ST.CurrencyConfig.Currency.Read(YR.CURRENCY.ID,YR.ERR.2)
            IF NOT(YR.ERR.2) THEN
                YR.CURRENCY.CCY.NAME = YR.CURRENCY.REC<ST.CurrencyConfig.Currency.EbCurCcyName,1>
                IF NOT(YR.OUTPUT) THEN
                    YR.OUTPUT = YR.CURRENCY.CCY.NAME
                END ELSE
                    YR.OUTPUT := '|':YR.CURRENCY.CCY.NAME
                END
            END
        NEXT YR.V002
    CASE 1

    END CASE

    RETURN

END
