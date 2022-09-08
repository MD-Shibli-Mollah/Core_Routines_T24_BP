* @ValidationCode : MjoxODgyOTIzNjQ1OkNwMTI1MjoxNTcxNzM3Nzc3NTk4OnN1ZGhhcmFtZXNoOjc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzoxNTE6MTIz
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 123/151 (81.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PRIVILEGES.UPDATE
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Description:
* This routine will determine if the value for TC.PRIVILEGES property is restricted , augmented or changed
* and will set the value for the filed MASTER.LEVEL.CHANGE for TC.PRIVILEGES property as restricted , augmented or changed

*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History:
*
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
*
RETURN
*-----------------------------------------------------------------------------
Initialise:
* Initialise the required variables
    changeStatus = ''
    updateAaArrExtuserFlag = ''
    savedArrPrivService = ''
    savedArrPrivServiceActive = ''
    savedArrPrivOperation = ''
    savedArrPrivOperationActive = ''
    newArrPrivService = ''
    newArrPrivServiceActive = ''
    newArrPrivOperation = ''
    newArrPrivOperationActive = ''
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
*
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
        GOSUB CheckResAug;* check if there is a restriction or augmentation in the property of the arrangement
        IF (changeStatus EQ 'Restricted') OR (changeStatus EQ 'Changed') OR (changeStatus EQ 'Augmented') THEN
            AO.Framework.AaUpdateArrangementExtuser(arrangementId, ebExternalUserIDList, arrangementExtuserRecord, changeStatus) ;* update the rebuild flag from concat file if there is a restriction or augmentation in the property
	    END
    END
    IF masterLevelChange NE '' THEN;* if there is a restriction or augmetation the masterLevelChange field will be updated
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivMasterLvlChange, masterLevelChange)
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
*
RETURN
*-------------------------------------------------------------------------------------
CheckResAug:
* the current values will be compared with the saved values and will determine if there is a restriction or augmentation for the privileges
    GOSUB GetRNew
    GOSUB GetRold
    GOSUB DoPrivilegesCheck
    
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
* retrieve the saved data for the TC.PRIVILEGES property from the arrangement
* get information from ROld
    savedArrPrivService = EB.SystemTables.getROld(AO.Framework.TcPrivileges.AaTcPrivService)
    CONVERT @VM TO @FM IN savedArrPrivService
    savedArrPrivServiceActive = EB.SystemTables.getROld(AO.Framework.TcPrivileges.AaTcPrivServiceActive)
    CONVERT @VM TO @FM IN savedArrPrivServiceActive
    savedArrPrivOperation = EB.SystemTables.getROld(AO.Framework.TcPrivileges.AaTcPrivOperation)
    CONVERT @VM TO @FM IN savedArrPrivOperation
    CONVERT @SM TO @VM IN savedArrPrivOperation
    savedArrPrivOperationActive = EB.SystemTables.getROld(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
    CONVERT @VM TO @FM IN savedArrPrivOperationActive
    CONVERT @SM TO @VM IN savedArrPrivOperationActive
*
RETURN
*-----------------------------------------------------------------------------
GetRNew:
* retrieve the new data for the TC.PRIVILEGES property from the arrangement
* get information from RNew
    newArrPrivService = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService)
    CONVERT @VM TO @FM IN newArrPrivService
    newArrPrivServiceActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)
    CONVERT @VM TO @FM IN newArrPrivServiceActive
    newArrPrivOperation = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)
    CONVERT @VM TO @FM IN newArrPrivOperation
    CONVERT @SM TO @VM IN newArrPrivOperation
    newArrPrivOperationActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
    CONVERT @VM TO @FM IN newArrPrivOperationActive
    CONVERT @SM TO @VM IN newArrPrivOperationActive
*
RETURN
*-----------------------------------------------------------------------------
DoPrivilegesCheck:
    subServiceType = ''
    typePos = ''
    countPrivService = 1
    countFieldName = 1
* loop all the Services
    LOOP
        REMOVE subServiceType FROM savedArrPrivService SETTING typePos
    WHILE subServiceType
        masterPosAf = ''
        masterPosAv = ''
        serviceEmpty = ''
        FIND subServiceType IN newArrPrivService SETTING masterPosAf,masterPosAv THEN
* if the service found in master and value lower than the sub the sub value will be changed directly
            IF (newArrPrivServiceActive<masterPosAf> EQ '') THEN
                serviceEmpty = "True"
            END
            IF (newArrPrivServiceActive<masterPosAf> EQ '') AND (savedArrPrivServiceActive<countPrivService> NE newArrPrivServiceActive<masterPosAf>) THEN
                changeRes = 'True'
            END
* if the service found in master and value higher than the sub will display an info when sub is open
            IF (newArrPrivServiceActive<masterPosAf> EQ 'Yes') AND (savedArrPrivServiceActive<countPrivService> NE newArrPrivServiceActive<masterPosAf>) THEN
* display an information when open the arrangement - this service can be added
                changeAug = 'True'
            END
            GOSUB CheckSavedArrOperation
        END
        countPrivService = countPrivService + 1
        serviceEmpty = ''
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckSavedArrOperation:
    countArrPrivOperation = 1
    tempSavedArrPrivOperation = savedArrPrivOperation<countPrivService>
    tempNewArrPrivOperation = newArrPrivOperation<masterPosAf>
    subValues = ''
* loop all the intervals from subArr
    LOOP
        REMOVE subValues FROM tempSavedArrPrivOperation SETTING subTypePos
    WHILE subValues
        subTypePos = ''
        subMasterPosAv = ''
        subMasterPosAs = ''
        FIND subValues IN tempNewArrPrivOperation SETTING subMasterPos,subMasterPosAv,subMasterPosAs THEN
* if the operation found in master and value lower than the sub the sub value will be changed directly
            IF (serviceEmpty EQ '') AND (newArrPrivOperationActive<masterPosAf,subMasterPosAv> EQ '') AND (savedArrPrivOperationActive<countPrivService,countArrPrivOperation> NE newArrPrivOperationActive<masterPosAf,subMasterPosAv>) THEN
                changeRes = 'True'
            END
            IF (serviceEmpty EQ 'True') AND (savedArrPrivOperationActive<countPrivService,countArrPrivOperation> NE newArrPrivOperationActive<masterPosAf,subMasterPosAv>)  THEN
                changeRes = 'True'
            END
* if the operation found in master and value higher than the sub will display an info when sub is open
            IF (newArrPrivOperationActive<masterPosAf,subMasterPosAv> EQ 'Yes') AND (savedArrPrivOperationActive<countPrivService,countArrPrivOperation> NE newArrPrivOperationActive<masterPosAf,subMasterPosAv>) THEN
* display an information when open the subArrangement - this service can be added
                changeAug = 'True'
            END
            countArrPrivOperation = countArrPrivOperation + 1
        END
    REPEAT
RETURN

END
