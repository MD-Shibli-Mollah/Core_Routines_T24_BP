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

* Version n dd/mm/yy  GLOBUS Release No. 200602 09/01/06
*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
* Modification History:
* ----------------------
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*-------------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE E.DX.TRANS.CSN
*
*  This routine returns all the commissions for a DX.TRANSACTION record
*  together with the commission currency. If a currency is passed in
*  as input it will convert commission amounts to this currency. Otherwise
*  it will default to the currency for that commission type.
*
    $USING DX.Trade
    $USING EB.Reports
    $USING ST.ExchangeRate
*
    DEFAULT.CCY = ''
    O.DATA.LOCAL = EB.Reports.getOData()
    IF O.DATA.LOCAL = "" THEN
        DEFAULT.CCY = EB.Reports.getOData()
    END
    RETURN.DATA = ''
    TOT.CSN = 5
    FOR CSN.COUNT = 1 TO TOT.CSN
        GOSUB PROCESS.CSN.TYPE
    NEXT CSN.COUNT
*
    RETURN
*
PROCESS.CSN.TYPE:
*
* Commission types are always returned in fixed sequence:-
* Commission@fmExecution@fmClearing@fmRegulatory@fmMisc (where @fm = field mark)
*
    THIS.TYPE = EB.Reports.getRRecord()<DX.Trade.Transaction.TxCommTyp,CSN.COUNT>
    CSN.CCY = EB.Reports.getRRecord()<DX.Trade.Transaction.TxCommCcy,CSN.COUNT>
*
    IF DEFAULT.CCY AND DEFAULT.CCY # CSN.CCY THEN
        GOSUB CONVERT.CSN.AMOUNT
        CSN.CCY = DEFAULT.CCY
    END ELSE
        CSN.AMOUNT = EB.Reports.getRRecord()<DX.Trade.Transaction.TxCommAmt,CSN.COUNT>
    END
*
    BEGIN CASE
        CASE THIS.TYPE = "COMMISSION"
            RETURN.DATA<1,1> = CSN.AMOUNT
            RETURN.DATA<1,2> = CSN.CCY
        CASE THIS.TYPE = "EXECUTION"
            RETURN.DATA<2,1> = CSN.AMOUNT
            RETURN.DATA<2,2> = CSN.CCY
        CASE THIS.TYPE = "CLEARING"
            RETURN.DATA<3,1> = CSN.AMOUNT
            RETURN.DATA<3,2> = CSN.CCY
        CASE THIS.TYPE = "REGULATORY"
            RETURN.DATA<4,1> = CSN.AMOUNT
            RETURN.DATA<4,2> = CSN.CCY
        CASE THIS.TYPE = "MISC"
            RETURN.DATA<5,1> = CSN.AMOUNT
            RETURN.DATA<5,2> = CSN.CCY
    END CASE
*
* Because we can't easily use FM/VM as delimiters in enquiry these
* are converted to ">" and "]" respectively
*     e.g of returned data:-
* 100.33]USD>43.23]GBP>........................
*
    CONVERT @FM TO ">" IN RETURN.DATA
    CONVERT @VM TO "]" IN RETURN.DATA
    EB.Reports.setOData(RETURN.DATA)
*
*
CONVERT.CSN.AMOUNT:
*******************
    BUY.CCY = DEFAULT.CCY
    CCY.MKT = 1
    BUY.AMT = ''
    SELL.AMT = EB.Reports.getRRecord()<DX.Trade.Transaction.TxCommAmt,CSN.COUNT>
    SELL.CCY = CSN.CCY
    DIFFERENCE = ''
    LCY.AMT = ''
    RET.CODE = ''
    BASE.CCY = ''
    EXCH.RATE = ''
    RET.CODE = ''
*
    ST.ExchangeRate.Exchrate(CCY.MKT, BUY.CCY, BUY.AMT, SELL.CCY, SELL.AMT, BASE.CCY, EXCH.RATE, DIFFERENCE, LCY.AMT, RET.CODE)
*
    IF NOT(RET.CODE) THEN
        CSN.AMOUNT = BUY.AMT
    END ELSE
        CSN.AMOUNT = ''
    END
    RETURN

    END
*
