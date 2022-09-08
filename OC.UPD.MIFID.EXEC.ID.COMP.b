* @ValidationCode : Mjo3MDg5MTM1OTpDcDEyNTI6MTU5OTU2NzA2NDc2NzprYmhhcmF0aHJhajo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6NTQ6NTQ=
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:41:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 54/54 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.MIFID.EXEC.ID.COMP(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* If NATIONAL.ID is populated in field MIFID.EXEC.ID then fetch RESIDENCE from CUSTOMER table for the MIFID.EXEC.ID.
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
    MifidExecid = ''
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
*Invoke OC.UPD.MIFID.EXEC.ID to get the return value and determine whether it is National id or not.
    OC.Reporting.UpdMifidExecId(APPL.ID,APPL.REC,FIELD.POS, NATIONAL.ID)
    IF NATIONAL.ID THEN
        BEGIN CASE
    
            CASE APPL.ID[1,2] = 'ND'
                MifidExecid = APPL.REC<FX.Contract.NdDeal.NdDealMifidExecId>
                MifidReportStatus = APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
            
            CASE APPL.ID[1,2] = 'SW'
                MifidExecid = APPL.REC<SW.Contract.Swap.MifidExecId>
                MifidReportStatus = APPL.REC<SW.Contract.Swap.MifidReportStatus>
                
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
*Populate the value only when MIFID.REPORT.STATUS as "NEWT"
        IF MifidReportStatus EQ "NEWT" THEN
            GOSUB ASSIGN.RESIDENCE.VALUE ; *
        END
    END
RETURN

*-----------------------------------------------------------------------------

*** <region name= ASSIGN.RESIDENCE.VALUE>
ASSIGN.RESIDENCE.VALUE:
*** <desc> </desc>
    IF MifidExecid THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(MifidExecid, OcCusErr)
        IF OcCustomerRec THEN
            NationalIdFromCustomer = OcCustomerRec<ST.Customer.OcCustomer.CusNationalId>
        END
        
        IF NATIONAL.ID EQ NationalIdFromCustomer THEN ;*To Check if the NATIONAL.ID is present in the field OC.UPD.INV.DEC.MKR
            CusErr = ''
            CustomerRec = ST.Customer.Customer.CacheRead(MifidExecid, CusErr)
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


