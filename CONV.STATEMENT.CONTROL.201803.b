* @ValidationCode : MjoyMDU2NzkwMzI1OkNwMTI1MjoxNTY0NTYzMjIyNzg0OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
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

$PACKAGE AC.StmtPrinting
SUBROUTINE CONV.STATEMENT.CONTROL.201803(REC.ID,R.STATEMENT.CONTROL,F.STATEMENT.CONTROL)
*-----------------------------------------------------------------------------
* Description:
*-------------
* This record routine will update the new field in STATEMENT.CONTROL called PREFORMAT.TAGS
* with the value in local field PREFORMAT.61.86
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 05/01/18 - Enhancement - 2401376 / Task - 2401379
*            SWIFT Performance enhancement
*            New file conversion routine.
*
* 30/07/19 - Enhancement 3246717 / Task 3181742
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
*
    $USING EB.LocalReferences
*
    LOC.FLD.POS = ''
    EB.LocalReferences.GetLocRef('STATEMENT.CONTROL','PREFORMAT.61.86',LOC.FLD.POS)
*
    IF R.STATEMENT.CONTROL<AC.StmtPrinting.StatementControl.ScontLocalRef,LOC.FLD.POS> = 'Y' THEN
        R.STATEMENT.CONTROL<AC.StmtPrinting.StatementControl.ScontLocalRef,LOC.FLD.POS> = ''
        R.STATEMENT.CONTROL<AC.StmtPrinting.StatementControl.ScontPreformatTags> = 'Y'
    END
*
RETURN
*-----------------------------------------------------------------------------
END
