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
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.DX.PARAMETER.G14.0.01(DX.PARAMETER.ID,R.DX.PARAMETER,F.DX.PARAMETER)
* Conversion routine to clear DX.PAR.ORTR.OV.RPR field
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.PARAMETER

      R.DX.PARAMETER<DX.PAR.ORTR.OV.RPR> = ""

      RETURN
   END
