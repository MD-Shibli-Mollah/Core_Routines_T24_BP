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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>558</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE TT.Config
      SUBROUTINE CONV.TELLER.PARM.10.0
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
*************************************************************************
*
      YFILE = "F.TELLER.PARAMETER" ; YNEWFIELDNO = 37
      Y1ST.FIELD.CANCEL = "" ; YLAST.FIELD.CANCEL = ""
*
      ADD.FIELD = ''
*
      ADD.FIELD<1,1> = 9                 ; * POSITION TO ADD
      ADD.FIELD<2,1> = 10                ; * NUMBER OF FIELDS TO ADD
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
         CALL SF.CLEAR(1,7,"RECORD RUNNING:  ":YID)
         IF YREC<24> = ID.COMPANY THEN
            TEXT = "CONVERSION ALREADY DONE"
            CALL OVE
            IF TEXT = "Y" THEN
               GOTO NEXT.READNEXT
            END ELSE
               RETURN
            END
         END
*
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
