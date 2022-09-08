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
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Config
      SUBROUTINE CONV.ACCT.PARAMETER.R7.200609(ID.ACCT.PARAMETER, R.ACCT.PARAMETER, FN.ACCT.PARAMETER)
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 08/06/06 - EN_10002965
*            Created to convert account parameter record for trade dated
*            balance check.
*
* 25/07/06 - BG_100011658
*            Fixed bug where conversion didn't work correctly when
*            VDATE.BAL.CHK wasn't set.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Initialise
      GOSUB INITIALISATION

* Update credit check field
      GOSUB UPDATE.CREDIT.CHECK

* Clear value date balance check
      GOSUB CLEAR.VDATE.BAL.CHK

      RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

      RETURN


*-----------------------------------------------------------------------------

*** <region name= UPDATE.CREDIT.CHECK>
UPDATE.CREDIT.CHECK:
*** <desc>Update credit check field</desc>

* Determine whether credit check field should be updated
* and updated it if necessary
      VDATE.BAL.CHK = R.ACCT.PARAMETER<67>
      CREDIT.CHECK = R.ACCT.PARAMETER<68>
      IF VDATE.BAL.CHK = "YES" AND (CREDIT.CHECK = "WORKING" OR CREDIT.CHECK = "") THEN
         R.ACCT.PARAMETER<68> = "FORWARD"
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CLEAR.VDATE.BAL.CHK>
CLEAR.VDATE.BAL.CHK:
*** <desc>Clear value date balance check</desc>

* Clear the value date balance check field
      R.ACCT.PARAMETER<67> = ""

      RETURN
*** </region>
   END
