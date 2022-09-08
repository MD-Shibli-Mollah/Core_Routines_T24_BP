* @ValidationCode : Mjo2ODkzOTA1NDU6Q3AxMjUyOjE1NTIzODYzMDM2OTk6c3JkZWVwaWdhOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDIuMjAxOTAxMTEtMDM0NzotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Mar 2019 15:55:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : srdeepiga
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190111-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 13/06/01  GLOBUS Release No. G12.1.00 30/10/01
*-----------------------------------------------------------------------------
* <Rating>7554</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LD.ModelBank
SUBROUTINE E.LD.SCHED.LIST.NEW

***********************************************************************
* This routine is called from the enquiries LD.BALANCES.FULL.NEW and LD.BALANCES.SUM . The complete schedule details is obtained by calling the LD.BUILD.FUTURE.SCHEDULES .
*
*
* 22/03/01 - GB0100810
*           wrong amounts are calculated for discounted commission
*           in new enquiries LD.FUTURE.BALANCES.NEW..
* 29/03/01 - GB0100912
*            Missing argument R.EB.BALANCES when calling
*            LD.BUILD.FUTURE.SCHEDULES.
*
* 17/01/01 - EN_10000280
*            LD - Capitalisation without LDS.
*            In the call to LD.BUILD.FUTURE.SCHEDULES, concat the contract
*            ID with an additional info 'ENQUIRY'
* 12/10/04 - BG_100007279
*            Replacement of READ statements with CACHE.READ
*
* 14/12/04 - EN_10002384
*            Allowing overlapping of repayment schedule dates
*            Modify enquiry to show PRIN.AMT.SPLIT in individual lines.
*
* 10/04/06 - CI_10040421
*            Include capitalise interest for repayment enhancement
*
* 08/06/06 - CI_10041734
*            Enquiry not showing Charge Details
*
* 06/07/06 - CI_10042438
*            Total repayment is incorrect for discounted loan contract
*
* 02/05/07 - CI_10048795
*            System shows enquiry incorrectly for LD, COMM.PAYABLE contract
*            after the schedule gets processed.
*
* 18/12/07 - CI_10052996
*            To display the Interest rate in the enquiry LD.BALANCES.FULL.NEW and LD.BALANCES.SUM.NEW
*
* 12/07/08 - EN_10003755
*            Provision for multiple interest tax keys
*
* 05/08/08 - BG_100019390
*            Total amount is updated wrongly for LD.BALANCES.FULL.NEW
*
* 11/09/09 - CI_10066040
*            Double the principal amount displayed on principal decrease and
*            preclosure done on the same day.
*
* 06/10/09 - CI_10066564
*            On same date principal increase/decrease on LD wrong sort of events on ENQ LD.BALANCES.FULL.NEW.
*
* 04/11/09 - CI_10067371
*            COB phase is determined by checking R.SPF.SYSTEM< SPF.OP.MODE> eq .B  AND
*            R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>[1,3] EQ 'COB'.
*
* 09/03/10 - 26147/32254
*            Enquiry LD.BALANCES.SUM.NEW doesn.t show the principal increase amount correctly.
*
* 28/06/11 - Task: 235629 / Defect: 231587
*            Enquiry LD.BALANCES.SUM.NEW doesn't show the principal due amount correctly.
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
* 15/07/13 - Task : 729367 / Defect : 723077
*            Enquiry LD.BALANCES.FULL displays wrong repayment schedule when we define two principal schedules on Maturity date.
*
* 07/08/13 - Task :749659
*            Defect : 749012
*            Initialise the CAP.INT.YES variable.
*
* 03/09/14 - Defect : 1092152 & Task : 1103602
*            Enquiry shows incorrect values for Total Amount & Principal Amount Labels.
*
* 23/04/15 - Defect : 1319988 / Task : 1325725
*            Enquiry doesn't shows their Individual moments entry when do Increase or Decrease operation on a same day.
*
*
* 23/04/15 - Task : 1325793 / Defect : 1316162
*            When the enquiry LD.BALANCES.FULL processed on COB, system would display the  LD detials .
*
* 21/12/2018 - Enhancement: 2822515
*              Task : 2847828
*              Componentisation changes.
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
    CAP.INT.YES = ""

    EOD = (R.SPF.SYSTEM<SPF.OP.MODE> EQ 'B' AND R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>[1,3] EQ 'COB')
