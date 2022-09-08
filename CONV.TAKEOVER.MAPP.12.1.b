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
* <Rating>169</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.TAKEOVER.MAPP.12.1
*
*
**************************************************************
** Add new Field  - ALLOW.NOINPUT
*************************************************************
* 23/08/02 - GLOBUS_EN_10000971
*          Conversion Of all Error Messages to Error Codes
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING TAKEOVER.MAPPING RECORDS ......PLEASE WAIT'
      F.TAKEOVER.MAPPING = ''
      YFILE.NAME1 = 'F.TAKEOVER.MAPPING'
      CALL OPF(YFILE.NAME1,F.TAKEOVER.MAPPING)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.TAKEOVER.MAPPING
      LOOP
         READNEXT K.TAKEOVER.MAPPING ELSE NULL
      WHILE K.TAKEOVER.MAPPING DO
         READU R.TAKEOVER.MAPPING FROM F.TAKEOVER.MAPPING,K.TAKEOVER.MAPPING ELSE
            E = 'EB.RTN.SEC.TRADE.MISING.FILE.1':FM:K.TAKEOVER.MAPPING
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.TAKEOVER.MAPPING,FM) + (R.TAKEOVER.MAPPING # '')
         IF NO.OF.FIELDS < 26 THEN
            INS '' BEFORE R.TAKEOVER.MAPPING<4>
         END
         WRITE R.TAKEOVER.MAPPING TO F.TAKEOVER.MAPPING,K.TAKEOVER.MAPPING
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.TAKEOVER.MAPPING.9002')
   END
