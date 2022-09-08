* @ValidationCode : MjotMTAyMTk0NzQ4MzpDcDEyNTI6MTU0NTM5ODI2Mjc3NjpqcHJpeWFkaGFyc2hpbmk6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjAtMTcyNjo3NTk6MzYw
* @ValidationInfo : Timestamp         : 21 Dec 2018 18:47:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jpriyadharshini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 360/759 (47.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181020-1726
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>1220</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IC.ModelBank
SUBROUTINE E.MB.IC.RATE.CHANGE(ACCOUNT.NO, START.DATE, END.DATE, RATE.CHANGES, ER)
*
************************************************************************
* Description:
* ============
*            This routine is called from the conversion routines E.MB.IC.CR.BASIC, E.MB.IC.CR.MARGIN
*            E.MB.IC.DEB.BASIC, E.MB.IC.DEB.MARGIN attached to the enquiry ACC.CURRENT.INT. This routine
*            calculates the debit and credit interest changes of an account for the specified period.
*
************************************************************************
* Modification Log:
* =================
* 22/10/08 - BG_100019949
*            Routie Standardisation
*
* 09/08/10 - Defect 68450 / Task - 74689
*            Changed the delimiter to '#'.
**
* 30/03/11 - Defect 180346 / Task - 182188
*            Changes done to show minimum interest rate if
*            Basic.Interest rate is less than minimum rate
*
* 12/10/11 - Defect 288849 / Task - 290709
*            Changes done to show maximum interest rate if the
*            derived interest rate is greater than maximum rate.
*
* 16/02/12 - Defect 248715 / Task - 357262
*            Changes done to show the successive rate changes in BASIC.INTEREST correctly.
*
* 23/08/12 - Defect 466674 / Task 468534
*            Changes done to display negative interest rate when set in ACI record
*            and to process the Neg.int.rate of BASIC.INTEREST record.
*
* 06/02/15 - Enhancement 1193814 / Task 1235197
*            Negative rate process for debit interest
*
* 29/11/18 - Defect 2870349 / Task 2878864
*            When RATE.CHANGES array is built with Null Rate Values then , Enquiry displays
*            incorrect results. Assigned Zero to Null RATE Values.
*
* 03/12/18 - Enhancement 2804452 / Task 2866586
*            Replacing calls of AccountDebitlimit from IC.Config to AC.AccountOpening since AccountDebitlimit
*            is moved from IC to AC.
************************************************************************
*
    $USING AC.AccountOpening
    $USING IC.InterestAndCapitalisation
    $USING IC.Config
    $USING ST.RateParameters
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING IC.ModelBank
    $USING EB.SystemTables
    $INSERT I_DAS.BASIC.INTEREST

*
************************************************************************
*
* Main Control
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB BUILD.BASE.RATE.CHANGES
*
    IF PROGRAM.EXIT THEN
        RETURN
    END
*
** Process debit and credit conditions separately
*
    DATE.LIST = ''
    DR.CR = 'CR'
    SRCH.FLD = YAC.CREDIT.INT ; SRCH.LEVEL = 'AC'
    GOSUB GET.INITIAL.RATE
*
    SRCH.FLD = IC.InterestAndCapitalisation.GroupDate.AcGrdCreditDates ; SRCH.LEVEL = 'GR'
    GOSUB GET.INITIAL.RATE
*
    GOSUB REPLACE.AC.GR
    GOSUB PROCESS.DATES
    RC.DATES = ''
    RC.DATES<1> = LOWER(DATE.LIST)
*
    DATE.LIST = ''
    DR.CR = 'DR'
    SRCH.FLD = YAC.DEBIT.INT ; SRCH.LEVEL = 'AC'
    GOSUB GET.INITIAL.RATE
*
    SRCH.FLD = IC.InterestAndCapitalisation.GroupDate.AcGrdDebitDates ; SRCH.LEVEL = 'GR'
    GOSUB GET.INITIAL.RATE
*
    GOSUB REPLACE.AC.GR
    GOSUB PROCESS.DATES
    RC.DATES<2> = LOWER(DATE.LIST)
*
** Return only the rates required for the period if 2 dates are supplied, or the
** current rates if only 1 date is supplied
*
    IF NOT(GET.RATE.ONLY) THEN
        GOSUB RETURN.RELEVANT.DATES
    END ELSE
*
** If rate only reqd. then look in the rate change array and pass only the
** last date.
*
        GOSUB PROCESS.GET.RATE.ONLY
    END
    RATE.CHANGES = RATE.CHANGES:'#':RC.DATES


RETURN
*
************************************************************************
*      SUBROUTINES
************************************************************************
*
INITIALISE:
*==========
*
    IC.RC.DATE = 1
    IC.RC.CREDIT.RATE.TYPE = 2
    IC.RC.CREDIT.BAND.UPTO = 3
    IC.RC.CREDIT.BAND.RATE = 4
    IC.RC.DEBIT.RATE.TYPE = 5
    IC.RC.DEBIT.BAND.UPTO = 6
    IC.RC.DEBIT.BAND.RATE = 7
    IC.RC.CREDIT2.RATE.TYPE = 8
    IC.RC.CREDIT2.BAND.UPTO = 9
    IC.RC.CREDIT2.BAND.RATE = 10
    IC.RC.DEBIT2.RATE.TYPE = 11
    IC.RC.DEBIT2.BAND.UPTO = 12
    IC.RC.DEBIT2.BAND.RATE = 13
    BASIC.RATE = ''
    MARGIN.RATE = ''
*
    YAC.DEBIT.INT = 1
    YAC.CREDIT.INT = 2
    YAC.DEBIT.LIMIT = 3

    BAND.LEVEL.NO = 1
*
    DTE2=''
    INS.DTE=''
    R.RECORD = ''
    NDTE = 0
    RATE.CHANGES = ''
    GET.RATE.ONLY = 0
    IF NOT(END.DATE) THEN
        GET.RATE.ONLY = 1
        IF NOT(START.DATE) THEN
            START.DATE = EB.SystemTables.getToday()
        END
        END.DATE = START.DATE
    END
*
    PROGRAM.EXIT = 0
    IF NOT(START.DATE) THEN
        PROGRAM.EXIT = 1
        RETURN
    END
*
*
RETURN
******************************
OPEN.FILES:

*
    FN.ACCOUNT.CREDIT.INT = 'F.ACCOUNT.CREDIT.INT'
    F.ACCOUNT.CREDIT.INT = ''
    
    FN.ACCOUNT.DEBIT.INT = 'F.ACCOUNT.DEBIT.INT'
    F.ACCOUNT.DEBIT.INT = ''
* Read ACCOUNT record and build GROUP.CCY key for GROUP.DATE file
*
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.NO, ER)
*
    GRP.CCY = R.ACCOUNT<AC.AccountOpening.Account.ConditionGroup>:R.ACCOUNT<AC.AccountOpening.Account.Currency>
    AC.CCY = R.ACCOUNT<AC.AccountOpening.Account.Currency>
