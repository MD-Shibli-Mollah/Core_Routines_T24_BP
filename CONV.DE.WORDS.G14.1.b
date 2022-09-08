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

* Version 3 31/05/01  GLOBUS Release No. G14.0.00 03/07/03
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
      SUBROUTINE CONV.DE.WORDS.G14.1(DE.WORDS.ID,WRD.REC,DE.WORDS.FILE)
*
* Conversion routine to update the new UNIT.TRILLION field
* with value TRILLION.
*
$INSERT I_EQUATE
$INSERT I_COMMON
*
      IF DE.WORDS.ID EQ "GB" THEN
         WRD.REC<9> = "TRILLION":VM:"TRILLION"
      END
*
      RETURN
*
   END
