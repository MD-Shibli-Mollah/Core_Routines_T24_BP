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

*--------------------------------------------------------------------------------------------------------------------------------
* <Rating>67</Rating>
*--------------------------------------------------------------------------------------------------------------------------------
    $PACKAGE FX.PositionAndReval
    SUBROUTINE PM.FX.IRG.FOR.FW.DEALS(PRINCIPAL.CCY,PM.FX.REVAL.POSN.CLASS,RESERVED.1,RESERVED.2)
*** <region name= Description>
*** <desc> </desc>
*      This subroutine should be attached to the PM.FX.SYNTH.RTN field of PM.PARAMETER.
*      The parameters of the routine are
*      Incoming Parameters :
*
*          PRINCIPAL.CCY          - If the contract involves Local Currency then Principal Currency is the Local Currency.
*                                 - For a cross currency deal, Buy Currency is taken as the Principal Currency.
*
*     Outgoing Parameters :
*          PM.FX.REVAL.POSN.CLASS - A Dynamic Array which holds the following information.
*                                   PM.MA.ASST.LIAB.CD - Asset / Liability
*                                   PM.MA.POSN.CLASS - Position Class
*                                   PM.MA.CCY.AMT - Notional Amount
*                                   PM.MA.RATE - Interest Rate
*                                   PM.MA.VALUE.DATE - Value date
*                                   PM.MA.POSN.TYPE - Position Type
*                                   PM.MA.CURRENCY - Currency.
*                    RESERVED.1  -  Reserved for Future Use.
*                    RESERVED.2  -  Reserved for Future Use.
*
*      This routine returns an array of position classes and its corresponding notional amounts ,interest rates.
*
*      Following are the steps performed.
*         1. The logic of Calculating INT.RATE.BUY and INT.RATE.SELL is based on the PRINCIPAL.CCY.
*                 a) Interest rate is taken from the Periodic Interest table for the Secondary currency.
*                 b) Based on the interest rate for the secondary currency, the interest rate for the Principal Currency is derived.
*         2. Notional Amounts are calculated for both the currencies based on the INT.RATE.BUY and INT.RATE.SELL
*         3. The Revaluation Related Position classes is formed as Below.
*                 a) FX:REVAL.TYPE:S - Spot position class - Buy Currency is a liability and Sell Currency is an asset.
*                 b) FX:REVAL.TYPE:M - Maturity Position Class - Buy Currency is an asset and sell Currency is a liability.
*         4. The formed Position Classes should be returned to the calling routine.
*
*     This routine can be modified in future , if needed to include any other position classes locally.
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------

*<region name = Modification History>
* Modification History
*****************************************************
* 12/03/2014 - Enhancment 704809 / Task 704814
*              PM FX Synthetic Modelling
*</region>
*-----------------------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>



    $USING FX.Contract
    $USING ST.CurrencyConfig
    $USING PM.Config
    $USING ST.ExchangeRate
    $USING EB.DataAccess
    $USING EB.Service
    $USING EB.SystemTables
    $USING PM.Engine

*** </region>

*** <region name= Process flow>
*** <desc> </desc>


    GOSUB INITIALISE
    GOSUB CALC.INT.RATE.BUY.AND.SELL
    GOSUB CALC.NOTIONAL.AMTS
    GOSUB TO.MODIFY.MAT.ACTIVITY

    RETURN

*** </region>

