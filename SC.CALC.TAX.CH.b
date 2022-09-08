* @ValidationCode : MjotMTg3MTE3NTUyNDpDcDEyNTI6MTU4NDY5MjkzNDI3ODpydmFyYWRoYXJhamFuOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDo0MzA6MjI5
* @ValidationInfo : Timestamp         : 20 Mar 2020 13:58:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 229/430 (53.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*Version on 9 12/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>518</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SC.SctTaxes
SUBROUTINE SC.CALC.TAX.CH (MAT VALU)
*
    PROG.ID = 'SC.CALC.TAX.CH'
    EQU TRUE TO 1 , FALSE TO '', GENEVA.STOCK.EXCHANGE LIT '003'
*
* 23/07/02 - GLOBUS_CI_10001993
*            Outgoing parameter ST.TAX.DETAILS is set.
*
* 12/01/04 - EN_10002140
*            For MB (Multi Book) purposes PARAMETER routine ID has been
*            converted to hold the current COMPANY ID along with the OLD ID
*            and instead of F.READ statement from calling routine for this
*            PARAMETER file, a core program EB.READ.PARAMETER
*            is called to read the PARAMETER record.
*
* 30/08/04 - CI_10022714
*            Defaulting of TAX.CODE for STAMP.TAX
*
* 26/04/06 - EN_10002900
*            SC Parameter records to be read using EB.READ.PARAMETER
*
* 18/12/07 - GLOBUS_BG_100016348
*            Item is marked as Obsolete
*
* 20/07/10 - 68871: Amend SC routines to use the Customer Service API's
*
* 21-01-16 - 1603791
*            Incorporation of components
*
* 17/02/16 - Enhancement 1192721/ Task 1634927
*            Reclassification of the units to ST module
*
* 13/02/19 - Enhancement 2987792/Sub-Enh 2987798/ Task 2987801
*            Tax code derivation process for Swiss Stamp Duty Tax Calculation
*
*************************************************************************
*
    $INSERT I_CustomerService_Profile

    $USING SC.ScoSecurityMasterMaintenance
    $USING SC.Config
    $USING ST.CompanyCreation
    $USING SC.SctTaxes
    $USING SC.ScoPortfolioMaintenance
    $USING CG.ChargeConfig
    $USING SC.SctTrading
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.Service
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING ST.Valuation

*
*************************************************************************
*
* EQUATE VARIABLES
*
*************************************************************************
*
* Incoming
*
    DIM VALU(55)
    EQU NOMINAL.NO TO VALU(1), VALUE.DATE TO VALU(2),
    TRADE.DATE TO VALU(3), MATURITY.DATE TO VALU(4),
    GROSS.AMT.SEC.CCY TO VALU(5), GROSS.AMT.TRADE.CCY TO VALU(6),
    SECURITY.NO TO VALU(7), CCY.OF.SECURITY TO VALU(8),
    DEAL.CURRENCY TO VALU(9), CUSTOMER.FLAG TO VALU(10),
    NEW.ISSUE.IND TO VALU(11), INTEREST.AMT TO VALU(12),
    NET.AMT.TRADE.CCY TO VALU(13), TRADE.PRICE TO VALU(14),
    NET.TRADE TO VALU(15), TRANSACTION.TYPE TO VALU(16),
    EXCHANGE.RATE TO VALU(17), PRICE.CODE TO VALU(18),
    STK.EXC.COUNTRY TO VALU(19), CUSTOMER.NO TO VALU(20),
    STOCK.EXCH TO VALU(33), PORTFOLIO TO VALU(34)
*
    CATEGORIES.ONLY = EB.SystemTables.getLocalSix() ;* replaced EQU with = & incorporated LOCAL6
*
* Outgoing
*
    EQU SWISS.STAMP.TAX TO VALU(51),
    EBV.FEES TO VALU(52),
*
    MISC.FEES.CAT TO VALU(21),
    MISC.FEES.DB.CODE TO VALU(22),
    MISC.FEES.CR.CODE TO VALU(23),
*
    ST.TAX.CAT TO VALU(25),
    ST.TAX.DB.CODE TO VALU(26),
    ST.TAX.CR.CODE TO VALU(27),
    ST.TAX.DETAILS TO VALU(28),         ;* CI_10001993 S/E
*
    EBV.FEES.CAT TO VALU(30),
    EBV.FEES.DB.CODE TO VALU(31),
    EBV.FEES.CR.CODE TO VALU(32),
    TAX.CODE TO VALU(55)      ;* CI_10022714 S/E
*
    SWISS.STAMP.TAX = 0 ; EBV.FEES = 0
*
* Open files
*
*
* Read SC.STD.SEC.TRADE record
*
    R.SC.STD.SEC.TRADE = '' ; YERROR = ''
    ST.CompanyCreation.EbReadParameter('F.SC.STD.SEC.TRADE','N','',R.SC.STD.SEC.TRADE,'','',YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:EB.SystemTables.getIdCompany():@VM:'F.SC.STD.SEC.TRADE')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
*
* Read SC.PARAMETER record
*
    R.SC.PARAMETER = '' ; PARAM.ERR = ''
    ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAMETER,'','',PARAM.ERR)
    IF PARAM.ERR THEN
        EB.SystemTables.setText('& MISSING FROM F.SC.PARAMETER':@FM:EB.SystemTables.getIdCompany())
        EB.ErrorProcessing.FatalError(PROG.ID)
    END

    CURRENCY.MARKET = R.SC.PARAMETER<SC.Config.Parameter.ParamDefaultCcyMarket>
    ROUNDING.FACTOR = R.SC.PARAMETER<SC.Config.Parameter.ParamCantonalRounding>
