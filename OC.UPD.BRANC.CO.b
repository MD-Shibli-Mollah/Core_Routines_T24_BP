* @ValidationCode : MjotMTEwMjk5MzkzMjpDcDEyNTI6MTU5OTQ3NjIzNDc3NTprYmhhcmF0aHJhajo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6Mjg6Mjg=
* @ValidationInfo : Timestamp         : 07 Sep 2020 16:27:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 28/28 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.BRANC.CO(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* populate LOCAL.COUNTRY from the current company.
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - LOCAL.COUNTRY/NULL
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

    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING FX.Contract
    $USING SW.Contract
    $USING FR.Contract
    $USING DX.Trade
*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    CompanyId = ''
    CompanyRec = ''
    LocalCountry = ''
    RET.VAL = ''
    MifidReportStatus = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
    
        CASE APPL.ID[1,2] = 'ND'
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'SW'
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
            
        CASE APPL.ID[1,2] = "FR"
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'DX'
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
            
        CASE APPL.ID[1,2] = "FX"
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
    END CASE
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
    IF MifidReportStatus EQ "NEWT" THEN
        LocalCountry = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
        IF LocalCountry THEN
            RET.VAL = LocalCountry
        END
    END
    

RETURN
*** </region>

END


