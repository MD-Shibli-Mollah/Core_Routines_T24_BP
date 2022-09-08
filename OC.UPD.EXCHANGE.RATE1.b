* @ValidationCode : Mjo2NTgyNDE1NDI6Q3AxMjUyOjE0ODcwNzkxNzUzMjM6aGFycnNoZWV0dGdyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 19:02:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-34</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.EXCHANGE.RATE1(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the exchange rate used in the contract.
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
* Ret.val	-	Applicable only for CIRS contracts
*				The INITIAL.XRATE field from the SWAP.BALANCES
*				of the applicable leg will be returned.
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

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:

    RET.VAL = ''
    SWAP.BAL.ID = ''
    SW.BAL.REC = ''

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
* Applicable only for CIRS contracts

    IF SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNotional> = 'NO' THEN
        GOSUB LEGTYPE
        * Form the SWAP.BALANCES record ID from the APPL.ID and the leg type
        SWAP.BAL.ID = APPL.ID : '.' : LEG.TYPE

        SWAP.BAL.REC = SW.Contract.SwapBalances.Read(SWAP.BAL.ID, SW.BAL.ERR)
        * Before incorporation : CALL F.READ(FN.SWAP.BALANCES,SWAP.BAL.ID,SWAP.BAL.REC,F.SWAP.BALANCES,SW.BAL.ERR)

        IF NOT(SW.BAL.ERR) THEN
            * Fetch the INITIAL.XRATE from balances record.
            RET.VAL = SWAP.BAL.REC<SW.Contract.SwapBalances.BalInitialXrate>
        END
    END

    RETURN
*-----------------------------------------------------------------------------

LEGTYPE:
* To identify the leg type
    IF APPL.REC<SW.Contract.Swap.AsCurrency> = APPL.REC<SW.Contract.Swap.BaseCurrency> THEN
        LEG.TYPE = 'A'
    END ELSE
        LEG.TYPE = 'L'
    END
    RETURN

*-----------------------------------------------------------------------------
    END
