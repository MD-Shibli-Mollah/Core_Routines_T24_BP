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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>735</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.DICTIONARY.11.1.0
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
*************************************************************************
*
      YFILE = "F.DICTIONARY"
      Y1ST.FIELD.CANCEL = "" ; YLAST.FIELD.CANCEL = ""
*
      ADD.FIELD = ''
*
      ADD.FIELD<1,1> = ''                ; * POSITION TO ADD FROM
      ADD.FIELD<2,1> = ''                ; * NUMBER OF FIELDS TO ADD
*
*
      GOSUB MODIFY.FILE ; IF TEXT = "NO" THEN RETURN
*
      RETURN
*
*************************************************************************
*
MODIFY.FILE:
*
      CALL SF.CLEAR.STANDARD
      TEXT = "" ; YFILE.SAVE = YFILE ; YFILE.ADD = "" ; YLOOP = "Y"
      LOOP UNTIL YLOOP = "NO" OR TEXT = "NO" DO
         GOSUB MODIFY.FILE.START
         BEGIN CASE
            CASE YFILE.ADD = "" ; YFILE.ADD = "$NAU"
            CASE YFILE.ADD = "$NAU" ; YFILE.ADD = "$HIS"
            CASE YFILE.ADD = "$HIS" ; YLOOP = "NO"
         END CASE
      REPEAT
      RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
      YFILE = YFILE.SAVE:YFILE.ADD
      F.FILE = "" ; CALL OPF (YFILE:FM:"NO.FATAL.ERROR", F.FILE)
      IF ETEXT THEN RETURN
      CALL SF.CLEAR(1,5,"FILE RUNNING:  ":YFILE)
*
      SELECT F.FILE
      LOOP
         READNEXT YID ELSE YID = ""
      UNTIL YID = "" DO
*
         READ YREC FROM F.FILE, YID ELSE GOTO FATAL.ERROR
*
         IF NOT(COUNT(YREC,FM)) THEN     ; * No field marks in record
            PRINT @(1,8):FMT("CONVERSION ALREADY DONE ":YID, "60L"):
            GOTO NEXT.READNEXT
         END
*
         IF YFILE[4] = "$HIS" THEN       ; * History file
         END
*
         IF YID EQ 'VALIDATION.ROUTINES' THEN GOTO NEXT.READNEXT       ; * Ignore this because it is being released.
*
         PRINT @(1,7):FMT("CONVERTING ":YID,"60L"):
*
         CONVERT FM TO VM IN YREC
*
         WRITE YREC TO F.FILE, YID
*
NEXT.READNEXT:
*
      REPEAT
      RETURN
*
*************************************************************************
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"MISSING FILE=":YFILE:" ID=":YID)
      CALL PGM.BREAK
*
*************************************************************************
   END
