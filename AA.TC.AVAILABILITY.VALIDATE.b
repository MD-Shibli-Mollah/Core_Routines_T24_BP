* @ValidationCode : MjoxMzY2NjM0MjQ1OkNwMTI1MjoxNTcxNzM3Nzc3Njc3OnN1ZGhhcmFtZXNoOjEyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6NDIwOjM5MQ==
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 12
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 391/420 (93.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AO.Framework
SUBROUTINE AA.TC.AVAILABILITY.VALIDATE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History
* 04/01/2018 - Initial version
* Enhancement 2379129 / Task 238097 - SubArrangements validation for TC.AVAILABILITY when create or update
* 13/03/2018 - Defects 2499076 , 2499074 / Task 2499703
*            - Missing validations for TC_Availability
* Enhancement 2584357 / Task 2624936 - Arrangements validation against product conditions
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------

    $USING AO.Framework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AA.ProductFramework
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.Template
    $USING AA.ARC
    $USING AF.Framework

*-----------------------------------------------------------------------------
    GOSUB Initialise ;* Initialise the required variables
    GOSUB ProcessCrossVal
       
RETURN
*-----------------------------------------------------------------------------
*** Initialise local variables and file variables
Initialise:
    
    masterArrId = ''
* get the arrangement ID
    arrangementId = AA.Framework.getArrId()
    arrangementRecord = AA.Framework.Arrangement.Read(arrangementId, errMsg)
* get the masterArrangement ID
    masterArrId = arrangementRecord<AA.Framework.Arrangement.ArrMasterArrangement>
    productId = arrangementRecord<AA.Framework.Arrangement.ArrProduct>
* generalValidation flag will be set to False if the common validation dont pass, in this case the validation will not continue
	generalValidation = ''

RETURN
*-----------------------------------------------------------------------------
ProcessCrossVal:
    IF EB.SystemTables.getMessage() EQ '' THEN     ;* Only during commit...
        TEMP.V.FUN = EB.SystemTables.getVFunction()
        BEGIN CASE
            CASE TEMP.V.FUN EQ 'D'
            CASE TEMP.V.FUN EQ 'R'
            CASE 1      ;* The real crossval...
                GOSUB RealCrossVal
        END CASE
    END

RETURN
*-----------------------------------------------------------------------------
RealCrossVal:
* Real cross validation goes here....
    TEMP.PROD.ARR = AF.Framework.getProductArr()
    TEMP.AA.PROD = AA.Framework.Product
    TEMP.AA.ARR = AA.Framework.AaArrangement

    BEGIN CASE
        CASE TEMP.PROD.ARR EQ TEMP.AA.PROD   ;* If its from the designer level
            GOSUB DesignerDefaults           ;* Ideally no defaults at the product level
        CASE TEMP.PROD.ARR EQ TEMP.AA.ARR    ;* If its from the arrangement level
            GOSUB ArrangementDefaults        ;* Arrangement defaults
    END CASE

    GOSUB CommonCrossVal

    BEGIN CASE
        CASE AF.Framework.getProductArr() EQ AA.Framework.Product
            GOSUB DesignerCrossVal          ;* Designer specific cross validations
        CASE AF.Framework.getProductArr() EQ AA.Framework.AaArrangement
            IF generalValidation EQ '' THEN
                GOSUB ArrangementCrossVal       ;* Arrangement specific cross validations
            END
    END CASE

RETURN

*-----------------------------------------------------------------------------
DesignerDefaults:

RETURN

*-----------------------------------------------------------------------------
ArrangementDefaults:

RETURN
*-----------------------------------------------------------------------------

CommonCrossVal:
    
    GOSUB CheckDuplicateDays ;* Check Duplicate DayNames
*
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
    dayName = ''
    typePos = ''

    countDaysSelected = 1
* loop all the Days
    LOOP
        REMOVE dayName FROM arrAvailDayName SETTING typePos
    WHILE dayName
        GOSUB CheckInputMissing
        GOSUB CheckArrIntervals
        countDaysSelected = countDaysSelected + 1
    REPEAT
	
RETURN
*-----------------------------------------------------------------------------
DesignerCrossVal:

RETURN

*-----------------------------------------------------------------------------
ArrangementCrossVal:
    IF masterArrId NE '' THEN
		GOSUB ValidateAgainstMasterArr
    END ELSE
		GOSUB ValidateAgainstProduct
	END
RETURN
*-----------------------------------------------------------------------------
CheckInputMissing:
    intervalsNo = COUNT(arrAvailStartTime<countDaysSelected>, @VM) + 1
* check if the input for the startTime is empty
    FOR countIntervals = 1 TO intervalsNo
        IF arrAvailStartTime<countDaysSelected,countIntervals> EQ '' THEN
            generalValidation = 'False'
            EB.SystemTables.setAs(countIntervals)
            EB.SystemTables.setAv(countDaysSelected)
            EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
            EB.SystemTables.setEtext("EB-INPUT.MISSING")     ;* Set Error
            EB.ErrorProcessing.StoreEndError()
        END
* check if the input for the endTime is empty
        IF arrAvailEndTime<countDaysSelected,countIntervals> EQ '' THEN
            generalValidation = 'False'
            EB.SystemTables.setAs(countIntervals)
            EB.SystemTables.setAv(countDaysSelected)
            EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailEndTime)
            EB.SystemTables.setEtext("EB-INPUT.MISSING")     ;* Set Error
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT countIntervals
* check if the input for the daySelect is empty
    IF arrAvailDaySelect<countDaysSelected> EQ '' THEN
        generalValidation = 'False'
        EB.SystemTables.setAs(1)
        EB.SystemTables.setAv(countDaysSelected)
        EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailDaySelect)
        EB.SystemTables.setEtext("EB-INPUT.MISSING")     ;* Set Error
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*-----------------------------------------------------------------------------
CheckArrIntervals:
    countSubArrIntervals = 1
    temparrAvailStartTime = arrAvailStartTime<countDaysSelected>
    subValues = ''
    subTypePos = ''
	timeToCheck = ''
	startTime = ''
    validFormat = ''

