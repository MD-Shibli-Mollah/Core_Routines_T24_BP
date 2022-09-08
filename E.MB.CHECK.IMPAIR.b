* @ValidationCode : MjoyMTI1MTU1Mjk1OkNwMTI1MjoxNTAwMzc2NzI3NjM1Om5zaGFtdWR1bmlzaGE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDQuMjoyNzoyMA==
* @ValidationInfo : Timestamp         : 18 Jul 2017 16:48:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nshamudunisha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/27 (74.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.2
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE IA.ModelBank
SUBROUTINE E.MB.CHECK.IMPAIR
*-----------------------------------------------------------------------------
* Enquiry CONTRACT.IMPAIR.EVIDENCE selects the EB.CASHFLOW record with IMPAIRMENT.STATUS
* as impaired. But the records should be displayed only if the respective module is installed
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/07/17 - Defect 2193866 / Task 2200604
*            New conversion routine has been introduced to check whether corresponding
*            modules are installed to return the amount correctly.
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING LD.Contract
    $USING MM.Contract
    $USING SL.Loans
    $USING ST.CompanyCreation

    GOSUB INIT
    GOSUB PROCESS

RETURN
    
*-----------------------------------------------------------------------------
*** <region name= INIT>

INIT:

    CONTRACT.ID = EB.Reports.getOData()

    LOCATE "LD" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING LD.INSTALLED ELSE
        LD.INSTALLED = ''
    END

    LOCATE "MM" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING MM.INSTALLED ELSE
        MM.INSTALLED = ''
    END

    LOCATE "SL" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING SL.INSTALLED ELSE
        SL.INSTALLED = ''
    END

RETURN

*** </region>

*-----------------------------------------------------------------------------
*** <region name= PROCESS>

PROCESS:
*
* The corresponding records should be read only if the module is installed to avoid unwanted
* fatal errors. Those amounts should be passed to O.DATA correctly to display correctly.
*
    BEGIN CASE
        CASE CONTRACT.ID[1,2] = 'LD' AND LD.INSTALLED

            R.LD.LOANS.AND.DEPOSITS = LD.Contract.LoansAndDeposits.Read(CONTRACT.ID, REC.ERR)
            AMOUNT = R.LD.LOANS.AND.DEPOSITS<LD.Contract.LoansAndDeposits.Amount>

        CASE CONTRACT.ID[1,2] = 'MM' AND MM.INSTALLED

            R.MM.MONEY.MARKET = MM.Contract.MoneyMarket.Read(CONTRACT.ID, REC.ERR)
            AMOUNT = R.MM.MONEY.MARKET<MM.Contract.MoneyMarket.Principal>

        CASE CONTRACT.ID[1,2] = 'SL' AND SL.INSTALLED

            R.SL.LOANS = SL.Loans.Loans.Read(CONTRACT.ID, REC.ERR)
            AMOUNT = R.SL.LOANS<SL.Loans.Loans.LnOwnAmount>

    END CASE

    EB.Reports.setOData(AMOUNT)

RETURN

*** </region>

*-----------------------------------------------------------------------------

END
