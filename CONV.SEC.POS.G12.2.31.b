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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
      SUBROUTINE CONV.SEC.POS.G12.2.31(ID.SP,R.SP,FN.SP)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/06/02 - GLOBUS_EN_10000522 COVER CALL OPTION
*            Created this routine for existing SECURITY.POSITION records that
*            have blocked amounts. If there is an amount blocked, then the
*            record will have a PRODUCT field populated with "SC" and AMT.BLOCKED
*            field equal populated with the amount blocked inserted in the record.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB PROCESS.RECORDS
      RETURN
*-----------------------------------------------------------------------------
INITIALISE:

      NOM.AMT.BLOCKED = 36
      PRODUCT = 61
      AMT.BLOCKED = 62
      PRODUCT.VALUE = "SC"

      RETURN
*-----------------------------------------------------------------------------
PROCESS.RECORDS:

      IF R.SP<NOM.AMT.BLOCKED> AND R.SP<PRODUCT> = "" AND R.SP<AMT.BLOCKED> = "" THEN
         R.SP<PRODUCT> = PRODUCT.VALUE
         R.SP<AMT.BLOCKED> = R.SP<NOM.AMT.BLOCKED>
      END

      RETURN
*-----------------------------------------------------------------------------
   END
