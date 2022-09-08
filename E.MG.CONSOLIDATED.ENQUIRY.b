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

* Version 13 26/07/01  GLOBUS Release No. G14.0.02 25/09/03
*-----------------------------------------------------------------------------
* <Rating>-71</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MG.ModelBank
    SUBROUTINE E.MG.CONSOLIDATED.ENQUIRY(TODISPLAY)
*
*  OUTPUT
*  ------
* TODISPLAY   : Contains data to display.
*
* 20/01/04 - EN_10002166
*            This routine is used for NOFILE enquiry MG.CONSOLIDATED.BALANCES
*            where the schedules of different contracts (associated) would
*            be merged into a single schedule.
*
* 14/05/04 - EN_10002260
*            Multibook Changes
*
* 08/09/04 - EN_10002338
*            Next Working day for MG schedules
*
* 29/05/08 - BG_100018583
*            reduce compiler ratings
*
*******************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MG.MORTGAGE
    $INSERT I_F.MG.PARAMETER
    $INSERT I_F.MG.BALANCES
    $INSERT I_F.MG.PAYMENT
    $INSERT I_F.MG.ADVICES
    $INSERT I_F.MG.SCHEDULES
    $INSERT I_F.MG.PAYMENT.CONTROL
    $INSERT I_MG.COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.MG.BALANCE.ENQUIRY
*********************************************************************

* SAVE and STORE the common variable values, to avoid  common variable
* to be used by some other applications, when executed under desktop.
    GOSUB INITIALISE          ;* BG_100018583 S/E
* Processing associate contracts, if the same is attached to main contract.

    ASSOC.IDS = R$MORTGAGE(MG.ASSOC.CONTRACT)
    IF ASSOC.IDS NE '' THEN
        ASS.CNT = DCOUNT(ASSOC.IDS,VM)
        FOR ASS.CT = 1 TO ASS.CNT
            R.RECORD = ''
            ID = ASSOC.IDS<1,ASS.CT>
            GOSUB BUILD.ENQUIRY.DATA
            R.RECORD.S = R.RECORD
            R.RECORD.S<500> = R.RECORD<500>
            R.RECORD.S<400> = R.RECORD<400>       ;* MG.CUSTOMER
            R.RECORD.S<401> = R.RECORD<401>       ;* MG.CURRENCY
            GOSUB BUILD.SORT.DATA
        NEXT ASS.CT
    END

    GOSUB LINK.ASSOCIATE.DATA

    MAT R$MORTGAGE = MAT SAVE.R$MORTGAGE
    MAT R$BALANCES = MAT SAVE.R$BALANCES

    CONTRACT$ID = SAVE.CONTRACT$ID

    RETURN          ;*  program return

***********************************************************************************************
INITIALISE:
    DIM SAVE.R$MORTGAGE(MG.AUDIT.DATE.TIME)
    MAT SAVE.R$MORTGAGE = MAT R$MORTGAGE
    DIM SAVE.R$BALANCES(MG.BAL.CHARGE.TAX.AMT)        ;* EN_10002338
    MAT SAVE.R$BALANCES = MAT R$BALANCES

    DIM R.WORK.BALANCES(MG.BAL.CHARGE.TAX.AMT)        ;* EN_10002338
    MAT R.WORK.BALANCES = ""
    DIM TEMP.REC(MG.BAL.CHARGE.TAX.AMT)     ;* EN_10002338
    MAT TEMP.REC = ""
    R.RECORD.MAIN = ""
    R.RECORD.FIN = ""
    ID = ""
    TODISPLAY = ""
    ASSOC.IDS = ""
    MG.PRIN.AMT = ""
    SAVE.CONTRACT$ID = CONTRACT$ID
    ID = D.RANGE.AND.VALUE<1>
    ID.MAIN = ID
    CONTRACT$ID = ID
* Processing Main contract
    GOSUB BUILD.ENQUIRY.DATA
    R.RECORD.S = R.RECORD
    R.RECORD.S<500> = R.RECORD<500>
    R.RECORD.S<400> = R.RECORD<400>     ;* MG.CUSTOMER
    R.RECORD.S<401> = R.RECORD<401>     ;* MG.CURRENCY
    GOSUB BUILD.SORT.DATA
    RETURN
*--------------------------------------------------------------------------------------------------

