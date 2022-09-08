* @ValidationCode : MjotMTE5MDE5ODIzOTpjcDEyNTI6MTUwMzM5NDg0NjE3MzpkaXZ5YWxha3NobWl2OjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA3LjIwMTcwNjE0LTAwNDI6MTUxOjEzMQ==
* @ValidationInfo : Timestamp         : 22 Aug 2017 15:10:46
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : divyalakshmiv
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 131/151 (86.7%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170614-0042
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>115</Rating>
*-----------------------------------------------------------------------------
* Version 3 29/09/00  GLOBUS Release No. G11.0.00 29/06/00
*     GLOBUS Release No 14.2.0   = 23/09/94
$PACKAGE AC.ModelBank

SUBROUTINE E.ACCT.AVERAGE.BAL
*-----------------------------------------------------------------------------

* Subroutine to calculate average balances for accounts
* between two given dates.
* Subroutine called from ACCT.AVERAGE.BAL enquiry.
* Incoming O.Data variable = &#1;Account.no, Start date, End date
* Outgoing O.Data variable = Days in Credit , Avrg Credit Balance
*                            Days in Debit , Avrg Debit Balance
*                            Number of days at Zreo balance
*
* 02/08/95  GB9500911
*           Amended due to CALC.FIELDS which sets up the totals to pass
*           back to the enquiry only being called if the date is for the
*           same month as the last activity.  Also, CNT not being reset
*           for each month.
*
* 06/09/02 - GLOBUS_EN_10001086
*          Conversion Of all Error Messages to Error Codes
*
* 14/11/02 - CI_10004707
*            On running the enquiry some messages appearing because the
*            variables TOT.CR.BAL and TOT.DR.BAL are not initialised.
*
* 10/09/08 - EN_10003825
*            Removal of ACCT.ACCT.ACTIVITY.
*
* 28/07/09 - EN_10004211
*            ACCT.BALANCE.ACTIVITY.
*
* 20/08/11 - ENHANCEMENT 211022 / TASK 211273
*            Acct Activity Merger for High Volume Account
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 02/07/14 - Defect - 993038 / Task - 1047286
*            If accout number passed is an AR account, then get the property
*            associated with ACCOUNT property class (E.x: CURACACCOUNT) and
*            calculate average balance for that balance type alone.
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 18/11/16 - EN_1917843 / TASK_1930455
*            Incorrect account number passed to AC.CHECK.HVT
*
* 27/07/16 - Defect 2199227 / Task 2213492
*            Average balance is not calculated properly as the last day is not included
*
*************************************************************************

    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING AC.BalanceUpdates
    $USING EB.API
    $USING AC.HighVolume

*************************************************************************
    GOSUB INITIALISE ; * Initialise required variables
    GOSUB PROCESS ; * Do the actual process

RETURN
*
*-----------------------------------------------------------------------------
GET.ACCT.ACTIVITY.DATES:
*----------------------
    ACTIVITY.IDS = ''
    ACTIVITY.RECS = ''
    YR.YEARM = ''

    PRG.NAME = 'AC.CHECK.HVT'
    RETURN.INFO = ''
    HVT.PROCESS = ''
* To avoid component dependency below code is added
* First check if the common api exist and call the API to get HVT flag
* if the routine not exist then use HVT flag in account
    AC.HighVolume.CheckHvt(ACCOUNT.NO[".",1,1], R.ACCOUNT, '', '', HVT.PROCESS, '', '', ERR)

* Removed the direct check for HVT.FLAG in account record, use the common routine
* to check the HVT flag, since the when the AC.HVT.PARAMETER is setup HVT.FLAG will not be
* defaulted by the system in the account, dynamically HVT flag is decided based on parameter

    IF HVT.PROCESS EQ 'YES' THEN
        ACTIVITY.DETAILS = ''
        ACTIVITY.DETAILS = 'ALL' ;* Set this flag to return all the acct activity details
        AC.HighVolume.EbReadHvt('ACCT.ACTIVITY', ACCOUNT.NO, ACTIVITY.DETAILS, '') ;* Call the core api to get the merged info for HVT accounts
        ACTIVITY.IDS = RAISE(ACTIVITY.DETAILS<1>)
        ACTIVITY.RECS = RAISE(ACTIVITY.DETAILS<2>)
        YR.YEARM = RAISE(ACTIVITY.DETAILS<3>)
    END ELSE
        EB.API.GetActivityDates(ACCOUNT.NO, YR.YEARM)
    END

RETURN
*-----------------------------------------------------------------------------
*****************************
* Calculate account balances
*  cr bal, dr bal, no of days at dr, cr and zero bal
*****************************
CALC.FIELDS:

    NO.DAYS = "C"
    EB.API.Cdd("",CURR.DATE,REC.DATE,NO.DAYS)
    CURR.DATE = REC.DATE
    NEW.BAL = ACCREC<AC.BalanceUpdates.AcctActivity.IcActBalance,CNT>
*
    IF REC.DATE EQ END.DATE AND END.FLAG THEN
        NO.DAYS+=1
    END
    
    BEGIN CASE
        CASE ACCOUNT.BAL < 0
            DR.DAYS += NO.DAYS
            DR.BAL = NO.DAYS * ACCOUNT.BAL
            TOT.DR.BAL += DR.BAL
        CASE ACCOUNT.BAL = "0"
            ZERO.DAYS += NO.DAYS
        CASE ACCOUNT.BAL > 0
            CR.DAYS += NO.DAYS
            CR.BAL = NO.DAYS * ACCOUNT.BAL
            TOT.CR.BAL += CR.BAL
    END CASE
*
    ACCOUNT.BAL = NEW.BAL

RETURN
*
*--------------------------------------------------------------
FINAL.CALC:
* Credit bal - ie av credit bal for tot time in credit
    IF CR.DAYS AND CR.DAYS <> 0 THEN
        CR.AV.BAL = TOT.CR.BAL/CR.DAYS
        EB.API.RoundAmount(CURRENCY,CR.AV.BAL,"","")
    END
* Debit bal - ie av debit bal for total time in debit
    IF DR.DAYS AND DR.DAYS <> 0 THEN
        DR.AV.BAL = TOT.DR.BAL/DR.DAYS
        EB.API.RoundAmount(CURRENCY,DR.AV.BAL,"","")
    END
*
* Convert to O.Data for return to enquiry
*
    EB.Reports.setOData(CR.DAYS:">":CR.AV.BAL:">":DR.DAYS:">":DR.AV.BAL:">":ZERO.DAYS)
RETURN

*--------------------------------------------------------------
*
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
*  Initialise Variables
***************************
*
    ACCOUNT.DETAILS = EB.Reports.getOData()
    EB.Reports.setOData("")
    START.DATE = ACCOUNT.DETAILS[1,8]
    END.DATE = ACCOUNT.DETAILS[9,8]
    ACCOUNT.NO = ACCOUNT.DETAILS[17,16]
    ACCREC = ""
    NO.DAYS = "C"
    ZERO.DAYS = "0"
    DR.DAYS = "0"
    CR.DAYS = "0"
    DR.AV.BAL = "0"
    CR.AV.BAL = "0"
    CURR.DATE = START.DATE
    ACCOUNT.BAL = ""
    START.YRMN = START.DATE[1,6]
    START.DAY = START.DATE[7,2]
    END.YRMN = END.DATE[1,6]
    END.DAY = END.DATE[7,2]
    CURRENCY = ""
    END.FLAG = 0
    CNT = 1

    TOT.CR.BAL = ''                    ; * CI_10004707s
    TOT.DR.BAL = ''                    ; * CI_10004707e
    ACC.BALANCE.TYPE = ''
    R.ARRANGEMENT = ''
    RET.ERROR = ''
    ACCOUNT.VALID = 1  ;* If account is not an AR Account, this flag will be cleared.
    ACC.PROPERTY.CLASS = 'ACCOUNT'
* For fetching the property associated to the ACCOUNT property class, the API AA.GET.BALANCE.TYPE is called.
* This will return actual property class only when it is called from accounting(Based on the 6th part in AA.ITEM.REF
* in entry). In other cases it will return suspense category(AASUSPENSE).
* E.x: AA.ITEM.REF = ACCOUNTS-CREDIT-ARRANGEMENT*20091223*US0010001*AA093577GY4F**DIRECT*AAACT093570CCNQL4B
* To get the actual property class,  a dummy AA.ITEM.REF is passed with 6th part as "DIRECT".
    DUMMY.AA.ITEM.REF = "*****DIRECT*"

*
*  Check startdate not greater than enddate
*
    IF START.DATE > END.DATE THEN
        EB.SystemTables.setEtext("AC.RTN.START.DATE.GT.THAN.END.DATE")
        GOSUB PGM.EXIT
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
*  Call routine to extract opening balance
*
    AC.BalanceUpdates.GetEnqBalance(ACCOUNT.NO,START.DATE,ACCOUNT.BAL)
*
*  Open and read account file to extract currency
*
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.NO,READ.ERR)
    CURRENCY = R.ACCOUNT<AC.AccountOpening.Account.Currency>
    HVT.PROCESS = ''          ;* Flag to indicate the account HVT flag

