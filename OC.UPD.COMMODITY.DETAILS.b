* @ValidationCode : Mjo2MjA2ODY1NzY6Y3AxMjUyOjE0ODcwNzg0OTk0ODU6aGFycnNoZWV0dGdyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYxMi4yMDE2MTEwMi0xMTQyOi0xOi0x
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

    SUBROUTINE OC.UPD.COMMODITY.DETAILS(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns details of the particular commodity.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------
************************************************************************************************
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- Variable holding the value of "PR" for Gold,silver,platinum,rhodium,palladium and osml
* 			and for rest update with 'NP'
*
*
**************************************************************************************************

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

* For commodity contracts,if Metal type is Gold,silver,platinum,rhodium,palladium or osml update with "PR" and for rest "NP".
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'FX'
            IF APPL.REC<FX.Contract.Forex.Quantity> NE '' THEN
                IF APPL.REC<FX.Contract.Forex.MetalType> EQ "GOLD" OR APPL.REC<FX.Contract.Forex.MetalType> EQ "SILV" OR APPL.REC<FX.Contract.Forex.MetalType> EQ "PALL" OR APPL.REC<FX.Contract.Forex.MetalType> EQ "PLAT"  OR APPL.REC<FX.Contract.Forex.MetalType> EQ "RHOD" OR APPL.REC<FX.Contract.Forex.MetalType> EQ "OSMI" THEN
                    RET.VAL = "PR"
                END ELSE
                    RET.VAL = "NP"
                END
            END
    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------
    END

