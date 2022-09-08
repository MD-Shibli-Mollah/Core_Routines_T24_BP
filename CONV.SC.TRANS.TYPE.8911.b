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
    $PACKAGE SC.Config
      SUBROUTINE CONV.SC.TRANS.TYPE.8911
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.TRANS.TYPE RECORDS.
* ALSO ADD NEW FIELDS :-
* 1.CU.COMM.RATE
* 2 CU.COMM.AMT.LCY
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SC.TRANS.TYPE RECORDS ......PLEASE WAIT'
      F.SC.TRANS.TYPE = ''
      YFILE.NAME1 = 'F.SC.TRANS.TYPE'
      CALL OPF(YFILE.NAME1,F.SC.TRANS.TYPE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.TRANS.TYPE$NAU'
      CALL OPF(YFILE.NAME2,F.SC.TRANS.TYPE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.TRANS.TYPE$HIS'
      CALL OPF(YFILE.NAME3,F.SC.TRANS.TYPE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.TRANS.TYPE
      LOOP
         READNEXT K.SC.TRANS.TYPE ELSE NULL
      WHILE K.SC.TRANS.TYPE DO
         READU R.SC.TRANS.TYPE FROM F.SC.TRANS.TYPE,K.SC.TRANS.TYPE ELSE
            E = 'OPEN ORDER "':K.SC.TRANS.TYPE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SC.TRANS.TYPE,FM) + (R.SC.TRANS.TYPE # '')
         IF NO.OF.FIELDS < 17 THEN
            INS '' BEFORE R.SC.TRANS.TYPE<5>
            INS '' BEFORE R.SC.TRANS.TYPE<5>
            INS '' BEFORE R.SC.TRANS.TYPE<5>
            INS '' BEFORE R.SC.TRANS.TYPE<5>
*
            R.SC.TRANS.TYPE<5> = 22999
            R.SC.TRANS.TYPE<6> = 22999
            R.SC.TRANS.TYPE<7> = 22999
            R.SC.TRANS.TYPE<8> = 22999
         END
         WRITE R.SC.TRANS.TYPE TO F.SC.TRANS.TYPE,K.SC.TRANS.TYPE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.TRANS.TYPE.8911')
********
* END
********
   END