*** <region name= INITIALISE>
*** <desc> </desc>
*--------------------------------------------------
INITIALISE:
*--------------------------------------------------

    INT.RATE.BUY = ''
    INT.RATE.SELL = ''
    OTH.CCY.BASIS = ''
    PM.FX.REVAL.POSN.CLASS = ''
    DDATE = ''
    REVAL.TYPE = ''
    SWAP.REVAL.TYPE = ''
    RS = ''
    RF = ''

    GAP.SPOT.POSN.CLASS = ''
    GAP.MAT.POSN.CLASS = ''

    DDATE = EB.SystemTables.getRNew(FX.Contract.Forex.DealDate)
    REVAL.TYPE = EB.SystemTables.getRNew(FX.Contract.Forex.RevaluationType)
    SWAP.REVAL.TYPE = 'IN':@VM:'SL':@VM:'SF'
    IF EB.SystemTables.getRNew(FX.Contract.Forex.DealType) = 'SW' AND REVAL.TYPE MATCHES SWAP.REVAL.TYPE THEN
        GAP.SPOT.POSN.CLASS = PM.Engine.getParamRec()<PM.Config.Parameter.PpFxIntSwSt>
        GAP.MAT.POSN.CLASS = PM.Engine.getParamRec()<PM.Config.Parameter.PpFxIntSwMat>
    END ELSE
        GAP.SPOT.POSN.CLASS = 'FX':REVAL.TYPE:'S'
        GAP.MAT.POSN.CLASS = 'FX':REVAL.TYPE:'M'
    END

    BEGIN CASE
        CASE EB.SystemTables.getRNew(FX.Contract.Forex.ValueDateBuy) < EB.SystemTables.getRNew(FX.Contract.Forex.ValueDateSell)
            VALUE.DATE=EB.SystemTables.getRNew(FX.Contract.Forex.ValueDateBuy)
        CASE 1          ;* R.NEW(FX.VALUE.DATE.BUY) >= R.NEW(FX.VALUE.DATE.SELL)
            VALUE.DATE=EB.SystemTables.getRNew(FX.Contract.Forex.ValueDateSell)
    END CASE

    RS=EB.SystemTables.getRNew(FX.Contract.Forex.SpotRate)    ;* FX.SPOT.RATE
    RF=EB.SystemTables.getRNew(FX.Contract.Forex.ForwardRate) ;* FORWARD RATE

    RETURN

*** </region>

*** <region name= CALC.INT.RATE.BUY.AND.SELL>
*** <desc>Calculate Interest Rate Buy and Sell </desc>
*------------------------------------------------------
CALC.INT.RATE.BUY.AND.SELL:
*------------------------------------------------------
*     The logic of Calculating INT.RATE.BUY and INT.RATE.SELL is based on the PRINCIPAL.CCY.
*                 a) Interest rate is taken from the Periodic Interest table for the Secondary currency.
*                 b) Based on the interest rate for the secondary currency, the interest rate for the Principal Currency is derived.
*    1. If the Principal Currency is Non base Currency and if the Revaluation Type is not RB, then the Interest rates can be taken from the contract.
*    2. For 'RB' method of revaluation , the INT.RATE.BUY and INT.RATE.SELL is not updated in the contract and hence this routine should calculate it.
*    3. If the Principal Currency is Base currency then contract cannot be referred for the interest rates. Because at the contract level , interest
*       rate for the Base currency is defaulted from Periodic Interest table and Interest rate for Non Base currency is derived at.
*       Hence this routine should calculate the INT.RATE.BUY and INT.RATE.SELL based on the PRINCIPAL.CCY concept.
*

    IF PRINCIPAL.CCY = EB.SystemTables.getRNew(FX.Contract.Forex.BaseCcy) OR EB.SystemTables.getRNew(FX.Contract.Forex.RevaluationType) = 'RB' THEN
        IF PRINCIPAL.CCY = EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought) THEN   ;* Principal Currency is buy currency , so default Currency sold from PI table
            IS.PRIN.CCY.BUY = 1
            BID.OFFER = 'B'
            SELL.CCY =EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold)
            ST.ExchangeRate.Termrate("","01","",SELL.CCY,DDATE,BID.OFFER,"",VALUE.DATE,"",INT.RATE.SELL,"","","","",RETURN.CODE)
            INT.RATE.SELL = OCONV(ICONV(INT.RATE.SELL, "MD9"), "MD9")
        END ELSE
            IS.PRIN.CCY.BUY = 0
            BID.OFFER = "O"
            BUY.CCY=EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought)
            ST.ExchangeRate.Termrate("","01","",BUY.CCY,DDATE,BID.OFFER,"",VALUE.DATE,"",INT.RATE.BUY,"","","","",RETURN.CODE)
            INT.RATE.BUY = OCONV(ICONV(INT.RATE.BUY, "MD9"), "MD9")
        END

        GOSUB DEFAULT.DAY.BASIS
        IF IS.PRIN.CCY.BUY = 1 THEN
            INT.RATE.BUY = (((100+(INT.RATE.SELL*NO.OF.DAYS.SELL.CCY/SELL.CCY.BASIS))*RF/RS)-100)*BUY.CCY.BASIS/NO.OF.DAYS.BUY.CCY
            INT.RATE.BUY = OCONV(ICONV(INT.RATE.BUY, "MD9"), "MD9")
        END ELSE
            INT.RATE.SELL = (((100+(INT.RATE.BUY*NO.OF.DAYS.BUY.CCY/BUY.CCY.BASIS))*RF/RS)-100)*SELL.CCY.BASIS/NO.OF.DAYS.SELL.CCY
            INT.RATE.SELL =  OCONV(ICONV(INT.RATE.SELL, "MD9"), "MD9")
        END
    END ELSE
        INT.RATE.BUY = EB.SystemTables.getRNew(FX.Contract.Forex.IntRateBuy)
        INT.RATE.SELL = EB.SystemTables.getRNew(FX.Contract.Forex.IntRateSell)
        GOSUB DEFAULT.DAY.BASIS
    END

    RETURN

