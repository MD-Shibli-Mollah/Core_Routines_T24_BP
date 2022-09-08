* @ValidationCode : MjoxMDY1NjA3NjgwOkNwMTI1MjoxNDk1ODExMzA1NjUzOnNlbGF5YXN1cml5YW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwNS4yMDE3MDUwNS0xNDQ4Oi0xOi0x
* @ValidationInfo : Timestamp         : 26 May 2017 20:38:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : selayasuriyan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201705.20170505-1448
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-159</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PM.Reports
SUBROUTINE E.PM.NOS.TXNS

* This routine is similar to E.PM.GET.TXN.DTLS but is specific to the
* PM.NOS enquiry. Signs on the amounts are reversed so that a credit to
* a NOSTRO or a credit balance is displayed as a -ve. In addition a total
* per transaction is calculated.
*
* A list of PM.DLY.POSN.CLASS ids (in date order per ccy) is passed
* in and a sorted list of transactions and their respective amounts
*
*  INPUT
*  =====
*  ENQ.KEYS     -  Record ID for PM.DLY.POSN.CLASS
*
*  OUTPUT
*  ======
*  R.RECORD     - A record in the format of PM.DLY.POSN.CLASS with the
*                 following additional associated multi value fields
*                 R.RECORD<10> = List of TXn ids
*                         <11> = List of position classes
*                         <12> = List os transaction amounts
*                         <13> = list of totals per transaction
*                         <14> = List of formated transaction amounts
*                         <15> = List of formated closing balances

* 24/02/97 - GB9700212
*            The program used to stop looking for multiple amount
*            entries once a match was found. It has now been changed
*            to create multiple entries for multiple amounts on the
*            PM.TRAN.ACTIVITY file for a particular TXN.ID
*
* 13/08/97 - GB9700938
*            Format to 19 digits and corect decimal places.
*            Add the Days closing balance calcualtion and
*            formatting to this program
*            Do not chnage sign for addition to balnce
*            depending upon formatting onlt do this at
*            print time
*
* 22/01/08 - CI_10053403
*            We don't need the cycle.data variable anymore
*
* 26/03/10 - Defect-32890/Task-34246
*            EXECUTE changed to DAS
*
* 19/11/10 - Defect 102382 / Task 109383
*           Transaction reference for entitlements are referred incorrectly.
*
* 12/07/11 - Defect 240827 / Task 242920
*            For the  Enquiry PM.NOS, during drill down to the second level,
*            System is taking take time to display the records.
*
* 28/11/11 - Defect 303719 / Task 315980
*            PM.NOS enquiry keeps timing out when navigated to last page and display
*            "Connection Timeout or invalid message returned from JMS queue" in Browser.
*
* 15/12/11 - Defect 321974 / Task 324587
*            Drilldown to PM.NOS enquiry doesn't show all the informations.
*
* 23/02/12 - Defect 328742/Task 360806
*            Issue with slow launching of drill down enquiries DPC.TXNS and PM.NOSTRO.TXNS
* 08/07/13 - Defect 709721/Task 715206
*			 ENQ PM.NOS has incorrect delimiters "." & "," in the transaction amount.
**
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
* 26/05/17 - Defect 2127307 / Task 2129237
*            The balance shown in PM.NOS enquiry's DRILL DOWN has not included the OPENING.BALANCE.
*
************************************************************************************************

    COM /E.PMGTA/ FLD.LIST, F.PM.DPC, F.PM.TRAN.ACTIVITY, SIGN, RUNNING.BALANCE, CCY.DECIMALS, DPC.KEYS


    $USING ST.CompanyCreation
    $USING PM.Engine
    $USING PM.Config
    $USING EB.DataAccess
    $USING EB.API
    $USING ST.CurrencyConfig
    $USING PM.Reports
    $USING EB.SystemTables
    $USING EB.Reports

    $INSERT I_DAS.PM.DRILL.DOWN

