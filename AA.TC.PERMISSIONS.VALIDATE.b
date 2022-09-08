* @ValidationCode : MjoxNjAwODc0OTgxOkNwMTI1MjoxNTcxNzM3Nzc3NDg1OnN1ZGhhcmFtZXNoOjQ0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6NDM5OjQxMQ==
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 44
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 411/439 (93.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PERMISSIONS.VALIDATE
*--------------------------------------------------------------------------------------------------------------
* Description :
* Validation routine for the property class TC.PERMISSIONS
*--------------------------------------------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
*
* 20/02/17 - Defect 2025238 / Task 2025374
*            Product group error variable is initialized
*
* 22/12/17 - Enhancement-2379129/ Task-2379132
*            TCUA - Validation for Permissions
*
* 23/02/18 - Defect 2472252 / Task 2473347, 2486987
*            Incorrect validations being performed on Detailed Permissions page
*
* 01/02/18 - Defect 2108755 / Task 2444623
*            Defined company field is allowed to accept branch companies
*
* 11/06/18 - Enh 2584357 / Task 2584360
*            TCUA: Online Arrangement Validations against product & Additional Validations on permissions
*
* 27/08/18 - Defect 2727649 / Task 2738705
*            The system is not throwing a validation error if we change the DEFINED.PRODUCT.SEL field in the arrangement condition.
*
* 14/09/18 - Defect 2872738 / Task 2874473
*            Update arrangement after a multi-value set was removed from Product Condition
*
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>
    $USING AO.Framework
    $USING AA.Framework
    $USING EB.ErrorProcessing
    $USING AC.AccountOpening
    $USING EB.OverrideProcessing
    $USING EB.SystemTables
    $USING EB.Template
    $USING AA.ProductFramework
    $USING EB.ARC
    $USING EB.DataAccess
    $USING SC.ScoPortfolioMaintenance
    $USING ST.CompanyCreation
    $USING AF.Framework
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>
    GOSUB INITIALISE
    GOSUB PROCESS.CROSSVAL
*
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:
*
    PRODUCT.GROUP.ERR=''                                                    ;* Initialize product group error
    TMP.AV=0
    errMsg=''
    masterArrId=''
    productId=''
    productGroupId=''
    currentArrangement=''
    arrangementRecord=''
    countConditionProductGroups=''
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Cross validation>
*** <desc>Cross validation stages</desc>
PROCESS.CROSSVAL:
*
    IF EB.SystemTables.getMessage() EQ '' THEN                              ;* Only during commit...
        TEMP.V.FUN = EB.SystemTables.getVFunction()
        BEGIN CASE
            CASE TEMP.V.FUN EQ 'D'
            CASE TEMP.V.FUN EQ 'R'
            CASE 1                                                          ;* The real crossval...
                GOSUB REAL.CROSSVAL
        END CASE
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Real Crossval>
*** <desc>Real Crossvalidation stages</desc>
REAL.CROSSVAL:
*
* Real cross validation goes here....
*
    TEMP.PROD.ARR = AF.Framework.getProductArr()
    TEMP.AA.PROD  = AA.Framework.Product
    TEMP.AA.ARR   = AA.Framework.AaArrangement
    BEGIN CASE
        CASE TEMP.PROD.ARR EQ TEMP.AA.PROD                                  ;* If its from the designer level
            GOSUB DESIGNER.DEFAULTS                                         ;* Ideally no defaults at the product level
        CASE TEMP.PROD.ARR EQ TEMP.AA.ARR                                   ;* If its from the arrangement level
            GOSUB ARRANGEMENT.DEFAULTS                                      ;* Arrangement defaults
    END CASE
*
    GOSUB COMMON.CROSSVAL
*
    BEGIN CASE
        CASE AF.Framework.getProductArr() EQ AA.Framework.Product
            GOSUB DESIGNER.CROSSVAL                                         ;* Designer specific cross validations
        CASE AF.Framework.getProductArr() EQ AA.Framework.AaArrangement
            GOSUB ARRANGEMENT.CROSSVAL                                      ;* Arrangement specific cross validations
    END CASE
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Designer Defaults>
*** <desc>Do any defaults for Product designer here</desc>
DESIGNER.DEFAULTS:
*
    FIELD.LIST = AO.Framework.TcPermissions.AaTcPermRelCustomer :@FM: AO.Framework.TcPermissions.AaTcPermProductGroups :@FM: AO.Framework.TcPermissions.AaTcPermProductGroupSel :@FM: AO.Framework.TcPermissions.AaTcPermProduct :@FM: AO.Framework.TcPermissions.AaTcPermProductSel  ;* Fields not to be inputted at Design level
*
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arrangement Defaults>
*** <desc>Do any defaults for Arrangement here</desc>
ARRANGEMENT.DEFAULTS:
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Common Crossvalidations>
*** <desc>Common cross-validations for both Product and Arrangement</desc>
COMMON.CROSSVAL:
*
    PRD.GROUPS=AO.Framework.TcPermissions.AaTcPermDefinedProductGroups
    EB.SystemTables.setAf(PRD.GROUPS)
    EB.Template.Dup()                                                                                           ;* Check Duplicate

    AV.CNT=DCOUNT(EB.SystemTables.getRNew(PRD.GROUPS), @VM)
    
    FOR DEFINED.PRD.CNT=1 TO AV.CNT
        EB.SystemTables.setAv(DEFINED.PRD.CNT)                                                                  ;* Error handling for Defined Product Group selction.(If product group is there , then product group sel value will be mandatory)
        IF EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)<1,DEFINED.PRD.CNT> ELSE
            EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)
            EB.SystemTables.setEtext("AO-DFE.INP.MANDATORY":@FM:"defined product group":@VM:"not empty");* Set Error
            EB.ErrorProcessing.StoreEndError()    ;* Raise Error
        END
    NEXT DEFINED.PRD.CNT
