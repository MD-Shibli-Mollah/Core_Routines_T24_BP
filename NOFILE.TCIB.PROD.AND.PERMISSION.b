* @ValidationCode : MjotMTEwMzM1MjA0NDpDcDEyNTI6MTQ4NzA2NjE4NjA4MDpyc3VkaGE6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwMi4wOjIxNjoyMDA=
* @ValidationInfo : Timestamp         : 14 Feb 2017 15:26:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 200/216 (92.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE T2.ModelBank
    SUBROUTINE NOFILE.TCIB.PROD.AND.PERMISSION(Y.FINAL.ARRAY)
*-----------------------------------------------------------------------------
* This Nofile Routine will show the what are all the EXT variables which are
* going to set by reading the Channel Permission
* Author: kanand@temenos.com
*--------------------------------------------------------------------------------
* Modification History:
*----------------------
*** <region name= Modification History>
* 08/07/14 - Enhancement 1001222 / Task 1001223
*            User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
*08/01/16 - Defect 1593481 / Task 1594090
*           Warnings in TAFC
*
* 21/12/15 - Enhancement 1470216 / Task 1559865
*            EB.USER.CONTEXT cleanup of variables
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            List the allowed products based on the specified company
*--------------------------------------------------------------------------------
*** <region name= Insert>
*** <desc>Insert Region </desc>
    $USING AA.ARC
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AC.AccountOpening
    $USING EB.ARC
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING LD.Contract
    $USING MM.Contract
    $USING SC.ScoPortfolioMaintenance
    $USING SC.ScvValuationUpdates
    $USING ST.CompanyCreation
    $INSERT I_DAS.AA.ARRANGEMENT
*** </region>
*---------------------------------------------------------------------------------
    GOSUB INITIALISE          ;*Open files and initialise variables
    GOSUB READ.FILES          ;*Read the external user,profile,permission records
*
    IF R.EB.EXTERNAL.USER THEN          ;* External user found
        GOSUB MAIN.PROCESS    ;* Form main processing logic
    END
*
    RETURN
*---------------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
*** <desc>Initialise Required Variables </desc>
    R.USER.RIGHTS.REC = ''    ;* user rights property record for the logged in external user
    R.PRODUCT.ACCESS.REC = '' ;* product access property record for the logged in external user
    R.ARR.PREF.REC = ''       ;* arrangement preferences property record for the logged in external user
* read INTERNET.SERVICES bound prop classes, fetch USER.RIGHTS, PRODUCT.ACCESS and ARRANGEMENT.PREFERENCES property class details for the logged in USER
    SEC.FILE.OPEN = ''
    FILE.OPEN = ''
    FILTERED.ARRAY = ''       ;* final array of elements to be added to SMS variables
    SC.IN.COMPANY = ''
    SC.IN.SPF = ''
    Y.SEE.PERMISSION = '';
    Y.TRANS.PERMISSION = '';
*
    LOCATE "SC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING SC.IN.SPF ELSE          ;* To check SC product availability in SPF
    SC.IN.SPF = 0
    END
    AA.INSTALLED = 0
    LOCATE 'AA' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING AAPOS THEN       ;* To check AA product availability in SPF
    AA.INSTALLED = 1
    END
    SC.INSTALLED =0
    LOCATE 'SC' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING SCPOS THEN       ;* To check SC product availability in SPF
    SC.INSTALLED = 1
    END ELSE
    SC.IN.COMPANY = 0
    END
*
    LD.INSTALLED = 0;
    LOCATE 'LD' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING LDPOS THEN       ;* To check LD product availability in SPF
    LD.INSTALLED = 1 ;
    END

    MM.INSTALLED = 0;
    LOCATE 'MM' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING MMPOS THEN       ;* To check MM product availability in SPF
    MM.INSTALLED = 1;
    END

    CUST.AC.LIST = ''         ;*Customer Account List
    RETURN
*** </region>
*-------------------------------------------------------------------------------------------------------------------------
*** <region name= Read Files>
READ.FILES:
*** <desc>Read the external user,profile,permission records. </desc>
* Get User permission
    Y.INPUT.CUSTOMER = ''; Y.ARRANGEMENT.ID = '';
    Y.USER.ID = '' ;
    LOCATE 'INPUT.USER' IN EB.Reports.getDFields()<1> SETTING ITEM.POS THEN
    Y.USER.ID = EB.Reports.getDRangeAndValue()<ITEM.POS>   ;* To get user Id
    END
    R.EB.EXTERNAL.USER = ''
    EB.YERR = ''
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(Y.USER.ID, EB.YERR)        ;* To get External User Record
    IF R.EB.EXTERNAL.USER EQ '' THEN
        R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.ReadNau(Y.USER.ID, ERR.NAU)       ;* To get Unauthorised External User Record
    END
    Y.INPUT.CUSTOMER = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuCustomer>   ;* To get External User Customer Id
    Y.ARRANGEMENT.ID = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuArrangement>          ;* To get External User arrangement
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN.PROCESS>
MAIN.PROCESS:
*** <desc>Form main processing conditions </desc>
    GOSUB READ.PRODUCT.ACCESS ;*Read product access property
    GOSUB GET.GROUP.PERMISSION.DETAILS
    IF R.GROUP.PERMISSION    THEN       ;* Need to filter ext variables based on group level configuration
        GOSUB  SET.BASED.ON.PERMISSION.FILTER
    END ELSE        ;* Take details  directly from product
        GOSUB CHECK.PROD.GROUPS.LIST    ;*No permission level checks, works based on product permission checks
    END
*
    RETURN
*** </region>
*-------------------------------------------------------------------------------------------------------------------------
***<region name = READ.PRODUCT.ACCESS>
READ.PRODUCT.ACCESS:
***<desc> read PRODUCT.ACCESS property class details</desc>
    R.PRODUCT.ACCESS.REC = ''
    ARR.ID = Y.ARRANGEMENT.ID   ;*Take the arrangement of the active channel
    PROPERTY.CLASS = 'PRODUCT.ACCESS'
    GOSUB GET.ARRANGEMENT.CONDS         ;* call AA.GET.ARRANGEMENT.CONDITIONS to get the property conditions
    IF NOT(RET.ERR) THEN
        R.PRODUCT.ACCESS.REC = RAISE(PROPERTY.RECORD)       ;* Get Product Access Record.
    END
*
    RETURN
***</region>
*--------------------------------------------------------------------------------------------------------------------------
***<region name = GET.ARRANGEMENT.CONDS>
GET.ARRANGEMENT.CONDS:
***<desc> Call AA.GET.ARRANGEMENT.CONDITIONS to fetch the property conditions </desc>
    ARR.CACHE.ID = ""         ;* cache id
    ARR.CACHE.VAL = ""        ;* Arrangement data read from cache
    ARR.CACHE.TYPE = "ARC.ARR.CACHE"    ;* Arrangement cache type
    ARR.ACTION = "" ;* Action to be performed on F.OS.XML.CACHE
* Token ID has been removed from AA.ARR.CACHE.ID formation to avoid inconsistancy in CACHE.ID
    ARR.CACHE.ID = ARR.ID:"_":PROPERTY.CLASS:"_":EB.ErrorProcessing.getExternalUserId()
* Read cache
    CALL OS.USE.CACHE(ARR.CACHE.TYPE, ARR.CACHE.ID, ARR.ACTION,ARR.CACHE.VAL)
    IF ARR.CACHE.VAL THEN
        PROPERTY.IS.NULL = PROPERTY.CLASS:"-NULL"
        IF ARR.CACHE.VAL EQ PROPERTY.IS.NULL THEN
            PROPERTY.RECORD = ''
        END ELSE
            PROPERTY.RECORD = ARR.CACHE.VAL       ;* To get property record from Cache
        END
    END ELSE
        IF INDEX(ARR.ID ,"/",1) THEN
            ARR.ID := '/AUTH' ;*read the record directly from AUTH
        END ELSE
            ARR.ID := '//AUTH'          ;*read the record directly from AUTH
        END
        AA.Framework.GetArrangementConditions(ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,PROPERTY.RECORD,RET.ERR)  ;* Get arrangement conditions based on the property class.
    END
*
    RETURN
***</region>
*--------------------------------------------------------------------
*** <region name= Get Product Group Permission Details>
GET.GROUP.PERMISSION.DETAILS:
*** <desc>Get the product permission </desc>
* Get User group permission if given for external user
    GROUP.PERMISSION = ''
    R.GROUP.PERMISSION = ''
    IF R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuChannelPermission> THEN
        ARC.PERMISSION.ID = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuChannelPermission>        ;* To get Channel Permission Id
        GOSUB READ.PERMISSION
        R.GROUP.PERMISSION = R.CHANNEL.PERMISSION ;* Group permission from channel permission table
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Set based on Permission Filter>
SET.BASED.ON.PERMISSION.FILTER:
*** <desc>Get the details based on filtering at product/group/user level </desc>
    GRP.CATEG.RANGE.LIST = ''; GRP.PROD.PERM.CATEGORY = ''; GRP.PROD.PERM.CATEGORY.EXCLUDE = ''; GRP.PROD.PRODUCTS = '' ;*initialising the variables
    Y.CUSTOMER = ''; PROD.GROUP.ID = '';PROD.GROUP.ID = '';PROD.GROUP.SEL = ''; Y.GROUP.ID = ''; PRO.GROUP.ID = ''      ;*intialising the variables
    GRP.PROD.TYPE =''; PROD.GRP.FLAG = ''; GROUP.GROUP.FLAG = '';
    PROXY.CUST.GROUP = ''
    Y.CUSTOMER = Y.INPUT.CUSTOMER
    CUSTOMER.LIST = DCOUNT(R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerRelatedCustomer>,@VM)
    FOR CUSTOMER.NOS = 1 TO CUSTOMER.LIST
        PROD.GRP.FLAG = ''; GROUP.GROUP.FLAG = '';          ;*initialising variables
        CUSTOMER.NO = R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerRelatedCustomer,CUSTOMER.NOS>  ;*Channel permission current customer
        PRO.GROUP.ID = R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerProductGroups,CUSTOMER.NOS>   ;*Channel permission currrent group id
        PROD.GROUP.SEL = R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerProductGroupSel,CUSTOMER.NOS>        ;*Channel permission current product group selection
        GRP.PROD.TYPE = R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductType>        ;*Selected product type

        LOCATE CUSTOMER.NO IN PROXY.CUST.GROUP SETTING CUST.POS ELSE  ;*locate previously available
        PROXY.CUST.GROUP<-1>=CUSTOMER.NO      ;*Forming the array for Proxy customers excluding duplicates
    END
*
    IF Y.CUSTOMER EQ CUSTOMER.NO THEN         ;*check for personal users
        PROD.GRP.FLAG = 1 ;* Flag to use as product permission filter
        GROUP.ID = PRO.GROUP.ID
        GOSUB READ.AA.PRODUCT.GROUP ;*Read AA product group
        GOSUB CHECK.PROD.GROUPS.LIST          ;* Check product permissions at first level filter
    END ELSE
        GROUP.GROUP.FLAG = 1        ;* flag to use group permission filter
        GOSUB CHECK.PRODUCT.GROUPS  ;*Check group level permissions at first level
    END

    NEXT CUSTOMER.NOS
*
    RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.PROD.GROUPS.LIST>
CHECK.PROD.GROUPS.LIST:
*** <desc>Get the category range from product </desc>

    EXIT.STAGE = ''; GROUPOS = ''; PROD.GROUP.ID = '';  PROD.GROUPS.LIST = '';  ;*Initialising variables
    PROD.GROUPS.LIST = DCOUNT(R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaProdGrpTrans>,@VM) ;* Allowed product groups
    FOR GROUPOS = 1 TO PROD.GROUPS.LIST
        Y.GROUP.ID = R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaProdGrpTrans,GROUPOS>      ;* Get Product Group Id
        GOSUB CHECK.PRODUCT.GROUPS
    NEXT
*
    RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.PRODUCT.GROUPS>
CHECK.PRODUCT.GROUPS:
*** <desc>Check Product Group Category Permission</desc>
    GROUP.CHECK = ''; PRODUCTS.ARRAY.LIST = ''; CUSTOMER.ACCOUNT.TO.READ = ''; GROUP.ID = ''; AA.PROD.GROUP = ''; AA.PROD.LINE = '' AA.PROD.TYPE = '';*Initialising variables

    IF GROUP.GROUP.FLAG THEN  ;* Get product group Id from Product Access
        GROUP.ID = PRO.GROUP.ID         ;*assigning the channel permission AA product group id
    END ELSE
        GROUP.ID = Y.GROUP.ID ;*assigning the product access property AA product group id
    END
    GOSUB READ.AA.PRODUCT.GROUP         ;*Read AA product group
*
    PROD.PERM.CATEGORY = ''; PRODUCTS.ARRAY.LIST = ''       ;*intialising variables
    AA.PROD.GROUP = GROUP.ID  ;*Allowed AA product groups
    AA.PROD.TYPE = R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductType>   ;*Selected product type
    AA.PROD.LINE = R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductLine>   ;*Selected product line
    IF R.GROUP.PERMISSION THEN
        IF ((PROD.GRP.FLAG NE '') AND (PRO.GROUP.ID NE Y.GROUP.ID)) THEN        ;*Group type at product level and group type at permission level
            GROUP.CHECK = 1   ;*Not available in product access property
        END
    END
    IF R.GROUP.PERMISSION EQ '' THEN    ;*no channel permission defined
        CUSTOMER.ACCOUNT.TO.READ = EB.ErrorProcessing.getExternalCustomer()     ;* When group permission is not available, External User will assigned to allowed customer
    END ELSE
        CUSTOMER.ACCOUNT.TO.READ = CUSTOMER.NO    ;*when channel permission available current customer is assigned
    END
    IF GROUP.CHECK EQ '' THEN ;*if no error then proceed

        EB.ARC.ListAllowedProducts(PRODUCT.ID,CUSTOMER.ACCOUNT.TO.READ,GROUP.ID,ALLOWED.COMPANY,PRODUCTS.ARRAY.LIST)        ;*call API routine to get the list of products
        CONVERT @FM TO @VM IN PRODUCTS.ARRAY.LIST   ;*convert the value marker

        GOSUB PRODUCTS.PERMISSION.CHECK ;*Product permission check for all type of products
    END
*
    RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= PRODUCTS.PERMISSION.CHECK>
PRODUCTS.PERMISSION.CHECK:
***<desc>Check the product group permissions based on the product(AC,SC,LD)</desc>

    LOOP
        REMOVE CURR.PROD.ID FROM PRODUCTS.ARRAY.LIST SETTING PROD.POS ;*looping to set ext variables for each product
    WHILE CURR.PROD.ID:PROD.POS
        CURR.PROD.ID=FIELD(CURR.PROD.ID,'*',1) ;* Get the allowed product
        PRODUCT.TRANS.ALLOWED = 1; PRODUCT.SEE.ALLOWED = 1  ;*Initialising with Maximum Default permission
        EXIT.STAGE = '';
        IF R.GROUP.PERMISSION THEN      ;*Group permission level check
            SPECIFIC.PRODUCT.FLAG.SET = ''; PROD.ID = CURR.PROD.ID
            GOSUB SET.PRODUCT.PERMISSIONS         ;*Checking individual product permission given in channel permission
            IF SPECIFIC.PRODUCT.FLAG.SET EQ '' AND EXIT.STAGE EQ '' THEN        ;*Account not given in individual permissions are allowed
                GOSUB SET.GRP.PERMISSION          ;*category check process with group permission
            END

            IF EXIT.STAGE EQ '' THEN
                GOSUB SET.EXT.VARIABLES.PRODUCTS  ;*Setting ext variables for products after all level of filters
            END
        END ELSE
            GOSUB SET.EXT.VARIABLES.PRODUCTS      ;*Setting ext variables for products after all level of filters
        END
    REPEAT
*
    RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = SET.PRODUCT.PERMISSIONS>
SET.PRODUCT.PERMISSIONS:
***<desc>Setting permissions specifically for each product for current customers</desc>

    LOCATE CURR.PROD.ID IN R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerProduct,CUSTOMER.NOS,1> SETTING GACPOS THEN
    SPECIFIC.PRODUCT.FLAG.SET = 1
    IF R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerProductSel,CUSTOMER.NOS,GACPOS> = 'See' THEN        ;* Lower most permission
        PRODUCT.TRANS.ALLOWED = 0   ;*nullfying the transact permission
    END
    IF R.GROUP.PERMISSION<EB.ARC.ChannelPermission.AiPerProductSel,CUSTOMER.NOS,GACPOS> = 'Exclude'   THEN  ;* product to be excluded EXIT.STAGE=1
        EXIT.STAGE = 1
        RETURN  ;* Dont proceed further as it failed
    END
    END
    RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= SET.EXT.VARIABLES.PRODUCTS>
SET.EXT.VARIABLES.PRODUCTS:
***<desc>Get View Trans Array for Products</desc>
    Y.SEE.PERMISSION = 'See'  ;* To assign view permission
    Y.TRANS.PERMISSION = 'Transact'     ;* To assign transaction permission
    IF PRODUCT.TRANS.ALLOWED THEN       ;* To form transaction array
        Y.FINAL.ARRAY<-1> = CURR.PROD.ID:"*":Y.TRANS.PERMISSION:"*":CUSTOMER.ACCOUNT.TO.READ
    END ELSE
        IF PRODUCT.SEE.ALLOWED THEN     ;* To form view array
            Y.FINAL.ARRAY<-1> = CURR.PROD.ID:"*":Y.SEE.PERMISSION:"*":CUSTOMER.ACCOUNT.TO.READ
        END
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= SET.CATEG.PERMISSION>
SET.GRP.PERMISSION:
***<desc>Check category permission in group/product level</desc>
    IF PROD.GROUP.SEL EQ 'See' THEN
        PRODUCT.TRANS.ALLOWED = 0       ;*Setting only See permission
    END
*
    IF PROD.GROUP.SEL EQ 'Exclude' THEN
        EXIT.STAGE = '1'      ;*Don't proceeed further as permission is given exclude
    END
*
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= READ.PERMISSION>
READ.PERMISSION:
*** <desc>Read the user and group  permission </desc>
    R.CHANNEL.PERMISSION = ''
    YERR = ''
    R.CHANNEL.PERMISSION = EB.ARC.ChannelPermission.Read(ARC.PERMISSION.ID, YERR)       ;* Read Channel permission record
*
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------------------
*** <region name= READ.AA.PRODUCT.GROUP>
READ.AA.PRODUCT.GROUP:
***<desc>Read the product group permission</desc>
    R.AA.PRODUCT.GROUP = '';
    GRP.ERR = '';
    R.AA.PRODUCT.GROUP = AA.ProductFramework.ProductGroup.Read(GROUP.ID, GRP.ERR)         ;* Read Product Group record
*
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------------------
    END
