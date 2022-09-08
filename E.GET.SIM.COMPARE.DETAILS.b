* @ValidationCode : MjotMTc4ODAwODM5NjpDcDEyNTI6MTYwNTUzMzcxMzMxMjpubWFydW46MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjM2NToyMzM=
* @ValidationInfo : Timestamp         : 16 Nov 2020 19:05:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nmarun
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 233/365 (63.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-139</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.GET.SIM.COMPARE.DETAILS(OUT.DATA)

*** <region name= PROGRAM DESCRIPTION>
***
*
** Nofile routine returning combined arrangement details
** Term Amount, Interest, Schedule details are the output
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
*  12-09-13   Task 737278
*             Enhancement 715620
*             Nofile routine returning combined arrangement details -
*             Term Amount, Interest, Schedule details are the output
*
*  24-12-13   Task 868089
*             Defect 868078
*             Payment Type, Property description should be taken based on
*             If description not available then get it using default.
*
*  08-10-20   Task        : 4083722
*             Enhancement : 3930698
*             Get periodic interest record from MDAL MarketData API
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***

    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING ST.RateParameters
    $USING EB.DataAccess
    $USING AA.ModelBank
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.Reports
    $USING MDLMKT.MarketData

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS LOGIC>
***
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB BUILD.PROCESS

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
***
INITIALISE:

* Initialise local variables

    OUT.DATA = ''
    PRIN.INT.RATE = ""
    PEN.INT.RATE = ""
    TOT.OUTS.AMT = ""
    TOT.INT.PAYABLE = ""
    TOT.OUTS.INT.AMT = ""
    EMI.AMT = ""
    TOT.MAT.AMT = ""
    ARR.ID = ""
    SIM.REF = ""

    INT.VAR.TEXT = ""
    TERM.VAR.TEXT = ""
    PS.VAR.TEXT = ""
    PROP.DESC.TEXT = ""
    RATE.TYPE.TEXT = ""
    FIX.TEXT = ""
    OTHER.TEXT = ""
    PAY.TYPE.TEXT = ""
    PROP.TEXT = ""
    AMOUNT.TEXT = ""
    PAY.METHOD.TEXT = ""
    FREQ.TEXT = ""

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPENFILES>
***
OPENFILES:

* Open needed files

    F.AA.PROPERTY = ''

    FN.BASIC.RATE.TEXT = "F.BASIC.RATE.TEXT"
    F.BASIC.RATE.TEXT = ""

    FN.PERIODIC.INTEREST = "F.PERIODIC.INTEREST"
    F.PERIODIC.INTEREST = ""

    FN.AA.PAYMENT.TYPE = "F.AA.PAYMENT.TYPE"
    F.AA.PAYMENT.TYPE = ""

    F.AA.SIMULATION.RUNNER = ""

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.PROCESS>
***
BUILD.PROCESS:

    GOSUB FIND.ARRANGEMENT

    IF SIM.REF NE "NONE" THEN
        EB.Reports.setEnqSimRef(SIM.REF)
        GOSUB GET.PROD.PROP.RECORD
        GOSUB GET.TERM.DETAILS
        GOSUB GET.INTEREST.DETAILS
        GOSUB GET.SCHEDULE.DETAILS

        CNT.PROP.DESC.TEXT = DCOUNT(PROP.DESC.TEXT,@FM)
        FOR CNT.VAL = 1 TO CNT.PROP.DESC.TEXT
            IF CNT.VAL EQ '1' THEN
                EB.Reports.setHeader("Interest")
            END ELSE
                IF CNT.VAL EQ CNT.PROP.DESC.TEXT THEN
                    EB.Reports.setHeader(EB.Reports.getHeader():@FM:" ":@FM:"Schedule")
                END ELSE
                    EB.Reports.setHeader(EB.Reports.getHeader():@FM:" ")
                END
            END
        NEXT CNT.VAL

        LOCATE 'Fixed Principal Payment' IN PAY.TYPE.TEXT SETTING PAY.TYPE1.POS ELSE
            PAY.TYPE.TEXT<-1> = 'Fixed Principal Payment'
            PROP.TEXT<-1> = 'Account'
            AMOUNT.TEXT<-1> = ' '
            PAY.METHOD.TEXT<-1> = ' '
            FREQ.TEXT<-1> = ' '
        END

        ALL.PROP.DESC = PROP.DESC.TEXT:@FM:PAY.TYPE.TEXT
        ALL.RATE.TYPE = RATE.TYPE.TEXT:@FM:PROP.TEXT
        ALL.FIX.OR.VAR = FIX.TEXT:@FM:AMOUNT.TEXT
        ALL.OTHER.VALUES = OTHER.TEXT:@FM:PAY.METHOD.TEXT
        ALL.TEMP.VALUES = TEMP.TEXT:@FM:FREQ.TEXT

        ALL.DETAILS = ALL.PROP.DESC:"*":ALL.RATE.TYPE:"*":ALL.FIX.OR.VAR:"*":ALL.OTHER.VALUES:"*":ALL.TEMP.VALUES
        OUT.DATA = TERM.VAR.TEXT:"*":EB.Reports.getHeader():"*":ALL.DETAILS
        CHANGE @FM TO @VM IN OUT.DATA
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= FIND.ARRANGEMENT>
***
FIND.ARRANGEMENT:

    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Pick the Simulation Reference
    END

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement ID
    END

    IF ARR.ID EQ '' THEN
        R.AA.SIMULATION.RUNNER = AA.Framework.SimulationRunner.Read(SIM.REF, SIM.ERR)
        ARR.ID = R.AA.SIMULATION.RUNNER<AA.Framework.SimulationRunner.SimArrangementRef>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PROD.PROP.RECORD>
***
GET.PROD.PROP.RECORD:

    AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, RET.ERROR)
    PRODUCT.OR.PROPERTY = "PRODUCT"
    PRODUCT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProduct>
    EFF.DATE = EB.SystemTables.getToday()
    PRODUCT.RECORD = ""
    RET.ERR = ""
    AA.ProductFramework.GetProductPropertyRecord(PRODUCT.OR.PROPERTY, "", PRODUCT.ID, "", "", "", "", EFF.DATE, PRODUCT.RECORD, RET.ERR)
    PRODUCT.LINE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>
    ACCOUNT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>:"-":R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PROPERTY.DESCRIPTION>
