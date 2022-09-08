* @ValidationCode : Mjo3MDI5NDM3MzA6Q3AxMjUyOjE1NzgxMzExOTMxNjM6c211Z2VzaDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6NTY6NTY=
* @ValidationInfo : Timestamp         : 04 Jan 2020 15:16:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 56/56 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PRIVILEGES.UPDATE.SUBARR
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Description:
* Provides cross-validation of data entered in the property classes TC.PRIVILEGES, TC.PERMISSIONS, TC.AVAILABILITY and PROTECTION.LIMIT,
* at product designer and arrangement levels - Master Update validations
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History:
*
* 25/01/2018 - Enhancement 2379129 / Task 2433777
*              SubArrangements update when the master is updated
*
* 04/01/20 - Enhancement 3504695 / Task 3521090
*            TCIB Limit Authorisation Enhancement changes - Adding activity status condition
*** </region>
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AO.Framework
    $USING EB.Interface
    $USING EB.Foundation
    $USING AF.Framework
*-----------------------------------------------------------------------------
    processTxt = TRIM(EB.SystemTables.getValText(), "", "D")
    activityStatus = AF.Framework.getC_arractivitystatus()["-",1,1]          ;* Arrangement Activity status
    IF processTxt EQ 'AUTHORISED' OR (activityStatus EQ 'AUTH' AND NOT(AA.Framework.getNewArrangement())) THEN     ;* Only during authorisation...
        GOSUB Initialise
        GOSUB Process
    END
    
RETURN
*-----------------------------------------------------------------------------
Process:
* read the arrangement record for current arrangement ID
    arrangementRecord=''
    errMsg=''
    masterArrangementId = AA.Framework.getArrId()
    arrangementRecord = AA.Framework.Arrangement.Read(masterArrangementId, errMsg)
    
* read the field SubArrangement of the current arrangement record. If the field is not NULL, means current arrangement is a Master arrangement
    subArrList = arrangementRecord<AA.Framework.Arrangement.ArrSubArrangement>
    IF subArrList NE '' THEN
        GOSUB SubArrangementUpdate
    END

RETURN
*-----------------------------------------------------------------------------
SubArrangementUpdate:
    subarrangementId = ''
    LOOP
        REMOVE subarrangementId FROM subArrList SETTING subTypePos
    WHILE subarrangementId
* for each subarrangement ID, build AA.Arrangement.Activity record that will be send through OFS message, for update the 4 properties
        ofsArrActivityRecord = ''
        GOSUB SubArrangementDailylimitsUpdate
        GOSUB SubArrangementPrivilegesUpdate
        GOSUB SubArrangementAvailabilityUpdate
        GOSUB SubArrangementPermissionsUpdate

*       build ofs message
        IF ofsArrActivityRecord NE '' THEN
            GOSUB BuildOfsMessage
            GOSUB SendOfsRequest
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
SubArrangementDailylimitsUpdate:
*   calls the routine that compare master with subarrangement and append into AA.Arrangement.Activity record data for ProtectionLimit property
    AO.Framework.TcUpdateDailylimits(subarrangementId,ofsArrActivityRecord)
RETURN
*-----------------------------------------------------------------------------
SubArrangementPrivilegesUpdate:
*   calls the routine that compare master with subarrangement and append into AA.Arrangement.Activity record data for Privileges property
    AO.Framework.TcUpdatePrivileges(subarrangementId,ofsArrActivityRecord)
RETURN
*-----------------------------------------------------------------------------
SubArrangementAvailabilityUpdate:
*   calls the routine that compare master with subarrangement and append into AA.Arrangement.Activity record data for Availability property
    AO.Framework.TcUpdateAvailability(subarrangementId,ofsArrActivityRecord)
RETURN
*-----------------------------------------------------------------------------
SubArrangementPermissionsUpdate:
*   calls the routine that compare master with subarrangement and append into AA.Arrangement.Activity record data for Permissions property
    AO.Framework.TcUpdatePermissions(subarrangementId,ofsArrActivityRecord)
RETURN
*-----------------------------------------------------------------------------
BuildOfsMessage:
*   inlcude into AA.Arrangement.Activity record the subArrID and Activity
    appName  = 'AA.ARRANGEMENT.ACTIVITY'
    ofsFunction = 'I'
    process = 'PROCESS'
    ofsVersion = 'AA.ARRANGEMENT.ACTIVITY,TC'
    gtsMode = ''
    noOfAuth = '0'
*
    ofsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActArrangement> = subarrangementId
    ofsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActActivity> = "ONLINE.SERVICES-UPDATE-ARRANGEMENT"
*
*   build OFS message
    EB.Foundation.OfsBuildRecord(appName,ofsFunction,process,ofsVersion,gtsMode,noOfAuth,'',ofsArrActivityRecord,ofsMessage)
RETURN
*-----------------------------------------------------------------------------
SendOfsRequest:
*   send OFS request
    ofsSourceId = "AA.COB":@FM:"OFS":@FM:"AA"     ;* Use the generic AA source
    callInfo = ""
    callInfo<1> = ofsSourceId
    EB.Interface.OfsCallBulkManager(callInfo, ofsMessage, ofsResponse, '')

RETURN
*-----------------------------------------------------------------------------
Initialise: ;* Initialise the required variables
    ofsArrActivityRecord = ''
RETURN
*-----------------------------------------------------------------------------
END