*
    R.ACCOUNT.DATE = ''
    R.GROUP.DATE = ''
    R.GROUP.DATE = IC.InterestAndCapitalisation.GroupDate.Read(GRP.CCY, ER)

RETURN
*****************************
BUILD.BASE.RATE.CHANGES:
*
** Build an array of Basic Rate Chnages
** BRT<1,X> - Key CCY
** BRT<2,x,y> - Dates
** BRT<3,x,y> - Rates
*
    IF IC.ModelBank.getCBrtCo() AND IC.ModelBank.getCBrtCo() NE EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialCom) THEN
        IC.ModelBank.setCBrtCcy('')
        IC.ModelBank.setCBrt('')
    END
    C$BRT.CCY.VAL = IC.ModelBank.getCBrtCcy()
    LOCATE AC.CCY IN C$BRT.CCY.VAL<1> BY 'AR' SETTING CC.POS ELSE
        INS AC.CCY BEFORE C$BRT.CCY.VAL<CC.POS>
        IC.ModelBank.setCBrtCcy(C$BRT.CCY.VAL)
        IC.ModelBank.setCBrtCo(EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialCom))
        ID.LIST      = EB.DataAccess.DasAllIds
        THE.ARGS     = ''
        TABLE.SUFFIX = ''
        EB.DataAccess.Das('BASIC.INTEREST',ID.LIST,THE.ARGS,TABLE.SUFFIX)
        GOSUB BUILD.EACH.RATE
    END
RETURN
*****************************
BUILD.EACH.RATE:
    LOOP
        REMOVE BRT.ID FROM ID.LIST SETTING YD
    WHILE BRT.ID:YD
        BDATE = BRT.ID[(LEN(BRT.ID)-8)+1,8]
        NOCCY = BRT.ID[1,LEN(BRT.ID)-8]
        IF AC.CCY = NOCCY[3] THEN
            C$BRT.VAL = IC.ModelBank.getCBrt()
            LOCATE NOCCY IN C$BRT.VAL<1,1> SETTING BPOS ELSE
                INS NOCCY BEFORE C$BRT.VAL<1,BPOS>
                IC.ModelBank.setCBrt(C$BRT.VAL)
            END
            C$BRT.VAL = IC.ModelBank.getCBrt()
            LOCATE BDATE IN C$BRT.VAL<2,BPOS,1> BY 'AR' SETTING BDPOS ELSE
                INS BDATE BEFORE C$BRT.VAL<2,BPOS,BDPOS>
                INS '' BEFORE C$BRT.VAL<3,BPOS,BDPOS>
                IC.ModelBank.setCBrt(C$BRT.VAL)
            END
        END
    REPEAT
RETURN
*
*------------------------------------------------------------------------
GET.INITIAL.RATE:
*================
** Find the applicable rate prior to the start date
*
    IF SRCH.LEVEL = 'AC' THEN
        R.ACCOUNT.DATE<YAC.DEBIT.INT> = R.ACCOUNT<AC.AccountOpening.Account.AcctDebitInt>
        R.ACCOUNT.DATE<YAC.CREDIT.INT> = R.ACCOUNT<AC.AccountOpening.Account.AcctCreditInt>
        R.ACCOUNT.DATE<YAC.DEBIT.LIMIT> = R.ACCOUNT<AC.AccountOpening.Account.AccDebLimit>

        DATE.REC = R.ACCOUNT.DATE
    END ELSE
        DATE.REC = R.GROUP.DATE
    END
*
** Look for the date before the start date
*
    IF DATE.REC = '' THEN
        RETURN
    END
    SRCH.DATE = START.DATE ;
*
** Build the date list for all dates up to the end date
** layout
**  1,x   - Record date
**  2,x   - grp or ac
*
    DPOS = 1        ;* Build up a list of all effective dates
    LOOP
    UNTIL DATE.REC<SRCH.FLD,DPOS> = ''
        IF DATE.REC<SRCH.FLD,DPOS> LE END.DATE THEN
            GOSUB INITIAL.RATE
        END
*
        DPOS += 1   ;* Go for next date
    REPEAT
*
** Therefore at the end of this we should have a list of all the rate changes
** in the given search level.
*
RETURN
*
*----------------------------------------------------------------------
INITIAL.RATE:

    R.CHK.FILE = ''
    LOCATE DATE.REC<SRCH.FLD,DPOS> IN DATE.LIST<1,1> BY 'AR' SETTING DPOS2 THEN
        NULL
    END

* If previous position is 'AC' then Group level is not valid. So, dont insert it.
* Insert 'GR' if the previous position is 'GR' or 'AC-GR'

    IF SRCH.LEVEL = 'GR' THEN
        IF (DPOS2 EQ 1) OR (DATE.LIST<2,DPOS2-1> NE 'AC') THEN

            INS DATE.REC<SRCH.FLD,DPOS> BEFORE DATE.LIST<1,DPOS2>
            INS SRCH.LEVEL BEFORE DATE.LIST<2,DPOS2>
        END
    END ELSE
        BEGIN CASE
            CASE  DR.CR = 'DR'
                FN.CHK.FILE = FN.ACCOUNT.DEBIT.INT
                F.CHK.FILE = F.ACCOUNT.DEBIT.INT
                BASIS.FLD = IC.Config.AccountDebitInt.AdiInterestDayBasis
            CASE 1
                FN.CHK.FILE = FN.ACCOUNT.CREDIT.INT
                F.CHK.FILE = F.ACCOUNT.CREDIT.INT
                BASIS.FLD = IC.Config.AccountCreditInt.AciInterestDayBasis
        END CASE
        REC.ID = ACCOUNT.NO:'-':DATE.REC<SRCH.FLD,DPOS>
        EB.DataAccess.FRead(FN.CHK.FILE, REC.ID, R.CHK.FILE, F.CHK.FILE,ERR)
        BASIS = R.CHK.FILE<BASIS.FLD>
        IF BASIS NE 'GENERAL' THEN
            DATE.LIST<2,DPOS2> = SRCH.LEVEL
        END ELSE
            DATE.LIST<2,DPOS2> = "AC-GR"          ;*Store it only as 'AC-GR' if the INTEREST.DAY.BASIS is 'GENERAL'
        END
        INS DATE.REC<SRCH.FLD,DPOS> BEFORE DATE.LIST<1,DPOS2>
    END