* Fetch the property associated with the ACCOUNT property class.
* e.x: CURACACCOUNT.
* Suffix the balance type with Account no and get the activity record for that balance type.
*
    IF  R.ACCOUNT<AC.AccountOpening.Account.ArrangementId> NE '' THEN
        ARRANGEMENT.ID = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>
        AA.Framework.GetArrangement(ARRANGEMENT.ID, R.ARRANGEMENT, RET.ERROR) ;* Get the arrangement details
        IF R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine> EQ "ACCOUNTS" THEN ;* Check whether the account belongs to ACCOUNTS product line.
            AA.Framework.GetBalanceType(ACC.PROPERTY.CLASS,ARRANGEMENT.ID,ACC.BALANCE.TYPE,DUMMY.AA.ITEM.REF,'','',RET.ERROR)
            ACCOUNT.NO = ACCOUNT.NO:'.':ACC.BALANCE.TYPE
        END  ELSE
* This is not an AR account e.x: Accounts created for Deposits or Lending.
* If ACCOUNT.VALID flag is cleared, no records will be dispalyed.
            ACCOUNT.VALID = ''
        END
    END
*
*   Get account activity dates
*
    GOSUB GET.ACCT.ACTIVITY.DATES
****************************************************
* Main process
****************************************************
    LOCATE START.YRMN IN YR.YEARM<1> BY "AR" SETTING YLOC ELSE
        NULL
    END
    LOOP
        IF YR.YEARM<YLOC> <> "" THEN
