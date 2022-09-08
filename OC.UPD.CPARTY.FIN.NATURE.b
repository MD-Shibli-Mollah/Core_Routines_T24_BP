* @ValidationCode : MjoxNTE5NDIwNTc1OmNwMTI1MjoxNDg3MDc4NDk5NDU3OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.CPARTY.FIN.NATURE(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to update the Financial nature of
*T24 bank in transaction database.It retruns a value of "F" as T24 bank is always financial
*in nature.
*
**
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - "F".
*
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*
*-----------------------------------------------------------------------------

    RET.VAL = 'F';*returns "F" as t24 bank is financial in nature.

    RETURN

    END
