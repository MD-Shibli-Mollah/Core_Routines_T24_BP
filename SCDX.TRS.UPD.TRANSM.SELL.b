* @ValidationCode : MjotMTQzODk4MjYyOkNwMTI1MjoxNjA0ODM3NTAyNTI3OnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyMDoyMA==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/20 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.TRANSM.SELL(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the LEI of the Broker only for Sell
* transaction to update it in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  LEI of the Broker when the customer is seller
*
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
    $USING SC.SctTrading
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING OC.Parameters
    $USING ST.CustomerService
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    IF CUS.SIDE EQ 'S' THEN
        GOSUB PROCESS       ; *Process to return the LEI of the Broker for Sell transaction
    END
*
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL   = ''
    BROKER.NO = ''
* Determine if the customer is buyer or seller
    CUS.SIDE  = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
        
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return the LEI of Broker for reporting purpose </desc>

* Get the Broker no ie Executing Entity
    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            BROKER.NO = TXN.REC<SC.SctTrading.SecTrade.SbsBrokerNo,1>
        
        CASE TXN.ID[1,5] EQ "DXTRA"
            BROKER.NO  = TXN.REC<DX.Trade.Trade.TraExecutingBroker>
    END CASE

* Get the LEI of the broker    
    LEI = ''
    SC.SctTrading.ScdxTrsGetCusLei(TXN.ID,TXN.REC, BROKER.NO, LEI)
    RET.VAL = LEI

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
