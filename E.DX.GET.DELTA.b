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
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE E.DX.GET.DELTA
*-----------------------------------------------------------------------------
* Program Description
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/03/06 - BG_100010587
*            Use EB.READ.PARAMETER to read the DX.PARAMETER file. For Muilti Book consistency.
*
* 21/06/06 - EN_10002981
*          - Remove DX.PRICE from DX module.
*
* 01/03/12 - Defect-365067 / Task-365070
*            Enquiry DX.PHAC.BRWS not returning the correct delta value
*            due to the change in key of market price record
*
* 16/05/12 - Defect-365067 / Task-406502
*            Enquiry DX.PHAC.BRWS not returning the correct delta value
*            when executed through scripting
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*-----------------------------------------------------------------------------
    $USING DX.Configuration
    $USING DX.Position
    $USING DX.Pricing
    $USING DX.Trade
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING EB.Reports
*-----------------------------------------------------------------------------

    GOSUB INITIALISE

    GOSUB MAIN.PROCESS

    EB.Reports.setOData(DELTA)

    RETURN

*-----------------------------------------------------------------------------
INITIALISE:

* Local variables

    tmp.O.DATA = EB.Reports.getOData()
    RECALCULATE.DELTA = FIELD(tmp.O.DATA,'_',1)
    DELTA = ''

* Parameters for DX.GET.MARKET.PRICE - incoming

    MARKET.PRICE = ''
    EXT.MARKET.PRICE = ''
    R.DX.PRICE.LOCAL = ''
    RETURN.CODE = ''

* Parameters for DX.GET.MARKET.PRICE - outgoing

    DX.REP.POSITION.ID = FIELD(tmp.O.DATA,'_',2)
    CONTROL.VAR = ''
    MAT.DATE = EB.SystemTables.getToday()

*BG_100010587 S
    DX.PARAMETER.ID = 'SYSTEM'
    FN.DX.PARAMETER.LOCAL = 'F.DX.PARAMETER'
    F.DX.PARAMETER.LOCAL  = ''
    R.DX.PARAMETER.LOCAL = ''
    YERR = ''
    ST.CompanyCreation.EbReadParameter( FN.DX.PARAMETER.LOCAL, 'N', '', R.DX.PARAMETER.LOCAL, DX.PARAMETER.ID, F.DX.PARAMETER.LOCAL, YERR)
*BG_100010587 E
* Determine if CURRENT or CLOSING prices to be used
    IF NOT(YERR) THEN
        PRICE.SET.LOCAL = R.DX.PARAMETER.LOCAL<DX.Configuration.Parameter.ParOnlinePriceSet>
    END ELSE
        PRICE.SET.LOCAL = 'CURRENT' ;* Assume CURRENT if DX.PARAMETER record not read
    END

    RETURN

*-----------------------------------------------------------------------------
MAIN.PROCESS:

* Determine if we need to recalculate or not

    IF UPCASE(RECALCULATE.DELTA) # 'Y' THEN
        CONTROL.VAR = 'NO'
    END

* Read DX.REP.POSITION record

    R.DX.REP.POSITION.LOCAL = ''
    YERR = ''

    R.DX.REP.POSITION.LOCAL = DX.Position.RepPosition.Read(DX.REP.POSITION.ID, YERR)

* Before incorporation : CALL F.READ(tmp.FN.DX.REP.POSITION,DX.REP.POSITION.ID,R.DX.REP.POSITION,tmp.F.DX.REP.POSITION,YERR)

    IF NOT(YERR) THEN
        CONTRACT.ID = R.DX.REP.POSITION.LOCAL<DX.Position.RepPosition.RpContract>
        STRIKE = R.DX.REP.POSITION.LOCAL<DX.Position.RepPosition.RpStrikePrice>
        CALL.OR.PUT = R.DX.REP.POSITION.LOCAL<DX.Position.RepPosition.RpCallPut>
        DX.TRANSACTION.IDS = R.DX.REP.POSITION.LOCAL<DX.Position.RepPosition.RpTransactionIds>

        DX.TRANSACTION.ID = DX.TRANSACTION.IDS<1,1>

        * Read underlying DX.TRANSACTION record

        R.DX.TRANSACTION = ''
        YERR = ''

        R.DX.TRANSACTION = DX.Trade.Transaction.Read(DX.TRANSACTION.ID, YERR)
        * Before incorporation : CALL F.READ(tmp.FN.DX.TRANSACTION,DX.TRANSACTION.ID,R.DX.TRANSACTION,tmp.F.DX.TRANSACTION,YERR)

        IF NOT(YERR) THEN

            * Call DX.GET.MARKET.PRICE to retrieve DELTA

            DX.Pricing.GetMarketPrice(PRICE.SET.LOCAL,CONTRACT.ID,MAT.DATE,STRIKE,CALL.OR.PUT,MARKET.PRICE,EXT.MARKET.PRICE,R.DX.PRICE.LOCAL,R.DX.TRANSACTION,CONTROL.VAR,RETURN.CODE)

            * Read direct from DX.MARKET.PRICE

            DX.MARKET.PRICE.ID = PRICE.SET.LOCAL:':'
            DX.MARKET.PRICE.ID:= FIELD(DX.REP.POSITION.ID,':',2)
            DX.MARKET.PRICE.ID:= ':'

            R.DX.MARKET.PRICE = DX.Pricing.MarketPrice.Read(DX.MARKET.PRICE.ID, YERR)
            * Before incorporation : CALL F.READ(tmp.FN.DX.MARKET.PRICE,DX.MARKET.PRICE.ID,R.DX.MARKET.PRICE,tmp.F.DX.MARKET.PRICE,YERR)

            DELTA = R.DX.MARKET.PRICE<DX.Pricing.MarketPrice.MktDelta>
        END
    END

    RETURN

*-----------------------------------------------------------------------------
*
    END
