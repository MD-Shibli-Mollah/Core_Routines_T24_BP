* @ValidationCode : MjotNTQ0ODg4ODc3OkNwMTI1MjoxNTk5NTY3MDY1NjUyOmtiaGFyYXRocmFqOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo1Mjo1MQ==
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:41:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/52 (98.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.CCY.2(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate CURRENCY When EXEC.VENUE is different from XXXX or XOFF and PROD.ID.TYPE is not set as "ISIN".
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - CURRENCY/NULL
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
* 02/04/2020 - Enhancement - 3661737 / Task - 3661740
*              CI#3 Mapping Routines Part-2
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING FR.Contract
    $USING FX.Contract
    $USING SW.Contract
    $USING FX.Config
    $USING DX.Trade
*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    Currency = ''
    RET.VAL = ''
    ExecVenue = ''
    MifidReportStatus = ''
    ProdIdType = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            Currency = APPL.REC<FX.Contract.NdDeal.NdDealSettlementCcy>
            ExecVenue = APPL.REC<FX.Contract.NdDeal.NdDealExecVenue>
            ProdIdType = APPL.REC<FX.Contract.NdDeal.NdDealProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.DEAL.CURRENCY ; *
            END
        
        CASE APPL.ID[1,2] EQ "SW"
            Currency = APPL.REC<SW.Contract.Swap.AsCurrency>
            ExecVenue = APPL.REC<SW.Contract.Swap.ExecVenue>
            ProdIdType = APPL.REC<SW.Contract.Swap.ProdIdType>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.DEAL.CURRENCY ; *
            END
            
        CASE APPL.ID[1,2] EQ "DX"
            IF APPL.REC<DX.Trade.Trade.TraLbCurrency> EQ APPL.REC<DX.Trade.Trade.TraAsCurrency> THEN
                Currency = ''
            END ELSE
                Currency = APPL.REC<DX.Trade.Trade.TraAsCurrency>
            END
            ExecVenue = APPL.REC<DX.Trade.Trade.TraExecVenue>
            ProdIdType = APPL.REC<DX.Trade.Trade.TraProdIdType>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.DEAL.CURRENCY ; *
            END
            
        CASE APPL.ID[1,2] EQ "FX"
            Currency = APPL.REC<FX.Contract.Forex.CurrencySold>
            ExecVenue = APPL.REC<FX.Contract.Forex.ExecVenue>
            ProdIdType = APPL.REC<FX.Contract.Forex.ProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.DEAL.CURRENCY ; *
            END
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= ASSIGN.DEAL.CURRENCY>
ASSIGN.DEAL.CURRENCY:
*** <desc> </desc>

    IF ProdIdType NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
        RET.VAL = Currency
    END
RETURN
*** </region>

END




