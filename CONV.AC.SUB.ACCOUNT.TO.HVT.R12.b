* @ValidationCode : MjoxMzA2ODEyMjg5OkNwMTI1MjoxNTcwMDkzNjQ4MjYwOmRzd2F0aGk6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4yMDE5MDcyMy0wMjUxOi0xOi0x
* @ValidationInfo : Timestamp         : 03 Oct 2019 14:37:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dswathi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
*
$PACKAGE AC.AccountClosure
SUBROUTINE CONV.AC.SUB.ACCOUNT.TO.HVT.R12
*----------------------------------------------------------------------------------
*
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* wherever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
*-------------------------------------------------------------------------------
*                      M O D I F I C A T I O N
*-------------------------------------------------------------------------------
* 08/12/11-
*           New routine to update HVT in AC.CONV.ENTRY
*
*-------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

*-------------------------------------------------------------------------------

*-- Main processing

    SAVE.ID.COMPANY = ID.COMPANY

*-- Loop through each company

    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

*-- Check whether product is installed


        GOSUB INITIALISE

        GOSUB WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION

    REPEAT

*-- Restore back ID.COMPANY if it has changed.

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

*-----------------------------------------*
WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION:
*----------------------------------------*

    AC.CONV.ENTRY.ID = "AC.SUB.ACCOUNT.TO.HVT"
    READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID ELSE
        WRITE 'HVT' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
    END

RETURN
*----------------------------------------------------------------------------