*
* Read SECURITY.MASTER record.
*
    R.SECURITY.MASTER = ''
    R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SECURITY.NO, YERROR)
* Before incorporation : CALL F.READ('F.SECURITY.MASTER',SECURITY.NO,R.SECURITY.MASTER,F.SECURITY.MASTER,YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:SECURITY.NO:@VM:'F.SECURITY.MASTER')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
*
    SUB.ASSET.TYPE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSubAssetType>
    ACCRUAL.START.DATE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmAccrualStartDate>
    IF EB.SystemTables.getApplication() = 'SEC.TRADE' THEN
        ISSUE.DATE = EB.SystemTables.getRNew(SC.SctTrading.SecTrade.SbsIssueDate)
    END ELSE
        ISSUE.DATE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmIssueDate>
    END
    KO.FLAG = ''
    ERR = ''
    R.SUB.ASSET.TYPE = ST.Valuation.SubAssetType.Read(SUB.ASSET.TYPE, ERR)
* Before incorporation : CALL F.READ('F.SUB.ASSET.TYPE',SUB.ASSET.TYPE,R.SUB.ASSET.TYPE,'',ERR)
    KO.FLAG=R.SUB.ASSET.TYPE<ST.Valuation.SubAssetType.CsgKassenobligationen>
    IF KO.FLAG = 'YES' & ACCRUAL.START.DATE EQ '' THEN
        KO.PROCESSING = TRUE  ;* Kassenobligationen
    END ELSE
        KO.PROCESSING = FALSE
    END

    customerKey = CUSTOMER.NO
    customerProfile = ''
    CALL CustomerService.getProfile(customerKey,customerProfile)
    IF EB.SystemTables.getEtext() = '' THEN
        CUSTOMER.RESIDENCE = customerProfile<Profile.residence>
    END ELSE
        EB.SystemTables.setText('UNABLE TO RETRIEVE RESIDENCE FOR CUSTOMER':CUSTOMER.NO)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END

*
* Read CUSTOMER.SECURITY record
*
    R.CUSTOMER.SECURITY = ''
    R.CUSTOMER.SECURITY = SC.Config.CustomerSecurity.Read(CUSTOMER.NO, YERROR)
