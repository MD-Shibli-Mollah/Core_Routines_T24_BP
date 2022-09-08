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

* Version 6 21/09/99  GLOBUS Release No. G10.1.01 30/09/99
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
   SUBROUTINE E.SC.POS.DET
*
************************************************************
*
*    SUBROUTINE TO DETERMINE WHICH EXAMPLE PROGRAM
*    IS TO BE USED FOR THE NEXT LEVEL ENQUIRY
*
************************************************************
* Modification History:
*
* 20/12/06 - GLOBUS_BG_100012629
*            Add sc.book.cost. Adjust case statements to put more "popular"
*            transactions at the top.
*
* 22/12/06 - EN_10003154
*            Include MF.TRADE
*
* 20/07/07 - GLOBUS_BG_100014262
*            include sc.sec.trade.cust.detail
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_ENQUIRY.COMMON
$INSERT I_EQUATE
*
   PREFIX = O.DATA[1,4]
*
* Sets the 'drilldown' application based on transaction prefix
* list the most common at the top.
   BEGIN CASE
      CASE PREFIX = 'SCTR' ; O.DATA = 'SEC.TRADE'
      CASE PREFIX = 'SECT' ; O.DATA = 'SECURITY.TRANSFER'
      CASE PREFIX = 'DIAR' ; O.DATA = 'ENTITLEMENT'
      CASE PREFIX = 'POST' ; O.DATA = 'POSITION.TRANSFER'
      CASE PREFIX = 'SCST' ; O.DATA = 'SC.SEC.TRADE.CUST.DETAIL' ; * BG_100014262
      CASE PREFIX = 'SCCO' ; O.DATA = 'SC.BOOK.COST'          ;* BG_100012629
      CASE PREFIX = 'MFTR' ; O.DATA = 'MF.TRADE'
      CASE PREFIX = 'BDRD' ; O.DATA = 'REDEMPTION.CUS'
      CASE PREFIX = 'COUP' ; O.DATA = 'DIV.COUP.CUS'
      CASE PREFIX = 'CAPI' ; O.DATA = 'CAPTL.INCREASE.CUS'
      CASE PREFIX = 'NEWI' ; O.DATA = 'NI.ADMIN.MASTER'
      CASE PREFIX = 'STKD' ; O.DATA = 'STOCK.DIV.CUS'
      CASE PREFIX = 'LIQD' ; O.DATA = 'LIQD.TRADE'
      CASE PREFIX = 'OPTT' ; O.DATA = 'OPTION.TRADE'
      CASE PREFIX = 'TOPT' ; O.DATA = 'OPTION.TAKEUP'
      CASE 1 ; O.DATA = ''
   END CASE
*
   RETURN
*
   END
