* @ValidationCode : MjotNzIzMTAwNTMwOkNwMTI1MjoxNTUwMTIxNjY0NzkxOm1oaW5kdW1hdGh5Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4yMDE5MDIwOS0wNDAxOi0xOi0x
* @ValidationInfo : Timestamp         : 14 Feb 2019 10:51:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190209-0401
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-94</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PW.ModelBank
SUBROUTINE E.PW.PENDING.PROCESS(ENQ.DATA)
*
* Subroutine Type : BUILD Routine
* Attached to     : PW.PENDING.PROCESS
* Attached as     : Build Routine
* Primary Purpose :
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
* Error Variables:
* ----------------
*
* Modification History
* ----------------------
*          Defect 350954 / Task 428057
*                The Modification done in the routine is used to get the status of the field COMPLETED in
*                PW.PROCESS application.If the activity is completed it won't go to PW.ACTIVITY.TXN for
*                further process
*
* 10/03/16 - Enhancement 1499015
*	       - Task 1654637
*	       - Routine incorporated
*
* 13/02/19 - Enhancement 2822523
*          - Task 2988373
*          - Componentization - PW.ModelBank
*-----------------------------------------------------------------------------
    $USING PW.Foundation
    $USING EB.Security
    $USING EB.DataAccess
    $USING EB.SystemTables



    GOSUB INITIALISE
    GOSUB PROCESS

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    Y.DEPARTMENT.CODE = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    Y.USER = EB.SystemTables.getOperator()

    TABLE.NAME   = "PW.PARTICIPANT"
    TABLE.SUFFIX = ""
    PW.LIST     = PW.Foundation.dasPwParticipantDaoUser
    ARGUMENTS = Y.DEPARTMENT.CODE:@FM:Y.USER

    EB.DataAccess.Das(TABLE.NAME,PW.LIST,ARGUMENTS,TABLE.SUFFIX)

    IF PW.LIST = "0" THEN
        PW.LIST = ""
    END

    PW.CNT = DCOUNT(PW.LIST,@FM)

    LOCATE 'OWNER' IN ENQ.DATA<2,1> SETTING PW.OWNER.POS THEN
        GOSUB PROCESS.OWNER
    END ELSE
        IF PW.LIST THEN
            PW.LIST = CHANGE(PW.LIST,@FM," ")
            Y.FINAL = TRIM(PW.LIST)
        END
    END

    Y.FINAL := " CALL.CENTRE.AGENT"
    Y.FINAL.MATCH = CHANGE(Y.FINAL," ",@VM)

    IF Y.FINAL THEN
        TABLE.NAME1   = "PW.PROCESS"
        TABLE.SUFFIX1 = ""
        PW.PR.LIST    = PW.Foundation.dasPwProcessList
        Y.FINAL = CHANGE(TRIM(Y.FINAL)," ","' '")
        ARGUMENTS1 = "RUNNING":@FM:"'":Y.FINAL:"'"
        EB.DataAccess.Das(TABLE.NAME1,PW.PR.LIST,ARGUMENTS1,TABLE.SUFFIX1)
        PW.PR.CNT = DCOUNT(PW.PR.LIST,@FM)

        FOR J=1 TO PW.PR.CNT
            GOSUB PROCESS.ACTIVITY
        NEXT J

        ENQ.DATA<2,-1> = "@ID"
        ENQ.DATA<3,-1> = "EQ"
        ENQ.DATA<4,-1> = TRIM(Y.PW.PENDING.PRO)
    END ELSE
* Using invalid field - not to select any records
        ENQ.DATA<2,-1> = 'TEST'
        ENQ.DATA<3,-1> = 'EQ'
        ENQ.DATA<4,-1> = ''
    END

RETURN

*****************
PROCESS.ACTIVITY:
*****************

    R.PW.PROCESS = ""
    R.PW.PROCESS = PW.Foundation.Process.Read(PW.PR.LIST<J>, ERR.PW.PROCESS)
    Y.ACT.TXN.IDS = R.PW.PROCESS<PW.Foundation.Process.ProcActivityTxn>
    Y.PROC.COMP = R.PW.PROCESS<PW.Foundation.Process.ProcCompleted>
    ACT.CNT = DCOUNT(Y.ACT.TXN.IDS,@VM)

    FOR K=1 TO ACT.CNT
        IF Y.PROC.COMP<1,K> NE 'Y' THEN
            R.PW.ACTIVITY.TXN  = ""
            R.PW.ACTIVITY.TXN = PW.Foundation.ActivityTxn.Read(Y.ACT.TXN.IDS<1,K>, ERR.PW.ACTIVITY)
            Y.STATUS = R.PW.ACTIVITY.TXN<PW.Foundation.ActivityTxn.ActTxnPwActivityStatus>
            Y.ACT.OWNER = R.PW.ACTIVITY.TXN<PW.Foundation.ActivityTxn.ActTxnOwner>
            IF K=1 AND Y.STATUS EQ 'ABORTED' THEN
                K=ACT.CNT
            END ELSE
                IF Y.ACT.OWNER MATCHES Y.FINAL.MATCH THEN
                    Y.PW.PENDING.PRO := PW.PR.LIST<J> : " "
                END
            END
        END
    NEXT K

RETURN

**************
PROCESS.OWNER:
**************

    Y.FIX.DATA = ENQ.DATA<4,PW.OWNER.POS>
    ENQ.DATA<2,PW.OWNER.POS> = ""
    ENQ.DATA<3,PW.OWNER.POS> = ""
    ENQ.DATA<4,PW.OWNER.POS> = ""

    Y.FIX.DATA = CHANGE(Y.FIX.DATA," ",@VM)

    IF Y.FIX.DATA EQ "BRANCH" THEN
        R.PW.PARTICIPANT = PW.Foundation.Participant.CacheRead('BRANCH', ERR.PW.PAR)
        Y.LIST.DAO = R.PW.PARTICIPANT<PW.Foundation.Participant.PartAcctOfficer>
        Y.LIST.DAO = CHANGE(Y.LIST.DAO,@VM,"' '")

        PW.LIST1 = PW.Foundation.dasPwParticipantDao
        ARGUMENTS1 = "'":Y.LIST.DAO:"'"

        EB.DataAccess.Das(TABLE.NAME,PW.LIST1,ARGUMENTS1,TABLE.SUFFIX)
        Y.FINAL = PW.LIST1
        Y.FINAL = CHANGE(Y.FINAL,@FM," ")
    END ELSE
        FOR K=1 TO PW.CNT
            IF PW.LIST<K> MATCHES Y.FIX.DATA THEN
                Y.FINAL := PW.LIST<K> : " "
            END
        NEXT K
    END

RETURN

*-----------------------------------------------------------------------------------
INITIALISE:

    PW.LIST = ""
    Y.FINAL = ""

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------
END
