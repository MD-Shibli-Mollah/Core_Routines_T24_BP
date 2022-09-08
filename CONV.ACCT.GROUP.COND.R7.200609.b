* @ValidationCode : MjotNTE3NDE3OTM0OmNwMTI1MjoxNTY3NTk2MTgyMjIwOnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4xOi0xOi0x
* @ValidationInfo : Timestamp         : 04 Sep 2019 16:53:02
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.Config
SUBROUTINE CONV.ACCT.GROUP.COND.R7.200609(ID.ACCT.GROUP.CONDITION, R.ACCT.GROUP.CONDITION, FN.ACCT.GROUP.CONDITION)
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 08/06/06 - EN_10002965
*            Created to convert account group condition record for trade
*            dated balance check.
*
* 05/08/19 - Enhancement 3265522 / Task 3265523
*            Moved routine from ST_ChargeConfig to AC_Config.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.PARAMETER

* Initialise
    GOSUB INITIALISATION

* Update credit check field
    GOSUB UPDATE.CREDIT.CHECK

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
    VDATE.BAL.CHK = R.ACCOUNT.PARAMETER<67>
    CREDIT.CHECK = R.ACCT.GROUP.CONDITION<48>
    IF VDATE.BAL.CHK = "YES" AND (CREDIT.CHECK = "WORKING" OR CREDIT.CHECK = "") THEN
        R.ACCT.GROUP.CONDITION<48> = "FORWARD"
    END

RETURN
*** </region>
END
