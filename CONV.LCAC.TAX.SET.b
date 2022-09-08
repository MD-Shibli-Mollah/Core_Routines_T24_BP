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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Foundation
      SUBROUTINE CONV.LCAC.TAX.SET(RELEASE.NO, R.RECORD, FN.FILE)

$INSERT I_EQUATE
$INSERT I_COMMON
*
      EQU LCAC.CHRG.CODE TO 7
      EQU LCAC.CHRG.REL.DRAW TO 10
      EQU LCAC.TF.REFERENCE TO 26
      EQU LCAC.TAX.CODE TO 27
      EQU LCAC.TAX.CHRG.STATUS TO 34
      EQU LCAC.TAX.DATE TO 36
*
! Remove all tax with status null i.e tax not yet taken
      TAX.CTR=DCOUNT(R.RECORD<LCAC.TAX.CODE>,VM)
      FOR YAV=1 TO TAX.CTR
         IF R.RECORD<LCAC.TAX.CHRG.STATUS,YAV> EQ '' THEN
            FOR I=LCAC.TAX.CODE TO LCAC.TAX.DATE
               R.RECORD=DELETE(R.RECORD,I,YAV)
            NEXT I
            YAV=''
            TAX.CTR=DCOUNT(R.RECORD<LCAC.TAX.CODE>,VM)
         END
      NEXT YAV
*
      CHRG.CTR=DCOUNT(R.RECORD<LCAC.CHRG.CODE>,VM)
      YAV=''
      FOR YAV=1 TO CHRG.CTR
         CHRG.DR.NO=FIELD(R.RECORD<LCAC.CHRG.REL.DRAW,YAV>,'-',2)
         IF CHRG.DR.NO > 0 THEN
            R.RECORD<LCAC.TF.REFERENCE,YAV>=RELEASE.NO:CHRG.DR.NO
         END
      NEXT YAV
*
      RETURN
*
   END
