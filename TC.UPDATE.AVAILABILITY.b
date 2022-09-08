* @ValidationCode : MjoxODY5ODM4Nzc4OkNwMTI1MjoxNTI4OTYxODk0MDE1OmRtYXRlaTo0OjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNi4wOjE5NToxNDk=
* @ValidationInfo : Timestamp         : 14 Jun 2018 10:38:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 149/195 (76.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AO.Framework
SUBROUTINE TC.UPDATE.AVAILABILITY(SubarrangementId,OfsArrActivityRecord)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History
* 04/01/2018 - Initial version
* Enhancement 2379129 /Task 238097 - SubArrangements update when the master updated for TC.AVAILABILITY  property
*
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table
*
*-----------------------------------------------------------------------------
    $USING AO.Framework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AA.ProductFramework

*-----------------------------------------------------------------------------

    GOSUB Initialise ;* Initialise the required variables
	GOSUB Process

RETURN

*-----------------------------------------------------------------------------
*** Initialise local variables and file variables
Initialise:
    subArrAvailDayName = ''
    subArrAvailDaySelect = ''
    subArrAvailStartTime = ''
    subArrAvailEndTime = ''
    maArrAvailDayName =  ''
    maArrAvailDaySelect =  ''
    maArrAvailStartTime =  ''
    maArrAvailEndTime = ''
    masterLvlChangeRes = ''
    masterLvlChangeAug = ''
    countVM = ''
    IF OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty> NE "" THEN
        countVM = DCOUNT(OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty>, @VM) + 1
    END ELSE
        countVM = 1
    END

RETURN

*-----------------------------------------------------------------------------
* the main routine
Process:
    GOSUB GetSubArrangementAvailabilityData
    GOSUB GetMasterArrangementAvailabilityData
    GOSUB DoAvailabilityValidations
    tempDate = OCONV(DATE(),'D-')
    tempDate = tempDate[7,4]:tempDate[1,2]:tempDate[4,2]
    tempTime =  OCONV(TIME(),'MTS')
    tempTime = tempTime[1,2]:tempTime[4,2]
    CURR.TIME = tempDate:tempTime
    IF countFieldName GT '1' THEN
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,-1> = 'TCAVAILABILITY'
        IF masterLvlChangeRes NE '' THEN
* if the master is updated only with the lower values then the MASTER.LVL.CHANGE value will be Restricted
            IF masterLvlChangeAug EQ '' THEN
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "MASTER.LVL.CHANGE:1:1"
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = 'RESTRICTED-':CURR.TIME
                countFieldName = countFieldName + 1
            END ELSE
* if the master is updated with the lower and higher values then the MASTER.LVL.CHANGE value will be Changed
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "MASTER.LVL.CHANGE:1:1"
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = 'CHANGED-':CURR.TIME
                countFieldName = countFieldName + 1
            END
        END
    END ELSE
* if the master is updated only with the higher values then the MASTER.LVL.CHANGE value will be Augmented
        IF masterLvlChangeAug NE '' THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,-1> = 'TCAVAILABILITY'
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,1> = "MASTER.LVL.CHANGE:1:1"
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,1> = 'AUGMENTED-':CURR.TIME
        END
    END

RETURN

*-----------------------------------------------------------------------------
* retrieve the data for the TC.AVAILABILITY property from the subArrangement
GetSubArrangementAvailabilityData:
    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    aaProperyClassId = 'TC.AVAILABILITY'
    AA.Framework.GetArrangementConditions(SubarrangementId, aaProperyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for TC Availability Property class
    IF retErr EQ '' AND propertyRecords NE '' THEN
        subArrAvailDayName = RAISE(RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailDayName>))
        subArrAvailDaySelect = RAISE(RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailDaySelect>))
        subArrAvailStartTime = RAISE(RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailStartTime>))
        subArrAvailEndTime = RAISE(RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailEndTime>))
    END
RETURN

*-----------------------------------------------------------------------------
* retrieve the data for the TC.AVAILABILITY property from the masterArrangement
GetMasterArrangementAvailabilityData:
* get information from masterarrangement
    masterArrangementId = AA.Framework.getArrId()
    aaProperyClassId = 'TC.AVAILABILITY'
    retErr = ''
	availabilityRec = ''

    AA.ProductFramework.GetPropertyRecord('', masterArrangementId, '', '', aaProperyClassId, '', availabilityRec, retErr)
    IF retErr = '' AND availabilityRec NE '' THEN
		maArrAvailDayName =  RAISE(availabilityRec<AO.Framework.TcAvailability.AaTcAvailDayName>)
		maArrAvailDaySelect =  RAISE(availabilityRec<AO.Framework.TcAvailability.AaTcAvailDaySelect>)
		maArrAvailStartTime =  RAISE(availabilityRec<AO.Framework.TcAvailability.AaTcAvailStartTime>)
		maArrAvailEndTime = RAISE(availabilityRec<AO.Framework.TcAvailability.AaTcAvailEndTime>)
    END
RETURN

*-----------------------------------------------------------------------------
DoAvailabilityValidations:
    subDayName = ''
    typePos = ''
    countDaysSelected = 1
    countFieldName = 1
