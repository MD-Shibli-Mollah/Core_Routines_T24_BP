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
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.STOCK.DIV.DET.8907
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING STOCK.DIV.DET RECORDS.
* ALSO ADD NEW FIELDS :-
*
*  1.  OVERRIDE
*  2. LOCAL.REF
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING STOCK.DIV.DET RECORDS ......PLEASE WAIT'
      F.STOCK.DIV.DET = ''
      YFILE.NAME1 = 'F.STOCK.DIV.DET'
      CALL OPF(YFILE.NAME1,F.STOCK.DIV.DET)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.STOCK.DIV.DET$NAU'
      CALL OPF(YFILE.NAME2,F.STOCK.DIV.DET)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.STOCK.DIV.DET$HIS'
      CALL OPF(YFILE.NAME3,F.STOCK.DIV.DET)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.STOCK.DIV.DET
      LOOP
         READNEXT K.STOCK.DIV.DET ELSE NULL
      WHILE K.STOCK.DIV.DET DO
         READU R.STOCK.DIV.DET FROM F.STOCK.DIV.DET,K.STOCK.DIV.DET ELSE
            E = 'OPEN ORDER "':K.STOCK.DIV.DET:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.STOCK.DIV.DET,FM) + (R.STOCK.DIV.DET # '')
         IF NO.OF.FIELDS < 30 THEN
            INS '' BEFORE R.STOCK.DIV.DET<20>
            INS '' BEFORE R.STOCK.DIV.DET<20>
         END
         WRITE R.STOCK.DIV.DET TO F.STOCK.DIV.DET,K.STOCK.DIV.DET
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.DIV.COUP.DET.8907')
********
* END
********
   END
