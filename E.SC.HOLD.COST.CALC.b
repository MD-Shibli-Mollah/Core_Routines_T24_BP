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
* <Rating>66</Rating>
*-----------------------------------------------------------------------------
* Version 10 22/05/01  GLOBUS Release No. G12.0.00 29/06/01
    $PACKAGE SC.ScoReports
    SUBROUTINE E.SC.HOLD.COST.CALC
*
************************************************************
*
*     SUBROUTINE TO CALCULATE AVERAGE COST PRICE
*
************************************************************
* Modification History
*
* 30/06/03 - GLOBUS_BG_100004681
*            Divide by zero
*
* 25/11/08 - GLOBUS_BG_100021004 - dadkinson@temenos.com
*            TTS0804595
*            Remove DBRs
*
* 22/11/10 - defect 107380
*            In SC.HOLD.SUM cost is displayed in uncorrect format for large nominal amount
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
*
* 09/10/15 - Defect 1491152 Task:1494933
*            Decimal Places in the values derived for Gross and Net Prices in SC.HOLD.SUM Enquiries
************************************************************
*
    $USING EB.Reports
    $USING SC.ScoSecurityPositionUpdate
    $USING SC.ScoPortfolioMaintenance 
    $USING SC.Config
    $USING EB.ErrorProcessing
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING EB.API

*
******************************************************************


    NOMINAL.BAL = EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpClosingBalNoNom>
    IF NOMINAL.BAL THEN
        MULT.FACTOR = EB.SystemTables.getLocalFou()
        PERC.CODE = EB.SystemTables.getLocalFiv()
        SEC.CCY = EB.SystemTables.getLocalSix()
        *
        COST.PRICE = EB.Reports.getOData()
        *
        ** GB9200431  CLEAN COST CHANGE
        *
        CLEAN.BOOK.COST = ''
        DEALER.BOOK = ''
        SEC.ACC.MASTER.ID = EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpSecurityAccount>

        R.SEC.ACC.MASTER = '' ;* BG_100021004 S  DBRs replaced
        YERR = ''

        R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.SecAccMaster.Read(SEC.ACC.MASTER.ID, YERR)
        * Before incorporation : CALL F.READ(tmp.FN.SEC.ACC.MASTER,SEC.ACC.MASTER.ID,R.SEC.ACC.MASTER,tmp.F.SEC.ACC.MASTER,YERR)
        DEALER.BOOK = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamDealerBook>
        CLEAN.BOOK.COST = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamCleanBookCost> ;* BG_100021004 E

        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(tmp.ETEXT) AND DEALER.BOOK AND CLEAN.BOOK.COST[1,1] = 'Y' THEN
            EB.SystemTables.setEtext(tmp.ETEXT)
            COST.OF.INVEST = EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpGrossCostSecCcy>
        END ELSE
            COST.OF.INVEST = EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityPosition.ScpCostInvstSecCcy>
        END
        *
        * BG_100004681 S
        *
        IF COST.OF.INVEST THEN
            AVG.COST = COST.OF.INVEST/NOMINAL.BAL
        END ELSE
            AVG.COST = 0
        END
        *
        * BG_100004681 E
        *
        AVG.COST = AVG.COST / MULT.FACTOR
        IF PERC.CODE = 'Y' THEN AVG.COST = AVG.COST * 100
        *
        AVG.COST = OCONV(ICONV(AVG.COST,'MD4'),'MD4')
* Removing the follwing line which is added for the Defect 107380   
* EB.Foundation.ScFormatCcyAmt(SEC.CCY,AVG.COST)  ;*DEFECT-107380-S/E
* as an fix for the defect 1491152 
* In the enquiry record of SC.HOLD.SUM.GRID, for the Field COST, in the subfield TYPE,
* value specified as CCY SEC.CCY (i.e formatting based on SECURITY.CURRENCY) 
* which it self does the formatting of  AVG.COST based on the currency. 
* So no  need to format the same in the code by calling the routine SC.FORMAT.CCY.AMT  
    END ELSE
        AVG.COST = ''
    END
*
    EB.Reports.setOData(AVG.COST)
* 
    RETURN
*
FATAL:
    EB.ErrorProcessing.Err()
    EB.SystemTables.setEtext(EB.SystemTables.getE())
    EB.ErrorProcessing.FatalError('E.SC.HOLD.COST.CALC')
    END