*
    TOT.PAY = 0
    VM.COUNT = '' ; SM.COUNT = ""       ;* Set during enquiry
    R.RECORD = ''   ;*  Returned M/v record
    R.DATE.IND = '' ;* Index for dates SCHED:ADJ
    NO.OF.DAYS = ""
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
    PREV.LINE = 0   ;*EN_10002384
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
    NEW.CAP.AMT=0
    NEW.CHG.AMT=0   ;* CI_10041734
    YI = 1 ; RUNNING.BAL = 0
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
** Build a list of future schedules for processing
*
* CI_10041734 S
    CHG.CNT = 0
    LOOP
        CHG.CNT += 1
    WHILE ACCBAL.REC<LD27.CHRGS.DUE.DATE,CHG.CNT>
        JUL.EFF.DATE = '' ; VDATE = ACCBAL.REC<LD27.CHRGS.DUE.DATE,CHG.CNT>
        CALL JULDATE(VDATE,JUL.EFF.DATE)
        LOCATE JUL.EFF.DATE IN SCHEDULE.DATES<1> BY 'AR' SETTING VDPOS ELSE
            INS JUL.EFF.DATE BEFORE SCHEDULE.DATES<VDPOS>
        END
    REPEAT
* CI_10041734 E

    SAVE.FUNCTION = V$FUNCTION
    IF EOD THEN
        V$FUNCTION = ""
    END   ;* Do NOT use I. This will write in EOD
    EXPANDED.DETAILS = "" ; FUTURE.IDX = ""
    R.EB.BALANCES = ''        ;* GB0100810 S/E
* EN_10000280 S
    LD.ID = ''
    LD.ID = ID[1,12]:@FM:'':@FM:'ENQUIRY'
* EN_10000280 E
    CALL LD.BUILD.FUTURE.SCHEDULES(LD.ID, R.CONTRACT, ACCBAL.REC, FUTURE.SCHEDULE.DATES, EXPANDED.DETAILS, OTS.BALANCES,R.EB.BALANCES)      ;* GB0100912 S/E ; * EN_10000280 S/E
    V$FUNCTION = SAVE.FUNCTION
*
RETURN
*
*--------------------------------------------------------------------
PROCESS.SCH:
*-----------
** Take each schedule and extract the elevant details
*
    NO.OF.DAYS = DCOUNT(SCHEDULE.DATES, @FM)
    SCH.DATE.DIETER = "" ; CONTRACT.STATUS = 'FWD'          ;* Set to CUR when drawndown
    SCH.DATE.ARR = SCHEDULE.DATES

    GOSUB BUILD.PROCESS.DATES



    LOOP
        REMOVE SCH.DATE FROM SCH.DATE.ARR SETTING SCH.DATE.POS
    WHILE SCH.DATE
        PRIN.SUM.WITHIN.DATES = ''

        SCH.DATE.DIETER = ''
        CALL JULDATE(SCH.DATE.DIETER,SCH.DATE)
    UNTIL SCH.DATE.DIETER GT END.DATE AND END.DATE NE ""
        IF SCH.DATE.DIETER LE PROCESS.DATE THEN
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
        GOSUB PROCESS.SCH.REST
    NEXT FUTURE.IDX
*
PROCESS.SCH.EXIT:
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
*--------------------------------------------------------------------
BUILD.PRIN.DATA:
*---------------

*
    IF CURR.PRIN.DATE LE ACCBAL.REC<LD27.DATE.FROM,VDPOS> THEN
        SCHEDULES.PAST.REC<LD28.PRINCIPAL.DUE.AMT> = -ACCBAL.REC<LD27.TRANS.PRIN.AMT,VDPOS>
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN         ;*EN_10002384-S
            SCHEDULES.PAST.REC<LD28.PRIN.AMT.SPLIT> = -ACCBAL.REC<LD27.TRANS.PRIN.AMT,VDPOS>
        END       ;*EN_10002384-E
        IF SCHEDULES.PAST.REC<LD28.PRINCIPAL.DUE.AMT> THEN
            PROCESS.P.SCHED = 1
            EVENT.DATE = ACCBAL.REC<LD27.DATE.FROM,VDPOS> ;* Date of Event
            GOSUB ADD.PRINC.SCHED.PAST
        END
    END