* loop all the intervals from subArr
    LOOP
        REMOVE values FROM temparrAvailStartTime SETTING subTypePos
        IF values EQ '0000' THEN
            values = '0000':'1'
        END
    WHILE values:subTypePos
* check time format HHMM
        startTime = 'True'
        timeToCheck = arrAvailStartTime<countDaysSelected,countSubArrIntervals>
        GOSUB ValidateTimeFormat
        startTime = ''
        timeToCheck = arrAvailEndTime<countDaysSelected,countSubArrIntervals>
        GOSUB ValidateTimeFormat

        IF validFormat EQ '' THEN
* check if the endTime is greater than startTime
            IF arrAvailEndTime<countDaysSelected,countSubArrIntervals> LE arrAvailStartTime<countDaysSelected,countSubArrIntervals> THEN
                generalValidation = 'False'
                EB.SystemTables.setAs(countSubArrIntervals)
                EB.SystemTables.setAv(countDaysSelected)
                EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
                EB.SystemTables.setEtext('AO-TIME.INTERVAL.NOK':@FM:arrAvailStartTime<countDaysSelected,countSubArrIntervals>:"-":arrAvailEndTime<countDaysSelected,countSubArrIntervals>)
                EB.ErrorProcessing.StoreEndError()
                generalValidation = 'False'
            END
* check if an earlier time interval is defined after a later time interval
            IF (countSubArrIntervals > 1) AND (arrAvailStartTime<countDaysSelected,countSubArrIntervals> LE arrAvailEndTime<countDaysSelected,countSubArrIntervals - 1>) THEN
                generalValidation = 'False'
                EB.SystemTables.setAs(countSubArrIntervals)
                EB.SystemTables.setAv(countDaysSelected)
                EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
                EB.SystemTables.setEtext('AO-INTERVAL.POSITION.NOK':@FM:arrAvailStartTime<countDaysSelected,countSubArrIntervals - 1>:"-":arrAvailEndTime<countDaysSelected,countSubArrIntervals - 1>)
                EB.ErrorProcessing.StoreEndError()
                generalValidation = 'False'
            END
        END
        countSubArrIntervals = countSubArrIntervals + 1
        validFormat = ''
    REPEAT
