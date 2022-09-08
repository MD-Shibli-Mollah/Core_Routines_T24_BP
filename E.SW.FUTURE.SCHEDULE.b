* @ValidationCode : MjoyMDExMzE2NTk5OkNwMTI1MjoxNTQ0MDc1MTgxMjYzOmFhcnRoaWE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEwLjIwMTgwOTIxLTExMzA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Dec 2018 11:16:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : aarthia
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180921-1130
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-206</Rating>
*-----------------------------------------------------------------------------
* Version 13 02/06/00  GLOBUS Release No. 200512 09/12/05
*
$PACKAGE SW.Reports
SUBROUTINE E.SW.FUTURE.SCHEDULE
*
*************************************************************************
*                                                                       *
*  Routine     :  E.SW.FUTURE.SCHEDULE                                  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :  Swap schedule enquiry.                                *
*                 Enquiry to show all swap schedules, past and future,  *
*                 their effect on the principal, interest payments,     *
*                 and any premiums etc.                                 *
*                                                                       *
*                 Enquiry data is populated into the common enquiry     *
*                 variable R.RECORD.                                    *
*                                                                       *
*************************************************************************
*
*  Modifications :
*
* xx/xx/95 - GB
*            Initial Version.
*
* 06/11/97 - GB9701305
*            Change to return the effective rate in field 161 and
*            the margin rate in field 162 of R.RECORD.
*
* 11/09/02 - CI_10003597
*            G12.1.06 problem with ENQ SWAP.SCHED.RR
*
* 22/10/02 - CI_10004259
*            Derived Interest Rate is not correct in Swap Schedule.
*
* 20/01/03 - CI_10006280
*            For IRS/CIRS, if it is forward start date, the spread is
*            not taken into account when generating the cash schedules
*            for Interest Payments on the floating leg.
*
* 30/12/03 - CI_10016218
*            ENQ-SWAP.SCHED.RR-Interest display & Blank STMT.ENTRY problem
*
* 11/04/05 - EN_10002475
*            SWAP CLEAN UP - II
*            Added a parameter for the routine SW.BUILD.SCHEDULE.LIST
*
* 05/08/05 - BG_100009217
*            System hangs while processing the unprocessed RR schedule
*
* 16/11/07 - BG_100015875
*            Charge/fee attached to schedules are not shown properly in
*            the enquiry
*
* 30/12/15 - Enhancement 1226121
*          - Task 1569212
*          - Routine incorporated
*
* 27/10/16 - Defect 1889180 / Task 1905318
*            SWAP.SCHEDULE enquiry displays NULL for zero Interest Rate.
*
* 01/11/17 - Defect 2312299 / Task 2326800
*            Enquiry SWAP.SCHEDULE displaying duplicate RR records of the same date.
*
* 28/11/17 - Defect 2359487 / Task 2359763
*            SSFO Error in TAFC where the rate field is updated as BLANK in TAFC and 0.0000 in TAFJ
*            Reported in 201712 in SWAP.SCHEDULE enquiry
*
* 03/12/18 - Defect 2875516 / Task 2884314
*            Fixed Leg interest rate is displayed in the schedule of the floating leg and 
*            no interest rate is displayed for the fixed leg.
*
*************************************************************************
*
*  Insert files.
*
    $USING SW.Contract
    $USING EB.DataAccess
    $USING SW.Schedules
    $USING SW.Foundation
    $USING EB.Reports

*************************************************************************
*
*************
MAIN.PROCESS:
*************
*
    GOSUB INITIALISATION
*
    GOSUB SAVE.COMMON         ;* Save swap common.
*
    GOSUB PROCESS.SWAP.CONTRACT         ;* Process swap contract.
*
    GOSUB PROCESS.SWAP.SCHEDULES        ;* Build enquiry data.
*
    GOSUB RELOAD.COMMON       ;* Reload swap common
*
RETURN
*
************************************************************************
*
***************
INITIALISATION:
***************
*
    F$SWAP.LOC = ""
    EB.DataAccess.Opf("F.SWAP",F$SWAP.LOC)
    SW.Foundation.setFdSwap(F$SWAP.LOC)
