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

* Version 5 07/12/95  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>499</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Upgrade
      SUBROUTINE TYPE.PROG.REBUILD
*
*     TYPE.PROG.REBUILD       EBS      21/1/87      JOHN HUNTER

*---- Program to rebuild F.TYPE.PROG from the file F.PGM.TYPE

*
* GB9400926 - Improve performance by concatenting @FM to array, rather
*             than using <-1>
*
* GB9501263 - 27/10/95
*             Ensure program works whether dictionary item is TYPE or
*             K.TYPE
*
* GB9501455 - 07/12/95
*             Incorrectly giving message that program was unsuccessful
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().  
*

      DIM PGM.REC(1)
      RECORD = ''
      TYPE = ''
      SYS.RETURN.CODE = ''

      OPEN '','F.PGM.FILE' TO F.PGM.FILE ELSE
         PRINT 'CANNOT OPEN F.PGM.FILE'
         RETURN
      END
      OPEN '','F.TYPE.PROG' TO F.TYPE.PROG ELSE
         PRINT 'CANNOT OPEN F.TYPE.PROG'
         RETURN
      END
      CLEARFILE F.TYPE.PROG
*
      CALL HUSHIT(1)
      EXECUTE 'SELECT F.PGM.FILE BY TYPE BY @ID'
*
*If select was unsuccessful, select using K.TYPE
*
      SYS.RETURN.CODE = @SYSTEM.RETURN.CODE
      IF SYS.RETURN.CODE < 0 THEN
         EXECUTE 'SELECT F.PGM.FILE BY K.TYPE BY @ID'
         SYS.RETURN.CODE = @SYSTEM.RETURN.CODE
      END
      CALL HUSHIT(0)
*
      IF SYS.RETURN.CODE < 0 THEN
         PRINT ; PRINT 'TYPE.PROG.REBUILD UNSUCCESSFUL' ; PRINT
         RETURN
      END

      LOOP
         READNEXT ID ELSE ID = ''
      UNTIL ID = ''
         MATREAD PGM.REC FROM F.PGM.FILE,ID ELSE STOP 'CANNOT READ F.PGM.FILE RECORD ':ID
         IF PGM.REC(1) <> TYPE AND TYPE <> '' THEN
            WRITE RECORD TO F.TYPE.PROG,TYPE
            RECORD = ''
         END
         TYPE = PGM.REC(1)
         IF RECORD THEN RECORD := @FM:ID
            ELSE RECORD = ID
      REPEAT
      IF RECORD <> '' THEN WRITE RECORD TO F.TYPE.PROG,TYPE
      PRINT ; PRINT 'F.TYPE.PROG rebuild completed .' ; PRINT
   END
