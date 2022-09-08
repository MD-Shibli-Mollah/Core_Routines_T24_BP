* @ValidationCode : MjotNjQxMTIwMjg4OkNwMTI1MjoxNTQ0MDA2OTg4NDQ4OnJ0YW5hc2U6MTk6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTozNTE6MzE5
* @ValidationInfo : Timestamp         : 05 Dec 2018 12:49:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : 19
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 319/351 (90.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PERMISSIONS.SUBARR.VALIDATE(MasterArrId)
*--------------------------------------------------------------------------------------------------------------
* Description :
* Validation routine for the property class TC.PERMISSIONS, validating SubArr against MasterArr
*--------------------------------------------------------------------------------------------------------------
* Modification History:
*
* 09/01/2018 - Enhancement-2379129/ Task-2379132
*              TCUA - Validation for Permissions
*
* 27/06/2018 - Enh 2584357 / Task 2584360
*              TCUA: Online Arrangement Validations against product & Additional Validations on permissions
*              Included also defect 2523508 - Validation failed at sub arrangement against master in permissions
*
* 14/09/2018 - Defect 2872738 / Task 2874473
*              Update arrangement after a multi-value set was removed from Product Condition
*
*-----------------------------------------------------------------------------
* In/out parameters:
* MasterArrId - string (Single), IN
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>
    $USING AO.Framework
    $USING AA.Framework
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.OverrideProcessing
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>
    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process validation>
*** <desc>Process validation of Sub Arr against Master Arr</desc>
PROCESS:
*   Read SubArrangement Permissions
    GOSUB READ.SUBARR.PERMISSIONS
*
*   Read MasterArrangement Permissions
    GOSUB READ.MASTERARR.PERMISSIONS
*
*   Allowed Customer validations
    GOSUB CHECK.ALLOWED.CUSTOMERS
*
*   Overall level validations
    GOSUB CHECK.DEF.PERMISSIONS
*
*   Relation Customer level validations
    GOSUB CHECK.RELCUST.PERMISSIONS
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Check TC.PERMISSIONS - Allowed Customers level>
*** <desc>Check TC.PERMISSIONS at Allowed Customers level</desc>
CHECK.ALLOWED.CUSTOMERS:
    IF subArrDefinedCustomer EQ "" THEN
        RETURN
    END

    totalStringsSub = DCOUNT(subArrDefinedCustomer, @VM)
    counterSub = 1
    LOOP WHILE counterSub LE totalStringsSub
        foundCustInMa=0
        totalMa = DCOUNT(maArrDefinedCustomer , @VM)
        counterMa = 1
        LOOP WHILE counterMa LE totalMa
            IF subArrDefinedCustomer<1, counterSub>  EQ  maArrDefinedCustomer<1, counterMa>  THEN
                foundCustInMa=1
                GOSUB CHECK.COMPANY
                IF maArrDefinedCustomersSel<1, counterMa> EQ 'No' AND subArrDefinedCustomersSel<1, counterSub> EQ 'Yes' THEN
                    GOSUB PERMISSIONS.ALLOWED.CUS.ERROR
                END
            END
            counterMa=counterMa+1
        REPEAT
        IF foundCustInMa EQ 0 THEN
            GOSUB PERMISSIONS.ALLOWED.CUS.ERROR2
        END
        counterSub = counterSub+1
    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Check TC.PERMISSIONS - Allowed Customers level - Check Company>
*** <desc>Check TC.PERMISSIONS at Allowed Customers level - Check Company</desc>
CHECK.COMPANY:
    totalCompSub = DCOUNT(subArrDefinedCompany<1,counterSub>, @SM)
    counterCompSub = 1
    LOOP WHILE counterCompSub LE totalCompSub
        foundCompInMa=0
        totalCompMa = DCOUNT(maArrDefinedCompany<1,counterMa> , @SM)
        counterCompMa = 1
        LOOP WHILE counterCompMa LE totalCompMa
            IF subArrDefinedCompany<1, counterSub, counterCompSub>  EQ  maArrDefinedCompany<1, counterMa, counterCompMa>  THEN
                foundCompInMa=1
            END
            counterCompMa = counterCompMa+1
        REPEAT
        IF foundCompInMa EQ 0 THEN
            GOSUB PERMISSIONS.COMP.ERROR
        END
        counterCompSub = counterCompSub+1
    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Allowed Customer level>
*** <desc>Permissions error at Allowed Customer level - Allowed Customer from SubArr is not found in MasterArr</desc>
PERMISSIONS.ALLOWED.CUS.ERROR:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.NOT.VALID':@FM:subArrDefinedCustomersSel<1, counterSub>:@VM:maArrDefinedCustomersSel<1, counterMa>)
    EB.ErrorProcessing.StoreEndError()
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Allowed Customer level>
*** <desc>Permissions error at Allowed Customer level - Allowed Customer from SubArr is not found in MasterArr</desc>
PERMISSIONS.ALLOWED.CUS.ERROR2:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedCustomers)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.CUST.NOT.FOUND':@FM:subArrDefinedCustomer<1, counterSub>)
    EB.ErrorProcessing.StoreEndError()
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Allowed Customer level>
*** <desc>Permissions error at Allowed Customer level - Company from SubArr is not found in MasterArr</desc>
PERMISSIONS.COMP.ERROR:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermDefinedCompany)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setAs(counterCompSub)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.COMPANY.NOT.FOUND':@FM:subArrDefinedCompany<1, counterSub, counterCompSub>)
    EB.ErrorProcessing.StoreEndError()
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*
*
*-----------------------------------------------------------------------------
*
*** <region name= Check TC.PERMISSIONS - Overall level>
*** <desc>Compare sub-arrangement DefinedProductGroups list against master, reload DefinedProductGroups list from master if need it
***      Check permissions.</desc>
CHECK.DEF.PERMISSIONS:
* ProductGroups should not be edited at arrangement level, for this reason,
*   Defined Product Groups list in the sub-arrangement must be identical (also in the same order) with Defined Product Groups list in master arrangement.
*
* First step, check if in the arrangement Defined Product Groups list is present a ProductGroup which was removed from master DefinedProductGroups, in this case remove PrdGrp from the arrangeemnt.
*
    defPrdGroupModified="" ;* DefinedProductGroupList was modified in the sub-arrangement
    defPrdGroupDel=""      ;* DefinedProductGroupList was modified in the master arrangement
