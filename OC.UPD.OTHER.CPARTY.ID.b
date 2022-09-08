* @ValidationCode : MjoxOTM2NzcyMzc3OkNwMTI1MjoxNTkyMzExOTQ1MzM0OnN0aGVqYXN3aW5pOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTozNToyNg==
* @ValidationInfo : Timestamp         : 16 Jun 2020 18:22:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/35 (74.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.OTHER.CPARTY.ID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns LEI id else NATIONAL id from the table OC.CUSTOMER.
* This is the common routine for the FX,ND,SWAP,FRA and DX.
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
* 
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- returns LEI id else NATIONAL id from the table OC.CUSTOMER.
*
*
*******************************************************************
* Modification History :
*-----------------------------------------------------------------------------
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
* 08/06/2020 - Enhancement 3715904 / Task 3786684
*              EMIR changes for DX
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING FR.Contract
    $USING ST.Customer
    $USING FX.Contract
    $USING SW.Contract
    $USING DX.Trade

    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    CustomerId = ""
    DxCustomerIds = ""
    OcCustomerRec = ""
    LeiId = ""
    NationalId = ""
    RET.VAL = ""


RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
    
        CASE APPL.ID[1,2] = 'FX'
            CustomerId = APPL.REC<FX.Contract.Forex.Counterparty>
        
        CASE APPL.ID[1,2] = 'SW'
            CustomerId = APPL.REC<SW.Contract.Swap.Customer>
    
        CASE APPL.ID[1,2] = 'FR'
            CustomerId = APPL.REC<FR.Contract.FraDeal.FrdCounterparty>
            
        CASE APPL.ID[1,2] = 'ND'
            CustomerId = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
            
        CASE APPL.ID[1,2] = 'DX'
            DxCustomerIds = APPL.REC<DX.Trade.Trade.TraPriCustNo>
            CustomerId = DxCustomerIds<1,1>
    END CASE

    IF CustomerId THEN
        OcCustomerRec = ST.Customer.OcCustomer.Read(CustomerId, Error)
        LeiId = OcCustomerRec<ST.Customer.OcCustomer.CusLegalEntityId>
        NationalId = OcCustomerRec<ST.Customer.OcCustomer.CusNationalId>
    
        BEGIN CASE
        
            CASE LeiId
                RET.VAL = LeiId
            
            CASE NationalId
                RET.VAL = NationalId
            
        END CASE
    END
   
RETURN
*** </region>

END


