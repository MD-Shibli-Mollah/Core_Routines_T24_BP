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
* <Rating>1812</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.NOF.TODAY.HIVAL.ENT.SECT(OUT.ARRAY)
*-----------------------------------------------------------------------------
*Description: To show Hi-value Transactions done today
*-----------------------------------------------------------------------------
*Modification History:
**********************
**
* 12/01/12 - Task 335791
*            Change the reads to Service api calls.
*
*-----------------------------------------------------------------------------
*** <region name = File Inserts>

    $INSERT I_CustomerService_Profile

    $USING CR.Analytical
    $USING AC.AccountOpening
    $USING AA.Framework
    $USING DX.Trade
    $USING SC.SctTrading
    $USING SC.SctOffMarketTrades
    $USING MF.Contract
    $USING EB.DataAccess
    $USING ST.ExchangeRate
    $USING CR.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports


*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

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

    RETURN
***</region>

*-------------------------------------------------------------------------

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
        END CASE
    REPEAT

    RETURN

***</region>

*-------------------------------------------------------------------------

*** <region name=  PROCESS.AA>
PROCESS.AA:
***

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    CUST.NO = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>
    custKey = CUST.NO
    customerProfile = ''
    CALL CustomerService.getProfile(custKey, customerProfile)
    SECT = customerProfile<Profile.sector>
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
            IF SECT EQ 1002 THEN
                IF COND.FLG EQ 'TRUE' THEN
                    CR.ModelBank.SetCondFlag(ACCT.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
                END ELSE
                    OUT.FLAG = 'TRUE'
                END
            END
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = ACCT.NO:'*':ACCT.CCY:'*':ACCT.AMT.FCY:'*':ACCT.AMT:'*':TXN.REF
            END

        END
    END
    COND.FLG = '' ; OUT.FLAG = ''
    R.AA = '' ; ACCT.AMT = '' ; ACCT.AMT.FCY = ''
    ACCT.CCY = '' ; OUT.AMT = ''

    RETURN

***</region>

*-------------------------------------------------------------------------

*** <region name=  PROCESS.DX>
PROCESS.DX:
***

    TXN.REF = ''

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>

    DX.CUS = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>

    R.DX = DX.Trade.Trade.Read(TXN.REF, DX.ERR)
    cust = DX.CUS
    customerProfle = ''
    CALL CustomerService.getProfile(cust, customerProfle)
    SECT = customerProfle<Profile.sector>
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

        IF FLG.OUT = 'TRUE' AND SECT EQ 1002 THEN
            IF COND.FLG EQ 'TRUE' THEN
                CR.ModelBank.SetCondFlag(DX.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END ELSE
                OUT.FLAG = 'TRUE'
            END
        END
        IF OUT.FLAG EQ 'TRUE' THEN
            OUT.ARRAY<-1> = DX.ACCT.NO:'*':DX.CCY:'*':DX.FCY.AMT:'*':DX.AMT:'*':TXN.REF
        END

    END
    COND.FLG = '' ; OUT.FLAG = '' ; R.DX = ''
    DX.FCY.AMT = '' ; DX.AMT = '' ; DX.CCY = ''
    OUT.AMT = '' ; FLG.OUT = '' ; CUSTOMER.LIST = ''

    RETURN

***</region>

*-------------------------------------------------------------------------

*** <region name=  PROCESS.MF>
PROCESS.MF:
***

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    CUST.NO = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>


    R.MF.TRADE = MF.Contract.Trade.Read(TXN.REF, MF.ERR)
    cusky = CUST.NO
    customerProfile = ''
    CALL CustomerService.getProfile(cusKy, customerProfile)
    SECT = customerProfile<Profile.sector>
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

            IF SECT EQ 1002 THEN
                IF COND.FLG EQ 'TRUE' THEN
                    CR.ModelBank.SetCondFlag(MF.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
                END ELSE
                    OUT.FLAG = 'TRUE'
                END
            END

            IF MF.AMT EQ '' THEN MF.AMT = 0
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = ACCT.NO:'*':MF.CCY:'*':MF.FCY.AMT:'*':MF.AMT:'*':TXN.REF
            END
        END
    END
    COND.FLG = '' ; OUT.FLAG = '' ; R.MF.TRADE = ''
    MF.AMT = '' ; MF.FCY.AMT = '' ; MF.CCY = ''
    OUT.AMT = ''; FLG.OUT = ''
    RETURN

***</region>

*-------------------------------------------------------------------------

*** <region name=  PROCESS.SEC>
PROCESS.SEC:
***

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>

    SC.CUS = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>
    R.SEC.TRADE = SC.SctTrading.SecTrade.Read(TXN.REF, ST.ERR)
    cukey = SC.CUS
    customerProfile = ''
    CALL CustomerService.getProfile(cukey, customerProfile)
    SECT = customerProfile<Profile.sector>
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

        IF FLG.OUT EQ 'TRUE' AND SECT EQ 1002 THEN
            IF COND.FLG EQ 'TRUE' THEN
                CR.ModelBank.SetCondFlag(SC.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
            END ELSE
                OUT.FLAG = 'TRUE'
            END
        END
        IF OUT.FLAG EQ 'TRUE' THEN
            OUT.ARRAY<-1> = SC.ACCT.NO:'*':SC.CCY:'*':SC.FCY.AMT:'*':SC.AMT:'*':TXN.REF
        END
    END
    COND1.FLAG = '' ; OUT.FLAG = '' ; R.SEC.TRADE = ''
    SC.CCY = '' ; SC.AMT = '' ; SC.FCY.AMT = ''
    OUT.AMT = '' ; FLG.OUT = '' ; CUSTOMER.LIST = ''

    RETURN

***</region>

*-------------------------------------------------------------------------

*** <region name=  PROCESS.SEC.TRANS>
PROCESS.SEC.TRANS:
***

    TXN.REF = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContractId>
    CUST.NO = R.CR.CLOG<CR.Analytical.ContactLog.ContLogContactClient>
    R.SEC.TRANS = SC.SctOffMarketTrades.SecurityTransfer.Read(TXN.REF, SEC.ERR)
    cusID = CUST.NO
    customerProfile = ''
    CALL CustomerService.getProfile(cusID, customerProfile)
    SECT = customerProfile<Profile.sector>
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
            IF SECT EQ 1002 THEN
                IF COND.FLG EQ 'TRUE' THEN
                    CR.ModelBank.SetCondFlag(ST.AMT,ST.AMT.LCY,ST.AMT.LCY.OPR,OUT.FLAG)
                END ELSE
                    OUT.FLAG = 'TRUE'
                END
            END
            IF OUT.FLAG EQ 'TRUE' THEN
                OUT.ARRAY<-1> = ST.ACCT.NO:'*':ST.CCY:'*':ST.FCY.AMT:'*':ST.AMT:'*':TXN.REF
            END
        END
    END
    COND1.FLAG = '' ; OUT.FLAG = '' ;R.SEC.TRANS = ''
    ST.CCY = '' ; ST.AMT = '' ; ST.FCY.AMT = ''
    OUT.AMT = ''

    RETURN

***</region>

*-------------------------------------------------------------------------

*** <region name=  LOCATE.FIELDS>
LOCATE.FIELDS:
***

*** <desc> To get the Selection criteria </desc>

    LOCATE 'AMOUNT.LCY' IN EB.Reports.getDFields()<1> SETTING POS2 THEN
    ST.AMT.LCY  = EB.Reports.getDRangeAndValue()<POS2>
    ST.AMT.LCY.OPR = EB.Reports.getDLogicalOperands()<POS2>
    COND.FLAG = "TRUE"
    END ELSE
    DEF.COND = 1
    END

    RETURN

*** </region>
*-------------------------------------------------------------------------

    END
