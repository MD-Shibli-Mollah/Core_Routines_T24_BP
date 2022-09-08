* @ValidationCode : MjotMTA0OTEzMzcxMjpJU08tODg1OS0xOjE2MTY0OTE5NzQ1MjM6c291cmF2bW9kYWs6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Mar 2021 15:02:54
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : souravmodak
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.BUILD.TARGET.ARR.PRODUCT(EnqData)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
*
*-----------------------------------------------------------------------------
* @uses I_ENQUIRY.COMMON I_F.AA.ARRANGEMENT
* @package AA.ModelBank
* @stereotype subroutine
* @author rakshara@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*
*   15/03/21 -  Task : 4284958
*               Defect\Enhancement : 4234319
*               Description : Conditions to get the product list from the sub arrangement conditions
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING AA.Framework
    $USING AA.SubArrangementRules
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB Initialise
    GOSUB MainProcess

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*----------

    ArrangementId = ''
    ArrPos = ''
    LOCATE "CONTRACT.REF" IN EnqData<2,1> SETTING ArrPos THEN
        ArrangementId = EnqData<4, ArrPos>
    END
    
    RArrangement = ''
    ProductLine = ''
    AllowedProducts = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

    AA.Framework.GetArrangement(ArrangementId, RArrangement, ArrError)       ;* Arrangement record
    ProductLine = RArrangement<AA.Framework.Arrangement.ArrProductLine>      ;* Arrangement product line

    BEGIN CASE
        CASE ProductLine EQ 'FACILITY'
            ArrangementRef = ArrangementId
            GOSUB GetAllowedProducts  ;* Get list of allowed products
        CASE ProductLine EQ 'LENDING'
            MasterArrangementId = RArrangement<AA.Framework.Arrangement.ArrMasterArrangement>  ;* Get master arrangement id.
            IF MasterArrangementId THEN
                ArrangementRef = MasterArrangementId
                GOSUB GetAllowedProducts  ;* Get list of allowed products
            END
    END CASE

    IF AllowedProducts THEN
        CHANGE @VM TO " " IN AllowedProducts
        CHANGE @SM TO " " IN AllowedProducts
        EnqData<2,-1> = "@ID"
        EnqData<3,-1> = "EQ"
        EnqData<4,-1> = AllowedProducts
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetAllowedProducts>
*** <desc>Get list of allowed products</desc>
GetAllowedProducts:
*------------

    SubArrRulesRecord = ''
    PropertyClass = "SUB.ARRANGEMENT.RULES"
    Property = ''
    AA.Framework.GetArrangementConditions(ArrangementRef, PropertyClass, Property, EffectiveDate, "", SubArrRulesRecord, RecError)
    SubArrRulesRecord = RAISE(SubArrRulesRecord)
    Product = SubArrRulesRecord<AA.SubArrangementRules.SubArrangementRules.SarProduct>
    BEGIN CASE
        CASE Product EQ "ANY"   ;* if the product is any we check for the sub arrangement condition in Deal
            DealSubArrRulesRecord = ''
            PropertyClass = "SUB.ARRANGEMENT.RULES"
            Property = ''
            MasterArrangementId = RArrangement<AA.Framework.Arrangement.ArrMasterArrangement>  ;* Get master arrangement id.
            AA.Framework.GetArrangementConditions(MasterArrangementId, PropertyClass, Property, EffectiveDate, "", DealSubArrRulesRecord, RecError)
            DealSubArrRulesRecord = RAISE(DealSubArrRulesRecord)
            DealProduct = DealSubArrRulesRecord<AA.SubArrangementRules.SubArrangementRules.SarProduct>
            BEGIN CASE
                CASE DealProduct EQ "ANY"   ;* if we again get product as any we keep the allowed list null
                    AllowedProducts = ""
                CASE DealProduct EQ "ALLOWED.LIST"  ;* if we found the options selected as allowed products we get the allowed product
                    AllowedProducts = DealSubArrRulesRecord<AA.SubArrangementRules.SubArrangementRules.SarAllowedProduct>  ;* Update Allowed products from product condition
            END CASE
        CASE Product EQ "ALLOWED.LIST"  ;* if we found the options selected as allowed products we get the allowed product
            AllowedProducts = SubArrRulesRecord<AA.SubArrangementRules.SubArrangementRules.SarAllowedProduct>  ;* Update Allowed products from product condition
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
