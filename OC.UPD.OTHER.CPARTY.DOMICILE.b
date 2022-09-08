* @ValidationCode : MjotMjMwNjE5OTg5OkNwMTI1MjoxNTM5MjMzODY4Mzc2OmhhcnJzaGVldHRncjozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEwLjIwMTgwOTA2LTAyMzI6MjY6MjY=
* @ValidationInfo : Timestamp         : 11 Oct 2018 10:27:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.OTHER.CPARTY.DOMICILE(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
******
*<Routine desc>
*
*The routine can be attached as LINK routine in tax mapping record
*to update domicile of deal cparty.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - " " or Street
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

    $INSERT I_CustomerService_NameAddress

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
*** <desc>Initialise the variables </desc>

    RET.VAL = ''
    CUSTOMER.ID = ''


    R.OC.CUSTOMER = ''
    READ.ERR = ''
    customerNameAddress=''
    responseDetails=''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    BEGIN CASE
        CASE APPL.ID[1,2] = "FX"
            CUSTOMER.ID = APPL.REC<FX.Contract.Forex.Counterparty>
        CASE APPL.ID[1,2] = "ND"
            CUSTOMER.ID = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
        CASE APPL.ID[1,2] = "SW"
            CUSTOMER.ID = APPL.REC<SW.Contract.Swap.Customer>
    END CASE

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(CUSTOMER.ID, READ.ERR);*read oc.customer record
* Before incorporation : CALL F.READ(FN.OC.CUSTOMER, CUSTOMER.ID, R.OC.CUSTOMER, F.OC.CUSTOMER, READ.ERR);*read oc.customer record

    READ.ERR = ''

    IF R.OC.CUSTOMER<ST.Customer.OcCustomer.CusIdType> NE 'LEI' THEN;*if id type is not equal to LEI
        CALL CustomerService.getNameAddress(CUSTOMER.ID,'', customerNameAddress)

        RET.VAL =customerNameAddress<NameAddress.street>;*return the street fromn customer record.

    END

RETURN
*** </region>

END


