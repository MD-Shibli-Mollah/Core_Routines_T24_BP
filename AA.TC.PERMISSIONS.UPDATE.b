* @ValidationCode : MjotODA0ODE3MDE6Q3AxMjUyOjE1NzE3Mzc3NzcyOTM6c3VkaGFyYW1lc2g6NzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjM0ODozMTg=
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 318/348 (91.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PERMISSIONS.UPDATE
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Description:
* This routine will determine if the value for TC.PERMISSIONS property is restricted , augmented or changed
* and will set the value for the filed MASTER.LEVEL.CHANGE for TC.PERMISSIONS property as restricted , augmented or changed

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History:
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table
*
* 25/06/18 - Defect 2647401 / Task 2647505
*           The rebuild flag is not updated for Changed status
*
* 23/07/18 -  Enhancement 2669405 / Task 2669408 - Introducing new property TC.LICENSING
*
* 04/10/18 - Defect 2809449  / Task 2809588 - Redesign AA.TC.PERMISSIONS.UPDATE routine as per retail team review
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*** </region>
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AO.Framework
    $USING EB.Channels
    $USING EB.DataAccess
    $USING AF.Framework
    $INSERT I_DAS.EB.EXTERNAL.USER
    
    activityStatus = AF.Framework.getC_arractivitystatus()["-",1,1]          ;* Arrangement Activity status
* The routine will be triggered only when the activity is authorised and for updating existing arrangement activity
    IF activityStatus EQ 'AUTH' AND NOT(AA.Framework.getNewArrangement()) THEN      ;* Only during authorisation...
        GOSUB Initialise
        GOSUB Process
    END
RETURN
*-----------------------------------------------------------------------------
Initialise:
* Initialise the required variables
    changeStatus = ''
    updateAaArrExtuserFlag = ''
    savedArrAvailDayName = ''
    savedArrAvailDaySelect = ''
    savedArrAvailStartTime = ''
    savedArrAvailEndTime = ''
    newArrAvailDayName =  ''
    newArrAvailDaySelect =  ''
    newArrAvailStartTime =  ''
    newArrAvailEndTime = ''
    changeRes = ''
    changeAug = ''
    masterLevelChange = ''
    subArrangementId = ''
    masterArrangement = ''
    arrangementExtuserRecord = ''
*
RETURN
*-----------------------------------------------------------------------------
Process:
* Insert/update AA.ARRANGEMENT.EXTUSER for current arrangement
    arrangementId = AA.Framework.getArrId() ;* get the arrangement ID
    arrangementRecord = AA.Framework.getRArrangement() ;* get the arrangement record
    masterArrangement = arrangementRecord<AA.Framework.Arrangement.ArrMasterArrangement> ;* get the master arrangement ID
    IF masterArrangement NE '' THEN
        subArrangementId = arrangementId
        arrangementId = masterArrangement
* read from AA.ARRANGEMENT.EXTUSER the record with ID= masterArrangement
        arrangementExtuserRecord = EB.Channels.AaArrangementExtuser.Read(masterArrangement, errMsg)
    END ELSE
* read from AA.ARRANGEMENT.EXTUSER the record with ID= masterArrangement
        arrangementExtuserRecord = EB.Channels.AaArrangementExtuser.Read(arrangementId, errMsg)
    END
    IF arrangementExtuserRecord EQ '' THEN
* get the list of external users for the current master arrangement
        GOSUB GetebExternalUserID ;* read the EEU
        IF ebExternalUserIDList NE '' THEN
* create records in AA.ARRANGEMENT.EXTUSER for each EEU (some EEU are attached directly to the master other to the subArr )
            AO.Framework.AaInsertArrangementExtuser(arrangementId, masterArrangement, subArrangementId, ebExternalUserIDList)
        END
    END ELSE
        ebExternalUserIDList = arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserId>
        ebExternalUserIDSubList = arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserId>
        GOSUB CheckResAug ;* check if there is a restriction or augmentation in the property of the arrangement
        IF (changeStatus EQ 'Restricted') OR (changeStatus EQ 'Changed') OR (changeStatus EQ 'Augmented') THEN ;* update the rebuild flag from concat file if there is a restriction or augmentation in the property
            AO.Framework.AaUpdateArrangementExtuser(arrangementId, ebExternalUserIDList, arrangementExtuserRecord, changeStatus)
        END
    END
    IF masterLevelChange NE '' THEN ;* if there is a restriction or augmetation the masterLevelChange field will be updated
        EB.SystemTables.setRNew(AO.Framework.TcPermissions.AaTcPermMasterLvlChange, masterLevelChange)
    END
*
RETURN
*-------------------------------------------------------------------------------------
GetebExternalUserID:
* read the EEU for the current arrangement
    ebExternalUserIDList = DAS.EXT$ARRANGEMENT
    theArgs = arrangementId
    tableSuffix = ''
    EB.DataAccess.Das('EB.EXTERNAL.USER',ebExternalUserIDList,theArgs,tableSuffix)
RETURN
*-------------------------------------------------------------------------------------
CheckResAug:
* the current values will be compared with the saved values and will determine if there is a restriction or augmentation for the permissions
    GOSUB GetRNew
    GOSUB GetRold
    GOSUB DoPermissionsCheck
    
    tempDate = OCONV(DATE(),'D-')
    tempDate = tempDate[7,4]:tempDate[1,2]:tempDate[4,2]
    tempTime =  OCONV(TIME(),'MTS')
    tempTime = tempTime[1,2]:tempTime[4,2]
    CURR.TIME = tempDate:tempTime
    IF changeRes NE '' THEN
* if the master is updated only with the lower values then the MASTER.LVL.CHANGE value will be Restricted
        IF changeAug EQ '' THEN
            changeStatus = 'Restricted'
            masterLevelChange = 'RESTRICTED-':CURR.TIME
        END ELSE
* if the master is updated with the lower and higher values then the MASTER.LVL.CHANGE value will be Changed
            changeStatus = 'Changed'
            masterLevelChange = 'CHANGED-':CURR.TIME
        END
    END ELSE
* if the master is updated only with the higher values then the MASTER.LVL.CHANGE value will be Augmented
	    IF changeAug NE '' THEN
	        changeStatus = 'Augmented'
	        masterLevelChange = 'AUGMENTED-':CURR.TIME
	    END
    END
*
RETURN
*-----------------------------------------------------------------------------
GetRold:
* retrieve the saved data for the TC.PERMISSIONS property from the arrangement
* get information from ROld
    savedArrDefinedCustomer         = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermDefinedCustomers)
    savedArrDefinedCompany          = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermDefinedCompany)
    savedArrDefinedCustomersSel     = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)
    savedArrDefinedProductGroups    = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups)
    savedArrDefinedProductGroupSel  = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)
    savedArrRelCustomer             = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermRelCustomer)
    savedArrProductGroups           = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermProductGroups)
    savedArrProductGroupSel         = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermProductGroupSel)
    savedArrProduct                 = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermProduct)
    savedArrProductSel              = EB.SystemTables.getROld(AO.Framework.TcPermissions.AaTcPermProductSel)

    CONVERT @VM TO @FM IN savedArrDefinedCustomer
    CONVERT @SM TO @VM IN savedArrDefinedCustomer
    CONVERT @TM TO @SM IN savedArrDefinedCustomer
