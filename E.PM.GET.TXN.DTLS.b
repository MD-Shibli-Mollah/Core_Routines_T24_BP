* @ValidationCode : MjoxMDE0MjE0NzQwOkNwMTI1MjoxNTU4MDA2NjkzMDgzOmFhcnRoaWE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAzLjIwMTkwMjE5LTEyNDE6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 May 2019 17:08:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : aarthia
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190219-1241
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-115</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.GET.TXN.DTLS

*  This routine will obtain the amount used to update PM for a given
*  transaction on a PM.DLY.POSN.CLASS record
*
*  INPUT
*  =====
*  ID          -  Record ID for PM.DLY.POSN.CLASS
*  O.DATA      -  Transaction ID
*
*  OUTPUT
*  ======
*  O.DATA      - Transaction amount in txn currency
*
* 14/08/97 - GB9700938
*            The E.PMGTA common has had new fields added to
*            it they are to be set to null in the setup routine
*
* 22/03/00 - GB0000352
*            Cater for drilldown from multiple currency enquiries
*            If sel. field TXN.TOT is set then use it like enquiry
*            main currency
*
* 16/08/00 - GB0002037 RPK.
*            If PM.ENQ.PARAM has a value of FX in ENQ.TYPE it is necessary
*            to reverse the sign applied for ASST.LIAB values.
*
* 12/03/08 - CI_10054095
*            For contracts in FD.FID.ORDER, PM.TRAN.ACTIVITY id will be delimited by "-".
*            Hence when arriving at id from records in PM.DRILL.DOWN, all parameters
*            after first "-" need to be retrieved.
*
* 03/08/09 - CI_10065057
*            remove the date suffix for drill down; store the DPC key minus suffix so that we don't repeat the dirll down
*
* 26/03/10 - Defect-32886/Task-34208
*            EXECUTE changed to DAS
*
* 23/02/12 - Defect 328742/Task 360806
*            Issue with slow launching of drill down enquiries DPC.TXNS and PM.NOSTRO.TXNS
*
* 18/10/12 - Defect 498140 / Task 503128
*            When drilling down Position Management enquiries - PM.CAS / PM.GAP,
*            The CURENCY is displayed as �0�
*
* 14/06/13 - Defect 695274 / Task 700786
*             When drill down the PM.FXREVAL and PM.CAS enquires currency dispalyed in both header and transaction details are different.
*
* 27/02/14 - Defect 674510 / Task 921864
*            On refreshing the PM.GAP drill down enquiry,sign change occurs for amounts displayed.
*
* 30/05/14 - Defect 1008592 / Task 1014490
*            Sign change happening on refreshing output of a drill down data of one enquiry (PM.CAS),
*            when the another enquiry is active (PM.FXPOS)
*
* 30/09/16 - Defect 1858629 / Task 1873480
*            For PM.GAP enquiry the drill down transactions details are not displayed for inputted transactions.
*
* 10/04/19 - Enh 2941192 / Task 3076644
*            Restructuring of DPC.TXNS enquiry issue
* 
*---------------------------------------------------------------------------------------------------------------------------------------------------


    COM /E.PMGTA/ FLD.LIST, F.PM.DPC, F.PM.TRAN.ACTIVITY, SIGN, RUNNING.BALANCE, CCY.DECIMALS, DPC.KEYS


    $INSERT I_DAS.PM.DRILL.DOWN


    $USING ST.CompanyCreation
    $USING PM.Engine
    $USING PM.Config
    $USING EU.Config
    $USING EB.DataAccess
    $USING ST.ExchangeRate
    $USING PM.Reports
    $USING EB.SystemTables
    $USING EB.Reports


* GB0000352 - start
    YCCY = ''
    GOSUB READ.PM.ENQ.PARAM

*when drill down the enquires ,refresh the Common variable PM$CCY.
    tmp.ID = EB.Reports.getId()
    PM.Config.setCcy(FIELD(tmp.ID, "." ,5))

