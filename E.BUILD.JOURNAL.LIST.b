* @ValidationCode : MjoxMTAzNDUxNTkyOmNwMTI1MjoxNTQzNDk2ODg0MDExOnZ2aWduZXNoOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 29 Nov 2018 18:38:04
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : vvignesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 15/05/01  GLOBUS Release No. G15.0.00 25/06/04
*-----------------------------------------------------------------------------
* <Rating>2282</Rating>
*-----------------------------------------------------------------------------
$PACKAGE RE.ModelBank
SUBROUTINE E.BUILD.JOURNAL.LIST(ENQUIRY.DATA)
*
*
************************************************************************
*
* 06/06/97 - GB9700611
*            New program to build temporary records in file RE.JOURNAL.WORK
*            for enquiry purposes.
*
* 01/10/98 - GB9801203
*            The RE.TYPES must be called with ALL.CB instead of ALL.C
*            Add !PERIOD as another selection for date
*            Write out one additional record in RE.JOURNAL.WORK
*            for a line that has had no movements.
*
* 21/12/99 - GB9900371
*            The problem occurs because of archiving
*            of the entry files pointed to by the
*            RE.STAT.LINE.MVMT file.
*
* 22/10/01 - EN_10000220
*            - the asset types 5nOFF & 5nOFFSP are replaced
*            - by NNNNNOFF & NNNNNOFFSP for checking against
*            - RE.TYPES.
*
* 24/03/03 - EN_10001835
*            Multi book allow for company code in key
*            clearfile to be done via EB.CLEARFILE
*
* 07/07/04 - BG_10006919
*            Call central routine for contingent types
*
* 01/03/05 - EN_10002431
*            Change done in retriving CATEG.ENTRY keys from RE.STAT.LINE.MVMT file.
*
*
* 10/05/06 - CI_10041027
*            SELECT command is formed accordingly for specific lines if given
*            in the enquiry. But, the wrong variable locate, never alters the
*            SELECT command and the selection of all the lines is done by default.
*
* 09/03/07 - EN_10003255
*            Modified to call DAS to select data.
*
* 04/10/07 - BG_100015329
*            Problem in EMC setup - resolved. Displaying mvmts multiple
*            times, in case if we execute GENERAL.LEDGER enquiry with
*            different user in multi book setup.
*
* 17/12/09 - CI_10068293
*            Changes done to select records based on last period end
*            date from DATES record.
*
* 29/11/18 - Enhancement 2822520 / Task 2879096
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.RE.CONSOL.SPEC.ENTRY
    $INSERT I_F.RE.JOURNAL.WORK
    $INSERT I_F.DATES
    $INSERT I_F.ENQUIRY
    $INSERT I_F.RE.STAT.LINE.BAL
    $INSERT I_F.COMPANY
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.RE.STAT.LINE.BAL
*
    GOSUB INITIALISATION
*
    SEL.CRITERIA = ""
    CALL EB.CLEAR.FILE(F.RE.JOURNAL.WORK.NAME:@FM:SEL.CRITERIA,F.RE.JOURNAL.WORK)
*
    LOCATE "REPORT.NAME" IN ENQUIRY.DATA<2,1> SETTING REP.POS THEN
        REPN.ID = ENQUIRY.DATA<4,REP.POS>
        CONVERT " " TO @VM IN REPN.ID
        IF DCOUNT(REPN.ID,@VM) GT 1 OR REPN.ID = "ALL" THEN
            ENQ.ERROR = "ONLY ONE REPORT NAME ALLOWED"
            GOTO PROGRAM.ABORT
        END ELSE
*
* Check calling ENQUIRY
*
            LOCATE "ENQUIRY.TYPE" IN R.ENQ<ENQ.FIELD.NAME,1> SETTING EPOS THEN
                ETYPE = R.ENQ<ENQ.OPERATION,EPOS> ;* Type of Enquiry
            END ELSE
                ETYPE = ''
            END
*
            IF ETYPE = '"GENERAL.LEDGER"' THEN
                GOSUB GET.GEN.LED.INFO
            END ELSE
                GOSUB GET.RE.JOUR.INFO
            END
            IF ENQ.ERROR THEN GOTO PROGRAM.ABORT
