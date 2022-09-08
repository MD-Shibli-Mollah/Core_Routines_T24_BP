* @ValidationCode : MjoxNDQ0Njk3NDMzOkNwMTI1MjoxNTk5NjQxMDI2ODg3OnMuc29taXNldHR5bGFrc2htaTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjA6MTcwOjEyMA==
* @ValidationInfo : Timestamp         : 09 Sep 2020 14:13:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 120/170 (70.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*--------------------------------------------------------------------------
* <Rating>769</Rating>
*--------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.STMT.ENT.BUILD(ENQ.DATA)
*--------------------------------------------------------------------------
* MODIFICATION HISTORY:
************************
* 25/10/11 - En- 99120 / Task - 156274
*            Improvement odf stmt.enquiries
*
* 14/12/11 - Defect 319668 / Task 320322
*            Changes done to get start date and end date accordingly.
*
* 19/12/11 - Defect 326700 / Task 326948
*            If HVT returns null values then do normal read to ACCT.STMT.PRINT
*            to get appropriate dates.
*
* 24/01/12 - Defect 323305 / Task 342045
*            Uninitialised variable error correction.
*
* 14/03/12 - Defect 367388 / Task 372044
*            Form correct STATEMENT.ID.
*
* 04/09/12 - Defect 472868 / Task 474925
*            when there is no entries for the requested period , modify the selection
*            accordingly.
*
* 12/09/12 - Defect 480518 / Task 480833
*            Populate processing date as null when no movement exist for the
*            stateemnt period so that core routine will identify and form dummy entry.
*
* 07/11/12 - Defect 497804 / Task 515252
*            ENQ.DATA is manupulated to update the OR relation so that query formed
*            in CONCAT.LIST.PROCESSOR joins the condition using OR relation.
*
* 20/11/12 - Task 522421
*            Eventhough FWD.MVMT.FLAG set system does not get the forward dated entries.
*            Changes done here to form the ENQ.DATA array to get the entries with processing
*            date greater than or equal to start date.
*
* 25/01/13 - Task 571809
*            During the first statement generation, entries falling below the frequency date
*            is not considered in the generated statement.
*
* 31/03/13 - Defect 559646 / Task 636125
*            When fwd.mvmt.req is set, assume one statement is generated and in current statement,
*            one transaction is input with future value date. When current statement is generated,
*            the future value dated entry is not printed.
*
* 09/07/13 - DEFECT 714730 / TASK 660714
*            SHOW.REVERSAL>NO, PROCESSING.DATE>NULL, MASK.PRINT>NULL
*            The above values are been hard coded in the routine. As the select statement built in
*            CONCAT.LIST.PROCESSOR was not picking up the correct value.
*
* 13/08/13 - Defect 750105 / Task 760912
*            For AA accounts when FWD.MVMT.REQ is set then do not get start date from ACCT.ACTIVITY.
* 27/12/13 - Task 867509
*            When statement was produced using enquiry ACCOUNT.STATEMENT for statement cycle 2
*            (with AC.STMT.HANDOFF available for cycle 2), system fails to use the AC.STMT.HANDOFF
*            available instead it was building its own handoff record internally based on statement cycle 1.
*
* 25/03/14 - Defcet 927037 / Task 932448
*            FROM.DATE and TO.DATE is displaying wrongly while running the enquiry
*            ACCOUNT.STATEMENT
*
* 11/04/14 - Defect 940894 / Task 968755
*            Pass the Statement Id correctly to check the existing entries.
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 02/09/14 - Defect - 1092449 / Task - 1102308
*            Statement Issues when closing accounts
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 24/05/17 - Defect 2113374 / Task 2135307
*            Statement printing missing an entry on First Statement
*
* 30/10/18 - EN 2828914 / Task 2828966
*            Assign carrier from the ENQ DATA based on the length of the Statement id part of the data
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*--------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING AC.BalanceUpdates
    $USING AC.AccountStatement
    $USING AC.HighVolume
    $USING EB.API
    $USING EB.DataAccess
*--------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB FORM.ENQ.DATA

RETURN
*--------------------------------------------------------------------------
INITIALISE:
*---------
    TEMP.ENQ.DATA = ''
    R.ACCT.STMT.PRINT = ''
    ACTUAL.STMT.ID = ''
    ACCOUNT.KEY = ''
    REQUESTED.DATE= ''
    FREQUENCY = ''
    CARRIER = ''
    REQ.STMT.DATE = ''
    ID.LEN = ''
    
    ACCOUNT.KEY = ENQ.DATA<4,1>[".",1,1]
    REQUESTED.DATE = ENQ.DATA<4,1>[".",2,1]
    FREQUENCY = ENQ.DATA<4,1>[".",3,1]
    FREQUENCY = FIELD(FREQUENCY,";",1)  ;* if FREQUENCY eq 1;1 THEN
        FREQUENCY = FREQUENCY[1,1]
    
        ID.LEN = DCOUNT(ENQ.DATA<4,1>,".")
        
        IF ID.LEN GE 4 THEN
            CARRIER = ENQ.DATA<4,1>[".",5,1]
        END ELSE
            CARRIER = ENQ.DATA<4,1>[".",4,1]
        END

        IF NOT(FREQUENCY) THEN
            FREQUENCY = 1
        END
        IF NOT(CARRIER) THEN
            CARRIER = 1
        END
        IF NOT(REQUESTED.DATE) THEN
            REQUESTED.DATE = EB.SystemTables.getToday()
        END

        ACTUAL.STMT.ID = ACCOUNT.KEY:".":REQUESTED.DATE:".":FREQUENCY:".":CARRIER

        RETURN
*--------------------------------------------------------------------------
FORM.ENQ.DATA:
*------------
***
        TEMP.ENQ.DATA = ENQ.DATA

        LOCATE 'STATEMENT.ID' IN TEMP.ENQ.DATA<2,1> SETTING ACT.POS THEN
            TEMP.ENQ.DATA<4,ACT.POS> = ACTUAL.STMT.ID
            ACT.POS += 1
        END
        TEMP.ENQ.DATA<2,ACT.POS> = "ACCT.ID"
        TEMP.ENQ.DATA<3,ACT.POS> = "EQ"
        TEMP.ENQ.DATA<4,ACT.POS> = ENQ.DATA<4,1>[".",1,1]

        LOCATE 'PROCESSING.DATE' IN TEMP.ENQ.DATA<2,1> SETTING DATE.POS THEN
            NULL
        END
        TEMP.ENQ.DATA<2,DATE.POS> = "PROCESSING.DATE"
        GOSUB GET.DATES

* During formation of query in CONCAT.LIST.PROCESSOR routine, join relation updated in 15th position
* of ENQ.DATA that will decide the relation between conditions in the query.
* eg: SSELECT FBNK.STMT.ENTRY WITH PROCESSING.DATE = "20091225" OR PROCESSING.DATE = ""

*   TEMP.ENQ.DATA<15,DATE.POS> = "OR" ;* Join the condition in the query
        TEMP.ENQ.DATA<15,DATE.POS> = "AND"


        LOCATE 'MASK.PRINT' IN TEMP.ENQ.DATA<2,1> SETTING MASK.POS THEN
            NULL
        END

        TEMP.ENQ.DATA<2,MASK.POS> = "MASK.PRINT"
        TEMP.ENQ.DATA<3,MASK.POS> = "EQ"
        TEMP.ENQ.DATA<4,MASK.POS> = "''"

        TEMP.ENQ.DATA<15,MASK.POS> = "OR"

* Processing date updated again in ENQ.DATA so as to select entries with Processing date EQ null
        TEMP.ENQ.DATA<2,DATE.POS+2> = "PROCESSING.DATE"
        TEMP.ENQ.DATA<3,DATE.POS+2> = "EQ"
        TEMP.ENQ.DATA<4,DATE.POS+2> = "''"

        GOSUB CHECK.FWD.MVMT.REQ

* When FORWARD.MVMT.REQD flag is set, there is no end date passed, so ENQ.DATA is modified.
* For example if the system forms the select command as
* SSELECT FBNK.STMT.ENTRY WITH PROCESSING.DATE EQ "20091222" OR PROCESSING.DATE EQ "" then this will be
* modified as SSELECT FBNK.STMT.ENTRY WITH PROCESSING.DATE GE "20091222" OR PROCESSING.DATE EQ ""
        IF FORWARD.MVMT.REQD THEN

            LOCATE 'STATEMENT.ID' IN TEMP.ENQ.DATA<2,1> SETTING DT.POS THEN
                REQ.STMT.DATE = TEMP.ENQ.DATA<4,DT.POS>[".",2,1]          ;* Get the date for which is statement is requested.
            END

            BEGIN CASE
                CASE TEMP.ENQ.DATA<3,DATE.POS> = 'RG'
* If system forms the operand as RG(Range) the date is formed as START.DATE:@SM:END.DATE. Since we modified
* the selection as GE(Greater than or equal to) we need to pass only the START.DATE.
                    TEMP.ENQ.DATA<4,DATE.POS> = TEMP.ENQ.DATA<4,DATE.POS,1>

                CASE TEMP.ENQ.DATA<3,DATE.POS> = 'LE'
* When fwd.mvmt.req is set, to include future dated entries, operand in enq.data is changed to GE during further processing.
* When statement freq is monthly from fwd.mvmt reqd set, assume 31 dec freq, entries input on 15 dec are skipped since
* operand passed as GE with date as freq date. This problem exist only when the 1st statement produced. To overcome this,
* when LE operand is passed, determine the 1st transaction date from acct.activity and update the date in enq.data so that
* all the entries from after 1st transaction date is included in the statement.
* GOSUB GET.START.DATE

* When it is the first statement to be printed, then include all the entries less than the requested date and greater than the
* requested date because forward movements is required. Hence hardcode the date as 1111111. This is applicabale for AA accounts too.
            
                    TEMP.ENQ.DATA<4,DATE.POS> = '11111111'
            END CASE

            TEMP.ENQ.DATA<3,DATE.POS> = "GE"
* When fwd.mvmt.req is set, assume one statement is generated and in current statement, one transaction is input with
* future value date. When current statement is generated, the future value dated entry is not printed.
            IF NOT(TEMP.ENQ.DATA<4,DATE.POS>) THEN
                TEMP.ENQ.DATA<4,DATE.POS> = REQ.STMT.DATE       ;* Update the fetched date in the processing date position
            END
        END

        LOCATE 'SHOW.REVERSAL' IN TEMP.ENQ.DATA<2,1> SETTING REV.POS THEN
            NULL
        END
        TEMP.ENQ.DATA<2,REV.POS> = "SHOW.REVERSAL"
        TEMP.ENQ.DATA<3,REV.POS> = "EQ"
        TEMP.ENQ.DATA<4,REV.POS> = "NO"

        ENQ.DATA = TEMP.ENQ.DATA

        RETURN
*
*--------------------------------------------------------------------------
GET.DATES:
*---------
*
        FILE.NAME = ''
        BEGIN CASE
            CASE FREQUENCY EQ '1'     ;*Read ACCT.STMT.PRINT, if Freq Cycle 1
                Y.AC.ID = ACCOUNT.KEY
                FILE.NAME = 'ACCT.STMT.PRINT'
                GOSUB READ.ACCT.STMT.PRINT
            CASE FREQUENCY EQ '2'     ;*Read ACCT.STMT2.PRINT, if Freq Cycle 2
                Y.AC.ID = ACCOUNT.KEY
                FILE.NAME = 'ACCT.STMT2.PRINT'
                GOSUB READ.ACCT.STMT.PRINT
            CASE '1'        ;*Read ACCT.STMT2.PRINT, if Freq cycle is other that 1 or 2
                Y.AC.ID = ACCOUNT.KEY:".":FREQUENCY
                FILE.NAME = 'ACCT.STMT2.PRINT'
                GOSUB READ.ACCT.STMT.PRINT
        END CASE

        R.STMT.DATE = FIELDS(R.ACCT.STMT.PRINT,'/',1,1)

        GOSUB DETERMINE.START.END.DATES

        BEGIN CASE

            CASE TEMP.ENQ.DATA<3,DATE.POS> = '' ;* if there is no date then pass as null. Core routine will take care.
                TEMP.ENQ.DATA<3,DATE.POS> = "EQ"
                TEMP.ENQ.DATA<4,DATE.POS> = ''

            CASE TEMP.ENQ.DATA<3,DATE.POS> = "RG"         ;* Check for IF.NO.MVMT set up and modify the dates accordingly.
                GOSUB CHECK.IF.MVMT.EXISTS

        END CASE

        RETURN
*--------------------------------------------------------------------------
*===================*
READ.ACCT.STMT.PRINT:
*===================*
* HVT flag should not be
* EB.READ.HVT has the inbuild logic to check if the account is HVT/NOT and get the notional merged record for HVT account
* or return the actual record for non HVT accounts.
        R.ACCT.STMT.PRINT = ""
        HVT.INFO = ''
*ERR = ''
*AC.HighVolume.EbReadHvt(FILE.NAME, Y.AC.ID, R.ACCT.STMT.PRINT, ERR)      ;* Call the core api to get the merged info for HVT accounts
        InDetails=''
        InDetails<1>=FILE.NAME
        InDetails<2>=Y.AC.ID
        InDetails<3>=''
        RequestMode='MERGE.HVT'
        LockRecord='No'
        AddlInfo=''
        ReservedIn=''
        AcctStmtRecord=''
        StmtSeqIndicator=''
        ErrorDetails=''
        ReservedOut=''
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, RequestMode, LockRecord, AddlInfo, ReservedIn, AcctStmtRecord, StmtSeqIndicator, ErrorDetails, ReservedOut)
        R.ACCT.STMT.PRINT=AcctStmtRecord
        RETURN
