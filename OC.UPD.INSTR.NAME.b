* @ValidationCode : Mjo4MjkyMzAwNjg6Q3AxMjUyOjE1OTk1NjcwNTI0NjU6a2JoYXJhdGhyYWo6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjc2Ojc2
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 76/76 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.INSTR.NAME(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate DESCRIPTION for the FRA,SW and ND.
* When EXEC.VENUE is different from XXXX or XOFF and PROD.ID.TYPE is not set as "ISIN".
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - DESCRIPTION/NULL
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
    $USING FX.Config
    $USING SW.Config
    $USING DX.Trade
    $USING DX.Configuration
*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    RET.VAL = ''
    Description = ''
    SwapType = ''
    SwapTypeRec = ''
    MifidReportStatus = ''
    ProdIdType = ''
    ExecVenue = ''
    NdfType = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            NdfType = APPL.REC<FX.Contract.NdDeal.NdDealNdfType>
            ExecVenue = APPL.REC<FX.Contract.NdDeal.NdDealExecVenue>
            ProdIdTye = APPL.REC<FX.Contract.NdDeal.NdDealProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" AND ProdIdTye NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
                BEGIN CASE
                    CASE NdfType EQ "VANILLA"
                        RET.VAL = "VANILLA"
                    CASE NdfType EQ "EXOTIC"
                        RET.VAL = "EXOTIC"
                END CASE
            END
        
        CASE APPL.ID[1,2] EQ "FR"
            ExecVenue = APPL.REC<FR.Contract.FraDeal.FrdExecVenue>
            ProdIdTye = APPL.REC<FR.Contract.FraDeal.FrdProdIdType>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" AND ProdIdTye NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
                RET.VAL = "Forward Rate Agreement"
            END
           
        
        CASE APPL.ID[1,2] EQ "SW"
            SwapType = APPL.REC<SW.Contract.Swap.SwapType>
            ExecVenue = APPL.REC<SW.Contract.Swap.ExecVenue>
            ProdIdTye = APPL.REC<SW.Contract.Swap.ProdIdType>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" AND ProdIdTye NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
                SwapErr = ''
                SwapTypeRec = SW.Config.SwapType.Read(SwapType, SwapErr)
                IF SwapTypeRec THEN
                    Description = SwapTypeRec<SW.Config.SwapType.TypDescription>
                    IF Description THEN
                        RET.VAL = Description
                    END
                END
            END
            
        CASE APPL.ID[1,2] EQ "DX"
            ExecVenue = APPL.REC<DX.Trade.Trade.TraExecVenue>
            ProdIdTye = APPL.REC<DX.Trade.Trade.TraProdIdType>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
            ID.CONTRACT = ""
            R.DX.CONTRACT.MASTER = ""
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
            IF MifidReportStatus EQ "NEWT" AND ProdIdTye NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
                ID.CONTRACT = APPL.REC<DX.Trade.Trade.TraContractCode>
                R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(ID.CONTRACT, '')
                RET.VAL = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmDescript>
            END
            
        CASE APPL.ID[1,2] EQ "FX"
            ForexType = APPL.REC<FX.Contract.Forex.TransactionType>
            ExecVenue = APPL.REC<FX.Contract.Forex.ExecVenue>
            ProdIdTye = APPL.REC<FX.Contract.Forex.ProdIdType>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
            IF MifidReportStatus EQ "NEWT" AND ProdIdTye NE "ISIN" AND (ExecVenue NE "XXXX" AND ExecVenue NE "XOFF") THEN
                FxErr = ''
                ForexTypeRec = FX.Config.TransactionType.Read(ForexType, FxErr)
                IF ForexTypeRec THEN
                    Description = ForexTypeRec<FX.Config.TransactionType.TtDescription>
                    IF Description THEN
                        RET.VAL = Description
                    END
                END
            END
    END CASE
RETURN
*** </region>

END


