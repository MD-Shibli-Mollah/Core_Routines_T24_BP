* @ValidationCode : Mjo1NDcyNDk4NjM6Y3AxMjUyOjE0ODcwNzc4MDI4NzI6aGFycnNoZWV0dGdyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYxMi4yMDE2MTEwMi0xMTQyOi0xOi0x
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:40:02
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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.PRICE.OR.RATE(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
****<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to
*update the price or rate.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val -"999999999999999.99999"
*
*-----------------------------------------------------------------------------
* Modification History :
**
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*
*-----------------------------------------------------------------------------

    RET.VAL = "999999999999999.99999"

    RETURN

    END
