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
* <Rating>-102</Rating>
*-----------------------------------------------------------------------------
* Version 6 15/05/01  GLOBUS Release No. G12.0.00 29/06/01

    $PACKAGE SW.Interest
    SUBROUTINE CONV.SW.PERFORM.ACCRUAL(ACCRUAL.TO.DATE, ADJUSTMENT.DATE, LEG.TYPE)

*
*************************************************************************
*                                                                       *
*  Routine        :  CONV.SW.PERFORM.ACCRUAL
*                                                                       *
*************************************************************************
*                                                                       *
*  Description    :  This routine will perform the interest accruals    *
*                    for the current swap contract from the interest    *
*                    effective date / next day of the last accr.to.date *
*                    to ACCRUAL.TO.DATE.                                *
*                    If an ADJUSTMENT.DATE has been passed (for         *
*                    backdated events only), locate the date in the     *
*                    accrual array; store the accrual amounts based on  *
*                    current month, previous month and previous year;   *
*                    remove all the accrual information after the       *
*                    ADJUSTMENT.DATE before calling EB.PERFORM.ACCRUAL; *
*                    nett the three accrued amounts with the            *
*                    corresponding old ones before calling              *
*                    SW.ACCOUNTING.                                     *
*                                                                       *
*************************************************************************
*                                                                       *
*  Parameters     :  ACCRUAL.TO.DATE - accrual to date              IN  *
*                    ADJUSTMENT.DATE - date to adjust accrual from  IN  *
*                    LEG.TYPE        - 'A'sset or 'L'iability       IN  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications  :                                                     *
*
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.DATES
    $INSERT I_F.EB.ACCRUAL.DATA
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_SW.COMMON
*
*************************************************************************
*
* initialisation
*
    TEXT = '' ; PRIN.DATA = '' ; INT.DATA = '' ; R.ACCRUAL = ''
    CALC.PERIOD = '' ; R$SW.BALANCES = '' ; NARRATIVE = ''  ;* EN_10002630 S/E
    NARR.SAVE = ''
*
    CALL CONV.SW.CALCULATE.INTEREST(LEG.TYPE)     ;* make sure SW.BAL.INTEREST.AMOUNT is set correctly
*
    IF LEG.TYPE = 'A' THEN
        R$SW.BALANCES = R$SW.ASSET.BALANCES
    END ELSE
        R$SW.BALANCES = R$SW.LIABILITY.BALANCES
    END
*
* don't perform accrual if final accrual has been done
* But only if ADJUSTMENT.DATE is null
*
    IF (ADJUSTMENT.DATE <> '') OR (ACCRUAL.TO.DATE > R$SW.BALANCES<SW.BAL.ACCR.TO.DATE,1>) THEN
        CALL CONV.SW.DETERMINE.FIELDS(LEG.TYPE)   ;* ensure the fields are set to this leg.type
        LOCATE 'IP' IN R$SWAP<SWAP$TYPE,1> SETTING POS ELSE
            RETURN
        END
        GOSUB ACCRUE.TO.DATE
    END
*
    RETURN
*
******************
* local subroutine
******************
*
*
ACCRUE.TO.DATE:
*
* accrue interest up to ACCRUAL.TO.DATE iff it is inside
* the current interest period
* include start.int.period and exclude end.int.period for FIRST DAY ACCRUAL
* exclude start.int.period and include end.int.period for LAST DAY ACCRUAL
*
    IF (ACCRUAL.TO.DATE >= R$SW.BALANCES<SW.BAL.START.INT.PERIOD>) AND (ACCRUAL.TO.DATE < R$SW.BALANCES<SW.BAL.END.INT.PERIOD>) THEN
        PRIN.DATA<EB.ACP.PRIN.AMOUNT> = R$SW.BALANCES<SW.BAL.PRINCIPAL>
        PRIN.DATA<EB.ACP.PRIN.EFF.DATE> = R$SW.BALANCES<SW.BAL.PRIN.DATE>
