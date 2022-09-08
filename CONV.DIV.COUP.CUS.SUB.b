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

* Version 1 16/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>1207</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.DIV.COUP.CUS.SUB
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.DIV.COUP.CUS.G12.0.00
* This program converts the ID of all the existing
* DIV.COUP.CUS records to include the SUB.ACCOUNT in
* the key of the DIV.COUP.CUS record.
* Update concat files
*
* author : P.LABE
* 30/11/03 - CI_10015359
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
*********************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DIV.COUP.CUS
$INSERT I_F.STMT.ENTRY
$INSERT I_F.CATEG.ENTRY
$INSERT I_F.COMPANY

      EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================

      GOSUB OPEN.FILES
*
* Update DIV.COUP.CUS files (live, unauthorised, historic)
*
      FN.FILE = FN.DIV.COUP.CUS
      F.FILE = F.DIV.COUP.CUS
      GOSUB OBTAIN.LIST
      FN.FILE = FN.DIV.COUP.CUS$NAU
      F.FILE = F.DIV.COUP.CUS$NAU
      GOSUB OBTAIN.LIST
      FN.FILE = FN.DIV.COUP.CUS$HIS
      F.FILE = F.DIV.COUP.CUS$HIS
      GOSUB OBTAIN.LIST

* Update concat files
      ST.TODAY = FALSE                   ; *Process SEC.TRADES.TODAY file

      YFILE = 'F.POS.CON.REPORT'
      GOSUB UPDATE.CONCAT.FILE
      YFILE = 'F.DET.CON.REQUEST'
      GOSUB UPDATE.CONCAT.FILE
      YFILE = 'F.SEC.TRADES.TODAY' ; ST.TODAY = TRUE
      GOSUB UPDATE.CONCAT.FILE
*
      RETURN
*
************
OBTAIN.LIST:
************
* Select list
*
      LIST = ''
      CMD = 'SELECT ':FN.FILE            ; * CI_10015359 S/E
      CALL EB.READLIST(CMD,LIST,'','','')
      IF LIST THEN GOSUB UPDATE.FILE
*
      RETURN
*
************
UPDATE.FILE:
************
* Main loop (process DIV.COUP.CUS keys) : add a dot to the key, write the new key and and delete the old one
*
      LOOP
         REMOVE CODE FROM LIST SETTING MORE
*
      WHILE CODE DO
*
         R.FILE = ''
         REFERENCE = ''
         CODE.NEW = ''
         KEY.FIELD1 = ''
         KEY.FIELD2 = ''
         CODE.REF = ''
* CI_10015359 S
*         CALL F.READU(FN.FILE,CODE,R.FILE,F.FILE,ER,'R 05 12')
         ER = ''
         READ R.FILE FROM F.FILE, CODE ELSE ER = 1
* CI_10015359 E
         IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:CODE:VM:FN.FILE
            GOTO FATAL.ERROR
         END
         IF R.FILE<SC.DPC.STATEMENT.NOS><1,1> THEN REFERENCE = R.FILE<SC.DPC.STATEMENT.NOS><1,1>
         IF FN.FILE = FN.DIV.COUP.CUS OR FN.FILE = FN.DIV.COUP.CUS$NAU THEN
            CODE.NEW = CODE:'.'
            IF REFERENCE THEN CODE.REF = CODE.NEW
         END
         IF FN.FILE = FN.DIV.COUP.CUS$HIS THEN
            KEY.FIELD1 = FIELD(CODE,';',1)
            KEY.FIELD2 = FIELD(CODE,';',2)
            CODE.NEW = KEY.FIELD1:'.':';':KEY.FIELD2
            IF REFERENCE THEN CODE.REF = KEY.FIELD1:'.'
         END

* CI_10015359 S
*         CALL F.WRITE(FN.FILE,CODE.NEW,R.FILE)
*         CALL F.DELETE(FN.FILE,CODE)
         WRITE R.FILE TO F.FILE,CODE.NEW
         DELETE F.FILE,CODE
* CI_10015359 E

