* @ValidationCode : MjotMjEwNTQ1NDUxMzpDcDEyNTI6MTU3MTczNzc3Nzg4NDpzdWRoYXJhbWVzaDo3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6MTk1OjE2NA==
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 164/195 (84.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.AVAILABILITY.UPDATE
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Description:
* This routine will determine if the value for TC.AVAILABILITY property is restricted , augmented or changed
* and will set the value for the filed MASTER.LEVEL.CHANGE for TC.AVAILABILITY property as restricted , augmented or changed
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
        GOSUB CheckResAug ;* check if there is a restriction or augmentation in the property of the arrangement
        IF (changeStatus EQ 'Restricted') OR (changeStatus EQ 'Changed') OR (changeStatus EQ 'Augmented') THEN
            AO.Framework.AaUpdateArrangementExtuser(arrangementId, ebExternalUserIDList, arrangementExtuserRecord, changeStatus)
        END
    END
    IF masterLevelChange NE '' THEN ;* if there is a restriction or augmetation the masterLevelChange field will be updated
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailMasterLvlChange, masterLevelChange)
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
* the current values will be compared with the saved values and will determine if there is a restriction or augmentation for the availability
    GOSUB GetRNew
    GOSUB GetRold
    GOSUB DoAvailabilityCheck
    
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
* retrieve the saved data for the TC.AVAILABILITY property from the arrangement
* get information from ROld
    savedArrAvailDayName = EB.SystemTables.getROld(AO.Framework.TcAvailability.AaTcAvailDayName)
    CONVERT @VM TO @FM IN savedArrAvailDayName
    savedArrAvailDaySelect = EB.SystemTables.getROld(AO.Framework.TcAvailability.AaTcAvailDaySelect)
    CONVERT @VM TO @FM IN savedArrAvailDaySelect
    savedArrAvailStartTime = EB.SystemTables.getROld(AO.Framework.TcAvailability.AaTcAvailStartTime)
    CONVERT @VM TO @FM IN savedArrAvailStartTime
    CONVERT @SM TO @VM IN savedArrAvailStartTime
    savedArrAvailEndTime = EB.SystemTables.getROld(AO.Framework.TcAvailability.AaTcAvailEndTime)
    CONVERT @VM TO @FM IN savedArrAvailEndTime
    CONVERT @SM TO @VM IN savedArrAvailEndTime
*
RETURN
*-----------------------------------------------------------------------------
GetRNew:
* retrieve the new data for the TC.AVAILABILITY property from the arrangement
* get information from RNew
    newArrAvailDayName = EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailDayName)
    CONVERT @VM TO @FM IN newArrAvailDayName
    newArrAvailDaySelect = EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailDaySelect)
    CONVERT @VM TO @FM IN newArrAvailDaySelect
    newArrAvailStartTime = EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailStartTime)
    CONVERT @VM TO @FM IN newArrAvailStartTime
    CONVERT @SM TO @VM IN newArrAvailStartTime
    newArrAvailEndTime = EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailEndTime)
    CONVERT @VM TO @FM IN newArrAvailEndTime
    CONVERT @SM TO @VM IN newArrAvailEndTime
*
RETURN
*-----------------------------------------------------------------------------
DoAvailabilityCheck:
*
    subDayName = ''
    typePos = ''
    countDaysSelected = 1
* loop all the Days
    LOOP
        REMOVE subDayName FROM savedArrAvailDayName SETTING typePos
    WHILE subDayName
* check day select - if dayselect in master is set to No and in subArr is Yes then it will be changed to No
        IF (newArrAvailDaySelect<countDaysSelected> EQ 'No') AND (savedArrAvailDaySelect<countDaysSelected> NE newArrAvailDaySelect<countDaysSelected>) THEN
            changeRes = 'True'
        END
        IF (newArrAvailDaySelect<countDaysSelected> EQ 'Yes') AND (savedArrAvailDaySelect<countDaysSelected> NE newArrAvailDaySelect<countDaysSelected>) THEN
