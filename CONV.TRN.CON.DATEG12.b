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

* Version 1 29/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>34</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE CONV.TRN.CON.DATEG12
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* author : L.COLI
*
* 22/03/05 - CI_10028622
*            Multicompany compatible
*
* 09/05/08 - CI_10055270
*            Extra dots were appended to SECURITY.POSITION and its related concat files.
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

    EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================
* CI_10028622 S
    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
* GB9701190 - Not for Conslidation and Reporting companies
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')
    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK
*
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
* CI_10028622 E
        IF R.COMPANY(EB.COM.MNEMONIC) EQ R.COMPANY(EB.COM.FINAN.FINAN.MNE) THEN
            GOSUB OPEN.FILES
            GOSUB PROCESS.TRN.CON.DATE
        END
* CI_10028622 S
* Processing for this company now complete.
*
    REPEAT
*
* Processing now complete for all companies.
* Change back to the original company if we have changed.
*
    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END
* CI_10028622 E
*
    RETURN

*****************************************************************
OPEN.FILES:
*****************************************************************

*
    FN.TRN.CON.DATE = 'F.TRN.CON.DATE'
    F.TRN.CON.DATE = ''
    CALL OPF(FN.TRN.CON.DATE,F.TRN.CON.DATE)
*
    RETURN

******************************************************************
PROCESS.TRN.CON.DATE:
*
* Select list
*
    SP.LIST = ''
    SELECT.SP = 'SSELECT ':FN.TRN.CON.DATE
    CALL EB.READLIST(SELECT.SP,SP.LIST,'','','')

*
* Main loop (process TRN.CON.DATE)
*
    LOOP
        REMOVE SP.CODE FROM SP.LIST SETTING MORE
*
    WHILE SP.CODE DO
*
        CALL F.READ(FN.TRN.CON.DATE,SP.CODE,R.FILE,F.TRN.CON.DATE,ER)
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:SP.CODE:VM:"F.TRN.CON.DATE"
            GOTO FATAL.ERROR
        END
*
*
        NB.ENR = DCOUNT(R.FILE,FM)
        FOR I = 1 TO NB.ENR
            R.FILE.NEW = CHANGE(R.FILE<I>,'.','..',1,6)
            R.FILE<I> = R.FILE.NEW
        NEXT I


        SP.CODE.NEW = SP.CODE:'.'
        CALL F.WRITE(FN.TRN.CON.DATE,SP.CODE.NEW,R.FILE)    ;*save new record
*
        CALL F.DELETE(FN.TRN.CON.DATE,SP.CODE)    ;*delete old record
*
        CALL JOURNAL.UPDATE(SP.CODE.NEW)

    REPEAT
    RETURN
******************************************************************

FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('CONV.TRN.CON.DATE')


END
