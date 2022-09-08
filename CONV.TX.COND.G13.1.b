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
    $PACKAGE TX.Contract
      SUBROUTINE CONV.TX.COND.G13.1(YFILE,YREC,YID)
************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
************************************************************************
* 24/10/02 - BG_100002490
*                      New conversion routine for TX.CONDITION
************************************************************************
      MSG.NO = YREC<11>
      YREC<11> = ''
      YREC<16> = MSG.NO
      RETURN
   END
