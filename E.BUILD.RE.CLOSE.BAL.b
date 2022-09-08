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

* Version 3 02/06/00  GLOBUS Release No. G12.2.00 04/04/02
*-----------------------------------------------------------------------------
* <Rating>-50</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.BUILD.RE.CLOSE.BAL
*
**************************************************************************
** This subroutine will build an array of closing balances for CRB lines
** for a given date. The details will be held in memory in a common variable
** balance will be extracted  by a conversion routine in the enquiry
** The layout of the balance array is:
**   C$BAL.ARRAY<1,X>    - Report.Line*Ccy
**   C$BAL.ARRAY<4,x>    - Balance in CCY
**   C$BAL.ARRAY<5,x>    - Balance in LCY
*
** The report name and dates required will be extracted from ENQ.SELECTION
** specifically with the names:
** REPORT.NAME  - NAME of report
** SYSTEM.DATE  - Dates. The first value will assumed to the start of the
**                range and is INCLUSIVE
*
*******************************************************************************
* MODIFICATION.HISTORY:
* 07/11/02 - CI_10004620
*            Modification done to show OPENING.BALANCE & CLOSING.BALANCE correctly
*
* 12/03/07 - EN_10003255
*            Modified to call DAS to select data.
*
* 20/09/07 - CI_10051478 / REF: HD0715726
*            Wrong Closing Balance subtotal in GENERAL.LEDGER enquiry,
*            even it has some value for closing balance.
*
* 04/10/07 - BG_100015329
*            Changes done to ignore those RE.STAT.LINE.BAL records which
*            are specific to CRB report usage.
*
*****************************************************************************
    $INSERT I_DAS.RE.STAT.LINE.BAL
    $USING RE.ReportGeneration
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables
    $USING RE.ModelBank
    $USING EB.Reports
*
    LOCATE 'REPORT.NAME' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    REPNAME = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    RETURN      ;* No report specified
    END
*
    LOCATE 'SEL.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN          ;* CI_10004620 S/E
    END.DATE = EB.Reports.getEnqSelection()<4,POS,1>[' ',2,1]          ;* Take first value only
    END ELSE
    RETURN      ;* No date specified
    END
*
** RE.STAT.LINE.BAL is stored by PERIOD.END, so we need to find out if
** SYSTEM.DATE defined was a working day. We then need to find the PERIOD
** END date for that date
*
    IF END.DATE GE EB.SystemTables.getToday() THEN ;* CI_10004620 S/E
        END.DATE = EB.SystemTables.getToday()
        PERIOD.END = END.DATE
        EB.API.Cdt('',PERIOD.END,'-1C')
    END ELSE
        PERIOD.END = END.DATE
        EB.API.Cdt('',PERIOD.END,'+1W-1C')          ;* Next Working Day -1
        IF PERIOD.END[5,2] NE END.DATE[5,2] THEN  ;* Get the end of month
            PERIOD.END = END.DATE[1,6]:'32'
            EB.API.Cdt('',PERIOD.END,'-1C')         ;* Get the end of month
        END
    END
*
    BAL.LIST = ''
    LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    CCY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    CCY = ""    ;* CI_10004620 S/E
    END
*
* EN_10004620 S

    BAL.LIST    = dasReStatLineBalBuildClosingBalanceByReportline
    THE.ARGS    = REPNAME
    IF CCY THEN
        THE.ARGS<2> = CCY
    END ELSE
        THE.ARGS<2> = EB.DataAccess.dasDoNotUseThisOptionalField
    END
    THE.ARGS<3> = PERIOD.END

    TABLE.SUFFIX = ''
*
* EN_10004620 E
    EB.DataAccess.Das('RE.STAT.LINE.BAL',BAL.LIST,THE.ARGS,TABLE.SUFFIX)
*
    LOOP
        REMOVE REP.KEY FROM BAL.LIST SETTING YD
    WHILE REP.KEY:YD
        CURR = FIELD(REP.KEY,'-',3)
        IF CURR EQ 'LOCAL' THEN
            CONTINUE
        END
        * READ BAL.REC FROM F.RE.STAT.LINE.BAL, REP.KEY THEN
        ERR = ''
        BAL.REC = RE.ReportGeneration.StatLineBal.Read(REP.KEY, ERR)
        IF NOT(ERR) THEN
            LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
            CCY = EB.Reports.getEnqSelection()<4,POS>
        END ELSE
            CCY = EB.SystemTables.getLccy()
        END
        NAME.NO = REP.KEY['-',1,2]
        CLOSE.LCY = BAL.REC<RE.ReportGeneration.StatLineBal.SlbClosingBalLcl>
        CLOSE.FCY = BAL.REC<RE.ReportGeneration.StatLineBal.SlbClosingBal>
        GOSUB ADD.TO.ARRAY
        CCY = ''          ;* Store grand total local
        CLOSE.FCY = ''    ;* Not required
        GOSUB ADD.TO.ARRAY
    END
    REPEAT
*
    RETURN
*
*--------------------------------------------------------------
ADD.TO.ARRAY:
*============
*
    SEARCH.KEY = NAME.NO:'*':CCY
    LOCAL.CBALARRAY = RE.ModelBank.getCBalArray()
    LOCATE SEARCH.KEY IN LOCAL.CBALARRAY<1,1> SETTING POS THEN
        LOCAL.CBALARRAY<4,POS> += CLOSE.FCY
        LOCAL.CBALARRAY<5,POS> += CLOSE.LCY
    END ELSE
        INS SEARCH.KEY BEFORE LOCAL.CBALARRAY<1,POS>
        INS CLOSE.FCY+0 BEFORE LOCAL.CBALARRAY<4,POS>
        INS CLOSE.LCY+0 BEFORE LOCAL.CBALARRAY<5,POS>
    END
    RE.ModelBank.setCBalArray(LOCAL.CBALARRAY)
*
    RETURN
*
    END
