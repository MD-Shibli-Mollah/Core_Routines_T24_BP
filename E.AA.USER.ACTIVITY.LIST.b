* @ValidationCode : MjotMTM2Nzg2NTM2NzpDcDEyNTI6MTUwODc0MzIwOTEyNTptamVuc2VuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MTEuMjAxNzA5MzAtMDAxMzo0MTo0MQ==
* @ValidationInfo : Timestamp         : 23 Oct 2017 09:20:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjensen
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/41 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201711.20170930-0013
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.USER.ACTIVITY.LIST(ACT.IDS)
*-----------------------------------------------------------------------------
*Description
* This routine returns the user activity list that need to be displayed for any arrangement
*-----------------------------------------------------------------------------
*Modification History
*
* 06/05/09 - CI_10062772
*            Activities after CALCULATE-PAYOFF are not displayed if they dont
*            have a valid property class -> like LENDING-RENEGOTIATE-ARRANGEMENT
*
* 20/10/17 - Enhancement: 2247535
*            Task: 2309921
*            Allow also SETTLE action for PAYOFF
*-----------------------------------------------------------------------------

    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
************************************
INITIALISE:
************
*
    ACT.IDS = ''
*
    LOCATE 'ARRANGEMENT' IN EB.Reports.getEnqSelection()<2,1> SETTING PROD.POS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,1>
    END
*
    R.AA.ARR = ''; FV.ARR = ''; READ.ERR = ''
    EFF.DATE = EB.SystemTables.getToday(); PROP.LIST = ''; CLASS.LIST = ''
    AA.Framework.GetArrangementProduct(ARR.ID, EFF.DATE, R.AA.ARR, PROD.ID, PROP.LIST)
    AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)
*
RETURN
******************
PROCESS:
******************
*
    AA.Framework.BuildActivities(PROD.ID,1,1,ARR)     ;*New parameter added
    CONVERT '_' TO @FM IN ARR
    LOOP
        REMOVE ACTIVITY.ID FROM ARR SETTING ACT.POS
        R.ACTIVITY = AA.ProductFramework.Activity.CacheRead(ACTIVITY.ID, "")
        IF R.ACTIVITY<AA.ProductFramework.Activity.ActLinkedActivity> THEN
            ACTIVITY = R.ACTIVITY<AA.ProductFramework.Activity.ActLinkedActivity>   ;*Get the linked activity
        END ELSE
            ACTIVITY = ACTIVITY.ID
        END
        ACTION = FIELD(ACTIVITY, AA.Framework.Sep, 2)
    WHILE ACTIVITY:ACT.POS    ;*Check the activity
*Exclude Payoff & Amend History
        IF ACTION EQ 'AMEND.HISTORY' ELSE
            PROP = FIELD(ACTIVITY, AA.Framework.Sep, 3)
            LOCATE PROP IN PROP.LIST<1,1> SETTING PROP.POS THEN
                PROP.CLS = CLASS.LIST<1,PROP.POS>
            END ELSE
                PROP.CLS = PROP         ;*should be arrangement
            END
            BEGIN CASE
                CASE PROP.CLS EQ 'PAYOFF' AND ACTION MATCHES 'UPDATE':@VM:'SETTLE' ;* For PAYOFF allow UPDATE and SETTLE
                    ACT.IDS<-1> = ACTIVITY.ID
                CASE PROP.CLS EQ 'PAYOFF'                                          ;* Don't allow anything else for PAYOFF
                CASE 1
                    ACT.IDS<-1> = ACTIVITY.ID                                      ;* Allow all other activities
            END CASE
*test
        END
    REPEAT

RETURN
