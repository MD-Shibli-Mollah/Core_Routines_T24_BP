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

* Version 1 16/05/01  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>1247</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.STOCK.DIV.CUS.SUB
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.STOCK.DIV.CUS.G12.0.00
* This program converts the ID of all the existing
* STOCK.DIV.CUS records to include the SUB.ACCOUNT in
* the key of the STOCK.DIV.CUS record.
* Update concat files
*
* author : P.LABE
*
*********************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.STOCK.DIV.CUS
$INSERT I_F.COMPANY
$INSERT I_F.STMT.ENTRY
$INSERT I_F.CATEG.ENTRY
$INSERT I_F.SECURITY.TRANS


      EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================

      GOSUB OPEN.FILES
*
* Update STOCK.DIV.CUS files (live, unauthorised, historic)
*
      FN.FILE = FN.STOCK.DIV.CUS
      F.FILE = F.STOCK.DIV.CUS
      GOSUB OBTAIN.LIST
      FN.FILE = FN.STOCK.DIV.CUS$NAU
      F.FILE = F.STOCK.DIV.CUS$NAU
      GOSUB OBTAIN.LIST
      FN.FILE = FN.STOCK.DIV.CUS$HIS
      F.FILE = F.STOCK.DIV.CUS$HIS
      GOSUB OBTAIN.LIST

* Update concat files
      YFILE = FN.CONCAT.STOCK.REQUEST
      F.YFILE = F.CONCAT.STOCK.REQUEST
      GOSUB UPDATE.CONCAT.ONE
      YFILE = FN.CON.STOCK.DIV.REP
      F.YFILE = F.CON.STOCK.DIV.REP
      GOSUB UPDATE.CONCAT.ONE
      GOSUB UPDATE.CONCAT.TWO
*
      RETURN
*
************
OBTAIN.LIST:
************
* Select list in STOCK.DIV.CUS files (live, unauthorised, historic)
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
* Main loop (process STOCK.DIV.CUS keys) : add a dot to the key, write the new key and and delete the old one
* Update the reference from the new id

      LOOP
         REMOVE CODE FROM LIST SETTING MORE
*
      WHILE CODE DO
*
         REFERENCE = ''
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

         IF R.FILE<SC.SDD.STATEMENT.NOS><1,1> THEN STMT.NO = R.FILE<SC.SDD.STATEMENT.NOS><1,1>

         IF FN.FILE = FN.STOCK.DIV.CUS OR FN.FILE = FN.STOCK.DIV.CUS$NAU THEN
            CODE.NEW = CODE:'.'
            TRANSACTION.ID = CODE.NEW
            CODE.SAVE = CODE
         END
         IF FN.FILE = FN.STOCK.DIV.CUS$HIS THEN
            KEY.FIELD1 = FIELD(CODE,';',1)
            KEY.FIELD2 = FIELD(CODE,';',2)
            CODE.NEW = KEY.FIELD1:'.':';':KEY.FIELD2
            CODE.SAVE = KEY.FIELD1
            TRANSACTION.ID = KEY.FIELD1:'.'
         END

         IF R.FILE<SC.SDD.REFERENCE.NO> THEN REFERENCE = R.FILE<SC.SDD.REFERENCE.NO>

         CALL F.WRITE(FN.FILE,CODE.NEW,R.FILE)
         CALL F.DELETE(FN.FILE,CODE)

* Update TRANS.REFERENCE field in STMT.ENTRY and CATEG.ENTRY files
* Update REF.NO.SEQUENCE field in SECURITY.TRANS file

         YID = ''
         IF REFERENCE THEN
            YID = REFERENCE ; YLIST = ''
            YFILE = FN.SECURITY.TRANS ; F.YFILE = F.SECURITY.TRANS
            GOSUB UPDATE.SEC.TRANS
         END
         IF STMT.NO THEN
            NB = ''
            NB = FIELD(R.FILE<SC.SDD.STATEMENT.NOS><1,2>,'-',2)
            IF NOT(NB) THEN NB = 1
            YFILE = FN.STMT.ENTRY ; F.YFILE = F.STMT.ENTRY
            GOSUB UPDATE.ENTRY
            IF R.FILE<SC.SDD.STATEMENT.NOS><1,3> THEN
               NB = ''
               NB = FIELD(R.FILE<SC.SDD.STATEMENT.NOS><1,3>,'-',2)
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
      YCMD = 'SSELECT ':YFILE:' WITH @ID LIKE ':YID:'...'
      CALL EB.READLIST(YCMD,YLIST,'','','')
      IF NOT(YLIST) THEN RETURN
      LOOP
         REMOVE YCODE FROM YLIST SETTING MORE
      WHILE YCODE DO
         CALL F.READU(YFILE,YCODE,R.YFILE,F.YFILE,ER,'R 05 12')
         IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YCODE:VM:YFILE
            GOTO FATAL.ERROR
         END
         R.YFILE<SC.SCT.REF.NO.SEQUENCE> = TRANSACTION.ID
         CALL F.WRITE(YFILE,YCODE,R.YFILE)
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
         IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:YFILE
            GOTO FATAL.ERROR
         END
