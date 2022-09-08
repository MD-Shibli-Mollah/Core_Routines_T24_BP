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
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
      SUBROUTINE CONV.PRICE.TYPE.9108
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING PRICE.TYPE RECORDS.
* ALSO ADD NEW FIELDS :-
***  CALCULATION.METHOD
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING PRICE.TYPE RECORDS ......PLEASE WAIT'
      F.PRICE.TYPE = ''
      YFILE.NAME1 = 'F.PRICE.TYPE'
      CALL OPF(YFILE.NAME1,F.PRICE.TYPE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.PRICE.TYPE$NAU'
      CALL OPF(YFILE.NAME2,F.PRICE.TYPE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.PRICE.TYPE$HIS'
      CALL OPF(YFILE.NAME3,F.PRICE.TYPE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.PRICE.TYPE
      LOOP
         READNEXT K.PRICE.TYPE ELSE NULL
      WHILE K.PRICE.TYPE # '' DO
         READU R.PRICE.TYPE FROM F.PRICE.TYPE,K.PRICE.TYPE ELSE
            E = 'SEC TRADE "':K.PRICE.TYPE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.PRICE.TYPE,FM) + (R.PRICE.TYPE # '')
         IF NO.OF.FIELDS < 14 THEN
            INS 'PRICE' BEFORE R.PRICE.TYPE<5>
         END
         WRITE R.PRICE.TYPE TO F.PRICE.TYPE,K.PRICE.TYPE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.PRICE.TYPE.9002')
   END
