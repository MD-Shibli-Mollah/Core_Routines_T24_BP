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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-34</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.CHECK.CCY.EXCEPTION
*-----------------------------------------------------------------------------
*
* This subroutine will be used to determine whether there is any exception
* for the current procesing currency in system summary record and return the
* O.DATA as "NOT IN BALANCE"
*
* The fields used are as follows:-
*
* INPUT
*         R.RECORD        System Summary record.
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*
* OUTPUT  O.DATA          "NOT IN BALANCE" if there is any exception
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $USING RE.ReportGeneration
    $USING EB.SystemTables
    $USING EB.Reports
    $USING RE.ModelBank
*-----------------------------------------------------------------------------

    GOSUB INITIALISE

    GOSUB PROCESS ; *

    RETURN

*
*-----------------------------------------------------------------------------
*

INITIALISE:

    POSITION.SETUP =  EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumPositionEntry>
    EB.Reports.setOData('')
    EXCP.CCY.LIST = ''

    RETURN

*
*-----------------------------------------------------------------------------
*

PROCESS:

    CCY.POS = 0
    LOOP
        CCY.POS += 1
        AL.CCY = EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumAlCcy, CCY.POS>
    WHILE AL.CCY
        AL.CCY.BAL = EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumAlCcyBalAmt, CCY.POS>
        AL.LCY.BAL = EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumAlLclBal, CCY.POS>
        AL.CCY.EXCP = EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumAlCcyExcep, CCY.POS>
        AL.LCY.EXCP = EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumAlLcyExcep, CCY.POS>

        BEGIN CASE
            CASE AL.CCY NE EB.SystemTables.getLccy() AND POSITION.SETUP = 'ACCOUNT'
                IF AL.CCY.BAL OR AL.LCY.BAL THEN ;* Position setup as ACCOUNT check the AL balance is zero
                    EXCP.CCY.LIST<-1> = AL.CCY
                END
            CASE AL.CCY NE EB.SystemTables.getLccy() AND POSITION.SETUP NE 'ACCOUNT'
                IF AL.CCY.EXCP OR AL.LCY.EXCP THEN ;* check the EXCEPTION fields are zero
                    EXCP.CCY.LIST<-1> = AL.CCY
                END
            CASE AL.CCY EQ EB.SystemTables.getLccy()  ;* LCCY check the exception filed
                IF EB.Reports.getRRecord()<RE.ReportGeneration.EbSystemSummary.EbSysumExceptAmtLcy> THEN
                    EXCP.CCY.LIST<-1> = AL.CCY
                END
        END CASE

    REPEAT

    IF EXCP.CCY.LIST THEN
        EXCP.CCY.CNT = DCOUNT(EXCP.CCY.LIST, @FM)
        CONVERT @FM TO ', ' IN EXCP.CCY.LIST
        IF EXCP.CCY.CNT > 1 THEN
            EB.Reports.setOData('Currency ':EXCP.CCY.LIST:' are not in balance')
        END ELSE
            EB.Reports.setOData('Currency ':EXCP.CCY.LIST:' is not in balance')
        END
    END

    RETURN
*
*-----------------------------------------------------------------------------
    END
