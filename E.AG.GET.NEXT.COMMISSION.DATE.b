* @ValidationCode : MjotMTM5MzI3ODQ1MTpDcDEyNTI6MTQ4MDU4Mzg5Nzk2Nzpwcml0aGFnOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Dec 2016 14:48:17
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
* <Rating>-62</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AG.ModelBank
    SUBROUTINE E.AG.GET.NEXT.COMMISSION.DATE
**********************************
*MODIFICATION HISTORY
*
* 23/04/12 - Task Id 1016833
*            Conversion routine to get next commission date
***********************************************************************

    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DatInterface
    $USING EB.SystemTables
    $USING EB.Reports

***********************************************************************
*


    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
***********************************************************************
INITIALISE:
**************
*
    LOCATE '@ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
    ARR.NO = EB.Reports.getEnqSelection()<4,ID.POS>
    END ELSE

    ARR.NO = EB.Reports.getOData()
    END
*
    IF EB.Reports.getEnqSimRef() THEN
        SIM.REF = EB.Reports.getEnqSimRef()
    END ELSE
        SIM.REF = ''
    END

    GOSUB GET.ARRANGEMENT.RECORD        ;*Get Arrangement Record
    PRODUCT.LINE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>       ;* Product Line from Activity
*
    RET.ERR = ''
    R.SCH = ''
    R.SIM = ''
    R.ACC.DETS = ''
    R.BILL = ''
    R.PAY.SCH = ''
    F.AA.SCH = ''
    PS.PROP = ''
    CMP.DATE = EB.SystemTables.getToday()
*
    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.SCHEDULED.ACTIVITY", ARR.NO, R.SCH, "", "", RET.ERR)
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.NO, R.ACC.DETS, "", "", RET.ERR)
        R.SIM = AA.Framework.SimulationRunner.Read(SIM.REF, RET.ERR)
        CMP.DATE = R.SIM<AA.Framework.SimulationRunner.SimSimEndDate>
    END ELSE
        R.SCH = AA.Framework.ScheduledActivity.Read(ARR.NO, RET.ERR)
        AA.PaymentSchedule.ProcessAccountDetails(ARR.NO, 'INITIALISE',   '', R.ACC.DETS, RET.ERROR)
    END
*
    PROP.CLS.LIST = ''
    IF SIM.REF THEN
        ARR.NO<1,2> = '1'
    END

    ARR.INFO = ARR.NO:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, CMP.DATE, R.ARR, PROPERTY.LIST)
*    CALL AA.GET.PROPERTY.CLASS(PROPERTY.LIST,PROP.CLS.LIST)
*    LOCATE "PRODUCT.COMMISSION" IN PROP.CLS.LIST<1,1>  SETTING CLS.POS THEN
*        PS.PROP = PROPERTY.LIST<1,CLS.POS>
*    END
*
    RETURN
*****************************************************************************************
PROCESS:
**********
*
    LOOP
        REMOVE PRP.ID FROM PROPERTY.LIST SETTING PRP.POS
    WHILE PRP.ID : PRP.POS
        CMP.ACTIVITY = PRODUCT.LINE:'-TRIGGER-':PRP.ID
        GOSUB GET.SCH.DETS
    REPEAT

    EB.Reports.setOData(FINAL.NEXT.DT)
*
    RETURN
*****************************************************************************************
GET.SCH.DETS:
******************

    PROCESS.END = ''
    LAST.DT = ''
    NEXT.DT = ''
    ACT.CNT = DCOUNT(R.SCH<AA.Framework.ScheduledActivity.SchActivityName>,@VM)
    FOR CNT.SCH = 1 TO ACT.CNT UNTIL PROCESS.END
        SCH.ACT.NAME = R.SCH<AA.Framework.ScheduledActivity.SchActivityName,CNT.SCH>
        FIN.SCH.ACT.NAME = FIELD(SCH.ACT.NAME,'*',1,1)
        IF FIN.SCH.ACT.NAME = CMP.ACTIVITY THEN
            LAST.DT = R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH>
            NEXT.DT = R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH>
            FINAL.DATE<-1> = NEXT.DT
            NXT.CNT = CNT.SCH +  1
            IF R.SCH<AA.Framework.ScheduledActivity.SchNextDate,NXT.CNT> EQ "" THEN
                PROCESS.END = 1
            END
        END
    NEXT CNT.SCH
*
    IF LAST.DT EQ CMP.DATE THEN         ;*Check for any due
        LOCATE CMP.DATE IN R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdBillPayDate,1> SETTING DT.POS THEN
        GOSUB CHECK.STATUS
    END
    END
*
    FINAL.DATE.SORT = SORT(FINAL.DATE)
    FINAL.NEXT.DT = FINAL.DATE.SORT<1>
*
    RETURN
*----------------------------------------------------------------------------------------
CHECK.STATUS:
***************
    PROCESS.END = ''
    FOR LOOP.CNT = 1 TO DCOUNT(R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdBillStatus,DT.POS>,@SM) UNTIL PROCESS.END
        IF R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdBillStatus,DT.POS,LOOP.CNT> NE 'SETTLED' AND R.ACC.DETS<AA.PaymentSchedule.AccountDetailsHist.AdRepayReference,DT.POS,LOOP.CNT> NE 'PAYOFF' THEN
            NEXT.DT = CMP.DATE
        END
    NEXT LOOP.CNT
*
    RETURN
*****************************************************************************************
*** <region name= GET.ARRANGEMENT.RECORD>
GET.ARRANGEMENT.RECORD:
*** <desc>Get Arrangement Record </desc>

    R.ARRANGEMENT = '' ; ARR.ERROR = ''
    IF AA.Framework.getRArrangement() THEN
        R.ARRANGEMENT = AA.Framework.getRArrangement()
    END ELSE
        AA.Framework.GetArrangement(ARR.NO, R.ARRANGEMENT, ARR.ERROR)     ;* Arrangement record
    END

    RETURN
*** </region>
