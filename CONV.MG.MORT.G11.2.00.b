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
* Version 1 24/07/01  GLOBUS Release No. G12.0.01 31/07/01
***************************************************************
    $PACKAGE MG.Contract
      SUBROUTINE CONV.MG.MORT.G11.2.00(RELEASE.NO,R.RECORD,FN.FILE)
***************************************************************

* This routine is to populate the ADD.PAY.DATE field in MG.MORTGAGE
* file with some value if ADD.PAY.TYPE has been input.
* and if ADD.PAY.DATE is equal to NULL.
* Default the REPAYMENT.DATE field value into ADD.PAY.DATE field.


      IF R.RECORD<52> EQ '' AND R.RECORD<49> NE '' THEN
         COUNT.ADD.PAY = DCOUNT(R.RECORD<49>, @VM)
         FOR II = 1 TO COUNT.ADD.PAY
            R.RECORD<52,II> = R.RECORD<21>
         NEXT
      END
      RETURN
   END
