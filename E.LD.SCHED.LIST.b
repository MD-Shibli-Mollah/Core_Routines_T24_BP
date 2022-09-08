* @ValidationCode : MjotMTQ2MjE2NjE4NTpDcDEyNTI6MTYxMDU1MzM1NDYzNDpqb3NlcGgucmFqZXNoOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoxMTU5OjY4OA==
* @ValidationInfo : Timestamp         : 13 Jan 2021 21:25:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : joseph.rajesh
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 688/1159 (59.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>7968</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LD.ModelBank
SUBROUTINE E.LD.SCHED.LIST

***********************************************************************
*
* This routine is used by the RPMNT.HSTRY enquiry to read all the schedule
* records and assemble the required information in R.RECORD in
*
***********************************************************************
*
* 26/06/95 - GB9500241
*            LD Early Repayments
*            Add processing for new type N schedules.
*
* 29/10/96 - GB9601327 & GB9601631 & GB9601703
*            Restructure to use LD.CYCLE.SCHEDULES
*
* 06/02/97 - GB9700132
*            Pick up NAU changes online if present. Include Diary schedules
*
* 02/04/97 - GB9700367
*            Add the adjusted date (using day convention)
*
* 01/05/97 - GB9700467
*            Liability Commitments for LDs.
*
* 28/05/97 - Onsite
*            Check back valued interest and commission schedules in the future
*            list as these are back-valued drawdown entries
*
* 02/06/91 - GB9700681
*            Show cancelled interest
*
* 22/10/97 - GB9701226
*            Do not add Capitalised interest to the runing balances for
*            past schedules as it is included anyway
*
* 27/10/97 - GB9701233
*            Include the first principal repayment for BEGIN annuity contract.
*
* 12/11/97 - GB9701078
*            Include Tax, split prin into dr and cr
*            Option to show principal mvmts in different lines
*
* 20/11/97 - GB9701369
*            Allow defaulting of tax keys via *tax.type.condition method
*            remove no change restriction from tax key fields. (KRB30102)
*
* 02/12/97 - GB9701367
*            Year 2000 changes - Extend contract keys/date field on
*                                schedule files for century compliance
*
* 16/01/98 - GB9701473
*            Incorrect signing for FEE amounts
*
* 01/04/98 - GB9800331
*            Cater for the situation were a FWD LD is modified on its
*            value date and thus moves from FWD to CUR online. The
*            balance info is both on the Account Blances and schedule
*            files at the Unau stage
*
* 09/07/98 - GB9800876
*            Correct incorrect correction of GB9701473 above
*
* 13/10/98 - GB9801260
*            Fees Payable should always be shown as negative
*
* 05/09/00 - GB0000515
*            LD capitalisation of interest and commission residual
*            balance left after maturity date
*
* 11/10/00 - GB0002581 - PJG
*            Added variable to pass to LD.TAX.CALC for German Withholding Tax.
*
* 10/01/01 - GB0002969
*            An extra argument is added to LD.BUILD.FUTURE.SCHEDULES
*            for enhancing the application of commission on the highest
*            balance on all types of loans.
*
* 29/01/01 - GB0002032
*            The enquires LD.BALANCES.FULL and LD.BALANCES.SUM do not
*            show the principal Amount in right way. In case we do any
*            Amendment to a Loan Contract on the Maturity date.
* 09/11/01 - CI_10000498
*             Correct the incorrect calcultion in capitalised deposit
*             type contracts
*
* 24/10/01 - CI_10000084
*            Capitalised charge (N schedule) should be added to total
*            principal and showed in the charge field of Enquires.
*
* 17/01/01 - EN_10000280
*            LD - Capitalisation without LDS.
*            In the call to LD.BUILD.FUTURE.SCHEDULES, concat the contract
*            ID with an additional info 'ENQUIRY'
*
* 30/01/02 - CI_10000877
*             Charge date fixing in enquiry
*
* 08/07/02 - CI_10002587
*            Enquiries showing the same opening and closing date after
*            crossing the maturity date.
*
* 24/07/02 - CI_10002810
*            When interest is capitalised  and tax amount is deducted,
*            the enq LD.BALANCES.SUM and LDSCHEDXL show wrong information
*            related to outstanding amount. The outstanding amounts for
*            future dates are not decreased by the tax amount.
*
* 23/09/02 - CI_10003792
*            For a discounted type of contract the amount display
*            in LD.BALANCES.Full is different from the one display
*            in contract
* 18/02/03 - CI_10006732
*            For a F schedule contract the enquiry does not
*            differentiate between pay and receive type of charges
*
* 16/05/03 - CI_10009205
*            When DD.FEE.CODE & DD.FEE.AMOUNT are input in a LD contract
*            the fees is doubled & shown in the enquiry.
*
* 18/08/04 - CI_10021916
*            LD.BALANCES.SUM enquiry shows incorrect value when 2 events
*            happen during the Maturity date.
*
* 24/09/04 - CI_10023053
*            Display of LD.BALANCES.FULL shows incorrect
*            Commission amt when commission is Discounted.
*            The amounts in the contract dint match with the
*            the one in the enquiry display when viewed at INAU stage
*            after AUTH stage.
* 12/10/04 - BG_100007279
*            Replacement of READ statements with CACHE.READ
*
* 14/12/04 - EN_10002384
*            Allowing overlapping of repayment schedule dates
*            Modify enquiry to show PRIN.AMT.SPLIT in individual lines.
*
* 17/12/04 - EN_10002387
*            Include capitalise interest for repayment enhancement
*
*13/04/05 - CI_10029238
*            Subtract the drawdown issue P&L from outstanding principal.
*
* 23/05/05 - CI_10030457
*            Include Principal portion of the Annuity Repayment amount
*            in the PRIN.AMT.SPLIT
*
* 21/07/05 - CI_10032538
*            Enquiry updates Principal amount incorrectly
*
* 09/09/05 - CI_10034444
*            Enquiry does not show the last repayment schedule amount that
*            was processed during SOD after the contract is preclosed on last
*            repayment schedule date(TODAY).
*
* 22/09/05 - CI_10034856
*            When 'N' schedule is defined system does not shows
*            sch.amt in RUNNING.BAL for past schedules.
*
* 13/10/05 - CI_10035606
*            Back Dated Contract Maturity Enquiry shows Incorrect output.
*
* 07/03/06 - CI_10039496
*            Enquiry does not show the initial principal disbursed when
*            ISSUE.PRICE is given a value other than 100
*
* 24/11/06 - CI_10045680
*            Enquiry displays the interest as zero for an "S" basis, forward
*            dated Discounted Loan contract with "I" and "P" schedules.
*
* 8/12/06 - CI_10046014
*           LD Discounted contract Mature at SOD set
*           Changing the maturity date Enquiry output incorrect.
*
* 08/01/07 - CI_10046484
*            Enquiry LD.DIARY.DETAILS shows blank page when there is no Dairy
*            details to display.
*
* 02/05/07 - CI_10048795
*            System shows enquiry incorrectly for LD, COMM.PAYABLE contract
*            after the schedule gets processed.
*
* 21/05/07 - CI_10049195/CI_10049442
*            LD.BALANCES.SUM enquiry shows incorrectly during principal decrease
*
* 03/12/07 - BG_100016136
*            Include Capitalised charge for repayment
*
* 18/12/07 - CI_10052996
*            To display the Interest rate in the enquiry LD.BALANCES.FULL and LD.BALANCES.SUM
*
* 12/07/08 - EN_10003755
*            Provision for multiple interest tax keys
*
* 10/09/09 - CI_10065987
*            when LD is input with MATURE.AT.SOD is set to yes and schedule on the current system date enquiry
*            shows incorrect balance
*
* 04/11/09 - CI_10067371
*            COB phase is determined by checking R.SPF.SYSTEM< SPF.OP.MODE> eq .B  AND
*            R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>[1,3] EQ 'COB'.
*
* 04/06/10 - CI_10070474
*            Capitalise interest amount add only once, to outstanding balance.
*
* 20/07/10 - 69962
*            System is not showing capitalisation of interest amount, with start date
*            because of uninistalisation of NEW.CAP.AMT.
*
* 25/11/10 - 112942
*            Defect: 110867 & Ref: HD1046928
*            When running a enquiry LD.BALANCES.FULL for a LD contract with CAPITALISATION
*            field as "YES" and two or more "P" schedules falls on maturity date system projection
*            of enquiry output was wrong.
*
* 11/04/11 - Task: 190006
*            Defect: 183021 & Ref: PACS00052189
*            System is not showing capitalisation of interest amount, with start date
*            because of uninistalisation of NEW.CAP.AMT.
*
* 29/04/11 - Task: 200947
*            Defect: 199911 & Ref: PACS00021539
*            System must perform checks while calculaintg TOT.PAY
*
* 16/06/11 - Task 228309
*            Defect - 224037
*            After cob the first month in loan Enquiry appears twice for LD Annuity contract,
*            hence all the remaining schedules are collapsed.
*
* 28/06/11 - Task: 235629 / Defect: 231587
*            Enquiry LD.BALANCES.SUM doesn't show the principal due amount correctly.
*
* 14/07/11 - CI_10073667 / Defect: 231587
*            Enquiry LD.BALANCES.SUM missing interest schedule on the date which we are doing amount increase.
*
* 01/02/12 - Task: 348112 / Defect: 346434
*            When a LD deposit contract input with capitalisation set to "YES", the Enquiry
*          LD.BALANCES.SUM shows wrong outstanding amount for the processed schedules.
*
* 24/02/12 - Task: 361376 / Defect: 358807
*            Set PROCESS.P.SCHED variable to 1 after processing each schedules even though
*    schedule amount is "0".
*
* 15/06/12 - Task: 423476 / Defect: 357675
*            Changed FOR NEXT statements to LOOP REMOVE to increase the enquiry performance.
* 11/07/12 - Task: 441236 / Defect : 435495
*            To handle the performance problem, we have to execute remove only when the previously fetched
*            Principle change is processed.
*
* 25/09/12 - Task:487777/Defect:487983
*            R10_LD_Reports_10 issue. While running the enquiry LD.BALANCES.SUM\LD.BALANCES.FULL for LD contracts
*            system shows wrong outstanding amount in the enquiry output.
*
* 05/11/12 - Task: 511459 / Defect: 504197
*            While running the enquiry LD.BALANCES.FULL after crossing an I schedule
*            and P schedule on the same day, system projects the outstanding amount without the I schedule amount
*
* 22/05/13 - Task: 683337 / Defect : 674496
*            Intialisation routine should be called each time the enquiry routine processes the request
*
* 15/07/13 - Task : 729367 / Defect : 723077
*            Enquiry LD.BALANCES.FULL displays wrong repayment schedule when we define two principal schedules on Maturity date.
*
* 22/04/14 - Defect : 972566 & Task : 978821
*            When 'N' schedule is defined system should check the calc type.
*            If it is PAY type CAP.CHG.AMT should be in positive and if it is RECEIVE then it should be Negative
*
* 03/09/14 - Defect : 1092152 & Task : 1103602
*             Enquiry shows incorrect values for Total Amount & Principal Amount Labels.
*
* 29/01/15 - Defect : 1235721 & Task : 1254377
*            Enquiry shows incorrect oustanding amount in the shcedules.
*
* 17/04/15 - Task : 1319451  / Defect : 1314309
*            When the drawing was input on greater than the Value date of commitment contract ,
*            enquiry failed to display the correct outstanidng amount.
*
* 04/05/15 - Task : 1333292 / Defect : 1298150
*            LD.BALANCES.FULL displays the capitalized charge and interest wrongly in the columns total payment and principal
*            with negative sign for the processed schedules.
*
* 23/04/15 - Task : 1325793 / Defect : 1316162
*            When the enquiry LD.BALANCES.FULL processed on COB, system would display the  LD detials .
*
* 03/06/15 - Task : 1365103 / Defect : 1298150
*            LD.BALANCES.FULL displays the capitalized charge and interest wrongly in the columns total payment and principal
*            with negative sign for the processed schedules.
*
* 09/12/16 - Defect : 1939175 / Task : 1949762
*            Outstanding amount is displayed incorrectly for commitment contracts.
*
* 22/04/17 - Defect : 2096924 / Task :2098366
*            Charge/Fee amount is not displaying on the  LD.BALANCES.SUM screen.
*
* 03/03/18 - Defect : 2480006 / Task :2487487
*            Incorrect payment details in schedule summary output
*
* 08/03/18 - Defect : 2480006 / Task : 2494643
*            Incorrect payment details in schedule summary output.
*
* 21/12/2018 - Enhancement: 2822515
*              Task :  2847828
*              Componentisation changes.
*
* 22/04/19 - Defect : 3088897 / Task :3096139
*            When F schedule is defined before the I schedule ,
*            The amount is displayed as double in charge column on the LD.BALANCES.FULL enquiry after crossing the F and  I schedules.
** 21/09/20 - Task :4048013 / Enhancement :3346226
*            LD RFR Enhancement-LD_ModelBank
*

***********************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ENQUIRY
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.LMM.SCHEDULE.DATES
    $INSERT I_F.DATES
    $INSERT I_F.COMPANY
    $INSERT I_F.LMM.SCHEDULES.PAST
    $INSERT I_F.LMM.SCHEDULES
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.PERIODIC.INTEREST
    $INSERT I_F.BASIC.RATE.TEXT
    $INSERT I_F.LMM.ACCOUNT.BALANCES
    $INSERT I_LD.ENQ.COMMON
    $INSERT I_F.PD.PAYMENT.DUE
    $INSERT I_LD.SCH.LIST
    $INSERT I_F.CURRENCY
    $INSERT I_F.SPF
    $INSERT I_TSA.COMMON
    $INSERT I_F.TSA.STATUS
    $INSERT I_F.LMM.CHARGE.CONDITIONS
*
***********************************************************************

MAIN.ROUTINE:
*------------

    GOSUB INITIALISE

    GOSUB PRE.PROCESS.SCHEDULES
    GOSUB PROCESS.SCH

    GOSUB FINAL.PROCESS
*
MAIN.ROUTINE.EXIT:
*-----------------
RETURN
************************************************************************
*
INITIALISE:
*----------
*
    CURR.DETAILS.ARR = ""
    CURR.PRIN.DATE = ""
    SCHEDULE.DETAILS = ""     ;* List of schedule records with full details
    ACCBAL.REC = R.RECORD     ;* Main file is account balances
    GOSUB READ.SCHEDULE.DATES
    DATE.LIST = CONVERT(@VM,"*",SCHED.DATES)
    SCHEDULE.DATES = FIELDS(DATE.LIST,"*",1,1)    ;* Schedule dates
    SCHEDULE.PROCESSED = FIELDS(DATE.LIST,"*",2,1)          ;* D or A flag
    FUTURE.SCHEDULE.DATES = ""          ;* Future schedule dates
    OTS.BALANCES = ""         ;* Array of balances on the schedule date
    FIRST.INPUT = (SCHED.DATES = "")
    BALANCE.SUMMARY = ""      ;* Balance summary record
    NEXT.LEVEL = "" ;* Level down enquiry

    EOD = (R.SPF.SYSTEM<SPF.OP.MODE> EQ 'B' AND R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>[1,3] EQ 'COB')
*
    TOT.PAY = 0
    VM.COUNT = '' ; SM.COUNT = ""       ;* Set during enquiry
    R.RECORD = ''   ;*  Returned M/v record
    R.DATE.IND = '' ;* Index for dates SCHED:ADJ
    NO.OF.DAYS = ""
    ALREADY.PROCESSED = ''    ;* To Prevent Fees From Being Processed Twice CI_10009205
    SCH.I.PROCESSED = ''
    SCH.C.PROCESSED = ''
    SKIP.I.SCH = ''
    SKIP.C.SCH =''
    IF SCHED.DATES THEN
        NO.OF.DAYS = COUNT(SCHED.DATES,@FM) + 1
    END
    V$SEQ = ID[13,2]
    IF EOD THEN
        PROCESS.DATE = R.DATES(EB.DAT.NEXT.WORKING.DAY)
    END ELSE
        PROCESS.DATE = R.DATES(EB.DAT.TODAY)
    END
    PROCESS.JULDATE = R.DATES(EB.DAT.JULIAN.DATE)
    GOSUB READ.CONTRACT.ARRAY
*
    LOAN.OR.DEPOSIT = "" ; LD.TYPE = ""
    CALL LD.CONTYPE(R.CONTRACT<LD.CATEGORY>, LOAN.OR.DEPOSIT, LD.TYPE, "", "")
    GREG.VALUE.DATE = R.CONTRACT<LD.VALUE.DATE>
*
    DISCOUNTED.INT = R.CONTRACT<LD.INT.PAYMT.METHOD> EQ "2"
    DISCOUNTED.COMM = R.CONTRACT<LD.COMM.PAYMT.METHOD> EQ "2"
*
** Allow for a start and end date to be passed in to the enquiry
*
    LOCATE "START.DATE" IN ENQ.SELECTION<2,1> SETTING ST.POS THEN
        START.DATE = ENQ.SELECTION<4,ST.POS>
    END ELSE
        START.DATE = ""
    END
*
    LOCATE "END.DATE" IN ENQ.SELECTION<2,1> SETTING ST.POS THEN
        END.DATE = ENQ.SELECTION<4,ST.POS>
    END ELSE
        END.DATE = ""
    END
*
    LOCATE "SHOW.PD.INFO" IN ENQ.SELECTION<2,1> SETTING PD.POS THEN
        INCLUDE.PD = ENQ.SELECTION<4,PD.POS>[1,1]
    END ELSE
        LOCATE "SHOW.PD.INFO" IN R.ENQ<ENQ.FIELD.NAME,1> SETTING PD.POS THEN
            INCLUDE.PD = R.ENQ<ENQ.OPERATION,PD.POS>[1,1]
        END ELSE
            INCLUDE.PD = ""
        END
    END
*
    LOCATE "INDIVIDUAL.MVMTS" IN ENQ.SELECTION<2,1> SETTING IM.POS THEN
        IND.PRIN = ENQ.SELECTION<4,IM.POS>[1,1]
    END ELSE
        LOCATE 'INDIVIDUAL.MVMTS' IN R.ENQ<ENQ.FIELD.NAME,1> SETTING IM.POS THEN
            IND.PRIN = CONVERT('"','',R.ENQ<ENQ.OPERATION,IM.POS>)[1,1]
        END ELSE
            IND.PRIN = ''
        END
    END
*
** The enquiry may supply a selection of the schedule types required for
** display. This can be a selection field of SCHEDULE.TYPES or in the
** body of the enquiry
*
    SCHED.TYPES = "ALL"
    LOCATE "SCHEDULE.TYPES" IN ENQ.SELECTION<2,1> SETTING ST.POS THEN
        SCHED.TYPES = ENQ.SELECTION<4,ST.POS>
    END ELSE
        LOCATE "SCHEDULE.TYPES" IN R.ENQ<ENQ.FIELD.NAME,1> SETTING ST.POS THEN
            SCHED.TYPES = CONVERT('"','',R.ENQ<ENQ.OPERATION,ST.POS>)
        END
    END
*
    PD.REC = ""
    PD.ID = "PD":CONTRACT.NO
    IF INCLUDE.PD MATCHES "Y":@VM:"M" THEN
        CALL F.READ("F.PD.PAYMENT.DUE", PD.ID, PD.REC, F.PD.PAYMENT.DUE, "")
    END
*
    PREV.LINE = 0   ;* EN_10002384
    SCHED.CAP = 0   ;* EN_10002387 S/E
INITIALISE.EXIT:
RETURN
************************************************************************
*
PRE.PROCESS.SCHEDULES:
*====================
** Read the Account balances record
** Expand all future schedules to calculate the amounts
*
    LAST.BALANCE = 0
*
** Get the opening Balance
*
    YI = 1 ; RUNNING.BAL = 0
    NEW.CAP.AMT = 0 ;* CI_10000084

    NO.BAL = DCOUNT(ACCBAL.REC<LD27.TRANS.PRIN.AMT>,@VM)
    OPEN.BAL = 0    ;* Store th estarying balance
    INITIAL.DD.AMT = ""       ;* Store the initial drawdown
    LOOP
        INITIAL.DD.AMT = ACCBAL.REC<LD27.TRANS.PRIN.AMT,YI>
    UNTIL ACCBAL.REC<LD27.TRANS.PRIN.AMT,YI> NE "" OR YI GT NO.BAL
        YI += 1
    REPEAT
*
** Check each principal change date is in the schedule date list. It may
** not be in the case of a back valued, or value today decrease / increase
** we should insert the date in the array in this case and let process
** schedules past to take care of  it
*
    PRIN.CNT = ''
    LOOP
        PRIN.CNT += 1
    WHILE ACCBAL.REC<LD27.EFFECTIVE.DATE,PRIN.CNT>
        IF ACCBAL.REC<LD27.EFFECTIVE.DATE,PRIN.CNT> LE ACCBAL.REC<LD27.DATE.FROM,PRIN.CNT> THEN     ;* Back value / Today
            JUL.EFF.DATE = '' ; VDATE = ACCBAL.REC<LD27.EFFECTIVE.DATE,PRIN.CNT>
            CALL JULDATE(VDATE, JUL.EFF.DATE)
            LOCATE JUL.EFF.DATE IN SCHEDULE.DATES<1> BY 'AR' SETTING VDPOS ELSE
                INS JUL.EFF.DATE BEFORE SCHEDULE.DATES<VDPOS>
            END
        END
    REPEAT
* CI_10000877 - S
    CHG.CNT = 0
    LOOP
        CHG.CNT += 1
    WHILE ACCBAL.REC<LD27.CHRGS.DUE.DATE,CHG.CNT>
        JUL.EFF.DATE = '' ; VDATE = ACCBAL.REC<LD27.CHRGS.DUE.DATE,CHG.CNT>
        CALL JULDATE(VDATE, JUL.EFF.DATE)
        LOCATE JUL.EFF.DATE IN SCHEDULE.DATES<1> BY 'AR' SETTING VDPOS ELSE
            INS JUL.EFF.DATE BEFORE SCHEDULE.DATES<VDPOS>
        END
    REPEAT
* CI_10000877 - E
*
***!      OPEN.BAL = RUNNING.BAL
*
** Build a list of future schedules for processing
*
    SAVE.FUNCTION = V$FUNCTION
    IF EOD THEN
        V$FUNCTION = ""       ;* Do NOT use I. This will write in EOD
    END
    EXPANDED.DETAILS = "" ; FUTURE.IDX = ""
* GB0002969 STARTS
*      CALL LD.BUILD.FUTURE.SCHEDULES(ID[1,12], R.CONTRACT, ACCBAL.REC, FUTURE.SCHEDULE.DATES, EXPANDED.DETAILS, OTS.BALANCES)
    R.EB.BALANCES = ''
* EN_10000280 S
    LD.ID = ''
    LD.ID = ID[1,12]:@FM:'':@FM:'ENQUIRY'
* EN_10000280 E
    CALL LD.BUILD.FUTURE.SCHEDULES(LD.ID, R.CONTRACT, ACCBAL.REC, FUTURE.SCHEDULE.DATES, EXPANDED.DETAILS, OTS.BALANCES,R.EB.BALANCES)      ;* EN_10000280 S/E
* GB0002969 ENDS
    V$FUNCTION = SAVE.FUNCTION
*
RETURN
*
*--------------------------------------------------------------------
PROCESS.SCH:
*-----------
** Take each schedule and extract the elevant details

*

    CAT.CODE = R.CONTRACT<LD.CATEGORY>
    LCU.CALC.BASE = R.CONTRACT<LD.L.C.U.CALC.BASE>

    CALL LD.CONTYPE(CAT.CODE,LOAN.OR.DEPOSIT,LD.CON.TYPE,"","")

    IF LD.CON.TYPE EQ "COMMITMENT" AND LCU.CALC.BASE MATCHES "TRANCHE-UNUSED":@VM:"UNUSED" THEN

        LD.REC = R.CONTRACT

        SCH.DATES = ''
        SCH.AMTS = ''
        CALL LD.TRANCHE.SCHED(LD.REC, LD.ID, ACCBAL.REC, MVMT.PRIN.DATA, SCH.DATES, SCH.AMTS, END.DATE)

        NO.OF.DAYS = DCOUNT(FUTURE.SCHEDULE.DATES<1>,@VM)
        SCH.DATE.DIETER = ""

        MVMT.DATES = FIELD(MVMT.PRIN.DATA,@FM,1,1)
        MVMT.AMTS = FIELD(MVMT.PRIN.DATA,@FM,2,1)
        TOT.MVMT.DATES = DCOUNT(MVMT.DATES,@VM)

        INIT.DATE.POS = 1
        TOT.MVMT.POS = TOT.MVMT.DATES
        MVMT.DATES.SORT = ''
        MVMT.AMTS.SORT = ''

        LOOP
        UNTIL (TOT.MVMT.POS < INIT.DATE.POS)
            MVMT.DATES.SORT<-1> = MVMT.DATES<1,TOT.MVMT.POS>
            MVMT.AMTS.SORT<-1> =  MVMT.AMTS<1,TOT.MVMT.POS>
            TOT.MVMT.POS -= 1
        REPEAT

    END

    NO.OF.DAYS = DCOUNT(SCHEDULE.DATES, @FM)
    SCH.DATE.DIETER = "" ; CONTRACT.STATUS = 'FWD'
    SCH.DATE.ARR = SCHEDULE.DATES

    GOSUB BUILD.PROCESS.DATES

    DO.PROCESS = 0
    LOOP
        REMOVE SCH.DATE FROM SCH.DATE.ARR SETTING SCH.DATE.POS
    WHILE SCH.DATE
        PRIN.SUM.WITHIN.DATES = ''      ;*CI_10030457 -S
        SPLIT.PROCESSED = ''  ;*CI_10030457 -E
        SCH.DATE.DIETER = ''
        CALL JULDATE(SCH.DATE.DIETER,SCH.DATE)
    UNTIL SCH.DATE.DIETER GT END.DATE AND END.DATE NE ""
        IF SCH.DATE.DIETER LE PROCESS.DATE THEN
            IF LD.CON.TYPE EQ "COMMITMENT" AND LCU.CALC.BASE MATCHES "TRANCHE-UNUSED":@VM:"UNUSED" THEN
                TOT.MVMT.DATES = DCOUNT(MVMT.DATES.SORT,@FM)
                FOR I = 1 TO TOT.MVMT.DATES
                    MVMT.DATE = MVMT.DATES.SORT<I>
                    IF (MVMT.DATE LE SCH.DATE.DIETER AND MVMT.DATE LE PROCESS.DATE)THEN
                        IF MVMT.AMTS.SORT<I> GT '0' THEN
* system updates the Principal schedule with '+ve' value of the Draw down LD contract for LD commitment
* so system taking up with possitive value in the MVMT.PRIN.DATA. otherwise system has Negative value
                            RUNNING.BAL.COMMIT = MVMT.AMTS.SORT<I> * -1
                        END ELSE
                            RUNNING.BAL.COMMIT = MVMT.AMTS.SORT<I>
                        END
                    END
                NEXT I
            END
            GOSUB PROCESS.SCH.PAST
        END
    REPEAT
*
** Now process the future scheduled events
*
    NO.OF.DAYS = DCOUNT(FUTURE.SCHEDULE.DATES<1>,@VM)
    SCH.DATE.DIETER = ""
    FOR FUTURE.IDX = 1 TO NO.OF.DAYS
        SCH.DATE.DIETER = FUTURE.SCHEDULE.DATES<1,FUTURE.IDX>
        SCH.DATE = ""
        CALL JULDATE(SCH.DATE.DIETER, SCH.DATE)
    UNTIL SCH.DATE.DIETER GT END.DATE AND END.DATE NE ""
        IF R.CONTRACT<LD.FIN.MAT.DATE> LT PROCESS.DATE THEN
            PROCESS.DATE = R.CONTRACT<LD.FIN.MAT.DATE>      ;*CI_10035606 S/E
        END
        IF SCH.DATE.DIETER GE PROCESS.DATE THEN   ;* CI_10003792 S-E ; * CI_10006732 S-E
            IF LD.CON.TYPE EQ "COMMITMENT" AND LCU.CALC.BASE MATCHES "TRANCHE-UNUSED":@VM:"UNUSED" THEN
                GOSUB CHECK.FALLS.DATES
            END
            GOSUB PROCESS.SCH.REST
        END         ;* CI_10003792 S-E
    NEXT FUTURE.IDX
*
PROCESS.SCH.EXIT:
RETURN

CHECK.FALLS.DATES:
*-----------------

    TOT.MVMT.DATES = DCOUNT(MVMT.DATES.SORT,@FM)

    FOR I = 1 TO TOT.MVMT.DATES

        MVMT.DATE = MVMT.DATES.SORT<I>
        IF (SCH.DATE.DIETER GE MVMT.DATE AND MVMT.DATE LE TODAY AND FUTURE.IDX EQ '1' ) OR (SCH.DATE.DIETER GE MVMT.DATE AND MVMT.DATE GE PROCESS.DATE) THEN
            IF MVMT.AMTS.SORT<I> THEN
* system updates the Principal schedule with '+ve' value of the Draw down LD contract for LD commitment
* so system taking up with possitive value in the MVMT.PRIN.DATA. otherwise system has Negative value
                IF MVMT.AMTS.SORT<I> GT '0' THEN
                    RUNNING.BAL.COMMIT = MVMT.AMTS.SORT<I> * -1
                END ELSE
                    RUNNING.BAL.COMMIT = MVMT.AMTS.SORT<I>
                END
            END
        END

    NEXT I
RETURN

*--------------------------------------------------------------------
BUILD.PROCESS.DATES:
*-------------------
    EFF.DATE.ARR = ACCBAL.REC<LD27.EFFECTIVE.DATE>
    CNT.DT = 1
    LOOP
        REMOVE EFF.DATE FROM EFF.DATE.ARR SETTING DATE.POS
    WHILE EFF.DATE
* Check eff.date and date.from fields to display correct outstanding amount in the enquiry output.
        IF EFF.DATE LE ACCBAL.REC<LD27.DATE.FROM,CNT.DT> THEN
            IF CURR.DETAILS.ARR THEN
                CURR.DETAILS.ARR = CURR.DETAILS.ARR:@FM:EFF.DATE:'*':ACCBAL.REC<LD27.TRANS.PRIN.AMT,CNT.DT>
            END ELSE
                CURR.DETAILS.ARR = EFF.DATE:'*':ACCBAL.REC<LD27.TRANS.PRIN.AMT,CNT.DT>
            END
        END
        CNT.DT += 1
    REPEAT

    CURR.DETAILS.ARR = SORT(CURR.DETAILS.ARR)

RETURN
*
*--------------------------------------------------------------------
BUILD.PRIN.DETAILS:
*------------------
    PRIN.SUM.WITHIN.DATES += -CURR.PRIN.AMT       ;*Add the Trans Prin Amt within a schedule date
    SCHEDULES.PAST.REC<LD28.PRINCIPAL.DUE.AMT> += -CURR.PRIN.AMT

RETURN
*
*--------------------------------------------------------------------
BUILD.PRIN.DATA:
*---------------
    PRIN.SUM.WITHIN.DATES -= SUM(SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT>)
    IF CAP.INT.YES THEN
        PRIN.SUM.WITHIN.DATES -= INTEREST.AMT + TAX.AMT.INT ;*Capitalised Amount to be added only in Running Bal ;*CI_10032538  -S/E
    END
    IF NEW.CAP.AMT THEN
        PRIN.SUM.WITHIN.DATES -= NEW.CAP.AMT
    END
    NO.OF.SPLT = DCOUNT(SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT>,@VM)
    IF NOT(NO.OF.SPLT) THEN
        NO.OF.SPLT = 1
    END
    SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT,NO.OF.SPLT> += PRIN.SUM.WITHIN.DATES
*
    IF SCHEDULES.PAST.REC<LD28.PRINCIPAL.DUE.AMT> THEN
        PROCESS.P.SCHED = 1
        SPLIT.PROCESSED = 1
        EVENT.DATE = ACCBAL.REC<LD27.DATE.FROM,VDPOS>       ;* Date of Event
        GOSUB ADD.PRINC.SCHED.PAST
    END

RETURN
*

*
*************************************************************************
READ.SCHEDULE.RECORD:
*====================
** Read the future schedule record to be expanded later
*
    SCHED.REC = ""
    CALL F.READ("F.LMM.SCHEDULES", SCH.ID, SCHED.REC, F.LMM.SCHEDULES, "")
*
RETURN
*
*------------------------------------------------------------------------
*
PROCESS.SCH.PAST:
*----------------
** Check the schedule type for past schedules, see if details are required.
** Extract the amounts and store as appropriate
*
    GOSUB INIT.AMT.VARS       ;* Clear variables
    OD.PROCESS = "" ;* Set if storing OD info

    SCH.DATE = SCH.DATE       ;* GB9701367

    GOSUB READ.SCH.PAST
    GOSUB GET.PAY.DATES:
*
    NEXT.LEVEL = "LMM.SCHEDULES.PAST S ":SCH.PAST.ID
*

    STORE.FEE.AMT = ''
    STORE.CHG.AMT = ''
    IF SCHEDULES.PAST.REC<LD28.FEE.DUE.AMOUNT> THEN
        IF SCH.DATE.DIETER LT ACCBAL.REC<LD27.START.PERIOD.INT> THEN  ;* CI_10006732 S
            VMC = DCOUNT(SCHEDULES.PAST.REC<LD28.FEE.DUE.AMOUNT>,@VM)  ;* Number of fees
            FEE.DUE.AMOUNT.ARR = SCHEDULES.PAST.REC<LD28.FEE.DUE.AMOUNT>
            LOOP
                REMOVE FEE.DUE.AMOUNT FROM FEE.DUE.AMOUNT.ARR SETTING FEE.DUE.AMOUNT.POS
            WHILE FEE.DUE.AMOUNT        ;* Split out pay and receive
                IF FEE.DUE.AMOUNT GT 0 THEN
                    FEE.AMT -= FEE.DUE.AMOUNT
                END ELSE
                    CHG.AMT -= FEE.DUE.AMOUNT
                END
            REPEAT
*
** Add the drawdown fees to the contract
*
            IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
                FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)   ;* Add total fees
            END