***
GET.PROPERTY.DESCRIPTION:

    R.PROPERTY = AA.ProductFramework.Property.Read(PROPERTY.ID, PROP.ERR)

    IF R.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()> THEN
        PROPERTY.DESCRIPTION = R.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
    END ELSE
        PROPERTY.DESCRIPTION = R.PROPERTY<AA.ProductFramework.Property.PropDescription,1>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= TERM.DETAILS>
***
GET.TERM.DETAILS:

    ENQ.DATA.NEW<1> = EB.Reports.getEnqSelection()<1>
    ENQ.DATA.NEW<2> = 'ID.COMP.1'
    ENQ.DATA.NEW<3> = 'EQ'
    ENQ.DATA.NEW<4> = ARR.ID
    ENQ.DATA.NEW<17> = 'SIM LIV'
    TEMP.R.RNQ = EB.Reports.getREnq()
    tmp=EB.Reports.getREnq(); tmp<2>="AA.ARR.TERM.AMOUNT"; EB.Reports.setREnq(tmp)
    AA.ModelBank.EAaBuildArrCond(ENQ.DATA.NEW)
    EB.Reports.setREnq(TEMP.R.RNQ)

    TERM.PROPERTY.CLASS = "TERM.AMOUNT"
    AA.ProductFramework.GetPropertyName(PRODUCT.RECORD,TERM.PROPERTY.CLASS,TERM.PROPERTY)

    ID.TO.ADD = ENQ.DATA.NEW<4>:"%":SIM.REF

    EB.DataAccess.FRead('F.AA.ARR.TERM.AMOUNT$SIM',ID.TO.ADD,TERM.PROPERTY.RECORD,F.AA.SIM.TERM.AMOUNT,SIM.ERR)
    IF TERM.PROPERTY.RECORD ELSE
        ARR.NO = ARR.ID
        TERM.PROPERTY.CLASS = "TERM.AMOUNT"
        EFF.DATE = EB.SystemTables.getToday()
        AA.ProductFramework.GetPropertyRecord('', ARR.NO, TERM.PROPERTY, EFF.DATE, TERM.PROPERTY.CLASS, '', TERM.PROPERTY.RECORD, RET.ERROR)
    END

    TERM.AMOUNT = TERM.PROPERTY.RECORD<AA.TermAmount.TermAmount.AmtAmount>
    TERM = TERM.PROPERTY.RECORD<AA.TermAmount.TermAmount.AmtTerm>
    REVOLVING = TERM.PROPERTY.RECORD<AA.TermAmount.TermAmount.AmtRevolving>
    IF REVOLVING EQ "PAYMENT" THEN
        REVOLVING.TXT = "Revolving on Payment"
    END ELSE
        REVOLVING.TXT = "Revolving on Prepayment"
    END
    TERM.VAR.TEXT = TERM.AMOUNT:"*":REVOLVING.TXT:"*":TERM

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.INTEREST.DETAILS>
***

