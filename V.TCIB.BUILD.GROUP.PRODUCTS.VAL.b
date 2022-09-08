* @ValidationCode : MjoxMjIwNDQ5MTkyOkNwMTI1MjoxNDg3MDY2MTg1ODMwOnJzdWRoYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6Mzg6MzA=
* @ValidationInfo : Timestamp         : 14 Feb 2017 15:26:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/38 (78.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE T2.ModelBank
    SUBROUTINE V.TCIB.BUILD.GROUP.PRODUCTS.VAL
*--------------------------------------------------------------------------------------------------------
* Attached to : Version control Channel Permission as a  Validation Routine to the field DISPLAY.PRODUCTS
* Incoming : N/A
* Outgoing : N/A
*--------------------------------------------------------------------------------------------------------
* Description: Validation routine is used to default the Auto permissions while amending the record
*--------------------------------------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 1001222/Task 1001223
* TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            List the allowed products based on the specified company
*--------------------------------------------------------------------------------------------------

    $USING EB.ARC
    $USING EB.Interface
    $USING EB.SystemTables
*
    IF ((EB.SystemTables.getMessage() EQ "VAL") OR (EB.Interface.getOfsHotField() EQ "")) THEN   ;*Will trigger during validation and not at process
        RETURN      ;*Process only during Validation
    END
    GOSUB INITIALISE
    GOSUB MAIN.PROCESS
*
    RETURN
*-------------------------------------------------------------------------------------------------------------------------
INITIALISE:
*Initialise Required variables
    DISPLAY.PRODUCT = EB.SystemTables.getComi()    ;*set the value of validate field
    CUSTOMER.ID =       EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer)<1,EB.SystemTables.getAv()>          ;*get the customer value
    AA.PRD.GRP.ID = EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductGroups)<1,EB.SystemTables.getAv()>      ;*get the product group value
    PRODUCT.LIST = ""
*
    RETURN
*------------------------------------------------------------------------------------------------------------------------
MAIN.PROCESS:
*To get product Id
    IF CUSTOMER.ID EQ "" OR AA.PRD.GRP.ID EQ "" THEN         ;*If value not present in customer or Product group then exit
        RETURN
    END
    IF DISPLAY.PRODUCT EQ "" THEN
        GOSUB SUB.RESET.PRODUCTS        ;*To reset the product values
        RETURN
    END
    EB.ARC.ListAllowedProducts(PRODUCT.ID,CUSTOMER.ID, AA.PRD.GRP.ID,ALLOWED.COMPANY, PRODUCT.LIST)     ;*Call routine to get the list of products
    GOSUB SUB.POPULATE.PRODUCTS
*
    RETURN
*------------------------------------------------------------------------------------------------------------------------
SUB.POPULATE.PRODUCTS:
*To get available products
    AvVar = EB.SystemTables.getAv()
    tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProduct); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProduct, tmp)
    tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductSel); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductSel, tmp)
    PRD.CNT = 1
    PRD.LIST.CNT = DCOUNT(PRODUCT.LIST,@FM)        ;*Multi valuing the group to store the available products
    LOOP
        WHILE(PRD.CNT LE PRD.LIST.CNT)  ;*Loop the product
        ALLOWED.PRODUCT=FIELD(PRODUCT.LIST<PRD.CNT>,'*',1) ;* Get allowed products
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProduct); tmp<1,AvVar,PRD.CNT>=ALLOWED.PRODUCT; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProduct, tmp);*Set the products to the products fields
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductSel); tmp<1,AvVar,PRD.CNT>="Auto"; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductSel, tmp);*Set the deafult permissions as auto permission to the product selection fields
        PRD.CNT = PRD.CNT + 1
    REPEAT
*
    RETURN
*----------------------------------------------------------------------------------------------------------------------
SUB.RESET.PRODUCTS:
*Reset product fields
    AvVar = EB.SystemTables.getAv()
    tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProduct); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProduct, tmp);*reset the products field
    tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductSel); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductSel, tmp);*reset the product selection fields
*
    RETURN
*----------------------------------------------------------------------------------------------------------------------
    END
