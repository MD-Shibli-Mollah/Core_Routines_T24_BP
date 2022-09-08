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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ErrorProcessing
      SUBROUTINE CONV.EB.ERROR.R07( THE.ID, THE.REC, THE.FILE)  
*-----------------------------------------------------------------------------
* This routine converts the record so that it now has
* a unique number code per eb.error record.
* 
*-----------------------------------------------------------------------------
* Modification History :
*
* 28/08/08 - CI_10057502
*            Multi-language error messages are stored as multi-value error
*            messages after conversion.
*            HD Ref: HD0820339
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE
      THE.FLD = THE.REC<1>                              ;* for converting mutli-values as sub-values
      CONVERT VM TO SM IN THE.FLD                       ;* since fields are converted from multi-value to associated multi-value set
      THE.REC<1> = THE.FLD                              ;* storing the converted fields
      * Set the unique code for this override.
      THE.ERR.ID = ''
      CALL EB.GET.OVE.ERR.ID( "ERROR" , THE.ERR.ID)
      THE.REC<11> = THE.ERR.ID

      RETURN

*
*-----------------------------------------------------------------------------
*

INITIALISE:

      RETURN

*
*-----------------------------------------------------------------------------
*
   END
