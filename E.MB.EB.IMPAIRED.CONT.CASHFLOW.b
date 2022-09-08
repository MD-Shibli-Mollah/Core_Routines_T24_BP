* @ValidationCode : MjoxMjg1NzY0MDI0OmNwMTI1MjoxNTgzMzkzOTQyNDUxOmtyYW1hc2hyaToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6MjI3OjIyNQ==
* @ValidationInfo : Timestamp         : 05 Mar 2020 13:09:02
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 225/227 (99.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------
* <Rating>1202</Rating>
*---------------------------------------------------------------------------------------
* Subroutine to get the EB.CASHFLOW details and IFRS.ACCT.BALANCES details of Contracts
* attached in the STANDARD.SELECTION for the NOFILE enquiries
$PACKAGE IA.ModelBank
SUBROUTINE E.MB.EB.IMPAIRED.CONT.CASHFLOW(Y.DATA)
*---------------------------------------------------------------------------------------
* Modification History :
*
* 07/01/2020 - Defect 3523957 / Task 3523970
*              Got Transaction Reference from the Selection Criteria and returned results correctly
*
* 02/12/2019 - SI 3345513 / Task 3463607
*              Changes with respect to movement of cashflow from IA to CW module.
*---------------------------------------------------------------------------------------
    $USING IA.Config
    $USING IA.Valuation
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $USING CW.CashFlow
    $INSERT I_DAS.EB.CASHFLOW
    $INSERT I_DAS.EB.CASHFLOW.NOTES


* MAIN PROCESSING
    GOSUB INITIALISE ;* Pass TRANS.REFERENCE data
    GOSUB SELECTFILES
    GOSUB PROCESS

RETURN
*---------------------------------------------------------------------------------------
INITIALISE:
    
    SEL.CMD = ''
    SEL.LIST = ''
    NO.OF.SEL = ''
    SEL.ERR = ''
    EBCASHFLOW.ID = ''
    IFRSACCTBALANCES.ID = ''
    R.EBCASHFLOW = ''
    R.IFRSACCTBALANCES = ''
    POS = ''

    TRANS.POS = ''

    IMP.AMC.ADJ.POS = ''
    UND.POS = ''
    AMC.POS = ''
    FVEQ.POS = ''
    FVPL.POS = ''


*---------------------------------------------------------------------------------------
* Variables to hold the EB.CASHFLOW Details

    TRANS.REF = ''
    CUSTOMER.NO = ''
    CURRENCY = ''
    VALUE.DATE = ''
    MATURITY.DATE = ''
    IAS.CLASSIFICATION.LOC = ''
    IMPAIR.STATUS = ''

    ACCOUNTING.METHOD = ''

    ASSET.LIAB.IND = ''

    IMPAIR.EFFECTIVE.DATE = ''

    BID.OR.OFFER = ''

    MARKET.KEY = ''
    MARKET.MARGIN = ''
    MARGIN.OPERAND = ''

    EIR = ''
    MARKET.RATE = ''

    DATE.IMPAIRED = ''

*---------------------------------------------------------------------------------------
* Variables to hold the Contractual Cahflow Details from EB.CASHFLOW

    CONTRACTUAL.CASHFLOW.DATE = ''
    CONTRACTUAL.CASHFLOW.AMOUNT = ''
    CONTRACTUAL.CASHFLOW.CURRENCY = ''
    CONTRACTUAL.CASHFLOW.TYPE = ''

*---------------------------------------------------------------------------------------
* Variables to hold the Expected Cashflow Details from EB.CASHFLOW

    EXPECTED.CASHFLOW.DATE = ''
    EXPECTED.CASHFLOW.AMOUNT = ''
    EXPECTED.CASHFLOW.CURRENCY = ''
    EXPECTED.CASHFLOW.TYPE = ''

*---------------------------------------------------------------------------------------
* Variables to hold the Collateral Details from EB.CASHFLOW

    EXPECTED.COLLATERAL.DATE = ''
    EXPECTED.COLLATERAL.AMOUNT = ''

*---------------------------------------------------------------------------------------
* Variables to hold the IFRS.ACCT.BALANCES Details

    CONTRACT.BALANCE = ''

    NPV.CON.CF.AMORT = ''
    NPV.CON.CF.FV = ''

    NPV.EXP.CF.AMORT = ''
    NPV.EXP.CF.FV = ''
    VAL.EXP.COLL.AMORT = ''
    VAL.EXP.COLL.FV = ''

    IMPAIR.AMC.ADJUST.AMOUNT = ''
    IMPAIR.AMC.ADJUST.LCY.AMOUNT = ''
    UNWIND.AMOUNT = ''
    UNWIND.LCY.AMOUNT = ''
    IMPAIR.AMORTISED.AMOUNT = ''
    IMPAIR.AMORTISED.LCY.AMOUNT = ''
    IMPAIR.FAIRVALUE.AMOUNT = ''
    IMPAIR.FAIRVALUE.LCY.AMOUNT = ''
    IMPAIRMENT.LOSS = ''
    LCY.IMPAIRMENT.LOSS = ''
    IMPAIR.LAST.CALC.DATE = ''
    BALANCES = ''
    LCY.BALANCES = ''
    ACCT.CALC.AMT  = ''
    LAST.CALC.DATE = ''
*---------------------------------------------------------------------------------------

    ERR.TXT = ''

    ARRAY = ''
    Y.DATA = ''

*---------------------------------------------------------------------------------------
* Getting the Transaction Reference from the Selection Criteria
    ENQ.SEL = EB.Reports.getEnqSelection()
    LOCATE '@ID' IN ENQ.SEL<2,1> SETTING TRANS.POS THEN
        TRANS.REFERENCE = ENQ.SEL<4,TRANS.POS>
    END

RETURN

*---------------------------------------------------------------------------------------

SELECTFILES:
*---------------------------------------------------------------------------------------
* Selecting the EB.CASHFLOW record based on the IMPAIRED Status and contract id if given

    THE.ARGS<1>= "IMPAIRMENT.STATUS"
    THE.ARGS<2> = "EQ"
    THE.ARGS<3> = "IMPAIRED"

    IF TRANS.REFERENCE NE "" THEN
        THE.ARGS<1,-1> = "@ID"
        THE.ARGS<2,-1> = "LK"
        THE.ARGS<3,-1> = TRANS.REFERENCE:"..."
    END

    TABLE.NAME = "EB.CASHFLOW"
    TABLE.SUFFIX = ""
    THE.LIST = dasSelectImpairedRecords

    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)

