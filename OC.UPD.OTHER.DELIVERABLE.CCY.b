* @ValidationCode : MjotMTI0MTI1NTk4MzpjcDEyNTI6MTQ4NzA3NzgwMzM4NjpoYXJyc2hlZXR0Z3I6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjEyLjIwMTYxMTAyLTExNDI6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:40:03
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

    SUBROUTINE OC.UPD.OTHER.DELIVERABLE.CCY(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the deliverable currency for delegated report.
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
* RET.VAL	-	CCY Asset currency of a SWAP contract
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*-----------------------------------------------------------------------------
    $USING SW.Contract
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

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
PROCESS:
*** <desc>PROCESS </desc>

    RET.VAL = APPL.REC<SW.Contract.Swap.AsCurrency>

    RETURN
*** </region>

*-----------------------------------------------------------------------------
    END
