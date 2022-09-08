* @ValidationCode : MjotMzYxMjM5MTYxOmNwMTI1MjoxNDg3MDc4NDk4ODk4OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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

    SUBROUTINE OC.UPD.FIXED.RATE.DAY.COUNT(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the day count basis on the fixed leg of the contract.
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
* RET.VAL	-	Day count basis on the Fixed leg of the contract
*				If T24 Bank is seller, the day count basis of asset leg
*				Else liability leg
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------


    $USING OC.Reporting
    $USING SW.Contract
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALIZE:

    RET.VAL = ''

    RETURN
*-----------------------------------------------------------------------------

PROCESS:
* Both IRS and CIRS
* Day count basis on the Fixed leg of the contract

* If T24 Bank is seller, the day count basis of asset leg

    OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)

    IF CPARTY.SIDE = 'S' THEN
        RET.VAL = APPL.REC<SW.Contract.Swap.AsBasis>
    END

    IF CPARTY.SIDE='B' THEN
        RET.VAL = APPL.REC<SW.Contract.Swap.LbBasis>
    END

    RETURN
*-----------------------------------------------------------------------------
    END
