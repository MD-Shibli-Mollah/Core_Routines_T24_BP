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
* <Rating>-17</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.OverrideProcessing
      SUBROUTINE CONV.OVERRIDE.R07( THE.ID, THE.REC, THE.FILE) 
*-----------------------------------------------------------------------------
* This routine converts the existing override record to:
*
*  o Have a multivalue set of MESSAGE, TYPE, CHANNEL and APROVE.METHOD. 
*    Previosly it only had MESSAGE.
*
*  o Deletes any values previosly stored in DATA.TYPE, DATA.DEFINTION and TYPE fields. 
*    AS they don't exist anymore.
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
      THE.OVE.ID = ''
      CALL EB.GET.OVE.ERR.ID( "OVERRIDE" , THE.OVE.ID)
      THE.REC<12> = THE.OVE.ID
* Set the obsolete fields to nothing
      THE.REC<13> = ''  ; *EB.OR.DATA.DEFINITION      
* Check if the TYPE field is set to 'WARNING' on the override.
* If so then populate the TYPE field in the new multivalue set added.
      IF THE.REC<46> # '' THEN ; *EB.OR.TYPE
         THE.REC<2> = "Warning"            
         THE.REC<46> = ''
      END      

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