RETURN
*-----------------------------------------------------------------------------
* validate the timeformat HHMM
ValidateTimeFormat:
*
    hours=''
    minutes=''

	IF LEN(timeToCheck) EQ 4  THEN

		hours = timeToCheck[1,2]
		minutes = timeToCheck[3,2]
		IF NOT(NUM(hours)) OR (hours EQ '') OR (LEN(hours) > 2) OR (hours > 24) OR ((hours GE 24) AND (minutes > 0 )) OR NOT(NUM(minutes)) OR (minutes EQ '') OR  (LEN(minutes) > 2) OR (minutes > 59) THEN
			validFormat = 'False'
            generalValidation = 'False'
			EB.SystemTables.setAs(countSubArrIntervals)
			EB.SystemTables.setAv(countDaysSelected)
            IF 	startTime EQ 'True' THEN
				EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
			END ELSE
                EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailEndTime)
			END
			EB.SystemTables.setEtext('AO-TIMEFORMAT.NOT.VALID':@FM:timeToCheck)
			EB.ErrorProcessing.StoreEndError()
            generalValidation = 'False'
		END
	END ELSE
        validFormat = 'False'
        EB.SystemTables.setAs(countSubArrIntervals)
        EB.SystemTables.setAv(countDaysSelected)
        IF 	startTime EQ 'True' THEN
            EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
        END ELSE
            EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailEndTime)
        END
        EB.SystemTables.setEtext('AO-TIMEFORMAT.NOT.VALID':@FM:timeToCheck)
        EB.ErrorProcessing.StoreEndError()
        generalValidation = 'False'
	END
RETURN
*-----------------------------------------------------------------------------
CheckDuplicateDays:

    dayAf = AO.Framework.TcAvailability.AaTcAvailDayName ;* Get DayName field position
    EB.SystemTables.setAf(dayAf)
    EB.Template.Dup() ;* Check Duplicate
    EB.SystemTables.setAf('')

RETURN
*-----------------------------------------------------------------------------
GetArrangementData:
* get information from arrangement using RNew
* this data will be used for the master validation against product conditions or for the subArr validation against masterArr
    arrAvailActivity = ''
    arrAvailDayName = ''
    arrAvailDaySelect = ''
    arrAvailStartTime = ''
    arrAvailEndTime = ''
    subArrAvailActivity = ''
    subArrAvailDayName = ''
    subArrAvailDaySelect = ''
    subArrAvailStartTime = ''
    subArrAvailEndTime = ''
    subArrAvailActivity = EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailActivity)
    subArrAvailDayName = RAISE(EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailDayName))
    CONVERT @VM TO @FM IN subArrAvailDayName
    subArrAvailDaySelect = RAISE(EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailDaySelect))
    CONVERT @VM TO @FM IN subArrAvailDaySelect
    subArrAvailStartTime = RAISE(EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailStartTime))
    subArrAvailEndTime = RAISE(EB.SystemTables.getRNew(AO.Framework.TcAvailability.AaTcAvailEndTime))
    arrAvailActivity = subArrAvailActivity
    arrAvailDayName = subArrAvailDayName
    arrAvailDaySelect = subArrAvailDaySelect
    arrAvailStartTime = subArrAvailStartTime
    arrAvailEndTime = subArrAvailEndTime
    
    insertArrAvailDayName = subArrAvailDayName
    insertArrAvailDaySelect = subArrAvailDaySelect
    insertArrAvailStartTime = subArrAvailStartTime
    insertArrAvailEndTime = subArrAvailEndTime
RETURN
*-----------------------------------------------------------------------------
GetMasterArrangementData:
* get information from masterarrangement using GetArrangementConditions
    maArrAvailActivity = ''
    maArrAvailDayName = ''
    maArrAvailDaySelect = ''
    maArrAvailStartTime = ''
    maArrAvailEndTime = ''
    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    aaProperyClassId = 'TC.AVAILABILITY'
    AA.Framework.GetArrangementConditions(masterArrId, aaProperyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for TC Availability Property class
    IF retErr = '' AND propertyRecords NE '' THEN
        maArrAvailActivity = RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailActivity>)
        maArrAvailDayName = RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailDayName>)
        CONVERT @VM TO @FM IN maArrAvailDayName
        maArrAvailDaySelect = RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailDaySelect>)
        CONVERT @VM TO @FM IN maArrAvailDaySelect
        maArrAvailStartTime = RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailStartTime>)
        CONVERT @VM TO @FM IN maArrAvailStartTime
        CONVERT @SM TO @VM IN maArrAvailStartTime
        maArrAvailEndTime = RAISE(propertyRecords<1,AO.Framework.TcAvailability.AaTcAvailEndTime>)
        CONVERT @VM TO @FM IN maArrAvailEndTime
        CONVERT @SM TO @VM IN maArrAvailEndTime
    END
