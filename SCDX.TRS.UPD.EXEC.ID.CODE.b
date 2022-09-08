* @ValidationCode : MjoxNzcwODQyNzI0OkNwMTI1MjoxNjA0ODM3NTAzNDQ4OnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyMzoyMw==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/23 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.EXEC.ID.CODE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the investment firm indicator to update it
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
* RET.VAL  -  LEI of the Broker
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
    GOSUB PROCESS       ; *Process to return the Investment firm indicator
           
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
*** <desc>Process to return the investment firm indicator for reporting purpose </desc>

* Get the Broker no ie Executing Entity
    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            BROKER.NO = TXN.REC<SC.SctTrading.SecTrade.SbsBrokerNo,1>
        
        CASE TXN.ID[1,5] EQ "DXTRA"
            BROKER.NO  = TXN.REC<DX.Trade.Trade.TraExecutingBroker>
    END CASE
    
    LEI = ''
    SC.SctTrading.ScdxTrsGetCusLei(TXN.ID,TXN.REC, BROKER.NO, LEI)
    GOSUB GET.BANK.LEI  ; *Get the BANK.LEI from the OC.PARAMETER

    RET.VAL = LEI

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.BANK.LEI>
GET.BANK.LEI:
*** <desc>Get the BANK.LEI from the OC.PARAMETER </desc>

    IF LEI THEN
        RETURN
    END

* Check whether there is any BANK.LEI defined in OC.PARAMETER
    OC.PARAM.ERR = '' ; OC.PARAM.REC = ''
    ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', 'N', '', OC.PARAM.REC, '', '', OC.PARAM.ERR)
    LEI = OC.PARAM.REC<OC.Parameters.OcParameter.ParamBankLei>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