*
RETURN
*-----------------------------------------------------------------------------
*** <region name= Designer Crossvalidations>
*** <desc>Product level cross validations</desc>
DESIGNER.CROSSVAL:
    LOOP
        REMOVE tmp.AF FROM FIELD.LIST SETTING SPOS                                                              ;* Remove a field from the application field list
    WHILE tmp.AF:SPOS
        AV.COUNT = DCOUNT(EB.SystemTables.getRNew(tmp.AF), @VM)                                                 ;* count the no. of multi-values
        FOR tmp.AV=1 TO AV.COUNT                                                                                ;* For each multi-value
            EB.SystemTables.setAv(tmp.AV)
            IF EB.SystemTables.getRNew(tmp.AF)<1,tmp.AV> THEN                                                   ;* If there is a value
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setEtext("AA-ALLOW.ARRGT.LEVEL");* Set Error
                EB.ErrorProcessing.StoreEndError()    ;* Raise Error
            END
        NEXT tmp.AV
    REPEAT
    DEFINED.PRODUCT.GRP.CNT=DCOUNT(EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups), @VM)
    FOR TMP.AV=1 TO DEFINED.PRODUCT.GRP.CNT
        EB.SystemTables.setAv(DEFINED.PRD.CNT)                                                                  ;* Error handling for Defined Product Group selction.(If product group is there , then product group sel should not be Exclude)
        IF EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)<1,TMP.AV> EQ 'Exclude' THEN
            EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)
            EB.SystemTables.setEtext("AO-EXCLUDE.PERMISSION");* Set Error
            EB.ErrorProcessing.StoreEndError()    ;* Raise Error
        END
    NEXT TMP.AV
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arrangement Crossvalidations>
*** <desc>Arrangement level cross-validations</desc>
ARRANGEMENT.CROSSVAL:
    GOSUB READ.CURRENT.ARRANGEMENT
*
*   check if current arrangement is a sub-arrangement
    IF masterArrId NE '' THEN
        AO.Framework.TcPermissionsSubarrValidate(masterArrId)                           ;* Validate sub-arrangement against master arrangement
    END
*
    EB.DataAccess.CacheRead("F.COMPANY.CHECK", "FIN.FILE", R.COMPANY.CHECK, ER)         ;*Getting the list of available companies
    COMP.CODE.LIST = R.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode>  ;*Contains the company code in the r.array
    USING.COMP.LIST = R.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingCom>    ;* Defined company field is allowed to accept branch companies
    CONVERT @SM TO @VM IN USING.COMP.LIST
    COMP.CHK.LIST = COMP.CODE.LIST:@VM:USING.COMP.LIST
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedCustomers)
    EB.Template.Dup()                                                                                           ;* Check Duplicate
    DEFINED.CUSTOMER.CNT=DCOUNT(EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomers),@VM)
    FOR DEFINED.CUSTOMER.COUNT=1 TO DEFINED.CUSTOMER.CNT
        IF EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)<1,DEFINED.CUSTOMER.COUNT> EQ '' THEN  ;* if Defined Customer is completed but Defined Customer Sel is blank
            EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)
            EB.SystemTables.setAv(DEFINED.CUSTOMER.COUNT)
            EB.SystemTables.setEtext("EB-INPUT.MISSING")     ;* Set Error
            EB.ErrorProcessing.StoreEndError()               ;* Raise Error
        END
        EB.SystemTables.setAv(DEFINED.CUSTOMER.COUNT)
        EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedCompany)
        EB.Template.Dup()                                                                                       ;* Check Duplicate
        ALLOWED.COMPANY=EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)<1,DEFINED.CUSTOMER.COUNT>
        ALLOWED.COM.CNT = DCOUNT(ALLOWED.COMPANY,@SM)
        GOSUB COMPANY.VALIDATE
    NEXT DEFINED.CUSTOMER.COUNT
*
    IF EB.SystemTables.getEtext() ELSE
        R.CHANNEL.PARAMETER=EB.ARC.ChannelParameter.Read('SYSTEM',E.CHANNEL.PARAMETER )
        LOCATE "Account" IN R.CHANNEL.PARAMETER<EB.ARC.ChannelParameter.CprRelationType,1> SETTING PARAM.REL.ACCT.POS THEN
            PARAM.REL.ACCT.PERMISSION=R.CHANNEL.PARAMETER<EB.ARC.ChannelParameter.CprRelationPermission,PARAM.REL.ACCT.POS> ;* Get relation code for account from channel parameter
            PARAM.REL.ACCT.CODE = R.CHANNEL.PARAMETER<EB.ARC.ChannelParameter.CprRelationCode,PARAM.REL.ACCT.POS>
            ACCT.CNT=DCOUNT(PARAM.REL.ACCT.PERMISSION,@VM)
        END
