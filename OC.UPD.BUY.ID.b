* @ValidationCode : MjotMjY1Njk3ODQwOkNwMTI1MjoxNTk5NDc2MjM4OTk0OmtiaGFyYXRocmFqOjk6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo3Njo3MQ==
* @ValidationInfo : Timestamp         : 07 Sep 2020 16:27:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 71/76 (93.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.BUY.ID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* If transaction is BUY - LEI code of the bank
* If transaction in SELL - Counterparty's LEGAL.ENTITY Id from OC.CUSTOMER, if not present fetch NATIONAL.ID
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - BANK.LEI/LEI of customer/ NATIONAL.ID of customer.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
* 02/04/20 - Enhancement - 3661703 / Task - 3661706
*            CI#2 Mapping Routines Part-1
*
* 14/04/20 - Enhancement 3689595 / Task 3689597
*            CI#2 - Mapping routines - Part I
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 28/08/20 - Enhancement 3793912/ Task 3793913
*            CI#2 - Mapping routines - Part I
*-----------------------------------------------------------------------------

    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING OC.Parameters
    $USING SW.Contract
    $USING FR.Contract
    $USING FX.Contract
    $USING ST.Customer
    $USING OC.Reporting
    $USING DX.Trade
    
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    CPARTY.SIDE = ''
    OcParamId = ''
    OcParamRec = ''
    LeiId = ''
    NationalId = ''
    BankLei = ''
    OcCustomerRec= ''
    CustomerId = ''
    RET.VAL = ''
    MifidReportStatus = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    BEGIN CASE
        
        CASE (APPL.ID[1,2] EQ 'SW')
*Invoke OC.UPD.CPARTY.SIDE to determine whether its a buy or sell transaction
            OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
        CASE APPL.ID[1,2] EQ "ND"
*Invoke OC.UPD.CPARTY.SIDE to determine whether its a buy or sell transaction
            OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
            MifidReportStatus = APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
        CASE APPL.ID[1,2] EQ "FR"
*Invoke OC.UPD.CPARTY.SIDE to determine whether its a buy or sell transaction
            OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
        CASE APPL.ID[1,2] EQ "DX"
*Invoke OC.UPD.CPARTY.SIDE to determine whether its a buy or sell transaction
            OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
                       
        CASE APPL.ID[1,2] EQ "FX"
*Invoke OC.UPD.CPARTY.SIDE to determine whether its a buy or sell transaction
            OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
            
    END CASE
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
    IF MifidReportStatus EQ "NEWT" THEN
        IF CPARTY.SIDE EQ "B" THEN
            GOSUB GET.BANK.LEI ; * Get the bank lei from the OC.PARAMETER
        END ELSE
            GOSUB GET.CUSTOMER.LEI.OR.NATIONAL.ID ; *Get the Customer lei or national id from the OC.CUSTOMER.
        END
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.CUSTOMER.LEI.OR.NATIONAL.ID>
GET.CUSTOMER.LEI.OR.NATIONAL.ID:
*** <desc> </desc>

    BEGIN CASE
    
        CASE APPL.ID[1,2] = 'SW'
            CustomerId = APPL.REC<SW.Contract.Swap.Customer>
    
        CASE APPL.ID[1,2] = 'FR'
            CustomerId = APPL.REC<FR.Contract.FraDeal.FrdCounterparty>
            
        CASE APPL.ID[1,2] = 'ND'
            CustomerId = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
              
        CASE APPL.ID[1,2] = 'DX'
            CustomerId = APPL.REC<DX.Trade.Trade.TraPriCustNo>
            CustomerId = CustomerId<1,1>
            
        CASE APPL.ID[1,2] = 'FX'
            CustomerId = APPL.REC<FX.Contract.Forex.Counterparty>
           
    END CASE
        
    IF CustomerId THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(CustomerId, OcCusErr)
        IF OcCustomerRec THEN
            LeiId = OcCustomerRec<ST.Customer.OcCustomer.CusLegalEntityId>
            IF LeiId THEN
                RET.VAL = LeiId
            END ELSE
                NationalId = OcCustomerRec<ST.Customer.OcCustomer.CusNationalId>
                RET.VAL = NationalId
            END
        END
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.BANK.LEI>
GET.BANK.LEI:
*** <desc> </desc>
    OcParamId = EB.SystemTables.getIdCompany()
    OcParamErr = ''
    ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', '', '', OcParamRec, OcParamId, '', OcParamErr)
    IF OcParamRec THEN
        BankLei = OcParamRec<OC.Parameters.OcParameter.ParamBankLei>
        IF BankLei THEN
            RET.VAL = BankLei
        END
    END
RETURN
*** </region>

END