*
    countArrDefinedPrdGrpList = DCOUNT(subArrDefinedProductGroups, @VM)                           ;* Count arrangement Defined Product Groups
    cntDefPrdGrp=1
    FOR cntDefPrdGrp=1 TO countArrDefinedPrdGrpList                                               ;* loop through all arrangement Defined Product Groups
        IF subArrDefinedProductGroups<1,cntDefPrdGrp> NE '' THEN
            FIND subArrDefinedProductGroups<1,cntDefPrdGrp> IN maArrDefinedProductGroups SETTING pos ELSE   ;* search current arr DefProductGroup into master arr DefProductGroups
                defPrdGroupDel = 1
                DEL subArrDefinedProductGroups<1,cntDefPrdGrp>        ;* delete from DefinedProductGroup the PrdGrp removed from master DefProductGroups
                DEL subArrDefinedProductGroupSel<1,cntDefPrdGrp>      ;* delete also the Permission
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups, subArrDefinedProductGroups)           ;* assign to RNew the updated list
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel, subArrDefinedProductGroupSel)       ;* assign to RNew the updated list
            END
        END
    NEXT cntDefPrdGrp
    
* Second step, check if all Product Groups from master DefinedProductGroup list are present in the arrangement, otherwise insert the missing Product Group
*
    countMaArrDefinedProductGroups = DCOUNT(maArrDefinedProductGroups, @VM)                       ;* Count DefinedProductGroups in the master arrangement
    subDefPrdGrpList = RAISE(subArrDefinedProductGroups)                                          ;* neccessary for LOCATE
    vAf = AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel
