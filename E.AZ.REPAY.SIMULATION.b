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

*-----------------------------------------------------------------------------
* <Rating>-249</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.AZ.REPAY.SIMULATION(RET.ARR)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.AZ.PRODUCT.PARAMETER
    $INSERT I_F.CARD.ISSUE
    $INSERT I_F.AZ.SCHEDULES
    $INSERT I_F.COMPANY
    $INSERT I_F.CARD.TYPE
    $INSERT I_AZ.ACCOUNT.COMMON
    $INSERT I_F.EB.ACCRUAL.DATA
***********************************************************************
* 16/06/03 - BG_100004495/BG_100004510
*            This is a NOFILE enquiry routine for AZ.REPAY.SIM
*            Input to this enquiry can be CARD.NUMBER or the MAIN-AZ-CONTRACT no.
*            This enquiry gives information of the repayment schedules until all the debits are cleared.
*
* 08/07/03 - BG_100004743/BG_100004742
*            Changes done to this routine to call a generic routine to generate CC.AMT
*            & distribute it to the available sub-contracts.
*
* 09/01/04 - EN_10002139
*            Company level parameters in a MB environment.
*            Used EB.READ.PARAMETER routine to read the AZ.PRODUCT.PARAMETER
*
* 08/08/05 - CI_10033194
*            When there is no holiday record defined for a year in holiday
*            table then system hangs while running the enquiry AZ.REPAY.SIM.
*
* 21/10/05 - CI_10035892
*            Two new selection fields CUTOFF.AMOUNT and CUTOFF.DATE has been added to the enquiry.
*            We wouldn't build enquiry data beyond the CUTOFF.AMOUNT or CUTOFF.DATE.
*
* 20/06/06 - BG_100011492
*            SAR-2006-03-31-0008 - EN_10002969. Variable interest rate is allowed in Credit Card type
*            of loans. Changes are made to calculate the interest amount with the latest interest rate.
*            New selection field SHOW.RATE has been added. If this field is input as YES then the RATE in
*            the rate change dates has to be displayed.
*
* 13/10/06 - CI_10044831
*            Increased the size of INT.AMT field in ENQUIRY. AZ.REPAY.SIM should simulate the repayment till
*            the CUTOFF.AMOUNT or till the remaining amount reaches zero.
*
* 26/02/07 - CI_10047434
*            When cut off amount/ cut off date is specified, then the enquiry does not show
*            details at all as MAIN.ACCT.ID is incorrectly set..
*
* 06/01/14 - Task: 880230
*            Defect: 775201 & Ref: PACS00314973
*            A2 interest basis was added INT.BASIS field.
*
* 06/04/14 - Task: 963567
*            Ref: 847835
*            A4 interest basis was added INT.BASIS field.
*
***********************************************************************

    GOSUB INITIALISE
    GOSUB GET.SUBACC
    IF NOT(NO.SUB) THEN
        RETURN
    END
    GOSUB GET.APP.DETAILS     ;*BG_100011492 - S/E
    GOSUB GET.REPAY.INFO
    GOSUB PROCESS.REPAYMENTS

    IF INCLUDE.RATE.INFO AND VARIABLE.RATE THEN   ;*BG_100011492 -S
        GOSUB INS.RATE.CHANGE
    END   ;*BG_100011492 - E

    END.DATE = DCOUNT(REPAY.DATES, FM)
    FOR ST.DATE = 1 TO END.DATE
        MAS.ACC = MAIN.ACCT.ID
        REP.DATE = REPAY.DATES<ST.DATE>
        IF INCLUDE.RATE.INFO THEN       ;*BG_100011492 - S
            RATE = RCHG.RATES<ST.DATE>
        END         ;*BG_100011492 - E
        CHG.AMT = CHGS<ST.DATE>
        INT.AMT = CI.AMT<ST.DATE>
        PRINC.AMT = CC.AMT<ST.DATE>
        TOT.FOR.DATE = CHG.AMT + INT.AMT + PRINC.AMT
        REMAINING.PRIN = LEFT.OVER.AMT<ST.DATE>
        TOT.WITHDRAWAL = TOT.WD.AMT
        AZ.TOTAL.WITHDRAWAL = AZ.TOT.WITHDRAWAL
        GOSUB FORM.RET.ARR
    NEXT ST.DATE
    CONVERT VM TO FM IN RET.ARR
    RETURN

***********************************************************************
INITIALISE:
*---------
    MAS.ACC = ''

    RET.ARR = ''
    DE.LIM = '*'
    SUB.ACC = ''
    REQ.ARR = ''
    NO.SUB = ''
    AZ.SUB.IDS = ''
    AZ.SUB.PRINS = ''
    AZ.ORIG.PRINS = ''
    AZ.INT.RATES = ''
    AZ.GRACE.PRDS = ''
    AZ.VAL.DATES = ''
    TOT.WD.AMT  = ''
    AZ.TOT.WITHDRAWAL  = ''
    CALC.PRIN.REPAY = ''
