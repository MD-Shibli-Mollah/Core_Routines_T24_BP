* @ValidationCode : MjoxNjY1Njk1OTA4OkNwMTI1MjoxNTUyMzg2MzA2ODk5OnNyZGVlcGlnYTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTAyLjIwMTkwMTExLTAzNDc6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Mar 2019 15:55:06
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

*-----------------------------------------------------------------------------
* <Rating>-136</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LD.ModelBank
SUBROUTINE E.TCIB.GET.LD.SCHEDULE.DATE
*-----------------------------------------------------------------------------
* Attached to     : TCIB.LD.LOANS & TCIB.LD.DEPOSITS Enquiry as Conversion routine
* Incoming        : Enquiry data(To get the LD id)
* Outgoing        : Payment date, amount, frequency
*-----------------------------------------------------------------------------
* Description:
* This routine is used by the TCIB.LD.LOANS & TCIB.LD.DEPOSITS enquiry to read all the schedule
* records and assemble the required information in O.DATA
*-----------------------------------------------------------------------------
* Modification History :
* 21/05/14 - Enhancement 920989/Task 1032322
*            TCIB : Retail (Loans and Deposits)
*
* 29/06/14 - Defect 1034730/Task 1044773
*            Interest rate for Floating type is displayed incorrectly in Loan Details.
*
* 29/06/14 - Defect 1039875/Task 1044875
*           Maturity Amount is calculated incorrectly for Deposit contract with monthly frequency.
*
* 29/11/2018 - Enhancement: 2822515
*              Task :  2847828
*              Componentisation changes.
*
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.LMM.ACCOUNT.BALANCES
    $INSERT I_F.LMM.SCHEDULES
    $INSERT I_LD.SCH.LIST
    $INSERT I_F.LMM.SCHEDULE.DATES
    $INSERT I_F.LMM.SCHEDULES.PAST
*
    GOSUB INIT
    GOSUB OPEN.FILE
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
*Initialise all variables
    FN.LMM.ACCOUNT.BALANCES  = 'F.LMM.ACCOUNT.BALANCES'
    F.LMM.ACCOUNT.BALANCES   = ''
*
    FN.LMM.SCHEDULE.DATES    = 'F.LMM.SCHEDULE.DATES'
    F.LMM.SCHEDULE.DATES     = ''
*
    FN.LMM.SCHEDULES.PAST    = 'F.LMM.SCHEDULES.PAST'
    F.LMM.SCHEDULES.PAST     = ''
RETURN
*-----------------------------------------------------------------------------
OPEN.FILE:
*-----------------------------------------------------------------------------
* Open required files
    CALL OPF(FN.LMM.ACCOUNT.BALANCES,F.LMM.ACCOUNT.BALANCES)
    CALL OPF(FN.LMM.SCHEDULE.DATES,F.LMM.SCHEDULE.DATES)
    CALL OPF(FN.LMM.SCHEDULES.PAST,F.LMM.SCHEDULES.PAST)
RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
* Get next payment date, amount and Loan amount,outstanding amount,amount paid out,interest value
    Y.LD.ID            = O.DATA         ;* Get the LD id
    Y.LMM.REC.ID       = Y.LD.ID:"00"   ;* Add 00 with LD id and read LMM.ACCOUNT.BALANCES
    CALL F.READ(FN.LMM.ACCOUNT.BALANCES,Y.LMM.REC.ID,R.LMM.ACCOUNT.BALANCES,F.LMM.ACCOUNT.BALANCES,ERR.LMM.ACCOUNT.BALANCES)
*
    Y.LOAN.AMT         = R.RECORD<LD.DRAWDOWN.NET.AMT>      ;* Loan amount
    Y.OUTSTAND.AMT     = R.RECORD<LD.AMOUNT>      ;* Outstanding amount
    Y.AMT.PAID.OUT     = Y.LOAN.AMT - Y.OUTSTAND.AMT        ;* Amount paid out
*
    LD.ID              = Y.LD.ID[1,12]:@FM:'':@FM:'ENQUIRY'
    R.CONTRACT         = R.RECORD
    ACCBAL.REC         = R.LMM.ACCOUNT.BALANCES
    CALL LD.BUILD.FUTURE.SCHEDULES(LD.ID,R.CONTRACT,ACCBAL.REC,FUTURE.SCHEDULE.DATES,EXPANDED.DETAILS,OTS.BALANCES,R.EB.BALANCES) ;* To get the future payment date and amount
    Y.NEXT.PAY.DATE    = FUTURE.SCHEDULE.DATES<1,1>         ;* Next payment date
    Y.PRINC.AMT        = ABS(EXPANDED.DETAILS<1,LD9.PRIN.AMOUNT.DUE>) ;* Principal amount
    Y.INT.AMT          = ABS(EXPANDED.DETAILS<1,LD9.INTEREST.AMT>)    ;* Interest amount
    Y.COMM.AMT         = ABS(EXPANDED.DETAILS<1,LD9.COMMISSION.AMT>)  ;* Commission amount
    Y.FEE.AMT          = ABS(EXPANDED.DETAILS<1,LD9.FEE.AMOUNT.DUE>)  ;* Fees amount
    Y.CHG.AMT          = ABS(EXPANDED.DETAILS<1,LD9.CHRG.AMOUNT.DUE>) ;* Charge amount
*
    GOSUB GET.FUTURE.PAST.INT
    GOSUB GET.FINAL.INT.VAL
*
    Y.LD.CAPIT.VAL     = R.CONTRACT<LD.CAPITALISATION>      ;* Capitalisation
    Y.LD.MAT.DATE      = R.CONTRACT<LD.FIN.MAT.DATE>        ;* Maturity date
