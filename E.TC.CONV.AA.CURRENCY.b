* @ValidationCode : MTotMTI2OTg5Mjg2MTpVVEYtODoxNDcwMDYzMTUyMjk5OnJzdWRoYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjA3LjE=
* @ValidationInfo : Timestamp         : 01 Aug 2016 20:22:32
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.Channels
    SUBROUTINE E.TC.CONV.AA.CURRENCY
*-----------------------------------------------------------------------------
* Description:
* This routine is used to return the list of eligible products currency and currency description
* for the applying customer.
*-----------------------------------------------------------------------------
* Subroutine type : CONVERSION
* Attached to     : Enquiry record TC.AA.PRODUCT
* Incoming        : O.DATA(Product)
* Outgoing        : O.DATA(Currency and Currency Description)
*-----------------------------------------------------------------------------
* Modification History :
* 25/05/16 - Enhancement 1694536 / Task 1745225
*            TCIB Componentization- Retail Functional Components
*-----------------------------------------------------------------------------
    $USING AA.ProductManagement
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.CurrencyConfig
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*----------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
* Initialise the required variables
    PRODUCT = EB.Reports.getOData() ;* Get Product value
    PRODUCT.ERR='' ;* Initialise product error
    RESULT.SET = '' ;* Initialise Result array
    CURRENCY.NAME='' ;* Initialise curency name
    CURRENCY.DESC='' ;* Initialise currency desc
    CURRENCY.ID='' ;* Initialise currency Id
    CURRENCY.REC='' ;* Initialise currency record
*
    RETURN
***</region>
*----------------------------------------------------------------------------
*** <region name= Process>
PROCESS:
*To retrieve the product currency and currency description of the product
    AA.PRODUCT.REC = AA.ProductManagement.ProductCatalog.Read(PRODUCT, PRODUCT.ERR) ;* Read and get the product record
    IF NOT(PRODUCT.ERR) THEN
        AA.PRODUCT.CURRENCY = AA.PRODUCT.REC<AA.ProductManagement.ProductCatalog.PrdCurrency> ;* Assign the product currency
        GOSUB PROCESS.CCY.VALUE.DESC
    END
    EB.Reports.setOData(RESULT.SET) ;* Return the product currency and currency description
*
    RETURN
***</region>
*----------------------------------------------------------------------------
*** <region name= Process Currency value and Description>
PROCESS.CCY.VALUE.DESC:
* Build an array with the currency and currency description for the selected product
    AA.PRODUCT.CURRENCY.COUNT = DCOUNT(AA.PRODUCT.CURRENCY,@VM) ;* Count the number of currency item.
    FOR CCY.CNT= 1 TO AA.PRODUCT.CURRENCY.COUNT
        CURRENCY.ID = AA.PRODUCT.CURRENCY<1,CCY.CNT>
        CURRENCY.REC = ST.CurrencyConfig.Currency.Read(CURRENCY.ID,CURRENCY.ERR) ;* Read and get the currency record
        IF NOT(CURRENCY.ERR) THEN
            CURRENCY.NAME = CURRENCY.REC<ST.CurrencyConfig.Currency.EbCurCcyName,1> ;* Assign the currency name
            IF NOT(CURRENCY.DESC) THEN
                CURRENCY.DESC = CURRENCY.NAME
            END ELSE
                CURRENCY.DESC := '|':CURRENCY.NAME ;* Form array for currency description
            END
        END
    NEXT CCY.CNT
    AA.PRODUCT.CURRENCY = CHANGE(AA.PRODUCT.CURRENCY,@VM,'|')
    RESULT.SET=AA.PRODUCT.CURRENCY:'*':CURRENCY.DESC ;* Result array with currency and currency description
*
    RETURN
***</region>
*--------------------------------------------------------------------------------
    END