*update reference number with the new key
         IF YFILE = FN.STMT.ENTRY AND R.YFILE<AC.STE.TRANS.REFERENCE> = CODE.SAVE THEN
            R.YFILE<AC.STE.TRANS.REFERENCE> = TRANSACTION.ID
            CALL F.WRITE(YFILE,YID,R.YFILE)
         END
         IF YFILE = FN.CATEG.ENTRY AND R.YFILE<AC.CAT.TRANS.REFERENCE> = CODE.SAVE THEN
            R.YFILE<AC.CAT.TRANS.REFERENCE> = TRANSACTION.ID
            CALL F.WRITE(YFILE,YID,R.YFILE)
         END
      NEXT YI
*
      RETURN
*
*****************************************************************
UPDATE.CONCAT.ONE:
*****************************************************************
*
* Select list from concat file
*
      YLIST = ''
      YID = ''
      YFIELD = ''
      YSELECT = 'SSELECT ':YFILE
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
*
         YNB = DCOUNT(YFIELD,FM)
*
         FOR I = 1 TO YNB                ; *process each line
            YFIELD.NEW<I> = YFIELD<I>:'.'
         NEXT I
*
         CALL F.WRITE(YFILE,YID,YFIELD.NEW)
*
         CALL JOURNAL.UPDATE(YID)
*
      REPEAT
*
      RETURN
*
******************
UPDATE.CONCAT.TWO:
******************
*
* Select list from SEC.TRADES.TODAY
*
      YFILE = FN.SEC.TRADES.TODAY
      YLIST = ''
      YID = ''
      YFIELD = ''
      YSELECT = 'SSELECT ':YFILE:' WITH @ID LIKE ':ID.COMPANY:'*STKD...'
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
         CALL F.READU(YFILE,YID,YFIELD,F.SEC.TRADES.TODAY,ER,'R 05 12')
         IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:YFILE
            GOTO FATAL.ERROR
         END
*
         YID.NEW = ''
         YFIELD.NEW = ''
*
         YID.NEW = YID:'.'
*
         YNB = DCOUNT(YFIELD,FM)
*
         FOR I = 1 TO YNB                ; *process each line
            YFIELD.NEW<I> = YFIELD<I>:'.'
         NEXT I
         CALL F.WRITE(YFILE,YID.NEW,YFIELD.NEW)
         CALL F.DELETE(YFILE,YID)
         CALL JOURNAL.UPDATE(YID.NEW)
*
      REPEAT
*
      RETURN
*
*****************************************************************
OPEN.FILES:
*****************************************************************

*
      FN.STOCK.DIV.CUS = 'F.STOCK.DIV.CUS'
      F.STOCK.DIV.CUS = ''
      CALL OPF(FN.STOCK.DIV.CUS,F.STOCK.DIV.CUS)
*
      FN.STOCK.DIV.CUS$NAU = 'F.STOCK.DIV.CUS$NAU'
      F.STOCK.DIV.CUS$NAU = ''
      CALL OPF(FN.STOCK.DIV.CUS$NAU,F.STOCK.DIV.CUS$NAU)
*
      FN.STOCK.DIV.CUS$HIS = 'F.STOCK.DIV.CUS$HIS'
      F.STOCK.DIV.CUS$HIS = ''
      CALL OPF(FN.STOCK.DIV.CUS$HIS,F.STOCK.DIV.CUS$HIS)
*
      FN.CONCAT.STOCK.REQUEST = 'F.CONCAT.STOCK.REQUEST'
      F.CONCAT.STOCK.REQUEST = ''
      CALL OPF(FN.CONCAT.STOCK.REQUEST,F.CONCAT.STOCK.REQUEST)
*
      FN.SEC.TRADES.TODAY = 'F.SEC.TRADES.TODAY'
      F.SEC.TRADES.TODAY = ''
      CALL OPF(FN.SEC.TRADES.TODAY,F.SEC.TRADES.TODAY)
*
      FN.CON.STOCK.DIV.REP = 'F.CON.STOCK.DIV.REP'
      F.CON.STOCK.DIV.REP = ''
      CALL OPF(FN.CON.STOCK.DIV.REP,F.CON.STOCK.DIV.REP)
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
      CALL FATAL.ERROR('CONV.STOCK.DIV.CUS.SUB')


   END
