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

* Version 1 10/09/01  GLOBUS Release No. G12.0.02 13/09/01
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TXN.G12002

$INSERT I_COMMON
$INSERT I_EQUATE

      COMO.NAME = "CONV.DX.TXN.G12002.":DATE():".":TIME()

      EXECUTE "COMO ON ":COMO.NAME

      CALL SUB.CONV.DX.TXN.G12002("F.DX.TRANSACTION")
      CALL SUB.CONV.DX.TXN.G12002("F.DX.TRANSACTION.HISTORY")
      CALL SUB.CONV.DX.TXN.G12002("F.DX.REVAL.TRANSACTION")
      CALL SUB.CONV.DX.TXN.G12002("F.DX.REVAL.TXN.HIST")
      CALL SUB.CONV.DX.TXN.G12002("F.DX.CO.TRANSACTION")

      EXECUTE "COMO OFF ":COMO.NAME

      RETURN

*================================================================================


* <new subroutines>
   END
