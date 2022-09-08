* @ValidationCode : MjotNTIwMTM0MTM0OkNwMTI1MjoxNTQwMTk2MjMxMTYxOmRtYXRlaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjAtMTcyNjotMTotMQ==
* @ValidationInfo : Timestamp         : 22 Oct 2018 11:17:11
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
SUBROUTINE AA.INSERT.ARRANGEMENT.EXTUSER(arrangementId, masterArrangement, subArrangementId, ebExternalUserIDList)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Description:
* This routine will insert new records in the concat file AA.ARRANGEMENT.EXTUSER

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
    GOSUB InsertAaArrExtUser
RETURN
*-----------------------------------------------------------------------------
InsertAaArrExtUser:
* insert new record the AA.ARRANGEMENT.EXTUSER table
    countPos = 1
    LOOP
        REMOVE ebExternalUserID FROM ebExternalUserIDList SETTING typePos
    WHILE ebExternalUserID
        IF masterArrangement EQ '' THEN
            arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserId,-1> = ebExternalUserID
            arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserStatus,-1> = 'AUTH'
            arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserRebuild,-1> = 'No'
        END ELSE
            IF countPos EQ 1 THEN
                arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubArrangementId,-1> = subArrangementId
            END
            aVpos =  COUNT(arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubArrangementId>,@VM) + 1
            arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserId,aVpos,-1> = ebExternalUserID
            arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserStatus,aVpos,-1> = 'AUTH'
            arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserRebuild,aVpos,-1> = 'No'

        END
        countPos = countPos + 1
    REPEAT
    IF masterArrangement EQ '' THEN
        EB.Channels.AaArrangementExtuserWrite(arrangementId,arrangementExtuserRecord)
    END ELSE
        EB.Channels.AaArrangementExtuserWrite(masterArrangement,arrangementExtuserRecord)
    END
*
RETURN
*-----------------------------------------------------------------------------
END