* split O.DATA
    tmp.O.DATA = EB.Reports.getOData()
    OPEN.BALANCE = FIELD(tmp.O.DATA, ">", 2)
    TYPE = FIELD(tmp.O.DATA, ">", 1)
    IF TYPE = "SETUP" THEN
        GOSUB SETUP.COMMON
        RETURN
    END
*
* Initialise the fields to be used on R.RECORD.
*

    tmp=EB.Reports.getRRecord(); tmp<10>=""; EB.Reports.setRRecord(tmp);* TXN id
    tmp=EB.Reports.getRRecord(); tmp<11>=""; EB.Reports.setRRecord(tmp);* TXN position class
    tmp=EB.Reports.getRRecord(); tmp<12>=""; EB.Reports.setRRecord(tmp);* TXN amounts
    tmp=EB.Reports.getRRecord(); tmp<13>=""; EB.Reports.setRRecord(tmp);* TXN totals
    tmp=EB.Reports.getRRecord(); tmp<14>=""; EB.Reports.setRRecord(tmp);* TXN formated amounts
    tmp=EB.Reports.getRRecord(); tmp<15>=""; EB.Reports.setRRecord(tmp);* Closing formated balance

    ROUND.TYPE = 1

* Add the current ID back into ENQ.KEYS.

    tmp.ID = EB.Reports.getId()
    CHECK.DATE = FIELD(tmp.ID, ".", 6)
    SAVE.ID = EB.Reports.getId()
    TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
    INS EB.Reports.getId() BEFORE TEMP.ENQ.KEYS<1>
    EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)

* Now loop through each of the PM.DLY.POSN.CLASS ids passed until the
* date changes. For all DPC records for a given date (CHECK.DATE)
* assemble a list of transcations and their details and return in
* R.RECORD.

    PREV.ID = ""
    EXIT.LOOP = ""
    Y.CUR.DPC.ID = ""
    Y.OLD.DPC.ID = ""
    Y.ARG = ""
    LOOP
*
* GB9600737
*
        DP.ID = EB.Reports.getEnqKeys()<1>
        DPC.ID = FIELD(DP.ID,'*',1)
        DPC.CLASS = FIELD(DPC.ID, ".", 1)
        DPC.DATE = FIELD(DPC.ID, ".", 6)
        DPC.CURRENCY = FIELD(DPC.ID,".",5)
        IF DPC.DATE > CHECK.DATE THEN
            EXIT.LOOP = 1
        END ELSE
            TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
            DEL TEMP.ENQ.KEYS<1>
            EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)
        END
    UNTIL EXIT.LOOP OR DPC.ID = ""
        MNE = FIELD(DP.ID,'*',2)
        IF DPC.ID[1,2] = "AC" THEN
            GOSUB READ.DPC.REC
            GOSUB GET.AC.TXNS
        END ELSE
            DPC.CHK = DPC.ID['.',1,6]
            LOCATE DPC.CHK:MNE IN DPC.KEYS SETTING DP.POS ELSE
                DPC.KEYS<-1> = DPC.CHK:MNE
                Y.ARG<-1> = DPC.CHK
            END
            Y.CUR.DPC.ID = DPC.ID[1,2]
            IF Y.OLD.DPC.ID EQ '' THEN
                Y.OLD.DPC.ID = Y.CUR.DPC.ID ;* assign this only for the first time
            END
            IF Y.OLD.DPC.ID NE Y.CUR.DPC.ID THEN
                Y.OLD.DPC.ID = Y.CUR.DPC.ID
                GOSUB SELECT.DRILL.DOWN
                Y.ARG = ''    ;* reinitialise for new selection only based on these posn classes
            END
        END
        Y.OLD.DPC.ID = Y.CUR.DPC.ID
    REPEAT
    IF Y.ARG THEN
        GOSUB SELECT.DRILL.DOWN
    END

