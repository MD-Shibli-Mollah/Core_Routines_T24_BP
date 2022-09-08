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
* <Rating>-95</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Interest
    SUBROUTINE CONV.SW.CALCULATE.INTEREST(LEG.TYPE)

*
*************************************************************************
*                                                                       *
*  Routine        :  CONV.SW.CALCULATE.INTEREST
*                                                                       *
*************************************************************************
*                                                                       *
*  Description    :  This routine calculates the amount of interest     *
*                    due in the current period.  It is called from      *
*                    SW.PERFORM.ACCRUAL and updates the BALANCES>       *
*                    INTEREST.AMOUNT field.                             *
*                                                                       *
*************************************************************************
*                                                                       *
*  Parameters     :  LEG.TYPE - 'A'sset or 'L'iability                  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications  :                                                     *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 22/09/08 - BG_100019970
*            Rating Reduction
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
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
    TEXT = '' ; R$SW.BALANCES = '' ; INTEREST.AMOUNT = ''
*
    Y.MKT.EXCH.CALC = 0 ; MKT.EXCH.INT.AMT = 0 ; MKT.EXCH.INT.RATE = ''
    Y.MKT.ACCRUAL.SAVE = ''

* R.ACCRUAL equivalent. To assign NULL values by default.
    YFLD = SW.BAL.ACCR.FROM.DATE
    FOR YI = EB.AC.FROM.DATE TO EB.AC.ACCR.ACT.AMT
        Y.MKT.ACCRUAL.SAVE<YI> = ''
        YFLD += 1
    NEXT YI

    PRIN.DATA = '' ; INT.DATA = '' ; R.ACCRUAL = '' ; CALC.PERIOD = ''
*
    SCHEDULES.TO.PROCESS = 'IP,AP,RR,PI,PD,NI,ND'
    CONVERT ',' TO VM IN SCHEDULES.TO.PROCESS
*
*
    TODAYS.DATE = R.DATES(EB.DAT.TODAY)
*
* check split month end
*
    IF TODAY[5,2] <> R.DATES(EB.DAT.LAST.WORKING.DAY)[5,2] THEN
        IF TODAY[2] <> '01' THEN        ;* split month end
            TODAYS.DATE = TODAY[1,6]:'01'
        END
    END
*
***********
* main body
***********
*
    SCHD.LIST = ''
    CALL CONV.SW.BUILD.SCHEDULE.LIST(SCHD.LIST,'')
*
    IF LEG.TYPE = 'A' THEN
        R$SW.BALANCES = R$SW.ASSET.BALANCES
    END ELSE
        R$SW.BALANCES = R$SW.LIABILITY.BALANCES
    END
*
    CALL CONV.SW.DETERMINE.FIELDS(LEG.TYPE)       ;* ensure the fields are set for this leg.type
*
    GOSUB BUILD.WORK.ARRAYS   ;* for EB.PERFORM.ACCRUAL
    GOSUB PROCESS.SCHEDULES   ;* in SCHEDULES.TO.PROCESS list
*
    IF INTEREST.AMOUNT THEN
        IF LEG.TYPE = 'A' THEN
            R$SW.ASSET.BALANCES<SW.BAL.INTEREST.AMOUNT> = INTEREST.AMOUNT
        END ELSE
            R$SW.LIABILITY.BALANCES<SW.BAL.INTEREST.AMOUNT> = INTEREST.AMOUNT
        END
    END
*
* Update the calculated Market Exchange Interest amount in SWAP.BALANCES
    IF MKT.EXCH.INT.AMT THEN
        IF LEG.TYPE = 'A' THEN
            R$SW.ASSET.BALANCES<SW.BAL.MKT.INT.AMOUNT> = MKT.EXCH.INT.AMT
        END ELSE
            R$SW.LIABILITY.BALANCES<SW.BAL.MKT.INT.AMOUNT> = MKT.EXCH.INT.AMT
        END
    END
*
    RETURN
