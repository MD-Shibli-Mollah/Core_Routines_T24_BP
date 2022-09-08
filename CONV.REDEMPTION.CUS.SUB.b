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

* Version 1 16/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1087</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccClassicCA
    SUBROUTINE CONV.REDEMPTION.CUS.SUB
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.REDEMPTION.CUS.G12.0.0
* This program converts the ID of all the existing
* REDEMPTION.CUS records to include the SUB.ACCOUNT in
* the key of the REDEMPTION.CUS record.
* Update concat files
*
* author : P.LABE
* 30/11/03 - ci_10015359
*            The fix solves the following issues:
*            1. Fatal error is stopped if the system fails to read a STMT
*               or CATEG.ENTRY.
*            2. SSELECT is replaced by SELECT statements.
*            3. READUs are replaced by READ statements, to avoid locking
*               problem.
*            4. F.READ,F.WRITE and F.DELETE are replaced with READ,
*               WRITE and DELETE statements to overcome the memory
*               constraints.
*
*
* 03/08/04 - CI_10021802
*            Problem in SELECT statement.
*
* 08/06/05 - CI_10041711
*            Problem in conversion of SC.ENT.TODAY
*
* 22/01/08 - CI_10053402
*            RUN.CONVERSION.PGMS ERROR
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDEMPTION.CUS
    $INSERT I_F.COMPANY
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.SECURITY.TRANS
    $INSERT I_F.CONSOL.ENT.TODAY
    $INSERT I_F.SC.ENT.TODAY

    EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================

    GOSUB OPEN.FILES
*
* Update REDEMPTION.CUS files (live, unauthorised, historic)
*
    FN.FILE = FN.REDEMPTION.CUS
    F.FILE = F.REDEMPTION.CUS
    GOSUB OBTAIN.LIST
    FN.FILE = FN.REDEMPTION.CUS$NAU
    F.FILE = F.REDEMPTION.CUS$NAU
    GOSUB OBTAIN.LIST
    FN.FILE = FN.REDEMPTION.CUS$HIS
    F.FILE = F.REDEMPTION.CUS$HIS
    GOSUB OBTAIN.LIST

* Selection on STMT.ENTRY and CATEG.ENTRY because there is no statement references
* for the customer in REDEMPTION.CUS records

    PREFIX = 'BDRDSC'
    YLIST = ''
    YID = ''
    YFILE = FN.STMT.ENTRY ; F.YFILE = F.STMT.ENTRY
    GOSUB UPDATE.ENTRY
    YLIST = ''
    YID = ''
    YFILE = FN.CATEG.ENTRY ; F.YFILE = F.CATEG.ENTRY
    GOSUB UPDATE.ENTRY
    YLIST = ''
    YID = ''
    YFILE = FN.CONSOL.ENT.TODAY ; F.YFILE = F.CONSOL.ENT.TODAY
    GOSUB UPDATE.ENTRY
    YLIST = ''
    YID = ''
    YFILE = FN.SC.ENT.TODAY ; F.YFILE = F.SC.ENT.TODAY
    GOSUB UPDATE.ENTRY

* Update concat files
    ST.TODAY = FALSE          ;*Process SEC.TRADES.TODAY file

    YFILE = 'F.RRQ.CON.REPORT'
    GOSUB UPDATE.CONCAT.FILE
    YFILE = 'F.BAL.CON.REQUEST'
    GOSUB UPDATE.CONCAT.FILE
    YFILE = 'F.SEC.TRADES.TODAY' ; ST.TODAY = TRUE
    GOSUB UPDATE.CONCAT.FILE
*
    RETURN
*
************
OBTAIN.LIST:
************
* Select list in REDEMPTION.CUS files (live, unauthorised, historic)
*
    LIST = ''
    CMD = 'SSELECT ':FN.FILE
    CALL EB.READLIST(CMD,LIST,'','','')
    IF LIST THEN GOSUB UPDATE.FILE
*
    RETURN
*
************
UPDATE.FILE:
************
* Main loop (process REDEMPTION.CUS keys) : add a dot to the key, write the new key and and delete the old one
* Update the reference from the new id

    LOOP
        REMOVE CODE FROM LIST SETTING MORE
*
    WHILE CODE DO