* GB9700938 Format TXN total before storing it.
    GOSUB CALC.TXN.TOTALS

    EB.Reports.setId(SAVE.ID)
    EB.Reports.setOData(EB.Reports.getId())

    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<10>, @VM))
RETURN


**************************************************************************
*                           INTERNAL ROUTINES
**************************************************************************


GET.AC.TXNS:
*===========

* There are no PM.TRAN.ACTIVITY records for accounts therefore store
* details based on the PM.DLY.POSN.CLASS record under the general
* transaction ref of the position class.


    TXN.AMT = 0
    VM.POS = 0
    NO.VMS = DCOUNT(DPC.REC<PM.Config.DlyPosnClass.DpcAsstLiabCd>, @VM)
    LOOP
        VM.POS += 1
        ASST.OR.LIAB = DPC.REC<PM.Config.DlyPosnClass.DpcAsstLiabCd, VM.POS>
        AMT.STR = DPC.REC<PM.Config.DlyPosnClass.DpcAmtCode, VM.POS>
        LOCATE "1" IN AMT.STR<1> SETTING YY THEN

* Display credit movments as negative, ie money out of Nostro.

            IF ASST.OR.LIAB = 2 THEN
                TXN.AMT -= DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
            END ELSE
                TXN.AMT += DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
            END
        END
    UNTIL VM.POS = NO.VMS
    REPEAT

* Use the position class as the transaction ID.

    LOCATE DPC.CLASS IN EB.Reports.getRRecord()<10,1> BY "AR" SETTING POS ELSE
        NULL
    END
    TEMP.R.RECORD = EB.Reports.getRRecord()
    INS DPC.CLASS BEFORE TEMP.R.RECORD<10,POS>
    INS DPC.CLASS BEFORE TEMP.R.RECORD<11,POS>
    INS TXN.AMT BEFORE TEMP.R.RECORD<12,POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)

* GB9700938 call Format.amount
    FORM.AMT = TXN.AMT
    GOSUB FORMAT.AMOUNT
    TEMP.R.RECORD = EB.Reports.getRRecord()
    INS FORM.AMT BEFORE TEMP.R.RECORD<14,POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)

RETURN

***********************************************************************
SELECT.DRILL.DOWN:
******************

    DPC.CHK = DPC.ID['.',1,6]
    FN.PM.DRILL.DOWN = "F.PM.DRILL.DOWN"
    F.PM.DRILL.DOWN = ""
    EB.DataAccess.Opf(FN.PM.DRILL.DOWN,F.PM.DRILL.DOWN)
    THE.ARGS = ''
    DAS.TABLE.SUFFIX = ''
    PM.LIST = ''
    THE.ARGS<1> = Y.ARG
    PM.LIST = dasPmDrillDownApplicaSel
    EB.DataAccess.Das("PM.DRILL.DOWN",PM.LIST,THE.ARGS,DAS.TABLE.SUFFIX)
    LOOP
        REMOVE DP.ID FROM PM.LIST SETTING PM.POS
    WHILE DP.ID : PM.POS
        TXN.ID = FIELD(DP.ID,"-",2,99)
        DPC.ID = FIELD(DP.ID,'-',1)
        COMP.LIST = DPC.ID['.',1,6]
        DPC.MKT = DPC.ID['.',2,1]
        DPC.CCY = DPC.ID['.',5,1]
        CONVERT "." TO @FM IN COMP.LIST
        GOSUB STORE.TXN.DTLS
    REPEAT

*
RETURN
**************************************************************************


STORE.TXN.DTLS:
*==============

    TXN.REC = ""
    TXN.AMT = 0

*
    GOSUB READ.PMT
*
    IF PM.TRAN.REC THEN
        GOSUB GET.TXN.AMOUNT
    END
*
*-------------

RETURN

