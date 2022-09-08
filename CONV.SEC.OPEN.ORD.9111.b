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
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderCapture
      SUBROUTINE CONV.SEC.OPEN.ORD.9111
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SEC.OPEN.ORDER RECORDS.
* ALSO ADD NEW FIELDS :-
*
*  1.  LIQD.PERIOD
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SEC.OPEN.ORDER RECORDS ......PLEASE WAIT'
      F.SEC.OPEN.ORDER = ''
      YFILE.NAME1 = 'F.SEC.OPEN.ORDER'
      CALL OPF(YFILE.NAME1,F.SEC.OPEN.ORDER)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SEC.OPEN.ORDER$NAU'
      CALL OPF(YFILE.NAME2,F.SEC.OPEN.ORDER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SEC.OPEN.ORDER$HIS'
      CALL OPF(YFILE.NAME3,F.SEC.OPEN.ORDER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SEC.OPEN.ORDER
      LOOP
         READNEXT K.SEC.OPEN.ORDER ELSE NULL
      WHILE K.SEC.OPEN.ORDER DO
         READU R.SEC.OPEN.ORDER FROM F.SEC.OPEN.ORDER,K.SEC.OPEN.ORDER ELSE
            E = 'OPEN ORDER "':K.SEC.OPEN.ORDER:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SEC.OPEN.ORDER,FM) + (R.SEC.OPEN.ORDER # '')
         IF NO.OF.FIELDS < 42 THEN
            INS '' BEFORE R.SEC.OPEN.ORDER<32>
         END
         WRITE R.SEC.OPEN.ORDER TO F.SEC.OPEN.ORDER,K.SEC.OPEN.ORDER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SEC.OPEN.ORDER.8907')
********
* END
********
   END
