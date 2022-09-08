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
      SUBROUTINE CONV.LETTER.OF.CREDIT.G12.1(LC.ID,Y.LCREC,Y.FILE)
*Conversion routine to populate the value "YES" in the new field
*'LIMIT.WITH.PROV' in LC.

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU TF.LC.LIMIT.WITH.PROV TO 203

      Y.LCREC<TF.LC.LIMIT.WITH.PROV> = "YES"
   END
