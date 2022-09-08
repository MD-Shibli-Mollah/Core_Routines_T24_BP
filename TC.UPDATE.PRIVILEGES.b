* @ValidationCode : MjoxNjQ4NjY0OTI0OkNwMTI1MjoxNTI4OTYxODkzOTgzOmRtYXRlaTozOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNi4wOjEzMjoxMTg=
* @ValidationInfo : Timestamp         : 14 Jun 2018 10:38:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 118/132 (89.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AO.Framework
SUBROUTINE TC.UPDATE.PRIVILEGES(SubarrangementId,OfsArrActivityRecord)
*-----------------------------------------------------------------------------
* Description:
* Provides cross-validation of data entered in TC.PRIVILEGES property class
* at product designer and arrangement levels
*-----------------------------------------------------------------------------
* Modification History:
*
* Enhancement 2379129 / Task 238097 - SubArrangements update when the master updated for TC.PRIVILEGES property
*
*
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table
*
*-----------------------------------------------------------------------------
*** <region name = Main section>
*** <desc>Main section</desc>

    $USING AO.Framework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AA.ProductFramework

*-----------------------------------------------------------------------------

    GOSUB Initialise
    GOSUB Process
       
RETURN
*-----------------------------------------------------------------------------
*** Initialise local variables and file variables
Initialise: ;* Initialise the required variables
    subArrPrivService = ''
    subArrPrivServiceActive = ''
    subArrPrivOperation = ''
    subArrPrivOperationActive = ''
    maArrPrivService = ''
    maArrPrivServiceActive = ''
    maArrPrivOperation = ''
    maArrPrivOperationActive = ''
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

    GOSUB GetSubArrangementPrivilegesData
    GOSUB GetMasterArrangementPrivilegesData
    GOSUB DoPrivilegesValidations
    tempDate = OCONV(DATE(),'D-')
    tempDate = tempDate[7,4]:tempDate[1,2]:tempDate[4,2]
    tempTime =  OCONV(TIME(),'MTS')
    tempTime = tempTime[1,2]:tempTime[4,2]
    CURR.TIME = tempDate:tempTime
    IF countFieldName GT '1' THEN
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,-1> = 'TCPRIVILEGES'
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
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,-1> = 'TCPRIVILEGES'
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,1> = "MASTER.LVL.CHANGE:1:1"
            OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,1> = 'AUGMENTED-':CURR.TIME
        END
    END
RETURN

*-----------------------------------------------------------------------------
* retrieve the data for the TC.PRIVILEGES property from the subArrangement
GetSubArrangementPrivilegesData:

* get information from masterarrangement

    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    aaProperyClassId = 'TC.PRIVILEGES'
    AA.Framework.GetArrangementConditions(SubarrangementId, aaProperyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for TC Availability Property class

* Get arrangement condition for Protection Limit Property class
    IF retErr = '' AND propertyRecords NE '' THEN
        subArrPrivService = RAISE(RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivService>))
        subArrPrivServiceActive = RAISE(RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivServiceActive>))
        subArrPrivOperation = RAISE(RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivOperation>))
        subArrPrivOperationActive = RAISE(RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivOperationActive>))
    END
RETURN

*-----------------------------------------------------------------------------
* retrieve the data for the TC.PRIVILEGES property from the masterArrangement
GetMasterArrangementPrivilegesData:
* get information from masterarrangement

    aaProperyClassId = 'TC.PRIVILEGES'
    masterArrangementId = AA.Framework.getArrId()
    retErr = ''
	privilegesRec = ''
    AA.ProductFramework.GetPropertyRecord('', masterArrangementId, '', '', aaProperyClassId, '', privilegesRec, retErr)
    IF retErr = '' AND privilegesRec NE '' THEN
		maArrPrivService =  RAISE(privilegesRec<AO.Framework.TcAvailability.AaTcAvailDayName>)
		maArrPrivServiceActive =  RAISE(privilegesRec<AO.Framework.TcAvailability.AaTcAvailDaySelect>)
		maArrPrivOperation =  RAISE(privilegesRec<AO.Framework.TcAvailability.AaTcAvailStartTime>)
		maArrPrivOperationActive = RAISE(privilegesRec<AO.Framework.TcAvailability.AaTcAvailEndTime>)
    END
    
