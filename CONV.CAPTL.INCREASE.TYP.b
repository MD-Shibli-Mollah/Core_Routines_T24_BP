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
      SUBROUTINE CONV.CAPTL.INCREASE.TYP
*
*     Amended October 1992 as part of PIF GB9200967 to change the field
*     of 'SC.CIT.ADVICE' on file F.CAPTL.INCREASE.TYP.
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING CAPTL.INCREASE.TYP RECORDS.
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.CAPTL.INCREASE.TYP
**************************
      PRINT @(10,10):'CONVERTING CAPTL.INCREASE.TYP RECORDS ..PLEASE WAIT'
*
      F.CAPTL.INCREASE.TYP = ''
      YFILE.NAME1 = 'F.CAPTL.INCREASE.TYP'
      CALL OPF(YFILE.NAME1,F.CAPTL.INCREASE.TYP)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.CAPTL.INCREASE.TYP$NAU'
      CALL OPF(YFILE.NAME2,F.CAPTL.INCREASE.TYP)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.CAPTL.INCREASE.TYP$HIS'
      CALL OPF(YFILE.NAME3,F.CAPTL.INCREASE.TYP)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
*
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.CAPTL.INCREASE.TYP
      LOOP
         READNEXT K.CAPTL.INCREASE.TYP ELSE NULL
      WHILE K.CAPTL.INCREASE.TYP DO
         READU R.CAPTL.INCREASE.TYP FROM F.CAPTL.INCREASE.TYP,K.CAPTL.INCREASE.TYP ELSE
            E = 'RECORD "':K.CAPTL.INCREASE.TYP:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         IF R.CAPTL.INCREASE.TYP<SC.CIT.ADVICE> = 'Y' THEN
            R.CAPTL.INCREASE.TYP<SC.CIT.ADVICE> = '1'
         END
         IF R.CAPTL.INCREASE.TYP<SC.CIT.ADVICE> = 'NO' THEN
            R.CAPTL.INCREASE.TYP<SC.CIT.ADVICE> = ''
         END
*
         WRITE R.CAPTL.INCREASE.TYP TO F.CAPTL.INCREASE.TYP,K.CAPTL.INCREASE.TYP
      REPEAT
*
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.CAPTL.INCREASE.TYP.11.2')
********
   END
