* @ValidationCode : MjoyMDU0NzMyMDkwOkNwMTI1MjoxNTkyNTcwOTY5NTMzOnN0aGVqYXN3aW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToxOToxMw==
* @ValidationInfo : Timestamp         : 19 Jun 2020 18:19:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/19 (68.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.QUANTITY(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
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
* Ret.val - 1
* For a DX trade return the values in the below priority order
* PRI.LOTS
* CONTRACT.SIZE
* LB.PRINCIPAL (for Swaptions)
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
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
            BEGIN CASE
                CASE APPL.REC<DX.Trade.Trade.TraPriLots> NE ''
                    RET.VAL = APPL.REC<DX.Trade.Trade.TraPriLots>
                CASE APPL.REC<DX.Trade.Trade.TraContractSize> NE ''
                    RET.VAL = APPL.REC<DX.Trade.Trade.TraPriLots>
                CASE APPL.REC<DX.Trade.Trade.TraLbPrincipal>  NE ''
                    RET.VAL = APPL.REC<DX.Trade.Trade.TraLbPrincipal>
            END CASE
        CASE 1
            RET.VAL = 1;*quantity will be returned as 1
    END CASE

RETURN
*** </region>
END