*
        INT.DATA<EB.ACI.INT.EFF.DATE> = R$SW.BALANCES<SW.BAL.EFFECTIVE.DATE>
        INT.DATA<EB.ACI.INT.KEY> = R$SW.BALANCES<SW.BAL.INTEREST.KEY>
        INT.DATA<EB.ACI.INT.RATE> = R$SW.BALANCES<SW.BAL.INTEREST.RATE>
*
* if fixed interest, need to set EB.ACI.INT.AMT for EB.PERFORM.ACCRUAL
*
        IF R$SWAP<SWAP$FIXED.INTEREST> = 'Y' THEN
            INT.DATA<EB.ACI.INT.AMT> = R$SW.BALANCES<SW.BAL.INTEREST.AMOUNT>
        END
*
        GOSUB POPULATE.R.ACCRUAL        ;* EN_10002630 S/E
*
* need to remove the affected fields if ADJUSTMENT.DATE is passed in
*
        IF ADJUSTMENT.DATE <> '' THEN
            GOSUB ADJUST.ACCRUAL.DATA
        END
*
        CALC.PERIOD<EB.ACD.RECORD.START> = R$SWAP<SWAP$INT.EFFECTIVE>
        CALC.PERIOD<EB.ACD.ACCR.START> = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
        CALC.PERIOD<EB.ACD.ACCR.END> = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
        CALC.PERIOD<EB.ACD.CONTRACT.ID> = C$SWAP.ID:'-':LEG.TYPE
        CALC.PERIOD<EB.ACD.ACCRUAL.PARAM> = R$SWAP<SW.EB.ACCRUAL.PARAM>
*
        CCY = R$SWAP<SWAP$CURRENCY>
        INT.DAY.BASIS = R$SWAP<SWAP$BASIS>
        GOSUB CALCULATE.ACCRUAL         ;* EN_10002630 S/E
*
* update the SWAP.BALANCES record in COMMON
*
        YFLD = SW.BAL.ACCR.FROM.DATE
        IF LEG.TYPE = 'A' THEN
            FOR YI = EB.AC.FROM.DATE TO EB.AC.ACCR.ACT.AMT
                R$SW.ASSET.BALANCES<YFLD> = R.ACCRUAL<YI>
                YFLD += 1
            NEXT YI
        END ELSE
            FOR YI = EB.AC.FROM.DATE TO EB.AC.ACCR.ACT.AMT
                R$SW.LIABILITY.BALANCES<YFLD> = R.ACCRUAL<YI>
                YFLD += 1
            NEXT YI
        END
*
* if ADJUSTMENT.DATE passed in then need to nett the three accrued amounts
*
        IF ADJUSTMENT.DATE <> '' THEN
            THIS.MONTH.ACCR -= OLD.THIS.MONTH
            PREV.MONTH.ACCR -= OLD.PREV.MONTH
            PREV.YEAR.ACCR -= OLD.PREV.YEAR
        END
*
* call SW.ACCOUNTING to construct the appropriate entries
        GOSUB CALL.SW.ACCOUNTING        ;* EN_10002630 - S
        GOSUB MKT.EXCH.INTERST.ACCRUAL
    END
    RETURN
*
*******************
POPULATE.R.ACCRUAL:
*******************
* To populate Accrual details from SWAP.BALANCES
    YFLD = 1
    FOR YI = SW.BAL.ACCR.FROM.DATE TO SW.BAL.ACCR.ACT.AMT
        R.ACCRUAL<YFLD> = R$SW.BALANCES<YI>
        YFLD += 1
    NEXT YI
    RETURN

******************
CALCULATE.ACCRUAL:
******************
    OTS.AMOUNT = '' ; CUSTOMER = ''     ;* may need changing for rounding later
    THIS.MONTH.ACCR = '' ; PREV.MONTH.ACCR = '' ; PREV.YEAR.ACCR = ''
*
    CALL EB.PERFORM.ACCRUAL(R.ACCRUAL,
    PRIN.DATA,
    INT.DATA,
    CALC.PERIOD,
    CCY,
    CUSTOMER,
    INT.DAY.BASIS,
    ACCRUAL.TO.DATE,
    THIS.MONTH.ACCR,
    PREV.MONTH.ACCR,
    PREV.YEAR.ACCR,
    OTS.AMOUNT)

    RETURN
