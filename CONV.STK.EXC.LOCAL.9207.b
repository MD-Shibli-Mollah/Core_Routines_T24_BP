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
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.STK.EXC.LOCAL.9207
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING STK.EXC.LOCAL RECORDS.
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
      EQU TRUE TO 1 , FALSE TO ''
**************************
      PRINT @(10,10):'CONVERTING STK.EXC.LOCAL RECORDS ......PLEASE WAIT'
      F.STK.EXC.LOCAL = ''
      YFILE.NAME = 'F.STK.EXC.LOCAL'
      CALL OPF(YFILE.NAME,F.STK.EXC.LOCAL)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME = 'F.STK.EXC.LOCAL$NAU'
      CALL OPF(YFILE.NAME,F.STK.EXC.LOCAL)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME = 'F.STK.EXC.LOCAL$HIS'
      CALL OPF(YFILE.NAME,F.STK.EXC.LOCAL)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      PRINT 'SELECT ':YFILE.NAME
      EXECUTE 'SELECT ':YFILE.NAME

      IF @SYSTEM.RETURN.CODE GT 0 THEN
         EOF = FALSE
         LOOP
            READNEXT K.STK.EXC.LOCAL ELSE EOF = TRUE
         UNTIL EOF
            READU R.STK.EXC.LOCAL FROM F.STK.EXC.LOCAL,K.STK.EXC.LOCAL ELSE
               E = 'RECORD "':K.STK.EXC.LOCAL:'" MISING FROM FILE'
               GOTO FATAL.ERR
            END
            NO.OF.FIELDS = COUNT(R.STK.EXC.LOCAL,FM) + (R.STK.EXC.LOCAL # '')
            IF NO.OF.FIELDS LT 29 THEN
               INS '' BEFORE R.STK.EXC.LOCAL<16>
               INS '' BEFORE R.STK.EXC.LOCAL<16>
               INS '' BEFORE R.STK.EXC.LOCAL<16>
               INS '' BEFORE R.STK.EXC.LOCAL<16>
               INS '' BEFORE R.STK.EXC.LOCAL<16>
            END
            WRITE R.STK.EXC.LOCAL TO F.STK.EXC.LOCAL,K.STK.EXC.LOCAL
         REPEAT
      END
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.STK.EXC.LOCAL.9206')
********
* END
********
   END