*
        IF masterArrId EQ '' THEN                                                            ;* This is a master arrangement
* Validation of the master Arrangement against Product Conditions.
*
            GOSUB GET.PRODUCT.CONDITION.DEFINITION

            TMP.PRD.GROUP = AO.Framework.TcPermissions.AaTcPermDefinedProductGroups
            TMP.PRD.GROUP.SEL = AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel
            definedProductGroupList = EB.SystemTables.getRNew(TMP.PRD.GROUP)                 ;* Defined Product Groups
            definedProductGroupSelList  = EB.SystemTables.getRNew(TMP.PRD.GROUP.SEL)         ;* Defined Product Groups Permissions
            GOSUB CHECK.DEF.PRD.GRP.VS.PROD.CONDITION                                        ;* validate arrangement Defined Product Groups against Product Conditions

            PRODUCT.AS.CNT=0
            PRD.GROUP.LIST=''
            REL.CUSTOMER.LIST=''
            TMP.PRD.GROUP = AO.Framework.TcPermissions.AaTcPermProductGroups
            TMP.PRD.GROUP.SEL = AO.Framework.TcPermissions.AaTcPermProductGroupSel
            tmpProductGroupList = EB.SystemTables.getRNew(TMP.PRD.GROUP)                     ;* Defined Product Groups in RelCustomer
            tmpProductGroupSelList  = EB.SystemTables.getRNew(TMP.PRD.GROUP.SEL)             ;* Defined Product Groups Permissions in RelCustomer
            AV.COUNT = DCOUNT(tmpProductGroupList, @VM)
            GOSUB CHECK.PRD.GRP.VS.PROD.CONDITION                                            ;* Validate Relation Customer Product Groups Permissions against Product Conditions
        END
*
*
        TMP.RELATION = AO.Framework.TcPermissions.AaTcPermRelCustomer
        relCustomer = EB.SystemTables.getRNew(TMP.RELATION)
        AV.COUNT = DCOUNT(relCustomer, @VM)                                              ;* Count all Relation Customers in the arrangement
*
* COUNT Relation Customers returns 0 only IF in the arrangement it is one Single RelationCustomer AND IF RelationCustomer field is NULL
        IF AV.COUNT EQ '0' THEN
            TMP.AV   = 1
            CUSTOMER.NO = relCustomer
            GOSUB CHK.RELCUST.EMPTY.FIELDS                                               ;* Check Relation Customer empty fields and throw errors
            GOSUB DEFINED.PRODUCT.GROUP.CHECK
        END
*
* Go through all Relation Customers in the arrangement
        FOR TMP.AV=1 TO AV.COUNT                    ;* For each Relation Customer do
            EB.SystemTables.setAv(TMP.AV)
            GOSUB DEFINED.PRODUCT.GROUP.CHECK
            GOSUB PRODUCT.CROSSVAL
        NEXT TMP.AV
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = CHECK.DEF.PRD.GRP.VS.PROD.CONDITION>
*** <desc> Validate arrangement Defined Product Group Permission against Product Condition Definition</desc>
CHECK.DEF.PRD.GRP.VS.PROD.CONDITION:
* ProductGroups should not be edited at arrangement level, for this reason,
*   Defined Product Groups list in the arrangement must be identical (also in the same order) with Product Groups list in Product Conditions record.

* First step, check if in the arrangement Defined Product Groups list is present a ProductGroup which was removed from Product Condition, in this case remove PrdGrp from the arrangeemnt. This is the case when an arrangement is updated after changes were done in Product Condition
*
    defPrdGroupModified="" ;* DefinedProductGroupList was modified in the arrangement
    defPrdGroupDel=""      ;* DefinedProductGroupList was modified in the product condition
*
    countArrDefinedPrdGrpList = DCOUNT(definedProductGroupList, @VM)                               ;* Count arrangement Defined Product Groups
    cntDefPrdGrp=1
    FOR cntDefPrdGrp=1 TO countArrDefinedPrdGrpList                                                ;* loop through all arrangement Defined Product Groups
        IF definedProductGroupList<1,cntDefPrdGrp> NE '' THEN
            a=definedProductGroupList<1,cntDefPrdGrp>
            b=conditionDefinedProductGroupList
            FIND definedProductGroupList<1,cntDefPrdGrp> IN conditionDefinedProductGroupList SETTING pos ELSE   ;* search current arr DefProductGroup into Product Condition
                defPrdGroupDel=1
                DEL definedProductGroupList<1,cntDefPrdGrp>         ;* delete from DefinedProductGroup the PrdGrp removed from ProductCondition
                DEL definedProductGroupSelList<1,cntDefPrdGrp>      ;* delete also the Permission
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups, definedProductGroupList)            ;* assign to RNew the updated list
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel, definedProductGroupSelList)       ;* assign to RNew the updated list
            END
        END
    NEXT cntDefPrdGrp
    tmpProductGroupList = EB.SystemTables.getRNew(TMP.PRD.GROUP)                      ;* Defined Product Groups
    tmpProductGroupSelList  = EB.SystemTables.getRNew(TMP.PRD.GROUP.SEL)              ;* Defined Product Group Permission
 