*
        END
*
        GOSUB SELECT.BAL.FILE
        GOSUB BUILD.MVMT.LIST
*
        IF ENQ.ERROR <> "" THEN GOTO PROGRAM.ABORT
*
        GOSUB PROCESS.EACH.REC
        GOSUB PROCESS.NIL.RECS
*
    END
*
RETURN
*
*=========================================================================
* SUBROUTINES
*=========================================================================
*
INITIALISATION:
*-------------
*
** Set local variables
*
    ENQ.ERROR = ""
    SEL.OUR.REF = ""
    SEL.CONT = ""
    SEL.REPL = ""
    SEL.CCY = ""
    Y.ASSET.CHECK = ""
*
** Open files
*
    F.STMT.ENTRY = ""
    F.STMT.ENTRY.NAME = "F.STMT.ENTRY"
    CALL OPF(F.STMT.ENTRY.NAME,F.STMT.ENTRY)
*
    F.CATEG.ENTRY = ""
    F.CATEG.ENTRY.NAME = "F.CATEG.ENTRY"
    CALL OPF(F.CATEG.ENTRY.NAME,F.CATEG.ENTRY)
*
    F.RE.CONSOL.SPEC.ENTRY = ""
    F.RE.CONSOL.SPEC.ENTRY.NAME = "F.RE.CONSOL.SPEC.ENTRY"
    CALL OPF(F.RE.CONSOL.SPEC.ENTRY.NAME,F.RE.CONSOL.SPEC.ENTRY)
*
    F.RE.STAT.LINE.MVMT = ""
    F.RE.STAT.LINE.MVMT.NAME = "F.RE.STAT.LINE.MVMT"
    CALL OPF(F.RE.STAT.LINE.MVMT.NAME,F.RE.STAT.LINE.MVMT)
*
    F.RE.STAT.LINE.BAL = ""
    F.RE.STAT.LINE.BAL.NAME = "F.RE.STAT.LINE.BAL"
    CALL OPF(F.RE.STAT.LINE.BAL.NAME,F.RE.STAT.LINE.BAL)
*
    F.RE.JOURNAL.WORK = ""
    F.RE.JOURNAL.WORK.NAME = "F.RE.JOURNAL.WORK"
    CALL OPF(F.RE.JOURNAL.WORK.NAME,F.RE.JOURNAL.WORK)
*
    F.RE.CONSOL.SPEC.ENTRY.ARC = ''
    F.RE.CONSOL.SPEC.ENTRY.ARC.NAME = "F":R.COMPANY(EB.COM.MNEMONIC):".RE.CONSOL.SPEC.ENTRY$ARC"
    F.STMT.ENTRY.ARC = ''
    F.STMT.ENTRY.ARC.NAME = "F":R.COMPANY(EB.COM.MNEMONIC):".STMT.ENTRY$ARC"
    F.CATEG.ENTRY.ARC =''
    F.CATEG.ENTRY.ARC.NAME = "F":R.COMPANY(EB.COM.MNEMONIC):".CATEG.ENTRY$ARC"
    OPFSTMT = 9
    OPFRCS = 9
    OPFCAT = 9
    OPEN "",F.STMT.ENTRY.ARC.NAME TO F.STMT.ENTRY.ARC ELSE OPFSTMT = 0
    OPEN "",F.CATEG.ENTRY.ARC.NAME TO F.CATEG.ENTRY.ARC ELSE OPFCAT = 0
*
    OPEN "",F.RE.CONSOL.SPEC.ENTRY.ARC.NAME TO F.RE.CONSOL.SPEC.ENTRY.ARC ELSE OPFRCS = 0 ;* GB9900371 E
*
** Get list of Asset Types and Contingent markers
*
    ASSET.TYPES = 'ALL.CB' ; CONTINGENT.TYPES = ''
    CALL RE.TYPES(ASSET.TYPES, CONTINGENT.TYPES)
*
    PERIOD.END = R.DATES(EB.DAT.PERIOD.END)