**********************************************************
READ.PMT:
*********
    PM.TRAN.REC = ""
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) THEN
*If file variables are null re initialise the common variable( and do OPF) before READ from PM.TRAN.ACTIVITY.
        IF NOT(FILEINFO(F.PM.TRAN.ACTIVITY,0)) THEN
            GOSUB SETUP.COMMON
        END
        ER1 = ""
        PM.TRAN.REC = PM.Engine.TranActivity.Read(TXN.ID, ER1)
        IF ER1 THEN
            PM.Reports.DrillDown.Delete(DP.ID)
            RETURN
        END
    END ELSE
        PM.CO2.TRAN.FILE = "F":MNE:".PM.TRAN.ACTIVITY"
        FCO2.PM.TRAN = ""
        EB.DataAccess.Opf(PM.CO2.TRAN.FILE, FCO2.PM.TRAN)
        ER2 = ""
        EB.DataAccess.FRead(PM.CO2.TRAN.FILE, TXN.ID, PM.TRAN.REC, FCO2.PM.TRAN, ER2)
        IF ER2 THEN
            PM.Reports.DrillDown.Delete(DP.ID)
            RETURN
        END
    END
RETURN

CALC.TXN.TOTALS:
*===============

    TXN.LIST = EB.Reports.getRRecord()<10>
    AMT.LIST = EB.Reports.getRRecord()<12>
    PREV.TXN = TXN.LIST<1,1>
    POS = 0
    TXN.TOTAL = ""
    LOOP
        POS += 1
        REMOVE TXN FROM TXN.LIST SETTING DELIM
        REMOVE AMT FROM AMT.LIST SETTING NAFF
        IF TXN NE PREV.TXN THEN
* GB970938 Formatt TXN.TOyal before storing it
            FORM.AMT = TXN.TOTAL
            GOSUB FORMAT.AMOUNT
            TEMP.R.RECORD = EB.Reports.getRRecord()
            INS FORM.AMT BEFORE TEMP.R.RECORD<13,POS-1>
            EB.Reports.setRRecord(TEMP.R.RECORD)
            TXN.TOTAL = AMT
        END ELSE
            TXN.TOTAL += AMT
        END
        PREV.TXN = TXN
* GB970938 Update Running.balance and format it and store it
        RUNNING.BALANCE += AMT
        FORM.AMT = RUNNING.BALANCE
        GOSUB FORMAT.AMOUNT
    WHILE DELIM
    REPEAT
    TEMP.R.RECORD = EB.Reports.getRRecord()
    TEMP.R.RECORD<15> = FORM.AMT  ;* Outstanding Balance for the day
    EB.Reports.setRRecord(TEMP.R.RECORD)

* GB970938 Formatt TXN.TOyal before storing it
    FORM.AMT = TXN.TOTAL
    GOSUB FORMAT.AMOUNT
    TEMP.R.RECORD = EB.Reports.getRRecord()
    INS FORM.AMT BEFORE TEMP.R.RECORD<13, POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)

RETURN



READ.DPC.REC:
*
* GB9600737
*
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) THEN
*If file variables are null re initialise the common variable( and do OPF) before READ from DPC
        IF NOT(FILEINFO(F.PM.DPC.LOC,0)) THEN
            GOSUB SETUP.COMMON
        END
        ER3 = ""
        DPC.REC = PM.Config.DlyPosnClass.Read(DPC.ID, ER3)
        IF ER3 THEN
            DPC.REC = ""
        END
    END ELSE
*
* For the secondary companies open the file with the menmonic set
*
        PM.CO2.DPC.FILE = "F":MNE:".PM.DLY.POSN.CLASS"
        FCO2.PM.DPC = ""
        EB.DataAccess.Opf(PM.CO2.DPC.FILE, FCO2.PM.DPC)
        ER4 = ""
        EB.DataAccess.FRead(PM.CO2.DPC.FILE, DPC.ID, DPC.REC,FCO2.PM.DPC,ER4)
        IF ER4 THEN
            DPC.REC = ""
        END
    END
