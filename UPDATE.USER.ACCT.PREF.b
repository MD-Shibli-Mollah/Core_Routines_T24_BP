* @ValidationCode : MjotMTkzNjcyMjIzOTpDcDEyNTI6MTUyMzM3MDg2NzQyMDpzYW50b3NocHJhc2FkOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA0LjIwMTgwNDA3LTAxMDU6MTI1OjExNw==
* @ValidationInfo : Timestamp         : 10 Apr 2018 20:04:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : santoshprasad
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 117/125 (93.6%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180407-0105
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.ARC
SUBROUTINE UPDATE.USER.ACCT.PREF(ID)
*-----------------------------------------------------------------------------
* This is the record routine of the service UPDATE.USER.ACCT.PREF.
* The purpose of this routine is to update External User Account Group Preferences
* Based on the changes in CHANNEL.PERMISSION.
*-----------------------------------------------------------------------------
* Modification History :
* 18/05/15 - Enhancement - 1226758 / Task: 1347374
*            Create and update account groups based on channel permission
*
* 12/06/15 - Defect - 1376513 / Task: 1377225
*            Already created Account groups are deleted while running the service
*
* 13/07/15 - Enhancement - 1326996 / Task 1399931
*            Incorporation of EB_ARC component
*
* 11/08/15 - Defect - 1433552 / Task 1434325
*            Account Group variable is not initialised.
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            List the allowed products based on the specified company
*
* 15/05/18 - Defect - 2500881 / Task : 2505944
*            Closed accounts are not removed from TCIB. CHANNEL.PERMISSION.LIST is null for accounts closed.
*            Therefore, reading ACCOUNT.CLOSED file and checking for closed accounts. All the closed accounts
*            will be checked for all the user groups and then removed if any closed accounts are present
*
* 29/03/18 - Defect - 2523170 / Task : 2529524
*             Citco Closed accounts are not removed from TCIB in case of multi company
*-----------------------------------------------------------------------------
    $USING AA.ProductFramework
    $USING EB.ARC
    $INSERT I_DAS.EB.EXTERNAL.USER
    $INSERT I_DAS.EB.EXT.USER.PREF
    $INSERT I_DAS.EB.EXTERNAL.USER
    $INSERT I_DAS.ACCOUNT.CLOSED
    $INSERT I_DAS.COMMON
*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS
*
RETURN
*--------------------------------------------------------------------------------
***</region>
*** <region name= INITIALISE>
INITIALISE:
***<desc> Initialise required variables and open files </desc>
*
RETURN
*--------------------------------------------------------------------------------
***</region>
*** <region name= OPENFILES>
OPENFILES:
***<desc> Open required files </desc>
*
RETURN
*----------------------------------------------------------------------------------
***</region>
*** <region name= PROCESS>
PROCESS:
*** <region>
    TEMP = ID
    CHANGE '-' TO @FM IN TEMP
    BEGIN CASE
        CASE TEMP<1,1> EQ 'ACCOUNT'
            Y.ACCT.ARRAY= TEMP<2>
            GOSUB REMOVE.CLOSED.ACCOUNT
        CASE TEMP<1,1> NE 'ACCOUNT'
            GOSUB UPDATE.ACCT.GROUP.FROM.CHANNEL.PERMISSION
    END CASE
***</region>
RETURN
*
*----------------------------------------------------------------------------------
*** <region name= UPDATE.ACCT.GROUP>
UPDATE.ACCT.GROUP.FROM.CHANNEL.PERMISSION:
***<desc>Process for filter accounts in account group based on channel permission</desc>
    CHNL.PERM.ID=ID ;* To get channel permission Id
    R.CHANNEL.PERMISSION = EB.ARC.ChannelPermission.Read(CHNL.PERM.ID, PERMISSION.ERR)  ;* Read a channel permission record
    USER.TYPE = "CORPORATE"   ;*User type to update the account group
    APP.NAME = "EB.EXTERNAL.USER"       ;* To get External User application name
    ID.LIST = DAS.EXT$CHANNEL.PERMISSION
    THE.ARGS = CHNL.PERM.ID:@FM:USER.TYPE          ;* External user selection argument with User Type and Channel Permission
    CALL DAS(APP.NAME,ID.LIST,THE.ARGS,'')        ;* List of corporate user
*
    IF ID.LIST THEN
        CUS.LIST=R.CHANNEL.PERMISSION<EB.ARC.ChannelPermission.AiPerRelatedCustomer>        ;* Get related customer list from cahnnel permission record
        CUSTOMER.LIST = DCOUNT(CUS.LIST,@VM)
        GOSUB CHECK.PRODUCT.GROUPS      ;*Check group level permissions at first level
    END
    GOSUB FILTER.ACCT.GROUP.LIST
*
RETURN
*---------------------------------------------------------------------------------------------------------------------------------
***</region>
*** <region name= CHECK.PRODUCT.GROUPS>
CHECK.PRODUCT.GROUPS:
***<desc>Check Product Groups</desc>
    FOR CUSTOMER.NOS = 1 TO CUSTOMER.LIST
        CUSTOMER.NO = R.CHANNEL.PERMISSION<EB.ARC.ChannelPermission.AiPerRelatedCustomer,CUSTOMER.NOS>          ;*Channel permission current customer
        PRO.GROUP.ID = R.CHANNEL.PERMISSION<EB.ARC.ChannelPermission.AiPerProductGroups,CUSTOMER.NOS> ;*Channel permission currrent group id
        PROD.GROUP.SEL = R.CHANNEL.PERMISSION<EB.ARC.ChannelPermission.AiPerProductGroupSel,CUSTOMER.NOS>      ;*Channel permission current product group selection
        GOSUB READ.AA.PRODUCT.GROUP     ;*Read AA product group
        AA.PROD.TYPE = R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductType>         ;*Selected product type
        IF AA.PROD.TYPE EQ 'AC' THEN
            GOSUB FORM.ARRAY.PROD
        END
    NEXT CUSTOMER.NOS
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------
***</region>
*** <region name= FORM.ARRAY.PROD>
FORM.ARRAY.PROD:
***<desc>Process Allowed Account List</desc>
    PRODUCTS.ARRAY.LIST='' ;* Initialise product array list
    EB.ARC.ListAllowedProducts(PRODUCT.ID,CUSTOMER.NO,PRO.GROUP.ID,ALLOWED.COMPANY,PRODUCTS.ARRAY.LIST) ;*call API routine to get the list of products
    GOSUB PRODUCTS.PERMISSION.CHECK
*
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** </region>
*** <region name= PRODUCTS.PERMISSION.CHECK>
PRODUCTS.PERMISSION.CHECK:
***<desc>Check the product group permissions based on the product(AC,SC,LD)</desc>
    LOOP
        REMOVE CURR.PROD.ID FROM PRODUCTS.ARRAY.LIST SETTING PROD.POS ;*looping to set ext variables for each product
    WHILE CURR.PROD.ID:PROD.POS
*
        CURR.PROD.ID=FIELD(CURR.PROD.ID,'*',1) ;* Get the allowed product
        EXIT.STAGE = '';
        SPECIFIC.PRODUCT.FLAG.SET = ''
        GOSUB SET.PRODUCT.PERMISSIONS   ;*Checking individual product permission given in channel permission
        IF SPECIFIC.PRODUCT.FLAG.SET EQ '' AND EXIT.STAGE EQ '' THEN  ;*Account not given in individual permissions are allowed
            GOSUB SET.GRP.PERMISSION    ;*category check process with group permission
        END
*
        IF EXIT.STAGE EQ '' THEN
            Y.ACCT.ARRAY<-1> = CURR.PROD.ID       ;*Forming the array for accts
        END
    REPEAT
*
RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = SET.PRODUCT.PERMISSIONS>
SET.PRODUCT.PERMISSIONS:
***<desc>Setting permissions specifically for each product for current customers</desc>
    LOCATE CURR.PROD.ID IN R.CHANNEL.PERMISSION<EB.ARC.ChannelPermission.AiPerProduct,CUSTOMER.NOS,1> SETTING CURR.PROD.POS THEN
        SPECIFIC.PRODUCT.FLAG.SET = 1
        IF R.CHANNEL.PERMISSION<EB.ARC.ChannelPermission.AiPerProductSel,CUSTOMER.NOS,CURR.PROD.POS> = 'Exclude'   THEN   ;* product to be excluded EXIT.STAGE=1
            EXIT.STAGE = 1
            RETURN  ;* Dont proceed further as it failed
        END
    END
*
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= SET.CATEG.PERMISSION>
SET.GRP.PERMISSION:
***<desc>Check category permission in group/product level</desc>
    IF PROD.GROUP.SEL EQ 'Exclude' THEN
        EXIT.STAGE = '1'      ;*Don't proceeed further as permission is given exclude
    END
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------
*** </region>
*** <region name= READ.AA.PRODUCT.GROUP>
READ.AA.PRODUCT.GROUP:
***<desc>Read the product group permission</desc>
    R.AA.PRODUCT.GROUP = '';
    GRP.ERR = '';
    R.AA.PRODUCT.GROUP = AA.ProductFramework.ProductGroup.Read(PRO.GROUP.ID, GRP.ERR)     ;* Read Product Group record
*
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------------------
*** </region>
*** <region name= FILTER.ACCT.ID>
FILTER.ACCT.ID:
***<desc>Read Account Group and Filter the Excluded Account Id</desc>

    LOOP
        REMOVE ACCT.GROUP.ID FROM THE.ACCT.GROUP.LIST SETTING POS     ;* To get account group Id
    WHILE ACCT.GROUP.ID:POS

        R.ACC.GROUP = EB.ARC.ExtUserPref.Read(ACCT.GROUP.ID,ERR.GROUP)   ;* Read account group preferences
        EXT.ACCT.GROUP.LIST=R.ACC.GROUP<EB.ARC.ExtUserPref.ExtUsrPrefUserAccounts>   ;* To Get External User Account Group List
        ACCT.ID.GROUP='' ;* Initialise the Account Group variable
        LOOP
            REMOVE ACCT.ID FROM EXT.ACCT.GROUP.LIST SETTING ACCT.ID.POS         ;* To get account Id from List
        WHILE ACCT.ID:ACCT.ID.POS
            IF TEMP<1,1> NE 'ACCOUNT' THEN
                LOCATE ACCT.ID IN Y.ACCT.ARRAY SETTING ACCT.POS THEN      ;* To check existing account is valid or not.
                    LOCATE ACCT.ID IN ACCT.ID.GROUP<1,1> SETTING DUP.POS ELSE ;* To avoid Duplicate accounts in account group array
                        ACCT.ID.GROUP<1,-1>=ACCT.ID       ;* Process valid account Id list
                    END
                END
            END ELSE
                LOCATE ACCT.ID IN Y.ACCT.ARRAY SETTING ACCT.POS ELSE      ;* To check if closed accounts are present in acc group.
                    ACCT.ID.GROUP<1,-1>=ACCT.ID       ;* only Acct not closed will be addded
                END
            END
        REPEAT
        R.ACC.GROUP<EB.ARC.ExtUserPref.ExtUsrPrefUserAccounts>=ACCT.ID.GROUP
* Update the account group and channel permission concat list
        IF (R.ACC.GROUP<EB.ARC.ExtUserPref.ExtUsrPrefUserAccounts>) NE '' THEN
            EB.ARC.ExtUserPref.Write(ACCT.GROUP.ID,R.ACC.GROUP)
            EB.ARC.ChannelPermissionList.Delete(ID)
        END ELSE
            EB.ARC.ExtUserPref.Delete(ACCT.GROUP.ID)
            EB.ARC.ChannelPermissionList.Delete(ID)
        END
    REPEAT
*
RETURN
*----------------------------------------------------------------------------------------------------------------
*** </region>
*** <region name= FILTER.ACCT.GROUP.LIST>
FILTER.ACCT.GROUP.LIST:
***<desc>Process Account Group List</desc>
    LOOP
        REMOVE EXT.USER.ID FROM ID.LIST SETTING EXT.USER.POS
    WHILE EXT.USER.ID:EXT.USER.POS
        THE.ACCT.GROUP.LIST=DAS.EB$USER.ID
        THE.ARGS=EXT.USER.ID:'...'
        CALL DAS('EB.EXT.USER.PREF',THE.ACCT.GROUP.LIST,THE.ARGS,'')  ;* To get account group list
        GOSUB FILTER.ACCT.ID
    REPEAT
*
RETURN
*----------------------------------------------------------------------------------------------------------------
*** </region>
*** <region name= REMOVE.CLOSED.ACCOUNT>
*** <desc>To remove closed accounts from all the account groups </desc>
REMOVE.CLOSED.ACCOUNT:
    THE.ACCT.GROUP.LIST=DAS.EB$USER.ID
    CALL DAS('EB.EXT.USER.PREF',THE.ACCT.GROUP.LIST,'','')  ;* To get account group list
    GOSUB FILTER.ACCT.ID
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
*--------------------------------------------------------------------------------------------------------------
