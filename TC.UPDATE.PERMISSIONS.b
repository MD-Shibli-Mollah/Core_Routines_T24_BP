* @ValidationCode : Mjo2NzQ2MjQyNDE6Q3AxMjUyOjE1Mjg5NjE4OTQwNzc6ZG1hdGVpOjM6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA2LjA6MzQ0OjMyMA==
* @ValidationInfo : Timestamp         : 14 Jun 2018 10:38:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 320/344 (93.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE TC.UPDATE.PERMISSIONS(SubarrangementId,OfsArrActivityRecord)
*-----------------------------------------------------------------------------
* This routine is called from AA.TC.PRIVILEGES.UPDATE.SUBARR
* Routine used for Master Update validations, for Permissions property, in order to update sub-arrangements
* The routine include changes for Permissions into AA.Arrangement.Activity record that will be sent with OFS message
*-----------------------------------------------------------------------------
* In/out parameters:
* SubarrangementId - string, INOUT
* OfsArrActivityRecord - string, INOUT
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History:
*
* 12/02/2018 - Enhancement 2379129 / Task 2433777
*              Master update validations for Permissions
*
*
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table
*
*** </region>
*-----------------------------------------------------------------------------
    $USING AO.Framework
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB Process
RETURN
*-----------------------------------------------------------------------------
Process:
    GOSUB GetMasterArrangementPermissionsData
    GOSUB GetSubArrangementPermissionsData
    GOSUB DoPermissionsValidations
    GOSUB CompleteMasterLvlChange
RETURN
*-----------------------------------------------------------------------------
GetMasterArrangementPermissionsData:
*   retrieve masterArrangement data, for TC.PERMISSIONS property, to read new permissions
    masterArrangementId = AA.Framework.getArrId()
    aaPropertyClassId = 'TC.PERMISSIONS'
    permissionsRec=''
    retErr = ''
    AA.ProductFramework.GetPropertyRecord('', masterArrangementId, '', '', aaPropertyClassId, '', permissionsRec, retErr)
    IF retErr EQ '' AND permissionsRec NE '' THEN
        maArrDefinedCustomer        = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedCustomers>
        maArrDefinedCompany         = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedCompany>
        maArrDefinedCustomersSel    = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel>
*
        maArrDefinedProductGroups   = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedProductGroups>
        maArrDefinedProductGroupSel = permissionsRec<AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel>
*
        maArrRelCustomer            = permissionsRec<AO.Framework.TcPermissions.AaTcPermRelCustomer>
        maArrProductGroups          = permissionsRec<AO.Framework.TcPermissions.AaTcPermProductGroups>
        maArrProductGroupSel        = permissionsRec<AO.Framework.TcPermissions.AaTcPermProductGroupSel>
*
        maArrProduct                = permissionsRec<AO.Framework.TcPermissions.AaTcPermProduct>
        maArrProductSel             = permissionsRec<AO.Framework.TcPermissions.AaTcPermProductSel>
    END
RETURN
*-----------------------------------------------------------------------------
GetSubArrangementPermissionsData:
*   retrieve subArrangement data for current SubarrangementId received in Input variable, to read TC.PERMISSIONS property
    aaPropertyClassId = 'TC.PERMISSIONS'
    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    AA.Framework.GetArrangementConditions(SubarrangementId, aaPropertyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for Protection Limit Property class
    IF retErr EQ '' AND propertyRecords NE '' THEN
        subArrDefinedCustomer         = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedCustomers>
        subArrDefinedCompany          = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedCompany>
        subArrDefinedCustomersSel     = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel>
*
        subArrDefinedProductGroups    = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedProductGroups>
        subArrDefinedProductGroupSel  = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel>
*
        subArrRelCustomer             = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermRelCustomer>
        subArrProductGroups           = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProductGroups>
        subArrProductGroupSel         = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProductGroupSel>
*
        subArrProduct                 = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProduct>
        subArrProductSel              = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProductSel>

        CONVERT @VM TO @FM IN subArrDefinedCustomer
        CONVERT @SM TO @VM IN subArrDefinedCustomer
        CONVERT @TM TO @SM IN subArrDefinedCustomer
*
        CONVERT @VM TO @FM IN subArrDefinedCompany
        CONVERT @SM TO @VM IN subArrDefinedCompany
        CONVERT @TM TO @SM IN subArrDefinedCompany
*
        CONVERT @VM TO @FM IN subArrDefinedCustomersSel
        CONVERT @SM TO @VM IN subArrDefinedCustomersSel
        CONVERT @TM TO @SM IN subArrDefinedCustomersSel
*
*
        CONVERT @VM TO @FM IN subArrDefinedProductGroups
        CONVERT @SM TO @VM IN subArrDefinedProductGroups
        CONVERT @TM TO @SM IN subArrDefinedProductGroups
*
        CONVERT @VM TO @FM IN subArrDefinedProductGroupSel
        CONVERT @SM TO @VM IN subArrDefinedProductGroupSel
        CONVERT @TM TO @SM IN subArrDefinedProductGroupSel
*
*
        CONVERT @VM TO @FM IN subArrProduct
        CONVERT @SM TO @VM IN subArrProduct
        CONVERT @TM TO @SM IN subArrProduct
*
        CONVERT @VM TO @FM IN subArrProductSel
        CONVERT @SM TO @VM IN subArrProductSel
        CONVERT @TM TO @SM IN subArrProductSel
    END
RETURN
*-----------------------------------------------------------------------------
DoPermissionsValidations:
*   check all permissions, for: Defined Allowed Customer, Defined Product Group, Relation Customer and Relation Customer-Product
    GOSUB CheckAllowedCustomer
    GOSUB CheckDefPermissions
    GOSUB CheckRelCustPermissions
RETURN
*-----------------------------------------------------------------------------
CheckAllowedCustomer:
    IF subArrDefinedCustomer EQ "" THEN
        RETURN
    END
*
*   loop through all Defined Customers in SubArrangement
    subDefCustomer = ''
    subCustPos = ''
    counterCust = 1
    LOOP
        REMOVE subDefCustomer FROM subArrDefinedCustomer SETTING subCustPos
    WHILE subDefCustomer
        masterPosAf=''
        masterPosAv=''
        FIND subDefCustomer IN maArrDefinedCustomer SETTING masterPosAf,masterPosAv THEN
*           Defined Customer is present in Master Arrangement
            GOSUB CheckCompany
            IF maArrDefinedCustomersSel<masterPosAf,masterPosAv> EQ 'No' AND subArrDefinedCustomersSel<1,counterCust> EQ 'Yes' THEN
*               Defined Customer has lower permission in master than in subArr. Update subArr with lower permission
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DEFINED.CUSTOMERS.SEL:":counterCust
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrDefinedCustomersSel<masterPosAf,masterPosAv>
                countFieldName = countFieldName + 1
            END
            IF maArrDefinedCustomersSel<masterPosAf,masterPosAv> EQ 'Yes' AND subArrDefinedCustomersSel<1,counterCust> EQ 'No' THEN
*               Defined Customer has augmented permission in master than in subArr
                masterLvlAugmented = 1
            END
        END ELSE
*           Defined Customers is not present in Master Arrangement - remove DefAllowedCustomer, DefCompany and DefCustomerSel
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DEFINED.CUSTOMERS:":counterCust
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DEFINED.COMPANY:":counterCust
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DEFINED.CUSTOMERS.SEL:":counterCust
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
        END
        counterCust=counterCust+1
    REPEAT
    
*   check Augmented defined customers
    GOSUB CheckAugmentedDefinedCustomers
RETURN
*-----------------------------------------------------------------------------
CheckCompany:
    defCompany = subArrDefinedCompany<1,counterCust>
    subDefCompany = ''
    subCompanyPos = ''
    countCompany = 1
*   loop through all Companies defined in SubArrangement
    LOOP
        REMOVE subDefCompany FROM defCompany SETTING subCompanyPos
    WHILE subDefCompany
        masterCompanyPosAf=''
        masterCompanyPosAv=''
        FIND subDefCompany IN maArrDefinedCompany<masterPosAf,masterPosAv> SETTING masterCompanyPosAf,masterCompanyPosAv THEN
        END ELSE
*           If a Company defined in SubArr is not found in Master Arr, assign string of companies from master to the subArrangement
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DEFINED.COMPANY:":counterCust
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrDefinedCompany<masterPosAf,masterPosAv>
            countFieldName = countFieldName + 1
            BREAK
        END
        countCompany = countCompany + 1
    REPEAT

*   check Augmented company
    GOSUB CheckAugmentedCompany
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedCompany:
*   loop through all Companies defined in master arr, and search each in sub arr. If not found, means it is augmented
    maCompaniesListAgmt = maArrDefinedCompany<masterPosAf,masterPosAv>
    LOOP
        REMOVE maCompanyAgmt FROM maCompaniesListAgmt SETTING MaPosAgmt
    WHILE maCompanyAgmt
        FIND maCompanyAgmt IN defCompany SETTING subCompanyPosAf,subCompanyPosAv THEN
        END ELSE
            masterLvlAugmented = 1
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedDefinedCustomers:
*   loop through all defined Customers in master arr, and search each in sub arr. If not found, means it is augmented

    maCustPosAgmt = ''
    counterCust = 1
    LOOP
        REMOVE maDefCustomerAgmt FROM maArrDefinedCustomer SETTING maCustPosAgmt
    WHILE maDefCustomerAgmt
        FIND maDefCustomerAgmt IN subArrDefinedCustomer SETTING subPosCustAfAgmt,subPosCustAvAgmt THEN
        END ELSE
            masterLvlAugmented = 1
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckDefPermissions:
    IF subArrDefinedProductGroups EQ "" THEN
        RETURN
    END
*   loop through all Defined Product Groups, in subArrangement
    subProductGroup = ''
    subPos = ''
    counterPrGr = 1
    LOOP
        REMOVE subProductGroup FROM subArrDefinedProductGroups SETTING subPos
    WHILE subProductGroup
        masterPosAf=''
        masterPosAv=''
        FIND subProductGroup IN maArrDefinedProductGroups SETTING masterPosAf,masterPosAv THEN
*           Defined Product Group is found in masterArrangement
            IF (maArrDefinedProductGroupSel<masterPosAf,masterPosAv> EQ 'See' AND subArrDefinedProductGroupSel<1, counterPrGr> EQ 'Transact') OR (maArrDefinedProductGroupSel<masterPosAf,masterPosAv> EQ 'Exclude' AND (subArrDefinedProductGroupSel<1, counterPrGr> EQ 'Transact' OR subArrDefinedProductGroupSel<1, counterPrGr> EQ 'See')) THEN
*               Defined Product Group has lower permission in master than in subArr. Update subArr with lower permission
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DEFINED.PRODUCT.GROUP.SEL:":counterPrGr
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrDefinedProductGroupSel<masterPosAf,masterPosAv>
                countFieldName = countFieldName + 1
            END
            IF (maArrDefinedProductGroupSel<masterPosAf,masterPosAv> EQ 'See' AND subArrDefinedProductGroupSel<1, counterPrGr> EQ 'Exclude') OR (maArrDefinedProductGroupSel<masterPosAf,masterPosAv> EQ 'Transact'  AND  (subArrDefinedProductGroupSel<1, counterPrGr> EQ 'Exclude' OR subArrDefinedProductGroupSel<1, counterPrGr> EQ 'See')) THEN
*               Defined Product Group has augmented permission in master than in subArr.
                masterLvlAugmented = 1
            END
        END
        counterPrGr = counterPrGr + 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckRelCustPermissions:
    IF subArrRelCustomer EQ "" THEN
        RETURN
    END
    
    subRelCust = ''
    subPos = ''
    counterSub = 1
*   loop through all Relation Customers in subArrangement
    LOOP
        REMOVE subRelCust FROM subArrRelCustomer SETTING subPos
    WHILE subRelCust
        maRelCust=''
        maPos=''
        
        foundCustInMa=''
        foundCustProdInMa=''
        totalMa = DCOUNT(maArrRelCustomer, @VM)
        counterMa = 1
*       search current subArr Relation Customer into masterArrangement
        LOOP WHILE counterMa LE totalMa
            IF subRelCust EQ maArrRelCustomer<1, counterMa> THEN   ;* subArr Relation Customer is found in master
                foundCustInMa=1
            END
            IF subRelCust EQ maArrRelCustomer<1, counterMa> AND (subArrProductGroups<1, 1, counterSub> EQ maArrProductGroups<1, counterMa>) THEN
*               subArr Relation Customer is found in master, and also is found the Relation Customer Product Group
                GOSUB CompareCusPermissions
                GOSUB CheckProductPermissions
                foundCustProdInMa=1
                BREAK
            END
            counterMa = counterMa + 1
        REPEAT
        IF foundCustInMa EQ '' OR (foundCustInMa EQ 1 AND foundCustProdInMa EQ '') THEN
            GOSUB RemoveRelCust
        END
        counterSub = counterSub + 1
    REPEAT
    
*   check Augmented Relation Customers
    GOSUB CheckAugmentedRelationCustomers
RETURN
*-----------------------------------------------------------------------------
CompareCusPermissions:
    IF (maArrProductGroupSel<1, counterMa> EQ 'See' AND subArrProductGroupSel<1, 1, counterSub> EQ 'Transact') OR (maArrProductGroupSel<1, counterMa> EQ 'Exclude' AND (subArrProductGroupSel<1, 1, counterSub> EQ 'Transact' OR subArrProductGroupSel<1, 1, counterSub> EQ 'See')) THEN
*       For current Relation Customer and current Product Group, master has lower permission than subArr. Update subArr with lower permission.
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT.GROUP.SEL:":counterSub
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrProductGroupSel<1, counterMa>
        countFieldName = countFieldName + 1
    END
    
    IF (maArrProductGroupSel<1, counterMa> EQ 'See' AND subArrProductGroupSel<1, 1, counterSub> EQ 'Exclude') OR (maArrProductGroupSel<1, counterMa> EQ 'Transact' AND (subArrProductGroupSel<1, 1, counterSub> EQ 'Exclude' OR subArrProductGroupSel<1, 1, counterSub> EQ 'See')) THEN
*       For current Relation Customer and current Product Group, master has augmented permission than subArr
        masterLvlAugmented=1
    END
RETURN
*-----------------------------------------------------------------------------
RemoveRelCust:
*   Either subArr Relation Customer is not found in masterArr, or is not found in master RelationCustomer-ProductGroup. Remove Relation Customer from subArr.
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "REL.CUSTOMER:":counterSub
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
    countFieldName = countFieldName + 1
            
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT.GROUPS:":counterSub
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
    countFieldName = countFieldName + 1
            
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT.GROUP.SEL:":counterSub
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
    countFieldName = countFieldName + 1
            
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT:":counterSub
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
    countFieldName = countFieldName + 1
            
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT.SEL:":counterSub
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
    countFieldName = countFieldName + 1
RETURN
*-----------------------------------------------------------------------------
CheckProductPermissions:
*   extract list of Products and Product Permissions, for current RelationCustomer-ProductGroup, from subArr and masterArr
    subProduct=subArrProduct<1, counterSub>
    subProductSel=subArrProductSel<1, counterSub>
    maProduct=maArrProduct<1, counterMa>
    maProductSel=maArrProductSel<1, counterMa>
    
    subProd = ''
    subProdPos = ''
    counterProdSub = 1
*   loop through all Products existing in subArr, for current RelationCustomer-ProductGroup
    LOOP
        REMOVE subProd FROM subProduct SETTING subProdPos
    WHILE subProd
        masterPos = ""
        totalMa = DCOUNT(maProduct, @SM)
        countProdMa=1
        foundProductInMa=''
*       search in master, in the list with all Products existing for current RelationCustomer-ProductGroup
        LOOP WHILE countProdMa LE totalMa
            IF subProd EQ maArrProduct<1,counterMa,countProdMa> THEN
*               the Product is found in masterArr
                foundProductInMa=1
                IF (maArrProductSel<1, counterMa, countProdMa> EQ 'See' AND subArrProductSel<1, counterSub, counterProdSub> EQ 'Transact') OR (maArrProductSel<1, counterMa, countProdMa> EQ 'Exclude' AND (subArrProductSel<1, counterSub, counterProdSub> EQ 'Transact' OR subArrProductSel<1, counterSub, counterProdSub> EQ 'See')) THEN
*                   The current Product from RelationCustomer-ProductGroup, has lower permissions in master than in subArr. Update subArr with lower permission.
                    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT.SEL:":counterSub:":":counterProdSub
                    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrProductSel<1, counterMa, countProdMa>
                    countFieldName = countFieldName + 1
                END
            
                IF (maArrProductSel<1, counterMa, countProdMa> EQ 'See' AND subArrProductSel<1, counterSub, counterProdSub> EQ 'Exclude') OR (maArrProductSel<1, counterMa, countProdMa> EQ 'Transact' AND (subArrProductSel<1, counterSub, counterProdSub> EQ 'Exclude' OR subArrProductSel<1, counterSub, counterProdSub> EQ 'See')) THEN
*                   The current Product from RelationCustomer-ProductGroup, has augmented permissions in master than in subArr
                    masterLvlAugmented=1
                END
            END
            countProdMa = countProdMa + 1
        REPEAT
        IF foundProductInMa EQ '' THEN
*           The current Product from RelationCustomer-ProductGroup was not found in master. Remove it from subArrangement.
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT:":counterSub:":":counterProdSub
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
                    
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "PRODUCT.SEL:":counterSub:":":counterProdSub
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
        END
        counterProdSub = counterProdSub + 1
    REPEAT
    
*   check Augmented Products
    GOSUB CheckAugmentedProducts
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedRelationCustomers:
    counterMaAgmt = 1
*   loop through all Relation Customers in masterArrangement, to check if there are more Customers defined than in subArr
    LOOP
        REMOVE maRelCustAgmt FROM maArrRelCustomer SETTING maPosAgmt
    WHILE maRelCustAgmt
        foundCustInSubAgmt=''
        foundCustProdInSubAgmt=''
        totalCustSubAgmt = DCOUNT(subArrRelCustomer, @SM)
        counterSubAgmt = 1
*       search current master Arr Relation Customer into sub Arrangement
        LOOP WHILE counterSubAgmt LE totalCustSubAgmt
            IF maRelCustAgmt EQ subArrRelCustomer<1, 1, counterSubAgmt> THEN   ;* master Relation Customer is found in subArr
                foundCustInSubAgmt=1
            END
            IF maRelCustAgmt EQ subArrRelCustomer<1, 1, counterSubAgmt> AND (maArrProductGroups<1, counterMaAgmt> EQ subArrProductGroups<1, 1, counterSubAgmt>) THEN
*               masterArr Relation Customer is found in sub Arr, and also is found the Relation Customer-Product Group
                foundCustProdInSubAgmt=1
                BREAK
            END
            counterSubAgmt = counterSubAgmt + 1
        REPEAT
        IF foundCustInSubAgmt EQ '' OR (foundCustInSubAgmt EQ 1 AND foundCustProdInSubAgmt EQ '') THEN
            masterLvlAugmented = 1
        END
        counterMaAgmt = counterMaAgmt + 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedProducts:
    subProduct=subArrProduct<1, counterSub>
    subProductSel=subArrProductSel<1, counterSub>
    maProduct=maArrProduct<1, counterMa>
    maProductSel=maArrProductSel<1, counterMa>
    
    maProdAgmt = ''
    maProdPosAgmt = ''
*   loop through all Products existing in maArr, for current RelationCustomer-ProductGroup
    LOOP
        REMOVE maProdAgmt FROM maProduct SETTING maProdPosAgmt
    WHILE maProdAgmt

        totalSubAgmt = DCOUNT(subProduct, @SM)
        countProdSubAgmt=1
        foundProductInSubAgmt=''
*       search in subArrangement, in the list with all Products existing for current RelationCustomer-ProductGroup
        LOOP WHILE countProdSubAgmt LE totalSubAgmt
            IF maProdAgmt EQ subArrProduct<1,counterSub,countProdSubAgmt> THEN
*               the Product is found in subArr
                foundProductInSubAgmt=1
            END
            countProdSubAgmt = countProdSubAgmt + 1
        REPEAT
    
        IF foundProductInSubAgmt EQ '' THEN
*           The current Product from master RelationCustomer-ProductGroup was not found in subArr.
            masterLvlAugmented=1
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CompleteMasterLvlChange:
    tempDate = OCONV(DATE(),'D-')
    tempDate = tempDate[7,4]:tempDate[1,2]:tempDate[4,2]
    tempTime =  OCONV(TIME(),'MTS')
    tempTime = tempTime[1,2]:tempTime[4,2]
    timeStamp = tempDate:tempTime
    IF countFieldName GT '1' THEN
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,-1> = "TCPERMISSIONS"
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "MASTER.LVL.CHANGE:1:1"
        IF masterLvlAugmented EQ '' THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "RESTRICTED-":timeStamp
        END ELSE
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "CHANGED-":timeStamp
        END
    END ELSE
        IF masterLvlAugmented NE '' THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,-1> = "TCPERMISSIONS"
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "MASTER.LVL.CHANGE:1:1"
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "AUGMENTED-":timeStamp
        END
    END
RETURN
*-----------------------------------------------------------------------------
Initialise:
    countVM=1
    countFieldName=1
    masterLvlAugmented=''
*
    IF OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty> NE "" THEN
        countVM = DCOUNT(OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty>, @VM) + 1
    END
RETURN
*-----------------------------------------------------------------------------
END
