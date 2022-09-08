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
* Version 2 30/10/00  GLOBUS Release No. 200508 30/06/05
* GLOBUS Release NO. G10.2.00
    $PACKAGE MG.Contract
      SUBROUTINE CONV.MG.G11.0.00(RELEASE.NO,R.RECORD,FN.FILE)

* For the existing MG contracts, Tax is not applicable and hence,
* We populate the Tax fields to NULL and TAX.E.I field in MG to 'N'
*
* 30/10/00 - GB0002862
*            There is no need to set new fields to null.
*            the only one which may need to be set is 84.
*

$INSERT I_COMMON
$INSERT I_EQUATE


*
* MG.TAX.E.I set to "N"
*

      R.RECORD<84> = 'N'
      RETURN
   END
