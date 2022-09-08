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

* Version n dd/mm/yy  GLOBUS Release No. G13.0.00 05/07/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.BulkOrder
      SUBROUTINE CONV.FX.BULK.ORDER.G13.1(YID,YREC,YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

$INSERT I_F.FX.BULK.ORDER
*
* Conversion routine for FX.BULK.ORDER
*

      YREC<FX.BULK.OUR.ACCOUNT.PAY> = ''
      RETURN

   END
