* @ValidationCode : MjotMTA3NTAxNzQ1MTpDcDEyNTI6MTU3ODU2NDQxOTM1ODptaGluZHVtYXRoeToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAxLjIwMTkxMjI0LTE5MzU6NTg6NTg=
* @ValidationInfo : Timestamp         : 09 Jan 2020 15:36:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/58 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PW.ModelBank
SUBROUTINE E.MB.PW.VIEW.ACTIVITY.WORKLOAD(YrDetails)
*-----------------------------------------------------------------------------
*
* This subroutine is attached as nofile to the enquiries PW.VIEW.ACTIVITY.WORKLOAD
* and PW.VIEW.ACTIVITY.PARTICIPANT.WORKLOAD. The routines calculates the workload
* of each Department Acct Officer related to a PW Process.
*
* Out Argument: YrDetails, returns that acctOfficerName, Id and number of PW.ACTIVITY.TXN
*               records with the accountOfficerid
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
    $USING ST.Config

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
    
    fnDeptAcctOfficer = 'F.DEPT.ACCT.OFFICER'
    fvDeptAcctOfficer = ''
    EB.DataAccess.Opf(fnDeptAcctOfficer,fvDeptAcctOfficer)

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
            yrPwParticipantAcctOfficer = yrPwParticipantRec<PW.Foundation.Participant.PartAcctOfficer>
            LOOP
                REMOVE yrDeptAcctOfficerId FROM yrPwParticipantAcctOfficer SETTING deptPos
            WHILE yrDeptAcctOfficerId:deptPos
                yrDeptAcctOffRec = ST.Config.DeptAcctOfficer.CacheRead(yrDeptAcctOfficerId, err)
                IF NOT(err) THEN
                    yrDeptAcctOfficerName = yrDeptAcctOffRec<ST.Config.DeptAcctOfficer.EbDaoName>
                    yrDeptAcctOfficer = yrDeptAcctOfficerName:'*':yrDeptAcctOfficerId
                END
                LOCATE yrDeptAcctOfficer IN yrDeptAcctOfficerVar SETTING daoPos ELSE
                    yrDeptAcctOfficerVar<-1> = yrDeptAcctOfficer
                END

            REPEAT
        END
    REPEAT

    yrDeptAcctOfficerVar = SORT(yrDeptAcctOfficerVar)
    
    GOSUB SELECT.PW.RECORDS
RETURN
*-----------------------------------------------------------------------------

SELECT.PW.RECORDS:

    LOOP
        REMOVE yrDeptAcctOfficer FROM yrDeptAcctOfficerVar SETTING pwPos
    WHILE yrDeptAcctOfficer:pwPos
        yrDeptAcctOfficerName = FIELD(yrDeptAcctOfficer,'*',1)
        yrDeptAcctOfficerId = FIELD(yrDeptAcctOfficer,'*',2)

        yrSelectCmd = 'SELECT ':fnPwActivityTxn:' WITH USER EQ ':yrDeptAcctOfficerId
        yrSelectCmd := ' AND WITH COMPLETION.DATE EQ ""':' AND WITH PW.ACTIVITY.STATUS NE ABORTED'
        yrSelectedIds = ''
        yrSelectedNos = ''
        EB.DataAccess.Readlist(yrSelectCmd,yrSelectedIds,'',yrSelectedNos,'')
        IF yrSelectedNos THEN
            YrDetails<-1> = yrDeptAcctOfficerName:'*':yrDeptAcctOfficerId:'*':yrSelectedNos
        END
    REPEAT

RETURN
*-----------------------------------------------------------------------------
END
