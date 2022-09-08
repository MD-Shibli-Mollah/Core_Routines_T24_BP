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

* Version 1 29/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FD.Config
      SUBROUTINE CONV.FD.PARAMETER.G12(RELEASE.NO,R.RECORD,FN.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      * Misc. fields
      FOR IDX = 43 TO 17
         R.RECORD<IDX> = R.RECORD<IDX-5>
      NEXT IDX

      * Reserved fields
      FOR IDX = 16 TO 12
         R.RECORD<IDX> = ""
      NEXT IDX

      * Default categories for deposit and placement
      FOR IDX = 11 TO 5
         THE.VALUE = R.RECORD<IDX-2>
         R.RECORD<IDX> = THE.VALUE
      NEXT IDX

      * Default value for FID.SUBTYPE and DEF.SUBTYPE field
      DEFAULT.VALUE = ""

      NB.TYPE = DCOUNT(R.RECORD<1>, VM)
      FOR IDX = 1 TO NB.TYPE
         BEGIN CASE
            CASE IDX = 1
               DEFAULT.VALUE = VM
            CASE IDX <> NB.TYPE
               DEFAULT.VALUE = DEFAULT.VALUE:"":VM
            CASE IDX = NB.TYPE
               DEFAULT.VALUE = DEFAULT.VALUE:""
         END CASE
      NEXT IDX

      R.RECORD<4> = DEFAULT.VALUE
      R.RECORD<3> = DEFAULT.VALUE

      RETURN
   END