*
* GB9600737
*

RETURN


GET.TXN.AMOUNT:
*==============

    OK = ""
    XX = 0
    NO.OF.POSN.CLASS = DCOUNT(PM.TRAN.REC<PM.Engine.TranActivity.PosnClass>,@VM)
    LOOP
        XX += 1
        COMP.LIST = COMP.LIST
        FLD.LIST = FLD.LIST
        LOOP
            REMOVE COMP.ID FROM COMP.LIST SETTING DELIM
            REMOVE COMP.FLD FROM FLD.LIST SETTING DELIM2
            OK = COMP.ID = PM.TRAN.REC<COMP.FLD, XX>
        UNTIL DELIM = 0 OR NOT(OK)
        REPEAT

        GOSUB UPDATE.TXN.AMT.IN.R.RECORD

    UNTIL (OK OR PM.TRAN.REC<PM.Engine.TranActivity.Currency, XX> = "") AND XX GE NO.OF.POSN.CLASS
    REPEAT

RETURN

*-------------------------------
UPDATE.TXN.AMT.IN.R.RECORD:
*-------------------------------

* Display credit movments as negative, ie money out of Nostro.

    IF OK THEN
        TXN.AMT = PM.TRAN.REC<PM.Engine.TranActivity.CcyAmt, XX>
        TXN.FAMT = PM.TRAN.REC<PM.Engine.TranActivity.CcyAmt, XX>

        EB.API.RoundAmount(DPC.CURRENCY, TXN.FAMT, ROUND.TYPE, "")

* GB9700938 Always use SIGN info and only reverse TXN.AMT for Liabs
        IF PM.TRAN.REC<PM.Engine.TranActivity.AsstLiabCd,XX> = 2 THEN
            TXN.AMT = TXN.AMT * -1
            TXN.FAMT = SIGN<3,1>:TXN.FAMT:SIGN<3,2>
        END ELSE
            TXN.FAMT = SIGN<4,1>:TXN.FAMT:SIGN<4,2>
        END
    END ELSE
        TXN.AMT = 0
        TXN.FAMT = " "
    END

    IF TXN.AMT NE 0 THEN

        IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) THEN
            LOCATE TXN.ID IN EB.Reports.getRRecord()<10,1> BY "AR" SETTING POS ELSE
                NULL
            END
            TEMP.R.RECORD = EB.Reports.getRRecord()
            INS TXN.ID BEFORE TEMP.R.RECORD<10,POS>
            EB.Reports.setRRecord(TEMP.R.RECORD)
        
        END ELSE
            LOCATE TXN.ID:'\':MNE IN EB.Reports.getRRecord()<10,1> BY "AR" SETTING POS ELSE
                NULL
            END
            TEMP.R.RECORD = EB.Reports.getRRecord()
            INS TXN.ID:'\':MNE BEFORE TEMP.R.RECORD<10,POS>
            EB.Reports.setRRecord(TEMP.R.RECORD)
        END
*
* GB9600737
*
        TEMP.R.RECORD = EB.Reports.getRRecord()
        INS DPC.CLASS BEFORE TEMP.R.RECORD<11,POS>
        INS TXN.AMT BEFORE TEMP.R.RECORD<12,POS>
        INS TXN.FAMT BEFORE TEMP.R.RECORD<14,POS>
        EB.Reports.setRRecord(TEMP.R.RECORD)

    END

RETURN

