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
* <Rating>-211</Rating>
*-----------------------------------------------------------------------------
* Version 6 29/09/00  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.DAILY.PL

* This routine will build R.RECORD for the estimated daily P&L enquiry.
* Each asset and liability representing the a "live" balance is taken
* and one days interest is then calculated on each balance. For nostro
* accounts the applicable rate is calculated by reading the account
* record (via NOSTRO.ACCOUNT). R.RECORD contians consolidated details
* for each application and for each of the nostro accounts. The user
* may enter a market rate via the enquiry selection fields which will
* then be used to calculate a second 2P&L figure which assumes that any
* remaining nostro balance can be placed in the market at the rate input.

**********************************************************************
* 16/05/96 GB9600737
*   Make sure the the ID in ID.LIST has the '\MNE'
*   appended to it so that multi company consolidation
*   works correctly. Strip it out to read the DPC record
*
* 28/09/98 - GB98001153
*            Allow NCU to be reported under EUR
*
* 22/08/04 - CI_10022433
*            The size of the dimensioned arrays DPC.REC,DPC.FILES
*            be increated to 50 ,to avoid the array index out of found
*            while running pm related enquiries.  This happens only when
*            the field COM.CONSOL.FROM in COMPANY.CONSOL having more than 10 mv's.
*
* 24/01/07 - CI_10046838
*            cater for multi valued banded interest rates related to amount
*
* 09/12/09 - BG_100026129
*            remove reference to overnight file - now obsolete
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
**********************************************************************


    $USING EB.Utility
    $USING ST.CurrencyConfig
    $USING PM.Config
    $USING AC.AccountOpening
    $USING PM.Reports
    $USING EB.Display
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports

    B = ''
    DEFFUN CHARX(B)
    GOSUB INITIALISE

* Call E.PM.GET.NOSTRO.CLASSES to get a list of all valid PM nostro
* classes based on the PM.AC.PARAM file. The ID to this file along with
* the balance types to check (ie overnight balances, accruals etc) must be
* passed.

    NOSTRO.CLASSES = ''
    BAL.TYPES = PM.Config.AcParam.ApClassOvernight
    BAL.TYPES<-1> = PM.Config.AcParam.ApClsOnlineActl
    BAL.TYPES<-1> = PM.Config.AcParam.ApClsOnlineSprd

    PM.Reports.EPmGetNostroClasses('CAS', BAL.TYPES, NOSTRO.CLASSES)

    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        RETURN
    END

    GOSUB CONSOLIDATE.DPC.DATA

    GOSUB CALC.PROFIT.LOSS

    RETURN



**************************************************************************
*                       INTERNAL ROUTINES
**************************************************************************

SELECT.DLY.POSN.CLASS:
*=====================

* Call E.PM.SEL.POSN.CLASS to get a list of PM.DLY.POSN.CLASS IDs and
* associated file mnemonics required. This routine requires an ID to the
* PM.ENQ.PARAM file which defines the records required for the enquiry.
* In addition information regarding the signing conventions required for
* the enquiry are returned. The PM.ENQ.PARAM will have already been
* loaded in the labelled common area (I_PM.ENQ.PARAM) by the routine
*  E.PM.INT.COMMON.

    ID.LIST = ''
    MNEMON.LIST = ""

    PM.Reports.EPmSelPosnClass(ID.LIST, MNEMON.LIST, MAT DPC.FILES)

    RETURN


CONSOLIDATE.DPC.DATA:
*====================

* Loop through each of the records selected from the posn class files
* and calculate on days interest for each of the balances and rates
* recorded.

    X = 0
    LOOP
        REMOVE TEMP.ID FROM ID.LIST SETTING POINT1
        EB.Reports.setId(TEMP.ID)
        REMOVE MNEMON FROM MNEMON.LIST SETTING POINT2
    WHILE EB.Reports.getId()
        tmp.ID = EB.Reports.getId()
        CLASS = FIELD(tmp.ID,'.',1)
        EB.Reports.setId(tmp.ID)
        tmp.ID = EB.Reports.getId()
        V$DATE = FIELD(tmp.ID,'.',6)
        EB.Reports.setId(tmp.ID)

        * Do not include any account movements with a forward value date or
        * contract movement with todays date. This is done to prevent double
        * counting at contract drawdown or repayment/maturity. Note use of
        * variable PM.ENQ.TODAY to cater for the fact that we could be looking
        * at todays or last nights file !!

        IF INDEX('ABCDEF',CLASS[3,1],1) THEN
            IF V$DATE GT PM.ENQ.TODAY THEN
                CONTINUE
            END
        END ELSE
            IF V$DATE LE PM.ENQ.TODAY THEN
                CONTINUE
            END
        END

        MAT DPC.REC = ''
        tmp.ID = EB.Reports.getId()
        DPC.ID = FIELD(tmp.ID,'*',1)
        EB.Reports.setId(tmp.ID)
        MATREAD DPC.REC FROM DPC.FILES(MNEMON),DPC.ID THEN
        GOSUB PROCESS.DPC.REC
    END

    REPEAT

    RETURN

