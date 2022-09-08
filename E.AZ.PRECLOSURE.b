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
* <Rating>-137</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.AZ.PRECLOSURE(E.ARRAY)

****************************************************************************************************
* MODIFICATIONS:
* 24/08/05 - CI_10033798
*            When reduce limit is set to NO then enquiry shows wrong preclosure information.
*
* 07/10/05 - CI_10035441
*            Interest component updated wrongly in the enquiry AZ.PRECLOSURE.
*
* 03/02/06 - CI_10038593
*            Change the position of error message mulitvalue in RETURN.AMOUNT variable
*
* 05/10/06 - CI_10044590
*            The accrued interest has been wrongly calculated till today instead of until previous day. So, before
*            calling AZ.DEPOSIT.CAP, AZ$PRECLOSE.FLAG has been set to exclude today for capitalisation.
*
* 20/11/06 - CI_10045435
*            Checking for PD.INSTALLED before calling PD in the routines.
*
* 07/12/06 - CI_10045957
*            Check if PD is installed evenif PD.LINK.TO.AZ is set to YES.
*
* 22/05/07 - CI_10049224
*            Modify this routine for supporting savings-plan and multi deposits.
*            Now this enquiry is not supporting for credit card type of contracts.
*
* 14/09/07 - CI_10051364
*             AZ$PRECLOSE.FLAG is reinitialised back for both loans & deposits.
*
* 25/12/07 - CI_10053088
*              TEXT & ETEXT  & Some common variables are assigned to "" ,if this enquiry is launched in the same session after
*              displaying the error msg from AZ template.
*
* 26/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
****************************************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AZ.PRODUCT.PARAMETER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.PD.PAYMENT.DUE
    $INSERT I_F.AZ.OVERDUES
    $INSERT I_F.PD.AMOUNT.TYPE
    $INSERT I_F.CURRENCY
    $INSERT I_F.AZ.SCHEDULES
    $INSERT I_F.FT.CHARGE.TYPE
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_AZ.ACCOUNT.COMMON         ;*CI_10044590 - S/E
    $INSERT I_F.COMPANY       ;*CI_10045435-S/E
    $INSERT I_F.ACCOUNT
    $INSERT I_AccountService_WorkingBalance

    GOSUB INITIALISE
    GOSUB GET.SELECTION

    IF ACCT.ID THEN
        GOSUB OPEN.FILES
        GOSUB CHECK.PRODUCT.PARAMETER
    END
*
    RETURN
*
INITIALISE:
*==========
    CH.FLAG = '' ; CACHE.SAVE = '' ; ACCT.ID = ''
    AZ.REC = '' ; AZ.ERR = '' ; CCY.REC = '' ; CCY.ERR = ''
    PARM.REC = '' ; PARM.ERR = '' ; ENTRY.REC = ''
    SUB.ENTRY.REC = '' ; RETURN.AMOUNT = '' ; ACCT.DET = ''
    INT.AMT = '' ; ACCR.INT.AMT = '' ; T.DATA = ''
    TOT.LCY.AMT = '' ; TOT.FCY.AMT = '' ; CH.CNT = ''
    NXT.CH = '' ; CHG.CODE = '' ; CHARGES.AMT = ''
    CHG.AMT = '' ; SCHD.REC = '' ; SCHD.ERR = '' ; SCHD.POS = ''
    CNT.CHG = '' ; CH.REC = '' ; CH.ERR = '' ; CH.DESC = ''
    E.ARRAY = '' ; PD.REC = '' ; PD.ERR = '' ; PD.FLAG = ''
    TOTAL.PD.AMT = '' ; OVERDUE.ID = '' ; CNT.VM = ''
    NXT.VM = '' ; PR.AMT = '' ; IN.AMT = '' ; CH.AMT = ''
    TX.AMT = '' ; OT.AMT = '' ; TYPE.REC = '' ; TYPE.ERR = ''
    CURR.INT.AMOUNT = '' ; IRA.AMOUNT = '' ; TOTAL.REPAY.AMT = ''
    CONT.ID = '' ; CH.FLAG = '' ; OD.POS = '' ; TEXT1 = ''
    TEXT2 = '' ; AZ.PD.VALUE = '' ; AZ.VALUE = '' ; COMP.ARRAY = ''
    CNT.OD.VM = '' ; NXT.OD.VM = '' ; TOTAL.PR.AMT = '' ; TOTAL.IN.AMT = ''
    TOTAL.CH.AMT = '' ; TOTAL.OTHR.AMT = ''
    PD.ID = ''      ;* CI_10033798 - S
    B.ERR.MSG = ''  ;* CI_10033798 - E
    TOT.OUTSTANDING = ''
    TOT.INT.AMT = ''
    ETEXT = "" ; E = "" ; TEXT = ""  ; END.ERROR = "" ; AZ$INITIALISE = ""      ;* CI_10053088 S/E
