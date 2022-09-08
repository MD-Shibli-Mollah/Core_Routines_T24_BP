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

*
*-----------------------------------------------------------------------------
* <Rating>31582</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.SW.ACCOUNTING(SCHEDULE.TYPE,LEG.TYPE,AMOUNT,VALUE.DATE,PROCESS.DATE,NARRATIVE,REVERSAL,LCY.AMOUNT,CHARGE.DETAILS)
*
************************************************************************
*                                                                      *
*  Routine     :  CONV.SW.ACCOUNTING                                        *
*                                                                      *
************************************************************************
*                                                                      *
*  Description :  This routine will create all accounting and crf      *
*                 entries for swap contracts.  It will be called for   *
*                 each schedule event in the swap, both asset and      *
*                 liability, to create the entries and 'append' them   *
*                 to an array of entries, held in common (I_SW.COMMON).*
*                 Accounting entries will be appended to the entry     *
*                 array SW.ACCOUNTING.ENTRIES, and Forward entries to  *
*                 the entry array SW.FORWARD.ENTRIES.                  *
*                 They will then be passed to EB.ACCOUNTING by the     *
*                 calling routine.                                     *
*                                                                      *
*                 The arguments supplied to SW.ACCOUNTING are as       *
*                 follows :                                            *
*                                                                      *
*                 o SCHEDULE.TYPE   -  The schedule being processed.   *
*                                      Id of SWAP.SCHEDULE.TYPE.       *
*                                                                      *
*                 o LEG.TYPE        -  Leg being processed.            *
*                                      Asset or Liability (A or L).    *
*                                                                      *
*                 o AMOUNT          -  Amount to be post (unsigned)    *
*                                      and in the correct currency.    *
*                                                                      *
*                 o VALUE.DATE      -  Value Date of schedule.         *
*                                      Default today.                  *
*                                                                      *
*                 o PROCESS.DATE    -  Process date of underlying      *
*                                      schedule (ie. Forward or Real   *
*                                      entry).  Default today.         *
*                                                                      *
*                 o NARRATIVE       -  Narrative to be included on the *
*                                      entry (1 or 0).                 *
*                                                                      *
*                 o REVERSAL        -  Flag to indicate entries are    *
*                                      reversals.                      *
*                                                                      *
*                 Arguments returned :                                 *
*                                                                      *
*                 o LCY.AMOUNT      -  Local currency amount.     I/O  *
*                                      Used for history purposes only. *
*                                                                      *
*                 o CHARGE.DETAILS  -  Charge/fee code(s)         I/O  *
*                                      Local curency amount         O  *
*                                      Foreign currency amount      O  *
*                                                                      *
************************************************************************
*                                                                      *
*  Modifications :                                                     *
*                                                                      *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 21/09/10 -  Defect 18083 / Task 33157
*             Linear method of NPV revaluation.
*
* 05/10/10 - EN - 24733/ Task - 61646
*            Change in accounting rules for swaps with negative rates
*

************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLASS
    $INSERT I_F.BROKER
    $INSERT I_F.DATES
    $INSERT I_F.DEALER.DESK
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_F.SWAP.PARAMETER
    $INSERT I_F.SWAP.REVAL.PARAMETER
    $INSERT I_F.SWAP.SCHEDULE.TYPE
    $INSERT I_F.SWAP.TYPE
    $INSERT I_SW.COMMON
    $INSERT I_SW.TRANSACTION.CODES
    $INSERT I_BATCH.FILES
*
*************************************************************************
*
    GOSUB INITIALISATION
*
* ignore schedule.type on reversal of a charge/fee
*
    IF REVERSAL AND CHARGE.DETAILS THEN
        GOSUB REVERSE.CHARGES.AND.FEES
    END ELSE
        SAVE.AMOUNT = AMOUNT  ;* keep a copy of the process.value
        GOSUB PROCESS.SCHEDULE
        IF NOT(REVERSAL) THEN
            GOSUB PROCESS.CHARGES.AND.FEES
        END
        AMOUNT = SAVE.AMOUNT  ;* restore to original amount
    END
*
    RETURN          ;* main return
*
*************************************************************************
*                                                                       *
*  Local subroutines.                                                   *
*                                                                       *
*************************************************************************
*
***************
INITIALISATION:
***************
*
*  CHARGE.DETAILS<1,x> - charge/fee codes
*                <2,x> - amount in local currency
*                <3,x> - amount in foreign currency
    IF NOT(REVERSAL) THEN
        CHARGE.DETAILS = ""
    END
*
    ACCOUNT.NUMBER = '' ; FOUND.CLIENT.ENNTRY = 0
    Y.TOT.MKT.EX.INT.AMT = 0 ; Y.CUR.CUST.RATE = '' ; Y.CUR.TRSY.RATE = ''
*
*  NET.CHARGES is only used by "IS" schedule for the time being
*  it can be defined in SWAP.SCHEDULE.TYPE for future development
*
    NET.CHARGES = (SCHEDULE.TYPE[1,2] EQ "IS")
*
*  Open files.
*
    F.SWAP.TYPE.ENT.TODAY = ""
    CALL OPF("F.SWAP.TYPE.ENT.TODAY",F.SWAP.TYPE.ENT.TODAY)
*
    R.SWAP.SCHED.TYPE = "" ; ER = ""    ;* GLOBUS_BG_100007219 /S
    CALL CACHE.READ('F.SWAP.SCHEDULE.TYPE',SCHEDULE.TYPE,R.SWAP.SCHED.TYPE,ER)
    IF ER THEN
        ETEXT = "SW.RTN.CANT.READ.SWAP.SCHEDULE.TYPE":FM:SCHEDULE.TYPE
        GOTO FATAL.ERROR
    END
*
 	R.SWAP.REVAL.PARAMETER = '' ; ER = ''
    CALL CACHE.READ('F.SWAP.REVAL.PARAMETER','SYSTEM',R.SWAP.REVAL.PARAMETER,ER)

    SWAP.TRANSACTION.CODE = R.SWAP.SCHED.TYPE<SW.SCHED.TRANSACTION.CODE>
    TRANSACTION.CODE = SWAP.TRANSACTION.CODE      ;* used in build.base.entry
*
*  Set value date.
*
    IF VALUE.DATE = "" THEN
        VALUE.DATE = TODAY
    END
*
*  Set process date.
*
    IF PROCESS.DATE = "" THEN
        PROCESS.DATE = TODAY
    END
*
    EOD.SCHEDULES = "IP,AP,RX,CM"
    CONVERT "," TO VM IN EOD.SCHEDULES
*
*  Determine whether forward or live entries should be raised.
*  EOD schedules processed on-line are still classified as FORWARD.
*
    ORIG.VALUE.DATE = FIELD(PROCESS.DATE,VM,2)
    PROCESS.DATE = FIELD(PROCESS.DATE,VM,1)
    GOSUB CHECK.FORWARD.ENTRY

    GOSUB GET.LEG.DETAILS

*
    IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN
        NOTIONAL = 0
        ORIG.NOTIONAL = 0
    END ELSE
        Y.PX.FOUND = 0 ; Y.SCHED.TYPE = '' ; Y.FIELD.POSN = 0 ; Y.VALUE.POSN = 0
        IF LEG.TYPE EQ 'A' THEN
            Y.SCHED.TYPE = R$SWAP<SW.AS.TYPE>
        END ELSE
            Y.SCHED.TYPE = R$SWAP<SW.LB.TYPE>
        END

* Priority 1 - Find from SWAP contract
        FIND 'PX' IN Y.SCHED.TYPE SETTING Y.FIELD.POSN, Y.VALUE.POSN THEN
            Y.PX.FOUND = 1
        END

* Priority 2 - Find from SWAP.BALANCES
        IF NOT(Y.PX.FOUND) THEN
            Y.PX.FOUND = (ORIG.NOTIONAL EQ "NO")
        END
    END
*  Construct the negative amount list.
*
    NEGATIVE.AMOUNT.LIST = ""
    NEGATIVE.AMOUNT.LIST<-1> = "ACI"    ;* Asset Contract Initiation
    NEGATIVE.AMOUNT.LIST<-1> = "LPX"    ;* Liab Principal Exchange
    NEGATIVE.AMOUNT.LIST<-1> = "LIS"    ;* Liab Issue Price
    NEGATIVE.AMOUNT.LIST<-1> = "LAC"    ;* Liab Interest Accrual
    NEGATIVE.AMOUNT.LIST<-1> = "LAM"    ;* Liab Interest Accrual
    NEGATIVE.AMOUNT.LIST<-1> = "LAY"    ;* Liab Interest Accrual
    NEGATIVE.AMOUNT.LIST<-1> = "AIP"    ;* Asset Interest Payment
    NEGATIVE.AMOUNT.LIST<-1> = "AAP"    ;* Asset Annuity Payment
    NEGATIVE.AMOUNT.LIST<-1> = "ARX"    ;* Asset Principal Re-exchange
    NEGATIVE.AMOUNT.LIST<-1> = "LCM"    ;* Liab Contract Maturity
    NEGATIVE.AMOUNT.LIST<-1> = "LPI"    ;* Liab Principal Increase
    NEGATIVE.AMOUNT.LIST<-1> = "APD"    ;* Asset Principal Decrease
    NEGATIVE.AMOUNT.LIST<-1> = "LNI"    ;* Liab Notional Principal Increase
    NEGATIVE.AMOUNT.LIST<-1> = "AND"    ;* Asset Notional Principal Increase
*
    IF NOT(REVERSAL) THEN
        LCY.AMOUNT = ""
    END

    EXCH.RATE = ""
    GOSUB DETERMINE.CCY.AMOUNTS         ;* Determine and sign LCY and FCY amounts.
*
    BASE.CURRENCY = R$SWAP<SW.BASE.CURRENCY>
    GOSUB SET.RESERVE.ENTRY.DETAILS
*
    RETURN          ;* to main
*
*-----------------------
CHECK.FORWARD.ENTRY:
*-----------------------
    FORWARD.ENTRY = 0

* The COB processing of SW.EOD.SCHEDULE.SELECT has been modified and hence
* changed the FORWARD.ENTRY check with respective to the COB processing date
    IF NOT(RUNNING.UNDER.BATCH) THEN
        IF (SCHEDULE.TYPE[1,2] MATCHES EOD.SCHEDULES) THEN
            FORWARD.ENTRY = 1
        END ELSE
            IF PROCESS.DATE > TODAY THEN
                FORWARD.ENTRY = 1
            END
        END
    END ELSE
        IF CONTROL.LIST<1,1> THEN
            Y.CURRENT.DATE = CONTROL.LIST<1,1>
            FORWARD.ENTRY = (PROCESS.DATE GT Y.CURRENT.DATE)
        END ELSE
            FORWARD.ENTRY = (PROCESS.DATE GT TODAY)
        END
    END
    RETURN
*-----------------------
GET.LEG.DETAILS:
*-----------------------
* Determine original principal.
*      whether principal is notional or real.
*      crf interest date and maturity date and currency of leg.
*      current interest amount or past interest amount (if REVERSAL).
*      information of the other leg.

    IF LEG.TYPE = "A" THEN    ;*  Asset.
*
        ORIGINAL.PRINCIPAL = R$SWAP<SW.AS.PRINCIPAL>
        NOTIONAL = (R$SW.ASSET.BALANCES<SW.BAL.NOTIONAL> EQ "Y")
        ORIG.NOTIONAL = R$SW.ASSET.BALANCES<SW.BAL.NOTIONAL>
        LEG.CCY = R$SW.ASSET.BALANCES<SW.BAL.CURRENCY>
        INTEREST.AMOUNT = R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT>
        CRF.INTEREST.DATE = R$SW.ASSET.BALANCES<SW.BAL.CRB.INTEREST.DATE>
        CRF.MATURITY.DATE = R$SW.ASSET.BALANCES<SW.BAL.CRB.MATURITY.DATE>
        INITIAL.XRATE = R$SW.ASSET.BALANCES<SW.BAL.INITIAL.XRATE>
        OUTS.PRIN.LCY = R$SW.ASSET.BALANCES<SW.BAL.OUTS.PRIN.LCY>
        CCY.REVAL.PL = R$SW.ASSET.BALANCES<SW.BAL.CCY.REVAL.PL>
        OUTS.PRIN.FCY = R$SW.ASSET.BALANCES<SW.BAL.PRINCIPAL, 1>

*
        OTHER.ORIGINAL.PRINCIPAL = R$SWAP<SW.LB.PRINCIPAL>
        OTHER.LEG.PRINCIPAL = R$SW.LIABILITY.BALANCES<SW.BAL.PRINCIPAL,1>
        OTHER.LEG.CCY = R$SW.LIABILITY.BALANCES<SW.BAL.CURRENCY>
        OTHER.OUTS.PRIN.LCY = R$SW.LIABILITY.BALANCES<SW.BAL.OUTS.PRIN.LCY>
*
        IF R$SW.ASSET.BALANCES<SW.BAL.TOT.MKT.INT.AMT> THEN
            Y.TOT.MKT.EX.INT.AMT = R$SW.ASSET.BALANCES<SW.BAL.TOT.MKT.INT.AMT>
        END

        Y.CUR.CUST.RATE = R$SWAP<SW.AS.CURRENT.RATE>
        Y.CUR.TRSY.RATE = R$SWAP<SW.AS.CUR.TRSRY.RATE>
*
    END ELSE        ;* Liability.
*
        ORIGINAL.PRINCIPAL = R$SWAP<SW.LB.PRINCIPAL>
        NOTIONAL = (R$SW.LIABILITY.BALANCES<SW.BAL.NOTIONAL> EQ "Y")
        ORIG.NOTIONAL = R$SW.LIABILITY.BALANCES<SW.BAL.NOTIONAL>
        LEG.CCY = R$SW.LIABILITY.BALANCES<SW.BAL.CURRENCY>
        INTEREST.AMOUNT = R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT>
        CRF.INTEREST.DATE = R$SW.LIABILITY.BALANCES<SW.BAL.CRB.INTEREST.DATE>
        CRF.MATURITY.DATE = R$SW.LIABILITY.BALANCES<SW.BAL.CRB.MATURITY.DATE>
        INITIAL.XRATE = R$SW.LIABILITY.BALANCES<SW.BAL.INITIAL.XRATE>
        OUTS.PRIN.LCY = R$SW.LIABILITY.BALANCES<SW.BAL.OUTS.PRIN.LCY>
        CCY.REVAL.PL = R$SW.LIABILITY.BALANCES<SW.BAL.CCY.REVAL.PL>
        OUTS.PRIN.FCY = R$SW.LIABILITY.BALANCES<SW.BAL.PRINCIPAL, 1>
*
        OTHER.ORIGINAL.PRINCIPAL = R$SWAP<SW.AS.PRINCIPAL>
        OTHER.LEG.CCY = R$SW.ASSET.BALANCES<SW.BAL.CURRENCY>
        OTHER.LEG.PRINCIPAL = R$SW.ASSET.BALANCES<SW.BAL.PRINCIPAL,1>
        OTHER.OUTS.PRIN.LCY = R$SW.ASSET.BALANCES<SW.BAL.OUTS.PRIN.LCY>
*
        IF R$SW.LIABILITY.BALANCES<SW.BAL.TOT.MKT.INT.AMT> THEN
            Y.TOT.MKT.EX.INT.AMT = R$SW.LIABILITY.BALANCES<SW.BAL.TOT.MKT.INT.AMT>
        END

        Y.CUR.CUST.RATE = R$SWAP<SW.LB.CURRENT.RATE>
        Y.CUR.TRSY.RATE = R$SWAP<SW.LB.CUR.TRSRY.RATE>
