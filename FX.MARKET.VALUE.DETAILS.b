* @ValidationCode : MjotMTQ1MDIyODYxNTpDcDEyNTI6MTU4OTYwMTQ3MDcyNjpiYWppdGg6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA0LjIwMjAwNDAyLTA1NDk6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 May 2020 09:27:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bajith
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200402-0549
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>210</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SC.ScvValuationUpdates
SUBROUTINE FX.MARKET.VALUE.DETAILS(RET.ARRAY.FX)

*** <region name= Description>
*** <desc> </desc>
* ----------------------------------------------------------------------------
* This subroutine calculates the market value of FX contracts.
*
* Drill down to Main enquiry FX.NET.EXPOSURE triggers this enquiry.
*----------------------------------------------------------------------------

*<region name = Modification History>
* Modification History
*****************************************************
* 10/09/14 - Defect 1104058 / Task 1109383
*            Exchange rate is not applied to the market value in FX.NET.EXPOSURE
*
* 10/10/14 - Defect 1135555 / Task : 1135952
*            Enquiry SC.CUSTOMER.GLOBAL.LIMIT is not displayed even though the records matched
*
* 01/12/15 - Enhancement:1322379 Task:1550275
*            Incorporation of SC_ScvValuationUpdates
*
* 17/02/16 - Enhancement 1192721/ Task 1634927
*            Reclassification of the units to ST module
*
* 07/05/20 - SI:3473538/ENH:3725387/TASK:3473538
*			 System Intraday vs Revaluation FX Rates
* ************************************************************************************************************
*** </region>

*** <region name= Inserts>
*** <desc> </desc>

    $INSERT I_DAS.SC.POS.ASSET
    $INSERT I_DAS.SC.GROUP.POS.ASSET

    $USING ST.CompanyCreation
    $USING EB.Reports
    $USING SC.ScoPortfolioMaintenance
    $USING ST.CurrencyConfig
    $USING FX.Contract
    $USING ST.ExchangeRate
    $USING EB.SystemTables
    $USING SC.Config
    $USING SC.ScvValuationUpdates
    $USING EB.DataAccess
    $USING ST.Valuation
    $USING SC.SctNonStop

*** </region>

*** <region name= Process Flow>
*** <desc> </desc>
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*** </region>
*----------------------------------------------------------------------------

*** <region name= INITIALISE>
*** <desc> </desc>
INITIALISE:
* The Enquiry FX.MARKET.VALUE can either be launched directly
* or it is a drilldown to Market Value of FX.NET.EXPOSURE enquiry.
* If the RET.ARRAY.FX holds value, then its a drill down from first level enquiry
* and the list of FX Ids are passed from the first level enquiry.
* If RET.ARRAY is null, then from SC.POS.ASSET / SC.GROUP.POS.ASSET the record
* pertaining to FX needs to be retrieved.
*

    IF RET.ARRAY.FX NE '' THEN
        FX.LIST = RET.ARRAY.FX<1>
        GROUP.OR.SINGLE.PORT = RET.ARRAY.FX<2>
        CUST.NUMBER = RET.ARRAY.FX<3>
        REF.CCY = RET.ARRAY.FX<4>

        GOSUB READ.SEC.ACC.MASTER

    END ELSE
        LOCATE "GROUP.PORTFOLIO" IN EB.Reports.getDFields()<1> SETTING POS THEN
            GROUP.OR.SINGLE.PORT =  EB.Reports.getDRangeAndValue()<POS>
        END
        LOCATE "PORTFOLIO.ID" IN EB.Reports.getDFields()<1> SETTING POS THEN
            CUST.NUMBER =  EB.Reports.getDRangeAndValue()<POS>
        END
        LOCATE "REF.CCY" IN EB.Reports.getDFields()<1> SETTING POS THEN
            REF.CCY = EB.Reports.getDRangeAndValue()<POS>
        END

        LOCATE "FX.IDS" IN EB.Reports.getDFields()<1> SETTING POS ELSE
            POS = 0
            GOSUB GET.FX.ASSET.TYPE.CODE
        END

        IF POS THEN
            FX.LIST =  EB.Reports.getDRangeAndValue()<POS>
        END

    END

    SC.ScvValuationUpdates.setCobIsOn('');* CI_10055841 S
    NS.INSTALLED = 0
    ONLINE.SESSION = ''
    ONLINE.SESSION.DATE = ''
    AFTER.COB.TXNS.EXISTS = 0
    tmp.COB.IS.ON = SC.ScvValuationUpdates.getCobIsOn()
    SC.SctNonStop.ScGetSystemStatus(ONLINE.SESSION,tmp.COB.IS.ON,NS.INSTALLED,ONLINE.SESSION.DATE,'','')      ;* CI_10055841 E
    SC.ScvValuationUpdates.setCobIsOn(tmp.COB.IS.ON)

