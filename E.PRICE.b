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

* Version 2 16/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
    SUBROUTINE E.PRICE
*************************************************************************
*
* Return the price for the yield enquiry
*
*************************************************************************

*
* 20/03/06 - GLOBUS_EN_10002868
*            Bond Pricing Calculation - Fixed
*
* 06/09/10 - ENHANCEMENT - 34396 - SAR-2009-12-17-0001
*            Introducing New Price type - 'COL.YIELD’
*
* 20/04/15 - 1323085
*            Incorporation of components
*
*******************************************
    $USING SC.ScoSecurityMasterMaintenance
    $USING SC.SctPriceTypeUpdateAndProcessing
    $USING EB.Reports
*******************************************
*
    tmp.ID = EB.Reports.getId()
    R.SEC.MASTER = SC.ScoSecurityMasterMaintenance.tableSecurityMaster(tmp.ID,ER)


    PRICE.TYPE.LOCAL = R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceType>
    ER = ''
    R.PRICE.TYPE.LOCAL = SC.SctPriceTypeUpdateAndProcessing.tablePriceType(PRICE.TYPE.LOCAL,ER)
    CALC.METHOD = R.PRICE.TYPE.LOCAL<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtCalculationMethod>

    IF CALC.METHOD[5] = 'YIELD' OR CALC.METHOD[1,1] = 'D' THEN
        EB.Reports.setOData(R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmDiscYldPerc>)
    END ELSE
        EB.Reports.setOData(R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>)
    END
    RETURN

    END
