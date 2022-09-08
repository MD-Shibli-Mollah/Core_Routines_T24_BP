* @ValidationCode : MjoxODQ4NzEyMTM0OmNwMTI1MjoxNDg3MDc3ODA0MTgxOmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:40:04
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.NOTIONAL.AMOUNT(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* FOREX - It returns the Amount corresponding to Notional Currency 1
* For SWAP Contracts
* IRS 	- 	The principal amount from the Asset/Liab leg
* CIRS 	- 	The principal amount corresponding to the
*			BASE ccy from the SWAP balances record.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- Variable holding the value of NOTIONAL Amount.
*
*
*******************************************************************

    $USING FX.Contract
    $USING SW.Contract
    $USING ST.CurrencyConfig
    $USING SW.Foundation

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB DETERMINE.FOR.T24.BANK

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    CURRENCY=''
    RET.VAL=''
    N.CCY = ''


    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
DETERMINE.FOR.T24.BANK:
*** <desc>PROCESS </desc>


    BEGIN CASE
            * FOREX - For Commodity Forwards & Commodity Swaps, Amount  expressed in currency should be returned.
        CASE APPL.ID[1,2] EQ 'FX'

            CURRENCY<1> =APPL.REC<FX.Contract.Forex.CurrencyBought>
            CURRENCY<2> =APPL.REC<FX.Contract.Forex.CurrencySold>

            IF APPL.REC<FX.Contract.Forex.Quantity> EQ '' THEN

                IF APPL.REC<FX.Contract.Forex.BaseCcy> EQ CURRENCY<1> THEN
                    RET.VAL = APPL.REC<FX.Contract.Forex.AmountBought>
                END ELSE
                    RET.VAL = APPL.REC<FX.Contract.Forex.AmountSold>
                END

            END ELSE

                ST.CurrencyConfig.GetCurrencyRecord('',CURRENCY<1>,R.CURRENCY,READ.ERR)


                IF R.CURRENCY<ST.CurrencyConfig.Currency.EbCurPreciousMetal> EQ "YES" THEN
                    RET.VAL = APPL.REC<FX.Contract.Forex.AmountBought>
                END ELSE
                    RET.VAL = APPL.REC<FX.Contract.Forex.AmountSold>
                END
            END
            * For SWAP Contracts
            * IRS 	- 	The principal amount from the Asset/Liab leg
            * CIRS 	- 	The principal amount corresponding to the
            *			BASE ccy from the SWAP balances record.
        CASE APPL.ID[1,2] = 'SW'

            IF SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNotional> = 'Y' THEN
                N.CCY = APPL.REC<SW.Contract.Swap.AsCurrency>
                RET.VAL = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalPrincipal>
            END ELSE
                N.CCY = APPL.REC<SW.Contract.Swap.BaseCurrency>
                IF APPL.REC<SW.Contract.Swap.AsCurrency> = N.CCY THEN
                    RET.VAL = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalPrincipal>
                END ELSE
                    RET.VAL = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalPrincipal>
                END
            END

    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------


    END
