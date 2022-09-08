* @ValidationCode : MjotMTEzODcxODg2OkNwMTI1MjoxNDgwNTgyMTMzODIzOnByaXRoYWc6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTYxMi4yMDE2MTEwMi0xMTQyOi0xOi0x
* @ValidationInfo : Timestamp         : 01 Dec 2016 14:18:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : prithag
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>23524</Rating>
*-----------------------------------------------------------------------------
* Version 8 31/05/01  GLOBUS Release No. G12.0.00 29/06/01
* Version 9.1.0A released on 29/09/89
    $PACKAGE LD.Foundation
    SUBROUTINE CONV.RE.LD.BAL.MOVE
*------------------------------------------------------------------------
*
*         This module updates the consolidation base for movements in
*         in LOANS and DEPOSITS contracts
*            Following movements are taken care of :
*                - principal
*                - accruals of interests,commissions & amortised charges
*                - settlement of interest,commissions,fees & charges
*                - fees and charges due
*                - WHT(with holding tax)
*         Maintains RE.LD.ACC.BAL to identify movements
*         Process changes in contract details that are part of
*         consolidation conditions
*
* 03/03/92 - HY9200669
*            Replace READLIST with call to EB.READLIST
*
* 21/12/92 - GB9201153
*            When the last item in YLMM.ACC>BAL.CNOS is greater that the
*            last item in YRE.LD.ACC.BAL.CNOS, the last item is not
*            processed as the variable Y.ENDRUN is already set, and the
*            loop (FETCH.KEY) should be processed once more.
*
*
* 16/06/93 - GB9300338
*            Only clear the consol key for commitments when the balances
*            are reduced to zero. Also commitments should be
*            processed last after all the linked contracts have been
*            matured
*
* 29/04/97 - GB9700358
*            Remove reference to WHT fields now used for REIMBURSEMENT
*
* 06/09/02 - EN_10001077
*            Conversion of error messages to error codes.
* 21/11/02 - CI_10004844
*          - Included the inserts of STANDARD.SELECTION & DAO
*06/01/2003 - EN_10001563
*             I_RE.INIT.CON insert routine is made obsolete
*             modifications are done to make a call to
*             RE.INIT.CON
*
* 19/01/06 - CI_10038283
*            Rename the field RE.CON.LOCAL.FIELD.NO to RE.CON.LOCAL.FIELD.NAM.
*------------------------------------------------------------------------
*             File inserts
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LMM.ACCOUNT.BALANCES
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.LMM.EOD.LIST
    $INSERT I_F.LMM.HISTORY.LIST
    $INSERT I_F.LMM.INSTALL.CONDS
    $INSERT I_F.LMM.SCHEDULES.PAST
    $INSERT I_F.CONSOLIDATE.COND
    $INSERT I_F.RE.LD.ACC.BAL
    $INSERT I_F.LMM.CHARGE.CONDITIONS
    $INSERT I_F.DATES
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.USER
    $INSERT I_F.STANDARD.SELECTION      ;* CI_10004844
    $INSERT I_F.DEPT.ACCT.OFFICER       ;* CI_10004844
*
    $INSERT I_RE.INIT.COMMON  ;* EN_10001563   S/E
*------------------------------------------------------------------------
* equates for RE.LD.CHARGE.COND
    EQU RE.LD.CHARGE.CODE TO 1,
    RE.LD.CHARGE.CATEG.CODE TO 2
*
*------------------------------------------------------------------------
*
    Y.RE.ROUTINE = "RE.LD.BAL.MOVE"
*
    GOSUB INITIAL.PROCESS:
*
    GOSUB MAIN.PROCESS:
*
    RETURN          ;* end of program
*
*------------------------------------------------------------------------
INITIAL.PROCESS:
*---------------
* initialises variables, open files, set up install conds and charge
* conds etc.
*  build key lists
*------------------------------------------------------------------------
*
* initialise flds needed by consol modules
*
    GOSUB SETUP.CONSOL.FLDS:
*
    GOSUB INITIALISE.VARIABLES:
*
* Open Loans & Deposits files
*
    GOSUB OPEN.LD.FILES
*
* List all dates between current rundate and next run-date
*
    GOSUB LIST.DATES
*
* Prepare lists of contract nos  from diff sources
*
    GOSUB LIST.CONTRACT.NOS
*
* Store INSTALL.CONDITION details for Interest processing
*
    GOSUB READ.LMM.INSTALL.CONDS:
*
* Check for changes in install conds and set corresponding flags for
* processing later
*
    GOSUB CHECK.INSTALL.CHANGES:
*
*
* build two arrays of charge cond associated with the charge categ code
* for yesterday and today
*
    GOSUB BUILD.CHARGE.CATEG.CODES:
*
*  Store currency markets for different movements - interest, commissions
*  & charges
*
    Y.MVMT.ID = ''
    Y.CALL.TYPE = 1
    Y.CONTRACT.CCY.MKT = ''
    GOSUB GET.CCY.MKT:
*
INITIAL.PROCESS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
SETUP.CONSOL.FLDS:
*-----------------
* set up environment needed for consolidation purposes
*-----------------------------------------------------------------------
*
* Following variables are used  in the I_GOSUB.RE.KEY.GEN.CON routine
*
    DIM Y.LD.REC(LD.AUDIT.DATE.TIME), YR.LOCAL.FILE.1(LD.AUDIT.DATE.TIME)
    DIM YR.LOCAL.FILE.2(1),YR.LOCAL.FILE.3(1),YR.LOCAL.FILE.4(1)
    DIM YR.LOCAL.FILE.5(1),YR.LOCAL.FILE.6(1)
    YID.CON = "ASSET&LIAB" ; Y.MAX.DIM = LD.AUDIT.DATE.TIME
    MAT YR.LOCAL.FILE.2 = ""
    MAT YR.LOCAL.FILE.3 = ""
    MAT YR.LOCAL.FILE.4 = ""
    MAT YR.LOCAL.FILE.5 = ""
    MAT YR.LOCAL.FILE.6 = ""
    YLOCAL.FILENAMES = "LD.LOANS.AND.DEPOSITS"
    YMAT.DATE = ""
    YMAT.DATE.PREV = ""
*
* Insert routine stores Consolidation Condition details
*
*$INSERT I_RE.INIT.CON        ;* EN_10001563 S/E
    CALL RE.INIT.CON
*
* Store Loans & Deposits record field numbers included in the
* Consolidation key
*
    GOSUB STORE.LD.KEY.FLDS
*
SETUP.CONSOL.FLDS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
STORE.LD.KEY.FLDS:
*-----------------
    Y.MAT.DATE.INCLUDED.IN.KEY = ""
    Y.LD.KEY.FIELDS = ""
    YAV = 1
    LOOP
        YCON.FILE = YR.CONSOLIDATE.COND(RE.CON.LOCAL.FILE.NAME)<1,YAV>
    UNTIL YCON.FILE = "" DO
        IF YCON.FILE = "LD.LOANS.AND.DEPOSITS" THEN
            YFD.NO = YR.CONSOLIDATE.COND(RE.CON.LOCAL.FIELD.NAM)<1,YAV>
            IF INDEX(YFD.NO,'/',1) THEN
                NULL
            END ELSE
                Y.LD.KEY.FIELDS = INSERT(Y.LD.KEY.FIELDS,-1,0,0,YFD.NO)
                IF YFD.NO = LD.FIN.MAT.DATE THEN Y.MAT.DATE.INCLUDED.IN.KEY = "Y"
            END
        END
        YAV += 1
    REPEAT
*
STORE.LD.KEY.FLDS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
INITIALISE.VARIABLES:
*--------------------
* Process Initialisation
*------------------------------------------------------------------------
    Y.FWD.CR.TYPE = "FORWARDCR"
    Y.FWD.DB.TYPE = "FORWARDDB"
    Y.CURR.CR.TYPE = "LIVECR"
    Y.CURR.DB.TYPE = "LIVEDB"
    Y.OD.DB.TYPE = "OVERDUEDB"
    Y.OD.CR.TYPE = "OVERDUECR"
    Y.NAB.DB.TYPE = "NABDB"
    Y.NAB.CR.TYPE = "NABCR"
    Y.FWD.COMMITMENT.TYPE = "FORWARDCMT"
    Y.CURR.COMMITMENT.TYPE = "LIVECMT"
    YT.FWD.AMT = "" ; YT.CURR.AMT = ""
    YLMM.CNO = 1
    YRE.LD.CNO = 1
    Y.HIS.NO = 1 ; Y.EOD.NO = 1
    YHIST.PROCESS = ""
    Y.ENDRUN = ""
    Y.CR.MVMT = ""
    Y.DB.MVMT = ""
    Y.CR.LCL.MVMT = ""
    Y.DB.LCL.MVMT = ""
    Y.SCHD.AMT = ""
    Y.MVMT.ENTRY = ""
    Y.LD.DETAILS = ""
    Y.TYPES = ""
    Y.BASE.KEYS = ""
    Y.BASE.REMOVED.KEYS = ""
    YYAMT = "" ; YYTYPE = ""
    YY.LCLAMT = ""
    YCONS.SPL.ENT.TXN.CODES = ""
    YCONS.EXCHANGE.RATES = ""
    YEXCHANGE.RATE = ""
    YUSED.CATEG.CODE = ""
*
* Variables used when processing select list to obtain contract keys and
* processes required - see FETCH.KEY
*
    YGET.NEXT.RE.LD = 1
    YGET.NEXT.LMM = 1
*
* store TXN codes used for consol SPEC.ENTRY
*
    YSPL.ENT.TXN.REF.NEW = 'NW'         ;* for NEW contracts
    YSPL.ENT.TXN.REF.INC = 'IN'         ;* for principal INCrease
    YSPL.ENT.TXN.REF.REP = 'RP'         ;* for REPayment
    YSPL.ENT.TXN.REF.MAT = 'MAT'        ;* for MATurity
    YSPL.ENT.TXN.REF.CUS = 'CUS'        ;* for CUStomer info changes
    YSPL.ENT.TXN.REF.APP = 'APP'        ;* for entries relating to APPlication
    LOCAL7 = "LDMOVEMENT"
    LOCAL8 = 1
    BATCH.DETAILS<1> = 3
* store types used for raising schd.amt entries
    Y.SCHD.TYPES = Y.FWD.CR.TYPE:FM:Y.FWD.DB.TYPE:FM:Y.CURR.CR.TYPE:FM:Y.CURR.DB.TYPE:FM:Y.NAB.CR.TYPE:FM:Y.NAB.DB.TYPE:FM:Y.OD.CR.TYPE:FM:Y.OD.DB.TYPE:FM:Y.FWD.COMMITMENT.TYPE:FM:Y.CURR.COMMITMENT.TYPE
*
    YNEXT.WORKING.DAY = R.DATES(EB.DAT.NEXT.WORKING.DAY)
*
    YTABLE.CHANGED.CODE = "TAB"
    YDUE.CODE = "DUE"
    YPAID.CODE = "PAY"
    YACCRUAL.CODE = "ACC"
    YCAPITALISE.CODE = "CAP"
    YRESERVE.CODE = "RES"
* mvmt.entry narratives
    YACC.MVMT.ENTRY = "ACCRUAL"
    YCAP.MVMT.ENTRY = "CAPITALISE"
    YFEE.MVMT.ENTRY = "FEES"
    YMVMT.ENTRY = "ENTRY"
*
* exception log common fields
*
    Y.EXC.USER = 'S'
    Y.EXC.APPLIC = "RE"
    Y.EXC.RTN = "RE.LD.BAL.MOVE"
    Y.EXC.MODULE = "RE.LD.BAL.MOVE"
    Y.EXC.ERR.CODE = "980"
    Y.EXC.VAL = ""
    Y.EXC.FILE = "RE.LD.ACC.BAL"
    Y.EXC.CURR.NO = ""
    Y.EXC.DEPT.CODE = R.USER<EB.USE.DEPARTMENT.CODE>
*
INITIALISE.VARIABLES.RETURN:
*
    RETURN
*
*-----------------------------------------------------------------------
OPEN.LD.FILES:
*-------------
*
    YFN.LMM.ACCOUNT.BALANCES = "F.LMM.ACCOUNT.BALANCES"
    F.LMM.ACCOUNT.BALANCES = ""
    CALL OPF(YFN.LMM.ACCOUNT.BALANCES,F.LMM.ACCOUNT.BALANCES)
*
    YFN.LMM.ACCOUNT.BALANCES.HIST = "F.LMM.ACCOUNT.BALANCES.HIST"
    F.LMM.ACCOUNT.BALANCES.HIST = ""
    CALL OPF(YFN.LMM.ACCOUNT.BALANCES.HIST,F.LMM.ACCOUNT.BALANCES.HIST)
*
    YFN.LD.LOANS.AND.DEPOSITS = "F.LD.LOANS.AND.DEPOSITS"
    F.LD.LOANS.AND.DEPOSITS = ""
    CALL OPF(YFN.LD.LOANS.AND.DEPOSITS,F.LD.LOANS.AND.DEPOSITS)
*
    YFN.LMM.INSTALL.CONDS = "F.LMM.INSTALL.CONDS"
    F.LMM.INSTALL.CONDS = ""
    CALL OPF(YFN.LMM.INSTALL.CONDS,F.LMM.INSTALL.CONDS)
*
    YFN.RE.LMM.INSTALL.CONDS = "F.RE.LMM.INSTALL.CONDS"
    F.RE.LMM.INSTALL.CONDS = ""
    CALL OPF(YFN.RE.LMM.INSTALL.CONDS,F.RE.LMM.INSTALL.CONDS)
*
    YFN.LMM.SCHEDULES.PAST = "F.LMM.SCHEDULES.PAST"
    F.LMM.SCHEDULES.PAST = ""
    CALL OPF(YFN.LMM.SCHEDULES.PAST,F.LMM.SCHEDULES.PAST)
*
    YFN.LMM.SCHEDULES.PAST.HIST = "F.LMM.SCHEDULES.PAST.HIST"
    F.LMM.SCHEDULES.PAST.HIST = ""
    CALL OPF(YFN.LMM.SCHEDULES.PAST.HIST,F.LMM.SCHEDULES.PAST.HIST)
*
    YFN.LMM.HISTORY.LIST = "F.LMM.HISTORY.LIST"
    F.LMM.HISTORY.LIST = ""
    CALL OPF(YFN.LMM.HISTORY.LIST,F.LMM.HISTORY.LIST)
*
    YFN.LD.LOANS.AND.DEPOSITS$HIS = "F.LD.LOANS.AND.DEPOSITS$HIS"
    F.LD.LOANS.AND.DEPOSITS$HIS = ""
    CALL OPF(YFN.LD.LOANS.AND.DEPOSITS$HIS,F.LD.LOANS.AND.DEPOSITS$HIS)
*
    YFN.RE.LD.ACC.BAL = "F.RE.LD.ACC.BAL"
    F.RE.LD.ACC.BAL = ""
    CALL OPF(YFN.RE.LD.ACC.BAL,F.RE.LD.ACC.BAL)
*
    YFN.LMM.CHARGE.CONDITIONS = "F.LMM.CHARGE.CONDITIONS"
    F.LMM.CHARGE.CONDITIONS = ""
    CALL OPF(YFN.LMM.CHARGE.CONDITIONS,F.LMM.CHARGE.CONDITIONS)
*
    YFN.RE.LD.CHARGE.COND = "F.RE.LD.CHARGE.COND"
    F.RE.LD.CHARGE.COND = ""
    CALL OPF(YFN.RE.LD.CHARGE.COND,F.RE.LD.CHARGE.COND)
*
    YFN.LMM.EOD.LIST = "F.LMM.EOD.LIST"
    F.LMM.EOD.LIST = ""
    CALL OPF(YFN.LMM.EOD.LIST,F.LMM.EOD.LIST)
*
    YFN.LMM.HISTORY.TODAY = "F.LMM.HISTORY.TODAY"
    F.LMM.HISTORY.TODAY = ""
    CALL OPF(YFN.LMM.HISTORY.TODAY,F.LMM.HISTORY.TODAY)
*
    YFN.LMM.SCHEDULE.DATES = "F.LMM.SCHEDULE.DATES"
    F.LMM.SCHEDULE.DATES = ""
    CALL OPF(YFN.LMM.SCHEDULE.DATES,F.LMM.SCHEDULE.DATES)
*
    F.LD.COMMITMENT = ""
    CALL OPF("F.LD.COMMITMENT", F.LD.COMMITMENT)
*
    OPEN "","&SAVEDLISTS&" TO F.SL ELSE
        TEXT = "CANNOT OPEN &SAVEDLISTS&"
        CALL FATAL.ERROR ("CONV.RE.LD.BAL.MOVE")
    END
*
OPEN.LD.FILES.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
LIST.DATES:
*----------
* List dates from start date till end date
* Start date = today , if last working day is of the same month as TODAY
*                            OR
*              first day of the month , if last working day is of
*              previous month
* End date = till next run date if next run date is of same month as
*             TODAY
*                             OR
*            last day of the month ,if next working day is of next month
*
*------------------------------------------------------------------------
*
    YLAST.RUN.DATE = R.DATES(EB.DAT.LAST.WORKING.DAY)
    YLAST.RUN.MONTH = YLAST.RUN.DATE[5,2]
    YCURR.MONTH = TODAY[5,2]
    IF YLAST.RUN.MONTH <> YCURR.MONTH THEN
        YSTART.DATE = TODAY[1,6]:"01"
    END ELSE
        YSTART.DATE = TODAY
    END
    Y.JULDATES = ""
    CALL JULDATE(YSTART.DATE,Y.JULDATES)
    Y.JULDATES = Y.JULDATES[3,5]
    Y.DATES = YSTART.DATE
*
    YNEXT.RUN.DATE = R.DATES(EB.DAT.NEXT.WORKING.DAY)
    YNEXT.RUN.MONTH = YNEXT.RUN.DATE[5,2]
    IF YNEXT.RUN.MONTH <> YCURR.MONTH THEN
        YEND.DATE = YNEXT.RUN.DATE[1,6]:"01"
    END ELSE
        YEND.DATE = YNEXT.RUN.DATE
    END
