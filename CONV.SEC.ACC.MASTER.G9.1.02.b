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

* Version 2 22/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.G9.1.02(SAM.ID,SAM.REC,SAM.FILE)

$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.SEC.ACC.MASTER
$INSERT I_F.SC.STD.SEC.TRADE
*
      F.SC.STD.SEC.TRADE = ""
      CALL OPF("F.SC.STD.SEC.TRADE",F.SC.STD.SEC.TRADE)
      R.SC.STD.SEC.TRADE = ""
      CALL F.READ("F.SC.STD.SEC.TRADE",ID.COMPANY,R.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE,ER)
      IF R.SC.STD.SEC.TRADE<SC.SST.SUSPENSE.UNREAL.PR> THEN
         SUSP.FLAG = R.SC.STD.SEC.TRADE<SC.SST.SUSPENSE.UNREAL.PR>
         IF SUSP.FLAG EQ 'NO' THEN
            SAM.REC<SC.SAM.UNREAL.LOSS.PROV> = ''
            SAM.REC<SC.SAM.UNREAL.PROFIT.SUSP> = ''
         END
      END
*
      RETURN
*
   END