BUILD.SORT.DATA:
*----------------
    R.RECORD.MAIN = ''

    MG.CCY.CUSTOMER = R$MORTGAGE(MG.CUSTOMER):'*':R$MORTGAGE(MG.CURRENCY)
    LOCATE MG.CCY.CUSTOMER IN MG.CCY.CUST<1> SETTING C.POS THEN
        R.RECORD.MAIN = FIELD(R.RECORD.FIN,'~',C.POS,1)

* MG.PRINT.AMT array contains all the consolidated principal amount of the
* contract which has same ccy and customer
        MG.PRIN =  MG.PRIN.AMT<C.POS>
        MG.PRIN += R$MORTGAGE(MG.PRINCIPAL.AMOUNT)
        DEL MG.PRIN.AMT<C.POS>
        INS MG.PRIN BEFORE MG.PRIN.AMT<C.POS>
    END ELSE
        MG.CCY.CUST<-1> = MG.CCY.CUSTOMER
        MG.PRIN.AMT<-1> = R$MORTGAGE(MG.PRINCIPAL.AMOUNT)
    END
    GOSUB BUILD.SORT.DATA.1


    RETURN

***************************************************************************************
BUILD.SORT.DATA.1:
*----------------------------

* For new currency assign values to R.RECORD.MAIN

    IF R.RECORD.MAIN EQ '' THEN
        R.RECORD.MAIN<MG.BAL.PAYMENT.DATE> = R.RECORD.S<MG.BAL.PAYMENT.DATE>
        R.RECORD.MAIN<MG.BAL.REPAYMENT.AMT> = R.RECORD.S<MG.BAL.REPAYMENT.AMT>
        R.RECORD.MAIN<MG.BAL.TAX.RCVD> = R.RECORD.S<MG.BAL.TAX.RCVD>
        R.RECORD.MAIN<MG.BAL.INTEREST.RCVD> = R.RECORD.S<MG.BAL.INTEREST.RCVD>
        R.RECORD.MAIN<MG.BAL.PRINCIPAL.RCVD> = R.RECORD.S<MG.BAL.PRINCIPAL.RCVD>
        R.RECORD.MAIN<MG.BAL.DEF.INT.AMT> = R.RECORD.S<MG.BAL.DEF.INT.AMT>
        R.RECORD.MAIN<MG.BAL.DEF.TAX.AMT> = R.RECORD.S<MG.BAL.DEF.TAX.AMT>
        R.RECORD.MAIN<500> = R.RECORD.S<500>      ;* PRIN.BALANCE
        R.RECORD.MAIN<400> = R.RECORD.S<400>      ;* MG.CUSTOMER
        R.RECORD.MAIN<401> = R.RECORD.S<401>      ;* MG.CURRENCY

        IF R.RECORD.FIN EQ '' THEN
            R.RECORD.FIN = R.RECORD.MAIN
        END ELSE
            R.RECORD.FIN<-1> = '~':R.RECORD.MAIN
        END
    END ELSE

* For same currency & customer and same date, add the new values to existing R.RECORD.MAIN.

        GOSUB MG.ASSIGN.DATA  ;* BG_100018583 S/E

*  R.RECORD.FIN is the array, from which the C.POS record would be retrived to R.RECORD.MAIN and
*  modified R.RECORD.MAIN would be updated in the same C.POS position in R.RECORD.FIN

        R.RECORD.FIN = LOWER(R.RECORD.FIN)
        CONVERT '~' TO FM IN R.RECORD.FIN
        R.RECORD.MAIN = LOWER(R.RECORD.MAIN)

        DEL R.RECORD.FIN<C.POS>
        INS R.RECORD.MAIN BEFORE R.RECORD.FIN<C.POS>

        CONVERT FM TO '~' IN R.RECORD.FIN
        R.RECORD.FIN = RAISE(R.RECORD.FIN)

    END


    RETURN
