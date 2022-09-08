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

* Version 3 25/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
      SUBROUTINE CONV.SC.PRICE.CHANGE.12.0(RELEASE.NO, R.RECORD, FN.FILE)

***********************************************************************
* 21/10/02 - BG_100002439
*            This Subroutine is written with the intention to update
*            SC.PRICE.CHANGE.CON separately as the conversion at HSJ
*            ran for about 35 hours as they had 3 million records
*            SC.PRICE.CHANGE.CON is updated as a FILE.ROUTINE in
*            CONV.SC.PRICE.CHANGE.12.0
*
**********************************************************************
*
$INSERT I_EQUATE
$INSERT I_COMMON

* 19/03/2000 - GB0100595

* A new field TIME.CHANGE has been added to the file SC.PRICE.CHANGE
* All the new fields need to be populated with a time value 00:01
* because the time entries have to be in ascending order and the
* fields need to have some standard data in them for that.

      IF R.RECORD<3> EQ '' THEN
         R.RECORD<3> = '00:01'
      END
      RETURN

   END
