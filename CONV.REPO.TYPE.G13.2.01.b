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

* Version 3 02/06/00  GLOBUS Release No. G13.2.01 27/02/03
*-----------------------------------------------------------------------------
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Config
      SUBROUTINE CONV.REPO.TYPE.G13.2.01(R.REPO.TYPE.ID, R.REPO.TYPE, F.REPO.TYPE)
*-----------------------------------------------------------------------------
* Conversion routine that will update the field DEAL.TYPE with
* "CLASSIC" for each REPO.TYPE record
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 27/02/03 - GLOBUS_EN_10001646
*            To set DEAL.TYPE field to 'CLASSIC' in REPO.TYPE
*            for REPO.TYPEs present in earlier releases,
*            Created this routine
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB PROCESS.RECORDS

      RETURN

*-----------------------------------------------------------------------------
* S U B R O U T I N E S
*-----------------------------------------------------------------------------
INITIALISE:

      DEAL.TYPE = 9

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORDS:
* For each record, perform the conversion by entering "CLASSIC"
* in the field DEAL.TYPE

      IF R.REPO.TYPE<DEAL.TYPE> = 'YES' THEN
         R.REPO.TYPE<DEAL.TYPE> = "OPEN"
      END ELSE
         R.REPO.TYPE<DEAL.TYPE> = "CLASSIC"
      END
      RETURN

*-----------------------------------------------------------------------------
   END
