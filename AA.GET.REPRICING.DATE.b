* @ValidationCode : MjoxMzU4MjI4NDk0OkNwMTI1MjoxNjA2MjgzMzA2NDQ3OnJhbmdhaGFyc2hpbmlyOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTozMTozMQ==
* @ValidationInfo : Timestamp         : 25 Nov 2020 11:18:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/31 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE AA.ModelBank
SUBROUTINE AA.GET.REPRICING.DATE(ArrangementId, RepricingActivity, AutoManualFlag, RepricingDate)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*
* The routine returns the repricing activity passed based on the AutoManualFlag
* if AutoManualFlag equals 'AUTO'  - the repricing date is taken from AA.SCHEDULED.ACTIVITY table
* if AutoManualFlag equals 'MANUAL'  - the repricing date is taken from AA.USER.ACTIVITY table
* If AutoManualFlag is null then the repricing date is returned from either of the tables based on the RepricingActivity's nature(User triggered/ Scheduled)
*
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
* ArrangementId - Current ArrangementId
*
* RepricingActivity - Activity for which repricing date must be returned
*
* AutoManualFlag - 'AUTO'/'MANUAL'/'' - taken from the field  - InitiationType
*
* Output
*
* RepricingDate - The date taken from Scheduled Activity record or User Activity Record based on the activity passed
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 30/10/20  - Enhancement : 4051785
*             Task : 4051788
*             To return the repricing rate based on the incoming activity and auto manual flags
*
* 16/11/20  - Enhancement : 4051785
*             Task : 4083926
*             To return the due date as repricing date from AA.USER.ACTIVITY table for Initiation Type 'AUTO'
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING AA.Framework
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise ; *
    GOSUB ProcessAction ; *

RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
    RepricingDate = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ProcessAction>
ProcessAction:
*** <desc> </desc>
    BEGIN CASE
        CASE AutoManualFlag EQ 'AUTO'
            GOSUB GetScheduledActivity ; *
        CASE AutoManualFlag EQ 'MANUAL'
            GOSUB GetUserActivity ; *
        CASE 1
            GOSUB GetScheduledActivity ; *
            IF NOT(RepricingDate) THEN
                GOSUB GetUserActivity ; *
            END
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetScheduledActivity>
GetScheduledActivity:
*** <desc> </desc>
    ScheduledActRec = ''
    ActPos = ''
    AA.Framework.LoadStaticData('F.AA.SCHEDULED.ACTIVITY', ArrangementId, ScheduledActRec, Error)

    LOCATE RepricingActivity IN ScheduledActRec<AA.Framework.ScheduledActivity.SchActivityName,1> SETTING ActPos THEN
        RepricingDate = ScheduledActRec<AA.Framework.ScheduledActivity.SchNextDate,ActPos>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetUserActivity>
GetUserActivity:
*** <desc> </desc>
    UserActivityRec = ''
    ActPos = ''
    AA.Framework.LoadStaticData('F.AA.USER.ACTIVITY', ArrangementId, UserActivityRec, Error)

    LOCATE RepricingActivity IN UserActivityRec<AA.Framework.UserActivity.UsrActActivityName,1> SETTING ActPos THEN
        RepricingDate = UserActivityRec<AA.Framework.UserActivity.UsrActDueDate,ActPos>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END




