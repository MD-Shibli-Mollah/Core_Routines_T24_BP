* @ValidationCode : MjoyMDk0MTY1MTA6Q3AxMjUyOjE2MTAzODcxMDQ4NTU6cmRlZXBpZ2E6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4yMDIwMTEyOC0wNjMwOjUwOjUw
* @ValidationInfo : Timestamp         : 11 Jan 2021 23:15:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 50/50 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SELL.DEC.MKR.TYPE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
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
* RET.VAL  -  If Decision maker is inputted & Customer is Seller,
*             then RET.VAL will be 1
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
    $USING SC.Config
    
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

    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Seller, then value 1 will be returned
        CASE TXN.ID[1,6] EQ 'SCTRSC'
            IF CUS.SIDE EQ 'S' THEN
                GOSUB GET.SELL.DEC.MKR.TYPE ; *Get the Seller decision maker Id Type
            END

* Derivative Txn:
* If the field PRI.BUY.SELL is set as SELL, then the customer mentioned in the field PRI.CUST.NO is considered as Seller,
* else the customer mentioned in the field SEC.CUST.NO is considered as Seller
        CASE TXN.ID[1,5] EQ 'DXTRA'
            IF (CUS.SIDE EQ 'S' AND TXN.REC<DX.Trade.Trade.TraPriCustType,1> EQ 'CUSTOMER') OR (CUS.SIDE EQ 'B' AND TXN.REC<DX.Trade.Trade.TraSecCustType> EQ 'CUSTOMER') THEN
                GOSUB GET.SELL.DEC.MKR.TYPE ; *Get the Seller decision maker Id Type
            END
    END CASE
    
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
*** <region name= GET.SELL.DEC.MKR.TYPE>
GET.SELL.DEC.MKR.TYPE:
*** <desc>Get the Sell Decision maker Id Type </desc>
    
    LEI.NCI = ''
    SC.SctTrading.ScdxTrsUpdSellDecMkrCode(TXN.ID,TXN.REC,TXN.DATA,LEI.NCI)
    ID.TYPE = ''
    SC.Config.GetLeiNciIdType(DECISION.MKR,LEI.NCI, ID.TYPE)
    BEGIN CASE
        CASE ID.TYPE EQ 'LEI'
            RET.VAL = 1
        CASE ID.TYPE EQ 'NIDN'
            RET.VAL = 2
        CASE ID.TYPE EQ 'CCPT'
            RET.VAL = 3
        CASE ID.TYPE EQ 'CONCAT'
            RET.VAL = 4
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