* Second step, check if all Product Groups from Product Condition are present in the arrangement, otherwise insert the missing Product Group
*
    defPrdGrpList = RAISE(definedProductGroupList)                                               ;* neccessary for LOCATE
*
    TMP.AV=1
    FOR TMP.AV=1 TO countConditionProductGroups                                                  ;* loop through all Product Groups defined in Product Conditions record
*
        IF conditionDefinedProductGroupList<1,TMP.AV> EQ definedProductGroupList<1,TMP.AV> THEN  ;* if Product Conditions ProductGroup matches arrangement DefinedProductGroup, compare permissions
            arr.TMP.AV = TMP.AV
            tmp.PRD.GRP.POS = TMP.AV
            GOSUB VALIDATE.PERMISSIONS                                                           ;* validate to be within Product Conditions limits
        END ELSE                                                                                 ;* Product Condition Product Group not equal with arrangement Product Group, for current index TMP.AV
            LOCATE conditionDefinedProductGroupList<1,TMP.AV> IN defPrdGrpList SETTING pos THEN  ;* search current Product Conditions ProductGroup, into arrangement Defined Product Groups
                arr.TMP.AV = pos
                tmp.PRD.GRP.POS = TMP.AV
                GOSUB VALIDATE.PERMISSIONS                                                       ;* validate to be within Product Conditions limits
            END ELSE                                                                             ;* inherited Product Conditions Product Group was removed at arrangement level
                defPrdGroupModified=1
                EB.SystemTables.setAf('')
                EB.SystemTables.setText("AO-PRD.COND.NO.CHANGE":@FM:"Defined Product Group")
                EB.OverrideProcessing.StoreOverride('')                                          ;* Throw Override
                definedProductGroupList=INSERT(definedProductGroupList,1,TMP.AV;conditionDefinedProductGroupList<1,TMP.AV>)          ;* reload from Product Condition level the missing/removed DefinedProductGroup
                definedProductGroupSelList=INSERT(definedProductGroupSelList,1,TMP.AV;conditionDefinedProductGroupSelList<1,TMP.AV>) ;* reload Permission from Product Condition level
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups, definedProductGroupList)            ;* assign to RNew the updated list
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel, definedProductGroupSelList)       ;* assign to RNew the updated list
                defPrdGrpList = RAISE(definedProductGroupList)
            END
        END
    NEXT TMP.AV
*
    IF defPrdGroupModified EQ '' AND defPrdGroupDel NE '' THEN
        EB.SystemTables.setAf('')
        EB.SystemTables.setText("AO-LIST.REINITIATED":@FM:"Defined Product Group ":@VM:" the product condition level.")
        EB.OverrideProcessing.StoreOverride('')             ;* Throw Override
    END
*
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name = CHECK.PRD.GRP.VS.PROD.CONDITION>
*** <desc> Validate Relation Customer Product Groups Permission against Product Condition Definition</desc>
CHECK.PRD.GRP.VS.PROD.CONDITION:
* for each Relation Customer
    FOR TMP.AV=1 TO AV.COUNT
        EB.SystemTables.setAv(TMP.AV)
        tmpProductGroup = tmpProductGroupList<1,TMP.AV>
        tmpProductGroupSel = tmpProductGroupSelList<1,TMP.AV>
    
        LOCATE tmpProductGroup IN conditionDefinedProductGroupList<1,1> SETTING tmp.PRD.GRP.POS THEN     ;* Locate Relation Customer Product Group in Product Condition
            conditionDefinedProductGroup = conditionDefinedProductGroupList<1,tmp.PRD.GRP.POS>           ;* Product Group from Product Condition
            conditionDefinedProductGroupSel = conditionDefinedProductGroupSelList<1,tmp.PRD.GRP.POS>     ;* Product Group Permission from Product Condition
            arr.TMP.AV=TMP.AV
            GOSUB VALIDATE.PERMISSIONS                                                                   ;* to be within Product Codnitions limits
        END
    NEXT TMP.AV
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PRODUCT.CONDITION.DEFINITION>
*** <desc>Get the definition from Product Condition of the AA Product</desc>
GET.PRODUCT.CONDITION.DEFINITION:
    Currency = ''                                                                                   ;* Currency
    EffectiveDate = ''                                                                              ;* Effective Date
    OutPropertyList = ''                                                                            ;* Property List
    OutPropertyClassList = ''                                                                       ;* Property Class List
    OutArrangementLinkType = ''                                                                     ;* Arrangement Link Type
    OutPropertyConditionList = ''                                                                   ;* Property Condition List
    RetErr = ''                                                                                     ;* Error Return
    AaProduct = productId                                                                           ;* AA Product ID
    AA.ProductFramework.GetProductConditionRecords(AaProduct, Currency, EffectiveDate, OutPropertyList, OutPropertyClassList, OutArrangementLinkType, OutPropertyConditionList, RetErr)
    LOCATE 'TC.PERMISSIONS' IN OutPropertyClassList SETTING permPos THEN
        permissionsRec = RAISE(OutPropertyConditionList<permPos>)                                   ;* Permissions Record
        conditionDefinedProductGroupList = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedProductGroups>      ;* Product Groups
        conditionDefinedProductGroupSelList = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel> ;* Permission for Product Groups
        countConditionProductGroups = DCOUNT(conditionDefinedProductGroupList, @VM)                                     ;* Count ProductGroups defined in Product Conditions record
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DEFINED.PRODUCT.GROUP.CHECK>
*** <desc>Relation Customer Product Group Validation</desc>
DEFINED.PRODUCT.GROUP.CHECK:
    TMP.PRD.GROUP = AO.Framework.TcPermissions.AaTcPermProductGroups
    definedProductGroupList = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups)
    IF EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV> EQ '' THEN                                                  ;* If current Product Group is null, do not check if RelCust ProductGroup is Duplicate or Undefined
        RETURN
    END