*
    TMP.AV=1
    FOR TMP.AV=1 TO countMaArrDefinedProductGroups
*
        IF subArrDefinedProductGroups<1,TMP.AV> EQ maArrDefinedProductGroups<1,TMP.AV> THEN       ;* if subArrangement DefinedProductGroup matches master arrangement DefinedProductGroup, compare permissions
            arr.TMP.AV = TMP.AV
            subArrPermission = subArrDefinedProductGroupSel<1, arr.TMP.AV>
            GOSUB COMPARE.DEF.PERMISSIONS                                                         ;* validate to be within master limits
        END ELSE
            LOCATE maArrDefinedProductGroups<1,TMP.AV> IN subDefPrdGrpList SETTING pos THEN       ;* search current Product Conditions ProductGroup, into arrangement Defined Product Groups
                arr.TMP.AV = pos
                subArrPermission = subArrDefinedProductGroupSel<1, arr.TMP.AV>
                GOSUB COMPARE.DEF.PERMISSIONS                                                     ;* validate to be within master limits
            END ELSE
                defPrdGroupModified=1
                EB.SystemTables.setAf('')
                EB.SystemTables.setText("AO-MAS.COND.NO.CHANGE":@FM:"Defined Product Group")
                EB.OverrideProcessing.StoreOverride('')                                           ;* Throw Override
                subArrDefinedProductGroups=INSERT(subArrDefinedProductGroups,1,TMP.AV;maArrDefinedProductGroups<1,TMP.AV>)           ;* reload from master, the missing/removed DefinedProductGroup
                subArrDefinedProductGroupSel=INSERT(subArrDefinedProductGroupSel,1,TMP.AV;maArrDefinedProductGroupsSel<1,TMP.AV>)    ;* reload Permission from master level
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups, subArrDefinedProductGroups)         ;* assign to RNew the updated list
                EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel, subArrDefinedProductGroupSel)     ;* assign to RNew the updated list
                subDefPrdGrpList = RAISE(subArrDefinedProductGroups)
            END
        END
    NEXT TMP.AV
*
    IF defPrdGroupModified EQ '' AND defPrdGroupDel NE '' THEN
        EB.SystemTables.setAf('')
        EB.SystemTables.setText("AO-LIST.REINITIATED":@FM:"Defined Product Group ":@VM:" the master arrangement level.")
        EB.OverrideProcessing.StoreOverride('')               ;* Throw Override
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Compare TC.PERMISSIONS - Overall level>
*** <desc>Compare TC.PERMISSIONS at Overall level </desc>
COMPARE.DEF.PERMISSIONS:
    BEGIN CASE
        CASE maArrDefinedProductGroupsSel<1, arr.TMP.AV> EQ 'Exclude' AND subArrPermission MATCHES 'See':@VM:'Transact'
            GOSUB PERMISSIONS.DEF.ERROR
        CASE maArrDefinedProductGroupsSel<1, arr.TMP.AV> EQ 'See' AND subArrPermission EQ 'Transact'
            GOSUB PERMISSIONS.DEF.ERROR
    END CASE
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Overall level>
*** <desc>Permissions error</desc>
PERMISSIONS.DEF.ERROR:
    EB.SystemTables.setAf(vAf)
    EB.SystemTables.setAv(arr.TMP.AV)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.NOT.VALID':@FM:subArrPermission:@VM:maArrDefinedProductGroupsSel<1, arr.TMP.AV>)
    EB.ErrorProcessing.StoreEndError()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*
*
*-----------------------------------------------------------------------------
*
*** <region name= Check TC.PERMISSIONS - Relation Customer level>
*** <desc>Check TC.PERMISSIONS at Relation Customer level</desc>
CHECK.RELCUST.PERMISSIONS:
    IF subArrRelCustomer EQ "" THEN
        RETURN
    END
