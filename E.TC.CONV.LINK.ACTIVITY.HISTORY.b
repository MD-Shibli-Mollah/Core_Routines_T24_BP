* @ValidationCode : MjotNDA2MDg3MzU3OkNwMTI1MjoxNTQxNzYxMzA1ODkxOmRtYXRlaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6MzA6MzA=
* @ValidationInfo : Timestamp         : 09 Nov 2018 13:01:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/30 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.Channels
SUBROUTINE E.TC.CONV.LINK.ACTIVITY.HISTORY
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 27/03/2018 - Initial version
* Defect 2524897 / task 2524946 - TC.AA.ARRANGEMENT and TC.AA.ARRANGEMENT.ACTIVITY enquiries are redesigned to match with TCUA front-end design
*
* Defect 2830026 / task 2832416 - TC.AA.ARRANGEMENT.HISTORY enquiry is not returning the auth/unauth arrangement id if they are more than one product condition with different expiry date. 
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AA.Framework
*-------------------------------------------------------------------------------
    GOSUB INITIALISE                  ;* Initialise variables
    GOSUB BUILD.OUTPUT ;* Build final output array
RETURN
*--------------------------------------------------------------------------------
INITIALISE:
    arrangementId = ''
    activityHistoryRec = ''
    activityRef = ''
    activityStatus =''
    activityRefAuth = ''
    activityRefUnAuth = ''
    activityRefOut = ''
     
RETURN
*--------------------------------------------------------------------------------
BUILD.OUTPUT:
* get the arrangement ID
    arrangementId = EB.Reports.getOData()
* read the activity history for the arrangement
    AA.Framework.ReadActivityHistory(arrangementId, '','', activityHistoryRec)

    activityRef = activityHistoryRec<AA.Framework.ActivityHistory.AhActivityRef>
    activityStatus = activityHistoryRec<AA.Framework.ActivityHistory.AhActStatus>
    
    statusPosFm = ''
    statusPosVm = ''
    statusPosSm = ''
    FIND "AUTH" IN activityStatus SETTING statusPosFm,statusPosVm,statusPosSm THEN
* extract the last AUTH activity
        activityRefAuth = activityRef<statusPosFm,statusPosVm,statusPosSm>
    END
    
    statusPosFm = ''
    statusPosVm = ''
    statusPosSm = ''
    FIND "UNAUTH" IN activityStatus SETTING statusPosFm,statusPosVm,statusPosSm THEN
* extract the last UNAUTH activity
        activityRefUnAuth = activityRef<statusPosFm,statusPosVm,statusPosSm>
    END
    activityRefOut =  activityRefAuth : "*" : activityRefUnAuth
* set the output for the conversion routine
    EB.Reports.setOData(activityRefOut)

RETURN
*-----------------------------------------------------------------------------
END