*--------------------------------------------------------------------------------------------------
SETUP.COMMON:
*============

    FLD.LIST = PM.Engine.TranActivity.PosnClass
    FLD.LIST<-1> = PM.Engine.TranActivity.CurrencyMarket
    FLD.LIST<-1> = PM.Engine.TranActivity.DealerDesk
    FLD.LIST<-1> = PM.Engine.TranActivity.PosnType
    FLD.LIST<-1> = PM.Engine.TranActivity.Currency
    FLD.LIST<-1> = PM.Engine.TranActivity.ValueDate


    PM.DPC.FILE = "F.PM.DLY.POSN.CLASS"
    F.PM.DPC.LOC = ""
    EB.DataAccess.Opf(PM.DPC.FILE, F.PM.DPC.LOC)
    F.PM.DPC = F.PM.DPC.LOC

    PM.TRAN.ACTIVITY.FILE = "F.PM.TRAN.ACTIVITY"
    F.PM.TRAN.ACTIVITY.LOC = ""
    EB.DataAccess.Opf(PM.TRAN.ACTIVITY.FILE, F.PM.TRAN.ACTIVITY.LOC)
    F.PM.TRAN.ACTIVITY = F.PM.TRAN.ACTIVITY.LOC

* GB9700938 Move setting of PM.PArms to setup routine
*  also set SIGN for when no param record so that
*  processing can be the same.
*
** Open PM.ENQ.PARAM file
*
    F.PM.ENQ.PARAM = ""
    EB.DataAccess.Opf("F.PM.ENQ.PARAM",F.PM.ENQ.PARAM)

*
** Read the enquiry parameter for PM.NOS
*
    PM.ENQ.PARAM.ID = "PM.NOS"
    READ.ERR = ""
    R.PM.ENQ.PARAM = PM.Reports.EnqParam.Read(PM.ENQ.PARAM.ID, READ.ERR)

    IF READ.ERR THEN
        R.PM.ENQ.PARAM = ""
    END

*
* Extract positive and negative indicators from the Parameter file
*
    Y = 0
    SIGN = ''
    IF R.PM.ENQ.PARAM THEN
        FOR X = PM.Reports.EnqParam.EnqTakSign TO PM.Reports.EnqParam.EnqDifPlacSign
            Y+= 1
            BEGIN CASE
                CASE R.PM.ENQ.PARAM<X> = 'BRACKETS'
                    SIGN<Y,1> = '('
                    SIGN<Y,2> = ')'
                CASE R.PM.ENQ.PARAM<X> = 'MINUS'
                    SIGN<Y,1> = '-'
                    SIGN<Y,2> = SPACE(1)
                CASE R.PM.ENQ.PARAM<X> = 'PLUS'
                    SIGN<Y,1> = '+'
                    SIGN<Y,2> = SPACE(1)
                CASE 1
                    SIGN<Y,1> = SPACE(1)
                    SIGN<Y,2> = SPACE(1)
            END CASE
        NEXT X
    END ELSE
        SIGN<3,1> = '-'
        SIGN<3,2> = SPACE(1)
        SIGN<4,1> = '+'
        SIGN<4,2> = SPACE(1)
    END

* GB9700938 set Running.Balance
    RUNNING.BALANCE = OPEN.BALANCE


* GB9700938 Set Number of decimals
    tmp.ID = EB.Reports.getId()
    CCY = FIELD(tmp.ID, ".", 5)
    CCY.DECIMALS = "NO.OF.DECIMALS"
    ST.CurrencyConfig.UpdCcy(CCY,CCY.DECIMALS)

RETURN

*
*------------------------------------------------------------
*
FORMAT.AMOUNT:
*-------------

    EB.API.RoundAmount(DPC.CURRENCY,FORM.AMT,ROUND.TYPE,"")

    IF FORM.AMT THEN
        IF FORM.AMT < 0 THEN
            FORM.AMT  = FORM.AMT * -1
            FORM.AMT = SIGN<3,1>:FORM.AMT:SIGN<3,2>
        END ELSE
            FORM.AMT = SIGN<4,1>:FORM.AMT:SIGN<4,2>
        END
    END ELSE
        FORM.AMT = " ":FORM.AMT:" "
    END
*
* Set DPC.KEYS
    DPC.KEYS = ""

RETURN
*
*------------------------------------------------------------
*
END
