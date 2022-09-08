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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>158</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfConfig
      SUBROUTINE CONV.SAFE.VALUES.9105
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SAFECUSTODY.VALUES RECORDS.
* ALSO ADD NEW FIELDS :-
*  1 XX-BROKER.TYPE
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      BROKER.TYPE = 'BROKER'
      PRINT @(10,10):'CONVERTING SAFECUSTODY.VALUES RECORDS ......PLEASE WAIT'
      F.SAFECUSTODY.VALUES = ''
      YFILE.NAME1 = 'F.SAFECUSTODY.VALUES'
      CALL OPF(YFILE.NAME1,F.SAFECUSTODY.VALUES)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SAFECUSTODY.VALUES$NAU'
      CALL OPF(YFILE.NAME2,F.SAFECUSTODY.VALUES)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SAFECUSTODY.VALUES
      LOOP
         READNEXT K.SAFECUSTODY.VALUES ELSE NULL
      WHILE K.SAFECUSTODY.VALUES DO
         READU R.SAFECUSTODY.VALUES FROM F.SAFECUSTODY.VALUES,K.SAFECUSTODY.VALUES ELSE
            E = 'OPEN ORDER "':K.SAFECUSTODY.VALUES:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SAFECUSTODY.VALUES,FM) + (R.SAFECUSTODY.VALUES # '')
         BR.BROKER.TYPE = ''
         IF NO.OF.FIELDS < 21 THEN
*
*
            INS '' BEFORE R.SAFECUSTODY.VALUES<12>
         END
*
         WRITE R.SAFECUSTODY.VALUES TO F.SAFECUSTODY.VALUES,K.SAFECUSTODY.VALUES
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SAFECUSTODY.VALUES.8912')
********
* END
********
   END