*
*
******************
* local subroutine
******************
*
BUILD.WORK.ARRAYS:
*
* build PRIN.DATA, INT.DATA, R.ACCRUAL and CALC.PERIOD for EB.PERFORM.ACCRUAL
*
    PRIN.DATA<EB.ACP.PRIN.AMOUNT> = R$SW.BALANCES<SW.BAL.PRINCIPAL>
    PRIN.DATA<EB.ACP.PRIN.EFF.DATE> = R$SW.BALANCES<SW.BAL.PRIN.DATE>
*
    INT.DATA<EB.ACI.INT.EFF.DATE> = R$SW.BALANCES<SW.BAL.EFFECTIVE.DATE>
    INT.DATA<EB.ACI.INT.KEY> = R$SW.BALANCES<SW.BAL.INTEREST.KEY>
    INT.DATA<EB.ACI.INT.RATE> = R$SW.BALANCES<SW.BAL.INTEREST.RATE>
    MKT.INT.DATA = R$SW.BALANCES<SW.BAL.MKT.INT.RATE>
*
    YFLD = SW.BAL.ACCR.FROM.DATE
    FOR YI = EB.AC.FROM.DATE TO EB.AC.ACCR.ACT.AMT
        R.ACCRUAL<YI> = ''
        YFLD += 1
    NEXT YI
*
    CALC.PERIOD<EB.ACD.RECORD.START> = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
    CALC.PERIOD<EB.ACD.ACCR.START> = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
    CALC.PERIOD<EB.ACD.ACCR.END> = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
    CALC.PERIOD<EB.ACD.CONTRACT.ID> = C$SWAP.ID:"-":LEG.TYPE
    CALC.PERIOD<EB.ACD.ACCRUAL.PARAM> = R$SWAP<SW.EB.ACCRUAL.PARAM>
*
    RETURN
*
*
PROCESS.SCHEDULES:
*
* process schedules in SCHD.LIST and act on those in SCHEDULES.TO.PROCESS only
*
    EXIT.LOOP = 0
    RATE.KEY = R$SWAP<SWAP$RATE.KEY>
    SPREAD = R$SWAP<SWAP$SPREAD>
*
    SCNT = 0
    LOOP
        SCNT += 1
        SCHD.TYPE = SCHD.LIST<1, SCNT>[1,2]
    UNTIL SCHD.TYPE = '' DO
*
        SCHD.LEG.TYPE = SCHD.LIST<8, SCNT>
        IF (SCHD.LEG.TYPE = LEG.TYPE) AND (SCHD.TYPE MATCHES SCHEDULES.TO.PROCESS) THEN
            SCHD.DATE = SCHD.LIST<2, SCNT>
            VALUE.DATE = SCHD.LIST<3, SCNT>
            PROCESS.DATE = SCHD.LIST<4, SCNT>
            EFFECTIVE.DATE = SCHD.LIST<5, SCNT>
            PROCESS.VALUE = SCHD.LIST<6, SCNT>
            SCHD.NARR = SCHD.LIST<7, SCNT>
            SCHD.INDEX = SCHD.LIST<9, SCNT>
*
* has to use PROCESS.DATE because TODAY must be a working day and
* EFFECTIVE.DATE could be a non-working day
*
* TODAYS.DATE will be 1st of month on a SME
*
            LOCATE "IP" IN R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING MPOS THEN
                EFF.IN.BETWEEN.IP = EFFECTIVE.DATE GE R$SW.BALANCES<SW.BAL.START.INT.PERIOD> AND EFFECTIVE.DATE LT R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
            END ELSE
                EFF.IN.BETWEEN.IP = 0
            END
            IF (PROCESS.DATE >= TODAYS.DATE) AND (EFFECTIVE.DATE <= R$SW.BALANCES<SW.BAL.END.INT.PERIOD>) THEN
*
* just interested in the current and forward schedules up to the END.INT.PERIOD
* terminate the process once an IP/AP schedule has been processed
* the unprocessed schedules will be included in the next interest period
*
                GOSUB PROCESS.CUR.FOR.SCHEDULE
            END
        END
*
        IF EXIT.LOOP THEN
            EXIT    ;*Loop breaks if EXIT.LOOP is set
        END
    REPEAT
    RETURN