RETURN
*
*-------------------------------------------------------------------
REPLACE.AC.GR:
*************
    NO.DATES = DCOUNT(DATE.LIST<1>,@VM)
    FOR IND = 1 TO NO.DATES
        IF DATE.LIST<2,IND> EQ 'AC-GR' THEN
            DATE.LIST<2,IND> = 'AC'
        END
    NEXT IND

RETURN
*----------------------------------------------------------------------
PROCESS.DATES:
*
* Loop through period and retrieve any rate changes found in either
* ACCOUNT.CREDIT/DEBIT.INT or GROUP.CREDIT/DEBIT.INT
*
    LAST.ADI.STATUS = ""
    LAST.ACI.STATUS = ""
    OLD.GDI.DATE = ""
    OLD.GCI.DATE = ""
    NO.DATES = DCOUNT(DATE.LIST<1>,@VM)
    FOR IND = 1 TO NO.DATES
        GOSUB PROCESS.DATE
    NEXT IND
*
RETURN
*
*----------------------------------------------------------------------------
PROCESS.DATE:
*
** See if the record is AC or GR
*
    DTE = DATE.LIST<1,IND>
    TYPE = DATE.LIST<2,IND>
    NEXT.DATE = DATE.LIST<1,IND+1>
    IF NEXT.DATE = '' THEN
        NEXT.DATE = END.DATE
    END
*
    BEGIN CASE
        CASE TYPE = 'AC'
            AI.ID = ACCOUNT.NO:'-':DTE
*
** Determine the next record change date, i.e. ignore the dates for
** the group
*
            NIND = IND
            LOOP
                NIND +=1
            UNTIL DATE.LIST<1,NIND> = '' OR DATE.LIST<2,NIND> = 'AC'
            REPEAT
            NEXT.DATE = DATE.LIST<1,NIND>
            IF NEXT.DATE = '' THEN
                NEXT.DATE = END.DATE
            END
*
            BEGIN CASE
                CASE DR.CR = 'CR'
                    LAST.ACI.STATUS = "AC"
                    GOSUB UPD.FROM.ACI
                CASE 1
                    LAST.ADI.STATUS = "AC"
                    GOSUB UPD.FROM.ADI
            END CASE
        CASE 1  ;* Need to cater for reverting back to group
            GI.ID = GRP.CCY:DTE
            BEGIN CASE
                CASE DR.CR = 'CR'
                    IF LAST.ACI.STATUS # "AC" THEN
                        GOSUB UPD.FROM.GCI
                    END
                CASE 1
                    IF LAST.ADI.STATUS # "AC" THEN
                        GOSUB UPD.FROM.GDI
                    END
            END CASE
    END CASE

RETURN

***************************************************************************
*
UPD.FROM.ADI:
*============
*
    ER = ''
    R.ACCOUNT.DEBIT.INT = IC.Config.AccountDebitInt.Read(AI.ID, ER)
    IF NOT(ER) AND R.ACCOUNT.DEBIT.INT<IC.Config.AccountDebitInt.AdiInterestDayBasis> NE 'GENERAL' THEN
        IF R.ACCOUNT.DEBIT.INT<IC.Config.AccountDebitInt.AdiInterestDayBasis> = 'NONE' THEN
            UPD.FLD = IC.RC.DEBIT.RATE.TYPE
            GOSUB UPD.RATE.TYPE.NONE
        END ELSE
            GOSUB ADI.RATE
        END
    END ELSE
        LAST.ADI.STATUS = 'GR'
        LOCATE DTE IN R.GROUP.DATE<IC.InterestAndCapitalisation.GroupDate.AcGrdDebitDates,1> BY 'AR' SETTING LAST.GDI.POS ELSE
            IF LAST.GDI.POS GT 1 THEN
                LAST.GDI.POS -= 1
            END
        END
        GI.ID = GRP.CCY:R.GROUP.DATE<IC.InterestAndCapitalisation.GroupDate.AcGrdDebitDates, LAST.GDI.POS>
        GOSUB UPD.FROM.GDI
    END
*
RETURN
*--------------------------------------------------------------------------
ADI.RATE:
*
* DR set of interest details
*
    NO.OF.BANDS = DCOUNT(R.ACCOUNT.DEBIT.INT<IC.Config.AccountDebitInt.AdiDrBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.ACCOUNT.DEBIT.INT<IC.Config.AccountDebitInt.AdiDrIntRate>, @VM)
    END
    R.RECORD = R.ACCOUNT.DEBIT.INT
    UPD.FLD = IC.RC.DEBIT.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.AccountDebitInt.AdiDrCalculType
    BASIC.RATE.FLD = IC.Config.AccountDebitInt.AdiDrBasicRate
    INT.RATE.FLD = IC.Config.AccountDebitInt.AdiDrIntRate
    MARGIN.OPER.FLD = IC.Config.AccountDebitInt.AdiDrMarginOper
    MIN.RATE.FLD = IC.Config.AccountDebitInt.AdiDrMinRate
    MAX.RATE.FLD = IC.Config.AccountDebitInt.AdiDrMaxRate
    MARGIN.RATE.FLD = IC.Config.AccountDebitInt.AdiDrMarginRate
    LIMIT.AMT.FLD = IC.Config.AccountDebitInt.AdiDrLimitAmt
    NEGATIVE.RATE = IC.Config.AccountDebitInt.AdiNegativeRates ;* Add Negative rate for ADI  DR interest process
    BAND.AMT.FLD = IC.RC.DEBIT.BAND.UPTO
    BAND.RATE.FLD = IC.RC.DEBIT.BAND.RATE
