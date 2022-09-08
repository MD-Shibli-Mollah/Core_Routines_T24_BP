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
    $PACKAGE FD.Config
      SUBROUTINE CONV.FD.MATURITY.DATES.G13(RELEASE.NO,R.RECORD,FN.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.FD.MATURITY.DATES

*GLOBUS_EN_10000600/GLOBUS_EN_10000629
*
*This subroutine is used to convert multi value field DAYS
*in sub value fields.

      CONVERT VM TO SM IN R.RECORD<FD.MD.DAYS>

   END