*
    END
    RETURN

**************************
SET.RESERVE.ENTRY.DETAILS:
**************************
*
    ACCOUNT.CAT = '' ; R.ACCOUNT.CLASS = ""
    CALL CACHE.READ('F.ACCOUNT.CLASS','SWREVAL',R.ACCOUNT.CLASS,ETEXT)
    IF ETEXT THEN
        GOTO FATAL.ERROR
    END ELSE
        ACCOUNT.CAT = R.ACCOUNT.CLASS<AC.CLS.CATEGORY>
    END
*
    REVAL.DEPT = '' ; R.DEALER.DESK = ""
    CALL CACHE.READ('F.DEALER.DESK',R$SWAP<SW.DEALER.DESK>,R.DEALER.DESK,"")
    REVAL.DEPT = R.DEALER.DESK<FX.DD.DEPT>
    REVAL.DEPT = FMT(REVAL.DEPT,'4"0"R')
*
    RESERVE.ACCOUNT.NUMBER = LCCY:ACCOUNT.CAT:REVAL.DEPT
    RESERVE.DR.CODE = R.SWAP.REVAL.PARAMETER<SW.REVAL.PARAM.CCY.REVAL.DR.CODE>
    RESERVE.CR.CODE = R.SWAP.REVAL.PARAMETER<SW.REVAL.PARAM.CCY.REVAL.CR.CODE>
    CCY.REVAL.PL.CATEG = R.SWAP.REVAL.PARAMETER<SW.REVAL.PARAM.CCY.REVAL.PL.CATEG>
*
*
    RETURN
*
*************************************************************************
*
*************************
REVERSE.CHARGES.AND.FEES:
*************************
*
    CHARGE.OR.FEE = (IF AMOUNT < 0 THEN 'F' ELSE 'C')
    AMOUNT = ABS(AMOUNT)
    GOSUB RESET.AMOUNTS       ;* lcy.amount fcy.amount should be unsigned
*
    T.DATA = CHARGE.DETAILS<1, 1>       ;* should only have one charge/fee code
    GOSUB CALL.CALC.CHARGE    ;* determine charge.acct/p&l.categ
*
    POST.CODE = T.DATA<3, 1>  ;* account no. or p&l category
    CREDIT.TXN.CODE = T.DATA<7, 1>
    DEBIT.TXN.CODE = T.DATA<8, 1>
    NARRATIVE = ''
*
* only live entry on reversal
*
    GOSUB RAISE.CHARGE.ACCT
    GOSUB RESET.AMOUNTS       ;* lcy.amount and fcy.amount should be unsigned
    GOSUB RAISE.CHARGE.PL
*
    RETURN
*
*****************
PROCESS.SCHEDULE:
*****************
*
    BEGIN CASE
*
    CASE SCHEDULE.TYPE[1,2] MATCHES "AC":VM:"AM":VM:"AY"
        GOSUB AC.INTEREST.ACCRUAL
*
    CASE SCHEDULE.TYPE[1,2] = "CI"
        IF AMOUNT THEN
            IF FORWARD.ENTRY THEN
                GOSUB CI.CONTRACT.INITIATION.FWD
            END ELSE
                GOSUB CI.CONTRACT.INITIATION.LIVE
                GOSUB BR.BROKER.ENTRIES
            END
        END
*
    CASE SCHEDULE.TYPE[1,2] = "CM"
        IF NOT(FORWARD.ENTRY) THEN
            GOSUB CM.CONTRACT.MATURITY
        END
*
    CASE SCHEDULE.TYPE[1,2] = "NR"
        GOSUB NR.NPV.REVAL
*
    CASE SCHEDULE.TYPE[1,2] = "RL"
* If REVERSAL is set then the amounts are backed out.
        GOSUB RL.CURRENCY.REVAL
*
    CASE SCHEDULE.TYPE[1,2] = "PX"
        IF FORWARD.ENTRY THEN
            GOSUB PX.PRINCIPAL.EXCHANGE.FWD
        END ELSE
            GOSUB PX.PRINCIPAL.EXCHANGE.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "RX"
        IF FORWARD.ENTRY THEN
            GOSUB RX.PRINCIPAL.REEXCHANGE.FWD
        END ELSE
            GOSUB RX.PRINCIPAL.REEXCHANGE.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "PI"
        IF FORWARD.ENTRY THEN
            GOSUB PI.PRINCIPAL.INCREASE.FWD
        END ELSE
            GOSUB PI.PRINCIPAL.INCREASE.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "NI"
        IF NOT(FORWARD.ENTRY) THEN
            GOSUB NI.PRINCIPAL.INCREASE.LIVE
        END
    CASE SCHEDULE.TYPE[1,2] = "ND"
        IF NOT(FORWARD.ENTRY) THEN
            GOSUB ND.PRINCIPAL.DECREASE.LIVE
        END
    CASE SCHEDULE.TYPE[1,2] = "PD"
        IF FORWARD.ENTRY THEN
            GOSUB PD.PRINCIPAL.DECREASE.FWD
        END ELSE
            GOSUB PD.PRINCIPAL.DECREASE.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "IP"
        IF FORWARD.ENTRY THEN
            GOSUB IP.INTEREST.PAYMENT.FWD
        END ELSE
            GOSUB IP.INTEREST.PAYMENT.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] MATCHES "PM":VM:"RV"
        IF FORWARD.ENTRY THEN
            GOSUB PM.PAYMENT.ACCT
        END ELSE
            GOSUB PM.PAYMENT.ACCT
            GOSUB RESET.AMOUNTS         ;* lcy.amount and fcy.amount should be unsigned
            GOSUB PM.PAYMENT.PL
        END
*
    CASE SCHEDULE.TYPE[1,2] = "IS"
        IF FORWARD.ENTRY THEN
            GOSUB PX.PRINCIPAL.EXCHANGE.FWD
        END ELSE
            IF NOT(REVERSAL) THEN
                LCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
            END
            GOSUB IS.ISSUE.PRICE.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "AP"
        IF FORWARD.ENTRY THEN
            GOSUB AP.ANNUITY.PAYMENT.FWD
        END ELSE
            GOSUB AP.ANNUITY.PAYMENT.LIVE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "CC"
        GOSUB CC.CHARGE
*
    END CASE
*
    RETURN
*
*************************
PROCESS.CHARGES.AND.FEES:
*************************
*
    SAVE.LCY.AMOUNT = LCY.AMOUNT        ;* save lcy.amount
*
*  Process charges
*
    CHARGE.OR.FEE = 'C'
    CHARGE.CODE = R.SWAP.SCHED.TYPE<SW.SCHED.CHARGE.CODE>
    GOSUB PROCESS.CHARGE
*
*  Process fees
*
    CHARGE.OR.FEE = 'F'
    CHARGE.CODE = R.SWAP.SCHED.TYPE<SW.SCHED.FEE.CODE>
    GOSUB PROCESS.CHARGE
*
    LCY.AMOUNT = SAVE.LCY.AMOUNT        ;* restore lcy.amount
*
    RETURN
*
*************************************************************************
*
*****************
BUILD.BASE.ENTRY:
*****************
*
***********************************************************
*  Build base STMT.ENTRY entry fields.                    *
***********************************************************
*
    ENTRY = ""
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = ""
    ENTRY<AC.STE.COMPANY.CODE> = ID.COMPANY
    ENTRY<AC.STE.AMOUNT.LCY> = 0
    ENTRY<AC.STE.TRANSACTION.CODE> = TRANSACTION.CODE
    ENTRY<AC.STE.THEIR.REFERENCE> = R$SWAP<SW.CUSTOMER.REF>
    ENTRY<AC.STE.NARRATIVE> = NARRATIVE
    ENTRY<AC.STE.PL.CATEGORY> = ""
    ENTRY<AC.STE.CUSTOMER.ID> = R$SWAP<SW.CUSTOMER>
    ENTRY<AC.STE.ACCOUNT.OFFICER> = R$SWAP<SW.ACCOUNT.OFFICER>
    ENTRY<AC.STE.PRODUCT.CATEGORY> = R$SWAP<SW.PRODUCT.CATEGORY>
    ENTRY<AC.STE.VALUE.DATE> = VALUE.DATE
    ENTRY<AC.STE.CURRENCY> = LEG.CCY
    ENTRY<AC.STE.AMOUNT.FCY> = ""
    ENTRY<AC.STE.EXCHANGE.RATE> = ""
    ENTRY<AC.STE.POSITION.TYPE> = R$SWAP<SW.POSITION.TYPE>
    ENTRY<AC.STE.OUR.REFERENCE> = C$SWAP.ID:".":LEG.TYPE
    ENTRY<AC.STE.CURRENCY.MARKET> = R$SWAP<SW.CURRENCY.MARKET>
    ENTRY<AC.STE.DEPARTMENT.CODE> = R$SWAP<SW.ACCOUNT.OFFICER>
    ENTRY<AC.STE.TRANS.REFERENCE> = C$SWAP.ID:";":R$SWAP<SW.CURR.NO>+1
    ENTRY<AC.STE.SYSTEM.ID> = "SW"
    ENTRY<AC.STE.BOOKING.DATE> = TODAY
    ENTRY<AC.STE.CRF.TYPE> = ""
    ENTRY<AC.STE.CRF.TXN.CODE> = ""
    ENTRY<AC.STE.CRF.MAT.DATE> = ""
    ENTRY<AC.STE.DEALER.DESK> = R$SWAP<SW.DEALER.DESK>
*
    IF REVERSAL THEN
        ENTRY<AC.STE.REVERSAL.MARKER> = "R"
    END ELSE
        ENTRY<AC.STE.REVERSAL.MARKER> = ""
    END
*
    RETURN
*
*************************************************************************
*
********************
AC.INTEREST.ACCRUAL:
********************
*
***********************************************************
*  Asset sched     : Credit P&L     -  Debit Accrual      *
*  Liability sched : Credit Accrual -  Debit P&L          *
*  Accrual category code = P&L category code.             *
***********************************************************
*
    Y.MKT.EXCH.CALC = 0 ; Y.MKT.PROFIT.LOSS = 'P' ;* EN_10002630 - S
    IF NARRATIVE THEN         ;* Specific to Market Exchange Accrual
        Y.MKT.EXCH.CALC = 1
        NARRATIVE = ''
    END
*
*Determine whether it is an income or expense to the bank
    GOSUB DETERMINE.INCOME.OR.EXPENSE

    IF EXPENSE.CATEGORY THEN
*
        CRF.TYPE = R$SWAP.PARAMETER<SW.PARAM.EXPENSE.CURR.ACCRUAL>
*
        BEGIN CASE
        CASE SCHEDULE.TYPE[2,1] = "C"
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.EXPENSE.CURR.ACCRUAL>
        CASE SCHEDULE.TYPE[2,1] = "M"
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.EXPENSE.PREV.MONTH>
        CASE SCHEDULE.TYPE[2,1] = "Y"
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.EXPENSE.PREV.YEAR>
        END CASE
*
        IF Y.CUR.TRSY.RATE AND (Y.CUR.CUST.RATE GT Y.CUR.TRSY.RATE) THEN
            Y.MKT.PROFIT.LOSS = 'L'
        END
    END ELSE
*
        CRF.TYPE = R$SWAP.PARAMETER<SW.PARAM.INCOME.CURR.ACCRUAL>
*
        BEGIN CASE
        CASE SCHEDULE.TYPE[2,1] = "C"
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.INCOME.CURR.ACCRUAL>
        CASE SCHEDULE.TYPE[2,1] = "M"
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.INCOME.PREV.MONTH>
        CASE SCHEDULE.TYPE[2,1] = "Y"
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.INCOME.PREV.YEAR>
        END CASE
*
        IF Y.CUR.TRSY.RATE AND (Y.CUR.CUST.RATE LT Y.CUR.TRSY.RATE) THEN
            Y.MKT.PROFIT.LOSS = 'L'
        END
    END
*
    IF Y.MKT.EXCH.CALC THEN   ;* Market Exchange Accrual
        Y.REVERSE.FLAG = 0

        BEGIN CASE
        CASE INCOME.CATEGORY AND Y.MKT.PROFIT.LOSS = 'P'
            Y.REVERSE.FLAG = 1
        CASE EXPENSE.CATEGORY AND Y.MKT.PROFIT.LOSS = 'L'
            Y.REVERSE.FLAG = 1
        END CASE

        IF Y.REVERSE.FLAG THEN GOSUB REVERSE.AMOUNTS
    END
*
    GOSUB BUILD.BASE.ENTRY
*
    IF REVERSAL THEN
        TXN.CODE = SW.TC.REV.CONTRACT
    END ELSE
        TXN.CODE = SW.TC.INTR.ACCRUAL
    END
*
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    ENTRY<AC.STE.PL.CATEGORY> = PL.CATEGORY
    ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
    ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE

* To Raise the contra entry of P&L in RE.CONSOL.SPEC.ENTRY
    IF NOT(Y.MKT.EXCH.CALC) THEN
        ENTRY<AC.STE.CRF.TYPE> = CRF.TYPE
        ENTRY<AC.STE.CRF.TXN.CODE> = TXN.CODE
        ENTRY<AC.STE.CRF.MAT.DATE> = CRF.INTEREST.DATE
    END

    GOSUB APPEND.LIVE.ENTRIES ;* Raise P/L

* To Raise the contra entry of P&L in Market Exchange Suspence Account
    IF Y.MKT.EXCH.CALC THEN
        PROD.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PRD.PR.CAT>
        IF Y.MKT.PROFIT.LOSS = 'L' THEN
            PROD.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PRD.LO.CAT>
        END

        IF NOT(PROD.CATEGORY) THEN
            ETEXT = 'SW-MISS.MKT.EXCH.PROD.CATEGORY'
            GOTO FATAL.ERROR
        END ELSE
            RESERVE.ACCOUNT.NUMBER = LCCY:PROD.CATEGORY:REVAL.DEPT
            OUTS.PRIN.LCY = LCY.AMOUNT
            GOSUB RAISE.RESERVE.ENTRY   ;* Raise Suspence entry
        END
    END
*
    RETURN
*
*----------------------------
DETERMINE.INCOME.OR.EXPENSE:
*----------------------------
* For deals with positive rates, the bank has to receive(income) on asset leg and pay(expense) on liability leg
* For deals with negative rates, the bank has to pay(expense) on asset leg and receive(income) on liability leg
* Hence the income and expense category has to be used accordingly

    EXPENSE.CATEGORY = ''
    INCOME.CATEGORY = ''
    BEGIN CASE
    CASE LEG.TYPE = "A"
        IF R$SWAP<SW.NEGATIVE.RATES> EQ "YES" AND ((Y.CUR.CUST.RATE NE '' AND Y.CUR.CUST.RATE < 0) OR AMOUNT < 0) THEN
            EXPENSE.CATEGORY = 1
        END ELSE
            INCOME.CATEGORY = 1
        END

    CASE LEG.TYPE = "L"
        IF R$SWAP<SW.NEGATIVE.RATES> EQ "YES" AND ((Y.CUR.CUST.RATE NE '' AND Y.CUR.CUST.RATE < 0) OR AMOUNT < 0) THEN
            INCOME.CATEGORY = 1
        END ELSE
            EXPENSE.CATEGORY = 1
        END
    END CASE

    RETURN