*
    IF NO.OF.BANDS = 1 AND R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = '' THEN
        R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = 0
    END

    RATE.BAND.CNT = 0
    GOSUB CLEAR.DATA.OVERLAPPING
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
        IF NO.OF.BANDS GT 1 THEN        ;* Only for Banded
            GOSUB UPD.FOR.DEBIT.LIMIT
        END
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES
*
* DR2 set of interest details
*
    NO.OF.BANDS = DCOUNT(R.ACCOUNT.DEBIT.INT<IC.Config.AccountDebitInt.AdiDrTwoBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.ACCOUNT.DEBIT.INT<IC.Config.AccountDebitInt.AdiDrTwoIntRate>, @VM)
    END
    R.RECORD = R.ACCOUNT.DEBIT.INT
    UPD.FLD = IC.RC.DEBIT2.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.AccountDebitInt.AdiDrTwoCalculType
    BASIC.RATE.FLD = IC.Config.AccountDebitInt.AdiDrTwoBasicRate
    INT.RATE.FLD = IC.Config.AccountDebitInt.AdiDrTwoIntRate
    MARGIN.OPER.FLD = IC.Config.AccountDebitInt.AdiDrTwoMarginOper
    MIN.RATE.FLD = IC.Config.AccountDebitInt.AdiDrTwoMinRate
    MAX.RATE.FLD = IC.Config.AccountDebitInt.AdiDrTwoMaxRate
    MARGIN.RATE.FLD = IC.Config.AccountDebitInt.AdiDrTwoMarginRate
    LIMIT.AMT.FLD = IC.Config.AccountDebitInt.AdiDrTwoLimitAmt
    BAND.AMT.FLD = IC.RC.DEBIT2.BAND.UPTO
    BAND.RATE.FLD = IC.RC.DEBIT2.BAND.RATE
*
    IF NO.OF.BANDS = 1 AND R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = '' THEN
        R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = 0
    END
    RATE.BAND.CNT = 0
    GOSUB CLEAR.DATA.OVERLAPPING
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
        IF NO.OF.BANDS GT 1 THEN        ;* Only for Banded
            GOSUB UPD.FOR.DEBIT.LIMIT
        END
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES

RETURN

***************************************************************************
*
UPD.FROM.ACI:
*============
*
    ER = ''
    R.ACCOUNT.CREDIT.INT = IC.Config.AccountCreditInt.Read(AI.ID, ER)
    IF NOT(ER) AND R.ACCOUNT.CREDIT.INT<IC.Config.AccountCreditInt.AciInterestDayBasis> NE 'GENERAL' THEN
        IF R.ACCOUNT.CREDIT.INT<IC.Config.AccountCreditInt.AciInterestDayBasis> = 'NONE' THEN
            UPD.FLD = IC.RC.CREDIT.RATE.TYPE
            GOSUB UPD.RATE.TYPE.NONE
        END ELSE
            GOSUB ACI.RATE
        END
    END ELSE
        LAST.ACI.STATUS = 'GR'
        LOCATE DTE IN R.GROUP.DATE<IC.InterestAndCapitalisation.GroupDate.AcGrdCreditDates,1> BY 'AR' SETTING LAST.GCI.POS ELSE
            IF LAST.GCI.POS GT 1 THEN
                LAST.GCI.POS -= 1
            END
        END
        GI.ID = GRP.CCY:R.GROUP.DATE<IC.InterestAndCapitalisation.GroupDate.AcGrdCreditDates, LAST.GCI.POS>
        GOSUB UPD.FROM.GCI
    END

*
RETURN
*------------------------------------------------------------------------
ACI.RATE:
*
* CR set of interest details
*
    NO.OF.BANDS = DCOUNT(R.ACCOUNT.CREDIT.INT<IC.Config.AccountCreditInt.AciCrBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.ACCOUNT.CREDIT.INT<IC.Config.AccountCreditInt.AciCrIntRate>, @VM)
    END
    R.RECORD = R.ACCOUNT.CREDIT.INT
    UPD.FLD = IC.RC.CREDIT.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.AccountCreditInt.AciCrCalculType
    BASIC.RATE.FLD = IC.Config.AccountCreditInt.AciCrBasicRate
    INT.RATE.FLD = IC.Config.AccountCreditInt.AciCrIntRate
    MARGIN.OPER.FLD = IC.Config.AccountCreditInt.AciCrMarginOper
    MIN.RATE.FLD = IC.Config.AccountCreditInt.AciCrMinRate
    MAX.RATE.FLD = IC.Config.AccountCreditInt.AciCrMaxRate
    MARGIN.RATE.FLD = IC.Config.AccountCreditInt.AciCrMarginRate
    LIMIT.AMT.FLD = IC.Config.AccountCreditInt.AciCrLimitAmt
    NEGATIVE.RATE = IC.Config.AccountCreditInt.AciNegativeRates
    BAND.AMT.FLD = IC.RC.CREDIT.BAND.UPTO
    BAND.RATE.FLD = IC.RC.CREDIT.BAND.RATE
*
    IF NO.OF.BANDS = 1 AND R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = '' THEN
        R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = 0
    END
    RATE.BAND.CNT = 0
    GOSUB CLEAR.DATA.OVERLAPPING
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
        IF NO.OF.BANDS GT 1 THEN        ;* Only for Banded
            GOSUB UPD.FOR.DEBIT.LIMIT
        END
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES
*
* CR2 set of interest details
*
    NO.OF.BANDS = DCOUNT(R.ACCOUNT.CREDIT.INT<IC.Config.AccountCreditInt.AciCrTwoBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.ACCOUNT.CREDIT.INT<IC.Config.AccountCreditInt.AciCrTwoIntRate>, @VM)
    END
    R.RECORD = R.ACCOUNT.CREDIT.INT
    UPD.FLD = IC.RC.CREDIT2.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.AccountCreditInt.AciCrTwoCalculType
    BASIC.RATE.FLD = IC.Config.AccountCreditInt.AciCrTwoBasicRate
    INT.RATE.FLD = IC.Config.AccountCreditInt.AciCrTwoIntRate
    MARGIN.OPER.FLD = IC.Config.AccountCreditInt.AciCrTwoMarginOper
    MIN.RATE.FLD = IC.Config.AccountCreditInt.AciCrTwoMinRate
    MAX.RATE.FLD = IC.Config.AccountCreditInt.AciCrTwoMaxRate
    MARGIN.RATE.FLD = IC.Config.AccountCreditInt.AciCrTwoMarginRate
    LIMIT.AMT.FLD = IC.Config.AccountCreditInt.AciCrTwoLimitAmt
    BAND.AMT.FLD = IC.RC.CREDIT2.BAND.UPTO
    BAND.RATE.FLD = IC.RC.CREDIT2.BAND.RATE
*
    IF NO.OF.BANDS = 1 AND R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = '' THEN
        R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO> = 0
    END
    RATE.BAND.CNT = 0
    GOSUB CLEAR.DATA.OVERLAPPING
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
        IF NO.OF.BANDS GT 1 THEN        ;* Only for Banded
            GOSUB UPD.FOR.DEBIT.LIMIT
        END
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES

