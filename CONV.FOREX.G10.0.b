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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.Contract
      SUBROUTINE CONV.FOREX.G10.0(RELEASE.NO,R.RECORD,FN.FILE)

$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.FOREX
*
      DAY.BASIS = FIELD(R.RECORD<FX.INT.BASIS.SOLD>,' ',1)
      R.RECORD<FX.INT.BASIS.SOLD> = DAY.BASIS
*
      DAY.BASIS = FIELD(R.RECORD<FX.INT.BASIS.BOUGHT>,' ',1)
      R.RECORD<FX.INT.BASIS.BOUGHT> = DAY.BASIS
*
      RETURN
*
   END