RETURN
*
*-------------------------------------------------------------------------
*
GET.GEN.LED.INFO:
*---------------
*
    LOCATE "SEL.DATE" IN ENQUIRY.DATA<2,1> SETTING SYSD.POS THEN
        SYSDTE = ENQUIRY.DATA<4,SYSD.POS>
        IF SYSDTE = '!TODAY' THEN SYSDTE = TODAY
*
        IF SYSDTE = '!PERIOD' THEN SYSDTE = PERIOD.END
        CONVERT " " TO @VM IN SYSDTE
        IF DCOUNT(SYSDTE,@VM) GT 2 OR SYSDTE = "ALL" THEN
            ENQ.ERROR = "ONLY TWO DATES REQUIRED FOR RANGE"
            RETURN
        END ELSE
            SYSDTE.FROM = SYSDTE<1,1>
            SYSDTE.TO = SYSDTE<1,2>
        END
    END ELSE SYSDTE = ""
*
* Default to last period end day if not entered
*
    IF SYSDTE = "" THEN
        SYSDTE.FROM = R.DATES(EB.DAT.LAST.PERIOD.END)
        SYSDTE.TO = R.DATES(EB.DAT.LAST.PERIOD.END)
        SYSDTE.RG = SYSDTE.FROM:" ":SYSDTE.TO
    END
*
    LOCATE "CURRENCY" IN ENQUIRY.DATA<2,1> SETTING CCYPOS THEN
        SEL.CCY = ENQUIRY.DATA<4,CCYPOS>
    END
*
    LOCATE "PCB.ACCOUNT" IN ENQUIRY.DATA<2,1> SETTING REPL.POS THEN
        SEL.REPL = ENQUIRY.DATA<4,REPL.POS>
    END
*
RETURN
*
*-------------------------------------------------------------------------
*
GET.RE.JOUR.INFO:
*---------------
*
    LOCATE "SEL.DATE" IN ENQUIRY.DATA<2,1> SETTING SYSD.POS THEN
        SYSDTE = ENQUIRY.DATA<4,SYSD.POS>
        IF SYSDTE = '!TODAY' THEN SYSDTE = TODAY
*
        IF SYSDTE = '!PERIOD' THEN SYSDTE = PERIOD.END
        CONVERT " " TO @VM IN SYSDTE
        IF DCOUNT(SYSDTE,@VM) GT 1 OR SYSDTE = "ALL" THEN
            ENQ.ERROR = "ONLY ONE REPORT DATE ALLOWED"
            RETURN
        END
    END ELSE SYSDTE = ""
*
* Default to last period end day if not entered
*
    IF SYSDTE = "" THEN
        SYSDTE = R.DATES(EB.DAT.LAST.PERIOD.END)
        IF SYSD.POS THEN
            ENQUIRY.DATA<4,SYSD.POS> = SYSDTE
        END
    END
*
    LOCATE "OUR.REFERENCE" IN ENQUIRY.DATA<2,1> SETTING OUR.REF.POS THEN
        SEL.OUR.REF = ENQUIRY.DATA<4,OUR.REF.POS>
    END
*
    LOCATE "CONTINGENT" IN ENQUIRY.DATA<2,1> SETTING CONT.POS THEN
        SEL.CONT = ENQUIRY.DATA<4,CONT.POS>
    END
*
RETURN
*
*-------------------------------------------------------------------------
*
SELECT.BAL.FILE:
*--------------
*
    BAL.ID.LIST  = dasReStatLineBalForReJournalWork
    THE.ARGS     = REPN.ID
    TABLE.SUFFIX = ''
*
* Set arguments 2 onwards to default to do not use, the code after will insert data as required.
*
    FOR SET.DEFAULT = 2 TO 7
        THE.ARGS<SET.DEFAULT> = dasDoNotUseThisOptionalField
    NEXT SET.DEFAULT
