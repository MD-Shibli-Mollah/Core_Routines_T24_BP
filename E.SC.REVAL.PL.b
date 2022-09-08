* @ValidationCode : MjoxMTYxMTU5NzU5OkNwMTI1MjoxNTE1NTYyMjAyNDcxOnJkZWVwaWdhOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjIwMTcxMjE2LTE1NTU6Njg6NDE=
* @ValidationInfo : Timestamp         : 10 Jan 2018 11:00:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/68 (60.2%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171216-1555
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>593</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SC.ScoReports
SUBROUTINE E.SC.REVAL.PL
*---------------------------------------------------------------
*              WRITTEN BY : S.GANAPATHY
*   SUBROUTINE TO CALCULATE UNREALIZED PROFIT
*
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modification History </desc>
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
*
* 18/07/02 - GLOBUS_EN_10000784
*            Add processing to handle part-paid & grouped shares/bonds such as
*            Telekurs Price Types 10, 11, 20 & 51.
*
* 25/11/08 - GLOBUS_BG_10020996 - dgearing@temenos.com
*            Replace read with f.read or cache.read
*
* 18/06/14 - Defect:1025419 Task:1028904
*            The Unrealised.PL is displayed wrongly in the enquiry SEC.INV.POSITIONS
*            and calculated without considering the discount amortised till today.
* 23-07-2015 - 1415959
*             Incorporation of components
*
* 03/05/16 - Defect:1712384 Task:1717006
*            The Unrealised.PL is displayed wrongly in the enquiry SEC.INV.POSITIONS
*
* 05/01/18  - Defect-2394037 / Task-2405686
*             SC- Unrealised PL in SEC.INV.POSITIONS
*---------------------------------------------------------------
*** </region>
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $USING SC.SctDealerBookPosition
    $USING SC.ScoSecurityMasterMaintenance
    $USING SC.SctPriceTypeUpdateAndProcessing
    $USING ST.ExchangeRate
    $USING EB.Foundation
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.Reports
    $USING SC.SctBonds

*** </region>
*

*

    SEC.CODE = FIELD(EB.Reports.getId(),'.',2)

    NOMINAL = EB.Reports.getRRecord()<SC.SctDealerBookPosition.TradingPosition.TrpCurrentPosition>
    POS.COST = EB.Reports.getRRecord()<SC.SctDealerBookPosition.TradingPosition.TrpCurCostPosition>
*
    R.SM = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SEC.CODE, ER) ; * BG_100020996
* Before incorporation : CALL F.READ('F.SECURITY.MASTER',SEC.CODE,R.SM,F.SECURITY.MASTER,ER) ; * BG_100020996
    IF ER NE '' THEN ; * BG_100020996
        EB.SystemTables.setText('RECORD ':SEC.CODE:' NOT FOUND IN F.SECURITY.MASTER')
        GOSUB FATAL ; * BG_100020996
    END
    PRICE.TYPE = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceType>
    PRICE.CCY = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceCurrency>
    SEC.CCY = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityCurrency>
    REVAL.PRICE = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>
    BOND.FACTOR = ''
*
    IF REVAL.PRICE THEN
        R.PRICE = SC.SctPriceTypeUpdateAndProcessing.PriceType.CacheRead(PRICE.TYPE, ER) ; * BG_100020996
* Before incorporation : CALL CACHE.READ('F.PRICE.TYPE',PRICE.TYPE,R.PRICE,ER) ; * BG_100020996
        IF ER NE '' THEN ; * BG_100020996
            EB.SystemTables.setText('RECORD ':PRICE.TYPE:' NOT FOUND IN F.PRICE.TYPE')
            GOSUB FATAL ; * BG_100020996
        END

* EN_10000784 S

        IF NOT(R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmNominalFactor>) THEN
            MUL.FACTOR = R.PRICE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtMultiplyFactor>
        END ELSE
            IF R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmFactorType> = "DIVIDE" THEN
                MUL.FACTOR = 1 / R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmNominalFactor>
            END ELSE
                MUL.FACTOR = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmNominalFactor>
            END
        END
* EN_10000784 E

        PERCENT = R.PRICE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtPercentage>
        IF PERCENT = 'Y' THEN
            PRICE.FAC = MUL.FACTOR/100
        END ELSE
            PRICE.FAC = MUL.FACTOR
        END
* Get the factor defined for the Security Master
        tmp.TODAY = EB.SystemTables.getToday()
        SC.SctBonds.ScGetCpnInfo(tmp.TODAY,BOND.FACTOR,"","",SEC.CODE)
        IF BOND.FACTOR ELSE
            BOND.FACTOR = 1
        END
* Cost calculated now includes the BOND.FACTOR
        REVAL.COST = NOMINAL * REVAL.PRICE * PRICE.FAC * BOND.FACTOR
        IF PRICE.CCY NE SEC.CCY THEN
            AMT.PCY = REVAL.COST
            AMT.SCY = ''
            EX.RATE = ''
            Y1 = '' ; Y2 = '' ; Y3 = '' ; EB.SystemTables.setEtext(''); RT.CODE = ''
            CCY.MKT =1
            ST.ExchangeRate.Exchrate(CCY.MKT,PRICE.CCY,AMT.PCY,SEC.CCY,AMT.SCY,Y1,EX.RATE,Y2,Y3,RT.CODE)
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setText(EB.SystemTables.getEtext())
                GOSUB FATAL ; * BG_100020996
            END
            REVAL.COST = AMT.SCY
        END
        REVAL.PL = REVAL.COST - POS.COST
    END ELSE
        REVAL.PL = ''
    END

    R.SC.TRANS.POS.HISTORY = ''; SC.ER = '' ; PTD.DA = ''; CURR.BOOK.VAL = ''

    R.SC.TRANS.POS.HISTORY = SC.SctDealerBookPosition.TransPosHistory.Read(EB.Reports.getId(), SC.ER)
* Before incorporation : CALL F.READ('F.SC.TRANS.POS.HISTORY',tmp.ID,R.SC.TRANS.POS.HISTORY,F.SC.TRANS.POS.HISTORY,SC.ER)

    IF R.SC.TRANS.POS.HISTORY THEN
* For revaluation process,  this PTD.DA.CALC multivaue set must be subtracted instead of summing up.
        PTD.DA = (R.SC.TRANS.POS.HISTORY<SC.SctDealerBookPosition.TransPosHistory.TrhPtdDaCalc,1> - R.SC.TRANS.POS.HISTORY<SC.SctDealerBookPosition.TransPosHistory.TrhPtdDaCalc,2>)
    END
    CURR.BOOK.VAL = POS.COST + PTD.DA
    REVAL.PL = REVAL.COST - CURR.BOOK.VAL
*
    EB.Foundation.ScFormatCcyAmt(EB.Reports.getRRecord()<SC.SctDealerBookPosition.TradingPosition.TrpSecurityCcy>,REVAL.PL)
    EB.Reports.setOData(REVAL.PL)
*
RETURN
*
*-----
FATAL:
*-----
    EB.ErrorProcessing.FatalError('E.SC.REVAL.PL')
END
