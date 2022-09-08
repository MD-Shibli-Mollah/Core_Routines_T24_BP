* @ValidationCode : MjotOTM1MjcxNDUzOkNwMTI1MjoxNTY0NTY3NDA0MDQ4OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 15:33:24
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

* Version 1 26/04/06  GLOBUS Release No. R06DEV
*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*
$PACKAGE AC.AccountStatement
SUBROUTINE CONV.ACCT.STMT.ENTRY.R06
*------------------------------------------------------------------------------------
* This routine will build the work file AC.CONV.ENTRY with the id's of
* ACCT.STMT.ENTRY in the format "STMTCONV"."ACCT.STMT.ENTRY ID" .This will be
* picked up by the batch process EOD.AC.CONV.ENTRY for the Multi threaded Conversion.
* Same for ACCT.STMT2.ENTRY in the format "STMTCONV2"."ACCT.STMT2.ENTRY ID".
*------------------------------------------------------------------------------------
* Modification History:
*
* 06/06/06 - BG_100011082 /REF: TTS0551306
*            New routine for the conversion
*
* 08/08/06 - CI_10043184 /REF: HD0611256
*            Instead of selecting and writing all records into AC.CONV.ENTRY, we are writing a DUMMY record
*            with id as "STMTCONV" to trigger the conversion in EOD.AC.CONV.ENTRY. Hence only one SELECT
*            (at EOD.AC.CONV.ENTRY.SELECT) is done thus by improving the performance.
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

***   Main processing   ***
*     ---------------     *

    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        GOSUB WRITE.AC.CONV.ENTRY       ;* Write a record in AC.CONV.ENTRY with Trigger record

    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

RETURN

*------------------*
WRITE.AC.CONV.ENTRY:
*------------------*

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

    AC.CONV.ENTRY.ID = "STMTCONV"

    READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID ELSE
        R.AC.CONV.ENTRY = "DUMMY"
        WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
    END

    AC.CONV.ENTRY.ID = "STMT2CONV"

    READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID ELSE
        R.AC.CONV.ENTRY = "DUMMY"
        WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
    END

RETURN

END