*
* Insert OPTIONAL Arguments as required.
*
    IF C$MULTI.BOOK THEN
        THE.ARGS<2> = ID.COMPANY
    END

    IF ETYPE = '"GENERAL.LEDGER"' THEN
        THE.ARGS<3> = SYSDTE.FROM
        THE.ARGS<4> = SYSDTE.TO
        IF SEL.CCY THEN
            THE.ARGS<5> = SEL.CCY
        END
        IF SEL.REPL THEN
            SEL.REP.LINE = FIELD(SEL.REPL,".",2)
            THE.ARGS<6> = SEL.CCY
        END
    END ELSE
        THE.ARGS<7> = SYSDTE
    END

    MVMT.ID.LIST = ""

    CALL DAS('RE.STAT.LINE.BAL',BAL.ID.LIST,THE.ARGS,TABLE.SUFFIX)
*
RETURN
*
*---------------------------------------------------------------------------
*
BUILD.MVMT.LIST:
*--------------

    MVMT.ID.LIST = ""
    REP.ID.LIST = ""
    REP.ID.LIST.PROCESSED = ""

    LOOP

        REMOVE BAL.ID FROM BAL.ID.LIST SETTING POSN

    WHILE BAL.ID:POSN

        GOSUB READ.BAL.REC
        MVMT.ID.ADDED = "N"
        IF R.RE.STAT.LINE.BAL<RE.SLB.MVMT.A.SPLIT> THEN
            FOR I = 1 TO R.RE.STAT.LINE.BAL<RE.SLB.MVMT.A.SPLIT>
                MVMT.ID = BAL.ID:"-":"A-":I
                LOCATE MVMT.ID IN MVMT.ID.LIST<1> SETTING MVMT.POS ELSE
                    INS MVMT.ID BEFORE MVMT.ID.LIST<MVMT.POS,0,0>
                    MVMT.ID.ADDED = "Y"
                END
            NEXT I
        END

        IF R.RE.STAT.LINE.BAL<RE.SLB.MVMT.P.SPLIT> THEN
            FOR I = 1 TO R.RE.STAT.LINE.BAL<RE.SLB.MVMT.P.SPLIT>
                MVMT.ID = BAL.ID:"-":"P-":I
                LOCATE MVMT.ID IN MVMT.ID.LIST<1> SETTING MVMT.POS ELSE
                    INS MVMT.ID BEFORE MVMT.ID.LIST<MVMT.POS,0,0>
                    MVMT.ID.ADDED = "Y"
                END
            NEXT I
        END

        IF R.RE.STAT.LINE.BAL<RE.SLB.MVMT.R.SPLIT> THEN
            FOR I = 1 TO R.RE.STAT.LINE.BAL<RE.SLB.MVMT.R.SPLIT>
                MVMT.ID = BAL.ID:"-":"R-":I
                LOCATE MVMT.ID IN MVMT.ID.LIST<1> SETTING MVMT.POS ELSE
                    INS MVMT.ID BEFORE MVMT.ID.LIST<MVMT.POS,0,0>
                    MVMT.ID.ADDED = "Y"
                END
            NEXT I
        END

        IF ETYPE = '"GENERAL.LEDGER"' THEN
            REP.ID = FIELD(BAL.ID,"-",1,2)
            LOCATE REP.ID IN REP.ID.LIST<1> SETTING REP.POS ELSE
                INS REP.ID BEFORE REP.ID.LIST<REP.POS,0,0>
            END
            IF MVMT.ID.ADDED = "Y" THEN
                REP.ID = FIELD(BAL.ID,"-",1,2)
                LOCATE REP.ID IN REP.ID.LIST.PROCESSED<1> SETTING REP.POS ELSE
                    INS REP.ID BEFORE REP.ID.LIST.PROCESSED<REP.POS,0,0>
                END
            END
        END

    REPEAT

    IF ETYPE = '"GENERAL.LEDGER"' THEN

        LOOP

            REMOVE REP.ID.PROCESSED FROM REP.ID.LIST.PROCESSED SETTING REP.PROC.POS

        WHILE REP.ID.PROCESSED:REP.PROC.POS

            LOCATE REP.ID.PROCESSED IN REP.ID.LIST<1> SETTING REP.ID.POS THEN
                DEL REP.ID.LIST<REP.ID.POS>
            END

        REPEAT

    END

