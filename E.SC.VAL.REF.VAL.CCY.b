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
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE SC.ScoReports
      SUBROUTINE E.SC.VAL.REF.VAL.CCY
************************************************************
* This routine is designed to test if thew VALUATION.CURRENCY and the
* REFERENCE.CURRENCY are the same on the SEC.ACC.MASTER record.
* It converts from the VALUATION.CURRENCY to the REFERENCE.CURRENCY if
* they are not.
*
*** <region name= Modification History>
*** <desc>Modification History </desc>
************************************************************
* Modification History:
*
* 26/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Tidy up.
* 23-07-2015 - 1415959
*             Incorporation of components
*-----------------------------------------------------------
*** </region>
*** <region name= Inserts>
*** <desc>Inserts </desc>

$USING ST.ExchangeRate
$USING EB.SystemTables
$USING EB.Reports


*** </region>

      REFERENCE.CCY = EB.Reports.getOData()[1,3]
      TOTAL.PORTFOLIO = EB.Reports.getOData()[4,99]
*
      IF REFERENCE.CCY = EB.SystemTables.getLocalOne() THEN
         EB.Reports.setOData(TOTAL.PORTFOLIO)
      END ELSE
         CCY1 = REFERENCE.CCY
         CCY2 = EB.SystemTables.getLocalOne()
         AMT1 = TOTAL.PORTFOLIO
         AMT2 = ''
         BASE.CCY = ''
         RET.CODE = ''
         EX.RATE = ''
         ST.ExchangeRate.Exchrate("1",CCY1,AMT1,CCY2,AMT2,BASE.CCY,EX.RATE,'','',RET.CODE)
         EB.Reports.setOData(AMT2)
      END
*
      RETURN
*
   END
