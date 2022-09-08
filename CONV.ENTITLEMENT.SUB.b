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

* Version 3 14/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1521</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEntitlements
    SUBROUTINE CONV.ENTITLEMENT.SUB
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.ENTITLEMENT.G12.0.00
* This program converts the ID of all the existing
* ENTITLEMENT records to include the SUB.ACCOUNT in
* the key of the ENTITLEMENT record.
* Update concat files
*
* author : P.LABE
*
* 23/05/01 - GB0101422
*            Do not fatal when STMT.ENTRY or CATEG.ENTRY
*            It can happen if archiving has been run.
*
* 17/09/02 - CI_10003686
*            The ENTITLEMENT ID is appended with a dot. But its
*            corresponding reference in STMT.ENTRY and CATEG.ENTRY
*            is not changed (not appended with a dot).
*            Field names are replaced by its corresponding Field nos.
*
* 21/10/02 - BG_100002459 (G13.1.00)
*            Release the STMT.ENTRY record not found
*
* 07/12/04 - CI_10025330
*            The Entitlement ids in concat file CONCAT.DIARY are not
*            appended with a dot.
*
* 22/03/05 - CI_10028622
*            Multicompany compatible
*
* 24/09/08 - GLOBUS_BG_100020020
*            System fatals out while doing OPF of SC.ENT.MANUAL, SC.ENT.ACTIVATED
*            and SC.ENT.VERIFIED file as it is made as Obsolete.
*
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ENTITLEMENT
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.SECURITY.TRANS

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
        GOSUB OPEN.FILES
*
* Update ENTITLEMENT files (live, unauthorised, historic)
*
        FN.FILE = FN.ENTITLEMENT
        F.FILE = F.ENTITLEMENT
        GOSUB OBTAIN.LIST
        FN.FILE = FN.ENTITLEMENT$NAU
        F.FILE = F.ENTITLEMENT$NAU
        GOSUB OBTAIN.LIST
        FN.FILE = FN.ENTITLEMENT$HIS
        F.FILE = F.ENTITLEMENT$HIS
        GOSUB OBTAIN.LIST

* Update REF.NO.SEQUENCE field in SECURITY.TRANS file

        YID = ''
        YLIST = ''
        YFILE = FN.SECURITY.TRANS ; F.YFILE = F.SECURITY.TRANS
        GOSUB UPDATE.SEC.TRANS

* Update concat files
        ST.TODAY = FALSE      ;*Process SEC.TRADES.TODAY file

        YFILE = 'F.SC.CON.ENTITLEMENT'
        GOSUB UPDATE.CONCAT.FILE
* CI_10025330 S
        YFILE = 'F.CONCAT.DIARY'
        GOSUB UPDATE.CONCAT.FILE
* CI_10025330 E
        YFILE = 'F.SEC.TRADES.TODAY' ; ST.TODAY = TRUE
        GOSUB UPDATE.CONCAT.FILE
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
*
************
OBTAIN.LIST:
************
* Select list in ENTITLEMENT files (live, unauthorised, historic)
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
* Main loop (process ENTITLEMENT keys) : add a dot to the key, write the new key and and delete the old one
* Update the reference from the new id

    LOOP
        REMOVE CODE FROM LIST SETTING MORE
*
    WHILE CODE DO
*
        STMT.NO = ''
        TRANSACTION.ID = ''
        KEY.FIELD1 = ''
        KEY.FIELD2 = ''
        R.FILE = ''
        CODE.SAVE = ''
        CALL F.READU(FN.FILE,CODE,R.FILE,F.FILE,ER,'R 05 12')
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:CODE:VM:FN.FILE
            GOTO FATAL.ERROR
        END

        IF R.FILE<91><1,1> THEN STMT.NO = R.FILE<91><1,1>   ;* CI_10003686S/E

        IF FN.FILE = FN.ENTITLEMENT OR FN.FILE = FN.ENTITLEMENT$NAU THEN
            CODE.NEW = CODE:'.'
            TRANSACTION.ID = CODE.NEW
            CODE.SAVE = CODE
        END
        IF FN.FILE = FN.ENTITLEMENT$HIS THEN
            KEY.FIELD1 = FIELD(CODE,';',1)
            KEY.FIELD2 = FIELD(CODE,';',2)
            CODE.NEW = KEY.FIELD1:'.':';':KEY.FIELD2
            CODE.SAVE = KEY.FIELD1
            TRANSACTION.ID = KEY.FIELD1:'.'
        END

        IF R.FILE<44> THEN    ;* CI_10003686 S/E
            R.FILE<44> = TRANSACTION.ID ;* CI_10003686 S/E
        END

        CALL F.WRITE(FN.FILE,CODE.NEW,R.FILE)
        CALL F.DELETE(FN.FILE,CODE)

* Update TRANS.REFERENCE field in STMT.ENTRY and CATEG.ENTRY files

        IF STMT.NO THEN
            NB = ''
            NB = FIELD(R.FILE<91><1,2>,'-',2)     ;* CI_10003686 S/E
            IF NOT(NB) THEN NB = 1
            YFILE = FN.STMT.ENTRY ; F.YFILE = F.STMT.ENTRY
            GOSUB UPDATE.ENTRY
            IF R.FILE<91><1,3> THEN     ;* CI_10003686 S/E
                NB = ''
                NB = FIELD(R.FILE<91><1,3>,'-',2) ;* CI_10003686 S/E

                IF NOT(NB) THEN NB = 1
                YFILE = FN.CATEG.ENTRY ; F.YFILE = F.CATEG.ENTRY
                GOSUB UPDATE.ENTRY
            END
        END
