* @ValidationCode : MjotMzc1NDc1OTc6Q3AxMjUyOjE2MTI1MTIxMjc4MTI6cy5zb21pc2V0dHlsYWtzaG1pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDIuMjAyMTAxMjEtMTMxNjo3MDo0NQ==
* @ValidationInfo : Timestamp         : 05 Feb 2021 13:32:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/70 (64.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 2 02/06/00  GLOBUS Release No. G10.2.02 29/03/00
*-----------------------------------------------------------------------------
* <Rating>-63</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.SEL.STMT.VALUE(YID.LIST)

**************************************************************************************************
* Modification details :-                                                                        *
**************************************************************************************************
* 27/10/03   BG_100005509                                                                        *
*            Minor bug fix to offical source to build globus G13207.                             *
* 25/10/05 - BG_100009585
*            As STMT.PRINTED is updated online , no need to check for ACCT.STMT.ENTRY.
*            Removed the section GET.ACCT.STMT.ENTRY
*
* 24/08/06 - EN_10003010
*            As STMT.PRINTED is updated online, no need to add ACCT.ENT.TODAY
*            entries seperately.
*            Ref : SAR-2005-05-20-0005
*
* 16/08/11 - EN 211023 / Task 211287
*            Coding to do special processing for HVT accounts.
*
* 13/03/14 - Defect 929011 / Task 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 06/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*
* 05/02/21- Enhancement 3760081 / Task 4133519
*          New routine AC.READ.ACCT.STMT.PRINT to read the records from STMT.PRINTED and STMT2.PRINTED
*          instead of STMT.PRINTED.READ and STMT2.PRINTED.READ and AC.SPLIT.ACCT.STMT.PRINT to update
*          STMT.PRINTED and STMT2.PRINTED.

**************************************************************************************************

    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING AC.HighVolume
    $USING AC.ModelBank
    $USING AC.AccountStatement
*
MAIN.PARA:
*
    LOCATE "ACCOUNT.SEL" IN EB.Reports.getDFields()<1> SETTING YACCT.POS ELSE
        RETURN
    END
    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING YDATE.POS ELSE
        RETURN
    END
**
**
    YID.LIST = ""
    YACCT.VALUES = ""
    YACCT.VALUES = EB.Reports.getDRangeAndValue()<YACCT.POS>
    YDATE.VALUE = EB.Reports.getDRangeAndValue()<YDATE.POS>

    OPEN.BAL = AC.ModelBank.getYopBal()
* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

* HVT.INFO = ''
*AC.HighVolume.EbReadHvt('ACCT.STMT.PRINT', YACCT.VALUES, HVT.INFO, '')   ;* Call the core api to get the merged info for HVT accounts
    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=YACCT.VALUES
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
    YR.ACCT.STMT = AcctStmtRecord

    YSTMT.DATES = FIELDS(YR.ACCT.STMT,"/",1,1)
    YCOUNT = COUNT(YSTMT.DATES,@FM) + (YSTMT.DATES # '')

    LOCATE YDATE.VALUE IN YSTMT.DATES<1> BY "AR" SETTING YPOS THEN

        OPEN.BAL = FIELD(YR.ACCT.STMT<YPOS>,"/",2)
        AC.ModelBank.setYopBal(OPEN.BAL)
        GOSUB READ.ENTRY.ID
        GOSUB PROCESS.RTN
    END
    YPOS += 1
    FOR I = YPOS TO YCOUNT
        YDATE.VALUE = YSTMT.DATES<I>
        GOSUB READ.ENTRY.ID
        GOSUB PROCESS.RTN
    NEXT I
RETURN

PROCESS.RTN:
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        YR.STMT.ENTRY = ""
        YR.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(YENTRY.ID, STMT.ERR)

        IF YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteBookingDate> GE YDATE.VALUE THEN
            YID.LIST := @FM:YENTRY.ID
        END ELSE
            GOSUB OPENING.BAL

        END
    REPEAT

RETURN

*
OPENING.BAL:
*
    BEGIN CASE
        CASE YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteCurrency> = EB.SystemTables.getLccy()
            YAMOUNT.POS = AC.EntryCreation.StmtEntry.SteAmountLcy
        CASE YR.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteCurrency> = ""
            YAMOUNT.POS = AC.EntryCreation.StmtEntry.SteAmountLcy
        CASE 1
            YAMOUNT.POS = AC.EntryCreation.StmtEntry.SteAmountFcy
    END CASE
    OPEN.BAL += YR.STMT.ENTRY<YAMOUNT.POS>
    AC.ModelBank.setYopBal(OPEN.BAL)
RETURN

*
READ.ENTRY.ID:
*
* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

    YR.ENTRY.FILE = ''
    HVT.INFO = ''
    STMT.PRINT.ID = YACCT.VALUES:'-':YDATE.VALUE
    InDetails<1>='STMT.PRINTED'
    InDetails<2>=STMT.PRINT.ID
    AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',HVT.INFO , '','', '')
    YR.ENTRY.FILE = HVT.INFO

RETURN
*-----------------------------------------------------------------------------------------------------------------------------------
END
