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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
* Conversion Routine for DIARY.
* This program will populate "DEPOSITORY" in field DEP.TYPE for
* all the existing DIARY records.

    $PACKAGE SC.SccEventCapture
SUBROUTINE CONV.DIARY.G13.0(YID,YREC,YFILE)

*-----------------------------------------------------------------
* 13/07/04 - GLOBUS_CI_10021347
*            Field name hardcoded to Field number
*
*-----------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

  NO.OF.DEPS = DCOUNT(YREC<46>,VM)     ;* CI_10021347 S/E
  FOR I = 1 TO NO.OF.DEPS
      YREC<47,I> = "DEPOSITORY"         ;* CI_10021347 S/E
  NEXT I

 RETURN
END
