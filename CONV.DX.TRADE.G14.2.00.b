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
    $PACKAGE DX.Trade
SUBROUTINE CONV.DX.TRADE.G14.2.00(DX.TRADE.ID,R.DX.TRADE,F.DX.TRADE)
* Conversion routine to clear VARIATION.MARGIN field in DX.TRADE file.
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
     EQUATE DX.TRA.VARIATION.MARGIN TO "29"
     R.DX.TRADE<DX.TRA.VARIATION.MARGIN> = ""

     RETURN
 END
