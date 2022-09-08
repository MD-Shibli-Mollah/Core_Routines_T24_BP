* @ValidationCode : MjotMjQzOTkxODkwOkNwMTI1MjoxNTUwMTIxNjY0NzQzOm1oaW5kdW1hdGh5Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4yMDE5MDIwOS0wNDAxOi0xOi0x
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
* <Rating>-45</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PW.ModelBank
SUBROUTINE E.PW.ACTIVITIES.LIST.CR.MGR(ENQ.DATA)
*
* Subroutine Type : BUILD Routine
* Attached to     : PW.ACTIVITIES.LIST.CR.MGR
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
**
* Modifications
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

    LOCATE '@ID' IN ENQ.DATA<2,1> SETTING PW.PROCESS.POS THEN
        PW.PROCESS.ID = ENQ.DATA<4,PW.PROCESS.POS>
        IF PW.PROCESS.ID THEN
            GOSUB PROCESS.OWNER
        END
    END

RETURN

*-----------------------------------------------------------------------------------
PROCESS.OWNER:
**************

    LOCATE 'OWNER' IN ENQ.DATA<2,1> SETTING PW.OWNER.POS THEN
        Y.FIX.DATA = ENQ.DATA<4,PW.OWNER.POS>
        Y.FINAL = CHANGE(Y.FIX.DATA,@VM," ")

        Y.FINAL := " CALL.CENTRE.AGENT"
        Y.FINAL.MATCH = CHANGE(Y.FINAL," ",@VM)

        Y.FINAL = CHANGE(Y.FINAL," ","' '")

        ENQ.DATA<2> = ''
        ENQ.DATA<3> = ''
        ENQ.DATA<4> = ''

        GOSUB PROCESS.FINAL
    END ELSE
* Using invalid field - not to select any records
        ENQ.DATA<2,-1> = 'TEST'
        ENQ.DATA<3,-1> = 'EQ'
        ENQ.DATA<4,-1> = ''
    END

RETURN

*-----------------------------------------------------------------------------------
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

*-----------------------------------------------------------------------------------
PROCESS.PW:
***********

    R.PW.PROCESS = ""
    R.PW.PROCESS = PW.Foundation.Process.Read(PW.LIST<I>, ERR.PW.PROCESS)
    Y.ACT.TXN.IDS = R.PW.PROCESS<PW.Foundation.Process.ProcActivityTxn>
    Y.PROC.COMP = R.PW.PROCESS<PW.Foundation.Process.ProcCompleted>
    Y.CNT = DCOUNT(Y.ACT.TXN.IDS,@VM)
    FOR J=1 TO Y.CNT
        GOSUB PROCESS.ACTIVITY
    NEXT J

RETURN

*-----------------------------------------------------------------------------------
PROCESS.ACTIVITY:
*****************

    IF Y.PROC.COMP<1,J> NE 'Y' THEN
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
    END

RETURN

*-----------------------------------------------------------------------------------
INITIALISE:
***********

    PW.PROCESS.ID = ''
    Y.PW.PENDING.ACT = ""
    PW.LIST = ""
    PW.LIST1 = ""
    Y.FINAL = ""

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------

END
