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
      SUBROUTINE CONV.STD.COUPON.8911
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.STD.COUPON RECORDS.
* ALSO ADD NEW FIELDS :-
*  DIV.TYPE.SHARE
*  SEC.CR.TR.CODE.CPN
*  SEC.DR.TR.CODE.DIV
*  SEC.CR.TR.CODE.DIV
*
* CHANGE FIELD
*  DIVIDEND.TYPE TO DIV.TYPE.BOND
*  SEC.DR.TRANS.CODE TO SEC.DR.TR.CODE.DPN
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SC.STD.COUPON RECORDS ......PLEASE WAIT'
      F.SC.STD.COUPON = ''
      YFILE.NAME1 = 'F.SC.STD.COUPON'
      CALL OPF(YFILE.NAME1,F.SC.STD.COUPON)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.STD.COUPON$NAU'
      CALL OPF(YFILE.NAME2,F.SC.STD.COUPON)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.STD.COUPON$HIS'
      CALL OPF(YFILE.NAME3,F.SC.STD.COUPON)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.STD.COUPON
      LOOP
         READNEXT K.SC.STD.COUPON ELSE NULL
      WHILE K.SC.STD.COUPON DO
         READU R.SC.STD.COUPON FROM F.SC.STD.COUPON,K.SC.STD.COUPON ELSE
            E = 'OPEN ORDER "':K.SC.STD.COUPON:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SC.STD.COUPON,FM) + (R.SC.STD.COUPON # '')
*
         IF NO.OF.FIELDS < 32 THEN
            INS '' BEFORE R.SC.STD.COUPON<6>
            INS '' BEFORE R.SC.STD.COUPON<5>
            INS '' BEFORE R.SC.STD.COUPON<2>
*
            R.SC.STD.COUPON<2> = R.SC.STD.COUPON<1>
            R.SC.STD.COUPON<6> = R.SC.STD.COUPON<5>
            R.SC.STD.COUPON<8> = R.SC.STD.COUPON<7>
         END
*
         WRITE R.SC.STD.COUPON TO F.SC.STD.COUPON,K.SC.STD.COUPON
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.STD.COUPON.8911')
********
* END
********
   END