RETURN

*
***************************************************************************
*
UPD.FROM.GDI:
*============
*
    ER = ''
    R.GROUP.DEBIT.INT = IC.Config.GroupDebitInt.Read(GI.ID, ER)
    IF NOT(ER) THEN
        IF R.GROUP.DEBIT.INT<IC.Config.GroupDebitInt.GdiInterestDayBasis> = 'NONE' THEN
            UPD.FLD = IC.RC.DEBIT.RATE.TYPE
            GOSUB UPD.RATE.TYPE.NONE
        END ELSE
            GOSUB GDI.RATE

*
        END
    END
*
RETURN
*--------------------------------------------------------------------------------
GDI.RATE:
*
* DR set of interest details
*
    NO.OF.BANDS = DCOUNT(R.GROUP.DEBIT.INT<IC.Config.GroupDebitInt.GdiDrBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.GROUP.DEBIT.INT<IC.Config.GroupDebitInt.GdiDrIntRate>,@VM)
    END
    R.RECORD = R.GROUP.DEBIT.INT
    UPD.FLD = IC.RC.DEBIT.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.GroupDebitInt.GdiDrCalculType
    BASIC.RATE.FLD = IC.Config.GroupDebitInt.GdiDrBasicRate
    INT.RATE.FLD = IC.Config.GroupDebitInt.GdiDrIntRate
    MARGIN.OPER.FLD = IC.Config.GroupDebitInt.GdiDrMarginOper
    MIN.RATE.FLD = IC.Config.GroupDebitInt.GdiDrMinRate
    MAX.RATE.FLD = IC.Config.GroupDebitInt.GdiDrMaxRate
    MARGIN.RATE.FLD = IC.Config.GroupDebitInt.GdiDrMarginRate
    LIMIT.AMT.FLD = IC.Config.GroupDebitInt.GdiDrLimitAmt
    NEGATIVE.RATE = IC.Config.GroupDebitInt.GdiGdiNegativeRates ;* Add Negative rate for GDI  DR interest process
    BAND.AMT.FLD = IC.RC.DEBIT.BAND.UPTO
    BAND.RATE.FLD = IC.RC.DEBIT.BAND.RATE
*
    RATE.BAND.CNT = 0
    GOSUB CLEAR.DATA.OVERLAPPING
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
        IF NO.OF.BANDS GT 1 THEN        ;* Only for Banded
            GOSUB UPD.FOR.DEBIT.LIMIT
        END
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES
*
* DR2 set of interest details
*
    NO.OF.BANDS = DCOUNT(R.GROUP.DEBIT.INT<IC.Config.GroupDebitInt.GdiDrTwoBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.GROUP.DEBIT.INT<IC.Config.GroupDebitInt.GdiDrTwoIntRate>, @VM)
    END
    R.RECORD = R.GROUP.DEBIT.INT
    UPD.FLD = IC.RC.DEBIT2.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.GroupDebitInt.GdiDrTwoCalculType
    BASIC.RATE.FLD = IC.Config.GroupDebitInt.GdiDrTwoBasicRate
    INT.RATE.FLD = IC.Config.GroupDebitInt.GdiDrTwoIntRate
    MARGIN.OPER.FLD = IC.Config.GroupDebitInt.GdiDrTwoMarginOper
    MIN.RATE.FLD = IC.Config.GroupDebitInt.GdiDrTwoMinRate
    MAX.RATE.FLD = IC.Config.GroupDebitInt.GdiDrTwoMaxRate
    MARGIN.RATE.FLD = IC.Config.GroupDebitInt.GdiDrTwoMarginRate
    LIMIT.AMT.FLD = IC.Config.GroupDebitInt.GdiDrTwoLimitAmt
    BAND.AMT.FLD = IC.RC.DEBIT2.BAND.UPTO
    BAND.RATE.FLD = IC.RC.DEBIT2.BAND.RATE
*
    GOSUB CLEAR.DATA.OVERLAPPING
    RATE.BAND.CNT = 0
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
        IF NO.OF.BANDS GT 1 THEN        ;* Only for Banded
            GOSUB UPD.FOR.DEBIT.LIMIT
        END
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES

RETURN
***************************************************************************
*
UPD.FROM.GCI:
*============
*
    ER = ''
    R.GROUP.CREDIT.INT = IC.Config.GroupCreditInt.Read(GI.ID, ER)
    IF NOT(ER) THEN
        IF R.GROUP.CREDIT.INT<IC.Config.GroupCreditInt.GciInterestDayBasis> = 'NONE' THEN
            UPD.FLD = IC.RC.CREDIT.RATE.TYPE
            GOSUB UPD.RATE.TYPE.NONE
        END ELSE
            GOSUB GCI.RATE
*
        END
    END

*
RETURN
*--------------------------------------------------------------------------------
GCI.RATE:
*
* CR set of interest details
*
    NO.OF.BANDS = DCOUNT(R.GROUP.CREDIT.INT<IC.Config.GroupCreditInt.GciCrBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.GROUP.CREDIT.INT<IC.Config.GroupCreditInt.GciCrIntRate>, @VM)
    END
    R.RECORD = R.GROUP.CREDIT.INT
    UPD.FLD = IC.RC.CREDIT.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.GroupCreditInt.GciCrCalculType
    BASIC.RATE.FLD = IC.Config.GroupCreditInt.GciCrBasicRate
    INT.RATE.FLD = IC.Config.GroupCreditInt.GciCrIntRate
    MARGIN.OPER.FLD = IC.Config.GroupCreditInt.GciCrMarginOper
    MIN.RATE.FLD = IC.Config.GroupCreditInt.GciCrMinRate
    MAX.RATE.FLD = IC.Config.GroupCreditInt.GciCrMaxRate
    MARGIN.RATE.FLD = IC.Config.GroupCreditInt.GciCrMarginRate
    LIMIT.AMT.FLD = IC.Config.GroupCreditInt.GciCrLimitAmt
    NEGATIVE.RATE = IC.Config.GroupCreditInt.GciNegativeRates
    BAND.AMT.FLD = IC.RC.CREDIT.BAND.UPTO
    BAND.RATE.FLD = IC.RC.CREDIT.BAND.RATE
