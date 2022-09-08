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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Foundation
      SUBROUTINE CONV.RE.MD.BALANCES.G12.1(MD.ID,MD.REC,MD.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*******************************************************************
      EQU MD.RBL.DATE.LAST.UPDATED TO 1, MD.RBL.CURRENCY TO 2,
         MD.RBL.FWD.PRINCIPAL TO 3, MD.RBL.FWD.PART.PRINCIPAL TO 4,
         MD.RBL.CUR.PRINCIPAL TO 5, MD.RBL.CUR.PART.PRINCIPAL TO 6,
         MD.RBL.PRIN.INCREASE TO 7, MD.RBL.PRIN.PART.INC TO 8,
         MD.RBL.INCREASE.DATE TO 9, MD.RBL.PRIN.DECREASE TO 10,
         MD.RBL.PRIN.PART.DEC TO 11, MD.RBL.DECREASE.DATE TO 12,
         MD.RBL.OTS.COMMISSION TO 13, MD.RBL.VALUE.DATE TO 14,
         MD.RBL.MATURITY.DATE TO 15, MD.RBL.CUSTOMER.NO TO 16




      IF FILE.TYPE NE 1 THEN RETURN
      MD.REC<MD.RBL.FWD.PART.PRINCIPAL> = ''
      MD.REC<MD.RBL.CUR.PART.PRINCIPAL> = ''
      MD.REC<MD.RBL.PRIN.PART.INC> = ''
      MD.REC<MD.RBL.PRIN.PART.DEC> = ''
*
*
      RETURN
************************************************************************
   END
