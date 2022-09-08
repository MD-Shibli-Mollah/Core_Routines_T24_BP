* @ValidationCode : MjoyMTMyMTkxMTEzOkNwMTI1MjoxNjEwMzk3NzIxNzc4OnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDo0MTozMQ==
* @ValidationInfo : Timestamp         : 12 Jan 2021 02:12:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/41 (75.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SELL.ID.TYPE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine determines whether the customer side is Seller for updation
* in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  If Customer is Seller, then RET.VAL will be 1
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
*** <region name= INSERTS>
*** <desc>Inserts</desc>

    $USING SC.Config
    $USING DX.Trade

*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to determine the customer side is Seller
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>
    
    RET.VAL = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to determine the customer side is Seller for reporting purpose </desc>

    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Seller, then value 1 will be returned
        CASE TXN.ID[1,6] EQ 'SCTRSC'
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO  = TXN.REC<SC.SctTrading.SecTrade.SbsCustomerNo,1>
                GOSUB GET.SELL.ID.TYPE ; *Get the Sell Id Type
            END

* Derivative Txn:
* If the field PRI.BUY.SELL is set as Sell, then the customer mentioned in the field PRI.CUST.NO is considered as Seller,
* else the customer mentioned in the field SEC.CUST.NO is considered as Seller
        CASE TXN.ID[1,5] EQ 'DXTRA'
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO  = TXN.REC<DX.Trade.Trade.TraPriCustNo,1>
            END ELSE
                CUSTOMER.NO  = TXN.REC<DX.Trade.Trade.TraSecCustNo>
            END
            GOSUB GET.SELL.ID.TYPE ; *Get the Sell Id Type
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SELL.ID.TYPE>
GET.SELL.ID.TYPE:
*** <desc>Get the Sell Id Type </desc>
    
    LEI.NCI = ''
    SC.SctTrading.ScdxTrsUpdSellId(TXN.ID,TXN.REC,TXN.DATA,LEI.NCI)
    ID.TYPE = ''
    SC.Config.GetLeiNciIdType(CUSTOMER.NO,LEI.NCI, ID.TYPE)
    BEGIN CASE
        CASE ID.TYPE EQ 'LEI'
            RET.VAL = 1
        CASE ID.TYPE EQ 'MIC'
            RET.VAL = 2
        CASE ID.TYPE EQ 'NIDN'
            RET.VAL = 3
        CASE ID.TYPE EQ 'INTC'
            RET.VAL = 4
        CASE ID.TYPE EQ 'CCPT'
            RET.VAL = 5
        CASE ID.TYPE EQ 'CONCAT'
            RET.VAL = 6
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