******************
BR.BROKER.ENTRIES:
******************
*
* Always raise live entries regardless of contract status
*
    IF R$SWAP<SW.BROKER.CODE> AND R$SWAP<SW.BROKERAGE.BASE>[1,1] EQ LEG.TYPE THEN
        BR.FREQ = ''
        IF REVERSAL THEN
            IS.GENERIC.SWAP = 'Y'
        END ELSE
            IS.GENERIC.SWAP = ''
            CALL CONV.SW.DETERMINE.GENERIC.IRS(IS.GENERIC.SWAP, BR.FREQ, C$SWAP.ID)
        END
*
        IF IS.GENERIC.SWAP EQ 'Y' THEN
*
            IF R$SWAP<SW.BROKERAGE.BASE> EQ 'ASSET' THEN
                BR.VALUE.DATE = R$SWAP<SW.AS.INT.EFFECTIVE>
                BR.PRINCIPAL = R$SWAP<SW.AS.PRINCIPAL>
                BR.CURRENCY = R$SWAP<SW.AS.CURRENCY>
                BR.RATE = R$SWAP<SW.AS.CURRENT.RATE>
                BR.END.INT.PERIOD = R$SW.ASSET.BALANCES<SW.BAL.END.INT.PERIOD>
            END ELSE
                BR.VALUE.DATE = R$SWAP<SW.LB.INT.EFFECTIVE>
                BR.PRINCIPAL = R$SWAP<SW.LB.PRINCIPAL>
                BR.CURRENCY = R$SWAP<SW.LB.CURRENCY>
                BR.RATE = R$SWAP<SW.LB.CURRENT.RATE>
                BR.END.INT.PERIOD = R$SW.LIABILITY.BALANCES<SW.BAL.END.INT.PERIOD>
            END
*
            GOSUB GET.BROKER.ENTRIES.DETAILS
            GOSUB RAISE.BROKER.ENTRIES
            NARRATIVE = SAVE.NARR
        END
    END
*
    RETURN
*
***************************
GET.BROKER.ENTRIES.DETAILS:
***************************
*
    APP.CATEGORY.CODE = "" ; ER = "" ; R.ACCOUNT.CLASS = ""
    CALL CACHE.READ('F.ACCOUNT.CLASS',"BROKER",R.ACCOUNT.CLASS,ER)
    APP.CATEGORY.CODE = R.ACCOUNT.CLASS<AC.CLS.CATEGORY>
    IF NOT(APP.CATEGORY.CODE) THEN
        ETEXT ="SW.RTN.ERROR.BROKER.REC.NOT.ON.ACCOUNT.CLASS.FILE"
        GOTO FATAL.ERROR
    END
*
    BROKERAGE.PAYABLE = R$SWAP.PARAMETER<SW.PARAM.BROKERAGE.PAYABLE>
*
    BROKER.SUB.DIVISION = ''
    CALL DBR('BROKER':FM:FX.BKR.BROKER.SUB.DIV,R$SWAP<SW.BROKER.CODE>,BROKER.SUB.DIVISION)
    BROKER.SUB.DIVISION = FMT(BROKER.SUB.DIVISION,"4'0'R")
*
    BROKER.CURRENCY = R$SWAP<SW.BROKER.CURRENCY>
    BROKER.CREDIT.ACCT = BROKER.CURRENCY:APP.CATEGORY.CODE:BROKER.SUB.DIVISION
    IF NOT(BROKER.CREDIT.ACCT) THEN
        ETEXT ='SW.RTN.NO.BROKER.CR.ACCT'
        GOTO FATAL.ERROR
    END
*
    SAVE.NARR = NARRATIVE
    NARRATIVE = "IRS BROKERAGE"
    IF REVERSAL THEN
        NARRATIVE := " - REVERSAL"
    END
*
    RETURN
*
*********************
RAISE.BROKER.ENTRIES:
*********************
*
***********************
* Cr Internal A/C
* Dr Brokerage Payable
***********************
*
* Call CALCULATE.BROKERAGE to get the transaction code
*
    BROKER.INFO = ''
    BROKER.INFO<1> = BR.RATE
    BROKER.INFO<2> = BR.FREQ
    BROKER.INFO<3> = BR.END.INT.PERIOD
    ENTRY.INFO = ''
*
    IF R$SWAP<SW.BROKER.AMOUNT> EQ '' THEN
        R$SWAP<SW.BROKER.AMOUNT> = 0
    END
*
    CALL CALCULATE.BROKERAGE('SW', R$SWAP<SW.BROKER.CODE>, R$SWAP<SW.PRODUCT.CATEGORY>, BR.CURRENCY, BR.PRINCIPAL, BR.VALUE.DATE, R$SWAP<SW.MATURITY.DATE>, R$SWAP<SW.CUSTOMER>, BROKER.INFO, ENTRY.INFO, '', '')
    TRANSACTION.CODE = ENTRY.INFO<AC.STE.TRANSACTION.CODE>
    IF NOT(TRANSACTION.CODE) THEN
        ETEXT ='SW.RTN.NO.BROKER.CR.TRANSACTION.CODE.ON.BROKER.FILE'
        GOTO FATAL.ERROR
    END
*
    IF R$SWAP<SW.BROKER.AMOUNT> EQ '' THEN
        ETEXT ='SW.RTN.BROKER.AMOUNT.MISS'
        GOTO FATAL.ERROR
    END
*
    LCY.AMOUNT = ""
    FCY.AMOUNT = ""
    IF R$SWAP<SW.BROKER.AMOUNT> NE 0 THEN
        GOSUB BUILD.BASE.ENTRY
*
        EXCH.RATE = ''
        BROKER.AMOUNT = R$SWAP<SW.BROKER.AMOUNT>
*
        IF BROKER.CURRENCY EQ LCCY THEN
            LCY.AMOUNT = BROKER.AMOUNT
            FCY.AMOUNT = ""
        END ELSE
            FCY.AMOUNT = BROKER.AMOUNT
            CALL MIDDLE.RATE.CONV.CHECK(FCY.AMOUNT,BROKER.CURRENCY,EXCH.RATE,"1",LCY.AMOUNT,"","")
            CALL EB.ROUND.AMOUNT(LCCY,LCY.AMOUNT,"","")
        END
*
* stmt entry
*
        ENTRY<AC.STE.ACCOUNT.NUMBER> = BROKER.CREDIT.ACCT
        ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
        ENTRY<AC.STE.NARRATIVE> = NARRATIVE
        ENTRY<AC.STE.PL.CATEGORY> = ""
        ENTRY<AC.STE.CUSTOMER.ID> = R$SWAP<SW.BROKER.CODE>
        ENTRY<AC.STE.VALUE.DATE> = TODAY
        ENTRY<AC.STE.CURRENCY> = BROKER.CURRENCY
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
        GOSUB APPEND.LIVE.ENTRIES       ;* always live entry
*
* categ entry
*
        GOSUB REVERSE.AMOUNTS
        ENTRY<AC.STE.ACCOUNT.NUMBER> = ""
        ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
        ENTRY<AC.STE.TRANSACTION.CODE> = 477
        ENTRY<AC.STE.NARRATIVE> = NARRATIVE
        ENTRY<AC.STE.PL.CATEGORY> = BROKERAGE.PAYABLE
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        GOSUB APPEND.LIVE.ENTRIES       ;* always live entry
*
    END
    RETURN
*
***************************
CI.CONTRACT.INITIATION.FWD:
***************************
*
***********************************************************
*  Asset sched     : Debit  FORWARDDB                     *
*  Liability sched : Credit FORWARDCR                     *
***********************************************************
    IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
        CRF.TYPE = "FWDNOTL"
        GOSUB DETERMINE.CRF.ENTRY.DETAIL
        TXN.CODE = SW.TC.NEW.CONTRACT
        MAT.DATE = VALUE.DATE ;* override default mat.date
        GOSUB RAISE.CRF.ENTRY
    END ELSE
* Changed CRF.TYPE for IRS contracts as Forward Notional
        IF Y.PX.FOUND THEN
            CRF.TYPE = "FORWARD"
        END ELSE
            CRF.TYPE = "SWFWNOTL"
        END
        GOSUB DETERMINE.CRF.ENTRY.DETAIL
        GOSUB REVERSE.AMOUNTS

        IF R$SWAP<SW.BALANCE.SHEET> = 'OFF' AND Y.PX.FOUND THEN
            GOSUB UPDATE.CCY.POS
        END

        TXN.CODE = SW.TC.NEW.CONTRACT
        MAT.DATE = VALUE.DATE ;* override default mat.date
        GOSUB REVERSE.AMOUNTS ;* EN_10002397 S/E
        GOSUB RAISE.CRF.ENTRY
    END
*
    RETURN
*
****************************
CI.CONTRACT.INITIATION.LIVE:
****************************
*
***********************************************************
*  Asset sched     : Debit  NOTIONALDB                    *
*  Liability sched : Credit NOTIONALCR                    *
***********************************************************
*
*
* To raise the Market Exchange postings
    IF Y.TOT.MKT.EX.INT.AMT THEN        ;* Applicable only if Market Exchange amount is updated in SWAP.BALANCES
        CALL CONV.SW.MKT.EXCH.ACCOUNTING(LEG.TYPE, Y.TOT.MKT.EX.INT.AMT, VALUE.DATE, PROCESS.DATE, NARRATIVE, REVERSAL, '')
    END

    CRF.TYPE = "NOTIONAL"
* Introduced new asset type for CIRS off-balance contracts
    IF Y.PX.FOUND AND R$SWAP<SW.FLEX.PRIN.PAYMENT> NE 'YES' THEN
        IF R$SWAP<SW.BALANCE.SHEET> = 'ON' THEN
            RETURN
        END ELSE
            CRF.TYPE = "SWOFFBAL"
        END
    END
    GOSUB DETERMINE.CRF.ENTRY.DETAIL
    TXN.CODE = SW.TC.NEW.CONTRACT
    GOSUB RAISE.CRF.ENTRY
*
* Code removed to generate the CRF entry with Asset type "FWDNOTL" for reversing the
* Forward principal
*
    RETURN
*
*********************
CM.CONTRACT.MATURITY:
*********************
*
***********************************************************
*  Asset sched     : Credit NOTIONALDB                    *
*  Liability sched : Debit  NOTIONALCR                    *
*  Only required if there has not been a principal        *
*  exchange and re-exchange.                              *
***********************************************************
*
    CRF.TYPE = "NOTIONAL"
    GOSUB DETERMINE.CRF.ENTRY.DETAIL
    TXN.CODE = SW.TC.MAT.CONTRACT
    GOSUB RAISE.CRF.ENTRY
*
    IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
        GOSUB DETERMINE.FX.ENTRY
        IF NOT(REVERSAL) THEN
            OUTS.PRIN.LCY = 0
            GOSUB UPDATE.OUTS.PRIN.LCY
        END
    END
*
    RETURN
*
*************
NR.NPV.REVAL:
*************
*
* Backout two old entries. Create two new entries.
* One to the reserve account, the other to the P&L account.
*
*
    SAVE.LEG.CCY = LEG.CCY
*
    IF R$SWAP<SW.AS.CURRENCY> <> R$SWAP<SW.LB.CURRENCY> THEN
        LEG.CCY = LCCY
    END
    SAVE.MY.LEG.CCY = LEG.CCY
*
*
    SAVE.NARR = NARRATIVE
    NEW.PL = AMOUNT
*
* first backout old
*
*
* NPV posted in foreign currency in case of changed reval type should be reversed in foreign
    IF R$SWAP<SW.FWD.REVAL.AMOUNT> THEN
        IF R$SWAP<SW.AS.CURRENCY> = R$SWAP<SW.LB.CURRENCY> THEN
            LEG.CCY = R$SWAP<SW.AS.CURRENCY>
            OLD.PL = R$SWAP<SW.FWD.REVAL.AMOUNT>
            OLD.PL.LCY = R$SWAP<SW.FWD.REVAL.PL.LCY>
        END ELSE
            LEG.CCY = LCCY
            OLD.PL = R$SWAP<SW.FWD.REVAL.PL.LCY>
            OLD.PL.LCY = R$SWAP<SW.FWD.REVAL.PL.LCY>
        END
    END ELSE
        LEG.CCY = LCCY
        OLD.PL = R$SWAP<SW.FWD.REVAL.PL.LCY>
        OLD.PL.LCY = R$SWAP<SW.FWD.REVAL.PL.LCY>
    END
    GOSUB GET.NPV.ENTRIES.DETAILS
*
    IF OLD.PL THEN
        IF OLD.PL > 0 THEN
            TRANSACTION.CODE = RESERVE.DR.CODE
            IF OLD.REVAL.PROFIT.CAT THEN
                PL.CATEGORY = OLD.REVAL.PROFIT.CAT
            END ELSE
                PL.CATEGORY = OLD.REVAL.LOSS.CAT
            END
            IF OLD.RESERVE.ACCOUNT.PROFIT THEN
                RESERVE.ACCOUNT.NUMBER = OLD.RESERVE.ACCOUNT.PROFIT
            END ELSE
                RESERVE.ACCOUNT.NUMBER = OLD.RESERVE.ACCOUNT.LOSS
            END
        END ELSE
            TRANSACTION.CODE = RESERVE.CR.CODE
            PL.CATEGORY = OLD.REVAL.LOSS.CAT
            RESERVE.ACCOUNT.NUMBER = OLD.RESERVE.ACCOUNT.LOSS
        END
*
* backout the P & L entry
*
        AMOUNT = OLD.PL
        LCY.AMOUNT = OLD.PL.LCY
        EXCH.RATE = ''
        GOSUB DETERMINE.CCY.AMOUNTS     ;* get exchange rate
*
        IF NOT(REVERSAL) THEN
            GOSUB REVERSE.AMOUNTS
        END
*
        NARRATIVE = SAVE.NARR<1>
        GOSUB RAISE.CATEG.ENTRY
*
* backout reserve account entry
*
        NARRATIVE = SAVE.NARR<2>
        GOSUB RAISE.CCY.RESERVE.ENTRY
*
    END   ;* if OLD.PL
*
    LEG.CCY = SAVE.MY.LEG.CCY
    GOSUB GET.NPV.ENTRIES.DETAILS
*
*
* Now raise new entries if not REVERSAL
*
    IF NOT(REVERSAL) THEN
        IF NEW.PL THEN
            IF NEW.PL > 0 THEN
                TRANSACTION.CODE = RESERVE.CR.CODE
                IF REVAL.PROFIT.CAT THEN
                    PL.CATEGORY = REVAL.PROFIT.CAT
                END ELSE
                    PL.CATEGORY = REVAL.LOSS.CAT
                END
                IF RESERVE.ACCOUNT.PROFIT THEN
                    RESERVE.ACCOUNT.NUMBER = RESERVE.ACCOUNT.PROFIT
                END ELSE
                    RESERVE.ACCOUNT.NUMBER = RESERVE.ACCOUNT.LOSS
                END
            END ELSE
                TRANSACTION.CODE = RESERVE.DR.CODE
                PL.CATEGORY = REVAL.LOSS.CAT
                RESERVE.ACCOUNT.NUMBER = RESERVE.ACCOUNT.LOSS
            END
*
* raise the P & L entry
*
            AMOUNT = NEW.PL
            LCY.AMOUNT = ''
            EXCH.RATE = ''
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
*
            NARRATIVE = SAVE.NARR<3>
            GOSUB RAISE.CATEG.ENTRY