*
* Store all dates and corresponding Half Julian dates till end date
*
    YT.DATE = YSTART.DATE
    LOOP
        CALL CDT("",YT.DATE,"+1C")
    UNTIL YT.DATE = YEND.DATE
        Y.DATES<-1> = YT.DATE
        YT.JULDATE = ""
        CALL JULDATE(YT.DATE,YT.JULDATE)
        Y.JULDATES<-1> = YT.JULDATE[3,5]
    REPEAT
*
LIST.DATES.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
LIST.CONTRACT.NOS:
*-----------------
* Prepares list of contract nos from the following files for later use
*        1) LMM.ACCOUNT.BALANCES with id like LD...
*        2) RE.LD.ACC.BAL
*        3) LMM.EOD.LIST with id like LD...
*        4) LMM.HISTORY.TODAY with id like LD...
* (1) and (2) give list of all contract nos to be processed
* Lists (3) and (4) trigger settlement processing
* List (4) triggers processing of changes in contract details
*
*-----------------------------------------------------------------------
*
* build LMM.LIST
*
    YLMM.ACC.BAL.CNOS = ""
    YID.LMM.ACC.BAL = ""
*
    CLEARSELECT
*
*###      EXECUTE "DELETE.LIST ":ID.COMPANY:".RE.LD.BAL.MOVE.LMM"
*###      EXECUTE "SSELECT ":YFN.LMM.ACCOUNT.BALANCES:" WITH @ID LIKE LD... "
*###      EXECUTE "SAVE.LIST ":ID.COMPANY:".RE.LD.BAL.MOVE.LMM"
*###      READLIST YLMM.ACC.BAL.CNOS FROM ID.COMPANY:".RE.LD.BAL.MOVE.LMM" ELSE
*###         YLMM.ACC.BAL.CNOS = ""
*###      END
*
    SELECT.COMMAND = "SSELECT ":YFN.LMM.ACCOUNT.BALANCES:" WITH @ID LIKE LD... "
    YLMM.ACC.BAL.CNOS = ""
    CALL EB.READLIST(SELECT.COMMAND, YLMM.ACC.BAL.CNOS, "LD.ACCBAL", "", "")
*
*
* build RE.LD.ACC.BAL list
*
    YID.RE.LD.ACC.BAL = ""
    YRE.LD.ACC.BAL.CNOS = ""
    CLEARSELECT
*
*###      EXECUTE "DELETE.LIST ":ID.COMPANY:".RE.LD.BAL.MOVE.ACC"
*###      EXECUTE "SSELECT ":YFN.RE.LD.ACC.BAL
*###      EXECUTE "SAVE.LIST ":ID.COMPANY:".RE.LD.BAL.MOVE.ACC"
*###      READLIST YRE.LD.ACC.BAL.CNOS FROM ID.COMPANY:".RE.LD.BAL.MOVE.ACC" ELSE
*###         YRE.LD.ACC.BAL.CNOS = ""
*###      END
*
    SELECT.COMMAND = "SSELECT ":YFN.RE.LD.ACC.BAL
    YRE.LD.ACC.BAL.CNOS = ""
    CALL EB.READLIST(SELECT.COMMAND, YRE.LD.ACC.BAL.CNOS, "LD.RE.ACCBAL", "", "")
*
* build EOD list
*
    Y.EOD.CNOS = ""
    YI = 1
    LOOP UNTIL Y.JULDATES<YI> = ""
        READ Y.LMM.EOD.REC FROM F.LMM.EOD.LIST,Y.JULDATES<YI> ELSE Y.LMM.EOD.REC = ""
        IF Y.LMM.EOD.REC <> "" THEN
            YJ = 1
            LOOP UNTIL Y.LMM.EOD.REC<YJ> = ""
                IF Y.LMM.EOD.REC<YJ>[1,2] = 'LD' THEN
                    LOCATE Y.LMM.EOD.REC<YJ> IN Y.EOD.CNOS<1> BY "AL" SETTING YLOC ELSE
                        INS Y.LMM.EOD.REC<YJ> BEFORE Y.EOD.CNOS<YLOC>
                    END
                END
                YJ += 1
            REPEAT
        END
        YI += 1
    REPEAT
*
* build HIST list
*
*###      EXECUTE "DELETE.LIST ":ID.COMPANY:".RE.LD.BAL.MOVE.HIST"
*###      EXECUTE 'SSELECT ':YFN.LMM.HISTORY.TODAY:" WITH @ID LIKE LD..."
*###      EXECUTE "SAVE.LIST ":ID.COMPANY:".RE.LD.BAL.MOVE.HIST"
*###      READLIST Y.HIS.CNOS FROM ID.COMPANY:".RE.LD.BAL.MOVE.HIST" THEN
*###         CONVERT @IM TO FM IN Y.HIS.CNOS
*###      END ELSE
*###         Y.HIS.CNOS = ""
*###      END
*
    SELECT.COMMAND = 'SSELECT ':YFN.LMM.HISTORY.TODAY:" WITH @ID LIKE LD..."
    Y.HIS.CNOS = ""
    CALL EB.READLIST(SELECT.COMMAND, Y.HIS.CNOS, "LD.RE.HIS", "", "")
*
LIST.CONTRACT.NOS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
CHECK.INSTALL.CHANGES:
*---------------------
* Checks for changes in int&comm categ codes and sets corresponding
* flags for later use
* if there is no install conds for previous day then todays install
* conds is used
*------------------------------------------------------------------------
*
*
* initialise flags
*
    YCHECK.IR.CUR = 0
    YCHECK.CR.CUR = 0
    YCHECK.IP.CUR = 0
    YCHECK.IPA = 0
    YCHECK.IRA = 0
    YCHECK.CRA = 0
    YCHECK.IR.PEN = 0
    YCHECK.CR.PEN = 0
    YCHECK.IR.PEN.M = 0
    YCHECK.CR.PEN.M = 0
    YCHECK.IR.SUS = 0
    YCHECK.CR.SUS = 0
    YCHECK.WHT = 0
    YCHECK.TAX.WHT = 0
    YCHECK.TAX.WHT.NT = 0
    YCHECK.TAX.WHT.GS = 0
    YINSTALL.COND.CHANGED = 0
*
    IF YPREV.INSTALL.REC = "" THEN
        YPREV.INSTALL.REC = Y.INSTL.REC
        GOTO CIC.RETURN:
    END
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IR..CUR> <> Y.INSTL.REC<LD30.PL.O.SET.IR..CUR> THEN
        YCHECK.IR.CUR = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.CR..CUR> <> Y.INSTL.REC<LD30.PL.O.SET.CR..CUR> THEN
        YCHECK.CR.CUR = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IRA> <> Y.INSTL.REC<LD30.PL.O.SET.IRA> THEN
        YCHECK.IRA = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IP..CUR> <> Y.INSTL.REC<LD30.PL.O.SET.IP..CUR> THEN
        YCHECK.IP.CUR = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.CRA> <> Y.INSTL.REC<LD30.PL.O.SET.CRA> THEN
        YCHECK.CRA = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IPA> <> Y.INSTL.REC<LD30.PL.O.SET.IPA> THEN
        YCHECK.IPA = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN> <> Y.INSTL.REC<LD30.PL.O.SET.IR..PEN> THEN
        YCHECK.IR.PEN = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.CP..CUR> <> Y.INSTL.REC<LD30.PL.O.SET.CP..CUR> THEN
        YCHECK.CR.PEN = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN.M> <> Y.INSTL.REC<LD30.PL.O.SET.IR..PEN.M> THEN
        YCHECK.IR.PEN.M = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.CR..PEN.M> <> Y.INSTL.REC<LD30.PL.O.SET.CR..PEN.M> THEN
        YCHECK.CR.PEN.M = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.IR..SUS> <> Y.INSTL.REC<LD30.PL.O.SET.IR..SUS> THEN
        YCHECK.IR.SUS = 1
        YINSTALL.COND.CHANGED = 1
    END
*
    IF YPREV.INSTALL.REC<LD30.PL.O.SET.CR..SUS> <> Y.INSTL.REC<LD30.PL.O.SET.CR..SUS> THEN
        YCHECK.CR.SUS = 1
        YINSTALL.COND.CHANGED = 1
    END
*
*
CIC.RETURN:
    RETURN
*
*------------------------------------------------------------------------
BUILD.CHARGE.CATEG.CODES:
*------------------------
* builds 2 arrays of charge conds and associated categ codes for
* all available charge codes - from RE.LD.CHARGE.COND &
* LMM.CHARGE.CONDITIONS
* yesterday's values are got from RE.LD.CHARGE.COND with id as ID.COMPANY
* today's by using a select list of charge conditions
* write back todays values on to RE.LD.CHARGE.COND
*------------------------------------------------------------------------
    AVAIL.CHRG.CODES = ""
    AVAIL.OLD.CHRG.CATEG.CODES = ""
    AVAIL.NEW.CHRG.CATEG.CODES = ""
    TODAY.CHRG.CODES = ""
    TODAY.CHRG.CATEG.CODES = ""
*
* get yesterday's charge codes
*
    YID.RE.LD.CHARGE.COND = ID.COMPANY
    GOSUB READ.RE.LD.CHARGE.COND:
    AVAIL.CHRG.CODES = YRE.LD.CHARGE.COND.REC<RE.LD.CHARGE.CODE>
    AVAIL.OLD.CHRG.CATEG.CODES = YRE.LD.CHARGE.COND.REC<RE.LD.CHARGE.CATEG.CODE>
    AVAIL.NEW.CHRG.CATEG.CODES = YRE.LD.CHARGE.COND.REC<RE.LD.CHARGE.CATEG.CODE>
*
* build today's array
*
    YID.LMM.CHARGE.CONDITIONS = ""
    CLEARSELECT
    EXECUTE "SELECT ":YFN.LMM.CHARGE.CONDITIONS
    LOOP
        READNEXT YID.LMM.CHARGE.CONDITIONS ELSE YID.LMM.CHARGE.CONDITIONS = ""
    WHILE YID.LMM.CHARGE.CONDITIONS
        GOSUB READ.LMM.CHARGE.CONDITIONS:
        YCHRG.CATEG.CODE = YCHARGE.COND.REC<LD21.CATEGORY.CODE>
        LOCATE YID.LMM.CHARGE.CONDITIONS IN TODAY.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
        ELSE
            INS YID.LMM.CHARGE.CONDITIONS BEFORE TODAY.CHRG.CODES<1,YCHRG.LOC>
            INS YCHRG.CATEG.CODE BEFORE TODAY.CHRG.CATEG.CODES<1,YCHRG.LOC>
        END
*
        YCHRG.LOC = ""
        LOCATE YID.LMM.CHARGE.CONDITIONS IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
        ELSE
            INS YID.LMM.CHARGE.CONDITIONS BEFORE AVAIL.CHRG.CODES<1,YCHRG.LOC>
            INS "" BEFORE AVAIL.OLD.CHRG.CATEG.CODES<1,YCHRG.LOC>
            INS YCHRG.CATEG.CODE BEFORE AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>
            YCHRG.LOC = ""
        END
        IF YCHRG.LOC THEN
            AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC> = YCHRG.CATEG.CODE
        END
    REPEAT
*
* write back RE.LD.CHARGE.COND
*
    YRE.LD.CHARGE.COND.REC<RE.LD.CHARGE.CODE> = TODAY.CHRG.CODES
    YRE.LD.CHARGE.COND.REC<RE.LD.CHARGE.CATEG.CODE> = TODAY.CHRG.CATEG.CODES
    GOSUB WRITE.RE.LD.CHARGE.COND:
*
BUILD.CHARGE.CATEG.CODES.RETURN:
    RETURN
*
*------------------------------------------------------------------------
GET.CCY.MKT:
*-----------
*
*  Calls routine FIND.CCY.MKT with the different movements, gets back
*  the currency market and stores it in memory.
*
    Y.APPL.ID = "LD"
    Y.CALL.CCY.MKT = ''
    YERR.CODE = ''
    YERR.MSG = ''
    Y.TXN.CCY.MKT = Y.CONTRACT.CCY.MKT
    CALL FIND.CCY.MKT(Y.APPL.ID,
    Y.CALL.TYPE,
    Y.MVMT.ID,
    Y.CALL.CCY.MKT,
    Y.TXN.CCY.MKT,
    YERR.CODE,
    YERR.MSG)
*
    IF YERR.CODE THEN
        E = "LD.RTN..CCY.MKT":FM:YERR.MSG
        GOTO FATAL.ERROR:
    END
    RETURN
*
*------------------------------------------------------------------------
MAIN.PROCESS:
*------------
* loops until all the keys are processed
*------------------------------------------------------------------------
*
    LOOP
* get the  contract no to be processed
    UNTIL Y.ENDRUN
REP1:
        GOSUB FETCH.KEY:
*
        IF YKEY.BAL THEN
            GOSUB READ.LD.FILES
*
* identify diff processes to be carried out based on EOD & HIST lists
*
            GOSUB GET.DIFF.PROC:
*
* Generate Consolidation Key for the Current LD  record
*
            GOSUB GET.CONSOL.KEY
            YKEY.CURR = YKEY.CON
*
* store flds reqd for schd.amt consolidation
*
            GOSUB STORE.LD.DET
*
            GOSUB ACCUM.MOVEMENTS
*
            IF YINSTALL.COND.CHANGED THEN
                GOSUB PROC.INSTALL.CHANGES
            END
*
            IF YHIST.PROCESS THEN
                IF Y.LD.REC.FOUND THEN
                    GOSUB PROCESS.STATIC.CHANGES
*
                    IF YKEY.FIELD.CHANGED THEN
*
*  If the consol key has changed then the link file should not be updated
*
                        Y.BASE.KEYS = ""
*
                    END
                END
            END
            GOSUB UPDATE.CONSOL
*
            IF YREVERSED.CONTRACT THEN
                GOSUB DELETE.RE.LD.ACC.BAL:
            END ELSE
                GOSUB WRITE.RE.LD.ACC.BAL:
            END
        END
    REPEAT
*
    BATCH.DETAILS<1> = 2
*
MAIN.PROCESS.RETURN:
*
    RETURN
*
***********************************************************************
***************       END OF MAIN ROUTINE              ****************
***********************************************************************
*
*------------------------------------------------------------------------
FETCH.KEY:
*------------
* gets the current contract no to be processed by comparing LMM list with
* RE.LD list
* If not found on lmm file checks in lmm hist file otherwise
* checks for error conditions
*
*------------------------------------------------------------------------
*
    YCONTRACT.FOUND = 0
    YREVERSED.CONTRACT = 0
    LOOP UNTIL YCONTRACT.FOUND OR Y.ENDRUN
        IF YGET.NEXT.RE.LD THEN
            REMOVE YRE.LD.KEY FROM YRE.LD.ACC.BAL.CNOS SETTING YDELIM.LD
        END
        IF YGET.NEXT.LMM THEN
            REMOVE YLMM.KEY FROM YLMM.ACC.BAL.CNOS SETTING YDELIM.LMM
        END
        YGET.NEXT.RE.LD = ''
        YGET.NEXT.LMM = ''
        Y.EOL = (YDELIM.LD + YDELIM.LMM)
        Y.EOL += (YRE.LD.KEY NE "") + (YLMM.KEY NE "")
        IF NOT(Y.EOL) THEN    ;* All data processed
            Y.ENDRUN = 1
        END

        IF YLMM.KEY THEN
            IF YRE.LD.KEY THEN
                BEGIN CASE
                CASE YLMM.KEY > YRE.LD.KEY
                    YKEY.BAL = YRE.LD.KEY
                    GOSUB CHECK.ACCBAL.HIST
                    IF YREVERSED.CONTRACT THEN
                        YCONTRACT.FOUND = 1
                    END ELSE
                        GOSUB CHECK.BALANCE.DTLS
                        YKEY.BAL = ''
                    END
                    YGET.NEXT.RE.LD = 1
                CASE YLMM.KEY < YRE.LD.KEY
                    YKEY.BAL = YLMM.KEY
                    YCONTRACT.FOUND = 1
                    YGET.NEXT.LMM = 1
                CASE OTHERWISE
                    YKEY.BAL = YLMM.KEY
                    YCONTRACT.FOUND = 1
                    YGET.NEXT.RE.LD = 1
                    YGET.NEXT.LMM = 1
                END CASE
            END ELSE
                YKEY.BAL = YLMM.KEY
                YGET.NEXT.LMM = 1
                YCONTRACT.FOUND = 1
            END
        END ELSE
            YKEY.BAL = YRE.LD.KEY
            GOSUB CHECK.ACCBAL.HIST
            IF YREVERSED.CONTRACT THEN
                YCONTRACT.FOUND = 1
            END ELSE
                IF YKEY.BAL THEN
                    GOSUB CHECK.BALANCE.DTLS
                    YKEY.BAL = ''
                END
            END
            YGET.NEXT.RE.LD = 1
        END
*

    REPEAT

    RETURN
*
*------------------------------------------------------------------------
CHECK.ACCBAL.HIST:
*-----------------
* check if contract is present in LMM.ACCOUNT.BALANCES.HIST and move it to
* YLMM.ACC.BAL.REC
*------------------------------------------------------------------------
*
    YREVERSED.CONTRACT = 1
    READ YLMM.ACC.BAL.REC FROM F.LMM.ACCOUNT.BALANCES.HIST,YKEY.BAL
    ELSE
        YLMM.ACC.BAL.REC = ""
        YREVERSED.CONTRACT = ""
    END
*
    RETURN
*
*------------------------------------------------------------------------
CHECK.BALANCE.DTLS:
*------------------
* for contracts found on RE.LD.ACC.BAL file but not on LMM.ACCOUNT.BAL
* ( not applicable for contracts reversed and found in accbal hist file)
* checks are made to ensure that no balances are left on RE.LD.ACC.BAL
* file
*   - FATAL ERROR condition raised when principal balances of FWD,CURR,
*     PDO and NAB are not zero
*   - EXCEPTION condition raised when interest,commission,fees and
*     charges flds are not zero
*------------------------------------------------------------------------
*
    GOSUB READ.RE.LD.ACC.BAL:
