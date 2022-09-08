* @ValidationCode : MjotMTgwNzA2MzEzNDpDcDEyNTI6MTQ4NTk0MTA4MTYxNjpkcG9vcm5pbWE6MjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDEuMDozNjozNg==
* @ValidationInfo : Timestamp         : 01 Feb 2017 14:54:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dpoornima
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201701.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.CALC.PERF.STDAT
************************************************************
*
*  SUBROUTINE TO CALCULATE PORTFOLIO PERFORMANCE DETAILS
*
************************************************************
*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
* 25/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Tidy up.
*
* 20/04/15 - 1323085
*            Incorporation of components
*
* 27/01/2016	DEFECT:2004514 TASK:2004516
*				Wrong next counter.
*-----------------------------------------------------------
*** </region>
*
    $USING SC.ScoPortfolioMaintenance
    $USING EB.SystemTables
    $USING EB.Reports

    K.SEC.ACC.MASTER = EB.Reports.getOData()
*

    R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.tableSecAccMaster(K.SEC.ACC.MASTER,SAM.ERR)

*
    PERFORM.DATES = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPerformDate>
    LAST.CONTR.POS = DCOUNT(R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPerformDate>,@VM) ; * BG_100020996
*
** NEED TO FIND DECEMBER DATE, IF NO DECEMBER DATE USE FIRST POSN
    THIS.YEAR = EB.SystemTables.getToday()[1,4]
    LAST.YEAR = THIS.YEAR - 1
    LAST.YEAR.END = LAST.YEAR:'12'
*
    COUNT.PERFORMS = DCOUNT(PERFORM.DATES,@VM) ; * BG_100020996
    VAL.FOUND = @FALSE ; VAL.POS = 0
    FOR X = 2 TO COUNT.PERFORMS UNTIL VAL.FOUND
        VAL.FOUND = INDEX(PERFORM.DATES<1,X>,LAST.YEAR.END,1)
        IF VAL.FOUND THEN
            VAL.POS = X
        END
    NEXT X
*
    IF NOT(VAL.POS) THEN
        VAL.POS = 1
    END
*
    IF VAL.FOUND THEN
        START.DATE = THIS.YEAR:'0101'
        TEMP.YEAR = THIS.YEAR - 1
    END ELSE
        START.DATE = PERFORM.DATES<1,VAL.POS>
        TEMP.YEAR = START.DATE[1,4]
    END
    EB.Reports.setOData(START.DATE)
*
    COMPARE.VALUE = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamCompareValue,VAL.POS>
*
    START.YEAR = START.DATE[1,4]
    IF THIS.YEAR = TEMP.YEAR THEN
        CONTRIBUTIONS = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamContributions,LAST.CONTR.POS> - R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamContributions,1>
        WITHDRAWALS = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamWithdrawals,LAST.CONTR.POS> - R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamWithdrawals,1>
    END ELSE
        CONTRIBUTIONS = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamContributions,LAST.CONTR.POS> - R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamContributions,VAL.POS>
        WITHDRAWALS = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamWithdrawals,LAST.CONTR.POS> - R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamWithdrawals,VAL.POS>
    END
*
    RETURN
    END
