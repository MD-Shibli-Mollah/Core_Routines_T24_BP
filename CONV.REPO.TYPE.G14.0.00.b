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
    $PACKAGE RP.Config
      SUBROUTINE CONV.REPO.TYPE.G14.0.00(REPO.TYPE.ID, R.REPO.TYPE, F.REPO.TYPE)

*********************************************************************
*
* Field RESERVED5 has been replaced with DEFAULT.PRICE. Hence,
* all the REPO.TYPE record will be selected and that the field
* DEFAULT.PRICE will be set to 'YES'.
*
**********************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE


      RP.TYP.DEFAULT.PRICE = 10

      R.REPO.TYPE<RP.TYP.DEFAULT.PRICE> = 'YES'

      RETURN

***********************************************************************
   END
