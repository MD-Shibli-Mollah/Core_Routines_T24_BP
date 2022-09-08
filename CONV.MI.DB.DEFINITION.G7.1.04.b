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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MI.Reports
      SUBROUTINE CONV.MI.DB.DEFINITION.G7.1.04(YID, YREC, YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*
* Simple record routine to lower the multi value group of fields to
* become a sub value set of fields, and to insert the company code
* into the multi value field there
*
      YREC<13,1> = ID.COMPANY

      FOR I = 14 TO 20
         YREC<I> = LOWER(YREC<I>)
      NEXT I
*
* Now complete
*
      RETURN

   END
