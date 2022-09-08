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

* Version 4 29/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>92</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Clearing
      SUBROUTINE CONV.FT.BC.TXN.CODE.11.1
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.FT.TXN.TYPE.CONDITION
$INSERT I_SCREEN.VARIABLES

      EQU BELL TO CHARX(7)

*************************************************************************
* PROGRAM MAINLINE *
* ~~~~~~~~~~~~~~~~ *

      APPLIC.NAME = 'F.FT.BC.TXN.CODE'

      ADD.FIELD = ''
      ADD.FIELD.POS = 17
      ADD.FIELD.TOT= 4
      OLD.FIELD.TOT = 25
      SUFFIXES = 'ý$NAUý$HIS'
      LINE.NO = 8                        ; * SCREEN LINE TO START DISPLAY

      FOR LP1 = 1 TO 3
         FILE.SUFFIX = SUFFIXES<1,LP1>
         GOSUB MODIFY.FILE
         RELEASE
         LINE.NO += 3
      NEXT LP1

      RETURN                             ; * FROM CONVERT.FT.BC.TXN.CODE.11.1

*************************************************************************

MODIFY.FILE:
*~~~~~~~~~~~

      TEXT = ''
      UPDTOT = 0

      FILE.NAME = APPLIC.NAME:FILE.SUFFIX
      F.FILE = ''
      CALL OPF (FILE.NAME:FM:'NO.FATAL.ERROR', F.FILE)
      IF ETEXT THEN
         CALL SF.CLEAR(8,22,"MISSING FILE=":FILE.NAME:" ID=":V$KEY)
         CALL PGM.BREAK
      END
      CALL SF.CLEAR(1,LINE.NO,"FILE RUNNING:  ":FILE.NAME)

      CLEARSELECT
      SELECT F.FILE
      FILE.ERROR = 0                     ; * FLAG FOR ALREADY CONVERTED
      LOOP WHILE READNEXT V$KEY DO

         LOOP
            LOKMSG = ''
            READU FILE.REC FROM F.FILE, V$KEY LOCKED
               LOKMSG = '"':V$KEY:'" in ':FILE.NAME:' is locked'
            END ELSE
               FILE.REC = ''
            END
         WHILE LOKMSG NE '' DO
            CRT @(1,23):BELL:LOKMSG:
            SLEEP 2
            CRT @(1,23):S.CLEAR.EOL:
         REPEAT

         CALL SF.CLEAR(1,LINE.NO+1,'RECORD RUNNING:  ':V$KEY)
         FIELD.TOT = DCOUNT(FILE.REC,@FM)

         IF FILE.REC EQ '' THEN
            RELEASE F.FILE,V$KEY
         END ELSE
            IF FIELD.TOT LE OLD.FIELD.TOT THEN
               FOR LP2 = 1 TO ADD.FIELD.TOT
                  INS '' BEFORE FILE.REC<ADD.FIELD.POS>
               NEXT LP2
            END ELSE
               IF NOT(FILE.ERROR) THEN   ; * NO ERRORS PREVIOUSLY
                  TEXT = ' "':V$KEY:'" ALREADY CONVERTED. CONTINUE THIS FILE? (Y/N) : '
                  CALL OVE
                  IF TEXT NE 'Y' THEN
                     RELEASE F.FILE,V$KEY
                     CLEARSELECT
                     RETURN              ; * FROM MODIFY.FILE
                  END
                  FILE.ERROR = 1
               END
            END
            WRITEU FILE.REC TO F.FILE, V$KEY
            RELEASE F.FILE,V$KEY
            UPDTOT += 1
         END
      REPEAT
      CALL SF.CLEAR(1,LINE.NO+1,'RECORDS UPDATED:  ':UPDTOT)

      RETURN                             ; * FROM MODIFY.FILE

   END
