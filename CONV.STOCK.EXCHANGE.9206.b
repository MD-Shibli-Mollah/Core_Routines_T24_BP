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
      SUBROUTINE CONV.STOCK.EXCHANGE.9206
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING STOCK.EXCHANGE RECORDS.
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
      EQU TRUE TO 1 , FALSE TO ''
**************************
      PRINT @(10,10):'CONVERTING STOCK.EXCHANGE RECORDS ......PLEASE WAIT'
      F.STOCK.EXCHANGE = ''
      YFILE.NAME = 'F.STOCK.EXCHANGE'
      CALL OPF(YFILE.NAME,F.STOCK.EXCHANGE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME = 'F.STOCK.EXCHANGE$NAU'
      CALL OPF(YFILE.NAME,F.STOCK.EXCHANGE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME = 'F.STOCK.EXCHANGE$HIS'
      CALL OPF(YFILE.NAME,F.STOCK.EXCHANGE)
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
            READNEXT K.STOCK.EXCHANGE ELSE EOF = TRUE
         UNTIL EOF
            READU R.STOCK.EXCHANGE FROM F.STOCK.EXCHANGE,K.STOCK.EXCHANGE ELSE
               E = 'RECORD "':K.STOCK.EXCHANGE:'" MISING FROM FILE'
               GOTO FATAL.ERR
            END
            NO.OF.FIELDS = COUNT(R.STOCK.EXCHANGE,FM) + (R.STOCK.EXCHANGE # '')
            IF NO.OF.FIELDS LT 17 THEN
               INS '' BEFORE R.STOCK.EXCHANGE<6>
               INS '' BEFORE R.STOCK.EXCHANGE<6>
               INS '' BEFORE R.STOCK.EXCHANGE<6>
               INS '' BEFORE R.STOCK.EXCHANGE<6>
               INS '' BEFORE R.STOCK.EXCHANGE<6>
            END
            WRITE R.STOCK.EXCHANGE TO F.STOCK.EXCHANGE,K.STOCK.EXCHANGE
         REPEAT
      END
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.STOCK.EXCHANGE.9206')
********
* END
********
   END
