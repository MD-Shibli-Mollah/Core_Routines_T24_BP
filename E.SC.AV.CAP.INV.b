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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.AV.CAP.INV
**********************************************************
*     SUBROUTINE TO CALCULATE AVERAGE CAPITAL INVESTED   *
*    CALLED BY ENQUIRY SC.VAL.MARKET AND
*       SC.VAL.COST
*    AVERAGE CAPITAL INVESTED IS RETURNED AS THE         *
*    PARAMETER
**********************************************************
*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
* 24/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Tidy up. Break into subroutines, remove branch
*            statement, remove inadvised use of common variable
*
* 14/04/11 - DEFECT:186978 TASK:191121
*            In SC.VAL.COST ENQUIRY, Portfolio Valuation gets displayed
*            in reference currency when the reference currency and valuation
*            currency of that particular portfolio are different.
*
* 20/04/15 - 1323085
*            Incorporation of components
*** </region>
*---------------------------------------------------------

    $USING SC.ScoPortfolioMaintenance
    $USING SC.ScvValuationUpdates
    $USING ST.ExchangeRate
    $USING SC.ScvCashAndFundFlow
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Foundation


* calculate no of days since start date
*
*   to calcualte start date
*
    tmp.ID = EB.Reports.getId()
    SAM.ID = FIELD(tmp.ID,".",1)
    EB.Reports.setId(tmp.ID)
    R.SAM = '' ; EB.SystemTables.setEtext('')
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SAM = SC.ScoPortfolioMaintenance.tableSecAccMaster(SAM.ID,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    REF.CCY = R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamReferenceCurrency> ; * BG_100020996
*
    COMPARISON.VALUATION = '' ; CONTRIBUTIONS.YR = ''
    WITHDRAWALS.YR = '' ; AC.ST.DATE = '' ; REPORT.DATE = ''
    SC.ScvValuationUpdates.CalcPerform(R.SAM,AC.ST.DATE,COMPARISON.VALUATION,CONTRIBUTIONS.YR,WITHDRAWALS.YR,REPORT.DATE)
    START.DATE.LOCAL = AC.ST.DATE
*
    D.ST = EB.SystemTables.getToday()[1,4]:"0101"
    T.YEAR = EB.SystemTables.getToday()[1,4]
    T.MONTH = EB.SystemTables.getToday()[5,2]
    T.DAY = EB.SystemTables.getToday()[7,2]
    IN.YEAR = START.DATE.LOCAL[1,4]
    IN.MONTH = START.DATE.LOCAL[5,2]
    IN.DAY = START.DATE.LOCAL[7,2]
    DAT1 = T.DAY:"/":T.MONTH:"/":T.YEAR
    DAT2 = IN.DAY:"/":IN.MONTH:"/":IN.YEAR
    I.DAT1 = ICONV(DAT1,"DE") ; I.DAT2 = ICONV(DAT2,"DE")
    DIFF.DAYS = I.DAT1-I.DAT2
    IF DIFF.DAYS = 0 THEN
        DIFF.DAYS = 1
    END
    REC.FUND.FLOW = ''
    V$ERROR = ''
    REC.FUND.FLOW = SC.ScvCashAndFundFlow.tableFundFlow(SAM.ID,V$ERROR)

    IF REC.FUND.FLOW<SC.ScvCashAndFundFlow.FundFlow.SffAmtRefCcy> = '' OR REC.FUND.FLOW<SC.ScvCashAndFundFlow.FundFlow.SffDate> = '' THEN
        AV.CAP.INV = 0
    END ELSE ; * BG_100020996
        GOSUB CALC.AV.INV.CAP.FROM.FF ; *Calculate average invested capital from fund flow ; * BG_100020996
    END ; * BG_100020996
*
* format to ref currency
*
    EB.Foundation.ScFormatCcyAmt(REF.CCY,AV.CAP.INV)

    CCY1 = R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamReferenceCurrency>
    CCY2 =  R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamValuationCurrency>
    IF CCY1 NE CCY2 AND AV.CAP.INV THEN
        VAL1 = AV.CAP.INV
        VAL2 = ''
        RET.CODE = ''
        RATE = ''
        ST.ExchangeRate.Exchrate("1",CCY1,VAL1,CCY2,VAL2,'',RATE,'','',RET.CODE)
        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(tmp.ETEXT) THEN
            EB.SystemTables.setEtext(tmp.ETEXT)
            EB.Reports.setOData(VAL2)
        END
    END  ELSE
        EB.Reports.setOData(AV.CAP.INV)
    END

    RETURN

*-----------------------------------------------------------------------------
*** <region name= CALC.AV.INV.CAP.FROM.FF>
CALC.AV.INV.CAP.FROM.FF:
*** <desc>Calculate average invested capital from fund flow </desc>

    FF.DATES = REC.FUND.FLOW<SC.ScvCashAndFundFlow.FundFlow.SffDate>
    CONVERT @SM TO @VM IN FF.DATES
    REF.CCY.AMTS = REC.FUND.FLOW<SC.ScvCashAndFundFlow.FundFlow.SffAmtRefCcy>
    CONVERT @SM TO @VM IN REF.CCY.AMTS
    NO.ENTRY = DCOUNT(FF.DATES,@VM)
    AV.CAP.INV = 0
    FOR I = 1 TO NO.ENTRY
        VAL.DATE = FF.DATES<1,I>
        *
        IF VAL.DATE GE START.DATE.LOCAL THEN
            VAL.YEAR = VAL.DATE[1,4]
            VAL.MONTH = VAL.DATE[5,2]
            VAL.DAY = VAL.DATE[7,2]
            VAL.DATE = VAL.DAY:"/":VAL.MONTH:"/":VAL.YEAR
            I.VAL = ICONV(VAL.DATE,"DE")
            NO.DAY.HELD = I.DAT1-I.VAL
            YAMT = REF.CCY.AMTS<1,I>*NO.DAY.HELD/DIFF.DAYS ; * BG_10002996
            AV.CAP.INV = AV.CAP.INV + YAMT ; * BG_100020996
        END
    NEXT I
*
    IF START.DATE.LOCAL[4] = '0101' THEN
        AV.CAP.INV += COMPARISON.VALUATION
    END

    RETURN
*** </region>


    END
