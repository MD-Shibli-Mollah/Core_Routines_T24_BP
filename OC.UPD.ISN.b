* @ValidationCode : MjotMTUzMDg2NTk0NzpDcDEyNTI6MTU5OTU2NzA1NTI0NjprYmhhcmF0aHJhajo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6NDg6NDg=
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 48/48 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.ISN(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate PROD.CLASS.ID if PROD.ID.TYPE is set to ISIN.
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - PROD.CLASS.ID/NULL
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

    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING FR.Contract
    $USING FX.Contract
    $USING SW.Contract
    $USING DX.Trade
*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    RET.VAL = ''
    prodClassId = ''
    ProdIdType = ''
    MifidReportStatus = ''
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            ProdClassId = APPL.REC<FX.Contract.NdDeal.NdDealProdClassId>
            ProdIdType = APPL.REC<FX.Contract.NdDeal.NdDealProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB CHECK.PROD.ID.TYPE ; *
            END
        
        CASE APPL.ID[1,2] EQ "FR"
            ProdClassId = APPL.REC<FR.Contract.FraDeal.FrdProdClassId>
            ProdIdType = APPL.REC<FR.Contract.FraDeal.FrdProdIdType>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            GOSUB CHECK.PROD.ID.TYPE ; *
        
        CASE APPL.ID[1,2] EQ "SW"
            ProdClassId = APPL.REC<SW.Contract.Swap.ProdClassId>
            ProdIdType = APPL.REC<SW.Contract.Swap.ProdIdType>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB CHECK.PROD.ID.TYPE ; *
            END
        
        CASE APPL.ID[1,2] EQ "DX"
            ProdClassId = APPL.REC<DX.Trade.Trade.TraProdClassId>
            ProdIdType = APPL.REC<DX.Trade.Trade.TraProdIdType>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB CHECK.PROD.ID.TYPE ; *
            END
            
        CASE APPL.ID[1,2] EQ "FX"
            ProdClassId = APPL.REC<FX.Contract.Forex.ProdClassId>
            ProdIdType = APPL.REC<FX.Contract.Forex.ProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" THEN
                GOSUB CHECK.PROD.ID.TYPE ; *
            END
    END CASE

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.PROD.ID.TYPE>
CHECK.PROD.ID.TYPE:
*** <desc> </desc>
    IF ProdIdType EQ "ISIN" THEN
        RET.VAL = ProdClassId
    END
RETURN
*** </region>
END