* Update TRANS.REFERENCE field in STMT.ENTRY and CATEG.ENTRY files

         IF NOT(REFERENCE) OR FN.FILE = FN.DIV.COUP.CUS$NAU ELSE       ; * CI_10015359 S/E
            NB = ''
            NB = FIELD(R.FILE<SC.DPC.STATEMENT.NOS><1,2>,'-',2)
            IF NOT(NB) THEN NB = 1
            YFILE = FN.STMT.ENTRY ; F.YFILE = F.STMT.ENTRY
            GOSUB UPDATE.ENTRY
            IF R.FILE<SC.DPC.STATEMENT.NOS><1,3> THEN
               NB = ''
               NB = FIELD(R.FILE<SC.DPC.STATEMENT.NOS><1,3>,'-',2)
               IF NOT(NB) THEN NB = 1
               YFILE = FN.CATEG.ENTRY ; F.YFILE = F.CATEG.ENTRY
               GOSUB UPDATE.ENTRY
            END
         END                             ; * CI_10015359 S/E
*
* CI_10015359 S
*UPDATE.JOURNAL:
*         CALL JOURNAL.UPDATE(CODE.NEW)
* CI_10015359 E
*
*
      REPEAT
*
      RETURN
*
*************
UPDATE.ENTRY:
*************
      FOR YI = 1 TO NB
         R.YFILE = ''
         YID = REFERENCE:FMT(YI,'4"0"R')
* CI_10015359 S
*         CALL F.READU(YFILE,YID,R.YFILE,F.YFILE,ER,'R 05 12')
         ER = ''
         READ R.YFILE FROM F.YFILE,YID ELSE ER= 1
*         IF ER THEN
*            E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:YFILE
*            GOTO FATAL.ERROR
*         END
         IF NOT(ER) THEN
* CI_10015359 E
*update reference number with the new key
            IF YFILE = FN.STMT.ENTRY AND R.YFILE<AC.STE.TRANS.REFERENCE> = CODE THEN
               R.YFILE<AC.STE.TRANS.REFERENCE> = CODE.REF
* CI_10015359 S
*            CALL F.WRITE(YFILE,YID,R.YFILE)
               WRITE R.YFILE TO F.YFILE,YID
* CI_10015359 E

            END
            IF YFILE = FN.CATEG.ENTRY AND R.YFILE<AC.CAT.TRANS.REFERENCE> = CODE THEN
               R.YFILE<AC.CAT.TRANS.REFERENCE> = CODE.REF
* CI_10015359 S
*            CALL F.WRITE(YFILE,YID,R.YFILE)
               WRITE R.YFILE TO F.YFILE,YID
* CI_10015359 E
            END
         END                             ; * CI_10015359 S/E
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
         YSELECT = 'SELECT ':YFILE:' WITH @ID LIKE ':ID.COMPANY:'*COUP...'       ; * CI_10015359 S/E
      END ELSE
         YSELECT = 'SELECT ':YFILE       ; * CI_10015359 S/E
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
*         CALL F.READU(YFILE,YID,YFIELD,F.YFILE,ER,'R 05 12')
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
         FOR I = 1 TO YNB                ; *process each line
            YFIELD.NEW<I> = YFIELD<I>:'.'
         NEXT I
*
* CI_10015359 S
*         CALL F.WRITE(YFILE,YID,YFIELD.NEW)
*         IF ST.TODAY THEN CALL F.DELETE(YFILE,YID.OLD)
*         CALL JOURNAL.UPDATE(YID)
         WRITE YFIELD.NEW TO F.YFILE,YID
         IF ST.TODAY THEN DELETE F.YFILE,YID.OLD
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
      FN.DIV.COUP.CUS = 'F.DIV.COUP.CUS'
      F.DIV.COUP.CUS = ''
      CALL OPF(FN.DIV.COUP.CUS,F.DIV.COUP.CUS)
*
      FN.STMT.ENTRY = 'F.STMT.ENTRY'
      F.STMT.ENTRY = ''
      CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)
*
      FN.CATEG.ENTRY = 'F.CATEG.ENTRY'
      F.CATEG.ENTRY = ''
      CALL OPF(FN.CATEG.ENTRY,F.CATEG.ENTRY)

*
      FN.DIV.COUP.CUS$NAU = 'F.DIV.COUP.CUS$NAU'
      F.DIV.COUP.CUS$NAU = ''
      CALL OPF(FN.DIV.COUP.CUS$NAU,F.DIV.COUP.CUS$NAU)
*
      FN.DIV.COUP.CUS$HIS = 'F.DIV.COUP.CUS$HIS'
      F.DIV.COUP.CUS$HIS = ''
      CALL OPF(FN.DIV.COUP.CUS$HIS,F.DIV.COUP.CUS$HIS)
*

      RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

      TEXT = E
      CALL FATAL.ERROR('CONV.DIV.COUP.CUS.SUB')


   END
