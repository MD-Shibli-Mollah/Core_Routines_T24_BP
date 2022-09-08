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

* Version 4 18/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FD.Reports
    SUBROUTINE E.FD.CASH.FLOW
*

    $USING AC.AccountOpening
    $USING EB.API
    $USING AC.ModelBank
    $USING AC.Config
    $USING EB.Reports
    $USING EB.SystemTables
*
** This routine is used to return the cash flow and value dates for
** a given number of days defined in the enquiry. The format of
** O.DATA expected is
**  Account Number * Start Date * No days required
** A multi valued list of dates is returned in the format
**  the number of days required may be nnCalender of nnWorking days
**     VALUE DATE * BALANCE
** As a multi valued field cannot be handled on a break by loans, we must
** Return the dates with a delimeter of \ and the enquiry must extract
** n number of times
*
* 13/07/93 - GB9301185
*            Show the last cash flow on the account if the date is outside
*            the cash flow window
*
* 15/04/96 - GB9600443
*            Ignore entries after they pass the number of CASH.FLOW.DAYS
*            specified on the ACCOUNT.PARAMETER record.
*
* 31/05/06 - CI_10041509
*            The obsolete Account fields changed.
*
* 23/05/08 - BG_100018550
*            Reducing the compiler rating
*
* 25/4/15 - 1322379
*           Incoporation of components
*
    IF EB.Reports.getOData() THEN
        ACCT.NO = EB.Reports.getOData()["*",1,1]
        START.DATE = EB.Reports.getOData()["*",2,1]
        NO.DAYS = EB.Reports.getOData()["*",3,1]
        DAYS.REQ = "+":NO.DAYS
        IF NOT(NUM(NO.DAYS)) THEN
            DAYS.REQ:= "C"    ;* Default Calender
        END         ;* BG_100018550 S/E
        DAY.TYPE = NO.DAYS[1] ;* Working or Calender
        OUT.DATA = ""
        *
        END.DATE = START.DATE
        EB.API.Cdt("", END.DATE, DAYS.REQ)
        *
        * GB9600443 Set the maximum calculation date using the no of cash flow days on
        * the account parameter record.
        *
        MAX.CALC.DATE = EB.SystemTables.getToday()
        CASH.FLOW.DAYS = '+' : EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParCashFlowDays> : 'C'
        EB.API.Cdt('', MAX.CALC.DATE, CASH.FLOW.DAYS)
        *
        ACCT.REC = ""
        ACCT.ERR = ''
        ACCT.REC = AC.AccountOpening.tableAccount(ACCT.NO,ACCT.ERR)
        *
        GOSUB GET.ACCOUNT.DATA   ;* BG_100018550 S/E
    END
*
    RETURN
***********************************************************************
GET.ACCOUNT.DATA:
******************

    IF ACCT.REC<AC.AccountOpening.Account.AvailableDate> THEN ;* CI_10041509 S
        LOCATE START.DATE IN ACCT.REC<AC.AccountOpening.Account.AvailableDate,1> BY "AR" SETTING YPOS ELSE      ;* CI_10041509 E
        IF YPOS GT 1 THEN ;* Get the previuos balance
            PREV.BAL = ACCT.REC<AC.AccountOpening.Account.AvailableDate,YPOS-1>
        END ELSE          ;* Get Today
            EB.Reports.setOData(ACCT.NO)
            AC.ModelBank.EnqGetBal()        ;* Returns Todays Balance
            PREV.BAL = EB.Reports.getOData()
        END
    END
    END ELSE
    EB.Reports.setOData(ACCT.NO)
    AC.ModelBank.EnqGetBal()      ;* Returns Todays Balance
    PREV.BAL = EB.Reports.getOData()
    END
*
    EB.Reports.setOData("")
    YDATE = START.DATE
    LOOP
    WHILE YDATE LE END.DATE   ;* Process for the period

        * GB9600443 Only process if in the cash flow window

        IF YDATE LT MAX.CALC.DATE THEN
            LOCATE YDATE IN ACCT.REC<AC.AccountOpening.Account.AvailableDate,1> SETTING YPOS THEN
            DATE.BAL = YDATE:"*":ACCT.REC<AC.AccountOpening.Account.AvailableBal,YPOS>
            PREV.BAL = ACCT.REC<AC.AccountOpening.Account.AvailableBal,YPOS>
        END ELSE          ;* Add the previous balance
            DATE.BAL = YDATE:"*":PREV.BAL
        END
    END ELSE
        DATE.BAL = YDATE:"*":"NA"
    END
    IF EB.Reports.getOData() THEN
        EB.Reports.setOData("\":DATE.BAL)
    END ELSE
        EB.Reports.setOData(DATE.BAL)
    END
    EB.API.Cdt("",YDATE,"+1":DAY.TYPE)
    REPEAT
    RETURN
    END
