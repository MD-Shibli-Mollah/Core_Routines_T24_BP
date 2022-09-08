* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PD.Contract
    SUBROUTINE CONV.PD.ECB.R07
*-----------------------------------------------------------------------------
*
* This routine will write AC.CONV.ENTRY file to trigger to update EB.CONTRACT.BALANCES
* from the LD and PD balance files.
*
* Modification log:
* -----------------
* 14/09/06 - EN_10003056
*            New conversion routine to update AC.CONV.ENTRY file to trigger
*            PD conversion for EB.CONTRACT.BALANCES update.
*
*______________________________________________________________________________________
*
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
*
* Check whether product is installed
*

        GOSUB INITIALISE

        GOSUB WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION

    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*---------*
INITIALISE:
*---------*

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

    RETURN
*
***********************************************************************************************************
WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION:
*****************************************

    AC.CONV.ENTRY.ID = "ECB.CONTRACT"
    READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID THEN
        LOCATE 'PD'  IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
            INS 'PD' BEFORE R.AC.CONV.ENTRY<POSN>
        END
        WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
    END ELSE
        WRITE 'PD' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
    END
*
    RETURN
*
