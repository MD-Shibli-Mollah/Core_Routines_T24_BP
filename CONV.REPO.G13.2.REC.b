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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
      SUBROUTINE CONV.REPO.G13.2.REC(R.REPO.ID, R.REPO, F.REPO)
*-----------------------------------------------------------------------------
* This will be run for each REPO record & will clear the old PRICE.1 field & copy the PRICE.2
* field to the multi-value FWD.PRICE
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 09/12/02 - GLOBUS_EN_10001532 - REPO Delivery Vs Payment (Additional Enhancements)
*            Clear the old PRICE.1 field & move the old PRICE.2 field to the new FWD.PRICE field.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB PROCESS.RECORD

      RETURN

*-----------------------------------------------------------------------------
* S U B R O U T I N E S
*-----------------------------------------------------------------------------
INITIALISE:
* Set up the field numbers for the conversion

      RP.NEW.SEC.CODE = 18
      RP.FWD.PRICE = 32
      RP.OLD.SEC.CODE = 49
      RP.OLD.FWD.PRICE = 62
      RP.PRICE.1 = 78
      RP.PRICE.2 = 79

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORD:
* This will rebuild the data in the multi-value set

      IF R.REPO<RP.PRICE.2> # '' THEN
         PRICE.2 = R.REPO<RP.PRICE.2>
*        Set the FWD.PRICE field up
         MV.POS = 0
         TEMP.ARRAY = R.REPO<RP.NEW.SEC.CODE>
         LOOP
            REMOVE SECURITY FROM TEMP.ARRAY SETTING MORE.SECURITIES
         WHILE SECURITY:MORE.SECURITIES DO
            MV.POS += 1
            R.REPO<RP.FWD.PRICE, MV.POS> = PRICE.2
         REPEAT

*        Set the OLD.FWD.PRICE field up
         MV.POS = 0
         TEMP.ARRAY = R.REPO<RP.OLD.SEC.CODE>
         LOOP
            REMOVE SECURITY FROM TEMP.ARRAY SETTING MORE.SECURITIES
         WHILE SECURITY:MORE.SECURITIES DO
            MV.POS += 1
            R.REPO<RP.OLD.FWD.PRICE, MV.POS> = PRICE.2
         REPEAT
      END

*     Clear the fields that will no longer be used
      R.REPO<RP.PRICE.1> = ''
      R.REPO<RP.PRICE.2> = ''

      RETURN

*-----------------------------------------------------------------------------
   END
