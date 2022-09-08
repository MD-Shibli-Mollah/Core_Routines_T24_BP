* @ValidationCode : MjoxMjEyNTcxOTA6Y3AxMjUyOjE0ODcwNzg0OTg5NDU6aGFycnNoZWV0dGdyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYxMi4yMDE2MTEwMi0xMTQyOi0xOi0x
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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.EXCH.RATE.BASIS(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine desc>
*
* The routine will be attached as a LINK routine in tax mapping record
*to update exch rate basis.It determines the base ccy and non base ccy
*of a OTC application.
**
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - base.ccy/non base ccy
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING FX.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *

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

        CASE APPL.ID[1,2] EQ 'FX'

            BASE.CCY =APPL.REC<FX.Contract.Forex.BaseCcy>

            IF BASE.CCY EQ APPL.REC<FX.Contract.Forex.CurrencyBought> THEN
                NON.BASE.CCY =APPL.REC<FX.Contract.Forex.CurrencySold>
            END ELSE
                NON.BASE.CCY = APPL.REC<FX.Contract.Forex.CurrencyBought>
            END


        CASE APPL.ID[1,2] EQ 'ND'

            BASE.CCY=APPL.REC<FX.Contract.NdDeal.NdDealBaseCurrency>

            IF BASE.CCY EQ APPL.REC<FX.Contract.NdDeal.NdDealDealCurrency> THEN
                NON.BASE.CCY=APPL.REC<FX.Contract.NdDeal.NdDealSettlementCcy>
            END ELSE
                NON.BASE.CCY=APPL.REC<FX.Contract.NdDeal.NdDealDealCurrency>
            END


    END CASE

    RET.VAL = BASE.CCY:"/":NON.BASE.CCY

    RETURN
*** </region>

    END


