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
* <Rating>-43</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.CAL.SOURCE

*
** Routine to return the the AA.SOURCE.CALC.TYPE ID for the current Property/Product
**
** O.DATA should be in the format <PRODUCT>_<DATE>_<PROPERTY>
**
** PRODUCT = the product name on the date which the enquiry results are based on
** DATE = either TODAY for Live/Unauth enquiry or the Simulation End Date
** PROPERTY = the calculated property for which the source calc type is required
*
*-----------------------------------------------------------------------------

*** <region name= Inserts used by the routine>
***

    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB CHECK.REQUIRED.INFO
    IF NOT(RET.ERR) THEN
        GOSUB PROCESS
        EB.Reports.setOData(SOURCE.CALC.TYPE : "*" : SOURCE.BALANCE)
    END

    RETURN

*-----------------------------------------------------------------------------
*
*** <region name= INITIALISE>
*** <desc>Initialise variables here</desc>
INITIALISE:

    RET.ERR = ''
    SOURCE.CALC.TYPE = ''
    SOURCE.BALANCE = ''

    RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.REQUIRED.INFO>
*** <desc>Check if information requiered for processing are available</desc>
CHECK.REQUIRED.INFO:

    PRODUCT.ID = EB.Reports.getOData()["_",1,1]
    ENQUIRY.DATE = EB.Reports.getOData()["_",2,1]
    PROPERTY.ID = EB.Reports.getOData()["_",3,1]

    AA.ProductFramework.GetPropertyClass(PROPERTY.ID, PROPERTY.CLASS.ID)
    IF NOT(PROPERTY.ID) OR NOT(PROPERTY.CLASS.ID MATCHES "CHARGE":@VM:"INTEREST") THEN
        RET.ERR = "INVALID PROPERTY ID - E.AA.GET.SOURCE.CALC.TYPE"
    END

    R.PRODUCT.RECORD = ''
    AA.ProductFramework.GetPublishedRecord('PRODUCT', '', PRODUCT.ID, ENQUIRY.DATE, R.PRODUCT.RECORD, VAL.ERROR)         ;* Get the Published Product definition
    PRODUCT.RECORD = R.PRODUCT.RECORD
    IF NOT(PRODUCT.RECORD) THEN
        RET.ERR = "INVALID PRODUCT RECORD / PRODUCT ID - E.AA.GET.SOURCE.CALC.TYPE"
    END

    RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
*** <desc>Actual Processing logic</desc>

PROCESS:

    LOCATE PROPERTY.ID IN PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdCalcProperty, 1> SETTING CALC.PROP.POS THEN
    SOURCE.CALC.TYPE = PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdSourceType, CALC.PROP.POS>
    SOURCE.BALANCE = PRODUCT.RECORD<AA.ProductManagement.ProductCatalog.PrdSourceBalance, CALC.PROP.POS>
    END ELSE
    RET.ERR = "SOURCE CALC PROPERTY NOT SET - E.AA.GET.SOURCE.CALC.TYPE ":PROPERTY.ID
    END

    RETURN

*** </region>
*-----------------------------------------------------------------------------

    END

