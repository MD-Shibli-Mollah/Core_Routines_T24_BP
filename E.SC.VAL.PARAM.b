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

* Version 10 22/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.VAL.PARAM
*
************************************************************
*
*     SUBROUTINE TO EQUATE
*     VAL.CCY TO LOCAL1
*     REF.CCY TO LOCAL2
*     LIQD.ASSET.NO TO LOCAL6
*     POSITION.KEYS TO LOCAL7
*
* 24/11/08 - GLOBUS_BG_100020992 - cgraf@temenos.com
*            Removal of code associated with LIQD.CON.POS
*
* 20/04/15 - 1323085
*            Incorporation of components
*
* 17/02/16 - Enhancement 1192721/ Task 1634927
*            Reclassification of the units to ST module
************************************************************
*

    $USING SC.Config
    $USING SC.ScoPortfolioMaintenance
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.Valuation
    tmp.ID = EB.Reports.getId()
    SEC.ACC.MASTER.ID = FIELD(tmp.ID,'.',1,1)
    EB.Reports.setId(tmp.ID)
*
    VAL.INTERFACE.ID = 'LQ'
    R.VAL.INTERFACE = ST.Valuation.ValInterface.CacheRead(VAL.INTERFACE.ID, YERR)
* Before incorporation : CALL CACHE.READ('F.VAL.INTERFACE',VAL.INTERFACE.ID,R.VAL.INTERFACE,YERR)

    LIQD.ASSET.NO = R.VAL.INTERFACE<1>
    EB.SystemTables.setLocalSix(LIQD.ASSET.NO)

    R.SEC.ACC.MASTER = ''
    YERR = ''
    R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.tableSecAccMaster(SEC.ACC.MASTER.ID,YERR)

    IF NOT(YERR) THEN
        EB.SystemTables.setLocalOne(R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamValuationCurrency>)
        EB.SystemTables.setLocalTwo(R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamReferenceCurrency>)
    END ELSE
        EB.Reports.setOData('')
    END

    RETURN

    END