*
* for princ balances
*
    YFWD.BAL = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC> + 0
    YCURR.BAL = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CURR.PRINC> + 0
    YOD.BAL = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OD.PRINC> + 0
    YNAB.BAL = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.PRINC.NAB> + 0
*
    IF YFWD.BAL OR YCURR.BAL OR YOD.BAL OR YNAB.BAL THEN
        E ="LC.RTN.CONTRACT.NO.PRINCIPAL.BAL.PRE.ACBAL.REC.MISS":FM:YKEY.BAL
        GOTO FATAL.ERROR
    END
*
* for int,comm,fees,chrgs
*
    GOSUB CHECK.OTHER.BALANCES
*
    GOSUB DELETE.RE.LD.ACC.BAL:
*
CHECK.BALANCES.RETURN:
*
    RETURN
*
*-----------------------------------------------------------------------
CHECK.OTHER.BALANCES:
*--------------------
* check and write EXCEPTION.LOG for outstanding int/comm/fee/charges amts
*------------------------------------------------------------------------
*
    Y.EXC.REC.ID = YKEY.BAL
*
    YEXC.FLD = "CURR.INT"
    YEXC.AMT = 0
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.ACCRUED.INT> + YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.INT>
    GOSUB WRITE.EXCEPTION.LOG:
*
    YEXC.FLD = "INT.REC.IN.ADV"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.INT.REC.IN.ADV> + 0
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "CURR.COMM"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.ACCRUED.COMM> + YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.COM>
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "COM.REC.IN.ADV"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.COM.REC.IN.ADV> + 0
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "PEN.INT"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OS.INT.ACC.ON.OD.P> + YRE.LD.ACC.BAL.REC<RE.LAB.PEN.INT.REC>
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "MEMO BASIS INT"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.M.OS.I.ACC.ON.OD.P> + 0
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "PEN.COMM"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OS.COM.ACC.ON.OD.P> + YRE.LD.ACC.BAL.REC<RE.LAB.PEN.COM.REC>
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "MEMO BASIS COMM"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.M.OS.C.ACC.ON.OD.P> + 0
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "NAB INT"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.INT.ON.NAB> + 0
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "NAB COMM"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.COMM.ON.NAB> + 0
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "INT PAYABLE"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CUR.ACC.I.PAY> + YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAYABLE.UCL>
    GOSUB WRITE.EXCEPTION.LOG
*
    YEXC.FLD = "INT.PAID.IN.ADV"
    YEXC.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAID.IN.ADV>
    GOSUB WRITE.EXCEPTION.LOG
*
* for fees amortised
*
    YEXC.FLD = "FEE.PAID.IN.ADV"
    YEXC.AMT = 0
    IF YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV> <> "" THEN
        YNO.OF.FEES = COUNT(YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV>,VM) + 1
        FOR YFEE = 1 TO YNO.OF.FEES
            IF YRE.LD.ACC.BAL.REC<RE.LAB.NO.OF.MTHS.LEFT,YFEE> <> 0 THEN
                YFEE.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV,YFEE> - ((YRE.LD.ACC.BAL.REC<RE.LAB.ORIGIN.AMOR.MTH,YFEE> - YRE.LD.ACC.BAL.REC<RE.LAB.NO.OF.MTHS.LEFT,YFEE>) * YRE.LD.ACC.BAL.REC<RE.LAB.MTHLY.AMORT.AMT,YFEE>)
                YEXC.AMT += YFEE.AMT
            END
        NEXT YFEE
    END
    GOSUB WRITE.EXCEPTION.LOG
*
* for charges due
*
    YEXC.FLD = "CHARGES DUE"
    YEXC.AMT = 0
    IF YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.AMT.DUE> <> "" THEN
        YNO.OF.FEES = COUNT(YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.AMT.DUE>,VM) + 1
        FOR YFEE = 1 TO YNO.OF.FEES
            YFEE.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.AMT.DUE,YFEE> + YRE.LD.ACC.BAL.REC<RE.LAB.AMT.REC,YFEE>
            YEXC.AMT += YFEE.AMT
        NEXT YFEE
    END
    GOSUB WRITE.EXCEPTION.LOG
*
* for fees due
*
    YEXC.FLD = "FEES DUE"
    YEXC.AMT = 0
    IF YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FEE.DUE> <> "" THEN
        YNO.OF.FEES = COUNT(YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FEE.DUE>,VM) + 1
        FOR YFEE = 1 TO YNO.OF.FEES
            YFEE.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FEE.DUE,YFEE.NO> + YRE.LD.ACC.BAL.REC<RE.LAB.CUM.FEE.REC,YFEE.NO>
            YEXC.AMT += YFEE.AMT
        NEXT YFEE
    END
    GOSUB WRITE.EXCEPTION.LOG
*
CHECK.OTHER.BALANCES.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
WRITE.EXCEPTION.LOG:
*-------------------
*
    IF YEXC.AMT THEN
        Y.EXC.ERR.MSG = "OUTSTANDING ":YEXC.FLD:" AMOUNT - ":YEXC.AMT
*
        CALL EXCEPTION.LOG(Y.EXC.USER,Y.EXC.APPLIC,Y.EXC.RTN,Y.EXC.MODULE,Y.EXC.ERR.CODE,Y.EXC.VAL,Y.EXC.FILE,Y.EXC.REC.ID,Y.EXC.CURR.NO,Y.EXC.ERR.MSG,Y.EXC.DEPT.CODE)
    END
*
    RETURN
*
*------------------------------------------------------------------------
GET.DIFF.PROC:
*-------------
* for current contract no check whether settlement,static changes process
* to be done by comparing with EOD and HIST lists
*------------------------------------------------------------------------
*
    YHIST.PROCESS = ""
    YSETTLEMENT.PROCESS = ""
*
    LOCATE YKEY IN Y.HIS.CNOS<1> BY 'AL' SETTING YHIST.POS
    ELSE
        YHIST.POS = ""
    END
*
    LOCATE YKEY IN Y.EOD.CNOS<1> BY 'AL' SETTING YEOD.POS
    ELSE
        YEOD.POS = ""
    END
*
    IF YHIST.POS THEN
        YSETTLEMENT.PROCESS = 1
        YHIST.PROCESS = 1
    END ELSE
        IF YEOD.POS THEN
            YSETTLEMENT.PROCESS = 1
        END
    END
*
GET.DIFF.PROC.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
GET.CONSOL.KEY:
*--------------
*
    Y.CONSOL.KEY.GENERATED = ""
    IF YLMM.ACC.BAL.REC<LD27.CONSOL.KEY> <> "" THEN
        YKEY.CON = YLMM.ACC.BAL.REC<LD27.CONSOL.KEY>
        YMAT.DATE = ""
    END ELSE
        GOSUB GEN.CONSOL.KEY
        YHIST.PROCESS = ""
        YLMM.ACC.BAL.REC<LD27.CONSOL.KEY> = YKEY.CON
        GOSUB WRITE.LMM.ACCOUNT.BALANCES
        Y.CONSOL.KEY.GENERATED = 1
    END
*
GET.CONSOL.KEY.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
GEN.CONSOL.KEY:
*--------------
*
    MAT YR.LOCAL.FILE.1 = MAT Y.LD.REC
    YKEY.CON = "LD":".":Y.LD.REC(LD.CURRENCY.MARKET):".":Y.LD.REC(LD.POSITION.TYPE):".":Y.LD.REC(LD.CURRENCY)
    Y.LOCAL.FILE.ID = YKEY
*
    $INSERT I_GOSUB.RE.KEY.GEN.CON
*
REM CONSOLIDATE KEY GENERATED IS NOW STORED IN YKEY.CON
*
    RETURN
*
*------------------------------------------------------------------------
STORE.LD.DET:
*************
* Routine stores Loans & Deposits details for later use to update
* Consolidate records
* The required fields are separated by SMs and the sequence of concat
* is the same as the interest fields in CONSOLIDATE.ASST.LIAB file
* Null values are inserted when not applicable for
* Loans & Deposits
*------------------------------------------------------------------------
*
    YT.LD.DET = Y.LD.REC(LD.VALUE.DATE):SM:Y.LD.REC(LD.FIN.MAT.DATE):SM:SM:SM
    YT.LD.DET := Y.LD.REC(LD.INTEREST.KEY):SM:Y.LD.REC(LD.INTEREST.SPREAD)
    RETURN
*
*------------------------------------------------------------------------
ACCUM.MOVEMENTS:
*---------------
* calculates diff movements and stores in memory
*
*------------------------------------------------------------------------
*
    GOSUB GET.CONTRACT.TYPE:
*
    GOSUB PROC.PRINC.MOVEMENTS
*
    GOSUB PROC.DISC.TYPE.FIELDS
*
    GOSUB PROC.INT.TYPE.FIELDS
*
    GOSUB PROC.AMORTISED.FEES:
*
    GOSUB PROC.CHARGES.DUE:
*
    GOSUB PROC.FEES.DUE:
*
    GOSUB PROC.WHT:
*
ACCUM.MOVEMENTS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
GET.CONTRACT.TYPE:
*------------------
* find whether interest & discount calc is on discount or bearing basis
* whether the contract is loan or deposit
*------------------------------------------------------------------------
*
    YINT.INT.BEARING.BASIS = ""
    YINT.DISCOUNT.BASIS = ""
    YCOM.INT.BEARING.BASIS = ""
    YCOM.DISCOUNT.BASIS = ""
    YLOAN.CONTRACT = ""
    YDEPOSIT.CONTRACT = ""
    BEGIN CASE
    CASE Y.LD.REC(LD.INT.PAYMT.METHOD) = 1
* interest bearing basis
        YINT.INT.BEARING.BASIS = 1
    CASE Y.LD.REC(LD.INT.PAYMT.METHOD) = 2
* interest on discount basis
        YINT.DISCOUNT.BASIS = 1
    END CASE
    BEGIN CASE
    CASE Y.LD.REC(LD.COMM.PAYMT.METHOD) = 1
* comm not discount basis
        YCOM.INT.BEARING.BASIS = 1
    CASE Y.LD.REC(LD.COMM.PAYMT.METHOD) = 2
* comm on discount basis
        YCOM.DISCOUNT.BASIS = 1
    END CASE
*
    IF YLMM.ACC.BAL.REC<LD27.TRANS.PRIN.AMT,1> > 0 THEN
        YDEPOSIT.CONTRACT = 1
    END ELSE
        YLOAN.CONTRACT = 1
    END
*
GET.CONTRACT.TYPE.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.PRINC.MOVEMENTS:
*-------------------
* Accumulation of TYPE wise balance amounts for the consolidate key
*
*------------------------------------------------------------------------
*
    YMAT.MARKER = ""          ;* Set when prin set to 0
    YT.BASE.REMOVED.KEY = ""
    YT.SCHD.AMT = ""
    YY.ENTRY = YKEY
*
    IF YLMM.ACC.BAL.REC<LD27.DATE.FROM> = "" THEN
        GOTO PROC.PRINC.MOVEMENTS.RETURN:
    END
    YCOUNT.AV = COUNT(YLMM.ACC.BAL.REC<LD27.DATE.FROM>,VM)+1
*
* Set base remove key if required
*
    IF YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> + 0 = 0 THEN
        IF YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + 0 = 0 THEN
            IF YLMM.ACC.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> + 0 = 0 THEN
                IF YLMM.ACC.BAL.REC<LD27.OUTS.PRINC.NAB,YCOUNT.AV> + 0 = 0 THEN
                    YMAT.MARKER = YKEY  ;* Use for TXN code
*
** Check for outstanding accruals. If any are present we should NOT
** remove the key at this point.
*
                    GOSUB CHECK.OTS.ACCRUALS
                    IF NOT(ACCRUALS.PRESENT) THEN ;* Break the Link
                        YT.BASE.REMOVED.KEY = YKEY
                        YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
                        IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
                            YLMM.ACC.BAL.REC<LD27.CONSOL.KEY> = ''
                            GOSUB WRITE.LMM.ACCOUNT.BALANCES:
                        END
                    END
*
                END
            END
        END
    END
*
    IF YLMM.ACC.BAL.REC<LD27.TRANS.PRIN.AMT,1> > 0 THEN
        YREF.DBCR = "CR"
    END ELSE
        YREF.DBCR = "DB"
    END
    GOSUB FWD.PRINC.PROCESS:
    GOSUB CURR.PRINC.PROCESS:
    GOSUB PDO.PRINC.PROCESS:
    GOSUB NAB.PRINC.PROCESS:
*
    YRE.LD.ACC.BAL.REC<RE.LAB.CURRENCY> = YLMM.ACC.BAL.REC<LD27.CURRENCY>
    YRE.LD.ACC.BAL.REC<RE.LAB.DATE.FROM> = YLMM.ACC.BAL.REC<LD27.DATE.FROM,YCOUNT.AV>
*
PROC.PRINC.MOVEMENTS.RETURN:
    RETURN
*
*------------------------------------------------------------------------
FWD.PRINC.PROCESS:
*-----------------
*
* forward princ processing
*
*------------------------------------------------------------------------
*
    YT.FWD.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> - YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC>
*
    IF YT.FWD.AMT = 0 THEN
        GOTO FWD.PRINC.PROCESS.RETURN:
    END
*
    YLMM.BAL.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> + 0
    YRE.LD.BAL.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC> + 0
    YPRINC.TYPE = "F"
    GOSUB GET.SPL.ENT.TXN.CODE:
*
    IF YREF.DBCR = "CR" THEN
        YYTYPE = Y.FWD.CR.TYPE
    END ELSE
        YYTYPE = Y.FWD.DB.TYPE
    END
* check whether contract belongs to commitment categs
    YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
    IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
        YYTYPE = Y.FWD.COMMITMENT.TYPE
    END
    YYAMT = YT.FWD.AMT
*
* If the outstanding forward principal has become zero then the local
* equivalent is the amt stored in RE.LD.ACC.BAL file. Also clear the
* local equiv and exchange rate fields in RE.LD.ACC.BAL
*
    IF YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> = 0 OR YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> = "" THEN
        YY.LCLAMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC.LCL> * -1
*
*******  Correction done... EB8800509
*
        YEXCHANGE.RATE = YRE.LD.ACC.BAL.REC<RE.LAB.EXCHANGE.RATE>
        YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC.LCL> = ""
        YRE.LD.ACC.BAL.REC<RE.LAB.EXCHANGE.RATE> = ""
    END ELSE
        Y.CCY = FIELD(YKEY.CURR,".",4)
        Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
        YY.LCLAMT = ""
        IF Y.CCY <> LCCY THEN
            YCHECK.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC> + 0
            IF YCHECK.AMT = 0 THEN
                YEXCHANGE.RATE = ""
                CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
                YRE.LD.ACC.BAL.REC<RE.LAB.EXCHANGE.RATE> = YEXCHANGE.RATE
            END ELSE
* use rate from RE.LD.ACC.BAL to calculate local ccy amt
                YEXCHANGE.RATE = YRE.LD.ACC.BAL.REC<RE.LAB.EXCHANGE.RATE>
                CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
            END
* update lcl equiv in RE.LD.ACC.BAL with days movement
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC.LCL> = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC.LCL> + YY.LCLAMT
        END
    END
*
    GOSUB UPDATE.CONSOL.STORE
*
    YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC> = YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV>
*
FWD.PRINC.PROCESS.RETURN:
    RETURN
*
*
*------------------------------------------------------------------------
CURR.PRINC.PROCESS:
*-----------------
*
* current princ processing
*
*------------------------------------------------------------------------
*
    YT.CURR.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> - YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CURR.PRINC>
*
    IF YT.CURR.AMT = 0 THEN
        GOTO CURR.PRINC.PROCESS.RETURN:
    END
*
    YLMM.BAL.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + 0
    YRE.LD.BAL.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CURR.PRINC> + 0
    YPRINC.TYPE = "C"
    GOSUB GET.SPL.ENT.TXN.CODE:
*
    IF YREF.DBCR = "CR" THEN
        YYTYPE = Y.CURR.CR.TYPE
    END ELSE
        YYTYPE = Y.CURR.DB.TYPE
    END
* check whether contract belongs to commitment categs
    YYAMT = YT.CURR.AMT
    YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
    IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
        YYTYPE = Y.CURR.COMMITMENT.TYPE
*
*  For commitments use exchange rate as when initiation of contract  *
*
        GOSUB PROCESS.COMMITMENTS:
    END
    GOSUB UPDATE.CONSOL.STORE
*
    YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CURR.PRINC> = YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV>
*
CURR.PRINC.PROCESS.RETURN:
    RETURN
*
*------------------------------------------------------------------------
PROCESS.COMMITMENTS:
*------------------
*
*  While initiation of commitment contract, store the exchange rate
*  used in RE.LD.ACC.BAL file. For all further calculations, only this
*  exchange rate is to be used. PIF NUMBER : EB8801089
*
    IF YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> = 0 OR YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> = "" THEN
        YY.LCLAMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CMT.PRINC.LCL> * -1
*
        YEXCHANGE.RATE = YRE.LD.ACC.BAL.REC<RE.LAB.CMMT.EXCH.RATE>
        YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CMT.PRINC.LCL> = ""
        YRE.LD.ACC.BAL.REC<RE.LAB.CMMT.EXCH.RATE> = ""
    END ELSE
        Y.CCY = FIELD(YKEY.CURR,".",4)
        Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
        YY.LCLAMT = ""
        IF Y.CCY <> LCCY THEN
            YCHECK.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CURR.PRINC> + 0
            IF YCHECK.AMT = 0 THEN
                YEXCHANGE.RATE = ""
                CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
                YRE.LD.ACC.BAL.REC<RE.LAB.CMMT.EXCH.RATE> = YEXCHANGE.RATE
            END ELSE
* use rate from RE.LD.ACC.BAL to calculate local ccy amt
                YEXCHANGE.RATE = YRE.LD.ACC.BAL.REC<RE.LAB.CMMT.EXCH.RATE>
                CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
            END
* update lcl equiv in RE.LD.ACC.BAL with days movement
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CMT.PRINC.LCL> = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CMT.PRINC.LCL> + YY.LCLAMT
        END
    END