*
            SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
            STORE.FEE.AMT = FEE.AMT ;* Store this
            GOSUB ADD.TO.REC.DETAILS
            SCH.TYPE = "CHG" ; SCH.AMT = CHG.AMT
            STORE.CHG.AMT = CHG.AMT
*
            GOSUB ADD.TO.REC.DETAILS
        END         ;* CI_10006732 E
*
        ALREADY.PROCESSED = 1 ;* CI_10009205
    END ELSE
*
** Add the drawdown fees to the contract
*
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
            FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)       ;* Add total fees
*
            IF FEE.AMT THEN
                SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
                STORE.FEE.AMT = FEE.AMT
                GOSUB ADD.TO.REC.DETAILS
            END
*
        END
*
        ALREADY.PROCESSED = 1 ;* CI_10009205
    END
*
    IF DISCOUNTED.COMM THEN   ;* Add the discounted interest if not there ; * CI_10023053 S/E
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> AND SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> = "" THEN
            IF LOAN.OR.DEPOSIT = "LOAN" THEN
                SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> = -ACCBAL.REC<LD27.COM.REC.IN.ADV>
            END
        END
    END
*
    IF SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> THEN

        COMM.AMOUNT = -SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT>
        SCH.TYPE = "COMM" ; SCH.AMT = COMM.AMOUNT
        GOSUB ADD.TO.REC.DETAILS