GET.INTEREST.DETAILS:

    ENQ.DATA.NEW<1> = EB.Reports.getEnqSelection()<1>
    ENQ.DATA.NEW<2> = 'ID.COMP.1'
    ENQ.DATA.NEW<3> = 'EQ'
    ENQ.DATA.NEW<4> = ARR.ID
    ENQ.DATA.NEW<17> = 'SIM LIV'
    TEMP.R.RNQ = EB.Reports.getREnq()
    tmp=EB.Reports.getREnq(); tmp<2>="AA.ARR.INTEREST"; EB.Reports.setREnq(tmp)
    AA.ModelBank.EAaBuildArrCond(ENQ.DATA.NEW)
    EB.Reports.setREnq(TEMP.R.RNQ)
    ENQ.PROPERTY = ENQ.DATA.NEW<4>
    CONVERT ' ' TO @FM IN ENQ.PROPERTY
    CNT.PROPERTY = DCOUNT(ENQ.PROPERTY,@FM)

    FOR CNT.I = 1 TO CNT.PROPERTY
        INT.DATA = ENQ.PROPERTY<CNT.I>
        INT.PROPERTY = FIELDS(INT.DATA,'-',2,1)
        PROPERTY.ID = INT.PROPERTY
        GOSUB GET.PROPERTY.DESCRIPTION

        ID.TO.ADD = INT.DATA:"%":SIM.REF
        EB.DataAccess.FRead('F.AA.ARR.INTEREST$SIM',ID.TO.ADD,INT.PROPERTY.RECORD,F.AA.SIM.INTEREST,SIM.ERR)
        IF  INT.PROPERTY.RECORD ELSE
            ARR.NO = ARR.ID
            INT.PROPERTY.CLASS = 'INTEREST'
            AA.ProductFramework.GetPropertyRecord('', ARR.NO, INT.PROPERTY, EFF.DATE, INT.PROPERTY.CLASS, '', INT.PROPERTY.RECORD, RET.ERROR)
        END
        GOSUB GET.REQUIRED.INT.VALUES
        BEGIN CASE
            CASE RATE.TIER.TYPE EQ 'SINGLE'
                GOSUB SINGLE.TYPE.PROCESS
            CASE RATE.TIER.TYPE EQ 'BAND'
                GOSUB BAND.TYPE.PROCESS
            CASE RATE.TIER.TYPE EQ 'LEVEL'
                GOSUB LEVEL.TYPE.PROCESS
        END CASE
    NEXT CNT.I

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= SINGLE.TYPE.PROCESS>
***
SINGLE.TYPE.PROCESS:

    RATE.TIER.TYPE.TEXT = "Single Rate"
    PERIODIC.INDEX.VAL = PERIODIC.INDEX
    FLOATING.INDEX.VAL = FLOATING.INDEX
    FIXED.RATE.VAL = FIXED.RATE
    MARGIN.OPER.VAL = MARGIN.OPER
    EFF.RATE.VAL = EFF.RATE
    MARGIN.RATE.VAL = MARGIN.RATE
    GOSUB COMMON.FORM.TEXT.MESSAGES
    GOSUB CLEAR.VARIABLES
    PROP.DESC.TEXT<-1> = PROPERTY.DESCRIPTION
    RATE.TYPE.TEXT<-1> = RATE.TIER.TYPE.TEXT
    FIX.TEXT<-1> = FIX.VAR.VAL
    OTHER.TEXT<-1> = EFF.RATE.VAL:"% (":DESCRIPTION.VAL.TEXT:" ":MARGIN.OPER.VAL:" ":MARGIN.RATE<1,1,1>:"%)":TIER.VAL.TEXT
    TEMP.TEXT<-1> = " "

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= BAND.TYPE.PROCESS>
***
BAND.TYPE.PROCESS:

    RATE.TIER.TYPE.TEXT = "Tier Bands"
    EFF.RATE.CNT = DCOUNT(EFF.RATE,@VM)
    FOR CNT.EF.RATE = 1 TO EFF.RATE.CNT
        PERIODIC.INDEX.VAL = PERIODIC.INDEX<1,CNT.EF.RATE>
        FIXED.RATE.VAL = FIXED.RATE<1,CNT.EF.RATE>
        FLOATING.INDEX.VAL = FLOATING.INDEX<1,CNT.EF.RATE>
        EFF.RATE.VAL = EFF.RATE<1,CNT.EF.RATE>
        MARGIN.RATE.VAL = MARGIN.RATE<1,CNT.EF.RATE>
        TIER.AMOUNT.VAL = TIER.AMOUNT<1,CNT.EF.RATE>
        NEXT.TIER.AMOUNT.VAL = TIER.AMOUNT<1,CNT.EF.RATE+1>
        GOSUB CLEAR.VARIABLES
        GOSUB COMMON.FORM.TEXT.MESSAGES
        IF CNT.EF.RATE EQ '1' THEN
            PROP.DESC.TEXT<-1> = PROPERTY.DESCRIPTION
        END ELSE
            PROP.DESC.TEXT<-1> = " "
        END
        RATE.TYPE.TEXT<-1> = RATE.TIER.TYPE.TEXT
        FIX.TEXT<-1> = FIX.VAR.VAL
        OTHER.TEXT<-1> = EFF.RATE.VAL:"% (":DESCRIPTION.VAL.TEXT:" ":MARGIN.OPER.VAL:" ":MARGIN.RATE<1,1,1>:"%)":TIER.VAL.TEXT
    NEXT CNT.EF.RATE

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= LEVEL.TYPE.PROCESS>
***
LEVEL.TYPE.PROCESS:

    RATE.TIER.TYPE.TEXT = "Tier Levels"
    EFF.RATE.CNT = DCOUNT(EFF.RATE,@VM)
    FOR CNT.EF.RATE = 1 TO EFF.RATE.CNT
        PERIODIC.INDEX.VAL = PERIODIC.INDEX<1,CNT.EF.RATE>
        FIXED.RATE.VAL = FIXED.RATE<1,CNT.EF.RATE>
        FLOATING.INDEX.VAL = FLOATING.INDEX<1,CNT.EF.RATE>
        EFF.RATE.VAL = EFF.RATE<1,CNT.EF.RATE>
        MARGIN.RATE.VAL = MARGIN.RATE<1,CNT.EF.RATE>
        TIER.AMOUNT.VAL = TIER.AMOUNT<1,CNT.EF.RATE>
        NEXT.TIER.AMOUNT.VAL = TIER.AMOUNT<1,CNT.EF.RATE+1>
        GOSUB CLEAR.VARIABLES
        GOSUB COMMON.FORM.TEXT.MESSAGES
        IF CNT.EF.RATE EQ '1' THEN
            PROP.DESC.TEXT<-1> = PROPERTY.DESCRIPTION
        END ELSE
            PROP.DESC.TEXT<-1> = " "
        END
        RATE.TYPE.TEXT<-1> = RATE.TIER.TYPE.TEXT
        FIX.TEXT<-1> = FIX.VAR.VAL
        OTHER.TEXT<-1> = EFF.RATE.VAL:"% (":DESCRIPTION.VAL.TEXT:" ":MARGIN.OPER.VAL:" ":MARGIN.RATE<1,1,1>:"%)":TIER.VAL.TEXT
    NEXT CNT.EF.RATE

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLEAR.VARIABLES>
***
CLEAR.VARIABLES:

    TIER.VAL.TEXT = ""

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.REQUIRED.INT.VALUES>
***
GET.REQUIRED.INT.VALUES:

    RATE.TIER.TYPE = INT.PROPERTY.RECORD<AA.Interest.Interest.IntRateTierType>
    FIXED.RATE = INT.PROPERTY.RECORD<AA.Interest.Interest.IntFixedRate>
    EFF.RATE = INT.PROPERTY.RECORD<AA.Interest.Interest.IntEffectiveRate>
    FLOATING.INDEX = INT.PROPERTY.RECORD<AA.Interest.Interest.IntFloatingIndex>
    PERIODIC.INDEX = INT.PROPERTY.RECORD<AA.Interest.Interest.IntPeriodicIndex>
    PERIODIC.RATE = INT.PROPERTY.RECORD<AA.Interest.Interest.IntPeriodicRate>
    MARGIN.OPER = INT.PROPERTY.RECORD<AA.Interest.Interest.IntMarginOper>
    MARGIN.RATE = INT.PROPERTY.RECORD<AA.Interest.Interest.IntMarginRate>
    TIER.AMOUNT = INT.PROPERTY.RECORD<AA.Interest.Interest.IntTierAmount>

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= COMMON.FORM.TEXT.MESSAGES>
***
COMMON.FORM.TEXT.MESSAGES:

    IF PERIODIC.INDEX.VAL OR FIXED.RATE.VAL THEN
        FIX.VAR.VAL = "Fixed"
    END ELSE
        FIX.VAR.VAL = "Variable"
    END

    GOSUB FIND.FLOAT.PERIODIC.DESCRIPTION
    GOSUB FIND.MARGIN.TEXT
    GOSUB FIND.TIER.TEXT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= FIND.FLOAT.PERIODIC.DESCRIPTION>
