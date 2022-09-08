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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Modelling
      SUBROUTINE CONV.AM.COMPARE.R08(AM.COMPARE.ID,R.AM.COMPARE,FN.AM.COMPARE)
*-----------------------------------------------------------------------------
* Program Description  : Convert AM.COMPARE records
*                        Change YES_NO fields to YES or blank fields.
*                        This is so that we can default data into fields but
*                        only give option to mark as yes or no, ie. by making
*                        these fields into check-boxes (YES). Therefore change
*                        existing AM.COMPARE records for these fields, changing
*                        'NO' to null.
*
*                        Fields affected:
*
*                           CONSOLIDATE
*                           HIGH.VOLUME
*                           VALUATE.PORTFOLIO
*                           COMPARE
*                           REBAL.SELL
*                           REBAL.BUY
*                           GENERATE.ORDER
*                           REBUILD.AXIS
*                           APPLY.FILTER
*                           CHECK.ORDER
*                           SHADOW.MODEL
*                           START
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB EQUATE.FIELDS
      GOSUB AMEND.FIELD.DATA

      RETURN
      
*-----------------------------------------------------------------------------
EQUATE.FIELDS:

* Equate field numbers to position manually, do no use $INSERT

      EQU consolidateFldPos TO 12
      EQU highVolumeFldPos TO 15
      EQU valuatePortfolioFldPos TO 17
      EQU compareFldPos TO 18
      EQU rebalSellFldPos TO 20
      EQU rebalBuyFldPos TO 21
      EQU generateOrderFldPos TO 22
      EQU rebuildAxisFldPos TO 24
      EQU applyFilterFldPos TO 30
      EQU checkOrderFldPos TO 33
      EQU shadowModelFldPos TO 34
      EQU startFldPos TO 36

      
      RETURN

*-----------------------------------------------------------------------------
AMEND.FIELD.DATA:

* Amend each field we are changing

      fieldToSet = consolidateFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = highVolumeFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = valuatePortfolioFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = compareFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = rebalSellFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = rebalBuyFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = generateOrderFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = rebuildAxisFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = applyFilterFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = checkOrderFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = shadowModelFldPos
      GOSUB MODIFY.NO.TO.BLANK

      fieldToSet = startFldPos
      GOSUB MODIFY.NO.TO.BLANK

      RETURN

*-----------------------------------------------------------------------------
MODIFY.NO.TO.BLANK:

* If the field in question is set to 'NO' set it to blank.

      fieldValue = R.AM.COMPARE<fieldToSet>
      
      IF UPCASE(fieldValue[1,1]) = 'N' THEN
         R.AM.COMPARE<fieldToSet> = ''
      END
      
      RETURN
      
*-----------------------------------------------------------------------------
   END