*
    LOCATE relCustomer<1,TMP.AV> IN REL.CUSTOMER.LIST<1,1> SETTING CUS.POS THEN                                     ;* Check whether the relation customer already defined in Relation Customers list
        LOCATE EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV> IN PRD.GROUP.LIST<1,1> SETTING GROUP.POS THEN       ;* Check whether the product group already defined for that particular relation customer
            IF CUS.POS EQ GROUP.POS THEN                                                                            ;* Error handling for Duplicate entry with same relation customer and product groups
                EB.SystemTables.setAf(TMP.PRD.GROUP)
                EB.SystemTables.setAv(TMP.AV)
                EB.SystemTables.setEtext("AA-DUPLICATE.LINE.DEFINITION")                                            ;* Set Error
                EB.ErrorProcessing.StoreEndError()                                                                  ;* Raise Error
            END
        END ELSE
            IF NOT(EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV> MATCHES definedProductGroupList) THEN         ;* Error handling for undefined product group
                EB.SystemTables.setAf(TMP.PRD.GROUP)
                EB.SystemTables.setEtext("AO-NOT.IN.DEFINED.PRODUCT.GROUP":@FM:EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV>)
                EB.ErrorProcessing.StoreEndError()                                                                               ;* Raise Error
            END
        END
    END ELSE
        IF NOT(EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV> MATCHES definedProductGroupList) THEN             ;* Error handling for undefined product group
            EB.SystemTables.setAf(TMP.PRD.GROUP)
            EB.SystemTables.setEtext("AO-NOT.IN.DEFINED.PRODUCT.GROUP":@FM:EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV>)     ;* Set Error
            EB.ErrorProcessing.StoreEndError()                                                                                   ;* Raise Error
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Product Validations>
*** <desc>Product cross-validations for current Relation Customer</desc>
PRODUCT.CROSSVAL:
*
    CUSTOMER.NO=EB.SystemTables.getRNew(TMP.RELATION)<1,TMP.AV>              ;* current Relation Customer
*
    REL.CUSTOMER.LIST<1,-1>=CUSTOMER.NO                                      ;* build an array with Relation Customers already/previously read in the loop
    PRD.GROUP.LIST<1,-1>=EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV>    ;* build an array with Product Groups
*
    ALLOWED.PRODUCTS=''
    DEFINED.COMPANY=EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)
    DEFINED.CUSTOMER=EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomers)
    DEFINED.CUSTOMER.SEL=EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)
    DEF.CUST = RAISE(DEFINED.CUSTOMER)
    LOCATE CUSTOMER.NO IN DEF.CUST SETTING DEFINED.CUS.POS THEN
        ALLOWED.COMPANY=DEFINED.COMPANY<1,DEFINED.CUS.POS>
        IF DEFINED.CUSTOMER.SEL<1,DEFINED.CUS.POS> EQ 'No' OR DEFINED.CUSTOMER.SEL<1,DEFINED.CUS.POS> EQ '' THEN  ;* if RelationCustomer is found in Defined Allowed Customers list, but permission is 'No'
            EB.SystemTables.setAf(TMP.RELATION)
            EB.SystemTables.setEtext("AO-NOT.DEFINED.CUSTOMER":@FM:EB.SystemTables.getRNew(TMP.RELATION)<1,TMP.AV>)     ;* Set Error
            EB.ErrorProcessing.StoreEndError()                                                                          ;* Raise Error
        END
    END ELSE
        EB.SystemTables.setAf(TMP.RELATION)                                                                         ;* current Relation Customer is not found in the Defined (Allowed) Customers list
        EB.SystemTables.setEtext("AO-NOT.DEFINED.CUSTOMER":@FM:EB.SystemTables.getRNew(TMP.RELATION)<1,TMP.AV>)     ;* Set Error
        EB.ErrorProcessing.StoreEndError()                                                                          ;* Raise Error
    END
*
    GOSUB CHK.RELCUST.EMPTY.FIELDS                                                                                  ;* Check Relation Customer empty fields and throw errors
*
    PRODUCT.GROUP=EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV>
    EB.ARC.ListAllowedProducts(productId, CUSTOMER.NO, PRODUCT.GROUP, ALLOWED.COMPANY, ALLOWED.PRODUCTS)            ;* when EB.SystemTables.getEtext() NE '', then Product check is not done and ALLOWED.PRODUCTS is returned NULL, because the flow exits from the EB.ARC method without processing.
    IF ALLOWED.PRODUCTS NE "" THEN
        CHANGE @FM TO @VM IN ALLOWED.PRODUCTS
        CHANGE '*' TO @VM IN ALLOWED.PRODUCTS
