* @ValidationCode : MjoxMzc1MDg1Mjc5OkNwMTI1MjoxNTk5NTY3MDU2ODU2OmtiaGFyYXRocmFqOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo1Mjo1Mg==
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/52 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.INV.DEC.MKR.COMP(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* If NATIONAL.ID is populated in field INV.DECISION.MKR.ID then fetch RESIDENCE from CUSTOMER table for the InvDecisionMkrId.
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - RESIDENCE/NULL
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
    NATIONAL.ID = ''
    RET.VAL = ''
    OcCustomerRec = ''
    InvDecisionMkrid = ''
    NationalIdFromCustomer = ''
    CustomerRec = ''
    Residence = ''
    MifidReportStatus = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
*Invoke OC.UPD.INV.DEC.MKR to get the return value and determine whether it is National id or not.
    OC.Reporting.UpdInvDecMkr(APPL.ID,APPL.REC,FIELD.POS, NATIONAL.ID)
    BEGIN CASE
    
        CASE APPL.ID[1,2] = 'ND'
            InvDecisionMkrid = APPL.REC<FX.Contract.NdDeal.NdDealInvDecisionMkrId>
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'SW'
            InvDecisionMkrid = APPL.REC<SW.Contract.Swap.InvDecisionMkrId>
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
            
        CASE APPL.ID[1,2] = 'FR'
            InvDecisionMkrid = APPL.REC<FR.Contract.FraDeal.FrdInvDecisionMkrId>
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
        CASE APPL.ID[1,2] = 'DX'
            InvDecisionMkrid = APPL.REC<DX.Trade.Trade.TraInvDecisionMkrId>
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
    
        CASE APPL.ID[1,2] = 'FX'
            InvDecisionMkrid = APPL.REC<FX.Contract.Forex.InvDecisionMkrId>
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
    END CASE
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
    IF MifidReportStatus THEN
        GOSUB ASSIGN.RESIDENCE.VALUE ; *
    END
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= ASSIGN.RESIDENCE.VALUE>
ASSIGN.RESIDENCE.VALUE:
*** <desc> </desc>
    IF InvDecisionMkrid THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(InvDecisionMkrid, OcCusErr)
        IF OcCustomerRec THEN
            NationalIdFromCustomer = OcCustomerRec<ST.Customer.OcCustomer.CusNationalId>
        END
        
        IF NATIONAL.ID EQ NationalIdFromCustomer THEN ;*To Check if the NATIONAL.ID is present in the field OC.UPD.INV.DEC.MKR
            CusErr = ''
            CustomerRec = ST.Customer.Customer.CacheRead(InvDecisionMkrid, CusErr)
            IF CustomerRec THEN
                Residence = CustomerRec<ST.Customer.Customer.EbCusResidence>
                IF Residence THEN
                    RET.VAL = Residence
                END
            END
        END
    END
RETURN
*** </region>

END


