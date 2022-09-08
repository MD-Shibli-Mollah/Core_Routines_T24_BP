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

* Version 3 15/05/01  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>-87</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.GET.TXN.DTLS.DET

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
***************************************************************************
*
* 15/09/97 - GB9700975
*            COPY of program E.PM.GET.TXN.DTLS with the sort criteria
*            changed. OVERDUE payment TXNS first and then all Real FWD
*            TXNS.
*
* 26/03/10 - Defect-32888/Task-34226
*            EXECUTE changed to DAS
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
***************************************************************************
*

    COM /E.PMGTA/ FLD.LIST, F.PM.DPC, F.PM.TRAN.ACTIVITY, SIGN, RUNNING.BALANCE, CCY.DECIMALS


    $USING ST.CompanyCreation
    $USING PM.Engine
    $USING PM.Config
    $USING EB.DataAccess
    $USING PM.Reports
    $USING EB.SystemTables
    $USING EB.Reports

    $INSERT I_DAS.PM.DRILL.DOWN


    IF EB.Reports.getOData() = "SETUP" THEN
        GOSUB SETUP.COMMON
        RETURN
    END

* Initialise the fields to be used on R.RECORD.

    tmp=EB.Reports.getRRecord(); tmp<10>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=""; EB.Reports.setRRecord(tmp)
*
* GB9700975s
*
    OD.TXN.ID = ""  ;* OverDue TXN ids
    RF.TXN.ID = ""  ;* Real Forward TXN ids
*
* GB9700975e
*
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
    LOOP
        DP.ID = EB.Reports.getEnqKeys()<1>
        DPC.ID = FIELD(DP.ID,'*',1)
        MNE = FIELD(DP.ID,'*',2)
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
        IF DPC.ID[1,2] = "AC" OR DPC.ID[1,2] = "AL" THEN
            GOSUB READ.DPC.REC
            GOSUB GET.AC.TXNS
        END ELSE
            GOSUB SELECT.DRILL.DOWN
        END
    REPEAT

    EB.Reports.setId(SAVE.ID)
    EB.Reports.setOData(EB.Reports.getId())
*
* GB9700975s
*
    tmp=EB.Reports.getRRecord(); tmp<10>=OD.TXN.ID<10>:@VM:RF.TXN.ID<10>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=OD.TXN.ID<11>:@VM:RF.TXN.ID<11>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=OD.TXN.ID<12>:@VM:RF.TXN.ID<12>; EB.Reports.setRRecord(tmp)
*
* GB9700975e
*
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
        IF ASST.OR.LIAB = 1 THEN
            TXN.AMT -= DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END ELSE
            TXN.AMT += DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END
    END
    UNTIL VM.POS = NO.VMS
    REPEAT

* Use the position class as the transaction ID.

    LOCATE DPC.CLASS IN RF.TXN.ID<10,1> BY "AR" SETTING POS ELSE
    NULL
    END
    INS DPC.CLASS BEFORE RF.TXN.ID<10,POS>
    INS DPC.CLASS BEFORE RF.TXN.ID<11,POS>
    INS TXN.AMT BEFORE RF.TXN.ID<12,POS>
    RETURN
****************************************************************
SELECT.DRILL.DOWN:
******************
    COMP.LIST = DPC.ID
    CONVERT "." TO @FM IN COMP.LIST
    DPC.CHK = DPC.ID['.',1,6]

* DAS

    FN.PM.DRILL.DOWN = "F.PM.DRILL.DOWN"
    F.PM.DRILL.DOWN = ""
    EB.DataAccess.Opf(FN.PM.DRILL.DOWN,F.PM.DRILL.DOWN)

    THE.ARGS = ''
    DAS.TABLE.SUFFIX = ''
    PM.LIST = ''
    THE.ARGS<1> = "@ID"
    THE.ARGS<2> = "LK"
    THE.ARGS<3> = DPC.CHK:"..."

    PM.LIST = dasPmDrillDownGeneralSel
    EB.DataAccess.Das("PM.DRILL.DOWN",PM.LIST,THE.ARGS,DAS.TABLE.SUFFIX)

    LOOP
        REMOVE DP.ID FROM PM.LIST SETTING PM.POS
    WHILE DP.ID : PM.POS
        TXN.ID = FIELD(DP.ID,"-",2)
        GOSUB STORE.TXN.DTLS
    REPEAT

