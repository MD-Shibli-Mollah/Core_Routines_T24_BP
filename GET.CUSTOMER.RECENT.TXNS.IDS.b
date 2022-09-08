* @ValidationCode : MjozNjk0NDMyMTc6Q3AxMjUyOjE1NTgwNjc1NzU4MTA6Y2hqYWhuYXZpOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDQuMjAxOTA0MTAtMDIzOTo2ODo2Mw==
* @ValidationInfo : Timestamp         : 17 May 2019 12:32:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : chjahnavi
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 63/68 (92.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AC.Channels
SUBROUTINE GET.CUSTOMER.RECENT.TXNS.IDS(ACCOUNT.LIST,TXN.COUNT,START.DATE, END.DATE, ID.LIST, CUSTOMER.ID)
*---------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This routine used to display the transactions list based on the input parameters for the customer accounts.
* Based on the date range provided the recent customer transactions are taken as resultant in comparison to the transaction count.
* This routine uses GetCustomerRecentTxnsIds and GetAccountTxnsIds to provide the data.
* The core API EStmtEntList is used to retrieve the statement entry list
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Call Routine
* Attached To        : Can be attached to any API. {e.g. E.NOFILE.TC.TXNS.LIST}
* IN Parameters      : Transaction count, Start date, End date
* Out Parameters     : Statement Id's
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1648966 / Task - 1843348
*            TCIB Retail : Transactions Detail (Recent Transaction)
*
* 12/03/19 - Enhancement - 2875480 / Task - 3030764
*            TCIB2.0 Retail IRIS R18 Migration
*
* 17/05/19 - Defect 3099901 / Task 3133852
*            External accounts recent transactions in TCIB Home page
*
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING AC.ModelBank
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.Reports
    $USING ST.CompanyCreation
    $USING AC.EntryCreation
    $USING AC.AccountOpening

    GOSUB INITIALISE
    GOSUB SET.VALUES
    GOSUB FORM.ARRAY

RETURN
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*-----------
** Initialise all variables
    DEFFUN System.getVariable()
    ID.LIST = ''; STMT.LIST = ''; Today = '';
RETURN
*----------------------------------------------------------------------------------------------------------------------
*** <region name= SET.VALUES>
*** <desc>Set values for calling the core API</desc>
SET.VALUES:
*------------
    IF CUSTOMER.ID NE '' AND EB.ErrorProcessing.getExternalUserId() EQ '' THEN
        USER.ACCOUNTS =  AC.AccountOpening.CustomerAccount.Read(CUSTOMER.ID, '')
        CONVERT @FM TO @SM IN USER.ACCOUNTS
    END ELSE
        USER.ACCOUNTS = ACCOUNT.LIST ;* Get Account list from the argument
    END
*If start and end date are not specified then produces one month data
    Today = EB.SystemTables.getToday()      ;*Get the today date

    IF START.DATE EQ '' THEN
        GET.DATE = Today
        EB.API.Cdt('',GET.DATE,'-30C')      ;*Get the Start date as one month from today
        START.DATE = GET.DATE
    END

    IF END.DATE EQ '' THEN
        END.DATE = Today                    ;*Get the End date as today
    END

    GOSUB GET.ID.LIST                       ;*Get the statement entries for the date range

RETURN
*-------------------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.ARRAY>
*** <desc>Check for the count and get the statment entries</desc>
FORM.ARRAY:
*-----------

    CurrListCount = DCOUNT(TXN.ARR,@FM)         ;*current count of statment entry Id's
    STMT.LIST<-1> = TXN.ARR                     ;*Assigning to new array

    IF CurrListCount < TXN.COUNT THEN           ;*Check the current count is less than Transaction count given as input parameter
        GOSUB COUNT.CYCLE                       ;*Repeated core api call to get the current count greater than provided transaction count
        ID.LIST = STMT.LIST
    END ELSE
        ID.LIST = STMT.LIST
    END
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------------
*** <region name= COUNT.CYCLE>
*** <desc>To Get the returned count greater than transaction count</desc>
COUNT.CYCLE:
*------------

    LOOP
    UNTIL CurrListCount GE TXN.COUNT        ;*Loop until current count is greater than transaction count
        EB.API.Cdt('',START.DATE,'-30C')        ;*Get start date as one month back date
        EB.API.Cdt('',END.DATE,'-30C')          ;*Get end date as one month back date
        GOSUB GET.ID.LIST                       ;*Call API to get the statement entry id's
        GOSUB NULL.CHECK                        ;*Check to validate whether the values are null
        IF RetValue NE '' THEN
            EXIT
        END ELSE
            SubListCount = '';
            SubListCount = DCOUNT(TXN.ARR,@FM)      ;*Temporary count for the current loop returned statment entry id's
            CurrListCount += SubListCount           ;*Adding with the total count
            STMT.LIST<-1> = TXN.ARR                 ;*Assigning to the same array for all statment entry id's
        END
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------
*** <region name= NULL.CHECK>
*** <desc>To check the returned value is null</desc>
NULL.CHECK:
*------------
    tempValue = ''; FirstValue = ''; NL.POS = ''; RetValue = '' ;*Initialising variables

    tempValue = 'DUMMY'             ;*Null value
    FirstValue = FIELD(TXN.ARR,@FM,1)   ;*first value from the returned array
*
    FINDSTR tempValue IN FirstValue SETTING NL.POS THEN     ;*Locate narrative from the statement narrative
        RetValue = "1"        ;*Set narrative found variable
    END ELSE
        IF FirstValue  EQ '' THEN
            RetValue = "1"        ;*Set narrative found variable
        END
    END
*
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.ID.LIST>
*** <desc>To get the statement entry id's for the specified date range</desc>
GET.ID.LIST:
*------------
*
    TXN.ARR = '';
    tmp=EB.Reports.getDFields(); tmp<1>='ACCT.ID'; EB.Reports.setDFields(tmp)           ;*Account input parameter
    tmp=EB.Reports.getDFields(); tmp<2>='BOOKING.DATE'; EB.Reports.setDFields(tmp)          ;*Booking date input parameter
    EB.Reports.setDLogicalOperands(1:@FM:2)
*
    tmp=EB.Reports.getDRangeAndValue(); tmp<1>=USER.ACCOUNTS; EB.Reports.setDRangeAndValue(tmp)     ;*Value for account parameter
    tmp=EB.Reports.getDRangeAndValue(); tmp<2>=START.DATE:@VM:END.DATE; EB.Reports.setDRangeAndValue(tmp)   ;*Value for date parameter

    AC.ModelBank.EStmtEntList(TXN.ARR)      ;*Call API which returns Statement entry id's
*
RETURN
*----------------------------------------------------------------------------------------------------------------------------
END