RETURN

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

    SCH.DATE = SCH.DATE

    GOSUB READ.SCH.PAST
    GOSUB GET.PAY.DATES:
*
    NEXT.LEVEL = "LMM.SCHEDULES.PAST S ":SCH.PAST.ID
*
    IF SCHEDULES.PAST.REC<LD28.FEE.DUE.AMOUNT> THEN
        VMC = DCOUNT(SCHEDULES.PAST.REC<LD28.FEE.DUE.AMOUNT>,@VM)      ;* Number of fees
        FEE.DUE.AMOUNT.ARR = SCHEDULES.PAST.REC<LD28.FEE.DUE.AMOUNT>
        LOOP
            REMOVE FEE.DUE.AMOUNT FROM FEE.DUE.AMOUNT.ARR SETTING FEE.DUE.AMOUNT.POS
        WHILE FEE.DUE.AMOUNT  ;* Split out pay and receive
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
            FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)       ;* Add total fees
        END
*
        SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
        GOSUB ADD.TO.REC.DETAILS
        CHG.TYPE = "CHG" ; SCH.AMT = CHG.AMT
*
        GOSUB ADD.TO.REC.DETAILS
*
    END ELSE
*
** Add the drawdown fees to the contract
*
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
            FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)       ;* Add total fees
*
            IF FEE.AMT THEN
                SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
                GOSUB ADD.TO.REC.DETAILS
            END
*
        END
*
    END
*
* GB0100810 S/E
*      IF DISCOUNTED.COMM AND NOT(FIRST.INPUT) THEN           ; * Add the discounted interest if not there
    IF DISCOUNTED.COMM THEN
        IF SCH.DATE.DIETER LT R.CONTRACT<LD.VALUE.DATE> AND SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> = "" THEN
            IF LOAN.OR.DEPOSIT = "LOAN" THEN
                SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> = -ACCBAL.REC<LD27.COMMITTED.COMM>
            END
        END
    END
*
    IF SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT> THEN
        COMM.AMOUNT = -SCHEDULES.PAST.REC<LD28.COMM.DUE.AMOUNT>
        SCH.TYPE = "COMM" ; SCH.AMT = COMM.AMOUNT
        GOSUB ADD.TO.REC.DETAILS
    END
*
    IF SCHEDULES.PAST.REC<LD28.TAX.CODE.COMM> OR ( DISCOUNTED.COMM AND R.CONTRACT<LD.VALUE.DATE> LE TODAY ) THEN        ;* Calcualte the tax
        TAX.BASE.AMT = ABS(COMM.AMOUNT)
        TAX.AMT = ABS(SCHEDULES.PAST.REC<LD28.TAX.CODE.COMM>)
        IF R.CONTRACT<LD.TAX.COMMISSN.TYPE> THEN
            TAX.CODE = R.CONTRACT<LD.TAX.COMMISSN.TYPE>
        END ELSE
            TAX.CODE = R.CONTRACT<LD.TAX.COMMISSION.KEY>
        END
        IF NOT(TAX.AMT) THEN
            GOSUB CALC.TAX.AMT
        END
        TAX.AMT.COM = TAX.AMT
        SCH.TYPE = "TAXC" ; SCH.AMT = TAX.AMT
        GOSUB ADD.TO.REC.DETAILS
    END
*
    IF SCHEDULES.PAST.REC<LD28.CAP.CHRG.REC> OR ACCBAL.REC<LD27.AMT.REC> THEN
        SCH.TYPE = "CAP"
*    SCH.AMT = SUM(SCHEDULES.PAST.REC<LD28.CAP.CHRG.REC>)
        Y.CHRGS.DUE.DATE = ACCBAL.REC<LD27.CHRGS.DUE.DATE>
        Y.CHRGS.COUNT = DCOUNT(Y.CHRGS.DUE.DATE,@VM)
        FOR I=1 TO Y.CHRGS.COUNT
            IF Y.CHRGS.DUE.DATE<1,I> EQ SCH.DATE.DIETER THEN
                IF ACCBAL.REC<LD27.CAP.CHRG.IND><1,I> EQ 'YES' THEN
                    NEW.CAP.AMT += ACCBAL.REC<LD27.AMT.REC,I>
                END ELSE
                    NEW.CHG.AMT += ACCBAL.REC<LD27.AMT.REC,I>
                END
            END
        NEXT I

        IF NEW.CAP.AMT THEN
            SCH.TYPE = "CAP"
