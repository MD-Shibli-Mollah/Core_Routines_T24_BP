* @ValidationCode : MjotMTA2ODAwMjQwNTpjcDEyNTI6MTU0Mzk5NTUxODE0MDpzYXNpa3VtYXJ2OjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMTgtMTUxMDoxNzoxNw==
* @ValidationInfo : Timestamp         : 05 Dec 2018 13:08:38
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sasikumarv
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 17/17 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181118-1510
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE ST.DormancyMonitor
SUBROUTINE ST.CDM.EXTERNAL.ACTIVITY.HANDOFF(CUSTOMER.ID,ACTIVITY.DETAILS,RESET.FLAG,RESERVED.IN,ERROR.DETAILS,RESERVED.OUT)
*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : vkrishnapriya@temenos.com
* Program Name   : ST.CDM.EXTERNAL.ACTIVITY.HANDOFF
* Module Name    : ST
* Component Name : ST_DormancyMonitor
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*   22/11/2018  - Enhancement 2857423 / Task 2857778
*                 New Api to pass the external activity details to Cdm trigger handoff
*
*-----------------------------------------------------------------------------

    $USING ST.DormancyMonitor

    GOSUB INITIALISE ; *Initialisation of variables

    GOSUB DETERMINE.STATUS.AND.DATE ; *To determine the status based on the Reset flag

    GOSUB PROCESS.EXTERNAL.REQUEST ; *To call the trigger handoff

RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialisation of variables </desc>

    HANDOFF.STATUS = '' ;* Holds the status to be passed to the Trigger Handoff api
    ACTIVITY.DATE = '' ;* Holds the Activity date from the Activity details passed

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= DETERMINE.STATUS.AND.DATE>
DETERMINE.STATUS.AND.DATE:
*** <desc>To determine the status based on the Reset flag </desc>

* If Reset Flag is set then pass the status as RESET , else as CHECK
* Fetch the Activity date fomr the Activity details
    
    IF RESET.FLAG THEN
        HANDOFF.STATUS = 'RESET'
        ACTIVITY.DATE = FIELD(ACTIVITY.DETAILS,'*',1)
        ACTIVITY.DETAILS = ''
    END ELSE
        HANDOFF.STATUS = 'CHECK'
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS.EXTERNAL.REQUEST>
PROCESS.EXTERNAL.REQUEST:
*** <desc>To call the trigger handoff </desc>

    ST.DormancyMonitor.CdmTriggerHandoff(CUSTOMER.ID, 'EXTERNAL', HANDOFF.STATUS, ACTIVITY.DATE, ACTIVITY.DETAILS, '', '', '')

RETURN
*** </region>

END
