* @ValidationCode : MjoyMTQ3NjU5MDI6Q3AxMjUyOjE2MTQzMzI5NDg4MTA6YnNhdXJhdmt1bWFyOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDIuMjAyMTAyMDItMTkxMjoxNToxNQ==
* @ValidationInfo : Timestamp         : 26 Feb 2021 15:19:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210202-1912
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.TOTAL.LOCK.AMT
*-----------------------------------------------------------------------------
* A new routine (E.TOTAL.LOCK.AMT) has been introduced to Show the cumulative of the locked
* amount if he has an multiple locked amount. This new routine is called from an existing enquiry
*(ACCOUNT.DETAILS.SCV).
*
*******************************************************************************
*           MODIFICATION HISTORY
*******************************************************************************
*
* 14/05/2013 - Defect : 670913
*              Task   : 674642
*              Changes done to solve the performance issue.
*
* 29/11/2014 - Defect : 1180293
*              Task   : 1184432
*              Changes done to retrieve the correct usable amount.
*
* 07/05/2015 - Enhancement 1263702
*              Changes done to Remove the inserts and incorporate the routine
*
* 18/01/2018 - Enhancement 2321342 / Task 2321345
*              Modified to get locked amount details from ECB
*              Modified direct read from account to AC.CashFlow.GetLockedDetails
*
* 12/07/2019 - Defect 3225120 / Task 3226190
*              Display only today's locked amount of the account while launching
*              the enquiry ACCOUNT.DETAILS.ARR.SCV/ACCOUNT.DETAILS.SCV
*
* 26/02/2021 - Defect 4151730 / 4252937
*              Display worst locked amount to keep enquiry in sync with accounting
*              and arrangement overviews
*******************************************************************************
*

    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING AC.CashFlow

    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------

INIT:
    ACC.NO = "" ;  AMT.CHK = "" ; ALL.DATE = "" ; R.ACC = "" ;
RETURN

PROCESS:

    ACC.NO = EB.Reports.getOData()
    LOCKED.DETAILS = ''
    RESPONSE.DETAILS = ''
    AC.CashFlow.GetLockedDetails(ACC.NO, LOCKED.DETAILS,RESPONSE.DETAILS)
    VAL = ""
    AMT.CHK = LOCKED.DETAILS<2>
    ALL.DATE = LOCKED.DETAILS<1>

* Accounting uses worst locked amount of the ladder for credit check purpose. Same is used for displaying locked amounts in AA overview also. So customer
* overview enquiry is made in sync by considering worst locked amount available in the ladder
    VAL= MAXIMUM(AMT.CHK)
    EB.Reports.setOData(VAL)
RETURN
*-----------------------------------------------------------------------------
END