* GB0000352 - end

    IF EB.Reports.getOData() = "SETUP" THEN
        GOSUB SETUP.COMMON
        RETURN
    END

* Initialise the fields to be used on R.RECORD.

    tmp=EB.Reports.getRRecord(); tmp<1>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<10>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<13>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp);* Original selected currency
    tmp=EB.Reports.getRRecord(); tmp<14>=''; EB.Reports.setRRecord(tmp);* Amount in PM$CCY
    tmp=EB.Reports.getRRecord(); tmp<15>=''; EB.Reports.setRRecord(tmp);* Transaction ccy
* Add the current ID back into ENQ.KEYS.

    tmp.ID = EB.Reports.getId()
    CHECK.DATE = FIELD(tmp.ID, ".", 6)
    SAVE.ID = EB.Reports.getId()
    TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
    INS tmp.ID BEFORE TEMP.ENQ.KEYS<1>
    EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)
* Now loop through each of the PM.DLY.POSN.CLASS ids passed until the
* date changes. For all DPC records for a given date (CHECK.DATE)
* assemble a list of transcations and their details and return in
* R.RECORD.

    EXIT.LOOP = ""
    Y.CUR.DPC.ID = ""
    Y.OLD.DPC.ID = ""
    Y.ARG = ""
    LOOP
        DP.ID = EB.Reports.getEnqKeys()<1>
        DPC.ID = FIELD(DP.ID,'*',1)
        DPC.CLASS = FIELD(DPC.ID, ".", 1)
        DPC.DATE = FIELD(DPC.ID, ".", 6)
        IF DPC.DATE > CHECK.DATE THEN
            EXIT.LOOP = 1
        END ELSE
            TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
            DEL TEMP.ENQ.KEYS<1>
            EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)
        END
    UNTIL EXIT.LOOP OR DPC.ID = ""
        MNE = FIELD(DP.ID,'*',2)
        DPC.MKT = DPC.ID['.',2,1]
        DPC.CCY = DPC.ID['.',5,1]
        GOSUB READ.DPC.REC
        IF DPC.ID[1,2] = "AC" OR DPC.ID[1,2] = "AL" THEN
            GOSUB GET.AC.TXNS
        END ELSE
            DPC.CHK = DPC.ID['.',1,6]
            LOCATE DPC.CHK:MNE IN DPC.KEYS SETTING DP.POS ELSE
            DPC.KEYS<-1> = DPC.CHK:MNE
            Y.ARG<-1> = DPC.CHK
        END
        Y.CUR.DPC.ID = DPC.ID[1,2]
        IF Y.OLD.DPC.ID EQ '' THEN
            Y.OLD.DPC.ID = Y.CUR.DPC.ID       ;* assign this only for the first time
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
        LOCATE "1" IN AMT.STR<1,1,1> SETTING YY THEN
        GOSUB SET.TXN.AMT

    END
    UNTIL VM.POS = NO.VMS
    REPEAT

* Use the position class as the transaction ID.

    SEARCH.CLASS = DPC.CLASS:'-':DPC.CCY
    LOCATE SEARCH.CLASS IN EB.Reports.getRRecord()<10,1> BY "AR" SETTING POS ELSE
    NULL
    END
    TEMP.R.RECORD = EB.Reports.getRRecord()
    INS SEARCH.CLASS BEFORE TEMP.R.RECORD<10,POS>
    INS DPC.CLASS BEFORE TEMP.R.RECORD<11,POS>
    INS CHECK.DATE BEFORE TEMP.R.RECORD<1,POS>
    INS TXN.AMT BEFORE TEMP.R.RECORD<12,POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)
*
** If the TXN ccy is different to the selected ccy (PM$CCY)
** then convert it using the fixed rate if available
*
    IF DPC.CCY NE PM.Config.getCcy() AND PM.Config.getCcy() THEN
        GOSUB CONVERT.TXN.AMT
    END ELSE
        OTHER.AMT = TXN.AMT
    END