*
        IF SCHEDULES.PAST.REC<LD28.TAX.CODE.COMM> THEN      ;* Calcualte the tax
            TAX.BASE.AMT = ABS(COMM.AMOUNT)
            TAX.AMT = ABS(SCHEDULES.PAST.REC<LD28.TAX.CODE.COMM>)
            TAX.AMT.COM = TAX.AMT
            SCH.TYPE = "TAXC" ; SCH.AMT = TAX.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
        IF SCH.DATE.DIETER EQ PROCESS.DATE AND R.CONTRACT<LD.MATURE.AT.SOD> EQ "YES" THEN
            SCH.C.PROCESSED = 1         ;* falg to skip this schedule date processing in PROCESS.SCH.REST para
        END
    END
*
* CI_10000084 S
* Captalised charge amount must be taken from
* accbal for avoiding incorrect calculation when cap charge
* introduced through contracts
    IF SCHEDULES.PAST.REC<LD28.CAP.CHRG.REC> OR ACCBAL.REC<LD27.AMT.REC> THEN
        SCH.TYPE = "CAP"

        Y.CHRGS.DUE.DATE = ACCBAL.REC<LD27.CHRGS.DUE.DATE>
        Y.CHRGS.CNT = DCOUNT(Y.CHRGS.DUE.DATE,@VM)
        CHG.AMT = ''
        FEE.AMT = ''
        FOR I = 1 TO Y.CHRGS.CNT

            IF Y.CHRGS.DUE.DATE<1,I> EQ SCH.DATE.DIETER THEN
                IF ACCBAL.REC<LD27.CAP.CHRG.IND><1,I> EQ 'YES' THEN
                    NEW.CAP.AMT += ACCBAL.REC<LD27.AMT.REC,I>
