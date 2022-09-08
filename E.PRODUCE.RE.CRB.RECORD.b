* @ValidationCode : MjoxNTAxMjI3NzI6Y3AxMjUyOjE1NDM0OTY4OTQ4ODI6dnZpZ25lc2g6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2OjM3MzoxMTA=
* @ValidationInfo : Timestamp         : 29 Nov 2018 18:38:14
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : vvignesh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 110/373 (29.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-83</Rating>
*-----------------------------------------------------------------------------
$PACKAGE RE.ModelBank

SUBROUTINE E.PRODUCE.RE.CRB.RECORD
*
* Enquiry routine to populate the R.RECORD for producing CRB report
*----------------------------------------------------------------------
* Modification log:
*------------------
* 09/09/05 - EN_10002664
*            Restrucure of reporting pgms to consistantly
*            use RE.RETURN.EXTRACT
*
* 30/01/06 - GLOBUS_BG_100010124
*            Currency wise details and TOTAL line details not displaying
*            correctly - Resolved.
*
* 07/12/06 - CI_10045983
*            Customer name display problem in CRB report for SEC.TRADES.
*
* 23/04/07 - CI_10048592 / REF: HD0705746
*            When multiple languages are added in the description of the line,
*            CRB report displays all the language description as a whole
*
* 10/07/07 - CI_10050264 / REF: HD0710904
*            INTEREST.BASIS field included in Flat file CRF
*
* 12/09/07 - CI_10051354
*            EXCH RATE not being displayed in T24 reports.
*
* 13/11/07 - CI_10051354
*            In CRB report for JPY currency total lines updated with decimal.
*            The currency need to be passed in R.RECORD<2> to display the
*            decimals accordingly.
*
* 17/12/07 - CI_10052967-HD0720729/HD0719807
*            New line to be displayed for total that accounts due to
*            suppressed PL keys currencywise.
*            The line will not be displayed if the total for the PL keys is 0.
*            HD0719807:
*            0 should be displayed if total line amount is null.
*
* 02/09/08 - BG_100019742/Ref: TTS0803123
*            For accounts and internal accounts take the customer description from account itself.
*
* 09/03/09 - BG_100022538
*            CRB Report shows JPY currency amount in decimals for PL entries
*
* 17/08/09 - CI_10065412
*            The contract has to printed on the CRB report, even when there is a
*            value for the DEAL.LCY.BALANCE field.
*
* 21/12/09 - CI_10068367
*            When there is a change in REVAL.RATE of the currency after cob,
*            the CRB report which is produced online is not showing the correct
*            reval rate
*
* 06/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 24/08/12 - Task 468806
*            Total line description is not getting printed in CRB report.
*
* 16/04/2013 - DEFECT 639838 / TASK 651130
*              Dont Read the sec master or dealer desk when ROUNDING.ADJUSTMENT entry is present.
*
* 11/02/2014 - DEFECT 892673 / TASK 911397
*              Format the fields CCY AMT & CCY AMT LCY values here instead of formatting the
*              same in the enquiry. This change is done to include the parameter NEG.AMT.FORMAT
*              that is set in the RE.STAT.REPORT.HEAD, which was not handled earlier.
*-------------------------------------------------------------------------------------------------------
*
* 08/05/2013 - DEFECT 613988 / TASK 669804
*              Total line which has *ZZY will be processed so that if zero amount is present,
*              then zero will be suppressed.
*
* 23/10/2014 -  Defect 1147729 / Task 1147863
*               When ZERO.SUPP.TOT in RE.STAT.REPORT.HEAD is set to Y, the total line should not display the value 0 if
*               the total sums up to 0. The fix done through 669804 is reverted as the TOTAL lines need to be differentiated
*               from the TOTAL OF A LINE as both carry *ZZY suffixes.
*
* 14/01/2015 - Defect 1200127 / Task 1226509
*              When CRB report is generated online the system used TODAY's exchange rate to calculate LCY equivalent of
*              the contracts.
*
*
* 19/04/15 - Enhancement - 1263572
*            TO avoid duplicate common variables, frequent variables are added in
*            in a common insert file.
*
* 22/05/2015 - Defect 1333615 / Task 1353064
*              When short name for defined language code is unavailable in the customer record, before defaulting Y.CUST.NAME
*              to English, prefLang is set as 1 and call to CustomerService.getNameAddress is made again. So that
*              Y.CUST.NAME does not remains NULL.
*
*3/6/2017   -Defect 2124986/ Task 2146909
*             EB.EOD.REPORT.PRINT job running slow for CRB report
*
* 06/03/2018 - Defect 2482396 / Task 2488329
*              Uninitialized variable has been initialized.
*
* 29/11/18 - Enhancement 2822520 / Task 2879096
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*----------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.RE.EXTRACT.PARAMS
    $INSERT I_E.CRB.REPORT.COMMON
    $INSERT I_F.INTEREST.BASIS
    $INSERT I_F.RE.STAT.LINE.CONT
    $INSERT I_F.RE.STAT.LINE.BAL
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_CustomerService_NameAddress
    $INSERT I_F.ACCOUNT
    $INSERT I_F.COMPANY
    $INSERT I_F.DATES
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.DEALER.DESK
    $INSERT I_F.CURRENCY
    $INSERT I_BATCH.FILES
    $INSERT I_F.SPF
    $INSERT I_F.RE.STAT.REPORT.HEAD
    $INSERT I_RE.REPORT.GEN.FILES.COMMON
*---------------------------------------------------------------------
    
    YKEY = O.DATA
    YSLC.ID = FIELD(YKEY,'*',1)                    ;* Store the ID to read RE.STAT.LINE.CONT file
    YKEY.ID = FIELD(YKEY,'.',1)                    ;* Store the ID to read the RE.STAT.REPORT.HEAD file
    ENQ.ERROR = ''
    IF FIELD(YKEY,'*',4) = 'ZZY'  THEN
        RETURN      ;* Total will be takencare by key like ...TOTAL.
    END

    R.OUTPUT.RECORD = ''
    ER = '' ; R.RE.CRF.REPORT = ''
    R.SLC = ''
    CALL F.READ(FN.RE.CRF.REPORT,YKEY,R.RE.CRF.REPORT,F.RE.CRF.REPORT,ER)
    IF FIELD(YKEY,'*',2) = 'ZZY' OR ER THEN
        CALL F.READ(FN.RE.STAT.LINE.CONT, YSLC.ID, R.SLC, F.RE.STAT.LINE.CONT,SLC.ER)
    END

    IF ER THEN
        GOSUB BUILD.SLC.RECORD          ;* No line mvmts , just populate the header details
    END ELSE
        GOSUB BUILD.RE.CRF.RECORD       ;* Populate the line mvmt details etc...
    END

RETURN

*---------------------------------------------------------------------
BUILD.RE.CRF.RECORD:
*-----------------

    FCNT = 0
    R.RECORD = ''
    
    BEGIN CASE

        CASE R.SLC<RE.SLC.TYPE> EQ 'TOTAL'
            GOSUB PRINT.TOTAL

        CASE FIELD(YKEY,'*',3) = 'PROFIT'
            GOSUB PRINT.LINE.TOTAL.PROFIT

        CASE FIELD(YKEY,'*',2) = 'ZZY'
            GOSUB PRINT.LINE.TOTAL

        CASE FIELD(YKEY,'*',3) = 'TOTAL'
            GOSUB PRINT.CCY.LINE.TOTAL

        CASE FIELD(YKEY,'*',3) = 'ZZZMISMATCH'
            GOSUB PRINT.MISMATCH

        CASE R.RE.CRF.REPORT<DEAL.BALANCE.POSN> OR R.RE.CRF.REPORT<DEAL.LCY.BALANCE.POSN>     ;* CONTRACT LEVEL RECORD
            GOSUB PRINT.CONTRACT

    END CASE

RETURN

*---------------------------------------------------------------------
PRINT.LINE.TOTAL.PROFIT:
*----------------
* Prints the total for a line.
*
    R.RECORD = ''
    FCNT = 0
    NARR = ''
    R.AMT = ''
    FOR FIELD.NO = 1 TO DCOUNT(R.EXTRACT.PARAMS.REC<RE.EXP.REP.LINE.NARR>,@VM)
        NARR:= R.RE.CRF.REPORT<FIELD.NO+1>:' '
    NEXT FIELD.NO

    R.RECORD<1> = NARR
    R.RECORD<2> = FIELD(YKEY,'*',2)
    R.RE.STAT.LINE.BAL = ''
    SLB.ID = FIELD(FIELD(YKEY,'*',1,1),'.',1,2)
    CONVERT '.' TO '-' IN SLB.ID
    SLB.ID := '-':FIELD(YKEY,'*',2)

    GOSUB GET.PERIOD.END.DATE
    SLB.ID := '-PROFIT-':PERIOD.END.DATE

    IF C$MULTI.BOOK THEN SLB.ID :='*':ID.COMPANY

    CALL F.READ(FN.RE.STAT.LINE.BAL,SLB.ID,R.RE.STAT.LINE.BAL,F.RE.STAT.LINE.BAL,'')
*The line will not be displayed if the total for the PL keys is 0.
    IF (R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL> EQ '') AND (R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL.LCL> EQ '') THEN
        R.RECORD = ''
        RETURN
    END

    R.AMT = R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<4> = R.RETURN.AMT
    END

    R.AMT = R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL.LCL>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<5> = R.RETURN.AMT
    END

RETURN
*-----------------------------------------------------------------------
*-------------
PRINT.CONTRACT:
*----------------
    CONSOL.KEY = ""
    Y.APPLN = ""
    R.RECORD = ''
    FCNT = 0
* Contract.id
    FCNT+ =1
    R.RECORD<FCNT> = FIELD(YKEY, '*',4)

* Currency
    FCNT +=1
    R.RECORD<FCNT> = R.RE.CRF.REPORT<CURRENCY.POSN>

* Customer No
    FCNT +=1

    CONSOL.KEY = FIELD(YKEY,'*',3)
    Y.APPLN = FIELD(CONSOL.KEY, '.',1)

    BEGIN CASE

        CASE Y.APPLN = "AL"

            Y.DEALER.DESK.ID = FIELD(YKEY, '*',4)
            Y.DEAL.ID = Y.DEALER.DESK.ID[13,2]
            IF Y.DEALER.DESK.ID NE "ROUNDING.ADJUSTMENT" THEN
                GOSUB GET.DEALER.DESK
            END ELSE
                Y.CUST.NAME = '' ;* Nullify the customer details
            END

        CASE Y.APPLN NE "SC"

            FIELD.NAME = 'CUSTOMER.NO'
            GOSUB GET.FIELD.VALUE
            Y.CUS.NO = RESULT
            GOSUB GET.CUST.DESC

        CASE 1

            Y.SC.TRADING.POSITION.ID = FIELD(YKEY, '*',4)
            Y.SECURITY.MASTER.ID = FIELD(Y.SC.TRADING.POSITION.ID, '.',2)
            IF Y.SC.TRADING.POSITION.ID NE "ROUNDING.ADJUSTMENT" THEN
                GOSUB GET.SECURITY.DESC
            END ELSE
                Y.CUST.NAME = '' ;* Nullify the customer details
            END

    END CASE

    R.RECORD<FCNT> = Y.CUST.NAME

* Foreign amount
    FCNT+=1
    R.AMT = R.RE.CRF.REPORT<DEAL.BALANCE.POSN>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<FCNT> = R.RETURN.AMT
    END

* local amount
    FCNT+=1
    R.AMT = R.RE.CRF.REPORT<DEAL.LCY.BALANCE.POSN>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<FCNT> = R.RETURN.AMT
    END

*DEAL RATE

    FIELD.NAME = 'DEAL.RATE'
    GOSUB GET.FIELD.VALUE
    FCNT +=1
    R.RECORD<FCNT> = RESULT

*INT RATE BASIS

    FIELD.NAME = 'INT.RATE.BASIS'
    GOSUB GET.FIELD.VALUE
    FCNT +=1
    R.RECORD<FCNT> = RESULT

* VALUE DATE
    FIELD.NAME = 'DEAL.VALUE.DATE'
    GOSUB GET.FIELD.VALUE
    FCNT +=1
    R.RECORD<FCNT> = RESULT

* MAT DATE
    FIELD.NAME = 'DEAL.MAT.DATE'
    GOSUB GET.FIELD.VALUE
    FCNT +=1
    R.RECORD<FCNT> = RESULT

RETURN

*******************************************************
PRINT.TOTAL:
****************
    FCNT = 0
    R.RECORD = ''
    NARR = ''
    FOR FIELD.NO = 1 TO DCOUNT(R.EXTRACT.PARAMS.REC<RE.EXP.REP.LINE.NARR>,@VM)
        NARR:= R.RE.CRF.REPORT<FIELD.NO+1>:' '
    NEXT FIELD.NO
    R.RECORD<1> = NARR
    R.AMT = R.RE.CRF.REPORT<LINE.TOTAL.POSN>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<5> = R.RETURN.AMT
    END

RETURN
*------------------------------------------------------------------
PRINT.CCY.LINE.TOTAL:
*-------------------
    R.AMT = ''
    R.RE.STAT.LINE.BAL = ''
    SLB.ID = FIELD(FIELD(YKEY,'*',1,1),'.',1,2)
    CONVERT '.' TO '-' IN SLB.ID
    Y.CCY = FIELD(YKEY,"*",2,1)
    SLB.ID = SLB.ID:'-':Y.CCY

    GOSUB GET.PERIOD.END.DATE
    SLB.ID := '-':PERIOD.END.DATE

    IF C$MULTI.BOOK THEN
        SLB.ID :='*':ID.COMPANY
    END

    CALL F.READ(FN.RE.STAT.LINE.BAL,SLB.ID,R.RE.STAT.LINE.BAL,F.RE.STAT.LINE.BAL,'')

    R.RECORD = ''
    R.RECORD<1> = 'TOTAL LINE FOR CURRENCY ': FIELD(YKEY,'*',2)
    R.RECORD<2> = FIELD(YKEY,'*',2)
    R.AMT = R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL>
    IF R.AMT NE '' THEN
        CCY = R.RECORD<2>
        GOSUB CURRENCY.FORMAT
        R.RECORD<4> = R.RETURN.AMT
    END ELSE
        R.RECORD<4> = "0"
    END

    R.AMT = R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL.LCL>
    IF R.AMT NE '' THEN
        CCY = R.RECORD<2>
        GOSUB CURRENCY.FORMAT
        R.RECORD<5> = R.RETURN.AMT
    END ELSE
        R.RECORD<5> = "0"
    END
*
* Adding the exchange rate of the currency to display in the TOTAL line

    Y.CCY.ID = FIELD(YKEY,'*',2)

    IF RUNNING.UNDER.BATCH AND R.SPF.SYSTEM<SPF.OP.MODE> = 'B' AND TODAY = C$BATCH.START.DATE THEN
        HIS.DATE = TODAY
    END ELSE
        HIS.DATE = R.DATES(EB.DAT.LAST.WORKING.DAY)
    END

    IF Y.CCY.ID NE LCCY THEN
        Y.CCY.BALANCE = 100 ; Y.CONV.BALANCE = "" ; YEXCHANGE.RATE = ""
        R.CCY.REC = '' ; ER = '' ; POS = ''
        CALL GET.CCY.HISTORY(HIS.DATE,Y.CCY.ID, R.CCY.REC, "")
        LOCATE '1' IN R.CCY.REC<EB.CUR.CURRENCY.MARKET,1> SETTING POS THEN
            YEXCHANGE.RATE = R.CCY.REC<EB.CUR.REVAL.RATE,POS>
        END ELSE
            POS = ''
        END
        IF YEXCHANGE.RATE EQ '' THEN                    ;* If reval rate value is null, get rate from MID.REVAL.RATE for the HIS.DATE this is done in MIDDLE.RATE.CONV.CHECK
            Y.CCY.ID = Y.CCY.ID:@VM:HIS.DATE
        END
        CALL MIDDLE.RATE.CONV.CHECK(Y.CCY.BALANCE, Y.CCY.ID, YEXCHANGE.RATE, '1' , Y.CONV.BALANCE, "" , "" )

        R.RECORD<6> = YEXCHANGE.RATE
    END
*
RETURN
*------------------------------------------------------------------
PRINT.MISMATCH:
*-------------------
    R.RECORD = ''
    FCNT = 0
    R.RECORD = ''
    R.AMT = ''
    R.RECORD<1> = '***BALANCE MISMATCH IN CRF KEY TYPE '
    R.RECORD<3> = FIELD(YKEY,'*',4)
    R.AMT = R.RE.CRF.REPORT<FOREIGN.BALANCE.POSN>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<5> = R.RETURN.AMT
    END

    R.AMT = R.RE.CRF.REPORT<DEAL.BALANCE.POSN>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<5> = R.RETURN.AMT
    END

RETURN
*--------------------------------------------------------------------
GET.FIELD.VALUE:
*--------------

    RESULT = '' ; FIELD.NO = ''
    LOCATE FIELD.NAME IN FIELD.NAME.POS<1,1> SETTING POS THEN
        FIELD.NO = FIELD.NAME.POS<1,POS>
    END ELSE
        LOCATE FIELD.NAME IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING SS.POS THEN
            FIELD.TYPE = SS.RECORD<SSL.SYS.TYPE,SS.POS>
            BEGIN CASE
                CASE FIELD.TYPE = 'D'       ;* Normal data field
                    FIELD.NO = SS.RECORD<SSL.SYS.FIELD.NO,SS.POS>         ;* Convert to field number
                CASE FIELD.TYPE = 'I' OR FIELD.TYPE = 'J'       ;* Idescriptors
                    FIELD.NO = FIELD.NAME   ;* Use the name instead
            END CASE
            FIELD.NAME.POS<1,SS.POS> = FIELD.NO
        END
    END

    BEGIN CASE
        CASE FIELD.NO = ''
            RESULT = ''
        CASE FIELD.NO = 0
            RESULT = O.DATA
        CASE NUM(FIELD.NO)
            RESULT = R.RE.CRF.REPORT<FIELD.NO>
        CASE OTHERWISE
            CALL IDESC(FN.RE.CRF.REPORT,O.DATA,R.RE.CRF.REPORT,FIELD.NO,RESULT)
    END CASE

RETURN
*---------------------------------------------------------------------
BUILD.SLC.RECORD:
*---------------
    IF R.SLC<RE.SLC.TYPE> NE 'TOTAL' THEN
        FCNT = 0
        R.RECORD = ''
* Field 1
        FCNT+ =1
        R.RECORD<FCNT> = FIELD(YKEY,'*',1)
        R.RECORD<FCNT> = FIELD(R.RECORD<FCNT>, '.',2)

* Field 2
        NARR = ''
        FOR FIELD.NO = 1 TO DCOUNT(R.EXTRACT.PARAMS.REC<RE.EXP.REP.LINE.NARR>,@VM)
            IF R.SLC<RE.SLC.DESC,FIELD.NO,LNGG> <> '' THEN
                NARR:= R.SLC<RE.SLC.DESC,FIELD.NO,LNGG>:' '
            END ELSE
                NARR:= R.SLC<RE.SLC.DESC,FIELD.NO,1>:' '
            END
        NEXT FIELD.NO
        R.RECORD<FCNT> = NARR
    END

RETURN

*-----------------------------------------------------------------------------
PRINT.LINE.TOTAL:
*----------------
* Prints the total for a line.
*
    R.RECORD = ''
    FCNT = 0
    NARR = ''
    R.AMT = ''
    FOR FIELD.NO = 1 TO DCOUNT(R.EXTRACT.PARAMS.REC<RE.EXP.REP.LINE.NARR>, @VM)
        NARR:= R.RE.CRF.REPORT<FIELD.NO+1>:' '
    NEXT FIELD.NO

    R.RECORD<1> = 'TOTAL FOR ': NARR

    R.RE.STAT.LINE.BAL = ''
    SLB.ID = FIELD(FIELD(YKEY,'*',1,1),'.',1,2)
    CONVERT '.' TO '-' IN SLB.ID

    GOSUB GET.PERIOD.END.DATE
    SLB.ID := '-LOCAL-':PERIOD.END.DATE

    IF C$MULTI.BOOK THEN
        SLB.ID :='*':ID.COMPANY
    END

    CALL F.READ(FN.RE.STAT.LINE.BAL,SLB.ID,R.RE.STAT.LINE.BAL,F.RE.STAT.LINE.BAL,'')

    R.AMT = R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<4> = R.RETURN.AMT
    END

    R.AMT = R.RE.STAT.LINE.BAL<RE.SLB.CLOSING.BAL.LCL>
    IF R.AMT NE '' THEN
        GOSUB CURRENCY.FORMAT
        R.RECORD<5> = R.RETURN.AMT
    END


RETURN
*-----------------------------------------------------------------------
GET.PERIOD.END.DATE:
*-------------------
* Get the correct PERIOD.END date
*

    BEGIN CASE
        CASE  R.SPF.SYSTEM<SPF.OP.MODE> = 'O' OR (C$BATCH.START.DATE NE TODAY)
            PERIOD.END.DATE = R.DATES(EB.DAT.LAST.PERIOD.END)
        CASE RUNNING.UNDER.BATCH
            PERIOD.END.DATE = R.DATES(EB.DAT.PERIOD.END)
        CASE 1
            PERIOD.END.DATE = TODAY
            CALL CDT("", PERIOD.END.DATE, "-1W")
            IF PERIOD.END.DATE[5,2] NE TODAY[5,2] THEN          ;* Make the previous month end
                PERIOD.END.DATE = TODAY[1,6]:'01'
                CALL CDT('', PERIOD.END.DATE, '-1C')
            END ELSE
                PERIOD.END.DATE = TODAY
                CALL CDT('',PERIOD.END.DATE,'-1C')
            END
    END CASE

RETURN
*-----------------------------------------------------------------------
GET.DEALER.DESK:
*--------------
    READV Y.CUST.NAME FROM F.DEALER.DESK, Y.DEAL.ID, FX.DD.DESCRIPTION ELSE
        Y.CUST.NAME = "MISSING DEALER DESK ":Y.DEAL.ID
    END
    IF Y.CUST.NAME<1,R.COMPANY(EB.COM.LANGUAGE.CODE)> THEN
        Y.CUST.NAME = Y.CUST.NAME<1,R.COMPANY(EB.COM.LANGUAGE.CODE)>
    END ELSE
        Y.CUST.NAME = Y.CUST.NAME<1,1>  ;* Default to English
    END

RETURN
*-------------------------------------------------------------------------------------------
GET.SECURITY.DESC:
*----------------
    READV Y.CUST.NAME FROM F.SECURITY.MASTER, Y.SECURITY.MASTER.ID, SC.SCM.SHORT.NAME ELSE
        Y.CUST.NAME = "MISSING SECURITY MASTER ":Y.SECURITY.MASTER.ID
    END
    IF Y.CUST.NAME<1,R.COMPANY(EB.COM.LANGUAGE.CODE)> THEN
        Y.CUST.NAME = Y.CUST.NAME<1,R.COMPANY(EB.COM.LANGUAGE.CODE)>
    END ELSE
        Y.CUST.NAME = Y.CUST.NAME<1,1>  ;* Default to English
    END

RETURN
*------------------------------------------------------------------------------------
GET.CUST.DESC:
*------------
    IF Y.APPLN = 'AC' THEN    ;* For accounts/internal accounts always take from Account itself.
        Y.ACC.NO = FIELD(YKEY,'*',4)
        READV Y.CUST.NAME FROM F.ACCOUNT, Y.ACC.NO, AC.ACCOUNT.TITLE.1 THEN     ;* For accounts and internal accounts
        END
        RETURN
    END
    customerId = Y.CUS.NO
    prefLang = LNGG
    customerNameAddress = ''
    customerName = ''
* get the Customer Name
    CALL CustomerService.getNameAddress(customerId, prefLang, customerNameAddress)
    Y.CUST.NAME = customerNameAddress<NameAddress.shortName>
    IF Y.CUST.NAME<1,R.COMPANY(EB.COM.LANGUAGE.CODE)> THEN
        Y.CUST.NAME = Y.CUST.NAME<1,R.COMPANY(EB.COM.LANGUAGE.CODE)>
    END ELSE
        prefLang = 1
        CALL CustomerService.getNameAddress(customerId, prefLang, customerName)
        Y.CUST.NAME = customerName<NameAddress.shortName>
        Y.CUST.NAME = Y.CUST.NAME<1,1>        ;* Default to English
    END

RETURN
*------------------------------------------------------------------------------------
CURRENCY.FORMAT:
*---------------
* Read the NEG.AMOUNT.FORMAT from the file RE.STAT.REPORT.HEAD, and FORMAT the amount
* using FMT by passing the negative value format.

    R.RETURN.AMT = ''
    GOSUB GET.NEGATIVE.AMT.FORMAT

    R.RETURN.AMT = FMT(R.AMT,NEG.AMOUNT.FORMAT)

RETURN
*------------------------------------------------------------------------------------
GET.NEGATIVE.AMT.FORMAT:
*-----------------------
    ERR = ''
    NEG.AMOUNT.FORMAT = ''
    CALL CACHE.READ('F.RE.STAT.REPORT.HEAD',YKEY.ID,R.RE.STAT.REPORT.HEAD,ERR)
    NEG.AMOUNT.FORMAT =  ',' :R.RE.STAT.REPORT.HEAD<RE.SRH.NEG.AMT.FORMAT>
RETURN
*------------------------------------------------------------------------------------

END