*
    DIS.NO = ''
    DIST.GEN.CC = ''
    RD.AZ.PRIN.AMT = ''
    REGION = ''
    REP.DATE = ''
    CHG.AMT = ''
    INT.AMT = ''
    PRINC.AMT = ''
    TOT.FOR.DATE = ''
    MAIN.ACCT.ID = ''
    REPAY.DATES = ''
    CHGS = ''
    CI.AMT = ''
    CC.AMT = ''
    GRACE.PERIOD = ''
    MIN.REPAY = ''
    ISA.CARD = ''
    GEN.CC.IDS = ''
    GEN.CC.FOR.PRIN = ''
    GEN.CC.GRACE.PRD = ''
    GEN.SUB.CC = ''
    AZ.TOTAL.WITHDRAWAL = ''
    LEFT.OVER.AMT = ''
    R.AZ.ACTIVE.SUB.ACC = ''
    CUTOFF.DATE = '' ; CUTOFF.AMT = ''  ;*CI_10035892 S/E
    VARIABLE.RATE = ''        ;*BG_100011492 - S
    AZ.DD.INT.RATES = ''
    INCLUDE.RATE.INFO = ''
    Y.SR.POS = ''
* If SHOW.RATE selection field in enquiry is YES, INTEREST RATE has to be
* displayed. So if INCLUDE.RATE.INFO is 1, include the RATE in output array
    LOCATE 'SHOW.RATE' IN D.FIELDS<1> SETTING Y.SR.POS THEN
    Y.SR.VALUE = D.RANGE.AND.VALUE<Y.SR.POS>
    IF Y.SR.VALUE EQ 'YES' THEN
        INCLUDE.RATE.INFO = 1
    END
    END
    RCHG.DATES = ''
    RCHG.RATES = ''
    RATE = ''
    Y.INT.RATE = '' ;*BG_100011492 - E
    F.ACC = 'F.ACCOUNT';     FV.ACC = ''
    CALL OPF(F.ACC,FV.ACC)
    FN.AZ.ACTIVE.SUB.ACC = 'F.AZ.ACTIVE.SUB.ACC' ; FV.AZ.ACTIVE.SUB.ACC = ''
    CALL OPF(FN.AZ.ACTIVE.SUB.ACC, FV.AZ.ACTIVE.SUB.ACC)
    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT' ; FV.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,FV.AZ.ACCOUNT)
    FN.APP = "F.AZ.PRODUCT.PARAMETER" ; FV.APP = ''
    CALL OPF(FN.APP,FV.APP)
    FN.AZ.SCHEDULES = 'F.AZ.SCHEDULES' ; FV.AZ.SCHEDULES = ''
    CALL OPF(FN.AZ.SCHEDULES,FV.AZ.SCHEDULES)
    CYCLED.DATE = ''
    NEXT.REPAY.DATE = ''
    FN.CRD.ISS.AC  = 'F.CARD.ISSUE.ACCOUNT' ; FV.CRD.ISS.AC = ''
    CALL OPF(FN.CRD.ISS.AC, FV.CRD.ISS.AC)
    CRD.ISS.AC.REC = ''
    FN.CRD.ISS  = 'F.CARD.ISSUE' ; FV.CRD.ISS = ''
    CALL OPF(FN.CRD.ISS, FV.CRD.ISS)

    RETURN
*-------------------------------------------------------------------------
GET.SUBACC:
*---------
* Form the list of all the AZ-SUB-CONTRACTS list which are to be repayed.
    LOCATE 'ACCT.NO' IN D.FIELDS<1> SETTING ACC.POS THEN
    SEL.OPR = D.LOGICAL.OPERANDS<ACC.POS>
    SEL.LIST = D.RANGE.AND.VALUE<ACC.POS>
* To give error if more than one account is entered in the selection
    SEL.CNT = DCOUNT(SEL.LIST,SM)
    IF SEL.CNT > '1' THEN
        ENQ.ERROR = 'ONLY ONE ACCOUNT NUMBER CAN BE ENTERED.'
        GOSUB V$ERROR
    END
    END
    MAIN.ACCT.ID = SEL.LIST   ;* CI_100047434 S/E
* CI_10035892 S
    LOCATE 'CUTOFF.AMOUNT' IN D.FIELDS<1> SETTING AMT.POS THEN
    CUTOFF.AMT = D.RANGE.AND.VALUE<AMT.POS>