*************************************************************************************************************
MG.ASSIGN.DATA:
*************
    JPAY.DATE = DCOUNT(R.RECORD.S<MG.BAL.PAYMENT.DATE>,VM)
    FOR J.PAY = 1 TO JPAY.DATE
        PAY.DATE = R.RECORD.S<MG.BAL.PAYMENT.DATE,J.PAY>
        LOCATE PAY.DATE IN R.RECORD.MAIN<MG.BAL.PAYMENT.DATE,1> BY 'AR' SETTING JPOS THEN
            R.RECORD.MAIN<MG.BAL.PAYMENT.DATE,JPOS> = R.RECORD.S<MG.BAL.PAYMENT.DATE,J.PAY>
            R.RECORD.MAIN<MG.BAL.REPAYMENT.AMT,JPOS> += R.RECORD.S<MG.BAL.REPAYMENT.AMT,J.PAY>
            R.RECORD.MAIN<MG.BAL.TAX.RCVD,JPOS> += R.RECORD.S<MG.BAL.TAX.RCVD,J.PAY>
            R.RECORD.MAIN<MG.BAL.INTEREST.RCVD,JPOS> += R.RECORD.S<MG.BAL.INTEREST.RCVD,J.PAY>
            R.RECORD.MAIN<MG.BAL.PRINCIPAL.RCVD,JPOS> += R.RECORD.S<MG.BAL.PRINCIPAL.RCVD,J.PAY>
            R.RECORD.MAIN<MG.BAL.DEF.INT.AMT,JPOS> += R.RECORD.S<MG.BAL.DEF.INT.AMT,J.PAY>
            R.RECORD.MAIN<MG.BAL.DEF.TAX.AMT,JPOS> += R.RECORD.S<MG.BAL.DEF.TAX.AMT,J.PAY>
            R.RECORD.MAIN<500,JPOS> += R.RECORD.S<500,J.PAY>          ;* PRIN.BALANCE
            R.RECORD.MAIN<400,JPOS> = R.RECORD.S<400,J.PAY> ;* MG.CUSTOMER
            R.RECORD.MAIN<401,JPOS> = R.RECORD.S<401,J.PAY> ;* MG.CURRENCY
        END ELSE
* For same currency and different date, insert the new values to existing R.RECORD.MAIN
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.PAYMENT.DATE,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.REPAYMENT.AMT,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.TAX.RCVD,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.INTEREST.RCVD,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.PRINCIPAL.RCVD,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.DEF.INT.AMT,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<MG.BAL.DEF.TAX.AMT,JPOS>
            INS '0' BEFORE R.RECORD.MAIN<500,JPOS>          ;* PRIN.BALANCE
            INS '0' BEFORE R.RECORD.MAIN<400,JPOS>          ;* MG.CUSTOMER
            INS '0' BEFORE R.RECORD.MAIN<401,JPOS>          ;* MG.CURRENCY

            R.RECORD.MAIN<MG.BAL.PAYMENT.DATE,JPOS> = R.RECORD.S<MG.BAL.PAYMENT.DATE,J.PAY>
            R.RECORD.MAIN<MG.BAL.REPAYMENT.AMT,JPOS> = R.RECORD.S<MG.BAL.REPAYMENT.AMT,J.PAY>
            R.RECORD.MAIN<MG.BAL.TAX.RCVD,JPOS> = R.RECORD.S<MG.BAL.TAX.RCVD,J.PAY>
            R.RECORD.MAIN<MG.BAL.INTEREST.RCVD,JPOS> = R.RECORD.S<MG.BAL.INTEREST.RCVD,J.PAY>
            R.RECORD.MAIN<MG.BAL.PRINCIPAL.RCVD,JPOS> = R.RECORD.S<MG.BAL.PRINCIPAL.RCVD,J.PAY>
            R.RECORD.MAIN<MG.BAL.DEF.INT.AMT,JPOS> = R.RECORD.S<MG.BAL.DEF.INT.AMT,J.PAY>
            R.RECORD.MAIN<MG.BAL.DEF.TAX.AMT,JPOS> = R.RECORD.S<MG.BAL.DEF.TAX.AMT,J.PAY>
            R.RECORD.MAIN<500,JPOS> = R.RECORD.S<500,J.PAY> ;* PRIN.BALANCE
            R.RECORD.MAIN<400,JPOS> = R.RECORD.S<400,J.PAY> ;* MG.CUSTOMER
            R.RECORD.MAIN<401,JPOS> = R.RECORD.S<401,J.PAY> ;* MG.CURRENCY

        END

    NEXT J.PAY

    RETURN
