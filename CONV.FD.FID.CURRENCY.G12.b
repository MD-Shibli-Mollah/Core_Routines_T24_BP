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
      SUBROUTINE CONV.FD.FID.CURRENCY.G12(RELEASE.NO,R.RECORD,FN.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      * New field MIN.AMT (index 7) equal to the old field MINIMUM.AMT (index 2)
      R.RECORD<7> = R.RECORD<2>

      * New field MULT.AMT (index 4) equal to the old field MULTIPLE.AMT (index 3)
      R.RECORD<4> = R.RECORD<3>

      * Old fields are cleared
      R.RECORD<2> = ""
      R.RECORD<3> = ""

      * Multivalue fields
      R.RECORD<2> = "FIXED":VM:"NOTICE"
      R.RECORD<3> = VM
      R.RECORD<4> = R.RECORD<4>:VM:R.RECORD<4>
      R.RECORD<5> = VM
      R.RECORD<6> = VM
      R.RECORD<7> = R.RECORD<7>:VM:R.RECORD<7>
      RETURN
   END
