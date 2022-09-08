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

* Version n dd/mm/yy  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
      SUBROUTINE CONV.DRAWINGS.G13.2(Y.DRID,Y.DRREC,YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQUATE TF.DR.DR.DEBIT.TO.CUST TO 188
      EQUATE TF.DR.DRAWING.TYPE TO 1

      IF Y.DRREC<TF.DR.DRAWING.TYPE> EQ "SP" THEN
         Y.DRREC<TF.DR.DR.DEBIT.TO.CUST> = "DEBITED"
      END

      RETURN
   END