* CI_10000877 - S
                END ELSE

                    CHARGE.CODE = ACCBAL.REC<LD27.CHRG.CODE,I> ;* Get the charge code from ACCBAL
                    CHRG.REC = ''
                    IF CHARGE.CODE THEN
                        CALL CACHE.READ('F.LMM.CHARGE.CONDITIONS', CHARGE.CODE, CHRG.REC,  IO.ERR) ;* Read the LMM.CHARGE.CONDITIONS to get PAY.RECEIVE value
                        IF CHRG.REC<LD21.PAY.RECEIVE> NE "PAY" THEN ;* Add the amount with their respective types.
                            CHG.AMT += ACCBAL.REC<LD27.AMT.REC,I>
                        END ELSE
                            FEE.AMT + = ACCBAL.REC<LD27.AMT.REC,I>
                        END
                    END

                END
* CI_10000877 - E
            END

        NEXT I
* CI_10000877 - S
        IF NEW.CAP.AMT THEN
            SCH.TYPE = "CAP"
* CI_10000877 - E
            SCH.AMT = NEW.CAP.AMT * -1  ;*CI_10030457 -S/E
            CAP.CHG.AMT = SCH.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
        IF CHG.AMT AND STORE.CHG.AMT NE CHG.AMT THEN ;* Don't process charge amount if both are same value
            SCH.TYPE = "CHG"
            SCH.AMT = CHG.AMT
            CHG.AMT = CHG.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
        IF FEE.AMT AND STORE.FEE.AMT NE FEE.AMT THEN ;* Don't process Fee amount if both are same value.
            SCH.TYPE = "FEE"
            SCH.AMT = FEE.AMT
            FEE.AMT = FEE.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
    END
*
    IF DISCOUNTED.INT THEN    ;* Add the discounted interest if not there ; * CI_10023053 S/E
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> AND SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> = "" THEN
            IF LOAN.OR.DEPOSIT = "DEPOSIT" THEN
                SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> = -ACCBAL.REC<LD27.INT.PAID.IN.ADV>
            END ELSE
                SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> = -ACCBAL.REC<LD27.INT.REC.IN.ADV>
            END
        END
    END
*
    CAP.INT.YES = ''          ;*CI_10030457 -S/E

    IF SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> THEN
*
        SCH.TYPE = "INT" ; SCH.AMT = -SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT>
        INTEREST.AMT = SCH.AMT
        GOSUB ADD.TO.REC.DETAILS
*
        IF SCHEDULES.PAST.REC<LD28.TAX.CODE.INT> THEN       ;* Calcualte the tax
            TAX.BASE.AMT = ABS(INTEREST.AMT)
            TAX.AMT = ABS(SCHEDULES.PAST.REC<LD28.TAX.CODE.INT>)
            TAX.AMT.INT = TAX.AMT
            SCH.TYPE = "TAXI" ; SCH.AMT = TAX.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
***!         IF R.CONTRACT<LD.CAPITALISATION> = "YES" AND SCH.DATE.DIETER NE R.CONTRACT<LD.FIN.MAT.DATE> THEN
***!            LAST.BALANCE += SCH.AMT
***!            RUNNING.BAL += SCH.AMT
***!         END
        IF SCH.DATE.DIETER EQ PROCESS.DATE AND R.CONTRACT<LD.MATURE.AT.SOD> EQ "YES" THEN
            SCH.I.PROCESSED = 1         ;* falg to skip this schedule date processing in PROCESS.SCH.REST para
        END
*
    END
*
    IF SCHEDULES.PAST.REC<LD28.CAP.INT> OR R.CONTRACT<LD.CAPITALISATION> EQ 'YES' THEN
        CAP.INT.YES = 'Y'
    END
** There is not always a drawdown schedule, so we need to add
** the initial amount
** There will not always be schedule past record for increase and back valued
** decreases, so the increase amount for the effective date should be added too
*

    UPDATE.REQD = ""
    PROCESS.P.SCHED = ""      ;* If set the details will be stored
    SCHEDULES.PAST.REC<LD28.PRINCIPAL.DUE.AMT> = ''         ;* Recalculate based on past movements
    IF CURR.PRIN.DATE AND CURR.PRIN.DATE EQ SCH.DATE.DIETER THEN
        GOSUB BUILD.PRIN.DETAILS
        UPDATE.REQD = 1
        DO.PROCESS = 0
    END
    IF NOT(DO.PROCESS) THEN
        LOOP
            REMOVE CURR.DETAILS FROM CURR.DETAILS.ARR SETTING C.POS
        WHILE CURR.DETAILS
            CURR.PRIN.DATE = CURR.DETAILS['*',1,1]
            CURR.PRIN.AMT = CURR.DETAILS['*',2,1]
            DO.PROCESS = 1
            IF CURR.PRIN.DATE AND CURR.PRIN.DATE EQ SCH.DATE.DIETER THEN
                GOSUB BUILD.PRIN.DETAILS
                UPDATE.REQD = 1
                DO.PROCESS = 0
            END ELSE
                EXIT
            END

        REPEAT
    END
    IF UPDATE.REQD THEN
        GOSUB BUILD.PRIN.DATA
    END
    IF NOT(PROCESS.P.SCHED) THEN        ;* Alreadxy done with the principal
        GOSUB INCLUDE.SCHEDULE
        IF INCLUDE.SCHED.DETS THEN
            SPECIAL.PROCESS = 1         ;*CI_10030457 -S If No P Sched, then
            PR.CNT = DO.COUNT ;*CI_10030457 -E process other schedules
            GOSUB STORE.SCHED.DETS
        END
    END
*
** Add PD details as a second line
*
    IF INCLUDE.PD MATCHES "Y":@VM:"M" THEN
*
        OD.PROCESS = 1
        GOSUB INIT.AMT.VARS   ;* Reset details
        NEXT.LEVEL = "PD.PAYMENT.DUE S ":PD.ID
*
** Add the Penalty interest and spread now
*
        PD.TYPE = "PE"
        GOSUB GET.OD.AMT
        INTEREST.AMT = SCH.AMT
        PD.TYPE = "PS"
        GOSUB GET.OD.AMT
        INTEREST.AMT += SCH.AMT
        IF SCH.AMT THEN
            SCH.TYPE = "INT"
            GOSUB ADD.TO.REC.DETAILS
        END
*
        GOSUB INCLUDE.SCHEDULE
        IF INCLUDE.SCHED.DETS THEN
            DIARY.DETS = "PENALTIES" ; CALL TXT(DIARY.DETS)
            GOSUB STORE.SCHED.DETS
        END
*
** Now add the remaining PD types
*
        GOSUB INIT.AMT.VARS
*
        PD.TYPE = "CH"
        GOSUB GET.OD.AMT
        IF SCH.AMT THEN
            CHG.AMT = SCH.AMT ; SCH.TYPE = "CHG"
            GOSUB ADD.TO.REC.DETAILS
        END
*
        PD.TYPE = "CO"
        GOSUB GET.OD.AMT
        IF SCH.AMT THEN
            COMM.AMOUNT = SCH.AMT ; SCH.TYPE = "COMM"
            GOSUB ADD.TO.REC.DETAILS
        END
*
        PD.TYPE = "IN"
        GOSUB GET.OD.AMT
        IF SCH.AMT THEN
            INTEREST.AMT = SCH.AMT ; SCH.TYPE = "INT"
            GOSUB ADD.TO.REC.DETAILS
        END
*
        PD.TYPE = "PR"
        GOSUB GET.OD.AMT
        IF SCH.AMT THEN
            RUNNING.BAL += SCH.AMT
            PRINC.AMT = SCH.AMT ; SCH.TYPE = "PRINC"
            GOSUB ADD.TO.REC.DETAILS
        END
*
        GOSUB INCLUDE.SCHEDULE
        IF INCLUDE.SCHED.DETS THEN
            DIARY.DETS = "OVERDUE AMOUNTS" ; CALL TXT(DIARY.DETS)
            GOSUB STORE.SCHED.DETS
        END
*
    END
*
** Set the contract to current if the value date has been processed
*
    IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
        CONTRACT.STATUS = 'CUR'
    END
*

PROCESS.SCH.PAST.EXIT:
*---------------------
RETURN
************************************************************************
*
GET.PAY.DATES:
*=============
*
    LAST.COMM.DATE = ""
    LAST.INT.DATE = ""
    LAST.PRINC.DATE = ""
    LAST.FEE.DATE = ""
    IF SCHEDULES.PAST.REC<LD28.DATE.COMM.REC> THEN
        MV.NO = DCOUNT(SCHEDULES.PAST.REC<LD28.DATE.COMM.REC>,@VM)
        LAST.COMM.DATE = SCHEDULES.PAST.REC<LD28.DATE.COMM.REC,MV.NO>
    END
    IF SCHEDULES.PAST.REC<LD28.DATE.INT.REC> THEN
        MV.NO = DCOUNT(SCHEDULES.PAST.REC<LD28.DATE.INT.REC>,@VM)
        LAST.INT.DATE = SCHEDULES.PAST.REC<LD28.DATE.INT.REC,MV.NO>
    END
    IF SCHEDULES.PAST.REC<LD28.DATE.REC> THEN
        MV.NO = DCOUNT(SCHEDULES.PAST.REC<LD28.DATE.REC>,@VM)
        LAST.PRINC.DATE = SCHEDULES.PAST.REC<LD28.DATE.REC,MV.NO>
    END
    IF SCHEDULES.PAST.REC<LD28.DATE.LAST.REC> THEN
        MV.NO = COUNT(SCHEDULES.PAST.REC<LD28.DATE.LAST.REC>,@VM)
        LAST.FEE.DATE = SCHEDULES.PAST.REC<LD28.DATE.LAST.REC,MV.NO>
    END
*
GET.PAY.DATES.EXIT:
RETURN
*
***********************************************************************
ADD.PRINC.SCHED.PAST:
*------------------
* This is a separate subroutine so that it can be called for each
* principal movement in the Accbal record. Some will appear in the
* schedules past record, others will not.
*
    SPECIAL.PROCESS = 0       ;* EN_10002384-S
    DO.COUNT = DCOUNT(SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT>,@VM)
    IF NOT(DO.COUNT) THEN
        DO.COUNT = 1
    END
    PR.CNT = 1
    LOOP
    WHILE PR.CNT <= DO.COUNT
*=========================================================================
* Take schedule amount from PRIN.AMT.SPLIT so that individual repayment
* may be shown on seperate lines. For contracts input before installing this
* enhancement, take the whole Principal due amount.
*===========================================================================
        SCH.TYPE = "PRINC" ; SCH.AMT = -SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT,PR.CNT>
        IF NOT(SCH.AMT) THEN
            SCH.AMT = -SCHEDULES.PAST.REC<LD28.PRINCIPAL.DUE.AMT>