********************************************************************************
PROCESS.DPC.REC:
****************

    WCCY = DPC.ID['.',5,1]
    IF WCCY NE PM.Config.getCcy() THEN
        tmp.PM$CCY = PM.Config.getCcy()
        PM.Reports.EPmDpcConvert(DPC.ID, MAT DPC.REC, tmp.PM$CCY)
        PM.Config.setCcy(tmp.PM$CCY)
    END
*
* GB9600737
*
    AMOUNT = DPC.REC(PM.Config.DlyPosnClass.DpcAmount)
*
    IF AMOUNT<1,2,1> THEN
        LIAB.AMT = AMOUNT<1,2,1>
    END ELSE
        LIAB.AMT = 0
    END
    IF AMOUNT<1,1,1> THEN
        ASSET.AMT = AMOUNT<1,1,1>
    END ELSE
        ASSET.AMT = 0
    END

* If this is a nostro movement then update the NOST.AMTS array according
* to the relevant significance of the account, ie A, B or C nostro etc.
* The rates (PM rate codes) associated with each 'account' will be
* determined later according to the final balance of that account.
* If this is a contract based movement then update the COMP.STR
* and INT.STR arrays with the movement amounts and rate codes
* respectively.

* Note : NOSTRO.CLASSES contains only the 3rd and 4th characters of a
* class which identify that class as a nostro class.
    LOCATE CLASS[3,2] IN NOSTRO.CLASSES<1> SETTING POSN THEN
*        XX = SEQX(CLASS[3,1]) - 64      ;* "A" nostro XX = 1
    NOST.BAL = ASSET.AMT - LIAB.AMT
    NOST.AMTS<POSN> += NOST.BAL

    END ELSE
    GOSUB PROCESS.CUST
    END

    RETURN

*********************************************************************************
PROCESS.CUST:
*************

    TOT.ASSET += ASSET.AMT
    TOT.LIABS -= LIAB.AMT     ;* Liabs are -ve

* Log FT and DC movements to the AC application.

    IF CLASS[1,3] MATCHES "FTA":@VM:"DCA":@VM:"TTA" THEN
        APPL = 'AC'
    END ELSE
        APPL = CLASS[1,2]
    END
    LOCATE APPL IN APPL.LIST<1,1> SETTING A.POS ELSE
    INS APPL BEFORE APPL.LIST<1,A.POS>
    END
    FOR ASST.LIAB = 1 TO 2

        * Consolidate each of the deal amounts by the interest code associated
        * with that amount.

        XX = 10
        LOOP
            INT.CODE = DPC.REC(PM.Config.DlyPosnClass.DpcAmtCode)<1,ASST.LIAB,XX>
        WHILE INT.CODE
            AMT = DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,ASST.LIAB,XX>
            IF ASST.LIAB = 2 THEN
                AMT = AMT * -1          ;* Liabs are -ve
            END
            IF INT.CODE[1,1] EQ 'F' THEN
                INT.CODE = INT.CODE:'*':DPC.REC(PM.Config.DlyPosnClass.DpcAvgRate)<1,ASST.LIAB,XX>
            END
            LOCATE INT.CODE IN INT.STR(A.POS)<ASST.LIAB, 1> SETTING I.POS THEN
            AMT.STR(A.POS)<ASST.LIAB, I.POS> += AMT
        END ELSE
            INS INT.CODE BEFORE INT.STR(A.POS)<ASST.LIAB, I.POS>
            INS AMT BEFORE AMT.STR(A.POS)<ASST.LIAB, I.POS>
        END
        XX += 1
    REPEAT
    NEXT
    TXNS<A.POS> := EB.Reports.getId():@VM

    RETURN

