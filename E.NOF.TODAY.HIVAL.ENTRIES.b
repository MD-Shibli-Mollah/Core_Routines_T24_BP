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
* <Rating>1840</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.NOF.TODAY.HIVAL.ENTRIES(OUT.ARRAY)
*-----------------------------------------------------------------------------
*Description: To show Hi-value Transactions done today
*-----------------------------------------------------------------------------
* Modification History:
***********************
*
* 26/04/12 - Enhancement : 355772 ; Task: 395046
*            To show FUNDS.TRANSFER also, if any large volume transactions are done
*             in descending order by  local currency amount
*
*-----------------------------------------------------------------------------
*** <region name = File Inserts>

    $USING CR.Analytical
    $USING AC.AccountOpening
    $USING AA.Framework
    $USING DX.Trade
    $USING SC.SctTrading
    $USING SC.SctOffMarketTrades
    $USING MF.Contract
    $USING FT.Contract
    $USING EB.DataAccess
    $USING ST.ExchangeRate
    $USING CR.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports


***</region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS
    GOSUB SORT.OUT.ARRAY ; *Sorting selected list in descending order by local currency amount

    RETURN
*-----------------------------------------------------------------------------

*** <region name=  INIALISE>
INITIALISE:
***

*** <desc> To initialise variables and open files. </desc>

    CCY.MKT = '1'

    FN.CR.CON.LOG = 'F.CR.CONTACT.LOG' ; F.CR.CON.LOG = ''
    EB.DataAccess.Opf(FN.CR.CON.LOG,F.CR.CON.LOG)

    F.AA.ARRANGEMENT = ''

    F.DX.TRADE = ''

    F.SEC.TRADE = ''

    F.MF.TRADE = ''

    F.SECURITY.TRANSFER = ''

    F.ACCOUNT = ''

    F.FUNDS.TRANSFER = ''

    F.CUSTOMER.ACCOUNT = ''

    RETURN

***</region>

*-----------------------------------------------------------------------------
*** <region name=  PROCESS>
PROCESS:
***

***<desc> Process and pass the out.array </desc>

    GOSUB LOCATE.FIELDS

    SEL.CMD = 'SELECT ':FN.CR.CON.LOG:' BY APPL.VERSION WITH CONTACT.DATE EQ ':EB.SystemTables.getToday()

    EB.DataAccess.Readlist(SEL.CMD,CR.LIST,"","","")

    LOOP
        REMOVE CR.NO FROM CR.LIST SETTING PO
    WHILE CR.NO
        R.CR.CLOG = CR.Analytical.ContactLog.Read(CR.NO, CR.ERR)
        APPL.NAME = FIELD(R.CR.CLOG<CR.Analytical.ContactLog.ContLogApplVersion>,',',1)

        BEGIN CASE
            CASE APPL.NAME = 'AA.ARRANGEMENT'
                GOSUB PROCESS.AA
            CASE APPL.NAME = 'DX.TRADE'
                GOSUB PROCESS.DX
            CASE APPL.NAME = 'MF.TRADE'
                GOSUB PROCESS.MF
            CASE APPL.NAME = 'SEC.TRADE'
                GOSUB PROCESS.SEC
            CASE APPL.NAME = 'SECURITY.TRANSFER'
                GOSUB PROCESS.SEC.TRANS
            CASE APPL.NAME = 'FUNDS.TRANSFER'
                GOSUB PROCESS.FT ; *Funds transfer records with accounts having portfolio no's are porcessed
        END CASE
    REPEAT

    RETURN

*** </region>