*
* count sub arrangement Relation Customers and loop through all
    totalSub = DCOUNT(subArrRelCustomer, @VM)
    counterSub = 1
    LOOP WHILE counterSub LE totalSub
        foundCustInMa=0
        foundCustProdInMa=0
* count master arrangement Relation Customers and loop until current subArr RelCust is found
        totalMa = DCOUNT(maArrRelCustomer, @SM)
        counterMa = 1
        LOOP WHILE counterMa LE totalMa
            IF (subArrRelCustomer<1, counterSub> EQ maArrRelCustomer<1, 1, counterMa>) THEN
* current subArr RelCust is found in masterArr Relation Customers
                foundCustInMa=1
            END
            IF (subArrRelCustomer<1, counterSub> EQ maArrRelCustomer<1, 1, counterMa>) AND (subArrProductGroups<1, counterSub> EQ maArrProductGroups<1, 1, counterMa>) THEN
* current subArr RelCust is found in masterArr Relation Customers and also ProductGroup is found
* compare permissions
                errorFound = ""
                GOSUB COMPARE.CUS.PERMISSIONS
                foundCustProdInMa=1
* check Products
                IF errorFound EQ "" THEN
* Product level validations, comparing products of current subArr Relation Customer, against current masterArr Relation Customer
                    GOSUB CHECK.PRD.PERMISSIONS
                END
                BREAK
            END
            counterMa = counterMa + 1
        REPEAT
*
        IF foundCustInMa EQ 0 THEN
* current subArr RelCust is not found in masterArr Relation Customers; Search subArr RelCust in masterArr Allowed Customer
            GOSUB SEARCH.RELCUST.IN.ALLOWEDCUST
        END
*
*
        IF foundCustInMa EQ 1 AND foundCustProdInMa EQ 0 THEN
* current subArr RelCust is found in masterArr Relation Customers but ProductGroup is not found
* in this case, check sub Arr Relation Customer-Product Group permission to not be lower than master permission at Defined Product Group level
            GOSUB CHK.PRDGRP.PERMISSION.AGAINST.MA.DEF.PERMISSION
        END
        counterSub = counterSub + 1
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Search subArr RelCust in masterArr Allowed Customer>
*** <desc> Search subArr RelCust in masterArr Allowed Customer; current subArr RelCust is not found in masterArr Relation Customers</desc>
SEARCH.RELCUST.IN.ALLOWEDCUST:
    foundCustInMaAllowedCust=0

* count master arrangement Allowed Customers and loop until current subArr RelCust is found
    totalMaAllowed = DCOUNT(maArrDefinedCustomer, @VM)
    counterMaInAllowed = 1
    LOOP WHILE counterMaInAllowed LE totalMaAllowed
        IF (subArrRelCustomer<1, counterSub> EQ maArrDefinedCustomer<1, counterMaInAllowed>) THEN
* current subArr RelCust is found in masterArr Allowed Customers
            foundCustInMaAllowedCust=1
            IF maArrDefinedCustomersSel<1, counterMaInAllowed> EQ 'Yes' THEN
