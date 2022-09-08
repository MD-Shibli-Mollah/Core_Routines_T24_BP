* @ValidationCode : Mjo2MzQ3MTY1Njg6Q3AxMjUyOjE1MzkyMzM4NjgyMTQ6aGFycnNoZWV0dGdyOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MDYtMDIzMjoyNToyNQ==
* @ValidationInfo : Timestamp         : 11 Oct 2018 10:27:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/25 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.OTHER.CPARTY.FIN.NATURE(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
**<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to update the Financial nature of
*deal cparty in transaction database.
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
*Ret.val - "F" for financial cparty.
*        - "N" for non financial cparty.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
* 08/10/18 - Enh 2789746 / Task 2789749
*            Changing OC.Parameters to ST.Customer to access OC.CUSTOMER
*
*-----------------------------------------------------------------------------
*

    $USING FX.Contract
    $USING SW.Contract
    $USING OC.Parameters
    $USING ST.Customer

*-----------------------------------------------------------------------------

    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc>Initialise the variables</desc>

    RET.VAL = ''

    COUNTERPARTY = ''
    R.OC.CUSTOMER = ''
    READ.ERR = ''
    FIN.PARTY = ''

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    BEGIN CASE
        CASE APPL.ID[1,2] = "FX"
            COUNTERPARTY = APPL.REC<FX.Contract.Forex.Counterparty>
        CASE APPL.ID[1,2] = "ND"
            COUNTERPARTY = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
        CASE APPL.ID[1,2] = "SW"
            COUNTERPARTY = APPL.REC<SW.Contract.Swap.Customer>
    END CASE

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(COUNTERPARTY, READ.ERR);*read oc.customer
* Before incorporation : CALL F.READ(FN.OC.CUSTOMER, COUNTERPARTY, R.OC.CUSTOMER, F.OC.CUSTOMER, READ.ERR);*read oc.customer

    FIN.PARTY = R.OC.CUSTOMER<ST.Customer.OcCustomer.CusFinancialCparty>;*fetch financial cparty

    IF FIN.PARTY EQ "YES" THEN;*if financial cparty,then return F
        RET.VAL = "F"
    END ELSE
        RET.VAL = "N"
    END

RETURN
*** </region>

END



