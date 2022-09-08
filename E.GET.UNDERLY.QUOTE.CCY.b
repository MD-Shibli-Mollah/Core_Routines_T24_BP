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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE E.GET.UNDERLY.QUOTE.CCY

* Enquiry Subroutine to calculate the Underlying  price in base currency equivalent
* Modification history
*--------------------------------------------------------------------------
* 08/01/13 - EN-360341 / Task-242183
*            Enhancement on creating currency pairs for FX-OTC options
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*--------------------------------------------------------------------------

    $USING EB.Reports
    $USING ST.ExchangeRate

    CCY.MKT = 1
    SELL.AMT = ''
    BASE.CCY = ''
    EXCHANGE.RATE = ''
    LCY.AMT = ''
    BUY.AMT = ''
    RETURN.CODE = ''
    TRADE.CCY = ''
    QUOTE.CCY = ''

    tmp.O.DATA = EB.Reports.getOData()
    TRADE.CCY = FIELD(tmp.O.DATA,"_",1)     ;*Trade Currency
    QUOTE.CCY = FIELD(tmp.O.DATA,"_",2)     ;*Strike Quote Currency
    DEL.CCY = FIELD(tmp.O.DATA,"_",3)       ;*Delivery Currency

* Find the ase Currency And Exchange Rate between trade and delivery currency
    ST.ExchangeRate.Exchrate(CCY.MKT,TRADE.CCY,BUY.AMT,DEL.CCY,SELL.AMT,BASE.CCY,EXCHANGE.RATE,'',LCY.AMT,RETURN.CODE)

    IF TRADE.CCY EQ BASE.CCY THEN  ;* when trade and base currency are same the exchange rate is returned
        EB.Reports.setOData(EXCHANGE.RATE)
    END ELSE
        CALC.EXCH.RATE = 1 / EXCHANGE.RATE
        EB.Reports.setOData(CALC.EXCH.RATE)

    END

    RETURN
    END
