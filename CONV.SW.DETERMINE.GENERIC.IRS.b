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
* <Rating>-72</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.SW.DETERMINE.GENERIC.IRS(ARG.OUT,FREQ.CODE,SWAP.ID)
*
*************************************************************************
*
* A generic interest rate swap must have regular interest payments and
* the brokerage calculation must be based on the fixed side.
*
* No principal movement and payment/receipt schedules will be allowed.
*
* ARG.OUT   - out
* FREQ.CODE - out
* SWAP.ID   - in
*
*************************************************************************
*
* 23/09/08 - BG_100020085
*            Rating Reduction for SWAP routines.
*
*************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_SW.COMMON
*
*************************************************************************
*
*************
MAIN.PROCESS:
*************
*
* A generic IRS has to be
* 1. same currency on both sides
* 2. a generic swap (no principal movement and payment/reciept)
* 3. regular interest payments with fixed rate defined
*    on the brokerage calculation side
*
    ARG.OUT = 'N'
    FREQ.CODE = ''

    IF (R$SWAP<SW.AS.CURRENCY> EQ R$SWAP<SW.LB.CURRENCY>) AND R$SWAP<SW.BROKERAGE.BASE> THEN
        GENERIC.SWAP = ''
        GOSUB CHECK.GENERIC.SWAP
        IF GENERIC.SWAP THEN
*
            GOSUB DETERMINE.BROKERAGE.BASE
*
* Look for IP with a frequency code
* OR multiple IPs
*
            GOSUB DETERMINE.IP

            IF IP.FOUND THEN
                ARG.OUT = 'Y'
            END
*
        END
*
    END
*
    RETURN
*
************************************************************************
*
*************************
DETERMINE.BROKERAGE.BASE:
*************************
    IF R$SWAP<SW.BROKERAGE.BASE> EQ 'ASSET' THEN
        BR.VALUE.DATE = R$SWAP<SW.AS.INT.EFFECTIVE>
        BR.PRINCIPAL = R$SWAP<SW.AS.PRINCIPAL>
        BR.CURRENCY = R$SWAP<SW.AS.CURRENCY>
        BR.RATE = R$SWAP<SW.AS.FIXED.RATE>
        SCHED.FIELD = SW.AS.TYPE
        FREQ.FIELD = SW.AS.DATE.FREQ
        INT.BASIS = R$SWAP<SW.AS.BASIS>
        INT.START.DATE = R$SW.ASSET.BALANCES<SW.BAL.START.INT.PERIOD>
    END ELSE
        BR.VALUE.DATE = R$SWAP<SW.LB.INT.EFFECTIVE>
        BR.PRINCIPAL = R$SWAP<SW.LB.PRINCIPAL>
        BR.CURRENCY = R$SWAP<SW.LB.CURRENCY>
        BR.RATE = R$SWAP<SW.LB.FIXED.RATE>
        SCHED.FIELD = SW.LB.TYPE
        FREQ.FIELD = SW.LB.DATE.FREQ
        INT.BASIS = R$SWAP<SW.LB.BASIS>
        INT.START.DATE = R$SW.LIABILITY.BALANCES<SW.BAL.START.INT.PERIOD>
    END

    RETURN

*************************************************************************
*******************
CHECK.GENERIC.SWAP:
*******************
*
* a generic swap is defined as no principal movements
* and no premium/discount
*
    AS.TYPES = R$SWAP<SW.AS.TYPE>
    AS.BAL.TYPES = R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE>
    LB.TYPES = R$SWAP<SW.LB.TYPE>
    LB.BAL.TYPES = R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE>
*
    TOKEN = 'PX'
    PX.EXISTS = (INDEX(AS.TYPES,TOKEN,1) OR INDEX(AS.BAL.TYPES,TOKEN,1) OR INDEX(LB.TYPES,TOKEN,1) OR INDEX(LB.BAL.TYPES,TOKEN,1))
*
    TOKEN = 'RX'
    RX.EXISTS = (INDEX(AS.TYPES,TOKEN,1) OR INDEX(AS.BAL.TYPES,TOKEN,1) OR INDEX(LB.TYPES,TOKEN,1) OR INDEX(LB.BAL.TYPES,TOKEN,1))
*
    TOKEN = 'PI'
    PI.EXISTS = (INDEX(AS.TYPES,TOKEN,1) OR INDEX(AS.BAL.TYPES,TOKEN,1) OR INDEX(LB.TYPES,TOKEN,1) OR INDEX(LB.BAL.TYPES,TOKEN,1))