*
    TEMP.R.RECORD = EB.Reports.getRRecord()
    INS OTHER.AMT BEFORE TEMP.R.RECORD<14,POS>
    INS DPC.CCY BEFORE TEMP.R.RECORD<15,POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)

    RETURN
******************************************************************
SET.TXN.AMT:
************
*
* GB0002037 Reverse signs for Forex Deals
*
    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqEnqType) = "FX" THEN
        IF ASST.OR.LIAB = 1 THEN
            TXN.AMT += DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END ELSE
            TXN.AMT -= DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END
    END ELSE
        IF ASST.OR.LIAB = 1 THEN
            TXN.AMT -= DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END ELSE
            TXN.AMT += DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END
    END

    RETURN

*******************************************************************
SELECT.DRILL.DOWN:
******************

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

*
* GB9600737
*
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) THEN
        ER3 = ""
        PM.TRAN.REC = PM.Engine.TranActivity.Read(TXN.ID, ER3)
        IF ER3 THEN
            PM.Reports.DrillDown.Delete(DP.ID)
            RETURN
        END
    END ELSE
        PM.CO2.TRAN.FILE = "F":MNE:".PM.TRAN.ACTIVITY"
        FCO2.PM.TRAN = ""
        EB.DataAccess.Opf(PM.CO2.TRAN.FILE, FCO2.PM.TRAN)
        ER4 = ""
        EB.DataAccess.FRead(PM.CO2.TRAN.FILE, TXN.ID, PM.TRAN.REC, FCO2.PM.TRAN, ER4)
        IF ER4 THEN
            PM.Reports.DrillDown.Delete(DP.ID)
            RETURN
        END
    END
*
* GB9600737
*
* Process each Position classes from PM.DRILL.DOWN with corresponding PM.TRAN.ACTIVITY record
    XX = 0
    LOOP
        XX += 1 ; OK = 0
        COMP.LIST = COMP.LIST
        FLD.LIST = FLD.LIST
        LOOP
            REMOVE COMP.ID FROM COMP.LIST SETTING DELIM ;* Fetch position class from PM.DRILL.DOWN stored in COM.LIST
            REMOVE COMP.FLD FROM FLD.LIST SETTING DELIM2
            OK = COMP.ID = PM.TRAN.REC<COMP.FLD, XX>


            * Skip the zero interest rated contract for PM.GAP with PM.PARAMETER with ZERO.INT.RATE not set
            *Contract with int key should not be skipped for drilldown data. The zero int rate contract must be skipped when parameter is no after validating the int key as well.

            IF OK AND R.PM.PARAMETER<PM.Config.Parameter.PpZeroIntRate> NE 'YES' AND PARAM.ID EQ 'GAP' AND NOT(PM.TRAN.REC<PM.Engine.TranActivity.Rate,XX>) AND NOT(PM.TRAN.REC<PM.Engine.TranActivity.IntKey,XX>) THEN
                OK = 0
            END


        UNTIL DELIM = 0 OR NOT(OK)
        REPEAT
        IF OK THEN
            GOSUB UPDATE.RECORD
        END
    UNTIL PM.TRAN.REC<PM.Engine.TranActivity.Currency, XX> = ""
    REPEAT

    RETURN

************************************************************************
UPDATE.RECORD:
**************
    TXN.AMT = SUM(PM.TRAN.REC<PM.Engine.TranActivity.CcyAmt, XX>)
*
* GB0002037 If Forex Param, reverse sign for ASST.LIAB
*
    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqEnqType) = "FX" THEN
        IF PM.TRAN.REC<PM.Engine.TranActivity.AsstLiabCd, XX> = 2 THEN        ;*2=SELL
            TXN.AMT = TXN.AMT * -1
        END
    END ELSE
        IF PM.TRAN.REC<PM.Engine.TranActivity.AsstLiabCd, XX> = 1 THEN        ;*1=BUY
            TXN.AMT = TXN.AMT * -1
        END
    END
