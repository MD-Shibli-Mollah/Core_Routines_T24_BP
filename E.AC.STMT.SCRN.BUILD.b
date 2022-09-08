* @ValidationCode : MjoxMDc5NjI5MTExOkNwMTI1MjoxNjEzMDM3MTQ1OTM3OnByYXNoYW50a3VtYXI6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMS4yMDIwMTIxNy0wNjI3Ojc2Ojcz
* @ValidationInfo : Timestamp         : 11 Feb 2021 15:22:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : prashantkumar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 73/76 (96.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201217-0627
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*--------------------------------------------------------------------------
* <Rating>-67</Rating>
*--------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.AC.STMT.SCRN.BUILD(ENQ.DATA)
*--------------------------------------------------------------------------
* MODIFICATION HISTORY:
************************
* 25/10/11 - En- 99120 / Task - 156274
*            Improvement odf stmt.enquiries
*
* 20/12/11 - Defect 325533 / Task 327440
*            Changes done to fetch past account.statement
*
* 08/08/13 - Defect 748536 / Task 752582
*            Amended the enquiry selection intead of replacing new selection criteria using INS
*            to solve the mandatory selection field missing while trying to server print in the desktop.
*
* 26/09/13 - Defect 748536 / Task 794439
*            Wrong entry displayed in the enquiry for the STMT.DATE inputted this is due to the wrong position of the
*            REQUESTED.DATE from the ENQ.DATA.
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 12/08/15 - Defect - 1432048 / Task 1436284
*            Done the changes to display Balance brought forward when there is not entries for that date.
*
* 10/09/15 - Defect 1432048/Task 1465432
*            Passing NULL value to PROCESSING.DATE instead of space.
*
* 08/12/16 - Defect 1937970 / Task 1949261
*            Pass ACCOUNT.NUMBER<2> as PROCESS, to get the entries with
*            processing date as greater than booking date (Ex: vd system)
* 23/02/17 - Defect 2006937 / Task 2028895
*            Processing date updated again in ENQ.DATA so as to select entries with Processing date EQ null.
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
* 11/02/21 - Defect 3968125 / 4223982
*            Changes done such that ENQ.DATA is updated with correct processing date when the requested date falls within first
*            1st freq date in ASP. Hence, entries should be returned between the input date in enq and freq date.
*
*--------------------------------------------------------------------------

    $USING AC.HighVolume
    $USING EB.API
    $USING EB.SystemTables
    $USING AC.AccountStatement

*--------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB FORM.ENQ.DATA
RETURN
*--------------------------------------------------------------------------
INITIALISE:
*---------

    R.ACCT.STMT.PRINT = ''
    TEMP.ENQ.DATA = ''

RETURN
*--------------------------------------------------------------------------
FORM.ENQ.DATA:
*------------
***
* ENQ.DATA assigned to the TEMP.ENQ.DATA and inserted the build routine selection fields
* after the related user level selection field in the TEMP.ENQ.DATA
* and finally assigned the TEMP.ENQ.DATA to the ENQ.DATA.

    TEMP.ENQ.DATA = ENQ.DATA
    LOCATE "SELECT.ACCOUNT" IN TEMP.ENQ.DATA<2,1> SETTING AC.POS THEN
        INS "ACCT.ID" BEFORE TEMP.ENQ.DATA<2,AC.POS+1>
        INS "EQ" BEFORE TEMP.ENQ.DATA<3,AC.POS+1>
        INS ENQ.DATA<4,AC.POS> BEFORE TEMP.ENQ.DATA<4,AC.POS+1>
    END

    LOCATE "STMT.DATE" IN TEMP.ENQ.DATA<2,1> SETTING DATE.POS THEN
        INS "PROCESSING.DATE" BEFORE TEMP.ENQ.DATA<2,DATE.POS+1>
    END

    ACCOUNT.ID = TEMP.ENQ.DATA<4,AC.POS>

    REQUESTED.DATE = TEMP.ENQ.DATA<4,DATE.POS>
    IF REQUESTED.DATE[1,1] = "!" THEN
        REQUESTED.DATE = EB.SystemTables.getToday()
    END

    GOSUB GET.DATES

    IF NOT(START.DATE) THEN
        INS "LE" BEFORE  TEMP.ENQ.DATA<3,DATE.POS+1>
        INS END.DATE BEFORE TEMP.ENQ.DATA<4,DATE.POS+1>
    END ELSE
        GOSUB CHECK.IF.MVMT.EXISTS
    END

* Processing date updated again in ENQ.DATA so as to select entries with Processing date EQ null
    INS "OR" BEFORE TEMP.ENQ.DATA<15,DATE.POS+1>
    INS "PROCESSING.DATE" BEFORE TEMP.ENQ.DATA<2,DATE.POS+2>
    INS "EQ" BEFORE TEMP.ENQ.DATA<3,DATE.POS+2>
    INS "''" BEFORE TEMP.ENQ.DATA<4,DATE.POS+2>
    
    ENQ.DATA = TEMP.ENQ.DATA

*
RETURN
*
*--------------------------------------------------------------------------
GET.DATES:
*--------------
* Call EB.READ.HVT which has internal check for HVT processing and returns the requiered record
* either notinaly merged data for HVT accounts or direct read to the file for non HVT accounts
    R.ACCT.STMT.PRINT = ""
  
*calling AC.READ.ACCT.STMT.PRINT
    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=ACCOUNT.ID
    InDetails<3>=''
    LockRecord="No"
    RequestMode="MERGE.HVT"
    AddInfo=''
    ReservedIn=''
    AcctStmtRecord=''
    StmtSeqIndicator=''
    ErrorDetails=''
    ReservedOut=''

    AC.AccountStatement.acReadAcctStmtPrint(InDetails,RequestMode,LockRecord,AddlInfo,ReservedIn,AcctStmtRecord,StmtSeqIndicator,ErrorDetails,ReservedOut)
    R.ACCT.STMT.PRINT=AcctStmtRecord
    Y.DATES = FIELDS(R.ACCT.STMT.PRINT , "/",1)
    CONVERT @VM TO @FM IN Y.DATES

    LOCATE REQUESTED.DATE IN Y.DATES BY "AR" SETTING POS ELSE
        NULL
    END

    END.DATE   = FIELD(R.ACCT.STMT.PRINT<POS>,"/",1,1)
*When the requested date falls within 1st freq date in ACCT.STMT.PRINT then update the start date with requested date.
    IF POS = 1 THEN
        START.DATE = REQUESTED.DATE
    END ELSE
        START.DATE = FIELD(R.ACCT.STMT.PRINT<POS-1>,"/",1,1)
    END

    IF START.DATE AND POS NE 1 THEN ;* If start.date is less than first freq date then fetch the entries from start date itself
        EB.API.Cdt('', START.DATE, '+1C')
    END

RETURN
*--------------------------------------------------------------------------
CHECK.IF.MVMT.EXISTS:
*********************
* Check whether any transaction exists within the statement period if so then modify the selection so that
* core routine will form dummy entry.
*
    ACCOUNT.NUMBER = ACCOUNT.ID
    ENTRY.LIST = ''
    OPENING.BAL = ''
    ER = ''

* ACCOUNT.STATEMENT related files such as ACCT.STMT.PRINT , STMT.PRINTED is updated based on
* processing date. Hence call EB.ACCT.ENTRY.LIST with ACCOUNT.NUMBER<2> as PROCESS, to fetch
* the entries based on processing date. This will ensure even the future value dated entries
* which falls on next statement cycle is displayed correctly.

    ACCOUNT.NUMBER<2> = "PROCESS"
    AC.AccountStatement.EbAcctEntryList(ACCOUNT.NUMBER,START.DATE,END.DATE,ENTRY.LIST,OPENING.BAL,ER)

    IF NOT(ENTRY.LIST) THEN
        TEMP.ENQ.DATA<3,DATE.POS+1> = 'EQ'
        TEMP.ENQ.DATA<4,DATE.POS+1> = ""
    END ELSE
        INS "RG" BEFORE  TEMP.ENQ.DATA<3,DATE.POS+1>
        INS START.DATE:@SM:END.DATE BEFORE TEMP.ENQ.DATA<4,DATE.POS+1>
    END

RETURN

*------------------------------------------------------------------------

END