* Throw error message if more than one selection is entered.
    SEL.LIST = D.RANGE.AND.VALUE<AMT.POS>
    SEL.CNT = DCOUNT(SEL.LIST,SM)
    IF SEL.CNT > '1' THEN
        ENQ.ERROR = 'NOT MORE THAN ONE CUTOFF AMOUNT ALLOWED'
        GOSUB V$ERROR
    END
    END

    LOCATE 'CUTOFF.DATE' IN D.FIELDS<1> SETTING DATE.POS THEN
    CUTOFF.DATE = D.RANGE.AND.VALUE<DATE.POS>
* Throw error message if more than one selection is entered.
    SEL.LIST = D.RANGE.AND.VALUE<DATE.POS>
    SEL.CNT = DCOUNT(SEL.LIST,SM)
    IF SEL.CNT > '1' THEN
        ENQ.ERROR = 'NOT MORE THAN ONE CUTOFF DATE ALLOWED'
        GOSUB V$ERROR
    END
    END
* CI_10035892 E

    CALL F.READ(FN.AZ.ACTIVE.SUB.ACC,MAIN.ACCT.ID,R.AZ.ACTIVE.SUB.ACC,FV.AZ.ACTIVE.SUB.ACC,AZ.ERR)
    IF AZ.ERR THEN
        ENQ.ERROR = 'THIS ACCOUNT DOES NOT HAVE AZ SUB-CONTRACTS.'
        GOSUB V$ERROR
    END
    NO.SUB = DCOUNT(R.AZ.ACTIVE.SUB.ACC, FM)
    CALL F.READ(FN.AZ.ACCOUNT,MAIN.ACCT.ID,R.AZ.MAIN.REC,FV.AZ.ACCOUNT,AZ.ERR)
    AIO.PRODUCT = R.AZ.MAIN.REC<AZ.ALL.IN.ONE.PRODUCT>
    CALL EB.READ.PARAMETER(FN.APP,'N',MAT AZ$PARAMETER,AIO.REC,AIO.PRODUCT,FV.APP,APP.ERR)          ;* record store in dimension and dynamic array
* EN_10002139 - E
    RETURN
*-------------------------------------------------------------------------
PROCESS.REPAYMENTS:
*-----------------
    CALL AZ.GET.REGION(REGION)
    RCNT = 1
    GOSUB FOR.COMMING.REPAY.DATE        ;* For the comming repayment date(1st repayment date) details of the amounts to be payed is read from AZ.SCHEDULES, if CC not generated then it has to be generated & accounted for.
    LOOP
    WHILE TOBE.REPAYED
        * Here repayment amount(CC) & repayment dates are Formed.
        RD.CC.AMT = 0 ;        RCNT += 1
        IF NOT(REPAY.DATES<RCNT>) THEN  ;* Get next repayment date.
            CURR.REPAY.DATE = REPAY.DATES<RCNT - 1>
            GOSUB GET.NEXT.REPAY.DATE
        END
        RD.AZ.PRIN.AMT = AZ.SUB.PRINS
        * This routine will calculate CC amount as per the contract details.
        * Also as per appropriation method CC.AMT is distributed to sub-contracts.
        CALL AZ.GEN.CC.AMT(AIO.REC, RD.CC.AMT, R.AZ.MAIN.REC, AZ.SUB.PRINS, AZ.GRACE.PRDS, AZ.SUB.CC)
        * CI_10044831 - Comments
        * 1. CUTOFF.AMT IS ENTERED SAY 47000
        * System should calculate the repayment till the remaining amount(LEFT.OVER.AMT) = 47000.
        * During the next repayement LEFT.OVER.AMT is stored in TOBE.REPAYED hence
        * system should return when CUTOFF.AMT >= TOBE.REPAYED i.e (47000 >= 47000)
        IF (CUTOFF.AMT > (TOBE.REPAYED - RD.CC.AMT) AND (CUTOFF.AMT >= TOBE.REPAYED)) OR (CUTOFF.DATE < NEXT.REPAY.DATE[1,8] AND CUTOFF.DATE) OR RD.CC.AMT <= 0 THEN      ;*CI_10044831 S
            RETURN
        END         ;*CI_10044831 E
        REPAY.DATES<RCNT> = NEXT.REPAY.DATE       ;        CHGS<RCNT> += 0      ;* CHARGES
        GOSUB FORM.CC.AMT
        GOSUB FORM.CI.AMT
        IF (CUTOFF.AMT > (TOBE.REPAYED - RD.CC.AMT)) OR ((TOBE.REPAYED - RD.CC.AMT) < 0) THEN       ;*CI_10044831 S
            TOBE.REPAYED -= (TOBE.REPAYED - CUTOFF.AMT)
        END ELSE
            TOBE.REPAYED -= RD.CC.AMT
        END         ;*CI_10044831 E
        LEFT.OVER.AMT<RCNT> = TOBE.REPAYED        ;* Remaining principal amount.
    REPEAT
