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
* <Rating>158</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvValuationUpdates
      SUBROUTINE CONV.SC.VALS.9207
*
*     Last updated by DEV (ANDREAS) at 09:49:41 on 08/05/92
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SAFECUSTODY.VALUES RECORDS.
*
* AK - 05/08/92.
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SAFECUSTODY.VALUES RECORDS ......PLEASE WAIT'
      F.SCV.FILE = ''
      YFILE.NAME1 = 'F.SAFECUSTODY.VALUES'
      CALL OPF(YFILE.NAME1,F.SCV.FILE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SAFECUSTODY.VALUES$NAU'
      CALL OPF(YFILE.NAME2,F.SCV.FILE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SCV.FILE
      LOOP
         READNEXT K.SCV.FILE ELSE NULL
      WHILE K.SCV.FILE DO
         READU R.SCV.FILE FROM F.SCV.FILE,K.SCV.FILE ELSE
            E = 'SAFECUSTODY VALUES "':K.SCV.FILE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.FLDS = COUNT(R.SCV.FILE,@FM)+1
         IF NO.FLDS LT 24 THEN
            INS '' BEFORE R.SCV.FILE<13>
            INS '' BEFORE R.SCV.FILE<13>
            INS '' BEFORE R.SCV.FILE<10>
         END
         WRITE R.SCV.FILE TO F.SCV.FILE,K.SCV.FILE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.OPN.ORD.8901')
********
* END
********
   END
