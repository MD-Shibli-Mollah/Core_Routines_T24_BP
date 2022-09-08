* @ValidationCode : Mjo3NDEzNDUyNTpDcDEyNTI6MTU5OTQ3NjIyOTQ4NDprYmhhcmF0aHJhajo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6NTQ6NTQ=
* @ValidationInfo : Timestamp         : 07 Sep 2020 16:27:09
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
SUBROUTINE OC.UPD.BUY.DEC.MKR.DOB(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* If NATIONAL.ID is populated in field BUYER.DECISION.MKR then fetch BIRTH.INCORP.DATE from CUSTOMER table for the DecisionMkrId
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - BIRTH.INCORP.DATE/NULL
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
    DecisionMkrid = ''
    NationalIdFromCustomer = ''
    CustomerRec = ''
    BirthIncorpDate = ''
    MifidReportStatus = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
*Invoke OC.UPD.BUY.DEC.MKR to get the return value and determine whether it is National id or not.
    OC.Reporting.UpdBuyDecMkr(APPL.ID,APPL.REC,FIELD.POS, NATIONAL.ID)
    IF NATIONAL.ID THEN
        BEGIN CASE
    
            CASE APPL.ID[1,2] = 'ND'
                DecisionMkrid = APPL.REC<FX.Contract.NdDeal.NdDealDecisionMkrId>
                MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
                
            CASE APPL.ID[1,2] = 'SW'
                DecisionMkrid = APPL.REC<SW.Contract.Swap.DecisionMkrId>
                MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
                
            CASE APPL.ID[1,2] = 'FR'
                DecisionMkrid = APPL.REC<FR.Contract.FraDeal.FrdDecisionMkrId>
                MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
                
            CASE APPL.ID[1,2] = 'DX'
                DecisionMkrid = APPL.REC<DX.Trade.Trade.TraDecisionMkrId>
                MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
                                
            CASE APPL.ID[1,2] = 'FX'
                DecisionMkrid = APPL.REC<FX.Contract.Forex.DecisionMkrId>
                MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
        END CASE
*Populate the value only when MIFID.REPORT.STATUS as "NEWT".
        IF MifidReportStatus EQ "NEWT" THEN
            GOSUB ASSIGN.DOB.FROM.CUSTOMER ; *
        END
    END
RETURN

*-----------------------------------------------------------------------------

*** <region name= ASSIGN.DOB.FROM.CUSTOMER>
ASSIGN.DOB.FROM.CUSTOMER:
*** <desc> </desc>
    IF DecisionMkrid THEN
        OcCusErr = ''
        OcCustomerRec = ST.Customer.OcCustomer.CacheRead(DecisionMkrid, OcCusErr)
        IF OcCustomerRec THEN
            NationalIdFromCustomer = OcCustomerRec<ST.Customer.OcCustomer.CusNationalId>
        END
        
        IF NATIONAL.ID EQ NationalIdFromCustomer THEN ;*To Check if the NATIONAL.ID is present in the field BUYER.DECISION.MKR
            CusErr = ''
            CustomerRec = ST.Customer.Customer.CacheRead(DecisionMkrid, CusErr)
            IF CustomerRec THEN
                BirthIncorpDate = CustomerRec<ST.Customer.Customer.EbCusBirthIncorpDate>
                IF BirthIncorpDate THEN
                    RET.VAL = BirthIncorpDate
                END
            END
        END
    END
RETURN
*** </region>

END