*

    RETURN

FORM.CC.AMT:
* CI_10044831 S -
* 1. To make LEFT.OVER.AMT = CUTOFF.AMT the remaining amount should be stored in CC.AMT = (TOBE.REPAYED - CUTOFF.AMT)
* 2. When CUTOFF.AMT is not entered system should simulate till LEFT.OVER.AMT is zero.
*    Check if (TOBE.REPAYED - RD.CC.AMT) is negative if it is then store the TOBE.REPAYED in CC.AMT
*    so that the LEFT.OVER.AMT becomes zero.
    IF (CUTOFF.AMT > (TOBE.REPAYED - RD.CC.AMT)) OR ((TOBE.REPAYED - RD.CC.AMT) < 0) THEN
        CC.AMT<RCNT> += (TOBE.REPAYED - CUTOFF.AMT)
    END ELSE
        CC.AMT<RCNT> += RD.CC.AMT       ;* PRINCIPLE AMOUNT
    END   ;*CI_10044831 E
    RETURN

FORM.CI.AMT:
* Principal amount distributed on sub-contracts is used in calculation of interest amount
* depnding on interest rate of each contract.
* Total of which gives interest amount to be repayed on all AZ sub-contracts.
    START.DATE = REPAY.DATES<RCNT - 1>
    END.DATE = REPAY.DATES<RCNT>
    IF VARIABLE.RATE THEN     ;*BG_100011492 - S
        * If BI key is attached, calculate the interest amount based on the variable rate of interest between repay dates
        GOSUB GET.RCHG.INT.AMT
        CI.AMT<RCNT> += RCHG.INT.AMT
    END ELSE        ;*BG_100011492 - E
        INT.RATES = LOWER(LOWER(AZ.INT.RATES))
        AZ.PRIN.AMT = LOWER(LOWER(RD.AZ.PRIN.AMT))
        GOSUB GET.INT.AMOUNT
        IF INCLUDE.RATE.INFO THEN       ;*BG_100011492 - S
            RCHG.DATES<-1> = END.DATE
            RCHG.RATES<-1> = INT.FIXED.RATE
        END         ;*BG_100011492 - E
        CI.AMT<RCNT> += SUM(INTEREST.AMOUNT)      ;* INTEREST AMOUNT.
    END   ;*BG_100011492 - S/E
    RETURN
*-------------------------------------------------------------------------
GET.REPAY.INFO:
*--------------
*
* Form the AZ-SUB-CONTRACT details in a array so the reading of AZ-SUB-CONTRACT is done only once for performance reasons...
    FOR WD.NO = 1 TO NO.SUB
        AZ.SUB.ACC = R.AZ.ACTIVE.SUB.ACC<WD.NO>
        CALL F.READ(FN.AZ.ACCOUNT,AZ.SUB.ACC,R.AZ.SUB.REC,FV.AZ.ACCOUNT,AZ.ERR)
        AZ.SUB.IDS<WD.NO> = AZ.SUB.ACC
        AZ.SUB.PRINS<WD.NO> = R.AZ.SUB.REC<AZ.PRINCIPAL>
        AZ.ORIG.PRINS<WD.NO> = R.AZ.SUB.REC<AZ.ORIG.PRINCIPAL>
        AZ.INT.RATES<WD.NO> = R.AZ.SUB.REC<AZ.INTEREST.RATE>
        * If DD.INT.RATE is given while draw down, that is being used for interest calculations for that sub account   ;*BG_100011492 - S
        AZ.DD.INT.RATES<WD.NO> = R.AZ.SUB.REC<AZ.DD.INT.RATE>         ;*BG_100011492 - E
        AZ.GRACE.PRDS<WD.NO> = R.AZ.SUB.REC<AZ.CC.PR.GRACE.PERIOD>
        AZ.VAL.DATES<WD.NO> = R.AZ.SUB.REC<AZ.VALUE.DATE>
        TOT.WD.AMT += R.AZ.SUB.REC<AZ.PRINCIPAL>
        AZ.TOT.WITHDRAWAL += R.AZ.SUB.REC<AZ.ORIG.PRINCIPAL>
    NEXT WD.NO
    TOBE.REPAYED = TOT.WD.AMT
    SAVE.AZ.GRACE.PRDS = AZ.GRACE.PRDS
    AZ.SUB.ACC = ''
    R.AZ.SUB.REC = ''
