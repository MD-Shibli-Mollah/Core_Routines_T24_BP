* @ValidationCode : MjoyMDkyMjgwNjU3OmNwMTI1MjoxNDg3MDc4NDk4OTY4OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:51:38
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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.DELIVERABLE.CCY(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* For FOREX-It returns alphabetically sorted first CURRENCY and for Commodity contracts,
* the settlement currency i.e the currency which is used in the contract.
* For SWAP 	- IRS, it returns the underlying currency
*			- CIRS, it returns the base currency
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
* Ret.val- Variable holding the value of DELIVERABLE CURRENCY field.
*
*
*******************************************************************
    $USING SW.Contract
    $USING FX.Contract
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

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
DETERMINE.FOR.T24.BANK:
*** <desc>PROCESS </desc>


    BEGIN CASE
            * FOREX-
            * For all type of Currency FX / FX Swaps, the currency which is first when the two currencies are sorted  alphabetically.
            * For ex: in EUR/USD deal, EUR comes first and the same is deliverable currency.
            *For Commodity contracts, the settlement currency i.e the currency which is used in the contract.

        CASE APPL.ID[1,2] EQ 'FX';*Sort the 2 currencies alphabetically.

            CURRENCY<1> = APPL.REC<FX.Contract.Forex.CurrencyBought>
            CURRENCY<2> = APPL.REC<FX.Contract.Forex.CurrencySold>

            IF APPL.REC<FX.Contract.Forex.Quantity> EQ '' THEN
                SORT.CURRENCY = SORT(CURRENCY)
                CURRENCY.1 = SORT.CURRENCY<1>

                RET.VAL = CURRENCY.1

            END ELSE

                ST.CurrencyConfig.GetCurrencyRecord('',CURRENCY<1>,R.CURRENCY,READ.ERR)

                IF R.CURRENCY<ST.CurrencyConfig.Currency.EbCurPreciousMetal> EQ "YES" THEN
                    RET.VAL = CURRENCY<2>
                END ELSE
                    RET.VAL = CURRENCY<1>
                END
            END

    END CASE


    RETURN
*** </region>

*-----------------------------------------------------------------------------
    END