RETURN
*
*-------------------------------------------------------------------------
*
PROCESS.EACH.REC:
*---------------
* Process each record in file RE.STAT.LINE.MVMT
*
    LOOP
        REMOVE MVMT.ID FROM MVMT.ID.LIST SETTING POSN
    WHILE MVMT.ID:POSN
        GOSUB READ.MVMT.REC
        GOSUB PROCESS.MVMT.REC
    REPEAT
*
RETURN
*
*-------------------------------------------------------------------------
*
PROCESS.NIL.RECS:
*---------------
* Process records for nil movements
*
    LOOP
        REMOVE MVMT.ID FROM REP.ID.LIST SETTING POSN
    WHILE MVMT.ID:POSN
        GOSUB PROCESS.EACH.NIL.REC
    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
*
PROCESS.EACH.NIL.REC:
*-------------------

    REPORT.NAME = FIELD(MVMT.ID,"-",1)
    REPORT.LINE = FIELD(MVMT.ID,"-",2)
    FILE.IDENTIFIER = "N"
    R.RE.JOURNAL.WORK = ''
    RE.JOURNAL.ID = REPORT.NAME:'*':REPORT.LINE:'*':FILE.IDENTIFIER:'*'
    RE.JOURNAL.ID := '':'*':'':'*':'':'*':'':'*':SYSDTE.TO
    IF C$MULTI.BOOK THEN
        RE.JOURNAL.ID := '*':OPERATOR:'*':ID.COMPANY
    END
    WRITE R.RE.JOURNAL.WORK TO F.RE.JOURNAL.WORK,RE.JOURNAL.ID

RETURN
*
*-------------------------------------------------------------------------
*
READ.MVMT.REC:
*------------
*
    Y.BAL.ID = FIELD(MVMT.ID,"-",1,4)
    ENTRY.IDX = FIELD(MVMT.ID,"-",5)
    ENTRY.LIST = ''
    CALL GET.MVMT.ENTRIES(Y.BAL.ID, ENTRY.IDX, ENTRY.LIST)
*
RETURN
*
*-------------------------------------------------------------------------
*
READ.BAL.REC:
*------------
*
    R.RE.STAT.LINE.BAL = "" ; ER = ""
    CALL F.READ(F.RE.STAT.LINE.BAL.NAME,
    BAL.ID,
    R.RE.STAT.LINE.BAL,
    F.RE.STAT.LINE.BAL,
    ER)
*
RETURN
*
*-------------------------------------------------------------------------
*
PROCESS.MVMT.REC:
*---------------
*
    REPORT.NAME = FIELD(MVMT.ID,"-",1)
    REPORT.LINE = FIELD(MVMT.ID,"-",2)
    FILE.IDENTIFIER = FIELD(MVMT.ID,"-",5)
    RECORD.DATE = FIELD(MVMT.ID,'-',4,1)
*
    BEGIN CASE
        CASE FILE.IDENTIFIER = "A"          ;* Account (STMT Entry)
            STMT.LIST = RAISE(ENTRY.LIST<1>)
            NO.OF.ENTRIES = DCOUNT(STMT.LIST, @FM)
            FOR CNT = 1 TO NO.OF.ENTRIES
                ENTRY.ID = STMT.LIST<CNT>
                GOSUB READ.STMT.ENTRY.REC
                GOSUB BUILD.RE.JOURNAL.WORK
            NEXT
        CASE FILE.IDENTIFIER = "P"          ;* P&L     (CATEG Entry)
            CATEG.LIST = RAISE(ENTRY.LIST<2>)
            NO.OF.ENTRIES = DCOUNT(CATEG.LIST, @FM)
            FOR CNT = 1 TO NO.OF.ENTRIES
                ENTRY.ID = CATEG.LIST<CNT>
                GOSUB READ.CATEG.ENTRY.REC
                GOSUB BUILD.RE.JOURNAL.WORK
            NEXT
        CASE FILE.IDENTIFIER = "R"          ;* Spec    (SPEC Entry)
            SPEC.LIST = RAISE(ENTRY.LIST<3>)
            NO.OF.ENTRIES = DCOUNT(SPEC.LIST, @FM)
            FOR CNT = 1 TO NO.OF.ENTRIES
                ENTRY.ID = SPEC.LIST<CNT>
                GOSUB READ.CONSOL.ENTRY.REC
                GOSUB BUILD.RE.JOURNAL.WORK
            NEXT
    END CASE