*
* raise new reserve account entry
*
            NARRATIVE = SAVE.NARR<4>
            GOSUB RAISE.CCY.RESERVE.ENTRY
*
        END         ;* if NEW.PL
    END   ;* if NOT(REVERSAL)
*
    NARRATIVE = SAVE.NARR
*
    LEG.CCY = SAVE.LEG.CCY
*
*
    RETURN
*
******************
RL.CURRENCY.REVAL:
******************
*
* Create two entries. One to the reserve account, the other to the P&L account.
*
    FCY.AMOUNT = ''
    EXCH.RATE = ''
    SAVE.NARR = NARRATIVE
*
* First the current principal
*
    IF LEG.TYPE = 'A' THEN
        LCY.AMOUNT = OUTS.PRIN.LCY
        PL.AMT = R$SW.ASSET.BALANCES<SW.BAL.CCY.REVAL.PL>
    END ELSE
        LCY.AMOUNT = 0 - OUTS.PRIN.LCY
        PL.AMT = 0 - R$SW.LIABILITY.BALANCES<SW.BAL.CCY.REVAL.PL>
    END
    NARRATIVE = SAVE.NARR<2>
    IF LCY.AMOUNT THEN
        GOSUB RAISE.RESERVE.ENTRY
    END
*
* Then the P & L amount.
*
    PL.CATEGORY = CCY.REVAL.PL.CATEG
    LCY.AMOUNT = PL.AMT
    IF LCY.AMOUNT < 0 THEN
        TRANSACTION.CODE = RESERVE.DR.CODE
    END ELSE
        TRANSACTION.CODE = RESERVE.CR.CODE
    END
    NARRATIVE = SAVE.NARR<1>
    IF LCY.AMOUNT THEN
*
*
* Convert lcy.amount to leg.ccy if foreign
        IF LEG.CCY NE LCCY THEN
            CCY1 = LEG.CCY
            AMT1 = ''
            CCY2 = LCCY
            AMT2 = LCY.AMOUNT
            XRATE = EXCH.RATE
*
            GOSUB CALC.EXCHRATE
            FCY.AMOUNT = AMT1
            EXCH.RATE = XRATE
        END
*
*
        GOSUB RAISE.CATEG.ENTRY
    END
*
    NARRATIVE = SAVE.NARR
*
    RETURN
*
**************************
PX.PRINCIPAL.EXCHANGE.FWD:
**************************
*
***********************************************************
*  Asset sched     : Credit Client Acct                   *
*  Liability sched : Debit  Client Acct                   *
***********************************************************
*
    ACCOUNT.TYPE = "PRINCIPAL"
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
* !!! raise FX entries for flexible swap
*
    IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
        CRF.TYPE = "FXFWD"
        IF LEG.TYPE = "A" THEN
            CRF.TYPE := "SELL"
        END ELSE
            CRF.TYPE := "BUY"
        END
        GOSUB DETERMINE.FX.ENTRY
        TXN.CODE = SW.TC.NEW.CONTRACT
        MAT.DATE = VALUE.DATE
        GOSUB RAISE.CRF.ENTRY
*
*  If flexible swap, updates CCY.POS
        GOSUB UPDATE.CCY.POS
    END
*
    RETURN
*
***************************
PX.PRINCIPAL.EXCHANGE.LIVE:
***************************
*
***********************************************************
*  Asset sched     : Credit Client Acct - Debit LIVEDB    *
*  Liability sched : Credit LIVECR - Debit Client Acct    *
***********************************************************
*
* Work out the correct exch.rate and/or lcy.amount
*
    BEGIN CASE
**
* use the original lcy.amount on reversal
*
    CASE REVERSAL
        NULL
**
* exch.rate must be between this principal and the other leg's principal
*
    CASE R$SWAP<SW.BALANCE.SHEET> = 'OFF' AND OTHER.LEG.CCY = LCCY
        EXCH.RATE = ""
        LCY.AMOUNT = OTHER.ORIGINAL.PRINCIPAL
        GOSUB DETERMINE.CCY.AMOUNTS     ;* get exch.rate
**
* if OFF balance sheet then lcy.equiv must be based on the base currency
*
    CASE R$SWAP<SW.BALANCE.SHEET> = 'OFF' AND LEG.CCY <> BASE.CURRENCY
        LCY.AMOUNT = OTHER.OUTS.PRIN.LCY          ;* other leg must be base
        IF NOT(LCY.AMOUNT) THEN
            SAVE.AMOUNT = AMOUNT
            SAVE.LEG.CCY = LEG.CCY
            AMOUNT = OTHER.ORIGINAL.PRINCIPAL
            LEG.CCY = BASE.CURRENCY
            EXCH.RATE = ""
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
            LCY.AMOUNT = ABS(LCY.AMOUNT)
            AMOUNT = SAVE.AMOUNT
            LEG.CCY = SAVE.LEG.CCY
        END
*
        EXCH.RATE = ""
        GOSUB DETERMINE.CCY.AMOUNTS     ;* exch.rate based on correct lcy.amount
    END CASE
*
* raise client account entry
*
    ACCOUNT.TYPE = "PRINCIPAL"
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
* For raising reveral of forward CRF entry
*
    IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
        IF R$SWAP<SW.VALUE.DATE> < TODAY THEN
            CRF.TYPE = "FXFWD"
            IF LEG.TYPE = "A" THEN
                CRF.TYPE := "SELL"
            END ELSE
                CRF.TYPE := "BUY"
            END
            GOSUB DETERMINE.FX.ENTRY
            TXN.CODE = SW.TC.NEW.CONTRACT
            MAT.DATE = VALUE.DATE
            GOSUB REVERSE.AMOUNTS
            GOSUB RAISE.CRF.ENTRY
        END
    END
*
* GB9601059 Only raise the CRF entries if the swap is ON balance sheet
*
    IF R$SWAP<SW.BALANCE.SHEET> = 'ON' THEN
        GOSUB PRINCIPAL.EXCHANGE.LIVE.CRF
    END ELSE        ;* off balance sheet
        IF NOT(REVERSAL) THEN
            OUTS.PRIN.LCY = ABS(LCY.AMOUNT)
            IF R$SWAP<SW.FLEX.PRIN.PAYMENT> <> 'YES' THEN
                GOSUB RAISE.RESERVE.ENTRY
            END
            GOSUB UPDATE.OUTS.PRIN.LCY
        END
*
* populate initial xrate
*
        IF LEG.TYPE = 'A' THEN
            R$SW.ASSET.BALANCES<SW.BAL.INITIAL.XRATE> = EXCH.RATE
        END ELSE
            R$SW.LIABILITY.BALANCES<SW.BAL.INITIAL.XRATE> = EXCH.RATE
        END
    END
*
    RETURN
*
****************************
PRINCIPAL.EXCHANGE.LIVE.CRF:
****************************
*
*  Raise live PX CRF entry
*
    CRF.TYPE = "LIVE"
    GOSUB DETERMINE.CRF.ENTRY.DETAIL
    TXN.CODE = SW.TC.PRIN.AMT.LIVE
*
    GOSUB REVERSE.AMOUNTS     ;* reverse signs of lcy.amount & fcy.amount
    GOSUB RAISE.CRF.ENTRY
*
    RETURN
*
*****************************
RX.PRINCIPAL.REEXCHANGE.LIVE:
*****************************
*
***********************************************************
*  Asset sched     : Credit LIVEDB - Debit Client Acct    *
*  Liability sched : Credit Client Acct - Debit LIVECR    *
***********************************************************
*
    IF R$SWAP<SW.BALANCE.SHEET> = 'ON' THEN
        ACCOUNT.TYPE = "PRINCIPAL"
        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
*  Raise CRF entry
*
        CRF.TYPE = "LIVE"
        GOSUB DETERMINE.CRF.ENTRY.DETAIL
        TXN.CODE = SW.TC.MAT.CONTRACT
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
        GOSUB RAISE.CRF.ENTRY
    END ELSE
* Lcy amount based on current lcy amount - ccy reval pl
        IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
* Get lcy amount from outstanding principal in swap balance
            GOSUB DETERMINE.FX.ENTRY
        END ELSE
            LCY.AMOUNT = OUTS.PRIN.LCY - CCY.REVAL.PL
            IF LEG.TYPE = 'A' THEN LCY.AMOUNT = 0 - LCY.AMOUNT
        END
        ACCOUNT.TYPE = "PRINCIPAL"
        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY

* To generate live entries for CIRS off balance contracts
        TXN.CODE = SW.TC.MAT.CONTRACT
        CRF.TYPE = 'SWOFFBAL'
        GOSUB DETERMINE.CRF.ENTRY.DETAIL
        GOSUB REVERSE.AMOUNTS
        GOSUB RAISE.CRF.ENTRY
        IF NOT(REVERSAL) THEN
            GOSUB REVERSE.AMOUNTS
            IF R$SWAP<SW.FLEX.PRIN.PAYMENT> <> 'YES' THEN
                OUTS.PRIN.LCY -= ABS(LCY.AMOUNT)
                GOSUB RAISE.RESERVE.ENTRY
            END ELSE
                OUTS.PRIN.LCY = 0
            END
            GOSUB UPDATE.OUTS.PRIN.LCY
        END
    END
*
    RETURN
*
****************************
RX.PRINCIPAL.REEXCHANGE.FWD:
****************************
*
***********************************************************
*  Asset sched     :  Debit Client Acct.                  *
*  Liability sched :  Credit Client Acct.                 *
***********************************************************
*
* EN_10001602
* !!! raise FX entries for flexible swap
*
    IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
        ACCOUNT.TYPE = "PRINCIPAL"
        CRF.TYPE = "FXFWD"
        IF LEG.TYPE = "L" THEN
            CRF.TYPE := "SELL"
        END ELSE
            CRF.TYPE := "BUY"
        END
        GOSUB DETERMINE.CCY.AMOUNTS

        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
        TXN.CODE = SW.TC.MAT.CONTRACT
        MAT.DATE = VALUE.DATE
        GOSUB RAISE.CRF.ENTRY
        GOSUB UPDATE.CCY.POS
    END ELSE
* Removed code reletaed to projection of RX forward entries
        ACCOUNT.TYPE = "PRINCIPAL"
        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
        IF R$SWAP<SW.BALANCE.SHEET> = 'OFF' THEN
            GOSUB UPDATE.CCY.POS
        END
    END
*
    RETURN
*
**************************
PI.PRINCIPAL.INCREASE.FWD:
**************************
*
***********************************************************
*  Asset sched     : Credit Client Acct                   *
*  Liability sched : Debit  Client Acct                   *
***********************************************************
*
    IF NOT(NOTIONAL) THEN
        IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
            IF LEG.TYPE = "A" THEN
                SCHED.TYPE = SW.LB.TYPE
                SCHED.DATE = SW.LB.DATE.FREQ
                SCHED.AMOUNT = SW.LB.AMOUNT
            END ELSE
                SCHED.TYPE = SW.AS.TYPE
                SCHED.DATE = SW.AS.DATE.FREQ
                SCHED.AMOUNT = SW.AS.AMOUNT
            END

            FOUND = 0
            OTHER.AMOUNT = 0
            SAVE.VALUE.DATE = VALUE.DATE
            VALUE.DATE = ORIG.VALUE.DATE
            FOR I = 1 TO DCOUNT(R$SWAP<SCHED.TYPE>,VM)
                IF "PI":VALUE.DATE = R$SWAP<SCHED.TYPE,I>:R$SWAP<SCHED.DATE,I>[1,8] THEN
                    OTHER.AMOUNT = R$SWAP<SCHED.AMOUNT,I>
                    FOUND = 1
                    EXIT
                END
            NEXT I
            VALUE.DATE = SAVE.VALUE.DATE
* New accounting rules for flexible swap
*--- Save amount for updating ccy position.
            ORIG.AMOUNT = AMOUNT
            IF NOT(FOUND) THEN
*--- Treatment of one sided PI
*--- A) Book to another leg
                SAVE.LEG.TYPE = LEG.TYPE
                SAVE.LEG.CCY = LEG.CCY
*--- 1. Update POSITION and book CRF.ENTRY
                FCY.AMOUNT = ''
                LCY.AMOUNT = ''
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = 'FWDNOTLDB'
                    AMOUNT = AMOUNT * (-1)
                END ELSE
                    CRF.TYPE = 'FWDNOTLCR'
                END
                TXN.CODE = SW.TC.PRIN.INCR.FWD
                MAT.DATE = VALUE.DATE
                GOSUB GET.AMOUNTS
                GOSUB RAISE.CRF.ENTRY
*
                IF LEG.TYPE = "A" THEN LEG.TYPE = "L" ELSE LEG.TYPE = "A"
                LEG.CCY = OTHER.LEG.CCY
*
* For adjusting the outstanding principal if any schedules falls on the same value date
*
                GOSUB FIND.CURR.SCHED.AMOUNT
*
*--- 2. Book new FX entry
                IF LEG.TYPE = "L" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                IF OTHER.LEG.PRINCIPAL <> '' THEN
                    AMOUNT = OTHER.LEG.PRINCIPAL
                END ELSE
                    AMOUNT = ORIG.OTHER.LEG.PRINCIPAL
                END
                FCY.AMOUNT = AMOUNT
                LCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                TXN.CODE = SW.TC.PRIN.INCR.FWD
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB REVERSE.AMOUNTS
                GOSUB RAISE.CRF.ENTRY
*--- 3. Reverse FX entry
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = ABS(AMOUNT)
                FCY.AMOUNT = AMOUNT
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                TXN.CODE = SW.TC.PRIN.INCR.FWD
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB RAISE.CRF.ENTRY
*
                LEG.CCY = SAVE.LEG.CCY
                LEG.TYPE = SAVE.LEG.TYPE

*--- B) Book its own leg
*--- 1. Update ccy position and STMT.ENTRY
                FCY.AMOUNT = ""
                LCY.AMOUNT = ""
                EXCH.RATE = ""
                AMOUNT = ORIG.AMOUNT
                GOSUB DETERMINE.CCY.AMOUNTS
                ACCOUNT.TYPE = "PRINCIPAL"
                GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
                GOSUB UPDATE.CCY.POS

*--- 2. Reverse FX entry
                IF LEG.TYPE = "L" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY - AMOUNT
                LCY.AMOUNT = ""
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.FX.ENTRY
                OTHER.LCY.AMOUNT = LCY.AMOUNT
                TXN.CODE = SW.TC.PRIN.INCR.FWD
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB REVERSE.AMOUNTS
                GOSUB RAISE.CRF.ENTRY

*--- 3. Book new FX entry
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY
                LCY.AMOUNT = ""
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.FX.ENTRY
                GOSUB RAISE.CRF.ENTRY

            END ELSE          ;* Found PI on another side

*--- Treatment of two sided PI
*--- A) Book to its own leg only
*    must check whether this leg is base ccy or not , if not base ccy
*    need to get the lcy amount from another leg

                LCY.AMOUNT1 = ""
                LCY.AMOUNT2 = ""
                LCY.AMOUNT3 = ""
                IF LEG.CCY <> BASE.CURRENCY THEN
