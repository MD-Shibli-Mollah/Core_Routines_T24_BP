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
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.SECURITY.SUPP.9012
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SECURITY.SUPP RECORDS.
* ALSO ADD NEW FIELDS :-
*  CALL.PUT.MATURITY
*  DATE FROM
*  DATE TO
*  MARKET PRICE
*  QUANTITY
*  PROBABILITY
*  DURATION
*  MODIFIED DURATION
*  CONVEXITE
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SECURITY.SUPP RECORDS ......PLEASE WAIT'
      F.SECURITY.SUPP = ''
      YFILE.NAME1 = 'F.SECURITY.SUPP'
      CALL OPF(YFILE.NAME1,F.SECURITY.SUPP)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SECURITY.SUPP$NAU'
      CALL OPF(YFILE.NAME2,F.SECURITY.SUPP)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SECURITY.SUPP$HIS'
      CALL OPF(YFILE.NAME3,F.SECURITY.SUPP)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
*
      SELECT F.SECURITY.SUPP
      LOOP
         READNEXT K.SECURITY.SUPP ELSE NULL
      WHILE K.SECURITY.SUPP DO
         READU R.SECURITY.SUPP FROM F.SECURITY.SUPP,K.SECURITY.SUPP ELSE
            E = 'SECURITY.SUPP "':K.SECURITY.SUPP:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SECURITY.SUPP,FM) + (R.SECURITY.SUPP # '')
         IF NO.OF.FIELDS <= 48 THEN
            INS '' BEFORE R.SECURITY.SUPP<21>
            INS '' BEFORE R.SECURITY.SUPP<21>
            INS '' BEFORE R.SECURITY.SUPP<21>
            INS '' BEFORE R.SECURITY.SUPP<20>
            INS '' BEFORE R.SECURITY.SUPP<20>
            INS '' BEFORE R.SECURITY.SUPP<20>
            INS '' BEFORE R.SECURITY.SUPP<20>
            INS '' BEFORE R.SECURITY.SUPP<20>
            INS '' BEFORE R.SECURITY.SUPP<20>
         END
         WRITE R.SECURITY.SUPP TO F.SECURITY.SUPP,K.SECURITY.SUPP
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SECURITY.SUPP.9012')
********
* END
********
   END
