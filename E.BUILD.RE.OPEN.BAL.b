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
* <Rating>-45</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.BUILD.RE.OPEN.BAL
************************************************************************
** This subroutine will build an array of opening balances for CRB lines
** for a given date. The details will be held in memory in a common variable
** balance will be extracted  by a conversion routine in the enquiry
** The layout of the balance array is:
**   C$BAL.ARRAY<1,X>    - Report.Line*Ccy
**   C$BAL.ARRAY<2,x>    - Balance in CCY
**   C$BAL.ARRAY<3,x>    - Balance in LCY
*
** The report name and dates required will be extracted from ENQ.SELECTION
** specifically with the names:
** REPORT.NAME  - NAME of report
** SYSTEM.DATE  - Dates. The first value will assumed to the start of the
**                range and is INCLUSIVE
*************************************************************************
* MODIFICATION.HISTORY:
* 12/11/02 - CI_10004620
*            Modification done to show the OPENING.BALANCE & CLOSING.BALANCE correctly
*
* 20/09/07 - CI_10051478 / REF: HD0715726
*            Wrong Opening Balance in GENERAL.LEDGER enquiry,
*
* 04/10/07 - BG_100015329
*            Changes done to ignore those RE.STAT.LINE.BAL records which
*            are specific to CRB report usage.
*
*************************************************************************
*
    $USING RE.ReportGeneration
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports
    $USING RE.ModelBank
*
    F.RE.STAT.LINE.BAL = ''
    YF.RE.STAT.LINE.BAL = 'F.RE.STAT.LINE.BAL'
    EB.DataAccess.Opf(YF.RE.STAT.LINE.BAL, F.RE.STAT.LINE.BAL)
*
    RE.ModelBank.setCBalArray('')
*
    LOCATE 'REPORT.NAME' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    REPNAME = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    RETURN      ;* No report specified
    END
*
    LOCATE 'SEL.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN          ;* CI_10004620 S/E
    START.DATE = EB.Reports.getEnqSelection()<4,POS,1>[' ',1,1]        ;* Take first value only
    END ELSE
    RETURN      ;* No date specified
    END
*
** RE.STAT.LINE.BAL is stored by PERIOD.END, so we need to find out if
** SYSTEM.DATE defined was a working day. We then need to find the PERIOD
** END date for that date
*
    PERIOD.END = START.DATE
    EB.API.Cdt('',PERIOD.END,'+1W-1C')    ;* Next Working Day -1
    IF PERIOD.END[5,2] NE START.DATE[5,2] THEN    ;* Get the end of month
        PERIOD.END = START.DATE[1,6]:'32'
        EB.API.Cdt('',PERIOD.END,'-1C')   ;* Get the end of month
    END
*
    BAL.LIST = ''
    LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    CCY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    CCY = ""    ;* CI_10004620 S/E
    END
*
* CI_10004620 S
    IF CCY THEN
        SEL.STMT = 'SELECT ':YF.RE.STAT.LINE.BAL:' WITH REPORT.NAME = ':REPNAME:' AND CURRENCY = ':CCY:' AND PERIOD.END.DATE = ':PERIOD.END:' BY REPORT.LINE'
    END ELSE
        SEL.STMT = 'SELECT ':YF.RE.STAT.LINE.BAL:' WITH REPORT.NAME = ':REPNAME:' AND PERIOD.END.DATE = ':PERIOD.END:' BY REPORT.LINE'
    END
*
* CI_10004620 E
    EB.DataAccess.Readlist(SEL.STMT, BAL.LIST, '', '', '')
*
    LOOP
        REMOVE REP.KEY FROM BAL.LIST SETTING YD
    WHILE REP.KEY:YD
        LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
        CCY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
        CCY = EB.SystemTables.getLccy()
    END
    CURR = FIELD(REP.KEY,'-',3)
    IF CURR EQ 'LOCAL' THEN
        CONTINUE
    END
    ERR = ''
    BAL.REC = RE.ReportGeneration.StatLineBal.Read(REP.KEY, ERR)
    IF NOT(ERR) THEN
        NAME.NO = REP.KEY['-',1,2]
        OPEN.LCY = BAL.REC<RE.ReportGeneration.StatLineBal.SlbOpenBalLcl>
        OPEN.FCY = BAL.REC<RE.ReportGeneration.StatLineBal.SlbOpenBal>
        GOSUB ADD.TO.ARRAY
        CCY = ''          ;* Store grand total local
        OPEN.FCY = ''     ;* Not required
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
        LOCAL.CBALARRAY<2,POS> += OPEN.FCY
        LOCAL.CBALARRAY<3,POS> += OPEN.LCY
    END ELSE
        INS SEARCH.KEY BEFORE LOCAL.CBALARRAY<1,POS>
        INS OPEN.FCY+0 BEFORE LOCAL.CBALARRAY<2,POS>
        INS OPEN.LCY+0 BEFORE LOCAL.CBALARRAY<3,POS>
    END
    RE.ModelBank.setCBalArray(LOCAL.CBALARRAY)  
    RETURN
*
    END
