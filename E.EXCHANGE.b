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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*
* IIIIIIIIIVersion 1 19/10/93
*
    $PACKAGE ST.ExchangeRate

    SUBROUTINE E.EXCHANGE
*

    $USING ST.ExchangeRate
    $USING EB.Reports

*
    ENQ.FIELDS = EB.Reports.getOData()
    CONVERT ">" TO @VM IN ENQ.FIELDS
*
    CCY.MKT = 1
    BUY.CCY = ENQ.FIELDS<1,1>
    BUY.AMT = ENQ.FIELDS<1,2>
    SELL.CCY = ENQ.FIELDS<1,3>
    SELL.AMT = ENQ.FIELDS<1,4>
    IF NOT(BUY.AMT) AND NOT(SELL.AMT) THEN
        BUY.AMT = ''
        SELL.AMT = ''
    END
    BASE.CCY = ''
    EXCHANGE.RATE = ENQ.FIELDS<1,5>
    DIFFERENCE = ""
    LCY.AMT = ""
    RETURN.CODE = ""
*
    ST.ExchangeRate.Exchrate(CCY.MKT,BUY.CCY,BUY.AMT,SELL.CCY,SELL.AMT,BASE.CCY,EXCHANGE.RATE,DIFFERENCE,LCY.AMT,RETURN.CODE)
*
    RET.FIELDS = ""
    RET.FIELDS<1,1> = BUY.CCY
    RET.FIELDS<1,2> = BUY.AMT
    RET.FIELDS<1,3> = SELL.CCY
    RET.FIELDS<1,4> = SELL.AMT
    RET.FIELDS<1,5> = EXCHANGE.RATE
*
    CONVERT @VM TO "=" IN RET.FIELDS
    EB.Reports.setOData(RET.FIELDS)
*
    RETURN
    END