*
*  Read Acct.Activity records while valid dates exist
*
            ACCID = ACCOUNT.NO:"-":YR.YEARM<YLOC>
            ACCREC = ""
            IF HVT.PROCESS EQ 'YES' THEN
                LOCATE ACCID IN ACTIVITY.IDS BY 'AL' SETTING READ.POS THEN
                    ACCREC = RAISE(ACTIVITY.RECS<READ.POS>)
                END ELSE
                    AC.BalanceUpdates.EbReadAcctActivityRecord(ACCID, ACCREC, "", READ.ERR)
                END
            END ELSE
                AC.BalanceUpdates.EbReadAcctActivityRecord(ACCID, ACCREC, "", READ.ERR)
            END
            IF READ.ERR THEN
                EB.SystemTables.setEtext("AC.RTN.NO.AC.ACTIVITY.ON.REC")
                GOSUB PGM.EXIT
            END
*
*
*  Process all Acct.Activity record for valid date and call calc process
*
            D.FLAG = 0
            CNT = 1
            LOOP
            WHILE ACCREC<AC.BalanceUpdates.AcctActivity.IcActDayNo,CNT> <> "" AND D.FLAG = 0
                REC.DATE = YR.YEARM<YLOC> : ACCREC<AC.BalanceUpdates.AcctActivity.IcActDayNo,CNT>
                IF REC.DATE >= START.DATE AND REC.DATE <= END.DATE THEN
                    GOSUB CALC.FIELDS
                END ELSE
                    IF REC.DATE >= START.DATE THEN
                        REC.DATE = END.DATE
                        D.FLAG = 1
                    END
                END
                CNT += 1
            REPEAT
            YLOC +=1
        END ELSE
            REC.DATE = END.DATE
            END.FLAG = 1
        END
    WHILE END.YRMN GE YR.YEARM<YLOC> AND END.FLAG = 0
    REPEAT
    REC.DATE = END.DATE
    END.FLAG = 1        ;* When queried for previous month End flag is not set for the additional day fix to work
* Everytime end date is set as Rec date, the end flag needs to be    END.FLAG = 1        ;* When queried for previous month End flag is not set for the additional day fix to work
* Everytime end date is set as Rec date, the end flag needs to be set set
* For legacy accounts, this flag will be 1 always.
* For AA accounts, ACCOUNT.VALID is set only for AR accounts.
    IF ACCOUNT.VALID THEN
        GOSUB CALC.FIELDS
        GOSUB FINAL.CALC
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*
PGM.EXIT:
    EB.SystemTables.setComi("")
*-----------------------------------------------------------------------------
*
END