*
    RETURN
*
GET.SELECTION:
*=============
    LOCATE 'ACCOUNT.NO' IN D.FIELDS<1> SETTING D.POS THEN
        ACCT.ID = D.RANGE.AND.VALUE<D.POS>
    END
*
    RETURN
*
OPEN.FILES:
*==========
    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT'
    FP.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,FP.AZ.ACCOUNT)

    FN.ACCOUNT = 'F.ACCOUNT'
    FP.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,FP.ACCOUNT)

    FN.AZ.ACTIVE.SUB.ACC = 'F.AZ.ACTIVE.SUB.ACC'
    FP.AZ.ACTIVE.SUB.ACC = ''
    CALL OPF(FN.AZ.ACTIVE.SUB.ACC,FP.AZ.ACTIVE.SUB.ACC)

    FN.AZ.PRODUCT.PARAMETER = 'F.AZ.PRODUCT.PARAMETER'
    FP.AZ.PRODUCT.PARAMETER = ''
    CALL OPF(FN.AZ.PRODUCT.PARAMETER,FP.AZ.PRODUCT.PARAMETER)

    LOCATE 'PD' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PD.INSTALLED ELSE          ;*CI_10045435-S
        PD.INSTALLED = ''
    END
    IF PD.INSTALLED THEN
        FN.PD.PAYMENT.DUE = 'F.PD.PAYMENT.DUE'
        FP.PD.PAYMENT.DUE = ''
        CALL OPF(FN.PD.PAYMENT.DUE,FP.PD.PAYMENT.DUE)

        FN.PD.AMOUNT.TYPE = 'F.PD.AMOUNT.TYPE'
        FP.PD.AMOUNT.TYPE = ''
        CALL OPF(FN.PD.AMOUNT.TYPE,FP.PD.AMOUNT.TYPE)
    END   ;*CI_10045435-E

    FN.AZ.OVERDUES = 'F.AZ.OVERDUES'
    FP.AZ.OVERDUES = ''
    CALL OPF(FN.AZ.OVERDUES,FP.AZ.OVERDUES)



    FN.CURRENCY = 'F.CURRENCY'
    FP.CURRENCY = ''
    CALL OPF(FN.CURRENCY,FP.CURRENCY)

    FN.AZ.SCHEDULES = 'F.AZ.SCHEDULES'
    FP.AZ.SCHEDULES = ''
    CALL OPF(FN.AZ.SCHEDULES,FP.AZ.SCHEDULES)

    FN.FT.CHARGE.TYPE = 'F.FT.CHARGE.TYPE'
    FP.FT.CHARGE.TYPE = ''
    CALL OPF(FN.FT.CHARGE.TYPE,FP.FT.CHARGE.TYPE)

    FN.FT.COMMISSION.TYPE = 'F.FT.COMMISSION.TYPE'
    FP.FT.COMMISSION.TYPE = ''
    CALL OPF(FN.FT.COMMISSION.TYPE,FP.FT.COMMISSION.TYPE)
*
    RETURN