*--- Prepare lcy amount
                    SAVE.LEG.CCY = LEG.CCY
                    LEG.CCY = BASE.CURRENCY
                    AMOUNT = OTHER.LEG.PRINCIPAL - OTHER.AMOUNT
                    LCY.AMOUNT = ""
                    FCY.AMOUNT = ""
                    EXCH.RATE = ""
                    GOSUB DETERMINE.CCY.AMOUNTS
                    LCY.AMOUNT1 = LCY.AMOUNT
                    AMOUNT = OTHER.LEG.PRINCIPAL
                    LCY.AMOUNT = ""
                    FCY.AMOUNT = ""
                    EXCH.RATE = ""
                    GOSUB DETERMINE.CCY.AMOUNTS
                    LCY.AMOUNT2 = LCY.AMOUNT
                    AMOUNT = OTHER.AMOUNT
                    LCY.AMOUNT = ""
                    FCY.AMOUNT = ""
                    EXCH.RATE = ""
                    GOSUB DETERMINE.CCY.AMOUNTS
                    LCY.AMOUNT3 = -LCY.AMOUNT
                    LEG.CCY = SAVE.LEG.CCY
                END

*--- 1. Reverse FX entry
                IF LEG.TYPE = "L" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY - ORIG.AMOUNT
                LCY.AMOUNT = LCY.AMOUNT1
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                TXN.CODE = SW.TC.PRIN.INCR.FWD
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB REVERSE.AMOUNTS
                GOSUB RAISE.CRF.ENTRY

*--- 2. Book new FX entry
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY
                LCY.AMOUNT = LCY.AMOUNT2
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                GOSUB RAISE.CRF.ENTRY

*--- 3. Update ccy position
                AMOUNT = ORIG.AMOUNT
                FCY.AMOUNT = ""
                LCY.AMOUNT = LCY.AMOUNT3
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                ACCOUNT.TYPE = "PRINCIPAL"
                GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
                GOSUB UPDATE.CCY.POS
*
            END     ;* end if not found
        END ELSE
* Removed code reletaed to projection of PI forward entries
            ACCOUNT.TYPE = "PRINCIPAL"
            GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
            IF R$SWAP<SW.BALANCE.SHEET> = 'OFF' THEN
                GOSUB UPDATE.CCY.POS
            END
        END
    END

    RETURN
*
*
***************************
PI.PRINCIPAL.INCREASE.LIVE:
***************************
*
***********************************************************
*  Asset sched     : Credit Client Acct                   *
*                    Debit  LIVEDB/NOTIONALDB             *
*  Liability sched : Credit LIVECR/NOTIONALCR             *
*                    Debit  Client Acct                   *
***********************************************************
*
    IF R$SWAP<SW.BALANCE.SHEET> = 'ON' THEN
        IF NOT(NOTIONAL) THEN
            ACCOUNT.TYPE = "PRINCIPAL"
            GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
        END
*
*  Raise CRF entry
*
        IF NOTIONAL THEN
            CRF.TYPE = "NOTIONAL"
        END ELSE
            CRF.TYPE = "LIVE"
        END
*
        GOSUB DETERMINE.CRF.ENTRY.DETAIL
        TXN.CODE = SW.TC.PRIN.INCR.LIVE
*
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
        GOSUB RAISE.CRF.ENTRY
*
    END ELSE
        IF NOT(NOTIONAL) THEN
            IF NOT(REVERSAL) THEN
                LCY.AMOUNT = ""
            END
            EXCH.RATE = INITIAL.XRATE
            IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN EXCH.RATE = ''
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
            ACCOUNT.TYPE = "PRINCIPAL"
            GOSUB RAISE.CLIENT.ACCOUNT.ENTRY

* To generate PI live entries for CIRS off balance contracts
            TXN.CODE = SW.TC.PRIN.INCR
            CRF.TYPE = 'SWOFFBAL'
            GOSUB DETERMINE.CRF.ENTRY.DETAIL
            GOSUB REVERSE.AMOUNTS
            GOSUB RAISE.CRF.ENTRY
*
            IF NOT(REVERSAL) THEN
                GOSUB REVERSE.AMOUNTS
                OUTS.PRIN.LCY += ABS(LCY.AMOUNT)
*
                IF R$SWAP<SW.FLEX.PRIN.PAYMENT> <> 'YES' THEN
                    GOSUB RAISE.RESERVE.ENTRY
                END
                IF ORIG.NOTIONAL EQ 'Y' THEN
                    TXN.CODE = SW.TC.PRIN.INCR.LIVE
                    GOSUB CI.CONTRACT.INITIATION.LIVE
                END
                GOSUB UPDATE.OUTS.PRIN.LCY
            END
        END ELSE

* To populate the Transaction code for IRS off balance contracts
            TXN.CODE = SW.TC.PRIN.INCR
            CRF.TYPE = 'NOTIONAL'
            GOSUB REVERSE.AMOUNTS
            GOSUB DETERMINE.CRF.ENTRY.DETAIL
            GOSUB RAISE.CRF.ENTRY
        END
*
        IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
            CRF.TYPE = "NOTIONAL"
            GOSUB DETERMINE.CRF.ENTRY.DETAIL
            TXN.CODE = SW.TC.PRIN.INCR.LIVE
            GOSUB REVERSE.AMOUNTS       ;* reverse signs of lcy.amount & fcy.amount
            GOSUB RAISE.CRF.ENTRY
*
*  New internal account booking
*--- Treatment of Live PI on its own leg
*--- Raise 3 internal account
*--- Asset
*--- DB outstanding principal - schedule amount
*--- CR outstanding amount
*--- DB schedule amount
*--- Liability
*--- CR outstanding principal - schedule amount
*--- DB outstanding amount
*--- CR schedule amount
            LCY.AMOUNT = ''
            IF LEG.TYPE = 'A' THEN
                FCY.AMOUNT = OUTS.PRIN.FCY - AMOUNT
            END ELSE
                FCY.AMOUNT = -(OUTS.PRIN.FCY - AMOUNT)
            END
            IF FCY.AMOUNT <> 0 THEN GOSUB RAISE.FLEX.RESERVE.ENTRY
*
            FCY.AMT1 = FCY.AMOUNT
            LCY.AMT1 = LCY.AMOUNT
            IF LEG.TYPE = 'A' THEN
                FCY.AMOUNT = -OUTS.PRIN.FCY
            END ELSE
                FCY.AMOUNT = OUTS.PRIN.FCY
            END
            EXCH.RATE = ''
            IF FCY.AMOUNT <> 0 THEN GOSUB RAISE.FLEX.RESERVE.ENTRY
*
            FCY.AMT2 = FCY.AMOUNT
            LCY.AMT2 = LCY.AMOUNT
            IF LEG.TYPE = 'A' THEN
                FCY.AMOUNT = AMOUNT
            END ELSE
                FCY.AMOUNT = -AMOUNT
            END
            LCY.AMOUNT = ''
            EXCH.RATE = ''
            IF FCY.AMOUNT <> 0 THEN GOSUB RAISE.FLEX.RESERVE.ENTRY
*
*
            IF LEG.TYPE = "A" THEN
                SCHED.TYPE = SW.LB.TYPE
                SCHED.DATE = SW.LB.DATE.FREQ
            END ELSE
                SCHED.TYPE = SW.AS.TYPE
                SCHED.DATE = SW.AS.DATE.FREQ
            END
*
            FOUND = 0
            SAVE.VALUE.DATE = VALUE.DATE
            VALUE.DATE = ORIG.VALUE.DATE
            FOR I = 1 TO DCOUNT(R$SWAP<SCHED.TYPE>,VM)
                IF "PI":VALUE.DATE = R$SWAP<SCHED.TYPE,I>:R$SWAP<SCHED.DATE,I>[1,8] THEN
                    FOUND = 1
                    EXIT
                END
            NEXT I
            VALUE.DATE = SAVE.VALUE.DATE
            IF NOT(FOUND) THEN
*--- Treatment of one sided PI on another leg
*--- 1. Update POSITION and book STMT.ENTRY
                AMOUNT = SAVE.AMOUNT
                GOSUB UPDATE.OUTS.PRIN.LCY
            END
        END
    END
*
    RETURN
*----------------------------------------------------------
* New paragraph for handle NI,ND schedule
***************************
NI.PRINCIPAL.INCREASE.LIVE:
***************************
*
***********************************************************
*  Asset sched     : Debit  FORWARDDB                     *
*  Liability sched : Credit FORWARDCR                     *
***********************************************************
*
*  Raise CRF entry
*
    CRF.TYPE = "NOTIONAL"
*
    GOSUB DETERMINE.CRF.ENTRY.DETAIL
*
    TXN.CODE = SW.TC.PRIN.INCR.LIVE
*
    GOSUB REVERSE.AMOUNTS     ;* reverse signs of lcy.amount & fcy.amount
    GOSUB RAISE.CRF.ENTRY
*
* Update OUTS.PRIN.LCY if there is PX
*
    IF NOT(REVERSAL) THEN
        IF 'PX' MATCH R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE> OR 'PX' MATCH R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE> THEN
            LCY.AMOUNT = ""
            EXCH.RATE = INITIAL.XRATE
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
            OUTS.PRIN.LCY += ABS(LCY.AMOUNT)
            GOSUB UPDATE.OUTS.PRIN.LCY
        END
    END
*
    RETURN
***************************
ND.PRINCIPAL.DECREASE.LIVE:
***************************
*
****************************************************
*  Asset sched     : Credit FORWARDDB              *
*  Liability sched : Debit  FORWARDCR              *
****************************************************
*
*  Raise PD CRF entry
*
    CRF.TYPE = "NOTIONAL"
*
*  Determine details to construct a crf entry
*
    MAT.DATE = CRF.MATURITY.DATE        ;* default to crf.maturity.date
*
    GOSUB DETERMINE.CRF.ENTRY.DETAIL
*
    TXN.CODE = SW.TC.PRIN.INCR.LIVE
*
    GOSUB REVERSE.AMOUNTS     ;* reverse signs of lcy.amount & fcy.amount
    GOSUB RAISE.CRF.ENTRY
*
*
*
    IF NOT(REVERSAL) THEN
        IF 'PX' MATCH R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE> OR 'PX' MATCH R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE> THEN
            LCY.AMOUNT = ""
            EXCH.RATE = INITIAL.XRATE
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
            OUTS.PRIN.LCY -= ABS(LCY.AMOUNT)
            GOSUB UPDATE.OUTS.PRIN.LCY
        END
    END
*
*
*
    RETURN
*
**************************
PD.PRINCIPAL.DECREASE.FWD:
**************************
*
***********************************************************
*  Asset sched     : Debit  Client Acct                   *
*  Liability sched : Credit Client Acct                   *
***********************************************************
*
    IF NOT(NOTIONAL) THEN
        IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
*
* try to find PD schedule in another side and book to client account / position
* with fcy = 0 and lcy = +lcy
*
            IF LEG.TYPE = "A" THEN
                SCHED.TYPE = SW.LB.TYPE
                SCHED.DATE = SW.LB.DATE.FREQ
                SCHED.AMOUNT = SW.LB.AMOUNT
            END ELSE
                SCHED.TYPE = SW.AS.TYPE
                SCHED.DATE = SW.AS.DATE.FREQ
                SCHED.AMOUNT = SW.AS.AMOUNT
            END

            FOUND = 0
            OTHER.AMOUNT = 0
            SAVE.VALUE.DATE = VALUE.DATE
            VALUE.DATE = ORIG.VALUE.DATE
            FOR I = 1 TO DCOUNT(R$SWAP<SCHED.TYPE>,VM)
                IF "PD":VALUE.DATE = R$SWAP<SCHED.TYPE,I>:R$SWAP<SCHED.DATE,I>[1,8] THEN
*--- Calculate other amount
                    OTHER.AMOUNT = R$SWAP<SCHED.AMOUNT,I>
                    FOUND = 1
                    EXIT
                END
            NEXT I
            VALUE.DATE = SAVE.VALUE.DATE
*
*--- Save amount for updating ccy position.
*--- Treatment of one sided PD
*--- A) Book to another leg
            ORIG.AMOUNT = AMOUNT
            IF NOT(FOUND) THEN
                SAVE.LEG.TYPE = LEG.TYPE
                SAVE.LEG.CCY = LEG.CCY
*--- 1. Update POSITION and book CRF.ENTRY for another leg
                FCY.AMOUNT = ''
                LCY.AMOUNT = ''
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = 'FWDNOTLDB'
                END ELSE
                    CRF.TYPE = 'FWDNOTLCR'
                    AMOUNT = AMOUNT * (-1)
                END
                TXN.CODE = SW.TC.PRIN.DECR
                MAT.DATE = VALUE.DATE
                GOSUB GET.AMOUNTS
                GOSUB RAISE.CRF.ENTRY
                GOSUB UPDATE.CCY.POS
                IF LEG.TYPE = "A" THEN LEG.TYPE = "L" ELSE LEG.TYPE = "A"
                LEG.CCY = OTHER.LEG.CCY
* For adjusting the outstanding principal if any schedules falls on the same value date
                GOSUB FIND.CURR.SCHED.AMOUNT
*--- 2. Book new FX entry
                IF LEG.TYPE = "L" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                IF OTHER.LEG.PRINCIPAL <> '' THEN
                    AMOUNT = OTHER.LEG.PRINCIPAL
                END ELSE
                    AMOUNT = ORIG.OTHER.LEG.PRINCIPAL
                END
                FCY.AMOUNT = AMOUNT
                LCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                TXN.CODE = SW.TC.PRIN.DECR
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB RAISE.CRF.ENTRY

*--- 3. Reverse FX entry
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = ABS(AMOUNT)
                FCY.AMOUNT = AMOUNT
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                GOSUB REVERSE.AMOUNTS
                TXN.CODE = SW.TC.PRIN.DECR
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB RAISE.CRF.ENTRY
                LEG.TYPE = SAVE.LEG.TYPE
                LEG.CCY = SAVE.LEG.CCY
                GOSUB UPDATE.CCY.POS
*--- B) Book its own leg
*--- 1. Update ccy position
                FCY.AMOUNT = ""
                LCY.AMOUNT = ""
                EXCH.RATE = ""
                AMOUNT = ORIG.AMOUNT
                GOSUB DETERMINE.CCY.AMOUNTS
                ACCOUNT.TYPE = "PRINCIPAL"
                GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
                GOSUB UPDATE.CCY.POS

*--- 2. Reverse FX entry
                IF LEG.TYPE = "L" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY + AMOUNT
                LCY.AMOUNT = ""
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.FX.ENTRY
                OTHER.LCY.AMOUNT = ABS(LCY.AMOUNT)
                TXN.CODE = SW.TC.PRIN.DECR
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB RAISE.CRF.ENTRY

*--- 3. Book new FX entry
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY
                LCY.AMOUNT = ""
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.FX.ENTRY
                GOSUB REVERSE.AMOUNTS
                GOSUB RAISE.CRF.ENTRY

            END ELSE          ;* Found PD on another side

*--- Treatment of two sided PD
*--- A) Book to its own leg only
*    must check whether this leg is base ccy or not , if not base ccy
*    need to get the lcy amount from another leg

                LCY.AMOUNT1 = ""
                LCY.AMOUNT2 = ""
                LCY.AMOUNT3 = ""
                IF LEG.CCY <> BASE.CURRENCY THEN
