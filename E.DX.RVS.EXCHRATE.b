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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
* Modification History:
* ---------------------
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*-----------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE E.DX.RVS.EXCHRATE
*
*    Routine to calculate the exchange rate between base ccy (buy) and
*    trade ccy (sell) on DX.REVALUE.SUMMARY
*
    $USING DX.Revaluation
    $USING EB.Reports
    $USING ST.ExchangeRate
*
    IF EB.Reports.getOData() = "" THEN
        EB.Reports.setOData("Missing Ccy")
    END ELSE
        GOSUB CALC.EXCH.RATE
    END
    RETURN
*
*
CALC.EXCH.RATE:
***************
    BUY.CCY = EB.Reports.getRRecord()<DX.Revaluation.RevalueSummary.RvsBaseCurrency>
    CCY.MKT = 1
    BUY.AMT = ''
    SELL.AMT = ''
    TRADE.CCY = EB.Reports.getOData()
    DIFFERENCE = ''
    LCY.AMT = ''
    RET.CODE = ''
    BASE.CCY = ''
    EXCH.RATE = ''
*
    ST.ExchangeRate.Exchrate(CCY.MKT, BUY.CCY, BUY.AMT, TRADE.CCY, SELL.AMT, BASE.CCY, EXCH.RATE, DIFFERENCE, LCY.AMT, RET.CODE)
*
    IF NOT(RET.CODE) AND EXCH.RATE THEN
        EB.Reports.setOData(EXCH.RATE)
    END
    RETURN
*
    END