* EB.ARC.ListAllowedProducts(ProductId, EB.SystemTables.getRNew(TMP.RELATION)<1,TMP.AV>, EB.SystemTables.getRNew(PRODUCT.ID,TMP.PRD.GROUP)<1,TMP.AV>, ALLOWED.COMPANY,ALLOWED.PRODUCTS)
        PRODUCT.AS.CNT=0
        PRODUCT.LIST=EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProduct)<1,TMP.AV>
        R.PRODUCT.GROUP=AA.ProductFramework.ProductGroup.Read(EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV>, PRODUCT.GROUP.ERR)
        DEFINED.PRD.GRP.SEL=EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)
        PROCESSED.PRD.ID = ''                                                                                              ;* Variable to hold already processed product ids, to find out the duplicate product ID under the same customer
        LOOP
            REMOVE PRD.ID FROM PRODUCT.LIST SETTING PRD.POS
        WHILE PRD.ID:PRD.POS
            PRODUCT.AS.CNT=PRODUCT.AS.CNT+1
            IF PRD.ID NE "" THEN                                                                                               ;* to not throw Duplicate error when the Product is empty
                LOCATE PRD.ID IN PROCESSED.PRD.ID<1,1> SETTING PRC.PRD.POS THEN                                                ;* Locate in already processed product list - Duplicate Product given
                    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProduct)                                          ;* Field for Error
                    EB.SystemTables.setAv(TMP.AV)
                    EB.SystemTables.setAs(PRODUCT.AS.CNT)
                    EB.SystemTables.setEtext("AA-DUPLICATE.LINE.DEFINITION")                                                   ;* Set Error
                    EB.ErrorProcessing.StoreEndError()                                                                         ;* Raise Error
                END

                LOCATE PRD.ID IN ALLOWED.PRODUCTS<1,1> SETTING PRODUCT.POS THEN
                    GOSUB ARR.OTHER.PRODUCT.CROSSVAL
                    GOSUB ARR.PRODUCT.CROSSVAL                                                                                 ;* Product Validation
                END ELSE
* If wrong product entered,Raise error
                    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProduct)
                    EB.SystemTables.setAv(TMP.AV)
                    EB.SystemTables.setAs(PRODUCT.AS.CNT)
                    EB.SystemTables.setEtext("EB-WRONG.PRODUCT.SELECTED")                                                      ;* Set Error
                    EB.ErrorProcessing.StoreEndError()                                                                         ;* Raise Error
                END
                PROCESSED.PRD.ID<1,-1> = PRD.ID                                                                                ;* Update processed product IDs to check the duplicate
            END
        REPEAT
    END ELSE
        IF EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProduct)<1,TMP.AV> NE '' AND CUSTOMER.NO NE '' AND PRODUCT.GROUP NE '' AND EB.SystemTables.getEtext() EQ '' THEN
