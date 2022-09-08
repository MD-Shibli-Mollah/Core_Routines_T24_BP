* @ValidationCode : MjotMTQyNjkwODI0OTpjcDEyNTI6MTQ4NzA3ODQ5OTQ3ODpoYXJyc2hlZXR0Z3I6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjEyLjIwMTYxMTAyLTExNDI6LTE6LTE=
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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.CONFIRMATION.MEANS(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report method of confirmation of the contract.
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
* RET.VAL	-	If confirmed by customer then E, else N
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING SW.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*-----------------------------------------------------------------------------

INITIALISE:
    RET.VAL = ''
    RETURN

*-----------------------------------------------------------------------------

PROCESS:
*If confirmed by customer then E, else N

    IF APPL.ID[1,2] EQ 'SW' AND APPL.REC<SW.Contract.Swap.ConfirmByCust> NE '' THEN
        RET.VAL = 'E'
    END ELSE
        RET.VAL = 'N'
    END

    RETURN

*-----------------------------------------------------------------------------

    END
