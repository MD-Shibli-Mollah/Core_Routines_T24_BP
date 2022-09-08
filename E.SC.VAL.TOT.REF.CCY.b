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

* Version 2 22/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>95</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.VAL.TOT.REF.CCY
*
************************************************************
*     This subroutine is essentially a copy of E.SC.VAL.REF.CCY and was
*     written as part of PIF GB9200915 by pete to equate;
*     REF.CCY to LOCAL1
*
* 20/04/15 - 1323085
*            Incorporation of components
************************************************************
*
    $USING SC.ScoPortfolioMaintenance
    $USING EB.SystemTables
    $USING EB.Reports
    
    tmp.O.DATA = EB.Reports.getOData()
    SEC.ACC.NO = FIELD(tmp.O.DATA,'.',1,1)
    EB.Reports.setOData(tmp.O.DATA)
*
*
    REF.CCY = '' ; EB.SystemTables.setEtext('')
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SAM = SC.ScoPortfolioMaintenance.tableSecAccMaster(SEC.ACC.NO,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    REF.CCY = R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamReferenceCurrency>

    IF EB.SystemTables.getEtext() THEN EB.Reports.setOData(''); RETURN
    EB.SystemTables.setLocalOne(REF.CCY)
*
    RETURN
*
    END
