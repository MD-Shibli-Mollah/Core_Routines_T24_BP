* @ValidationCode : MjoxNzYzNTkzMTc5OkNwMTI1MjoxNjEwMzg3MTAzMzQ0OnJkZWVwaWdhOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDozNjozNg==
* @ValidationInfo : Timestamp         : 11 Jan 2021 23:15:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SELL.ID(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the LEI of the Customer if the customer is of Sell side
* for updation in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  If Customer is Seller, then RET.VAL will hold the LEI of Customer
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
    $USING SC.SctTrading
    
*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return the LEI of the customer if Customer is Seller
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    CUSTOMER.NO = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return the LEI of the customer if Customer is Seller for reporting purpose </desc>

* Check if the customer is Buyer or seller
    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)

    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Seller, then LEI of that customer will be populated
        CASE TXN.ID[1,6] EQ "SCTRSC"
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO  = TXN.REC<SC.SctTrading.SecTrade.SbsCustomerNo,1>
                CUST.LEI.NCI = TXN.REC<SC.SctTrading.SecTrade.SbsCustomerLeiNci,1>
            END

* Derivative Txn:
* If the field PRI.BUY.SELL is set as Sell, then LEI of the customer specified in the field PRI.CUST.NO shall be populated
* else LEI of the customer specified in the field SEC.CUST.NO shall be populated.
        CASE TXN.ID[1,5] EQ "DXTRA"
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO  = TXN.REC<DX.Trade.Trade.TraPriCustNo,1>
                CUST.LEI.NCI = TXN.REC<DX.Trade.Trade.TraPriCustLeiNci,1>
            END ELSE
                CUSTOMER.NO  = TXN.REC<DX.Trade.Trade.TraSecCustNo>
                CUST.LEI.NCI = TXN.REC<DX.Trade.Trade.TraSecCustLeiNci>
            END
    END CASE
        
    GOSUB GET.CUS.LEI ; *Get the LEI of the customer
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUS.LEI>
GET.CUS.LEI:
*** <desc>Get the LEI of the customer </desc>
    
    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END

* If the field CUST.LEI.NCI holds value, then fetch either NCI or LEI code from that field (Third Part)
    RET.VAL = FIELD(CUST.LEI.NCI,'-',3)
    IF RET.VAL THEN
        RETURN
    END
    
    LEI = ''
    SC.SctTrading.ScdxTrsGetCusLei(TXN.ID,TXN.REC,CUSTOMER.NO,LEI)
    RET.VAL = LEI

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
