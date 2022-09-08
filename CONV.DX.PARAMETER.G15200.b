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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.DX.PARAMETER.G15200(ID.DX.PARAMETER,R.DX.PARAMETER,FN.DX.PARAMETER)
*-----------------------------------------------------------------------------
* Program Description
* This routine clearsdown a selection of fields that have become reserved
* fields as part of EN_10002314
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      R.DX.PARAMETER<7> = ""
      R.DX.PARAMETER<12> = ""
      R.DX.PARAMETER<13> = ""
      R.DX.PARAMETER<19> = ""
      R.DX.PARAMETER<20> = ""
      R.DX.PARAMETER<22> = ""
      R.DX.PARAMETER<27> = ""
      R.DX.PARAMETER<28> = ""
      R.DX.PARAMETER<29> = ""
      R.DX.PARAMETER<30> = ""
      R.DX.PARAMETER<31> = ""
      R.DX.PARAMETER<32> = ""
      R.DX.PARAMETER<33> = ""
      R.DX.PARAMETER<34> = ""
      R.DX.PARAMETER<35> = ""
      R.DX.PARAMETER<36> = ""
      R.DX.PARAMETER<50> = ""

      RETURN

*-----------------------------------------------------------------------------
INITIALISE:

      RETURN

*-----------------------------------------------------------------------------
*
   END