* Product Group/Product level validations
* because subArr Relation Customer is found only in masterArr ALLOWED Customers, Product Groups and Products are missing in master
* in this case, check ProductGroup/Product permission to not be lower than master permission at Defined Product Group level
                GOSUB CHK.PRDGRP.PERMISSION.AGAINST.MA.DEF.PERMISSION
                GOSUB CHK.PRD.PERMISSION.AGAINST.MA.DEF.PERMISSION
            END
            IF maArrDefinedCustomersSel<1, counterMaInAllowed> EQ 'No' THEN
                GOSUB PERMISSIONS.CUS.ERROR2
            END
        END
        counterMaInAllowed = counterMaInAllowed + 1
    REPEAT
    IF foundCustInMaAllowedCust EQ 0 THEN
        GOSUB PERMISSIONS.CUS.ERROR2
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Compare TC.PERMISSIONS - Relation Customer level>
*** <desc>Compare TC.PERMISSIONS at Relation Customer level</desc>
COMPARE.CUS.PERMISSIONS:
    BEGIN CASE
        CASE maArrProductGroupSel<1, 1, counterMa> EQ 'Exclude' AND subArrProductGroupSel<1, counterSub> MATCHES 'See':@VM:'Transact'
            errorFound=1
            GOSUB PERMISSIONS.CUS.ERROR
        CASE maArrProductGroupSel<1, 1, counterMa> EQ 'See' AND subArrProductGroupSel<1, counterSub> EQ 'Transact'
            errorFound=1
            GOSUB PERMISSIONS.CUS.ERROR
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Relation Customer level>
*** <desc>Permissions error at Relation Customer level - permission in SubArr is higher than in MasterArr</desc>
PERMISSIONS.CUS.ERROR:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductGroupSel)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.NOT.VALID':@FM: subArrProductGroupSel<1, counterSub>:@VM: maArrProductGroupSel<1, 1, counterMa>)
    EB.ErrorProcessing.StoreEndError()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Relation Customer level>
*** <desc>Permissions error at Relation Customer level - relationCustomer from SubArr is not found in MasterArr</desc>
PERMISSIONS.CUS.ERROR2:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermRelCustomer)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.REL.CUST.NOT.FOUND':@FM:subArrRelCustomer<1, counterSub>)
    EB.ErrorProcessing.StoreEndError()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Relation Customer level>
*** <desc>Permissions error at Relation Customer level - RelationCustomer-ProductGroup from SubArr is not found in MasterArr</desc>
PERMISSIONS.CUS.ERROR3:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductGroups)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.REL.CUST.PRGR.NOT.FOUND' :@FM: subArrRelCustomer<1, counterSub> : @VM:subArrProductGroups<1, counterSub>)
    EB.ErrorProcessing.StoreEndError()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*** <region name= Check TC.PERMISSIONS - Relation Customer - Product group level>
*** <desc>Sub arr Relation Customer - Product group is not found in master arr Relation Customer - Product group</desc>
*** <desc>in this case, Sub arr Relation Customer - Product group permission is checked against master arr default Product Group permission</desc>
CHK.PRDGRP.PERMISSION.AGAINST.MA.DEF.PERMISSION:
    IF subArrProductGroups<1, counterSub> EQ '' THEN
        RETURN
    END
    foundPrdGrInMa=0
    totalDefStringsMa = DCOUNT(maArrDefinedProductGroups, @VM)
    counterMa = 1
    LOOP WHILE counterMa LE totalDefStringsMa
        IF subArrProductGroups<1, counterSub> EQ maArrDefinedProductGroups<1, counterMa> THEN
            foundPrdGrInMa=1
            subArrPermission = subArrProductGroupSel<1, counterSub>
            arr.TMP.AV = counterMa
*           point error to Relation Customer - Product Group
            vAf = AO.Framework.TcPermissions.AaTcPermProductGroupSel
            GOSUB COMPARE.DEF.PERMISSIONS
            BREAK
        END
        counterMa = counterMa+1
    REPEAT
    IF foundPrdGrInMa EQ 0 THEN
        GOSUB PERMISSIONS.CUS.ERROR3
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Check TC.PERMISSIONS - Product level>
*** <desc>Check TC.PERMISSIONS at Product level, for current subArr Relation Customer</desc>
CHECK.PRD.PERMISSIONS:
* count the Products defined as exception in current subArr Relation Customer
    totalSub2 = DCOUNT(subArrProduct<1,counterSub>, @SM)
    counterSub2=1
*
    LOOP WHILE counterSub2 LE totalSub2
* count the Products defined as exception in current masterArr Relation Customer
        totalMa2 = DCOUNT(maArrProduct<1,counterMa>, @SM)
        counterMa2=1
        foundProductInMa=0
*
        LOOP WHILE counterMa2 LE totalMa2
            IF subArrProduct<1,counterSub,counterSub2> EQ maArrProduct<1,counterMa,counterMa2> THEN