*
    F.SWAP$NAU = ""
    EB.DataAccess.Opf("F.SWAP$NAU",F.SWAP$NAU)
*
    F$SWAP.BALANCES.LOC = ""
    EB.DataAccess.Opf("F.SWAP.BALANCES",F$SWAP.BALANCES.LOC)
    SW.Foundation.setFdSwapBalances(F$SWAP.BALANCES.LOC)
*
    SW.Foundation.setRSwap("")
    SW.Foundation.setRSwAssetBalances("")
    SW.Foundation.setRSwLiabilityBalances("")
    SW.Foundation.setCAccountingEntries("")
    SW.Foundation.setCForwardEntries("")
*
    SW.Foundation.setCSwapId(EB.Reports.getId());* Swap contract id.
    ASST.BAL.ID = SW.Foundation.getCSwapId():".A"        ;* Asset swap bal id.
    LIAB.BAL.ID = SW.Foundation.getCSwapId():".L"        ;* Liab swap bal id.
*
    ENQUIRY.MODE = 1
*
    SCHED.TYPE.ORDER = "CI,PX,IS,IP,AP,RR,PI,PD,PM,RV,RX,CM"
    CONVERT ',' TO @VM IN SCHED.TYPE.ORDER
    AsLegCount = ''
*
RETURN
*
*************************************************************************
*
**********************
PROCESS.SWAP.CONTRACT:
**********************

*
*  Read swap contract from either the swap unauth or auth file.
*


    ER = ''
    C$SWAP.ID.VAL = SW.Foundation.getCSwapId()
    R$SWAP.VAL = SW.Contract.Swap.ReadNau(C$SWAP.ID.VAL, ER)
    IF ER THEN
        ER = ''
        R$SWAP.VAL = SW.Contract.Swap.Read(C$SWAP.ID.VAL, ER)
        IF ER THEN
            R$SWAP.VAL = ''
        END
    END
    SW.Foundation.setRSwap(R$SWAP.VAL)

*
*  Read swap balance asset and liability records.
*


    IF R$SWAP.VAL THEN
        ER = ''
        R$SW.ASSET.BALANCES.VAL = SW.Contract.SwapBalances.Read(ASST.BAL.ID, ER)
        IF ER THEN
            R$SW.ASSET.BALANCES.VAL = ""
        END
        ER = ''
        R$SW.LIABILITY.BALANCES.VAL = SW.Contract.SwapBalances.Read(LIAB.BAL.ID, ER)
        IF ER THEN
            R$SW.LIABILITY.BALANCES.VAL = ''
        END
        SW.Foundation.setRSwAssetBalances(R$SW.ASSET.BALANCES.VAL)
        SW.Foundation.setRSwLiabilityBalances(R$SW.LIABILITY.BALANCES.VAL)
    END

*
*  Process all schedules on the swap contract.
*  Will loop until there are no more schedules to process, ie.
*  the contract matures.
*  Schedule processing routines are called in enquiry mode to
*  prevent file updates.
*
    SCHEDULE.LIST = '' ; Y.PROCESS.SCHEDULES = 1
    LOOP
    WHILE (SCHEDULE.LIST OR Y.PROCESS.SCHEDULES)
        SCHEDULE.LIST = '' ; Y.PROCESS.SCHEDULES = 0
        SW.Schedules.CycleSchedules(ENQUIRY.MODE)
        SW.Schedules.BuildScheduleList(SCHEDULE.LIST, '')
        SW.Schedules.ScheduleProcessing(SCHEDULE.LIST,ENQUIRY.MODE)
    REPEAT
*
RETURN
*
*************************************************************************
*
***********************
PROCESS.SWAP.SCHEDULES:
***********************
*
*  Build enquiry data.
*  Read details from the swap balance records.
*
    IF SW.Foundation.getRSwap() THEN
*
*  Initialise enq.data to current swap contract details.
*
        ENQ.DATA = SW.Foundation.getRSwap()