RETURN
*---------------------------------------------------------------------------------------
*Loop begins here

PROCESS:

    LOOP
        REMOVE EBCASHFLOW.ID FROM THE.LIST SETTING POS
    WHILE EBCASHFLOW.ID:POS

* Reading the EB.CASHFLOW record for the particular Contract Id

        R.EBCASHFLOW = CW.CashFlow.EbCashflow.Read(EBCASHFLOW.ID, EBCASHFLOW.ERR)
        IFRSACCTBALANCES.ID = EBCASHFLOW.ID

* Reading the IFRS.ACCT.BALANCES record for the particular Contract Id

        R.IFRSACCTBALANCES = IA.Config.IfrsAcctBalances.Read(IFRSACCTBALANCES.ID, IFRSACCTBALANCES.ERR)

*----------------------------------------------------------------------------------------
* EB.CASHFLOW Details

        TRANS.REF = EBCASHFLOW.ID
        CUSTOMER.NO = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCustomerId>
        CURRENCY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCurrency>
        VALUE.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfValueDate>
        MATURITY.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfMaturityDate>
        IAS.CLASSIFICATION.LOC = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfIasClassification>
        IMPAIR.STATUS = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfImpairmentStatus>
        DATE.IMPAIRED = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfDateImpaired>
        ACCOUNTING.METHOD = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfAccountingMethod>

* Reading Account Head Type from IFRS.ACCT.BALANCES

        ACCT.HEAD.TYPE = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType>

*----------------------------------------------------------------------------------------

*IFRS.ACCT.BALANCES Details

* Counting the number of values in Account Head Type Using DCOUNT

        FIELD.COUNT = DCOUNT(ACCT.HEAD.TYPE,@VM)

* Checking the Local Curremcy

        IF CURRENCY EQ EB.SystemTables.getLccy() THEN

* loop for calculating Loss for each Account head type present in set.
* ACCT.BAL.BALANCES and ACCT.BAL.BALANCES fields are added to calculate Loss for Local Currency

            FOR I = 1 TO FIELD.COUNT
                ACCT.CALC.AMT = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt>,@VM,I)
                LAST.CALC.DATE = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcDate>,@VM,I)
                BALANCES = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance>,@VM,I)
                IMPAIRMENT.LOSS = -(IMPAIRMENT.LOSS + ACCT.CALC.AMT + BALANCES)
                IMPAIR.LAST.CALC.DATE = LAST.CALC.DATE
            NEXT I
* continue to the next iteration for processing next account type head.
        END

* Else part used to calculate Loss for foreign currency
* ACCT.BAL.LCY.BALANCE and ACCT.BAL.LST.CAL.LCY.AMT fields are used in calculating Loss for foreign currency

        ELSE
            FOR I = 1 TO FIELD.COUNT
                ACCT.CALC.AMT = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt>,@VM,I)
                LAST.CALC.DATE = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcDate>,@VM,I)
                ACCT.CALC.AMT.LCY = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLstCalLcyAmt>,@VM,I)
                LCY.BALANCES = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLcyBalance>,@VM,I)
                BALANCES = FIELD(R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance>,@VM,I)
                IMPAIRMENT.LOSS = -(IMPAIRMENT.LOSS + ACCT.CALC.AMT + BALANCES)
                LCY.IMPAIRMENT.LOSS = -(LCY.IMPAIRMENT.LOSS + ACCT.CALC.AMT.LCY + LCY.BALANCES)
                IMPAIR.LAST.CALC.DATE = LAST.CALC.DATE
            NEXT I
