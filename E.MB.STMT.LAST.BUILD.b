* @ValidationCode : MjoxNDA0MDIyOTMwOkNwMTI1MjoxNTY4MTE1MzY1Mzg4OnN0YW51c2hyZWU6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4yMDE5MDcyMy0wMjUxOjYzOjU2
* @ValidationInfo : Timestamp         : 10 Sep 2019 17:06:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 56/63 (88.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>-52</Rating>
*-----------------------------------------------------------------------------

$PACKAGE AC.ModelBank

SUBROUTINE E.MB.STMT.LAST.BUILD(ENQ.DATA)
***************************************************************************************
* Subroutine Type : Subroutine

* Incoming : ENQ.DATA Common Variable contains all the Enquiry Selection Criteria Details

*Outgoing : ENQ.DATA Common Variable

*Attached to : ENQUIRY STMT.ENTRY.LAST

*Purpose  : To get the Selection Field values and passed to main routine

********************************************************************************************
* Modification History
*
*  6/09/12 - Defect 475320/Task 477182
*            Account Statement Binocular Drilldown not working as expected.
*
* 10/10/12 - Defect 485840 / Task 489108
*            When CHEQUE.ISSUE drill down is launched from Enquiry STMT.ENT.LAST, error message is thrown
*
* 13/04/15 - Defect 1298336 / Task 1313983
*            When there are no entries for the selected period it should pick the DUMMY entry and display to user
*            instead of the error "Either incorrect selection or invalid account"
*
* 04/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/05/17 - Defect - 2136713/ Task - 2140572
*            While run Enquiry STMT.ENT.LAST ,Fatal error in CDT due to the Y.DATES values
*            with subvalue markers before call AC.GET.ACCT.ENTRIES routine.
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
* *******************************************************************************************

    $USING EB.SystemTables
    $USING EB.API
    $USING AC.AccountStatement
    $USING AC.Config

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB MAIN.PROCESS
RETURN

*********************
INITIALISE:
**********************

    ACCT.POS = ""
    ACCT.NO = ""
    R.ACC.ERR = ""
    R.ACCOUNT.STATEMENT = ""
    ACC.PARAM.ERR = ""
    Y.STMT.DATE = ""
    TO.DATE = ''
    VDATE = ""
    DATE.TO.PROCESS = ""
    Y.DATES = ""

RETURN

***********************
OPEN.FILES:
***********************

    LOCATE "ACCT.ID" IN ENQ.DATA<2,1> SETTING ACC.POS THEN
        ACC.NO = ENQ.DATA<4,ACC.POS>
    END

    R.ACCOUNT.STATEMENT = AC.AccountStatement.tableAccountStatement(ACC.NO,R.ACC.STMT.ERR)

RETURN

******************************
MAIN.PROCESS:
******************************

* This to get the last statement printed date and also to get whether the system follows value dated or trade dated


    VDATE = 0
    IF (EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng> = 'Y') THEN
        VDATE = 1
    END

    Y.STMT.DATE = R.ACCOUNT.STATEMENT<AC.AccountStatement.AccountStatement.AcStaFquOneLastDate>

    TO.DATE = EB.SystemTables.getToday()

    EB.API.Cdt("",TO.DATE,'-1C')          ;*to get the stmt till yesterday

    IF Y.STMT.DATE = "" THEN
        ENQ.DATA<3,2> = "LE"
        ENQ.DATA<4,2> = TO.DATE
        NUM.OPER.VAL = "8"
* If the last statement is not present, will select the entries upto one calendar day less than today like upto 03 December.
        Y.DATES = ENQ.DATA<4,2>  ;*
    END ELSE
        EB.API.Cdt("",Y.STMT.DATE,'+1W')  ;*to get the next day after the last stmt printed
* If the last statement as 30 November,Today date as 04 December.
* Hence, to select the entries between the last stmt date upto one day calendar day less than today.
        IF (Y.STMT.DATE GT TO.DATE) THEN
            TO.DATE = Y.STMT.DATE
        END
        ENQ.DATA<3,2> = "RG"
        ENQ.DATA<4,2> = Y.STMT.DATE
        ENQ.DATA<4,2,2> = TO.DATE
        NUM.OPER.VAL = "2"
        Y.DATES<1,1> = ENQ.DATA<4,2,1>
        Y.DATES<1,2> = ENQ.DATA<4,2,2>
    END

    IF VDATE = 1 THEN
        ENQ.DATA<2,2> = "VALUE.DATE"
        DATE.TO.PROCESS = 'VALUE'
    END ELSE
        ENQ.DATA<2,2> = "BOOKING.DATE"
        DATE.TO.PROCESS = 'BOOK'
    END

    ENQ.DATA<2,1> = "ACCT.ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = ACC.NO

    ENTRY.LIST = ''							 ;* System will return the entries if exist for the given account.
    AC.AccountStatement.AcGetAcctEntries(ACC.NO, NUM.OPER.VAL , Y.DATES, DATE.TO.PROCESS, ENTRY.LIST)   ;* Check for entries for the given account.

    IF NOT(ENTRY.LIST) THEN                       ;* No entries exist. Append another condition to pick atleast dummy entry.
        ENQ.DATA<15,2> = 'OR'                     ;* Join the conditions using 'OR' conjunction.
        ENQ.DATA<2,3> = ENQ.DATA<2,2>
        ENQ.DATA<3,3> = 'EQ'
        ENQ.DATA<4,3> = ''
    END

RETURN
*------------------------------------------------------------------------
END