*** </region>
*** <region name= DEFAULT.DAY.BASIS>
*** <desc>Defaults the day basis </desc>
*--------------------------------------------------------------
DEFAULT.DAY.BASIS:
*--------------------------------------------------------------
*  Get the Interest Day Basis and the Number of Days for Buy Currency and Sell Currency which is used for Notional amounts calculation.


    tmp.R.NEW.FX.Contract.Forex.CurrencyBought = EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought)
    EB.DataAccess.Dbr("CURRENCY":@FM:ST.CurrencyConfig.Currency.EbCurInterestDayBasis:@FM:".A",tmp.R.NEW.FX.Contract.Forex.CurrencyBought,BUY.CCY.BASIS)
    EB.SystemTables.setRNew(FX.Contract.Forex.CurrencyBought, tmp.R.NEW.FX.Contract.Forex.CurrencyBought)
    tmp.R.NEW.FX.Contract.Forex.CurrencySold = EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold)
    EB.DataAccess.Dbr("CURRENCY":@FM:ST.CurrencyConfig.Currency.EbCurInterestDayBasis:@FM:".A",tmp.R.NEW.FX.Contract.Forex.CurrencySold,SELL.CCY.BASIS)
    EB.SystemTables.setRNew(FX.Contract.Forex.CurrencySold, tmp.R.NEW.FX.Contract.Forex.CurrencySold)

    tmp.R.NEW.FX.Contract.Forex.SpotDate = EB.SystemTables.getRNew(FX.Contract.Forex.SpotDate)
    EB.Service.BdCalcDays(tmp.R.NEW.FX.Contract.Forex.SpotDate,VALUE.DATE,BUY.CCY.BASIS,NO.OF.DAYS.BUY.CCY)
    EB.SystemTables.setRNew(FX.Contract.Forex.SpotDate, tmp.R.NEW.FX.Contract.Forex.SpotDate)
    tmp.R.NEW.FX.Contract.Forex.SpotDate = EB.SystemTables.getRNew(FX.Contract.Forex.SpotDate)
    EB.Service.BdCalcDays(tmp.R.NEW.FX.Contract.Forex.SpotDate,VALUE.DATE,SELL.CCY.BASIS,NO.OF.DAYS.SELL.CCY)
    EB.SystemTables.setRNew(FX.Contract.Forex.SpotDate, tmp.R.NEW.FX.Contract.Forex.SpotDate)

    BUY.CCY.BASIS=FIELD(BUY.CCY.BASIS,"/",2)      ;* INT. BASIS BASE
    SELL.CCY.BASIS=FIELD(SELL.CCY.BASIS,"/",2)    ;* INT. BASIS OTHER

    IF NO.OF.DAYS.BUY.CCY = 0 THEN NO.OF.DAYS.BUY.CCY = 1
    IF NO.OF.DAYS.SELL.CCY = 0 THEN NO.OF.DAYS.SELL.CCY = 1
    RETURN
**</region>

*** <region name= CALC.NOTIONAL.AMTS>
*** <desc>Calculate Notional amounts </desc>
*--------------------------------------------------------------
CALC.NOTIONAL.AMTS:
*---------------------------------------------------------------

* Calculate Notional Amounts for Buy Currency and Sell Currency based on the INT.RATE.BUY and INT.RATE.SELL.
    GOSUB CURRENCY.FORMATS

    NOTIONAL.BUY.AMT=OCONV(ICONV((EB.SystemTables.getRNew(FX.Contract.Forex.AmountBought)/(100+INT.RATE.BUY*NO.OF.DAYS.BUY.CCY/BUY.CCY.BASIS))*100,BUY.FORMAT),BUY.FORMAT)
    NOTIONAL.SELL.AMT = OCONV(ICONV((EB.SystemTables.getRNew(FX.Contract.Forex.AmountSold)/(100+INT.RATE.SELL*NO.OF.DAYS.SELL.CCY/SELL.CCY.BASIS))*100,SELL.FORMAT),SELL.FORMAT)

    RETURN

