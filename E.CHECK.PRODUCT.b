* @ValidationCode : MjoxMzM3OTYzMTg0OkNwMTI1MjoxNTQ3MTk4NTY3Mzg5OmtrYXZpdGhhbmphbGk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Jan 2019 14:52:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kkavithanjali
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PV.ModelBank
SUBROUTINE E.CHECK.PRODUCT
*-----------------------------------------------------
* Annotations:
*-------------
    !**
* Enquiry conversion routine to check the existance of a product and to return the
* outstanding amount of a contract whose key will passed through O.DATA.
*
* @param
*
* @stereotype   SUBROUTINE
* @package      PV
* @uses         To return the outstanding amount of a contract
* @link         Enquiry PV.PROVISION.SUMMARY
*!
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*----------------------
*
* 05/06/12 - Defect 410065
*            Fatal error when executing PV.PROVISION.SUMMARY due to missing product.
*
* 30/12/15 - Defect 1581208 / Task 1585501
*            Outstanding amount for PDPD records has to be returned.
*
* 01/10/17 - Defect 2939717 / Task 2939896
*            Outstanding amount for SL.LOANS and FACILITY records has to be returned.
*
*--------------------------------------------------------------------------------------------------------------


    $USING ST.CompanyCreation
    $USING LD.Contract
    $USING PD.Contract
    $USING MM.Contract
    $USING AC.AccountOpening
    $USING SL.Loans
    $USING EB.SystemTables
    $USING EB.Reports
    $USING PV.ModelBank
    $USING SL.Facility

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*----------
INITIALISE:
*----------

    CONTRACT.ID = EB.Reports.getOData()
    EB.Reports.setId(EB.Reports.getOData()[1,2])
    APP.POS = ''
    R.REC = ""

RETURN

*-------
PROCESS:
*-------
    ID.VAL = EB.Reports.getId()
    BEGIN CASE

        CASE ID.VAL EQ "SL"

            LOCATE "SL" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING APP.POS THEN
                R.REC = SL.Loans.Loans.Read(CONTRACT.ID, ERR1)
                SL.AMOUNT = R.REC<SL.Loans.Loans.LnOwnAmount>
*   When Record not found in SL.LOANS, then Check whether it is a Facility record ID by reading.
                IF R.REC EQ "" THEN
                    R.REC = SL.Facility.Facility.Read(CONTRACT.ID, ERR1)
                    SL.AMOUNT = R.REC<SL.Facility.Facility.FacSlAmount>
                END
                EB.Reports.setOData(SL.AMOUNT)
            END

        CASE ID.VAL EQ "MM"

            LOCATE "MM" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING APP.POS THEN
                R.REC.ID = MM.Contract.MoneyMarket.Read(CONTRACT.ID, ERR1)
                MM.AMOUNT = R.REC.ID<MM.Contract.MoneyMarket.Principal>
                EB.Reports.setOData(MM.AMOUNT)
            END

        CASE ID.VAL EQ "LD"

            PD.AMOUNT = ''
            LOCATE "PD" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING APP.POS THEN
                PD.ID = "PD" : CONTRACT.ID
                R.REC.ID = PD.Contract.PaymentDue.Read(PD.ID, ERR1)
                PD.AMOUNT = R.REC.ID<PD.Contract.PaymentDue.TotalAmtToRepay>
            END
            LOCATE "LD" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING APP.POS THEN
                R.REC.ID = LD.Contract.LoansAndDeposits.Read(CONTRACT.ID, ERR1)
                LD.AMT = R.REC.ID<LD.Contract.LoansAndDeposits.Amount>
                AMT = LD.AMT + PD.AMOUNT
                EB.Reports.setOData(AMT)
            END
    
        CASE ID.VAL EQ "PD"
* For PDPD records, get the amount by reading PD record
            AMT = ''
            LOCATE "PD" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING APP.POS THEN
                R.REC.ID = PD.Contract.PaymentDue.Read(CONTRACT.ID, ERR1)
                AMT = R.REC.ID<PD.Contract.PaymentDue.TotalAmtToRepay>
                EB.Reports.setOData(AMT)
            END

        CASE NUM(EB.Reports.getOData())

            AC.AMOUNT = ''
            ERR1 = ''
            CALL AccountService.getWorkingBalance(CONTRACT.ID, AC.AMOUNT, ERR1)
            EB.Reports.setOData(AC.AMOUNT)

    END CASE

RETURN
END
