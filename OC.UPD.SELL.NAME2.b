* @ValidationCode : Mjo4NDMzOTY1Nzg6Q3AxMjUyOjE1OTk2NDUwODY1NTk6a2JoYXJhdGhyYWo6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjU1OjU1
* @ValidationInfo : Timestamp         : 09 Sep 2020 15:21:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 55/55 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.SELL.NAME2(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* If NATIONAL.ID is populated in field SELLER.ID then fetch NAME.2 from CUSTOMER table for the counterparty
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - NAME.2/NULL
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660945 / Task 3660948
*            CI#4 - Mapping Routines - Part II
*
* 13/04/20 - Enhancement 3661787 / Task 3661793
*            CI#4 - Mapping Routines - Part III
*
* 14/04/20 - Enhancement 3689608 / Task 3689612
*            CI#4 - Mapping routines - Part III
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 28/08/20 - Enhancement 3793949 / Task 3793955
*            CI#4 - Mapping routines - Part III
*-----------------------------------------------------------------------------

    $USING ST.Config
    $USING EB.SystemTables
    $USING OC.Parameters
    $USING FR.Contract
    $USING SW.Contract
    $USING FX.Contract
    $USING ST.Customer
    $USING DX.Trade
*-----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    NATIONAL.ID = ''
    RET.VAL = ''
    OcCustomerRec = ''
    CustomerId = ''
    NationalIdFromCustomer = ''
    CustomerRec = ''
    Name2 = ''
    MifidReportStatus = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
*Invoke OC.UPD.SELL.ID to get the return value and determine whether it is National id or not.
    OC.Reporting.UpdSellId(APPL.ID,APPL.REC,FIELD.POS,NATIONAL.ID)
    IF NATIONAL.ID THEN
        BEGIN CASE
    
            CASE APPL.ID[1,2] = 'SW'
                CustomerId = APPL.REC<SW.Contract.Swap.Customer>
                MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
    
            CASE APPL.ID[1,2] = 'FR'
                CustomerId = APPL.REC<FR.Contract.FraDeal.FrdCounterparty>
                MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
            CASE APPL.ID[1,2] = 'ND'
                CustomerId = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
                MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
                                
            CASE APPL.ID[1,2] = 'DX'
                CustomerId = APPL.REC<DX.Trade.Trade.TraPriCustNo>
                MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
                CustomerId = CustomerId<1,1>
                
            CASE APPL.ID[1,2] = 'FX'
                CustomerId = APPL.REC<FX.Contract.Forex.Counterparty>
                MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
        END CASE
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
        IF MifidReportStatus EQ "NEWT" THEN
            GOSUB ASSIGN.NAME.2.FROM.CUSTOMER ; *
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ASSIGN.NAME.2.FROM.CUSTOMER>
ASSIGN.NAME.2.FROM.CUSTOMER:
*** <desc> </desc>
    IF CustomerId THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(CustomerId, OcCusErr)
        IF OcCustomerRec THEN
            NationalIdFromCustomer = OcCustomerRec<ST.Customer.OcCustomer.CusNationalId>
        END
        
        IF NATIONAL.ID EQ NationalIdFromCustomer THEN ;*To Check if the NATIONAL.ID is present in the field SELLER.ID
            CusErr = ''
            CustomerRec = ST.Customer.Customer.CacheRead(CustomerId, CusErr)
            IF CustomerRec THEN
                Name2 = CustomerRec<ST.Customer.Customer.EbCusNameTwo>
                IF Name2 THEN
                    RET.VAL = Name2
                END
            END
        END
    END
    
RETURN
*** </region>

END