RETURN
*-----------------------------------------------------------------------------
GetProductData:
* get information from product
    prodAvailDayName = ''
    prodAvailDaySelect = ''
    prodAvailStartTime = ''
    prodAvailEndTime = ''
    OutPropertyList = ''
    OutPropertyConditionList = ''
    RetErr = ''

* get the information for each property from product conditions
    AA.ProductFramework.GetProductConditionRecords(productId, "", "", OutPropertyList, "", "", OutPropertyConditionList, RetErr)
    IF RetErr = '' AND OutPropertyList NE '' THEN
        FIND "TCAVAILABILITY" IN OutPropertyList SETTING PropPos THEN
            prodAvailDayName = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcAvailability.AaTcAvailDayName>)
            CONVERT @VM TO @FM IN prodAvailDayName
            prodAvailDaySelect = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcAvailability.AaTcAvailDaySelect>)
            CONVERT @VM TO @FM IN prodAvailDaySelect
            prodAvailStartTime = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcAvailability.AaTcAvailStartTime>)
            CONVERT @VM TO @FM IN prodAvailStartTime
            CONVERT @SM TO @VM IN prodAvailStartTime
            prodAvailEndTime = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcAvailability.AaTcAvailEndTime>)
            CONVERT @VM TO @FM IN prodAvailEndTime
            CONVERT @SM TO @VM IN prodAvailEndTime
        END
    END
    
RETURN
*-----------------------------------------------------------------------------
* validation for dayName and daySelect
ValidateAgainstMasterArr:
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
* get information from masterArrangement using GetArrangementConditions
    GOSUB GetMasterArrangementData
* validations for DaySelect against the master
    subDayName = ''
    typePos = ''
    countDaysSelected = 1
* loop all the Days
    dayNameMissing = ''
    tempMasAvailDayName = maArrAvailDayName

    LOOP
        REMOVE subDayName FROM tempMasAvailDayName SETTING typePos
    WHILE subDayName
* determine if the daySelect from arrangement is restricted as against product condition
        FIND subDayName IN subArrAvailDayName SETTING afSep THEN
            IF (maArrAvailDaySelect<countDaysSelected> EQ 'No') AND (subArrAvailDaySelect<afSep> NE maArrAvailDaySelect<countDaysSelected>) THEN
                EB.SystemTables.setAs('')
                EB.SystemTables.setAv(countDaysSelected)
                EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailDaySelect)
                EB.SystemTables.setEtext('AO-DAYSELECT.NOT.VALID':@FM:subDayName)
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                GOSUB CheckSubArrIntervals
            END
        END ELSE
            dayNameMissing = 'True'
*   reinitiate dayNames
            insertArrAvailDayName = INSERT(insertArrAvailDayName, countDaysSelected; subDayName)
*   reinitiate daySelect
            insertArrAvailDaySelect = INSERT(insertArrAvailDaySelect, countDaysSelected; maArrAvailDaySelect<countDaysSelected>)
*   reinitiate startTime
            insertArrAvailStartTime = INSERT(insertArrAvailStartTime, countDaysSelected; maArrAvailStartTime<countDaysSelected>)
*   reinitiate endTime
            insertArrAvailEndTime = INSERT(insertArrAvailEndTime, countDaysSelected; maArrAvailEndTime<countDaysSelected>)
        END
        countDaysSelected = countDaysSelected + 1
    REPEAT
    IF dayNameMissing NE '' THEN
* Throw Override if dayName is missing from arrangement
        EB.SystemTables.setAf('')
        EB.SystemTables.setText("AO-MAS.COND.NO.CHANGE":@FM:"Days")
        EB.OverrideProcessing.StoreOverride('')