***********************************************
LINK.ASSOCIATE.DATA:
*------------------

    CNT.FM = DCOUNT(R.RECORD.FIN,'~')
    FOR FMARK = 1 TO CNT.FM
        R.RECORD.UPDATE = FIELD(R.RECORD.FIN,'~',FMARK,1)

        GOSUB UPDATE.PRIN.BAL
        CNT.VM = DCOUNT(R.RECORD.UPDATE<MG.BAL.PAYMENT.DATE>,VM)
        FOR VMARK = 1 TO CNT.VM
            TODISPLAY<-1> = ID.MAIN:"*":R.RECORD.UPDATE<400,VMARK>:"*":R.RECORD.UPDATE<401,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.PAYMENT.DATE,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.REPAYMENT.AMT,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.TAX.RCVD,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.INTEREST.RCVD,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.PRINCIPAL.RCVD,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.DEF.INT.AMT,VMARK>:"*":R.RECORD.UPDATE<MG.BAL.DEF.TAX.AMT,VMARK>:"*":R.RECORD.UPDATE<500,VMARK>:"*":MG.PRIN.AMT<FMARK>:"*":PBALANCE
        NEXT VMARK
    NEXT FMARK
    RETURN
*---------------------------------------------------------------------------------------------
* This para updates the principal balance for the contracts have same ccy and customer
UPDATE.PRIN.BAL:
*---------------
    START.BAL = MG.PRIN.AMT<FMARK>
    R.RECORD = R.RECORD.UPDATE
    R.RECORD<500> = ''
    NO.OF.RECS = DCOUNT(R.RECORD<MG.BAL.PAYMENT.DATE>,VM)
    FOR YCOUNT = 1 TO NO.OF.RECS
        PRIN.RCVD.AMT = R.RECORD<MG.BAL.PRINCIPAL.RCVD,YCOUNT>
        DEF.INT.AMT = 0
        DEF.TX.AMT = 0
        DEF.INT.AMT = R.RECORD<MG.BAL.DEF.INT.AMT,YCOUNT>
        DEF.TX.AMT = R.RECORD<MG.BAL.DEF.TAX.AMT,YCOUNT>
        PBALANCE = START.BAL - PRIN.RCVD.AMT + DEF.INT.AMT + DEF.TX.AMT
        R.RECORD<500,-1> = PBALANCE
        START.BAL = PBALANCE
    NEXT YCOUNT
    R.RECORD.UPDATE = R.RECORD
    RETURN

*--------------------------------------------------------------------------------------------------


BUILD.ENQUIRY.DATA:
*------------------
*

    R.MG = "" ; ETEXT = ""
    IF APPLICATION NE "MG.BALANCE.ENQUIRY" THEN
        F.MG.MORTGAGE = ""
        CALL OPF("F.MG.MORTGAGE",F.MG.MORTGAGE)
*
        IF ETEXT THEN
            RETURN
        END
        MG.ERR = ''
        CALL F.MATREAD("F.MG.MORTGAGE",ID,MAT R$MORTGAGE,MG.AUDIT.DATE.TIME,F.MG.MORTGAGE,MG.ERR)   ;* EN_10000067 ; * CI-10004652
        IF NOT(R$MORTGAGE(1)) THEN
            DIM R$MORTGAGE$NAU(MG.AUDIT.DATE.TIME)          ;* EN_10000067
            FN.MG.MORTGAGE = 'F.MG.MORTGAGE$NAU'
            F.MG.MORTGAGE = ''
            ETEXT = ''
            CALL OPF(FN.MG.MORTGAGE,F.MG.MORTGAGE)
            IF ETEXT THEN
                RETURN
            END
            MAT R$MORTGAGE$NAU = ''
            NAU.ERROR = ''
            CALL F.MATREAD(FN.MG.MORTGAGE,ID,MAT R$MORTGAGE$NAU,MG.AUDIT.DATE.TIME,F.MG.MORTGAGE,ETEXT)       ;* EN_10000067 ; * CI-10004652
            MAT R$MORTGAGE = MAT R$MORTGAGE$NAU
        END
        MAT.DATE = R$MORTGAGE(MG.MATURITY.DATE)
        VAL.DATE = R$MORTGAGE(MG.VALUE.DATE)
*
        F$MG.BALANCES = ""
        CALL OPF("F.MG.BALANCES",F$MG.BALANCES)
        CALL F.MATREAD("F.MG.BALANCES", ID, MAT R$BALANCES, 50, F$MG.BALANCES, E)         ;* CI-10004652
*
        F$MG.PARAMETER = ''
        F$MG.PARAMETER.FILE = "F.MG.PARAMETER"
        CALL OPF(F$MG.PARAMETER.FILE, F$MG.PARAMETER)