RETURN
*** </region>
*-------------------------------------------------------------------------------------
*** <region name= GET.FX.ASSET.TYPE.CODE>
*** <desc> </desc>
GET.FX.ASSET.TYPE.CODE:

    R.VAL.INTERFACE = ''
    INTERFACE.ID = 'FX'
    R.VAL.INTERFACE = ST.Valuation.ValInterface.Read(INTERFACE.ID, '')
* Before incorporation : CALL F.READ('F.VAL.INTERFACE',INTERFACE.ID,R.VAL.INTERFACE,'','')
    FX.ASSET.TYPE.CODE = R.VAL.INTERFACE<1>

    R.ASSET.BREAK = ''
    IF FX.ASSET.TYPE.CODE THEN
        R.ASSET.BREAK = ST.Valuation.AssetBreak.Read(FX.ASSET.TYPE.CODE, '')
* Before incorporation : CALL F.READ('F.ASSET.BREAK',FX.ASSET.TYPE.CODE,R.ASSET.BREAK,'','')
    END
    FX.SUB.ASSET.TYPE.CODE = R.ASSET.BREAK<1>


    IF GROUP.OR.SINGLE.PORT = 'SINGLE' THEN       ;* Single Portfolio
        DAS.FILE.NAME = 'SC.POS.ASSET'
        DAS.ARGS =  CUST.NUMBER:'.':FX.SUB.ASSET.TYPE.CODE:'.':FX.ASSET.TYPE.CODE
        DAS.FILE.SUFFIX = ''
        DAS.LIST =  dasScPosAssetIdLike
        EB.DataAccess.Das(DAS.FILE.NAME,DAS.LIST,DAS.ARGS,DAS.FILE.SUFFIX)

        GOSUB READ.SEC.ACC.MASTER


    END ELSE

*Read the SC.VALUATION.GROUP.WRK.POST </desc>
        GOSUB READ.SEC.ACC.MASTER
        SAVE.ID.COMPANY = EB.SystemTables.getIdCompany()
        OWN.COMP.ID = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamOwnCompId>
        IF NOT(OWN.COMP.ID) THEN
            OWN.COMP.ID = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamCoCode>
        END

        IF OWN.COMP.ID NE EB.SystemTables.getIdCompany() THEN
* id company are differecnt then load the company
            ST.CompanyCreation.LoadCompany(OWN.COMP.ID)
        END

*Read the SC.VALUATION.GROUP.WRK.POST </desc>

        R.SC.VALUATION.GROUP.WRK.POST = ''
        YERR = ''

        DAS.FILE.NAME = 'SC.GROUP.POS.ASSET'
        DAS.ARGS = CUST.NUMBER
        DAS.FILE.SUFFIX = ''
        DAS.LIST =  dasscgroupposassetIdLike      ;* fetch the records with portfolio
        EB.DataAccess.Das(DAS.FILE.NAME,DAS.LIST,DAS.ARGS,DAS.FILE.SUFFIX)
        R.SC.VALUATION.GROUP.WRK.POST = DAS.LIST

        FX.ASSET.ID = CUST.NUMBER:'.':FX.SUB.ASSET.TYPE.CODE:'.':FX.ASSET.TYPE.CODE
        LOCATE FX.ASSET.ID IN R.SC.VALUATION.GROUP.WRK.POST SETTING POSN THEN
            DAS.LIST = FX.ASSET.ID
        END

        IF EB.SystemTables.getIdCompany() NE SAVE.ID.COMPANY THEN
* reload the original company
            ST.CompanyCreation.LoadCompany(SAVE.ID.COMPANY)
        END
    END

    CCY.LIST = ''
    R.SC.POS.ASSET = '' ; ER = ''
    DEAL.LIST = ''
    FX.LIST = DAS.LIST

RETURN
*** </region>
*--------------------------------------------------------------------------------------
*** <region name= READ.SEC.ACC.MASTER>
READ.SEC.ACC.MASTER:
*** <desc>Read the SEC.ACC.MASTER record </desc>

    R.SEC.ACC.MASTER = ''
    YERR = ''
    R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.SecAccMaster.Read(CUST.NUMBER, YERR)
* Before incorporation : CALL F.READ('F.SEC.ACC.MASTER',CUST.NUMBER,R.SEC.ACC.MASTER,'',YERR)

    SAM.REF.CCY = ''
    SAM.REF.CCY = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamReferenceCurrency>