*
    TOKEN = 'PD'
    PD.EXISTS = (INDEX(AS.TYPES,TOKEN,1) OR INDEX(AS.BAL.TYPES,TOKEN,1) OR INDEX(LB.TYPES,TOKEN,1) OR INDEX(LB.BAL.TYPES,TOKEN,1))
*
    TOKEN = 'PM'
    PM.EXISTS = (INDEX(AS.TYPES,TOKEN,1) OR INDEX(AS.BAL.TYPES,TOKEN,1) OR INDEX(LB.TYPES,TOKEN,1) OR INDEX(LB.BAL.TYPES,TOKEN,1))
*
    TOKEN = 'RV'
    RV.EXISTS = (INDEX(AS.TYPES,TOKEN,1) OR INDEX(AS.BAL.TYPES,TOKEN,1) OR INDEX(LB.TYPES,TOKEN,1) OR INDEX(LB.BAL.TYPES,TOKEN,1))
*
    GENERIC.SWAP = NOT(PX.EXISTS OR RX.EXISTS OR PI.EXISTS OR PD.EXISTS OR PM.EXISTS OR RV.EXISTS)
*
    RETURN
*
********************
DETERMINE.FREQUENCY:
********************
*
* Sort schedule dates into ascending order
* Work out number of days in each period
* Then determine the frequency
*
    FREQ.CODE = ''
    SCHED.DATE.ARRAY = ''
    FOR YY = 1 TO NO.OF.SCHEDS
        IF R$SWAP<SCHED.FIELD,YY>[1,2] EQ 'IP' THEN
            SCHED.DATE = R$SWAP<FREQ.FIELD,YY>
            LOCATE SCHED.DATE IN SCHED.DATE.ARRAY<1,1> BY 'AR' SETTING DPOS ELSE
                INS SCHED.DATE BEFORE SCHED.DATE.ARRAY<1,DPOS>
            END
        END
    NEXT YY
*
    NO.OF.IPS = DCOUNT(SCHED.DATE.ARRAY<1>,VM)
    IF NO.OF.IPS LT 1 THEN
        RETURN
    END
*
    START.DATE = INT.START.DATE
    FOR YY = 1 TO NO.OF.IPS
        END.DATE = SCHED.DATE.ARRAY<1,YY>
        DAYS.IN.PERIOD = ''
        CALL BD.CALC.DAYS(START.DATE,END.DATE,INT.BASIS,DAYS.IN.PERIOD)
        SCHED.DATE.ARRAY<2,YY> = DAYS.IN.PERIOD
        START.DATE = END.DATE
    NEXT YY
*
* determine number of interest payments per year
*
    IF INT.BASIS[1,1] MATCHES 'A':VM:'B' THEN
        YEAR.DAYS = 360
    END ELSE
        YEAR.DAYS = 365
    END

    FREQ.ARRAY = ''
    FOR YY = 1 TO NO.OF.IPS
        DAYS.IN.PERIOD = SCHED.DATE.ARRAY<2,YY>
* Only Mnn allowed
        BEGIN CASE
        CASE DAYS.IN.PERIOD >= 28
            FREQ = INT(36/INT(DAYS.IN.PERIOD/10))
        CASE 1
            FREQ = 1
        END CASE
        FREQ.ARRAY<FREQ> += 1
    NEXT YY
*
    FREQ.COUNT = MAXIMUM(FREQ.ARRAY)
    LOCATE FREQ.COUNT IN FREQ.ARRAY<1> SETTING FREQ ELSE
        FREQ = 1
    END
    FREQ.CODE = INT(12/FREQ)
    FREQ.CODE = 'M':FMT(FREQ.CODE,"2'0'R")
*
    RETURN
*
*************************************************************************
*
DETERMINE.IP:

    IP.FOUND = ''
    NO.OF.SCHEDS = DCOUNT(R$SWAP<SCHED.FIELD>,VM)
    FOR YI = 1 TO NO.OF.SCHEDS
        IF R$SWAP<SCHED.FIELD,YI>[1,2] EQ 'IP' THEN
            FREQ.CODE = R$SWAP<FREQ.FIELD,YI>[9,5]
            IF (FREQ.CODE) AND (FREQ.CODE[1,1] EQ 'M') THEN
                FREQ.CODE = R$SWAP<FREQ.FIELD,YI>[9,5]
                IP.FOUND = 1
                EXIT          ;* this loop
            END ELSE          ;* multiple IPs
                GOSUB DETERMINE.FREQUENCY
                GOSUB SET.IP.FOUND
                EXIT          ;* this loop
            END
        END
    NEXT YI
*
    RETURN
***************************************************************************
SET.IP.FOUND:
*************

    IF FREQ.CODE THEN
        IP.FOUND = 1
    END

    RETURN
****************************************************************************
END
