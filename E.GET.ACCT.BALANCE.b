* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.ACCT.BALANCE
*-----------------------------------------------------------------------------
* Enquiry routine used to get accounts open actual balance from acct.activity
* Used in STMT.ENT.TODAY eqnuiry
*-----------------------------------------------------------------------------
*
* Modification history:
*
* 24/01/07 - CI_10046819
*            New version
*
* 09/03/11 - Task - 169030
*			 Checking whether the BAL.DATE is null or not. IF it is null the minus
*			 one calender day from today and assign to BAL.DATE
*
* 30/05/11 - DEFECT 201180 / TASK 220525
*            For AA Accounts, AA.GET.ACCT.BALANCE routine is used to
*			 fetch the correct balance instead of the API EB.GET.ACCT.BALANCE.
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AC.API
    $USING AA.Accounting
    $USING EB.Utility

    GOSUB INITIALISE

    GOSUB PROCESS

*------------------------------------------------------------------------------
INITIALISE:
*----------

    ACCT.NO = EB.Reports.getOData()

    RETURN
*-------------------------------------------------------------------------------
PROCESS:
*-------

    R.ACCOUNT = '' ; AC.ERR = ''
    R.ACCOUNT = AC.AccountOpening.tableAccount(ACCT.NO, AC.ERR)
    IF AC.ERR THEN
        RETURN ;* when  account not present
    END

    BAL.DATE= EB.SystemTables.getRDates(EB.Utility.Dates.DatLastPeriodEnd)
    ACCT.REC = ''
    BAL.TYPE = 'BOOKING'
    ACCT.BAL = ''
    CREDIT.MVMT = ''
    DEBIT.MVMT = ''
    ERR.MSG = ''

    IF R.ACCOUNT<AC.AccountOpening.Account.ArrangementId> THEN          ;*For arrangement account, call AA.GET.ACCT.BALANCE API to return the correct balance
        AA.Accounting.GetAcctBalance(ACCT.NO, R.ACCOUNT, BAL.TYPE, BAL.DATE, '', ACCT.BAL, CREDIT.MVMT, DEBIT.MVMT, ERR.MSG)
    END ELSE
        AC.API.EbGetAcctBalance(ACCT.NO, ACCT.REC, BAL.TYPE, BAL.DATE, '', ACCT.BAL, CREDIT.MVMT, DEBIT.MVMT, ERR.MSG)
    END

    EB.Reports.setOData(ACCT.BAL)
    RETURN
*-----------------------------------------------------------------------------
    END