* loop all the Days
    LOOP
        REMOVE subDayName FROM subArrAvailDayName SETTING typePos
    WHILE subDayName
* check day select - if dayselect in master is set to No and in subArr is Yes then it will be changed to No
        IF (maArrAvailDaySelect<countDaysSelected> EQ 'No') AND (subArrAvailDaySelect<countDaysSelected> NE maArrAvailDaySelect<countDaysSelected>) THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "DAY.SELECT:":countDaysSelected
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailDaySelect<countDaysSelected>
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
        END
        IF (maArrAvailDaySelect<countDaysSelected> EQ 'Yes') AND (subArrAvailDaySelect<countDaysSelected> NE maArrAvailDaySelect<countDaysSelected>) THEN
* an information will be displayed when the subArr will be opened
            masterLvlChangeAug = 'True'
        END
        
        GOSUB CheckSubArrIntervalsForUpdate
        countDaysSelected = countDaysSelected + 1
    REPEAT

RETURN

*-----------------------------------------------------------------------------
CheckSubArrIntervalsForUpdate:
    countSubArrIntervals = 1
    tempsubArrAvailStartTime = subArrAvailStartTime<countDaysSelected>
    subValues = ''
    subTypePos = ''
    intervalDeleted = ''
* loop all the intervals from subArr
    LOOP
        REMOVE subValues FROM tempsubArrAvailStartTime SETTING subTypePos
        IF subValues EQ '0000' THEN
            subValues = '0000':'1'
        END
    WHILE subValues:subTypePos
        GOSUB CheckMasterArrIntervalsForUpdate
        countSubArrIntervals = countSubArrIntervals + 1
        intervalDeleted = ''
        intervalAltered = ''
        intervalMatch = ''
    REPEAT
RETURN

*-----------------------------------------------------------------------------
CheckMasterArrIntervalsForUpdate:
    countMasArrIntervals = 1
    checkInterval = 'False'
    subMasterValues = ''
    masTypePos = ''
    tempmaArrAvailStartTime = ''
    tempmaArrAvailStartTime = maArrAvailStartTime<countDaysSelected>
 
* loop all the intervals from masterArr
    LOOP
        REMOVE subMasterValues FROM tempmaArrAvailStartTime SETTING masTypePos
        IF subMasterValues EQ '0000' THEN
            subMasterValues = '0000':'1'
        END
    WHILE subMasterValues
* the sub interval matches the current master interval
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> EQ maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> EQ maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) THEN
            intervalMatch = 'True'
        END
* the starttime subArr is earlier than the master
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> LT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> EQ maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "START.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailStartTime<countDaysSelected,countMasArrIntervals>
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalAltered = 'True'
        END
* the endtime subArr is later than the master
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> EQ maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> GT maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "END.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailEndTime<countDaysSelected,countMasArrIntervals>
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalAltered = 'True'
        END

* the start time is earlier in the master and end time is also earlier
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> GT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> GT maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> LT maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "END.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailEndTime<countDaysSelected,countMasArrIntervals>
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalAltered = 'True'
        END
* the start time is later in the master and end time is also later
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> LT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> LT maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> GT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "START.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailStartTime<countDaysSelected,countMasArrIntervals>
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalAltered = 'True'
        END
* the master interval has both starttime and endtime inside the subArr interval
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> LT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> GT maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "START.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailStartTime<countDaysSelected,countMasArrIntervals>
            countFieldName = countFieldName + 1
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "END.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrAvailEndTime<countDaysSelected,countMasArrIntervals>
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalAltered = 'True'
        END
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> GT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> LE maArrAvailEndTime<countDaysSelected,countMasArrIntervals>) THEN
* an information will be displayed when the subArr will be opened
            masterLvlChangeAug = 'True'
            intervalAltered = 'True'
        END
        IF (subArrAvailStartTime<countDaysSelected,countSubArrIntervals> GE maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> LT maArrAvailEndTime<countDaysSelected,countMasArrIntervals>)  THEN
* an information will be displayed when the subArr will be opened
            masterLvlChangeAug = 'True'
            intervalAltered = 'True'
        END
* deletion of the intervals
*if the sub interval is in the left side of the current master interval , not overlap
        IF (subArrAvailEndTime<countDaysSelected,countSubArrIntervals> LT maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (countMasArrIntervals EQ '1') AND (intervalDeleted EQ '') THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "START.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "END.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalDeleted = 'True'
        END
*if the sub interval is in the right side of the current master interval , not overlap
        IF (maArrAvailStartTime<countDaysSelected,countMasArrIntervals + 1> EQ '') AND (intervalDeleted EQ '') AND (intervalAltered EQ '') AND (intervalMatch EQ '') THEN
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "START.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "END.TIME:":countDaysSelected:":":countSubArrIntervals
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = "\NULL"
            countFieldName = countFieldName + 1
            masterLvlChangeRes = 'True'
            intervalDeleted = 'True'
        END
        
        countMasArrIntervals = countMasArrIntervals + 1
    REPEAT

RETURN


END
