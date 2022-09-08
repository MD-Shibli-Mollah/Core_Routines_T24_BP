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
      SUBROUTINE CONV.REDEMPTION.DET.8907
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING REDEMPTION.DET RECORDS.
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
      PRINT @(10,10):'CONVERTING REDEMPTION.DET RECORDS ......PLEASE WAIT'
      F.REDEMPTION.DET = ''
      YFILE.NAME1 = 'F.REDEMPTION.DET'
      CALL OPF(YFILE.NAME1,F.REDEMPTION.DET)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.REDEMPTION.DET$NAU'
      CALL OPF(YFILE.NAME2,F.REDEMPTION.DET)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.REDEMPTION.DET$HIS'
      CALL OPF(YFILE.NAME3,F.REDEMPTION.DET)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.REDEMPTION.DET
      LOOP
         READNEXT K.REDEMPTION.DET ELSE NULL
      WHILE K.REDEMPTION.DET DO
         READU R.REDEMPTION.DET FROM F.REDEMPTION.DET,K.REDEMPTION.DET ELSE
            E = 'OPEN ORDER "':K.REDEMPTION.DET:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.REDEMPTION.DET,FM) + (R.REDEMPTION.DET # '')
         IF NO.OF.FIELDS < 31 THEN
            INS '' BEFORE R.REDEMPTION.DET<21>
            INS '' BEFORE R.REDEMPTION.DET<21>
         END
         WRITE R.REDEMPTION.DET TO F.REDEMPTION.DET,K.REDEMPTION.DET
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.REDEMPTION.DET.8907')
********
* END
********
   END
