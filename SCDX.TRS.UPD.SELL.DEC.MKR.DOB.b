* @ValidationCode : MjotMjMzODYyMTQ2OkNwMTI1MjoxNjEwMzk3NzIxNDQ2OnJkZWVwaWdhOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDo0NDo0NA==
* @ValidationInfo : Timestamp         : 12 Jan 2021 02:12:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 44/44 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SELL.DEC.MKR.DOB(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine determines whether the customer side is Seller & Decision maker
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
* RET.VAL  -  If Customer is Seller, then RET.VAL will be Date of Birth of Decision Maker
*
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
    $USING EB.Delivery
    $USING SC.SctTrading
    $USING SC.ScoFoundation
    $USING ST.CustomerService
    
*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to determine the customer side is Seller with Decision Maker inputted in txn
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    DECISION.MKR = ''
    CUSTOMER.NO  = ''
* Check if EW is installed
    EW.INSTALLED = ''
    EB.Delivery.ValProduct("EW","","",EW.INSTALLED,"")
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to determine the customer side is Seller when Decision Maker inputted in txn for reporting purpose </desc>

    GOSUB GET.DECISION.MKR.VALUE ; *Get the Decision Maker value from the Transaction

    IF NOT(DECISION.MKR) THEN
        RETURN ;* When Decision Maker is not mentioned, then ignore the below process
    END

* Check if the customer is Buyer or seller
    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    
    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Seller, then Date of Birth of the customer defined in the field DECISION.MKR.ID will be returned
        CASE TXN.ID[1,6] EQ 'SCTRSC'
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO = DECISION.MKR
            END

* Derivative Txn:
* If PRI.CUST.TYPE is Customer and PRI.BUY.SELL is SELL, then shall populate this field with the Date of Birth of the customer defined in the field DECISION.MKR.ID.
* If SEC.CUST.TYPE is Customer and SEC.BUY.SELL is SELL, then shall populate this field with the Date of Birth of the customer defined in the field DECISION.MKR.ID.
        CASE TXN.ID[1,5] EQ 'DXTRA'
            IF (CUS.SIDE EQ 'S' AND TXN.REC<DX.Trade.Trade.TraPriCustType,1> EQ 'CUSTOMER') OR (CUS.SIDE EQ 'B' AND TXN.REC<DX.Trade.Trade.TraSecCustType> EQ 'CUSTOMER') THEN
                CUSTOMER.NO = DECISION.MKR
            END
    END CASE
    
    GOSUB GET.CUS.DOB ; *Get the Date of Birth for the Customer *
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
*** <region name= GET.CUS.DOB>
GET.CUS.DOB:
*** <desc>Get the Date of Birth for the Customer </desc>

    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.NO, R.CUSTOMER)
    RET.VAL =  R.CUSTOMER<ST.CustomerService.CustomerRecord.dateOfBirth>

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