***********************************************************************
CALC.PROFIT.LOSS:
*================


    ER1 = ''
    REC.CURRENCY = ''
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    tmp.PM$CCY = PM.Config.getCcy()
    REC.CURRENCY = ST.CurrencyConfig.Currency.Read(tmp.PM$CCY, ER1)
* Before incorporation : CALL F.READ('F.CURRENCY',tmp.PM$CCY,REC.CURRENCY,tmp.F.CURRENCY,ER1)
    PM.Config.setCcy(tmp.PM$CCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
    BASIS = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>
    IF BASIS THEN
        BASIS = BASIS[1,1]
    END
    IF BASIS EQ 'A' OR BASIS EQ 'B' THEN
        NUMERATOR = 36000
    END ELSE
        NUMERATOR = 36500
    END

* For the contract based movements determine the actual interest rate
* for each of the amount/int.code combinations and then calculate the
* average asset/liab amounts and rates.

    GOSUB CALC.DEAL.RATES.AND.PROFIT

* For each nostro account for the currency determine the appropriate
* interest rate and calculate the P&L for each account and the overall
* nostro profit. In addition calculate the possible nostro profit based
* on the notional rate input by the user.

    GOSUB CALC.NOSTRO.RATES.AND.PROFIT

* Update R.RECORD.

    EB.Reports.setRRecord('')
    tmp=EB.Reports.getRRecord(); tmp<1>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<2>=APPL.LIST; EB.Reports.setRRecord(tmp)

    FOR XX = 1 TO APPL.CNT
        FOR YY = 1 TO 2
            tmp=EB.Reports.getRRecord(); tmp<2+YY, XX>=AMT.STR(XX)<YY>; EB.Reports.setRRecord(tmp);* asset & liab amounts
            tmp=EB.Reports.getRRecord(); tmp<4+YY, XX>=INT.STR(XX)<YY>; EB.Reports.setRRecord(tmp);* asset & liab rates
            tmp=EB.Reports.getRRecord(); tmp<6+YY, XX>=PAL.STR(XX)<YY>; EB.Reports.setRRecord(tmp);* asset & liab interest
        NEXT YY
    NEXT XX
    tmp=EB.Reports.getRRecord(); tmp<9>=TOT.ASSET; EB.Reports.setRRecord(tmp);* total assets excluding nostros
    tmp=EB.Reports.getRRecord(); tmp<10>=TOT.LIABS; EB.Reports.setRRecord(tmp);* total liabs excluding nostros
    tmp=EB.Reports.getRRecord(); tmp<11>=ASSET.RATE; EB.Reports.setRRecord(tmp);* avg asset rate excl nostros
    tmp=EB.Reports.getRRecord(); tmp<12>=LIAB.RATE; EB.Reports.setRRecord(tmp);* avg liab rate excl nostros
    tmp=EB.Reports.getRRecord(); tmp<13>=TOT.PAL<1>; EB.Reports.setRRecord(tmp);* asset profit excl nostros
    tmp=EB.Reports.getRRecord(); tmp<14>=TOT.PAL<2>; EB.Reports.setRRecord(tmp);* liab profit excl nostros

    CONVERT @VM TO " " IN TXNS
    FOR XX = 1 TO APPL.CNT
        tmp=EB.Reports.getRRecord(); tmp<15, XX>=TXNS<XX>; EB.Reports.setRRecord(tmp);* List of PM.xxx.POSN.CLASS keys
    NEXT XX

    FOR XX = 1 TO NO.OF.NOSTROS
        tmp=EB.Reports.getRRecord(); tmp<20,XX>=CHARX(XX+64); EB.Reports.setRRecord(tmp);* nostro grade ie A, B etc
        FOR YY = 1 TO 2
            tmp=EB.Reports.getRRecord(); tmp<20+YY, XX>=NOST.AMTS<XX,YY>; EB.Reports.setRRecord(tmp);* nostro amts
            tmp=EB.Reports.getRRecord(); tmp<22+YY, XX>=NOST.RATES<XX,YY>; EB.Reports.setRRecord(tmp);* nostro rate
            tmp=EB.Reports.getRRecord(); tmp<24+YY, XX>=NOST.PRFT.LOSS<XX,YY>; EB.Reports.setRRecord(tmp);* nostro P&L
        NEXT YY
    NEXT XX

    FOR YY = 1 TO 2
        tmp=EB.Reports.getRRecord(); tmp<26+YY>=TOT.NOSTRO<YY>; EB.Reports.setRRecord(tmp);* tot nost assets/liabs
        tmp=EB.Reports.getRRecord(); tmp<28+YY>=AVG.NOS.RATES<YY>; EB.Reports.setRRecord(tmp);* avg nostro rates
        tmp=EB.Reports.getRRecord(); tmp<30+YY>=ACTUAL.NOST.PL<YY>; EB.Reports.setRRecord(tmp);* actual nostro P&L
    NEXT YY

* Finally calcualte the actual P&L and notioanl P&L figures respectively.

    DEAL.PL = TOT.PAL<1> + TOT.PAL<2>

    tmp=EB.Reports.getRRecord(); tmp<40>=DEAL.PL + ACTUAL.NOST.PL<1> + ACTUAL.NOST.PL<2>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<41>=DEAL.PL + NOTIONAL.NOST.PL; EB.Reports.setRRecord(tmp)

* Include the notional nostro rate

    tmp=EB.Reports.getRRecord(); tmp<42>=PM.Config.getRate(); EB.Reports.setRRecord(tmp)

    RETURN


CALC.DEAL.RATES.AND.PROFIT:
*==========================

* Calculate the daily profit for each rate/amtount combination for
* both assets and liabilities. Given these figures and the total
* assets and liabilities figures the average asset and liability
* rates can be calculated.

    APPL.CNT = DCOUNT(APPL.LIST, @VM)
    FOR A.POS = 1 TO APPL.CNT
        FOR ASST.LIAB = 1 TO 2
            TEMP.AMT = 0
            AMT.X.RATE = 0
            XX = 1
            LOOP
                INT.CODE = INT.STR(A.POS)<ASST.LIAB, XX>
            WHILE INT.CODE
                AMT = AMT.STR(A.POS)<ASST.LIAB, XX>
                GOSUB GET.RATE
                TEMP.AMT += AMT
                AMT.X.RATE += AMT * RATE
                XX += 1
            REPEAT
            TEMP.PL = AMT.X.RATE / NUMERATOR
            PAL.STR(A.POS)<ASST.LIAB> = TEMP.PL
            AMT.STR(A.POS)<ASST.LIAB> = TEMP.AMT
            IF TEMP.AMT THEN
                INT.STR(A.POS)<ASST.LIAB> = AMT.X.RATE / TEMP.AMT
            END ELSE
                INT.STR(A.POS)<ASST.LIAB> = ""
            END
            TOT.PAL<ASST.LIAB> += TEMP.PL
            TOT.AMT.X.RATE<ASST.LIAB> += AMT.X.RATE
        NEXT ASST.LIAB
    NEXT A.POS

    IF TOT.ASSET THEN
        ASSET.RATE = TOT.AMT.X.RATE<1> / TOT.ASSET
    END
    IF TOT.LIABS THEN
        LIAB.RATE = TOT.AMT.X.RATE<2> / TOT.LIABS
    END

    RETURN


CALC.NOSTRO.RATES.AND.PROFIT:
*============================

* Get the rates for the nostro accounts based on the NOSTRO.ACCOUNT file.
* It is assumed that the PM "A" nostro will be the first nostro account
* on the NOSTRO.ACCOUNT file and that the PM "B" nostro will be the
* second etc.


    ER2 = ''
    tmp.PM$CCY = PM.Config.getCcy()
    NOST.ACCT.REC = AC.AccountOpening.NostroAccount.Read(tmp.PM$CCY, ER2)
* Before incorporation : CALL F.READ('F.NOSTRO.ACCOUNT',tmp.PM$CCY,NOST.ACCT.REC,F.NOSTRO.ACCOUNT,ER2)
    PM.Config.setCcy(tmp.PM$CCY)
    IF ER2 THEN
        EB.SystemTables.setText("CANNOT DETERMINE ":PM.Config.getCcy():" NOSTRO ACCOUNT RATES - MISSING NOSTRO.ACCOUNT RECORD")
        EB.Display.Rem()
    END

* For each of the nostros in NOST.AMTS array read the account record
* based on the NOSTRO.ACCOUNT record and then call E.PM.AC.RATE.CODE to
* determine the PM style interest code (ie as stored on PM.DLY.POSN.CLASS)
* and then call E.PM.AC.RATES to get the actual rate. The nostro rates
* and daily profit amounts and then returned in the arrays NOST.RATESS
* and AMT.X.RATE which are associated (mvs) with the NOST.AMTS
* array.

    NO.OF.NOSTROS = DCOUNT(NOST.AMTS, @FM)
    FOR XX = 1 TO NO.OF.NOSTROS
        GOSUB PROCESS.NOSTRO.ACCOUNT
    NEXT XX

    FOR XX = 1 TO 2
        IF TOT.NOSTRO<XX> THEN
            AVG.NOS.RATES<XX> = ACTUAL.NOST.PL<XX> / TOT.NOSTRO<XX> * NUMERATOR
        END
    NEXT XX

* Finally calculate the notional P&L on the total nostro balance given
* the notional rateinput by the user.

    NET.NOSTRO = TOT.NOSTRO<1> + TOT.NOSTRO<2>
    NOTIONAL.NOST.PL = NET.NOSTRO * PM.Config.getRate() / NUMERATOR

    RETURN

******************************************************************
PROCESS.NOSTRO.ACCOUNT:
***********************

    ACCT.ID = NOST.ACCT.REC<AC.AccountOpening.NostroAccount.EbNosAccount, 1, XX>

* Note : PM records nostro balances the opposite way round to the
* accounting moduel of globus. Therefore when determining the rate
* to be applied based on the balance we must reverse the sign on the
* PM figure.

    IF NOST.AMTS<XX> GE 0 THEN
        CR.OR.DR = 'DEBIT'
    END ELSE
        CR.OR.DR = 'CREDIT'
    END

    AMT = ABS(NOST.AMTS<XX>)
    ACCT.ID<2> = AMT
    PM.Reports.EPmAcRateCode(ACCT.ID, CR.OR.DR, INT.CODE)
    ACCT.ID = ACCT.ID<1>

    RATE = 0
    ASST.LIAB = ''
    GOSUB GET.RATE

    TEMP.AMT = NOST.AMTS<XX>
    NOST.AMTS<XX> = ''
    IF TEMP.AMT GE 0 THEN
        ASST.LIAB = 1
    END ELSE
        ASST.LIAB = 2
    END
    NOST.AMTS<XX, ASST.LIAB> = TEMP.AMT
    NOST.RATES<XX, ASST.LIAB> = RATE
    TOT.NOSTRO<ASST.LIAB> += TEMP.AMT

    AMT.X.RATE = TEMP.AMT * RATE
    TEMP.PL = AMT.X.RATE / NUMERATOR
    NOST.PRFT.LOSS<XX, ASST.LIAB> = TEMP.PL
    ACTUAL.NOST.PL<ASST.LIAB> += TEMP.PL

    RETURN

*****************************************************************
GET.RATE:
*========

    INT.CODE<2> = ABS(AMT)
    tmp.PM$CCY = PM.Config.getCcy()
    PM.Reports.EPmAcRates(INT.CODE, tmp.PM$CCY, BASIS, ASST.LIAB, RATE)
    PM.Config.setCcy(tmp.PM$CCY)
    INT.CODE<1> = INT.CODE

    RETURN


INITIALISE:
*==========

* Initialise all variables and open files.

    EB.SystemTables.setFCurrency('')
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    EB.DataAccess.Opf('F.CURRENCY',tmp.F.CURRENCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)

    F.NOSTRO.ACCOUNT = ''
    FILE.NOSTRO.ACCOUNT = "F.NOSTRO.ACCOUNT"
    EB.DataAccess.Opf(FILE.NOSTRO.ACCOUNT,F.NOSTRO.ACCOUNT)

* Because this enquiry can be based on either todays file PM.DLY... or
* last nights file PM.NIGHT... fiel then we must be create a local
* variable for todays date (or last nights date) rather then use TODAY.

    PM.ENQ.TODAY = EB.SystemTables.getToday()

*
    DIM DPC.REC(50)
    DIM DPC.FILES(50)
    DIM INT.STR(20) ; MAT INT.STR = ''
    DIM AMT.STR(20) ; MAT AMT.STR = ''
    DIM PAL.STR(20) ; MAT PAL.STR = ''
    APPL.LIST = ''
    TOT.ASSET = 0
    TOT.LIABS = 0
    TOT.NOSTRO = 0
*
    NOST.AMTS = ''
    NOST.RATES = ''
    NOST.PRFT.LOSS = ''
*
    ACTUAL.PL = ''
    NOTIONAL.PL = ''
    ACTUAL.NOST.PL = 0
    NOTIONAL.NOST.PL = 0
    TOT.AMT.X.RATE = 0
    TOT.PAL = ''
    LIAB.RATE = 0
    ASSET.RATE = 0
    AVG.NOS.RATES = ''
    TXNS = ''

    RETURN


******
    END