*
    CONVERT @VM TO @FM IN savedArrDefinedCompany
    CONVERT @SM TO @VM IN savedArrDefinedCompany
    CONVERT @TM TO @SM IN savedArrDefinedCompany
*
    CONVERT @VM TO @FM IN savedArrDefinedCustomersSel
    CONVERT @SM TO @VM IN savedArrDefinedCustomersSel
    CONVERT @TM TO @SM IN savedArrDefinedCustomersSel
*
    CONVERT @VM TO @FM IN savedArrDefinedProductGroups
    CONVERT @SM TO @VM IN savedArrDefinedProductGroups
    CONVERT @TM TO @SM IN savedArrDefinedProductGroups
*
    CONVERT @VM TO @FM IN savedArrDefinedProductGroupSel
    CONVERT @SM TO @VM IN savedArrDefinedProductGroupSel
    CONVERT @TM TO @SM IN savedArrDefinedProductGroupSel
*
    CONVERT @VM TO @FM IN savedArrProduct
    CONVERT @SM TO @VM IN savedArrProduct
    CONVERT @TM TO @SM IN savedArrProduct
    CONVERT @VM TO @FM IN savedArrProductSel
    CONVERT @SM TO @VM IN savedArrProductSel
    CONVERT @TM TO @SM IN savedArrProductSel
*
RETURN
*-----------------------------------------------------------------------------
GetRNew:
* retrieve the new data for the TC.PERMISSIONS property from the arrangement
* get information from RNew
    newArrDefinedCustomer         = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomers)
    newArrDefinedCompany          = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCompany)
    newArrDefinedCustomersSel     = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedCustomersSel)
    newArrDefinedProductGroups    = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups)
    newArrDefinedProductGroupSel  = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermDefinedProductGroupSel)
    newArrRelCustomer             = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermRelCustomer)
    newArrProductGroups           = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductGroups)
    newArrProductGroupSel         = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductGroupSel)
    newArrProduct                 = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProduct)
    newArrProductSel              = EB.SystemTables.getRNew(AO.Framework.TcPermissions.AaTcPermProductSel)

    CONVERT @VM TO @FM IN newArrDefinedCustomer
    CONVERT @SM TO @VM IN newArrDefinedCustomer
    CONVERT @TM TO @SM IN newArrDefinedCustomer
