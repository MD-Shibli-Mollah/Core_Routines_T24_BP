* @ValidationCode : MjoyNzU1MjQxMzg6Q3AxMjUyOjE2MTAzNzM5MzI4NTM6cmRlZXBpZ2E6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4yMDIwMTEyOC0wNjMwOjQyOjQx
* @ValidationInfo : Timestamp         : 11 Jan 2021 19:35:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/42 (97.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.BUY.DEC.MKR.NAME2(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine determines whether the customer side is Buyer & Decision maker
* is inputted in the Transaction for updation in SCDX.ARM.MIFID.DATA for reporting purpose
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -  If Customer is Buyer, then RET.VAL will be Last Name of Decision Maker
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
* 06/01/2021 - SI: 4015370/ Enh: 4149404 / Task: 4149408
*              LEI NCI Handling - TRS Reporting
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING DX.Trade
    $USING SC.SctTrading
    $USING ST.CustomerService
    
*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to determine the customer side is Buyer with Decision Maker inputted in txn
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    DECISION.MKR = ''
    CUSTOMER.NO  = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to determine the customer side is Buyer when Decision Maker inputted in txn for reporting purpose </desc>

    GOSUB GET.DECISION.MKR.VALUE ; *Get the Decision Maker value from the Transaction

    IF NOT(DECISION.MKR) THEN
        RETURN ;* When Decision Maker is not mentioned, then ignore the below process
    END

    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Buyer, then Last name of the customer defined in the field DECISION.MKR.ID will be returned
        CASE TXN.ID[1,6] EQ 'SCTRSC'
            IF CUS.SIDE EQ 'B' THEN
                CUSTOMER.NO = DECISION.MKR
            END

* Derivative Txn:
* If PRI.CUST.TYPE is Customer and PRI.BUY.SELL is BUY, then shall populate this field with the Last name of the customer defined in the field DECISION.MKR.ID.
* If SEC.CUST.TYPE is Customer and SEC.BUY.SELL is BUY, then shall populate this field with the Last name of the customer defined in the field DECISION.MKR.ID.
        CASE TXN.ID[1,5] EQ 'DXTRA'
            IF (CUS.SIDE EQ 'B' AND TXN.REC<DX.Trade.Trade.TraPriCustType,1> EQ 'CUSTOMER') OR (CUS.SIDE EQ 'S' AND TXN.REC<DX.Trade.Trade.TraSecCustType> EQ 'CUSTOMER') THEN
                CUSTOMER.NO = DECISION.MKR
            END
    END CASE
    
    GOSUB GET.CUS.NAME2 ; *Get the Last Name for the Customer *
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.DECISION.MKR.VALUE>
GET.DECISION.MKR.VALUE:
*** <desc>Get the Decision Maker value from the Transaction </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ 'SCTRSC'
            DECISION.MKR = TXN.REC<SC.SctTrading.SecTrade.SbsDecisionMkrId>

        CASE TXN.ID[1,5] EQ 'DXTRA'
            DECISION.MKR = TXN.REC<DX.Trade.Trade.TraDecisionMkrId>
    END CASE

* When the Decision maker is mentioned in the format L/N-CustomerNo-LEI/NCI code, fetch the customer from the second part
    IF DECISION.MKR[1,2] MATCHES 'L-':@VM:'N-' THEN
        DECISION.MKR = FIELD(DECISION.MKR,'-',2)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUS.NAME2>
GET.CUS.NAME2:
*** <desc>Get the Last Name for the Customer </desc>

    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.NO, R.CUSTOMER)
    RET.VAL =  R.CUSTOMER<ST.CustomerService.CustomerRecord.name2>

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
