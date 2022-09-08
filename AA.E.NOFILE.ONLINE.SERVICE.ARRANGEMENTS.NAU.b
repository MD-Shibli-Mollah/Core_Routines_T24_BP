* @ValidationCode : MjotMTQ2MTg4MTM2NTpDcDEyNTI6MTU2MDUyMTQ4OTYzMDpydGFuYXNlOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTEtMDMyMDoyMTA6MTcy
* @ValidationInfo : Timestamp         : 14 Jun 2019 17:11:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 172/210 (81.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190611-0320
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.E.NOFILE.ONLINE.SERVICE.ARRANGEMENTS.NAU(finalArray)
*-----------------------------------------------------------------------------
* Nofile enquiry routine to list online arrangement activities pending for approval.
* This enquiry is designed to use it for TCUA
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History :
*
* 31-Jan-2019 - Enh 2875458 / Task 2907647
*               IRIS R18 TCUA
*
* 21-May-2019 - Defect 3141178 / Task 3141341
*               Minor changes in TCUA API
*
* 12-Jun-2019 - Defect 3178773/ Task 3179332
*               Multi inputter support for audit fields in IRIS R18 APIs, for the setting DateTimeMv=Yes in SPF record.
*
*** </region>
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.Security
    $USING EB.ARC
    $INSERT I_DAS.AA.ARRANGEMENT.ACTIVITY
*-----------------------------------------------------------------------------
    GOSUB initialise                  ;* Initialise variables
    GOSUB dasSelection                ;* Only INAU activities for the arrangement
    GOSUB process                     ;* main process
*
RETURN
*--------------------------------------------------------------------------------
*** <region name= initialise>
*** <desc>Initialise Required variables</desc>
initialise:
* Initialise variables
    finalArray = "" ;* OUtput array
*
    fieldNames = EB.Reports.getEnqSelection()<2> ;* Selection field name
    selectionOperands = EB.Reports.getEnqSelection()<3> ;* Filter operands
    selectionValues = EB.Reports.getEnqSelection()<4> ;* Contains @VM separated list of the selection values input by user
*
* In OFS request we can have 2 conditions for masterArrangementId: masterArrangementId:NE='',masterArrangementId:EQ=AA18107MCPD7,
*                                           but only the condition masterArrangementId=AA18107MCPD7 need to be sent to DAS query.
* This variable is used, for an exceptional case, in which the first condition is on an ID (masterArrangementId:EQ=AA18107MCPD7,masterArrangementId:NE='')
    maArrIdConditionAdded="" ;* boolean, used to not override the value of master arr ID that we want to use in DAS query.
    countFields = DCOUNT(fieldNames,@VM)   ;* count the selection fields completed in the enquiry, in order to loop and to find the both conditions for masterArrangementId, if there are two.
    FOR i=1 TO countFields
        IF fieldNames<1,i> EQ "masterArrangementId" AND maArrIdConditionAdded EQ "" THEN ;* if selection field is masterArrangementId, but a condition on an ID (masterArrangementId:EQ=AA18107MCPD7) was not yet found.
            masterArrangement = selectionOperands<1, i>   ;* Operand passed, which can be: EQ or NE
            masterArrangementId = selectionValues<1, i>   ;* Master arrangement id passed through ofs, which can be: '' or AA18107MCPD7
            IF LEN(masterArrangementId) NE 2 THEN         ;* if masterArrangementId is an ID (masterArrangementId:EQ=AA18107MCPD7), then the value of boolean variable is changed to 1
                maArrIdConditionAdded=1
            END
        END
    NEXT i

    LOCATE "arrangementId" IN fieldNames<1,1> SETTING arrPos THEN
        lArrangementId = selectionValues<1, arrPos> ;* Arrangement id passed
    END

    LOCATE "customerId" IN fieldNames<1,1> SETTING arrPos THEN
        lCustomerId = selectionValues<1, arrPos> ;* customerId id passed
    END
    LOCATE "productId" IN fieldNames<1,1> SETTING arrPos THEN
        lProductId = selectionValues<1, arrPos> ;* productId passed
    END
    LOCATE "arrangementStatus" IN fieldNames<1,1> SETTING arrPos THEN
        lArrangementStatus = selectionValues<1, arrPos> ;* Master arrangement id passed
    END
    LOCATE "productGroupId" IN fieldNames<1,1> SETTING arrPos THEN
        lProductGroupId = selectionValues<1, arrPos> ;* productGroupId passed
    END
    LOCATE "subArrangementName" IN fieldNames<1,1> SETTING arrPos THEN
        lSubArrangementName = selectionValues<1, arrPos> ;* subArrangementName passed
    END
    LOCATE "inputterId" IN fieldNames<1,1> SETTING arrPos THEN
        lInputter = selectionValues<1, arrPos> ;* inputter passed
    END
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= dasSelection>
*** <desc>Select arrangements waiting for approval</desc>
dasSelection:
* Only INAU activities for the arrangement
    tableName = "AA.ARRANGEMENT.ACTIVITY"
    theList = DAS$STATUS.NAU
    tableSuffix = '$NAU'
    theArgs = ""
    theArgs<1> = masterArrangement
    theArgs<2> = masterArrangementId
* To get the list of arrangements waiting for approval
    EB.DataAccess.Das(tableName,theList,theArgs,tableSuffix)

    arrangementActivityList = ''
    arrangementActivityList = theList
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= process>
*** <desc>Main process</desc>
process:
    IF arrangementActivityList THEN ;*Build details from AA.ARRANGEMENT.ACTIVITY
        noOfRecords = DCOUNT(arrangementActivityList,@FM) ;* No of records selected from NAU
        FOR lCount = 1 TO noOfRecords
            arrangementActivityId = arrangementActivityList<lCount>
            GOSUB readArrangementActivityNau ;* To read arrangement activity from NAU table
            GOSUB checkSelectionOnArrActivity ;* Run different selection
            IF skipFlag EQ "" THEN ;* Skip if selection not matching
                GOSUB readArrangementActivityHistory ;* Read from AA.ACTIVITY.HISTORY
                GOSUB readAAArrangement ;* Read from AA.ARRANGEMENT
                IF skipFlag EQ "" THEN ;* Skip if selection not matching
                    GOSUB linkedSubArrangementName ;* Fetch the subArrangementName (Remarks) from AA.ARRANGEMENT for sub arrangements
                    GOSUB constructOutputArray ;* Out array
                END
            END
        NEXT lCount
    END
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= readArrangementActivityNau>
*** <desc>Read arrangement activity from NAU table</desc>
readArrangementActivityNau:
*To read arrangement activity from NAU table
    arrangementActivityNauRec = AA.Framework.ArrangementActivity.ReadNau(arrangementActivityId, readErr)
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= checkSelectionOnArrActivity>
*** <desc>Check selection criteria on Arrangement Activity table</desc>
checkSelectionOnArrActivity:
* Check additional selection criteria
    skipFlag = ""
    customerId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActCustomer>
    aaArrangementId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActArrangement>
    productId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActProduct>
    inputter = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActInputter>
    created = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActDateTime>
*
* when in SPF record, DATE.TIME.MV field is set to YES, then, when an unauthorised record is modified, both inputters (who created and who modified) will be saved in Inputter multi value field.
    foundInputter = ""
    inputterId = ""
    createdAt = ""
    inputterName = ""
    extUserName = ""
    countInputters = DCOUNT(inputter,@VM)  ;* count the number of inputters in the Inputter multi value field, for the current arrangement activity
    FOR cntInputter=1 TO countInputters            ;* if in the Inputter field are saved multiple inputters, loop through each one
        currentInputter = inputter<1,cntInputter>  ;* extract the inputter string from the position cntInputter
        currentInputterId = FIELD(currentInputter,'_',2)     ;* Inputter field contains the value as: 10_INPUTTER__OFS_BROWSERTC. Here it is extracted the second string.
        currentCreatedAt = created<1,cntInputter>
*
        IF lInputter NE "" AND lInputter EQ currentInputterId THEN  ;* if the inputter string specified in selection is present in the Inputter field of the current arrangementActivity
            foundInputter=1
        END
        userRecord   = EB.Security.User.Read(currentInputterId,'')        ;* read the record from F.USER
        extUserRec   = EB.ARC.ExternalUser.Read(currentInputterId,'')     ;* read the record from F.EB.EXTERNAL.USER
        IF inputterId EQ "" THEN
            inputterId = currentInputterId                             ;* add the first inputter
            createdAt  = currentCreatedAt                              ;* add createdAt for the first inputter
            inputterName = userRecord<EB.Security.User.UseUserName>    ;* add inputterName of the first inputter
            extUserName  = extUserRec<EB.ARC.ExternalUser.XuName>      ;* add externalUserName of the first inputter
        END ELSE
            inputterId = inputterId:"|":currentInputterId              ;* add next inputter, delimited with "|"
            createdAt = createdAt:"|":currentCreatedAt                 ;* add createdAt of the next inputter, delimited with "|"
            inputterName = inputterName:"|":userRecord<EB.Security.User.UseUserName>   ;* add inputterName of the next inputter, delimited with "|"
            extUserName  = extUserName:"|":extUserRec<EB.ARC.ExternalUser.XuName>  ;* add extUserName  of the next inputter, delimited with "|"
            IF cntInputter EQ countInputters THEN
                GOSUB checkOnlyPipe
            END
        END
    NEXT cntInputter
*
* Check the different cases to skip the further processing if the selection failed based on provided selection value
    BEGIN CASE
        CASE lCustomerId NE "" AND lCustomerId NE customerId
            skipFlag = 1
        CASE lArrangementId NE "" AND lArrangementId NE aaArrangementId
            skipFlag = 1
        CASE lProductId NE "" AND lProductId NE productId
            skipFlag = 1
        CASE lInputter NE "" AND foundInputter EQ ""    ;* if the inputter string specified in selection is NOT present in the Inputter field of the current arrangementActivity
            skipFlag = 1
    END CASE
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name = checkOnlyPipe>
*** <desc>if inputterName/extUserName contains only empty strings, remove also '|'</desc>
checkOnlyPipe:
* check inputterName
    extInputterNotNull=''
    FOR cntInp=1 TO countInputters  ;* loop through all strings contained in inputterName variable
        iName=FIELD(inputterName,'|',cntInp)     ;* extract inputterName from the current position
        IF iName NE "" THEN                      ;* if in the current position there is an inputterName string present
            extInputterNotNull = 1
            BREAK;
        END
    NEXT cntInp
    IF extInputterNotNull EQ '' THEN             ;* if all the extUser strings are null in extUserName variable, then, do not let '|' to be present in extUserName variable.
        inputterName=''
    END
        
* check extUserName
    extUserNotNull=''
    FOR cntExtUser=1 TO countInputters  ;* loop through all strings contained in extUserName variable
        eName=FIELD(extUserName,'|',cntExtUser)  ;* extract extUser from the current position
        IF eName NE "" THEN                      ;* if in the current position there is an extUser string present
            extUserNotNull = 1
            BREAK;
        END
    NEXT cntExtUser
    IF extUserNotNull EQ '' THEN                 ;* if all the extUser strings are null in extUserName variable, then, do not let '|' to be present in extUserName variable.
        extUserName=''
    END
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= readArrangementActivityHistory>
*** <desc>Read Arrangement Activity History</desc>
readArrangementActivityHistory:
* Read from AA.ACTIVITY.HISTORY
    aaActivityHistoryRec = ''
    unauthArrActivityId=''
    authArrActivityId=''
    aaArrangementId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActArrangement>
    AA.Framework.ReadActivityHistory(aaArrangementId, '', '', aaActivityHistoryRec)   ;* Get the activity history record.
    activityRef = aaActivityHistoryRec<AA.Framework.ActivityHistory.AhActivityRef>
    activityStatus = aaActivityHistoryRec<AA.Framework.ActivityHistory.AhActStatus>

    fmPos = ''
    vmPos = ''
    smPos = ''
    FIND "UNAUTH" IN activityStatus SETTING fmPos,vmPos,smPos THEN ;* extract the last UNAUTH activity
        unauthArrActivityId = activityRef<fmPos,vmPos,smPos>
    END ELSE  ;* UNAUTH arrangementActivity was not found. Search for UNAUTH-CHG status.
        FIND "UNAUTH-CHG" IN activityStatus SETTING fmPos,vmPos,smPos THEN ;* extract arrangementActivityId which is in UNAUTH-CHG status
            unauthArrActivityId = activityRef<fmPos,vmPos,smPos>           ;* found UNAUTH-CHG arrangementActivity
        END
    END
    fmPos = ''
    vmPos = ''
    smPos = ''
    FIND "AUTH" IN activityStatus SETTING fmPos,vmPos,smPos THEN
* extract the last AUTH activity
        authArrActivityId = activityRef<fmPos,vmPos,smPos>
    END
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= readAAArrangement>
*** <desc>Read AA.Arrangement record </desc>
readAAArrangement:
* read the AA.Arrangement for the given arrangement
    aaArrangementId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActArrangement>
    EB.DataAccess.FRead("F.AA.ARRANGEMENT", aaArrangementId, aaArrangementRec, "", aAArrErr)
    subArrangementName = aaArrangementRec<AA.Framework.Arrangement.ArrRemarks>
    currentStatus = aaArrangementRec<AA.Framework.Arrangement.ArrArrStatus>
    productGroupId = aaArrangementRec<AA.Framework.Arrangement.ArrProductGroup>
* Check the different cases to skip the further processing if the selection failed based on provided selection value
    BEGIN CASE
        CASE lArrangementStatus NE "" AND lArrangementStatus NE currentStatus
            skipFlag = 1
        CASE lProductGroupId NE "" AND lProductGroupId NE productGroupId
            skipFlag = 1
        CASE lSubArrangementName NE "" AND lSubArrangementName NE subArrangementName
            skipFlag = 1
    END CASE
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= linkedSubArrangementName>
*** <desc>Read subArrangementName (Remarks) from AA.ARRANGEMENT for sub arrangements</desc>
linkedSubArrangementName:
* Fetch the subArrangementName (Remarks) from AA.ARRANGEMENT for sub arrangements
    linkedSubArrangementIds = aaArrangementRec<AA.Framework.Arrangement.ArrSubArrangement>
    linkedSubArrangementNames = ""
* Loop through each sub arrangement and get the subArrangement name
    LOOP
        REMOVE linkedSubArrangementId FROM linkedSubArrangementIds SETTING linkedSubArrangementIdPos
    WHILE linkedSubArrangementId
        EB.DataAccess.FRead("F.AA.ARRANGEMENT", linkedSubArrangementId, linkedAAArrangementRec, "", linkedArrErr)
        linkedSubArrangementName = linkedAAArrangementRec<AA.Framework.Arrangement.ArrRemarks>
        IF linkedSubArrangementNames THEN
            linkedSubArrangementNames := @SM:linkedSubArrangementName
        END ELSE
            linkedSubArrangementNames = linkedSubArrangementName
        END

    REPEAT

    CONVERT @VM TO @SM IN linkedSubArrangementIds ;* Convert vm into sm
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= constructOutputArray>
*** <desc>construct output array</desc>
constructOutputArray:
* Construct the out array as per the enquiry structure
    activity = ""
    arrangementId = aaArrangementId
    currentStatus = aaArrangementRec<AA.Framework.Arrangement.ArrArrStatus>
    startDate = aaArrangementRec<AA.Framework.Arrangement.ArrStartDate>
    productGroupId = aaArrangementRec<AA.Framework.Arrangement.ArrProductGroup>
    
    productId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActProduct>
    customerId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActCustomer>
    linkedMasterArrangementId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActMasterArrangement>
    
* Audit information
    recordStatus = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActRecordStatus>
    currentNumber = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActCurrNo>
    authoriserId = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActAuthoriser>
    companyCode = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActCoCode>
    departmentCode = arrangementActivityNauRec<AA.Framework.ArrangementActivity.ArrActDeptCode>
    
* Build the final array based on the values from different tables
    finalArray<-1> = arrangementId:"*":currentStatus:"*":subArrangementName:"*":productGroupId:"*":productId:"*":customerId:"*":linkedMasterArrangementId:"*":linkedSubArrangementIds:"*":linkedSubArrangementNames
    finalArray :="*":authArrActivityId:"*":unauthArrActivityId:"*":recordStatus:"*":currentNumber:"*":inputterId:"*":createdAt:"*":authoriserId:"*":companyCode:"*":departmentCode:"*":startDate:"*":inputterName:"*":extUserName
*
RETURN
*** </region>
*--------------------------------------------------------------------------------
END