*---------------------------------------------------------------------------------
DETERMINE.START.END.DATES:
**************************

        LOCATE REQUESTED.DATE IN R.STMT.DATE<1> BY 'AR' SETTING POS THEN
            IF R.STMT.DATE<POS-1> THEN
                TEMP.ENQ.DATA<3,DATE.POS> = 'RG'
                START.DATE = R.STMT.DATE<POS-1>
                EB.API.Cdt('', START.DATE, '+1C')
                END.DATE = R.STMT.DATE<POS>
                TEMP.ENQ.DATA<4,DATE.POS> = START.DATE:@SM:END.DATE
            END ELSE
                TEMP.ENQ.DATA<3,DATE.POS> = "LE"
                TEMP.ENQ.DATA<4,DATE.POS> = REQUESTED.DATE
            END
        END ELSE
            IF R.STMT.DATE<POS> THEN
                IF R.STMT.DATE<POS-1> THEN
                    TEMP.ENQ.DATA<3,DATE.POS> = 'RG'
                    START.DATE = R.STMT.DATE<POS-1>
                    EB.API.Cdt('', START.DATE, '+1C')
                    END.DATE = R.STMT.DATE<POS>
                    TEMP.ENQ.DATA<4,DATE.POS> = START.DATE:@SM:END.DATE
                END ELSE
                    TEMP.ENQ.DATA<3,DATE.POS> = "LE"
                    TEMP.ENQ.DATA<4,DATE.POS> = R.STMT.DATE<POS>
                END
            END
        END

        RETURN
