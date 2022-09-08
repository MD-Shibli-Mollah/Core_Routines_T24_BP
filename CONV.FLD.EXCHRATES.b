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
      SUBROUTINE CONV.FLD.EXCHRATES(IN.FNAME, RETURN.VALUE, IN.REC.ID, IN.DATA)
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_AM.VAL.COMMON
$INSERT I_F.SEC.ACC.MASTER
      CALL DBR('SEC.ACC.MASTER':FM:SC.SAM.REFERENCE.CURRENCY,
         AM$ID, REF.CCY)
      CCY.MKT = 1
      BUY.CCY = REF.CCY:VM:AM$STMT.DATE
      SELL.CCY = IN.REC.ID
      BUY.AMT = 1000
      SELL.AMT = ''
      EX.RATE = ''
      CALL EXCHRATE(CCY.MKT, BUY.CCY,BUY.AMT,SELL.CCY,SELL.AMT,
         '',EX.RATE,'','',RET.CODE)
      RETURN.VALUE = EX.RATE
      RETURN
   END