* CI_10000877 - E
            SCH.AMT = NEW.CAP.AMT * -1  ;*CI_10030457 -S/E
            CAP.CHG.AMT = SCH.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
        IF NEW.CHG.AMT THEN
            IF NEW.CHG.AMT > 0 THEN
                SCH.TYPE="CHG"
                SCH.AMT=NEW.CHG.AMT
                CHG.AMT=SCH.AMT
            END ELSE          ;* BG_100019390 S
                SCH.TYPE = "FEE"
                SCH.AMT = NEW.CHG.AMT
                FEE.AMT = SCH.AMT
            END     ;* BG_100019390 E
            GOSUB ADD.TO.REC.DETAILS
            NEW.CHG.AMT=0
        END
    END
*
***********************
** Commented for setting int rate as committed rate& also the discounted interest is always set here for the current period
    IF DISCOUNTED.INT THEN
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> AND SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> = "" THEN
            IF LOAN.OR.DEPOSIT = "DEPOSIT" THEN
                SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> = -ACCBAL.REC<LD27.COMMITTED.INT>
            END ELSE
                SCHEDULES.PAST.REC<LD28.INTEREST.DUE.AMT> = -ACCBAL.REC<LD27.COMMITTED.INT>
*********************************
            END
        END
    END
*
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

        IF SCHEDULES.PAST.REC<LD28.TAX.CODE.INT> OR (DISCOUNTED.INT AND (R.CONTRACT<LD.VALUE.DATE> LE TODAY )) THEN
            TAX.BASE.AMT = ABS(INTEREST.AMT)
            TAX.AMT = ABS(SCHEDULES.PAST.REC<LD28.TAX.CODE.INT>)
            IF R.CONTRACT<LD.TAX.INT.TYPE> THEN   ;* EN_10003755 S
                TAX.CODE = R.CONTRACT<LD.TAX.INT.TYPE>
            END ELSE
                TAX.CODE = R.CONTRACT<LD.TAX.INT.KEY>       ;* EN_10003755 E
            END
            IF NOT(TAX.AMT) THEN
                GOSUB CALC.TAX.AMT
            END
            TAX.AMT.INT = TAX.AMT
            SCH.TYPE = "TAXI" ; SCH.AMT = TAX.AMT
            GOSUB ADD.TO.REC.DETAILS
*
        END
    END
***********************************
** The following lines are included to included the principal tax on contract start date
    IF R.CONTRACT<LD.TAX.PRINCIPAL.KEY> OR R.CONTRACT<LD.TAX.PRINCIPAL.TYPE> AND SCH.DATE.DIETER EQ R.CONTRACT<LD.VALUE.DATE> THEN
        TAX.BASE.AMT = ABS(R.CONTRACT<LD.AMOUNT>)
        IF R.CONTRACT<LD.TAX.PRINCIPAL.TYPE> THEN
            TAX.CODE = R.CONTRACT<LD.TAX.PRINCIPAL.TYPE>
        END ELSE
            TAX.CODE = R.CONTRACT<LD.TAX.PRINCIPAL.KEY>
        END
        GOSUB CALC.TAX.AMT
        TAX.AMT.PRIN = TAX.AMT
        SCH.TYPE = "TAXP" ; SCH.AMT = TAX.AMT
        GOSUB ADD.TO.REC.DETAILS
*
    END
