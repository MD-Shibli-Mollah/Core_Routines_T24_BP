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

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
      SUBROUTINE CONV.EXCHRATES(IN.F.ARR, IN.ID.ARR, RET.IDS, RET.FNAME)
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_AM.VAL.COMMON
$INSERT I_F.SC.VALUATION.EXTRACT
      FN.SC.VEH.CONCAT = 'F.SC.VALUATION.EXTRACT.CONCAT'
      FV.SC.VEH.CONCAT = ''
      FN.SC.VEH = 'F.SC.VALUATION.EXTRACT'
      FV.SC.VEH = ''
      CALL OPF(FN.SC.VEH, FV.SC.VEH)
      CALL OPF(FN.SC.VEH.CONCAT, FV.SC.VEH.CONCAT)
      LIST.CCY = ''
      RET.SC.VEH.IDS = ''
      CALL F.READ(FN.SC.VEH.CONCAT, AM$ID, RET.SC.VEH.IDS,
         FV.SC.VEH.CONCAT, READ.ERR1)
      SC.VEH.TOT = COUNT(RET.SC.VEH.IDS, FM)+1
      FOR SC.VEH.CNT = 1 TO SC.VEH.TOT
         CALL F.READ(FN.SC.VEH, RET.SC.VEH.IDS<SC.VEH.CNT>, REC.SC.VEH,
            FV.SC.VEH, READ.ERR2)
         IF LIST.CCY = '' THEN
            LIST.CCY = REC.SC.VEH<SC.VEX.SECURITY.CCY>
         END ELSE
            LOCATE REC.SC.VEH<SC.VEX.SECURITY.CCY> IN LIST.CCY<1> SETTING CCY.POS ELSE
               LIST.CCY := FM:REC.SC.VEH<SC.VEX.SECURITY.CCY>
            END
         END
      NEXT SC.VEH.TOT
      RET.IDS = LIST.CCY
      RET.FNAME = 'CURRENCY'
      RETURN
   END
