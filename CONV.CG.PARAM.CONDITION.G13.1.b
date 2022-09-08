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

* Version 3 25/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctCapitalGains
      SUBROUTINE CONV.CG.PARAM.CONDITION.G13.1(YID, R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
* RECORD.ROUTINE used be CONV.CG.PARAM.CONDITION.G13.1
* This program will populate new field with the default value.
*-----------------------------------------------------------------------------
* Modification History:
*
* 17/09/02 - GLOBUS_EN_10000785
*            Populate new fields for CG.PARAM.CONDITION
*-----------------------------------------------------------------------------
$INSERT I_EQUATE
$INSERT I_COMMON

      IF R.RECORD<8> = "" THEN 
         R.RECORD<8> = "LOCAL"           ; * set source/local tax to local 
      END

      RETURN

   END