*
        MAT R$PARAMETER = ''  ;* EN_10002260 S
        F.MG.PARAMETER = ''
        MG.PARAM.ID = ''
        CALL EB.READ.PARAMETER('F.MG.PARAMETER','N',MAT R$PARAMETER,'',MG.PARAM.ID,F.MG.PARAMETER,YERR)       ;* EN_10002135 S/E ; * BG_10006150 S/E
        IF YERR THEN
            RETURN
        END


    END
*
    IF APPLICATION EQ 'MG.BALANCE.ENQUIRY' THEN   ;* CI_10004312 S
        IF R.NEW(MG.BE.START.DATE) AND R.NEW(MG.BE.END.DATE) THEN
            VAL.DATE = R.NEW(MG.BE.START.DATE)
            MAT.DATE = R.NEW(MG.BE.END.DATE)
        END
    END   ;* CI_10004312 E

    IF MAT.DATE GT R$BALANCES(MG.BAL.ACCR.TO.DATE) THEN
* Call MG.FORWARD.VIEW with mode.
        CALL MG.FORWARD.VIEW( MAT.DATE:FM:'ENQ', MAT R.WORK.BALANCES, "", FWD.ERROR)
    END ELSE
        MAT R.WORK.BALANCES = MAT R$BALANCES
    END

* Before we do any furhter processing determine the prin balance on
* the requested start date as it may be needed by then enquiry. It is
* easier to do it now before we remove any of the unwanted detail

    IF VAL.DATE LT R.WORK.BALANCES(MG.BAL.RECORD.START.DATE) THEN
        START.DATE = R.WORK.BALANCES(MG.BAL.RECORD.START.DATE)
    END ELSE
        START.DATE = VAL.DATE
    END
    LOCATE START.DATE IN R.WORK.BALANCES(MG.BAL.PRIN.EFF.DATE)<1,1> BY "DR" SETTING POS ELSE
        NULL
    END   ;* BG_100018583 S/E
    O.DATA = R$MORTGAGE(MG.PRINCIPAL.AMOUNT)
    START.SAVE.BAL = O.DATA

* Remove all unwanted details based on the START.DATE passed in the
* MG.BALANCE.ENQUIRY record.

    BEGIN CASE
    CASE VAL.DATE GE R.WORK.BALANCES(MG.BAL.RECORD.START.DATE)
        STRIP.DATA = 1
    CASE MAT.DATE LE R.WORK.BALANCES(MG.BAL.ACCR.TO.DATE)<1,1>
        STRIP.DATA = 1
    CASE 1
        STRIP.DATA = ""
    END CASE
    IF STRIP.DATA THEN
        START.DATE = VAL.DATE
        END.DATE = MAT.DATE
        GOSUB STRIP.UNWANTED.DATA
    END

    GOSUB REVERSE.TIME.ORDER

* Set the RECORD.START.DATE and END.INT.PERIOD to the dates requested so
* that we can access these form the enquiry.

    IF VAL.DATE GT R.WORK.BALANCES(MG.BAL.RECORD.START.DATE) THEN
        R.WORK.BALANCES(MG.BAL.RECORD.START.DATE) = VAL.DATE
    END
    R.WORK.BALANCES(MG.BAL.END.INT.PERIOD) = MAT.DATE

    FOR XX = 1 TO MG.BAL.REDEM.DATE     ;* EN_10002338
        R.RECORD<XX> = R.WORK.BALANCES(XX)
    NEXT XX

*
* Forward dated principal increase is also incorporated in the R.RECORD
*
    Y1COUNT = DCOUNT(R.RECORD<MG.BAL.PAYMENT.DATE>, VM)
* GB0102029 S
    PRIN.EFF.DATE = R$BALANCES(MG.BAL.PRIN.EFF.DTE)
    PRIN.EFF.DATE<-1> = R$MORTGAGE(MG.PRIN.EFF.DATE)
    PRIN.INCREASE = R$BALANCES(MG.BAL.PRIN.INCREASE)
    PRIN.INCREASE<-1> = R$MORTGAGE(MG.PRIN.INCREASE)