*
* Get the repayment & billing details from the CARD.ISSUE application.
    CALL AZ.GET.CARD.REPAYMENT.DATE(MAIN.ACCT.ID,REPAY.REC)
    CALL F.READ(FN.CRD.ISS.AC, MAIN.ACCT.ID, CARD.ACCT.REC, FV.CRD.ISS.AC, C.ERR)
    CARD.ID = CARD.ACCT.REC<1>
    REPAY.DATE = REPAY.REC<CARD.IS.REPAY.DATE>[1,8]
    REPAY.FQCY = REPAY.REC<CARD.IS.REPAY.DATE>[9, LEN(REPAY.REC<CARD.IS.REPAY.DATE>)]
    BILL.CLOSE.DATE  = REPAY.REC<CARD.IS.BILLING.CLOSE>[1,8]
    LAST.BILL.CLOSE = REPAY.REC<CARD.IS.LST.BILLING.CLOSE>[1,8]

    RETURN
*-------------------------------------------------------------------------
GET.NEXT.REPAY.DATE:
*------------------
* Arrive at next repayment date from the frequency mentioned in CARD.ISSUE record.
    SAVE.COMI = COMI
    COMI = CURR.REPAY.DATE:REPAY.FQCY
    CALL CFQ
    NEXT.REPAY.DATE = COMI
    COMI = SAVE.COMI

    CYCLED.DATE = NEXT.REPAY.DATE
    GOSUB CHECK.FOR.HOLIDAY
    NEXT.REPAY.DATE = CYCLED.DATE[1,8]

    RETURN
*---------------------------------------------------------------------------
CHECK.FOR.HOLIDAY:
*----------------
    REGION.CODE = ''
    COUNTRY.CD = ''
    CARD.TYPE.ID = FIELD(CARD.ID,'.',1)
    CALL DBR("CARD.TYPE":FM: CARD.TYPE.FORWARD.BACKWARD,CARD.TYPE.ID,FWD.BWK.IND)
    DAYTYPE = ''
    CYCLED.DATE.ONLY = CYCLED.DATE[1,8]
    COUNTRY.CD = ID.COMPANY

    LOCAL.COUNTRY = R.COMPANY(EB.COM.LOCAL.COUNTRY)
    LOCAL.REGION = R.COMPANY(EB.COM.LOCAL.REGION)
    IF LOCAL.REGION = '' THEN
        LOCAL.REGION = '00'
    END
    REGION.CODE = LOCAL.COUNTRY:LOCAL.REGION

    CALL AWD(REGION.CODE,CYCLED.DATE.ONLY,DAYTYPE)

    IF DAYTYPE EQ 'W' OR FWD.BWK.IND[1,1] = '4' OR FWD.BWK.IND[1,1] EQ '' THEN
        RETURN
    END ELSE
        BEGIN CASE
            CASE FWD.BWK.IND[1,1] = '1'
                CAL.TYPE = 'S'
                FOR.BACK.IND = 'F'
                DISPLACEMENT= ''
            CASE FWD.BWK.IND[1,1] = '2'
                CAL.TYPE = 'S'
                FOR.BACK.IND = 'B'
                DISPLACEMENT= ''
            CASE FWD.BWK.IND[1,1] = '3'
                FOR.BACK.IND = 'F'
                CAL.TYPE = 'D'
                DISPLACEMENT = '0M'
        END CASE
        START.DATE = CYCLED.DATE.ONLY
        SIGN = ''
        COUNTRY.CODE = COUNTRY.CD
        REGION.CD = ''
        RETURN.DATE = ''
        RETURN.CODE = ''
        RETURN.DISPLACEMENT = ''
        CALL WORKING.DAY(CAL.TYPE, START.DATE, SIGN, DISPLACEMENT, FOR.BACK.IND, COUNTRY.CODE, REGION.CD, RETURN.DATE, RETURN.CODE,RETURN.DISPLACEMENT)
        IF RETURN.CODE EQ 'ERR' THEN    ;* CI_10033194 - S
            IF ETEXT THEN
                ENQ.ERROR = ETEXT
            END
            GOSUB V$ERROR
        END ELSE    ;* CI_10033194 - E
            CYCLED.DATE[1,8] = RETURN.DATE
        END         ;* CI_10033194 - S/E
    END

    RETURN
