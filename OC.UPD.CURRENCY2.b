* @ValidationCode : MjotMTE2NDQ0MDQxNTpjcDEyNTI6MTU5MTg3MzU4MDE0ODpzdGhlamFzd2luaTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjEyLjIwMTYxMTAyLTExNDI6NDE6NDE=
* @ValidationInfo : Timestamp         : 11 Jun 2020 16:36:20
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/41 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.CURRENCY2(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* For FOREX, it returns Non-base ccy if it is not same as Deliverable otherwise Blank.
* For SWAP, applicable for CIRS Contracts
* It returns Non-base ccy if it is not same as Deliverable otherwise Blank.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING SW.Contract
    $USING FX.Contract
    $USING ST.CurrencyConfig
    $USING SW.Foundation


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
* Ret.val- Variable holding the value of CURRENCY2 field.
*
*
*******************************************************************

    GOSUB INITIALISE
    GOSUB CHECK.CURRENCY2

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
CHECK.CURRENCY2:
*** <desc>PROCESS </desc>


    BEGIN CASE
            * For FOREX, it returns Non-base ccy if it is not same as Deliverable otherwise Blank.

        CASE APPL.ID[1,2] EQ 'FX';*Sort the 2 currencies alphabetically.

            CURRENCY<1> =APPL.REC<FX.Contract.Forex.CurrencyBought>;*fetch currency bought and sold
            CURRENCY<2> =APPL.REC<FX.Contract.Forex.CurrencySold>

            IF APPL.REC<FX.Contract.Forex.Quantity> EQ '' THEN;*for currency forex
                SORT.CURRENCY = SORT(CURRENCY);*sort the 2 currencies
                DELIVERABLE.CURRENCY = SORT.CURRENCY<1>;*first ccy is deliverable ccy


                BASE.CCY =APPL.REC<FX.Contract.Forex.BaseCcy>;*fetch base ccy

                IF BASE.CCY EQ APPL.REC<FX.Contract.Forex.CurrencyBought> THEN;*determine non base ccy
                    NON.BASE.CCY =APPL.REC<FX.Contract.Forex.CurrencySold>
                END ELSE
                    NON.BASE.CCY = APPL.REC<FX.Contract.Forex.CurrencyBought>
                END

                IF NON.BASE.CCY NE DELIVERABLE.CURRENCY THEN;*if non base ccy not equal to delievrable ccy
                    RET.VAL = NON.BASE.CCY;*then return non base ccy
                END

            END


            * For SWAP, applicable for CIRS Contracts
            * It returns Non-base ccy if it is not same as Deliverable otherwise Blank.
        CASE APPL.ID[1,2] EQ 'SW';*Sort the 2 currencies alphabetically.

            IF SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNotional> = 'NO' THEN
                CURRENCY<1> = APPL.REC<SW.Contract.Swap.AsCurrency>
                CURRENCY<2> = APPL.REC<SW.Contract.Swap.LbCurrency>
                SORT.CURRENCY = SORT(CURRENCY);*sort the 2 currencies.
                DELIVERABLE.CURRENCY = SORT.CURRENCY<1>;*first ccy is deliverable ccy.


                BASE.CCY =APPL.REC<SW.Contract.Swap.BaseCurrency>;*fetch base ccy

                IF BASE.CCY EQ APPL.REC<SW.Contract.Swap.AsCurrency> THEN;*determine non base ccy
                    NON.BASE.CCY =APPL.REC<SW.Contract.Swap.LbCurrency>
                END ELSE
                    NON.BASE.CCY = APPL.REC<SW.Contract.Swap.AsCurrency>
                END

                IF NON.BASE.CCY NE DELIVERABLE.CURRENCY THEN;*if non base ccy not equal to deliverable ccy
                    RET.VAL = NON.BASE.CCY;*then return non base ccy
                END

            END

    END CASE


    RETURN
*** </region>

*-----------------------------------------------------------------------------

    END
