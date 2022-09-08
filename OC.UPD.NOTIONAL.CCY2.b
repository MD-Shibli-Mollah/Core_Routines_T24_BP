* @ValidationCode : MjoxMjkyMjk0NjA0OmNwMTI1MjoxNDg3MDc3ODA0MTYxOmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.NOTIONAL.CCY2(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* FOREX - It returns Non Base currency of the contract.
* For SWAP, only CIRS applicable -  Non base currency is returned
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------
*******************************************************************
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- Variable holding the value of NOTIONAL CCY2 field.
*
*
*******************************************************************

    $USING FX.Contract
    $USING SW.Contract
    $USING SW.Foundation

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN


*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

    RET.VAL=''

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> determine the base and non base ccy</desc>

    BEGIN CASE
            * FOREX - It returns Non Base currency of the contract.
        CASE APPL.ID[1,2] EQ 'FX'

            BASE.CCY =APPL.REC<FX.Contract.Forex.BaseCcy>

            IF BASE.CCY EQ APPL.REC<FX.Contract.Forex.CurrencyBought> THEN
                RET.VAL = APPL.REC<FX.Contract.Forex.CurrencySold>
            END ELSE
                RET.VAL = APPL.REC<FX.Contract.Forex.CurrencyBought>
            END

            * For SWAP, only CIRS applicable
            * Non base currency is returned
        CASE APPL.ID[1,2] = 'SW'

            IF SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNotional> = 'NO' THEN
                IF APPL.REC<SW.Contract.Swap.AsCurrency> = APPL.REC<SW.Contract.Swap.BaseCurrency> THEN
                    RET.VAL = APPL.REC<SW.Contract.Swap.LbCurrency>
                END ELSE
                    RET.VAL = APPL.REC<SW.Contract.Swap.AsCurrency>
                END
            END

    END CASE

    RETURN
*** </region>

    END