*-------------------------------------------------------------------------
FOR.COMMING.REPAY.DATE:
*---------------------
* For the comming repay date information of repayment is formed from the AZ.SCHEDULES,
* if billing close has not happened then CC is generated. CC is not to be generated for New withdrawals, this is included in the repayment date.
    REPAY.DATES<RCNT> = REPAY.DATE
    FOR WD.NO = 1 TO NO.SUB
        SUB.CC.AMT = 0
        SUB.CI.AMT = 0
        SUB.CHGS = 0
        *
        CALL F.READ(FN.AZ.SCHEDULES, AZ.SUB.IDS<WD.NO>, AZ.SCH.REC, FV.AZ.SCHEDULES, SCH.ERR)
        ALL.DATES = RAISE(AZ.SCH.REC<AZ.SLS.DATE>)
        LOCATE REPAY.DATE IN ALL.DATES<1> SETTING C.POS ELSE
        C.POS = ''
    END
    IF NOT(C.POS) THEN
        CI.AMT<RCNT> += 0
        CC.AMT<RCNT> += 0
        CHGS<RCNT> += 0
        CONTINUE
    END
    SUB.VALUE.DATE = AZ.VAL.DATES<WD.NO>
    SUB.CC.AMT = AZ.SCH.REC<AZ.SLS.TYPE.CC, C.POS>
    IF NOT(SUB.CC.AMT) THEN
        IF REPAY.DATE GT BILL.CLOSE.DATE THEN
            * Here CC is not generated so we have to generate for the REPAYMENT DATE.
            SUB.CI.AMT = AZ.SCH.REC<AZ.SLS.TYPE.CI, C.POS>
            SUB.CHGS = AZ.SCH.REC<AZ.SLS.TYPE.C, C.POS>
            DIST.GEN.CC<-1> = WD.NO
        END ELSE
            * This is a new withdrawal done after BILL.CLOSE so no CC for comming REPAY.DATE
            CI.AMT<RCNT + 1> += AZ.SCH.REC<AZ.SLS.TYPE.CI, C.POS>
            CHGS<RCNT + 1> += AZ.SCH.REC<AZ.SLS.TYPE.C, C.POS>
        END
        *CI_10044831 S
    END ELSE
        * Billing has happened.
        SUB.CI.AMT = AZ.SCH.REC<AZ.SLS.TYPE.CI, C.POS>
        SUB.CHGS = AZ.SCH.REC<AZ.SLS.TYPE.C, C.POS>
        *CI_10044831 E
    END
    CC.AMT<RCNT> += SUB.CC.AMT
    CI.AMT<RCNT> += SUB.CI.AMT
    CHGS<RCNT> += SUB.CHGS
    NEXT WD.NO
******
    RD.CC.AMT = 0
    DIS.NO = DCOUNT(DIST.GEN.CC, FM)
    FOR DIS.SUB.NO = 1 TO DIS.NO
        WD.NO = DIST.GEN.CC<DIS.SUB.NO>
        GEN.CC.IDS<DIS.SUB.NO> = AZ.SUB.IDS<WD.NO>
        GEN.CC.FOR.PRIN<DIS.SUB.NO> = AZ.SUB.PRINS<WD.NO>
        GEN.CC.GRACE.PRD<DIS.SUB.NO> = AZ.GRACE.PRDS<WD.NO>
    NEXT DIS.SUB.NO
    IF DIS.NO THEN  ;*BG_100004742 - S/E
        CALL AZ.GEN.CC.AMT(AIO.REC, RD.CC.AMT, R.AZ.MAIN.REC, GEN.CC.FOR.PRIN, GEN.CC.GRACE.PRD, GEN.SUB.CC)
    END
    CC.AMT<RCNT> += RD.CC.AMT
    FOR DIS.SUB.NO = 1 TO DIS.NO
        WD.NO = DIST.GEN.CC<DIS.SUB.NO>
        AZ.SUB.IDS<WD.NO> = GEN.CC.IDS<DIS.SUB.NO>
        AZ.SUB.PRINS<WD.NO> = GEN.CC.FOR.PRIN<DIS.SUB.NO>
        AZ.GRACE.PRDS<WD.NO> = GEN.CC.GRACE.PRD<DIS.SUB.NO>
    NEXT DIS.SUB.NO
*
    TOBE.REPAYED -= CC.AMT<RCNT>
    LEFT.OVER.AMT<RCNT> = TOBE.REPAYED
*
    IF INCLUDE.RATE.INFO THEN ;*BG_100011492 - S
        * Here, calculate the interest rate for the comming repay date
        RCHG.DATES<-1> = REPAY.DATE
        IF VARIABLE.RATE THEN
            CALL EB.CALC.INTEREST.RATE("LOAN","",R.AZ.MAIN.REC<AZ.CURRENCY>,'','',RATE.KEY,RATE.SPREAD,RATE.OPERAND,RATE.PERCENT,INT.FIXED.RATE,REPAY.DATE,'',Y.INT.RATE)
            RCHG.RATES<-1> = Y.INT.RATE
        END ELSE
            RCHG.RATES<-1> = INT.FIXED.RATE
        END
    END   ;*BG_100011492 - E

    RETURN