* an information will be displayed when the subArr will be opened
            changeAug = 'True'
        END
        
        GOSUB CheckSavedArrIntervalsForUpdate
        countDaysSelected = countDaysSelected + 1
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------
CheckSavedArrIntervalsForUpdate:
*
    countSavedArrIntervals = 1
    tempSavedArrAvailStartTime = savedArrAvailStartTime<countDaysSelected>
    subValues = ''
    subTypePos = ''
    intervalDeleted = ''
* loop all the intervals from subArr
    LOOP
        REMOVE subValues FROM tempSavedArrAvailStartTime SETTING subTypePos
        IF subValues EQ '0000' THEN
            subValues = '0000':'1'
        END
    WHILE subValues:subTypePos
        GOSUB CheckNewArrIntervalsForUpdate
        countSavedArrIntervals = countSavedArrIntervals + 1
        intervalDeleted = ''
        intervalAltered = ''
        intervalMatch = ''
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------
CheckNewArrIntervalsForUpdate:
*
    countNewArrIntervals = 1
    checkInterval = 'False'
    subNewValues = ''
    masTypePos = ''
    tempNewArrAvailStartTime = ''
    tempNewArrAvailStartTime = newArrAvailStartTime<countDaysSelected>

* loop all the intervals from masterArr
    LOOP
        REMOVE subNewValues FROM tempNewArrAvailStartTime SETTING masTypePos
        IF subNewValues EQ '0000' THEN
            subNewValues = '0000':'1'
        END
    WHILE subNewValues
    
        savedStartTime = savedArrAvailStartTime<countDaysSelected,countSavedArrIntervals>
        newStartTime = newArrAvailStartTime<countDaysSelected,countNewArrIntervals>
        savedEndTime = savedArrAvailEndTime<countDaysSelected,countSavedArrIntervals>
        newEndTime = newArrAvailEndTime<countDaysSelected,countNewArrIntervals>
        nextNewStartTime = newArrAvailStartTime<countDaysSelected,countNewArrIntervals + 1>
* the sub interval matches the current master interval
        BEGIN CASE
            CASE (savedStartTime EQ newStartTime)
                IF (savedEndTime EQ newEndTime) THEN
                    intervalMatch = 'True'
                END
* the endtime subArr is later than the master
                IF (savedEndTime GT newEndTime) THEN
                    changeRes = 'True'
                    intervalAltered = 'True'
                END
* the starttime subArr is earlier than the master
            CASE (savedStartTime LT newStartTime)
                IF (savedEndTime EQ newEndTime) THEN
                    changeRes = 'True'
                    intervalAltered = 'True'
                END
* the start time is later in the master and end time is also later
                IF  (savedEndTime LT newEndTime) AND  (savedEndTime GT newStartTime) THEN
                    changeRes = 'True'
                    intervalAltered = 'True'
                END
* the master interval has both starttime and endtime inside the subArr interval
                IF (savedEndTime GT newEndTime) THEN
                    changeRes = 'True'
                    intervalAltered = 'True'
                END
* the start time is earlier in the master and end time is also earlier
            CASE (savedStartTime GT newStartTime)
                IF (savedEndTime GT newEndTime) AND (savedStartTime LT newEndTime) THEN
                    changeRes = 'True'
                    intervalAltered = 'True'
                END
* the time interval is augmented
                IF (savedEndTime LE newEndTime) THEN
                    changeAug = 'True'
                    intervalAltered = 'True'
                END
            CASE (savedStartTime GE newStartTime) AND  (savedEndTime LT newEndTime)
                changeAug = 'True'
                intervalAltered = 'True'
* deletion of the intervals
*if the sub interval is in the left side of the current master interval , not overlap
            CASE (savedStartTime LT newStartTime) AND (countNewArrIntervals EQ '1') AND (intervalDeleted EQ '')
                changeRes = 'True'
*if the sub interval is in the right side of the current master interval , not overlap
            CASE (nextNewStartTime EQ '') AND (intervalDeleted EQ '') AND (intervalAltered EQ '') AND (intervalMatch EQ '')
                changeRes = 'True'
                intervalDeleted = 'True'
        END CASE
        countNewArrIntervals = countNewArrIntervals + 1
    REPEAT
*
RETURN

END