*
    RETURN
*
*------------------------------------------------------------------------
PDO.PRINC.PROCESS:
*-----------------
*
* overdue princ processing
*
*------------------------------------------------------------------------
*
    YT.OD.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> - YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OD.PRINC>
*
    IF YT.OD.AMT = 0 THEN
        GOTO PDO.PRINC.PROCESS.RETURN:
    END
*
    YLMM.BAL.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> + 0
    YRE.LD.BAL.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OD.PRINC> + 0
    YPRINC.TYPE = "P"
    GOSUB GET.SPL.ENT.TXN.CODE:
*
    IF YREF.DBCR = "CR" THEN
        YYTYPE = Y.OD.CR.TYPE
    END ELSE
        YYTYPE = Y.OD.DB.TYPE
    END
    YYAMT = YT.OD.AMT
    GOSUB UPDATE.CONSOL.STORE
*
    YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OD.PRINC> = YLMM.ACC.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV>
*
PDO.PRINC.PROCESS.RETURN:
    RETURN
*
*
*------------------------------------------------------------------------
NAB.PRINC.PROCESS:
*-----------------
*
* NAB princ processing
*
*------------------------------------------------------------------------
*
    YT.NAB.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.PRINC.NAB,YCOUNT.AV> - YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.PRINC.NAB>
*
    IF YT.NAB.AMT = 0 THEN
        GOTO NAB.PRINC.PROCESS.RETURN:
    END
*
    YLMM.BAL.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.PRINC.NAB,YCOUNT.AV> + 0
    YRE.LD.BAL.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.PRINC.NAB> + 0
    YPRINC.TYPE = "N"
    GOSUB GET.SPL.ENT.TXN.CODE:
*
    IF YREF.DBCR = "CR" THEN
        YYTYPE = Y.NAB.CR.TYPE
    END ELSE
        YYTYPE = Y.NAB.DB.TYPE
    END
    YYAMT = YT.NAB.AMT
    GOSUB UPDATE.CONSOL.STORE
*
    YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.PRINC.NAB> = YLMM.ACC.BAL.REC<LD27.OUTS.PRINC.NAB,YCOUNT.AV>
*
NAB.PRINC.PROCESS.RETURN:
    RETURN
*
*------------------------------------------------------------------------
GET.SPL.ENT.TXN.CODE:
*-------------------
* checks the movement by comparing the amts from ACCBAL & RE.LMM.BALANCES
* and translates the spl entry txn ref
*------------------------------------------------------------------------
*
    IF YMAT.MARKER THEN
* maturity
        YSPL.ENT.TXN.CODE = YSPL.ENT.TXN.REF.MAT
        GOTO GET.SPL.ENT.TXN.CODE.RETURN:
    END
*
    IF YLMM.BAL.AMT < 0 THEN
        YLMM.BAL.AMT = YLMM.BAL.AMT * -1
    END
    IF YRE.LD.BAL.AMT < 0 THEN
        YRE.LD.BAL.AMT = YRE.LD.BAL.AMT * -1
    END
*
    IF YRE.LD.BAL.AMT = 0 THEN
        IF YLMM.BAL.AMT <> 0 THEN
            YSPL.ENT.TXN.CODE = YPRINC.TYPE:"NW"
        END
    END ELSE
        IF YLMM.BAL.AMT > YRE.LD.BAL.AMT THEN
            YSPL.ENT.TXN.CODE = YPRINC.TYPE:"IN"
        END ELSE
            YSPL.ENT.TXN.CODE = YPRINC.TYPE:"RP"
        END
    END
*
GET.SPL.ENT.TXN.CODE.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.DISC.TYPE.FIELDS:
*-----------------------
*
* calculates receipts/payments and accruals for interest & commissions
* which are on discount basis
*------------------------------------------------------------------------
*
* check for receipts by checking start periods
* for interest and commissions
*
    YINT.RECEIPT.OR.PMNT = 0
    YSPL.ENT.TXN.CODE = YCAPITALISE.CODE
    YY.ENTRY = YKEY
    IF YINT.DISCOUNT.BASIS THEN
        IF YLMM.ACC.BAL.REC<LD27.START.PERIOD.INT> <= YNEXT.WORKING.DAY THEN
            IF YLMM.ACC.BAL.REC<LD27.START.PERIOD.INT> <> YRE.LD.ACC.BAL.REC<RE.LAB.START.PERIOD.INT> THEN
* receipts
                YINT.RECEIPT.OR.PMNT = 1
                YYAMT = YLMM.ACC.BAL.REC<LD27.COMMITTED.INT> * -1
                IF YYAMT THEN
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'INTEREST'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    IF YYAMT > 0 THEN
                        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IRA>:'.':Y.CALL.CCY.MKT
                    END ELSE
                        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IPA>:'.':Y.CALL.CCY.MKT
                    END
                    GOSUB UPDATE.CONSOL.STORE
                END
                YRE.LD.ACC.BAL.REC<RE.LAB.START.PERIOD.INT> = YLMM.ACC.BAL.REC<LD27.START.PERIOD.INT>
            END
        END
    END
*
    YCOM.RECEIPT = 0
    YSPL.ENT.TXN.CODE = YCAPITALISE.CODE
    YY.ENTRY = YKEY
    IF YCOM.DISCOUNT.BASIS THEN
        IF YLMM.ACC.BAL.REC<LD27.START.PERIOD.COM> <= YNEXT.WORKING.DAY THEN
            IF YLMM.ACC.BAL.REC<LD27.START.PERIOD.COM> <> YRE.LD.ACC.BAL.REC<RE.LAB.START.PERIOD.COM> THEN
* receipts
                YCOM.RECEIPT = 1
                YYAMT = YLMM.ACC.BAL.REC<LD27.COMMITTED.COMM> * -1
                IF YYAMT THEN
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'COMM.CHRG'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CRA>:'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                END
                YRE.LD.ACC.BAL.REC<RE.LAB.START.PERIOD.COM> = YLMM.ACC.BAL.REC<LD27.START.PERIOD.COM>
            END
        END
    END
*
* accruals
*
    YSPL.ENT.TXN.CODE = YACCRUAL.CODE
    YYENTRY = YACC.MVMT.ENTRY
    IF YINT.DISCOUNT.BASIS THEN
* for int recd
*         IF YLMM.ACC.BAL.REC<LD27.COMMITTED.INT> < 0 THEN
        IF YLOAN.CONTRACT THEN
            IF YINT.RECEIPT.OR.PMNT THEN
                YCAPITALISED.AMT = YLMM.ACC.BAL.REC<LD27.COMMITTED.INT> * -1
                YYAMT = (YLMM.ACC.BAL.REC<LD27.INT.REC.IN.ADV> - (YRE.LD.ACC.BAL.REC<RE.LAB.INT.REC.IN.ADV> + YCAPITALISED.AMT))
            END ELSE
                YYAMT = (YLMM.ACC.BAL.REC<LD27.INT.REC.IN.ADV> - YRE.LD.ACC.BAL.REC<RE.LAB.INT.REC.IN.ADV>)
            END
            IF YYAMT THEN
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'INTEREST'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IRA>:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
        END
*
* for int paid
*
*         IF YLMM.ACC.BAL.REC<LD27.COMMITTED.INT> > 0 THEN
        IF YDEPOSIT.CONTRACT THEN
            IF YINT.RECEIPT.OR.PMNT THEN
                YCAPITALISED.AMT = YLMM.ACC.BAL.REC<LD27.COMMITTED.INT> * -1
                YYAMT = (YLMM.ACC.BAL.REC<LD27.INT.PAID.IN.ADV> - (YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAID.IN.ADV> + YCAPITALISED.AMT))
            END ELSE
                YYAMT = (YLMM.ACC.BAL.REC<LD27.INT.PAID.IN.ADV> - YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAID.IN.ADV>)
            END
            IF YYAMT THEN
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'INTEREST'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IPA>:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
        END
    END
*
* commission recd
*
    IF YCOM.DISCOUNT.BASIS THEN
        IF YCOM.RECEIPT THEN
            YCAPITALISED.AMT = YLMM.ACC.BAL.REC<LD27.COMMITTED.COMM> * -1
            YYAMT = (YLMM.ACC.BAL.REC<LD27.COM.REC.IN.ADV> -(YRE.LD.ACC.BAL.REC<RE.LAB.COM.REC.IN.ADV> + YCAPITALISED.AMT))
        END ELSE
            YYAMT = (YLMM.ACC.BAL.REC<LD27.COM.REC.IN.ADV> - YRE.LD.ACC.BAL.REC<RE.LAB.COM.REC.IN.ADV>)
        END
        IF YYAMT THEN
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'COMM.CHRG'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CRA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
*
    END
* store new values in RE.LD.ACC.BAL
*
    YRE.LD.ACC.BAL.REC<RE.LAB.INT.REC.IN.ADV> = YLMM.ACC.BAL.REC<LD27.INT.REC.IN.ADV>
    YRE.LD.ACC.BAL.REC<RE.LAB.COM.REC.IN.ADV> = YLMM.ACC.BAL.REC<LD27.COM.REC.IN.ADV>
    YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAID.IN.ADV> = YLMM.ACC.BAL.REC<LD27.INT.PAID.IN.ADV>
*
PROC.DISC.TYPE.FIELDS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.INT.TYPE.FIELDS:
*----------------------
* calculates receipts/payments,accruals of interest,commissions for
* interest bearing type contracts
*------------------------------------------------------------------------
*
    GOSUB PROC.CURR.CAP.AND.ACC:
*
    GOSUB PROC.PENALTY.CAP.AND.ACC:
*
    GOSUB PROC.MEMO.CAP.AND.ACC:
*
PROC.INT.TYPE.FIELDS.RETURN:
*
    RETURN
*------------------------------------------------------------------------
PROC.CURR.CAP.AND.ACC:
*---------------------
*
* calculates capitalisation and accruals for current interest/commissions
* amounts
*
*------------------------------------------------------------------------
*
*
* calc capitalisation amt
*
    YSPL.ENT.TXN.CODE = YCAPITALISE.CODE
    YY.ENTRY = YKEY
    YCAPITALISED.INT.AMT = 0
    YCAPITALISED.COM.AMT = 0
    IF YSETTLEMENT.PROCESS THEN
* check settlements reflected in ACCBAL recs
        GOSUB PROC.ACCBAL.SETTLEMENTS:
        IF Y.LD.REC(LD.STATUS) <> "WOF" AND Y.LD.REC(LD.STATUS) <> "NAB" THEN
            IF YLMM.ACC.BAL.REC<81> <> "REVE" THEN
*
* process schd past recs
*
                GOSUB PROC.SCHEDULES.PAST:
            END
        END
*
        IF YLOAN.CONTRACT THEN
            IF YINT.INT.BEARING.BASIS THEN
                IF YCAPITALISED.INT.AMT THEN
                    YYAMT = YCAPITALISED.INT.AMT
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'INTEREST'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                END
            END
        END
*
        IF YDEPOSIT.CONTRACT THEN
            IF YINT.INT.BEARING.BASIS THEN
                IF YCAPITALISED.INT.AMT THEN
                    YYAMT = YCAPITALISED.INT.AMT
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'INTEREST'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                END
            END
        END
*
        IF YCOM.INT.BEARING.BASIS THEN
            IF YCAPITALISED.COM.AMT THEN
                YYAMT = YCAPITALISED.COM.AMT
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..CUR>:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
        END
    END
*
* calc accruals
*
    YSPL.ENT.TXN.CODE = YACCRUAL.CODE
    YY.ENTRY = YKEY
    YACCRUED.AMT = 0
* for loan contracts
    IF YLOAN.CONTRACT THEN
        IF YINT.INT.BEARING.BASIS THEN
* interest accruals
            YACCRUED.AMT = (YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.INT> + YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.INT>) - (YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.ACCRUED.INT> + YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.INT> + YCAPITALISED.INT.AMT)
            IF YACCRUED.AMT THEN
                YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'INTEREST'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
* store new amts in RE.LD.ACC.BAL
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.ACCRUED.INT> = YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.INT>
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.INT> = YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.INT>
        END
*
* for commission accruals
*
        IF YCOM.INT.BEARING.BASIS THEN
            YACCRUED.AMT = (YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.COMM> + YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.COM>) - (YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.ACCRUED.COMM> + YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.COM> + YCAPITALISED.COM.AMT)
            IF YACCRUED.AMT THEN
                YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..CUR>:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
* store new amts in RE.LD.ACC.BAL
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.ACCRUED.COMM> = YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.COMM>
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.COM> = YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.COM>
        END
    END
*
* for deposits
*
    IF YDEPOSIT.CONTRACT THEN
        IF YINT.INT.BEARING.BASIS THEN
            YACCRUED.AMT = (YLMM.ACC.BAL.REC<LD27.OUTS.CUR.ACC.I.PAY> + YLMM.ACC.BAL.REC<LD27.INT.PAYABLE.UCL>) - (YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CUR.ACC.I.PAY> + YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAYABLE.UCL> + YCAPITALISED.INT.AMT)
            IF YACCRUED.AMT THEN
                YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'INTEREST'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
* store new amts in RE.LD.ACC.BAL
            YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CUR.ACC.I.PAY> = YLMM.ACC.BAL.REC<LD27.OUTS.CUR.ACC.I.PAY>
            YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAYABLE.UCL> = YLMM.ACC.BAL.REC<LD27.INT.PAYABLE.UCL>
        END
    END
*
*
PROC.CURR.CAP.AND.ACC.RETURN:
    RETURN
*
*
*------------------------------------------------------------------------
PROC.ACCBAL.SETTLEMENTS:
*-----------------------
*
* check if overdue amounts on RE.LD.ACC.BAL and LMM.ACCOUNT.BALANCES
* are of opposite sign to that expected and include in capitalisation
* calculation(pre-payments): OUTS.OVER.DUE.INT fld or INT.PAYABLE.UCL fld
*
*------------------------------------------------------------------------
*
    YRE.LD.AMT = 0
    YLMM.AMT = 0
    IF YINT.INT.BEARING.BASIS THEN
        IF YLOAN.CONTRACT THEN
            IF YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.INT> > 0 THEN
                YRE.LD.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.INT>
            END
*
            IF YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.INT> > 0 THEN
                YLMM.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.INT>
            END
        END
*
        IF YDEPOSIT.CONTRACT THEN
            IF YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAYABLE.UCL> < 0 THEN
                YRE.LD.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.INT.PAYABLE.UCL>
            END
*
            IF YLMM.ACC.BAL.REC<LD27.INT.PAYABLE.UCL> < 0 THEN
                YLMM.AMT = YLMM.ACC.BAL.REC<LD27.INT.PAYABLE.UCL>
            END
        END
*
        YCAP.AMT = YLMM.AMT - YRE.LD.AMT
        YCAPITALISED.INT.AMT += YCAP.AMT
    END
*
* commissions
*
    YRE.LD.AMT = 0
    YLMM.AMT = 0
    IF YCOM.INT.BEARING.BASIS THEN
        IF YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.COM> > 0 THEN
            YRE.LD.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.OVER.DUE.COM>
        END
*
        IF YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.COM> > 0 THEN
            YLMM.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.COM>
        END
        YCAP.AMT = YLMM.AMT - YRE.LD.AMT
        YCAPITALISED.COM.AMT += YCAP.AMT
    END
*
PROC.ACCBAL.SETTLEMENTS.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.SCHEDULES.PAST:
*-------------------
* processes available schedules from RE.LD.ACC.BAL &
*         new schedules past rec between today and next working day
*------------------------------------------------------------------------
*
    IF YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE> <> "" THEN
        YDATE.NO = 1
        Y.FLAG.OVER = ""
        LOOP
        UNTIL YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE,YDATE.NO> = "" OR Y.FLAG.OVER
            YSCHED.DATE = YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE,YDATE.NO>
            Y.SCHED.STATUS = ""
            LOCATE YSCHED.DATE IN YLMM.SCHEDULE.DATES.REC<1> BY "AL" SETTING Y.DATE.FOUND ELSE NULL
            IF YSCHED.DATE = YLMM.SCHEDULE.DATES.REC<Y.DATE.FOUND,1> THEN
                Y.SCHED.STATUS = YLMM.SCHEDULE.DATES.REC<Y.DATE.FOUND,2>
                IF YLMM.SCHEDULE.DATES.REC<Y.DATE.FOUND,2> = "D" THEN
                    IF YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.STATUS,YDATE.NO> = "D" THEN
*
*    The schedule is "DEAD"
*
                        GOTO NEXT.DATE
                    END
                END
            END
            YCAP.INT.AMT = 0
            YCAP.COM.AMT = 0
            YJUL.DATE = YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE,YDATE.NO>
            YID.LMM.SCHEDULES.PAST = YKEY:YJUL.DATE:"00"
            GOSUB READ.LMM.SCHEDULES.PAST:
            IF YLMM.SCHEDULES.PAST.REC = "" THEN
                IF Y.LD.REC(LD.STATUS) = "LIQ" THEN
                    YID.HIST.LMM.SCHEDULES.PAST = YID.LMM.SCHEDULES.PAST
                    GOSUB READ.SCHEDULES.PAST.HIST:
                END
                IF YLMM.SCHEDULES.PAST.REC = "" THEN
                    E ="LD.RTN.MISSING.REC":FM:YID.LMM.SCHEDULES.PAST:VM:YFN.LMM.SCHEDULES.PAST
                    GOTO FATAL.ERROR
                END
            END
*
            IF YRE.LD.ACC.BAL.REC<RE.LAB.INTEREST.REC.AMT,YDATE.NO> = YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.REC.AMT> THEN
                IF YRE.LD.ACC.BAL.REC<RE.LAB.COMM.REC.AMT,YDATE.NO> = YLMM.SCHEDULES.PAST.REC<LD28.COMM.REC.AMOUNT> THEN
*
*   No need to process any further SCHEDULES.PAST records
*
                    Y.FLAG.OVER = 1
                    GOTO NEXT.DATE
                END
            END