* reinitiate the availability data
        insertArrAvailDayName = LOWER(insertArrAvailDayName)
        insertArrAvailDaySelect = LOWER(insertArrAvailDaySelect)
        insertArrAvailStartTime = LOWER(insertArrAvailStartTime)
        insertArrAvailEndTime = LOWER(insertArrAvailEndTime)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailDayName, insertArrAvailDayName)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailDaySelect, insertArrAvailDaySelect)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailStartTime, insertArrAvailStartTime)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailEndTime, insertArrAvailEndTime)
    END
RETURN
*-----------------------------------------------------------------------------
* validation for time intervals for each day
CheckSubArrIntervals:
    countSubArrIntervals = 1
    tempsubArrAvailStartTime = subArrAvailStartTime<afSep>

    subValues = ''
    subTypePos = ''
* loop all the intervals from subArr
    LOOP
        REMOVE subValues FROM tempsubArrAvailStartTime SETTING subTypePos
        IF subValues EQ '0000' THEN
            subValues = '0000':'1'
        END
    WHILE subValues:subTypePos
    
        GOSUB CheckMasterArrIntervals
        countSubArrIntervals = countSubArrIntervals + 1
     
    REPEAT
RETURN

*-----------------------------------------------------------------------------
CheckMasterArrIntervals:
    countMasArrIntervals = 1
* checkInterval flag is used to determine wheter at least one interval from master matches with sub interval
    checkInterval = 'False'
    subMasterValues = ''
    masTypePos = ''
    masterIntervals = ''
    tempmaArrAvailStartTime = ''
    tempmaArrAvailStartTime = maArrAvailStartTime<countDaysSelected>
* loop all the intervals from masterArr
    LOOP
        REMOVE subMasterValues FROM tempmaArrAvailStartTime SETTING masTypePos
        IF subMasterValues EQ '0000' THEN
            subMasterValues = '0000':'1'
        END
    WHILE subMasterValues
* check if the sub arrangement interval is restricted against the masterArr interval
        IF (subArrAvailStartTime<afSep,countSubArrIntervals> GE maArrAvailStartTime<countDaysSelected,countMasArrIntervals>) AND (subArrAvailEndTime<afSep,countSubArrIntervals> LE maArrAvailEndTime<countDaysSelected,countMasArrIntervals>)  THEN
            checkInterval = 'True'
        END
        IF countMasArrIntervals EQ 1 THEN
            masterIntervals = maArrAvailStartTime<countDaysSelected,countMasArrIntervals>:"-":maArrAvailEndTime<countDaysSelected,countMasArrIntervals>
        END ELSE
            masterIntervals = masterIntervals : " and " : maArrAvailStartTime<countDaysSelected,countMasArrIntervals>:"-":maArrAvailEndTime<countDaysSelected,countMasArrIntervals>
        END

        countMasArrIntervals = countMasArrIntervals + 1
    REPEAT
    IF checkInterval = 'False' THEN
        EB.SystemTables.setAs(countSubArrIntervals)
        EB.SystemTables.setAv(countDaysSelected)
        EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
        EB.SystemTables.setEtext('AO-INTERVAL.NOT.VALID':@FM:masterIntervals)
        EB.ErrorProcessing.StoreEndError()
    END
RETURN

*-----------------------------------------------------------------------------
* validation for dayName and daySelect against the product conditions
ValidateAgainstProduct:
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
* get the data for the Product Conditions using GetProductConditionRecords
    GOSUB GetProductData
* loop all the dayNames , validate the daySelect
    dayName = ''
    typePos = ''
    countDaysSelected = 1
    dayNameMissing = ''
    tempProdAvailDayName = prodAvailDayName
    LOOP
        REMOVE dayName FROM tempProdAvailDayName SETTING typePos
    WHILE dayName
* determine if the time interval from arrangement is restricted as against product condition
        FIND dayName IN arrAvailDayName SETTING afSep THEN
            IF (prodAvailDaySelect<countDaysSelected> EQ 'No') AND (arrAvailDaySelect<afSep> NE prodAvailDaySelect<countDaysSelected>) THEN
                EB.SystemTables.setAs('')
                EB.SystemTables.setAv(countDaysSelected)
                EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailDaySelect)
                EB.SystemTables.setEtext('AO-RESTRICTED.OPTION':@FM:dayName)
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                GOSUB CheckArrangementIntervals
            END
        END ELSE
            dayNameMissing = 'True'
