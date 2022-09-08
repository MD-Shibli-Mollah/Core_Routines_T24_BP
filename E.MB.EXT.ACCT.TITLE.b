* @ValidationCode : MjoxNzA5MzE5MzkyOkNwMTI1MjoxNjE4NDcxOTI1NzIzOmJzYXVyYXZrdW1hcjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTA0LjIwMjEwNDA3LTA1MDc6Mjc6Mjc=
* @ValidationInfo : Timestamp         : 15 Apr 2021 13:02:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202104.20210407-0507
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.EXT.ACCT.TITLE
*-----------------------------------------------------------------------------
*Description:
*            Conversion routine used to get account title from history file
*            for the accounts which are closed
*-----------------------------------------------------------------------------
* Version No: 1.0
* ------------------
*
* Change History
* 22/10/08 - BG_100019949
*            Routie Standardisation
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 16/07/20 - Defect 3850232 / Task 3859454
*            Changes done to display the details of account from ACCOUNT application
*            when migrated from lower releases
*
* 15/04/21 - Defect 4330374 / Task 4338764
*            Update audit fields properly
*----------------------------------------------------------------------------------

    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AC.AccountClosure
    
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

INITIALISE:

* Get the Account No from O.DATA and read the Account application's History file

    ACCOUNT.NO = EB.Reports.getOData()

* Get the Record fetched from the Enquiry

    CLOSED.REC = EB.Reports.getRRecord()

** Get the each field from record fetched from then enquiry
    
    CUSTOMER.ID = CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldCustomerId>
    
    ACCOUNT.OFFICER = CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldAccountOfficer>
    
    IF CUSTOMER.ID = "" AND ACCOUNT.OFFICER = "" THEN
        OLD.RECORD =1
    END
    
RETURN

PROCESS:

* Get the value of the field ACCOUNT.TITLE
* Return O.DATA with the value of ACCOUNT.TITLE to the enquiry

    AC.AccountOpening.AccountHistRead(ACCOUNT.NO,R.ACCOUNT,R.ACCOUNT.ERROR)
    ACCOUNT.TITLE = R.ACCOUNT<AC.AccountOpening.Account.ShortTitle>
    
    IF OLD.RECORD THEN
* Populate the values from Account history for the fields which are null in ACCOUNT.CLOSED
      
        CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldCustomerId> = R.ACCOUNT<AC.AccountOpening.Account.Customer>
        CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldAccountBranch> = R.ACCOUNT<AC.AccountOpening.Account.CoCode>
        CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldAccountOfficer> = R.ACCOUNT<AC.AccountOpening.Account.AccountOfficer>
        CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldClosureReason> = R.ACCOUNT<AC.AccountOpening.Account.ClosureReason>
        IF R.ACCOUNT<AC.AccountOpening.Account.ClosedOnline> EQ "Y" THEN
            CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldCloseMode> ="ONLINE"
        END
        CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldClosureInputter> = R.ACCOUNT<AC.AccountOpening.Account.Inputter,1>
        CLOSED.REC<AC.AccountClosure.AccountClosed.AcCldClosureAuthoriser> = R.ACCOUNT<AC.AccountOpening.Account.Authoriser,1>
     
        EB.Reports.setRRecord(CLOSED.REC)
    END
      
    
    
    EB.Reports.setOData(ACCOUNT.TITLE)

RETURN