RETURN
*** </region>

*-------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> </desc>
PROCESS:
* The Unrealised Profit / Loss from SC.POS.ASSET / SC.GROUP.POS.ASSET is taken for each FX transaction.

    RET.ARRAY.FX = ''
    LOOP
        REMOVE ID.LIST FROM FX.LIST SETTING POS
    WHILE ID.LIST
        IF GROUP.OR.SINGLE.PORT = 'SINGLE' THEN
            R.POS.ASSET = SC.ScvValuationUpdates.PosAsset.Read(ID.LIST, ER)
* Before incorporation : CALL F.READ('F.SC.POS.ASSET',ID.LIST,R.POS.ASSET,'',ER)
            DEAL.REF = R.POS.ASSET<SC.ScvValuationUpdates.PosAsset.PasSecurityNo>
        END ELSE
            R.POS.ASSET = SC.ScvValuationUpdates.GroupPosAsset.Read(ID.LIST, ER)
* Before incorporation : CALL F.READ('F.SC.GROUP.POS.ASSET',ID.LIST,R.POS.ASSET,'',ER)
            DEAL.REF = R.POS.ASSET<SC.ScvValuationUpdates.GroupPosAsset.GpaSecurityNo>
        END
        TOT.UNRL.PFT = ''
        TOT.UNRL.PFT.LCY = ''
        NO.OF.DEALS = DCOUNT(DEAL.REF,@VM)
        PROCESS.DIFF.FX.DEAL = DEAL.REF<1,1>
        GOSUB GET.UNRL.PFT.LOSS
    REPEAT

    GOSUB TOTAL.OF.UNREALISED.PFT
RETURN
*** </region>
*-------------------------------------------------------------------------------------
*** <region name= GET.UNRL.PFT.LOSS>
*** <desc> </desc>
GET.UNRL.PFT.LOSS:
    FOR DEAL.COUNT = 1 TO NO.OF.DEALS
        IF DEAL.REF<1,DEAL.COUNT> NE PROCESS.DIFF.FX.DEAL THEN
            PROCESS.DIFF.FX.DEAL = DEAL.REF<1,DEAL.COUNT>
            TOT.UNRL.PFT = 0
        END ELSE
            IF DEAL.COUNT NE 1 THEN
                CONTINUE
            END
        END

        R.FOREX = FX.Contract.Forex.Read(PROCESS.DIFF.FX.DEAL, ER)
* Before incorporation : CALL F.READ('F.FOREX',PROCESS.DIFF.FX.DEAL,R.FOREX,'',ER)
        DEAL.RATE = ''

        BEGIN CASE
            CASE R.FOREX<FX.Contract.Forex.DealType> = 'SP'
                DEAL.RATE = R.FOREX<FX.Contract.Forex.SpotRate>

            CASE R.FOREX<FX.Contract.Forex.DealType> = 'FW'
                DEAL.RATE = R.FOREX<FX.Contract.Forex.ForwardRate>

            CASE R.FOREX<FX.Contract.Forex.DealType> = 'SW'
                IF PROCESS.DIFF.FX.DEAL = R.FOREX<FX.Contract.Forex.SwapRefNo,1> THEN
                    DEAL.RATE = R.FOREX<FX.Contract.Forex.SpotRate>
                END ELSE
                    DEAL.RATE = R.FOREX<FX.Contract.Forex.ForwardRate>
                END
        END CASE


        CCY1.TOT.UNRL.CCY = ''
        CCY2.TOT.UNRL.CCY = ''

        LOCATE PROCESS.DIFF.FX.DEAL IN DEAL.REF<1,1> SETTING POS THEN
            IF GROUP.OR.SINGLE.PORT = 'SINGLE' THEN
                CCY1.TOT.UNRL.CCY = R.POS.ASSET<SC.ScvValuationUpdates.PosAsset.PasTotUnrlCcy,POS>
                CCY2.TOT.UNRL.CCY = R.POS.ASSET<SC.ScvValuationUpdates.PosAsset.PasTotUnrlCcy,POS+1>
            END ELSE
                CCY1.TOT.UNRL.CCY = R.POS.ASSET<SC.ScvValuationUpdates.GroupPosAsset.GpaTotUnrlCcy,POS>
                CCY2.TOT.UNRL.CCY = R.POS.ASSET<SC.ScvValuationUpdates.GroupPosAsset.GpaTotUnrlCcy,POS+1>
            END
        END

