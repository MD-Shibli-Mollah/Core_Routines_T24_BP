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

* Version 1 14/03/01  GLOBUS Release No. G11.2.00 28/03/01
    $PACKAGE LC.Contract
      SUBROUTINE CONV.LETTER.OF.CREDIT.G11.2(LC.ID,Y.LCREC,LC.FILE)
*Conversion to populate the field RISK.PARTY in LC which is
*a new field.

$INSERT I_COMMON
$INSERT I_EQUATE

      EQUATE TF.LC.RISK.PARTY TO 192
      EQUATE TF.LC.LC.TYPE TO 2
      EQUATE TF.LC.ISSUING.BANK.NO TO 6
      YLC.TYPE = Y.LCREC<TF.LC.LC.TYPE>

      CALL LC.IMP.EXP(YLC.TYPE,IMPORT.LC,EXPORT.LC,'D')

      IF EXPORT.LC THEN
         IF Y.LCREC<TF.LC.RISK.PARTY> EQ '' THEN
            Y.LCREC<TF.LC.RISK.PARTY> = Y.LCREC<TF.LC.ISSUING.BANK.NO>
         END
      END
      RETURN
   END