* Product from subArr RelationCustomer is found in masterArr RelationCustomer; Check Permissions
                GOSUB COMPARE.PRD.PERMISSIONS
                foundProductInMa=1
            END
            counterMa2 = counterMa2 + 1
        REPEAT
*
* current subArr Relation Customer Product is not found in current masterArr Relation Customer Products
        IF foundProductInMa EQ 0 THEN
* in this case, check Product permission to not be lower than master permission at Defined Product Group level
            GOSUB CHK.PRD.PERMISSION.AGAINST.MA.DEF.PERMISSION
        END
        counterSub2 = counterSub2 + 1
    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Compare TC.PERMISSIONS - Product level>
*** <desc>Compare TC.PERMISSIONS at Product level</desc>
COMPARE.PRD.PERMISSIONS:
    masterPermission = maArrProductSel<1,counterMa,counterMa2>
    BEGIN CASE
        CASE maArrProductSel<1,counterMa,counterMa2> EQ 'Exclude' AND subArrProductSel<1,counterSub,counterSub2> MATCHES 'See':@VM:'Transact'
            GOSUB PERMISSIONS.PRD.ERROR
        CASE maArrProductSel<1,counterMa,counterMa2> EQ 'See' AND subArrProductSel<1,counterSub,counterSub2> EQ 'Transact'
            GOSUB PERMISSIONS.PRD.ERROR
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Permissions error - Product level>
*** <desc>Permissions error at Product level - permission in SubArr is higher than in MasterArr</desc>
PERMISSIONS.PRD.ERROR:
    EB.SystemTables.setAf(AO.Framework.TcPermissions.AaTcPermProductSel)
    EB.SystemTables.setAv(counterSub)
    EB.SystemTables.setAs(counterSub2)
    EB.SystemTables.setEtext('AO-TC.PERMISSION.NOT.VALID':@FM:subArrProductSel<1,counterSub,counterSub2>:@VM:masterPermission)
    EB.ErrorProcessing.StoreEndError()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= check Product permission>
*** <desc>check Product permission to not be lower than master permission at Defined Product Group level </desc>
CHK.PRD.PERMISSION.AGAINST.MA.DEF.PERMISSION:
* the subArr Relation Customer-ProductGroup = subArrProductGroups<1, counterSub>
* search current subArr RelationCustomer-ProductGroup in master DefinedProductGroup
    totalDefStringsMa = DCOUNT(maArrDefinedProductGroups, @VM)
    counterDefMa = 1
    foundInMa=0
    LOOP WHILE counterDefMa LE totalDefStringsMa
        IF subArrProductGroups<1, counterSub> EQ maArrDefinedProductGroups<1, counterDefMa> THEN
            foundInMa=1
            GOSUB COMPARE.PRD.PERMISSION.AGAINST.MA.PRDGROUP
            BREAK
        END
        counterDefMa = counterDefMa+1
    REPEAT
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= compare subArr Product permission against master permission at Defined Product Group level>
*** <desc>compare subArr Product permission against master permission at Defined Product Group level</desc>
COMPARE.PRD.PERMISSION.AGAINST.MA.PRDGROUP:
    masterPermission = maArrDefinedProductGroupsSel<1, counterDefMa>
    BEGIN CASE
        CASE maArrDefinedProductGroupsSel<1, counterDefMa> EQ 'Exclude' AND subArrProductSel<1,counterSub,counterSub2> MATCHES 'See':@VM:'Transact'
            GOSUB PERMISSIONS.PRD.ERROR
        CASE maArrDefinedProductGroupsSel<1, counterDefMa> EQ 'See' AND subArrProductSel<1,counterSub,counterSub2> EQ 'Transact'
            GOSUB PERMISSIONS.PRD.ERROR
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Read SubArr Permissions>
*** <desc>Read SubArrangement Permissions from RNew</desc>
READ.SUBARR.PERMISSIONS:
    subArrDefinedCustomer        = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomers)
    subArrDefinedCompany         = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)
    subArrDefinedCustomersSel    = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)
