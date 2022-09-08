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

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
      SUBROUTINE CONV.REPO.POSITION.G13.1.REC(R.REPO.POSITION.ID, R.REPO.POSITION, F.REPO.POSITION)
*-----------------------------------------------------------------------------
* This will be run for each REPO.POSITION record & will update the multi-value set containing the
* NOMINAL, CLEAN.PRICE & CONTRACT.ID
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 08/10/02 - GLOBUS_BG_100002318 - REPO Price Fields
*            Create this program.
*
* 24/10/02 - GLOBUS_BG_100002503 - REPO Price Fields
*            Has used insert references instead of field numbers.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

$INSERT I_CONV.REPO.G13.1
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB PROCESS.RECORD

      RETURN

*-----------------------------------------------------------------------------
* S U B R O U T I N E S
*-----------------------------------------------------------------------------
INITIALISE:

      RP.POS.COST.PRICE = 12             ; * BG_100002503 S
      RP.POS.NOMINAL = 13
      RP.POS.CONTRACT.ID = 14            ; * BG_100002503 E

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORD:
* This will rebuild the data in the multi-value set

      LOCATE R.REPO.POSITION.ID IN RP.CONV.ARRAY<1, 1> SETTING MV.POS THEN
         R.REPO.POSITION<RP.POS.COST.PRICE> = RAISE(RP.CONV.ARRAY<3, MV.POS>)
         R.REPO.POSITION<RP.POS.NOMINAL> = RAISE(RP.CONV.ARRAY<4, MV.POS>)
         R.REPO.POSITION<RP.POS.CONTRACT.ID> = RAISE(RP.CONV.ARRAY<2, MV.POS>)
      END

      RETURN

*-----------------------------------------------------------------------------
   END