*****************************************
** There is not always a drawdown schedule, so we need to add
** the initial amount
** There will not always be schedule past record for increase and back valued
** decreases, so the increase amount for the effective date should be added too
*



    LOOP
        REMOVE CURR.DETAILS FROM CURR.DETAILS.ARR SETTING C.POS
    WHILE CURR.DETAILS:C.POS
        CURR.PRIN.DATE = CURR.DETAILS['*',1,1]
        CURR.PRIN.AMT = CURR.DETAILS['*',2,1]

        IF CURR.PRIN.DATE AND CURR.PRIN.DATE EQ SCH.DATE.DIETER THEN
            GOSUB BUILD.PRIN.DATA

        END
        VDPOS += 1
    REPEAT




    IF NOT(PROCESS.P.SCHED) THEN        ;* Alreadxy done with the principal
        GOSUB INCLUDE.SCHEDULE
        IF INCLUDE.SCHED.DETS THEN
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
    SPECIAL.PROCESS = 0       ;*EN_10002384-S
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
        END
        PRINC.AMT = SCH.AMT
        IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN ;* Set the principal amt to be the Issue price
            BEGIN CASE
                CASE CONTRACT.STATUS NE 'FWD'         ;* Only use DD price at start
                CASE R.CONTRACT<LD.DRAWDOWN.ISSUE.PRC> = ''
                    EVENT.DATE = R.CONTRACT<LD.DRAWDOWN.ENT.DATE>
                    CONTRACT.STATUS = 'CUR'
                CASE 1
                    PRINC.AMT += R.CONTRACT<LD.ISSUE.PL.AMOUNT>
                    EVENT.DATE = R.CONTRACT<LD.DRAWDOWN.ENT.DATE>
                    CONTRACT.STATUS = 'CUR'
            END CASE
        END
*
* REIMBURSE.AMOUNT should be taken only for maturity repayment event and not for other events on the same date.
        IF SCH.DATE.DIETER = R.CONTRACT<LD.FIN.MAT.DATE> AND ACCBAL.REC<LD27.OUTS.CURR.PRINC,VDPOS> EQ 0 AND PR.CNT EQ DO.COUNT THEN        ;* On maturity date use the reimbursement price
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
*
        LAST.BALANCE += SCH.AMT
        RUNNING.BAL += SCH.AMT
*
        SPECIAL.PROCESS = 1
        GOSUB INCLUDE.SCHEDULE
        IF INCLUDE.SCHED.DETS THEN
            GOSUB STORE.SCHED.DETS
        END
*
        GOSUB INIT.AMT.VARS
*
        PR.CNT += 1
    REPEAT
    SPECIAL.PROCESS = 0 ;
    IF CURR.PRIN.DATE NE SCH.DATE.DIETER THEN
        PREV.LINE = 0 ;*EN_10002384-E
    END
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
    OD.PROCESS = ""
    GOSUB INIT.AMT.VARS

    SCH.DATE = SCH.DATE

    SCHEDULES.REC = RAISE(EXPANDED.DETAILS<FUTURE.IDX>)     ;* Extract the expanded record
    SCHEDULE.DATE = CONTRACT.NO:SCH.DATE:"00"
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
                FEE.AMT += ABS(SCHEDULES.REC<LD9.FEE.AMOUNT.DUE,YIND>) * -1
            END ELSE
                CHG.AMT += SCHEDULES.REC<LD9.FEE.AMOUNT.DUE,YIND>
            END
        NEXT YIND
*
** Add the drawdown fees to the contract
*
        IF SCH.DATE.DIETER GE PROCESS.DATE THEN
            IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
                FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)   ;* Add total fees
            END
        END
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
        IF SCH.DATE.DIETER GE PROCESS.DATE THEN   ;* Fees will already be processed as Past items
            IF SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
                FEE.AMT -= SUM(R.CONTRACT<LD.DD.FEE.AMT>)   ;* Add total fees
                IF FEE.AMT THEN
                    SCH.TYPE = "FEE" ; SCH.AMT = FEE.AMT
                    GOSUB ADD.TO.REC.DETAILS
                END
            END
        END
*
    END
    IF SCHEDULES.REC<LD9.TYPE.P> EQ 'Y' THEN
        PRINC.AMOUNT = SCHEDULES.REC<LD9.PRIN.AMOUNT.DUE>
    END
*
    IF SCHEDULES.REC<LD9.TYPE.C> EQ 'Y' THEN

        COMM.AMOUNT = SCHEDULES.REC<LD9.COMMISSION.AMT>

        SCH.TYPE = "COMM" ; SCH.AMT = COMM.AMOUNT
        GOSUB ADD.TO.REC.DETAILS