*-----------------------------------------------------------------------------
*** <region name=  PROCESS.AA>
PROCESS.AA:
***

    COND1.FLAG = '' ; OUT.FLAG = ''
    R.AA = '' ; ACCT.AMT = '' ; ACCT.AMT.FCY = ''
    ACCT.CCY = ''
    OUT.AMT = ''
    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    R.AA = AA.Framework.Arrangement.Read(TXN.REF, AA.ERR)
    IF R.AA NE '' THEN
        ACCT.NO = R.AA<AA.Framework.Arrangement.ArrLinkedApplId>
        IF INT(ACCT.NO) THEN
            R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.NO, ACCT.ERR)

            ACCT.CCY = R.ACCOUNT<AC.AccountOpening.Account.Currency>
            ACCT.AMT = R.ACCOUNT<AC.AccountOpening.Account.WorkingBalance>

            IF ACCT.CCY NE EB.SystemTables.getLccy() THEN
                EXCH.RATE = ''
                tmp.LCCY = EB.SystemTables.getLccy()
                ST.ExchangeRate.Exchrate(CCY.MKT, ACCT.CCY, ACCT.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", "", RET.CODE)
                EB.SystemTables.setLccy(tmp.LCCY)
                ACCT.AMT.FCY = ACCT.AMT
                ACCT.AMT = OUT.AMT
                IF ACCT.AMT EQ '' THEN ACCT.AMT = 0
            END

            IF DEF.COND EQ 1 THEN
                IF ACCT.AMT GT 100000 OR ACCT.AMT LT -100000 THEN
                    OUT.FLAG = 'TRUE'
                END
            END ELSE
                CR.ModelBank.SetCondFlag(ACCT.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = ACCT.NO:'*':ACCT.CCY:'*':ACCT.AMT.FCY:'*':ACCT.AMT:'*':TXN.REF
            END
        END
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------
*** <region name=  PROCESS.DX>
PROCESS.DX:
***
    TXN.REF = ''

    COND1.FLAG = '' ; OUT.FLAG = '' ; R.DX = ''
    DX.FCY.AMT = '' ; DX.AMT = '' ; DX.CCY = ''
    OUT.AMT = '' ; FLG.OUT = '' ; CUSTOMER.LIST = ''

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    DX.CUS = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>

    R.DX = DX.Trade.Trade.Read(TXN.REF, DX.ERR)
    IF R.DX NE '' THEN
        CUSTOMER.LIST = R.DX<DX.Trade.Trade.TraPriCustNo>
        FLD.CNT = DCOUNT(CUSTOMER.LIST,@VM)

        IF FLD.CNT EQ 1 THEN
            DX.ACCT.NO = R.DX<DX.Trade.Trade.TraPriAccount,1>
            IF INT(DX.ACCT.NO) THEN
                FLG.OUT = "TRUE"
                DX.CCY = R.DX<DX.Trade.Trade.TraPriRefCcy,1>
                DX.AMT = R.DX<DX.Trade.Trade.TraPriNetCost,1>
                IF DX.CCY NE EB.SystemTables.getLccy() THEN
                    EXCH.RATE = ''
                    tmp.LCCY = EB.SystemTables.getLccy()
                    ST.ExchangeRate.Exchrate(CCY.MKT, DX.CCY, DX.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", LOCAL.AMOUNT, RET.CODE)
                    EB.SystemTables.setLccy(tmp.LCCY)
                    DX.FCY.AMT = DX.AMT
                    DX.AMT = OUT.AMT
                END
            END
        END ELSE
            CONVERT @VM TO @FM IN CUSTOMER.LIST
            LOOP
                REMOVE CUST.NO FROM CUSTOMER.LIST SETTING POS1
            WHILE CUST.NO
                IF CUST.NO EQ DX.CUS THEN
                    DX.ACCT.NO = R.DX<DX.Trade.Trade.TraPriAccount,POS1>
                    IF INT(DX.ACCT.NO) THEN
                        FLG.OUT = "TRUE"
                        DX.CCY = R.DX<DX.Trade.Trade.TraPriRefCcy,POS1>
                        DX.AMT += R.DX<DX.Trade.Trade.TraPriNetCost,POS1>
                        IF DX.CCY NE EB.SystemTables.getLccy() THEN
                            EXCH.RATE = ''
                            tmp.LCCY = EB.SystemTables.getLccy()
                            ST.ExchangeRate.Exchrate(CCY.MKT, DX.CCY, DX.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", LOCAL.AMOUNT, RET.CODE)
                            EB.SystemTables.setLccy(tmp.LCCY)
                            DX.FCY.AMT = DX.AMT
                            DX.AMT = OUT.AMT
                        END
                        IF DX.CCY NE EB.SystemTables.getLccy() THEN
                            EXCH.RATE = ''
                            tmp.LCCY = EB.SystemTables.getLccy()
                            ST.ExchangeRate.Exchrate(CCY.MKT, DX.CCY, DX.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", LOCAL.AMOUNT, RET.CODE)
                            EB.SystemTables.setLccy(tmp.LCCY)
                            DX.FCY.AMT = DX.AMT
                            DX.AMT = OUT.AMT
                        END
                    END
                END
            REPEAT
        END
        IF DX.AMT EQ '' THEN DX.AMT = 0
        IF FLG.OUT = 'TRUE' THEN
            IF DEF.COND EQ 1 THEN
                IF DX.AMT GT 100000 OR DX.AMT LT -100000 THEN
                    OUT.FLAG = 'TRUE'
                END
            END ELSE
                CR.ModelBank.SetCondFlag(DX.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = DX.ACCT.NO:'*':DX.CCY:'*':DX.FCY.AMT:'*':DX.AMT:'*':TXN.REF
            END
        END
    END

    RETURN
***</region>

*-----------------------------------------------------------------------------
*** <region name=  PROCESS.MF>
PROCESS.MF:
***
    COND1.FLAG = '' ; OUT.FLAG = '' ; R.MF.TRADE = ''
    MF.AMT = '' ; MF.FCY.AMT = '' ; MF.CCY = ''
    OUT.AMT = ''; FLG.OUT = ''
    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    R.MF.TRADE = MF.Contract.Trade.Read(TXN.REF, MF.ERR)
    IF R.MF.TRADE NE '' THEN
        ACCT.NO = R.MF.TRADE<MF.Contract.Trade.TrdSettlementAcc>
        IF INT(ACCT.NO) THEN
            MF.CCY = R.MF.TRADE<MF.Contract.Trade.TrdSettlementCcy>
            MF.AMT = R.MF.TRADE<MF.Contract.Trade.TrdCuNetAmt>

            IF MF.CCY NE EB.SystemTables.getLccy() THEN
                EXCH.RATE = ''
                tmp.LCCY = EB.SystemTables.getLccy()
                ST.ExchangeRate.Exchrate(CCY.MKT, MF.CCY, MF.AMT, tmp.LCCY, OUT.AMT, "",EXCH.RATE, "", LOCAL.AMOUNT,RET.CODE)
                EB.SystemTables.setLccy(tmp.LCCY)
                MF.FCY.AMT = MF.AMT
                MF.AMT = OUT.AMT
            END
            IF DEF.COND EQ 1 THEN
                IF MF.AMT GT 100000 OR MF.AMT LT -100000 THEN
                    OUT.FLAG = 'TRUE'
                END
            END ELSE
                CR.ModelBank.SetCondFlag(MF.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END
            IF MF.AMT EQ '' THEN MF.AMT = 0
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = ACCT.NO:'*':MF.CCY:'*':MF.FCY.AMT:'*':MF.AMT:'*':TXN.REF
            END
        END
    END

    RETURN
***</region>

*-----------------------------------------------------------------------------

***<region name=  PROCESS.SEC>
PROCESS.SEC:
***
    COND1.FLAG = '' ; OUT.FLAG = '' ; R.SEC.TRADE = ''
    SC.CCY = '' ; SC.AMT = '' ; SC.FCY.AMT = ''
    OUT.AMT = '' ; FLG.OUT = '' ; CUSTOMER.LIST = ''

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    SC.CUS = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>
    R.SEC.TRADE = SC.SctTrading.SecTrade.Read(TXN.REF, ST.ERR)
    IF R.SEC.TRADE NE '' THEN
        CUSTOMER.LIST = R.SEC.TRADE<SC.SctTrading.SecTrade.SbsCustomerNo>
        FLD.CNT = DCOUNT(CUSTOMER.LIST,@VM)

        IF FLD.CNT EQ 1 THEN
            IF SC.CUS EQ R.SEC.TRADE<SC.SctTrading.SecTrade.SbsCustomerNo,1> THEN
                SC.ACCT.NO = R.SEC.TRADE<SC.SctTrading.SecTrade.SbsCustAccNo,1>
                IF INT(SC.ACCT.NO) THEN
                    FLG.OUT = 'TRUE'
                    SC.CCY = R.SEC.TRADE<SC.SctTrading.SecTrade.SbsSecurityCurrency,1>
                    SC.AMT = R.SEC.TRADE<SC.SctTrading.SecTrade.SbsCuNetAmTrd,1>
                    IF SC.CCY NE EB.SystemTables.getLccy() THEN
                        EXCH.RATE = ''
                        tmp.LCCY = EB.SystemTables.getLccy()
                        ST.ExchangeRate.Exchrate(CCY.MKT, SC.CCY, SC.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", LOCAL.AMOUNT, RET.CODE)
                        EB.SystemTables.setLccy(tmp.LCCY)
                        SC.FCY.AMT = SC.AMT
                        SC.AMT = OUT.AMT
                    END
                END
            END
        END ELSE
            CONVERT @VM TO @FM IN CUSTOMER.LIST
            LOOP
                REMOVE CUST.NO FROM CUSTOMER.LIST SETTING POS1
            WHILE CUST.NO
                IF CUST.NO EQ SC.CUS THEN
                    SC.ACCT.NO = R.SEC.TRADE<SC.SctTrading.SecTrade.SbsCustAccNo,POS1>
                    IF INT(SC.ACCT.NO) THEN
                        FLG.OUT = 'TRUE'
                        SC.CCY = R.SEC.TRADE<SC.SctTrading.SecTrade.SbsSecurityCurrency,POS1>
                        SC.AMT += R.SEC.TRADE<SC.SctTrading.SecTrade.SbsCuNetAmTrd,POS1>
                        IF SC.CCY NE EB.SystemTables.getLccy() THEN
                            EXCH.RATE = ''
                            tmp.LCCY = EB.SystemTables.getLccy()
                            ST.ExchangeRate.Exchrate(CCY.MKT, SC.CCY, SC.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", LOCAL.AMOUNT, RET.CODE)
                            EB.SystemTables.setLccy(tmp.LCCY)
                            SC.FCY.AMT = SC.AMT
                            SC.AMT = OUT.AMT
                        END
                    END
                END
            REPEAT
        END
        IF SC.AMT EQ '' THEN SC.AMT = 0
        IF FLG.OUT EQ 'TRUE' THEN
            IF DEF.COND EQ 1 THEN
                IF SC.AMT GT 100000 OR SC.AMT LT -100000 THEN
                    OUT.FLAG = 'TRUE'
                END
            END ELSE
                CR.ModelBank.SetCondFlag(SC.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = SC.ACCT.NO:'*':SC.CCY:'*':SC.FCY.AMT:'*':SC.AMT:'*':TXN.REF
            END
        END
    END


    RETURN

***</region>

*-----------------------------------------------------------------------------

*** <region name=  PROCESS.SEC.TRANS>
PROCESS.SEC.TRANS:
***
    COND1.FLAG = '' ; OUT.FLAG = '' ;R.SEC.TRANS = ''
    ST.CCY = '' ; ST.AMT = '' ; ST.FCY.AMT = ''
    OUT.AMT = ''

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    R.SEC.TRANS = SC.SctOffMarketTrades.SecurityTransfer.Read(TXN.REF, SEC.ERR)
    IF R.SEC.TRANS NE '' THEN
        ST.ACCT.NO = R.SEC.TRANS<SC.SctOffMarketTrades.SecurityTransfer.ScStrCuAccountNo>
        IF INT(ST.ACCT.NO) THEN
            ST.CCY = R.SEC.TRANS<SC.SctOffMarketTrades.SecurityTransfer.ScStrSecurityCcy>
            ST.AMT = R.SEC.TRANS<SC.SctOffMarketTrades.SecurityTransfer.ScStrNetAmtSecCcy>
            IF ST.CCY NE EB.SystemTables.getLccy() THEN
                EXCH.RATE = ''
                tmp.LCCY = EB.SystemTables.getLccy()
                ST.ExchangeRate.Exchrate(CCY.MKT, ST.CCY, ST.AMT, tmp.LCCY, OUT.AMT, "", EXCH.RATE, "", LOCAL.AMOUNT, RET.CODE)
                EB.SystemTables.setLccy(tmp.LCCY)
                ST.FCY.AMT = ST.AMT
                ST.AMT = OUT.AMT
            END
            IF ST.AMT EQ '' THEN ST.AMT = 0
            IF DEF.COND EQ 1 THEN
                IF ST.AMT GT 100000 OR ST.AMT LT -100000 THEN
                    OUT.FLAG = 'TRUE'
                END
            END ELSE
                CR.ModelBank.SetCondFlag(ST.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = ST.ACCT.NO:'*':ST.CCY:'*':ST.FCY.AMT:'*':ST.AMT:'*':TXN.REF
            END
        END
    END


    RETURN

***</region>

*-----------------------------------------------------------------------------

*** <region name=  PROCESS.LOCATE.FIELDS>
LOCATE.FIELDS:
***

***<desc> To get the Selection criteria </desc>

    LOCATE 'AMOUNT.LCY' IN EB.Reports.getDFields()<1> SETTING POS2 THEN
    ST.AMT.LCY  = EB.Reports.getDRangeAndValue()<POS2>
    ST.AMT.LCY.OPR = EB.Reports.getDLogicalOperands()<POS2>
    COND.FLAG = "TRUE"
    END ELSE
    DEF.COND = 1
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= SORT.OUT.ARRAY>
SORT.OUT.ARRAY:
*** <desc>Sorting selected list in descending order by local currency amount </desc>
    COUNT.ARRAY = '' ; I = '' ; J = ''
    X.ARRAY = '' ; X.VAL = ''
    Y.ARRAY = '' ; Y.VAL = ''
    TEMP.VAL = ''

    COUNT.ARRAY = DCOUNT(OUT.ARRAY,@FM)

    FOR I = 1 TO COUNT.ARRAY-1
        X.ARRAY  = OUT.ARRAY<I+1>
        X.VAL = FIELD(X.ARRAY,'*',4)

        FOR J=1 TO I
            Y.ARRAY = OUT.ARRAY<J>
            Y.VAL = FIELD(Y.ARRAY,'*',4)
            IF Y.VAL LT X.VAL THEN
                TEMP.VAL = Y.ARRAY
                OUT.ARRAY<J> = OUT.ARRAY<I+1>
                OUT.ARRAY<I+1> = TEMP.VAL

            END
        NEXT J

    NEXT I
    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS.FT>
PROCESS.FT:
*** <desc>Funds transfer records with accounts having portfolio no's are porcessed </desc>
    TXN.REF = '' ; FT.CUS = ''
    FLG.OUT = '' ; FT.CCY = ''
    FT.AMT = '' ; FT.FCY.AMT = ''
    OUT.FLAG = ''

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    FT.CUS = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>

    CUS.ACC.ERR = '' ; R.CUSTOMER.ACCOUNT = ''
    R.CUSTOMER.ACCOUNT = AC.AccountOpening.CustomerAccount.Read(FT.CUS, CUS.ACC.ERR)

    FT.ERR = '' ; R.FUNDS.TRANSFER = ''
    R.FUNDS.TRANSFER = FT.Contract.FundsTransfer.Read(TXN.REF, FT.ERR)
    CR.ACCOUNT.NO = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.CreditAcctNo>
    DB.ACCOUNT.NO =  R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.DebitAcctNo>

    LOCATE CR.ACCOUNT.NO IN R.CUSTOMER.ACCOUNT<AC.AccountOpening.CustomerAccount.EbCacAccountNumber> SETTING POS THEN
    FT.ACCT.NO = CR.ACCOUNT.NO
    GOSUB READ.ACCOUNT.APP ; *Read account application; to check account belongs to some portfolio
    IF INT(FT.ACCT.NO) AND PORT.NO THEN
        FLG.OUT = 'TRUE'
        FT.CCY = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.CreditCurrency>
        FT.AMT = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.LocAmtCredited>
        FT.FCY.AMT = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.AmountCredited>[4,99]
    END
    END ELSE
    LOCATE DB.ACCOUNT.NO IN R.CUSTOMER.ACCOUNT<AC.AccountOpening.CustomerAccount.EbCacAccountNumber> SETTING POS THEN
    FT.ACCT.NO = DB.ACCOUNT.NO
    GOSUB READ.ACCOUNT.APP ; *Read account application; to check account belongs to some portfolio
    IF INT(FT.ACCT.NO) AND PORT.NO THEN
        FLG.OUT = 'TRUE'
        FT.CCY = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.DebitCurrency>
        FT.AMT = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.LocAmtDebited>
        FT.FCY.AMT = R.FUNDS.TRANSFER<FT.Contract.FundsTransfer.AmountDebited>[4,99]
    END
    END
    END

    IF FT.AMT = '' THEN FT.AMT = 0

    IF FLG.OUT EQ 'TRUE' THEN
        IF DEF.COND EQ 1 THEN
            IF FT.AMT GT 100000 OR FT.AMT LT -100000 THEN
                OUT.FLAG = 'TRUE'
            END
        END ELSE
            CR.ModelBank.SetCondFlag(FT.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
        END
        IF OUT.FLAG EQ 'TRUE' THEN
            OUT.ARRAY<-1> = FT.ACCT.NO:'*':FT.CCY:'*':FT.FCY.AMT:'*':FT.AMT:'*':TXN.REF
        END
    END


    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= READ.ACCOUNT.APP>
READ.ACCOUNT.APP:
*** <desc>Read account application; to check account belongs to some portfolio </desc>
    R.ACCOUNT = '' ; ACC.ERR = '' ; PORT.NO = ''
    R.ACCOUNT = AC.AccountOpening.Account.Read(FT.ACCT.NO, ACC.ERR)
    PORT.NO = R.ACCOUNT<AC.AccountOpening.Account.PortfolioNo>

    RETURN
*** </region>

    END
