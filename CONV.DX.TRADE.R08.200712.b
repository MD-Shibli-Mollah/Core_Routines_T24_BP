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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
*
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TRADE.R08.200712(DX.TRADE.ID,R.DX.TRADE,FN.DX.TRADE)
*-----------------------------------------------------------------------------
* Template record routine, to be used as a basis for building a RECORD.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
*
* Conversion of DX.TRADE
*
* Blanks out SUPPRESS.ALL.MSG field.
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 12/12/2007 - BG_100016290 - aleggett@temenos.com
*              Created
*
* 21/12/2007 - BG_100016734 - aleggett@temenos.com
*              Convert EXOTIC.EVENT field from 'YES'/'NO'/blank to 'YES'/blank
*              check-box type field.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB EQUATE.FIELDS
      GOSUB AMEND.FIELD.DATA

      RETURN
      
*-----------------------------------------------------------------------------
EQUATE.FIELDS:

* Equate field numbers to position manually, do no use $INSERT

      EQU exoticEventPos TO 188
      EQU usrFldPricePos TO 196
      EQU suppressAllMsgPos TO 211

      RETURN

*-----------------------------------------------------------------------------
AMEND.FIELD.DATA:

      IF R.DX.TRADE<exoticEventPos> = 'NO' THEN
         R.DX.TRADE<exoticEventPos> = ''
      END
      
      IF R.DX.TRADE<usrFldPricePos> = 'NO' THEN
         R.DX.TRADE<usrFldPricePos> = ''
      END

      R.DX.TRADE<suppressAllMsgPos> = ''

      RETURN

*-----------------------------------------------------------------------------
   END
