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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctBlocking
      SUBROUTINE CONV.SC.BLOCK.SEC.POS.G12.2.31(ID.BLOCK,R.BLOCK,FN.BLOCK)
*-----------------------------------------------------------------------------
*Conversion routine that will update the field PRODUCT with "SC" for each
*SC.BLOCK.SEC.POS record
*-----------------------------------------------------------------------------
* Modification History :
*
* 20/03/02 - GLOBUS_EN_10000522
*            Created this routine
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------
      GOSUB INITIALISE

      GOSUB PROCESS.RECORDS

      RETURN
*-----------------------------------------------------------------------------
INITIALISE:

      PRODUCT.NO = 17

      RETURN
*-----------------------------------------------------------------------------
*For each record, perform the conversion by entering "SC" in the field PRODUCT
PROCESS.RECORDS:

      IF NOT(R.BLOCK<PRODUCT.NO>) THEN
         R.BLOCK<PRODUCT.NO> = "SC"
      END

      RETURN        
*-----------------------------------------------------------------------------
   END