*
        IF R.CONTRACT<LD.TAX.COMMISSION.KEY> OR R.CONTRACT<LD.TAX.COMMISSN.TYPE> THEN
            TAX.BASE.AMT = ABS(COMM.AMOUNT)
            IF R.CONTRACT<LD.TAX.COMMISSN.TYPE> THEN
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
    IF SCHEDULES.REC<LD9.TYPE.I> THEN
        SCH.TYPE = "INT" ; SCH.AMT = SCHEDULES.REC<LD9.INTEREST.AMT>
        INTEREST.AMT = SCH.AMT * -1
        GOSUB ADD.TO.REC.DETAILS
        IF (R.CONTRACT<LD.CAPITALISATION> = "YES" OR SCHEDULES.REC<LD9.CAP.INT> = 'Y')  AND SCH.DATE.DIETER NE R.CONTRACT<LD.FIN.MAT.DATE> THEN
            LAST.BALANCE += SCH.AMT
            RUNNING.BAL += SCH.AMT
            IF NOT(SCHED.CAP) THEN
                SCHED.CAP = "1"
            END     ;* EN_10002387 S/E
        END
*
        IF R.CONTRACT<LD.TAX.INT.TYPE> OR R.CONTRACT<LD.TAX.INT.KEY> THEN       ;* EN_10003755 S
            TAX.BASE.AMT = ABS(INTEREST.AMT)
            IF R.CONTRACT<LD.TAX.INT.TYPE> THEN
                TAX.CODE = R.CONTRACT<LD.TAX.INT.TYPE>
            END ELSE
                TAX.CODE = R.CONTRACT<LD.TAX.INT.KEY>       ;* EN_10003755 E
            END
            GOSUB CALC.TAX.AMT
            TAX.AMT.INT = TAX.AMT
            SCH.TYPE = "TAXI" ; SCH.AMT = TAX.AMT
            GOSUB ADD.TO.REC.DETAILS
        END
    END
**
    SPECIAL.PROCESS = 0 ; PREV.LINE = 0 ;*EN_10002384-S
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
                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR SCHED.CAP) AND SCH.DATE.DIETER EQ R.CONTRACT<LD.FIN.MAT.DATE> AND LOAN.OR.DEPOSIT NE "DEPOSIT" THEN         ;* GB0000515 S ; * EN_10002387 S/E
                    PRINC.AMT = ABS(RUNNING.BAL)
                END ;* GB0000515 E
                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR SCHED.CAP) AND SCH.DATE.DIETER EQ R.CONTRACT<LD.FIN.MAT.DATE> AND LOAN.OR.DEPOSIT EQ "DEPOSIT" THEN         ;* CI_10002810 S ; * EN_10002387 S/E
                    PRINC.AMT = RUNNING.BAL * -1
                END ;* CI_10002810 E
                GOSUB ADD.TO.REC.DETAILS
*
                LAST.BALANCE += SCH.AMT
                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR SCHED.CAP) AND SCH.DATE.DIETER EQ R.CONTRACT<LD.FIN.MAT.DATE> THEN  ;* GB0000515 S ; * EN_10002387 S/E
                    RUNNING.BAL += PRINC.AMT
                END ELSE
                    RUNNING.BAL += SCH.AMT
                END
                IF PR.CNT = DO.COUNT ELSE
                    SPECIAL.PROCESS = 1
                    GOSUB INCLUDE.SCHEDULE
                    IF INCLUDE.SCHED.DETS THEN
                        GOSUB STORE.SCHED.DETS
                    END
                END
            NEXT PR.CNT       ;*EN_10002384-E
        END
    END
**
    IF SCHEDULES.REC<LD9.TYPE.N> EQ 'Y' THEN
        SCH.TYPE = "CAP" ; SCH.AMT = SUM(SCHEDULES.REC<LD9.CHRG.AMOUNT.DUE>)
        CAP.CHG.AMT = SCH.AMT
        GOSUB ADD.TO.REC.DETAILS
*
        LAST.BALANCE += SCH.AMT
        RUNNING.BAL += SCH.AMT
    END
*
    IF SCHEDULES.REC<LD9.TYPE.D> EQ "Y" THEN
        DIARY.DETS = LOWER(SCHEDULES.REC<LD9.DIARY.ACTION>) ;* May be multiple lines
        SCH.AMT = DIARY.DETS ; SCH.TYPE = "DIAR"
        GOSUB ADD.TO.REC.DETAILS
*
    END