* Before incorporation : CALL F.READ('F.CUSTOMER.SECURITY',CUSTOMER.NO,R.CUSTOMER.SECURITY,F.CUSTOMER.SECURITY,YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:CUSTOMER.NO:@VM:'F.CUSTOMER.SECURITY')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
*
* Read SEC.ACC.MASTER record.
*
    R.SEC.ACC.MASTER = ''
    IF PORTFOLIO THEN
        R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.SecAccMaster.Read(PORTFOLIO, YERROR)
* Before incorporation : CALL F.READ('F.SEC.ACC.MASTER',PORTFOLIO,R.SEC.ACC.MASTER,F.SEC.ACC.MASTER,YERROR)
        IF YERROR THEN
            EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:PORTFOLIO:@VM:'F.SEC.ACC.MASTER')
            EB.ErrorProcessing.FatalError(PROG.ID)
        END
    END
*
    STOCK.EXCHANGE.DOMICILE = ''
    ERR = ''
    R.STOCK.EXCHANGE = SC.Config.StockExchange.Read(STOCK.EXCH, ERR)
* Before incorporation : CALL F.READ('F.STOCK.EXCHANGE',STOCK.EXCH,R.STOCK.EXCHANGE,'',ERR)
    STOCK.EXCHANGE.DOMICILE=R.STOCK.EXCHANGE<SC.Config.StockExchange.SteDomicile>
*
    DEALER.BOOK = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamDealerBook>
*
    IF CUSTOMER.FLAG EQ 'C' THEN
        MISC.FEES.CAT = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstClMiscFeesCat>
        MISC.FEES.DB.CODE = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstClMisDbTransCd>
        MISC.FEES.CR.CODE = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstClMisCrTransCd>
    END ELSE
        MISC.FEES.CAT = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstBrMiscFeesCat>
        MISC.FEES.DB.CODE = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstBrMisDbTransCd>
        MISC.FEES.CR.CODE = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstBrMisCrTransCd>
    END
*
    IF R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'B' THEN
        IMATURITY.DATE = ICONV(MATURITY.DATE,"D") ; IVALUE.DATE = ICONV(VALUE.DATE,"D")
        INT.ISSUE.DATE = ICONV(ISSUE.DATE,"D")
        IF INT.ISSUE.DATE AND MATURITY.DATE THEN
            DIFF.DAYS = ABS(IMATURITY.DATE - INT.ISSUE.DATE)          ;* Days on a 365 day basis
        END ELSE
            DIFF.DAYS = 370
        END
        YEARS = ABS(MATURITY.DATE[1,4] - ISSUE.DATE[1,4])
        YEARS += (MATURITY.DATE[5,2] NE ISSUE.DATE[5,2])
        DAYS = ''   ;* Days on a 360 day basis
        EB.Service.BdCalcDays(ISSUE.DATE,MATURITY.DATE,'D',DAYS)
    END ELSE
        DIFF.DAYS = 370
    END
*
*************************************************************************
*
* Calculate Stamp Tax
*
*************************************************************************
*

    TAX.CODE = ''
    NO.TAXES = 0
    K.SC.TAX.PARAMETER = ''
    NO.TAX.CAT=''
    NO.TAX.DB.CODE=''
    NO.TAX.CR.CODE=''
    BEGIN CASE
        CASE NEW.ISSUE.IND
            IF R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityDomicile> MATCHES 'CH':@VM:'LI' THEN
* All Swiss New Issues
                GOSUB NEW.ISSUES
            END ELSE
* NO.TAXES = 1
                GOSUB FOREIGN.SECURITIES
            END
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityDomicile> MATCHES 'CH':@VM:'LI'
* Swiss Securities
            GOSUB LOCAL.SECURITIES
        CASE 1
* Non Swiss Securities.
            GOSUB FOREIGN.SECURITIES
    END CASE

    IF TAX.CODE NE '' THEN