*            IF YLMM.SCHEDULES.PAST.REC <> "" THEN
            IF YINT.INT.BEARING.BASIS THEN
                YCAP.INT.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.INTEREST.REC.AMT,YDATE.NO> - YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.REC.AMT>
                YCAPITALISED.INT.AMT += YCAP.INT.AMT
            END
            IF YCOM.INT.BEARING.BASIS THEN
                YCAP.COM.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.COMM.REC.AMT,YDATE.NO> - YLMM.SCHEDULES.PAST.REC<LD28.COMM.REC.AMOUNT>
                YCAPITALISED.COM.AMT += YCAP.COM.AMT
            END
* store the new balances in RE.LD.ACC.BAL
            YRE.LD.ACC.BAL.REC<RE.LAB.INTEREST.REC.AMT,YDATE.NO> = YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.REC.AMT>
            YRE.LD.ACC.BAL.REC<RE.LAB.COMM.REC.AMT,YDATE.NO> = YLMM.SCHEDULES.PAST.REC<LD28.COMM.REC.AMOUNT>
            YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.STATUS,YDATE.NO> = Y.SCHED.STATUS
*            END ELSE
*               DEL YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE,YDATE.NO>
*               DEL YRE.LD.ACC.BAL.REC<RE.LAB.INTEREST.REC.AMT,YDATE.NO>
*               DEL YRE.LD.ACC.BAL.REC<RE.LAB.COMM.REC.AMT,YDATE.NO>
*            END
NEXT.DATE:
*--------
            YDATE.NO += 1
        REPEAT
    END
*
* process new schedules
*
    YDATE.NO = 0
    LOOP
        YDATE.NO += 1
    UNTIL Y.JULDATES<YDATE.NO> = ""
        YCAP.INT.AMT = 0
        YCAP.COM.AMT = 0
        YID.LMM.SCHEDULES.PAST = YKEY:Y.JULDATES<YDATE.NO>:"00"
        GOSUB READ.LMM.SCHEDULES.PAST:
        IF YLMM.SCHEDULES.PAST.REC <> "" THEN
            Y.SCHED.STATUS = ""
            LOCATE Y.JULDATES<YDATE.NO> IN YLMM.SCHEDULE.DATES.REC<1> SETTING Y.DATE.FOUND ELSE Y.DATE.FOUND = ""
            IF Y.DATE.FOUND THEN
                Y.SCHED.STATUS = YLMM.SCHEDULE.DATES.REC<Y.DATE.FOUND,2>
            END
            IF YINT.INT.BEARING.BASIS THEN
                YCAP.INT.AMT = YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.REC.AMT> * -1
                YCAPITALISED.INT.AMT += YCAP.INT.AMT
                IF YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.REC.AMT> <> YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> THEN
                    YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE,-1> = Y.JULDATES<YDATE.NO>
                    YRE.LD.ACC.BAL.REC<RE.LAB.INTEREST.REC.AMT,-1> = YLMM.SCHEDULES.PAST.REC<LD28.INTEREST.REC.AMT>
                    YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.STATUS,-1> = Y.SCHED.STATUS
                END
            END
*
            IF YCOM.INT.BEARING.BASIS THEN
                YCAP.COM.AMT = YLMM.SCHEDULES.PAST.REC<LD28.COMM.REC.AMOUNT> * -1
                YCAPITALISED.COM.AMT += YCAP.COM.AMT
                IF YLMM.SCHEDULES.PAST.REC<LD28.COMM.REC.AMOUNT> <> YLMM.SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> THEN
                    YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.DATE,-1> = Y.JULDATES<YDATE.NO>
                    YRE.LD.ACC.BAL.REC<RE.LAB.COMM.REC.AMT,-1> = YLMM.SCHEDULES.PAST.REC<LD28.COMM.REC.AMOUNT>
                    YRE.LD.ACC.BAL.REC<RE.LAB.SCHED.STATUS,-1> = Y.SCHED.STATUS
                END
            END
*
        END
    REPEAT
*
PROC.SCHEDULES.PAST.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.PENALTY.CAP.AND.ACC:
*--------------------
* calculates capitalisation & accrual amts for overdue principals
*------------------------------------------------------------------------
*
* capitalisation
*
    YSPL.ENT.TXN.CODE = YCAPITALISE.CODE
    YY.ENTRY = YKEY
    YCAPITALISED.AMT = 0
    Y.PEN.SPL.INT.PROCESS = ""
    Y.PEN.SPL.COM.PROCESS = ""
    YCAPITALISED.AMT = YLMM.ACC.BAL.REC<LD27.PEN.INT.REC> - YRE.LD.ACC.BAL.REC<RE.LAB.PEN.INT.REC>
*
    IF NOT(YLMM.ACC.BAL.REC<LD27.PEN.INT.REC>) THEN
        IF NOT(YLMM.ACC.BAL.REC<LD27.PEN.I.LAST.DAY.ACC>) THEN
            IF NOT(YLMM.ACC.BAL.REC<LD27.OS.INT.ACC.ON.OD.P>) THEN
                IF Y.LD.REC(LD.STATUS) <> "NAB" THEN
*
*  Consider yesterdays accrual and last day accrual as CAPITALISED AMOUNT
*
                    YCAPITALISED.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OS.INT.ACC.ON.OD.P> + YRE.LD.ACC.BAL.REC<RE.LAB.PEN.I.LAST.DAY.ACC>
*
*  Raise entry in opposite sign of accruals
*
                    YCAPITALISED.AMT = -(YCAPITALISED.AMT)
                    Y.PEN.SPL.INT.PROCESS = 1
                END
            END
        END
    END
*
    IF YCAPITALISED.AMT THEN
        YYAMT = YCAPITALISED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
    YCAPITALISED.AMT = YLMM.ACC.BAL.REC<LD27.PEN.COM.REC> - YRE.LD.ACC.BAL.REC<RE.LAB.PEN.COM.REC>
*
    IF NOT(YLMM.ACC.BAL.REC<LD27.PEN.COM.REC>) THEN
        IF NOT(YLMM.ACC.BAL.REC<LD27.PEN.C.LAST.DAY.ACC>) THEN
            IF NOT(YLMM.ACC.BAL.REC<LD27.OS.COM.ACC.ON.OD.P>) THEN
                IF Y.LD.REC(LD.STATUS) <> "NAB" THEN
*
*  Consider yesterdays accrual and last day accrual as CAPITALISED AMOUNT
*
                    YCAPITALISED.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.OS.COM.ACC.ON.OD.P> + YRE.LD.ACC.BAL.REC<RE.LAB.PEN.C.LAST.DAY.ACC>
                    YCAPITALISED.AMT = -(YCAPITALISED.AMT)
                    Y.PEN.SPL.COM.PROCESS = 1
                END
            END
        END
    END
*
    IF YCAPITALISED.AMT THEN
        YYAMT = YCAPITALISED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CP..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
* accruals
*
    YSPL.ENT.TXN.CODE = YACCRUAL.CODE
    YY.ENTRY = YKEY
    YACCRUED.AMT = 0
    YACCRUED.AMT = YLMM.ACC.BAL.REC<LD27.OS.INT.ACC.ON.OD.P> - YRE.LD.ACC.BAL.REC<RE.LAB.OS.INT.ACC.ON.OD.P>
*
    IF Y.PEN.SPL.INT.PROCESS THEN
*
*  Consider yesterdays last day accrual as ACCRUED AMOUNT
*
        YACCRUED.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.PEN.I.LAST.DAY.ACC>
    END
*
    IF YACCRUED.AMT THEN
        YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
    YACCRUED.AMT = YLMM.ACC.BAL.REC<LD27.OS.COM.ACC.ON.OD.P> - YRE.LD.ACC.BAL.REC<RE.LAB.OS.COM.ACC.ON.OD.P>
*
    IF Y.PEN.SPL.COM.PROCESS THEN
*
*  Consider yesterdays last day accrual as ACCRUED AMOUNT
*
        YACCRUED.AMT = YRE.LD.ACC.BAL.REC<RE.LAB.PEN.C.LAST.DAY.ACC>
    END
*
    IF YACCRUED.AMT THEN
        YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CP..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
* store new amt in RE.LD.ACC.BAL
    YRE.LD.ACC.BAL.REC<RE.LAB.PEN.INT.REC> = YLMM.ACC.BAL.REC<LD27.PEN.INT.REC>
    YRE.LD.ACC.BAL.REC<RE.LAB.PEN.COM.REC> = YLMM.ACC.BAL.REC<LD27.PEN.COM.REC>
    YRE.LD.ACC.BAL.REC<RE.LAB.OS.INT.ACC.ON.OD.P> = YLMM.ACC.BAL.REC<LD27.OS.INT.ACC.ON.OD.P>
    YRE.LD.ACC.BAL.REC<RE.LAB.OS.COM.ACC.ON.OD.P> = YLMM.ACC.BAL.REC<LD27.OS.COM.ACC.ON.OD.P>
    YRE.LD.ACC.BAL.REC<RE.LAB.PEN.I.LAST.DAY.ACC> = YLMM.ACC.BAL.REC<LD27.PEN.I.LAST.DAY.ACC>
    YRE.LD.ACC.BAL.REC<RE.LAB.PEN.C.LAST.DAY.ACC> = YLMM.ACC.BAL.REC<LD27.PEN.C.LAST.DAY.ACC>
*
PROC.PENALTY.CAP.AND.ACC.RETURN:
    RETURN
*
*------------------------------------------------------------------------
PROC.MEMO.CAP.AND.ACC:
*---------------------
* calculates capitalisation & accrual amts processed on MEMO basis
*------------------------------------------------------------------------
*
*
*
* accruals
*
    YSPL.ENT.TXN.CODE = YACCRUAL.CODE
    YY.ENTRY = YKEY
    YACCRUED.AMT = YLMM.ACC.BAL.REC<LD27.M.OS.I.ACC.ON.OD.P> - YRE.LD.ACC.BAL.REC<RE.LAB.M.OS.I.ACC.ON.OD.P>
    IF YACCRUED.AMT THEN
        YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN.M>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
    YRE.LD.ACC.BAL.REC<RE.LAB.M.OS.I.ACC.ON.OD.P> = YLMM.ACC.BAL.REC<LD27.M.OS.I.ACC.ON.OD.P>
*
    YACCRUED.AMT = YLMM.ACC.BAL.REC<LD27.M.OS.C.ACC.ON.OD.P> - YRE.LD.ACC.BAL.REC<RE.LAB.M.OS.C.ACC.ON.OD.P>
    IF YACCRUED.AMT THEN
        YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..PEN.M>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
    YRE.LD.ACC.BAL.REC<RE.LAB.M.OS.C.ACC.ON.OD.P> = YLMM.ACC.BAL.REC<LD27.M.OS.C.ACC.ON.OD.P>
*
    YACCRUED.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.INT.ON.NAB> - YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.INT.ON.NAB>
    IF YACCRUED.AMT THEN
        YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..SUS>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
    YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.INT.ON.NAB> = YLMM.ACC.BAL.REC<LD27.OUTS.INT.ON.NAB>
*
    YACCRUED.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.COMM.ON.NAB> - YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.COMM.ON.NAB>
    IF YACCRUED.AMT THEN
        YYAMT = YACCRUED.AMT
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..SUS>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
*
    YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.COMM.ON.NAB> = YLMM.ACC.BAL.REC<LD27.OUTS.COMM.ON.NAB>
*
PROC.MEMO.CAP.AND.ACC.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.AMORTISED.FEES:
*---------------------
* calculates fees and charges received and due including amortised fees
*------------------------------------------------------------------------
*
* amortised fees
* multivalue sets on LMM.ACC.BAL & RE.LD.ACC.BAL are compared to
* calculate the amts. New multivalue sets on LMM.ACC.BAL are added to
* RE.LD.ACC.BAL
* Check for changes in categ codes
*
    YNO.OF.FEES.IN.LMM = 0
    IF YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV> <> "" THEN
        YNO.OF.FEES.IN.LMM = COUNT(YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV>,VM) + 1
    END
    FOR YFEE.NO = 1 TO YNO.OF.FEES.IN.LMM
        YFLAG.CONSOL.UPDATED = 0
        BEGIN CASE
        CASE YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV,YFEE.NO> = ""
* capitalisation entry
            YFLAG.CONSOL.UPDATED = 1
            YSPL.ENT.TXN.CODE = YCAPITALISE.CODE
            YY.ENTRY = YKEY
            YFEES.RECD = YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV,YFEE.NO>
            IF YFEES.RECD THEN
                YYAMT = YFEES.RECD
                GOSUB RAISE.NEW.AMORT.FEE.ENTRY:
            END
*
* accruals
*
            YSPL.ENT.TXN.CODE = YACCRUAL.CODE
            YY.ENTRY = YKEY
            YNO.OF.AMORTISED.MONTHS = YLMM.ACC.BAL.REC<LD27.ORIGIN.AMOR.MTH,YFEE.NO> - YLMM.ACC.BAL.REC<LD27.NO.OF.MTHS.LEFT,YFEE.NO>
            IF YNO.OF.AMORTISED.MONTHS THEN
                YYAMT = YNO.OF.AMORTISED.MONTHS * YLMM.ACC.BAL.REC<LD27.MTHLY.AMORT.AMT,YFEE.NO> * -1
                GOSUB RAISE.NEW.AMORT.FEE.ENTRY:
            END
        CASE YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV,YFEE.NO> <> ""
*
* fee present on both files - RE.LD.ACC.BAL & LMM.ACC.BAL
*
            YFEE.AMT = 0
            IF YLMM.ACC.BAL.REC<LD27.NO.OF.MTHS.LEFT,YFEE.NO> = 0 THEN
                IF YRE.LD.ACC.BAL.REC<RE.LAB.NO.OF.MTHS.LEFT,YFEE.NO> THEN      ;*aLREADY DONE
                    YFEE.AMT = (YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV,YFEE.NO> - ((YRE.LD.ACC.BAL.REC<RE.LAB.ORIGIN.AMOR.MTH,YFEE.NO> - YRE.LD.ACC.BAL.REC<RE.LAB.NO.OF.MTHS.LEFT,YFEE.NO>) * YRE.LD.ACC.BAL.REC<RE.LAB.MTHLY.AMORT.AMT,YFEE.NO>)) * -1
                END
            END ELSE
*** GB9100043 :
                YFEE.AMT = (YRE.LD.ACC.BAL.REC<RE.LAB.MTHLY.AMORT.AMT,YFEE.NO> *(YRE.LD.ACC.BAL.REC<RE.LAB.NO.OF.MTHS.LEFT,YFEE.NO> - YLMM.ACC.BAL.REC<LD27.NO.OF.MTHS.LEFT,YFEE.NO>)) * -1
*** GB9100043 :
            END
*
            IF YFEE.AMT THEN
                YFLAG.CONSOL.UPDATED = 1
                YYAMT = YFEE.AMT
                YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.CHRGS.CODE,YFEE.NO>
                LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YUSED.CATEG.CODE = AVAIL.OLD.CHRG.CATEG.CODES<1,YCHRG.LOC>
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YUSED.CATEG.CODE:'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
        END CASE
*
        IF YFLAG.CONSOL.UPDATED THEN
* check for changes in charge categ code
            IF AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC> <> YUSED.CATEG.CODE THEN
                YSPL.ENT.TXN.CODE = YTABLE.CHANGED.CODE
                YY.ENTRY = YKEY
                YFEE.AMT = YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV,YFEE.NO> - (YLMM.ACC.BAL.REC<LD27.MTHLY.AMORT.AMT,YFEE.NO> * (YLMM.ACC.BAL.REC<LD27.ORIGIN.AMOR.MTH,YFEE.NO> - YLMM.ACC.BAL.REC<LD27.NO.OF.MTHS.LEFT,YFEE.NO>))
                IF YFEE.AMT THEN
* reverse old entry
                    YYAMT = YFEE.AMT * -1
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'COMM.CHRG'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    YYTYPE = YUSED.CATEG.CODE:'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
* raise new entry
                    YYAMT = YFEE.AMT
                    YYTYPE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>:'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                END
            END
        END
* store new values in RE.LD.ACC.BAL
        YRE.LD.ACC.BAL.REC<RE.LAB.FEE.PAID.IN.ADV,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.CCY,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.CHRGS.CCY,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.MTHLY.AMORT.AMT,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.MTHLY.AMORT.AMT,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.NO.OF.MTHS.LEFT,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.NO.OF.MTHS.LEFT,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.ORIGIN.AMOR.MTH,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.ORIGIN.AMOR.MTH,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.CODE,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.CHRGS.CODE,YFEE.NO>
    NEXT YFEE.NO
*
PROC.AMORTISED.FEES.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
RAISE.NEW.AMORT.FEE.ENTRY:
*-------------------------
* get type from NEW.CATEG.CODEs
*------------------------------------------------------------------------
*
    YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.CHRGS.CODE,YFEE.NO>
    LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
    ELSE
        E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
        GOTO FATAL.ERROR
    END
    YUSED.CATEG.CODE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>
*
**** Get currency market for appropriate movement
*
    Y.MVMT.ID = 'COMM.CHRG'
    Y.CALL.TYPE = 4
    GOSUB GET.CCY.MKT:
    YYTYPE = YUSED.CATEG.CODE:'.':Y.CALL.CCY.MKT
    GOSUB UPDATE.CONSOL.STORE
*
    RETURN
*
*------------------------------------------------------------------------
PROC.CHARGES.DUE:
*----------------
* process for charges not paid on due date
*------------------------------------------------------------------------
*
    YNO.OF.CHARGES.IN.LMM = 0
    IF YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE> <> "" THEN
        YNO.OF.CHARGES.IN.LMM = COUNT(YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE>,VM) + 1
    END
*
    FOR YCHRG.NO = 1 TO YNO.OF.CHARGES.IN.LMM
        YFLAG.CONSOL.UPDATED = 0
        BEGIN CASE
        CASE YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.AMT.DUE,YCHRG.NO> = ""