* If not Allowed Products found for Customer and ProductGroup
            EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProduct)
            EB.SystemTables.setAv(TMP.AV)
            EB.SystemTables.setEtext("EB-WRONG.PRODUCT.SELECTED")
            EB.ErrorProcessing.StoreEndError()                                                                                 ;* Raise Error
        END
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ARR.OTHER.PRODUCT.CROSSVAL>
*** <desc>Other product validation</desc>
ARR.OTHER.PRODUCT.CROSSVAL:
    IF ((R.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductLine> EQ 'OTHER' AND R.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductType> EQ 'AC') OR R.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductLine> EQ 'ACCOUNT') AND (ALLOWED.PRODUCTS<1,PRODUCT.POS+3> EQ 'See' AND EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)<1,TMP.AV,PRODUCT.AS.CNT> EQ "Transact") THEN
        EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProduct)
        EB.SystemTables.setAv(TMP.AV)
        EB.SystemTables.setAs(PRODUCT.AS.CNT)
        EB.SystemTables.setEtext("AO-PRODUCT.PERMISSION":@FM:EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)<1,TMP.AV,PRODUCT.AS.CNT>) ;* Set Error
        EB.ErrorProcessing.StoreEndError()                                                                                                                    ;* Raise Error
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ARR.PRODUCT.CROSSVAL>
*** <desc>Product Cross Validation</desc>
ARR.PRODUCT.CROSSVAL:
    LOCATE EB.SystemTables.getRNew(TMP.PRD.GROUP)<1,TMP.AV> IN conditionDefinedProductGroupList<1,1> SETTING tmp.PRD.GRP.POS THEN                              ;* Locate Product group in Product Condition definition
        conditionDefinedProductGroup = conditionDefinedProductGroupList<1,tmp.PRD.GRP.POS>                                                                     ;* Product Group from Product Condition
        conditionDefinedProductGroupSel = conditionDefinedProductGroupSelList<1,tmp.PRD.GRP.POS>                                                               ;* Product Group Permission from Product Condition
        BEGIN CASE
            CASE conditionDefinedProductGroupSel EQ 'See' AND EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)<1,TMP.AV,PRODUCT.AS.CNT> EQ 'Transact'     ;* Overriding the permission with product condition definition
                EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductSel)
                EB.SystemTables.setAv(TMP.AV)
                EB.SystemTables.setAs(PRODUCT.AS.CNT)
                EB.SystemTables.setEtext("AO-PRODUCT.PERMISSION":@FM:EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)<1,TMP.AV,PRODUCT.AS.CNT>)           ;* Set Error
                EB.ErrorProcessing.StoreEndError()                                                                                                                              ;* Raise Error
            CASE conditionDefinedProductGroupSel EQ 'Exclude' AND EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)<1,TMP.AV,PRODUCT.AS.CNT> MATCHES 'See':@VM:'Transact' ;* Overriding the permission with product condition definition
                EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductSel)
                EB.SystemTables.setAv(TMP.AV)
                EB.SystemTables.setAs(PRODUCT.AS.CNT)
                EB.SystemTables.setEtext("AO-PRODUCT.PERMISSION":@FM:EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)<1,TMP.AV,PRODUCT.AS.CNT>)           ;* Set Error
                EB.ErrorProcessing.StoreEndError()                                                                                                                              ;* Raise Error
        END CASE
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= COMPANY.VALIDATE>
*** <desc>Check the valid company</desc>
COMPANY.VALIDATE:
    BEGIN CASE
        CASE EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)<1,DEFINED.CUSTOMER.COUNT> AND EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)<1,DEFINED.CUSTOMER.COUNT> NE "ALL"
            LOCATE "ALL" IN EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)<1,DEFINED.CUSTOMER.COUNT,1> SETTING ALLOWED.COM.POS THEN ;* Find "ALL" in defined company list
                IF ALLOWED.COM.CNT GT 1 THEN                                                                ;* Throw error when both individual companies and ALL defined
                    EB.SystemTables.setAs(ALLOWED.COM.POS)

                    EB.SystemTables.setEtext("EB-OPTION.ALL.NOT.ALLOWED")                                   ;* Set Error
                    EB.ErrorProcessing.StoreEndError()                                                      ;* Raise Error
                END
            END ELSE
                FOR COMPANY.CNT=1 TO ALLOWED.COM.CNT
                    GOSUB CHECK.VALID.COMPANY
                NEXT COMPANY.CNT
            END
        CASE EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)<1,DEFINED.CUSTOMER.COUNT> EQ '' ;* Defined Company should not be null
            EB.SystemTables.setEtext("EB-INPUT.MISSING")                                                                ;* Set Error
            EB.ErrorProcessing.StoreEndError()                                                                          ;* Raise Error
    END CASE
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.VALID.COMPANY>
*** <desc>Check the valid company</desc>
CHECK.VALID.COMPANY:
    LOCATE EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)<1,DEFINED.CUSTOMER.COUNT,COMPANY.CNT> IN COMP.CHK.LIST<1,1> SETTING COM.POS ELSE ;* locate a valid company
        EB.SystemTables.setAs(COMPANY.CNT)
        EB.SystemTables.setEtext("EB-COMPANY.CODE.DEFINITION.MISS")                                                     ;* Set Error
        EB.ErrorProcessing.StoreEndError()                                                                              ;* Raise Error
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.CURRENT.ARRANGEMENT>
*** <desc>Read current arrangement</desc>
READ.CURRENT.ARRANGEMENT:
    currentArrangement= AA.Framework.getArrId()
    arrangementRecord = AA.Framework.Arrangement.Read(currentArrangement, errMsg)              ;* Read current arrangement
    masterArrId       = arrangementRecord<AA.Framework.Arrangement.ArrMasterArrangement>       ;* If masterArrangement is not null, current arrangement is a sub-arrangement
    productId         = arrangementRecord<AA.Framework.Arrangement.ArrProduct>                 ;* Get Product ID
    productGroupId    = arrangementRecord<AA.Framework.Arrangement.ArrProductGroup>            ;* Get Product Group ID
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VALIDATE.PERMISSIONS>
*** <desc>Validate permissions</desc>
VALIDATE.PERMISSIONS:
* arrangement permission cannot be higher than in Product Condition. the order from high to low permission is: Transact, See, Exclude
    BEGIN CASE
        CASE conditionDefinedProductGroupSelList<1,tmp.PRD.GRP.POS> EQ 'See' AND tmpProductGroupSelList<1,arr.TMP.AV> EQ 'Transact'
            EB.SystemTables.setAf(TMP.PRD.GROUP.SEL)
            EB.SystemTables.setAv(arr.TMP.AV)
            EB.SystemTables.setEtext("AO-PRODUCT.PERMISSION":@FM:EB.SystemTables.getRNew(TMP.PRD.GROUP.SEL)<1,arr.TMP.AV>) ;* Set Error
            EB.ErrorProcessing.StoreEndError()                                                                             ;* Raise Error
        CASE conditionDefinedProductGroupSelList<1,tmp.PRD.GRP.POS> EQ 'Exclude' AND tmpProductGroupSelList<1,arr.TMP.AV> MATCHES 'See':@VM:'Transact'
            EB.SystemTables.setAf(TMP.PRD.GROUP.SEL)
            EB.SystemTables.setAv(arr.TMP.AV)
            EB.SystemTables.setEtext("AO-PRODUCT.PERMISSION":@FM:EB.SystemTables.getRNew(TMP.PRD.GROUP.SEL)<1,arr.TMP.AV>) ;* Set Error
            EB.ErrorProcessing.StoreEndError()                                                                             ;* Raise Error
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHK.RELCUST.EMPTY.FIELDS>
*** <desc>Check Empty fields in current Relation Customer</desc>
CHK.RELCUST.EMPTY.FIELDS:
    TMP.RC.PRDGRP     = AO.Framework.TcPermissions.AaTcPermProductGroups
    TMP.RC.PRDGRP.SEL = AO.Framework.TcPermissions.AaTcPermProductGroupSel
    TMP.RC.PRD        = AO.Framework.TcPermissions.AaTcPermProduct
    TMP.RC.PRD.SEL    = AO.Framework.TcPermissions.AaTcPermProductSel
    vRCPrdGrp    = EB.SystemTables.getRNew(TMP.RC.PRDGRP)<1,TMP.AV>                                           ;* read Product Group at Relation Customer level
    vRCPrdGrpSel = EB.SystemTables.getRNew(TMP.RC.PRDGRP.SEL)<1,TMP.AV>                                       ;* read Product Group Permission at Relation Customer level
    vRCPrdMv     = EB.SystemTables.getRNew(TMP.RC.PRD)<1,TMP.AV>                                              ;* read Product multi value set at Relation Customer level
    vRCPrdSelMv  = EB.SystemTables.getRNew(TMP.RC.PRD.SEL)<1,TMP.AV>                                          ;* read Product Permission multi value set at Relation Customer level
