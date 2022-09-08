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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.R7.200609(ID.SEC.ACC.MASTER, R.SEC.ACC.MASTER, FN.SEC.ACC.MASTER)
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 08/06/06 - EN_10002965
*            Created to convert securities master record for trade dated
*            balance check.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Initialise
      GOSUB INITIALISATION

* Clear fields
      GOSUB CLEAR.FIELDS

      RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

      RETURN

*-----------------------------------------------------------------------------

*** <region name= CLEAR.FIELDS>
CLEAR.FIELDS:
*** <desc>Clear fields</desc>

* Clear old CREDIT.CHECK and AVAILABLE.BAL.UPD fields
   R.SEC.ACC.MASTER<105> = ""
   R.SEC.ACC.MASTER<106> = ""

	RETURN
*** </region>
   END