* non-payment
            YSPL.ENT.TXN.CODE = YDUE.CODE
            YY.ENTRY = YKEY
            YYAMT = YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE,YCHRG.NO> + YLMM.ACC.BAL.REC<LD27.AMT.REC,YCHRG.NO>
            IF YYAMT THEN
                YFLAG.CONSOL.UPDATED = 1
                YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.CHRG.CODE,YCHRG.NO>
                LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YUSED.CATEG.CODE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YUSED.CATEG.CODE:'SP':'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
*
        CASE YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.AMT.DUE,YCHRG.NO> <> ""
* receipt entry
            YSPL.ENT.TXN.CODE = YPAID.CODE
            YY.ENTRY = YKEY
            YYAMT = YLMM.ACC.BAL.REC<LD27.AMT.REC,YCHRG.NO> - YRE.LD.ACC.BAL.REC<RE.LAB.AMT.REC,YCHRG.NO>
            IF YYAMT THEN
                YFLAG.CONSOL.UPDATED = 1
                YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.CHRG.CODE,YCHRG.NO>
                LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YUSED.CATEG.CODE = AVAIL.OLD.CHRG.CATEG.CODES<1,YCHRG.LOC>
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YUSED.CATEG.CODE:'SP':'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
        END CASE
*
        IF YFLAG.CONSOL.UPDATED THEN
* check for changes in CHARGE.CONDITIONS
            YSPL.ENT.TXN.CODE = YTABLE.CHANGED.CODE
            YY.ENTRY = YKEY
            IF YUSED.CATEG.CODE <> AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC> THEN
                YCHARGE.AMT = YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE,YCHRG.NO> + YLMM.ACC.BAL.REC<LD27.AMT.REC,YCHRG.NO>
                IF YCHARGE.AMT THEN
* reverse old entry
                    YYAMT = YCHARGE.AMT * -1
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'COMM.CHRG'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    YYTYPE = YUSED.CATEG.CODE:'SP':'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                    YYAMT = YCHARGE.AMT
                    YYTYPE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>:'SP':'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                END
            END
        END
* store new values in RE.LD.ACC.BAL
        YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.AMT.DUE,YCHRG.NO> = YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE,YCHRG.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.CHRGS.DUE.DATE,YCHRG.NO> = YLMM.ACC.BAL.REC<LD27.CHRGS.DUE.DATE,YCHRG.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.CHRG.CODE,YCHRG.NO> = YLMM.ACC.BAL.REC<LD27.CHRG.CODE,YCHRG.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.AMT.REC,YCHRG.NO> = YLMM.ACC.BAL.REC<LD27.AMT.REC,YCHRG.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.DATE.RECEIVED,YCHRG.NO> = YLMM.ACC.BAL.REC<LD27.DATE.RECEIVED,YCHRG.NO>
*
    NEXT YCHRG.NO
*
PROC.CHARGES.DUE.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.FEES.DUE:
*-------------
* for fees due
*------------------------------------------------------------------------
*
    YNO.OF.FEES.DUE.IN.LMM = 0
    IF YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE> <> "" THEN
        YNO.OF.FEES.DUE.IN.LMM = COUNT(YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE>,VM) + 1
    END
    FOR YFEE.NO = 1 TO YNO.OF.FEES.DUE.IN.LMM
        YFLAG.CONSOL.UPDATED = 0
        BEGIN CASE
        CASE YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FEE.DUE,YFEE.NO> = ""
* non payment entry
            YSPL.ENT.TXN.CODE = YDUE.CODE
            YY.ENTRY = YKEY
            YYAMT = YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE,YFEE.NO> + YLMM.ACC.BAL.REC<LD27.CUM.FEE.REC>
            IF YYAMT THEN
                YFLAG.CONSOL.UPDATED = 1
                YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.FEE.CHRG.CODE,YFEE.NO>
                LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YUSED.CATEG.CODE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YUSED.CATEG.CODE:'SP':'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
*
        CASE YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FEE.DUE,YFEE.NO> <> ""
* check for receipt
            YSPL.ENT.TXN.CODE = YPAID.CODE
            YY.ENTRY = YKEY
            YYAMT = YLMM.ACC.BAL.REC<LD27.CUM.FEE.REC,YFEE.NO> - YRE.LD.ACC.BAL.REC<RE.LAB.CUM.FEE.REC,YFEE.NO>
            IF YYAMT THEN
                YFLAG.CONSOL.UPDATED = 1
                YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.FEE.CHRG.CODE,YFEE.NO>
                LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YUSED.CATEG.CODE = AVAIL.OLD.CHRG.CATEG.CODES<1,YCHRG.LOC>
*
**** Get currency market for appropriate movement
*
                Y.MVMT.ID = 'COMM.CHRG'
                Y.CALL.TYPE = 4
                GOSUB GET.CCY.MKT:
                YYTYPE = YUSED.CATEG.CODE:'SP':'.':Y.CALL.CCY.MKT
                GOSUB UPDATE.CONSOL.STORE
            END
        END CASE
*
        IF YFLAG.CONSOL.UPDATED THEN
*
* check for changes in LMM.CHARGE.CONDITIONS
*
            IF YUSED.CATEG.CODE <> AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC> THEN
                YSPL.ENT.TXN.CODE = YTABLE.CHANGED.CODE
                YY.ENTRY = YKEY
                YFEE.AMT = YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE,YFEE.NO> + YLMM.ACC.BAL.REC<LD27.CUM.FEE.REC,YFEE.NO>
                IF YFEE.AMT THEN
* reverse entry
                    YYAMT = YFEE.AMT * -1
*
**** Get currency market for appropriate movement
*
                    Y.MVMT.ID = 'COMM.CHRG'
                    Y.CALL.TYPE = 4
                    GOSUB GET.CCY.MKT:
                    YYTYPE = YUSED.CATEG.CODE:'SP':'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
* raise new entry
                    YYAMT = YFEE.AMT
                    YYTYPE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>:'SP':'.':Y.CALL.CCY.MKT
                    GOSUB UPDATE.CONSOL.STORE
                END
            END
        END
* store new values in RE.LD.ACC.BAL
        YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FEE.DUE,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.FEE.DUE.DATE,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.FEE.DUE.DATE,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.FEE.CHRG.CODE,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.FEE.CHRG.CODE,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.CUM.FEE.REC,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.CUM.FEE.REC,YFEE.NO>
        YRE.LD.ACC.BAL.REC<RE.LAB.LAST.DATE.REC,YFEE.NO> = YLMM.ACC.BAL.REC<LD27.LAST.DATE.REC,YFEE.NO>
*
    NEXT YFEE.NO
*
PROC.FEES.DUE.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROC.WHT:
*--------
* process With Holding Tax amts
*------------------------------------------------------------------------
*
PROC.WHT.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
GET.TAX.CCY.MKT:
*-----------
*
*   Gets the tax currency market using tax code as movement id.
*  Calls routine FIND.CCY.MKT with the different movements, gets back
*  the currency market and stores it in memory.
*
    Y.APPL.ID = "TAX"
    Y.CALL.TYPE = 6
    Y.MVMT.ID = Y.TAX.CODE
    Y.TAX.CCY.MKT = ''
    YERR.CODE = ''
    YERR.MSG = ''
    Y.TXN.CCY.MKT = Y.CONTRACT.CCY.MKT
    CALL FIND.CCY.MKT(Y.APPL.ID,
    Y.CALL.TYPE,
    Y.MVMT.ID,
    Y.TAX.CCY.MKT,
    Y.TXN.CCY.MKT,
    YERR.CODE,
    YERR.MSG)
*
    IF YERR.CODE THEN
        E = "LD.RTN..CCY.MKT":FM:YERR.MSG
        GOTO FATAL.ERROR:
    END
    RETURN
*
*------------------------------------------------------------------------
PROC.INSTALL.CHANGES:
*--------------------
* Uses the flags set for different accounts and moves the balances to the
* new categories(accounts)
*------------------------------------------------------------------------
*
*
    YY.LCLAMT = ""
    YY.ENTRY = YKEY
    YSPL.ENT.TXN.CODE = "TAB"
    YEXCHANGE.RATE = ""
*
    IF YCHECK.IR.CUR THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.INT> + YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.INT>
        IF Y.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
            YYAMT = -(Y.AMOUNT)
*
*  First remove the amount from the old tyepe
*
            GOSUB UPDATE.CONSOL.STORE
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
            YYAMT = Y.AMOUNT
*
*  Update the new type with the amount
*
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.CR.CUR THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.COMM> + YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.COM>
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'COMM.CHRG'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.CR..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.IP.CUR THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.CUR.ACC.I.PAY> + YLMM.ACC.BAL.REC<LD27.INT.PAYABLE.UCL>
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.IRA THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.INT.REC.IN.ADV> + 0
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IRA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IRA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.CRA THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.COM.REC.IN.ADV> + 0
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'COMM.CHRG'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CRA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.CRA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.IPA THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.INT.PAID.IN.ADV> + 0
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IPA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IPA>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.IR.PEN THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OS.INT.ACC.ON.OD.P> + YLMM.ACC.BAL.REC<LD27.PEN.INT.REC>
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..PEN>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.CR.PEN THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OS.COM.ACC.ON.OD.P> + YLMM.ACC.BAL.REC<LD27.PEN.COM.REC>
        IF Y.AMOUNT <> 0 THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'COMM.CHRG'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CP..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.CP..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.IR.PEN.M THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.M.OS.I.ACC.ON.OD.P> + 0
        IF Y.AMOUNT THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..PEN.M>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..PEN.M>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.CR.PEN.M THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.M.OS.C.ACC.ON.OD.P> + 0
        IF Y.AMOUNT THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'COMM.CHRG'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..PEN.M>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.CR..PEN.M>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.IR.SUS THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.INT.ON.NAB> + 0
        IF Y.AMOUNT THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'INTEREST'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.IR..SUS>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..SUS>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    IF YCHECK.CR.SUS THEN
        Y.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.COMM.ON.NAB> + 0
        IF Y.AMOUNT THEN
            YYAMT = -(Y.AMOUNT)
*
**** Get currency market for appropriate movement
*
            Y.MVMT.ID = 'COMM.CHRG'
            Y.CALL.TYPE = 4
            GOSUB GET.CCY.MKT:
            YYTYPE = YPREV.INSTALL.REC<LD30.PL.O.SET.CR..SUS>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
            YYAMT = Y.AMOUNT
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.CR..SUS>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
    END
*
    RETURN
*
*------------------------------------------------------------------------
UPDATE.CONSOL.STORE:
*-------------------
* appends the spl ent txn code to the type to store accruals and
* capitalisation separately
* stores the amounts,exch rates,txn codes,schd.amt details associated
* with the type
*------------------------------------------------------------------------
*
    YYTYPE = YYTYPE:YSPL.ENT.TXN.CODE
    LOCATE YYTYPE IN Y.TYPES<1> SETTING YLOC ELSE
        Y.TYPES<YLOC> = YYTYPE
        IF YYAMT > 0 THEN
            Y.CR.MVMT<YLOC> = YYAMT
            Y.DB.MVMT<YLOC> = 0
            Y.CR.LCL.MVMT<YLOC> = YY.LCLAMT
            Y.DB.LCL.MVMT<YLOC> = 0
        END ELSE
            Y.DB.MVMT<YLOC> = YYAMT
            Y.CR.MVMT<YLOC> = 0
            Y.DB.LCL.MVMT<YLOC> = YY.LCLAMT
            Y.CR.LCL.MVMT<YLOC> = 0
        END
        Y.MVMT.ENTRY<YLOC> = YY.ENTRY
        YCONS.SPL.ENT.TXN.CODES<YLOC> = YSPL.ENT.TXN.CODE
        YCONS.EXCHANGE.RATES<YLOC> = YEXCHANGE.RATE
        GOSUB UPDATE.LD.ENTRIES
        YLOC = ""
    END
    IF YLOC <> "" THEN
        IF YYAMT > 0 THEN
            Y.CR.MVMT<YLOC> = Y.CR.MVMT<YLOC> + YYAMT
            Y.CR.LCL.MVMT<YLOC> = Y.CR.LCL.MVMT<YLOC> + YY.LCLAMT
        END ELSE
            Y.DB.MVMT<YLOC> = Y.DB.MVMT<YLOC> + YYAMT
            Y.DB.LCL.MVMT<YLOC> = Y.DB.LCL.MVMT<YLOC> + YY.LCLAMT
        END
        GOSUB UPDATE.LD.ENTRIES
    END
*
UPDATE.CONSOL.STORE.RETURN:
*--------------------------
    RETURN
*
*------------------------------------------------------------------------
UPDATE.LD.ENTRIES:
*-----------------
* TYPE location is set in YLOC when this routine is entered
* This routine is called by UPDATE.CONSOL.STORE
*------------------------------------------------------------------------
*
    Y.TYPE.LOCATED = 1
    Y.TRIM.TYPE = YYTYPE[1,(LEN(YYTYPE) - 3)]
    LOCATE Y.TRIM.TYPE IN Y.SCHD.TYPES<1> SETTING Y.TYPE.LOC
    ELSE
        Y.TYPE.LOCATED = 0
    END
    IF Y.TYPE.LOCATED THEN
        LOCATE YT.LD.DET IN Y.LD.DETAILS<YLOC,1> SETTING YLOCV ELSE
            Y.LD.DETAILS<YLOC,YLOCV> = YT.LD.DET
            Y.SCHD.AMT<YLOC,YLOCV> = YYAMT
            YLOCV = ""
        END
        IF YLOCV <> "" THEN
            Y.SCHD.AMT<YLOC,YLOCV> = Y.SCHD.AMT<YLOC,YLOCV> + YYAMT
        END
*
        LOCATE YKEY IN Y.BASE.KEYS<YLOC,1> BY "AL" SETTING YLOCV ELSE
            INS YKEY BEFORE Y.BASE.KEYS<YLOC,YLOCV>
        END
*
        IF YT.BASE.REMOVED.KEY <> "" THEN
            LOCATE YT.BASE.REMOVED.KEY IN Y.BASE.REMOVED.KEYS<YLOC,1> BY "AL" SETTING YLOCV ELSE
                INS YT.BASE.REMOVED.KEY BEFORE Y.BASE.REMOVED.KEYS<YLOC,YLOCV>
            END
        END
    END
*
UPDATE.LD.ENTRIES.RETURN:
    RETURN
*
*------------------------------------------------------------------------
UPDATE.CONSOL:
*-------------
* for each type stored in memory updates the consolidation data base
* get rid of spl ent txn code appended to the type
*------------------------------------------------------------------------
*
    IF Y.TYPES <> "" THEN
        Y.PARAMS.CON = ""
        Y.PARAMS.CON<1> = YKEY.CURR
        Y.PARAMS.CON<2> = FIELD(YKEY.CURR,".",4)
        Y.COUNT.AV = COUNT(Y.TYPES,FM)+1
        FOR YI = 1 TO Y.COUNT.AV
            YCON.TYPE = Y.TYPES<YI>[1,LEN(Y.TYPES<YI>)-3]
            Y.PARAMS.CON<3> = YCON.TYPE
            Y.CCY.MKT = FIELD(YCON.TYPE,'.',2)
            IF Y.CCY.MKT = '' THEN
                Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
            END
            Y.PARAMS.CON<4> = Y.DB.MVMT<YI>
            Y.PARAMS.CON<5> = Y.CR.MVMT<YI>
            Y.PARAMS.CON<6> = ""
            Y.PARAMS.CON<7> = ""
            IF Y.PARAMS.CON<2> <> LCCY THEN
*
* LOCAL equivalents are already calculated and stored for FORWARD deals
*
                IF Y.PARAMS.CON<3> = Y.FWD.CR.TYPE OR Y.PARAMS.CON<3> = Y.FWD.DB.TYPE OR Y.PARAMS.CON<3> = Y.FWD.COMMITMENT.TYPE OR Y.PARAMS.CON<3> = Y.CURR.COMMITMENT.TYPE THEN
*
**** Commitments were included for PIF NO EB8801089
*
                    Y.PARAMS.CON<6> = Y.DB.LCL.MVMT<YI>
                    Y.PARAMS.CON<7> = Y.CR.LCL.MVMT<YI>
                    Y.PARAMS.CON<20> = YCONS.EXCHANGE.RATES<YI>
                END ELSE
*
* Calculate local equivalents for other types
*
                    IF Y.PARAMS.CON<4> <> 0 AND Y.PARAMS.CON<4> <> "" THEN
                        Y.LOCAL.EQ.AMT = ""
                        YEXCHANGE.RATE = ""
                        CALL MIDDLE.RATE.CONV.CHECK(Y.PARAMS.CON<4>,Y.PARAMS.CON<2>,YEXCHANGE.RATE,Y.CCY.MKT,Y.LOCAL.EQ.AMT,"","")
                        IF ETEXT <> "" THEN
                            E = YKEY.CURR:" ":Y.PARAMS.CON<4>:" CCY CONV ERR ":ETEXT
                            GOTO FATAL.ERROR
                        END ELSE
                            Y.PARAMS.CON<6> = Y.LOCAL.EQ.AMT
                            Y.PARAMS.CON<20> = YEXCHANGE.RATE
                        END
                    END
                    IF Y.PARAMS.CON<5> <> 0 AND Y.PARAMS.CON<5> <> "" THEN
                        Y.LOCAL.EQ.AMT = ""
                        YEXCHANGE.RATE = ""
                        CALL MIDDLE.RATE.CONV.CHECK(Y.PARAMS.CON<5>,Y.PARAMS.CON<2>,YEXCHANGE.RATE,Y.CCY.MKT,Y.LOCAL.EQ.AMT,"","")
                        IF ETEXT <> "" THEN
                            E = YKEY.CURR:" ":Y.PARAMS.CON<5>:" CCY CONV ERR ":ETEXT
                            GOTO FATAL.ERROR
                        END ELSE
                            Y.PARAMS.CON<7> = Y.LOCAL.EQ.AMT
                            Y.PARAMS.CON<20> = YEXCHANGE.RATE
                        END
                    END
                END
            END