*
    CONVERT @VM TO @FM IN newArrDefinedCompany
    CONVERT @SM TO @VM IN newArrDefinedCompany
    CONVERT @TM TO @SM IN newArrDefinedCompany
*
    CONVERT @VM TO @FM IN newArrDefinedCustomersSel
    CONVERT @SM TO @VM IN newArrDefinedCustomersSel
    CONVERT @TM TO @SM IN newArrDefinedCustomersSel
*
    CONVERT @VM TO @FM IN newArrDefinedProductGroups
    CONVERT @SM TO @VM IN newArrDefinedProductGroups
    CONVERT @TM TO @SM IN newArrDefinedProductGroups
*
    CONVERT @VM TO @FM IN newArrDefinedProductGroupSel
    CONVERT @SM TO @VM IN newArrDefinedProductGroupSel
    CONVERT @TM TO @SM IN newArrDefinedProductGroupSel
*
    CONVERT @VM TO @FM IN newArrProduct
    CONVERT @SM TO @VM IN newArrProduct
    CONVERT @TM TO @SM IN newArrProduct
*
    CONVERT @VM TO @FM IN newArrProductSel
    CONVERT @SM TO @VM IN newArrProductSel
    CONVERT @TM TO @SM IN newArrProductSel
RETURN
*-----------------------------------------------------------------------------
DoPermissionsCheck:
*   check all permissions, for: Defined Allowed Customer, Defined Product Group, Relation Customer and Relation Customer-Product
    GOSUB CheckAllowedCustomer
    GOSUB CheckDefPermissions
    GOSUB CheckRelCustPermissions
RETURN
*-----------------------------------------------------------------------------
CheckAllowedCustomer:
    IF savedArrDefinedCustomer EQ "" THEN
        RETURN
    END
*   loop through all Defined Customers in SubArrangement
    subDefCustomer = ''
    subCustPos = ''
    counterCust = 1
    LOOP
        REMOVE subDefCustomer FROM savedArrDefinedCustomer SETTING subCustPos
    WHILE subDefCustomer
        masterPosAf=''
        masterPosAv=''
        FIND subDefCustomer IN newArrDefinedCustomer SETTING masterPosAf,masterPosAv THEN
*           Defined Customer is present in Master Arrangement
            GOSUB CheckCompany
            IF newArrDefinedCustomersSel<masterPosAf,masterPosAv> EQ 'No' AND savedArrDefinedCustomersSel<1,counterCust> EQ 'Yes' THEN
*               Defined Customer has lower permission in master than in subArr. Update subArr with lower permission
                changeRes = 'True'
            END
            IF newArrDefinedCustomersSel<masterPosAf,masterPosAv> EQ 'Yes' AND savedArrDefinedCustomersSel<1,counterCust> EQ 'No' THEN
*               Defined Customer has augmented permission in master than in subArr
                changeAug = 'True'
            END
        END ELSE
*           Defined Customers is not present in Master Arrangement - remove DefAllowedCustomer, DefCompany and DefCustomerSel
        END
        counterCust=counterCust+1
    REPEAT
*   check Augmented defined customers
    GOSUB CheckAugmentedDefinedCustomers
RETURN
*-----------------------------------------------------------------------------
CheckCompany:
    defCompany = savedArrDefinedCompany<1,counterCust>
    subDefCompany = ''
    subCompanyPos = ''
    countCompany = 1
*   loop through all Companies defined in SubArrangement
    LOOP
        REMOVE subDefCompany FROM defCompany SETTING subCompanyPos
    WHILE subDefCompany
        masterCompanyPosAf=''
        masterCompanyPosAv=''
        FIND subDefCompany IN newArrDefinedCompany<masterPosAf,masterPosAv> SETTING masterCompanyPosAf,masterCompanyPosAv THEN
        END ELSE
        END
        countCompany = countCompany + 1
    REPEAT