*
MKT.EXCH.INTERST.ACCRUAL:
* To calculate Market Interest interest amount for the current period
    MKT.EXCH.INT.AMT = 0 ; MKT.EXCH.INT.RATE = '' ; Y.ACCRUAL.SAVE = ''

    IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SWAP$FIXED.RATE> THEN
        Y.MKT.EXCH.CALC = 1
        Y.ACCRUAL.SAVE = R.ACCRUAL      ;* Accrual data related to Customer rate
        R.ACCRUAL = Y.MKT.ACCRUAL.SAVE  ;* Accrual data related to Treasury rate

        INT.DATA<EB.ACI.INT.RATE> = MKT.INT.DATA  ;* Treasury Rate
        GOSUB ACCRUE.TO.DATE  ;* Calculate accrual for the Treasury rate

        Y.MKT.ACCRUAL.SAVE = R.ACCRUAL
        R.ACCRUAL = Y.ACCRUAL.SAVE ; Y.MKT.EXCH.CALC = 0
    END
    RETURN
*
PROCESS.CUR.FOR.SCHEDULE:

    IF SCHD.TYPE MATCHES 'IP':VM:'AP' THEN
*
* if Interest Payment is fixed just use the interest amount on the IP schedule
* otherwise, set ACCRUAL.TO.DATE to SW.BAL.END.INT.PERIOD -1C and call ACCRUE.TO.DATE
* the loop should be terminated immediately in both cases
*
        IF R$SWAP<SWAP$FIXED.INTEREST> = 'Y' THEN
            INTEREST.AMOUNT = PROCESS.VALUE
        END ELSE
            ACCRUAL.TO.DATE = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
            CALL CDT('', ACCRUAL.TO.DATE, '-1C')  ;* this is the last day to be accrued
            IF R$SW.BALANCES<SW.BAL.ACCR.TO.DATE,1> AND ACCRUAL.TO.DATE <= R$SW.BALANCES<SW.BAL.ACCR.TO.DATE,1> THEN
                RETURN
            END ELSE
                GOSUB ACCRUE.TO.DATE
                GOSUB MKT.EXCH.INTERST.ACCRUAL
            END
        END
*
        EXIT.LOOP = 1
        RETURN      ;* the IP schedule is the last schedule we are interested anyway
*
    END ELSE
*
* this is either RR, PI or PD which needs to update either INT.DATA or PRIN.DATA
*
* !!! Fix for null RR schedule fouling up the committed interest amount
*
        IF PROCESS.VALUE <> '' THEN
            IF SCHD.TYPE = 'RR' THEN
                PROCESS.VALUE += SPREAD
            END
            IF EFF.IN.BETWEEN.IP AND (R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SWAP$FIXED.RATE>) THEN
* For an amendment between IPs, the effective date will be from the start interest date of the
* current period.

                EFFECTIVE.DATE=R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
            END
            CALL SW.UPDATE.BALANCES(SCHD.TYPE, EFFECTIVE.DATE, PROCESS.VALUE, RATE.KEY, PRIN.DATA, INT.DATA)
        END
*
    END

    RETURN
*
ACCRUE.TO.DATE:
*
* accrue interest up to ACCRUAL.TO.DATE
*
    CCY = R$SWAP<SWAP$CURRENCY>
    INT.DAY.BASIS = R$SWAP<SWAP$BASIS>
*
    CUSTOMER = ''   ;* may need changing for rounding later
*
    OTS.AMOUNT = ''
    THIS.MONTH.ACCR = ''
    PREV.MONTH.ACCR = ''
    PREV.YEAR.ACCR = ''
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

    IF Y.MKT.EXCH.CALC THEN   ;* Market Exchange calculation
        MKT.EXCH.INT.AMT = THIS.MONTH.ACCR + PREV.MONTH.ACCR + PREV.YEAR.ACCR
    END ELSE
        INTEREST.AMOUNT = THIS.MONTH.ACCR + PREV.MONTH.ACCR + PREV.YEAR.ACCR
    END
*
    RETURN
*
*
END