*--- Prepare lcy amount
                    SAVE.LEG.CCY = LEG.CCY
                    LEG.CCY = BASE.CURRENCY
                    AMOUNT = OTHER.LEG.PRINCIPAL + OTHER.AMOUNT
                    LCY.AMOUNT = ""
                    FCY.AMOUNT = ""
                    EXCH.RATE = ""
                    GOSUB DETERMINE.CCY.AMOUNTS
                    LCY.AMOUNT1 = LCY.AMOUNT
                    AMOUNT = OTHER.LEG.PRINCIPAL
                    LCY.AMOUNT = ""
                    FCY.AMOUNT = ""
                    EXCH.RATE = ""
                    GOSUB DETERMINE.CCY.AMOUNTS
                    LCY.AMOUNT2 = LCY.AMOUNT
                    AMOUNT = OTHER.AMOUNT
                    LCY.AMOUNT = ""
                    FCY.AMOUNT = ""
                    EXCH.RATE = ""
                    GOSUB DETERMINE.CCY.AMOUNTS
                    LCY.AMOUNT3 = LCY.AMOUNT
                    LEG.CCY = SAVE.LEG.CCY
                END

*--- 1. Reverse FX entry
                IF LEG.TYPE = "L" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY + ORIG.AMOUNT
                LCY.AMOUNT = LCY.AMOUNT1
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                TXN.CODE = SW.TC.PRIN.DECR
                MAT.DATE = VALUE.DATE   ;* override default mat.date
                GOSUB RAISE.CRF.ENTRY

*--- 2. Book new FX entry
                IF LEG.TYPE = "A" THEN
                    CRF.TYPE = "FXFWDSELL"
                END ELSE
                    CRF.TYPE = "FXFWDBUY"
                END
                AMOUNT = OUTS.PRIN.FCY
                LCY.AMOUNT = LCY.AMOUNT2
                FCY.AMOUNT = ""
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                GOSUB REVERSE.AMOUNTS
                GOSUB RAISE.CRF.ENTRY

*--- 3. Update ccy position
                AMOUNT = ORIG.AMOUNT
                FCY.AMOUNT = ""
                LCY.AMOUNT = LCY.AMOUNT3
                EXCH.RATE = ""
                GOSUB DETERMINE.CCY.AMOUNTS
                ACCOUNT.TYPE = "PRINCIPAL"
                GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
                GOSUB UPDATE.CCY.POS
            END     ;* end if not found
        END ELSE
* Removed code reletaed to projection of PD forward entries
            ACCOUNT.TYPE = "PRINCIPAL"
            GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
            IF R$SWAP<SW.BALANCE.SHEET> = 'OFF' THEN
                GOSUB UPDATE.CCY.POS
            END
        END
    END
*
*
    RETURN
*
***************************
PD.PRINCIPAL.DECREASE.LIVE:
***************************
*
***********************************************************
*  Asset sched     : Credit LIVEDB/NOTIONALDB             *
*                    Debit  Client Acct                   *
*  Liability sched : Credit Client Acct                   *
*                    Debit  LIVECR/NOTIONALCR             *
***********************************************************
*
    IF R$SWAP<SW.BALANCE.SHEET> = 'ON' THEN
        IF NOT(NOTIONAL) THEN
            ACCOUNT.TYPE = "PRINCIPAL"
            GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
        END
        GOSUB PRINCIPAL.DECREASE.LIVE.CRF
    END ELSE
        IF NOT(NOTIONAL) THEN
            IF NOT(REVERSAL) THEN
                LCY.AMOUNT = ""
            END
            EXCH.RATE = INITIAL.XRATE
            IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN EXCH.RATE = ''
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
            ACCOUNT.TYPE = "PRINCIPAL"
            GOSUB RAISE.CLIENT.ACCOUNT.ENTRY

* To generate PD live entries for CIRS off balance contracts
            TXN.CODE = SW.TC.PRIN.DECR
            CRF.TYPE = 'SWOFFBAL'
            GOSUB DETERMINE.CRF.ENTRY.DETAIL
            GOSUB REVERSE.AMOUNTS
            GOSUB RAISE.CRF.ENTRY
            IF NOT(REVERSAL) THEN
                GOSUB REVERSE.AMOUNTS
                OUTS.PRIN.LCY -= ABS(LCY.AMOUNT)
                IF R$SWAP<SW.FLEX.PRIN.PAYMENT> <> 'YES' THEN
                    GOSUB RAISE.RESERVE.ENTRY
                END
                IF ORIG.NOTIONAL EQ 'Y' THEN
                    GOSUB CM.CONTRACT.MATURITY
                END
                GOSUB UPDATE.OUTS.PRIN.LCY
            END
        END ELSE
            GOSUB PRINCIPAL.DECREASE.LIVE.CRF
        END
*
        IF R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ 'YES' THEN
            CRF.TYPE = "NOTIONAL"
            GOSUB DETERMINE.CRF.ENTRY.DETAIL
            TXN.CODE = SW.TC.PRIN.INCR.LIVE
            MAT.DATE = VALUE.DATE
            GOSUB REVERSE.AMOUNTS       ;* reverse signs of lcy.amount & fcy.amount
            GOSUB RAISE.CRF.ENTRY

            IF LEG.TYPE = "A" THEN
                SCHED.TYPE = SW.LB.TYPE
                SCHED.DATE = SW.LB.DATE.FREQ
            END ELSE
                SCHED.TYPE = SW.AS.TYPE
                SCHED.DATE = SW.AS.DATE.FREQ
            END
*
*--- Treatment of Live PD on its own leg
*--- Raise 3 internal account
*--- Asset
*--- DB outstanding principal + schedule amount
*--- CR outstanding amount
*--- CR schedule amount
*--- Liability
*--- CR outstanding principal - schedule amount
*--- DB outstanding amount
*--- DB schedule amount
            LCY.AMOUNT = ''
            IF LEG.TYPE = 'A' THEN
                FCY.AMOUNT = OUTS.PRIN.FCY + AMOUNT
            END ELSE
                FCY.AMOUNT = -(OUTS.PRIN.FCY + AMOUNT)
            END
            IF FCY.AMOUNT <> 0 THEN GOSUB RAISE.FLEX.RESERVE.ENTRY
*
            FCY.AMT3 = FCY.AMOUNT
            LCY.AMT3 = LCY.AMOUNT
            IF LEG.TYPE = 'A' THEN
                FCY.AMOUNT = -OUTS.PRIN.FCY
            END ELSE
                FCY.AMOUNT = OUTS.PRIN.FCY
            END
            EXCH.RATE = ''
            IF FCY.AMOUNT <> 0 THEN GOSUB RAISE.FLEX.RESERVE.ENTRY
*
            FCY.AMT4 = FCY.AMOUNT
            LCY.AMT4 = LCY.AMOUNT
            IF LEG.TYPE = 'A' THEN
                FCY.AMOUNT = -AMOUNT
            END ELSE
                FCY.AMOUNT = AMOUNT
            END
            LCY.AMOUNT = ''
            EXCH.RATE = ''
            IF FCY.AMOUNT <> 0 THEN GOSUB RAISE.FLEX.RESERVE.ENTRY
*
            FOUND = 0
            SAVE.VALUE.DATE = VALUE.DATE
            VALUE.DATE = ORIG.VALUE.DATE
            FOR I = 1 TO DCOUNT(R$SWAP<SCHED.TYPE>,VM)
                IF "PD":VALUE.DATE = R$SWAP<SCHED.TYPE,I>:R$SWAP<SCHED.DATE,I>[1,8] THEN
                    FOUND = 1
                    EXIT
                END
            NEXT I
            VALUE.DATE = SAVE.VALUE.DATE
            IF NOT(FOUND) THEN
*
*--- Treatment of one sided PD on another leg
*--- 1. Update POSITION and book STMT.ENTRY
* to reverse forward spec and raise live spec
                AMOUNT = SAVE.AMOUNT
                GOSUB UPDATE.OUTS.PRIN.LCY
            END
        END
    END
*
    RETURN
*
****************************
PRINCIPAL.DECREASE.LIVE.CRF:
****************************
*
*  Raise PD CRF entry
*
    IF NOTIONAL THEN
        CRF.TYPE = "NOTIONAL"
    END ELSE
        CRF.TYPE = "LIVE"
    END
*
    GOSUB DETERMINE.CRF.ENTRY.DETAIL
    TXN.CODE = SW.TC.PRIN.DECR
*
    GOSUB REVERSE.AMOUNTS     ;* reverse signs of lcy.amount & fcy.amount
    GOSUB RAISE.CRF.ENTRY
*
    RETURN
*
*************************
IP.INTEREST.PAYMENT.LIVE:
*************************
*
***********************************************************
*  Asset sched     : Credit Accrual - Debit Client Acct   *
*  Liability sched : Credit Client Acct - Debit Accrual   *
***********************************************************
*
    ACCOUNT.TYPE = "INTEREST"
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
    GOSUB INTEREST.PAYMENT.LIVE.CRF
*
    RETURN
*
**************************
INTEREST.PAYMENT.LIVE.CRF:
**************************
*
*  Raise interest accrual entry
*
* On IP payment date, the category code used for capitalisation should be based on whether it is an income or expense
*
    GOSUB DETERMINE.INCOME.OR.EXPENSE

    IF INCOME.CATEGORY THEN
        CRF.TYPE = R$SWAP.PARAMETER<SW.PARAM.INCOME.CURR.ACCRUAL>
    END ELSE
        CRF.TYPE = R$SWAP.PARAMETER<SW.PARAM.EXPENSE.CURR.ACCRUAL>
    END
*
    GOSUB REVERSE.AMOUNTS     ;* reverse signs of lcy.amount & fcy.amount
*
*  Raise categ.entry rather than crf entry if reversal of Interest Payment
*
    IF REVERSAL THEN
        PL.CATEGORY = CRF.TYPE          ;* only reverse from current month p&l temporarily
        GOSUB RAISE.CATEG.ENTRY
    END ELSE
        TXN.CODE = SW.TC.INTR.ACCRUAL
        MAT.DATE = CRF.INTEREST.DATE
        GOSUB RAISE.CRF.ENTRY
    END
*
    RETURN
*
************************
IP.INTEREST.PAYMENT.FWD:
************************
*
***********************************************************
*  Asset sched     : Debit  Client Acct                   *
*  Liability sched : Credit Client Acct                   *
***********************************************************
*
    ACCOUNT.TYPE = "INTEREST"
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
    RETURN
*
****************
PM.PAYMENT.ACCT:
****************
*
***********************************************************
*  PM schedule    :  Credit Client Acct                   *
*  RV schedule    :  Debit  Client Acct                   *
***********************************************************
*
    IF SCHEDULE.TYPE[1,2] = 'RV' THEN
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
    END
*
    ACCOUNT.TYPE = "PRINCIPAL"
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
    RETURN
*
**************
PM.PAYMENT.PL:
**************
*
***********************************************************
*  PM schedule    :  Debit  P&L                           *
*  RV schedule    :  Credit P&L                           *
***********************************************************
*
    IF SCHEDULE.TYPE[1,2] = 'PM' THEN
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
    END
*
    PL.CATEGORY = R.SWAP.SCHED.TYPE<SW.SCHED.CATEGORY.CODE>
    GOSUB RAISE.CATEG.ENTRY
*
    RETURN
*
********************
IS.ISSUE.PRICE.LIVE:
********************
*
***********************************************************
*  Asset sched     : Credit Client Acct of issue price    *
*                    Debit  LIVEDB of original principal  *
*                    Credit P&L of price difference       *
*  Liability sched : Credit LIVECR of original principal  *
*                    Debit  Client Acct of issue price    *
*                    Debit  P&L of price difference       *
***********************************************************
*
    ACCOUNT.TYPE = 'PRINCIPAL'
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
*  Save lcy.amount and schedule.type
*  before raising entries based on the original principal and price difference
*
    SAVE.LCY.AMOUNT = LCY.AMOUNT
    SAVE.SCHEDULE.TYPE = SCHEDULE.TYPE
*
    PRICE.DIFF = ORIGINAL.PRINCIPAL - AMOUNT
*
    AMOUNT = ORIGINAL.PRINCIPAL
    LCY.AMOUNT = ""
    EXCH.RATE = ""
    GOSUB DETERMINE.CCY.AMOUNTS
    GOSUB PRINCIPAL.EXCHANGE.LIVE.CRF
*
*  Save the original.principal in LCY to avoid rounding error
*  when calculating the price.diff in LCY
*
    SAVE.ORIG.PRINCIPAL.LCY = LCY.AMOUNT
*
    IF PRICE.DIFF THEN
        IF (LEG.TYPE = 'A' AND PRICE.DIFF < 0) OR (LEG.TYPE = 'L' AND PRICE.DIFF > 0) THEN
            SCHEDULE.TYPE = "PM"
        END ELSE
            SCHEDULE.TYPE = "RV"
        END
*
        AMOUNT = ABS(PRICE.DIFF)        ;* unsigned
        LCY.AMOUNT = ""
        EXCH.RATE = ""
        GOSUB DETERMINE.CCY.AMOUNTS
*
*  Work out the price.diff in LCY to avoid rounding error
*
        LCY.AMOUNT = ABS(SAVE.ORIG.PRINCIPAL.LCY) - ABS(SAVE.LCY.AMOUNT)
        LCY.AMOUNT = ABS(LCY.AMOUNT)    ;* unsigned
        GOSUB PM.PAYMENT.PL   ;* requires both amounts unsigned
    END
*
*  Change amount to original principal for charge/commission calculation
*
    AMOUNT = ORIGINAL.PRINCIPAL
*
* restore schedule.type and lcy.amount
*
    LCY.AMOUNT = SAVE.LCY.AMOUNT
    SCHEDULE.TYPE = SAVE.SCHEDULE.TYPE
*
    RETURN
*
***********************
AP.ANNUITY.PAYMENT.FWD:
***********************
*
*********************************************************************
*  Asset sched     : Debit  Client Acct of the repayment amount     *
*  Liability sched : Credit Client Acct of the repayment amount     *
*********************************************************************
*
    ACCOUNT.TYPE = 'PRINCIPAL'
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
* !!! May need to do the ccy position update here
*
    RETURN
*
************************
AP.ANNUITY.PAYMENT.LIVE:
************************
*
**************************************************************
*  Asset sched     : Debit  Client Acct of repayment amount  *
*                    Credit accrual of interest amount       *
*                    Credit LIVEDB of surplus repay amount   *
*  Liability sched : Credit Client Acct of repayment amount  *
*                    Debit  accrual of interest amount       *
*                    Debit  LIVECR of surplus repay amount   *
**************************************************************
*
*  Save lcy.amount and schedule.type
*
    SAVE.LCY.AMOUNT = LCY.AMOUNT
    SAVE.SCHEDULE.TYPE = SCHEDULE.TYPE
*
    REPAY.REMAINDER = AMOUNT - INTEREST.AMOUNT
*
    BEGIN CASE
**
*  need to decrease the principal with the surplus repayment amount
*
    CASE REPAY.REMAINDER > 0
        ACCOUNT.TYPE = 'PRINCIPAL'
        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
*
        AMOUNT = INTEREST.AMOUNT
        LCY.AMOUNT = ""
        EXCH.RATE = ""
        GOSUB DETERMINE.CCY.AMOUNTS
        GOSUB INTEREST.PAYMENT.LIVE.CRF
*
*  Save the interest.amount in LCY to avoid rounding error
*  when calculating repay.remainder in LCY
*
        SAVE.INTEREST.AMOUNT.LCY = LCY.AMOUNT
*
        SCHEDULE.TYPE = "PD"
        AMOUNT = REPAY.REMAINDER
        LCY.AMOUNT = ""
        EXCH.RATE = ""
        GOSUB DETERMINE.CCY.AMOUNTS