* If 'N' and 'I' schedules alone processed in COB system considers the PRINC.AMT as Charge and I schedule.
* Hence system shows the principal outstanding as charge amount which is wrong. PRIN.AMT.SPLIT is updates
* as null for interest and charges and hence we have set the PRINC.AMT as 0 for charge and I schedule.
            PRINC.AMT = 0
        END ELSE
            PRINC.AMT = SCH.AMT
        END

        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN ;* Set the principal amt to be the Issue price
            BEGIN CASE
                CASE CONTRACT.STATUS NE 'FWD'         ;* Only use DD price at start
                CASE R.CONTRACT<LD.DRAWDOWN.ISSUE.PRC> = ''
                    EVENT.DATE = R.CONTRACT<LD.DRAWDOWN.ENT.DATE>
                    CONTRACT.STATUS = 'CUR'
                CASE 1
* CI_10029238
* For  outstanding principal calculation, loss should be subtracted from principal amount.
                    SIGN = 1      ;* CI_10039496 S
                    IF LD.TYPE EQ 'DEPOSIT' THEN      ;* If deposit change the sign
                        SIGN = -1
                    END
                    PRINC.AMT -= R.CONTRACT<LD.ISSUE.PL.AMOUNT> * SIGN    ;* CI_10039496 E
                    EVENT.DATE = R.CONTRACT<LD.DRAWDOWN.ENT.DATE>
                    CONTRACT.STATUS = 'CUR'
            END CASE
        END
*
* REIMBURSE.AMOUNT should be taken only for maturity repayment event and not for other events on the same date.
        IF SCH.DATE.DIETER = R.CONTRACT<LD.FIN.MAT.DATE> AND ACCBAL.REC<LD27.OUTS.CURR.PRINC,VDPOS> EQ 0 AND PR.CNT EQ DO.COUNT THEN ;* On maturity date use the reimbursement price ; * CI_10034444 S/E
            EVENT.DATE = R.CONTRACT<LD.FIN.MAT.DATE>
            CONTRACT.STATUS = 'MAT'
            BEGIN CASE
                CASE R.CONTRACT<LD.REIMBURSE.AMOUNT> = ''
                CASE LOAN.OR.DEPOSIT = 'LOAN'
                    PRINC.AMT +=  R.CONTRACT<LD.REIMBURSE.PL.AMT>
                CASE 1
                    PRINC.AMT +=  R.CONTRACT<LD.REIMBURSE.PL.AMT>
            END CASE
        END
*
        GOSUB CHECK.CANCELLED.INT
*
        GOSUB ADD.TO.REC.DETAILS

        LAST.BALANCE += SCH.AMT
        RUNNING.BAL += SCH.AMT

        IF PR.CNT EQ DO.COUNT THEN      ;*CI_10030457 -S Add Cap with running balance
            IF (SCHEDULES.PAST.REC<LD28.CAP.INT> OR R.CONTRACT<LD.CAPITALISATION> EQ 'YES') AND SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT,PR.CNT> THEN
                LAST.BALANCE += SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> -TAX.AMT.INT    ;*CI_10032538 -S
                RUNNING.BAL += SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT>-TAX.AMT.INT      ;*CI_10032538 -E
            END
* When START.DATE is given at Enquiry level, system not takes the cap amount. Hence removed NOT(START.DATE) condition
* When N schedule alone given, AMT.SPLIT wont be updated. In this case, we have already added CAP amount to running balance
            IF NEW.CAP.AMT AND SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT,PR.CNT> THEN
                LAST.BALANCE -= NEW.CAP.AMT
                RUNNING.BAL -= NEW.CAP.AMT
            END

        END         ;*CI_10030457 -E

*
        SPECIAL.PROCESS = 1
        GOSUB INCLUDE.SCHEDULE
        IF INCLUDE.SCHED.DETS THEN
            GOSUB STORE.SCHED.DETS
        END
*
        PR.CNT += 1
    REPEAT
*
    SPECIAL.PROCESS = 0 ; PREV.LINE = 0 ;* EN_10002384-E
RETURN
*
************************************************************************
CHECK.CANCELLED.INT:
*==================
** Check the CANCELLED INTEREST fields and extract the amount of cancelled
** interst plus the event date
*
    LOCATE VDPOS IN ACCBAL.REC<LD27.CANCEL.MV.NO,1> SETTING CAN.POS THEN
        EVENT.DATE = ACCBAL.REC<LD27.CANCEL.DATE, CAN.POS>
        IF LOAN.OR.DEPOSIT = "DEPOSIT" THEN
            INTEREST.AMT -= SUM(ACCBAL.REC<LD27.CANCEL.INT, CAN.POS>)
        END ELSE
            INTEREST.AMT += SUM(ACCBAL.REC<LD27.CANCEL.INT, CAN.POS>)
        END
    END
*
RETURN
*
************************************************************************
*
PROCESS.SCH.REST:
*----------------
** Take the now complete details from the future schedule records and
** update as required
*
    IF SCH.DATE.DIETER EQ PROCESS.DATE AND R.CONTRACT<LD.MATURE.AT.SOD> EQ "YES" THEN
* If schedule information has built from past record, then skip the process here.
* Else it may double the schedule amount
        IF SCH.I.PROCESSED THEN
            SKIP.I.SCH = 1
        END
        IF SCH.C.PROCESSED THEN
            SKIP.C.SCH = 1
        END
    END

    OD.PROCESS = ""
    GOSUB INIT.AMT.VARS

    SCH.DATE = SCH.DATE       ;* GB9701367
    SCHEDULES.REC = RAISE(EXPANDED.DETAILS<FUTURE.IDX>)     ;* Extract the expanded record
* For Annuity Repayment, include the principal portion
    NO.OF.SCHEDS = DCOUNT(SCHEDULES.REC<LD9.SCHED.TYPE>,@VM) ;*CI_10030457 -S
    LOCATE 'A' IN SCHEDULES.REC<LD9.SCHED.TYPE,1> SETTING POSA THEN
        P.SCHED.AMT = SCHEDULES.REC<LD9.PRIN.AMOUNT.DUE> - SUM(SCHEDULES.REC<LD9.PRIN.AMT.SPLIT>)   ;* Show Principal part of repayment in a separate line.
        LOCATE 'P' IN SCHEDULES.REC<LD9.SCHED.TYPE,1> SETTING POSP THEN
            NO.OF.SPLIT = DCOUNT(SCHEDULES.REC<LD9.PRIN.AMT.SPLIT>,@VM)
            SCHEDULES.REC<LD9.PRIN.AMT.SPLIT,NO.OF.SPLIT> += P.SCHED.AMT
        END
        LOCATE 'B' IN SCHEDULES.REC<LD9.SCHED.TYPE,1> SETTING POSB THEN
            NO.OF.SPLIT = DCOUNT(SCHEDULES.REC<LD9.PRIN.AMT.SPLIT>,@VM)
            SCHEDULES.REC<LD9.PRIN.AMT.SPLIT,NO.OF.SPLIT> += P.SCHED.AMT
        END
    END   ;*CI_10030457 -E
*
    SCHEDULE.DATE = CONTRACT.NO:SCH.DATE:"00"
    IF (R.CONTRACT<LD.CAPITALISATION> = "YES" OR SCHEDULES.REC<LD9.CAP.INT> = 'Y') THEN
        CAP.INT.YES = 'Y'
    END
*
    IF R.CONTRACT<LD.RECORD.STATUS>[2,2] = "NA" THEN
        NEXT.LEVEL = "LD.LOANS.AND.DEPOSITS S ":CONTRACT.NO
    END ELSE
        NEXT.LEVEL = "LMM.SCHEDULES S ":SCHEDULE.DATE
    END
*
** Schedule Info For Revision
*
    IF SCHEDULES.REC<LD9.TYPE.R> EQ 'Y' THEN
        SCH.TYPE = "REVSN"
        INTEREST.RATE = SCHEDULES.REC<LD9.INT.EFFECT.RATE> ; SCH.AMT = INTEREST.RATE
        GOSUB ADD.TO.REC.DETAILS
    END
*
    IF SCHEDULES.REC<LD9.TYPE.F> EQ 'Y' THEN
        VMC = DCOUNT(SCHEDULES.REC<LD9.FEE.AMOUNT.DUE>,@VM)  ;* Number of fees
        FOR YIND = 1 TO VMC   ;* Split out pay and receive
            IF SCHEDULES.REC<LD9.FEE.CALC.TYPE,YIND> EQ "PAY" THEN
* GB9701473
* GB9800876
                FEE.AMT += ABS(SCHEDULES.REC<LD9.FEE.AMOUNT.DUE,YIND>) * -1
            END ELSE
                CHG.AMT += SCHEDULES.REC<LD9.FEE.AMOUNT.DUE,YIND>     ;* CI_10000084 S/E
            END
        NEXT YIND
*
** Add the drawdown fees to the contract
*
        IF NOT(ALREADY.PROCESSED) THEN  ;* CI_10009205
            IF SCH.DATE.DIETER GE PROCESS.DATE THEN
                IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
                    FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)         ;* Add total fees
                END
            END
        END         ;* CI_10009205
*
        SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
        GOSUB ADD.TO.REC.DETAILS
        SCH.TYPE = "CHG" ; SCH.AMT = CHG.AMT
        GOSUB ADD.TO.REC.DETAILS
*
    END ELSE
*
** Add the drawdown fees to the contract
*
        IF NOT(ALREADY.PROCESSED) THEN  ;* CI_10009205
            IF SCH.DATE.DIETER GE PROCESS.DATE THEN         ;* Fees will already be processed as Past items
                IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
                    FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)         ;* Add total fees
                    IF FEE.AMT THEN
                        SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
                        GOSUB ADD.TO.REC.DETAILS
                    END
                END
            END
*
        END         ;* CI_10009205
    END
*
    IF SCHEDULES.REC<LD9.TYPE.C> EQ 'Y' AND NOT(SKIP.C.SCH) THEN

        COMM.AMOUNT = SCHEDULES.REC<LD9.COMMISSION.AMT>

        SCH.TYPE = "COMM" ; SCH.AMT = COMM.AMOUNT
        GOSUB ADD.TO.REC.DETAILS
*
        IF R.CONTRACT<LD.TAX.COMMISSION.KEY> OR R.CONTRACT<LD.TAX.COMMISSN.TYPE> THEN     ;* GB9701369
            TAX.BASE.AMT = ABS(COMM.AMOUNT)
            IF R.CONTRACT<LD.TAX.COMMISSN.TYPE> THEN        ;* GB9701369
                TAX.CODE = R.CONTRACT<LD.TAX.COMMISSN.TYPE>
            END ELSE
                TAX.CODE = R.CONTRACT<LD.TAX.COMMISSION.KEY>
            END
            GOSUB CALC.TAX.AMT
            TAX.AMT.COM = TAX.AMT
            SCH.TYPE = "TAXC" ; SCH.AMT = TAX.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
    END
*
    IF SCHEDULES.REC<LD9.TYPE.I> AND NOT(SKIP.I.SCH) THEN
        SCH.TYPE = "INT"
        IF R.CONTRACT<LD.STATUS> EQ 'FWD' AND SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN      ;* CI_10045680 S If SCH.DATE EQ Value Date, take Int Amt from Tot.Interest.Amt
            SCH.AMT = -R.CONTRACT<LD.TOT.INTEREST.AMT>
        END ELSE
            SCH.AMT = SCHEDULES.REC<LD9.INTEREST.AMT>
        END         ;* CI_10045680 E
        IF LOAN.OR.DEPOSIT = 'DEPOSIT' AND R.CONTRACT<LD.INTEREST.BASIS> EQ 'S' THEN
            INTEREST.AMT = SCH.AMT
        END ELSE
            INTEREST.AMT = SCH.AMT * -1
        END
        GOSUB ADD.TO.REC.DETAILS