*Condition added in order to assign TAX code or TAX.TYPE.CONDITION to T.DATA

        IF TAX.CODE[1,1] EQ '*' THEN
            T.DATA = TAX.CODE ;* this will be  tax.type.condition
        END ELSE
            T.DATA = TAX.CODE:".":TRADE.DATE
        END
       
        T.DATA<2> = "TAX"
        FOREIGN.AMOUNT = 0
        LOCAL.AMOUNT = 0
        IF NOT(YERROR) THEN
            CG.ChargeConfig.CalculateCharge(CUSTOMER.NO, DEAL.AMOUNT, DEAL.CURRENCY, CURRENCY.MARKET, '', '', '', T.DATA, '', LOCAL.AMOUNT, FOREIGN.AMOUNT)
        END
        IF DEAL.CURRENCY EQ EB.SystemTables.getLccy() THEN
            SWISS.STAMP.TAX = LOCAL.AMOUNT
        END ELSE
            SWISS.STAMP.TAX = FOREIGN.AMOUNT
        END
*
        ST.TAX.CAT = T.DATA<3,1>[4,5]
        ST.TAX.CR.CODE = T.DATA<7,1>
        ST.TAX.DB.CODE = T.DATA<8,1>
        ST.TAX.DETAILS = T.DATA<12,1>   ;* CI_10001993
    END

    K.SC.TAX.PARAMETER = 'CANTONAL.TAX'
    ST.CompanyCreation.EbReadParameter('F.SC.TAX.PARAMETER','N','',R.SC.TAX.PARAMETER,K.SC.TAX.PARAMETER,'',YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:K.SC.TAX.PARAMETER:@VM:'F.SC.TAX.PARAMETER')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
    LOCATE 'BOTH' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpLocalForeign,1> SETTING LF.POS THEN
        LOCATE 'TRADE' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpEvent,LF.POS,1> SETTING EPOS THEN
            TAX.CODE = R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpTaxCode,LF.POS,EPOS>
        END ELSE
            EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'TRADE':@VM:K.SC.TAX.PARAMETER)
            EB.ErrorProcessing.FatalError(PROG.ID)
        END         ;* Locate TRADE
    END ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'LOCAL':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate LOCAL
*Condition added in order to assign TAX code or TAX.TYPE.CONDITION to T.DATA

    IF TAX.CODE[1,1] EQ '*' THEN
        T.DATA = TAX.CODE ;* this will be  tax.type.condition
    END ELSE
        T.DATA = TAX.CODE:".":TRADE.DATE
    END
  
    T.DATA<2> = "TAX"
    DEAL.AMOUNT = GROSS.AMT.TRADE.CCY + INTEREST.AMT
    IF ROUNDING.FACTOR THEN
* Round DEAL.AMOUNT up to the nearest ROUNDING.FACTOR
        DEAL.AMOUNT = INT(DEAL.AMOUNT / ROUNDING.FACTOR) * ROUNDING.FACTOR
        IF MOD(DEAL.AMOUNT,ROUNDING.FACTOR) THEN
            DEAL.AMOUNT += ROUNDING.FACTOR
        END
    END
    CANTONAL.TAX = 0
    FOREIGN.AMOUNT = 0
    LOCAL.AMOUNT = 0
    CG.ChargeConfig.CalculateCharge(CUSTOMER.NO, DEAL.AMOUNT, DEAL.CURRENCY, CURRENCY.MARKET, '', '', '', T.DATA, '', LOCAL.AMOUNT, FOREIGN.AMOUNT)
    IF DEAL.CURRENCY EQ EB.SystemTables.getLccy() THEN
        CANTONAL.TAX = LOCAL.AMOUNT
    END ELSE
        CANTONAL.TAX = FOREIGN.AMOUNT
    END
*
    DEAL.AMOUNT = CANTONAL.TAX
    K.SC.TAX.PARAMETER = 'EBV.FEES'
    ST.CompanyCreation.EbReadParameter('F.SC.TAX.PARAMETER','N','',R.SC.TAX.PARAMETER,K.SC.TAX.PARAMETER,'',YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:K.SC.TAX.PARAMETER:@VM:'F.SC.TAX.PARAMETER')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
    LOCATE 'BOTH' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpLocalForeign,1> SETTING LF.POS THEN
        LOCATE 'TRADE' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpEvent,LF.POS,1> SETTING EPOS THEN
            TAX.CODE = R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpTaxCode,LF.POS,EPOS>
        END ELSE
            EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'TRADE':@VM:K.SC.TAX.PARAMETER)
            EB.ErrorProcessing.FatalError(PROG.ID)
        END         ;* Locate TRADE
    END ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'LOCAL':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate LOCAL
 
