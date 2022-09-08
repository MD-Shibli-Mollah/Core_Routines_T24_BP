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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>470</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfAdvisoryFees
      SUBROUTINE CONV.ADVCHG.8809
*
* To add one new fields :-
*
* PERIOD.FROM & PERIOD.TO ARE INCLUDED.
*
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
      YFILE = "F.SC.ADVISORY.CHG" ; YNEWFIELDNO = 22
      YNEWFIELDNO2 = 22
      GOSUB MODIFY.FILE ; IF TEXT = "NO" THEN RETURN
*
      RETURN
*-----------
MODIFY.FILE:
*-----------
      CALL SF.CLEAR.STANDARD
      TEXT = "" ; YFILE.SAVE = YFILE ; YFILE.ADD = "" ; YLOOP = "Y"
      LOOP UNTIL YLOOP = "NO" DO
         GOSUB MODIFY.FILE.START
         BEGIN CASE
            CASE YFILE.ADD = "" ; YFILE.ADD = "$NAU"
            CASE YFILE.ADD = "$NAU" ; YFILE.ADD = "$HIS"
            CASE YFILE.ADD = "$HIS" ; YLOOP = "NO"
         END CASE
      REPEAT
      RETURN
*-----------
MODIFY.FILE.START:
*-----------
      YFILE = YFILE.SAVE:YFILE.ADD
      F.FILE = "" ; CALL OPF (YFILE:FM:"NO.FATAL.ERROR", F.FILE)
      IF ETEXT THEN RETURN
      CALL SF.CLEAR(1,5,"FILE RUNNING:  ":YFILE)
*
      SELECT F.FILE
      LOOP
         READNEXT YID ELSE NULL
      WHILE YID DO
*
         READ YREC FROM F.FILE, YID ELSE GOTO FATAL.ERROR
         CALL SF.CLEAR(1,7,"RECORD RUNNING:  ":YID)
         YCOUNT = COUNT(YREC,FM)+1
         IF YCOUNT = YNEWFIELDNO OR YCOUNT = YNEWFIELDNO2 THEN
            TEXT = "CONVERSION ALREADY DONE"
            CALL REM
            RETURN
         END
*
         INS '' BEFORE YREC<3>
         INS '' BEFORE YREC<3>
         YREC<3> = TODAY[1,6]
         YREC<4> = TODAY[1,6]
         WRITE YREC TO F.FILE, YID
*
      REPEAT
      RETURN
*-----------
FATAL.ERROR:
*-----------
      CALL SF.CLEAR(8,22,"MISSING FILE=":YFILE:" ID=":YID)
      CALL PGM.BREAK
   END
