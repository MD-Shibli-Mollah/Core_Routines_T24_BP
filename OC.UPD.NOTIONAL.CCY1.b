* @ValidationCode : MjotMzY2MDY1ODQwOmNwMTI1MjoxNDg3MDc3ODA0MTY5OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.NOTIONAL.CCY1(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the notional currency for bank's own reporting.
*
*
* Incoming parameters:
*
* APPL.ID	-	Transaction ID of the contract.
* APPL.REC	-	A dynamic array holding the contract.
* FIELD.POS	-	Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* RET.VAL	-	For IRS transactions, underlying currency.
*
*				For Currency Interest Rate Swaps, base currency
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING SW.Contract
    $USING SW.Foundation
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    GOSUB PROCESS


    RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:

    RET.VAL = ''

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:

    IF SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNotional> = 'Y' THEN
        RET.VAL = APPL.REC<SW.Contract.Swap.AsCurrency>
    END ELSE
        RET.VAL = APPL.REC<SW.Contract.Swap.BaseCurrency>
    END


    RETURN
    END
