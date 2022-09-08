* @ValidationCode : MjotMjUzNzM5Mzk3OkNwMTI1MjoxNTk5NjQ1MDkwODA1OmtiaGFyYXRocmFqOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo1Njo1Ng==
* @ValidationInfo : Timestamp         : 09 Sep 2020 15:21:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 56/56 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.UNIQUE.PROD.ID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate UNIQUE.PROD.ID When EXEC.VENUE is different from XXXX or XOFF and PROD.ID.TYPE is not set as "ISIN".
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - UNIQUE.PROD.ID/NULL
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
    UniqueProdId = ''
    ExecVenue = ''
    RET.VAL = ''
    MifidReportStatus= ''
    ProdIdType = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            UniqueProdId = APPL.REC<FX.Contract.NdDeal.NdDealUniqueProdId>
            ExecVenue = APPL.REC<FX.Contract.NdDeal.NdDealExecVenue>
            ProdIdType = APPL.REC<FX.Contract.NdDeal.NdDealProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.UNIQUE.PROD.ID ; *
            END
        
        CASE APPL.ID[1,2] EQ "FR"
            UniqueProdId = APPL.REC<FR.Contract.FraDeal.FrdUniqueProdId>
            ExecVenue = APPL.REC<FR.Contract.FraDeal.FrdExecVenue>
            ProdIdType = APPL.REC<FR.Contract.FraDeal.FrdProdIdType>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.UNIQUE.PROD.ID ; *
            END
        
        CASE APPL.ID[1,2] EQ "SW"
            UniqueProdId = APPL.REC<SW.Contract.Swap.UniProdId>
            ExecVenue = APPL.REC<SW.Contract.Swap.ExecVenue>
            ProdIdType = APPL.REC<SW.Contract.Swap.ProdIdType>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.UNIQUE.PROD.ID ; *
            END
        
        
        CASE APPL.ID[1,2] EQ "DX"
            UniqueProdId = APPL.REC<DX.Trade.Trade.TraUniProdId>
            ExecVenue = APPL.REC<DX.Trade.Trade.TraExecVenue>
            ProdIdType = APPL.REC<DX.Trade.Trade.TraProdIdType>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.UNIQUE.PROD.ID ; *
            END
        
        CASE APPL.ID[1,2] EQ "FX"
            UniqueProdId = APPL.REC<FX.Contract.Forex.UniqueProdId>
            ExecVenue = APPL.REC<FX.Contract.Forex.ExecVenue>
            ProdIdType = APPL.REC<FX.Contract.Forex.ProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB ASSIGN.UNIQUE.PROD.ID ; *
            END
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= ASSIGN.UNIQUE.PROD.ID>
ASSIGN.UNIQUE.PROD.ID:
*** <desc> </desc>

    IF ProdIdType NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
        RET.VAL = UniqueProdId
    END
RETURN
*** </region>

END