RETURN

*-----------------------------------------------------------------------------
* updating TC.PRIVILEGES data from subArrangement against master
DoPrivilegesValidations:
    subServiceType = ''
    typePos = ''
    countPrivService = 1
    countFieldName = 1
* loop all the Services
    LOOP
        REMOVE subServiceType FROM subArrPrivService SETTING typePos
    WHILE subServiceType
        masterPosAf = ''
        masterPosAv = ''
        serviceEmpty = ''
        FIND subServiceType IN maArrPrivService SETTING masterPosAf,masterPosAv THEN
* if the service found in master and value lower than the sub the sub value will be changed directly
            IF (maArrPrivServiceActive<masterPosAf> EQ '') THEN
                serviceEmpty = "True"
            END
            IF (maArrPrivServiceActive<masterPosAf> EQ '') AND (subArrPrivServiceActive<countPrivService> NE maArrPrivServiceActive<masterPosAf>) THEN
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "SERVICE.ACTIVE:":countPrivService
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrPrivServiceActive<masterPosAf>
                countFieldName = countFieldName + 1
                masterLvlChangeRes = 'True'
            END
* if the service found in master and value higher than the sub will display an info when sub is open
            IF (maArrPrivServiceActive<masterPosAf> EQ 'Yes') AND (subArrPrivServiceActive<countPrivService> NE maArrPrivServiceActive<masterPosAf>) THEN
* display an information when open the subArrangement - this service can be added
                masterLvlChangeAug = 'True'
            END
            GOSUB CheckSubArrOperation
        END
        countPrivService = countPrivService + 1
        serviceEmpty = ''
    REPEAT
RETURN

*-----------------------------------------------------------------------------
CheckSubArrOperation:
    countSubArrPrivOperation = 1
    tempsubArrPrivOperation = subArrPrivOperation<countPrivService>
    tempMasArrPrivOperation = maArrPrivOperation<masterPosAf>
    subValues = ''
* loop all the intervals from subArr
    LOOP
        REMOVE subValues FROM tempsubArrPrivOperation SETTING subTypePos
    WHILE subValues
        subTypePos = ''
        subMasterPosAv = ''
        subMasterPosAs = ''
        FIND subValues IN tempMasArrPrivOperation SETTING subMasterPos,subMasterPosAv,subMasterPosAs THEN
* if the operation found in master and value lower than the sub the sub value will be changed directly
            IF (serviceEmpty EQ '') AND (maArrPrivOperationActive<masterPosAf,subMasterPosAv> EQ '') AND (subArrPrivOperationActive<countPrivService,countSubArrPrivOperation> NE maArrPrivOperationActive<masterPosAf,subMasterPosAv>) THEN
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "OPERATION.ACTIVE:":countPrivService:":":countSubArrPrivOperation
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = maArrPrivOperationActive<masterPosAf,subMasterPosAv>
                countFieldName = countFieldName + 1
                masterLvlChangeRes = 'True'
            END
            IF (serviceEmpty EQ 'True') AND (subArrPrivOperationActive<countPrivService,countSubArrPrivOperation> NE maArrPrivOperationActive<masterPosAf,subMasterPosAv>)  THEN
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countVM,countFieldName> = "OPERATION.ACTIVE:":countPrivService:":":countSubArrPrivOperation
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countVM,countFieldName> = ''
                countFieldName = countFieldName + 1
                masterLvlChangeRes = 'True'
            END
* if the operation found in master and value higher than the sub will display an info when sub is open
            IF (maArrPrivOperationActive<masterPosAf,subMasterPosAv> EQ 'Yes') AND (subArrPrivOperationActive<countPrivService,countSubArrPrivOperation> NE maArrPrivOperationActive<masterPosAf,subMasterPosAv>) THEN
* display an information when open the subArrangement - this service can be added
                masterLvlChangeAug = 'True'
            END
            countSubArrPrivOperation = countSubArrPrivOperation + 1
        END
    REPEAT
RETURN


END