*
            Y.PARAMS.CON<8> = ""
            Y.PARAMS.CON<9> = ""
            Y.PARAMS.CON<10> = ""
            Y.PARAMS.CON<11> = ""
            Y.PARAMS.CON<12> = ""
            Y.PARAMS.CON<13> = ""
            Y.PARAMS.CON<14> = ""
            YCOUNT = COUNT(Y.LD.DETAILS<YI>,VM)+1
            FOR YJ = 1 TO YCOUNT
                Y.PARAMS.CON<8,YJ> = Y.LD.DETAILS<YI,YJ,1>
                Y.PARAMS.CON<9,YJ> = Y.LD.DETAILS<YI,YJ,2>
                Y.PARAMS.CON<10,YJ> = Y.LD.DETAILS<YI,YJ,3>
                Y.PARAMS.CON<11,YJ> = Y.LD.DETAILS<YI,YJ,4>
                Y.PARAMS.CON<12,YJ> = Y.LD.DETAILS<YI,YJ,5>
                Y.PARAMS.CON<13,YJ> = Y.LD.DETAILS<YI,YJ,6>
                Y.PARAMS.CON<14,YJ> = Y.SCHD.AMT<YI,YJ>
            NEXT
            IF Y.CONSOL.KEY.GENERATED THEN
                Y.PARAMS.CON<15> = Y.BASE.KEYS<YI>
            END ELSE
                Y.PARAMS.CON<15> = ""
            END
            Y.PARAMS.CON<16> = Y.BASE.REMOVED.KEYS<YI>
            Y.PARAMS.CON<17> = Y.MVMT.ENTRY<YI>
            Y.PARAMS.CON<18> = Y.LD.REC(LD.CUSTOMER.ID)
            Y.PARAMS.CON<19> = YCONS.SPL.ENT.TXN.CODES<YI>
            Y.PARAMS.CON<21> = Y.LD.REC(LD.DEPT.CODE)
            Y.PARAMS.CON<22> = Y.LD.REC(LD.CATEGORY)
*
* Update CONSOLIDATE.ASST.LIAB file for this TYPE
*
            CALL RE.CONSOL.UPDATE(Y.PARAMS.CON,"ASSET&LIAB","")
        NEXT
    END
*
* Initialise values for next Consolidate Key
*
    YKEY.PREV = YKEY.CURR
    YMAT.DATE.PREV = YMAT.DATE
    Y.CR.MVMT = ""
    Y.DB.MVMT = ""
    Y.CR.LCL.MVMT = ""
    Y.DB.LCL.MVMT = ""
    Y.TYPES = ""
    Y.MVMT.ENTRY = ""
    Y.LD.DETAILS = ""
    YCONS.SPL.ENT.TXN.CODES = ""
    YCONS.EXCHANGE.RATES = ""
    Y.SCHD.AMT = ""
    Y.BASE.KEYS = ""
    Y.BASE.REMOVED.KEYS = ""
*
UPDATE.CONSOL.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROCESS.STATIC.CHANGES:
*----------------------
*
* gets the curr no of of main contract from LMM.HISTORY.LIST
* checks flds involved in consolidation for any change and also the schd
* flds like value date etc
* for changes in consol key creates entries for both principal and int/
* comm/fees&charges
* for changes in scheduled amt flds creates entries for only for princi
* balances
*------------------------------------------------------------------------
*
* Read Today's history list file
*
    YHIST.KEY = YKEY:TODAY
    GOSUB READ.HIST.LIST
*
* Initialise memory variables used to check changes in key fields
* and schd amt fields
*
    YKEY.FIELD.CHANGED = ""
    YSCHD.AMT.FLDS.CHANGED = ""
    YCHANGE.VALUE.DATE = "_"
    YCHANGE.MAT.DATE = "_"
    YCHANGE.INT.KEY = "_"
    YCHANGE.INT.SPREAD = "_"
    YKEY.NEW = YKEY.CURR
*
* Check for changes in the consolidation entries
*
    YCOUNT.HIS.RECS = COUNT(Y.HIST.LIST.REC<LD26.CURRENT.NO>,VM)+1
    FOR YX = YCOUNT.HIS.RECS TO 1 STEP -1
        IF Y.HIST.LIST.REC<LD26.FILE.NAME,YX> MATCHES "0X'LD.LOANS.AND.DEPOSITS'" THEN
            Y.HIS.REC.NO = Y.HIST.LIST.REC<LD26.CURRENT.NO,YX> - 1
            IF Y.HIS.REC.NO = 0 THEN
                YX = 1
            END ELSE
                Y.LD.HIS.KEY = YKEY:";":Y.HIS.REC.NO
                GOSUB READ.LD.HIS.FILE
                GOSUB CHECK.CONSOLIDATION.CHANGE
            END
        END
    NEXT
*
    IF YKEY.FIELD.CHANGED THEN
*
* When there is change in consolidation key fields
*
        GOSUB GEN.CONSOL.KEY
        YKEY.NEW = YKEY.CON
        YMAT.DATE.NEW = YMAT.DATE
        IF YKEY.NEW <> YKEY.CURR THEN
*
* Account for balance and interest changes
*
            GOSUB PROCESS.BAL.AND.INT.CHANGE
            YLMM.ACC.BAL.REC<LD27.CONSOL.KEY> = YKEY.NEW
*
* Save calculated consol. key
*
            GOSUB WRITE.LMM.ACCOUNT.BALANCES
        END
    END
*
    IF YSCHD.AMT.FLDS.CHANGED THEN
*
* Account for the changes in the interest details
*
        YMAT.DATE.NEW = YMAT.DATE
        GOSUB RESET.UNCHANGED.SCHD.FLDS
        GOSUB PROCESS.BAL.SCHD.CHANGE
    END
*
PROCESS.STATIC.CHANGES.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
READ.HIST.LIST:
*--------------
    READ Y.HIST.LIST.REC FROM F.LMM.HISTORY.LIST, YHIST.KEY ELSE
        E = "LD.RTN.RECORD.MISS":FM:YHIST.KEY:VM:YFN.LMM.HISTORY.LIST
        GOTO FATAL.ERROR
    END
    RETURN
*
*------------------------------------------------------------------------
READ.LD.HIS.FILE:
*----------------
    READ Y.LD.HIS.REC FROM F.LD.LOANS.AND.DEPOSITS$HIS,Y.LD.HIS.KEY ELSE
        E = "LD.RTN.HIS.REC.MISS":FM:Y.LD.HIS.KEY:VM:YFN.LD.LOANS.AND.DEPOSITS$HIS
        GOTO FATAL.ERROR
    END
    RETURN
*
*------------------------------------------------------------------------
WRITE.LMM.ACCOUNT.BALANCES:
*--------------------------
    WRITE YLMM.ACC.BAL.REC TO F.LMM.ACCOUNT.BALANCES,YKEY.BAL
    RETURN
*
*------------------------------------------------------------------------
CHECK.CONSOLIDATION.CHANGE:
*--------------------------
* Set indicator if any of consol.key fields has changed
*------------------------------------------------------------------------
    YAF = 1
    LOOP
        YCHEK.FIELD = Y.LD.KEY.FIELDS<YAF>
    UNTIL YKEY.FIELD.CHANGED = "Y" OR YCHEK.FIELD = "" DO
        IF Y.LD.HIS.REC<YCHEK.FIELD> <> "_" THEN
* CHECK ALSO AGAINST THE ACTUAL FIELD AS CURR.NO 1 STORES RECORD IMAGE
            IF Y.LD.HIS.REC<YCHEK.FIELD> <> Y.LD.REC(YCHEK.FIELD) THEN
                YKEY.FIELD.CHANGED = "Y"
            END
        END
        YAF += 1
    REPEAT
*
* Check change in interest fields and if any, update store
*
    IF Y.LD.HIS.REC<LD.VALUE.DATE> <> "_" THEN
        IF Y.LD.HIS.REC<LD.VALUE.DATE> <> Y.LD.REC(LD.VALUE.DATE) THEN
            YCHANGE.VALUE.DATE = Y.LD.HIS.REC<LD.VALUE.DATE>
            YSCHD.AMT.FLDS.CHANGED = "Y"
        END
    END
    IF Y.LD.HIS.REC<LD.FIN.MAT.DATE> <> "_" THEN
        IF Y.LD.HIS.REC<LD.FIN.MAT.DATE> <> Y.LD.REC(LD.FIN.MAT.DATE) THEN
            YCHANGE.MAT.DATE = Y.LD.HIS.REC<LD.FIN.MAT.DATE>
            YSCHD.AMT.FLDS.CHANGED = "Y"
        END
    END
    IF Y.LD.HIS.REC<LD.INTEREST.KEY> <> "_" THEN
        IF Y.LD.HIS.REC<LD.INTEREST.KEY> <> Y.LD.REC(LD.INTEREST.KEY) THEN
            YCHANGE.INT.KEY = Y.LD.HIS.REC<LD.INTEREST.KEY>
            YSCHD.AMT.FLDS.CHANGED = "Y"
        END
    END
    IF Y.LD.HIS.REC<LD.INTEREST.SPREAD> <> "_" THEN
        IF Y.LD.HIS.REC<LD.INTEREST.SPREAD> <> Y.LD.REC(LD.INTEREST.SPREAD) THEN
            YCHANGE.INT.SPREAD = Y.LD.HIS.REC<LD.INTEREST.SPREAD>
            YSCHD.AMT.FLDS.CHANGED = "Y"
        END
    END
*
    RETURN
*
*------------------------------------------------------------------------
PROCESS.BAL.AND.INT.CHANGE:
*--------------------------
*
* Entries for Balance fields
*
    YCOUNT.AV = COUNT(YLMM.ACC.BAL.REC<LD27.DATE.FROM>,VM)+1
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV>
    IF YH.AMOUNT <> "" AND YH.AMOUNT <> 0 THEN
        IF YH.AMOUNT > 0 THEN YH.TYPE = Y.FWD.CR.TYPE
        ELSE YH.TYPE = Y.FWD.DB.TYPE
* check whether contract belongs to commitment categs
        YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
        IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
            YH.TYPE = Y.FWD.COMMITMENT.TYPE
        END
*
* Local equivalent of forward principal should be available in
* record var. YRE.LD.ACC.BAL.REC
*
        YH.LCLAMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.FWD.PRINC.LCL>
        YSTORED.RATE = YRE.LD.ACC.BAL.REC<RE.LAB.EXCHANGE.RATE>
        YH.SCHD.AMOUNT = YH.AMOUNT
        GOSUB RAISE.CONSOL.ENTRIES
        YH.LCL.AMOUNT = ""
    END
* for curr princi
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV>
    IF YH.AMOUNT <> 0 THEN
        IF YH.AMOUNT > 0 THEN YH.TYPE = Y.CURR.CR.TYPE
        ELSE YH.TYPE = Y.CURR.DB.TYPE
* check whether contract belongs to commitment categs
        YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
        IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
*
*  Use stored local equivalents and exchange rates... EB8801089
*
            YH.TYPE = Y.CURR.COMMITMENT.TYPE
            YH.LCLAMT = YRE.LD.ACC.BAL.REC<RE.LAB.OUTS.CMT.PRINC.LCL>
            YSTORED.RATE = YRE.LD.ACC.BAL.REC<RE.LAB.CMMT.EXCH.RATE>
        END
        YH.SCHD.AMOUNT = YH.AMOUNT
        GOSUB RAISE.CONSOL.ENTRIES
    END
* for od princi
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV>
    IF YH.AMOUNT THEN
        IF YH.AMOUNT > 0 THEN YH.TYPE = Y.OD.CR.TYPE
        ELSE YH.TYPE = Y.OD.DB.TYPE
        YH.SCHD.AMOUNT = YH.AMOUNT
        GOSUB RAISE.CONSOL.ENTRIES
    END
* for nab princi
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.PRINC.NAB,YCOUNT.AV>
    IF YH.AMOUNT THEN
        IF YH.AMOUNT > 0 THEN YH.TYPE = Y.NAB.CR.TYPE
        ELSE YH.TYPE = Y.NAB.DB.TYPE
        YH.SCHD.AMOUNT = YH.AMOUNT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
* Entries for Interest ,commission,fees,charges fields
*
    YH.SCHD.AMOUNT = 0
* no schd.amt for int,comm,fees & charges
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.INT> + YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.INT>
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.ACCRUED.COMM> + YLMM.ACC.BAL.REC<LD27.OUTS.OVER.DUE.COM>
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.CR..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.CUR.ACC.I.PAY> + YLMM.ACC.BAL.REC<LD27.INT.PAYABLE.UCL>
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.INT.REC.IN.ADV> + 0
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IRA>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.COM.REC.IN.ADV> + 0
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.CRA>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.INT.PAID.IN.ADV> + 0
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IPA>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OS.INT.ACC.ON.OD.P> + YLMM.ACC.BAL.REC<LD27.PEN.INT.REC>
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..PEN>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OS.COM.ACC.ON.OD.P> + YLMM.ACC.BAL.REC<LD27.PEN.COM.REC>
    IF YH.AMOUNT <> 0 THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.CP..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.M.OS.I.ACC.ON.OD.P> + 0
    IF YH.AMOUNT THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..PEN.M>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.M.OS.C.ACC.ON.OD.P> + 0
    IF YH.AMOUNT THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.CR..PEN.M>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.INT.ON.NAB> + 0
    IF YH.AMOUNT THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'INTEREST'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..SUS>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
    YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.COMM.ON.NAB> + 0
    IF YH.AMOUNT THEN
*
**** Get currency market for appropriate movement
*
        Y.MVMT.ID = 'COMM.CHRG'
        Y.CALL.TYPE = 4
        GOSUB GET.CCY.MKT:
        YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.CR..SUS>:'.':Y.CALL.CCY.MKT
        GOSUB RAISE.CONSOL.ENTRIES
    END
*
* amortised fees
*
    IF YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV> <> "" THEN
        YNO.OF.AMORT.FEES = COUNT(YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV>,VM) + 1
        FOR YFEE.NO = 1 TO YNO.OF.AMORT.FEES
            YAMT.AMORTISED = YLMM.ACC.BAL.REC<LD27.FEE.PAID.IN.ADV,YFEE.NO> - ((YLMM.ACC.BAL.REC<LD27.ORIGIN.AMOR.MTH,YFEE.NO> - YLMM.ACC.BAL.REC<LD27.NO.OF.MTHS.LEFT,YFEE.NO>) * YLMM.ACC.BAL.REC<LD27.MTHLY.AMORT.AMT,YFEE.NO>)
            IF YAMT.AMORTISED THEN
                YH.AMOUNT = YAMT.AMORTISED
                YH.CHRG.CODE = YLMM.ACC.BAL.REC<LD27.CHRGS.CODE,YFEE.NO>
                LOCATE YH.CHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YH.CHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YH.TYPE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>
                GOSUB RAISE.CONSOL.ENTRIES
            END
        NEXT YFEE.NO
    END
*
* for charges due
*
    IF YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE> <> "" THEN
        YNO.OF.CHARGES = COUNT(YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE>,VM) + 1
        FOR YCHRG.NO = 1 TO YNO.OF.CHARGES
            YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.CHRGS.AMT.DUE,YCHRG.NO> + YLMM.ACC.BAL.REC<LD27.AMT.REC,YCHRG.NO>
            IF YH.AMOUNT THEN
                YH.CHRG.CODE = YLMM.ACC.BAL.REC<LD27.CHRG.CODE,YCHRG.NO>
                LOCATE YH.CHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YH.CHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YH.TYPE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>:"SP"
                GOSUB RAISE.CONSOL.ENTRIES
            END
        NEXT YCHRG.NO
    END
*
* for fees due
*
    IF YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE> <> "" THEN
        YNO.OF.FEES = COUNT(YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE>,VM) + 1
        FOR YFEE.NO = 1 TO YNO.OF.FEES
            YH.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.FEE.DUE,YFEE.NO> + YLMM.ACC.BAL.REC<LD27.CUM.FEE.REC,YFEE.NO>
            IF YH.AMOUNT THEN
                YCHRG.CODE = YLMM.ACC.BAL.REC<LD27.FEE.CHRG.CODE,YFEE.NO>
                LOCATE YCHRG.CODE IN AVAIL.CHRG.CODES<1,1> BY 'AR' SETTING YCHRG.LOC
                ELSE
                    E ="LD.RTN.MISSING":FM:YCHRG.CODE:VM:YFN.LMM.CHARGE.CONDITIONS
                    GOTO FATAL.ERROR
                END
                YH.TYPE = AVAIL.NEW.CHRG.CATEG.CODES<1,YCHRG.LOC>:"SP"
                GOSUB RAISE.CONSOL.ENTRIES
            END
        NEXT YFEE.NO
    END
* process With Holding Tax amts
*
PROCESS.BAL.INT.CHANGE.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
PROCESS.BAL.SCHD.CHANGE:
*-----------------------
*
* raise entries only for principal balances
*------------------------------------------------------------------------
*
    YCOUNT.AV = COUNT(YLMM.ACC.BAL.REC<LD27.DATE.FROM>,VM)+1
    YAV = YCOUNT.AV
    LOOP
        IF YAV <> 0 THEN YDATE = YLMM.ACC.BAL.REC<LD27.DATE.FROM,YAV>
    UNTIL YDATE < TODAY OR YAV = 0 DO
        YAV -= 1
    REPEAT
*
    IF YAV <> 0 THEN
        Y.SCHD.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.FWD.PRINC,YAV> + 0
        IF Y.SCHD.AMOUNT <> 0 THEN
            IF Y.SCHD.AMOUNT > 0 THEN YH.TYPE = Y.FWD.CR.TYPE
            ELSE YH.TYPE = Y.FWD.DB.TYPE
* check whether contract belongs to commitment categs
            YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
            IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
                YH.TYPE = Y.FWD.COMMITMENT.TYPE
            END
            GOSUB RAISE.INT.ENTRIES
        END
*
        Y.SCHD.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.CURR.PRINC,YAV> + 0
        IF Y.SCHD.AMOUNT <> 0 THEN
            IF Y.SCHD.AMOUNT > 0 THEN YH.TYPE = Y.CURR.CR.TYPE
            ELSE YH.TYPE = Y.CURR.DB.TYPE
