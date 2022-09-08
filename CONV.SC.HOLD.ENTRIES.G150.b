* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>1954</Rating>
*-----------------------------------------------------------------------------
* Routine to raise real entries from SC.HOLD.ENTRIES as SC.HOLD.ENTRIES
* is no longer used after G150 Conversion.

*------------------------------------------------------------------------
* 21/07/04 - BG_100006967
*            BG for the EN_10002167.Remove F Entries for those transaction
*            for which Real Entries are raised.
*
* 02/09/04 - BG_100007172
*            Entries were not raised properly.
*
* 01/02/05 - CI_10026854
*            Override Message while running Conversion.
*
* 25/11/05 - CI_10036910
*            Fatal error for redemption contracts
*
*
* 21/12/05 - CI_10037516
*            Stop reversal entries for transactions that were input today
*
* 14/03/06 - GLOBUS_CI_10039717
*            Replace EXECUTE SELECT with EB.READLIST
*
*
* 23/03/06 - GLOBUS_CI_10039951
*
*            Reversal of F entry does not happen correctly on running.
*
* 17/04/06 - GLOBUS_EN_10002900
*            SC Parameter records to be read using EB.READ.PARAMETER
*
* 17/05/07 - CI_10049128
*            COB crashed after running  CONV.SC.HOLD.ENTRIES.
*
* 10/06/08 - CI_10055950
*            Conversion should be applied when R.ACCT.PASSED<I> has value
*
* 16/06/08 - CI_10055977
*            CONV.SC.HOLD.ENTRIES.G150 is raising invalid entries
*
* 15/09/14 - Defect:1108468 Task:1113128
*            EB.EOD.ERROR in CONV.SC.HOLD.ENTRIES.G150
*------------------------------------------------------------------------

*------------------------------------------------------------
    $PACKAGE SC.SctSettlement
    SUBROUTINE CONV.SC.HOLD.ENTRIES.G150
*------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.COMPANY
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT
    $INSERT I_F.SC.STD.SEC.TRADE
    $INSERT I_F.USER
    $INSERT I_F.SC.ENT.TODAY
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SECURITY.TRANSFER
    $INSERT I_F.DIARY
    $INSERT I_F.SC.PARAMETER
    $INSERT I_F.ENTITLEMENT
*
    SEL.CMD = 'SELECT F.SC.PARAMETER'
    SEL.PARAM.LIST = '' ; SEL.ERR = '' ; SEL.NOS = ''
    CALL EB.READLIST(SEL.CMD, SEL.PARAM.LIST, '',SEL.NOS,SEL.ERR)

    SAVE.COMPANY = ID.COMPANY

    LOOP
        REMOVE SC.PARAM.ID FROM SEL.PARAM.LIST SETTING SEL.POS
    WHILE SC.PARAM.ID:SEL.POS DO
        IF SAVE.COMPANY NE SC.PARAM.ID THEN
            CALL LOAD.COMPANY(SC.PARAM.ID)
        END
        GOSUB INITIALISE

        GOSUB CHECK.VD.ACCTNG

        IF NOT(VD.SYS) THEN
            RETURN
        END
        GOSUB PROCESS
        IF SAVE.COMPANY NE SC.PARAM.ID THEN
            CALL LOAD.COMPANY(SAVE.COMPANY)
        END

    REPEAT

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*------

    CMD = 'SSELECT ':SETTL.DATE.FILE
    SETTL.DATE.CONTROL.LIST = '' ; SELECTED = '' ; SYS.RET.CODE = ''
    CALL EB.READLIST(CMD, SETTL.DATE.CONTROL.LIST, '', SELECTED, SYS.RET.CODE)
