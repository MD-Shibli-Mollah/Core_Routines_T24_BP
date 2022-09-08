* @ValidationCode : MjoyMDk1OTc0MzM2OmNwMTI1MjoxNTczNjMxOTk4MTE1OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTEuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Nov 2019 13:29:58
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------
* <Rating>-52</Rating>
*---------------------------------------------------------------------------------------
* Subroutine to select the records of both EB.CASHFLOW and EB.CASHFLOW.HIS for a particular contract or for
* all based on the selection criteria
* attached in STANDARD.SELECTION for the NOFILE enquiry EB.CASHFLOW.SUMMARY
$PACKAGE CW.CashFlow
SUBROUTINE E.MB.EB.CASHFLOW.SUMMARY(Y.DATA)

    $USING CW.CashFlow
    $USING EB.DataAccess
    $USING EB.Reports

*MAIN PROCESSING
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB SELECTFILES

RETURN
*---------------------------------------------------------------------------------------
INITIALISE:
*---------------------------------------------------------------------------------------
*Variables for opening EB.CASHFLOW and EB.CASHFLOW.HIS

    FN.EBCASHFLOW = 'F.EB.CASHFLOW'
    F.EBCASHFLOW = ''

    FN.EBCASHFLOWHIS = 'F.EB.CASHFLOW.HIS'
    F.EBCASHFLOWHIS = ''

*---------------------------------------------------------------------------------------

    SEL.CMD = ''
    SEL1.CMD = ''
    SEL.LIST = ''
    SEL1.LIST = ''
    NO.OF.SEL = ''
    NO.OF.SEL1 = ''
    SEL.ERR = ''
    SEL1.ERR = ''
    EBCASHFLOW.ID = ''
    EBCASHFLOWHIS.ID = ''
    R.EBCASHFLOW = ''
    R.EBCASHFLOWHIS = ''
    POS = ''
    POS1 = ''

*----------------------------------------------------------------------------------------
* Variables to hold the both EB.CASHFLOW and EB.CASHFLOW.HIS Details

    TRANS.REF = ''
    CUSTOMER.NO = ''
    CURRENCY = ''
    VALUE.DATE = ''
    MATURITY.DATE = ''
    IAS.CLASSIFICATION.LOC = ''
    IMPAIR.STATUS = ''

*----------------------------------------------------------------------------------------
* Variables to hold the Contractual Cahflow Details from both EB.CASHFLOW and EB.CASHFLOW.HIS

    CONTRACTUAL.CASHFLOW.DATE = ''
    CONTRACTUAL.CASHFLOW.AMOUNT = ''
    CONTRACTUAL.CASHFLOW.CURRENCY = ''
    CONTRACTUAL.CASHFLOW.TYPE = ''

*----------------------------------------------------------------------------------------
* Variables to hold the Expected Cashflow Details from both EB.CASHFLOW and EB.CASHFLOW.HIS

    EXPECTED.CASHFLOW.DATE = ''
    EXPECTED.CASHFLOW.AMOUNT = ''
    EXPECTED.CASHFLOW.CURRENCY = ''
    EXPECTED.CASHFLOW.TYPE = ''

*-----------------------------------------------------------------------------------------

    ARRAY = ''
    ARRAY1 = ''
    Y.DATA = ''

*---------------------------------------------------------------------------------------
* Getting the Transaction Reference from the Selection Criteria

    LOCATE '@ID' IN EB.Reports.getEnqSelection()<2,1> SETTING TRANS.POS THEN
        TRANS.REFERENCE = EB.Reports.getEnqSelection()<4,TRANS.POS>
    END

RETURN

*---------------------------------------------------------------------------------------
OPENFILES:

    EB.DataAccess.Opf(FN.EBCASHFLOW,F.EBCASHFLOW)
    EB.DataAccess.Opf(FN.EBCASHFLOWHIS,F.EBCASHFLOWHIS)

RETURN

*---------------------------------------------------------------------------------------
SELECTFILES:
*---------------------------------------------------------------------------------------
*Selecting the EB.CASHFLOW record based on the selection criteria

    IF TRANS.REFERENCE EQ '' THEN
        SEL.CMD = 'SELECT ':FN.EBCASHFLOW:' BY @ID'
    END
    ELSE
        SEL.CMD = 'SELECT ':FN.EBCASHFLOW:' WITH @ID LIKE ':TRANS.REFERENCE:'...'
    END

    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.SEL,SEL.ERR)