*
    GOSUB INCLUDE.SCHEDULE
    IF INCLUDE.SCHED.DETS THEN
        GOSUB STORE.SCHED.DETS
    END
    SPECIAL.PROCESS = 0 ; PREV.LINE = 0 ;*EN_10002384
*
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
                R.RECORD<LD.SL.ENQ.END.DATE> = SCH.DATE.DIETER
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
        INT.RATE = INT.RTE<1> ;* CI_10052996 To display the Interest rate in the enquiry LD.BALANCES.FULL.NEW and LD.BALANCES.SUM.NEW
    END
    IF INT.SPREAD THEN
        INT.RATE = INT.RATE:' + ':INT.SPREAD
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
            IF SPECIAL.PROCESS THEN     ;*EN_10002384-S
* SPECIAL.PROCESS is set to insert new lines for each principal split.
                MERGE.INSERT = 'INSERT'
            END ELSE          ;*EN_10002384-E
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
*******************************
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
            END
            INS DATE.CHK BEFORE R.DATE.IND<K>
            INS SCH.DATE.DIETER BEFORE R.RECORD<LD.SL.EVENT.DATE,K>
            INS ADJ.DATE BEFORE R.RECORD<LD.SL.ADJ.DATE,K>

            INS PRINC.AMT BEFORE R.RECORD<LD.SL.PRIN.AMOUNT,K>
            IF SCH.TYPE="PRINC" AND DO.COUNT NE PR.CNT THEN ;*EN_10002384-S
                INS '0' BEFORE R.RECORD<LD.SL.INT.AMOUNT,K>
                INS '0' BEFORE R.RECORD<LD.SL.CAP.CHG.AMOUNT,K>       ;* Capitalised charges
                INS '0' BEFORE R.RECORD<LD.SL.CHARGES.AMOUNT,K>       ;* Fees
                INS '0' BEFORE R.RECORD<LD.SL.COMM.AMOUNT,K>          ;* Commission
                INS '0' BEFORE R.RECORD<LD.SL.FEE.AMOUNT,K> ;* Payable fees
                INS '0' BEFORE R.RECORD<LD.SL.CHG.AMOUNT,K>
                INS '0' BEFORE R.RECORD<LD.SL.TAX.AMT.PRIN,K>
                INS '0' BEFORE R.RECORD<LD.SL.TAX.AMT.INT,K>
                INS '0' BEFORE R.RECORD<LD.SL.TAX.AMT.COM,K>
                INS RUNNING.BAL BEFORE R.RECORD<LD.SL.RUNNING.BAL,K>
                INS PRINC.AMT BEFORE R.RECORD<LD.SL.TOTAL.PAYMENT,K>
                INS PRINC.AMT.DR BEFORE R.RECORD<LD.SL.PRINC.AMT.DR,K>
                INS PRINC.AMT.CR BEFORE R.RECORD<LD.SL.PRINC.AMT.CR,K>
                PREV.LINE = K
            END ELSE
                INS INTEREST.AMT BEFORE R.RECORD<LD.SL.INT.AMOUNT,K>
                INS CAP.CHG.AMT BEFORE R.RECORD<LD.SL.CAP.CHG.AMOUNT,K>         ;* Capitalised charges
                INS FEE.AMT BEFORE R.RECORD<LD.SL.CHARGES.AMOUNT,K>   ;* Fees
                INS COMM.AMOUNT BEFORE R.RECORD<LD.SL.COMM.AMOUNT,K>  ;* Commission
                INS FEE.AMT BEFORE R.RECORD<LD.SL.FEE.AMOUNT,K>       ;* Payable fees
                INS CHG.AMT BEFORE R.RECORD<LD.SL.CHG.AMOUNT,K>
                INS TAX.AMT.PRIN BEFORE R.RECORD<LD.SL.TAX.AMT.PRIN,K>
                INS TAX.AMT.INT BEFORE R.RECORD<LD.SL.TAX.AMT.INT,K>
                INS TAX.AMT.COM BEFORE R.RECORD<LD.SL.TAX.AMT.COM,K>

* Capitalsed charge is showed in the charge column of enquiry
                IF CAP.CHG.AMT NE 0 THEN
                    R.RECORD<LD.SL.CHG.AMOUNT,K> += CAP.CHG.AMT
