* @ValidationCode : MjotMTUwNDI0Mzk5NzpDcDEyNTI6MTYxMjUxMjEyODI0MzpzLnNvbWlzZXR0eWxha3NobWk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMi4yMDIxMDEyMS0xMzE2OjczOjU4
* @ValidationInfo : Timestamp         : 05 Feb 2021 13:32:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/73 (79.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-78</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.INTERNAL.ENTRIES(ID.LIST)
*-------------------------------------------------------------------------
*
* Subroutine to return list of entries for all internal accounts with
* category supplied by the user.
*
* Passed in ENQUIRY.COMMON in D.RANGE.AND.VALUE is the 'id' of the
* category. Note: the selection for category can be EQ, RG etc.
* Call CONCAT.LIST.PROCESSOR to return list of categories.
*
*
* The entry ids are on STMT.PRINTED
*
*-------------------------------------------------------------------------
* 01/04/05 - BG_100008493
*            Double entries, remove the use of ACCT.ENT.TODAY as
*            ACCT.STMT.ENTRY is updated online.
*
* 25/10/05 - BG_100009585
*            As STMT.PRINTED is updated online , no need to check with
*            ACCT.STMT.ENTRY.
*
* 09/05/06 - CI_10041008
*            After clearing the R.ENQ variable to call CONCAT.LIST.PROCESSOR,
*            set COMPANY.SELECT from the original enquiry.
*
* 10/0811 - EN 211023 / Task 211287
*           Coding to do special processing for HVT accounts.
*
* 13/03/14 - Defect 929011 / TASK 939244
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*
* 05/02/21- Enhancement 3760081 / Task 4133519
*          New routine AC.READ.ACCT.STMT.PRINT to read the records from STMT.PRINTED and STMT2.PRINTED
*          instead of STMT.PRINTED.READ and STMT2.PRINTED.READ and AC.SPLIT.ACCT.STMT.PRINT to update
*          STMT.PRINTED and STMT2.PRINTED.
*-------------------------------------------------------------------------
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AC.HighVolume
    $USING AC.AccountStatement
*
*-------------------------------------------------------------------------
*
    GOSUB INITIALISATION
*
    LOOP
        REMOVE CATEGORY FROM CATEGORY.LIST SETTING D
    WHILE CATEGORY:D
        R.CATEG.INT.ACCT = AC.AccountOpening.tableCategIntAcct(CATEGORY, ERR)
        IF R.CATEG.INT.ACCT THEN
            ACCOUNT.LIST<-1> = R.CATEG.INT.ACCT
        END
    REPEAT
*
    LOOP
        REMOVE ACCOUNT.KEY FROM ACCOUNT.LIST SETTING D
    WHILE ACCOUNT.KEY:D
        GOSUB BUILD.ENTRY.LIST
    REPEAT
*
RETURN
*
*-------------------------------------------------------------------------
*
INITIALISATION:
*
* Default details and open files
*
    ID.LIST = ""    ;* Entries returned here
    CATEGORY.LIST = ""        ;* List of internal categories
    ACCOUNT.LIST = ""         ;* List of internal accounts
*
    SAVE.DATA.FILE.NAME = EB.Reports.getDataFileName()          ;* Save common variables
    SAVE.ENQ.SELECTION = EB.Reports.getEnqSelection()
    SAVE.R.ENQ = EB.Reports.getREnq()
    EB.Reports.setDataFileName("CATEG.INT.ACCT")
    EB.Reports.setREnq("")
*ENQ
    LOCATE "INTERNAL.CATEGORY" IN EB.Reports.getDFields()<1> SETTING POS THEN
        EB.Reports.setEnqSelection("")
        tmp=EB.Reports.getEnqSelection(); tmp<2>="@ID"; EB.Reports.setEnqSelection(tmp)
        tmp=EB.Reports.getEnqSelection(); tmp<3>=EB.Reports.getOperandList()<EB.Reports.getDLogicalOperands()<POS>>; EB.Reports.setEnqSelection(tmp);* EQ, RG etc
        tmp=EB.Reports.getEnqSelection(); tmp<4>=EB.Reports.getDRangeAndValue()<POS>; EB.Reports.setEnqSelection(tmp)
        tmp=EB.Reports.getREnq(); tmp<EB.Reports.Enquiry.EnqCompanySelect>=SAVE.R.ENQ<EB.Reports.Enquiry.EnqCompanySelect>; EB.Reports.setREnq(tmp);* CI_10041008 S/E
        EB.Reports.ConcatListProcessor()      ;* Returns list of accounts
    END
*
    EB.Reports.setDataFileName(SAVE.DATA.FILE.NAME);* Restore common variables
    EB.Reports.setEnqSelection(SAVE.ENQ.SELECTION)
    EB.Reports.setREnq(SAVE.R.ENQ)
*
    CATEGORY.LIST = EB.Reports.getEnqKeys()

    HVT = ''
    R.ACCOUNT = ''
    ACC.ERR = ''
*
RETURN
*
*
*-------------------------------------------------------------------------
*
BUILD.ENTRY.LIST:
*
* Read ACCT.STMT.PRINT for the statement dates & read STMT.PRINTED,
* ACCOUNT-DATE, for each date building the entries in ID.LIST.

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

    R.ACCT.STMT.PRINT = ""

*CALLING AC.READ.ACCT.STMT.PRINT INSTEAD OF EB.READ.HVT
    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=ACCOUNT.KEY
    InDetails<3>=''
    RequestMode='MERGE.HVT'
    LockRecord='No'
    AddlInfo=''
    ReservedIn=''
    AcctStmtRecord=''
    StmtSeqIndicator=''
    ErrorDetails=''
    ReservedOut=''
    AC.AccountStatement.acReadAcctStmtPrint(InDetails, RequestMode, LockRecord, AddlInfo, ReservedIn, R.ACCT.STMT.PRINT, StmtSeqIndicator, ErrorDetails, ReservedOut)
   
    LOOP
        REMOVE STMT.DETAILS FROM R.ACCT.STMT.PRINT SETTING D
    WHILE STMT.DETAILS:D
        STMT.PRINT.ID = ACCOUNT.KEY:"-":STMT.DETAILS["/",1,1]
        R.STMT.PRINTED = ''
        InDetails<1>='STMT.PRINTED'
        InDetails<2>=STMT.PRINT.ID
        AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',R.STMT.PRINTED , '', '', '')
        IF R.STMT.PRINTED THEN
            ENTRIES = R.STMT.PRINTED
            GOSUB ADD.ENTRIES
        END
    REPEAT
*
RETURN
*
*-------------------------------------------------------------------------
*
ADD.ENTRIES:
*
    IF ID.LIST THEN
        ID.LIST := @FM:ENTRIES
    END ELSE
        ID.LIST = ENTRIES
    END
*
RETURN
*
*-------------------------------------------------------------------------
PROGRAM.END:
RETURN
*
*-------------------------------------------------------------------------
END
*
