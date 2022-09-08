* @ValidationCode : MjoxMDU1OTA3Njk6Q3AxMjUyOjE2MTE5MjQzNjQ5NDU6cXVhemlyYWhiZXIucmFiYmFuaTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAxLjIwMjAxMjI2LTA2MTg6MTE5Ojc3
* @ValidationInfo : Timestamp         : 29 Jan 2021 18:16:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : quazirahber.rabbani
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 77/119 (64.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



*-----------------------------------------------------------------------------
* <Rating>1120</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.CHARGES.VAL

*-----------------------------------------------------------------------------------------
* 18/03/99 - GB9900471
*            The program must cater for a situation where no charges
*            are needed at all. This would be in the case of bank
*            drafts being issued.
*
* 06/09/01 - GLOBUS_EN_10000101
*            Enhanced Cheque.Issue to collect charges at each Status
*            and link to Soft Delivery
*            - Changed Cheque.Issue to standard template
*            - Changed all values captured in ER to capture in E
*            - GoTo Check.Field.Err.Exit has been changed to GoTo Check.Field.Exit
*            - All the variables are set in I_CI.COMMON
*
*            New fields added to the template are
*            - Cheque.Status
*            - Chrg.Code
*            - Chrg.Amount
*            - Tax.Code
*            - Tax.Amt
*            - Waive.Charges
*            - Class.Type       : -   Link to Soft Delivery
*            - Message.Class    : -      -  do  -
*            - Activity         : -      -  do  -
*            - Delivery.Ref     : -      -  do  -
*
* 22/10/01 - GLOBUS_CI_10000413
*            Changed the variable name ISSUE.END.DATE to CQ$ISSUE.END.DATE
*
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 14/08/15 - Enhancement 1265068 / Task 1387491
*           - Routine incorporated
*
* 09/03/17 - Defect 1877093 / Task 2045513
*            The Issue Rollover should not be set if ISSUE.CHG.FQU is Null.
*            In that case, BAND charges calculation should only depend on no of cheque issued.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 23/10/19 - Defect 3380546 / Task 3400425
*            LEVEL charges calculation must be done correctly when any number of cheques
*            are issued for the same account.
* 14/01/21 - Enhancement 3784714 / Task 4154238
*            calculate Tax on the cheque issued charges
*-----------------------------------------------------------------------------------------

    $USING CQ.ChqFees
    $USING AC.AccountOpening
    $USING CQ.ChqConfig
    $USING ST.ExchangeRate
    $USING EB.API
    $USING EB.SystemTables
    $USING CQ.ChqIssue
    $USING CG.ChargeConfig

*CHARGES.VAL
*-----------

    IF CQ.ChqIssue.getCqChequeCharge() = "" THEN RETURN         ; * GB9900471
    GOSUB CALC.ISSUE.PERIOD.DATES
    IF EB.SystemTables.getVFunction() = 'A' THEN RETURN    ; * CI_10000413
    SAVE.ISSUED.THIS.PD = CQ.ChqIssue.getCqIssuedThisPd()
    IF CQ.ChqIssue.getCqIssueRollover() THEN CQ.ChqIssue.setCqIssuedThisPd(0)

    BEGIN CASE
        CASE CQ.ChqIssue.getCqCharges() NE ''
            IF CQ.ChqIssue.getCqCharges() THEN           ; * Don't convert if zero
                IF CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency> <> EB.SystemTables.getLccy() THEN    ; * EN_10000101 - dynamic
                    IF CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeAllowFcyAcct>[1,1] = "N" THEN
                        EB.SystemTables.setE("ST.RTN.AC.CCY.ONLY.LOCAL.TYPE":@FM:CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency>); * EN_10000101 - ER to E & to dynamic array
                        RETURN              ; * EN_10000101
                    END
                    CQ.ChqIssue.setCqLcyAmt('')
                    YFAMT = CQ.ChqIssue.getCqCharges()
                    YFCY = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCurrency)
                    YRATE = CQ.ChqIssue.getCqExchRate()<1>
                    BUY.AMT = YFAMT

                    YMARKET = CQ.ChqIssue.getCqCcyMkt()

                    LCY.AMT = CQ.ChqIssue.getCqLcyAmt()

                    ST.ExchangeRate.MiddleRateConvCheck (YFAMT,YFCY,YRATE,YMARKET,LCY.AMT,"","")
                    CQ.ChqIssue.setCqLcyAmt(LCY.AMT)
                    CQ.ChqIssue.setCqCharges(YFAMT)
                END
            END ELSE
                CQ.ChqIssue.setCqLcyAmt('')
            END
        CASE 1
*
* If a flat issue charge is defined start with this
*
            CQ.ChqIssue.setCqCharges(0)
            IF CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgFlatIssueChg> THEN CQ.ChqIssue.setCqCharges(CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgFlatIssueChg>)