*Condition added in order to assign TAX code or TAX.TYPE.CONDITION to T.DATA

    IF TAX.CODE[1,1] EQ '*' THEN
        T.DATA = TAX.CODE ;* this will be  tax.type.condition
    END ELSE
        T.DATA = TAX.CODE:".":TRADE.DATE
    END
    T.DATA<2> = "TAX"
    FOREIGN.AMOUNT = 0
    LOCAL.AMOUNT = 0
 
    IF NOT(YERROR) THEN
        CG.ChargeConfig.CalculateCharge(CUSTOMER.NO, DEAL.AMOUNT, DEAL.CURRENCY, CURRENCY.MARKET, '', '', '', T.DATA, '', LOCAL.AMOUNT, FOREIGN.AMOUNT)
    END
    IF DEAL.CURRENCY EQ EB.SystemTables.getLccy() THEN
        EBV.FEES = LOCAL.AMOUNT + CANTONAL.TAX
    END ELSE
        EBV.FEES = FOREIGN.AMOUNT + CANTONAL.TAX
    END
*
    EBV.FEES.CAT = T.DATA<3,1>[4,5]
    EBV.FEES.DB.CODE = T.DATA<8,1>
    EBV.FEES.CR.CODE = T.DATA<7,1>
    IF CATEGORIES.ONLY OR NO.TAXES THEN
* Only return Categories & Transaction codes.
        SWISS.STAMP.TAX = 0
        EBV.FEES = 0
    END ELSE
        IF NOT(SWISS.STAMP.TAX) THEN
            EBV.FEES = 0
        END ELSE
            BEGIN CASE
                CASE 1
                    BEGIN CASE
*
* Finance companies & their clients are exempt EBV fees in Geneva.
*
                        CASE R.SC.PARAMETER<SC.Config.Parameter.ParamExemptEbvFees> EQ 'YES' AND (R.SC.PARAMETER<SC.Config.Parameter.ParamLocalStockExch> EQ STOCK.EXCH) AND (CUSTOMER.RESIDENCE MATCHES 'CH':@VM:'LI')
                            EBV.FEES = 0
                        CASE R.SC.PARAMETER<SC.Config.Parameter.ParamLocalStockExch> EQ STOCK.EXCH AND (CUSTOMER.RESIDENCE MATCHES 'CH':@VM:'LI') AND R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscEffektenhaendler>
                            EBV.FEES = 0
                        CASE R.SC.PARAMETER<SC.Config.Parameter.ParamExemptEbvFees> EQ 'YES' AND NOT(CUSTOMER.RESIDENCE MATCHES 'CH':@VM:'LI')
                            EBV.FEES = 0
                        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmCertOfDeposit>[1,1] EQ 'Y'
                            EBV.FEES = 0
                        CASE CUSTOMER.RESIDENCE MATCHES 'CH':@VM:'LI'
