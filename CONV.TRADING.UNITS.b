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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
* Version 1 09/03/00  GLOBUS Release No. 200508 29/07/05

    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.TRADING.UNITS(RELEASE.NO, R.RECORD, FN.FILE)

* 24/02/2000 - GB0000223

* If the value in TRADING UNITS field of SECURITY MASTER records needs
* to be restricted to 3 decimal places, run this subroutine.

$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.SECURITY.MASTER

      IF R.RECORD<40> EQ 0 THEN
         R.RECORD<40> = 0.001
      END

      RETURN

   END