*
CHECK.PRODUCT.PARAMETER:
*=======================
    CALL F.READ(FN.AZ.ACCOUNT,ACCT.ID,AZ.REC,FP.AZ.ACCOUNT,AZ.ERR)
    IF AZ.ERR THEN
        RETURN
    END

    IF AZ.REC<AZ.REPAYMENT.TYPE> EQ 'CREDIT-CARD' THEN      ;* This enquiry is not supporting for credit card type of contracts
        GOSUB EXIT.CREDIT.CARD
        RETURN
    END

    CALL F.READ(FN.CURRENCY,AZ.REC<AZ.CURRENCY>,CCY.REC,FP.CURRENCY,CCY.ERR)
    CALL F.READ(FN.AZ.PRODUCT.PARAMETER,AZ.REC<AZ.ALL.IN.ONE.PRODUCT>,PARM.REC,FP.AZ.PRODUCT.PARAMETER,PARM.ERR)

    IF PARM.REC<AZ.APP.LOAN.DEPOSIT> EQ 'LOAN' THEN
        CALL AZ.LOAN.PRE.CLOSURE(ACCT.ID,'1*ENQ',ENTRY.REC,SUB.ENTRY.REC,RETURN.AMOUNT,'VAL')       ;* CI_10033798 - S/E

        COMP.ARRAY = RETURN.AMOUNT<11>
        VALUE.ARRAY = RETURN.AMOUNT<12>
        B.ERR.MSG = RETURN.AMOUNT<14>   ;* CI_10033798 - S/E // CI_10038593 - S/E Change the multivalue number

        IF PARM.REC<AZ.APP.PD.LINK.TO.AZ> = 'YES' AND PD.INSTALLED THEN         ;*CI_10045957 S/E
            GOSUB GET.PD.DETAILS
        END ELSE
            GOSUB GET.OVERDUES
        END

        GOSUB FORMAT.LN.ARRAY
    END ELSE

        CALL F.READ(FN.AZ.ACTIVE.SUB.ACC,ACCT.ID,R.AZ.ACTIVE.SUB.ACC,FP.AZ.ACTIVE.SUB.ACC,AZ.ERR)
        IF NOT(R.AZ.ACTIVE.SUB.ACC) THEN          ;* Getting Sub account lists
            R.AZ.ACTIVE.SUB.ACC = ACCT.ID
        END

        CACHE.SAVE = CACHE.OFF
        CACHE.OFF = 0
        AZ$PRECLOSE.FLAG = 'Y'          ;*CI_10044590 - S/E
        EARLY.RED.MARGIN = PARM.REC<AZ.APP.EARLY.RED.MARGIN>
        * Looping the sub accounts one by one
        LOOP
            REMOVE ACCT.DET FROM R.AZ.ACTIVE.SUB.ACC SETTING S.POS
        WHILE ACCT.DET:S.POS
            IF ACCT.DET = ACCT.ID THEN
                VAL.DATE = AZ.REC<AZ.VALUE.DATE>
            END ELSE
                CALL F.READ(FN.AZ.ACCOUNT,ACCT.DET,R.AZ.ACCOUNT,FP.AZ.ACCOUNT,AZ.ERR)
                VAL.DATE = R.AZ.ACCOUNT<AZ.VALUE.DATE>
            END

            *get balance using service routine.
            accountKey = ACCT.DET
            response.Details = ''
            workingBal = ''
            CALL AccountService.getWorkingBalance(accountKey, workingBal, response.Details)
            *
            TOT.OUTSTANDING += workingBal<Balance.workingBal>
            INT.AMT = ''
            ACCR.INT.AMT = ''
            CALL AZ.DEPOSIT.CAP(ACCT.DET,VAL.DATE,EARLY.RED.MARGIN,INT.AMT,'ENQ',ACCR.INT.AMT,'')
            INT.AMT = INT.AMT + ACCR.INT.AMT      ;*CI_10035441 S/E  ;*Update the accr.amt along with the corrected interest amount...
            TOT.INT.AMT +=  INT.AMT
        REPEAT

        CACHE.OFF = CACHE.SAVE

        GOSUB FORMAT.DEP.ARRAY
        GOSUB GET.CHARGES
    END

    AZ$PRECLOSE.FLAG = ''     ;* Reset the pre close flag (Common variable)  ;* CI_10051364 S/E

*
    RETURN