*
*   if all Relation Customer related fields are empty, return
    IF CUSTOMER.NO EQ "" AND vRCPrdGrp EQ "" AND vRCPrdGrpSel EQ "" AND vRCPrdMv EQ "" AND vRCPrdSelMv EQ "" THEN
        RETURN
    END
*
*   if Relation Customer field is empty and one of the fields ProductGroup, ProductGroupSel, Product, ProductSel is not empty
    IF CUSTOMER.NO EQ "" AND (vRCPrdGrp NE "" OR vRCPrdGrpSel NE "" OR vRCPrdMv NE "" OR vRCPrdSelMv NE "") THEN
        EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermRelCustomer)
        EB.SystemTables.setAv(TMP.AV)
        EB.SystemTables.setEtext("EB-INPUT.MISSING")                                                          ;* Set Error
        EB.ErrorProcessing.StoreEndError()
    END
*
*   if only one of the ProductGroup or ProductGroupSel is empty, or both are empty but one of the Customer, Product, ProductPermission is not empty
    IF (vRCPrdGrp EQ "" AND vRCPrdGrpSel NE "") OR (vRCPrdGrp NE "" AND vRCPrdGrpSel EQ "") OR (((vRCPrdGrp EQ "" AND vRCPrdGrpSel EQ "") OR (vRCPrdGrp NE "" AND vRCPrdGrpSel NE "")) AND (CUSTOMER.NO NE "" OR vRCPrdMv NE "" OR vRCPrdSelMv NE "")) THEN
        IF vRCPrdGrp EQ "" THEN
            EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductGroups)                           ;* Product Group empty
            EB.SystemTables.setAv(TMP.AV)
            EB.SystemTables.setEtext("EB-INPUT.MISSING")                                                      ;* Set Error
            EB.ErrorProcessing.StoreEndError()
        END
*
*
* Count number of Products and of ProductSel in current Relation Customer
        RC.PRD.COUNT    = DCOUNT(vRCPrdMv, @SM)                                                               ;* count Product in multi value sets
        RC.PRDSEL.COUNT = DCOUNT(vRCPrdSelMv, @SM)                                                            ;* count ProductSel in multi value sets
        PRD.CNT         = MAXIMUM(RC.PRD.COUNT :@AM: RC.PRDSEL.COUNT)
*
* If Products and ProductSel are not defined AND PrdGrpSel is null
        IF PRD.CNT EQ 0 AND vRCPrdGrpSel EQ "" AND vRCPrdGrp NE "" THEN
            EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductGroupSel)                         ;* Product Group Permission empty
            EB.SystemTables.setAv(TMP.AV)
            EB.SystemTables.setEtext("EB-INPUT.MISSING")                                                      ;* Set Error
            EB.ErrorProcessing.StoreEndError()
        END
*
* Loop through all Products
        FOR TMP.AS = 1 TO PRD.CNT
            vRCPrd = EB.SystemTables.getRNew(TMP.RC.PRD)<1,TMP.AV,TMP.AS>
            vRCPrdSel = EB.SystemTables.getRNew(TMP.RC.PRD.SEL)<1,TMP.AV,TMP.AS>
*
*       if null Product and/or ProductPermission
            IF vRCPrd EQ "" AND vRCPrdSel NE "" THEN
                EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProduct)                             ;* Product null
                EB.SystemTables.setAv(TMP.AV)
                EB.SystemTables.setAs(TMP.AS)
                EB.SystemTables.setEtext("EB-INPUT.MISSING")                                                  ;* Set Error
                EB.ErrorProcessing.StoreEndError()
            END
            IF vRCPrd NE "" AND vRCPrdSel EQ "" THEN
                EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductSel)                          ;* Product Permission null
                EB.SystemTables.setAv(TMP.AV)
                EB.SystemTables.setAs(TMP.AS)
                EB.SystemTables.setEtext("EB-INPUT.MISSING")                                                  ;* Set Error
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT TMP.AS
*
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
END
