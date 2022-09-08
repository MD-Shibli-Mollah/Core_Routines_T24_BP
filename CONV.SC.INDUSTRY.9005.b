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
      SUBROUTINE CONV.SC.INDUSTRY.9005
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.INDUSTRY RECORDS.
* ALSO ADD NEW FIELDS :-
* 1.CU.COMM.RATE
* 2 CU.COMM.AMT.LCY
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SC.INDUSTRY RECORDS ......PLEASE WAIT'
      F.SC.INDUSTRY = ''
      YFILE.NAME1 = 'F.SC.INDUSTRY'
      CALL OPF(YFILE.NAME1,F.SC.INDUSTRY)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.INDUSTRY$NAU'
      CALL OPF(YFILE.NAME2,F.SC.INDUSTRY)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.INDUSTRY$HIS'
      CALL OPF(YFILE.NAME3,F.SC.INDUSTRY)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.INDUSTRY
      LOOP
         READNEXT K.SC.INDUSTRY ELSE NULL
      WHILE K.SC.INDUSTRY DO
         READU R.SC.INDUSTRY FROM F.SC.INDUSTRY,K.SC.INDUSTRY ELSE
            E = 'OPEN ORDER "':K.SC.INDUSTRY:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SC.INDUSTRY,FM) + (R.SC.INDUSTRY # '')
         IF NO.OF.FIELDS < 11 THEN
            INS '' BEFORE R.SC.INDUSTRY<2>
         END
         WRITE R.SC.INDUSTRY TO F.SC.INDUSTRY,K.SC.INDUSTRY
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.INDUSTRY.8904')
********
* END
********
   END