*
*  Process asset leg schedules.
*  Add asset sched details to enq.data only if leg ccy defined.
*
        LEG.CCY = SW.Foundation.getRSwap()<SW.Contract.Swap.AsCurrency>          ;* Asset leg ccy.
        IF LEG.CCY THEN
            LEG.TYPE = "A"    ;* Asset.
            R$SW.BALANCES = SW.Foundation.getRSwAssetBalances()
            INT.EFF.DATE = SW.Foundation.getRSwap()<SW.Contract.Swap.AsIntEffective>      ;* Eff date.
            MARGIN.RATE = SW.Foundation.getRSwap()<SW.Contract.Swap.AsSpread> + 0
*
            IF SW.Foundation.getRSwap()<SW.Contract.Swap.AsFixedRate> <> "" OR SW.Foundation.getRSwap()<SW.Contract.Swap.AsFixedInterest> = "Y" THEN
                LEG.INT.TYPE = "FIXED"  ;* Fixed interest.
            END ELSE
                LEG.INT.TYPE = "FLOAT"  ;* Floating interest.
            END
*
            GOSUB BUILD.ENQUIRY.DATA
            AsLegCount = IDX
        END
*
*  R.RECORD (common var) - Data array passed to enquiry
*  for display.
*  Add asset sched details (ENQ.DATA) to enquiry array.
*
        EB.Reports.setRRecord(ENQ.DATA)
*
*  Process liability leg schedules.
*  Add liab sched details to enq.data only if leg ccy defined.
*
        LEG.CCY = SW.Foundation.getRSwap()<SW.Contract.Swap.LbCurrency>          ;* Liab leg ccy.
        IF LEG.CCY THEN
            LEG.TYPE = "L"    ;* Liability.
            R$SW.BALANCES = SW.Foundation.getRSwLiabilityBalances()
            INT.EFF.DATE = SW.Foundation.getRSwap()<SW.Contract.Swap.LbIntEffective>      ;* Eff date.
            MARGIN.RATE = SW.Foundation.getRSwap()<SW.Contract.Swap.LbSpread> + 0
*
            IF SW.Foundation.getRSwap()<SW.Contract.Swap.LbFixedRate> <> "" OR SW.Foundation.getRSwap()<SW.Contract.Swap.LbFixedInterest> = "Y" THEN
                LEG.INT.TYPE = "FIXED"  ;* Fixed interest.
            END ELSE
                LEG.INT.TYPE = "FLOAT"  ;* Floating interest.
            END
*
            GOSUB BUILD.ENQUIRY.DATA
*
            GOSUB APND.LB.ARR.TO.ENQ
*
        END
*
        EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<152>,@VM));* VM count for enquiry.
*
    END
*
RETURN
*
*************************************************************************
*
*******************
BUILD.ENQUIRY.DATA:
*******************
*
*  Build array ENQ.DATA with asset/liability schedule details.
*
    SORT.DATE.LIST = ""
*
    ENQ.DATA<150> = ""        ;* Leg currency.
    ENQ.DATA<151> = ""        ;* 'Fixed' or 'Float' interest.
    ENQ.DATA<152> = ""        ;* Leg type (asst or liab).
    ENQ.DATA<153> = ""        ;* Process dates.
    ENQ.DATA<154> = ""        ;* Sched types.
    ENQ.DATA<155> = ""        ;* Sched amounts.
    ENQ.DATA<156> = ""        ;* Principals outstanding by date.
    ENQ.DATA<157> = ""        ;* Start dates of 1st int periods.
    ENQ.DATA<158> = ""        ;* Sched eff dates.
    ENQ.DATA<159> = ""        ;* Value dates.
    ENQ.DATA<160> = ""        ;* Schedule dates.
    ENQ.DATA<161> = ""        ;* Effective rates.
    ENQ.DATA<162> = ""        ;* Margin rate.
*
    SCHEDS.TO.DISPLAY = 1
    PIDX = 1        ;* index to principal outstanding
*
    IDX = 0
    LOOP IDX+=1 UNTIL R$SW.BALANCES<SW.Contract.SwapBalances.BalScheduleType,IDX> = ""
*
        GOSUB UPDATE.SWAP.BAL.DETAILS
        
        IF SKIP.SCHED THEN ;* Ignore the current schedule
            CONTINUE
        END
*
        GOSUB GET.SWAP.BAL.PRIN
*
        INS SCHED.PRIN BEFORE ENQ.DATA<156,POS>
