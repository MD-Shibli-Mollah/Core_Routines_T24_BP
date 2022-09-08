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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.DX.PARAMETER.200512(DX.PARAMETER.ID,R.DX.PARAMETER,FN.DX.PARAMETER)
*-----------------------------------------------------------------------------
* Program Description : This routine clears and sets data in replaced fields
*                       within DX.PARAMETER:
*
*                       FLDNO  OLDNAME             NEWNAME
*                       -----  -------             -------
*
*                       41     HLD.EOE.HIST.DAYS   HLD.WORK.HIST.DAYS
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE
      GOSUB EQUATE.FIELDS
      GOSUB RESET.FIELDS

      RETURN

*-----------------------------------------------------------------------------
INITIALISE:

      RETURN
      
*-----------------------------------------------------------------------------
EQUATE.FIELDS:

      EQUATE HLD.WORK.HIST.DAYS TO 41

      RETURN

*-----------------------------------------------------------------------------
RESET.FIELDS:

      R.DX.PARAMETER<HLD.WORK.HIST.DAYS> = 30 ; * Defaulted to 30

      RETURN

*-----------------------------------------------------------------------------
*
   END