*  Do conversion between the reference currencies of SAM and enquiry

        CCY1.TOT.UNRL.CCY.IN.REF = ''
        CCY2.TOT.UNRL.CCY.IN.REF = ''
        IF SAM.REF.CCY NE REF.CCY THEN
            BUY.CCY = SAM.REF.CCY
            BUY.AMT = CCY1.TOT.UNRL.CCY
            SELL.CCY = REF.CCY
            SELL.AMT = ''
            IF BUY.AMT THEN
                GOSUB EXCHRATE
            END
            CCY1.TOT.UNRL.CCY.IN.REF = SELL.AMT

            BUY.CCY = SAM.REF.CCY
            BUY.AMT = CCY2.TOT.UNRL.CCY
            SELL.CCY = REF.CCY
            SELL.AMT = ''
            IF BUY.AMT THEN
                GOSUB EXCHRATE
            END
            CCY2.TOT.UNRL.CCY.IN.REF = SELL.AMT

            TOT.UNRL.PFT = CCY1.TOT.UNRL.CCY.IN.REF + CCY2.TOT.UNRL.CCY.IN.REF  ;* converted amounts in terms of reference currency of enquiry

        END ELSE
            TOT.UNRL.PFT = CCY1.TOT.UNRL.CCY + CCY2.TOT.UNRL.CCY
        END

* if SAM reference currency is LCY then dont do a conversion
        IF SAM.REF.CCY EQ EB.SystemTables.getLccy() THEN
            TOT.UNRL.PFT.LCY = CCY1.TOT.UNRL.CCY + CCY2.TOT.UNRL.CCY
        END ELSE


            BUY.CCY = REF.CCY
            BUY.AMT = TOT.UNRL.PFT
            SELL.CCY = EB.SystemTables.getLccy()
            GOSUB EXCHRATE
            TOT.UNRL.PFT.LCY = SELL.AMT
        END
        RET.ARRAY.FX<-1> = PROCESS.DIFF.FX.DEAL:"*":R.FOREX<FX.Contract.Forex.DealType>:"*":R.FOREX<FX.Contract.Forex.AmountBought>:"*":R.FOREX<FX.Contract.Forex.CurrencyBought>:"*":R.FOREX<FX.Contract.Forex.CurrencySold>:"*":R.FOREX<FX.Contract.Forex.SpotDate>:"*":R.FOREX<FX.Contract.Forex.ValueDateBuy>:"*":DEAL.RATE:"*":REF.CCY:"*":TOT.UNRL.PFT:"*":TOT.UNRL.PFT.LCY
    NEXT DEAL.COUNT
RETURN
*** </region>
*-------------------------------------------------------------------------------------
*** <region name= EXCHRATE>
*** <desc> </desc>

EXCHRATE:

    EXCH.RATE = ''
    SELL.AMT = ''
    BASE.CCY = ''
* If COB.VAL.CCY.MARKET present in SC.PARAMETER then pass it in exchrate call.
    ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAMETER,'','',ER)
    IF R.SC.PARAMETER<SC.Config.Parameter.ParamDefaultCcyMarket> THEN
        EXCH.RATE.CCY.MKT = R.SC.PARAMETER<SC.Config.Parameter.ParamDefaultCcyMarket>
    END ELSE
        EXCH.RATE.CCY.MKT = 1
    END
    IF EB.SystemTables.getRunningUnderBatch() AND SC.ScvValuationUpdates.getCobIsOn() = 1 AND R.SC.PARAMETER<SC.Config.Parameter.ParamCobValCcyMarket> THEN
        EXCH.RATE.CCY.MKT = R.SC.PARAMETER<SC.Config.Parameter.ParamCobValCcyMarket>
    END
    ST.ExchangeRate.Exchrate(EXCH.RATE.CCY.MKT,BUY.CCY,BUY.AMT,SELL.CCY,SELL.AMT,BASE.CCY,EXCH.RATE,DIFFERENCE,LCY.AMT,RETURN.CODE)
RETURN
*** </region>
*-------------------------------------------------------------------------------------
*** <region name= TOTAL.OF.UNREALISED.PFT>
*** <desc> </desc>
TOTAL.OF.UNREALISED.PFT:

    TOTAL.NO.OF.DEALS = DCOUNT(RET.ARRAY.FX,@FM)
    TOTAL.UNRL.PFT.IN.LCY = 0
    FOR DEAL.COUNT = 1 TO TOTAL.NO.OF.DEALS
        TOTAL.UNRL.PFT.IN.LCY = TOTAL.UNRL.PFT.IN.LCY + FIELD(RET.ARRAY.FX<DEAL.COUNT>,'*',11,1)
    NEXT DEAL.COUNT
    RET.ARRAY.FX = RET.ARRAY.FX :"*":TOTAL.UNRL.PFT.IN.LCY
RETURN

*** </region>
END
