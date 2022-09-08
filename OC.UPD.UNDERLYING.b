* @ValidationCode : MjotMTU0NjEzNTM0MDpjcDEyNTI6MTQ4NzA3NzgwMjc4NTpoYXJyc2hlZXR0Z3I6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjEyLjIwMTYxMTAyLTExNDI6LTE6LTE=
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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.UNDERLYING(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*
*<Routine description>
*
* The routine will determine if type of underlying.
* Attached as a link routine in TX.TXN.BASE.MAPPING record to determine
* the type of the underlying for a contract.
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
* RET.VAL	-	"I"
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:

* For IRS/CIRS the underlying will always be returned as I

    RET.VAL = 'I'

    RETURN
*** </region>


    END