*
* Then proceed to band and level charges for the number issued. This is
* based on the number issued in this charging period as held on the cheque
* register.
*
            UPTO = CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueUpto>
            AMNT = CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueChgAmt>
            VALC = COUNT(UPTO,@VM)+1
            NUMB = CQ.ChqIssue.getCqNumberIs()  ;* for LEVEL caculation only the currently issued number of cheques must be considered.
            IF CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueBandLevel> = 'LEVEL' THEN
                FOR V$NUM = 1 TO VALC
                    IF NUMB <= UPTO<1,V$NUM> OR V$NUM = VALC THEN
                        CQ.ChqIssue.setCqCharges(CQ.ChqIssue.getCqCharges() + (CQ.ChqIssue.getCqNumberIs()*AMNT<1,V$NUM>))
                        V$NUM = VALC
                    END
                NEXT V$NUM
            END ELSE
                CNT = CQ.ChqIssue.getCqNumberIs()
                LAST.BAND = 0
                NO.CHG = 0
                FOR I = 1 TO VALC
                    BEGIN CASE
                        CASE I = VALC
                            NO.CHG = CNT
                        CASE CQ.ChqIssue.getCqIssuedThisPd() GT UPTO<1,I>
                            NULL
                        CASE CQ.ChqIssue.getCqIssuedThisPd() GT LAST.BAND
                            IF (CNT + CQ.ChqIssue.getCqIssuedThisPd()) LE UPTO<1,I> THEN
                                NO.CHG = CNT
                            END ELSE
                                NO.CHG = UPTO<1,I> - CQ.ChqIssue.getCqIssuedThisPd()
                            END
                        CASE CNT + LAST.BAND LE UPTO<1,I>
                            NO.CHG = CNT
                        CASE 1
                            NO.CHG = UPTO<1,I> - LAST.BAND
                    END CASE
                    CNT -= NO.CHG
                    LAST.BAND = UPTO<1,I>
                    CHG.VAL1 = CQ.ChqIssue.getCqCharges()
                    CHG.VAL1 += (NO.CHG * AMNT<1,I>)
                    CQ.ChqIssue.setCqCharges(CHG.VAL1)
                UNTIL CNT = 0
                NEXT I
            END
            IF CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency> <> EB.SystemTables.getLccy() AND CQ.ChqIssue.getCqCharges() THEN  ; * EN_10000101 - dynamic
                CQ.ChqIssue.setCqLcyAmt(CQ.ChqIssue.getCqCharges())
                YFAMT = ""
                YFCY = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCurrency)
                YRATE = CQ.ChqIssue.getCqExchRate()<1>
                YMARKET = CQ.ChqIssue.getCqCcyMkt()
                YLAMT = CQ.ChqIssue.getCqCharges()
                YDIF.AMT = ""
                YDIF.PCT = ""
                ST.ExchangeRate.MiddleRateConvCheck (YFAMT,YFCY,YRATE,YMARKET,YLAMT,YDIF.AMT,YDIF.PCT)
                CQ.ChqIssue.setCqCharges(YFAMT)
            END
    END CASE
    GOSUB CALCULATETAX.VAL ; *TAX.CALCULATE
    CQ.ChqIssue.setCqIssuedThisPd(SAVE.ISSUED.THIS.PD)
RETURN
*-----------(Charges.Val)
*-----------------------------------------------------------------------------
*** <region name= CALCULATETAX.VAL>
CALCULATETAX.VAL:
*** <desc>TAX.CALCULATE </desc>
    TAX.ID=''
    CHARGES=CQ.ChqIssue.getCqCharges()
    CQ.ChqIssue.setCqCharges(CHARGES)
    TAX.ID=CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgTaxId>

    TAX.DATA<1,1> =TAX.ID
    TAX.DATA<2,1> = ''
    
    TAX.DATA<68> = 'YES' ;* To Retrive Commission/charge/tax even its value is Zero

    ACCT.CUST = CQ.ChqIssue.getCqAcctCust()
    ACCT.CURR = CQ.ChqIssue.getCqAcctCurr()
    CURR.MKT = CQ.ChqIssue.getCqCcyMkt()
    CUST.COND = CQ.ChqIssue.getCqCustCond()
    IF CHARGES GT 0 AND TAX.ID NE '' THEN
        CG.ChargeConfig.CalculateCharge(ACCT.CUST , CHARGES, ACCT.CURR, CURR.MKT, EXCH.RATE, '', ACCT.CURR, TAX.DATA, CUST.COND, '', '')
      
        CQ.ChqIssue.setCqChqTaxData(TAX.DATA)
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------------------
CALC.ISSUE.PERIOD.DATES:
*-----------------------
* If charges are defined for issue and other than flat charge then take
* the start date of the issue charging period, cycle it forward to get
* the end date. If the issue date of this issue falls within this period
* then fine, do nothing more than charge normally. If the issue date
* falls into the next period then the register period must be reset

    CQ.ChqIssue.setCqIssueRollover(0)
    IF CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueUpto> THEN

        IF CQ.ChqIssue.getCqIssueStartDate() = '' THEN
            CQ.ChqIssue.setCqIssueStartDate(CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate>)
            CQ.ChqIssue.setCqIssueStartDate(EB.SystemTables.getToday()[1,4]:CQ.ChqIssue.getCqIssueStartDate()[2]:CQ.ChqIssue.getCqIssueStartDate()[1,2])
            IF CQ.ChqIssue.getCqIssueStartDate() > EB.SystemTables.getToday() THEN CQ.ChqIssue.setCqIssueStartDate(CQ.ChqIssue.getCqIssueStartDate()[1,4]-1:CQ.ChqIssue.getCqIssueStartDate()[5,4])
        END
        CQ.ChqIssue.setCqIssueEndDate(CQ.ChqIssue.getCqIssueStartDate()); * CI_10000413
        SAVED.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(CQ.ChqIssue.getCqIssueStartDate():CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueChgFqu>)
        EB.API.Cfq()
        CQ.ChqIssue.setCqIssueEndDate(EB.SystemTables.getComi()[1,8]); * CI_10000413
        EB.SystemTables.setComi(SAVED.COMI)

        IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate) >= CQ.ChqIssue.getCqIssueEndDate()) AND (CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgIssueChgFqu>)  THEN

            CQ.ChqIssue.setCqIssueRollover(1)  ;* if no ISSUE.CHG.FQU is given then the rollover shouldnot be set
        END
    END

RETURN
*-----------(Calc.Issue.Period.Dates)

END
*-----(End of routine Cheque.Issue.Charges.Val)

