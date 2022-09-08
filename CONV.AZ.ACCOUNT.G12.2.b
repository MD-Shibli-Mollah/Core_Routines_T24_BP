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
      SUBROUTINE CONV.AZ.ACCOUNT.G12.2(AZ.ID,R.AZ.ACCOUNT,FV.AZ.ACCOUNT)

* This is the conversion routine to change the calculation
* base as SCHEDULED BALANCE for SAVINGS-PLAN deposits.

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU AZ.REPAYMENT.TYPE TO 40,
         AZ.CALCULATION.BASE TO 41

      IF R.AZ.ACCOUNT<AZ.REPAYMENT.TYPE> = 'SAVINGS-PLAN' THEN
         R.AZ.ACCOUNT<AZ.CALCULATION.BASE> = 'SCHEDULED BALANCE'
      END

      RETURN
   END