*** </region>


*** <region name= CURRENCY.FORMATS>
*** <desc>Format the amount </desc>
*--------------------------------------------------------
CURRENCY.FORMATS:
*---------------------------------------------------------
    tmp.LCCY = EB.SystemTables.getLccy()
    LOCAL.FORMAT='' ; EB.DataAccess.Dbr('CURRENCY':@FM:ST.CurrencyConfig.Currency.EbCurNoOfDecimals,tmp.LCCY,LOCAL.FORMAT)
    EB.SystemTables.setLccy(tmp.LCCY)
    LOCAL.FORMAT='MD':LOCAL.FORMAT
    IF EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought)# EB.SystemTables.getLccy() THEN
        BUY.FORMAT='' ; EB.DataAccess.Dbr('CURRENCY':@FM:ST.CurrencyConfig.Currency.EbCurNoOfDecimals,EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought),BUY.FORMAT)
        BUY.FORMAT='MD':BUY.FORMAT
    END ELSE
        BUY.FORMAT=LOCAL.FORMAT
    END
    IF EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold)#EB.SystemTables.getLccy() THEN
        SELL.FORMAT='' ; EB.DataAccess.Dbr('CURRENCY':@FM:ST.CurrencyConfig.Currency.EbCurNoOfDecimals,EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold),SELL.FORMAT)
        SELL.FORMAT='MD':SELL.FORMAT
    END ELSE
        SELL.FORMAT=LOCAL.FORMAT
    END
    RETURN
*** </region>


*** <region name= TO.MODIFY.MAT.ACTIVITY>
*** <desc> Information returned to calling program </desc>
*---------------------------------------------------------------
TO.MODIFY.MAT.ACTIVITY:
*--------------------------------------------------------------
* Revaluation Related Position Classes is generated here.
* The array PM.FX.REVAL.POSN.CLASS is similar in structure to that of MAT.ACTIVITY.
* ASST.LIAB.CD - 1 indicates asset and 2 indicates liability.
* FX:REVAL.TYPE:S -  Spot position class - Buy Currency is a liability and Sell Currency is an asset.
* FX:REVAL.TYPE:M - Maturity Position Class - Buy Currency is an asset and sell Currency is a liability.
*
* Start Posn Classes - Sell
    ROW.COUNT = 1
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 1
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = GAP.SPOT.POSN.CLASS
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = ABS(NOTIONAL.SELL.AMT)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> = INT.RATE.SELL
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = EB.SystemTables.getRNew(FX.Contract.Forex.SpotDate)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnType>=EB.SystemTables.getRNew(FX.Contract.Forex.PositionTypeSell)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCurrency>= EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold)

* Start Posn Classes - Buy

    ROW.COUNT = ROW.COUNT + 1
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 2
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = GAP.SPOT.POSN.CLASS
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = ABS(NOTIONAL.BUY.AMT)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> = INT.RATE.BUY
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = EB.SystemTables.getRNew(FX.Contract.Forex.SpotDate)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnType> = EB.SystemTables.getRNew(FX.Contract.Forex.PositionTypeBuy)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCurrency>= EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought)

* Maturity Posn Classes - Sell

    ROW.COUNT = ROW.COUNT + 1
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 1
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = GAP.MAT.POSN.CLASS
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = ABS(NOTIONAL.BUY.AMT)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> = INT.RATE.BUY
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = VALUE.DATE
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnType> = EB.SystemTables.getRNew(FX.Contract.Forex.PositionTypeBuy)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCurrency>= EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought)

* Maturity Posn Classes - Buy

    ROW.COUNT = ROW.COUNT + 1
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 2
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = GAP.MAT.POSN.CLASS
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = ABS(NOTIONAL.SELL.AMT)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> = INT.RATE.SELL
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = VALUE.DATE
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnType>=EB.SystemTables.getRNew(FX.Contract.Forex.PositionTypeSell)
    PM.FX.REVAL.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCurrency>= EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold)

    RETURN

*** </region>
    END