*
*  Determine effective rate (by date).
*
        LOCATE SCHED.EFF.DATE IN R$SW.BALANCES<SW.Contract.SwapBalances.BalEffectiveDate,1> BY 'DR' SETTING EIDX ELSE
            NULL
        END
        EFFECTIVE.DATE = R$SW.BALANCES<SW.Contract.SwapBalances.BalEffectiveDate,EIDX>
        EFFECTIVE.RATE = R$SW.BALANCES<SW.Contract.SwapBalances.BalInterestRate,EIDX>
*
*  If the sched.eff.date of an IP schedule EQ the effective date of a rate,
*  i.e. rate change and interest payment happen on the same date,
*  the effective rate will be the one before except the initial one.
*
        IF SCHED.TYPE[1,2] = "IP" AND EFFECTIVE.DATE = SCHED.EFF.DATE THEN
            IF R$SW.BALANCES<SW.Contract.SwapBalances.BalInterestRate,EIDX+1> THEN
                EFFECTIVE.RATE = R$SW.BALANCES<SW.Contract.SwapBalances.BalInterestRate,EIDX+1>
            END
        END
*
        IF EFFECTIVE.RATE NE "" THEN
            INS EFFECTIVE.RATE BEFORE ENQ.DATA<161,POS>
        END ELSE
            INS "" BEFORE ENQ.DATA<161,POS>
        END
*
    REPEAT
*
*  If there are no schedules to be display, default enquiry
*  header data.
*
    IF NOT(SCHEDS.TO.DISPLAY) THEN
        ENQ.DATA<150> = LEG.CCY         ;* Leg currency.
        ENQ.DATA<151> = LEG.INT.TYPE    ;* 'Float' or 'Fixed'.
        ENQ.DATA<152> = LEG.TYPE        ;* Leg type.
        ENQ.DATA<157> = INT.EFF.DATE    ;* First interest period start dates.
        ENQ.DATA<162> = MARGIN.RATE     ;* Interest spread.
    END
*
RETURN
*
************************
UPDATE.SWAP.BAL.DETAILS:
************************
*
    SCHED.EFF.FOUND = '' ;* a flag to identify the multiple schedules with same effective date
    SCHED.TYPE = R$SW.BALANCES<SW.Contract.SwapBalances.BalScheduleType,IDX>
    CHRG.CODE = R$SW.BALANCES<SW.Contract.SwapBalances.BalChargeCode,IDX>
    SCHED.EFF.DATE = R$SW.BALANCES<SW.Contract.SwapBalances.BalSchedEffDate,IDX>
*
*  Sort schedules by schedule type and schedule eff date.
*
    LOCATE SCHED.TYPE[1,2] IN SCHED.TYPE.ORDER<1,1> SETTING TYP.IDX ELSE
        NULL
    END
    SORT.KEY = SCHED.EFF.DATE:FMT(TYP.IDX,"2'0'R")
*
    SCHED.EFF.FOUND = 1       ;* Assume schedule with same effective date is found
    LOCATE SORT.KEY IN SORT.DATE.LIST<1,1> BY "AR" SETTING POS ELSE
        SCHED.EFF.FOUND = ''   ;* Schedule with the same effective date is not found
        NULL
    END
    SKIP.SCHED = '' ;* skip the schedule for processing
    IF SCHED.TYPE[1,2] = 'RR' AND SCHED.EFF.FOUND THEN  ;* Multiple schedules for the same effective date are found
        SKIP.SCHED = 1
        RETURN
    END
    INS SORT.KEY BEFORE SORT.DATE.LIST<1,POS>
*
    INS LEG.CCY BEFORE ENQ.DATA<150,POS>
    INS LEG.INT.TYPE BEFORE ENQ.DATA<151,POS>
    INS LEG.TYPE BEFORE ENQ.DATA<152,POS>
    INS R$SW.BALANCES<SW.Contract.SwapBalances.BalProcessDate,IDX> BEFORE ENQ.DATA<153,POS>
    IF CHRG.CODE THEN
        IF R$SW.BALANCES<SW.Contract.SwapBalances.BalCcyAmount,IDX> LT 0 THEN
            SCHED.TYPE = SCHED.TYPE:"-FEE"
        END ELSE
            SCHED.TYPE = SCHED.TYPE:"-CHRG"
        END
    END
    INS SCHED.TYPE BEFORE ENQ.DATA<154,POS>
    INS R$SW.BALANCES<SW.Contract.SwapBalances.BalCcyAmount,IDX> BEFORE ENQ.DATA<155,POS>
