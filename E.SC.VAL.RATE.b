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

* Version 15 22/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-49</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SC.ScvReports
      SUBROUTINE E.SC.VAL.RATE
*
************************************************************
*
*    SUBROUTINE TO CALCULATE SEC.CCY/REF.CCY EXCHANGE RATE
*
*
*
*Modifications -
*-------------
*
*29/03/00 - GB0000612
*           jBASE changes.
*           R.FOREX is a dynamic array, It is changed to Dynamic array
*           where ever it is found to be a Dimensioned array.
*
* 10/06/03 - CI_10009809
*           If statement changed
*
* 30/03/06 - GLOBUS_BG_100010818
*            Incorrect display in SC.VAL.COST as the fields is
*            null, but the enquiry tests for 0. Amend to return
*            zero not null.
*            Re-organise program structure.
*
* 20/04/15 - 1323085
*            Incorporation of components 
************************************************************
*
$USING ST.ExchangeRate
$USING ST.RateParameters
$USING FX.Contract
$USING EB.SystemTables
$USING EB.Reports
*
      IF EB.Reports.getOData() THEN ; * BG_100010818 s
         GOSUB MAIN.PROCESS
      END ELSE
         EB.Reports.setOData(0)
      END

      RETURN   ; * BG_100010818 e

*-----------------------------------------------------------------------------
MAIN.PROCESS:
* Main processing
* BG_100010818 s
*
******************************************************************
*
*   LOCAL1 = REF.CCY * EQUATED IN E.SC.VAL.REF.CCY
*
********************************************************************
*
      REF.CCY = EB.SystemTables.getLocalOne()
      REFERENCE.CCY = EB.SystemTables.getLocalTwo()
*
      SEC.CCY = EB.Reports.getRRecord()<3,EB.Reports.getVc()>
      SEC.CODE = EB.Reports.getRRecord()<1,EB.Reports.getVc()>
      SEC.NAME = EB.Reports.getRRecord()<2,EB.Reports.getVc()>
      REF.CCY = EB.SystemTables.getLocalOne()
      REFERENCE.CCY = EB.SystemTables.getLocalTwo()

      CCY1 = SEC.CCY ; * BG_100010818 s
      CCY2 = REF.CCY
      FORWARD.RATE = ''    ; * BG_100010818 e
*
      IF SEC.CODE[1,2] = 'FX' AND CCY1 NE CCY2 THEN       ; * CALL FX.FORWARD.RATE TO OBTAIN XRATE ; * BG_100010818
      
tmp.ETEXT = EB.SystemTables.getEtext()
         R.FOREX = FX.Contract.Forex.Read(SEC.CODE, tmp.ETEXT) ; * BG_100010818 e
* Before incorporation : CALL F.READ(FN.FOREX,SEC.CODE,R.FOREX,F.FOREX,tmp.ETEXT) ; * BG_100010818 e
EB.SystemTables.setEtext(tmp.ETEXT)
         IF R.FOREX<FX.Contract.Forex.DealType> = 'FW' THEN      ; *GB0000612 ; * CI_10009809
            IF REF.CCY NE REFERENCE.CCY THEN
               GOSUB GET.FX.FORWARD.RATE ; * Get the FX exchange rate
            END ELSE
               FORWARD.RATE = EB.Reports.getRRecord()<6,EB.Reports.getVc()>
            END
         END
      END

      IF CCY1 NE CCY2 THEN
         VAL1 = EB.Reports.getOData()
         VAL2 = ''
         RET.CODE = ''
         RATE = FORWARD.RATE
          ST.ExchangeRate.Exchrate("1",CCY1,VAL1,CCY2,VAL2,'',RATE,'','',RET.CODE)
tmp.ETEXT = EB.SystemTables.getEtext()
         IF NOT(tmp.ETEXT) THEN
            EB.Reports.setOData(VAL2)
         END ELSE
            EB.Reports.setOData(0)
         END
      END
*
   RETURN
*

*-----------------------------------------------------------------------------
*** <region name= GET.FX.FORWARD.RATE>
GET.FX.FORWARD.RATE:
*** <desc>Get the FX exchange rate</desc>
* BG_100010818

      IF EB.Reports.getRRecord()<4,EB.Reports.getVc()> LT 0 THEN
         VALUE.DATE = R.FOREX<FX.Contract.Forex.ValueDateSell>   ; *GB0000612
      END ELSE
         VALUE.DATE = R.FOREX<FX.Contract.Forex.ValueDateBuy>    ; *GB0000612
      END
      AGAINST.CCY = REF.CCY
      FOR.CCY = SEC.CCY
      INTERPOLATION.MKR = ''
      DATE.OR.REST = VALUE.DATE
      REST.TEXT = ''
      INTERPOLATE = ''
      FORWARD.RATE = ''
      FOR.LCY.RATE = ''
      AGAINST.LCY.RATE = ''
      DAYS.SINCE.SPOT = ''
      RETURN.CODE = ''
       ST.RateParameters.Fwdrates('1',FOR.CCY,AGAINST.CCY,INTERPOLATION.MKR,DATE.OR.REST,REST.TEXT,INTERPOLATE,FORWARD.RATE,FOR.LCY.RATE,AGAINST.LCY.RATE,DAYS.SINCE.SPOT,RETURN.CODE)
      IF RETURN.CODE THEN
         FORWARD.RATE = ''
      END

      RETURN
*** </region>
   END
*