*
        IF R.CONTRACT<LD.TAX.INT.TYPE> OR R.CONTRACT<LD.TAX.INT.KEY> THEN       ;* GB9701369 * EN_10003755 S/E
            TAX.BASE.AMT = ABS(INTEREST.AMT)
            IF R.CONTRACT<LD.TAX.INT.TYPE> THEN   ;* GB9701369 * EN_10003755 S/E
                TAX.CODE = R.CONTRACT<LD.TAX.INT.TYPE>      ;* EN_10003755 S/E
            END ELSE
                TAX.CODE = R.CONTRACT<LD.TAX.INT.KEY>       ;* EN_10003755 S/E
            END
            GOSUB CALC.TAX.AMT
            TAX.AMT.INT = TAX.AMT
            SCH.TYPE = "TAXI" ; SCH.AMT = TAX.AMT
            GOSUB ADD.TO.REC.DETAILS
            IF (R.CONTRACT<LD.CAPITALISATION> = "YES" OR SCHEDULES.REC<LD9.CAP.INT> = 'Y') THEN     ;*CI_10030457 -S
*For Capitalised Interest, include Tax Amt to the Princ part.
                DO.COUNT = ''; FLG.UPD = ''
                DO.COUNT = DCOUNT(SCHEDULES.REC<LD9.PRIN.AMT.SPLIT>, @VM)
                IF NOT(DO.COUNT) THEN
                    DO.COUNT = 1
                END
            END     ;*CI_10030457 -E
        END
    END
**
    SPECIAL.PROCESS = 0 ; PREV.LINE = 0 ;* EN_10002384-S
    IF SCH.DATE.DIETER GE PROCESS.DATE OR R.CONTRACT<LD.ANNUITY.PAY.METHOD> = 'BEGIN' THEN          ;* Ignore back valued principal except 'BEGIN'
        IF SCHEDULES.REC<LD9.TYPE.P> THEN
            DO.COUNT = DCOUNT(SCHEDULES.REC<LD9.PRIN.AMT.SPLIT>, @VM)
            IF NOT(DO.COUNT) THEN
                DO.COUNT = 1
            END
            FOR PR.CNT = 1 TO DO.COUNT
                SCH.TYPE = "PRINC" ; SCH.AMT = SCHEDULES.REC<LD9.PRIN.AMT.SPLIT,PR.CNT>
                IF NOT(SCH.AMT) THEN
                    SCH.AMT = SCHEDULES.REC<LD9.PRIN.AMOUNT.DUE>
                END
                PRINC.AMT = SCH.AMT
                IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN   ;* Set the principal amt to be the Issue price
                    EVENT.DATE = R.CONTRACT<LD.DRAWDOWN.ENT.DATE>
                    BEGIN CASE
                        CASE R.CONTRACT<LD.ANNUITY.PAY.METHOD> = 'BEGIN'
* GB9800331
                            IF SCH.DATE.DIETER GE PROCESS.DATE AND R.CONTRACT<LD.STATUS> EQ 'FWD' THEN
*
* first add the drawdown amount
*
                                PROCESS.P.SCHED = 1
                                SAVE.SCH.AMT = SCH.AMT
                                CONTRACT.AMOUNT = R.CONTRACT<LD.DRAWDOWN.ISSUE.PRC>
                                IF LOAN.OR.DEPOSIT = 'LOAN' THEN
                                    CONTRACT.AMOUNT = -CONTRACT.AMOUNT
                                END
                                PRINC.AMT = CONTRACT.AMOUNT
                                SCH.AMT = PRINC.AMT
*
                                GOSUB ADD.TO.REC.DETAILS
                                LAST.BALANCE += SCH.AMT
                                RUNNING.BAL += SCH.AMT
                                GOSUB STORE.SCHED.DETS
                                GOSUB INIT.AMT.VARS
*
* now add in the first repayment
*
                                SCH.AMT = SAVE.SCH.AMT
                                PRINC.AMT = SCH.AMT
                            END
                        CASE R.CONTRACT<LD.DRAWDOWN.ISSUE.PRC> = ''
* GB9800331
                        CASE SCH.AMT = ''
                        CASE LOAN.OR.DEPOSIT = 'LOAN'
                            PRINC.AMT = -R.CONTRACT<LD.DRAWDOWN.ISSUE.PRC>
                        CASE 1
                            PRINC.AMT = R.CONTRACT<LD.DRAWDOWN.ISSUE.PRC>
                    END CASE
                END
*
                IF SCH.DATE.DIETER = R.CONTRACT<LD.FIN.MAT.DATE> THEN ;* On maturity date use the reimbursement price
                    EVENT.DATE = R.CONTRACT<LD.FIN.MAT.DATE>
                    BEGIN CASE
                        CASE R.CONTRACT<LD.REIMBURSE.PRICE> = ''
                        CASE 1    ;* Recalulate using the REIMB price
                            PRINC.AMT = OCONV(ICONV((SCH.AMT * R.CONTRACT<LD.REIMBURSE.PRICE> / 100),'MD':CCY.DEC),'MD':CCY.DEC)
                    END CASE
                END
* CI_10000498 S/E
* ABS function used only for loans
* Before assigning RUNNING.BAL to PRINC.AMT, need to check DO.COUNT & PR.CNT both are equal for avoid the two or more "P" schedules
* falls on maturity date LD.BALANCES.FULL enquiry projection was wrong.
                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR SCHED.CAP) AND SCH.DATE.DIETER EQ R.CONTRACT<LD.FIN.MAT.DATE> AND LOAN.OR.DEPOSIT NE "DEPOSIT" AND (DO.COUNT EQ PR.CNT) THEN    ;* GB0000515 S ; * EN_10002387 S/E
                    PRINC.AMT = ABS(RUNNING.BAL)
                END ;* GB0000515 E
                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR SCHED.CAP) AND SCH.DATE.DIETER EQ R.CONTRACT<LD.FIN.MAT.DATE> AND LOAN.OR.DEPOSIT EQ "DEPOSIT" AND (DO.COUNT EQ PR.CNT) THEN    ;* CI_10002810 S ; * EN_10002387 S/E
                    PRINC.AMT = RUNNING.BAL * -1
                END ;* CI_10002810 E
                GOSUB ADD.TO.REC.DETAILS
*
                LAST.BALANCE += SCH.AMT
                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR SCHED.CAP) AND SCH.DATE.DIETER EQ R.CONTRACT<LD.FIN.MAT.DATE> THEN  ;* GB0000515 S ; * EN_10002387 S/E
                    RUNNING.BAL += PRINC.AMT
                END ELSE
                    RUNNING.BAL += SCH.AMT
                END ;* GB0000515 E
                IF PR.CNT = DO.COUNT ELSE
                    SPECIAL.PROCESS = 1
                    GOSUB INCLUDE.SCHEDULE        ;* NEW CHANGES S
                    IF INCLUDE.SCHED.DETS THEN
                        GOSUB STORE.SCHED.DETS
                    END
                END
            NEXT PR.CNT       ;* EN_10002384-E
        END
    END
**
*
    IF SCHEDULES.REC<LD9.TYPE.I> THEN   ;*CI_10030457 -S
        IF (R.CONTRACT<LD.CAPITALISATION> = "YES" OR SCHEDULES.REC<LD9.CAP.INT> = 'Y')  AND SCH.DATE.DIETER NE R.CONTRACT<LD.FIN.MAT.DATE> THEN
            RUNNING.BAL -= INTEREST.AMT+TAX.AMT.INT         ;*CI_10032538-S/E
            IF NOT(SCHED.CAP) THEN
                SCHED.CAP = "1"
            END     ;* EN_10002387 S/E
        END
    END   ;*CI_10030457 -E
*
    IF SCHEDULES.REC<LD9.TYPE.N> EQ 'Y' THEN
        SCH.TYPE = "CAP" ; SCH.AMT = SUM(SCHEDULES.REC<LD9.CHRG.AMOUNT.DUE>)
*  CI_10000084 S
*  Change the sign of Capitalised charge amount
        IF SCHEDULES.REC<LD9.FEE.CALC.TYPE,YIND> EQ "PAY" THEN
            CAP.CHG.AMT = SCH.AMT * -1
            RUNNING.BAL += CAP.CHG.AMT
        END ELSE
            CAP.CHG.AMT = SCH.AMT
            RUNNING.BAL += CAP.CHG.AMT * -1
        END
        GOSUB ADD.TO.REC.DETAILS
*  RUNNING.BAL += CAP.CHG.AMT      ;*Update running balance as it's already processed and ready for display
* CI_10000084 E
        IF NOT(SCHED.CAP) THEN          ;* BG_100016136 S
            SCHED.CAP = "1"
        END         ;* BG_100016136 E
    END
*
    IF SCHEDULES.REC<LD9.TYPE.D> EQ "Y" THEN
        
        DIARY.DETS = SCHEDULES.REC<LD9.DIARY.ACTION> ;* May be multiple lines
        DIARY.DETS = CHANGE(DIARY.DETS,@VM,'-')
        SCH.AMT = DIARY.DETS ; SCH.TYPE = "DIAR"
        GOSUB ADD.TO.REC.DETAILS
*
    END
*
    GOSUB INCLUDE.SCHEDULE
    IF INCLUDE.SCHED.DETS THEN
        GOSUB STORE.SCHED.DETS
    END
*
    SPECIAL.PROCESS = 0 ; PREV.LINE = 0 ;* EN_10002384
    SCH.I.PROCESSED = ''
    SCH.C.PROCESSED = ''
    SKIP.I.SCH = ''
    SKIP.C.SCH =''
** Set the contract to current if the value date has been processed
*
    IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
        CONTRACT.STATUS = 'CUR'
    END
*
PROCESS.SCH.REST.EXIT:
*
RETURN
************************************************************************
*
FINAL.PROCESS:
*-------------
** Handoff details requried to the enquiry plus the rates
*
    VM.COUNT = DCOUNT(R.RECORD<LD.SL.EVENT.DATE>,@VM)        ;* The number of lines in the multi values to be handed back
*
    INT.TYPE = R.CONTRACT<LD.INT.RATE.TYPE>
    INT.RATE = R.CONTRACT<LD.INTEREST.RATE>
    INT.KEY = R.CONTRACT<LD.INTEREST.KEY>
    INT.SPREAD = R.CONTRACT<LD.INTEREST.SPREAD>
*
    R.RECORD<LD.SL.CUSTOMER.NO> = R.CONTRACT<LD.CUSTOMER.ID>
    R.RECORD<LD.SL.CURRENCY> = R.CONTRACT<LD.CURRENCY>
*
    IF LD.TYPE NE "COMMITMENT" AND LD.TYPE NE "LIAB.COMMITMENT" THEN
        IF V$SEQ EQ '00' THEN
            R.RECORD<LD.SL.CURRENT.AMOUNT> = R.CONTRACT<LD.AMOUNT>
            R.RECORD<LD.SL.OPENING.BAL> = OPEN.BAL          ;* Opening balance
            R.RECORD<LD.SL.CLOSING.BAL> = RUNNING.BAL       ;* Closing balance
            IF SCH.DATE.DIETER THEN     ;* Final date
                R.RECORD<LD.SL.ENQ.END.DATE> = R.CONTRACT<LD.FIN.MAT.DATE>      ;*CI_10002587-S/E
            END ELSE
                SCH.DATE.DIETER = R.CONTRACT<LD.FIN.MAT.DATE>
            END
        END
*
    END ELSE
*
        CONTRACT.AMOUNT = R.CONTRACT<LD.AMOUNT>
        NO.OF.AMOUNTS = COUNT(CONTRACT.AMOUNT,@VM) + 1
        HIGHEST.AMOUNT = CONTRACT.AMOUNT<1,1>
        FOR I = 2 TO NO.OF.AMOUNTS
            IF CONTRACT.AMOUNT<1,I> GT HIGHEST.AMOUNT THEN
                HIGHEST.AMOUNT = CONTRACT.AMOUNT<1,I>
            END
        NEXT
        R.RECORD<LD.SL.CURRENT.AMOUNT> = HIGHEST.AMOUNT
*
    END