*
*  Work out the repay.remainder in LCY to avoid rounding error
*  The sign of lcy.amount must be the same as fcy.amount
*
        LCY.AMOUNT = ABS(SAVE.LCY.AMOUNT) - ABS(SAVE.INTEREST.AMOUNT.LCY)
        SIGN.DIFF = ((LCY.AMOUNT * FCY.AMOUNT) < 0)
        IF SIGN.DIFF THEN
            LCY.AMOUNT = -LCY.AMOUNT
        END
*
        GOSUB PRINCIPAL.DECREASE.LIVE.CRF
**
*  Just like a normal interest payment
*
    CASE REPAY.REMAINDER = 0
        ACCOUNT.TYPE = 'PRINCIPAL'
        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
        GOSUB INTEREST.PAYMENT.LIVE.CRF
**
*  Shouldn't really happen here
*  anyway, make sure it is sufficient to cover the interest
*
    CASE OTHERWISE
        AMOUNT = INTEREST.AMOUNT
        LCY.AMOUNT = ""
        EXCH.RATE = ""
        GOSUB DETERMINE.CCY.AMOUNTS
*
        ACCOUNT.TYPE = 'PRINCIPAL'
        GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
        GOSUB INTEREST.PAYMENT.LIVE.CRF
*
    END CASE
*
*  Restore amount, lcy.amount and schedule.type
*
    AMOUNT = SAVE.AMOUNT
    LCY.AMOUNT = SAVE.LCY.AMOUNT
    SCHEDULE.TYPE = SAVE.SCHEDULE.TYPE
*
    RETURN
*
**********
CC.CHARGE:
**********
*
***********************************************************
*  Asset sched     : Credit P&L - Debit Client Acct       *
*  Liability sched : Credit Client Acct - Debit P&L       *
***********************************************************
*
    RETURN
*
*************************************************************************
*
***************************
RAISE.CLIENT.ACCOUNT.ENTRY:
***************************
*
    GOSUB BUILD.BASE.ENTRY
    GOSUB DETERMINE.CLIENT.ACCOUNT
*
    IF LEG.CCY NE LCCY AND (FCY.AMOUNT = 0 OR FCY.AMOUNT = '') AND LCY.AMOUNT NE 0 THEN
        EXCH.RATE1 = ''
        CALL MIDDLE.RATE.CONV.CHECK(FCY.AMOUNT, LEG.CCY, EXCH.RATE1, "1", LCY.AMOUNT,"","")
        CALL EB.ROUND.AMOUNT(LEG.CCY, FCY.AMOUNT,"","")
        EXCH.RATE = EXCH.RATE1
    END

    ENTRY<AC.STE.ACCOUNT.NUMBER> = ACCOUNT.NUMBER
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT

    IF FCY.AMOUNT NE 0 AND FCY.AMOUNT NE '' THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
    END
*
*
* Extra Info for EB.ACCOUNTING to invoke the PD processing.  Only set for
* all receipt schedules and in-flow charges and commissions on the asset
* side only, eg RX, IP, PD,...
*
    IF LCY.AMOUNT < 0 AND NOT(REVERSAL) AND LEG.TYPE = 'A' THEN
        ENTRY<AC.STE.LIQUIDATION.MODE> = R$SWAP<SW.LIQUIDATION.MODE>
        ENTRY<AC.STE.REPAYMENT.DATE> = VALUE.DATE
*
        REPAY.TYPE = 'PR'
        IF SCHEDULE.TYPE[1,2] = 'IP' THEN
            REPAY.TYPE = 'IN'
        END
*
        ENTRY<AC.STE.REPAYMENT.TYPE> = REPAY.TYPE
        ENTRY<AC.STE.REPAYMENT.AMT> = AMOUNT * (-1)
        ENTRY<AC.STE.OUTSTANDING.BAL> = R$SW.ASSET.BALANCES<SW.BAL.PRINCIPAL,1>
        ENTRY<AC.STE.CONTRACT.INT.RATE> = R$SWAP<SW.AS.CURRENT.RATE>
    END
*
*
*
    GOSUB DETERMINE.ACCOUNT.CATEG       ;* Determine acct categ code.
    GOSUB APPEND.ENTRIES
*
    RETURN
*
****************
RAISE.CRF.ENTRY:
****************
*
    GOSUB BUILD.BASE.ENTRY
*
    IF REVERSAL THEN
        TXN.CODE = SW.TC.REV.CONTRACT
    END
*
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    IF FCY.AMOUNT NE 0 AND FCY.AMOUNT NE '' THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
    END
    ENTRY<AC.STE.CRF.TYPE> = CRF.TYPE
    ENTRY<AC.STE.CRF.TXN.CODE> = TXN.CODE
    ENTRY<AC.STE.CRF.MAT.DATE> = MAT.DATE
*
    GOSUB APPEND.ENTRIES
*
    RETURN
*
******************
RAISE.CATEG.ENTRY:
******************
*
*  Only live categ.entry
*
    GOSUB BUILD.BASE.ENTRY
*
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    ENTRY<AC.STE.PL.CATEGORY> = PL.CATEGORY
    IF FCY.AMOUNT NE 0 AND FCY.AMOUNT NE '' THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
    END
*
    GOSUB APPEND.LIVE.ENTRIES
*
    RETURN
*
********************
RAISE.RESERVE.ENTRY:
********************
*
    LCY.AMOUNT = -LCY.AMOUNT
    IF LCY.AMOUNT < 0 THEN
        TRANSACTION.CODE = RESERVE.DR.CODE
    END ELSE
        TRANSACTION.CODE = RESERVE.CR.CODE
    END
*
    GOSUB BUILD.BASE.ENTRY
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = RESERVE.ACCOUNT.NUMBER
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    ENTRY<AC.STE.AMOUNT.FCY> = ''
    ENTRY<AC.STE.EXCHANGE.RATE> = ''
    ENTRY<AC.STE.CURRENCY> = LCCY
*
    GOSUB APPEND.ENTRIES
*
    RETURN
*
*
********************
RAISE.FLEX.RESERVE.ENTRY:
********************
*
    FCY.AMOUNT = -FCY.AMOUNT
    IF LCY.AMOUNT NE '' THEN
        LCY.AMOUNT = LCY.AMOUNT * (-1)
    END
    IF FCY.AMOUNT < 0 THEN
        TRANSACTION.CODE = RESERVE.DR.CODE
    END ELSE
        TRANSACTION.CODE = RESERVE.CR.CODE
    END
*
    GOSUB BUILD.BASE.ENTRY
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = LEG.CCY:ACCOUNT.CAT:REVAL.DEPT
    IF LEG.CCY = LCCY THEN
        LCY.AMOUNT = FCY.AMOUNT
        ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
        FCY.AMOUNT = ''
    END ELSE
        CALL MIDDLE.RATE.CONV.CHECK(FCY.AMOUNT,LEG.CCY,EXCH.RATE,"1",LCY.AMOUNT,"","")
        CALL EB.ROUND.AMOUNT(LCCY,LCY.AMOUNT,"","")
        ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    END

    IF FCY.AMOUNT NE 0 AND FCY.AMOUNT NE '' THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
    END
    ENTRY<AC.STE.CURRENCY> = LEG.CCY
    GOSUB APPEND.ENTRIES
*
    RETURN
*
***********************************************************************
RAISE.CCY.RESERVE.ENTRY:
************************
*
    GOSUB REVERSE.AMOUNTS
*
    IF LCY.AMOUNT < 0 THEN
        TRANSACTION.CODE = RESERVE.DR.CODE
    END ELSE
        TRANSACTION.CODE = RESERVE.CR.CODE
    END
*
    GOSUB BUILD.BASE.ENTRY
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = RESERVE.ACCOUNT.NUMBER
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    IF FCY.AMOUNT NE 0 AND FCY.AMOUNT NE '' THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
    END
*
    GOSUB APPEND.ENTRIES
*
    RETURN
*
*************************************************************************
*
*********************
UPDATE.OUTS.PRIN.LCY:
*********************
*
* update outstanding principal lcy
*
    IF LEG.TYPE = 'A' THEN
        R$SW.ASSET.BALANCES<SW.BAL.OUTS.PRIN.LCY> = OUTS.PRIN.LCY
    END ELSE
        R$SW.LIABILITY.BALANCES<SW.BAL.OUTS.PRIN.LCY> = OUTS.PRIN.LCY
    END
*
    RETURN
*
*************************************************************************
*
***************
PROCESS.CHARGE:
***************
*
*  Set up T.DATA
*
    T.DATA = ''
    VMC = DCOUNT(CHARGE.CODE, VM)
    FOR YI = 1 TO VMC
        IF CHARGE.CODE<1, YI> THEN
            T.DATA<1, -1> = CHARGE.CODE<1, YI>
        END
    NEXT YI
*
*  Only pass charge and commission codes to calculate.charge
*
    IF T.DATA THEN
        GOSUB CALL.CALC.CHARGE
*
*  Will return charge, commission and tax details
*
        VMC = DCOUNT(T.DATA<1>, VM)
        FOR YI = 1 TO VMC
*
            POST.CODE = T.DATA<3, YI>   ;* account no. or p&l category
            LCY.AMOUNT = T.DATA<4, YI>
            FCY.AMOUNT = T.DATA<5, YI>
            EXCH.RATE = T.DATA<6, YI>
            CREDIT.TXN.CODE = T.DATA<7, YI>
            DEBIT.TXN.CODE = T.DATA<8, YI>
            NARRATIVE = T.DATA<12, YI>  ;* tax details for bank side only
*
*  Charge is +ve and fee is -ve
*
            IF CHARGE.OR.FEE = 'F' THEN
                GOSUB REVERSE.AMOUNTS   ;* reverse signs of lcy.amount & fcy.amount
            END
*
*  Update charge.details which might include tax details
*
            CHARGE.DETAILS<1, -1> = T.DATA<1, YI>
            CHARGE.DETAILS<2, -1> = LCY.AMOUNT
            CHARGE.DETAILS<3, -1> = FCY.AMOUNT
*
            GOSUB RESET.AMOUNTS         ;* lcy.amount and fcy.amount should be unsigned
*
            IF FORWARD.ENTRY THEN
                GOSUB RAISE.CHARGE.ACCT
            END ELSE
                GOSUB RAISE.CHARGE.ACCT
                GOSUB RESET.AMOUNTS     ;* lcy.amount and fcy.amount should be unsigned
                GOSUB RAISE.CHARGE.PL
            END
*
        NEXT YI
    END
*
    RETURN
*
*****************
CALL.CALC.CHARGE:
*****************
*
    TOT.CHG.LOCAL = ''
    TOT.CHG.FOREIGN = ''
*
    CALL CALCULATE.CHARGE(R$SWAP<SW.CUSTOMER>,
    AMOUNT,         ;* unsigned
    LEG.CCY,
    R$SWAP<SW.CURRENCY.MARKET>,
    '',
    '',
    '',
    T.DATA,
    '',
    TOT.CHG.LOCAL,
    TOT.CHG.FOREIGN)
*
    RETURN
*
******************
RAISE.CHARGE.ACCT:
******************
*
***********************************************************
*  Fee code       :  Credit Client Acct                   *
*  Charge code    :  Debit Client Acct                    *
***********************************************************
*
    IF CHARGE.OR.FEE = 'C' THEN
        TRANSACTION.CODE = DEBIT.TXN.CODE
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
    END ELSE
        TRANSACTION.CODE = CREDIT.TXN.CODE
    END
*
*  Use swap.transaction.code if net.client.entries
*
    IF NET.CHARGES THEN
        TRANSACTION.CODE = SWAP.TRANSACTION.CODE
    END
*
    ACCOUNT.TYPE = "PRINCIPAL"
    GOSUB RAISE.CLIENT.ACCOUNT.ENTRY
    ENTRY<AC.STE.NARRATIVE> = ""        ;* no narrative on client side
*
    RETURN
*
****************
RAISE.CHARGE.PL:
****************
*
***********************************************************
*  Fee code       :  Debit P&L or internal account        *
*  Charge code    :  Credit P&L or internal account       *
***********************************************************
*
    IF CHARGE.OR.FEE = 'F' THEN
        TRANSACTION.CODE = DEBIT.TXN.CODE
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
    END ELSE
        TRANSACTION.CODE = CREDIT.TXN.CODE
    END
*
    IF NUM(POST.CODE) THEN    ;* it's a p&l category number
        PL.CATEGORY = POST.CODE
        GOSUB RAISE.CATEG.ENTRY
    END ELSE        ;* it's an internal account number
        GOSUB BUILD.BASE.ENTRY
        ENTRY<AC.STE.ACCOUNT.NUMBER> = POST.CODE
        ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
        GOSUB APPEND.LIVE.ENTRIES
    END
*
    RETURN
*
*************************************************************************
*
*******************
NET.CLIENT.ENTRIES:
*******************
*
*  go backward to find the first instance of the client account entry
*  cos that's the one we've just done
*  If not found then need to append it to accounting/forward entries.
*
    IF ACCOUNT.NUMBER THEN
        FMC = DCOUNT(COMMON.ENTRIES, FM)
        FOR EIDX = FMC TO 1 STEP -1
            IF ACCOUNT.NUMBER = COMMON.ENTRIES<EIDX, AC.STE.ACCOUNT.NUMBER> THEN
                IF VALUE.DATE = COMMON.ENTRIES<EIDX, AC.STE.VALUE.DATE> THEN
                    IF SWAP.TRANSACTION.CODE = COMMON.ENTRIES<EIDX, AC.STE.TRANSACTION.CODE> THEN
                        FOUND.CLIENT.ENTRY = 1
                        COMMON.ENTRIES<EIDX, AC.STE.AMOUNT.LCY> += ENTRY<AC.STE.AMOUNT.LCY>
                        IF ENTRY<AC.STE.AMOUNT.FCY> THEN
                            COMMON.ENTRIES<EIDX, AC.STE.AMOUNT.FCY> += ENTRY<AC.STE.AMOUNT.FCY>
                        END
                        EXIT  ;* exit this loop
                    END
                END
            END
        NEXT EIDX
    END
*
    RETURN
*
*************************************************************************
*
***************
APPEND.ENTRIES:
***************
*
    IF FORWARD.ENTRY THEN
        GOSUB APPEND.FORWARD.ENTRIES
    END ELSE
        GOSUB APPEND.LIVE.ENTRIES
    END
*
    RETURN
*
********************
APPEND.LIVE.ENTRIES:
********************
*
***********************************************************
*  Append accounting and crf entries to an array of       *
*  entries (C$ACCOUNTING.ENTRIES) held in common          *
*  (I_SW.COMMON).  They will all be held here and then    *
*  passed to EB.ACCOUNTING by the calling routine.        *
*  If REVERSAL is set then reverse the sign of the Local  *
*  and Foreign CCY amounts.                               *
***********************************************************
*
    IF REVERSAL THEN
        ENTRY<AC.STE.AMOUNT.LCY> = -ENTRY<AC.STE.AMOUNT.LCY>
        IF ENTRY<AC.STE.AMOUNT.FCY> THEN
            ENTRY<AC.STE.AMOUNT.FCY> = -ENTRY<AC.STE.AMOUNT.FCY>
        END
    END
*
    FOUND.CLIENT.ENTRY = 0
    IF NET.CHARGES THEN
        COMMON.ENTRIES = C$ACCOUNTING.ENTRIES
        GOSUB NET.CLIENT.ENTRIES
        C$ACCOUNTING.ENTRIES = COMMON.ENTRIES
    END