* continue to the next iteration for processing next account type head.
        END

*----------------------------------------------------------------------------------------

        ASSET.LIAB.IND = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfAssetLiabInd>

        IMPAIR.EFFECTIVE.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfImpairEffDate>

        MARKET.KEY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfMarketKey>
        MARKET.MARGIN = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfMarketMargin>
        MARGIN.OPERAND = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfMarginOperand>

        IF ASSET.LIAB.IND EQ "A" THEN
            BID.OR.OFFER = "O"
        END
        ELSE
            BID.OR.OFFER = "B"
        END

        EIR = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfEir>

*----------------------------------------------------------------------------------------
* Calling the Core routine to calculate the Market Rate by giving the Market Key,Market Margin,Market Operand,
* Currency,Maturity Date of the Contract and the Bid/Offer Rate Marker for the Contract

        CW.CashFlow.EbGetMarketRate(MARKET.KEY,MARKET.RATE,MARKET.MARGIN,MARGIN.OPERAND,CURRENCY,BID.OR.OFFER,MATURITY.DATE,ERR.TXT)

*----------------------------------------------------------------------------------------
* Contractual Cashflow Details

        CONTRACTUAL.CASHFLOW.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashFlowDate>
        CONTRACTUAL.CASHFLOW.AMOUNT = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashFlowAmt>
        CONTRACTUAL.CASHFLOW.CURRENCY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashflowCcy>
        CONTRACTUAL.CASHFLOW.TYPE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashFlowType>

*----------------------------------------------------------------------------------------
* Expected Cashflow Details

        EXPECTED.CASHFLOW.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowDate>
        EXPECTED.CASHFLOW.AMOUNT = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowAmt>
        EXPECTED.CASHFLOW.CURRENCY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowCcy>
        EXPECTED.CASHFLOW.TYPE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowType>

*----------------------------------------------------------------------------------------
* Collateral Details

        EXPECTED.COLLATERAL.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCollDate>
        EXPECTED.COLLATERAL.AMOUNT = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCollAmt>

*----------------------------------------------------------------------------------------
* IFRS.ACCT.BALANCES Details

        CONTRACT.BALANCE = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalContractBalance>

        NPV.CON.CF.AMORT = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvConCfAmort>
        NPV.CON.CF.FV = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvConCfFv>

        NPV.EXP.CF.AMORT = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvExpCfAmort>
        NPV.EXP.CF.FV = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvExpCfFv>
        VAL.EXP.COLL.AMORT = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalValExpCollAmort>
        VAL.EXP.COLL.FV = R.IFRSACCTBALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalValExpCollFv>

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from EB.CASHFLOW and IFRS.ACCT.BALANCES
* each data seperated by '*' to be returned from the routine

