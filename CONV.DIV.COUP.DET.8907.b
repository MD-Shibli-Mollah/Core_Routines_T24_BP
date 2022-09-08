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
      SUBROUTINE CONV.DIV.COUP.DET.8907
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING DIV.COUP.DET RECORDS.
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
      PRINT @(10,10):'CONVERTING DIV.COUP.DET RECORDS ......PLEASE WAIT'
      F.DIV.COUP.DET = ''
      YFILE.NAME1 = 'F.DIV.COUP.DET'
      CALL OPF(YFILE.NAME1,F.DIV.COUP.DET)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.DIV.COUP.DET$NAU'
      CALL OPF(YFILE.NAME2,F.DIV.COUP.DET)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.DIV.COUP.DET$HIS'
      CALL OPF(YFILE.NAME3,F.DIV.COUP.DET)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.DIV.COUP.DET
      LOOP
         READNEXT K.DIV.COUP.DET ELSE NULL
      WHILE K.DIV.COUP.DET DO
         READU R.DIV.COUP.DET FROM F.DIV.COUP.DET,K.DIV.COUP.DET ELSE
            E = 'OPEN ORDER "':K.DIV.COUP.DET:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.DIV.COUP.DET,FM) + (R.DIV.COUP.DET # '')
         IF NO.OF.FIELDS < 38 THEN
            INS '' BEFORE R.DIV.COUP.DET<28>
            INS '' BEFORE R.DIV.COUP.DET<28>
         END
         WRITE R.DIV.COUP.DET TO F.DIV.COUP.DET,K.DIV.COUP.DET
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
