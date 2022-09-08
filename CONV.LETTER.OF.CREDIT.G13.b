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
    $PACKAGE LC.Contract
      SUBROUTINE CONV.LETTER.OF.CREDIT.G13(Y.LCID,Y.LCREC,YFILE)
*
* Modifications
*
* 04/02/04 - BG_100006151
*            T parameter need not be changed here.
*
$INSERT I_COMMON
$INSERT I_EQUATE

      EQUATE TF.LC.PREADV.LIMIT TO 205

      Y.LCREC<TF.LC.PREADV.LIMIT> = "NO"

      RETURN
   END