*
    GOSUB CLEAR.DATA.OVERLAPPING
    RATE.BAND.CNT = 0
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES
*
* CR2 set of interest details
*
    NO.OF.BANDS = DCOUNT(R.GROUP.CREDIT.INT<IC.Config.GroupCreditInt.GciCrTwoBasicRate>, @VM)
    IF NO.OF.BANDS = 0 THEN
        NO.OF.BANDS = DCOUNT(R.GROUP.CREDIT.INT<IC.Config.GroupCreditInt.GciCrTwoIntRate>, @VM)
    END
    R.RECORD = R.GROUP.CREDIT.INT
    UPD.FLD = IC.RC.CREDIT2.RATE.TYPE
    CALCUL.TYPE.FLD = IC.Config.GroupCreditInt.GciCrTwoCalculType
    BASIC.RATE.FLD = IC.Config.GroupCreditInt.GciCrTwoBasicRate
    INT.RATE.FLD = IC.Config.GroupCreditInt.GciCrTwoIntRate
    MARGIN.OPER.FLD = IC.Config.GroupCreditInt.GciCrTwoMarginOper
    MIN.RATE.FLD = IC.Config.GroupCreditInt.GciCrTwoMinRate
    MAX.RATE.FLD = IC.Config.GroupCreditInt.GciCrTwoMaxRate
    MARGIN.RATE.FLD = IC.Config.GroupCreditInt.GciCrTwoMarginRate
    LIMIT.AMT.FLD = IC.Config.GroupCreditInt.GciCrTwoLimitAmt
    BAND.AMT.FLD = IC.RC.CREDIT2.BAND.UPTO
    BAND.RATE.FLD = IC.RC.CREDIT2.BAND.RATE
*
    GOSUB CLEAR.DATA.OVERLAPPING
    RATE.BAND.CNT = 0
    FOR BAND.LEVEL.NO = 1 TO NO.OF.BANDS
        GOSUB UPD.RATE.CHANGES
    NEXT BAND.LEVEL.NO
* Update the RATE.CHANGES with previous rate if int rate is null for the BAND.DATE
    GOSUB POPULATE.RATE.CHANGES

RETURN

***************************************************************************
POPULATE.RATE.CHANGES:
**********************
    PREV.BAND.AMT = ''
    PREV.BAND.RATE = ''

    B.DATE = ''
    BDATE.LIST = RAISE(RATE.CHANGES<1>)
    LOOP
        REMOVE BAND.DATE FROM BDATE.LIST SETTING BD
    WHILE BAND.DATE:BD
        B.DATE += 1
        IF RATE.CHANGES<BAND.RATE.FLD,B.DATE> NE '' THEN
            RATE.LIST = RATE.CHANGES<BAND.RATE.FLD,B.DATE>
*--- Check whether whether the date is Group / Account rate change date.
            LOCATE BAND.DATE IN DATE.LIST<1,1> SETTING POS THEN
                NO.OF.BRATES = DCOUNT(RATE.LIST,@SM)
                PREV.BAND.AMT = RAISE(RATE.CHANGES<BAND.AMT.FLD,B.DATE>)
                PREV.BAND.RATE = RAISE(RATE.CHANGES<BAND.RATE.FLD,B.DATE>)
            END ELSE          ;* Basic rate change.
                GOSUB POPULATE.RATE.AMT
            END
        END
    REPEAT
RETURN
*********************************************************************
POPULATE.RATE.AMT:
******************
*--- Populate the rate and amount from the recent rate change
*--- if they are empty.
    FOR BAMT = 1 TO NO.OF.BRATES
        IF RATE.CHANGES<BAND.AMT.FLD,B.DATE,BAMT> = '' THEN
            RATE.CHANGES<BAND.AMT.FLD,B.DATE,BAMT> = PREV.BAND.AMT<1,BAMT>
        END
        IF RATE.CHANGES<BAND.RATE.FLD,B.DATE,BAMT> = '' THEN
            RATE.CHANGES<BAND.RATE.FLD,B.DATE,BAMT> = PREV.BAND.RATE<1,BAMT>
        END
    NEXT BAMT

* Store the last interest rate

    PREV.BAND.AMT = RAISE(RATE.CHANGES<BAND.AMT.FLD,B.DATE>)
    PREV.BAND.RATE = RAISE(RATE.CHANGES<BAND.RATE.FLD,B.DATE>)

RETURN
**********************************************************************************
UPD.RATE.TYPE.NONE:
*==================
*
    GOSUB CHECK.FOR.DATE
    RATE.CHANGES<UPD.FLD, NDTE> = 'N'
    RATE.CHANGES<UPD.FLD+1, NDTE> = ''
    RATE.CHANGES<UPD.FLD+2, NDTE> = ''
    RATE.CHANGES<UPD.FLD+6, NDTE> = 'N'
    RATE.CHANGES<UPD.FLD+7, NDTE> = ''
    RATE.CHANGES<UPD.FLD+8, NDTE> = ''
*
RETURN
*
***************************************************************************
*
UPD.RATE.CHANGES:
*===============
*
    RATE = ''
    VAR.RATE.LIST = ''
    IF R.RECORD<BASIC.RATE.FLD,BAND.LEVEL.NO> THEN          ;* Variable Rate
        BASIC.RATE.ID = R.RECORD<BASIC.RATE.FLD,BAND.LEVEL.NO>:R.ACCOUNT<AC.AccountOpening.Account.Currency>
        GOSUB GET.VARIABLE.RATE
    END ELSE        ;* Fixed Rate
        RATE = R.RECORD<INT.RATE.FLD,BAND.LEVEL.NO>
        VAR.RATE.LIST<1> = DTE
        VAR.RATE.LIST<2> = RATE
    END
*

    RATE.BAND.CNT = BAND.LEVEL.NO
    YI = ''         ;* Go through remaining dates for BRT
    LOOP
        YI +=1
    UNTIL VAR.RATE.LIST<1,YI> = ''
*
        IF VAR.RATE.LIST<2,YI> THEN
            RATE = VAR.RATE.LIST<2,YI>      ;* Rate for the record date
        END ELSE
            RATE = 0                        ;* When RATE.CHANGES array is built with Null RATE Values then , Enquiry displays incorrect results.
        END
        DTE2 = VAR.RATE.LIST<1,YI>

        GOSUB CHECK.FOR.DATE
        GOSUB CHECK.FOR.MARGIN
        IF RATE NE '' THEN
            GOSUB UPDATE.RATE.CHANGE.ARR
        END
    REPEAT