*
    LOOP
        REMOVE K.SC.SETTL.DATE.CONTROL FROM SETTL.DATE.CONTROL.LIST SETTING DATE.POS
    WHILE K.SC.SETTL.DATE.CONTROL:DATE.POS DO
        *
        READ R.SC.SETTL.DATE.CONTROL FROM F.SC.SETTL.DATE.CONTROL,K.SC.SETTL.DATE.CONTROL ELSE
            E = 'RECORD & NOT FOUND ON FILE & ':FM:K.SC.SETTL.DATE.CONTROL:VM:'F.SC.SETTL.DATE.CONTROL'
            GOTO FATAL
        END
        *
        TRANS.REF.NOS = R.SC.SETTL.DATE.CONTROL<1>
        ID.RECORDS = R.SC.SETTL.DATE.CONTROL<2>
        ROUTINES = R.SC.SETTL.DATE.CONTROL<3>
        CRF.FLAGS = R.SC.SETTL.DATE.CONTROL<4>
        *
        PROC.RECS = ''
        J = 0
        R.MY.SETTL.DATE.CONTROL = ""
        LOOP UNTIL TRANS.REF.NOS = '' DO
            PROC.RECS = 1
            *
            TRANS.REF.NO = TRANS.REF.NOS<1,1>
            ID.NEW = ID.RECORDS<1,1>
            ROUTINE = ROUTINES<1,1>
            CRF.FLAG = CRF.FLAGS<1,1>

            TO.DATE = ''      ;*CI_10037516 -S
            TO.DATE = R.DATES(EB.DAT.JULIAN.DATE)[3,5]      ;*CI_10037516 -E
            *
            DEL TRANS.REF.NOS<1,1>
            DEL ROUTINES<1,1>
            DEL ID.RECORDS<1,1>
            DEL CRF.FLAGS<1,1>
            *
            F.NAME = 'F.':ROUTINE ; FILE.NAME = ''
            CALL OPF(F.NAME,FILE.NAME)
            *
            V$FUNCTION = 'DUMMY'
            MY.ROUTINE = ROUTINE
            CALL @MY.ROUTINE
            *
            MAT R.NEW = ""
            ER = '' ; RETRY = ''
            MATREADU R.NEW FROM FILE.NAME,ID.NEW ELSE
            E = 'RECORD & NOT FOUND ON FILE & ':FM:ID.NEW:VM:' ':F.NAME
            GOTO FATAL
        END

        BEGIN CASE
            CASE ROUTINE = "SEC.TRADE"
                SECURITY.CCY = R.NEW(SC.SBS.SECURITY.CURRENCY)
                FLAG.ACTUAL.SETTLEMENT = R.NEW(SC.SBS.CASH.HOLD.SETTLE)

            CASE ROUTINE = "SECURITY.TRANSFER"
                SECURITY.CCY = R.NEW(SC.STR.SECURITY.CCY)
                FLAG.ACTUAL.SETTLEMENT = R.NEW(SC.STR.CASH.HOLD.SETTLE)

            CASE ROUTINE = "DIARY"
                SECURITY.CCY = R.NEW(SC.DIA.CURRENCY)
                FLAG.ACTUAL.SETTLEMENT = R.NEW(SC.DIA.CASH.HOLD.SETTLE)

            CASE ROUTINE = "ENTITLEMENT"
                SECURITY.CCY = R.NEW(SC.ENT.CURRENCY)
                ID.DIARY = FIELD(ID.NEW,".",1)
                FLAG.ACTUAL.SETTLEMENT = ""
                CALL DBR("DIARY":FM:SC.DIA.CASH.HOLD.SETTLE,ID.DIARY,FLAG.ACTUAL.SETTLEMENT)

            CASE OTHERWISE
                SECURITY.CCY = ''
                FLAG.ACTUAL.SETTLEMENT = ''
        END CASE

        READ R.ACCT.PASSED FROM F.SC.HOLD.ENTRIES,TRANS.REF.NO ELSE
            R.ACCT.PASSED = ''
        END
        R.ACCT.PASSED.NEW = ''
        IF R.ACCT.PASSED THEN
            ENTRIES = COUNT(R.ACCT.PASSED,FM) + 1
            FOR I = 1 TO ENTRIES
                IF R.ACCT.PASSED<I> THEN
                    R.ACCT.PASSED<I,AC.STE.BOOKING.DATE> = R.DATES(EB.DAT.TODAY)
                    R.ACCT.PASSED.NEW<-1> = R.ACCT.PASSED<I>
                END
            NEXT I
            *
            IF NOT(R.NEW(V-9)) THEN
                CURR.NO = 0
            END ELSE
                CURR.NO = COUNT(R.NEW(V-9),VM)+1
            END
            CURR.NO = CURR.NO + 1
            IF FLAG.ACTUAL.SETTLEMENT NE 'YES' THEN
                *
                * CI10039951 -S
                SAVE.ID.NEW = ID.NEW
                ID.NEW = TRANS.REF.NO
                * CI10039951 -E
                *
                CALL.TYPE = 'REV.AUT':FM:'STORE.OVERRIDES'        ;* CI_10026854/S/E
                CALL EB.ACCOUNTING('SC',CALL.TYPE,'','1')
                ID.NEW = SAVE.ID.NEW          ;*CI10039951 -S/E
            END
            *
            IF R.SC.PARAMETER<SC.PARAM.CG.BASE.UPDATE> = "YES" OR R.SC.PARAMETER<SC.PARAM.CG.BASE.UPDATE> = "RULES" THEN
                GOSUB CGT.PROCESSING
            END

            MATWRITE R.NEW TO FILE.NAME,ID.NEW
            *
            DELETE F.SC.HOLD.ENTRIES,TRANS.REF.NO
        END ELSE RELEASE FILE.NAME,ID.NEW
            *
            R.CONSOL.ENTRIES = ''
            IF R.SC.STD.SEC.TRADE<SC.SST.CRF.POST> = 'Y' AND CRF.FLAG THEN
                *

                READ R.SC.CONSOL.ENTRIES FROM F.SC.CONSOL.ENTRIES,TRANS.REF.NO ELSE
                    E = 'RECORD & NOT FOUND ON FILE & ':FM:TRANS.REF.NO:VM:'F.SC.CONSOL.ENTRIES'
                    GOSUB LOG.EXCEPTION
                    R.SC.CONSOL.ENTRIES = ''
                END
                COUNT.POSNS = COUNT(R.SC.CONSOL.ENTRIES<1>,VM) + (R.SC.CONSOL.ENTRIES<1> # '')
                FOR X = 1 TO COUNT.POSNS
                    POSN.KEY = R.SC.CONSOL.ENTRIES<1,X>
                    IF POSN.KEY THEN
                        READU R.SC.ENT.TODAY FROM F.SC.ENT.TODAY,POSN.KEY ELSE R.SC.ENT.TODAY = ''
                        ETEXT = ''
                        MATURITY.DATE = ''
                        SECURITY.MASTER.ID = FIELD(POSN.KEY,'.',2)
                        CALL DBR('SECURITY.MASTER':FM:SC.SCM.MATURITY.DATE,SECURITY.MASTER.ID,MATURITY.DATE)
                        IF MATURITY.DATE = '' THEN
                            MATURITY.DATE = '0'
                        END
                        *
                        LAST.POS = COUNT(R.SC.ENT.TODAY<1>,VM) + (R.SC.ENT.TODAY<1> # '')
                        VALUE.DATE = FIELD(K.SC.SETTL.DATE.CONTROL,'*',1)
                        TRANS.CODE = R.SC.CONSOL.ENTRIES<8,X>

                        CONSOL.TYPE = 'FORWARDLIVE'
                        ACCRUAL.TYPE = ''
                        R.SC.ENT.TODAY<SC.ENTTD.TRANS.REF,LAST.POS+1> = TRANS.REF.NO
                        R.SC.ENT.TODAY<SC.ENTTD.ID.RECORD,LAST.POS+1> = ID.NEW
                        R.SC.ENT.TODAY<SC.ENTTD.TRANS.TYPE,LAST.POS+1> = CONSOL.TYPE
                        R.SC.ENT.TODAY<SC.ENTTD.TRANS.CODE,LAST.POS+1> = TRANS.CODE
                        R.SC.ENT.TODAY<SC.ENTTD.ACCRUAL.TYPE,LAST.POS+1> = ACCRUAL.TYPE
                        R.SC.ENT.TODAY<SC.ENTTD.VALUE.DATE,LAST.POS+1> = TODAY
                        R.SC.ENT.TODAY<SC.ENTTD.REVERSAL.FLAG,LAST.POS+1> = 'R'
                        R.SC.ENT.TODAY<SC.ENTTD.MATURITY.DATE,LAST.POS+1> = MATURITY.DATE
                        IF TRANS.REF.NO[7,5] NE TO.DATE THEN          ;*CI_10037516 -S/E
                            REVERSAL.ENTRY = 'R'
                            GOSUB RAISE.CONSOL.ENTRIES
                            IF CONSOL.ENTRY THEN
                                R.CONSOL.ENTRIES<-1> = CONSOL.ENTRY
                            END
                        END   ;*CI_10037516 -S/E


                        ACCRUAL.TYPE = ''
                        CONSOL.TYPE = 'LIVE'
                        IF R.SC.CONSOL.ENTRIES<5> THEN
                            ACCRUAL.TYPE = 'IENC'
                        END
                        IF R.SC.CONSOL.ENTRIES<15> THEN
                            ACCRUAL.TYPE<1,2> = "CIENC"
                        END
                        R.SC.ENT.TODAY<SC.ENTTD.TRANS.REF,LAST.POS+2> = TRANS.REF.NO
                        R.SC.ENT.TODAY<SC.ENTTD.ID.RECORD,LAST.POS+2> = ID.NEW
                        R.SC.ENT.TODAY<SC.ENTTD.TRANS.TYPE,LAST.POS+2> = CONSOL.TYPE
                        R.SC.ENT.TODAY<SC.ENTTD.TRANS.CODE,LAST.POS+2> = TRANS.CODE
                        R.SC.ENT.TODAY<SC.ENTTD.ACCRUAL.TYPE,LAST.POS+2> = ACCRUAL.TYPE
                        R.SC.ENT.TODAY<SC.ENTTD.VALUE.DATE,LAST.POS+2> = VALUE.DATE
                        R.SC.ENT.TODAY<SC.ENTTD.REVERSAL.FLAG,LAST.POS+2> = ''
                        R.SC.ENT.TODAY<SC.ENTTD.MATURITY.DATE,LAST.POS+2> = MATURITY.DATE
                        *
                        REVERSAL.ENTRY = ''
                        GOSUB RAISE.CONSOL.ENTRIES
                        IF CONSOL.ENTRY THEN
                            R.CONSOL.ENTRIES<-1> = CONSOL.ENTRY
                        END
                        WRITE R.SC.ENT.TODAY TO F.SC.ENT.TODAY,POSN.KEY
                    END
                NEXT X
            END
            *If the R.CONSOL.ENTRIES and R.ACCT.PASSED.NEW both has value,then add both the entries and passed it to EB.ACCOUNTING.
            IF R.CONSOL.ENTRIES AND R.ACCT.PASSED.NEW THEN
                R.CONSOL.ENTRIES<-1> = R.ACCT.PASSED.NEW
            END
            *If the R.ACCT.PASSED.NEW has value and R.CONSOL.ENTRIES doesnt have value,then pass only R.ACCT.PASSED.NEW to EB.ACCOUNTING
            IF R.ACCT.PASSED.NEW AND R.CONSOL.ENTRIES EQ '' THEN
                R.CONSOL.ENTRIES = R.ACCT.PASSED.NEW
            END
            IF R.CONSOL.ENTRIES THEN
                CALL EB.ACCOUNTING('SC','SAO',R.CONSOL.ENTRIES,'')
            END
            CALL JOURNAL.UPDATE(ID.NEW)
        REPEAT

    REPEAT

*
*------------
*  END OF JOB
*------------
*
    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*---------
    F.SC.SETTL.DATE.CONTROL = '' ; SETTL.DATE.FILE = 'F.SC.SETTL.DATE.CONTROL'
    CALL OPF(SETTL.DATE.FILE,F.SC.SETTL.DATE.CONTROL)
    F.SC.HOLD.ENTRIES = ''
    CALL OPF('F.SC.HOLD.ENTRIES',F.SC.HOLD.ENTRIES)
    FN.SC.STD.SEC.TRADE = 'F.SC.STD.SEC.TRADE'
    F.SC.STD.SEC.TRADE = ''
    CALL OPF(FN.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE)
    F.SC.ENT.TODAY = ''
    CALL OPF('F.SC.ENT.TODAY',F.SC.ENT.TODAY)
    F.SC.CONSOL.ENTRIES = ''
    CALL OPF('F.SC.CONSOL.ENTRIES',F.SC.CONSOL.ENTRIES)
    F.SECURITY.MASTER = ''
    CALL OPF('F.SECURITY.MASTER',F.SECURITY.MASTER)

    FN.SC.PARAMETER = 'F.SC.PARAMETER'
    F.SC.PARAMETER = ''
    CALL OPF(FN.SC.PARAMETER,F.SC.PARAMETER)

    R.SC.PARAMETER = ''
    YERR = ''
    CALL EB.READ.PARAMETER(FN.SC.PARAMETER,'N','',R.SC.PARAMETER,'',F.SC.PARAMETER,YERR)
*
* SET UP VARIABLES (ALBEIT BLANK) TO PASS THRU TO ACCOUNTING ROUTINE
*
    PARAM.ERR = ''
    CALL EB.READ.PARAMETER(FN.SC.STD.SEC.TRADE,'N','',R.SC.STD.SEC.TRADE,'',F.SC.STD.SEC.TRADE,PARAM.ERR)
    IF PARAM.ERR THEN
        E = 'RECORD & NOT FOUND ON FILE & ':FM:ID.COMPANY:VM:' F.SC.STD.SEC.TRADE'
        GOTO FATAL
    END

    RETURN
*
**********************************
* UPDATE EXCEPTION LOG FILE
**********************************
LOG.EXCEPTION:
    FKEY = TRANS.REF.NO
    FNAME = 'SC.CONSOL.ENTRIES'
    MESS = E
    TYPE = 'S'
    APP = 'SC'
    ROUTINE = 'SC.SETT.DATE.ACCTG'
    MODULE = 'SC.SETT.DATE.ACCTG'
    CODE = '920'
    VALUE = ''
    CURR.NO = '1'
    DEPT = R.USER<EB.USE.DEPARTMENT.CODE>
    CALL EXCEPTION.LOG(TYPE,APP,ROUTINE,MODULE,CODE,VALUE,FNAME,FKEY,CURR.NO,MESS,DEPT)
    E = ''
    RETURN

*-----------------------------------------------------------------------------
CGT.PROCESSING:
* New subr BG_100002797
* update CG.TXN.BASE with STMT.ENTRY ids

    YAPPL = ROUTINE
    MATBUILD YR.NEW FROM R.NEW

    YCLIENT.NOS = "" ; YSTMT.NOS = ""
    CALL SC.GET.CGT.STMT.ENTRY.IDS(YAPPL,YR.NEW,YCLIENT.NOS,YSTMT.NOS)

    BEGIN CASE
        CASE ROUTINE = 'SEC.TRADE'
            YSECURITY.NO = R.NEW(SC.SBS.SECURITY.CODE)

        CASE ROUTINE = 'SECURITY.TRANSFER'
            YSECURITY.NO = R.NEW(SC.STR.SECURITY.NO)

        CASE ROUTINE = 'ENTITLEMENT'
            YSECURITY.NO = R.NEW(SC.ENT.SECURITY.NO)

        CASE 1
            YSECURITY.NO = ''

    END CASE
    CALL SC.CTB.UPDATE.STMT.NOS(YSECURITY.NO,YCLIENT.NOS,YSTMT.NOS)

    RETURN
*-----------------------------------------------------------------------------

*
RAISE.CONSOL.ENTRIES:

    SC.CONSOL.TODAY = ''
    SC.CONSOL.TODAY<1> = POSN.KEY
    SC.CONSOL.TODAY<2> = TRANS.REF.NO   ;* CI_10036910
    SC.CONSOL.TODAY<3> = TRANS.REF.NO   ;* CI_10036910
    SC.CONSOL.TODAY<4> = CONSOL.TYPE
    SC.CONSOL.TODAY<5> = TRANS.CODE
    SC.CONSOL.TODAY<6> = ACCRUAL.TYPE<1,1>
    IF REVERSAL.ENTRY THEN
        SC.CONSOL.TODAY<7> = TODAY
    END ELSE
        SC.CONSOL.TODAY<7> = VALUE.DATE
    END
    SC.CONSOL.TODAY<8> = REVERSAL.ENTRY
    SC.CONSOL.TODAY<9>= MATURITY.DATE
    SC.CONSOL.TODAY<10> = SECURITY.CCY
    SC.CONSOL.TODAY<11> = ACCRUAL.TYPE<1,2>
    CONSOL.ENTRY = ''
    CALL SC.TRADE.UPD.CONSOL(SC.CONSOL.TODAY,CONSOL.ENTRY)
*    CALL EB.ACCOUNTING('SC','SAO',CONSOL.ENTRY,'')

    RETURN

*-----------------------------------------------------------------------------
CHECK.VD.ACCTNG:
*--------------
* Check if 'SC' is value dated.

    SYS.ID = 'SC' ; VD.SYS = '' ; ANY.ID = ''
    CALL AC.VALUE.DATED.ACCTNG(SYS.ID,'','','',ANY.ID,VD.SYS)

    RETURN

*-----------------------------------------------------------------------------
FATAL:

    TEXT = E
    CALL FATAL.ERROR('SC.SETT.DATE.ACCTG')
    END