* No need to add cap amount to running balance, as it is done already in ADD.PRINC.SCHED.PAST para.
* RUNNING.BAL += NEW.CAP.AMT
                    NEW.CAP.AMT = 0
                END

                INS RUNNING.BAL BEFORE R.RECORD<LD.SL.RUNNING.BAL,K>
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
                END ;* EN_10002387 E

                IF (R.CONTRACT<LD.CAPITALISATION> EQ "YES" OR CAP.INT.YES = 'Y') AND SCH.DATE.DIETER NE R.CONTRACT<LD.FIN.MAT.DATE> THEN    ;* GB0000515 S
                    TOT.PAY = PRINC.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.INT + TAX.AMT.COM
                END ELSE
                    TOT.PAY = PRINC.AMT + INTEREST.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.INT + TAX.AMT.COM
                END ;* GB0000515 E
                INS TOT.PAY BEFORE R.RECORD<LD.SL.TOTAL.PAYMENT,K>
                INS NEXT.LEVEL BEFORE R.RECORD<LD.SL.ENQ.NEXT.LEVEL,K>
                INS PRINC.AMT.DR BEFORE R.RECORD<LD.SL.PRINC.AMT.DR,K>
                INS PRINC.AMT.CR BEFORE R.RECORD<LD.SL.PRINC.AMT.CR,K>
                IF CURR.PRIN.DATE EQ SCH.DATE.DIETER THEN
                    PREV.LINE = K ; * Need to keep existing value of K since PRINC.AMT values is not updated in R.RECORD<LD.SL.PRINC.AMT> Array in proper position.
                END
            END     ;*EN_10002384-E
        END ELSE    ;* Add to existing details
            R.RECORD<LD.SL.INT.AMOUNT,K> += INTEREST.AMT
            R.RECORD<LD.SL.PRIN.AMOUNT,K> += PRINC.AMT
            R.RECORD<LD.SL.CAP.CHG.AMOUNT,K> += CAP.CHG.AMT
            R.RECORD<LD.SL.CHARGES.AMOUNT,K> += FEE.AMT
            R.RECORD<LD.SL.COMM.AMOUNT,K> += COMM.AMOUNT
            R.RECORD<LD.SL.FEE.AMOUNT,K> += FEE.AMT
            R.RECORD<LD.SL.CHG.AMOUNT,K> += CHG.AMT
            R.RECORD<LD.SL.TAX.AMT.PRIN,K> += TAX.AMT.PRIN
            R.RECORD<LD.SL.TAX.AMT.INT,K> += TAX.AMT.INT
            R.RECORD<LD.SL.TAX.AMT.COM,K> += TAX.AMT.COM
            R.RECORD<LD.SL.RUNNING.BAL,K> = RUNNING.BAL     ;* Replace with the latest
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
* ABS value of PRINC.AMT should not be used to calcuate the tot payment amount which will display wrong payment amount.
            TOT.PAY = PRINC.AMT + INTEREST.AMT + FEE.AMT + CHG.AMT + COMM.AMOUNT + TAX.AMT.INT + TAX.AMT.COM
            R.RECORD<LD.SL.TOTAL.PAYMENT,K> += TOT.PAY
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
    TAX.AMT = '' ; TAX.AMT.LOC = '' ; TAX.AMT.FOR = ''; TAX.TOT = ''; TAX.TOT.LOCAL = ''  ;* EN_10003755 S/E
    TAX.CCY = R.CONTRACT<LD.CURRENCY>
    TAX.CUST = R.CONTRACT<LD.CUSTOMER.ID>
    TAX.CUST<3> = R.CONTRACT<LD.CONTRACT.GRP>
    TAX.CCY.MKT = R.CONTRACT<LD.CURRENCY.MARKET>
    IF TAX.BASE.AMT THEN
        CALL LD.TAX.CALC('',TAX.TOT, TAX.TOT.LOC, TAX.AMT.LOC, TAX.AMT.FOR, '', '', '', '',
        TAX.BASE.AMT, TAX.CODE, TAX.CCY, '', TAX.CUST, TAX.CCY.MKT, '', '')     ;* EN_10003755 - new argument TAX.TOT.LOC reutrns the total tax amount in local currency
    END

* update the TAX.AMT in deal currency
    TAX.AMT = TAX.TOT         ;* EN_10003755 S/E
*
RETURN
*
END
