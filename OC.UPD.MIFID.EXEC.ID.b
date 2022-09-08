* @ValidationCode : Mjo2NDk3MDMyMTM6Q3AxMjUyOjE1OTk1NjcwNTkxNzM6a2JoYXJhdGhyYWo6MTA6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo0NTo0NQ==
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/45 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.MIFID.EXEC.ID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate LEI Id for the customer defined in  MIFID.EXEC.ID, if no LEI id, populate NATIONAL.ID
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
    MifidExecid = ''
    RET.VAL = ''
    LeiId = ''
    NationalId = ''
    MifidReportStatus = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
       
        CASE APPL.ID[1,2] = 'ND'
            MifidExecid = APPL.REC<FX.Contract.NdDeal.NdDealMifidExecId>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'SW'
            MifidExecid = APPL.REC<SW.Contract.Swap.MifidExecId>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FR'
            MifidExecid = APPL.REC<FR.Contract.FraDeal.FrdMifidExecId>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
                               
        CASE APPL.ID[1,2] = 'DX'
            MifidExecid = APPL.REC<DX.Trade.Trade.TraMifidExecId>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FX'
            MifidExecid = APPL.REC<FX.Contract.Forex.MifidExecId>
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
    IF MifidExecid THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(MifidExecid, OcCusErr)
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