* GB0102029 E
    LOOP
        REMOVE YDATE FROM PRIN.EFF.DATE SETTING POS
        REMOVE YPRIN FROM PRIN.INCREASE SETTING POS2
    WHILE YDATE
        YPRIN = YPRIN * -1
        YCOUNT = 1
        LOOP
        WHILE YDATE GT R.RECORD<MG.BAL.PAYMENT.DATE,YCOUNT> AND YCOUNT LE Y1COUNT
            YCOUNT += 1
        REPEAT
        INS YDATE BEFORE R.RECORD<MG.BAL.PAYMENT.DATE,YCOUNT>
        INS YPRIN BEFORE R.RECORD<MG.BAL.PRINCIPAL.RCVD,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.INTEREST.RCVD,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.REPAYMENT.AMT,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.TAX.RCVD,YCOUNT>
        INS '0' BEFORE R.RECORD<38,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.DEF.INT.AMT,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.DEF.TAX.AMT,YCOUNT>
    REPEAT
*
* Before returning to the enquiry we need to tell it the maximum number
* of multivalues and subvalues that it is likely to encounter when
* displaying the current record. The largest number of sub and multi
* values will appear in the accrual fields.

    SAVE.BAL = START.SAVE.BAL
    NO.OF.RECS = DCOUNT(R.RECORD<MG.BAL.PAYMENT.DATE>,VM)
    FOR YCOUNT = 1 TO NO.OF.RECS
        PRIN.RCVD.AMT = R.RECORD<MG.BAL.PRINCIPAL.RCVD,YCOUNT>
        SAVE.BAL = START.SAVE.BAL
        DEF.INT.AMT = 0
        DEF.TX.AMT = 0
        DEF.INT.AMT = R.RECORD<MG.BAL.DEF.INT.AMT,YCOUNT>
        DEF.TX.AMT = R.RECORD<MG.BAL.DEF.TAX.AMT,YCOUNT>
        PBALANCE = SAVE.BAL - PRIN.RCVD.AMT + DEF.INT.AMT + DEF.TX.AMT
        R.RECORD<500,-1> = PBALANCE
        R.RECORD<400,-1> = R$MORTGAGE(MG.CUSTOMER)
        R.RECORD<401,-1> = R$MORTGAGE(MG.CURRENCY)
        START.SAVE.BAL = PBALANCE
    NEXT YCOUNT

    SM.COUNT = COUNT(R.RECORD<MG.BAL.ACCR.PRIN>, SM) + 1
    VM.COUNT = COUNT(R.RECORD<MG.BAL.ACCR.PRIN>, VM) + 1

    RETURN

**************************************************************************
*                             INTERNAL ROUTINES
**************************************************************************


STRIP.UNWANTED.DATA:
*===================

* Process each group of fields on R.WORK.BALANCES in turn. This is done by an
* internal routine. For each group of MV fields define the controlling
* date field and the start and end fields of the group and handoff to
* the subroutine SPLIT.MV.FIELDS.

* Contract.type/date feilds

    DATE.FLD = MG.BAL.TYPE.EFF.DATE
    START.FLD = MG.BAL.CONTRACT.TYPE
    END.FLD = MG.BAL.TYPE.EFF.DATE
    GOSUB SPLIT.MV.FIELDS

* principal balance fields

    DATE.FLD = MG.BAL.PRIN.EFF.DATE
    START.FLD = MG.BAL.PRIN.BALANCE
    END.FLD = MG.BAL.PRIN.EFF.DATE
    GOSUB SPLIT.MV.FIELDS

* Interest rate fields

    DATE.FLD = MG.BAL.INT.EFF.DATE
    START.FLD = MG.BAL.INT.RATE
    END.FLD = MG.BAL.INT.EFF.DATE
    GOSUB SPLIT.MV.FIELDS

* Interest accrual fields.

    DATE.FLD = MG.BAL.ACCR.FROM.DATE
    START.FLD = MG.BAL.ACCR.PRIN
    END.FLD = MG.BAL.ACCR.ACT.AMT
    GOSUB SPLIT.MV.FIELDS
    LAST.FROM.DATE = R.WORK.BALANCES(MG.BAL.ACCR.FROM.DATE)<1,LPOS>

* Payment details fields

    DATE.FLD = MG.BAL.PAYMENT.DATE
    START.FLD = MG.BAL.PAYMENT.DATE
    END.FLD = MG.BAL.ADD.PAY.5.RCVD
    GOSUB SPLIT.MV.FIELDS

* Remove all categ.entry ids as they are not required

    R.WORK.BALANCES(MG.BAL.CHARGE.TAX.AMT) = ""       ;* EN_10002338

    RETURN