* NULL
                        CASE CUSTOMER.RESIDENCE NE "" AND CUSTOMER.RESIDENCE NE "CH" AND CUSTOMER.FLAG = "B"
                            EBV.FEES = 0
                        CASE 1
                            IF CUSTOMER.FLAG = 'B' THEN
                                EBV.FEES = -EBV.FEES
                            END
                    END CASE
            END CASE
            IF EBV.FEES THEN
                BEGIN CASE
                    CASE CUSTOMER.FLAG = 'C'
                        IF R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscEffektenhaendler> AND STOCK.EXCH = GENEVA.STOCK.EXCHANGE THEN
                            EBV.FEES = 0
                        END
                    CASE 1
                        IF STOCK.EXCH = GENEVA.STOCK.EXCHANGE THEN
                            EBV.FEES = 0
                        END ELSE
                            IF NOT(STK.EXC.COUNTRY MATCHES 'CH':@VM:'LI') THEN
                                EBV.FEES = 0
                            END
                        END
                END CASE
            END
        END
    END
    EB.Foundation.ScFormatCcyAmt(DEAL.CURRENCY,SWISS.STAMP.TAX)
    EB.Foundation.ScFormatCcyAmt(DEAL.CURRENCY,EBV.FEES)


    IF NOT(EBV.FEES.CAT) OR NOT(ST.TAX.CAT) THEN
        ST.CompanyCreation.EbReadParameter('F.SC.TAX.PARAMETER','N','',R.SC.TAX.PARAMETER,'NO.TAX','',YERROR)
        IF YERROR THEN
            EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:'NO.TAX':@VM:'F.SC.TAX.PARAMETER')
            EB.ErrorProcessing.FatalError(PROG.ID)
        END
    
        TAX.CODE = R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpTaxCode,1,1>
        IF TAX.CODE[1,1] EQ '*' THEN
            R.DATA=''
            R.DATA = TAX.CODE
            R.DATA<2> = "TAX"
            R.DATA<68> = "YES"
*CALCULATE CHARGE IS CALLED   IN ORDER TO GET THE TAX.CODE,CATEGORY,DR,CR CODES
            CG.ChargeConfig.CalculateCharge(CUSTOMER.NO, '1000000', EB.SystemTables.getLccy(),CURRENCY.MARKET, "", "", "", R.DATA, "","","")
            TAX.CODE  = R.DATA<1,1>
            NO.TAX.CAT = R.DATA<3,1>[4,5]
            NO.TAX.CR.CODE = R.DATA<7,1>
            NO.TAX.DB.CODE = R.DATA<8,1>
    
        END ELSE
    
            EB.DataAccess.Dbr('TAX':@FM:CG.ChargeConfig.Tax.EbTaxCategory:@FM:'L...D',TAX.CODE,NO.TAX.CAT)
    
            EB.DataAccess.Dbr('TAX':@FM:CG.ChargeConfig.Tax.EbTaxTrCodeCr:@FM:'L...D',TAX.CODE,NO.TAX.CR.CODE)
    
            EB.DataAccess.Dbr('TAX':@FM:CG.ChargeConfig.Tax.EbTaxTrCodeDr:@FM:'L...D',TAX.CODE,NO.TAX.DB.CODE)
        END
    END
    IF NOT(EBV.FEES.CAT) THEN
        EBV.FEES.CAT = ''
        EBV.FEES.CR.CODE = ''
        EBV.FEES.DB.CODE = ''
        EBV.FEES.CAT = NO.TAX.CAT
        EBV.FEES.CR.CODE = NO.TAX.CR.CODE
        EBV.FEES.DB.CODE = NO.TAX.DB.CODE
    END
    IF NOT(ST.TAX.CAT) THEN
        ST.TAX.CAT = ''
        ST.TAX.CR.CODE = ''
        ST.TAX.DB.CODE = ''
        ST.TAX.CAT = NO.TAX.CAT
        ST.TAX.CR.CODE = NO.TAX.CR.CODE
        ST.TAX.DB.CODE = NO.TAX.DB.CODE
    END

RETURN          ;* Exit Subroutine.
*
*-----------
NEW.ISSUES:
*-----------
*
    IF R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'B' THEN
        NOMINAL.VALUE = NOMINAL.NO
    END ELSE
        NOMINAL.VALUE = GROSS.AMT.TRADE.CCY
    END
    BEGIN CASE
        CASE DIFF.DAYS LT 365 OR KO.PROCESSING
* Medium term Notes
            K.SC.TAX.PARAMETER = 'M.TERM.NOTES'
            DEAL.AMOUNT = NOMINAL.VALUE * YEARS
            IF CUSTOMER.FLAG EQ 'B' OR DEALER.BOOK THEN
