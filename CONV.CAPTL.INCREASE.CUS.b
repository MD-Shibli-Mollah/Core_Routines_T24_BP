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
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.CAPTL.INCREASE.CUS
*
*     Amended October 1992 as part of PIF GB9200967 to change the field
*     of 'SC.CID.ADVICE.PRINT.FLAG' on file F.CAPTL.INCREASE.CUS.
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING CAPTL.INCREASE.CUS RECORDS.
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.CAPTL.INCREASE.CUS
**************************
      PRINT @(10,10):'CONVERTING CAPTL.INCREASE.CUS RECORDS ..PLEASE WAIT'
*
      F.CAPTL.INCREASE.CUS = ''
      YFILE.NAME1 = 'F.CAPTL.INCREASE.CUS'
      CALL OPF(YFILE.NAME1,F.CAPTL.INCREASE.CUS)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.CAPTL.INCREASE.CUS$NAU'
      CALL OPF(YFILE.NAME2,F.CAPTL.INCREASE.CUS)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.CAPTL.INCREASE.CUS$HIS'
      CALL OPF(YFILE.NAME3,F.CAPTL.INCREASE.CUS)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
*
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.CAPTL.INCREASE.CUS
      LOOP
         READNEXT K.CAPTL.INCREASE.CUS ELSE NULL
      WHILE K.CAPTL.INCREASE.CUS DO
         READU R.CAPTL.INCREASE.CUS FROM F.CAPTL.INCREASE.CUS,K.CAPTL.INCREASE.CUS ELSE
            E = 'RECORD "':K.CAPTL.INCREASE.CUS:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         IF R.CAPTL.INCREASE.CUS<SC.CID.ADVICE.PRINT.FLAG> = 'Y' THEN
            R.CAPTL.INCREASE.CUS<SC.CID.ADVICE.PRINT.FLAG> = '1'
         END
         IF R.CAPTL.INCREASE.CUS<SC.CID.ADVICE.PRINT.FLAG> = 'NO' THEN
            R.CAPTL.INCREASE.CUS<SC.CID.ADVICE.PRINT.FLAG> = ''
         END
*
         WRITE R.CAPTL.INCREASE.CUS TO F.CAPTL.INCREASE.CUS,K.CAPTL.INCREASE.CUS
      REPEAT
*
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.CAPTL.INCREASE.CUS.11.2')
********
   END