*
    subArrDefinedProductGroups   = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups)
    subArrDefinedProductGroupSel = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)
*
    subArrRelCustomer            = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermRelCustomer)
    subArrProductGroups          = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductGroups)
    subArrProductGroupSel        = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductGroupSel)
*
    subArrProduct                = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProduct)
    subArrProductSel             = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Read MasterArr Permissions>
*** <desc>Read MasterArrangement Permissions from</desc>
READ.MASTERARR.PERMISSIONS:
    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    aaProperyClassId = 'TC.PERMISSIONS'
    AA.Framework.GetArrangementConditions(MasterArrId, aaProperyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for Permissions Property class
*
    IF retErr EQ '' AND propertyRecords NE '' THEN
*
        maArrDefinedCustomer         = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedCustomers>
        maArrDefinedCompany          = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedCompany>
        maArrDefinedCustomersSel     = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel>
*
        maArrDefinedProductGroups    = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedProductGroups>
        maArrDefinedProductGroupsSel = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel>
*
        maArrRelCustomer             = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermRelCustomer>
        maArrProductGroups           = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProductGroups>
        maArrProductGroupSel         = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProductGroupSel>
*
        maArrProduct                 = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProduct>
        maArrProductSel              = propertyRecords<1,AO.Framework.TcPermissions.AaTcPermProductSel>
*
        CONVERT @VM TO @FM IN maArrDefinedCustomer
        CONVERT @SM TO @VM IN maArrDefinedCustomer
        CONVERT @TM TO @SM IN maArrDefinedCustomer
*
        CONVERT @VM TO @FM IN maArrDefinedCompany
        CONVERT @SM TO @VM IN maArrDefinedCompany
        CONVERT @TM TO @SM IN maArrDefinedCompany
*
        CONVERT @VM TO @FM IN maArrDefinedCustomersSel
        CONVERT @SM TO @VM IN maArrDefinedCustomersSel
        CONVERT @TM TO @SM IN maArrDefinedCustomersSel
*
*
        CONVERT @VM TO @FM IN maArrDefinedProductGroups
        CONVERT @SM TO @VM IN maArrDefinedProductGroups
        CONVERT @TM TO @SM IN maArrDefinedProductGroups
*
        CONVERT @VM TO @FM IN maArrDefinedProductGroupsSel
        CONVERT @SM TO @VM IN maArrDefinedProductGroupsSel
        CONVERT @TM TO @SM IN maArrDefinedProductGroupsSel
*
*
        CONVERT @VM TO @FM IN maArrProduct
        CONVERT @SM TO @VM IN maArrProduct
        CONVERT @TM TO @SM IN maArrProduct
*
        CONVERT @VM TO @FM IN maArrProductSel
        CONVERT @SM TO @VM IN maArrProductSel
        CONVERT @TM TO @SM IN maArrProductSel
*
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:
*** SubArrangement
* Allowed Customer
    subArrDefinedCustomer        = ""
    subArrDefinedCompany         = ""
    subArrDefinedCustomersSel    = ""
*
* Overall level
    subArrDefinedProductGroups   = ""
    subArrDefinedProductGroupSel = ""
*
* Relation Customer level
    subArrRelCustomer            = ""
    subArrProductGroups          = ""
    subArrProductGroupSel        = ""
*
* Product level
    subArrProduct                = ""
    subArrProductSel             = ""
*
*** Master Arrangement
* Allowed Customer
    maArrDefinedCustomer         = ""
    maArrDefinedCompany          = ""
    maArrDefinedCustomersSel     = ""
*
* Overall level
    maArrDefinedProductGroups    = ""
    maArrDefinedProductGroupsSel = ""
*
* Relation Customer level
    maArrRelCustomer             = ""
    maArrProductGroups           = ""
    maArrProductGroupSel         = ""
*
* Product level
    maArrProduct                 = ""
    maArrProductSel              = ""
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
END
