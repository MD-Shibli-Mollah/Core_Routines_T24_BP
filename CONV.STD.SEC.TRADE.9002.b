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

* Version 3 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>257</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.STD.SEC.TRADE.9002
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.STD.SEC.TRADE RECORDS.
* ALSO ADD NEW FIELDS :-
*  1 BELGIUM.TAX.FLAG
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.STK.EXC.LOCAL
**************************
      PRINT @(10,10):'CONVERTING SC.STD.SEC.TRADE RECORDS ......PLEASE WAIT'
      F.STK.EXC.LOCAL = ''
      CALL OPF('F.STK.EXC.LOCAL',F.STK.EXC.LOCAL)
      K.LOCAL = ID.COMPANY
      READ R.LOCAL FROM F.STK.EXC.LOCAL,K.LOCAL ELSE
         E = 'STOCK EXC LOCAL RECORD NOT FOUND '
         GOTO FATAL.ERR
      END
      MISC.CATEGORY = R.LOCAL<SE.LCL.MISC.FEES.CAT>
      MISC.DB.CODE = R.LOCAL<SE.LCL.MISC.DB.TRANS.CD>
      MISC.CR.CODE = R.LOCAL<SE.LCL.MISC.CR.TRANS.CD>
      F.SC.STD.SEC.TRADE = ''
      YFILE.NAME1 = 'F.SC.STD.SEC.TRADE'
      CALL OPF(YFILE.NAME1,F.SC.STD.SEC.TRADE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.STD.SEC.TRADE$NAU'
      CALL OPF(YFILE.NAME2,F.SC.STD.SEC.TRADE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.STD.SEC.TRADE$HIS'
      CALL OPF(YFILE.NAME3,F.SC.STD.SEC.TRADE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.STD.SEC.TRADE
      LOOP
         READNEXT K.SC.STD.SEC.TRADE ELSE NULL
      WHILE K.SC.STD.SEC.TRADE DO
         READU R.SC.STD.SEC.TRADE FROM F.SC.STD.SEC.TRADE,K.SC.STD.SEC.TRADE ELSE
            E = 'OPEN ORDER "':K.SC.STD.SEC.TRADE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SC.STD.SEC.TRADE,FM) + (R.SC.STD.SEC.TRADE # '')
         IF NO.OF.FIELDS < 53 THEN
*
            INS '' BEFORE R.SC.STD.SEC.TRADE<44>
*
         END
*
         WRITE R.SC.STD.SEC.TRADE TO F.SC.STD.SEC.TRADE,K.SC.STD.SEC.TRADE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.STD.SEC.TRADE.9002')
********
   END
