* @ValidationCode : MjotNjM4MTI1NjE3OkNwMTI1MjoxNTc4NTY0NDE5NjQwOm1oaW5kdW1hdGh5OjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNTozNjozNg==
* @ValidationInfo : Timestamp         : 09 Jan 2020 15:36:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PW.ModelBank
SUBROUTINE E.MB.PW.VIEW.PROCESS.WORKLOAD(yrDetails)
*-----------------------------------------------------------------------------
*
* This subroutine is attached as nofile to the enquiries PW.VIEW.PROCESS.WORKLOAD
* and PW.VIEW.PROCESS.PARTICIPANT.WORKLOAD. The routines calculates the workload
* of each PARTICIPANT group in Workflow.
*
* Out Argument: YrDetails, returns that participantName, Id and number of PW.PROCESS
*               records with the participant
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 17/12/2019 - Enhancement 3396943 / Task 3483737
*              Integration of BSG created screen to L1 PW
*
*-----------------------------------------------------------------------------
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.Browser
    $USING PW.Foundation


    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------


INITIALISE:

    fnPwParticipant = 'F.PW.PARTICIPANT'
    fvPwParticipant = ''
    EB.DataAccess.Opf(fnPwParticipant,fvPwParticipant)

    fnPwActivityTxn = 'F.PW.ACTIVITY.TXN'
    fvPwActivityTxn = ''
    EB.DataAccess.Opf(fnPwActivityTxn,fvPwActivityTxn)

    fnPwProcess = 'F.PW.PROCESS'
    fvPwProcess = ''
    EB.DataAccess.Opf(fnPwProcess,fvPwProcess)

RETURN

*-----------------------------------------------------------------------------

PROCESS:

    TableName = "PW.PARTICIPANT"
    TheList = EB.DataAccess.DasAllIds
    EB.DataAccess.Das(TableName, TheList, "", "")
    TheList = SORT(TheList)
    LOOP
        REMOVE yrPwParticipantId FROM TheList SETTING partPos
    WHILE yrPwParticipantId:partPos
        yrPwParticipantRec = PW.Foundation.Participant.CacheRead(yrPwParticipantId, readErr)
        IF NOT(readErr) THEN
            yrPwParticipantDesc = yrPwParticipantRec<PW.Foundation.Participant.PartDescription>
            GOSUB SELECT.PW.PROCESS
        END
    REPEAT


RETURN
*-----------------------------------------------------------------------------


SELECT.PW.PROCESS:
    
    TableName = "PW.PROCESS"
    pwProcessList = PW.Foundation.dasPwProcessList
    TheArgs = "RUNNING":@FM:yrPwParticipantId
    EB.DataAccess.Das(TableName, pwProcessList, TheArgs, "")
    IF pwProcessList THEN
        selectedNos = DCOUNT(pwProcessList,@FM)
        yrDetails<-1> = yrPwParticipantDesc:'*':yrPwParticipantId:'*':selectedNos
    END

RETURN
*-----------------------------------------------------------------------------

END
