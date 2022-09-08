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
* <Rating>505</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
      SUBROUTINE CONV.PRICE.TYPE.12.1
*
* WRITTEN BY A. KYRIACOU
* DATE  08/03/93.
*
*     Amended March 1993 as part of PIF GB9200236 to add fields,
*     DISCOUNTED.INSTRUMENT
*
**************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING PRICE.TYPE RECORDS ...PLEASE WAIT'
      F.PRICETYPE = ''
      UNAUTH.FILE = 1
      INSERT.VALS = 0
      YFILE.NAME = 'F.PRICE.TYPE$NAU'
      CALL OPF(YFILE.NAME,F.PRICETYPE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      UNAUTH.FILE = 0
      YFILE.NAME = 'F.PRICE.TYPE$HIS'
      CALL OPF(YFILE.NAME,F.PRICETYPE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      INSERT.VALS = 1
      YFILE.NAME1 = 'F.PRICE.TYPE$NAU'
      F.NAU = ''
      CALL OPF(YFILE.NAME1,F.NAU)
      YFILE.NAME = 'F.PRICE.TYPE'
      CALL OPF(YFILE.NAME,F.PRICETYPE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.PRICETYPE
      LOOP
         READNEXT K.PRICE.TYPE ELSE NULL
      WHILE K.PRICE.TYPE NE '' DO
         READU R.PRICE.TYPE FROM F.PRICETYPE,K.PRICE.TYPE ELSE
            E = 'PRICE TYPE "':K.PRICE.TYPE:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.FLDS = COUNT(R.PRICE.TYPE,@FM)+1
         IF NO.FLDS LT 15 THEN
            IF R.PRICE.TYPE<5> = 'PRICE' THEN
               INS 'NO' BEFORE R.PRICE.TYPE<6>
            END ELSE INS '' BEFORE R.PRICE.TYPE<6>
            IF UNAUTH.FILE AND R.PRICE.TYPE<6> = '' THEN R.PRICE.TYPE<7> = 'IHLD'
            IF INSERT.VALS AND R.PRICE.TYPE<6> = '' THEN
               READU R.NAU FROM F.NAU,K.PRICE.TYPE ELSE R.NAU = ''
*               IF R.NAU THEN
               R.NAU = R.PRICE.TYPE
               R.NAU<7> = 'IHLD'
               R.NAU<8> = R.PRICE.TYPE<8> + 1
               WRITE R.NAU TO F.NAU,K.PRICE.TYPE
*               END ELSE RELEASE F.NAU,K.PRICE.TYPE
            END
         END
*
         WRITE R.PRICE.TYPE TO F.PRICETYPE,K.PRICE.TYPE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.PRICE.TYPE.12.1')
********
   END