*
    IF NOT(FOUND.CLIENT.ENTRY) THEN
        C$ACCOUNTING.ENTRIES<-1> = LOWER(ENTRY)
    END
*
    RETURN
*
***********************
APPEND.FORWARD.ENTRIES:
***********************
*
***********************************************************
*  Append forward entries to an array of entries          *
*  (C$FORWARD.ENTRIES) held in common (I_SW.COMMON).      *
*  They will all be held here and then passed to          *
*  EB.ACCOUNTING by the calling routine.                  *
*  If REVERSAL is set then reverse the sign of the Local  *
*  and Foreign CCY amounts.                               *
***********************************************************
*
    IF REVERSAL THEN
        ENTRY<AC.STE.AMOUNT.LCY> = -ENTRY<AC.STE.AMOUNT.LCY>
        IF ENTRY<AC.STE.AMOUNT.FCY> THEN
            ENTRY<AC.STE.AMOUNT.FCY> = -ENTRY<AC.STE.AMOUNT.FCY>
        END
    END
*
    FOUND.CLIENT.ENTRY = 0
    IF NET.CHARGES THEN
        COMMON.ENTRIES = C$FORWARD.ENTRIES
        GOSUB NET.CLIENT.ENTRIES
        C$FORWARD.ENTRIES = COMMON.ENTRIES
    END
*
    IF NOT(FOUND.CLIENT.ENTRY) THEN
        C$FORWARD.ENTRIES<-1> = LOWER(ENTRY)
    END
*
    RETURN
*
*************************************************************************
*
**********************
DETERMINE.CCY.AMOUNTS:
**********************
*
*  Foreign CCY / Local CCY Conversion.
*
    IF LEG.CCY = LCCY THEN
        LCY.AMOUNT = AMOUNT
        FCY.AMOUNT = ""
    END ELSE
        FCY.AMOUNT = AMOUNT
*
        CALL MIDDLE.RATE.CONV.CHECK(FCY.AMOUNT,LEG.CCY,EXCH.RATE,"1",LCY.AMOUNT,"","")
        CALL EB.ROUND.AMOUNT(LCCY,LCY.AMOUNT,"","")
    END
*
*  Signed the amount for certain leg.type:schedule.type combinations
*
    NEG.KEY = LEG.TYPE:SCHEDULE.TYPE[1,2]
*
    LOCATE NEG.KEY IN NEGATIVE.AMOUNT.LIST<1> SETTING POS THEN
        GOSUB REVERSE.AMOUNTS ;* reverse signs of lcy.amount & fcy.amount
    END
*
    RETURN
*
*************************
DETERMINE.CLIENT.ACCOUNT:
*************************
*
***********************************************************
*  Determine client principal / interest account number.  *
***********************************************************
*
*  ACCOUNT.TYPE already set from calling subs.
*
    IF LCY.AMOUNT < 0 THEN
        ACCOUNT.PAYMENT = "RECEIPT"
    END ELSE
        ACCOUNT.PAYMENT = "PAYMENT"
    END
*
    ACCOUNT.NUMBER = ""
    SETTLEMENT.INFO = ""
*
    CALL CONV.SW.DETERMINE.SETTLEMENT.INFO(LEG.CCY,ACCOUNT.PAYMENT,ACCOUNT.TYPE,SETTLEMENT.INFO)
*
    ACCOUNT.NUMBER = SETTLEMENT.INFO<1>
*
    RETURN
*
************************
DETERMINE.ACCOUNT.CATEG:
************************
*
*************************************************
*  Determine the category code of the account   *
*  and set the stmt entry category code.        *
*************************************************
*
    ACCT.CATEG = ""
    RR.KEY = ACCOUNT.NUMBER
    ACCT.FILE = "ACCOUNT"
    ACCT.FILE<2> = AC.CATEGORY
    ACCT.FILE<3> = ""
*
    CALL DBR(ACCT.FILE,RR.KEY,ACCT.CATEG)
    ENTRY<AC.STE.PRODUCT.CATEGORY> = ACCT.CATEG
*
    RETURN
*
***************************
DETERMINE.CRF.ENTRY.DETAIL:
***************************
*
*  Determine details to construct a crf entry
*
    MAT.DATE = CRF.MATURITY.DATE        ;* default to crf.maturity.date
*
    IF LEG.TYPE = "A" THEN
        CRF.TYPE := "DB"
    END ELSE
        CRF.TYPE := "CR"
    END
*
    RETURN
*
****************
REVERSE.AMOUNTS:
****************
*
*  Revese signs of lcy.amount and fcy.amount
*
    LCY.AMOUNT = -LCY.AMOUNT
    IF FCY.AMOUNT THEN
        FCY.AMOUNT = -FCY.AMOUNT
    END
*
    RETURN
*
**************
RESET.AMOUNTS:
**************
*
*  Lcy.amount and fcy.amount should be unsigned
*
    LCY.AMOUNT = ABS(LCY.AMOUNT)
    IF FCY.AMOUNT THEN
        FCY.AMOUNT = ABS(FCY.AMOUNT)
    END
*
    RETURN
*
*************************************************************************
*
***************
UPDATE.CCY.POS:
***************
*
* !!! Raise the currency positions here
*
    IF LEG.TYPE = 'A' THEN
        R$SW.ASSET.BALANCES<SW.BAL.POSITION.DATE,-1> = VALUE.DATE
        R$SW.ASSET.BALANCES<SW.BAL.POSITION.LCY,-1> = LCY.AMOUNT
        R$SW.ASSET.BALANCES<SW.BAL.POSITION.FCY,-1> = FCY.AMOUNT
    END ELSE
        R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.DATE,-1> = VALUE.DATE
        R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.LCY,-1> = LCY.AMOUNT
        R$SW.LIABILITY.BALANCES<SW.BAL.POSITION.FCY,-1> = FCY.AMOUNT
    END

    RETURN
*
*************************************************************************
*
************************
GET.NPV.ENTRIES.DETAILS:
************************
*
    R.SWAP.TYPE = '' ; ER = ""
    CALL CACHE.READ('F.SWAP.TYPE',R$SWAP<SW.SWAP.TYPE>,R.SWAP.TYPE,ER)
    IF ER THEN
        ETEXT ='SW.RTN.CANT.READ.SWAP.TYPE':FM:R$SWAP<SW.SWAP.TYPE>
        GOTO FATAL.ERROR
    END
*
    OLD.SWAP.TYPE = ''
    READ OLD.SWAP.TYPE FROM F.SWAP.TYPE.ENT.TODAY, R$SWAP<SW.SWAP.TYPE> ELSE
        OLD.SWAP.TYPE = R.SWAP.TYPE
    END
*
    GOSUB GET.RESERVE.CATEGORY
*
    OLD.RESERVE.ACCOUNT.PROFIT = ''
    IF OLD.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.PFT> THEN
        OLD.RESERVE.ACCOUNT.PROFIT = LEG.CCY:OLD.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.PFT>:REVAL.DEPT
    END ELSE
        OLD.RESERVE.ACCOUNT.PROFIT = LEG.CCY:PROFIT.ACCOUNT.CAT:REVAL.DEPT
    END

    OLD.RESERVE.ACCOUNT.LOSS = ''
    IF OLD.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.LOSS> THEN
        OLD.RESERVE.ACCOUNT.LOSS = LEG.CCY:OLD.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.LOSS>:REVAL.DEPT
    END ELSE
        OLD.RESERVE.ACCOUNT.LOSS = LEG.CCY:LOSS.ACCOUNT.CAT:REVAL.DEPT
    END

    OLD.REVAL.PROFIT.CAT = OLD.SWAP.TYPE<SW.TYP.REVAL.PROFIT.CAT>
    OLD.REVAL.LOSS.CAT = OLD.SWAP.TYPE<SW.TYP.REVAL.LOSS.CAT>
*
    RESERVE.ACCOUNT.PROFIT = ''
    IF R.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.PFT> THEN
        RESERVE.ACCOUNT.PROFIT = LEG.CCY:R.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.PFT>:REVAL.DEPT
    END ELSE
        RESERVE.ACCOUNT.PROFIT = LEG.CCY:PROFIT.ACCOUNT.CAT:REVAL.DEPT
    END

    RESERVE.ACCOUNT.LOSS = ''
    IF R.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.LOSS> THEN
        RESERVE.ACCOUNT.LOSS = LEG.CCY:R.SWAP.TYPE<SW.TYP.INT.CAT.REVAL.LOSS>:REVAL.DEPT
    END ELSE
        RESERVE.ACCOUNT.LOSS = LEG.CCY:LOSS.ACCOUNT.CAT:REVAL.DEPT
    END

    REVAL.PROFIT.CAT = R.SWAP.TYPE<SW.TYP.REVAL.PROFIT.CAT>
    REVAL.LOSS.CAT = R.SWAP.TYPE<SW.TYP.REVAL.LOSS.CAT>
*
    RETURN

*
*********************
GET.RESERVE.CATEGORY:
*********************
    LOSS.ACCOUNT.CAT = '' ; PROFIT.ACCOUNT.CAT = '' ; R.ACCOUNT.CLASS = ""
    CALL CACHE.READ('F.ACCOUNT.CLASS','SUSPCREDIT',R.ACCOUNT.CLASS,ETEXT)
    IF ETEXT THEN
        GOTO FATAL.ERROR
    END ELSE
        LOSS.ACCOUNT.CAT = R.ACCOUNT.CLASS<AC.CLS.CATEGORY>
    END

    R.ACCOUNT.CLASS = ""
    CALL CACHE.READ('F.ACCOUNT.CLASS','SUSPDEBIT',R.ACCOUNT.CLASS,ETEXT)
    IF ETEXT THEN
        GOTO FATAL.ERROR
    END ELSE
        PROFIT.ACCOUNT.CAT = R.ACCOUNT.CLASS<AC.CLS.CATEGORY>
    END
    RETURN
*
**************
CALC.EXCHRATE:
**************
*
    BASE.CCY = ''
    RETURN.CODE = ''
    CALL EXCHRATE('1',
    CCY1,
    AMT1,
    CCY2,
    AMT2,
    BASE.CCY,
    XRATE,
    '',
    '',
    RETURN.CODE)
*
    RETURN
*
*
********************
DETERMINE.FX.ENTRY:
********************
*
* book to FX asset type -> lcy.equiv must be based on the base currency
*
    IF LEG.CCY <> BASE.CURRENCY THEN
        IF SCHEDULE.TYPE[1, 2] MATCH "PX" : VM : "RX" THEN
            SAVE.AMOUNT = AMOUNT
            SAVE.LEG.CCY = LEG.CCY
            AMOUNT = OTHER.LEG.PRINCIPAL
            LEG.CCY = BASE.CURRENCY
            EXCH.RATE = ""
            LCY.AMOUNT = ""
            GOSUB DETERMINE.CCY.AMOUNTS ;* get lcy.amount
            LCY.AMOUNT = ABS(LCY.AMOUNT)
            AMOUNT = SAVE.AMOUNT
            LEG.CCY = SAVE.LEG.CCY
            EXCH.RATE = ""
            GOSUB DETERMINE.CCY.AMOUNTS ;* exch.rate based on correct lcy.amount
            END ELSE IF SCHEDULE.TYPE[1, 2] MATCH "PI" : VM : "PD" THEN
*--- Find the same schedule on the opposite side to get amount to find lcy amount and rate.
*--- If no match schedule found then use mid rate to convert fcy amount.
                IF LEG.TYPE = "A" THEN
                    SW.TYPE.FIELD = SW.LB.TYPE
                    SW.DATE.FREQ.FIELD = SW.LB.DATE.FREQ
                    SW.AMOUNT.FIELD = SW.LB.AMOUNT
                END ELSE
                    SW.TYPE.FIELD = SW.AS.TYPE
                    SW.DATE.FREQ.FIELD = SW.AS.DATE.FREQ
                    SW.AMOUNT.FIELD = SW.AS.AMOUNT
                END
                SCHED.FOUND = 0
                FOR SCHED.IDX = 1 TO DCOUNT(R$SWAP<SW.TYPE.FIELD>, VM)
                    IF R$SWAP<SW.TYPE.FIELD, SCHED.IDX>[1, 2] = SCHEDULE.TYPE[1, 2] THEN
                        IF R$SWAP<SW.DATE.FREQ.FIELD, SCHED.IDX>[1, 8] = VALUE.DATE THEN
                            SCHED.FOUND = 1
                            EXIT
                        END
                    END
                NEXT SCHED.IDX
                IF SCHED.FOUND = 1 AND LEG.CCY <> BASE.CURRENCY THEN
                    SAVE.AMOUNT = AMOUNT
                    SAVE.LEG.CCY = LEG.CCY
                    AMOUNT = R$SWAP<SW.AMOUNT.FIELD, SCHED.IDX>
                    LEG.CCY = BASE.CURRENCY
                    EXCH.RATE = ""
                    LCY.AMOUNT = ""
                    GOSUB DETERMINE.CCY.AMOUNTS   ;* get lcy.amount
                    LCY.AMOUNT = ABS(LCY.AMOUNT)
                    AMOUNT = SAVE.AMOUNT
                    LEG.CCY = SAVE.LEG.CCY
                    EXCH.RATE = ""
                END ELSE
                    LCY.AMOUNT = ""
                    EXCH.RATE = ""
                END
                GOSUB DETERMINE.CCY.AMOUNTS
            END
        END ELSE
            IF FCY.AMOUNT = "" OR LCY.AMOUNT = "" THEN
                GOSUB DETERMINE.CCY.AMOUNTS
            END
        END
*
        RETURN
*
*************************************************************************
*                                                                       *
*  Error Handling                                                       *
*                                                                       *
*************************************************************************
*
************
FATAL.ERROR:
************
*
        TEXT = ETEXT
        CALL FATAL.ERROR("SW.ACCOUNTING")
*
        RETURN
*
*************************************************************************
GET.AMOUNTS:
************
        IF LEG.CCY <> LCCY THEN
            FCY.AMOUNT = AMOUNT
            CALL MIDDLE.RATE.CONV.CHECK(FCY.AMOUNT, LEG.CCY, EXCH.RATE, "1", LCY.AMOUNT,"","")
            CALL EB.ROUND.AMOUNT(LCCY, LCY.AMOUNT,"","")
        END ELSE
            LCY.AMOUNT = AMOUNT
        END

        RETURN

*-----------------------------------------------------------------------------------
FIND.CURR.SCHED.AMOUNT:
*----------------------
        ORIG.OTHER.LEG.PRINCIPAL = OTHER.LEG.PRINCIPAL
        Y.POS = 0
        IF LEG.TYPE = "L" THEN
            LOCATE ORIG.VALUE.DATE IN R$SW.LIABILITY.BALANCES<SW.BAL.PRIN.DATE,1> SETTING Y.POS THEN
            END ELSE
                Y.POS = 0
            END
            OTHER.LEG.PRINCIPAL = R$SW.LIABILITY.BALANCES<SW.BAL.PRINCIPAL,1 + Y.POS >
        END ELSE
            IF LEG.TYPE = 'A' THEN
                LOCATE ORIG.VALUE.DATE IN R$SW.ASSET.BALANCES<SW.BAL.PRIN.DATE,1> SETTING Y.POS THEN
                END ELSE
                    Y.POS = 0
                END
                OTHER.LEG.PRINCIPAL = R$SW.ASSET.BALANCES<SW.BAL.PRINCIPAL,1 + Y.POS >
            END
        END
        RETURN
*
*------------------------------------------------------------------------------------
    END
