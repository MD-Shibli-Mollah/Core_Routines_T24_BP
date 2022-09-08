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
    $PACKAGE SC.SctPositionTransfer
      SUBROUTINE CONV.POS.TRANSFER.9010
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING POSITION.TRANSFER RECORDS.
* ALSO ADD NEW FIELDS :-
*   VALUE.DATE
*   CUSTOMER
*   NO.NOMINAL
*   TEXT.INTERNAL
*   TEXT CONFIRM
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING POSITION.TRANSFER RECORDS ......PLEASE WAIT'
      F.POSITION.TRANSFER = ''
      YFILE.NAME1 = 'F.POSITION.TRANSFER'
      CALL OPF(YFILE.NAME1,F.POSITION.TRANSFER)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.POSITION.TRANSFER$NAU'
      CALL OPF(YFILE.NAME2,F.POSITION.TRANSFER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.POSITION.TRANSFER$HIS'
      CALL OPF(YFILE.NAME3,F.POSITION.TRANSFER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
*
      SELECT F.POSITION.TRANSFER
      LOOP
         READNEXT K.POSITION.TRANSFER ELSE NULL
      WHILE K.POSITION.TRANSFER DO
         READU R.POSITION.TRANSFER FROM F.POSITION.TRANSFER,K.POSITION.TRANSFER ELSE
            E = 'POSITION.TRANSFER "':K.POSITION.TRANSFER:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.POSITION.TRANSFER,FM) + (R.POSITION.TRANSFER # '')
         IF NO.OF.FIELDS < 31 THEN
            INS '' BEFORE R.POSITION.TRANSFER<7>
            INS '' BEFORE R.POSITION.TRANSFER<7>
            INS '' BEFORE R.POSITION.TRANSFER<7>
            INS '' BEFORE R.POSITION.TRANSFER<2>
            TRADE.DATE = R.POSITION.TRANSFER<1>
            INS TRADE.DATE BEFORE R.POSITION.TRANSFER<2>
         END
         WRITE R.POSITION.TRANSFER TO F.POSITION.TRANSFER,K.POSITION.TRANSFER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.POS.TRANSFER.9010')
********
* END
********
   END