*---------------------------------------------------------------------------------------
*Loop begins here

    LOOP
        REMOVE EBCASHFLOW.ID FROM SEL.LIST SETTING POS
    WHILE EBCASHFLOW.ID:POS

* Reading the EB.CASHFLOW record for the particular Contract Id

        R.EBCASHFLOW = CW.CashFlow.EbCashflow.Read(EBCASHFLOW.ID, EBCASHFLOW.ERR)

        TRANS.REF = EBCASHFLOW.ID
        CUSTOMER.NO = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCustomerId>
        CURRENCY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCurrency>
        VALUE.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfValueDate>
        MATURITY.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfMaturityDate>
        IAS.CLASSIFICATION.LOC = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfIasClassification>
        IMPAIR.STATUS = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfImpairmentStatus>

        CONTRACTUAL.CASHFLOW.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashFlowDate>
        CONTRACTUAL.CASHFLOW.AMOUNT = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashFlowAmt>
        CONTRACTUAL.CASHFLOW.CURRENCY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashflowCcy>
        CONTRACTUAL.CASHFLOW.TYPE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfCashFlowType>

        EXPECTED.CASHFLOW.DATE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowDate>
        EXPECTED.CASHFLOW.AMOUNT = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowAmt>
        EXPECTED.CASHFLOW.CURRENCY = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowCcy>
        EXPECTED.CASHFLOW.TYPE = R.EBCASHFLOW<CW.CashFlow.EbCashflow.CshfExpCflowType>

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from EB.CASHFLOW
* each data seperated by '*' to be returned from the routine

* For Reference, the positions in which each data will be hold in the array seperated by '*' are
*-----------------------------------------------------------------------------------------
* EB.CASHFLOW Data
*-----------------------------------------------------------------------------------------
* POS<1> = Transaction Reference , POS<2> = Customer Number , POS<3> = Currency , POS<4> = Value date
* POS<5> = Maturity Date , POS<6> = IAS Classification , POS<7> = Impair Status
* POS<8> = Contractual Cashflow Date , POS<9> = Contractual Cashflow Amount
* POS<10> = Contractual Cashflow Curreny , POS<11> = Contractual Cashflow Type
* POS<12> = Expected Cashflow Date , POS<13> = Expected Cashflow Amount
* POS<14> = Expected Cashflow Currency , POS<15> = Expected Cashflow Type

        ARRAY = TRANS.REF:'*':CUSTOMER.NO:'*':CURRENCY:'*':VALUE.DATE:'*':MATURITY.DATE:'*':IAS.CLASSIFICATION.LOC:'*':IMPAIR.STATUS
        ARRAY = ARRAY:'*':CONTRACTUAL.CASHFLOW.AMOUNT:'*':CONTRACTUAL.CASHFLOW.CURRENCY:'*':'*':CONTRACTUAL.CASHFLOW.TYPE:'*':CONTRACTUAL.CASHFLOW.TYPE
        ARRAY = ARRAY:'*':EXPECTED.CASHFLOW.DATE:'*':EXPECTED.CASHFLOW.AMOUNT:'*':EXPECTED.CASHFLOW.CURRENCY:'*':EXPECTED.CASHFLOW.TYPE

        Y.DATA<-1> = ARRAY

*--------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop

        TRANS.REF = ''
        CUSTOMER.NO = ''
        CURRENCY = ''
        VALUE.DATE = ''
        MATURITY.DATE = ''
        IAS.CLASSIFICATION.LOC = ''
        IMPAIR.STATUS = ''

        CONTRACTUAL.CASHFLOW.TYPE = ''
        CONTRACTUAL.CASHFLOW.AMOUNT = ''
        CONTRACTUAL.CASHFLOW.CURRENCY = ''
        CONTRACTUAL.CASHFLOW.DATE = ''

        EXPECTED.CASHFLOW.TYPE = ''
        EXPECTED.CASHFLOW.AMOUNT = ''
        EXPECTED.CASHFLOW.CURRENCY = ''
        EXPECTED.CASHFLOW.DATE = ''

        ARRAY = ''

    REPEAT

*loop ends here
*---------------------------------------------------------------------------------------
*Selecting the EB.CASHFLOW.HIS record based on the selection criteria

    IF TRANS.REFERENCE EQ '' THEN
        SEL1.CMD = 'SELECT ':FN.EBCASHFLOWHIS:' BY-DSND @ID'
    END
    ELSE
        SEL1.CMD = 'SELECT ':FN.EBCASHFLOWHIS:' WITH @ID LIKE ':TRANS.REFERENCE:'... BY-DSND @ID'
    END

    EB.DataAccess.Readlist(SEL1.CMD,SEL1.LIST,'',NO.OF.SEL1,SEL1.ERR)