* check whether contract belongs to commitment categs
            YCHECK.CATEG = Y.LD.REC(LD.CATEGORY)
            IF (YCHECK.CATEG >= 21095 AND YCHECK.CATEG <= 21099) OR (YCHECK.CATEG >= 21120 AND YCHECK.CATEG <= 21124) THEN
                YH.TYPE = Y.CURR.COMMITMENT.TYPE
            END
            GOSUB RAISE.INT.ENTRIES
        END
        Y.SCHD.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.OD.PRINC,YAV>
        IF Y.SCHD.AMOUNT THEN
            IF Y.SCHD.AMOUNT > 0 THEN YH.TYPE = Y.OD.CR.TYPE
            ELSE YH.TYPE = Y.OD.DB.TYPE
            GOSUB RAISE.INT.ENTRIES
        END
        Y.SCHD.AMOUNT = YLMM.ACC.BAL.REC<LD27.OUTS.PRINC.NAB,YAV>
        IF Y.SCHD.AMOUNT THEN
            IF Y.SCHD.AMOUNT > 0 THEN YH.TYPE = Y.NAB.CR.TYPE
            ELSE YH.TYPE = Y.NAB.DB.TYPE
            GOSUB RAISE.INT.ENTRIES
        END
    END
*
    RETURN
*
*------------------------------------------------------------------------
RAISE.CONSOL.ENTRIES:
*--------------------
    FOR YENT = 1 TO 2
        Y.PARAMS.CON = ""
        Y.PARAM.MAT.DATE = ""
        IF YENT = 1 THEN
            Y.PARAM.KEY = YKEY.CURR
            Y.KEY.TO.BE.REMOVED = YKEY
            Y.AMT.SIGN = -1
            IF Y.MAT.DATE.INCLUDED.IN.KEY THEN
                Y.PARAM.MAT.DATE = YCHANGE.MAT.DATE
            END
        END ELSE
            Y.PARAM.KEY = YKEY.NEW
            Y.KEY.TO.BE.REMOVED = ""
            Y.AMT.SIGN = 1
            IF Y.MAT.DATE.INCLUDED.IN.KEY THEN
                Y.PARAM.MAT.DATE = YMAT.DATE.NEW
            END
        END
*
        Y.PARAMS.CON<1> = Y.PARAM.KEY
        Y.PARAMS.CON<2> = FIELD(Y.PARAM.KEY,".",4)
        Y.PARAMS.CON<3> = YH.TYPE
        Y.CCY.MKT = FIELD(Y.PARAM.KEY,".",2)
        IF FIELD(YH.TYPE,'.',2) THEN
            Y.CCY.MKT = FIELD(YH.TYPE,'.',2)
        END
        Y.PARAM.AMT = YH.AMOUNT * Y.AMT.SIGN
*
        Y.LOCAL.EQ.AMT = ""
        YEXCHANGE.RATE = ""
        IF Y.PARAMS.CON<2> <> LCCY THEN
            IF YH.TYPE = Y.FWD.CR.TYPE OR YH.TYPE = Y.FWD.DB.TYPE OR YH.TYPE = Y.FWD.COMMITMENT.TYPE OR YH.TYPE = Y.CURR.COMMITMENT.TYPE THEN
                Y.LOCAL.EQ.AMT = YH.LCLAMT * Y.AMT.SIGN
                YEXCHANGE.RATE = YSTORED.RATE
            END ELSE
                Y.LOCAL.EQ.AMT = ""
                CALL MIDDLE.RATE.CONV.CHECK(Y.PARAM.AMT,Y.PARAMS.CON<2>,YEXCHANGE.RATE,Y.CCY.MKT,Y.LOCAL.EQ.AMT,"","")
                IF ETEXT <> "" THEN
                    E = Y.PARAM.KEY:" ":Y.PARAM.AMT:" CCY CONV ERR ":ETEXT
                    GOTO FATAL.ERROR
                END
            END
        END
*
        IF Y.PARAM.AMT > 0 THEN
            Y.PARAMS.CON<4> = ""
            Y.PARAMS.CON<5> = Y.PARAM.AMT
            Y.PARAMS.CON<6> = ""
            Y.PARAMS.CON<7> = Y.LOCAL.EQ.AMT
        END ELSE
            Y.PARAMS.CON<4> = Y.PARAM.AMT
            Y.PARAMS.CON<5> = ""
            Y.PARAMS.CON<6> = Y.LOCAL.EQ.AMT
            Y.PARAMS.CON<7> = ""
        END
        Y.PARAMS.CON<20> = YEXCHANGE.RATE
*
        IF YH.SCHD.AMOUNT <> 0 THEN
            Y.PARAMS.CON<8> = Y.LD.REC(LD.VALUE.DATE)
            Y.PARAMS.CON<9> = Y.LD.REC(LD.FIN.MAT.DATE)
            Y.PARAMS.CON<10> = ""
            Y.PARAMS.CON<11> = ""
            Y.PARAMS.CON<12> = Y.LD.REC(LD.INTEREST.KEY)
            Y.PARAMS.CON<13> = Y.LD.REC(LD.INTEREST.SPREAD)
            Y.PARAMS.CON<14> = YH.SCHD.AMOUNT * Y.AMT.SIGN
        END
*
        Y.PARAMS.CON<15> = YKEY
        Y.PARAMS.CON<16> = Y.KEY.TO.BE.REMOVED
        Y.PARAMS.CON<17> = "LD.CONSOL.KEY"
        Y.PARAMS.CON<18> = Y.LD.REC(LD.CUSTOMER.ID)
        Y.PARAMS.CON<19> = YSPL.ENT.TXN.REF.APP
        Y.PARAMS.CON<21> = Y.LD.REC(LD.DEPT.CODE)
        Y.PARAMS.CON<22> = Y.LD.REC(LD.CATEGORY)
        CALL RE.CONSOL.UPDATE(Y.PARAMS.CON,"ASSET&LIAB","")
    NEXT YENT
*
    RETURN
*
*------------------------------------------------------------------------
RESET.UNCHANGED.SCHD.FLDS:
*--------------------------
    IF YCHANGE.VALUE.DATE = "_" THEN
        YCHANGE.VALUE.DATE = Y.LD.REC(LD.VALUE.DATE)
    END
    IF YCHANGE.MAT.DATE = "_" THEN
        YCHANGE.MAT.DATE = Y.LD.REC(LD.FIN.MAT.DATE)
    END
    IF YCHANGE.INT.KEY = "_" THEN
        YCHANGE.INT.KEY = Y.LD.REC(LD.INTEREST.KEY)
    END
    IF YCHANGE.INT.SPREAD = "_" THEN
        YCHANGE.INT.SPREAD = Y.LD.REC(LD.INTEREST.SPREAD)
    END
*
    RETURN
*
*------------------------------------------------------------------------
RAISE.INT.ENTRIES:
*-----------------
    Y.PARAMS.CON = ""
    IF YKEY.FIELD.CHANGED THEN
        Y.PARAM.KEY = YKEY.CURR
        Y.PARAM.MAT.DATE = YCHANGE.MAT.DATE
    END ELSE
        Y.PARAM.KEY = YKEY.NEW
        Y.PARAM.MAT.DATE = YMAT.DATE.NEW
    END
    Y.PARAMS.CON<1> = Y.PARAM.KEY
    Y.PARAMS.CON<2> = FIELD(Y.PARAM.KEY,".",4)
    Y.PARAMS.CON<3> = YH.TYPE
    Y.PARAMS.CON<15> = ""
    Y.PARAMS.CON<17> = YKEY
    Y.PARAMS.CON<18> = Y.LD.REC(LD.CUSTOMER.ID)
    Y.PARAMS.CON<19> = 'SCH'
    Y.PARAMS.CON<20> = ""
    Y.PARAMS.CON<21> = Y.LD.REC(LD.DEPT.CODE)
    Y.PARAMS.CON<22> = Y.LD.REC(LD.CATEGORY)
    Y.PARAMS.CON<8,1> = YCHANGE.VALUE.DATE
    Y.PARAMS.CON<9,1> = YCHANGE.MAT.DATE
    Y.PARAMS.CON<10,1> = ""
    Y.PARAMS.CON<11,1> = ""
    Y.PARAMS.CON<12,1> = YCHANGE.INT.KEY
    Y.PARAMS.CON<13,1> = YCHANGE.INT.SPREAD
    Y.PARAMS.CON<14,1> = Y.SCHD.AMOUNT * (-1)
    Y.PARAMS.CON<8,2> = Y.LD.REC(LD.VALUE.DATE)
    Y.PARAMS.CON<9,2> = Y.LD.REC(LD.FIN.MAT.DATE)
    Y.PARAMS.CON<10,2> = ""
    Y.PARAMS.CON<11,2> = ""
    Y.PARAMS.CON<12,2> = Y.LD.REC(LD.INTEREST.KEY)
    Y.PARAMS.CON<13,2> = Y.LD.REC(LD.INTEREST.SPREAD)
    Y.PARAMS.CON<14,2> = Y.SCHD.AMOUNT
    CALL RE.CONSOL.UPDATE(Y.PARAMS.CON,"ASSET&LIAB","")
*
    RETURN
*
*------------------------------------------------------------------------
READ.LD.FILES:
*-------------
*
    YKEY = YKEY.BAL[1,LEN(YKEY.BAL)-2]
* main contract
    Y.LD.REC.FOUND = 1
    MATREAD Y.LD.REC FROM F.LD.LOANS.AND.DEPOSITS,YKEY ELSE
        MAT Y.LD.REC = ""
        Y.LD.REC.FOUND = ""
    END
*
* For LD contracts reversed on the same day
*
    IF NOT(Y.LD.REC.FOUND) THEN
        GOSUB READ.LD.HIS.RECORD
    END
*
* read ACCBAL if not a reversed contract, for reversed contracts rec
* read in CHECK.ACCBAL.HIST
*
* LMM.ACCOUNT.BALANCES rec
*
    IF NOT(YREVERSED.CONTRACT) THEN
        READ YLMM.ACC.BAL.REC FROM F.LMM.ACCOUNT.BALANCES,YKEY.BAL
        ELSE
            E ="LD.RTN.CONTRACT.NO.MISSING":FM:YKEY.BAL:VM:YFN.LMM.ACCOUNT.BALANCES
            GOTO FATAL.ERROR
        END
    END ELSE
        IF YLMM.ACC.BAL.REC<81> <> "REVE" THEN
*
*  The record read from the HISTORY file must either be reversed
*  or CONTRACT STATUS must be 'WOF' or 'LIQ'
*
            IF Y.LD.REC(LD.STATUS) <> "WOF" AND Y.LD.REC(LD.STATUS) <> "LIQ" THEN
                E ="LD.RTN.CONTRACT.NO.INVALID.CONTRACT.STATUS":FM:YKEY
                GOTO FATAL.ERROR
            END
        END
        IF Y.LD.REC.FOUND THEN
            E ="LD.RTN.CONTRACT.FOUND.NOT.FOUND.ACC.BAL":FM:YKEY
            GOTO FATAL.ERROR
        END
    END
*
* read RE.LD.ACC.BAL rec
*
    READ YRE.LD.ACC.BAL.REC FROM F.RE.LD.ACC.BAL,YKEY.BAL
    ELSE
        YRE.LD.ACC.BAL.REC = ""
    END
*
*  read LMM.SCHEDULE.DATES rec
*
    READ YLMM.SCHEDULE.DATES.REC FROM F.LMM.SCHEDULE.DATES,YKEY
    ELSE
        YLMM.SCHEDULE.DATES.REC = ""
    END
*
    Y.CONTRACT.CCY.MKT = Y.LD.REC(LD.CURRENCY.MARKET)
    Y.TAX.CODE = Y.LD.REC(LD.W.H.TAX.RATE.KEY)
READ.LD.FILES.RETURN:
*
    RETURN
*
*------------------------------------------------------------------------
READ.LD.HIS.RECORD:
*------------------
    Y.LD.TEMP.REC = ""
    YHIS.NO = 1
    YREC.INDIC = 1
*
* Search history records in steps of 10 history nos. to locate the range
*
    LOOP
        YHIS.SNO = YHIS.NO * 10
        YHIS.KEY = YKEY:";":YHIS.SNO
        READ Y.LD.TEMP.REC FROM F.LD.LOANS.AND.DEPOSITS$HIS, YHIS.KEY ELSE
            Y.LD.TEMP.REC = ""
            YREC.INDIC = ""
        END
    UNTIL YREC.INDIC = "" DO
        YHIS.NO += 1
    REPEAT
*
* Now locate and read the last history record
*
    LOOP
        YREC.INDIC = ""
        YHIS.KEY = YKEY:";":YHIS.SNO
        Y.LD.TEMP.REC = ""
        READ Y.LD.TEMP.REC FROM F.LD.LOANS.AND.DEPOSITS$HIS, YHIS.KEY ELSE
            YREC.INDIC = 1
        END
        YHIS.SNO -= 1
    UNTIL YREC.INDIC = "" OR YHIS.SNO = 0 DO
    REPEAT
*
    IF YREC.INDIC = "" THEN
        MATPARSE Y.LD.REC FROM Y.LD.TEMP.REC,FM
    END ELSE
        E ="LD.RTN.CONTRACT.MISS.LD.LOANS.AND.DEPOSITS.FILE":FM:YKEY
        GOTO FATAL.ERROR
    END
    RETURN
*
*------------------------------------------------------------------------
READ.RE.LD.ACC.BAL:
*------------------
    READ YRE.LD.ACC.BAL.REC FROM F.RE.LD.ACC.BAL ,YKEY.BAL
    ELSE
        E ="LD.RTN.MISSING":FM:YID.RE.LD.ACC.BAL:VM:YFN.RE.LD.ACC.BAL
        GOTO FATAL.ERROR
    END
*
    RETURN
*
*------------------------------------------------------------------------
WRITE.RE.LD.ACC.BAL:
*-------------------
    WRITE YRE.LD.ACC.BAL.REC TO F.RE.LD.ACC.BAL,YKEY.BAL
*
    RETURN
*
*------------------------------------------------------------------------
DELETE.RE.LD.ACC.BAL:
*--------------------
*
    DELETE F.RE.LD.ACC.BAL,YKEY.BAL
*
*------------------------------------------------------------------------
WRITE.RE.LD.CHARGE.COND:
*-----------------------
    WRITE YRE.LD.CHARGE.COND.REC TO F.RE.LD.CHARGE.COND,YID.RE.LD.CHARGE.COND
*
    RETURN
*
*------------------------------------------------------------------------
*
READ.LMM.INSTALL.CONDS:
*----------------------
* Record Key to be used here is '1'
*
*
* Todays install conds
*
    READ Y.INSTL.REC FROM F.LMM.INSTALL.CONDS,"1" ELSE
        E = "LD.RTN.1.MISSING.KEY":FM:"1":VM:YFN.LMM.INSTALL.CONDS
        GOTO FATAL.ERROR
    END
*
* Previous days install conds
*
    READ YPREV.INSTALL.REC FROM F.RE.LMM.INSTALL.CONDS , "1"
    ELSE
        YPREV.INSTALL.REC = ""
    END
    RETURN
*
*------------------------------------------------------------------------
READ.RE.LD.CHARGE.COND:
*----------------------
    READ YRE.LD.CHARGE.COND.REC FROM F.RE.LD.CHARGE.COND,YID.RE.LD.CHARGE.COND
    ELSE
        YRE.LD.CHARGE.COND.REC = ""
    END
*
    RETURN
*
*------------------------------------------------------------------------
READ.LMM.CHARGE.CONDITIONS:
*--------------------------
*
    READ YCHARGE.COND.REC FROM F.LMM.CHARGE.CONDITIONS,YID.LMM.CHARGE.CONDITIONS
    ELSE
        E ="LD.RTN.CHARGE.COND.MISSING":FM:YID.LMM.CHARGE.CONDITIONS:VM:YFN.LMM.CHARGE.CONDITIONS
        GOTO FATAL.ERROR
    END
*
    RETURN
*
*************************************************************************
*
READ.LMM.SCHEDULES.PAST:
*-----------------------
    READ YLMM.SCHEDULES.PAST.REC FROM F.LMM.SCHEDULES.PAST,YID.LMM.SCHEDULES.PAST ELSE YLMM.SCHEDULES.PAST.REC = ""
    RETURN
***
*------------------------------------------------------------------------
READ.SCHEDULES.PAST.HIST:
*-----------------------
    READ YLMM.SCHEDULES.PAST.REC FROM F.LMM.SCHEDULES.PAST.HIST,YID.HIST.LMM.SCHEDULES.PAST ELSE YLMM.SCHEDULES.PAST.REC = ""
    RETURN
***
*------------------------------------------------------------------------
CHECK.OTS.ACCRUALS:
*==================
** Check that the last value in the accruals field is zero, or null
** if not we cannot clear the consol key
*
    ACCRUALS.PRESENT = ""
    FOR YI = LD27.OUTS.ACCRUED.INT TO LD27.COM.REC.IN.ADV
        YCNT = DCOUNT(YLMM.ACC.BAL.REC<YI>,VM)
        IF YLMM.ACC.BAL.REC<YI,YCNT>+0 NE 0 THEN ACCRUALS.PRESENT = 1
    UNTIL ACCRUALS.PRESENT    ;* No sense in continuing
    NEXT YI
*
    FOR YI = LD27.OUTS.INT.ON.NAB TO LD27.FEE.PAID.IN.ADV
        YCNT = DCOUNT(YLMM.ACC.BAL.REC<YI>,VM)
        IF YLMM.ACC.BAL.REC<YI,YCNT>+0 NE 0 THEN ACCRUALS.PRESENT = 1
    UNTIL ACCRUALS.PRESENT
    NEXT YI
*
    RETURN
*
*------------------------------------------------------------------------
FATAL.ERROR:
*-----------
    TEXT = E ; CALL FATAL.ERROR("CONV.RE.LD.BAL.MOVE")
*
*************************************************************************
************************** END ******************************************
*************************************************************************
END
