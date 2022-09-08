* @ValidationCode : Mjo5NDU3NDE1OTY6Q3AxMjUyOjE1OTk1NjcwNTE4OTg6a2JoYXJhdGhyYWo6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjMzOjMz
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 33/33 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.INV.FIRM(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* to populate this field with value "TRUE" if REGULATORY.CLASS in OC.PARAMETER is set to Financial Counterparty.
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - TRUE or NULL
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

    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING OC.Parameters
    $USING FX.Contract
    $USING SW.Contract
    $USING FR.Contract
    $USING DX.Trade
    
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    RET.VAL = ''
    OcParamId = ''
    OcParamRec = ''
    RegulatoryClass= ''
    MifidReportStatus = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            MifidReportStatus = APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
        CASE APPL.ID[1,2] EQ "SW"
            MifidReportStatus = APPL.REC<SW.Contract.Swap.MifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FR'
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'DX'
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FX'
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
    END CASE

*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
    IF MifidReportStatus EQ "NEWT" THEN
        OcParamId = EB.SystemTables.getIdCompany()
        OcParamErr = ''
        ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', '', '', OcParamRec, OcParamId, '', OcParamErr)
        IF OcParamRec THEN
            RegulatoryClass = OcParamRec<OC.Parameters.OcParameter.ParamRegulatoryClass>
            IF RegulatoryClass EQ "FINANCIAL.COUNTERPARTY" THEN
                RET.VAL = "TRUE"
            END
        END
    END
RETURN
*** </region>

END


