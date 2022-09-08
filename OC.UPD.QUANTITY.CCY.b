* @ValidationCode : MjotMjk1MDAzOTM4OkNwMTI1MjoxNTkyNTY5MTIyMTIxOnN0aGVqYXN3aW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToxMjoxMg==
* @ValidationInfo : Timestamp         : 19 Jun 2020 17:48:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/12 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.QUANTITY.CCY(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
****<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to
*update the QUANTITY.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val - For a DX.TRADE, return null when Quantity taken from PRI.LOTS or CONTRACT.SIZE fields.
* consider LB.CURRENCY (for Swaptions where LB.PRINCIPAL is considered for QUANTITY)
*-----------------------------------------------------------------------------
* Modification History :
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
*-----------------------------------------------------------------------------
    $USING DX.Trade

*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    RET.VAL=''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'DX'
            IF APPL.REC<DX.Trade.Trade.TraPriLots> EQ '' AND APPL.REC<DX.Trade.Trade.TraContractSize> EQ '' AND APPL.REC<DX.Trade.Trade.TraLbCurrency> NE '' THEN
                RET.VAL = APPL.REC<DX.Trade.Trade.TraLbCurrency>
            END
    END CASE
RETURN
*** </region>
END
