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
    $PACKAGE PD.Contract
      SUBROUTINE CONV.PD.PAYMENT.DUE.G12.2(PD.ID,R.PD.RECORD,F.PD.PAYMENT.DUE)
$INSERT I_COMMON
$INSERT I_EQUATE

* If the parameter record is of category from 1000 TO 9999 , Then change
* it to AC-1000 to AC-9999 .
      PD.PAR.ID = R.PD.RECORD<14>
      IF NUM(PD.PAR.ID) THEN
         IF (PD.PAR.ID GE 1000 ) AND (PD.PAR.ID LE 9999 ) THEN
            R.PD.RECORD<14> = 'AC-':PD.PAR.ID
         END
      END
      RETURN
   END
