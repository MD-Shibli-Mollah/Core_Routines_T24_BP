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

* Version 2 29/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-58</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE CONV.SUB.ACCOUNT
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.SECURITY.POSITION.
* This program converts the ID of all the existing
* SECURITY.POSITION records to include the SUB.ACCOUNT in
* the key of the SECURITY.POSITION record.
* This conversion subroutine also converts all the
* SECURITY.POSITION concat files
*
* author : L.COLI
*
*
* GB0101932
*       Process the concat files in others routines
*       because the SECURITY.POSITION is in level client
*       and not the concat file
*
* 22/03/05 - CI_10028622
*            Multicompany compatible
*
* 12/05/05 - CI_10030114
*            Multi conv stops if there is no record in one company
*
* 29/01/08 - CI_10053469
*            Error in conversion of SECURITY.POSITION Records
*
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.POSITION
    $INSERT I_F.COMPANY



    EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================
    SAVE.ID.COMPANY = ID.COMPANY
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')
    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        GOSUB OPEN.FILES
        IF R.COMPANY(EB.COM.MNEMONIC) EQ R.COMPANY(EB.COM.CUSTOMER.MNEMONIC) THEN
            GOSUB PROCESS.SECURITY.POSITION
        END
    REPEAT

* Processing now complete for all companies.
* Change back to the original company if we have changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN


*****************************************************************
OPEN.FILES:
*****************************************************************

    FN.SECURITY.POSITION = 'F.SECURITY.POSITION'
    F.SECURITY.POSITION = ''
    CALL OPF(FN.SECURITY.POSITION,F.SECURITY.POSITION)

    RETURN

******************************************************************
PROCESS.SECURITY.POSITION:
******************************************************************
    SP.LIST = ''
    SELECT.SP = 'SSELECT ':FN.SECURITY.POSITION
    CALL EB.READLIST(SELECT.SP,SP.LIST,'','','')
    LOOP
        REMOVE SP.CODE FROM SP.LIST SETTING MORE
    WHILE SP.CODE DO
        CALL F.READU(FN.SECURITY.POSITION,SP.CODE,R.SECURITY.POSITION,F.SECURITY.POSITION,ER,'R 05 12')
        IF ER THEN
            GOSUB FATAL.ERROR
        END

        SP.CODE.NEW = SP.CODE:'.'       ;*add '.' (dot) to the key

        CALL F.WRITE(FN.SECURITY.POSITION,SP.CODE.NEW,R.SECURITY.POSITION)      ;*write the new key
        CALL F.DELETE(FN.SECURITY.POSITION,SP.CODE)         ;*delete the old one
        CALL JOURNAL.UPDATE(SP.CODE.NEW)
    REPEAT
    RETURN

******************************************************************
FATAL.ERROR:
******************************************************************
    TEXT  = 'RECORD & NOT FOUND ON FILE & ':FM:SP.CODE:VM:'F.SECURITY.POSITION'
    CALL FATAL.ERROR('CONV.SUB.ACCOUNT')

END
