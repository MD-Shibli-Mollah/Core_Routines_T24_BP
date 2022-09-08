* @ValidationCode : MjotNjE0OTkzMjk1OmNwMTI1MjoxNDg3MDc4NDk5NDY0OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:51:39
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

    SUBROUTINE OC.UPD.CONFIRMATION.TIMESTAMP(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* For FOREX contract, it returns the value of CONFIRMED BY BROKER or CONFIRM BY CPTY.
* For SWAP contract, return value is CONFIRM.BY.CUST
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
* Ret.val- Variable holding the value of CONFIRMED BY BROKER or CONFIRM BY CPTY.
*
*
*******************************************************************

    $USING FX.Contract
    $USING SW.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB DETERMINE.FOR.T24.BANK

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    RET.VAL=''

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
DETERMINE.FOR.T24.BANK:
*** <desc>PROCESS </desc>

* For FOREX contract,return value is CONFIRMD.BY.BROKER or CONF.BY.CPARTY
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'FX'
            IF APPL.REC<FX.Contract.Forex.ConfirmdByBroker> NE '' THEN
                RET.VAL = APPL.REC<FX.Contract.Forex.ConfirmdByBroker>
            END ELSE
                RET.VAL = APPL.REC<FX.Contract.Forex.ConfByCparty>
            END
            * For SWAP contract,return value is CONFIRM.BY.CUST
        CASE APPL.ID[1,2] EQ 'SW'
            IF APPL.REC<SW.Contract.Swap.ConfirmByCust> NE '' THEN
                RET.VAL = APPL.REC<SW.Contract.Swap.ConfirmByCust>
            END

    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------
    END
