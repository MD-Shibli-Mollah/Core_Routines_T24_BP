* @ValidationCode : MjoxNzM1MTI3NjExOkNwMTI1MjoxNTkyOTM4NzUyODM2OnNpdmFjaGVsbGFwcGE6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjgzOjU5
* @ValidationInfo : Timestamp         : 24 Jun 2020 00:29:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 59/83 (71.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.Channels
SUBROUTINE E.NOFILE.TC.PRODUCT.DETAILS(consolidatedProducts)
*-----------------------------------------------------------------------------------
* Incoming         : CUSTOMER.NO , PRODUCT.GROUP,PRODUCY.ID and COMPNAY.ID
* Outgoing         : ALLOWED.PRODUCTS
* Attached in      : SS>NOFILE.TC.PRODUCT.DETAILS
* ----------------------------------------------------------------------------------
* Get the allowed product details based on the customer and the product group
*-----------------------------------------------------------------------------
* Modification History:
* 03/10/16 - Enhancement 1812222 / / Task 1905849
*            Tc Permissions property class - To list allowed products for customer
*
* 12/02/2019 - Enhancement 2875458 / Task 3025789 - Migration to IRIS R18
*
* 22/05/2019 - Defect 3143229 / Task 3145191
*-----------------------------------------------------------------------------
    $USING EB.ARC
    $USING EB.Reports
    $USING AA.ProductFramework
    $USING AO.Framework
*
    GOSUB INITIALISE
    GOSUB MAIN.PROCESS
*
RETURN
*-------------------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables</desc>
INITIALISE:
* Initialise Required Variables
    LOCATE 'CUSTOMER.NO' IN EB.Reports.getDFields()<1> SETTING CUS.POS THEN
        CUSTOMER.NO=EB.Reports.getDRangeAndValue()<CUS.POS> ;* Get the customer number
    END
    LOCATE 'PRODUCT.GROUP' IN EB.Reports.getDFields()<1> SETTING PRD.POS THEN
        productGroupIds=EB.Reports.getDRangeAndValue()<PRD.POS> ;* Get the product group
    END
    LOCATE 'PRODUCT.ID' IN EB.Reports.getDFields()<1> SETTING PRODUCT.POS THEN
        productIds=EB.Reports.getDRangeAndValue()<PRODUCT.POS> ;* Get the product Id
    END
    LOCATE 'COMPANY.ID' IN EB.Reports.getDFields()<1> SETTING COMPANY.POS THEN
        COMPANYID=EB.Reports.getDRangeAndValue()<COMPANY.POS> ;* Get the Company Id
    END
    LOCATE 'ONLINE.SERVICE.PRODUCT' IN EB.Reports.getDFields()<1> SETTING ONSERVPROD.POS THEN
        onlineServiceProduct = EB.Reports.getDRangeAndValue()<ONSERVPROD.POS> ;* Get the Online Service Product Id
    END
*
RETURN
*** </region>
* ------------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN.PROCESS>
*** <desc>the main process</desc>
MAIN.PROCESS:
    CHANGE @SM TO @VM IN COMPANYID
    CHANGE "|" TO @FM IN productGroupIds
    CHANGE "|" TO @FM IN productIds
    IF onlineServiceProduct NE '' THEN
* getPermissionsConditions for ONLINE.SERVICES
        GOSUB GET.PRODUCT.CONDITION.DEFINITION
        productGroupIds =  conditionDefinedProductGroupList
        CHANGE @VM TO @FM IN productGroupIds
    END
    consolidatedProducts = ''
    FOR productGroupCounter = 1 TO DCOUNT(productGroupIds, @FM)

        allowedProducts = ''
        productGroupId = productGroupIds<productGroupCounter>
        productId = productIds<productGroupCounter>
        EB.ARC.ListAllowedProducts(productId,CUSTOMER.NO,productGroupId,COMPANYID,allowedProducts)   ;*call routine to get the list of products
        allowedProductsArray = ''
        LOOP
            REMOVE productArrary FROM allowedProducts SETTING productPos
        WHILE productArrary:productPos
            productIdFromArray = FIELD(productArrary,"*",1)
            productGroupIdFromArray = FIELD(productArrary,"*",2)
            currencyIdFromArray = FIELD(productArrary,"*",3)
            permissionFromArray = FIELD(productArrary,"*",4)
            FIND productGroupId IN productGroupIds SETTING fmPos THEN
                CHANGE @VM TO @FM IN conditionDefinedProductGroupSelList
                permissionFromArray = conditionDefinedProductGroupSelList<fmPos>
            END
            IF NOT(allowedProductsArray) THEN
                allowedProductsArray = productArrary:"*":productGroupId:"*":permissionFromArray
            END ELSE
                allowedProductsArray<-1> = productIdFromArray:"**":currencyIdFromArray
            END
	
        REPEAT
        IF allowedProductsArray NE '' THEN
            consolidatedProducts<-1> = allowedProductsArray  ;* set the output for routine
        END
    NEXT productGroupCounter
    IF consolidatedProducts EQ '' THEN
        GOSUB READ.AA.PRODUCT.GROUPS
        consolidatedProducts = "":"*":AA.PROD.GROUP.DESC:"*":"":"*":productGroupIds:"*":""
    END
*
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.PRODUCT.CONDITION.DEFINITION>
*** <desc>get the permission conditions for productGroup ONLINE.SERVICES</desc>
GET.PRODUCT.CONDITION.DEFINITION:
    permissionsRec = ''
    conditionDefinedProductGroupList = ''
    conditionDefinedProductGroupSelList = ''
    Currency = ''                                                                                   ;* Currency
    EffectiveDate = ''                                                                              ;* Effective Date
    OutPropertyList = ''                                                                            ;* Property List
    OutPropertyClassList = ''                                                                       ;* Property Class List
    OutArrangementLinkType = ''                                                                     ;* Arrangement Link Type
    OutPropertyConditionList = ''                                                                   ;* Property Condition List
    RetErr = ''                                                                                     ;* Error Return
    AaProduct = onlineServiceProduct                                                                           ;* AA Product ID
    AA.ProductFramework.GetProductConditionRecords(AaProduct, Currency, EffectiveDate, OutPropertyList, OutPropertyClassList, OutArrangementLinkType, OutPropertyConditionList, RetErr)
    LOCATE 'TC.PERMISSIONS' IN OutPropertyClassList SETTING permPos THEN
        permissionsRec = RAISE(OutPropertyConditionList<permPos>)                                   ;* Permissions Record
        conditionDefinedProductGroupList = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedProductGroups>      ;* Product Groups
        conditionDefinedProductGroupSelList = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel> ;* Permission for Product Groups
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
READ.AA.PRODUCT.GROUPS:
* Read the product group permission

    R.AA.PRODUCT.GROUP = '';
    GRP.ERR = '';
    R.AA.PRODUCT.GROUP = AA.ProductFramework.ProductGroup.Read(productGroupIds, GRP.ERR)         ;* To get product group record
    AA.PROD.GROUP.DESC=R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgDescription,1>
*
RETURN
END
