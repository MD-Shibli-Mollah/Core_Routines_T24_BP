* @ValidationCode : MjotMTc4MzgyNjY4NjpjcDEyNTI6MTYwMTE5NjI3NTIwMTptYW5pc2VrYXJhbmthcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzotMTotMQ==
* @ValidationInfo : Timestamp         : 27 Sep 2020 14:14:35
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : manisekarankar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>74</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IA.ModelBank
SUBROUTINE E.MB.NOF.IFRS.ACCT.HEAD(Y.DATA)
*-----------------------------------------------------------------------------
*
* This is the new nofile routine to get details from IFRS.ACCT.BALANCES. It is attached to IMPAIR.DETAILS enquiry.
*
*-----------------------------------------------------------------------------
* MODIFICATION.DETAILS:
*
* 10/06/13 - Defect 660554 / Task 699193
*            Changes done to calculate previous impairement amount and return with Y.DATA
*
* 26/05/14 - Enhancement - 981590 / Task - 990441
*            Changes done to support impairment for EIR based SC.TRADING.POSITION
*
* 19/09/20 - Enhancement 3934727 / Task 3940804
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING LD.Contract
    $USING MM.Contract
    $USING SL.Loans
    $USING IA.Config
    $USING RE.ConBalanceUpdates
    $USING BF.ConBalanceUpdates
    $USING EB.DataAccess
    $USING EB.Reports

    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------

INIT:
*****
    LOCATE '@ID' IN EB.Reports.getDFields()<1> SETTING Y.FLD.POS THEN
        Y.TRANS.REF = EB.Reports.getDRangeAndValue()<1,Y.FLD.POS>
    END

    FN.APPLICATION = ''
    CCY.FIELD = ''
    CUS.ID = ''
    CONT.CURRENCY = ''
    CONT.CUSTOMER = ''

    BEGIN CASE
        CASE Y.TRANS.REF[1,2] = 'LD'
            FN.APPLICATION = 'F.LD.LOANS.AND.DEPOSITS'
            CCY.FIELD = LD.Contract.LoansAndDeposits.Currency
            CUS.ID = LD.Contract.LoansAndDeposits.CustomerId

        CASE Y.TRANS.REF[1,2] = 'MM'
            FN.APPLICATION = 'F.MM.MONEY.MARKET'
            CCY.FIELD  =  MM.Contract.MoneyMarket.Currency
            CUS.ID = MM.Contract.MoneyMarket.CustomerId

        CASE Y.TRANS.REF[1,2] = 'SL'
            FN.APPLICATION = 'F.SL.LOANS'
            CCY.FIELD  = SL.Loans.Loans.LnDealCurrency
            CUS.ID = SL.Loans.Loans.LnCustomer

        CASE Y.TRANS.REF MATCHES '1-10N"-"1-3N"."1-12X'
            FN.APPLICATION = 'F.EB.CONTRACT.BALANCES'
            CCY.FIELD  = BF.ConBalanceUpdates.EbContractBalances.EcbCurrency
            CUS.ID = BF.ConBalanceUpdates.EbContractBalances.EcbCustomer

        CASE 1
            FN.APPLICATION = 'F.ACCOUNT'
            CCY.FIELD = AC.AccountOpening.Account.Currency
            CUS.ID = AC.AccountOpening.Account.Customer
    END CASE


    F.APPLICATION = ''
    EB.DataAccess.Opf(FN.APPLICATION, F.APPLICATION)

    Y.ERR = ""
    R.IFRS.ACCT.BALANCES = IA.Config.IfrsAcctBalances.Read(Y.TRANS.REF, Y.ERR)
    IF Y.ERR THEN RETURN
    Y.CHECK.VAL = 'AMORTISED':@FM:'DISCLOSURE':@FM:'FAIRVALUE'
    LAST.BAL.LIST = 'IMPAIR.AMORTISED':@FM:'IMPAIR.FAIRVALUE':@FM:'AMORT.UNDER.IMP':@FM:'IMPAIR.FAIRVALUE'
    PREV.IMPAIR.BAL = 0

    EB.DataAccess.FRead(FN.APPLICATION, Y.TRANS.REF, R.APP.REC, F.APPLICATION, ERR)
    CONT.CURRENCY = R.APP.REC<CCY.FIELD>
    CONT.CUSTOMER = R.APP.REC<CUS.ID>

RETURN
*-----------------------------------------------------------------------------

PROCESS:
********

    LOOP
        REMOVE Y.LOCATE.VAL FROM Y.CHECK.VAL SETTING Y.POS
    WHILE Y.LOCATE.VAL:Y.POS

        FINDSTR Y.LOCATE.VAL IN R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType> SETTING AF.IDX,AS.IDX THEN
            DEL R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType,AS.IDX>
            DEL R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance,AS.IDX>
            DEL R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLcyBalance,AS.IDX>
            DEL R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcDate,AS.IDX>
            DEL R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt,AS.IDX>
            DEL R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLstCalLcyAmt,AS.IDX>
        END
    REPEAT
    Y.ACCT.CNT = DCOUNT(R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType>,@VM)

    FOR II=1 TO Y.ACCT.CNT
        ACCT.HEAD =  R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType,II>
        LOCATE ACCT.HEAD IN LAST.BAL.LIST SETTING POS THEN
            PREV.IMPAIR.BAL += R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt,II>
        END ELSE
            PREV.IMPAIR.BAL += R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance,II>
        END

        R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType,II> = OCONV(R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType,II>,"MCT")
        CONVERT '.' TO " " IN R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType,II>
    NEXT II

    IF R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance> OR R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLcyBalance> OR R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt> THEN
        Y.DATA = Y.TRANS.REF:'*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalContractBalance>:'*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType>:'*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance>
        Y.DATA := '*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt>:'*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLcyBalance>:'*':PREV.IMPAIR.BAL
        Y.DATA := '*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLstCalLcyAmt>:'*':R.IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcDate>:'*':CONT.CURRENCY:'*':CONT.CUSTOMER
    END ELSE
        Y.DATA = ""
    END

RETURN
*-----------------------------------------------------------------------------
END
