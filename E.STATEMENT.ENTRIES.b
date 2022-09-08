* @ValidationCode : MjoxMzYwMjYzMzY6Q3AxMjUyOjE2MTI1MTIxMjg5OTQ6cy5zb21pc2V0dHlsYWtzaG1pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDIuMjAyMTAxMjEtMTMxNjoxNjc6OTI=
* @ValidationInfo : Timestamp         : 05 Feb 2021 13:32:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 92/167 (55.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 6 02/06/00  GLOBUS Release No. G13.2.00 12/02/03
*-----------------------------------------------------------------------------
* <Rating>99</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.STATEMENT.ENTRIES(ID.LIST)
*
*-------------------------------------------------------------------------
*
* Subroutine to return list of entries for a specific statement. Used
* by the enquiry system for printing and displaying statements.
* Passed in ENQUIRY.COMMON in D.RANGE.AND.VALUE is the 'id' of the
* statement:
*
* ACCOUNT.YYYYMMDD.FREQ.CARRIER eg 19.19930731.1.1
*
* Date, frequency and carrier are all optional and they default to
* today, 1 & 1 respectively.
*
* The entry ids are either on STMT.PRINTED or a combination of
* ACCT.STMT.ENTRY & ACCT.ENT.TODAY - the latter occurs when the date
* requested is beyond the last statement date.
*
* 10/02/98 - GB9800120
*            Extract the frequency correctly. It is not always 1, and the
*            wrong files can be opened and read
*
* 05/01/00 - GB9901859
*            Where ACCOUNT.STATEMENT has frequency 1 and frequency 2,
*            and the relationship is COMBINED, the system prints
*            statement with incorrect order and incorrect dates.
*
*10/12/01 - GLOBUS_EN_10000302
*           Changes made to include forward value dated statement
*           entries in the enquiry
*
* 22/10/02 - GLOBUS_EN_10001477
*            Changes done to adapt additional frequencies for account
*            statement
*
* 22/02/03 - BG_100003504
*            Changes made to display additional fqu details correctly.
*
* 23/06/03 - BG_100004605
*            Bug fixes for the enquiry STMT.ENT.BOOK related to
*            additional freq of account statement.
*
* 01/04/05 - BG_100008493
*            Double entries, remove the use of ACCT.ENT.TODAY as
*            ACCT.STMT.ENTRY is updated online.
*
* 29/09/05 - CI_10035054
*            While printing statement for closed account through PRINT.STATEMENT,
*            (only)the closure statement entry doesn't get populated in the
*            PRINT.STATEMENT output. Changes done to solve this.
*
* 25/10/05 - BG_100009585
*            As STMT.PRINTED is updated online , no need for ACCT.STMT.ENTRY.
*
* 07/12/05 - CI_10036642
*            Special statement not generated
*
* 15/09/10 - CI_10071447
*            ACCOUNT.STATEMENT.SCRN enquiry is restricted to give one account.
*            If more than one account is given, then while creating dummy entry
*            error is thrown in oracle database while indexing is set for account field.
*            Code rating changes have been done.
*
* 05/08/11 - ENHANCEMENT 211024 / TASK 211300
*            For HVT.ACCT get ACCT.ENT.FWD record from AC.HVT.TRIGGER file
*            so call EB.READ.HVT to the required record
*
* 10/08/11 -  Enhancement -  211023 / Task 211287
*            Coding to do special processing for HVT accounts.
*
* 24/01/12 - Defect 323305 / Task 342045
*            Initialising the variable "HVT.INFO".
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 06/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 26/11/18 - Enhancement 2802644 /  Task 2806568
*           INQ.LIQ.POSTINGS is to be called only when IC is installed.
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*
* 05/02/21- Enhancement 3760081 / Task 4133519
*          New routine AC.READ.ACCT.STMT.PRINT to read the records from STMT.PRINTED and STMT2.PRINTED
*          instead of STMT.PRINTED.READ and STMT2.PRINTED.READ and AC.SPLIT.ACCT.STMT.PRINT to update
*          STMT.PRINTED and STMT2.PRINTED.
*-------------------------------------------------------------------------
*
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AC.EntryCreation
    $USING AC.AccountStatement
    $USING AC.HighVolume
    $USING IC.InterestAndCapitalisation
    $USING EB.API

* 10000302 E
*
*-------------------------------------------------------------------------
*
    GOSUB INITIALISATION
    IF PROCESS.FLAG THEN
        GOSUB OPEN.FILES
        GOSUB BUILD.ENTRY.LIST
    END
*
RETURN
*
*-------------------------------------------------------------------------
*
INITIALISATION:
*
* Default details and open files
*
    LOCATE "STATEMENT.ID" IN EB.Reports.getDFields()<1> SETTING STMT.POS ELSE
        STMT.POS = 1          ;* Must be there
    END
    IF EB.Reports.getDRangeAndValue()<STMT.POS> THEN
        ACCOUNT = EB.Reports.getDRangeAndValue()<STMT.POS>[".",1,1]
        REQUESTED.DATE = EB.Reports.getDRangeAndValue()<STMT.POS>[".",2,1]
        FREQUENCY = EB.Reports.getDRangeAndValue()<STMT.POS>[".",3,1]
    END ELSE
*
** Look for the account number and date and frequency to build the key
*
        LOCATE "SELECT.ACCOUNT" IN EB.Reports.getDFields()<1> SETTING YAC.POS THEN
            ACCOUNT = EB.Reports.getDRangeAndValue()<YAC.POS>
        END ELSE
            ACCOUNT = ""
        END
        LOCATE "STMT.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS THEN
            REQUESTED.DATE = EB.Reports.getDRangeAndValue()<DATE.POS>
        END ELSE
            REQUESTED.DATE = ""
        END
        LOCATE "STMT.FREQ" IN EB.Reports.getDFields()<1> SETTING FREQ.POS THEN
            FREQUENCY = EB.Reports.getDRangeAndValue()<FREQ.POS>
        END ELSE
            FREQUENCY = 1
        END
*
    END

* Check if more than one account number is given
    PROCESS.FLAG = 1
    IF DCOUNT(ACCOUNT,@SM) GT 1 THEN
        PROCESS.FLAG = ''
        RETURN
    END

* GB9800120 - Extract the frequency correctly as in E.ACCOUNT.STATEMENT,
*             for example
    FREQUENCY = FREQUENCY[";",1,1]      ;* Strip off end bit
    FREQUENCY = FREQUENCY[1,1]
*
    ID.LIST = ""    ;* To be returned
    ENTRY.LIST = ""
    HVT = ''
    HVT.INFO = ''
*
    IF REQUESTED.DATE = "" THEN
        REQUESTED.DATE = EB.SystemTables.getToday()
    END
*
    IF FREQUENCY = "" THEN
        FREQUENCY = 1
    END

RETURN
*
*-------------------------------------------------------------------------
*
OPEN.FILES:

    FORWARD.MVMT.REQD = ''
    R.ACCOUNT.STATEMENT = AC.AccountStatement.tableAcStmtParameter('SYSTEM', AC.STMT.PARAM.ERR)
    IF R.ACCOUNT.STATEMENT THEN
        FORWARD.MVMT.REQD = R.ACCOUNT.STATEMENT<AC.AccountStatement.AcStmtParameter.AcStpFwdMvmtReqd>
    END

    EB.DataAccess.Opf("F.STMT.ENTRY",F.STMT.ENTRY.PATH)
RETURN
*
*-------------------------------------------------------------------------
*
CHECK.IC.INSTALLED:
*
* To check if IC is installed
*
    productId = 'IC'
    ICinstalled = ''
    EB.API.ProductIsInCompany(productId, ICinstalled)
    
RETURN
*-------------------------------------------------------------------------
BUILD.ENTRY.LIST:
*
* Find the statement appropriate to the requested date
*
* EN_10001477 S
    IF FREQUENCY[1,1] = 1 OR FREQUENCY[1,1] = 2 THEN        ;* BG_100003504 S
        ACCT.STMT.PRINT.ID = ACCOUNT
    END ELSE
        ACCT.STMT.PRINT.ID = ACCOUNT:".":FREQUENCY
    END   ;* BG_100003504 E

    IF FREQUENCY[1,1] GT "1" THEN
        ACCT.STMT.FILE =  "ACCT.STMT2.PRINT"
        STMT.PRINTED.FILE = "STMT2.PRINTED"
        FWD.STMT.PRINTED.FILE = "FWD.STMT2.PRINTED"

    END ELSE
        ACCT.STMT.FILE =  "ACCT.STMT.PRINT"
        STMT.PRINTED.FILE = "STMT.PRINTED"
        FWD.STMT.PRINTED.FILE = "FWD.STMT1.PRINTED"
    END


* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

    R.ACCT.STMT.PRINT = ""
    Y.HVT.FREQ = ''
*AC.HighVolume.EbReadHvt(ACCT.STMT.FILE, ACCT.STMT.PRINT.ID , R.ACCT.STMT.PRINT, '')          ;* Call the core api to get the merged info for HVT accounts
    InDetails<1>=ACCT.STMT.FILE
    InDetails<2>=ACCT.STMT.PRINT.ID
    
    RequestMode='MERGE.HVT'
    
    
            
    AC.AccountStatement.acReadAcctStmtPrint(InDetails, RequestMode, '','', '',R.ACCT.STMT.PRINT, '', '', '')
    
            
    LOCATE REQUESTED.DATE IN R.ACCT.STMT.PRINT<1> BY "AL" SETTING POS ELSE
        NULL
    END
*
    STATEMENT.DATE = R.ACCT.STMT.PRINT<POS>["/",1,1]
    END.DATE = REQUESTED.DATE
    START.DATE = FIELD(R.ACCT.STMT.PRINT<POS-1>,"/",1,1)
*
    IF STATEMENT.DATE THEN    ;* Real statement
* EN_10001477 S
        IF (FREQUENCY[1,1] # "1") AND (FREQUENCY[1,1] # "2") THEN     ;* BG_100004605 S/E
            STMT.PRINTED.ID = ACCOUNT:".":FREQUENCY:"-":STATEMENT.DATE
        END ELSE
            STMT.PRINTED.ID = ACCOUNT:"-":STATEMENT.DATE
        END

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

        R.STMT.PRINTED = ''
        ID.LIST = ''
        InDetails<1>=STMT.PRINTED.FILE
        InDetails<2>=STMT.PRINTED.ID
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',R.STMT.PRINTED , '', '', '')
;* Call the core api to get the merged info for HVT accounts
        ID.LIST = R.STMT.PRINTED

        IF ID.LIST EQ '' THEN
            EB.Reports.setEnqError("Missing STMT.PRINTED ":FREQUENCY: " record ":STMT.PRINTED.ID)
        END

    END
* 10000302 S
* If FORWARD.MVMT.REQD  is set then, read the record from the file FWD.STMT1.
* PRINTED OR FWD.STMT2.PRINTED for STMT.PRINTED id.Append only those
* stmt entries which are not already in ID.LIST
*
    IF FORWARD.MVMT.REQD THEN
        HVT.INFO = ''
        FWD.ID.LIST= ""
        AC.HighVolume.EbReadHvt(FWD.STMT.PRINTED.FILE, STMT.PRINTED.ID, HVT.INFO, '')  ;* Call the core api to get the merged info for HVT accounts
        FWD.ID.LIST = HVT.INFO

        IF FWD.ID.LIST THEN
            IF ID.LIST THEN
                LOOP
                    REMOVE FWD.STMT.ID FROM FWD.ID.LIST SETTING FWD.POS
                WHILE FWD.POS:FWD.STMT.ID DO
                    LOCATE FWD.STMT.ID IN ID.LIST<1> SETTING FWD.STMT.POS ELSE
                        ID.LIST<-1> = FWD.STMT.ID
                    END
                REPEAT
            END ELSE
                ID.LIST = FWD.ID.LIST
            END
        END
    END
*
* interest accruing subroutine
*
    LOCATE "INCLUDE.LIQ.INT" IN EB.Reports.getDFields()<1> SETTING INC.POS ELSE
        INC.POS = 0
    END
    IF EB.Reports.getDRangeAndValue()<INC.POS> = 'Y' THEN
        ACCT.ID = FIELD(ACCOUNT,@FM,1)
        GOSUB CHECK.IC.INSTALLED
        IF ICinstalled THEN
            IC.InterestAndCapitalisation.IntLiqPostings(ACCT.ID,START.DATE,END.DATE,ENTRY.LIST)
        END
        IF ENTRY.LIST <> "" THEN
            REC.CNT = DCOUNT(ENTRY.LIST,@FM)
            FOR X = 1 TO REC.CNT
                DUMMY.ID = "DUMMY.ID":EB.SystemTables.getTno():".":X
                ID.LIST<-1> = DUMMY.ID
                ENTRY.REC = RAISE(ENTRY.LIST<X>)
                WRITE ENTRY.REC TO F.STMT.ENTRY.PATH, DUMMY.ID
            NEXT X
        END
    END
*
** If Forward entries are requested then extract add the contents to
** the list of ACCT.ENT.FWD
*
    LOCATE "INCLUDE.FWD.ENT" IN EB.Reports.getDFields()<1> SETTING FWD.POS ELSE
        FWD.POS = 0
    END
    IF EB.Reports.getDRangeAndValue()<FWD.POS> = 'Y' THEN
        ACCT.ID = FIELD(ACCOUNT,@FM,1) ; AEF.REC = ""
* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.
        AC.HighVolume.EbReadHvt('ACCT.ENT.FWD', ACCT.ID, AEF.REC,ERR)
* 10000302 S
*
* Add those stmt entry ids from ACCT.ENT.FWD to ID.LIST,which are not
* already present in ID.LIST for the account
*
        IF FORWARD.MVMT.REQD THEN
            LOOP
                REMOVE AEF.ID FROM AEF.REC SETTING AEF.POS1
            WHILE AEF.ID:AEF.POS1 DO
                LOCATE AEF.ID IN ID.LIST<1> SETTING AEF.POS2 ELSE
                    ID.LIST<-1> = AEF.ID
                END
            REPEAT
        END ELSE
            IF AEF.REC THEN
                ID.LIST<-1> = AEF.REC
            END
        END
* 10000302 E
    END
*
    IF ID.LIST = '' THEN
        DUMMY.ID = 'DUMMY.ID':EB.SystemTables.getTno()
        DUMMY.REC = ''
        DUMMY.REC<AC.EntryCreation.StmtEntry.SteAccountNumber> = ACCOUNT
*
        WRITE DUMMY.REC TO F.STMT.ENTRY.PATH, DUMMY.ID
        ID.LIST = DUMMY.ID
    END
*
RETURN
*
*-------------------------------------------------------------------------
END
