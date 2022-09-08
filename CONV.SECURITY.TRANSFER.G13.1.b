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
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOffMarketTrades
      SUBROUTINE CONV.SECURITY.TRANSFER.G13.1(YID, R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
* RECORD.ROUTINE used be CONV.SECURITY.TRANSFER.G13.1
* conversion details will add new fields and this program will populate them
* with the correct values.
*-----------------------------------------------------------------------------
* Modification History:
*
* 16/09/02 - GLOBUS_EN_10000785
*            Populate new fields for SECURITY.TRANSFER
*-----------------------------------------------------------------------------
$INSERT I_EQUATE
$INSERT I_COMMON

* extract security number
      SECURITY.NUMBER = R.RECORD<2>
* extract trade date
      TRADE.DATE = R.RECORD<6>
* extract portfolio number
      PORTFOLIO.NUMBER = R.RECORD<9>

* only populate these fields if CGT.BASE.AMT is populated
* and the conversion has not already populated the fields
      IF R.RECORD<54> NE "" AND R.RECORD<60> = "" THEN

         GROUP.NO = '' ; SOURCE.LOCAL.TAX = ''
         CALL SC.CHECK.CG.PARAM.CONDITION(SECURITY.NUMBER,PORTFOLIO.NUMBER,GROUP.NO,SOURCE.LOCAL.TAX,TRADE.DATE)

         R.RECORD<59> = GROUP.NO         ; * CG.PARAM.CONDITION id
         R.RECORD<60> = "LOCAL"          ; * set source/local tax to local

      END

      RETURN

   END
