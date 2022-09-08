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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.DX.PARAM.200602(ID,R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
* Program Description
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/01/2006 - BG_100009996
*              Created.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------
      DX.PAR.POS.DATE = 27
      DX.PAR.POS.COMPANY = 28
      
      POS.DATE = R.RECORD<DX.PAR.POS.DATE>
      POS.COMPANY = R.RECORD<DX.PAR.POS.COMPANY>
      IF POS.DATE[1,1] EQ VM AND POS.COMPANY[1,1] EQ VM THEN
*... POS.DATE and POS.COMPANY start with a blank multi value, remove it.
         POS.DATE = POS.DATE[2,9999]
         POS.COMPANY = POS.COMPANY[2,9999]
         R.RECORD<DX.PAR.POS.DATE> = POS.DATE
         R.RECORD<DX.PAR.POS.COMPANY> = POS.COMPANY
      END 
      
      RETURN

   END
