* @ValidationCode : MjotNzA4NjUzMTg6Q3AxMjUyOjE1NTc0MTIyODIxODc6bWhpbmR1bWF0aHk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNC4yMDE5MDQxMC0wMjM5OjExMDo4Ng==
* @ValidationInfo : Timestamp         : 09 May 2019 20:01:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 86/110 (78.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PW.ModelBank
SUBROUTINE E.PW.ACTIVITIES.LIST(ENQ.DATA)
*-----------------------------------------------------------------------------
* Modification History:
*
*
* 03/07/15   -       defect: 1364462 task :  1392901
*                   Drill Down Enquiry not working for pending task in CSAGENT homepage
*
* 10/03/16 - Enhancement 1499015
*	       - Task 1654637
*	       - Routine incorporated
*
* 13/02/19 - Enhancement 2822523
*          - Task 2988373
*          - Componentization - PW.ModelBank
*
* 09/05/19 - Defect 3119682
*          - Task 3121760
*          - Not able to view the pending activities in the enquiry PW.ACTIVITIES.LIST.
*-----------------------------------------------------------------------------
*
* Subroutine Type : BUILD Routine
* Attached to     : PW.ACTIVITIES.LIST
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

    LOCATE '@ID' IN ENQ.DATA<2,1> SETTING PW.PROCESS.POS THEN
        PW.PROCESS.ID = ENQ.DATA<4,PW.PROCESS.POS>

        IF PW.PROCESS.ID THEN
            TABLE.NAME   = "PW.PARTICIPANT"
            TABLE.SUFFIX = ""
            PW.LIST1     = PW.Foundation.dasPwParticipantDaoUser
            ARGUMENTS = Y.DEPARTMENT.CODE:@FM:Y.USER
            EB.DataAccess.Das(TABLE.NAME, PW.LIST1, ARGUMENTS, TABLE.SUFFIX)

            GOSUB PROCESS.OWNER
        END
    END

RETURN

**************
PROCESS.OWNER:
**************

    PW.CNT1 = DCOUNT(PW.LIST1,@FM)
    IF PW.LIST1 EQ "0" THEN
        PW.LIST1 = ""
    END

    LOCATE 'OWNER' IN ENQ.DATA<2,1> SETTING PW.OWNER.POS THEN
        Y.FIX.DATA = ENQ.DATA<4,PW.OWNER.POS>
        Y.FIX.DATA = CHANGE(Y.FIX.DATA," ",@VM)

        IF Y.FIX.DATA EQ "BRANCH" THEN
            R.PW.PARTICIPANT = PW.Foundation.Participant.CacheRead('BRANCH', ERR.PW.PAR)
            Y.LIST.DAO = R.PW.PARTICIPANT<PW.Foundation.Participant.PartAcctOfficer>
            Y.LIST.DAO = CHANGE(Y.LIST.DAO,@VM,"' '")

            TABLE.NAME2   = "PW.PARTICIPANT"
            TABLE.SUFFIX2 = ""
            PW.LIST2     = PW.Foundation.dasPwParticipantDao
            ARGUMENTS2 = "'":Y.LIST.DAO:"'"

            EB.DataAccess.Das(TABLE.NAME2, PW.LIST2, ARGUMENTS2, TABLE.SUFFIX2)
            Y.FINAL = PW.LIST2
            Y.FINAL = CHANGE(Y.FINAL,@FM," ")
        END ELSE
            IF PW.CNT1 EQ 1 AND PW.LIST1 MATCHES Y.FIX.DATA THEN
                Y.FINAL := PW.LIST1 ;* Processing when there is only 1 value
            END ELSE
                FOR K=1 TO PW.CNT1
                    IF PW.LIST1<K> MATCHES Y.FIX.DATA THEN   ;* When more than one owner is given in selection criteria and if it matches the DAS results. (E.g Y.FIX.DATA can have given as 'BRANCH CALL.CENTER'in the enquiry selection criteria)
                        Y.FINAL := PW.LIST1<K> : " "         ;* store the value with a space appended
                    END
                NEXT K
            END
        END
        ENQ.DATA<2> = ''
        ENQ.DATA<3> = ''
        ENQ.DATA<4> = ''
    END ELSE
        PW.LIST1 = CHANGE(PW.LIST1,@FM," ")
        Y.FINAL = PW.LIST1
    END
    Y.FINAL = TRIM(Y.FINAL) ;* trim the extra space added at the end
    Y.FINAL := " CALL.CENTRE.AGENT"
    Y.FINAL.MATCH = CHANGE(Y.FINAL," ",@VM)
    Y.FINAL = CHANGE(Y.FINAL," ","' '")

    IF Y.FINAL THEN
        GOSUB PROCESS.FINAL
    END ELSE
* Using invalid field - not to select any records
        ENQ.DATA<2,-1> = 'TEST'
        ENQ.DATA<3,-1> = 'EQ'
        ENQ.DATA<4,-1> = ''
    END

RETURN

**************
PROCESS.FINAL:
**************

    TABLE.NAME   = "PW.PROCESS"
    TABLE.SUFFIX = ""
    PW.LIST     = PW.Foundation.dasPwProcessActivityList
    ARGUMENTS = PW.PROCESS.ID:@FM:"RUNNING":@FM:"'":Y.FINAL:"'"

    EB.DataAccess.Das(TABLE.NAME, PW.LIST, ARGUMENTS, TABLE.SUFFIX)
    PW.CNT = DCOUNT(PW.LIST,@FM)

    FOR I=1 TO PW.CNT
        GOSUB PROCESS.PW
    NEXT I

    IF Y.PW.PENDING.ACT THEN
        ENQ.DATA<2,-1> = '@ID'
        ENQ.DATA<3,-1> = 'EQ'
        ENQ.DATA<4,-1> = TRIM(Y.PW.PENDING.ACT)
    END ELSE
* Using invalid field - not to select any records
        ENQ.DATA<2,-1> = 'TEST'
        ENQ.DATA<3,-1> = 'EQ'
        ENQ.DATA<4,-1> = ''
    END

RETURN

***********
PROCESS.PW:
***********

    R.PW.PROCESS = ""
    R.PW.PROCESS = PW.Foundation.Process.Read(PW.LIST<I>, ERR.PW.PROCESS)
    Y.ACT.TXN.IDS = R.PW.PROCESS<PW.Foundation.Process.ProcActivityTxn>
    Y.PROC.COMP = R.PW.PROCESS<PW.Foundation.Process.ProcCompleted>
    Y.CNT = DCOUNT(Y.ACT.TXN.IDS,@VM)

    FOR J=1 TO Y.CNT
        IF Y.PROC.COMP<1,J> NE 'Y' THEN
            R.PW.ACTIVITY.TXN = PW.Foundation.ActivityTxn.Read(Y.ACT.TXN.IDS<1,J>, ERR.PW.ACTIVITY)
            Y.STATUS = R.PW.ACTIVITY.TXN<PW.Foundation.ActivityTxn.ActTxnPwActivityStatus>
            Y.ACT.OWNER = R.PW.ACTIVITY.TXN<PW.Foundation.ActivityTxn.ActTxnOwner>

            IF J=1 AND Y.STATUS EQ 'ABORTED' THEN
                J=Y.CNT
            END ELSE
                IF Y.ACT.OWNER MATCHES Y.FINAL.MATCH THEN
                    Y.PW.PENDING.ACT := Y.ACT.TXN.IDS<1,J> : " "
                END
            END
        END
    NEXT J

RETURN

*-----------------------------------------------------------------------------------
INITIALISE:

    PW.PROCESS.ID = ''
    Y.PW.PENDING.ACT = ""
    PW.LIST = ""
    PW.LIST1 = ""
    Y.FINAL = ""

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------

END