*
        REFERENCE = ''
        TRANSACTION.ID = ''
        KEY.FIELD1 = ''
        KEY.FIELD2 = ''
        R.FILE = ''
        CODE.SAVE = ''
* CI_10015359 S 
        ER = ''
        READ R.FILE FROM F.FILE,CODE ELSE ER = 1
* CI_10015359 E
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:CODE:VM:FN.FILE
            GOTO FATAL.ERROR
        END

        IF FN.FILE = FN.REDEMPTION.CUS OR FN.FILE = FN.REDEMPTION.CUS$NAU THEN
            CODE.NEW = CODE:'.'
            TRANSACTION.ID = CODE.NEW
            CODE.SAVE = CODE
        END
        IF FN.FILE = FN.REDEMPTION.CUS$HIS THEN
            KEY.FIELD1 = FIELD(CODE,';',1)
            KEY.FIELD2 = FIELD(CODE,';',2)
            CODE.NEW = KEY.FIELD1:'.':';':KEY.FIELD2
            CODE.SAVE = KEY.FIELD1
            TRANSACTION.ID = KEY.FIELD1:'.'
        END

        IF R.FILE<SC.BAL.REFERENCE.NO> THEN REFERENCE = R.FILE<SC.BAL.REFERENCE.NO>
* CI_10015359 S 
        WRITE R.FILE TO F.FILE,CODE.NEW
        DELETE F.FILE,CODE
* CI_10015359 E

* Update TRANS.REFERENCE field in STMT.ENTRY and CATEG.ENTRY files
* Update REF.NO.SEQUENCE field in SECURITY.TRANS file

        YID = ''
        IF REFERENCE THEN
            YID = REFERENCE ; YLIST = ''
            YFILE = FN.SECURITY.TRANS ; F.YFILE = F.SECURITY.TRANS
            GOSUB UPDATE.SEC.TRANS
        END
* 
*
    REPEAT
*
    RETURN
*
*****************
UPDATE.SEC.TRANS:
*****************
* Update reference field in SECURITY.TRANS file
    YCMD = 'SELECT ':YFILE:' WITH @ID LIKE ':YID:'...'      ;* CI_10015359 S/E
    CALL EB.READLIST(YCMD,YLIST,'','','')
    IF NOT(YLIST) THEN RETURN
    LOOP
        REMOVE YCODE FROM YLIST SETTING MORE
    WHILE YCODE DO
* CI_10015359 S 
        ER = ''
        READ R.YFILE FROM F.YFILE,YCODE ELSE ER = 1
* CI_10015359 E
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YCODE:VM:YFILE
            GOTO FATAL.ERROR
        END
        R.YFILE<SC.SCT.REF.NO.SEQUENCE> = TRANSACTION.ID
* CI_10015359 S 
        WRITE R.YFILE TO F.YFILE,YCODE
* CI_10015359 E
    REPEAT
*
    RETURN
*
*************
UPDATE.ENTRY:
*************

* CI_10021802 starts



    SELECT F.YFILE

    LOOP
        READNEXT YID ELSE YID = ''

    WHILE YID DO
        R.YFILE = ''

* CI_10015359 S 
        ER = ''
        READ R.YFILE FROM F.YFILE,YID ELSE ER = 1 
        IF NOT(ER) AND R.YFILE<17>[1,6] = PREFIX THEN
* CI_10015359 E
* CI_10021802 E

*update reference number with the new key

            IF YFILE = FN.STMT.ENTRY THEN
                R.YFILE<AC.STE.TRANS.REFERENCE> := '.'
* CI_10015359 S 
                WRITE R.YFILE TO F.YFILE,YID
* CI_10015359 E
            END
            IF YFILE = FN.CATEG.ENTRY THEN
                R.YFILE<AC.CAT.TRANS.REFERENCE> := '.'
* CI_10015359 S 
                WRITE R.YFILE TO F.YFILE,YID
