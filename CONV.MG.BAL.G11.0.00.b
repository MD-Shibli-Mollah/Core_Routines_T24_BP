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
* Version 1 07/09/00  GLOBUS Release No. 200508 30/06/05
*      Since for the existing MG contracts Tax is not applicable,
*         we populate the Tax fields in MG.BALANCES to Zero.
    $PACKAGE MG.Contract
      SUBROUTINE CONV.MG.BAL.G11.0.00(RELEASE.NO,R.RECORD,FN.FILE)

* 29/11/01 - CI_1000554
*            Subroutine Name changed from G11.0.0 to G11.0.00
*

$INSERT I_COMMON
$INSERT I_EQUATE

      R.RECORD<14,1> = ""
      R.RECORD<15> = 0
      R.RECORD<16> = 0
      R.RECORD<24> = 0

      FOR I = 1 TO DCOUNT(R.RECORD<33>,VM)
         R.RECORD<39,I> = 0
      NEXT I
      RETURN
   END
