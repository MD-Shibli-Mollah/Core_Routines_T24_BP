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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MI.Reports
      SUBROUTINE CONV.MI.RECORD.G10.2(ID,MI.REC,YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU MI.ENT.SIGN TO 1
      EQU MI.ENT.AMOUNT.LCY TO 12
      EQU MI.ENT.AMOUNT.FCY TO 14
      EQU MI.ENT.REAL.AMOUNT.LCY TO 18
      EQU MI.ENT.REAL.AMOUNT.FCY TO 19

!
! With the help of the SIGN and AMOUNT field , we are populating the
! the exact format into the REAL.AMOUNT field.
!

      IF MI.REC<MI.ENT.SIGN> = 'CR' THEN
         MI.REC<MI.ENT.REAL.AMOUNT.LCY> = MI.REC<MI.ENT.AMOUNT.LCY>
         MI.REC<MI.ENT.REAL.AMOUNT.FCY> = MI.REC<MI.ENT.AMOUNT.FCY>
      END ELSE
         MI.REC<MI.ENT.REAL.AMOUNT.LCY> = '-' : MI.REC<MI.ENT.AMOUNT.LCY>
         IF MI.REC<MI.ENT.AMOUNT.FCY> = '' THEN
            MI.REC<MI.ENT.REAL.AMOUNT.FCY> = ''
         END ELSE
            MI.REC<MI.ENT.REAL.AMOUNT.FCY> = '-' : MI.REC<MI.ENT.AMOUNT.FCY>
         END
      END
      RETURN
   END