*
    RETURN
*****************************************************************
STORE.TXN.DTLS:
*==============

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
    XX = 0
    LOOP
        XX += 1 ; OK = 0
        COMP.LIST = COMP.LIST
        FLD.LIST = FLD.LIST
        LOOP
            REMOVE COMP.ID FROM COMP.LIST SETTING DELIM
            REMOVE COMP.FLD FROM FLD.LIST SETTING DELIM2
            OK = COMP.ID = PM.TRAN.REC<COMP.FLD, XX>
        UNTIL DELIM = 0 OR NOT(OK)
        REPEAT
        IF OK THEN
            GOSUB UPDATE.RECORD
            *
        END
    UNTIL PM.TRAN.REC<PM.Engine.TranActivity.Currency, XX> = ""
    REPEAT

    RETURN
****************************************************************
UPDATE.RECORD:
**************
    TXN.AMT = SUM(PM.TRAN.REC<PM.Engine.TranActivity.CcyAmt, XX>)
    IF PM.TRAN.REC<PM.Engine.TranActivity.AsstLiabCd, XX> = 1 THEN
        TXN.AMT = TXN.AMT * -1
    END
*
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) THEN
        IF TXN.ID[1,2] = "PD" THEN
            LOCATE TXN.ID IN OD.TXN.ID<10,1> BY "AR" SETTING POS ELSE
            NULL
        END
        INS TXN.ID BEFORE OD.TXN.ID<10,POS>
        INS DPC.CLASS BEFORE OD.TXN.ID<11,POS>
        INS TXN.AMT BEFORE OD.TXN.ID<12,POS>
    END ELSE
        LOCATE TXN.ID IN RF.TXN.ID<10,1> BY "AR" SETTING POS ELSE
        NULL
    END
    INS TXN.ID BEFORE RF.TXN.ID<10,POS>
    INS DPC.CLASS BEFORE RF.TXN.ID<11,POS>
    INS TXN.AMT BEFORE RF.TXN.ID<12,POS>
    END
    END ELSE
    IF TXN.ID[1,2] = "PD" THEN
        LOCATE TXN.ID:'\':MNE IN OD.TXN.ID<10,1> BY "AR" SETTING POS ELSE
        NULL
    END
    INS TXN.ID:'\':MNE BEFORE OD.TXN.ID<10,POS>
    INS DPC.CLASS BEFORE OD.TXN.ID<11,POS>
    INS TXN.AMT BEFORE OD.TXN.ID<12,POS>
    END ELSE
    LOCATE TXN.ID:'\':MNE IN RF.TXN.ID<10,1> BY "AR" SETTING POS ELSE
    NULL
    END
    INS TXN.ID:'\':MNE BEFORE RF.TXN.ID<10,POS>
    INS DPC.CLASS BEFORE RF.TXN.ID<11,POS>
    INS TXN.AMT BEFORE RF.TXN.ID<12,POS>
    END
    END
*

    RETURN

******************************************************************
READ.DPC.REC:
*============

*
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) THEN
        ER1 = ""
        DPC.REC = PM.Config.DlyPosnClass.Read(DPC.ID, ER1)
        IF ER1 THEN
            DPC.REC = ""
        END
    END ELSE
        *
        * For the secondary companies open the file with the menmonic set
        *
        PM.CO2.DPC.FILE = "F":MNE:".PM.DLY.POSN.CLASS"
        FCO2.PM.DPC = ""
        EB.DataAccess.Opf(PM.CO2.DPC.FILE, FCO2.PM.DPC)
        ER2 = ""
        EB.DataAccess.FRead(PM.CO2.DPC.FILE, DPC.ID, DPC.REC, FCO2.PM.DPC, ER2)
        IF ER2 THEN
            DPC.REC = ""
        END
    END
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
    FLD.LIST<-1> = PM.Engine.TranActivity.ValueDateSfx


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
    RETURN


******
    END
