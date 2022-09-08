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
* Conversion routine to append the currency for DX.TRANS.BALANCES ids.

    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TRANS.G13.1(YID,YREC,YFILE)

* 29/01/03 - GLOBUS_BG_100003274
*          - Forward patching from 131DEV

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.CONTRACT.MASTER
$INSERT I_F.DX.TRANS.BALANCES

*********

      FN.DX.CONTRACT.MASTER = "F.DX.CONTRACT.MASTER"
      F.DX.CONTRACT.MASTER = ''
      FN.DX.TRANS.BALANCES = "F.DX.TRANS.BALANCES"
      F.DX.TRANS.BALANCES = ''
      CALL OPF(FN.DX.TRANS.BALANCES,F.DX.TRANS.BALANCES)
      CALL OPF(FN.DX.CONTRACT.MASTER, F.DX.CONTRACT.MASTER)
      CONTRACT.ID = YREC<DX.BAL.CONTRACT>

      CALL F.READ('F.DX.CONTRACT.MASTER',CONTRACT.ID,R.CONTRACT,F.DX.CONTRACT.MASTER,ER)

      IF R.CONTRACT THEN
         CURR = R.CONTRACT<DX.CM.CURRENCY>
      END

      IF YID['.',3,1] EQ '' THEN
         CALL F.DELETE('F.DX.TRANS.BALANCES',YID)
         YID = YID:'.':CURR
      END

      RETURN
   END
