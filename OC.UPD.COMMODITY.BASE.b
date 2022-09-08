* @ValidationCode : MjoyNjMwMDMzMDg6Y3AxMjUyOjE0ODcwNzg0OTk0OTE6aGFycnNoZWV0dGdyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYxMi4yMDE2MTEwMi0xMTQyOi0xOi0x
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
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.COMMODITY.BASE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It retruns the type of commodity underlying the contract.
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
* Ret.val- Variable holding the value of "ME" incase of precious Metal.
*
*
*******************************************************************

    $USING FX.Contract
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

* For Precious Metal currency update with "ME".
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'FX'
            IF APPL.REC<FX.Contract.Forex.Quantity> NE '' THEN
                RET.VAL = "ME"
            END
    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------
    END