*
RETURN
*
*-------------------------------------------------------------------------
*
READ.STMT.ENTRY.REC:
*------------------
*
    R.STMT.ENTRY = "" ; ER = ""
    CALL F.READ(F.STMT.ENTRY.NAME,
    ENTRY.ID,
    R.STMT.ENTRY,
    F.STMT.ENTRY,
    ER)
    IF ER AND OPFSTMT NE 0 THEN
        CALL F.READ( F.STMT.ENTRY.ARC.NAME,ENTRY.ID,R.STMT.ENTRY,F.STMT.ENTRY.ARC,ER)
        IF ER THEN
            TEXT = "RECORD NOT AVAILABLE IN LIVE FILE AND ARC FILE"
            CALL REM
        END
    END
*
    SYSTEM.ID = R.STMT.ENTRY<AC.STE.SYSTEM.ID>
    OUR.REF = R.STMT.ENTRY<AC.STE.OUR.REFERENCE>
    IF OUR.REF = '' THEN OUR.REF = R.STMT.ENTRY<AC.STE.TRANS.REFERENCE>
    CONTINGENT = 'N'
    TXN.CODE = R.STMT.ENTRY<AC.STE.TRANSACTION.CODE>
    CURRENCY = R.STMT.ENTRY<AC.STE.CURRENCY>
    AMT.FCY = R.STMT.ENTRY<AC.STE.AMOUNT.FCY>
    AMT.LCY = R.STMT.ENTRY<AC.STE.AMOUNT.LCY>
    BOOKING.DATE = R.STMT.ENTRY<AC.STE.BOOKING.DATE>
    VALUE.DATE = R.STMT.ENTRY<AC.STE.VALUE.DATE>
*
RETURN
*
*-------------------------------------------------------------------------
*
READ.CATEG.ENTRY.REC:
*-------------------
*
    R.CATEG.ENTRY = "" ; ER = ""
    CALL F.READ(F.CATEG.ENTRY.NAME,
    ENTRY.ID,
    R.CATEG.ENTRY,
    F.CATEG.ENTRY,
    ER)
    IF ER AND OPFCAT NE 0 THEN
        CALL F.READ(F.CATEG.ENTRY.ARC.NAME,ENTRY.ID,R.CATEG.ENTRY,F.CATEG.ENTRY.ARC,ER)
        IF ER THEN
            TEXT = "RECORD NOT AVAILABLE IN LIVE FILE AND ARC FILE"
            CALL REM
        END
    END
*
    SYSTEM.ID = R.CATEG.ENTRY<AC.CAT.SYSTEM.ID>
    OUR.REF = R.CATEG.ENTRY<AC.CAT.OUR.REFERENCE>
    IF OUR.REF = '' THEN OUR.REF = R.CATEG.ENTRY<AC.CAT.TRANS.REFERENCE>
    CONTINGENT = 'N'
    TXN.CODE = R.CATEG.ENTRY<AC.CAT.TRANSACTION.CODE>
    CURRENCY = R.CATEG.ENTRY<AC.CAT.CURRENCY>
    AMT.FCY = R.CATEG.ENTRY<AC.CAT.AMOUNT.FCY>
    AMT.LCY = R.CATEG.ENTRY<AC.CAT.AMOUNT.LCY>
    BOOKING.DATE = R.CATEG.ENTRY<AC.CAT.BOOKING.DATE>
    VALUE.DATE = R.CATEG.ENTRY<AC.CAT.VALUE.DATE>
