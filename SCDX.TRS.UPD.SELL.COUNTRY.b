* @ValidationCode : MjozNzI0NDE1Mzk6Q3AxMjUyOjE2MDQ4Mzc1MDM4OTk6cmRlZXBpZ2E6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3OjE2OjE2
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SELL.COUNTRY(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the Local Country if the customer is of Seller side
* for updation in SCDX.ARM.MIFID.DATA for reporting purpose
* 
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
* RET.VAL  -  If Customer is Seller, then RET.VAL will hold the Local Country
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING EB.SystemTables
    $USING ST.CompanyCreation
    
*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return the Local Country if Customer is Seller
           
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
*** <desc>Process to return the Local Country if Customer is Seller for reporting purpose </desc>

* Check if the customer is buyer or seller
    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    BEGIN CASE
* Security Txn:
* If the customer mentioned in CUSTOMER.NO is Seller, then Local Country will be returned
        CASE TXN.ID[1,6] EQ "SCTRSC"
            IF CUS.SIDE EQ 'S' THEN
                RET.VAL = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
            END

* Derivative Txn:
* If the field PRI.BUY.SELL is set as Sell, then the customer mentioned in the field PRI.CUST.NO is considered as Seller,
* else the customer mentioned in the field SEC.CUST.NO is considered as Seller
* Henc return the Local Country
        CASE TXN.ID[1,5] EQ "DXTRA"
            RET.VAL = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
