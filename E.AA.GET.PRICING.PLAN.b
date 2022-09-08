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
*-----------------------------------------------------------------------------
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PR.ModelBank
    SUBROUTINE E.AA.GET.PRICING.PLAN(ENQ.DATA)
*-----------------------------------------------------------------------------
* This Nofile routine is used in the enquiry AA.GET.PRICING.PLAN. This enquiry is attached
* to AA.ARRANGEMENT.ACTIVITY,AA.NEW version to get the pricing plan
*
*-----------------------------------------------------------------------------
* Modifications:
*----------------------------------------------------------------------------
*
* 06/01/14 : Task	: 881469
*            Defect : 836911
*            Case statement added for the automatic or pricing.

*----------------------------------------------------------------------------

    $USING AA.ProductManagement
    $USING AA.PricingRules
    $USING AA.ProductFramework
    $USING EB.Reports


    GOSUB INIT
    GOSUB PROCESS
    RETURN

*************************************************************************************
INIT:
*************************************************************************************

    AA.PROD = '' ; PROD.CURR = '' ; AA.PROP = '' ; AA.PROD.COND = '' ; R.PUB = '' ;
    PRICE.PLAN = '' ; OUT.PROPERTY.CLASS.LIST = '' ; OUT.PROPERTY.LIST = '' ;

    LOCATE "PRODUCT" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    AA.PROD = EB.Reports.getEnqSelection()<4,POS>
    END

    AA.ProductFramework.GetPublishedRecord("PRODUCT","",AA.PROD,"",R.PUB,PUB.ERR)
    PROD.CURR = R.PUB<AA.ProductManagement.ProductCatalog.PrdCurrency>
    AA.ProductFramework.GetProductConditionRecords(AA.PROD,PROD.CURR, "", OUT.PROPERTY.LIST, OUT.PROPERTY.CLASS.LIST, OUT.ARRANGEMENT.LINK.TYPE,OUT.PROPERTY.CONDITION.LIST, RET.ERR)

    LOCATE 'PRICING.RULES' IN OUT.PROPERTY.CLASS.LIST<1> SETTING POS THEN
    AA.PROP = OUT.PROPERTY.LIST<POS>
    END

    LOCATE AA.PROP IN R.PUB<AA.ProductManagement.ProductDesigner.PrdProperty,1> SETTING POSS THEN
    AA.PROD.COND = R.PUB<AA.ProductManagement.ProductCatalog.PrdPrdProperty,POSS>
    END
    RETURN

***********************************************************************************
PROCESS:
************************************************************************************

    AA.ProductFramework.GetProductPropertyRecord('PROPERTY','', AA.PROD, AA.PROP, CONDITION.ID, PROD.CURR, START.DATE, DATE.TXN, PRODUCT.PROP.RECORD, VAL.ERROR)
    PRICE.PLAN = PRODUCT.PROP.RECORD<AA.PricingRules.PricingRules.PricePlanSelectMethod>

    BEGIN CASE
        CASE PRICE.PLAN EQ "AUTOMATIC"
            ENQ.DATA = "AUTOMATIC" : @FM : "NO.PRICING"
        CASE PRICE.PLAN EQ "MANUAL"
            ENQ.DATA = "MANUAL" : @FM : "NO.PRICING"
        CASE PRICE.PLAN EQ "NO.PRICING"
            ENQ.DATA = "NO.PRICING"
        CASE PRICE.PLAN EQ "AUTOMATIC.OR.MANUAL"
            ENQ.DATA = "AUTOMATIC" : @FM : "MANUAL" : @FM : "NO.PRICING"
    END CASE

    RETURN
    END
