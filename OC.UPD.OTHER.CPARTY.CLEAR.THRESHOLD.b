* @ValidationCode : MjozNDc5MzYyMTpDcDEyNTI6MTUzOTIzMzg2ODM0NTpoYXJyc2hlZXR0Z3I6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMC4yMDE4MDkwNi0wMjMyOjI5OjI5
* @ValidationInfo : Timestamp         : 11 Oct 2018 10:27:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.OTHER.CPARTY.CLEAR.THRESHOLD (APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*****
*<Routine desc>
*
*The routine can be attached as LINK routine in tax mapping record
*to determine clearing threshold of deal cparty.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - "Y" if clear threshold set to ABOVE else "N"

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
*** <desc>initialise the variables </desc>

    RET.VAL = ''

    COUNTERPARTY = ''
    R.OC.CUSTOMER = ''
    READ.ERR = ''
    CLEARING.THRESHOLD = ''
    FIN.CPARTY=''

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

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(COUNTERPARTY, READ.ERR);*read oc.customer record
* Before incorporation : CALL F.READ(FN.OC.CUSTOMER, COUNTERPARTY, R.OC.CUSTOMER, F.OC.CUSTOMER, READ.ERR);*read oc.customer record

    FIN.CPARTY = R.OC.CUSTOMER<ST.Customer.OcCustomer.CusFinancialCparty>;*fetch financial info of customer

    IF FIN.CPARTY EQ 'NO' THEN

        CLEARING.THRESHOLD = R.OC.CUSTOMER<ST.Customer.OcCustomer.CusClearingThreshold>;*extract clearing threshold

        IF CLEARING.THRESHOLD EQ "ABOVE" THEN;*if set to above,then return yes
            RET.VAL = "Y"
        END ELSE
            RET.VAL = "N"
        END

    END

RETURN
*** </region>

END


