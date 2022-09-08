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

* Version 1 16/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
      SUBROUTINE CONV.PAST.UPDATE.12.0(RELEASE.NO, R.RECORD, FN.FILE)

* 05/03/2000 - GB0100595

* Two new fields, PAST.UPDATE.PRICE and PAST.UPDATE.INCOME have been added
* to the file PRICE.UPDATE. All the new fields need to be populated with a value of 'YES'.

$INSERT I_EQUATE
$INSERT I_COMMON

      IF R.RECORD<4> EQ '' THEN
         R.RECORD<4> = 'YES'
      END

      IF R.RECORD<5> EQ "" THEN
         R.RECORD<5> = "YES"
      END

      RETURN

   END