*
    R.RECORD<LD.SL.CATEGORY> = R.CONTRACT<LD.CATEGORY>
    R.RECORD<LD.SL.LD.STATUS> = R.CONTRACT<LD.STATUS>
    R.RECORD<LD.SL.LD.STATUS,2> = R.CONTRACT<LD.OVERDUE.STATUS>

    IF INT.TYPE EQ 3 THEN
        INT.RTE = ''
        IO.ERR = ''
        CALL LD.GET.INTEREST(R.CONTRACT<LD.INTEREST.KEY>,R.CONTRACT<LD.CURRENCY>, '', INT.RTE, IO.ERR)
        INT.RATE = INT.RTE<1> ;* CI_10052996 To display the Interest rate in the enquiry LD.BALANCES.FULL and LD.BALANCES.SUM
    END
    IF INT.SPREAD AND NOT(R.CONTRACT<LD.RFR.CALC.METHOD> MATCHES 'COMPOUND':@VM:'SIMPLE')  THEN
        INT.RATE = INT.RATE:' + ':INT.SPREAD ;* Don't add spread with interest rate for RFR compounding method.
    END
    R.RECORD<LD.SL.CURRENT.RATE> = INT.RATE

    IF START.DATE THEN        ;* Use supplied date
        R.RECORD<LD.SL.ENQ.START.DATE> = START.DATE
    END ELSE
        R.RECORD<LD.SL.ENQ.START.DATE> = R.CONTRACT<LD.VALUE.DATE>
    END
    R.RECORD<LD.SL.MAT.DATE> = R.CONTRACT<LD.FIN.MAT.DATE>
    LAST.MV = COUNT(ACCBAL.REC<LD27.DATE.FROM>,@VM) + 1
    R.RECORD<LD.SL.CURRENT.BAL> = ACCBAL.REC<LD27.OUTS.CURR.PRINC,LAST.MV> + ACCBAL.REC<LD27.OUTS.OD.PRINC,LAST.MV>
    R.RECORD<LD.SL.CURRENT.BAL> = R.RECORD<14> + ACCBAL.REC<LD27.OUTS.PRINC.NAB,LAST.MV>
*
    IF LOAN.OR.DEPOSIT = "LOAN" THEN
        R.RECORD<LD.SL.CURRENT.BAL> = -R.RECORD<14>
    END ELSE
        R.RECORD<LD.SL.CURRENT.BAL> = ABS(R.RECORD<14>)
    END
    IF R.RECORD<LD.SL.DIARY.DETS> EQ "" THEN      ;* CI_10046484 S ;* To show some sort of msg, when there is no Diary schedules
        R.RECORD<LD.SL.DIARY.DETS> = "NO DIARY DETAILS TO DISPLAY"
    END   ;* CI_10046484 E
*
FINAL.PROCESS.EXIT:
*------------------
RETURN
*************************************************************************
*
READ.SCH.PAST:
*-------------

    SCH.PAST.ID = ID[1,12]:SCH.DATE:ID[13,2]
    SCHEDULES.PAST.REC = ''
    READ SCHEDULES.PAST.REC FROM FV.LMM.SCHEDULES.PAST, SCH.PAST.ID ELSE
        NULL
    END
*

READ.SCH.PAST.EXIT:
*------------------
RETURN
*************************************************************************
*
READ.SCHEDULE.DATES:
*-----------------
** Read LMM.SCHEDULE.DATES to get the past events
*
    CALL LD.ENQ.INT.I   ;* Intialisation routine should be called each time the enquiry routine processes the request
    READ SCHED.DATES FROM FV.LMM.SCHEDULE.DATES, ID ELSE
        SCHED.DATES = ""
    END
*
RETURN
*************************************************************************
READ.CONTRACT.ARRAY:
*------------------
*
    CONTRACT.NO = ID[1,12]
*
** Read the unauthorised record online to get the latest version
*
    R.CONTRACT = ''
    IF NOT(EOD) THEN
        READ R.CONTRACT FROM FV.LD.LOANS.AND.DEPOSITS$NAU, CONTRACT.NO ELSE
            NULL
        END
    END
    IF R.CONTRACT<LD.RECORD.STATUS>[2,2] NE "NA" THEN
        READ R.CONTRACT FROM FV.LD.LOANS.AND.DEPOSITS, ID[1,12] ELSE
            NULL
        END
    END
*
** Get the number of contract details
*
    CCY.DEC = ''    ;* BG_100007279 S
    CCY.REC = ''
    IO.ERR = ''
    CALL CACHE.READ('F.CURRENCY', R.CONTRACT<LD.CURRENCY>, CCY.REC, IO.ERR)
    CCY.DEC = CCY.REC<EB.CUR.NO.OF.DECIMALS>      ;* BG_100007279 E
*
READ.CONTRACT.ARRAY.EXIT:
*------------------------
RETURN
*
*************************************************************************
INIT.AMT.VARS:
*=============
** Details of amount for each schedule processed
*
    PRINC.AMT = 0   ;* Principal
    PRINC.AMT.CR = 0          ;* Principal Credit
    PRINC.AMT.DR = 0          ;* Principal Debit
    INTEREST.AMT = 0          ;* Interest
    COMM.AMOUNT = 0 ;* Commission
    CAP.CHG.AMT = 0 ;* Capitalised Charges
    FEE.AMT = 0     ;* Payable charges
    CHG.AMT = 0     ;* Receivable charges
    DIARY.DETS = "" ;* Diary Details
    TAX.AMT.PRIN = 0          ;* Principal Tax
    TAX.AMT.INT = 0 ;* Interest Tax
    TAX.AMT.COM = 0 ;* Commission Tax
    INTEREST.RATE = ""        ;* Rate revision
    EVENT.DATE = "" ;* Date of the actual event

    NEW.CAP.AMT = 0

*
RETURN
*
*---------------------------------------------------------------------
ADD.TO.REC.DETAILS:
*==================
** Store the extracted details in R.RECORD by type
*
    IF SCH.AMT THEN
        LOCATE SCH.DATE.DIETER IN R.RECORD<LD.SL.SCH.DATE.TYPE,1> BY "AR" SETTING SCH.POS ELSE
            NULL
        END
        INS SCH.DATE.DIETER BEFORE R.RECORD<LD.SL.SCH.DATE.TYPE,SCH.POS>
        INS SCH.TYPE BEFORE R.RECORD<LD.SL.SCH.TYPE,SCH.POS>
        INS SCH.AMT BEFORE R.RECORD<LD.SL.SCH.AMT,SCH.POS>
    END
*
RETURN
*
*------------------------------------------------------------------------------
INCLUDE.SCHEDULE:
*================
** Decide whether or not to include the schedule accoriding to the types
** requested
*
    INCLUDE.SCHED.DETS = ""   ;* Set to 1 if required
    BEGIN CASE
        CASE SCHED.TYPES = "ALL"
            INCLUDE.SCHED.DETS = 1
        CASE PRINC.AMT AND INDEX(SCHED.TYPES,"P",1)
            INCLUDE.SCHED.DETS = 1
        CASE INTEREST.AMT AND INDEX(SCHED.TYPES,"I",1)
            INCLUDE.SCHED.DETS = 1
        CASE COMM.AMOUNT AND INDEX(SCHED.TYPES,"C",1)
            INCLUDE.SCHED.DETS = 1
        CASE FEE.AMT AND INDEX(SCHED.TYPES,"F",1)
            INCLUDE.SCHED.DETS = 1
        CASE CHG.AMT AND INDEX(SCHED.TYPES,"F",1)
            INCLUDE.SCHED.DETS = 1
        CASE CAP.CHG.AMT AND INDEX(SCHED.TYPES,"N",1)
            INCLUDE.SCHED.DETS = 1
        CASE CAP.CHG.AMT AND INDEX(SCHED.TYPES,"F",1)
            INCLUDE.SCHED.DETS = 1
        CASE DIARY.DETS AND INDEX(SCHED.TYPES,"D",1)
            INCLUDE.SCHED.DETS = 1
        CASE INTEREST.RATE AND INDEX(SCHED.TYPES,"R",1)
            INCLUDE.SCHED.DETS = 1
    END CASE
*
RETURN
*
*-------------------------------------------------------------------------------
STORE.SCHED.DETS:
*================
** Store details of scehdule amounts by date and type
*
    IF SCH.DATE.DIETER GE START.DATE THEN
*
** Get the adjusted date for accounting
*
        IF EVENT.DATE THEN
            SCHEDULED.DATE = EVENT.DATE
        END ELSE
            SCHEDULED.DATE = SCH.DATE.DIETER
        END
*
        IF PRINC.AMT GT 0 THEN
            PRINC.AMT.DR = PRINC.AMT
        END ELSE
            PRINC.AMT.CR = PRINC.AMT
        END
*
        ADJ.DATE = ''
        CALL EB.DETERMINE.PAYMENT.DATE(R.CONTRACT<LD.VD.PRIOR.ADJUST>, SCHEDULED.DATE, R.CONTRACT<LD.BUS.DAY.DEFN>, R.CONTRACT<LD.VD.DATE.ADJUSTMENT>, ADJ.DATE)
*
        DATE.CHK = SCH.DATE.DIETER:".":ADJ.DATE
        LOCATE DATE.CHK IN R.DATE.IND<1> BY "AR" SETTING K THEN
*
            NO.OF.DT = DCOUNT(R.DATE.IND,@FM)      ;*CI_10030457 -S
            FOR CNT.DT = K TO NO.OF.DT
                IF R.DATE.IND<CNT.DT> NE DATE.CHK THEN
                    K = CNT.DT - 1
                    CNT.DT = NO.OF.DT
                END ELSE      ;*If many schedule is on same date
                    K = CNT.DT          ;*then insert them by order
                END
            NEXT CNT.DT     ;*CI_10030457 -E
*
            IF SPECIAL.PROCESS THEN     ;* EN_10002384-S
* SPECIAL.PROCESS is set to insert new lines for each principal split.
                MERGE.INSERT = 'INSERT'
            END ELSE          ;* EN_10002384-E
                BEGIN CASE
                    CASE IND.PRIN = 'Y' AND PROCESS.P.SCHED
                        MERGE.INSERT = 'INSERT'
                    CASE NOT(OD.PROCESS)    ;* Add to existing values
                        MERGE.INSERT = "MERGE"
                    CASE INCLUDE.PD = "Y"
                        MERGE.INSERT = "INSERT"
                    CASE 1
                        MERGE.INSERT = "MERGE"        ;* Add PD info to existing line
                END CASE
            END
        END ELSE
            MERGE.INSERT = "INSERT"     ;* Insert new value
        END
*
* CI_10000084

* CI_10000877 - S
* Populate the CHG.AMT with correct values from LMM.ACCOUNT.BALANCES
*         Y.CHRGS.DUE.DATE = ACCBAL.REC<LD27.CHRGS.DUE.DATE>
*         Y.CHRGS.CNT = DCOUNT(Y.CHRGS.DUE.DATE,VM)
*         FOR I = 1 TO Y.CHRGS.CNT
*            IF Y.CHRGS.DUE.DATE<1,I> = SCH.DATE.DIETER THEN
*               IF ACCBAL.REC<LD27.CAP.CHRG.IND,I> = "NO" THEN
*                  CHG.AMT += ACCBAL.REC<LD27.AMT.REC,I>
*               END
*            END
*         NEXT I
* CI_10000084
* CI _I_10000877 - E
        IF MERGE.INSERT = "INSERT" THEN ;* Add new MV set

            IF R.RECORD<LD.SL.EVENT.DATE,K> = SCH.DATE.DIETER THEN
                K+=1
            END     ;* PD line add after
