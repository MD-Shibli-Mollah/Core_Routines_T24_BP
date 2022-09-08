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

* Version 3 31/05/01  GLOBUS Release No. G13.0.00 05/07/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LD.Foundation
      SUBROUTINE CONV.LD.DEALER.DESK.REF.13.2(LD.ID,R.RECORD,LD.FILE)

$INSERT I_EQUATE
$INSERT I_COMMON
*
      EQU LD.DEALER.DESK TO 217
      R.RECORD<LD.DEALER.DESK> = "00"
*
      RETURN
*
   END
