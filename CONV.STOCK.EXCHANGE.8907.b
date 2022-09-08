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
      SUBROUTINE CONV.STOCK.EXCHANGE.8907
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SEC.OPEN.ORDER RECORDS.
* ALSO ADD NEW FIELDS :-
*
* 1. SETTL DAYS
* 2.  SETTL DAYS BASIS
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING STOCK.EXCHANGE RECORDS ......PLEASE WAIT'
      F.STOCK.EXCHANGE = ''
      YFILE.NAME1 = 'F.STOCK.EXCHANGE'
      CALL OPF(YFILE.NAME1,F.STOCK.EXCHANGE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.STOCK.EXCHANGE$NAU'
      CALL OPF(YFILE.NAME2,F.STOCK.EXCHANGE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.STOCK.EXCHANGE$HIS'
      CALL OPF(YFILE.NAME3,F.STOCK.EXCHANGE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.STOCK.EXCHANGE
      LOOP
         READNEXT K.STOCK.EXCHANGE ELSE NULL
      WHILE K.STOCK.EXCHANGE DO
         READU R.STOCK.EXCHANGE FROM F.STOCK.EXCHANGE,K.STOCK.EXCHANGE ELSE
            E = 'OPEN ORDER "':K.STOCK.EXCHANGE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.STOCK.EXCHANGE,FM) + (R.STOCK.EXCHANGE # '')
         IF NO.OF.FIELDS < 13 THEN
            INS '' BEFORE R.STOCK.EXCHANGE<4>
            INS '' BEFORE R.STOCK.EXCHANGE<4>
         END
         WRITE R.STOCK.EXCHANGE TO F.STOCK.EXCHANGE,K.STOCK.EXCHANGE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.STOCK.EXCHANGE.8907')
********
* END
********
   END
