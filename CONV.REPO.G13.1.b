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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
      SUBROUTINE CONV.REPO.G13.1(R.REPO.ID, R.REPO, F.REPO)
*-----------------------------------------------------------------------------
* Conversion routine that will update the field CALCULATION.LINK with "NO" for each
* REPO record
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 06/09/02 - GLOBUS_EN_10000956 - REPO Price Fields
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

      CALCULATION.LINK = 60

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORDS:
* For each record, perform the conversion by entering "NO" in the field CALCULATION.LINK

      IF R.REPO<CALCULATION.LINK> = '' THEN
         R.REPO<CALCULATION.LINK> = "NO"
      END

      RETURN

*-----------------------------------------------------------------------------
   END