*   check Augmented company
    GOSUB CheckAugmentedCompany
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedCompany:
*   loop through all Companies defined in master arr, and search each in sub arr. If not found, means it is augmented
    maCompaniesListAgmt = newArrDefinedCompany<masterPosAf,masterPosAv>
    LOOP
        REMOVE maCompanyAgmt FROM maCompaniesListAgmt SETTING MaPosAgmt
    WHILE maCompanyAgmt
        FIND maCompanyAgmt IN defCompany SETTING subCompanyPosAf,subCompanyPosAv THEN
        END ELSE
            changeAug = 'True'
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedDefinedCustomers:
*   loop through all defined Customers in master arr, and search each in sub arr. If not found, means it is augmented

    maCustPosAgmt = ''
    counterCust = 1
    LOOP
        REMOVE maDefCustomerAgmt FROM newArrDefinedCustomer SETTING maCustPosAgmt
    WHILE maDefCustomerAgmt
        FIND maDefCustomerAgmt IN savedArrDefinedCustomer SETTING subPosCustAfAgmt,subPosCustAvAgmt THEN
        END ELSE
            changeAug = 'True'
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckDefPermissions:
    IF savedArrDefinedProductGroups EQ "" THEN
        RETURN
    END
*   loop through all Defined Product Groups, in subArrangement
    subProductGroup = ''
    subPos = ''
    counterPrGr = 1
    LOOP
        REMOVE subProductGroup FROM savedArrDefinedProductGroups SETTING subPos
    WHILE subProductGroup
        masterPosAf=''
        masterPosAv=''
        FIND subProductGroup IN newArrDefinedProductGroups SETTING masterPosAv THEN
*           Defined Product Group is found in masterArrangement
            IF (newArrDefinedProductGroupSel<masterPosAv> EQ 'See' AND savedArrDefinedProductGroupSel<counterPrGr> EQ 'Transact') OR (newArrDefinedProductGroupSel<masterPosAv> EQ 'Exclude' AND (savedArrDefinedProductGroupSel<counterPrGr> EQ 'Transact' OR savedArrDefinedProductGroupSel<counterPrGr> EQ 'See')) THEN
*               Defined Product Group has lower permission in master than in subArr. Update subArr with lower permission
                changeRes = 'True'
            END
            IF (newArrDefinedProductGroupSel<masterPosAv> EQ 'See' AND savedArrDefinedProductGroupSel<counterPrGr> EQ 'Exclude') OR (newArrDefinedProductGroupSel<masterPosAv> EQ 'Transact'  AND  (savedArrDefinedProductGroupSel<counterPrGr> EQ 'Exclude' OR savedArrDefinedProductGroupSel<counterPrGr> EQ 'See')) THEN
*               Defined Product Group has augmented permission in master than in subArr.
                changeAug = 'True'
            END
        END
        counterPrGr = counterPrGr + 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckRelCustPermissions:
    IF savedArrRelCustomer EQ "" THEN
        RETURN
    END
    subRelCust = ''
    subPos = ''
    counterSub = 1
*   loop through all Relation Customers in subArrangement
    LOOP
        REMOVE subRelCust FROM savedArrRelCustomer SETTING subPos
    WHILE subRelCust
        maRelCust=''
        maPos=''
        foundCustInMa=''
        foundCustProdInMa=''
        totalMa = DCOUNT(newArrRelCustomer, @VM)
        counterMa = 1
*       search current subArr Relation Customer into masterArrangement
        LOOP WHILE counterMa LE totalMa
            IF subRelCust EQ newArrRelCustomer<1, counterMa> THEN   ;* subArr Relation Customer is found in master
                foundCustInMa=1
            END
            IF subRelCust EQ newArrRelCustomer<1, counterMa> AND (savedArrProductGroups<1, 1, counterSub> EQ newArrProductGroups<1, counterMa>) THEN
*               subArr Relation Customer is found in master, and also is found the Relation Customer Product Group
                GOSUB CompareCusPermissions
                GOSUB CheckProductPermissions
                foundCustProdInMa=1
                BREAK
            END
            counterMa = counterMa + 1
        REPEAT
        counterSub = counterSub + 1
    REPEAT
*   check Augmented Relation Customers
    GOSUB CheckAugmentedRelationCustomers
RETURN
*-----------------------------------------------------------------------------
CompareCusPermissions:
    IF (newArrProductGroupSel<1, counterMa> EQ 'See' AND savedArrProductGroupSel<1, 1, counterSub> EQ 'Transact') OR (newArrProductGroupSel<1, counterMa> EQ 'Exclude' AND (savedArrProductGroupSel<1, 1, counterSub> EQ 'Transact' OR savedArrProductGroupSel<1, 1, counterSub> EQ 'See')) THEN