*   reinitiate dayNames
            insertArrAvailDayName = INSERT(insertArrAvailDayName, countDaysSelected; dayName)
*   reinitiate daySelect
            insertArrAvailDaySelect = INSERT(insertArrAvailDaySelect, countDaysSelected; prodAvailDaySelect<countDaysSelected>)
*   reinitiate startTime
            insertArrAvailStartTime = INSERT(insertArrAvailStartTime, countDaysSelected; prodAvailStartTime<countDaysSelected>)
*   reinitiate endTime
            insertArrAvailEndTime = INSERT(insertArrAvailEndTime, countDaysSelected; prodAvailEndTime<countDaysSelected>)
        END
        countDaysSelected = countDaysSelected + 1
    REPEAT
    IF dayNameMissing NE '' THEN
* Throw Override if dayName is missing from arrangement
        EB.SystemTables.setAf('')
        EB.SystemTables.setText("AO-PRD.COND.NO.CHANGE":@FM:"Days")
        EB.OverrideProcessing.StoreOverride('')
* reinitiate the availability data
        insertArrAvailDayName = LOWER(insertArrAvailDayName)
        insertArrAvailDaySelect = LOWER(insertArrAvailDaySelect)
        insertArrAvailStartTime = LOWER(insertArrAvailStartTime)
        insertArrAvailEndTime = LOWER(insertArrAvailEndTime)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailDayName, insertArrAvailDayName)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailDaySelect, insertArrAvailDaySelect)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailStartTime, insertArrAvailStartTime)
        EB.SystemTables.setRNew(AO.Framework.TcAvailability.AaTcAvailEndTime, insertArrAvailEndTime)
    END
RETURN
*-----------------------------------------------------------------------------
* validation for time intervals for each day
CheckArrangementIntervals:
    countArrIntervals = 1
    tempArrAvailStartTime = arrAvailStartTime<afSep>
    subValues = ''
    subTypePos = ''
* loop all the intervals from arr
    LOOP
        REMOVE subValues FROM tempArrAvailStartTime SETTING subTypePos
        IF subValues EQ '0000' THEN
            subValues = '0000':'1'
        END
    WHILE subValues:subTypePos
    
        GOSUB CheckProductArrIntervals
        countArrIntervals = countArrIntervals + 1
     
    REPEAT
RETURN

*-----------------------------------------------------------------------------
CheckProductArrIntervals:
    countProdIntervals = 1
* checkInterval flag is used to determine wheter at least one interval from master matches with sub interval
    checkInterval = 'False'
    prodValues = ''
    prodTypePos = ''
    prodIntervals = ''
    tempProdAvailStartTime = ''
    tempProdAvailStartTime = prodAvailStartTime<countDaysSelected>
* loop all the intervals from masterArr
    LOOP
        REMOVE prodValues FROM tempProdAvailStartTime SETTING prodTypePos
        IF prodValues EQ '0000' THEN
            prodValues = '0000':'1'
        END
    WHILE prodValues
* check if the arrangement interval is restricted against the product interval
        IF (arrAvailStartTime<afSep,countArrIntervals> GE prodAvailStartTime<countDaysSelected,countProdIntervals>) AND (arrAvailEndTime<afSep,countArrIntervals> LE prodAvailEndTime<countDaysSelected,countProdIntervals>)  THEN
            checkInterval = 'True'
        END
        IF countProdIntervals EQ 1 THEN
            prodIntervals = prodAvailStartTime<countDaysSelected,countProdIntervals>:"-":prodAvailEndTime<countDaysSelected,countProdIntervals>
        END ELSE
            prodIntervals = prodIntervals : " and " : prodAvailStartTime<countDaysSelected,countProdIntervals>:"-":prodAvailEndTime<countDaysSelected,countProdIntervals>
        END

        countProdIntervals = countProdIntervals + 1
    REPEAT
    IF checkInterval = 'False' THEN
        EB.SystemTables.setAs(countArrIntervals)
        EB.SystemTables.setAv(countDaysSelected)
        EB.SystemTables.setAf(AO.Framework.TcAvailability.AaTcAvailStartTime)
        EB.SystemTables.setEtext('AO-TIME.INTERVAL.OUT':@FM:prodIntervals)
        EB.ErrorProcessing.StoreEndError()
    END
RETURN

END