*=========================================================================
* The below line has been included to insert new lines for every PRIN.AMT.SPLIT
* The above line would always give the second position and the last line
* would be inserted in the second position. PREV.LINE is set inside the IF
* condition. Also if the line inserted is not the last line for a date,
* just insert 0 for all other positions. The original values for the due
* date would always appear on the last line of the date.
*==========================================================================
            IF PREV.LINE THEN
                K = PREV.LINE + 1
            END     ;* EN_10002384
            INS DATE.CHK BEFORE R.DATE.IND<K>
            INS SCH.DATE.DIETER BEFORE R.RECORD<LD.SL.EVENT.DATE,K>
            INS ADJ.DATE BEFORE R.RECORD<LD.SL.ADJ.DATE,K>
            INS PRINC.AMT BEFORE R.RECORD<LD.SL.PRIN.AMOUNT,K>
            IF SCH.TYPE="PRINC" AND DO.COUNT NE PR.CNT THEN ;* EN_10002384-S
                INS '0' BEFORE R.RECORD<LD.SL.INT.AMOUNT,K>
                INS '0' BEFORE R.RECORD<LD.SL.CAP.CHG.AMOUNT,K>       ;* Capitalised charges
                INS '0' BEFORE R.RECORD<LD.SL.CHARGES.AMOUNT,K>       ;* Fees
                INS '0' BEFORE R.RECORD<LD.SL.COMM.AMOUNT,K>          ;* Commission
                INS '0' BEFORE R.RECORD<LD.SL.FEE.AMOUNT,K> ;* Payable fees
                INS '0' BEFORE R.RECORD<LD.SL.CHG.AMOUNT,K>
                INS '0' BEFORE R.RECORD<LD.SL.TAX.AMT.PRIN,K>
                INS '0' BEFORE R.RECORD<LD.SL.TAX.AMT.INT,K>
                INS '0' BEFORE R.RECORD<LD.SL.TAX.AMT.COM,K>

                IF LD.CON.TYPE EQ "COMMITMENT" AND LCU.CALC.BASE MATCHES "TRANCHE-UNUSED":@VM:"UNUSED" THEN
                    INS RUNNING.BAL.COMMIT BEFORE R.RECORD<LD.SL.RUNNING.BAL,K>
                END ELSE
                    INS RUNNING.BAL BEFORE R.RECORD<LD.SL.RUNNING.BAL,K>
                END

                INS PRINC.AMT BEFORE R.RECORD<LD.SL.TOTAL.PAYMENT,K>
                INS PRINC.AMT.DR BEFORE R.RECORD<LD.SL.PRINC.AMT.DR,K>
                INS PRINC.AMT.CR BEFORE R.RECORD<LD.SL.PRINC.AMT.CR,K>
                PREV.LINE = K
            END ELSE
                INS INTEREST.AMT BEFORE R.RECORD<LD.SL.INT.AMOUNT,K>
                INS CAP.CHG.AMT BEFORE R.RECORD<LD.SL.CAP.CHG.AMOUNT,K>         ;* Capitalised charges
*Include Fee Amt & Chg Amt under the same column in R.RECORD
                INS FEE.AMT BEFORE R.RECORD<LD.SL.FEE.AMOUNT,K>       ;* Payable fees
                INS CHG.AMT BEFORE R.RECORD<LD.SL.CHG.AMOUNT,K>       ;*CI_10049442E
                INS COMM.AMOUNT BEFORE R.RECORD<LD.SL.COMM.AMOUNT,K>  ;* Commission
                INS TAX.AMT.PRIN BEFORE R.RECORD<LD.SL.TAX.AMT.PRIN,K>
                INS TAX.AMT.INT BEFORE R.RECORD<LD.SL.TAX.AMT.INT,K>
                INS TAX.AMT.COM BEFORE R.RECORD<LD.SL.TAX.AMT.COM,K>
* CI_10000084
* Capitalsed charge is showed in the charge column of enquiry
                IF CAP.CHG.AMT NE 0 THEN
                    R.RECORD<LD.SL.CHG.AMOUNT,K> += CAP.CHG.AMT
* No need to add cap amount to running balance, as it is done already in ADD.PRINC.SCHED.PAST para.
* RUNNING.BAL += NEW.CAP.AMT
                    NEW.CAP.AMT = 0
                END
* CI_10000084
*

                IF LD.CON.TYPE EQ "COMMITMENT" AND LCU.CALC.BASE MATCHES "TRANCHE-UNUSED":@VM:"UNUSED" THEN
                    INS RUNNING.BAL.COMMIT BEFORE R.RECORD<LD.SL.RUNNING.BAL,K>
                END ELSE
                    INS RUNNING.BAL BEFORE R.RECORD<LD.SL.RUNNING.BAL,K>
                END

                INS DIARY.DETS BEFORE R.RECORD<LD.SL.DIARY.DETS,K>    ;* Diary Narrative
                IF INDEX(SCHED.TYPES,"D",1) THEN
                    SM.COUNT = DCOUNT(DIARY.DETS,@SM)
                END ELSE
                    SM.COUNT = 1
                END
                INS INTEREST.RATE BEFORE R.RECORD<LD.SL.NEW.INT.RATE,K>         ;* New Interest Rate
                INS OD.PROCESS BEFORE R.RECORD<LD.SL.PD.IND,K>


                CAP.INT.YES = ''        ;* EN_10002387 S
                LOCATE ADJ.DATE IN FUTURE.SCHEDULE.DATES<1,1> SETTING DATE.POS THEN
                    CAP.INT.YES = EXPANDED.DETAILS<DATE.POS,LD9.CAP.INT>
                END ELSE      ;* CI_10030457 -S
                    IF ADJ.DATE LT TODAY THEN     ;*Process Capitalisation for Past schedules
                        CAP.INT.YES = SCHEDULES.PAST.REC<LD28.CAP.INT>
                    END
                END ;*CI_10030457 -E

                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR CAP.INT.YES = 'Y') AND SCH.DATE.DIETER NE R.CONTRACT<LD.FIN.MAT.DATE> THEN    ;* GB0000515 S
                    TOT.PAY = PRINC.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.COM   ;*CI_10032538 -S/E
                END ELSE
                    TOT.PAY = PRINC.AMT + INTEREST.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.INT + TAX.AMT.COM
                END ;* GB0000515 E
                INS TOT.PAY BEFORE R.RECORD<LD.SL.TOTAL.PAYMENT,K>
                INS NEXT.LEVEL BEFORE R.RECORD<LD.SL.ENQ.NEXT.LEVEL,K>
                INS PRINC.AMT.DR BEFORE R.RECORD<LD.SL.PRINC.AMT.DR,K>
                INS PRINC.AMT.CR BEFORE R.RECORD<LD.SL.PRINC.AMT.CR,K>
            END     ;* EN_10002384-E
        END ELSE    ;* Add to existing details
* Changes of CI_10021916 reversed. When more than one event(such as principal increase/decrease,   ; * CI_10034444 S/E
* principal schedule that was processed during SOD) happened on preclosed maturity date, the net
* principal amount(Reimburse amount and other principal movement) will be displayed in enquiry.

            R.RECORD<LD.SL.INT.AMOUNT,K> += INTEREST.AMT
            IF R.CONTRACT<LD.CHRG.CAPITALISE> = "YES" THEN  ;* GB0002032 S
                R.RECORD<LD.SL.PRIN.AMOUNT,K> = PRINC.AMT
            END ELSE
*               R.R.RECORD<LD.SL.PRIN.AMOUNT,K> += PRINC.AMT
                R.RECORD<LD.SL.PRIN.AMOUNT,K> += PRINC.AMT  ;* CI_10000084
            END     ;* GB0002032 E
            R.RECORD<LD.SL.CAP.CHG.AMOUNT,K> += CAP.CHG.AMT
            R.RECORD<LD.SL.CHARGES.AMOUNT,K> += FEE.AMT
            R.RECORD<LD.SL.COMM.AMOUNT,K> += COMM.AMOUNT
            R.RECORD<LD.SL.FEE.AMOUNT,K> += FEE.AMT
            R.RECORD<LD.SL.CHG.AMOUNT,K> += (CHG.AMT+ CAP.CHG.AMT)
            R.RECORD<LD.SL.TAX.AMT.PRIN,K> += TAX.AMT.PRIN
            R.RECORD<LD.SL.TAX.AMT.INT,K> += TAX.AMT.INT
            R.RECORD<LD.SL.TAX.AMT.COM,K> += TAX.AMT.COM

            IF LD.CON.TYPE EQ "COMMITMENT" AND LCU.CALC.BASE MATCHES "TRANCHE-UNUSED":@VM:"UNUSED" THEN
                R.RECORD<LD.SL.RUNNING.BAL,K> = RUNNING.BAL.COMMIT     ;* Replace with the latest
            END ELSE
                R.RECORD<LD.SL.RUNNING.BAL,K> = RUNNING.BAL
            END     ;* Replace with the latest


            IF NOT(OD.PROCESS) THEN
                IF R.RECORD<LD.SL.DIARY.DETS,K> THEN
                    R.RECORD<LD.SL.DIARY.DETS,K> := @SM:DIARY.DETS
                END ELSE
                    R.RECORD<LD.SL.DIARY.DETS,K> = DIARY.DETS
                END
            END
            IF INDEX(SCHED.TYPES,"D",1) THEN
                SM.COUNT = DCOUNT(R.RECORD<LD.SL.DIARY.DETS,K>,@SM)
            END ELSE
                SM.COUNT = 1
            END
            R.RECORD<LD.SL.PD.IND,K> = OD.PROCESS
*
            IF CAP.INT.YES = 'Y' AND SCH.DATE.DIETER NE R.CONTRACT<LD.FIN.MAT.DATE> THEN
                TOT.PAY = PRINC.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.COM
            END ELSE
                TOT.PAY = PRINC.AMT + INTEREST.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.INT + TAX.AMT.COM
            END
            IF R.CONTRACT<LD.CHRG.CAPITALISE> = "YES" THEN  ;* GB0002032 S
                R.RECORD<LD.SL.CHG.AMOUNT,K> -= CAP.CHG.AMT ;* CI_10000084
                R.RECORD<LD.SL.TOTAL.PAYMENT,K> = TOT.PAY
            END ELSE
                R.RECORD<LD.SL.TOTAL.PAYMENT,K> += TOT.PAY
            END     ;* GB0002032 E
            R.RECORD<LD.SL.PRINC.AMT.DR,K> += PRINC.AMT.DR
            R.RECORD<LD.SL.PRINC.AMT.CR,K> += PRINC.AMT.CR
        END
    END ELSE
        OPEN.BAL = RUNNING.BAL
    END
*
** Set the contract to current if the value date has been processed
*
*
RETURN
*
*---------------------------------------------------------------------------------
GET.OD.AMT:

** Look for the outstanding amount for the type on the repayment date
*
    SCH.AMT = ""
    LOCATE SCH.DATE.DIETER IN PD.REC<PD.PAYMENT.DTE.DUE,1> SETTING DATE.POS THEN
        LOCATE PD.TYPE IN PD.REC<PD.PAY.TYPE, DATE.POS, 1> SETTING TYPE.POS THEN
            SCH.AMT = -PD.REC<PD.PAY.AMT.OUTS,DATE.POS,TYPE.POS>
        END
    END
*
RETURN
*
*-----------------------------------------------------------------------------------
CALC.TAX.AMT:
*============
** Calculate the TAX amount on interest and commission
** A tax key is passed in with the base amount
*
    TAX.AMT = '' ; TAX.AMT.LOC = '' ; TAX.AMT.FOR = '' ; TAX.TOT = ''; TAX.TOT.LOCAL = '' ;* EN_10003755 S/E
    TAX.CCY = R.CONTRACT<LD.CURRENCY>
    TAX.CUST = R.CONTRACT<LD.CUSTOMER.ID>
    TAX.CUST<3> = R.CONTRACT<LD.CONTRACT.GRP>     ;* GB9701369
    TAX.CCY.MKT = R.CONTRACT<LD.CURRENCY.MARKET>
    IF TAX.BASE.AMT THEN
*
**  GN0002581 - added TAX.DATA to passed vars below...
        TAX.DATA = ""
        CALL LD.TAX.CALC(TAX.DATA, TAX.TOT, TAX.TOT.LOCAL, TAX.AMT.LOC, TAX.AMT.FOR, '', '', '', '',
        TAX.BASE.AMT, TAX.CODE, TAX.CCY, '', TAX.CUST, TAX.CCY.MKT, '', '')     ;* EN_10003755 S/E - new arguments to return total tax amount in local currency
    END
    TAX.AMT = TAX.TOT         ;* EN_10003755 - S/E
*
RETURN
*
END