*       For current Relation Customer and current Product Group, master has lower permission than subArr. Update subArr with lower permission.
        changeRes = 'True'
    END
    IF (newArrProductGroupSel<1, counterMa> EQ 'See' AND savedArrProductGroupSel<1, 1, counterSub> EQ 'Exclude') OR (newArrProductGroupSel<1, counterMa> EQ 'Transact' AND (savedArrProductGroupSel<1, 1, counterSub> EQ 'Exclude' OR savedArrProductGroupSel<1, 1, counterSub> EQ 'See')) THEN
*       For current Relation Customer and current Product Group, master has augmented permission than subArr
        changeAug = 'True'
    END
RETURN
*-----------------------------------------------------------------------------
CheckProductPermissions:
*   extract list of Products and Product Permissions, for current RelationCustomer-ProductGroup, from subArr and masterArr
    subProduct=savedArrProduct<1, counterSub>
    subProductSel=savedArrProductSel<1, counterSub>
    maProduct=newArrProduct<1, counterMa>
    maProductSel=newArrProductSel<1, counterMa>
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
            IF subProd EQ newArrProduct<1,counterMa,countProdMa> THEN
*               the Product is found in masterArr
                foundProductInMa=1
                IF (newArrProductSel<1, counterMa, countProdMa> EQ 'See' AND savedArrProductSel<1, counterSub, counterProdSub> EQ 'Transact') OR (newArrProductSel<1, counterMa, countProdMa> EQ 'Exclude' AND (savedArrProductSel<1, counterSub, counterProdSub> EQ 'Transact' OR savedArrProductSel<1, counterSub, counterProdSub> EQ 'See')) THEN
*                   The current Product from RelationCustomer-ProductGroup, has lower permissions in master than in subArr. Update subArr with lower permission.
                    changeRes = 'True'
                END
                IF (newArrProductSel<1, counterMa, countProdMa> EQ 'See' AND savedArrProductSel<1, counterSub, counterProdSub> EQ 'Exclude') OR (newArrProductSel<1, counterMa, countProdMa> EQ 'Transact' AND (savedArrProductSel<1, counterSub, counterProdSub> EQ 'Exclude' OR savedArrProductSel<1, counterSub, counterProdSub> EQ 'See')) THEN
*                   The current Product from RelationCustomer-ProductGroup, has augmented permissions in master than in subArr
                    changeAug = 'True'
                END
            END
            countProdMa = countProdMa + 1
        REPEAT
        IF foundProductInMa EQ '' THEN
*           The current Product from RelationCustomer-ProductGroup was not found in master. Remove it from subArrangement.
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
        REMOVE maRelCustAgmt FROM newArrRelCustomer SETTING maPosAgmt
    WHILE maRelCustAgmt
        foundCustInSubAgmt=''
        foundCustProdInSubAgmt=''
        totalCustSubAgmt = DCOUNT(savedArrRelCustomer, @SM)
        counterSubAgmt = 1
*       search current master Arr Relation Customer into sub Arrangement
        LOOP WHILE counterSubAgmt LE totalCustSubAgmt
            IF maRelCustAgmt EQ savedArrRelCustomer<1, 1, counterSubAgmt> THEN   ;* master Relation Customer is found in subArr
                foundCustInSubAgmt=1
            END
            IF maRelCustAgmt EQ savedArrRelCustomer<1, 1, counterSubAgmt> AND (newArrProductGroups<1, counterMaAgmt> EQ savedArrProductGroups<1, 1, counterSubAgmt>) THEN
*               masterArr Relation Customer is found in sub Arr, and also is found the Relation Customer-Product Group
                foundCustProdInSubAgmt=1
                BREAK
            END
            counterSubAgmt = counterSubAgmt + 1
        REPEAT
        IF foundCustInSubAgmt EQ '' OR (foundCustInSubAgmt EQ 1 AND foundCustProdInSubAgmt EQ '') THEN
            changeAug = 'True'
        END
        counterMaAgmt = counterMaAgmt + 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckAugmentedProducts:
    subProduct=savedArrProduct<1, counterSub>
    subProductSel=savedArrProductSel<1, counterSub>
    maProduct=newArrProduct<1, counterMa>
    maProductSel=newArrProductSel<1, counterMa>
    
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
            IF maProdAgmt EQ savedArrProduct<1,counterSub,countProdSubAgmt> THEN
*               the Product is found in subArr
                foundProductInSubAgmt=1
            END
            countProdSubAgmt = countProdSubAgmt + 1
        REPEAT
        IF foundProductInSubAgmt EQ '' THEN
*           The current Product from master RelationCustomer-ProductGroup was not found in subArr.
            changeAug = 'True'
        END
    REPEAT
RETURN
END
