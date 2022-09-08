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

* Version 2 06/06/01  GLOBUS Release No. 200509 30/08/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Foundation
      SUBROUTINE CONV.LC.G10 (RELEASE.NO, R.RECORD, FN.FILE)

$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.LETTER.OF.CREDIT
*
      DAY.BASIS = FIELD(R.RECORD<TF.LC.DAY.BASIS>,' ',1)
      R.RECORD<TF.LC.DAY.BASIS> = DAY.BASIS
*
      RETURN
*
   END
