* @ValidationCode : MTotMTY2NjA4ODE0NDpJU08tODg1OS0xOjE0NzI2MTg1MDM0MzY6aGFyaXByYXNhdGg6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDguMA==
* @ValidationInfo : Timestamp         : 31 Aug 2016 10:11:43
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : hariprasath
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE AA.Facility
    SUBROUTINE SETTLEMENT.EXIT.API(EventType,ApplicationName,ApplicationId,ProcessType,ExitFlag)
*-----------------------------------------------------------------------------
*
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Its a exist API for TEC inline processing for AA. Currently the tec emit will not
*** required during R&R and scheduled activities.
*** </region>
*-----------------------------------------------------------------------------
* @uses  		: AA.Facility.CheckArrangementServiceExitPoints
* @access		: public
* @stereotype 	: subroutine
* @author 		: hariprasath@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param EventType				- Processing Event Type
* @param ApplicationName		- Processing Application
* @param ApplicationId			- Current Application id 

* Output
*
* @param ExitFlag				- Exit flag

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 21/08/16 - Enhancement : 1791962
*			 Task : 1791958
*            API which is called from TEC Inline processing for the event type SETTLEMENT-SERVICE

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AA.Facility


*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>
    
    GOSUB Initialise			;* Initialise the variables
    GOSUB CheckCoreExitPoints   ;* Default core exit critria
    GOSUB CheckLocalExitPoints	;* Local exit critria if any
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise the variables</desc>
Initialise:

    
    ExitFlag = ""		;* If application want to exit the process
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckCoreExitPoints>
*** <desc>Core exist critria</desc>
CheckCoreExitPoints:

    AA.Facility.CheckArrangementExitPoints(EventType, ApplicationName, ApplicationId, ExitFlag)  ;* Core check for exit critria
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckLocalExitPoints>
*** <desc>Local exist critria</desc>
CheckLocalExitPoints:

    IF NOT(ExitFlag) THEN		;* Core not issue any exit flag
***    If you required, issue exit flag based on local logic!    
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END