* For Reference, the positions in which each data will be hold in the array seperated by '*' are
*-----------------------------------------------------------------------------------------
* EB.CASHFLOW Data
*-----------------------------------------------------------------------------------------
* POS<1> = Transaction Reference , POS<2> = Customer Number , POS<3> = Currency , POS<4> = Value date
* POS<5> = Maturity Date , POS<6> = IAS Classification , POS<7> = Impair Status
* POS<8> = EIR , POS<9> Market Rate
* POS<10> = Contractual Cashflow Date , POS<11> = Contractual Cashflow Amount
* POS<12> = Contractual Cashflow Curreny , POS<13> = Contractual Cashflow Type
* POS<14> = Expected Cashflow Date , POS<15> = Expected Cashflow Amount
* POS<16> = Expected Cashflow Currency , POS<17> = Expected Cashflow Type
* POS<18> = Expected Collateral Date , POS<19> = Expected Collateral Amount , POS<31> = Impairment Date
*-----------------------------------------------------------------------------------------
* IFRS.ACCT.BALANCES Data
*-----------------------------------------------------------------------------------------
* POS<20> = Contract Balance , POS<21> = NPV Contractual Cash flow at EIR
* POS<22> = NPV Contractual Cash flow at Market Rate , POS<23> = NPV Expected Cash flow at EIR
* POS<24> = NPV Expected Cash flow at Market Rate , POS<25> = NPV Collateral at EIR
* POS<26> = NPV  Collateral at FV , POS<27> = Impair Effective Date , POS<28> = Impairment Loss
* POS<29> = Lcy Impairment Loss , POS<30> = Impair Last Calc Date
*-----------------------------------------------------------------------------------------

        ARRAY = TRANS.REF:'*':CUSTOMER.NO:'*':CURRENCY:'*':VALUE.DATE:'*':MATURITY.DATE:'*':IAS.CLASSIFICATION.LOC:'*':IMPAIR.STATUS:'*':EIR:'*':MARKET.RATE
        ARRAY = ARRAY:'*':CONTRACTUAL.CASHFLOW.DATE:'*':CONTRACTUAL.CASHFLOW.AMOUNT:'*':CONTRACTUAL.CASHFLOW.CURRENCY:'*':CONTRACTUAL.CASHFLOW.TYPE
        ARRAY = ARRAY:'*':EXPECTED.CASHFLOW.DATE:'*':EXPECTED.CASHFLOW.AMOUNT:'*':EXPECTED.CASHFLOW.CURRENCY:'*':EXPECTED.CASHFLOW.TYPE
        ARRAY = ARRAY:'*':EXPECTED.COLLATERAL.DATE:'*':EXPECTED.COLLATERAL.AMOUNT
        ARRAY = ARRAY:'*':CONTRACT.BALANCE:'*':NPV.CON.CF.AMORT:'*':NPV.CON.CF.FV:'*':NPV.EXP.CF.AMORT:'*':NPV.EXP.CF.FV:'*':VAL.EXP.COLL.AMORT:'*':VAL.EXP.COLL.FV
        ARRAY = ARRAY:'*':IMPAIR.EFFECTIVE.DATE:'*':IMPAIRMENT.LOSS:'*':LCY.IMPAIRMENT.LOSS:'*':IMPAIR.LAST.CALC.DATE:'*':DATE.IMPAIRED
        Y.DATA<-1> = ARRAY

*-----------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop

        TRANS.REF = ''
        CUSTOMER.NO = ''
        CURRENCY = ''
        VALUE.DATE = ''
        MATURITY.DATE = ''
        IAS.CLASSIFICATION.LOC = ''
        IMPAIR.STATUS = ''
        DATE.IMPAIRMENT = ''

        ACCOUNTING.METHOD = ''

        ASSET.LIAB.IND = ''

        IMPAIR.EFFECTIVE.DATE = ''

        BID.OR.OFFER = ''

        MARKET.KEY = ''
        MARKET.MARGIN = ''
        MARGIN.OPERAND = ''

        EIR = ''
        MARKET.RATE = ''

        CONTRACTUAL.CASHFLOW.DATE = ''
        CONTRACTUAL.CASHFLOW.TYPE = ''
        CONTRACTUAL.CASHFLOW.AMOUNT = ''
        CONTRACTUAL.CASHFLOW.CURRENCY = ''

        EXPECTED.CASHFLOW.DATE = ''
        EXPECTED.CASHFLOW.TYPE = ''
        EXPECTED.CASHFLOW.AMOUNT = ''
        EXPECTED.CASHFLOW.CURRENCY = ''

        EXPECTED.COLLATERAL.DATE = ''
        EXPECTED.COLLATERAL.AMOUNT = ''

        CONTRACT.BALANCE = ''

        NPV.CON.CF.AMORT = ''
        NPV.CON.CF.FV = ''

        NPV.EXP.CF.AMORT = ''
        NPV.EXP.CF.FV = ''
        VAL.EXP.COLL.AMORT = ''
        VAL.EXP.COLL.FV = ''

        IMPAIR.AMC.ADJUST.AMOUNT = ''
        IMPAIR.AMC.ADJUST.LCY.AMOUNT = ''
        UNWIND.AMOUNT = ''
        UNWIND.LCY.AMOUNT = ''
        IMPAIR.AMORTISED.AMOUNT = ''
        IMPAIR.AMORTISED.LCY.AMOUNT = ''
        IMPAIR.FAIRVALUE.AMOUNT = ''
        IMPAIR.FAIRVALUE.LCY.AMOUNT = ''
        IMPAIRMENT.LOSS = ''
        LCY.IMPAIRMENT.LOSS = ''
        IMPAIR.LAST.CALC.DATE = ''

        ERR.TXT = ''

        ARRAY = ''

        IMP.AMC.ADJ.POS = ''
        UND.POS = ''
        AMC.POS = ''
        FVEQ.POS = ''
        FVPL.POS = ''

        EBCASHFLOW.ID = ''
        IFRSACCTBALANCES.ID = ''
        R.EBCASHFLOW = ''
        R.IFRSACCTBALANCES = ''
        POS = ''
        BALANCES = ''
        LCY.BALANCES = ''
        ACCT.CALC.AMT  = ''
        LAST.CALC.DATE = ''

    REPEAT

RETURN

*Loop ends here
*---------------------------------------------------------------------------------------
END