***
FIND.FLOAT.PERIODIC.DESCRIPTION:

    SAVE.ETEXT = ""
    SAVE.ETEXT = EB.SystemTables.getEtext()   ;* Save EText Values to restore it later
    EB.SystemTables.setEtext('')  ;* set Error text to Null
    IF FLOATING.INDEX.VAL THEN
        R.BASIC.RATE.TEXT = ""
        R.BASIC.RATE.TEXT = MDLMKT.MarketData.getBasicInterestName(FLOATING.INDEX.VAL)
        IF R.BASIC.RATE.TEXT THEN
            IF R.BASIC.RATE.TEXT<MDLMKT.MarketData.BasicInterestName.rateNames.rateName,EB.SystemTables.getLngg()> THEN
                DESCRIPTION.VAL.TEXT = R.BASIC.RATE.TEXT<MDLMKT.MarketData.BasicInterestName.rateNames.rateName,EB.SystemTables.getLngg()>
            END ELSE
                DESCRIPTION.VAL.TEXT = R.BASIC.RATE.TEXT<MDLMKT.MarketData.BasicInterestName.rateNames.rateName,1>
            END
        END
    END ELSE
        PI.ID = PERIODIC.INDEX.VAL:R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>:EB.SystemTables.getToday()
        R.PERIODIC.INTEREST = ""
        R.PERIODIC.INTEREST = MDLMKT.MarketData.getPeriodicInterest(PI.ID)
        IF R.PERIODIC.INTEREST THEN
            IF R.PERIODIC.INTEREST<MDLMKT.MarketData.PeriodicInterest.rateNames.rateName,EB.SystemTables.getLngg()> THEN
                DESCRIPTION.VAL.TEXT = R.PERIODIC.INTEREST<MDLMKT.MarketData.PeriodicInterest.rateNames.rateName,EB.SystemTables.getLngg()>
            END ELSE
                DESCRIPTION.VAL.TEXT = R.PERIODIC.INTEREST<MDLMKT.MarketData.PeriodicInterest.rateNames.rateName,1>
            END
        END
    END
    EB.SystemTables.setEtext(SAVE.ETEXT)    ;* Restore EText values after using MDAL API
    
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= FIND.MARGIN.TEXT>
***
FIND.MARGIN.TEXT:

    MARGIN.OPER.VAL = MARGIN.OPER<1,CNT.EF.RATE>
    IF MARGIN.OPER.VAL THEN
        BEGIN CASE
            CASE MARGIN.OPER.VAL EQ 'ADD'
                MARGIN.OPER.VAL = "+"
            CASE MARGIN.OPER.VAL EQ 'SUB'
                MARGIN.OPER.VAL = "-"
            CASE MARGIN.OPER.VAL EQ 'MULTIPLY'
                MARGIN.OPER.VAL = "*"
        END CASE
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= FIND.TIER.TEXT>
***
FIND.TIER.TEXT:

    TEMP.TIER.AMOUNT = TIER.AMOUNT
    CHANGE @VM TO '' IN TEMP.TIER.AMOUNT

    IF TEMP.TIER.AMOUNT NE '' THEN
        IF TIER.AMOUNT.VAL NE '' THEN
            TIER.VAL.TEXT = "up to ":TIER.AMOUNT.VAL
        END ELSE
            TIER.VAL.TEXT = "remainder"
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SCHEDULE.DETAILS>
***
GET.SCHEDULE.DETAILS:

    ENQ.DATA.NEW<1> = EB.Reports.getEnqSelection()<1>
    ENQ.DATA.NEW<2> = 'ID.COMP.1'
    ENQ.DATA.NEW<3> = 'EQ'
    ENQ.DATA.NEW<4> = ARR.ID
    ENQ.DATA.NEW<17> = 'SIM LIV'
    TEMP.R.RNQ = EB.Reports.getREnq()
    tmp=EB.Reports.getREnq(); tmp<2>="AA.ARR.PAYMENT.SCHEDULE"; EB.Reports.setREnq(tmp)
    AA.ModelBank.EAaBuildArrCond(ENQ.DATA.NEW)
    EB.Reports.setREnq(TEMP.R.RNQ)

    PS.PROPERTY.CLASS = "PAYMENT.SCHEDULE"
    AA.ProductFramework.GetPropertyName(PRODUCT.RECORD,PS.PROPERTY.CLASS,PS.PROPERTY)

    ID.TO.ADD = ENQ.DATA.NEW<4>:"%":SIM.REF

    EB.DataAccess.FRead('F.AA.ARR.PAYMENT.SCHEDULE$SIM',ID.TO.ADD,PS.PROPERTY.RECORD,F.AA.SIM.PAYMENT.SCHEDULE,SIM.ERR)
    IF PS.PROPERTY.RECORD ELSE
        ARR.NO = ARR.ID
        AA.ProductFramework.GetPropertyRecord('', ARR.NO, PS.PROPERTY, EFF.DATE, PS.PROPERTY.CLASS, '', PS.PROPERTY.RECORD, RET.ERROR)
    END

    PAYMENT.TYPE = PS.PROPERTY.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
    TOT.PAY.TYPE = DCOUNT(PAYMENT.TYPE,@VM)
    FOR CNT.J = 1 TO TOT.PAY.TYPE
        PS.PROPERTIES = PS.PROPERTY.RECORD<AA.PaymentSchedule.PaymentSchedule.PsProperty,CNT.J>
        GOSUB PROCESS.BY.PROPERTY
    NEXT CNT.J

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.BY.PROPERTY>
***
PROCESS.BY.PROPERTY:

    FOR CNT.Y = 1 TO DCOUNT(PS.PROPERTIES,@VM)
        PS.PROPERTY = PS.PROPERTIES<1,CNT.Y>
        PROPERTY.ID = PS.PROPERTY
        GOSUB GET.PROPERTY.DESCRIPTION
        AA.ProductFramework.GetPropertyClass(PS.PROPERTY,PROP.CLASS)
        GOSUB FIND.AMOUNT
        FREQ = PS.PROPERTY.RECORD<AA.PaymentSchedule.PaymentSchedule.PsDueFreq,CNT.J>
        IN.DATA = ""
        OUT.MASK = ""
        EB.Utility.BuildRecurrenceMask(FREQ,IN.DATA,OUT.MASK)
        FREQ = OUT.MASK
        PAY.METHOD = PS.PROPERTY.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod,CNT.J>
        R.AA.PAYMENT.TYPE = AA.PaymentSchedule.PaymentType.Read(PAYMENT.TYPE<1,CNT.J>, TYPE.ERR)

        IF R.AA.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtDescription,EB.SystemTables.getLngg()> THEN
            PAYMENT.TYPE.DESCRIPTION = R.AA.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtDescription,EB.SystemTables.getLngg()>
        END ELSE
            PAYMENT.TYPE.DESCRIPTION = R.AA.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtDescription,1>
        END

        IF AMOUNT EQ '' THEN
            AMOUNT = " "
        END
        IF AMOUNT THEN
            AMOUNT = FMT(AMOUNT, "R2#10")
        END
        IF PAY.METHOD EQ '' THEN
            PAY.METHOD = " "
        END
        IF FREQ EQ '' THEN
            FREQ = " "
        END
        PAY.TYPE.TEXT<-1> = PAYMENT.TYPE.DESCRIPTION
        PROP.TEXT<-1> = PROPERTY.DESCRIPTION
        AMOUNT.TEXT<-1> = AMOUNT
        PAY.METHOD.TEXT<-1> = PAY.METHOD
        FREQ.TEXT<-1> = FREQ
    NEXT CNT.Y

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= FIND.AMOUNT>
***
FIND.AMOUNT:

    AMOUNT = ' '
    IF PROP.CLASS EQ 'ACCOUNT' THEN
        ACTUAL.AMT = PS.PROPERTY.RECORD<AA.PaymentSchedule.PaymentSchedule.PsActualAmt,CNT.J>
        CALC.AMT = PS.PROPERTY.RECORD<AA.PaymentSchedule.PaymentSchedule.PsCalcAmount,CNT.J>
        IF ACTUAL.AMT THEN
            AMOUNT = ACTUAL.AMT
        END ELSE
            AMOUNT = CALC.AMT
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

END
