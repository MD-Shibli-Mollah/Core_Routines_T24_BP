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
    $PACKAGE AZ.Contract
      SUBROUTINE CONV.AZ.SCHEDULES.G12.1.00(AZ.ID,R.AZ.SCH,F.AZ.SCH)
$INSERT I_COMMON
$INSERT I_EQUATE
* Assume that the TYPE.N & TYPE.I falls on the same date.
      R.AZ.SCH<5> = R.AZ.SCH<3>
      RETURN
   END
