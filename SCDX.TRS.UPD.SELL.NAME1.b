* @ValidationCode : MjotMTI2OTU0OTc0MjpDcDEyNTI6MTYwNDgzNzQ5OTU2MDpyZGVlcGlnYTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6Mjk6Mjk=
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SELL.NAME1(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the First Name of customer if the customer is of Sell side
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
* RET.VAL  -  If Customer is Seller, then RET.VAL will hold the First Name of customer
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING DX.Trade
    $USING ST.CustomerService
    $USING SC.SctTrading
    
*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return the First Name of customer if Customer is Seller
           
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
*** <desc>Process to return the First Name of customer if Customer is Seller for reporting purpose </desc>

    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Seller, then first Name of that customer will be populated
        CASE TXN.ID[1,6] EQ "SCTRSC"
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO = TXN.REC<SC.SctTrading.SecTrade.SbsCustomerNo,1>
            END

* Derivative Txn:
* If the field PRI.BUY.SELL is set as Sell, then first Name of the customer specified in the field PRI.CUST.NO shall be populated
* else first Name of the customer specified in the field SEC.CUST.NO shall be populated.
        CASE TXN.ID[1,5] EQ "DXTRA"
            IF CUS.SIDE EQ 'S' THEN
                CUSTOMER.NO  = TXN.REC<DX.Trade.Trade.TraPriCustNo,1>
            END ELSE
                CUSTOMER.NO  = TXN.REC<DX.Trade.Trade.TraSecCustNo>
            END
    END CASE
    
    GOSUB GET.CUS.FIRST.NAME ; *Get the first name of the customer 
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUS.FIRST.NAME>
GET.CUS.FIRST.NAME:
*** <desc>Get the first name of the customer </desc>
    
    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.NO, R.CUSTOMER)
    RET.VAL =  R.CUSTOMER<ST.CustomerService.CustomerRecord.name1>

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
