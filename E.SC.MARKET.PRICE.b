* @ValidationCode : MjotMjM1MjQxMzI1OkNwMTI1MjoxNTU1NDA2OTc0NDA2OmthbGFpa3VtYXJhbnA6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMi4yMDE5MDExNy0wMzQ3OjE4ODoxODE=
* @ValidationInfo : Timestamp         : 16 Apr 2019 14:59:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kalaikumaranp
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 181/188 (96.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190117-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 8 22/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-165</Rating>
$PACKAGE SC.SctPriceTypeUpdateAndProcessing
*-----------------------------------------------------------------------------
SUBROUTINE E.SC.MARKET.PRICE
*
*
** This routine will return the current market price for a security
** in both the security currency, the portfolio currency, and also
** the value of the position in both currencies.
** Arguments:
** IN O.DATA : Security Position Id
** OUT
**    O.DATA<1> : Market Price Security Currency
**    O.DATA<2> : Market Price Reference Currency
**    O.DATA<3> : Market Price Local
**    O.DATA<4> : Value Security Currency
**    O.DATA<5> : Value Reference Currency
**    O.DATA<6> : Value local currency
**    0.DATA<7> : Rate / Price flag
**    O.DATA<8> : Margin Value Security Cccy
**    O.DATA<9> : Margin Value Reference Ccy
**    O.DATA<10> : Margin Value Local ccy
**    O.DATA<11> : Accrued Int Sec Ccy
**    O.DATA<12> : Accrued Int Ref Cccy
**    O.DATA<13> : Accrued int Local Ccy
**    O.DATA<14> : Security Currency
**    O.DATA<15> : Reference Currecny
**    O.DATA<16> : Bond or Share indicator
**    O.DATA<17> : Maturity Date
**
** The out elements are delimited by a "*" character
*
*******************************************************************
*
* CHANGE CONTROL
* --------------
*
* 01/09/98 - GB9801068
*            Two new parameters added to SC.CALC.CONSID
*
*
* 08/04/03 - GLOBUS_EN_10001683
*          - Customer individual loan to value ratios
*
* 14/07/03 - BG_100004794
*          - Added CUST.CODE as the last arguement while calling
*          - SC.CALC.ASSET.VAL.
*
* 21/12/04 - EN_10002382
*            Securities Phase I non stop processing.
*
* 20/03/06 - EN_10002868
*            Bond Pricing Calculation - Fixed
*
* 14/08/07 - EN_10003486
*            Collateral Monitoring - Insufficient automation
*
* 25/11/08 - GLOBUS_BG_100021004 - dadkinson@temenos.com
*            TTS0804595
*            Remove DBRs
*
* 31/08/10 - ENHANCEMENT - 34396 - SAR-2009-12-17-0001
*            Introducing New Price type - 'COL.YIELD'
*
* 01/04/11 - DEFECT 38731 TASK 184161
*            E.SC.MARKET.PRICE  routine calls limit routines for converting amounts,
*            Conversion of amounts from one currency into other can be performed
*            using the EXCHRATE routine.
*
* 29/05/13 - Defect-683144 / Task-686600
*            Enquiry SC.HOLD.SUM.BY.SEC displays wrong Unrealised P&L amount
*            when the SECURITY and PRICE currency are different in the
*            Security master.
*
* 06/09/13 - Defect 772330 TASK 776718
*            CUSTOMER.POSITION.SUM.SCV Enquiry does not showing the ACCRUED.INT for SHARE & BOND
*
* 27/02/14 - DEFECT 921123 TASK 926583
*            Security Currency Field Issue
*
* 20/04/15 - 1323085
*            Incorporation of components
*
* 24/11/15 - Defect:1538949  TASK :1542955
*            ENQ >CUSTOMER.POSITION output is wrong for security position which was created through REPO
*
* 29/04/16 - DEFECT 1651969 TASK 1715351
*            The VALUE.REF.CCY column in enquiry SC.HOLD.SUM.BY.PF does not include the accrued interest.
*
* 18/07/16 - Defect-1794483/Task-1799380
*            When deal has different PRICE and SECURITY currency in SECURITY.MASTER level,
*            Calculation of DEAL.LCY.AMOUNT is wrongly updated.
*
* 18/07/16 - Defect-2679100/Task-2688453
*             CUSTOMER.POSITION enquiry provides improper data.
*
* 01/04/19 - SI: 2908608/ Enhancement:3021678 /Task:3021681
*            Maintain Portfolio Value
*
* 01/04/2019 - SI 2956310 / Enh 3059924 / Task 3059932
*              Blocked positions excluded from Collateral valuation
*********************************************************************************************************
*
    $USING ST.ExchangeRate
    $USING SC.ScvValuationUpdates
    $USING SC.SctPriceTypeUpdateAndProcessing
    $USING SC.ScoSecurityPositionUpdate
    $USING SC.ScoSecurityMasterMaintenance
    $USING SC.ScoPortfolioMaintenance
    $USING SC.ScvConfig
    $USING EB.Reports
    $USING EB.SystemTables
    $USING SC.Config
    
    GOSUB INITIALISE
    GOSUB EXTRACT.PRICE
    GOSUB CALC.CONSID
    GOSUB CALC.MARGIN.INTEREST
    GOSUB CONVERT.TO.CCY
    GOSUB ADD.SC.DATA
*

    CONVERT @FM TO "*" IN OUT.DATA
    EB.Reports.setOData(OUT.DATA)
*
RETURN
*
*--------------------------------------------------------------------------
INITIALISE:
*==========
*

** Read the Security Master record
*
    SC.POS.ID = EB.Reports.getOData()
    SM.ID = EB.Reports.getOData()[".",2,1] ; PORT.ID = EB.Reports.getOData()[".",1,1]
    SM.REC = "" ; SAM.REC = "" ; SC.POS.REC = ""
    SM.ERR = ''
    SM.REC = SC.ScoSecurityMasterMaintenance.tableSecurityMaster(SM.ID,SM.ERR)
    SAM.ERR = ''
    SAM.REC = SC.ScoPortfolioMaintenance.tableSecAccMaster(PORT.ID,SAM.ERR)

    SP.ID = SC.POS.ID
    LOCK.RECORD = 0
    PROCESS.MAIN.SP = 0
    GOSUB READ.SEC.POSITION
    SC.POS.REC = SP.RECORD
    GOSUB DETERMINE.PEND.NOMINAL ; *Get the pending nominal whose EX.DATE are lesser than Today
    
RETURN

*--------------------------------------------------------------------------
EXTRACT.PRICE:
*=============
** Get the price accroding to method from SECURITY.MASTER
** Also get the MARGIN.RATE, PERCENTAGE, MULT.FACTOR
*
    R.PRICE.TYPE = '' ;* BG_100021004 S  Remove DBRs
    YERR = ''
    R.PRICE.TYPE = SC.SctPriceTypeUpdateAndProcessing.PriceType.CacheRead(SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceType>, YERR)
* Before incorporation : CALL CACHE.READ('F.PRICE.TYPE',SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceType>,R.PRICE.TYPE,YERR)
    CALC.METHOD = R.PRICE.TYPE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtCalculationMethod>
    PERC.IND = R.PRICE.TYPE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtPercentage> ;* BG_100021004 E

    IF CALC.METHOD MATCHES "DISCOUNT":@VM:"YIELD":@VM:"TYIELD":@VM:"COL.YIELD" THEN  ;* Percentage
        MARKET.PRICE.LOCAL = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmDiscYldPerc>
    END ELSE
        MARKET.PRICE.LOCAL = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>
    END

    TEMP.SM.ID = SM.ID ; SM.ID<2> = PORT.ID       ;* EN_10001683 S/E
    PERCENTAGE = '' ; MULT.FACTOR = '' ; MARGIN.RATE = ''
    SC.ScvConfig.ScParamAssetVal(SM.ID,PERCENTAGE,MULT.FACTOR,MARGIN.RATE)
    SM.ID = TEMP.SM.ID        ;* EN_10001683 S/E

RETURN
*
*--------------------------------------------------------------------------
CALC.CONSID:
*==========
*
    SC.VALUE = "" ; VALUE.DATE = EB.SystemTables.getToday() ; REF.CCY.AMT = ''

    CAP.RATE = "" ; CAP.AMT = "" ;* GB9801068 S
* If CLOSING.BAL.NOM is NULL and REPO.NOMINAL is not NULL then
* system need not call SC.SctPriceTypeUpdateAndProcessing.CalcConsid for calculating amounts
* Pending nominal will be considered for portfolio valuation
    NO.NOMINAL = SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpClosingBalNoNom> + TOT.PENDING.NOMINAL
    IF NOT(NO.NOMINAL) AND SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpRepoNominal> NE '' THEN
        RETURN
    END
    SC.SctPriceTypeUpdateAndProcessing.CalcConsid(SM.ID, NO.NOMINAL, MARKET.PRICE.LOCAL, VALUE.DATE, SC.VALUE,CAP.RATE,CAP.AMT,FACTOR) ;* GB9801068 E
    REF.CCY.AMT = SC.VALUE
    IF SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityCurrency> NE SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceCurrency> THEN
*When security and price currency are different the amount calculated should be in security currency
        CCY.MKT.LOCAL = 1
        BUY.CCY = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceCurrency>       ;*Price currency
        BUY.AMT = SC.VALUE   ;*Amount in price currency
        SELL.CCY = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityCurrency>   ;*Security currency
        SELL.AMT = ''         ;*Amount to be in security currency
        BASE.CCY = ''         ;*Base currency
        EXCH.RATE = ''        ;*Exchange rate
        DIFFERENCE = ''
        LCY.AMT = ''          ;*Local currency amount
        RETURN.CODE = ''
        ST.ExchangeRate.Exchrate(CCY.MKT.LOCAL,BUY.CCY,BUY.AMT,SELL.CCY,SELL.AMT,BASE.CCY,EXCH.RATE,DIFFERENCE,LCY.AMT,RETURN.CODE)
        SC.VALUE = SELL.AMT  ;*Amount in secuity currency
        REF.CCY.AMT = SC.VALUE
    END
RETURN
*
*---------------------------------------------------------------------------
CALC.MARGIN.INTEREST:
*====================
** Calculate the margin value and the accrued interests
*
    GOSUB CHECK.TO.EXCLUDE.BLOCKED.POSN ; * Exclude Blocked position
    MARGIN.VAL = ""
    ACCRUED.INT = SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpMaturityDate>          ;* Pass as Maturity Date
* Pending nominal will be considered for portfolio valuation while computing the MARGIN value
    NO.NOMINAL = SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpClosingBalNoNom> + TOT.PENDING.NOMINAL
    
* PORT.ID is Added as arguement while calling SC.CALC.ASSET.VAL for SC.CUSTOMER.MARGIN * EN_10003486
    SC.ScvValuationUpdates.CalcAssetVal(SM.ID, NO.NOMINAL, MARKET.PRICE.LOCAL, "", MARGIN.VAL, "", ACCRUED.INT, "", PERCENTAGE, MULT.FACTOR, MARGIN.RATE, SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpCostInvstSecCcy>, SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpGrossCostSecCcy>, "", SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpInterestRate>, "",PORT.ID)         ;* EN_10003486
*
* Exclude blocked position
    UNBLOCKED.POSITION = ''
    IF EXCLUDE.BLOCK.POSN THEN
        UNBLOCKED.POSITION = NO.NOMINAL - SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpNomAmtBlocked>
        SC.ScvValuationUpdates.CalcAssetVal(SM.ID, UNBLOCKED.POSITION, MARKET.PRICE.LOCAL, "", MARGIN.VAL, "", ACCRUED.INT, "", PERCENTAGE, MULT.FACTOR, MARGIN.RATE, SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpCostInvstSecCcy>, SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpGrossCostSecCcy>, "", SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpInterestRate>, "",PORT.ID)
    END
*

RETURN
*
*--------------------------------------------------------------------------
CONVERT.TO.CCY:
*==============
*
    SC.CURRENCY = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityCurrency> ;*SECURITY.CURRENCY is DEAL.CURRENCY
    PORT.CURRENCY = SAM.REC<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamReferenceCurrency>
*
** Store in Security Currency
*
    OUT.DATA = ""
    OUT.DATA<1> = MARKET.PRICE.LOCAL
    IF CALC.METHOD MATCHES "DISCOUNT":@VM:"YIELD":@VM:"TYIELD" OR PERC.IND = "Y" THEN
        OUT.DATA<2> = MARKET.PRICE.LOCAL ; OUT.DATA<3> = MARKET.PRICE.LOCAL
        OUT.DATA<7> = "RATE"
    END ELSE
        OUT.DATA<7> = "PRICE"
    END
    OUT.DATA<4> = SC.VALUE
    OUT.DATA<8> = MARGIN.VAL<1>
    OUT.DATA<11> = ACCRUED.INT
*
** Store Local equiv
*
    IF SC.CURRENCY = EB.SystemTables.getLccy() THEN
        OUT.DATA<6> = SC.VALUE
        IF OUT.DATA<3> = "" THEN
            OUT.DATA<3> = MARKET.PRICE.LOCAL
        END
        OUT.DATA<10> = MARGIN.VAL<1>
        OUT.DATA<13> = ACCRUED.INT
    END ELSE
        tmp.LCCY = EB.SystemTables.getLccy()
        YAMT = SC.VALUE ; EB.Reports.setYccy(tmp.LCCY)
        EB.SystemTables.setLccy(tmp.LCCY)
        GOSUB CONVERT.AMOUNT
        OUT.DATA<6> = YAMT
*
        YAMT = MARGIN.VAL<1>
        GOSUB CONVERT.AMOUNT
        OUT.DATA<10> = YAMT
        YAMT = ACCRUED.INT
        GOSUB CONVERT.AMOUNT
        OUT.DATA<13> = ACCRUED.INT
*
        IF OUT.DATA<3> = "" THEN
            tmp.LCCY = EB.SystemTables.getLccy()
            YAMT = MARKET.PRICE.LOCAL ; EB.Reports.setYccy(tmp.LCCY)

            GOSUB CONVERT.AMOUNT
            OUT.DATA<3> = YAMT
        END
    END

*
** Store in Portfolio Reference CCY
*
    IF SC.CURRENCY = PORT.CURRENCY THEN
        OUT.DATA<5> = SC.VALUE
        IF OUT.DATA<2> = "" THEN
            OUT.DATA<2> = MARKET.PRICE.LOCAL
        END

        OUT.DATA<9> = MARGIN.VAL<1>
        OUT.DATA<12> = ACCRUED.INT
    END ELSE
        YAMT = REF.CCY.AMT ; EB.Reports.setYccy(PORT.CURRENCY)
        GOSUB CONVERT.AMOUNT
        OUT.DATA<5> = YAMT
        YAMT = MARGIN.VAL<1>
        GOSUB CONVERT.AMOUNT
        OUT.DATA<9> = YAMT
*
        YAMT = ACCRUED.INT
        GOSUB CONVERT.AMOUNT
        OUT.DATA<12> = YAMT
*
        IF OUT.DATA<2> = "" THEN
            YAMT = MARKET.PRICE.LOCAL ; EB.Reports.setYccy(PORT.CURRENCY)
            GOSUB CONVERT.AMOUNT
            OUT.DATA<2> = YAMT
        END
    END
* Include the accrued interest to gross amount when the Price Basis set as "Include Accruals"
    IF R.PRICE.TYPE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtPriceBasis> EQ "INC.ACCR" THEN
        OUT.DATA<5> = OUT.DATA<5> + OUT.DATA<12>
        OUT.DATA<4> = OUT.DATA<4> + OUT.DATA<11>
    END
*
RETURN
*
*----------------------------------------------------------------------
ADD.SC.DATA:
*===========
** Add the reference currency, security currenct and Bond or Share
** indicator
*
    OUT.DATA<14> = SC.CURRENCY          ;* Security currency
    OUT.DATA<15> = PORT.CURRENCY
    OUT.DATA<16> = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>
    OUT.DATA<17> = SM.REC<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMaturityDate>
*
RETURN
*
*----------------------------------------------------------------------
CONVERT.AMOUNT:
*==============
** Convert amount to specified currency
*
    IN.AMT = YAMT ; IN.CCY = SC.CURRENCY
    OUT.AMT = "" ; OUT.CCY = EB.Reports.getYccy()

* While calling EXCHRATE, if the IN.AMT is passed as 0 it gets converted
* into NULL which is then assigned to OUT.AMT. Therefore skip the exchange rate conversion
* and assign the YAMT as zero.

    IF NOT(IN.AMT) THEN
        YAMT = 0
        RETURN
    END

    CCY.MKT.LOCAL = 1
    BASE.CCY = ''
    EXCHANGE.RATE = ''
    DIFFERENCE = ''
    LCY.AMT = ''
    RETURN.CODE = ''
    ST.ExchangeRate.Exchrate(CCY.MKT.LOCAL,IN.CCY,IN.AMT,OUT.CCY,OUT.AMT,BASE.CCY,EXCHANGE.RATE,DIFFERENCE,LCY.AMT,RETURN.CODE)

    YAMT = OUT.AMT
*
RETURN
*
*---------------------------------------------------------------------
********************
READ.SEC.POSITION:
********************

    REV1 = ''
    REV2 = ''
    REV3 = ''
    REV4 = ''
    READ.ERROR = ''
    SP.RECORD = ''
    SP.RECORD.ORG = ''

    SC.ScoSecurityPositionUpdate.ReadPosition(SP.ID,LOCK.RECORD,PROCESS.MAIN.SP,REV1,REV2,SP.RECORD,SP.RECORD.ORG,READ.ERROR,REV3,REV4)
RETURN
*-----------------------------------------------------------------------------
*** <region name= DETERMINE.PEND.NOMINAL>
DETERMINE.PEND.NOMINAL:
*** <desc>Get the pending nominal whose EX.DATE are lesser than Today </desc>

    TOT.PENDING.NOMINAL = 0
* Pending nominal with EX.DATE lesser than or equal to Today will be considered for portfolio valuation.
* Get the position till which looping has to be done to retreive the pending nominal
    LOCATE EB.SystemTables.getToday() IN SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpEffPvUpdDate,1> BY 'AR' SETTING EX.POS THEN
        EX.CNT = EX.POS
    END ELSE
        EX.CNT = EX.POS - 1
    END
* All the pending nominal with EX.DATE lesser than Today will be summed up & updated in PEND.NOMINAL in SC.POS.ASSET
    FOR EX.ID = 1 TO EX.CNT
        TOT.PENDING.NOMINAL += SUM(SC.POS.REC<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpPendNominal,EX.ID>)
    NEXT EX.ID

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.TO.EXCLUDE.BLOCKED.POSN>
CHECK.TO.EXCLUDE.BLOCKED.POSN:
*** <desc> </desc>

    GOSUB READ.PARAMETER  ; * Read SC.PARAMETER
    EXCLUDE.BLOCK.POSN = 0
    IF R.SC.PARAMETER<SC.Config.Parameter.ParamExcludeBlockedPosn> EQ 'YES' THEN
        EXCLUDE.BLOCK.POSN = 1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------*-----------------------------------------------------------------------------
*** <region name= READ.PARAMETER>
READ.PARAMETER:
*** <desc> </desc>

    R.SC.PARAMETER = ''
    R.SC.PARAMETER = SC.ScvValuationUpdates.getRScParameter()
RETURN
*** </region>
*-----------------------------------------------------------------------------*-----------------------------------------------------------------------------
END