*
* GB9600737
*
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
    INS DPC.CCY BEFORE TEMP.R.RECORD<15,POS>
    INS CHECK.DATE BEFORE TEMP.R.RECORD<1,POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)
*
** If the TXN ccy is different to the selected ccy (PM$CCY)
** then convert it using the fixed rate if available
*
    IF DPC.CCY NE PM.Config.getCcy() AND PM.Config.getCcy() THEN
        GOSUB CONVERT.TXN.AMT
    END ELSE
        OTHER.AMT = TXN.AMT
    END
    TEMP.R.RECORD = EB.Reports.getRRecord()
    INS OTHER.AMT BEFORE TEMP.R.RECORD<14,POS>
    EB.Reports.setRRecord(TEMP.R.RECORD)
    RETURN

READ.DPC.REC:
*============

*
* GB9600737
*
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) THEN
        ER5 = ""
        DPC.REC = PM.Config.DlyPosnClass.Read(DPC.ID, ER5)
        IF ER5 THEN
            DPC.REC = ""
        END
    END ELSE
        *
        * For the secondary companies open the file with the menmonic set
        *
        PM.CO2.DPC.FILE = "F":MNE:".PM.DLY.POSN.CLASS"
        FCO2.PM.DPC = ""
        EB.DataAccess.Opf(PM.CO2.DPC.FILE, FCO2.PM.DPC)
        ER = ""
        EB.DataAccess.FRead(PM.CO2.DPC.FILE, DPC.ID, DPC.REC, FCO2.PM.DPC, ER)
        IF ER THEN
            DPC.REC = ""
        END
    END
*
* GB9600737
*

    RETURN

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

* GB9700938 Set new common filds to Null
    SIGN = ''
    RUNNING.BALANCE = ''
    CCY.DECIMALS = ''
    tmp=EB.Reports.getRRecord(); tmp<13>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)
    DPC.KEYS = ""

    RETURN
*
*---------------------------------------------------------------------
CONVERT.TXN.AMT:
*===============
**
    OTHER.AMT = ''
    LOCATE DPC.CCY IN PM.Config.getREuFixedCcy()<EU.Config.FixedCurrency.FcCurrencyCode,1> SETTING CPOS THEN
    FIXED.RATE = PM.Config.getREuFixedCcy()<EU.Config.FixedCurrency.FcFixedRate,CPOS>
    END ELSE
    FIXED.RATE = ''
    END
    tmp.PM$CCY = PM.Config.getCcy()
    ST.ExchangeRate.Exchrate(DPC.MKT, DPC.CCY, TXN.AMT, tmp.PM$CCY, OTHER.AMT, '', FIXED.RATE, '', '', '')
    PM.Config.setCcy(tmp.PM$CCY)
*
    RETURN
*----------------------------------------------------------------------------------------------------------------------------
READ.PM.ENQ.PARAM:
*==================
    F$PM.ENQ.PARAM.LOC = ''
    PM.ENQ.PARAM.FILE = "F.PM.ENQ.PARAM"
    EB.DataAccess.Opf(PM.ENQ.PARAM.FILE, F$PM.ENQ.PARAM.LOC)
    PM.Config.setFPmEnqParam(F$PM.ENQ.PARAM.LOC)

    PM.Config.clearRPmEnqParam()
    tmp.ID = EB.Reports.getId()
    POSN.CLASS = FIELD(tmp.ID,".",1)

    FN.PM.POSN.REFERENCE = "F.PM.POSN.REFERENCE"
    F.PM.POSN.REFERENCE = ''
    EB.DataAccess.Opf(FN.PM.POSN.REFERENCE,F.PM.POSN.REFERENCE)

    R.PM.PARAMETER = ''
    PM.PARAM.ERR = ''
    ST.CompanyCreation.EbReadParameter('F.PM.PARAMETER','N','',R.PM.PARAMETER,'SYSTEM','',PM.PARAM.ERR)



    PM.POS = ''
    PM.LIST = ''
    POSN.CLASSES = ''
    PARAM.ID = ''
    CPOS = ''
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    PM.LIST = 'ALL.IDS'
    EB.DataAccess.Das("PM.POSN.REFERENCE",PM.LIST,THE.ARGS,TABLE.SUFFIX)

    LOOP
        REMOVE POSN.ID FROM PM.LIST SETTING PM.POS
    WHILE POSN.ID:PM.POS
        IF POSN.ID NE "PM.NOS" THEN
            ER1 = ""
            REF.REC = PM.Config.PosnReference.Read(POSN.ID, ER1)
            IF ER1 EQ "" THEN
                POSN.CLASSES = REF.REC<PM.Config.PosnReference.PrPosnClass>
                POSN.CLASSES = RAISE(POSN.CLASSES)
                LOCATE POSN.CLASS IN POSN.CLASSES SETTING CPOS THEN
                PARAM.ID =POSN.ID
                EXIT
            END
        END
    END
    REPEAT