RETURN
*
***************************************************************************
UPDATE.RATE.CHANGE.ARR:

    BEGIN CASE
        CASE R.RECORD<CALCUL.TYPE.FLD> = "BAND"
            GOSUB BAND.RATE
        CASE R.RECORD<CALCUL.TYPE.FLD> = "LEVEL"
            RATE.CHANGES<UPD.FLD+1, NDTE,RATE.BAND.CNT> = R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO>
            RATE.CHANGES<UPD.FLD+2, NDTE,RATE.BAND.CNT> = RATE:'$':BASIC.RATE:'$':MARGIN.RATE
            RATE.CHANGES<UPD.FLD, NDTE> = 'L'
            BASIC.RATE = ''
            MARGIN.RATE = ''
        CASE R.RECORD<CALCUL.TYPE.FLD> = "FIXED" OR R.RECORD<CALCUL.TYPE.FLD> = ""
            RATE.CHANGES<UPD.FLD+1, NDTE> = ""
            RATE.CHANGES<UPD.FLD+2, NDTE> = RATE:'$':BASIC.RATE:'$':MARGIN.RATE
            RATE.CHANGES<UPD.FLD, NDTE> = 'F'
            BASIC.RATE = ''
            MARGIN.RATE = ''
    END CASE
RETURN

*------------------------------------------------------------------------
BAND.RATE:

    RATE.CHANGES<UPD.FLD, NDTE> = 'B'
    RATE.CHANGES<UPD.FLD+1, NDTE,RATE.BAND.CNT> = R.RECORD<LIMIT.AMT.FLD,BAND.LEVEL.NO>
    RATE.CHANGES<UPD.FLD+2, NDTE,RATE.BAND.CNT> = RATE:'$':BASIC.RATE:'$':MARGIN.RATE
    BASIC.RATE = ''
    MARGIN.RATE = ''

    IF RATE.CHANGES<UPD.FLD+1, NDTE,RATE.BAND.CNT> = '' AND R.RECORD<LIMIT.AMT.FLD> NE '' THEN
        FOR CHECK.LOOP = BAND.LEVEL.NO TO 1 STEP -1
            IF R.RECORD<LIMIT.AMT.FLD,CHECK.LOOP> THEN
                RATE.CHANGES<UPD.FLD+1, NDTE,RATE.BAND.CNT-1> = R.RECORD<LIMIT.AMT.FLD,CHECK.LOOP>
                CHECK.LOOP = 1
            END
        NEXT CHECK.LOOP
    END
RETURN

*------------------------------------------------------------------------
CHECK.FOR.MARGIN:
*================
*
* Check for MARGIN
*
    BASIC.RATE = RATE
    MIN.RATE = R.RECORD<MIN.RATE.FLD,BAND.LEVEL.NO>
    MAX.RATE = R.RECORD<MAX.RATE.FLD,BAND.LEVEL.NO>
    BEGIN CASE
        CASE R.RECORD<MARGIN.OPER.FLD,BAND.LEVEL.NO>[1,1] = "S"
            RATE = RATE - R.RECORD<MARGIN.RATE.FLD,BAND.LEVEL.NO>
            MARGIN.RATE = R.RECORD<MARGIN.RATE.FLD,BAND.LEVEL.NO>:'-'

        CASE R.RECORD<MARGIN.OPER.FLD,BAND.LEVEL.NO>[1,1] = "M"
            ADD.RATE = (RATE * R.RECORD<MARGIN.RATE.FLD,BAND.LEVEL.NO>) / 100
            ADD.RATE = OCONV(ICONV(ADD.RATE, 'MD9'),'MD9')
            GOSUB CUT.ZERO.DECIMAL
            RATE = RATE + ADD.RATE
            MARGIN.RATE =(100 + R.RECORD<MARGIN.RATE.FLD,BAND.LEVEL.NO>) / 100:'*'
*
        CASE R.RECORD<MARGIN.OPER.FLD,BAND.LEVEL.NO>[1,1] = "A"
            RATE = RATE + R.RECORD<MARGIN.RATE.FLD,BAND.LEVEL.NO>
            MARGIN.RATE = R.RECORD<MARGIN.RATE.FLD,BAND.LEVEL.NO>:'+'
*
    END CASE
*
* Allow negative rates if configured to do so, default is no
    IF R.RECORD<NEGATIVE.RATE> NE 'YES' AND RATE < 0 THEN
        GOSUB CHECK.NEGATIVE
    END
*
    IF MIN.RATE AND RATE < MIN.RATE THEN
        RATE = MIN.RATE
    END

    IF MAX.RATE AND RATE > MAX.RATE THEN
        RATE = MAX.RATE
    END
*
RETURN
*
***************************************************************************
*
CHECK.FOR.DATE:
*==============
*
    IF DTE2 AND DTE2 < DTE THEN
        INS.DTE = DTE
    END ELSE
        INS.DTE = DTE2
    END
    LOCATE INS.DTE IN RATE.CHANGES<IC.RC.DATE,1> BY 'AR' SETTING NDTE ELSE
        INS INS.DTE BEFORE RATE.CHANGES<IC.RC.DATE, NDTE>
        FOR NULLIFY = 2 TO 13
            INS '' BEFORE RATE.CHANGES<NULLIFY, NDTE>
        NEXT NULLIFY
    END
*
RETURN
*
***************************************************************************
*
GET.VARIABLE.RATE:
*=================
** Return a list of relevant dates and rates upto the next
** group date.
*
    LOCATE BASIC.RATE.ID IN IC.ModelBank.getCBrt()<1,1> SETTING BPOS THEN
        LOCATE DTE IN IC.ModelBank.getCBrt()<2,BPOS,1> BY 'AR' SETTING BDPOS ELSE
            IF BDPOS > 1 THEN
                BDPOS -= 1    ;* To get the last date
            END
        END
        YI = ''     ;* Counter for rate list for BRT if
        LOOP
            YI += 1
        UNTIL IC.ModelBank.getCBrt()<2,BPOS,BDPOS> GT NEXT.DATE OR IC.ModelBank.getCBrt()<2,BPOS,BDPOS> = ''
            GOSUB VAR.RATE
            BDPOS += 1
        REPEAT
    END
*
RETURN
*--------------------------------------------------------------------------------
VAR.RATE:

    VAR.RATE.LIST<1,YI> = IC.ModelBank.getCBrt()<2,BPOS,BDPOS>
    IF IC.ModelBank.getCBrt()<3,BPOS,BDPOS> NE '' THEN
        VAR.RATE.LIST<2,YI> = IC.ModelBank.getCBrt()<3,BPOS,BDPOS>
    END ELSE
        ID = IC.ModelBank.getCBrt()<1,BPOS>:IC.ModelBank.getCBrt()<2,BPOS,BDPOS>
        R.BASIC.INTEREST = ''
        R.BASIC.INTEREST = ST.RateParameters.BasicInterest.Read(ID, ER)
        IF NOT(ER) THEN
            GOSUB ASSIGN.BI.RATE
        END
    END