*
    INS INT.EFF.DATE BEFORE ENQ.DATA<157,POS>
    INS SCHED.EFF.DATE BEFORE ENQ.DATA<158,POS>
    INS R$SW.BALANCES<SW.Contract.SwapBalances.BalValueDate,IDX> BEFORE ENQ.DATA<159,POS>
    INS R$SW.BALANCES<SW.Contract.SwapBalances.BalScheduleDate,IDX> BEFORE ENQ.DATA<160,POS>
    INS MARGIN.RATE BEFORE ENQ.DATA<162,POS>
*
RETURN
*
******************
GET.SWAP.BAL.PRIN:
******************
*  Determine schedule principal outstanding (by date).
    SCHED.PRIN = ""
*
    LOOP
        PRIN.EFF.DATE = R$SW.BALANCES<SW.Contract.SwapBalances.BalPrinDate,PIDX>
    UNTIL PRIN.EFF.DATE = "" DO
        IF PRIN.EFF.DATE <= SCHED.EFF.DATE THEN
            SCHED.PRIN = R$SW.BALANCES<SW.Contract.SwapBalances.BalPrincipal,PIDX>
*
*  If the sched.eff.date of an IP schedule EQ the effective principal date,
*  i.e. principal movement and interest payment happen on the same date,
*  the effective principal will be the one before except the initial one.
*
            IF SCHED.TYPE[1,2] = "IP" AND PRIN.EFF.DATE = SCHED.EFF.DATE AND R$SW.BALANCES<SW.Contract.SwapBalances.BalPrincipal,PIDX+1> THEN
                SCHED.PRIN = R$SW.BALANCES<SW.Contract.SwapBalances.BalPrincipal,PIDX+1>
            END
            EXIT    ;* this loop
        END
        PIDX += 1
    REPEAT
*
RETURN
*
*******************
APND.LB.ARR.TO.ENQ:
*******************
*  Append liab sched details (ENQ.DATA) to enquiry array.
*
    R.RECORD.VAL = EB.Reports.getRRecord()
    INS ENQ.DATA<150> BEFORE R.RECORD.VAL<150,-1>
    INS ENQ.DATA<151> BEFORE R.RECORD.VAL<151,-1>
    INS ENQ.DATA<152> BEFORE R.RECORD.VAL<152,-1>
    INS ENQ.DATA<153> BEFORE R.RECORD.VAL<153,-1>
    INS ENQ.DATA<154> BEFORE R.RECORD.VAL<154,-1>
    INS ENQ.DATA<155> BEFORE R.RECORD.VAL<155,-1>
    INS ENQ.DATA<156> BEFORE R.RECORD.VAL<156,-1>
    INS ENQ.DATA<157> BEFORE R.RECORD.VAL<157,-1>

    INS ENQ.DATA<158> BEFORE R.RECORD.VAL<158,-1>
    INS ENQ.DATA<159> BEFORE R.RECORD.VAL<159,-1>
    INS ENQ.DATA<160> BEFORE R.RECORD.VAL<160,-1>
* If EffectiveRate array of asset leg fully holds null value, then insert the liability leg details after the asset leg position.
    IF R.RECORD.VAL<161> EQ '' THEN
        INS ENQ.DATA<161> BEFORE R.RECORD.VAL<161,AsLegCount>
    END ELSE
        INS ENQ.DATA<161> BEFORE R.RECORD.VAL<161,-1>
    END
    INS ENQ.DATA<162> BEFORE R.RECORD.VAL<162,-1>

    EB.Reports.setRRecord(R.RECORD.VAL)
*
RETURN
*
************
SAVE.COMMON:
************
*
    SW.Foundation.SaveCommon()
*
RETURN
*
*************************************************************************
*
**************
RELOAD.COMMON:
**************
*
    SW.Foundation.RestoreCommon()
*
RETURN
*
*************************************************************************
*
END