* No Tax on Brokers or Nostro Trades
                K.SC.TAX.PARAMETER = 'NO.TAX'
            END         ;* Customer Flag & Dealer Book
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmCertOfDeposit>[1,1] EQ 'Y'
* Treasuary Bills
            K.SC.TAX.PARAMETER = 'TREASURY.BILLS'
            DEAL.AMOUNT = (NOMINAL.VALUE * DAYS) / 360
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMutualFund>[1,1] EQ 'Y'
* Mutual Funds
            K.SC.TAX.PARAMETER = 'MUTUAL.FUNDS'
            DEAL.AMOUNT = NOMINAL.VALUE
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'S'
* Shares
            K.SC.TAX.PARAMETER = 'SHARES'
            DEAL.AMOUNT = NOMINAL.VALUE
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'B'
* Bonds
            K.SC.TAX.PARAMETER = 'BONDS'
            DEAL.AMOUNT = NOMINAL.VALUE
        CASE 1
            K.SC.TAX.PARAMETER = 'NO.TAX'
            DEAL.AMOUNT = NOMINAL.NO
    END CASE
* Read Tax Parameter record.
    ST.CompanyCreation.EbReadParameter('F.SC.TAX.PARAMETER','N','',R.SC.TAX.PARAMETER,K.SC.TAX.PARAMETER,'',YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:K.SC.TAX.PARAMETER:@VM:'F.SC.TAX.PARAMETER')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
    LOCATE 'BOTH' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpLocalForeign,1> SETTING LF.POS THEN
        LOCATE 'NEW.ISSUE' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpEvent,LF.POS,1> SETTING EPOS THEN
            TAX.CODE = R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpTaxCode,LF.POS,EPOS>
        END ELSE
            EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'NEW.ISSUE':@VM:K.SC.TAX.PARAMETER)
            EB.ErrorProcessing.FatalError(PROG.ID)
        END         ;* Locate NEW.ISSUE
    END ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'BOTH':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate BOTH
RETURN
*
*----------------
LOCAL.SECURITIES:
*----------------
*
    DEAL.AMOUNT = GROSS.AMT.TRADE.CCY + INTEREST.AMT
    BEGIN CASE
        CASE EB.SystemTables.getApplication() EQ 'LIQD.TRADE'
* Forward Trades
            K.SC.TAX.PARAMETER = 'FORWARD.TRADES'
        CASE DIFF.DAYS LT 365
* R.SECURITY.MASTER<SC.SCM.NOTES>[1,1] EQ 'Y' &
* Medium term Notes
            K.SC.TAX.PARAMETER = 'NO.TAX'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmWarrantsFlag>[1,1] EQ 'Y' OR R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmRightsFlag>[1,1] EQ 'Y'
* Warrants or Rights
            K.SC.TAX.PARAMETER = 'WARRANTS.RIGHTS'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmCertOfDeposit>[1,1] EQ 'Y'
* Treasuary Bills
            K.SC.TAX.PARAMETER = 'TREASURY.BILLS'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMutualFund>[1,1] EQ 'Y'
* Mutual Funds
            K.SC.TAX.PARAMETER = 'MUTUAL.FUNDS'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'S'
* Shares
            K.SC.TAX.PARAMETER = 'SHARES'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'B'
* Bonds
            K.SC.TAX.PARAMETER = 'BONDS'
    END CASE
*
*******
*
    BEGIN CASE
        CASE DEALER.BOOK
            IF R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortfolioType> EQ 'TRADING' THEN
* Bank buys securities for its own TRADING stock.
                K.SC.TAX.PARAMETER = 'NO.TAX'
            END
        CASE R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscEffektenhaendler>
* Swiss Securities Trader.
            K.SC.TAX.PARAMETER = 'NO.TAX'
    END CASE

