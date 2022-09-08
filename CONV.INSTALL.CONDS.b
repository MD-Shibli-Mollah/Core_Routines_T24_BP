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
* <Rating>1060</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LM.Config
      SUBROUTINE CONV.INSTALL.CONDS
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
*************************************************************************
*
      YFILE = "F.LMM.INSTALL.CONDS" ; YLASTFIELDNO = 103 ; YNEWFIELDNO = 104
      Y1ST.FIELD.CANCEL = "" ; YLAST.FIELD.CANCEL = ""
      Y1ST.FIELD.ADD = 95 ; YLAST.FIELD.ADD = 95
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
            CASE YFILE.ADD = "$NAU" ; YLOOP = "NO"
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
         YCOUNT = COUNT(YREC,FM)+1
         IF YCOUNT = YNEWFIELDNO THEN
            TEXT = "CONVERSION ALREADY DONE"
            CALL OVE ; IF TEXT = "Y" THEN GOTO NEXT.READNEXT
               ELSE RETURN
         END
*
         IF YCOUNT <> YLASTFIELDNO THEN
            TEXT = "LAST FIELD DEFINED=":YLASTFIELDNO
            TEXT = TEXT:", BUT RECORDFIELDS=":YCOUNT
            CALL OVE ; IF TEXT = "Y" THEN GOTO NEXT.READNEXT
               ELSE RETURN
         END
*
         IF YLAST.FIELD.CANCEL = "" THEN
            YLAST.FIELD.CANCEL = Y1ST.FIELD.CANCEL
         END
         IF Y1ST.FIELD.CANCEL <> "" THEN
            FOR Y = Y1ST.FIELD.CANCEL TO YLAST.FIELD.CANCEL
               YREC = DELETE(YREC,Y1ST.FIELD.CANCEL,0,0)
            NEXT Y
         END
*
         IF YLAST.FIELD.ADD = "" THEN
            YLAST.FIELD.ADD = Y1ST.FIELD.ADD
         END
         IF Y1ST.FIELD.ADD <> "" THEN
            FOR Y = Y1ST.FIELD.ADD TO YLAST.FIELD.ADD
               YREC = INSERT(YREC,Y,0,0,"")
            NEXT Y
         END
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