* CI_10015359 E
            END
        END         ;* CI_10015359 S/E
        IF YFILE = FN.CONSOL.ENT.TODAY THEN
            IF COUNT(R.YFILE<RE.CET.TXN.REF>,'.') EQ 5 AND R.YFILE<RE.CET.PRODUCT> EQ 'SC' THEN
                R.YFILE<RE.CET.TXN.REF> := '.'
                WRITE R.YFILE TO F.YFILE,YID
            END
        END
        IF YFILE = FN.SC.ENT.TODAY THEN
            SET.LIST = R.YFILE<SC.ENTTD.TRANS.REF> ; SET.POSN = 1
            LOOP
                REMOVE SET.VALUE FROM SET.LIST SETTING SETPOS
            WHILE SET.VALUE:SETPOS
                IF COUNT(R.YFILE<SC.ENTTD.ID.RECORD,SET.POSN>,'.') EQ 5 THEN
                    R.YFILE<SC.ENTTD.ID.RECORD,SET.POSN> := '.'
                END
                SET.POSN += 1
            REPEAT
            WRITE R.YFILE TO F.YFILE,YID
        END 

    REPEAT
*
    RETURN
*
*******************
UPDATE.CONCAT.FILE:
*******************
*
* Select list from concat file
*
    F.YFILE = ''
    CALL OPF(YFILE,F.YFILE)
    YLIST = ''
    YID = ''
    YFIELD = ''
    IF ST.TODAY THEN
        YSELECT = 'SELECT ':YFILE:' WITH @ID LIKE ':ID.COMPANY:'*BDRD...'       ;* CI_10015359 S/E
    END ELSE
        YSELECT = 'SELECT ':YFILE       ;* CI_10015359 S/E
    END
    CALL EB.READLIST(YSELECT,YLIST,'','','')
    IF NOT(YLIST) THEN
        RETURN
    END
*
    LOOP
        REMOVE YID FROM YLIST SETTING MORE
*
    WHILE YID DO
*
* CI_10015359 S

        ER = ''
        READ YFIELD FROM F.YFILE,YID ELSE ER = 1
* CI_10015359 E
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:YFILE
            GOTO FATAL.ERROR
        END
*
        YID.OLD = ''
        YFIELD.NEW = ''
*
        IF ST.TODAY THEN
            YID.OLD = YID
            YID := '.'
        END
*
        YNB = DCOUNT(YFIELD,FM)
*
        FOR I = 1 TO YNB      ;*process each line
            YFIELD.NEW<I> = YFIELD<I>:'.'
        NEXT I
*
* CI_10015359 S 
*
        WRITE YFIELD.NEW TO F.YFILE,YID
        IF ST.TODAY THEN DELETE F.YFILE,YID.OLD
*
* CI_10015359 E

*
    REPEAT
*
    RETURN
*
*****************************************************************
OPEN.FILES:
*****************************************************************

*
    FN.REDEMPTION.CUS = 'F.REDEMPTION.CUS'
    F.REDEMPTION.CUS = ''
    CALL OPF(FN.REDEMPTION.CUS,F.REDEMPTION.CUS)
*
    FN.REDEMPTION.CUS$NAU = 'F.REDEMPTION.CUS$NAU'
    F.REDEMPTION.CUS$NAU = ''
    CALL OPF(FN.REDEMPTION.CUS$NAU,F.REDEMPTION.CUS$NAU)
*
    FN.REDEMPTION.CUS$HIS = 'F.REDEMPTION.CUS$HIS'
    F.REDEMPTION.CUS$HIS = ''
    CALL OPF(FN.REDEMPTION.CUS$HIS,F.REDEMPTION.CUS$HIS)
*
    FN.STMT.ENTRY = 'F.STMT.ENTRY'
    F.STMT.ENTRY = ''
    CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)
*
    FN.CATEG.ENTRY = 'F.CATEG.ENTRY'
    F.CATEG.ENTRY = ''
    CALL OPF(FN.CATEG.ENTRY,F.CATEG.ENTRY)
*
    FN.SECURITY.TRANS = 'F.SECURITY.TRANS'
    F.SECURITY.TRANS = ''
    CALL OPF(FN.SECURITY.TRANS,F.SECURITY.TRANS)

    FN.CONSOL.ENT.TODAY = 'F.CONSOL.ENT.TODAY'
    F.CONSOL.ENT.TODAY = ''
    CALL OPF(FN.CONSOL.ENT.TODAY,F.CONSOL.ENT.TODAY)

    FN.SC.ENT.TODAY = 'F.SC.ENT.TODAY'
    F.SC.ENT.TODAY = ''
    CALL OPF(FN.SC.ENT.TODAY,F.SC.ENT.TODAY)
*

    RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('CONV.REDEMPTION.CUS.SUB')


END
