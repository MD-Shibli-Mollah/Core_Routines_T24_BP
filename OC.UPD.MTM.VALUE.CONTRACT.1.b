* @ValidationCode : MjoxMDQyOTk4OTkyOkNwMTI1MjoxNTkxODczNTgxMTAxOnN0aGVqYXN3aW5pOjk6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTo5Mzo3NA==
* @ValidationInfo : Timestamp         : 11 Jun 2020 16:36:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 74/93 (79.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655 
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.MTM.VALUE.CONTRACT.1(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
*
* The routine returns the MTM value of contract(FX,ND,SW,FRA AND DX.TRADE for own book reporting.
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*
* 11/7/16 - Defect 1523549 / Task 1562086
*			MTM value 1 & MTM value 2 updation in OC.VAL.COLL.DATA enquiry.
*
* 27/02/20 - Enhancement 3562855 / Task 3562856
*            MTM value changes in FRA for EMIR-Phase2
*
* 27/02/20 - Enhancement 3568609 / Task 3568610
*            MTM value changes in SW for the EMIR-Phase2.
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
* 08/06/2020 - Enhancement 3715904 / Task 3786684
*              EMIR changes for DX
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $USING EB.SystemTables
    $USING EB.API
    $USING SW.Contract
    $USING FR.Contract
    $USING FR.Config
    $USING FR.PositionAndReval
    $USING AC.CurrencyPosition
    $USING FX.Contract
    $USING OC.Reporting
    $USING EB.DataAccess
    $USING DX.Pricing
    $INSERT I_DAS.POS.TRANSACTION

*** </region>
*-----------------------------------------------------------------------------
*** <region name= main body>
*** <desc>main body </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------

*** </region>
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Open the files </desc>

    RET.VAL=''
    READ.ERR=''
    CURR.MKT=''
    POSITION.TYPE=''
    DEALER.DESK=''
    SET.CCY=''
    DEAL.CCY=''
    VAL.DATE=''
    R.POS.TRANSACTION = ''
    syDxMarketValId = ''
    syDxMarketValRec = ''

RETURN

*** </region>
*-----------------------------------------------------------------------------
***<region name= PROCESS>
PROCESS:
*** <desc>PROCESS  </desc>


    BEGIN CASE

        CASE TXN.ID[1,2] EQ 'SW'
            SWAP.BALANCES.ID = TXN.ID:'.A'

            R.SWAP.BALANCES = SW.Contract.SwapBalances.Read(SWAP.BALANCES.ID,READ.ERR)
* Before incorporation : CALL F.Read(FN.SWAP.BALANCES,SWAP.BALANCES.ID,R.SWAP.BALANCES,F.SWAP.BALANCES,READ.ERR)

            IF NOT (READ.ERR) THEN
                NotionalValue = 0
                OC.Reporting.UpdNotionalAmount(TXN.ID,TXN.REC,TXN.DATA,NotionalValue) ;*Get the notional value for the SWAP deals.
                IF R.SWAP.BALANCES<SW.Contract.SwapBalances.BalNotional> EQ 'Y' THEN ;*IRS deal types
                    RET.VAL = TXN.REC<SW.Contract.Swap.FwdRevalAmount> + NotionalValue  ;*fetch the reval amount and add the value of Notional from the routine OC.UPD.NOTIONAL.AMOUNT
                END ELSE
                    RET.VAL=TXN.REC<SW.Contract.Swap.FwdRevalPlLcy> + NotionalValue ;*CIRS deal types..fetch the reval ProfitLoss and add the value of Notional from the routine OC.UPD.NOTIONAL.AMOUNT
                END
            END

        CASE TXN.ID[1,2] EQ 'FX'

            KEY.LIST = dasPosTransaction$ID
            THE.ARGS = TXN.ID:'...'
            DAS.TABLE.SUFFIX = '' ;* live table
            EB.DataAccess.Das('POS.TRANSACTION',KEY.LIST,THE.ARGS,DAS.TABLE.SUFFIX)

            IF KEY.LIST THEN
                LOOP
                    REMOVE ID FROM KEY.LIST SETTING MORE
                WHILE ID:MORE

                    R.POS.TRANSACTION = AC.CurrencyPosition.PosTransaction.Read(ID,READ.ERR)
*Before incorporation : F.Read(FN.POS.TRANSACTION,ID,R.POS.TRANSACTION,F.POS.TRANSACTION,READ.ERR)
                    IF NOT (READ.ERR) THEN

                        TODATE.LCY.AMT.1= R.POS.TRANSACTION<AC.CurrencyPosition.PosTransaction.PosTxnTodateLcyAmtOne>
                        TODATE.LCY.AMT.2= R.POS.TRANSACTION<AC.CurrencyPosition.PosTransaction.PosTxnTodateLcyAmtTwo>

                        TOTAL.AMT = TODATE.LCY.AMT.1+TODATE.LCY.AMT.2

                        RET.VAL += TOTAL.AMT ;*sum of unrealised profit and loss in both currencies.
                    END
                REPEAT
            END


        CASE TXN.ID[1,2] EQ 'DX'
* For a DX.TRADE, fetch MTM.AMOUNT field from the corresponding SYDX.MARKET.VAL record
            syDxMarketValId = TXN.ID:'_':EB.SystemTables.getToday()
            syDxMarketValRec = DX.Pricing.MarketVal.Read(syDxMarketValId, '')
        
            IF syDxMarketValRec AND syDxMarketValRec<DX.Pricing.MarketVal.MktMtmAmount> NE '' THEN
                RET.VAL = syDxMarketValRec<DX.Pricing.MarketVal.MktMtmAmount>
            END


        CASE TXN.ID[1,2] EQ 'ND'

            GOSUB FETCH.ID.ELEMENTS;*get nd.deal details.

            IF TXN.REC<FX.Contract.NdDeal.NdDealBuySellInd> = "BUY" THEN
                ND.POS.ID = TXN.ID:'-':CURR.MKT:POSITION.TYPE:DEALER.DESK:SET.CCY:DEAL.CCY:VAL.DATE;*form the pos.txn id for nd.deal
            END ELSE
                ND.POS.ID = TXN.ID:'-':CURR.MKT:POSITION.TYPE:DEALER.DESK:DEAL.CCY:SET.CCY:VAL.DATE;*form the pos.txn id for nd.deal
            END

            R.POS.TRANSACTION = AC.CurrencyPosition.PosTransaction.Read(ND.POS.ID, READ.ERR);*read the pos.txn record.
* Before incorporation : CALL F.READ("F.POS.TRANSACTION",ND.POS.ID,R.POS.TRANSACTION,tmp.F.POS.TRANSACTION,READ.ERR);*read the pos.txn record.


            IF NOT (READ.ERR) THEN

                TODATE.LCY.AMT.1= R.POS.TRANSACTION<AC.CurrencyPosition.PosTransaction.PosTxnTodateLcyAmtOne>
                TODATE.LCY.AMT.2= R.POS.TRANSACTION<AC.CurrencyPosition.PosTransaction.PosTxnTodateLcyAmtTwo>
                DealAmount = ''
                DealAmount = TXN.REC<FX.Contract.NdDeal.NdDealDealAmount>
                RET.VAL = TODATE.LCY.AMT.1+TODATE.LCY.AMT.2 + DealAmount ;*sum of unrealised profit and loss in both currencies and add the deal amount from the contract.

            END



        CASE TXN.ID[1,2] EQ 'FR'

            tmp.ID.COMPANY = EB.SystemTables.getIdCompany()
            R.FRA.PARAMETER = FR.Config.FraParameter.Read(tmp.ID.COMPANY, READ.ERR);*read FRA.PARAMETER record.
* Before incorporation : CALL F.READ("F.FRA.PARAMETER",tmp.ID.COMPANY,R.FRA.PARAMETER,F.FRA.PARAMETER,READ.ERR);*read FRA.PARAMETER record.
            EB.SystemTables.setIdCompany(tmp.ID.COMPANY)

            IF R.FRA.PARAMETER<FR.Config.FraParameter.FrpTrDealWiseReval> EQ 'YES' THEN;*if deal wise revaluation is set

                IF TXN.REC<FR.Contract.FraDeal.FrdFraType> EQ 'TRADE' THEN;*for trade type FRA deals


                    R.FRA.POSITION = FR.PositionAndReval.FraPosition.Read(TXN.ID, READ.ERR);*read FRA POSITION records.
* Before incorporation : CALL F.READ("F.FRA.POSITION",TXN.ID,R.FRA.POSITION,tmp.F.FRA.POSITION,READ.ERR);*read FRA POSITION records.

                    RET.VAL =  R.FRA.POSITION<FR.PositionAndReval.FraPosition.FrnTotalReval> + TXN.REC<FR.Contract.FraDeal.FrdFraAmount> ;*fetch the total reval field value and add the value from the contract-FRA.DEAL AMOUNT.

                    IF RET.VAL EQ '' THEN;*if total reval is null,then refer old deal P&L.
                        RET.VAL=R.FRA.PARAMETER<FR.PositionAndReval.FraPosition.FrnOldDealPandl> + TXN.REC<FR.Contract.FraDeal.FrdFraAmount> ;*fetch the old P&L and add the value from the contract-FRA.DEAL AMOUNT.
                    END

                END ELSE;*For hedge type deals


                    R.FRA.HEDGE.POSITION = FR.PositionAndReval.FraHedgePosition.Read(TXN.ID, READ.ERR);*read FRA.HEDGE.POSITION
* Before incorporation : CALL F.READ("F.FRA.HEDGE.POSITION",TXN.ID,tmp.F.FRA.HEDGE.POSITION,R.FRA.HEDGE.POSITION,READ.ERR);*read FRA.HEDGE.POSITION

                    RET.VAL = R.FRA.HEDGE.POSITION<FR.PositionAndReval.FraHedgePosition.FrhRevalProfitLoss> + TXN.REC<FR.Contract.FraDeal.FrdFraAmount> ;*fetch the value from REVAL.PROFIT.LOSS field and add the value from the contract-FRA.DEAL AMOUNT.

                END

            END


    END CASE

RETURN

FETCH.ID.ELEMENTS:
*********************
    CURR.MKT = TXN.REC<FX.Contract.NdDeal.NdDealCurrencyMarket> ;* Assign currency market
    POSITION.TYPE = TXN.REC<FX.Contract.NdDeal.NdDealPositionType> ;* Assign position type
    DEALER.DESK = TXN.REC<FX.Contract.NdDeal.NdDealDealerDesk> ;* Assign dealer desk
    SET.CCY = TXN.REC<FX.Contract.NdDeal.NdDealSettlementCcy> ;* Assign settlement currency
    DEAL.CCY = TXN.REC<FX.Contract.NdDeal.NdDealDealCurrency> ;* Assign deal currency
    VAL.DATE = TXN.REC<FX.Contract.NdDeal.NdDealValueDate> ;* Assign value date

RETURN

END