SPLIT.MV.FIELDS:
*===============

    LOCATE END.DATE IN R$BALANCES(DATE.FLD)<1,1> BY "DR" SETTING HPOS THEN
        IF R.WORK.BALANCES(DATE.FLD)<1,HPOS + 1> = END.DATE THEN
            HPOS += 1
        END
    END ELSE
        NULL
    END

* When removing data from the live record if we do not locate the
* required date exactly then for the contract.type, prin.balance,
* interest.rate and accrual fields we must take the values for the
* set immediately prior to the split date. If we do not do this then
* the opening values of these fields will not be known. However this is
* not required nor is it desirable for the repayment fields.

    LOCATE START.DATE IN R.WORK.BALANCES(DATE.FLD)<1,1> BY "DR" SETTING LPOS THEN
        IF R.WORK.BALANCES(DATE.FLD)<1, LPOS + 1> = START.DATE THEN
            LPOS += 1
        END
    END ELSE
        IF DATE.FLD = MG.BAL.PAYMENT.DATE THEN
            LPOS -= 1
        END
    END

* Find the position of the value marks where we need to split the
* record. We can the perform a string extraction to do the split
* which is the fastest.

    FOR XX = START.FLD TO END.FLD

* If HPOS is 1 then then the whole field is required so don't bother
* with the string extraction. If HPOS is greater than the number of MVs,
* ie the history end date is less that the last date in the field,
* then we don't want anything. In this case the index function will
* return a 0 as the VM required does not exist so we can skip the string
* extraction.

        IF HPOS LE 1 THEN
            R.WORK.BALANCES(XX) = R.WORK.BALANCES(XX)
        END ELSE
            HIST.INDEX = INDEX(R.WORK.BALANCES(XX), VM, HPOS-1) + 1
            IF HIST.INDEX GT 1 THEN
                R.WORK.BALANCES(XX) = R.WORK.BALANCES(XX)[HIST.INDEX, 999]
            END
        END

* If LPOS is less than 1 ie this is a payment field and the last payment
* was before the live start date (contract has matured) then no data
* should be present on the live record so set then field to null.
* If the value mark we are looking for does not exist, ie the live start
* date is less than the last date in the field, then take the whole field
* as it is all required. If we do not do this then the INDEX function
* will return a -1 and the field will be lost.

        IF LPOS LT 1 THEN
            R.WORK.BALANCES(XX) = ""
        END ELSE
            LIVE.INDEX = INDEX(R.WORK.BALANCES(XX), VM, LPOS) - 1
            IF LIVE.INDEX GT 0 THEN
                R.WORK.BALANCES(XX) = R.WORK.BALANCES(XX)[1, LIVE.INDEX]
            END
        END
    NEXT XX

    RETURN


REVERSE.TIME.ORDER:
*==================

* Data on the MG.BALANCES file is stored in reverse chronological order
* which is O.K. for updating but not so good for display purposes.
* therefore reverse the order of each group of MV fields.

    MAT TEMP.REC = MAT R.WORK.BALANCES

    START.GROUP = MG.BAL.CONTRACT.TYPE
    END.GROUP = MG.BAL.TYPE.EFF.DATE
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.PRIN.BALANCE
    END.GROUP = MG.BAL.PRIN.EFF.DATE
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.INT.EFF.DATE
    END.GROUP = MG.BAL.INT.RATE
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.ACCR.FROM.DATE
    END.GROUP = MG.BAL.ACCR.ACT.AMT
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.PAYMENT.DATE
    END.GROUP = MG.BAL.ADD.PAY.5.RCVD
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.DEF.IN.EFF.DATE
    END.GROUP = MG.BAL.DEF.TAX.AMT
    GOSUB REVERSE.ORDER

    MAT R.WORK.BALANCES = MAT TEMP.REC
    RETURN


REVERSE.ORDER:
*=============

    NO.OF.MVS = COUNT(R.WORK.BALANCES(START.GROUP), VM) + (R.WORK.BALANCES(START.GROUP) NE "")
    FOR XX = START.GROUP TO END.GROUP
        TEMP.REC(XX) = ""
        FOR YY = 1 TO NO.OF.MVS
            INS R.WORK.BALANCES(XX)<1,YY> BEFORE TEMP.REC(XX)<1,1>
        NEXT YY
    NEXT XX

    RETURN


******
END