*-------------------------------------------------------------------------
GET.INT.AMOUNT:
*--------------
* Get  the interest amount .
    UNROUND.INT.AMT = ""
    ROUND.TYPE = 1
    INTEREST.AMOUNT = ""
    ACCR.DAYS = 0
    INT.BASIS = TRIM(AIO.REC<AZ.APP.INT.BASIS>[1,2])
    CURRENCY = R.AZ.MAIN.REC<AZ.CURRENCY>
    IF INT.BASIS = '' THEN
        INT.BASIS = 'INTEREST.DAY.BASIS'
        CALL UPD.CCY(CURRENCY,INT.BASIS)
    END

    INT.BASIS.DETAILS = INT.BASIS       ;*New variable to pass Basis to EB.INTEREST.CALC
    IF INT.BASIS EQ "A4" THEN ;*Specific only for A4 Basis
        ** Build Calc Period to pass
        CALC.PERIOD<EB.ACD.ACCR.START> = START.DATE         ;*Pass current period start
        CALC.PERIOD<EB.ACD.ACCR.END> = END.DATE   ;*Pass current period end
        INT.BASIS.DETAILS<6> = LOWER(CALC.PERIOD) ;*Lower the Calc Period
    END

    CALL EB.INTEREST.CALC(START.DATE, END.DATE,INT.RATES,AZ.PRIN.AMT,UNROUND.INT.AMT,ACCR.DAYS,INT.BASIS.DETAILS,CURRENCY,INTEREST.AMOUNT,ROUND.TYPE,'')
    INTEREST.AMOUNT = RAISE(INTEREST.AMOUNT)
    RETURN
*-------------------------------------------------------------------------
FORM.RET.ARR:
*-----------
    REQ.ARR = ''
    REQ.ARR = MAS.ACC
    REQ.ARR := DE.LIM:REP.DATE
    IF INCLUDE.RATE.INFO THEN ;*BG_100011492 - S
        * If SHOW.RATE is YES, include the rates otherwise insert null in the outgoing array
        REQ.ARR := DE.LIM:RATE
    END ELSE
        REQ.ARR := DE.LIM:''
    END   ;*BG_100011492 - E
    REQ.ARR := DE.LIM:CHG.AMT
    REQ.ARR := DE.LIM:INT.AMT
    REQ.ARR := DE.LIM:PRINC.AMT
    REQ.ARR := DE.LIM:TOT.FOR.DATE
    REQ.ARR := DE.LIM:TOT.WITHDRAWAL
    REQ.ARR := DE.LIM:AZ.TOTAL.WITHDRAWAL
    REQ.ARR := DE.LIM:REMAINING.PRIN
*
    RET.ARR<1,-1> = REQ.ARR

    RETURN
*-------------------------------------------------------------------------
*BG_100011492 - S
GET.APP.DETAILS:
*--------------
    RATE.KEY = AIO.REC<AZ.APP.RATE.KEY>
    RATE.SPREAD = AIO.REC<AZ.APP.RATE.SPREAD>
    RATE.OPERAND = AIO.REC<AZ.APP.RATE.OPERAND>
    RATE.PERCENT = AIO.REC<AZ.APP.RATE.PERCENT>
    INT.FIXED.RATE = AIO.REC<AZ.APP.INT.FIXED.RATE>

    IF RATE.KEY NE '' THEN
        VARIABLE.RATE = 1
    END

    RETURN