*
    IF Y.LD.CAPIT.VAL EQ 'YES' AND Y.NEXT.PAY.DATE NE Y.LD.MAT.DATE THEN        ;* Check LD captitalisation and maturity value
        Y.NEXT.PAY.AMT = Y.PRINC.AMT + Y.FEE.AMT + Y.CHG.AMT + Y.COMM.AMT       ;* Next payment amount
    END ELSE
        Y.NEXT.PAY.AMT = Y.PRINC.AMT + Y.INT.AMT + Y.FEE.AMT + Y.CHG.AMT + Y.COMM.AMT     ;* Next payment amount
    END
    GOSUB FORMAT.INT.RATE
*
    O.DATA     = Y.NEXT.PAY.DATE        ;* Next payment date(1)
    O.DATA<-1> = Y.NEXT.PAY.AMT         ;* Next payment amount(2)
    O.DATA<-1> = Y.INT        ;* Interest rate(3)
    O.DATA<-1> = Y.LOAN.AMT   ;* Loan amount(4)
    O.DATA<-1> = Y.AMT.PAID.OUT         ;* Amount paid out(5)
    O.DATA<-1> = Y.OUTSTAND.AMT         ;* Outstanding amount(6)
    O.DATA<-1> = Y.MAT.INT.VAL          ;* Total interest amount for the whole tennor(7)
    CHANGE @FM TO "*" IN O.DATA          ;* All the values are assembled in O.DATA. By using '*' marker taking for another fields in the enquiry.
RETURN
*-----------------------------------------------------------------------------
FORMAT.INT.RATE:
*-----------------------------------------------------------------------------
* Interest rate should not be display like 7+2=9%. It should be 9%
    LD.ModelBank.EMbLdBalances()
    Y.INT.RATE = O.DATA
    FINDSTR "=" IN Y.INT.RATE SETTING Y.FIELD,Y.VALUE THEN  ;* Check '=' is available in the interest rate output
        Y.INT  = FIELD(Y.INT.RATE,"=",2)          ;* Get the interest rate alone
    END ELSE
        Y.INT  = Y.INT.RATE   ;* Interest rate
    END
RETURN
*-----------------------------------------------------------------------------
GET.FUTURE.PAST.INT:
*-----------------------------------------------------------------------------
* check past interest amount from LMM.SCHEDULES.PAST
    CALL F.READ(FN.LMM.SCHEDULE.DATES,Y.LMM.REC.ID,R.LMM.SCHEDULE.DATES,F.LMM.SCHEDULE.DATES,ERR.LMM.SCHEDULE.DATES)
    IF R.LMM.SCHEDULE.DATES THEN
        CHANGE @VM TO '*' IN R.LMM.SCHEDULE.DATES  ;* Change VM to * to get the schedule date and dead/live status
        Y.SCHED.CNT          = '1'
        Y.SCHEDULE.DATES     = FIELDS(R.LMM.SCHEDULE.DATES,"*",1,1)   ;* Schedule dates
        Y.SCHEDULE.PROCESSED = FIELDS(R.LMM.SCHEDULE.DATES,"*",2,1)   ;* Schedule status
        LOOP
            REMOVE Y.DEAD.ALIVE.IND FROM Y.SCHEDULE.PROCESSED SETTING Y.DEAD.ALIVE.IND.POS
        WHILE Y.DEAD.ALIVE.IND:Y.DEAD.ALIVE.IND.POS
            Y.PAST.SCHE.DATE = Y.SCHEDULE.DATES<Y.SCHED.CNT>          ;* Schedule date
            IF Y.DEAD.ALIVE.IND EQ 'D' THEN       ;* Check if the status is 'D', otherwise skip.
                GOSUB CHECK.PAST.SCHEDULES
            END ELSE
                RETURN
            END
            Y.SCHED.CNT   += 1
        REPEAT
    END
RETURN
*-----------------------------------------------------------------------------
CHECK.PAST.SCHEDULES:
*-----------------------------------------------------------------------------
* Get past interest amount
*
    Y.PAST.SCHED.ID           = Y.LD.ID:Y.PAST.SCHE.DATE:"00"         ;* Form LMM.SCHEDULES.PAST id
    CALL F.READ(FN.LMM.SCHEDULES.PAST,Y.PAST.SCHED.ID,R.LMM.SCHEDULES.PAST,F.LMM.SCHEDULES.PAST,ERR.LMM.SCHEDULES.PAST)
    IF R.LMM.SCHEDULES.PAST THEN
        Y.INT.DUE.AMT         = R.LMM.SCHEDULES.PAST<LD28.INTEREST.DUE.AMT>
        Y.INT.DUE.AMT.LST<-1> = Y.INT.DUE.AMT     ;* Past interest amount
    END
RETURN
*-----------------------------------------------------------------------------
GET.FINAL.INT.VAL:
*-----------------------------------------------------------------------------
* Calcualte the total interest amount for the whole tennor
*
    Y.FUTURE.INT.AMT = R.EB.BALANCES<34>          ;* Future interest amount
    Y.ALL.INT.VAL    = Y.INT.DUE.AMT.LST:@VM:Y.FUTURE.INT.AMT          ;* Add both past & future interest amount
    Y.MAT.INT.VAL    = ''
    LOOP
        REMOVE Y.INT.VAL FROM Y.ALL.INT.VAL SETTING Y.INT.VAL.POS
    WHILE Y.INT.VAL:Y.INT.VAL.POS
        Y.DEP.INT.VAL  = ABS(Y.INT.VAL)
        Y.MAT.INT.VAL  = Y.MAT.INT.VAL + Y.DEP.INT.VAL      ;* Total interest for the whole tennor
    REPEAT
RETURN
END
