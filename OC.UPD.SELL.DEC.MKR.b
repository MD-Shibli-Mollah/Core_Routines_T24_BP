* @ValidationCode : MjoxMDY1OTQwNDA6Q3AxMjUyOjE1OTk2NDUwODI2OTI6a2JoYXJhdGhyYWo6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjQ3OjQ3
* @ValidationInfo : Timestamp         : 09 Sep 2020 15:21:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/47 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.SELL.DEC.MKR(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* LEI Id for the customer defined in DECISION.MKR.ID, if no LEI id, populate NATIONAL.ID from the OC.CUSTOMER.
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - LEI.ID/NATIONAL.ID/NULL
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
    $USING OC.Reporting
    $USING DX.Trade
*-----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    OcCustomerRec = ''
    DecisionMkrid = ''
    RET.VAL = ''
    LeiId = ''
    NationalId = ''
    MifidReportStatus = ''
    CPARTY.SIDE = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

*Invoke OC.UPD.CPARTY.SIDE to determine whether its a buy or sell transaction
    OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
    
    BEGIN CASE
       
        CASE APPL.ID[1,2] = 'ND'
            DecisionMkrid = APPL.REC<FX.Contract.NdDeal.NdDealDecisionMkrId>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'SW'
            DecisionMkrid = APPL.REC<SW.Contract.Swap.DecisionMkrId>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FR'
            DecisionMkrid = APPL.REC<FR.Contract.FraDeal.FrdDecisionMkrId>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
                        
        CASE APPL.ID[1,2] = 'DX'
            DecisionMkrid = APPL.REC<DX.Trade.Trade.TraDecisionMkrId>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FX'
            DecisionMkrid = APPL.REC<FX.Contract.Forex.DecisionMkrId>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
    END CASE
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
    IF MifidReportStatus EQ "NEWT" AND CPARTY.SIDE EQ "S" THEN
        GOSUB GET.LEI.OR.NATIONAL.ID ; *
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.LEI.OR.NATIONAL.ID>
GET.LEI.OR.NATIONAL.ID:
*** <desc> </desc>
    IF DecisionMkrid THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(DecisionMkrid, OcCusErr)
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

END



