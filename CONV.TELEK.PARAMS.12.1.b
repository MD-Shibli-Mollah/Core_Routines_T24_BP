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

* Version 5 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>726</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE XT.PriceFeed
      SUBROUTINE CONV.TELEK.PARAMS.12.1
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
*************************************************************************
*
      PRINT @(5,5):"This program CONVERTS TELEK.PARAMETER"
      TEXT = "DO YOU WISH TO CONVERT THE FILE"
      CALL OVE
      IF TEXT NE "Y" THEN GOTO PGM.EXIT
*
      YFILE = "F.TELEK.PARAMETERS"       ; * File to be converted
      COMPANY.CODE.POS = 16              ; * Position of XX.CO.CODE in the file
*
** If any fields are to be removed from the file add these here
** If several sets of fields are to be removed these should be added
** in multi values 2 and onwards
*
      CANCEL.FIELD = ""
      CANCEL.FIELD<1,1> = ""             ; * Position to delete from
      CANCEL.FIELD<2,1> = ""             ; * Number of fields to delete
*
** Add the position where new fields start, plus the number of fields
** required.
** If several sets of fields are to be added these should be added
** in multi values 2 and onwards
*
      ADD.FIELD = ''
      ADD.FIELD<1,1> = 7                 ; * POSITION TO ADD
      ADD.FIELD<2,1> = 4                 ; * NUMBER OF FIELDS TO ADD
*
      GOSUB MODIFY.FILE ; IF TEXT = "NO" THEN RETURN
*
PGM.EXIT:
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
         CALL SF.CLEAR(1,7,"RECORD RUNNING:  ":YID)
         IF YREC<COMPANY.CODE.POS> MATCHES "2A7N" THEN
            TEXT = "CONVERSION ALREADY DONE"
            CALL OVE
            IF TEXT = "Y" THEN
               GOTO NEXT.READNEXT
            END ELSE
               RETURN
            END
         END
*
** Delete the fields specified here
*
         X = 0
         LOOP X+=1 UNTIL CANCEL.FIELD<1,X> = ""
            POS = CANCEL.FIELD<1,X>
            NOF = CANCEL.FIELD<2,X>
            FOR Y = 1 TO NOF
               DEL YREC<POS>
            NEXT Y
         REPEAT
*
** Add the fields specified here
*
         X = 0
         LOOP X +=1 UNTIL ADD.FIELD<1,X> = ''
            POS = ADD.FIELD<1,X>
            NOF = ADD.FIELD<2,X>
            FOR Y = 1 TO NOF
               YREC = INSERT(YREC,POS,0,0,"")
            NEXT Y
         REPEAT
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