*---------------------------------------------------------------------------------------
*Loop begins here

    LOOP
        REMOVE EBCASHFLOWHIS.ID FROM SEL1.LIST SETTING POS1
    WHILE EBCASHFLOWHIS.ID:POS1

*Reading the EB.CASHFLOW.HIS record for the particular Contract Id

        R.EBCASHFLOWHIS = CW.CashFlow.EbCashflowHis.Read(EBCASHFLOWHIS.ID, EBCASHFLOWHIS.ERR)

        TRANS.REF = EBCASHFLOWHIS.ID
        CUSTOMER.NO = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfCustomerId>
        CURRENCY = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfCurrency>
        VALUE.DATE = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfValueDate>
        MATURITY.DATE = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfMaturityDate>
        IAS.CLASSIFICATION.LOC = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfIasClassification>
        IMPAIR.STATUS = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfImpairmentStatus>

        CONTRACTUAL.CASHFLOW.DATE = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfCashFlowDate>
        CONTRACTUAL.CASHFLOW.AMOUNT = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfCashFlowAmt>
        CONTRACTUAL.CASHFLOW.CURRENCY = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfCashflowCcy>
        CONTRACTUAL.CASHFLOW.TYPE = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfCashFlowType>

        EXPECTED.CASHFLOW.DATE = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfExpCflowDate>
        EXPECTED.CASHFLOW.AMOUNT = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfExpCflowAmt>
        EXPECTED.CASHFLOW.CURRENCY = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfExpCflowCcy>
        EXPECTED.CASHFLOW.TYPE = R.EBCASHFLOWHIS<CW.CashFlow.EbCashflow.CshfExpCflowType>

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from EB.CASHFLOW
* each data seperated by '*' to be returned from the routine

* For Reference, the positions in which each data will be hold in the array seperated by '*' are
*-----------------------------------------------------------------------------------------
* EB.CASHFLOW Data
*-----------------------------------------------------------------------------------------
* POS<1> = Transaction Reference , POS<2> = Customer Number , POS<3> = Currency , POS<4> = Value date
* POS<5> = Maturity Date , POS<6> = IAS Classification , POS<7> = Impair Status
* POS<8> = Contractual Cashflow Date , POS<9> = Contractual Cashflow Amount
* POS<10> = Contractual Cashflow Curreny , POS<11> = Contractual Cashflow Type
* POS<12> = Expected Cashflow Date , POS<13> = Expected Cashflow Amount
* POS<14> = Expected Cashflow Currency , POS<15> = Expected Cashflow Type

        ARRAY1 = TRANS.REF:'*':CUSTOMER.NO:'*':CURRENCY:'*':VALUE.DATE:'*':MATURITY.DATE:'*':IAS.CLASSIFICATION.LOC:'*':IMPAIR.STATUS
        ARRAY1 = ARRAY1:'*':CONTRACTUAL.CASHFLOW.DATE:'*':CONTRACTUAL.CASHFLOW.AMOUNT:'*':CONTRACTUAL.CASHFLOW.CURRENCY:'*':CONTRACTUAL.CASHFLOW.TYPE
        ARRAY1 = ARRAY1:'*':EXPECTED.CASHFLOW.DATE:'*':EXPECTED.CASHFLOW.AMOUNT:'*':EXPECTED.CASHFLOW.CURRENCY:'*':EXPECTED.CASHFLOW.TYPE

        Y.DATA<-1> = ARRAY1

*--------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop

        TRANS.REF = ''
        CUSTOMER.NO = ''
        CURRENCY = ''
        VALUE.DATE = ''
        MATURITY.DATE = ''
        IAS.CLASSIFICATION.LOC = ''
        IMPAIR.STATUS = ''

        CONTRACTUAL.CASHFLOW.TYPE = ''
        CONTRACTUAL.CASHFLOW.AMOUNT = ''
        CONTRACTUAL.CASHFLOW.CURRENCY = ''
        CONTRACTUAL.CASHFLOW.DATE = ''

        EXPECTED.CASHFLOW.TYPE = ''
        EXPECTED.CASHFLOW.AMOUNT = ''
        EXPECTED.CASHFLOW.CURRENCY = ''
        EXPECTED.CASHFLOW.DATE = ''

        ARRAY1 = ''

    REPEAT

RETURN

*Loop ends here
*---------------------------------------------------------------------------------------
END
