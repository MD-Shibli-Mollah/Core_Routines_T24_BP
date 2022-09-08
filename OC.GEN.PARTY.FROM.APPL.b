* @ValidationCode : MjotMzY2NzQwOTUzOkNwMTI1MjoxNTQxNzYwNjY5OTIwOmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MDYtMDIzMjotMTotMQ==
* @ValidationInfo : Timestamp         : 09 Nov 2018 16:21:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>242</Rating>
*-----------------------------------------------------------------------------

$PACKAGE OC.Parameters
SUBROUTINE OC.GEN.PARTY.FROM.APPL(MODULE.NAME , DEAL.CPARTY , BANK.CPARTY , GENERATING.CPARTY , Reserved1 , Reserved2)
*-----------------------------------------------------------------------------
* Routine to identify the generating party when both the deal counterparty and T24 bank are of the same priority
* Incoming parameters
*                    MODULE.NAME - Name of the application
*                    DEAL.CPARTY - Deal counterparty
*                    BANK.CPARTY - T24 Bank
* Outgoing parameters
*                    GENERATING.CPARTY - Generating party
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*-----------------------------------------------------------------------------
* 07/06/06 - EN_923925
*            Swap clearing phase 1 - Unique transaction identifier
*
* 30/12/15 - EN_1226121 / Task 1568411
*            Incorporation of the routine
*
* 08/10/18 - Enh 2789746 / Task 2789749
*            Changing OC.Parameters to ST.Customer to access OC.CUSTOMER
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main section>


    $USING EB.SystemTables
    $USING EB.API
    $USING FX.Contract
    $USING FR.Contract
    $USING SW.Contract
    $USING FX.Foundation
    $USING FX.Config
    $USING ST.CompanyCreation
    $USING OC.Parameters
    $USING EB.DataAccess
    $USING ST.Customer



    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
***
    ERR1 = ''
    ERR2 = ''

    FN.FX.PARAMETERS = "F.FX.PARAMETERS"
    F.FX.PARAMETERS = ""
    EB.DataAccess.Opf(FN.FX.PARAMETERS ,F.FX.PARAMETERS)

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(DEAL.CPARTY, ERR1)
* Before incorporation : CALL F.READ('F.OC.CUSTOMER',DEAL.CPARTY,R.OC.CUSTOMER,tmp.F.OC.CUSTOMER,ERR1)

    tmp.FX.PARAMETERS.REC = FX.Foundation.getParametersRec()
    tmp.FX.PARAMETERS.REC = FX.Config.Parameters.Read('FX.PARAMETERS', ERR2)
* Before incorporation : CALL F.READ("F.FX.PARAMETERS",'FX.PARAMETERS',tmp.FX.PARAMETERS.REC,F.FX.PARAMETERS,ERR2)
    FX.Foundation.setParametersRec(tmp.FX.PARAMETERS.REC)

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
PROCESS:
***
* To identify the generating party when the deal counterparty and T24 customer are of the same priority .
    BEGIN CASE

        CASE MODULE.NAME EQ 'ND.DEAL'

            BUY.SELL.IND = EB.SystemTables.getRNew(FX.Contract.NdDeal.NdDealBuySellInd)

            IF BUY.SELL.IND EQ 'BUY' THEN ;* Bank is the generating party when buy sell indicator is 'BUY'
                GENERATING.CPARTY = BANK.CPARTY
            END ELSE
                GENERATING.CPARTY = DEAL.CPARTY ;* Deal counterparty is the generating party when buy sell indicator is 'SELL'
            END

        CASE MODULE.NAME EQ 'SWAP'

            BEGIN CASE

                CASE (EB.SystemTables.getRNew(SW.Contract.Swap.AsRateKey) AND EB.SystemTables.getRNew(SW.Contract.Swap.LbRateKey)) OR (EB.SystemTables.getRNew(SW.Contract.Swap.AsRateKey) EQ '' AND EB.SystemTables.getRNew(SW.Contract.Swap.LbRateKey) EQ '') ;* Both legs are fixed/float
                    BANK.LEI = OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamBankLei>
                    CUSTOMER.LEI = R.OC.CUSTOMER<ST.Customer.OcCustomer.CusLegalEntityId>
                    LEI<1> = BANK.LEI
                    LEI<2> = CUSTOMER.LEI
                    SORT.LEI = SORT(LEI)
                    REQ.LEI = SORT.LEI<2> ;* Reversed ASCII sort of BANK LEI and CUSTOMER LEI
                    IF REQ.LEI EQ BANK.LEI THEN
                        GENERATING.CPARTY = BANK.CPARTY ;* Bank is the generating party when its LEI is greater than counterparty's LEI
                    END ELSE
                        GENERATING.CPARTY = DEAL.CPARTY ;* Deal counterparty is the generating party when its LEI is greater than bank's LEI
                    END

                CASE EB.SystemTables.getRNew(SW.Contract.Swap.AsRateKey) NE ''  ;* LB leg is fixed
                    GENERATING.CPARTY = BANK.CPARTY ;* Bank is the generating party when LB leg is fixed
                CASE EB.SystemTables.getRNew(SW.Contract.Swap.LbRateKey) NE ''  ;* AS leg is fixed
                    GENERATING.CPARTY = DEAL.CPARTY ;* Deal counterparty is the generating party when AS leg is fixed
            END CASE
        CASE MODULE.NAME EQ 'FOREX'


            PRECIOUS.METAL.BUY = 0
            PRECIOUS.METAL.SELL = 0

            TEMP = FX.Foundation.getParametersRec()
            LOCATE EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold) IN TEMP<FX.Config.Parameters.PPreciousMetals,1> SETTING POS THEN
                PRECIOUS.METAL.SELL = 1
            END

            LOCATE EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought) IN TEMP<FX.Config.Parameters.PPreciousMetals,1> SETTING POS THEN
                PRECIOUS.METAL.BUY = 1
            END

            BEGIN CASE

                CASE PRECIOUS.METAL.SELL
                    GENERATING.CPARTY = BANK.CPARTY ;* Bank is the generating party when a metal is on the sell side

                CASE PRECIOUS.METAL.BUY
                    GENERATING.CPARTY = DEAL.CPARTY ;* Deal counterparty is the generating party when a metal is on the buy side

                CASE 1

                    CURRENCY<1> = EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought)
                    CURRENCY<2> = EB.SystemTables.getRNew(FX.Contract.Forex.CurrencySold)
                    SORT.CURRENCY = SORT(CURRENCY)
                    CURRENCY.1 = SORT.CURRENCY<1>

                    IF CURRENCY.1 EQ EB.SystemTables.getRNew(FX.Contract.Forex.CurrencyBought) THEN
                        GENERATING.CPARTY = DEAL.CPARTY
                    END ELSE
                        GENERATING.CPARTY = BANK.CPARTY
                    END
            END CASE

        CASE MODULE.NAME EQ 'FRA.DEAL'

            IF EB.SystemTables.getRNew(FR.Contract.FraDeal.FrdPurchaseSale) EQ 'PURCHASE' THEN
                GENERATING.CPARTY = BANK.CPARTY ;* Bank is the generating party when the deal is for purchase
            END ELSE
                GENERATING.CPARTY = DEAL.CPARTY ;* Deal counterparty is the generating party when the deal is for sale
            END
    END CASE

RETURN
END
*** </region>
