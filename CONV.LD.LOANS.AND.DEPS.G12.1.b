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
    $PACKAGE LD.Contract
      SUBROUTINE CONV.LD.LOANS.AND.DEPS.G12.1(LD.ID,R.LD.ACCOUNT,FV.LD)

* This is the conversion routine to convert all the commitment contract
* to update LD.TRANCHE.AMT with LD.AMOUNT
* 13/10/2003 - CI_10015410/CI_10013510
*                    To update the TRANCHE.AMOUNT
*                    as the LD.AMOUNT
*

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU LD.CATEGORY TO 11
      EQU LD.AMOUNT TO 4
      EQU LD.TRANCHE.AMT TO 97

      COMMITMENT = R.LD.ACCOUNT<LD.CATEGORY> GE 21095 AND R.LD.ACCOUNT<LD.CATEGORY> LE 21099
      LIAB.COMMITMENT = R.LD.ACCOUNT<LD.CATEGORY> GE 21101 AND R.LD.ACCOUNT<LD.CATEGORY> LE 21105

      IF COMMITMENT OR LIAB.COMMITMENT THEN
         IF R.LD.ACCOUNT<LD.TRANCHE.AMT,1> = '' THEN
            R.LD.ACCOUNT<LD.TRANCHE.AMT,1> = R.LD.ACCOUNT<LD.AMOUNT>
         END
      END
      RETURN
   END