*
GET.CHARGES:
*===========
    T.DATA = PARM.REC<AZ.APP.PRE.CLOSURE.FEE>

    CALL CALCULATE.CHARGE(AZ.REC<AZ.CUSTOMER>,AZ.REC<AZ.PRINCIPAL>,AZ.REC<AZ.CURRENCY>,'1','','','',T.DATA,'',TOT.LCY.AMT,TOT.FCY.AMT)

    CNT.CH = DCOUNT(T.DATA<1>,VM)

    FOR NXT.CH = 1 TO CNT.CH
        CHG.CODE = T.DATA<1,NXT.CH>
        CHARGES.AMT += T.DATA<4,NXT.CH>
        CHG.AMT = T.DATA<4,NXT.CH>

        GOSUB FORMAT.CH.ARRAY
    NEXT NXT.CH

    CALL F.READ(FN.AZ.SCHEDULES,ACCT.ID,SCHD.REC,FP.AZ.SCHEDULES,SCHD.ERR)

    LOCATE TODAY IN SCHD.REC<AZ.SLS.DATE,1> SETTING SCHD.POS THEN
        CNT.CHG = DCOUNT(SCHD.REC<AZ.SLS.CHG.CODE,SCHD.POS>,@SM)

        FOR NXT.CHG = 1 TO CNT.CHG
            IF SCHD.REC<AZ.SLS.CHG.AMT,SCHD.POS,NXT.CHG> NE '' AND SCHD.REC<AZ.SLS.CHG.AMT,SCHD.POS,NXT.CHG> NE '0' THEN
                CHG.CODE = SCHD.REC<AZ.SLS.CHG.CODE,SCHD.POS,NXT.CHG>
                CHARGES.AMT += SCHD.REC<AZ.SLS.CHG.AMT,SCHD.POS,NXT.CHG>
                CHG.AMT = SCHD.REC<AZ.SLS.CHG.AMT,SCHD.POS,NXT.CHG>

                GOSUB FORMAT.CH.ARRAY
            END
        NEXT NXT.CHG
    END

    CH.FLAG = 'Y'
    GOSUB FORMAT.DEP.ARRAY
*
    RETURN
