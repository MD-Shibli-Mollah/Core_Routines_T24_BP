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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TXN.G12100.PATCH

$INSERT I_COMMON
$INSERT I_EQUATE

      COMO.NAME = "CONV.DX.TXN.G12100.PATCH.":DATE():".":TIME()

      EXECUTE "COMO ON ":COMO.NAME

      CALL SUB.CONV.DX.TXN.G12100.PATCH("F.DX.TRADE")

*      CALL SUB.CONV.DX.TXN.G12100.PATCH("F.DX.TRANSACTION.HISTORY","TXN")
*      CALL SUB.CONV.DX.TXN.G12100.PATCH("F.DX.REVAL.TRANSACTION","TXN")
*      CALL SUB.CONV.DX.TXN.G12100.PATCH("F.DX.REVAL.TXN.HIST","TXN")
*      CALL SUB.CONV.DX.TXN.G12100.PATCH("F.DX.CO.TRANSACTION","TXN")

      EXECUTE "COMO OFF ":COMO.NAME

      RETURN

*================================================================================


* <new subroutines>
   END
