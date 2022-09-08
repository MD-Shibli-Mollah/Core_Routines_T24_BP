* @ValidationCode : MjoxNzA2NjQzNzUyOkNwMTI1MjoxNTQwMTk2MjMyOTc0OmRtYXRlaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjAtMTcyNjotMTotMQ==
* @ValidationInfo : Timestamp         : 22 Oct 2018 11:17:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181020-1726
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.UPDATE.ARRANGEMENT.EXTUSER(arrangementId, ebExternalUserIDList, arrangementExtuserRecord, changeStatus)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Description:
* This routine will update records in the concat file AA.ARRANGEMENT.EXTUSER
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History:
*
* 04/10/18 - Defect 2809449  / Task 2809588 - Redesign AA.TC.PERMISSIONS.UPDATE routine as per retail team review
*
*** </region>
*-----------------------------------------------------------------------------
    $USING EB.Channels

    GOSUB Initialise
    GOSUB Process

*
RETURN
*-----------------------------------------------------------------------------
Initialise:
* Initialise the required variables
    
*
RETURN
*-----------------------------------------------------------------------------
Process:
    GOSUB UpdateAaArrExtUser
RETURN
*-----------------------------------------------------------------------------
UpdateAaArrExtUser:
* update the AA.ARRANGEMENT.EXTUSER table
* Find the current EB.EXTERNAL.USER ID in the arrangementExtuserRecord, if found then the flag will be updated to 'Yes' if not will be added
* update if the current arrangement is a master
    LOOP
        REMOVE ebExternalUserID FROM ebExternalUserIDList SETTING typePos
    WHILE ebExternalUserID
        FIND ebExternalUserID IN arrangementExtuserRecord SETTING fmPos,vmPos THEN
            IF arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserStatus,vmPos> EQ 'AUTH' THEN
                arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserRebuild,vmPos> = 'Yes'
            END
        END
    REPEAT
* update if the current arrangement is a subArr
    IF (changeStatus EQ 'Restricted') OR (changeStatus EQ 'Changed') THEN
        aaeuSubArrList = arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubArrangementId>
        subArrCnt=1
        LOOP
            REMOVE subArrID FROM aaeuSubArrList SETTING typePos
        WHILE subArrID
            eeuSubList = arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserId, subArrCnt>
            subEuCnt=1
            LOOP
                REMOVE ebExtUserSubID FROM eeuSubList SETTING subTypePos
            WHILE ebExtUserSubID
                IF arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserStatus,subArrCnt,subEuCnt> EQ 'AUTH' THEN
                    arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserRebuild,subArrCnt,subEuCnt> = 'Yes'
                END
                subEuCnt = subEuCnt + 1
            REPEAT
            subArrCnt = subArrCnt + 1
        REPEAT
    END
    EB.Channels.AaArrangementExtuserWrite(arrangementId,arrangementExtuserRecord)
*
RETURN

*-----------------------------------------------------------------------------
END