*
FORMAT.CH.ARRAY:
*===============
    CALL F.READ(FN.FT.CHARGE.TYPE,CHG.CODE,CH.REC,FP.FT.CHARGE.TYPE,CH.ERR)

    IF CH.ERR THEN
        CALL F.READ(FN.FT.COMMISSION.TYPE,CHG.CODE,CH.REC,FP.FT.COMMISSION.TYPE,CH.ERR)

        CH.DESC = CH.REC<FT4.SHORT.DESCR,1>
    END ELSE
        CH.DESC = CH.REC<FT5.SHORT.DESCR,1>
    END


    IF CHG.AMT NE '' THEN
        E.ARRAY<-1> = '     ':FMT(CH.DESC,"37' 'L"):' - ':FMT(CHG.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
    END
*
    RETURN
*
GET.OVERDUES:
*============
*    CALL F.READ(FN.AZ.OVERDUES,ACCT.ID,PD.REC,FP.AZ.OVERDUES,PD.ERR)

    CNT.OD.VM = DCOUNT(COMP.ARRAY,@VM)

    IF B.ERR.MSG THEN         ;* CI_10033798 - S
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = 'CAUTION : This report is notional since below warnings have to be solved first'
        FOR I = 1 TO DCOUNT(B.ERR.MSG,VM)
            E.ARRAY<-1> = 'WARNING :         ':B.ERR.MSG<1,I>
        NEXT I
    END   ;* CI_10033798 - E

    FOR NXT.OD.VM = 1 TO CNT.OD.VM

        IF NXT.OD.VM = '1' THEN
            E.ARRAY<-1> = ' '
            E.ARRAY<-1> = ' '
            E.ARRAY<-1> = 'Overdue Details'
            E.ARRAY<-1> = '==============='
            E.ARRAY<-1> = ' '
        END

        BEGIN CASE
            CASE COMP.ARRAY<1,NXT.OD.VM> = 'PR'
                TOTAL.PR.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Principal Amount                       - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            CASE COMP.ARRAY<1,NXT.OD.VM> = 'IN'
                TOTAL.IN.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Interest Amount                        - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            CASE COMP.ARRAY<1,NXT.OD.VM> = 'CH'
                TOTAL.CH.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Charge Amount                          - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            CASE COMP.ARRAY<1,NXT.OD.VM> = 'CO'
                TOTAL.CH.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Commission Amount                      - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            CASE COMP.ARRAY<1,NXT.OD.VM> = 'PE'
                TOTAL.IN.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Penalty Interest                       - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            CASE COMP.ARRAY<1,NXT.OD.VM> = 'PS'
                TOTAL.IN.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Penalty Spread                         - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            CASE OTHERWISE
                TOTAL.OTHR.AMT += VALUE.ARRAY<1,NXT.OD.VM>
                E.ARRAY<-1> = '    Other Overdue Amount                   - ':FMT(VALUE.ARRAY<1,NXT.OD.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        END CASE

        TOTAL.PD.AMT += VALUE.ARRAY<1,NXT.OD.VM>
    NEXT NXT.OD.VM

    IF TOTAL.PR.AMT THEN
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = 'Total Overdue Principal                    - ':FMT(TOTAL.PR.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = ' '
    END

    IF TOTAL.IN.AMT THEN
        E.ARRAY<-1> = 'Total Overdue Interest                     - ':FMT(TOTAL.IN.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = ' '
    END


    IF TOTAL.CH.AMT THEN
        E.ARRAY<-1> = 'Total Overdue Charges                      - ':FMT(TOTAL.CH.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = ' '
    END

    IF TOTAL.OTHR.AMT THEN
        E.ARRAY<-1> = 'Total Other Charges                        - ':FMT(TOTAL.OTHR.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = ' '
    END

    E.ARRAY<-1> = 'Total Overdue Amount                       - ':FMT(TOTAL.PD.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
    E.ARRAY<-1> = ' '

    E.ARRAY<-1> = ' '

    IF TOTAL.PD.AMT THEN
        OVERDUE.ID = ACCT.ID
    END
*
    RETURN
*
GET.PD.DETAILS:
*==============
    CALL F.READ(FN.PD.PAYMENT.DUE,'PDAZ':ACCT.ID,PD.REC,FP.PD.PAYMENT.DUE,PD.ERR)

    CNT.VM = DCOUNT(PD.REC<PD.TOT.OVRDUE.TYPE>,@VM)

    FOR NXT.VM = 1 TO CNT.VM
        IF NXT.VM = '1' THEN
            PD.FLAG = 'Y'

            E.ARRAY<-1> = ' '
            E.ARRAY<-1> = ' '
            E.ARRAY<-1> = 'Overdue Details'
            E.ARRAY<-1> = '==============='
            E.ARRAY<-1> = ' '
        END

        GOSUB CHECK.PRECLOSURE.ROUTINE

        BEGIN CASE
            CASE PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'PR'
                PR.AMT = PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>
            CASE PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'IN' OR PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'PE' OR PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'PS' OR PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'PF'
                IN.AMT += PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>
            CASE PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'CH' OR PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'CO'
                CH.AMT += PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>
            CASE PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> = 'TX'
                TX.AMT = PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>
            CASE OTHERWISE
                OT.AMT += PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>
        END CASE

        TOTAL.PD.AMT += PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>

        CALL F.READ(FN.PD.AMOUNT.TYPE,PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM>,TYPE.REC,FP.PD.AMOUNT.TYPE,TYPE.ERR)

        IF OD.POS THEN
            OD.POS = ''
            E.ARRAY<-1> = '     ':FMT(TYPE.REC<PD.AMT.TYP.DESCRIPTION>,"37' 'L"):' - ':FMT(PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>):'     ;     ':TEXT1
        END ELSE
            E.ARRAY<-1> = '     ':FMT(TYPE.REC<PD.AMT.TYP.DESCRIPTION>,"37' 'L"):' - ':FMT(PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>):'     ;     ':TEXT2
        END
    NEXT NXT.VM

    E.ARRAY<-1> = ' '

    IF PD.FLAG THEN
        PD.ID = 'PDAZ':ACCT.ID

        IF PR.AMT THEN
            E.ARRAY<-1> ='Total Overdue Principal                    - ':FMT(PR.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END

        IF IN.AMT THEN
            E.ARRAY<-1> = 'Total Overdue Interest                     - ':FMT(IN.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END

        IF CH.AMT THEN
            E.ARRAY<-1> = 'Total Overdue Charges                      - ':FMT(CH.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END

        IF TX.AMT THEN
            E.ARRAY<-1> = 'Total Overdue Tax                          - ':FMT(TX.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END

        IF OT.AMT THEN
            E.ARRAY<-1> = 'Total Overdue Other Charges                - ':FMT(OT.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END

        E.ARRAY<-1> = 'Total Overdue Amount                       - ':FMT(TOTAL.PD.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = ' '

        IF AZ.PD.VALUE THEN
            E.ARRAY<-1> = 'Total Amount to be settled through AZ      - ':FMT(AZ.PD.VALUE,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END

        IF AZ.VALUE THEN
            E.ARRAY<-1> = 'Total Amount to be settled through PD      - ':FMT(AZ.VALUE,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
            E.ARRAY<-1> = ' '
        END
    END
*
    RETURN
*
CHECK.PRECLOSURE.ROUTINE:
*========================
    TEST = PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM>
    LOCATE PD.REC<PD.TOT.OVRDUE.TYPE,NXT.VM> IN COMP.ARRAY<1,1> SETTING OD.POS THEN
        TEXT1 = 'Value can be settled through AZ'
        AZ.PD.VALUE += VALUE.ARRAY<1,OD.POS>
    END ELSE
        OD.POS = ''
        TEXT2 = 'Value can be settled through PD'
        AZ.VALUE += PD.REC<PD.TOT.OD.TYPE.AMT,NXT.VM>
    END
*
    RETURN
*
FORMAT.LN.ARRAY:
*===============
    CURR.INT.AMOUNT = RETURN.AMOUNT<6> - RETURN.AMOUNT<9>

    IF CURR.INT.AMOUNT LT '0' THEN
        CURR.INT.AMOUNT = '0'
        IRA.AMOUNT = ABS(CURR.INT.AMOUNT)
    END

    TOTAL.REPAY.AMT = RETURN.AMOUNT<3> + RETURN.AMOUNT<10> + CURR.INT.AMOUNT + TOTAL.PD.AMT

    CONT.ID = ACCT.ID

    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = 'Current Schedule Details'
    E.ARRAY<-1> = '========================'
    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = '    Principal                              - ':FMT(RETURN.AMOUNT<3>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
    E.ARRAY<-1> = '    Interest                               - ':FMT(CURR.INT.AMOUNT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)

    IF IRA.AMOUNT THEN
        E.ARRAY<-1> = '    Excess Interest Amount                 - ':FMT(IRA.AMOUNT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
    END

    IF RETURN.AMOUNT<10> THEN
        E.ARRAY<-1> = '    Charges                                - ':FMT(RETURN.AMOUNT<10>,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
    END

    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = 'Total Amount to be paid as of ':OCONV(ICONV(TODAY,'D'),'D'):'  - ':FMT(TOTAL.REPAY.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)

    E.ARRAY<1> := '*':CONT.ID:'*':PD.ID:'*':OVERDUE.ID
*
    RETURN
*
FORMAT.DEP.ARRAY:
*===============
    IF NOT(CH.FLAG) THEN
        CONT.ID = ACCT.ID

        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = 'Current Schedule Details'
        E.ARRAY<-1> = '========================'
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = '    Principal                              - ':FMT(TOT.OUTSTANDING,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = '    Interest                               - ':FMT(TOT.INT.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        E.ARRAY<-1> = ' '
    END ELSE
        IF CHARGES.AMT THEN
            E.ARRAY<-1> = ' '
            E.ARRAY<-1> = 'Total Charges                              - ':FMT(CHARGES.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)
        END

        TOTAL.REPAY.AMT = TOT.OUTSTANDING + TOT.INT.AMT - CHARGES.AMT

        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = ' '
        E.ARRAY<-1> = 'Total Amount to be paid as of ':OCONV(ICONV(TODAY,'D'),'D'):'  - ':FMT(TOTAL.REPAY.AMT,'19R,':CCY.REC<EB.CUR.NO.OF.DECIMALS>)

        E.ARRAY<1> := '*':CONT.ID
    END
*
    RETURN
*
EXIT.CREDIT.CARD:
*----------------
    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = ' '
    E.ARRAY<-1> = 'CAUTION : This enquiry is not support for credit card type contracts'

    RETURN

    END