*
*************************
MKT.EXCH.INTERST.ACCRUAL:
*************************
* To Calculate Market Exchange accrual
    Y.ACCRUAL.SAVE = ''

    IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SWAP$FIXED.RATE> THEN
        Y.ACCRUAL.SAVE = R.ACCRUAL
        GOSUB POPULATE.R.ACCRUAL

* Populate Market Exchange related accrual details
        YFLD = EB.AC.RATE
        FOR YI = SW.BAL.MKT.ACCR.RATE TO SW.BAL.MKT.ACT.AMT
            R.ACCRUAL<YFLD> = R$SW.BALANCES<YI>
            YFLD += 1
        NEXT YI

        IF ADJUSTMENT.DATE <> '' THEN
            GOSUB ADJUST.ACCRUAL.DATA
        END

* Assign Market Exchange interest rate
        INT.DATA<EB.ACI.INT.RATE> = R$SW.BALANCES<SW.BAL.MKT.INT.RATE>

        GOSUB CALCULATE.ACCRUAL

* Population of calculated accrual details in SWAP.BALANCES
        YFLD = SW.BAL.MKT.ACCR.RATE
        IF LEG.TYPE = 'A' THEN
            FOR YI = EB.AC.RATE TO EB.AC.ACCR.ACT.AMT
                R$SW.ASSET.BALANCES<YFLD> = R.ACCRUAL<YI>
                YFLD += 1
            NEXT YI
        END ELSE
            FOR YI = EB.AC.RATE TO EB.AC.ACCR.ACT.AMT
                R$SW.LIABILITY.BALANCES<YFLD> = R.ACCRUAL<YI>
                YFLD += 1
            NEXT YI
        END

        IF ADJUSTMENT.DATE <> '' THEN
            THIS.MONTH.ACCR -= OLD.THIS.MONTH
            PREV.MONTH.ACCR -= OLD.PREV.MONTH
            PREV.YEAR.ACCR -= OLD.PREV.YEAR
        END

        R.ACCRUAL = Y.ACCRUAL.SAVE
        NARR.SAVE = 'MKT.EXCH.ACCRUAL'  ;* To distinguish that this is for Market Exchange postings
        GOSUB CALL.SW.ACCOUNTING
        NARR.SAVE = ''
    END
    RETURN

*******************
CALL.SW.ACCOUNTING:
*******************
    IF THIS.MONTH.ACCR THEN
        NARRATIVE = NARR.SAVE
        CALL CONV.SW.ACCOUNTING('AC', LEG.TYPE, THIS.MONTH.ACCR, '', '', NARRATIVE, '', '', '')
    END
*
    IF PREV.MONTH.ACCR THEN
        NARRATIVE = NARR.SAVE
        CALL CONV.SW.ACCOUNTING('AM', LEG.TYPE, PREV.MONTH.ACCR, '', '', NARRATIVE, '', '', '')
    END
*
    IF PREV.YEAR.ACCR THEN
        NARRATIVE = NARR.SAVE
        CALL CONV.SW.ACCOUNTING('AY', LEG.TYPE, PREV.YEAR.ACCR, '', '', NARRATIVE, '', '', '')
    END
    RETURN          ;* EN_10002630 - E
*
ADJUST.ACCRUAL.DATA:
*
* adjust R.ACCRUAL if ADJUSTMENT.DATE passed in
*
    IF ADJUSTMENT.DATE >= R$SW.BALANCES<SW.BAL.START.INT.PERIOD> THEN
        START.INT.PERIOD = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
        OLD.PREV.YEAR = 0
        OLD.PREV.MONTH = 0
        OLD.THIS.MONTH = 0
*
* backdated event is inside current interest period
* that is no statement entries have been made
* so just need to redo perform accrual
        CALL EB.ACCRUAL.ADJUST(ADJUSTMENT.DATE, START.INT.PERIOD, R.ACCRUAL, OLD.PREV.YEAR, OLD.PREV.MONTH, OLD.THIS.MONTH)
    END   ;* IF ADJUSTMENT.DATE >= START.INT.PERIOD
*
    RETURN
*
*************************************************************************
*
END
