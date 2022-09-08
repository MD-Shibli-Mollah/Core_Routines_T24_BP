* @ValidationCode : MjotMTI4NDk1ODk2NzpDcDEyNTI6MTQ4NzA2NjE4NTYyODpyc3VkaGE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwMi4wOjQ1OjQz
* @ValidationInfo : Timestamp         : 14 Feb 2017 15:26:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 43/45 (95.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE T2.ModelBank
    SUBROUTINE V.TCIB.PERMISSION.CHECK.REC
*-----------------------------------------------------------------------------
* Attached to : Version control Channel Permission as a Check record routine
* Incoming : N/A
* Outgoing : N/A
*-------------------------------------------------------------------------------
*DESCRIPTION    : Will populate OWNER field based on the ID if not given before.
*DESCRIPTION    : WILL ALSO DYNAMICALLY BUILD UP ALL PRODUCTS
*-------------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 1001222/Task 1001223
* TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            List the allowed products based on the specified company
*-------------------------------------------------------------------------------

    $USING EB.ARC
    $USING EB.SystemTables
*
    GOSUB INITIALISE
    GOSUB MAIN.PROCESS
*
    RETURN
*------------------------------------------------------------------------------------
INITIALISE:
*Initialise Required Variables
    RECORD.ID = EB.SystemTables.getIdNew()        ;*set the id.new in a variable
    ID.OWNER =  FIELD(RECORD.ID,"-",1)  ;*to find the customer id
    CUSTOMER.LIST = EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer)          ;*get the customer list
*Automatically default the CUSTOMER and RELATED.CUSTOMER field
    IF EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerCustomer)<1,1> EQ "" THEN
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerCustomer); tmp<1,1>=ID.OWNER; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerCustomer, tmp);*if owner field is null then default the customer id
    END
    IF  EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer)<1,1> EQ "" THEN      ;*if owner field is null then default the customer id
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer); tmp<1,1>=ID.OWNER; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer, tmp)
    END
    CHANNEL.PROD.GROUP       = ""
    PRODUCT.LIST        = ""
    NEW.PRODUCT.LIST         = ""
    NEW.PRODUCT.PERM         = ""
*
    RETURN
*----------------------------------------------------------------------------------------------------------------------
MAIN.PROCESS:
*Dynamically build up the Products per Related customer and the according permissions
    CUS.ID = 1
    CUS.COUNT = DCOUNT(CUSTOMER.LIST,@VM)          ;*get the no.of customers
    FOR CUS.ID = 1 TO CUS.COUNT         ;*Loop through the customers to get the related products
        IF EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerDisplayProducts)<1,CUS.ID> NE "" THEN
            *Initating for the Loop
            PRODUCT.LIST = "";
            STORED.PRODUCTS = "" ; STORED.PERMISSIONS = ""
            CUSTOMER.ID = EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer)<1,CUS.ID>    ;*get the related customer id
            CHANNEL.PROD.GROUP = EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductGroups)<1,CUS.ID>         ;*get the product group id
            STORED.PRODUCTS   = EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProduct)<1,CUS.ID>       ;*get the products
            STORED.PERMISSIONS= EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductSel)<1,CUS.ID>   ;*get the product selection
            EB.ARC.ListAllowedProducts(PRODUCT.ID,CUSTOMER.ID,CHANNEL.PROD.GROUP,ALLOWED.COMPANY,PRODUCT.LIST)    ;*call routine to get the list of products
            GOSUB SUB.RESTORE.PRODUCTS  ;*Build the list of products
        END
    NEXT CUS.ID
*populate the products
    EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProduct, NEW.PRODUCT.LIST);*setting the new array variables
    EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductSel, NEW.PRODUCT.PERM);*setting the new array variables
*
    RETURN
*---------------------------------------------------------------------------------------------------------------------------
SUB.RESTORE.PRODUCTS:
*Inner Loop
    ALLOWED.PRODUCT.CNT=DCOUNT(PRODUCT.LIST,@FM) ;* Count of product Id list
    FOR PRD.CNT=1 TO ALLOWED.PRODUCT.CNT
        PRODUCT.ID   = FIELD(PRODUCT.LIST<PRD.CNT>,'*',1) ;* Get the allowed product
        NEW.PRODUCT.LIST<1,CUS.ID,-1>      = PRODUCT.ID
        LOCATE PRODUCT.ID IN STORED.PRODUCTS<1,1,1> SETTING CUS.POS THEN        ;*checking special permission has been given
        *found the product with a special permission
        NEW.PRODUCT.PERM<1,CUS.ID,-1>      = STORED.PERMISSIONS<1,1,CUS.POS>          ;*setting the same special permission
    END ELSE
        *did not find the product
        NEW.PRODUCT.PERM<1,CUS.ID,-1>      = "Auto"     ;*setting the default permission as Auto
    END
    NEXT PRD.CNT
*
    RETURN
*-------------------------------------------------------------------------------------------------------------------------
    END
