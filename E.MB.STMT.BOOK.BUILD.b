* @ValidationCode : MjotNDI4ODgwOTIyOkNwMTI1MjoxNTg4NDA5MjIwODkzOmJoYXJhdGhzaXZhOjE5OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA0LjA6MzIxOjI0MA==
* @ValidationInfo : Timestamp         : 02 May 2020 14:17:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bharathsiva
* @ValidationInfo : Nb tests success  : 19
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 240/321 (74.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-154</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.STMT.BOOK.BUILD(ENQ.DATA)

*************************************************************************************************
* Subroutine Type: Subroutine

* Incoming : ENQ.DATA Common Variable contains all the Enquiry Selection Criteria Details

* Outgoing : ENQ.DATA Common Variable

* Attached to : ENQUIRY STMT.ENT.BOOK

* Purpose  : To get the Selection Field values and passed to main routine
*-----------------------------------------------------------------------------
* MODIFICATION HISTORY:
*************************
* 07/12/11 - Defect 319668 / Task 320322
*            Validation added to check for value,book or processing.date.
*
* 06/02/13 - Defect - 539102 / Task - 584381
*            System doesn't display the static info. when there are no entries to display it.
*
* 16/04/13 - Defect - 640740 / Task - 651632
*            When enquiry STMT.ENT.BOOK is launched without without any date then
*            enquiry throws server disconnected error.
*
** 30/10/13 - Defect 801588 / Task 824032
*            In STMT.ENT.BOOK enquiry, FIXED.SORT field as VALUE.DATE. Hence entry's
*            sorted based on VALUE.DATE, but client requirement is to sort the entries based on BOOKING.DATE or as per the sort selection.
*            FIXED.SORT field has been removed from enquiry and code is introduced to sort as per the user requirement.
*
* 04/05/15 - Defect 1331929 / Task 1335973
*            Enquiry crashes and times out if date input is other than 8 digits, since fatal error is called while call to CDT.
*            Before processsing, validation of dates carried out and proper error message thorwn to overcome fatal out.
*
* 23/10/15 - Defect 1494599 / Task 1509977
*            Output of Enquiry STMT.ENT.BOOK doesn't match with the ACCOUNT balance when a FT transaction
*            is input with booking date as working date and value date as Holiday.
*
* 13/01/17 - Defect 1980046 / Task 1983318
*            Transaction failure alerts in enquiries STMT.ENT.BOOK
*            Fatal out error while running the STMT.ENT.BOOK with the booking date given as extra space.
*
* 27/11/17 - Defect 2357251 / Task 2358886
*            For No sort option internal fixed selection also should not be done
*
* 08/05/18 - Defect 2572597 / Task 2581511
*            Position of the Dates is not hardcoded rather the Date will be located and located
*            position will be used to assign the values.
*            This will make sure correct command is formed.
*
* 04/09/18 - Defect 2736629 / Task 2753954
*            Form Y.DATES properly for RG operand where only one selection date is provided
*
*
* 29/09/18 - Defect 2783287 / Task 2789596
*            STMT.ENT.BOOK enquiry is not working properly when selection criteria is given with BETWEEN operand.
*
* 17/10/18 - Defect 2797621 / Task 2815933
*            Define the sorting conditions if both fixed and dynamic sorting conditions are not
*            present
*
* 27/08/19 - Defect 3262058 / Task 3310704
*            Enquiry STMT.ENT.BOOK does not show output when launched from company other than
*            account's company
*
* 02/05/20 - Defect 3716927 / Task 3723699
*            The core enquiry STMT.ENT.BOOK does not display the entries in browser as per the sorting condition defined in FIXED.SORT field of enquiry record.
************************************************************************************************
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.AccountStatement
    $USING EB.API
    $USING EB.Utility
    $USING EB.DataAccess
    $USING AC.StmtPrinting
    $USING AC.Config
    $USING EB.Iris
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
***************************************************************************************************

    GOSUB INITIALISE
    GOSUB PROCESS
    IF EB.Reports.getEnqError() EQ '' AND ACCT.NO THEN
        GOSUB PRE.SELECTION.PROCESS ;* Pre process to be done to show enquiry output when launched from company other than account's company
    END
    IF EB.Reports.getEnqError() EQ '' AND DATE.TO.PROCESS AND PROCESS.NEXT THEN
        GOSUB CHECK.IF.MVMT.EXISTS
    END
RETURN
****************************************************************************************************

INITIALISE:
    DATE.POS = ""
    ACCT.POS = ""
    ACCT.NO = ""
    BOOK.POS = ""
    BOOK.VAL = ""
    PROCESS.POS = ""
    PROCESS.VAL = ""
    VALUE.POS = ""
    VALUE.VAL = ""
    OPER.VAL = ""
    SET.FLAG = ""
    DATE.TO.PROCESS = ""
    Y.DATES = ""
    OLD.ENQ.DATA = ENQ.DATA
    FIXED.FLAG = 0
    VDATE = EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng> ;*valuedated system
    PROCESS.NEXT = 1
    
    UxpBrowser=''
    EB.Iris.RpGetIsUxpBrowser(UxpBrowser)   ;*Check for UXP request
    IF UxpBrowser THEN
        noOfSelFields = DCOUNT(ENQ.DATA<2>,@VM)             ;*Get the total number of selection fields
        FOR field=1 TO noOfSelFields
            IF ENQ.DATA<2,field> MATCHES 'BOOKING.DATE':@VM:'VALUE.DATE':@VM:'PROCESSING.DATE' THEN         ;*Check for any date field as criteria
                IF ENQ.DATA<3,field> MATCHES 'GE':@VM:'LE' THEN                                             ;*Check for the operators sepcified for range values
                    LOCATE ENQ.DATA<2,field> IN secondOccFields<1,1> SETTING firstPos THEN                  ;*Check 2nd occurence of the date fields
                        IF ENQ.DATA<2,field> EQ ENQ.DATA<2,secondOccFields<2,firstPos>> THEN                ;*In-case of same criteria field mentioned again as selection
                            ENQ.DATA<3,secondOccFields<2,firstPos>> = 'RG'                                  ;*Update the operator as Range
                            ENQ.DATA<4,secondOccFields<2,firstPos>>:=' ':ENQ.DATA<4,field>                  ;*Update the 2nd (or) max limit mentioned as range value
                        END
                    END ELSE
                        secondOccFields<1,-1> = ENQ.DATA<2,field>                                          ;*Assign the 2nd occurence date field
                        secondOccFields<2,-1> = field                                                       ;*Assign the 2nd occurence position of date field
                    END
                END
            END
        NEXT field
    END
    
RETURN

PROCESS:


    LOCATE "ACCT.ID" IN ENQ.DATA<2,1> SETTING ACCT.POS THEN
        ACCT.NO = ENQ.DATA<4,ACCT.POS>
    END

    LOCATE "BOOKING.DATE" IN ENQ.DATA<2,1> SETTING BOOK.POS THEN
        DATE.POS = BOOK.POS
        BOOK.VAL = ENQ.DATA<4,BOOK.POS>
        OPER.VAL = ENQ.DATA<3,BOOK.POS>
        IF BOOK.VAL  THEN
            DATE.TO.PROCESS = 'BOOK'
            DATE.VAL = BOOK.VAL
            GOSUB VALIDATE.DATE
            BOOK.VAL = DATE.VAL
        END
    END

    LOCATE "VALUE.DATE" IN ENQ.DATA<2,1> SETTING VALUE.POS THEN
        DATE.POS = VALUE.POS
        VALUE.VAL = ENQ.DATA<4,VALUE.POS>
        OPER.VAL = ENQ.DATA<3,VALUE.POS>
        IF VALUE.VAL THEN
            DATE.TO.PROCESS = 'VALUE'
            DATE.VAL = VALUE.VAL
            GOSUB VALIDATE.DATE
            VALUE.VAL = DATE.VAL
        END
    END

    LOCATE "PROCESSING.DATE" IN ENQ.DATA<2,1> SETTING PROCESS.POS THEN
        DATE.POS = PROCESS.POS
        PROCESS.VAL = ENQ.DATA<4,PROCESS.POS>
        OPER.VAL = ENQ.DATA<3,PROCESS.POS>
        IF PROCESS.VAL THEN
            DATE.TO.PROCESS = 'PROCESS'
            DATE.VAL = PROCESS.VAL
            GOSUB VALIDATE.DATE
            PROCESS.VAL = DATE.VAL
        END
    END
* Do not modify ENQ.DATA when selection has any two dates, set Enq error and return back.
    BEGIN CASE
        CASE BOOK.VAL
            IF PROCESS.VAL NE '' OR  VALUE.VAL NE '' THEN
                ENQ.DATA = OLD.ENQ.DATA
                EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
                RETURN
            END
        CASE PROCESS.VAL
            IF BOOK.VAL NE '' OR  VALUE.VAL NE '' THEN
                ENQ.DATA = OLD.ENQ.DATA
                EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
                RETURN
            END

        CASE VALUE.VAL
            IF BOOK.VAL NE '' OR  PROCESS.VAL NE '' THEN
                ENQ.DATA = OLD.ENQ.DATA
                EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
                RETURN
            END

    END CASE

    ENQ.DATA<2,ACCT.POS> = "ACCT.ID"
    ENQ.DATA<3,ACCT.POS> = "EQ"
    ENQ.DATA<4,ACCT.POS> = ACCT.NO
    
    IF ENQ.DATA<16> NE 'YES' THEN          ;* Only if there is no No sort option internal fixed selection should be done
        GOSUB FILTER.SORT
        GOSUB USER.DEFINED.SORT   ;*sorting data based on sort.
    END
    
RETURN

*----------------------------------------------------------------
FILTER.SORT:
*************
* Determine if fixed sorting conditions are mentioned in enquiry record to avoid overwriting of
* sorting conditions. If both fixed sort and dynamic sort conditions are given, dynamic sort takes precedence.
    RENQ.REC = EB.Reports.getREnq()
    FIXED.SORT.CNT = DCOUNT(RENQ.REC<EB.Reports.Enquiry.EnqFixedSort>,@VM)
    FOR SORT.CNT = 1 TO FIXED.SORT.CNT
        IF (RENQ.REC<EB.Reports.Enquiry.EnqFixedSort,SORT.CNT> MATCHES 'BOOKING.DATE':@VM:'VALUE.DATE':@VM:'PROCESSING.DATE') OR (RENQ.REC<EB.Reports.Enquiry.EnqFixedSort,SORT.CNT> MATCHES 'BOOKING.DATE DSND':@VM:'VALUE.DATE DSND':@VM:'PROCESSING.DATE DSND') THEN
            FIXED.FLAG = 1
            SORT.CNT = FIXED.SORT.CNT
        END
    NEXT SORT.CNT
    
*If enquiry does'nt have sorting condition(ENQ.DATE<9> Equail to null and R.ENQ<4> = '')  , than system should consider the selection filed
    BEGIN CASE

        CASE DATE.TO.PROCESS = 'BOOK'

            ENQ.DATA<2,BOOK.POS> = "BOOKING.DATE"
            ENQ.DATA<3,BOOK.POS> =  OPER.VAL
            ENQ.DATA<4,BOOK.POS> = BOOK.VAL
            IF ENQ.DATA<9> EQ '' AND NOT(FIXED.FLAG) THEN       ;*Enquiry doesn't have sorting condition
                tmp=EB.Reports.getREnq(); tmp<4,1>="BOOKING.DATE"; EB.Reports.setREnq(tmp);*pass the booking. date
                tmp=EB.Reports.getREnq(); tmp<4,2>="DATE.TIME"; EB.Reports.setREnq(tmp)
            END
        CASE DATE.TO.PROCESS = 'VALUE'

            ENQ.DATA<2,VALUE.POS> = "VALUE.DATE"
            ENQ.DATA<3,VALUE.POS> =  OPER.VAL
            ENQ.DATA<4,VALUE.POS> = VALUE.VAL
            IF ENQ.DATA<9> EQ '' AND NOT(FIXED.FLAG) THEN
                tmp=EB.Reports.getREnq(); tmp<4,1>="VALUE.DATE"; EB.Reports.setREnq(tmp)
                tmp=EB.Reports.getREnq(); tmp<4,2>="DATE.TIME"; EB.Reports.setREnq(tmp)
            END
        CASE DATE.TO.PROCESS = 'PROCESS'

            ENQ.DATA<2,PROCESS.POS> = "PROCESSING.DATE"
            ENQ.DATA<3,PROCESS.POS> =  OPER.VAL
            ENQ.DATA<4,PROCESS.POS> = PROCESS.VAL
            IF ENQ.DATA<9> EQ '' AND NOT(FIXED.FLAG) THEN
                tmp=EB.Reports.getREnq(); tmp<4,1>="PROCESSING.DATE"; EB.Reports.setREnq(tmp)
                tmp=EB.Reports.getREnq(); tmp<4,2>="DATE.TIME"; EB.Reports.setREnq(tmp)
            END
    END CASE

RETURN
*------------------------------------------------------
USER.DEFINED.SORT:
******************
*if enquiry has sorting condition, than pass the enquiry (R.ENQ<4>) as per the sorting order
    IF ENQ.DATA<9> THEN
        FIXED.CNT = DCOUNT(ENQ.DATA<9>,@VM)        ;* Dcount the user sort
        IF EB.Reports.getREnq()<4> THEN      ;*if FIXED.SORT is set in Enquiry
            SAVE.ENQ.SORT=EB.Reports.getREnq()<4>
        END
        SORT.CNT = 1
        LOOP
        WHILE SORT.CNT LE FIXED.CNT
            tmp=EB.Reports.getREnq(); tmp<4,SORT.CNT>=ENQ.DATA<9,SORT.CNT>; EB.Reports.setREnq(tmp)
            SORT.CNT += 1
        REPEAT
        IF SAVE.ENQ.SORT THEN
            Y.DATE.CNT=FIXED.CNT + 1
            tmp=EB.Reports.getREnq(); tmp<4,Y.DATE.CNT>=SAVE.ENQ.SORT; EB.Reports.setREnq(tmp);*adding DATE&TIME to the last position
        END
    END

RETURN
*-------------------------------------------------------------------------------------
CHECK.IF.MVMT.EXISTS:
*********************
* Check whether any transaction exists within the statement period if so then modify the selection so that
* core routine will form dummy entry.
*
    IF ENQ.DATA<4,DATE.POS> EQ '!TODAY' THEN
        ENQ.DATA<4,DATE.POS> = EB.SystemTables.getToday()                           ;* If period is today, assign today's date.
    END

    GOSUB CONV.OPER.VAL.TO.NUM.OPER.VAL           ;* Core enquriy can understand the operands only in numeric.

    ENTRY.LIST = ''                               ;* System will return the entries if exist for the given account.

    IF OPER.VAL NE 'RG' THEN
        Y.DATES = ENQ.DATA<4,DATE.POS>                       ;* Get the selection period.
    END

* Calculate the period end when the system with value dated, in enquiry given date as process date and operands are EQ or RG or LE
    IF  VDATE = "Y" AND DATE.TO.PROCESS = 'PROCESS' AND (NUM.OPER.VAL = 1 OR NUM.OPER.VAL = 2 OR NUM.OPER.VAL = 8) THEN
        GOSUB CHECK.STMT.CONTROL.SETUP
    END

    AC.AccountStatement.AcGetAcctEntries(ACCT.NO, NUM.OPER.VAL, Y.DATES, DATE.TO.PROCESS, ENTRY.LIST)   ;* Check for entries for the given account.
* Insert the condition onto correct position.
    IF NOT(ENTRY.LIST) THEN                       ;* No entries exist. Append another condition to pick atleast dummy entry.
        ENQ.DATA<15,DATE.POS> = "OR"
        INS ENQ.DATA<2,DATE.POS> BEFORE ENQ.DATA<2,DATE.POS+1>
        INS 'EQ' BEFORE ENQ.DATA<3,DATE.POS+1>
        INS '' BEFORE ENQ.DATA<4,DATE.POS+1>
    END

RETURN
*------------------------------------------------------------------------
CONV.OPER.VAL.TO.NUM.OPER.VAL:
******************************

    NUM.OPER.VAL = ''          ;* Possible operands are EQ, RG, LT, LE, GT, GE.

    BEGIN CASE
        CASE OPER.VAL EQ 'EQ'
            NUM.OPER.VAL = 1
        CASE OPER.VAL EQ 'RG'
            NUM.OPER.VAL = 2
            IF NOT(INDEX(ENQ.DATA<4,DATE.POS>, ' ', 1)) THEN
                Y.DATES = ENQ.DATA<4,DATE.POS>:@VM:ENQ.DATA<4,DATE.POS>     ;* form Y.DATES where both start and end date is the selection date
                ENQ.DATA<4,DATE.POS> = ENQ.DATA<4,DATE.POS>:' ':ENQ.DATA<4,DATE.POS>
            END ELSE
                START.DATE = FIELD(ENQ.DATA<4,DATE.POS>, ' ', 1)
                END.DATE = FIELD(ENQ.DATA<4,DATE.POS>, ' ', 2)
                Y.DATES = START.DATE:@VM:END.DATE
            END
        CASE OPER.VAL EQ 'LT'
            NUM.OPER.VAL = 3
            EB.API.Cdt('', ENQ.DATA<4,DATE.POS>, '-1C')
        CASE OPER.VAL EQ 'LE'
            NUM.OPER.VAL = 8
        CASE OPER.VAL EQ 'GT'
            NUM.OPER.VAL = 4
            EB.API.Cdt('', ENQ.DATA<4,DATE.POS>, '+1C')
        CASE OPER.VAL EQ 'GE'
            NUM.OPER.VAL = 9
    END CASE

RETURN
*------------------------------------------------------------------------
*** <region name= VALIDATE.DATE>
VALIDATE.DATE:
*** <desc>
**  Validations to handle Date input provided by the user.</desc>

    SAVE.COMI = EB.SystemTables.getComi()
    GIVEN.DATE = DATE.VAL
    IF OPER.VAL EQ 'RG' AND INDEX(GIVEN.DATE,' ', 1) THEN
        FIRST.DATE = FIELD(GIVEN.DATE,' ',1)
        EB.SystemTables.setComi(FIRST.DATE)
        GOSUB SET.ENQ.ERROR
        FIRST.DATE = EB.SystemTables.getComi()
        DATE.VAL = FIRST.DATE
        
        SECOND.DATE = FIELD(GIVEN.DATE,' ',2)
        IF SECOND.DATE THEN
            EB.SystemTables.setComi(SECOND.DATE)
            GOSUB SET.ENQ.ERROR
            SECOND.DATE = EB.SystemTables.getComi()

            DATE.VAL = FIRST.DATE:" ":SECOND.DATE
        END
    END ELSE
        EB.SystemTables.setComi(DATE.VAL)
        GOSUB SET.ENQ.ERROR
        DATE.VAL = EB.SystemTables.getComi()
    END

    EB.SystemTables.setComi(SAVE.COMI)

RETURN
*------------------------------------------------------------------------
*** <region name= SET.ENQ.ERROR>
SET.ENQ.ERROR:
*** <desc>
**  Sets the error message if ETEXT returned from IN2D routine </desc>

    IF EB.SystemTables.getComi() NE "!TODAY" THEN
        EB.Utility.InTwod("11","D")
        IF EB.SystemTables.getEtext() THEN
            EB.Reports.setEnqError(EB.SystemTables.getEtext())
        END
    END

RETURN
*------------------------------------------------------------------------
CHECK.STMT.CONTROL.SETUP:
************************
* In STATEMENT.CONTROL application, If the STMT.DATE.TYPE field is set as PERIOD then system will show the current system
* period end date as (next working day - 1 calander day)
    R.STATEMENT.CONTROL = ''
    YERR = ''

    EB.API.GetStandardSelectionDets('STATEMENT.CONTROL',SS.FIELD) ;* Get Standard selection record.

    LOCATE "STMT.DATE.TYPE" IN SS.FIELD<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING FIELD.POS THEN  ;* date type field found
        EB.DataAccess.CacheRead('F.STATEMENT.CONTROL','SYSTEM',R.STATEMENT.CONTROL,YERR)
        IF R.STATEMENT.CONTROL AND R.STATEMENT.CONTROL<AC.StmtPrinting.StatementControl.ScontStmtDateType> EQ 'PERIOD' THEN
            GOSUB GET.PERIOD.END.DATE
        END
    END

RETURN
******************************************************
GET.PERIOD.END.DATE:
**********************
* Calculating the period end date as (next working day - 1 calander day).

    BEGIN CASE

        CASE NUM.OPER.VAL EQ 1 ;* while doing enquiry if the user given EQ operater modifiying the operand to ranges(RG)
            START.DATE1 = Y.DATES
            END.DATE1 = Y.DATES
            EB.API.Cdt('', END.DATE1, '+1W')
            EB.API.Cdt('', END.DATE1, '-1C')
            IF  START.DATE1 <> END.DATE1 THEN
                ENQ.DATA<3,DATE.POS> = 'RG'
                NUM.OPER.VAL = 2
                ENQ.DATA<4,DATE.POS> = START.DATE1:@SM:END.DATE1
                Y.DATES = ENQ.DATA<4,DATE.POS>
            END

        CASE NUM.OPER.VAL EQ 2 ;* while doing enquiry if the user given RG operater calcute start date and end dates
            IF Y.DATES<1,2> NE '' THEN
                START.DATE1 = Y.DATES<1,1>
                END.DATE1 = Y.DATES<1,2>
                EB.API.Cdt('', END.DATE1, '+1W')
                EB.API.Cdt('', END.DATE1, '-1C')
                ENQ.DATA<4,DATE.POS> = START.DATE1:@SM:END.DATE1
                Y.DATES = ENQ.DATA<4,DATE.POS>
            END

        CASE NUM.OPER.VAL EQ 8  ;* while doing enquiry if the user given LE operater calcute end dates
            END.DATE1 = Y.DATES
            EB.API.Cdt('', END.DATE1, '+1W')
            EB.API.Cdt('', END.DATE1, '-1C')
            ENQ.DATA<4,DATE.POS> = END.DATE1
            Y.DATES = ENQ.DATA<4,DATE.POS>

    END CASE

RETURN
******************************************************
PRE.SELECTION.PROCESS:
**********************
*Check setup as per enquiry record and set correct account company </desc>
    
    R.ENQ = EB.Reports.getREnq()
    COMP.FOR.ENQ = ''
    COMP.FOR.ENQ = R.ENQ<EB.Reports.Enquiry.EnqCompForEnq>
    IF NOT(COMP.FOR.ENQ) THEN   ;* If no company is defined in enquiry to access data just return
        RETURN
    END

    ACC.REC = '' ; ACC.ER = ''
    ACC.REC = AC.AccountOpening.Account.Read(ACCT.NO, ACC.ER)   ;* Read account and take its company
    IF ACC.ER THEN
        ACC.ER = ''
        AC.AccountOpening.AccountHistRead(ACCT.NO, ACC.REC, ACC.ER)
    END
    
    IF ACC.ER THEN
        RETURN
    END
    
    ACC.COMP = ACC.REC<AC.AccountOpening.Account.CoCode>
    COMP.REC = '' ; COMP.ER = ''
    COMP.REC = ST.CompanyCreation.Company.CacheRead(ACC.COMP, COMP.ER)  ;* Get account's company record
    LEAD.COMP = COMP.REC<ST.CompanyCreation.Company.EbComFinancialCom>  ;* If in case, its branch company then get the lead company
* Consider the case when Comp For Enq is defined as ALL.COMPANY and BNK and NL1 are not sharing customers. In that case, if company mnemonic is passed for BNK
* account from NL1 then, we are already in BNK and account read will be successful. But back in CONCAT.LIST.PROCESSOR, we would have looped through all lead
* companies which might result is error as companies can be loaded in any order. Also if BNK & EU1 are only defined in Comp For Enq and user gives account
* of MF1 with mnemonic, then also read of account will be succesful and we will be currently in MF1 only. In order to not get any error from CONCAT.LIST.PROCESSOR
* manipulate the R.ENQ with account company here if that company is not there.
    IF LEAD.COMP EQ EB.SystemTables.getIdCompany() THEN
        IF COMP.FOR.ENQ EQ 'ALL.COMPANY' THEN
            R.ENQ<EB.Reports.Enquiry.EnqCompForEnq> = LEAD.COMP ;* Manipulate the account's company so that CONCAT.LIST.PROCESSOR just processes only 1 company
            EB.Reports.setREnq(R.ENQ)
            RETURN  ;* Only return if Comp For Enq is ALL.COMPANY as there can be case when EU1 & BNK are defined and enquiry is run for BNK account from BNK
        END ELSE
            LOCATE LEAD.COMP IN COMP.FOR.ENQ<1,1> SETTING COMP.POS ELSE ;* Is this company defined in enquiry
                R.ENQ<EB.Reports.Enquiry.EnqCompForEnq> = LEAD.COMP
                EB.Reports.setREnq(R.ENQ)   ;* Manipulate the account's company so that CONCAT.LIST.PROCESSOR just processes only 1 company
                RETURN  ;* Only return if Comp For Enq did not contain accouny's company as there can be case when EU1 & BNK are defined and enquiry is run for BNK account from BNK
            END
        END
    END

* When mnemonic is not passed with account then we must manipulate Comp For Enq to account's company
    IF COMP.FOR.ENQ EQ 'ALL.COMPANY' THEN
        R.ENQ<EB.Reports.Enquiry.EnqCompForEnq> = LEAD.COMP ;* Manipulate the account's company so that CONCAT.LIST.PROCESSOR just processes only 1 company
        EB.Reports.setREnq(R.ENQ)
    END ELSE
        LOCATE LEAD.COMP IN COMP.FOR.ENQ<1,1> SETTING COMP.POS THEN ;* Is this company defined in enquiry
            R.ENQ<EB.Reports.Enquiry.EnqCompForEnq> = LEAD.COMP ;* Manipulate the account's company so that CONCAT.LIST.PROCESSOR just processes only 1 company
        END ELSE
            R.ENQ<EB.Reports.Enquiry.EnqCompForEnq> = ''    ;* This makes sure there is no performance issue in CONCAT.LIST.PROCESSOR as the account's company is not defined in enquiry
            PROCESS.NEXT = 0
        END
        EB.Reports.setREnq(R.ENQ)
    END

RETURN
******************************************************
END