* The ENQ PARAM id can be with company code hence read the respective company id first then go with generic postion type.
*If generic position is  not found then go with PM.NOS

    ENQ.POSN.TYPE = ''
    ENQ.POSN.TYPE = FIELD(PARAM.ID,"*",1)

    READ.SUCCESS = ''
    PARAM.ID = ENQ.POSN.TYPE:'*':EB.SystemTables.getIdCompany()       ;* Priority 1 is to read for the respective company

    GOSUB READ.PARAMETER

    IF NOT(READ.SUCCESS) THEN
        PARAM.ID = ENQ.POSN.TYPE        ;* Priority 2 is to read for the generic position type
        GOSUB READ.PARAMETER
    END

    IF NOT(READ.SUCCESS) THEN
        PARAM.ID = 'PM.NOS'   ;* Priority 3 is to read the default setup which is PM.NOS, the same is done in E.PM.INIT.COMMON
        GOSUB READ.PARAMETER
    END

    F.PM.CALENDAR = ''
    EB.DataAccess.Opf("F.PM.CALENDAR",F.PM.CALENDAR)
    ER2 = ""
    tmp.EnqCalendar = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCalendar)
    R$PM.CALENDAR.DYN = PM.Config.Calendar.Read(tmp.EnqCalendar, ER2)
    PM.Config.setRPmEnqParam(PM.Reports.EnqParam.EnqCalendar, tmp.EnqCalendar)
    PM.Config.setDynArrayToRPmCalendar(R$PM.CALENDAR.DYN)
    Y = 0
    TEMP.SIGN = ""
    FOR XX = PM.Reports.EnqParam.EnqTakSign TO PM.Reports.EnqParam.EnqDifPlacSign
        Y+=1
        TEMP.SIGN<Y> = XX
    NEXT XX
    Y+=1 ; TEMP.SIGN<Y>=PM.Reports.EnqParam.EnqFxBuySign
    Y+=1 ; TEMP.SIGN<Y>=PM.Reports.EnqParam.EnqFxSellSign
    FOR XX = 1 TO Y
        BEGIN CASE
            CASE PM.Config.getRPmEnqParam(TEMP.SIGN<XX>) = 'BRACKETS'
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>='('; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>=')'; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
            CASE PM.Config.getRPmEnqParam(TEMP.SIGN<XX>) = 'MINUS'
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>='-'; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
            CASE PM.Config.getRPmEnqParam(TEMP.SIGN<XX>) = 'PLUS'
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>='+'; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
            CASE 1
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
        END CASE
    NEXT XX

    RETURN

READ.PARAMETER: 

    READ.SUCCESS = 1
    ER = ""
    R$PM.ENQ.PARAM.DYN = PM.Reports.EnqParam.Read(PARAM.ID, ER)
    PM.Config.setDynArrayToRPmEnqParam(R$PM.ENQ.PARAM.DYN)
    IF ER THEN
        READ.SUCCESS = 0
    END
    RETURN

    END