*
        CALL JOURNAL.UPDATE(CODE.NEW)
*
    REPEAT
*
    RETURN
*
*****************
UPDATE.SEC.TRANS:
*****************
* Update reference field in SECURITY.TRANS file
    FIRST.YCODE = TRUE
    YLAST = ''
    YNEW = ''
    YCMD = 'SSELECT ':YFILE:' WITH @ID LIKE DIARSC...'
    CALL EB.READLIST(YCMD,YLIST,'','','')
    IF NOT(YLIST) THEN RETURN
    LOOP
        REMOVE YCODE FROM YLIST SETTING MORE
    WHILE YCODE DO
        IF FIRST.YCODE THEN
            YLAST = YCODE[1,16]
            FIRST.YCODE = FALSE
        END
        CALL F.READU(YFILE,YCODE,R.YFILE,F.YFILE,ER,'R 05 12')
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YCODE:VM:YFILE
            GOTO FATAL.ERROR
        END
        R.YFILE<SC.SCT.REF.NO.SEQUENCE> := '.'
        CALL F.WRITE(YFILE,YCODE,R.YFILE)
        YNEW = YCODE[1,16]
        IF YLAST NE YNEW THEN ;*Update journal each time there is a new ENTITLEMENT record
            YLAST = YNEW
            CALL JOURNAL.UPDATE(YCODE)
        END
    REPEAT
*
    RETURN
*
*************
UPDATE.ENTRY:
*************
    FOR YI = 1 TO NB
        R.YFILE = ''
        YID = STMT.NO:FMT(YI,'4"0"R')
        CALL F.READU(YFILE,YID,R.YFILE,F.YFILE,ER,'R 05 12')
* GB0101422 - S
*         IF ER THEN
*            E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:YFILE
*            GOTO FATAL.ERROR
*         END
        IF NOT(ER) THEN
* GB0101422 - E
*update reference number with the new key
            UPD.REC = FALSE
            IF YFILE = FN.STMT.ENTRY THEN
                IF R.YFILE<AC.STE.TRANS.REFERENCE> = CODE.SAVE THEN
                    R.YFILE<AC.STE.TRANS.REFERENCE> = TRANSACTION.ID
                    UPD.REC = TRUE
                END
                IF R.YFILE<AC.STE.OUR.REFERENCE> = CODE.SAVE THEN
                    R.YFILE<AC.STE.OUR.REFERENCE> = TRANSACTION.ID
                    UPD.REC = TRUE
                END
                IF UPD.REC THEN CALL F.WRITE(YFILE,YID,R.YFILE)
            END
            UPD.REC = FALSE
            IF YFILE = FN.CATEG.ENTRY THEN
                IF R.YFILE<AC.CAT.TRANS.REFERENCE> = CODE.SAVE THEN
                    R.YFILE<AC.CAT.TRANS.REFERENCE> = TRANSACTION.ID
                    UPD.REC = TRUE
                END
                IF R.YFILE<AC.CAT.OUR.REFERENCE> = CODE.SAVE THEN
                    R.YFILE<AC.CAT.OUR.REFERENCE> = TRANSACTION.ID
                    UPD.REC = TRUE
                END
                IF UPD.REC THEN CALL F.WRITE(YFILE,YID,R.YFILE)
            END
*BG100002459-S
        END ELSE
            CALL F.RELEASE(YFILE,YID,F.YFILE)
*BG100002459-S
        END         ;*              GB0101422

    NEXT YI
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
        YSELECT = 'SSELECT ':YFILE:' WITH @ID LIKE ':ID.COMPANY:'*DIARSC...'
    END ELSE
        YSELECT = 'SSELECT ':YFILE
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
        CALL F.READU(YFILE,YID,YFIELD,F.YFILE,ER,'R 05 12')
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:YFILE
            GOTO FATAL.ERROR
        END
*
        YFIELD.NEW = ''
        YID.OLD = ''
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
        CALL F.WRITE(YFILE,YID,YFIELD.NEW)
        IF ST.TODAY THEN CALL F.DELETE(YFILE,YID.OLD)
*
        CALL JOURNAL.UPDATE(YID)
*
    REPEAT
*
    RETURN
*
*****************************************************************
OPEN.FILES:
*****************************************************************

*
    FN.ENTITLEMENT = 'F.ENTITLEMENT'
    F.ENTITLEMENT = ''
    CALL OPF(FN.ENTITLEMENT,F.ENTITLEMENT)
*
    FN.ENTITLEMENT$NAU = 'F.ENTITLEMENT$NAU'
    F.ENTITLEMENT$NAU = ''
    CALL OPF(FN.ENTITLEMENT$NAU,F.ENTITLEMENT$NAU)
*
    FN.ENTITLEMENT$HIS = 'F.ENTITLEMENT$HIS'
    F.ENTITLEMENT$HIS = ''
    CALL OPF(FN.ENTITLEMENT$HIS,F.ENTITLEMENT$HIS)
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
*
    RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('CONV.ENTITLEMENT.SUB')


END