* Read Tax Parameter record.
    ST.CompanyCreation.EbReadParameter('F.SC.TAX.PARAMETER','N','',R.SC.TAX.PARAMETER,K.SC.TAX.PARAMETER,'',YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:K.SC.TAX.PARAMETER:@VM:'F.SC.TAX.PARAMETER')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
    LOCATE 'LOCAL' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpLocalForeign,1> SETTING LF.POS ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'LOCAL':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate LOCAL
    LOCATE 'TRADE' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpEvent,LF.POS,1> SETTING EPOS THEN
        TAX.CODE = R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpTaxCode,LF.POS,EPOS>
    END ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'TRADE':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate TRADE
RETURN
*
*------------------
FOREIGN.SECURITIES:
*------------------
*
    DEAL.AMOUNT = GROSS.AMT.TRADE.CCY + INTEREST.AMT
    BEGIN CASE
        CASE EB.SystemTables.getApplication() EQ 'LIQD.TRADE'
* Forward Trades
            K.SC.TAX.PARAMETER = 'FORWARD.TRADES'
        CASE DIFF.DAYS LT 365
* R.SECURITY.MASTER<SC.SCM.NOTES>[1,1] EQ 'Y' &
* Medium term Notes
            K.SC.TAX.PARAMETER = 'NO.TAX'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmWarrantsFlag>[1,1] EQ 'Y' OR R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmRightsFlag>[1,1] EQ 'Y'
* Warrants or Rights
            K.SC.TAX.PARAMETER = 'WARRANTS.RIGHTS'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmCertOfDeposit>[1,1] EQ 'Y'
* Treasuary Bills
            K.SC.TAX.PARAMETER = 'TREASURY.BILLS'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMutualFund>[1,1] EQ 'Y'
* Mutual Funds
            K.SC.TAX.PARAMETER = 'MUTUAL.FUNDS'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'S'
* Shares
            K.SC.TAX.PARAMETER = 'SHARES'
        CASE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] EQ 'B'
* Bonds
            K.SC.TAX.PARAMETER = 'BONDS'
    END CASE
*
*******
*
    BEGIN CASE
        CASE NOT(CUSTOMER.RESIDENCE MATCHES 'CH':@VM:'LI') AND R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>[1,1] = 'B'
            K.SC.TAX.PARAMETER = 'NO.TAX'
* Foreign Customers Foreign Bonds.
        CASE DEALER.BOOK
            IF R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortfolioType> EQ 'TRADING' THEN
* Bank buys securities for its own TRADING stock.
                K.SC.TAX.PARAMETER = 'NO.TAX'
            END
        CASE R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscEffektenhaendler>
* Swiss Securities Trader.
            K.SC.TAX.PARAMETER = 'NO.TAX'
        CASE CUSTOMER.FLAG EQ 'B'
* Securities Trader, Broker or Bank irrespective of residence.
            K.SC.TAX.PARAMETER = 'NO.TAX'
    END CASE

* Read Tax Parameter record.
    ST.CompanyCreation.EbReadParameter('F.SC.TAX.PARAMETER','N','',R.SC.TAX.PARAMETER,K.SC.TAX.PARAMETER,'',YERROR)
    IF YERROR THEN
        EB.SystemTables.setText('RECORD & MISSING FROM &':@FM:K.SC.TAX.PARAMETER:@VM:'F.SC.TAX.PARAMETER')
        EB.ErrorProcessing.FatalError(PROG.ID)
    END
    LOCATE 'FOREIGN' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpLocalForeign,1> SETTING LF.POS ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'FOREIGN':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate FOREIGN
    LOCATE 'TRADE' IN R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpEvent,LF.POS,1> SETTING EPOS THEN
        TAX.CODE = R.SC.TAX.PARAMETER<SC.SctTaxes.ScTaxParameter.ScTpTaxCode,LF.POS,EPOS>
    END ELSE
        EB.SystemTables.setText('& MISSING FROM SC.TAX.PARAMETER RECORD - &':@FM:'TRADE':@VM:K.SC.TAX.PARAMETER)
        EB.ErrorProcessing.FatalError(PROG.ID)
    END   ;* Locate TRADE
RETURN
*
*****************
* END OF CODING.
*****************
*
END
