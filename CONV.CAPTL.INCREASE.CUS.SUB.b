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
* <Rating>997</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.CAPTL.INCREASE.CUS.SUB
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.CAPTL.INCREASE.CUS
* This program converts the ID of all the existing
* CAPTL.INCREASE.CUS records to include the SUB.ACCOUNT in
* the key of the CAPTL.INCREASE.CUS record.
* Update concat files
*
* author : P.LABE
*
*********************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.CAPTL.INCREASE.CUS
$INSERT I_F.SECURITY.TRANS
$INSERT I_F.COMPANY

      EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================

      GOSUB OPEN.FILES

* Update CAPTL.INCREASE.CUS files (live, unauthorised, historic)

      FN.FILE = FN.CAPTL.INCREASE.CUS
      F.FILE = F.CAPTL.INCREASE.CUS
      GOSUB OBTAIN.LIST
      FN.FILE = FN.CAPTL.INCREASE.CUS$NAU
      F.FILE = F.CAPTL.INCREASE.CUS$NAU
      GOSUB OBTAIN.LIST
      FN.FILE = FN.CAPTL.INCREASE.CUS$HIS
      F.FILE = F.CAPTL.INCREASE.CUS$HIS
      GOSUB OBTAIN.LIST

* Update concat files
      ST.TODAY = FALSE                   ; *Process SEC.TRADES.TODAY file

      YFILE = 'F.DET.CON.REQ'
      GOSUB UPDATE.CONCAT.FILE
      YFILE = 'F.POS.CON.CID'
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
      CMD = 'SSELECT ':FN.FILE
      CALL EB.READLIST(CMD,LIST,'','','')
      IF LIST THEN GOSUB UPDATE.FILE
*
      RETURN
*
************
UPDATE.FILE:
************
* Main loop (process CAPTL.INCREASE.CUS keys) : add a dot to the key, write the new key and and delete the old one
*
      LOOP
         REMOVE CODE FROM LIST SETTING MORE
*
      WHILE CODE DO
*
         R.FILE = ''
         CODE.NEW = ''
         KEY.FIELD1 = ''
         KEY.FIELD2 = ''
         REF.CODE = ''
         TRANSACTION.ID = ''
         REFERENCE = ''
         CALL F.READU(FN.FILE,CODE,R.FILE,F.FILE,ER,'R 05 12')
         IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:CODE:VM:FN.FILE
            GOTO FATAL.ERROR
         END
         IF R.FILE<SC.CID.REFERENCE.NO> THEN REFERENCE = R.FILE<SC.CID.REFERENCE.NO>
         IF FN.FILE = FN.CAPTL.INCREASE.CUS OR FN.FILE = FN.CAPTL.INCREASE.CUS$NAU THEN
            CODE.NEW = CODE:'.'
            TRANSACTION.ID = CODE.NEW
            REF.CODE = CODE
         END
         IF FN.FILE = FN.CAPTL.INCREASE.CUS$HIS THEN
            KEY.FIELD1 = FIELD(CODE,';',1)
            KEY.FIELD2 = FIELD(CODE,';',2)
            CODE.NEW = KEY.FIELD1:'.':';':KEY.FIELD2
            REF.CODE = KEY.FIELD1
            TRANSACTION.ID = KEY.FIELD1:'.'
         END
         CALL F.WRITE(FN.FILE,CODE.NEW,R.FILE)
         CALL F.DELETE(FN.FILE,CODE)

* Update REF.NO.SEQUENCE field in SECURITY.TRANS file

         IF NOT(REFERENCE) THEN GOTO UPDATE.JOURNAL

         SCT.LIST = ''
         SCT.CMD = 'SSELECT ':FN.SECURITY.TRANS:' WITH @ID LIKE ':REFERENCE:'...'
         CALL EB.READLIST(SCT.CMD,SCT.LIST,'','','')
         IF NOT(SCT.LIST) THEN
            E = 'MISSING LIST FOR SECURITY.TRANS'
            GOTO FATAL.ERROR
         END
         LOOP
            REMOVE SCT.CODE FROM SCT.LIST SETTING MORE
         WHILE SCT.CODE DO

            CALL F.READU(FN.SECURITY.TRANS,SCT.CODE,R.SECURITY.TRANS,F.SECURITY.TRANS,ER,'R 05 12')
            IF ER THEN
               E = 'RECORD & NOT FOUND ON FILE & ':FM:SCT.CODE:VM:'F.SECURITY.TRANS'
               GOTO FATAL.ERROR
            END
            IF R.SECURITY.TRANS<SC.SCT.REF.NO.SEQUENCE> = REF.CODE THEN
               R.SECURITY.TRANS<SC.SCT.REF.NO.SEQUENCE> = TRANSACTION.ID         ; *update reference number with the new key
               CALL F.WRITE(FN.SECURITY.TRANS,SCT.CODE,R.SECURITY.TRANS)
            END

         REPEAT
*
UPDATE.JOURNAL:
         CALL JOURNAL.UPDATE(CODE.NEW)
*
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
         YSELECT = 'SSELECT ':YFILE:' WITH @ID LIKE ':ID.COMPANY:'*CAPI...'
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
         CALL F.WRITE(YFILE,YID,YFIELD.NEW)
*
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
      FN.CAPTL.INCREASE.CUS = 'F.CAPTL.INCREASE.CUS'
      F.CAPTL.INCREASE.CUS = ''
      CALL OPF(FN.CAPTL.INCREASE.CUS,F.CAPTL.INCREASE.CUS)
*
      FN.SECURITY.TRANS = 'F.SECURITY.TRANS'
      F.SECURITY.TRANS = ''
      CALL OPF(FN.SECURITY.TRANS,F.SECURITY.TRANS)

*
      FN.CAPTL.INCREASE.CUS$NAU = 'F.CAPTL.INCREASE.CUS$NAU'
      F.CAPTL.INCREASE.CUS$NAU = ''
      CALL OPF(FN.CAPTL.INCREASE.CUS$NAU,F.CAPTL.INCREASE.CUS$NAU)
*
      FN.CAPTL.INCREASE.CUS$HIS = 'F.CAPTL.INCREASE.CUS$HIS'
      F.CAPTL.INCREASE.CUS$HIS = ''
      CALL OPF(FN.CAPTL.INCREASE.CUS$HIS,F.CAPTL.INCREASE.CUS$HIS)
*

      RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

      TEXT = E
      CALL FATAL.ERROR('CONV.CAPTL.INCREASE.CUS.SUB')


   END
