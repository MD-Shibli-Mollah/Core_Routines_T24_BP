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

* Version 1 15/11/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
      SUBROUTINE CONV.DR.G10.2.07(ID,R.RECORD,YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU TF.DR.DRAWING.TYPE TO 1
      EQU TF.DR.LC.LIAB.RELEASE TO 135
      EQU TF.DR.LC.LIAB.RELEASE.LCY TO 136
      EQU TF.DR.TRUST.REL TO 166

      IF R.RECORD<TF.DR.DRAWING.TYPE> MATCHES 'CO':VM:'CR':VM:'FR':VM:'RP' THEN
         IF R.RECORD<TF.DR.TRUST.REL> EQ '' THEN
            R.RECORD<TF.DR.LC.LIAB.RELEASE> = ''
            R.RECORD<TF.DR.LC.LIAB.RELEASE.LCY> = ''
         END
      END
      RETURN
   END