*--------------------------------------------------------------------------
CHECK.IF.MVMT.EXISTS:
*********************
* Check whether any transaction exists within the statement period if so then modify the selection so that
* core routine will form dummy entry.
*
        ACCOUNT.NUMBER = ''
        ACCOUNT.NUMBER<1> = ACCOUNT.KEY
        ACCOUNT.NUMBER<2> = "PROCESS"
        ACCOUNT.NUMBER<6> = ACTUAL.STMT.ID  ;* Pass Statement Id correctly and not the enquiry common variables which will not get populated in this stage..
        ENTRY.LIST = ''
        OPENING.BAL = ''
        ER = ''
        AC.AccountStatement.EbAcctEntryList(ACCOUNT.NUMBER,START.DATE,END.DATE,ENTRY.LIST,OPENING.BAL,ER)
        IF NOT(ENTRY.LIST) THEN
            TEMP.ENQ.DATA<3,DATE.POS> = "EQ"
            TEMP.ENQ.DATA<4,DATE.POS> = ''
        END

        RETURN
*------------------------------------------------------------------------
CHECK.FWD.MVMT.REQ:
*------------------
        R.AC.STMT.PARAM = ''
        EB.DataAccess.CacheRead("F.AC.STMT.PARAMETER","SYSTEM",R.AC.STMT.PARAM,'')

        FORWARD.MVMT.REQD = ''
        IF R.AC.STMT.PARAM THEN
            FORWARD.MVMT.REQD = R.AC.STMT.PARAM<AC.AccountStatement.AcStmtParameter.AcStpFwdMvmtReqd>
        END

        RETURN

*--------------------------------------------------------------------------
    END