*-------------------------------------------------------------------------
GET.RCHG.INT.AMT:
*---------------
* Since BI key is attached, interest amount has to be calculated on the variable rate of interest. Here the START.DATE is the
* current repay date and END.DATE is the next repay date. Between these two dates, all rate change dates are calculated. For
* every rate change, start date and end date are identified along with the variable interest rate. Then, for every sub account,
* the corresponding rate either variable rate or DD.INT.RATE is used to calculate interest amount. Sum of all interest amounts
* of all sub accounts is returned to update the CI for the corresponding repay date.
    FLOAT.CCY = R.AZ.MAIN.REC<AZ.CURRENCY>
    FLOAT.DATES = ''
    FLOAT.RATES = ''
    INTEREST.DATES = ''
    INTEREST.RATES = ''
    NEW.START.DATE = ''
    NEW.END.DATE = ''
    TEMP.RATES = ''
    Y.END.DATE.POS = ''
    Y.RCHG.END.DATE = ''
    Y.INT.RATE = ''
    Y.DATE.CNT = ''
    Y.RATE.CNT = ''
    Y.SUB.CNT = ''
    Y.FLOAT.CNT = ''
    RCHG.INT.AMT = 0
    CALL EB.GET.FLOATING.RATE.CHANGES(FLOAT.CCY,RATE.KEY,START.DATE,FLOAT.DATES,FLOAT.RATES)
    LOCATE START.DATE IN FLOAT.DATES<1,1> SETTING Y.BI.TODAY ELSE
    CALL EB.CALC.INTEREST.RATE("LOAN","",FLOAT.CCY,'','',RATE.KEY,RATE.SPREAD,RATE.OPERAND,RATE.PERCENT,INT.FIXED.RATE,START.DATE,'',Y.INT.RATE)
    INTEREST.DATES<-1> = START.DATE
    INTEREST.RATES<-1> = Y.INT.RATE
    END
    Y.FLOAT.CNT = DCOUNT(FLOAT.DATES,VM)
    FOR Y.DATE.CNT = Y.FLOAT.CNT TO 1 STEP -1
        IF FLOAT.DATES<1,Y.DATE.CNT> LT END.DATE THEN
            INTEREST.DATES<-1> = FLOAT.DATES<1,Y.DATE.CNT>
            CALL EB.CALC.INTEREST.RATE("LOAN","",FLOAT.CCY,'','',RATE.KEY,RATE.SPREAD,RATE.OPERAND,RATE.PERCENT,INT.FIXED.RATE,FLOAT.DATES<1,Y.DATE.CNT>,'',Y.INT.RATE)
            INTEREST.RATES<-1> = Y.INT.RATE
        END
    NEXT Y.DATE.CNT
    INTEREST.DATES<-1> = END.DATE
* INTEREST.DATES holds the dates, between them there is a rate change exists. INTEREST.RATES holds the corresponding rates between two dates
    GOSUB CALC.RCHG.INT.AMOUNT

    RETURN
*-------------------------------------------------------------------------
CALC.RCHG.INT.AMOUNT:
*-------------------
    Y.DATE.CNT = COUNT(INTEREST.DATES,FM)
    SAVE.START.DATE = START.DATE
    SAVE.END.DATE = END.DATE
    NEW.END.DATE = START.DATE
    FOR Y.RATE.CNT = 1 TO Y.DATE.CNT
        NEW.START.DATE = NEW.END.DATE
        NEW.END.DATE = INTEREST.DATES<Y.RATE.CNT + 1>
        Y.INT.RATE = INTEREST.RATES<Y.RATE.CNT>
        IF INCLUDE.RATE.INFO THEN
            RCHG.DATES<-1> = NEW.END.DATE
            RCHG.RATES<-1> = Y.INT.RATE
        END
        FOR Y.SUB.CNT = 1 TO NO.SUB
            IF AZ.DD.INT.RATES<Y.SUB.CNT> NE '' THEN
                * If DD.INT.RATE presents for a sub account, that has been used from AZ.DD.INT.RATES
                TEMP.RATES<Y.SUB.CNT> = AZ.DD.INT.RATES<Y.SUB.CNT>
            END ELSE
                TEMP.RATES<Y.SUB.CNT> = Y.INT.RATE
            END
        NEXT
        START.DATE = NEW.START.DATE
        END.DATE = NEW.END.DATE
        INT.RATES = LOWER(LOWER(TEMP.RATES))
        AZ.PRIN.AMT = LOWER(LOWER(RD.AZ.PRIN.AMT))
        GOSUB GET.INT.AMOUNT
        RCHG.INT.AMT += SUM(INTEREST.AMOUNT)
    NEXT Y.RATE.CNT
    START.DATE = SAVE.START.DATE
    END.DATE = SAVE.END.DATE

    RETURN
*-------------------------------------------------------------------------
INS.RATE.CHANGE:
*--------------
* Insert null to other details for a non repay date for wich there is
* a rate change exists and that has to be shown in output.
    Y.RCHG.CNT = DCOUNT(RCHG.DATES,FM)
    LOOP
        REMOVE RCHG.DATE FROM RCHG.DATES SETTING Y.RCHG.DLIM
    WHILE RCHG.DATE:Y.RCHG.DLIM
        LOCATE RCHG.DATE IN REPAY.DATES BY 'AR' SETTING RCHG.POS ELSE
        INS RCHG.DATE BEFORE REPAY.DATES<RCHG.POS>
        INS '' BEFORE CHGS<RCHG.POS>
        INS '' BEFORE CI.AMT<RCHG.POS>
        INS '' BEFORE CC.AMT<RCHG.POS>
        INS '' BEFORE LEFT.OVER.AMT<RCHG.POS>
    END
    REPEAT
    RETURN
*-------------------------------------------------------------------------
*BG_100011492 - E
V$ERROR:
    RETURN TO V$ERROR
    RETURN
*-------------------------------------------------------------------------
    END
