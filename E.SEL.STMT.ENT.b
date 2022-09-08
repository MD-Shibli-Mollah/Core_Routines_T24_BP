* @ValidationCode : MjoxMDI5MDkyMzg2OkNwMTI1MjoxNjEyNTEyMTI4NjQ0OnMuc29taXNldHR5bGFrc2htaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAyLjIwMjEwMTIxLTEzMTY6MjI2OjY3
* @ValidationInfo : Timestamp         : 05 Feb 2021 13:32:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 67/226 (29.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 3 02/06/00  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-284</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.SEL.STMT.ENT(YID.LIST)
*-----------------------------------------------------------------------------
*
* 09/01/02 - GLOBUS_EN_10000302
*            Changes are made to include forward statements which
*            have already been printed in the statement when requested
*
* 01/04/05 - BG_100008493
*            ACCT.STMT.ENTRY is updated online, so don't include
*            ACC.ENT.TODAY entries.
*
* 25/10/05 - BG_100009585
*            STMT.PRINTED is updated online , no need to check ACCT.STMT.ENTRY
*            Removed GET.ACCT.STMT.ENTRY section
*
* 18/07/05 - EN_10003010
*            Remove of ENT.TODAY/LWORK.DAY files
*            As the STMT.PRINTED gets updated online, hence remove the
*            ACCT.ENT.TODAY.
*            Ref : SAR-2005-05-20-005
*
* 06/04/09 - BG_100023123
*            OPF for ACCT.ENT.TODAY is removed since updates to ACCT.ENT.TODAY
*            can be switched off from ACCOUNT.PARAMETER
*
* 10/08/11 - EN 211023 / Task 211287
*           Coding to do special processing for HVT accounts.
*
* 16/02/14 - Defect 929011/ TASK 939224
*            Direct check for HVT flag in account record is removed and replaced
*            by the core API which can handle both HVT and non HVT accounts
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 05/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*
* 05/02/21- Enhancement 3760081 / Task 4133519
*          New routine AC.READ.ACCT.STMT.PRINT to read the records from STMT.PRINTED and STMT2.PRINTED
*          instead of STMT.PRINTED.READ and STMT2.PRINTED.READ and AC.SPLIT.ACCT.STMT.PRINT to update
*          STMT.PRINTED and STMT2.PRINTED.
*-------------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.AccountStatement
    $USING AC.HighVolume
    $USING EB.DataAccess
    $USING AC.Config
    $USING AC.EntryCreation
   
*
    YF.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT.PATH = ""
    EB.DataAccess.Opf(YF.ACCOUNT,F.ACCOUNT.PATH)
*

    FORWARD.MVMT.REQD = ''
    R.AC.STMT.PARAMETER = AC.AccountStatement.tableAcStmtParameter('SYSTEM', STMT.PARAM.ERR)
    FORWARD.MVMT.REQD = R.AC.STMT.PARAMETER<AC.AccountStatement.AcStmtParameter.AcStpFwdMvmtReqd>

    IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng> EQ 'Y' THEN
        IF FORWARD.MVMT.REQD THEN
            FWD.MVMT.FLAG = 1
        END
    END
*EN_10000302 ENDS

    LOCATE "ACCT.SEL" IN EB.Reports.getDFields()<1> SETTING ACCT.POS ELSE
        RETURN
    END
    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS ELSE
        RETURN
    END
*
    YID.LIST = ""
    YLIST.ID = "ACCT.ENQ":EB.SystemTables.getTno()
    YACCT.FIXED = "SSELECT ":YF.ACCOUNT
    YSENTENCE = "" ; YOPERAND = EB.Reports.getDLogicalOperands()<ACCT.POS>
    YVALUES = EB.Reports.getDRangeAndValue()<ACCT.POS>
*
    YACCT.LIST = "" ;* List of acct ids
*
    ON YOPERAND GOSUB V$EQU,
    PROCESS.RANGE,
    LESS.THAN,
    GREATER.THAN,
    NOT.EQUAL,
    LK,
    UL,
    LESS.THAN.EQ,
    GREATER.THAN.EQ,
    NOT.RANGE
*
** Now using YACCT.LIST build a list of statement entry ids for the given
** booking dates
*
    YOPERAND = EB.Reports.getDLogicalOperands()<DATE.POS>
    YVALUES = EB.Reports.getDRangeAndValue()<DATE.POS>
    HVT = ''
    IF YACCT.LIST THEN
        LOOP
            REMOVE YID.ACCT FROM YACCT.LIST SETTING YD
*
** Build list of possible stmt dates
*

* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.

            YR.ACCT.STMT.PRINT = ""

*CALLING AC.READ.ACCT.STMT.PRINT INSTEAD OF EB.READ.HVT WITH ACCT.STMT.PRINT
            InDetails<1>='ACCT.STMT.PRINT'
            InDetails<2>=YID.ACCT
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
            YR.ACCT.STMT.PRINT=AcctStmtRecord
            YSTMT.DATES = FIELDS(YR.ACCT.STMT.PRINT,"/",1,1)
*
            ON YOPERAND GOSUB EQU.DT,
            RANGE.DT,
            LESS.THAN.DT,
            GREATER.THAN.DT,
            NOT.EQUAL.DT,
            LK.DT,
            UL.DT,
            LESS.THAN.EQ.DT,
            GREATER.THAN.EQ.DT,
            NOT.RANGE.DT
*
        WHILE YD
        REPEAT
    END
*
    DEL YID.LIST<1> ;* Empty
RETURN
*
*------------------------------------------------------------------------
V$EQU:
*==
*
    YACCT.LIST = YVALUES
    CONVERT @VM TO @FM IN YACCT.LIST
    CONVERT @SM TO @FM IN YACCT.LIST
*
RETURN
*
*------------------------------------------------------------------------
EQU.DT:
*==
*
    YDATE.LIST = YVALUES
    LOOP
        REMOVE YDTE FROM YDATE.LIST SETTING YD
        LOCATE YDTE IN YSTMT.DATES<1> BY "AR" SETTING YPOS THEN       ;* Date FOUND
            GOSUB GET.STMT.PRINTED
        END ELSE    ;* Take closest
            IF YSTMT.DATES<YPOS> THEN
                GOSUB GET.STMT.PRINTED
            END
        END
    WHILE YD
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
PROCESS.RANGE:
*====
*
    IF YVALUES<1,1,2> = "" THEN
        GOSUB V$EQU
    END ELSE
        IF YVALUES<1,1,1> GT YVALUES<1,1,2> THEN
            YSEL1 = YVALUES<1,1,2> ; YSEL2 = YVALUES<1,1,1>
        END ELSE
            YSEL1 = YVALUES<1,1,1> ; YSEL2 = YVALUES<1,1,2>
        END
        YSENTENCE = "WITH @ID GE ":YSEL1:" AND @ID LE ":YSEL2
        GOSUB PERFORM.SELECTION
    END
*
RETURN
*
*------------------------------------------------------------------------
RANGE.DT:
*========
*
    IF YVALUES<1,1,2> = "" THEN
        GOSUB EQU.DT
    END ELSE
        IF YVALUES<1,1,1> GT YVALUES<1,1,2> THEN
            YSEL1 = YVALUES<1,1,2> ; YSEL2 = YVALUES<1,1,1>
        END ELSE
            YSEL1 = YVALUES<1,1,1> ; YSEL2 = YVALUES<1,1,2>
        END
*
        LOCATE YSEL1 IN YSTMT.DATES<1> BY "AR" SETTING YPOS ELSE
            NULL    ;* Date FOUND
        END
        LOOP
        UNTIL YSTMT.DATES<YPOS> GT YSEL2 OR YSTMT.DATES<YPOS> = ""
            GOSUB GET.STMT.PRINTED
            YPOS += 1
        REPEAT
*
    END
*
RETURN
*
*------------------------------------------------------------------------
LESS.THAN:
*========
*
    YSEL1 = YVALUES<1,1>
    YSENTENCE = "WITH @ID LT ":YSEL1
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
LESS.THAN.DT:
*========
*
    YSEL1 = YVALUES<1,1>
    LOCATE YSEL1 IN YSTMT.DATES<1> BY "AR" SETTING YPOS ELSE
        NULL        ;* Date FOUND
    END
    YIDX = 1
    LOOP
    UNTIL YIDX GT YPOS
        GOSUB GET.STMT.PRINTED
        YPOS -= 1
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
GREATER.THAN:
*============
*
    YSEL1 = YVALUES<1,1>
    YSENTENCE = "WITH @ID GT ":YSEL1
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
GREATER.THAN.DT:
*============
*
    YSEL1 = YVALUES<1,1>
    LOCATE YSEL1 IN YSTMT.DATES<1> BY "AR" SETTING YPOS ELSE
        NULL
    END
    GOSUB PERFORM.SELECTION
    LOOP
    UNTIL YSTMT.DATES<YPOS> = ""
        GOSUB GET.STMT.PRINTED
        YPOS += 1
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
NOT.EQUAL:
*=========
*
    YSENTENCE = "WITH @ID "
    LOOP
        REMOVE YCONCAT.ID FROM YVALUES SETTING YD
        YSENTENCE := "NE ":YCONCAT.ID
    WHILE YD
        YSENTENCE := " AND "
    REPEAT
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
NOT.EQUAL.DT:
*=========
*
    YPOS = 1
    LOOP
    UNTIL YSTMT.DATES<YPOS> = ""
        GOSUB GET.STMT.PRINTED
        YPOS += 1
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
LK:
*====
*
    YSEL1 = YVALUES<1,1>
    YSENTENCE = "WITH @ID LIKE ":YSEL1
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
LK.DT:
*=========
*
    GOSUB NOT.EQUAL.DT
*
RETURN
*
*------------------------------------------------------------------------
UL:
*======
*
    YSEL1 = YVALUES<1,1>
    YSENTENCE = "WITH @ID UNLIKE ":YSEL1
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
UL.DT:
*=========
*
    GOSUB NOT.EQUAL.DT
*
RETURN
*
*------------------------------------------------------------------------
LESS.THAN.EQ:
*===============
*
    YSEL1 = YVALUES<1,1>
    YSENTENCE = "WITH @ID LE ":YSEL1
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
LESS.THAN.EQ.DT:
*========
*
    YSEL1 = YVALUES<1,1>
    LOCATE YSEL1 IN YSTMT.DATES<1> BY "AR" SETTING YPOS ELSE
        NULL        ;* Date FOUND
    END
    YIDX = 1
    LOOP
    UNTIL YIDX GT YPOS
        GOSUB GET.STMT.PRINTED
        YPOS -= 1
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
GREATER.THAN.EQ:
*==================
*
    YSEL1 = YVALUES<1,1>
    YSENTENCE = "WITH @ID GE ":YSEL1
    GOSUB PERFORM.SELECTION
*
RETURN
*
*------------------------------------------------------------------------
GREATER.THAN.EQ.DT:
*===============
*
    GOSUB GREATER.THAN.DT
RETURN
*
*------------------------------------------------------------------------
NOT.RANGE:
*========
*
    IF YVALUES<1,1,2> = "" THEN
        GOSUB NOT.EQUAL
    END ELSE
        IF YVALUES<1,1,1> GT YVALUES<1,1,2> THEN
            YSEL1 = YVALUES<1,1,2> ; YSEL2 = YVALUES<1,1,1>
        END ELSE
            YSEL1 = YVALUES<1,1,1> ; YSEL2 = YVALUES<1,1,2>
        END
        YSENTENCE = "WITH @ID LT ":YSEL1:" AND @ID GT ":YSEL2
        GOSUB PERFORM.SELECTION
    END
*
RETURN
*
*------------------------------------------------------------------------
NOT.RANGE.DT:
*============
*
    GOSUB NOT.EQUAL.DT
RETURN
*
*------------------------------------------------------------------------
PERFORM.SELECTION:
*================
*
    CALL HUSHIT(1)
    SELECT.COMMAND = YACCT.FIXED:" ":YSENTENCE
    CALL HUSHIT(0)

    EB.DataAccess.Readlist(SELECT.COMMAND, YACCT.LIST, YLIST.ID,"", "")
*
RETURN
*
*------------------------------------------------------------------------
GET.STMT.PRINTED:
*================
*
* EB.READ.HVT has the logic to check the HVT flag and return the required record
* notionally merged for HVT account / from disc for non HVT accounts.
    STMT.PRINT.ID = YID.ACCT:"-":YSTMT.DATES<YPOS>
    R.STMT.PRINTED = ''
    InDetails<1>='STMT.PRINTED'
    InDetails<2>=STMT.PRINT.ID
    AC.AccountStatement.acReadAcctStmtPrint(InDetails, "MERGE.HVT", '', '', '',R.STMT.PRINTED , '','', '')
    
    IF R.STMT.PRINTED THEN
        YID.LIST := @FM:R.STMT.PRINTED
    END

* EN_10000302 STARTS
* Get the list of stmt entries from FWD.STMT1.PRINTED and
* add only those which have a value date less than or equal
* to TODAY

    IF FWD.MVMT.FLAG THEN
        FWD.ID.LIST = '' ; FWD.STMT.ID = '' ; FWD.STMT.POS = ''
        FWD.STMT.PRINT.ID = YID.ACCT:"-":YSTMT.DATES<YPOS>
        FWD.ID.LIST = ''
        AC.HighVolume.EbReadHvt('FWD.STMT1.PRINTED', FWD.STMT.PRINT.ID, FWD.ID.LIST, '')         ;* Call the core api to get the merged info for HVT accounts

        IF FWD.ID.LIST THEN
            GOSUB ADD.TO.LIST ;*Check if the value date of the entry is less than today and append to the entry list
        END
    END
* EN_10000302 ENDS
RETURN
*
*------------------------------------------------------------------------
*** <region name= ADD.TO.LIST>
ADD.TO.LIST:
*** <desc>Check if the value date of the entry is less than today and append to the entry list </desc>

    LOOP
        REMOVE FWD.STMT.ID FROM FWD.ID.LIST SETTING FWD.STMT.POS
    WHILE FWD.STMT.ID:FWD.STMT.POS
        R.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(FWD.STMT.ID, ENTRY.ERR)
        STMT.VALUE.DATE = R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteValueDate>

        IF STMT.VALUE.DATE LE EB.SystemTables.getToday() THEN          ;* If the value date of the entry is less then today add to he list
            LOCATE FWD.STMT.ID IN YID.LIST<1> SETTING STMT.ID.POS ELSE
                YID.LIST<-1> = FWD.STMT.ID
            END
        END

    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