*
RETURN
*
*-------------------------------------------------------------------------
*
READ.CONSOL.ENTRY.REC:
*--------------------
*
    R.RE.CONSOL.SPEC.ENTRY = "" ; ER = ""
    CALL F.READ(F.RE.CONSOL.SPEC.ENTRY.NAME,
    ENTRY.ID,
    R.RE.CONSOL.SPEC.ENTRY,
    F.RE.CONSOL.SPEC.ENTRY,
    ER)
    IF ER AND OPFRCS NE 0 THEN
        CALL F.READ(F.RE.CONSOL.SPEC.ENTRY.ARC.NAME,ENTRY.ID,R.RE.CONSOL.SPEC.ENTRY,F.RE.CONSOL.SPEC.ENTRY.ARC,ER)
        IF ER THEN
            TEXT = "RECORD NOT AVAILABLE IN LIVE FILE AND ARC FILE"
            CALL REM
        END
    END
*
    SYSTEM.ID = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.SYSTEM.ID>
    OUR.REF = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.OUR.REFERENCE>
    IF OUR.REF = '' THEN OUR.REF = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.TRANS.REFERENCE>
    CONSOL.KEY.TYPE = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.CONSOL.KEY.TYPE>
*
    NO.DOTS = COUNT(CONSOL.KEY.TYPE,'.')
    ASSET.TYPE = FIELD(CONSOL.KEY.TYPE,".",NO.DOTS+1)
*
    CONT.IND = ''
    CALL AC.CHECK.ASSET.TYPE(ASSET.TYPE, CONTINGENT.TYPES, CONT.IND)
    IF CONT.IND THEN
        CONTINGENT = 'C'
    END ELSE
        CONTINGENT = 'N'
    END
*
    TXN.CODE = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.TRANSACTION.CODE>
    CURRENCY = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.CURRENCY>
    AMT.FCY = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.AMOUNT.FCY>
    AMT.LCY = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.AMOUNT.LCY>
    BOOKING.DATE = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.BOOKING.DATE>
    VALUE.DATE = R.RE.CONSOL.SPEC.ENTRY<RE.CSE.VALUE.DATE>
*
RETURN
*
*-------------------------------------------------------------------------
*
BUILD.RE.JOURNAL.WORK:
*--------------------
*
    IF SEL.CONT <> "" THEN
        IF CONTINGENT <> SEL.CONT THEN RETURN
    END
    IF SEL.OUR.REF <> "" THEN
        IF OUR.REF <> SEL.OUR.REF THEN RETURN
    END
*
** Chcek for Revaluation types and record as the application
** RV. These can be identified by RVL transcation code, and
** by OUR.REF like AL...
** AC and IC are all to be treated as AC transactions
*
    IF TXN.CODE = 'RVL' OR OUR.REF[1,2] = 'AL' THEN
        SYSTEM.ID = 'RV'
    END
    IF SYSTEM.ID[1,2] = 'IC' THEN SYSTEM.ID = 'AC'
*
    R.RE.JOURNAL.WORK = ''
    RE.JOURNAL.ID = REPORT.NAME:'*':REPORT.LINE:'*':FILE.IDENTIFIER:'*'
    RE.JOURNAL.ID := ENTRY.ID:'*':SYSTEM.ID:'*':OUR.REF:'*':CONTINGENT:'*':RECORD.DATE
    IF C$MULTI.BOOK THEN
        RE.JOURNAL.ID := '*':OPERATOR:'*':ID.COMPANY
    END
    R.RE.JOURNAL.WORK<RE.JK.TXN.CODE> = TXN.CODE
    IF NOT(CURRENCY) THEN CURRENCY = LCCY
    R.RE.JOURNAL.WORK<RE.JK.CURRENCY> = CURRENCY
    R.RE.JOURNAL.WORK<RE.JK.AMOUNT.FCY> = AMT.FCY
    R.RE.JOURNAL.WORK<RE.JK.AMOUNT.LCY> = AMT.LCY
    R.RE.JOURNAL.WORK<RE.JK.VALUE.DATE> = VALUE.DATE
    R.RE.JOURNAL.WORK<RE.JK.BOOKING.DATE> = BOOKING.DATE
*
    WRITE R.RE.JOURNAL.WORK TO F.RE.JOURNAL.WORK,RE.JOURNAL.ID
*
RETURN
*
*----------------------------------------------------------------------
*
PROGRAM.ABORT:
*------------
*
RETURN
*
*
END