RETURN

***************************************************************************
*
UPD.FOR.DEBIT.LIMIT:
*==================
** Build a list of account debit limit dates, and a list of all
** relevant base rate changes
*
    BAND.INFO = ''  ;* List of Band changes due to ADL and BI
    IF SRCH.LEVEL = 'GR' AND DR.CR = 'DR' THEN
        LOCATE DTE IN R.ACCOUNT.DATE<YAC.DEBIT.LIMIT,1> BY 'AR' SETTING ADLPOS ELSE
            NULL
        END

        YI = ''
        LOOP
            YI += 1
        UNTIL R.ACCOUNT.DATE<YAC.DEBIT.LIMIT,ADLPOS> = '' OR R.ACCOUNT.DATE<YAC.DEBIT.LIMIT,ADLPOS> GE NEXT.DATE
            R.ACCOUNT.DEBIT.LIMIT = ''
            ER = ''
            LIM.ID = ACCOUNT.NO:'-':R.ACCOUNT.DATE<YAC.DEBIT.LIMIT,ADLPOS>
            R.ACCOUNT.DEBIT.LIMIT = AC.AccountOpening.AccountDebitLimit.Read(LIM.ID, ER)
        
            IF ER = '' THEN
                LIM.AMT = R.ACCOUNT.DEBIT.LIMIT<AC.AccountOpening.AccountDebitLimit.AdlLimit>
            
            END
            IF YI = 1 THEN
                BAND.INFO<1,YI> = DTE
            END ELSE
                BAND.INFO<1,YI> = R.ACCOUNT.DATE<YAC.DEBIT.LIMIT,ADLPOS>
            END
            BAND.INFO<2,YI> = LIM.AMT
            ADLPOS += 1
        REPEAT
    END
*
RETURN
*
***************************************************************************
*
CUT.ZERO.DECIMAL:
*================
*
    X = INDEX(ADD.RATE,'.',1)
    IF X > 0 THEN
        LOOP UNTIL ADD.RATE[LEN(ADD.RATE),1] <> '0' DO
            ADD.RATE = ADD.RATE[1,LEN(ADD.RATE)-1]
        REPEAT
        IF ADD.RATE[LEN(ADD.RATE),1] = "." THEN
            ADD.RATE = ADD.RATE[1,LEN(ADD.RATE)-1]
        END
    END
*
RETURN
*
*----------------------------------------------------------------------------
RETURN.RELEVANT.DATES:
*=====================
** Strip out dates before START.DATE and after END.DATE
*
    TEMP.RATE.CHANGES = RATE.CHANGES
    RATE.CHANGES = ''
*
    LOCATE START.DATE IN TEMP.RATE.CHANGES<1,1> BY 'AR' SETTING DATE.POS ELSE
        NULL
    END

    DATE.CNT = ''
    LOOP
    UNTIL TEMP.RATE.CHANGES<1,DATE.POS> = '' OR TEMP.RATE.CHANGES<1,DATE.POS> GT END.DATE
        DATE.CNT +=1
        FOR YI = 1 TO 13
            RATE.CHANGES<YI,DATE.CNT> = TEMP.RATE.CHANGES<YI,DATE.POS>
        NEXT YI
        DATE.POS += 1
    REPEAT
*
RETURN
*
***************************************************************************
CLEAR.DATA.OVERLAPPING:
*---------------------
*-- Same BI & Interest change dates.
    LOCATE DTE IN RATE.CHANGES<IC.RC.DATE,1> BY 'AR' SETTING RPOS THEN
        IF RATE.CHANGES<UPD.FLD+1, RPOS> NE '' THEN
            RATE.CHANGES<UPD.FLD+1, RPOS> = ''
            RATE.CHANGES<UPD.FLD+2, RPOS> = ''
            RATE.CHANGES<UPD.FLD, RPOS> = ''
        END
    END
RETURN

*******************************************************************************
PROCESS.GET.RATE.ONLY:
*--------------------

    TEMP.RATE.CHANGES = RATE.CHANGES
    RATE.CHANGES = ''
*
** Loop through the array of rate changes replacing Debit withlates debit etc
** until we've exceeded the date inquestion
*
    RATE.CHANGES<1> = START.DATE        ;* Date requested
    YI = 1
    LOOP
    UNTIL TEMP.RATE.CHANGES<1,YI> GT START.DATE OR TEMP.RATE.CHANGES<1,YI> = ''
        FOR FLD = 2 TO 11 STEP 3
            IF TEMP.RATE.CHANGES<FLD,YI> THEN
                RATE.CHANGES<FLD> = TEMP.RATE.CHANGES<FLD,YI>         ;* Type
                RATE.CHANGES<FLD+1> = TEMP.RATE.CHANGES<FLD+1,YI>     ;* Limit
                RATE.CHANGES<FLD+2> = TEMP.RATE.CHANGES<FLD+2,YI>     ;* Rate
            END
        NEXT FLD
        YI += 1
    REPEAT
*
RETURN
*
***************************************************************************
CHECK.NEGATIVE:
*==============
    IF R.RECORD<NEGATIVE.RATE> EQ "BLOCK.MARGIN" AND BASIC.RATE < 0  THEN
        IF RATE < BASIC.RATE THEN       ;* It's more negative so lose the margin
            RATE = BASIC.RATE
        END
    END ELSE
        RATE = 0    ;* we know its negtive so set to zero , could have started as positive
    END

RETURN
*-------------------------------------------------------------------------------
ASSIGN.BI.RATE:
*-------------
    BI.RATE = R.BASIC.INTEREST<ST.RateParameters.BasicInterest.EbBinInterestRate>
    IF BI.RATE NE '' THEN
        VAR.RATE.LIST<2,YI> = BI.RATE
        tmp=IC.ModelBank.getCBrt(); tmp<3,BPOS,BDPOS>=BI.RATE; IC.ModelBank.setCBrt(tmp)
    END ELSE
        BI.RATE = R.BASIC.INTEREST<ST.RateParameters.BasicInterest.EbBinNegIntRate>
        VAR.RATE.LIST<2,YI> = BI.RATE
        tmp=IC.ModelBank.getCBrt(); tmp<3,BPOS,BDPOS>=BI.RATE; IC.ModelBank.setCBrt(tmp)
    END

RETURN
*---------------------------------------------------------------------------
END
