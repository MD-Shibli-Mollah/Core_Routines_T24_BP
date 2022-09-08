* @ValidationCode : MjoxNTk1Mjk3Mjc4OkNwMTI1MjoxNTY0NTYzMjIyNzc1OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 14:23:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.StmtPrinting
SUBROUTINE CONV.STATEMENT.CONTROL.201410
*-----------------------------------------------------------------------------
* Description:
*-------------
* This pre routine will update the STMT.INTEG.CHK field in STATEMENT.CONTROL
* record if ADDITIONAL.INFO of AC.STATEMENT.SERVICE contains '.STMTCHK' value.
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 24/10/14 - Task
*            New file conversion routine.
*
* 30/07/19 - Enhancement 3246717 / Task 3181742
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PGM.FILE
    $INSERT I_F.STATEMENT.CONTROL
*
*------------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*----------
*
    FN.PGM.FILE = 'F.PGM.FILE'
    R.F.PGM.FILE = ''
*
    FN.STATEMENT.CONTROL = 'F.STATEMENT.CONTROL'
    F.STATEMENT.CONTROL = ''
    R.STATEMENT.CONTROL = ''
*
    EQU SCONT.STMT.INTEG.CHK TO 4
*
RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
*-------
*
    Y.ERROR = ''
    CALL CACHE.READ(FN.PGM.FILE, 'AC.STATEMENT.SERVICE', R.PGM.FILE, Y.ERROR)
    UPD.STMT.CTRL= ''
    IF INDEX(R.PGM.FILE<EB.PGM.ADDITIONAL.INFO>, '.STMTCHK', 1) THEN
        UPD.STMT.CTRL = 1
    END
*
    IF NOT(UPD.STMT.CTRL) THEN
        RETURN
    END
*
    Y.ERROR = ''
    CALL F.READU(FN.STATEMENT.CONTROL, 'SYSTEM', R.STATEMENT.CONTROL, F.STATEMENT.CONTROL, Y.ERROR, 'E')
    R.STATEMENT.CONTROL<SCONT.STMT.INTEG.CHK> = 'YES'
    CALL F.WRITE(FN.STATEMENT.CONTROL,'SYSTEM', R.STATEMENT.CONTROL)
*
RETURN
*
*-----------------------------------------------------------------------------
*
END
