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

*
*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.DX.PARAMETER.R7.200611(DX.PARAMETER.ID,R.DX.PARAMETER,FN.DX.PARAMETER)
*-----------------------------------------------------------------------------
* This routine clears the field MAINT.DX.PRICE as it has been made obsolete.
*
* Field number is (as of 200611):
*
*     MAINT.DX.PRICE =  14
*-----------------------------------------------------------------------------
* Modification History:
*
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB EQUATE.FIELDS
      GOSUB CLEAR.FIELDS

      RETURN

*-----------------------------------------------------------------------------
EQUATE.FIELDS:

      EQUATE MAINT.DX.PRICE TO 14

      RETURN

*-----------------------------------------------------------------------------
CLEAR.FIELDS:

      R.DX.PARAMETER<MAINT.DX.PRICE> = ''

      RETURN

*-----------------------------------------------------------------------------
   END
