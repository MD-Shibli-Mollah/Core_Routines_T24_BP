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
* <Rating>69</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.Config
      SUBROUTINE CONV.RE.STAT.OUTPUT.12.1.1
* Version 2 05/01/00  GLOBUS Release No. G10.2.01 25/02/00
      PROG.ID = 'CONV.RE.STAT.OUTPUT.12.1.1'
      FILE.NAME = 'F.RE.STAT.OUTPUT'
$INSERT I_COMMON
$INSERT I_EQUATE
      EXECUTE 'COMO ON ':PROG.ID

      FOR X = 1 TO 3
         BEGIN CASE
            CASE X EQ 1
               F.FILE.NAME = FILE.NAME
            CASE X EQ 2
               F.FILE.NAME = FILE.NAME:'$NAU'
            CASE X EQ 3
               F.FILE.NAME = FILE.NAME:'$HIS'
         END CASE
         GOSUB PROCESS.FILE
      NEXT X

      EXECUTE 'COMO OFF'
      RETURN                             ; * Exit program.

PROCESS.FILE:
      F.FILE = ''
      CALL OPF(F.FILE.NAME,F.FILE)
      PRINT 'SSELECT ':F.FILE.NAME
      EXECUTE 'SSELECT ':F.FILE.NAME
      LOOP
         READNEXT K.RE.STAT.OUTPUT ELSE K.RE.STAT.OUTPUT = ''
      UNTIL K.RE.STAT.OUTPUT = ''
         READ R.RE.STAT.OUTPUT FROM F.FILE,K.RE.STAT.OUTPUT ELSE
            TEXT = 'UNABLE TO READ & FROM &':@FM:K.RE.STAT.OUTPUT:@VM:F.FILE.NAME
            CALL FATAL.ERROR(PROG.ID)
         END
         IF DCOUNT(R.RE.STAT.OUTPUT,@FM) EQ 15 THEN
            INS '' BEFORE R.RE.STAT.OUTPUT<7>
         END
         WRITE R.RE.STAT.OUTPUT TO F.FILE,K.RE.STAT.OUTPUT
      REPEAT

      RETURN
   END
