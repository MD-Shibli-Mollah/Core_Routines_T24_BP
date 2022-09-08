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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Reports
    SUBROUTINE E.SW.REVAL.CALC
*************************************************************************
* This routine is used by the SWAPs currency revaluation enquiry to
* calculate the local currency equivalents of the outstanding principal -
* both at contract initiation and the current value.
*************************************************************************
*
*   GB9901583 : This routine will be modified so as to use the REVAL.RATE
*                on F.CURRENCY instead of using the MID.REVAL.RATE.
*
* 22/03/04 - GLOBUS_BG_100006426
*            Trim incoming data as it is padded with spaces by the ENQUIRY
*            routines. Move the rate code so that it is only executed if
*            required.
*
* 30/12/15 - Enhancement 1226121
*		   - Task 1569212
*		   - Routine incorporated
*
**************************************************************************
    $USING ST.CurrencyConfig
    $USING EB.DataAccess
    $USING ST.ExchangeRate
    $USING EB.SystemTables
    $USING EB.Reports

*
* Open CURRENCY file

    FN.CURRENCY = 'F.CURRENCY'
    F.CURRENCY.LOC = ''
    EB.DataAccess.Opf(FN.CURRENCY, F.CURRENCY.LOC)
    EB.SystemTables.setFCurrency(F.CURRENCY.LOC)
*
    CUURENCY = ''
    CCY.MKT = 1
    R.CURRENCY = ''
    POS = ''
    ERR.MSG = ''
*
* O.DATA should be in the format CCY*AMT.FCY[*RATE]
    O.DATA.VAL = EB.Reports.getOData()
    CURRENCY = FIELD(O.DATA.VAL, '*', 1)
    CURRENCY = TRIM(CURRENCY)          ; * BG_100006426
    AMT.FCY = FIELD(O.DATA.VAL, '*', 2)
    AMT.FCY = TRIM(AMT.FCY)            ; * BG_100006426
    RATE = FIELD(O.DATA.VAL, '*', 3)
    RATE = TRIM(RATE)                  ; * BG_100006426
*
    AMT.LCY = ''
*
    IF CURRENCY = EB.SystemTables.getLccy() THEN            ; * BG_100006426 s
        AMT.LCY = AMT.FCY
    END ELSE
        IF RATE = '' THEN               ; * GB9901583 (start)
            * If the RATE is NOT present then we read REVAL.RATE from F.CURRENCY
            * If RATE is NULL then calcuate and apply MID.REVAL.RATE
            R.CURRENCY = ST.CurrencyConfig.Currency.Read(CURRENCY, ERR.MSG)
            LOCATE CCY.MKT IN R.CURRENCY<ST.CurrencyConfig.Currency.EbCurCurrencyMarket,1> SETTING POS THEN
            RATE = R.CURRENCY<ST.CurrencyConfig.Currency.EbCurRevalRate,POS>
        END
    END                             ; * GB9901583 (end)
    ST.ExchangeRate.MiddleRateConvCheck(AMT.FCY, CURRENCY, RATE, "", AMT.LCY, "", "")
    END                                ; * BG_100006426 e
*
* Set the return argument to the local currency amount.
    EB.Reports.setOData(AMT.LCY<1,1>)

    RETURN
    END
