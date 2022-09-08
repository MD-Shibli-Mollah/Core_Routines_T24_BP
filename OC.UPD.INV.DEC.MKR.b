* @ValidationCode : Mjo2ODEyMjY3Mzg6Q3AxMjUyOjE1OTk1NjcwNTk0Nzc6a2JoYXJhdGhyYWo6MTA6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo1Mzo1Mw==
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/53 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.INV.DEC.MKR(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* LEI Id for the customer defined in INV.DECISION.MKR.ID, if no LEI id, populate NATIONAL.ID from the OC.CUSTOMER.
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
* 02/04/2020 - Enhancement - 3661737 / Task - 3661740
*              CI#3 Mapping Routines Part-2
*
* 14/04/20 - Enhancement 3689604 / Task 3689605
*            CI#3 - Mapping routines - Part II
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
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
    OcCustomerRec = ''
    InvDecMkrid = ''
    RET.VAL = ''
    LeiId = ''
    NationalId = ''
    TradingCapacity = ''
    MifidReportStatus = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
       
        CASE APPL.ID[1,2] = 'ND'
            InvDecMkrId = APPL.REC<FX.Contract.NdDeal.NdDealInvDecisionMkrId>
            TradingCapacity = APPL.REC<FX.Contract.NdDeal.NdDealTradingCapacity>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'SW'
            InvDecMkrId = APPL.REC<SW.Contract.Swap.InvDecisionMkrId>
            TradingCapacity = APPL.REC<SW.Contract.Swap.TradingCapacity>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FR'
            InvDecMkrId = APPL.REC<FR.Contract.FraDeal.FrdInvDecisionMkrId>
            TradingCapacity = APPL.REC<FR.Contract.FraDeal.FrdTradingCapacity>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'DX'
            InvDecMkrId = APPL.REC<DX.Trade.Trade.TraInvDecisionMkrId>
            TradingCapacity = APPL.REC<DX.Trade.Trade.TraTradingCapacity>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
               
        CASE APPL.ID[1,2] = 'FX'
            InvDecMkrId = APPL.REC<FX.Contract.Forex.InvDecisionMkrId>
            TradingCapacity = APPL.REC<FX.Contract.Forex.TradingCapacity>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
    END CASE
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
    IF MifidReportStatus EQ "NEWT" THEN
        GOSUB GET.DATA.FROM.OC.CUSTOMER ; *
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.DATA.FROM.OC.CUSTOMER>
GET.DATA.FROM.OC.CUSTOMER:
*** <desc> </desc>
    IF TradingCapacity NE "MTCH" THEN
        IF InvDecMkrId THEN
            OcCusErr = ''
            OcCustomerRec = ST.Customer.OcCustomer.CacheRead(InvDecMkrId, OcCusErr)
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
    END
RETURN
*** </region>

END



