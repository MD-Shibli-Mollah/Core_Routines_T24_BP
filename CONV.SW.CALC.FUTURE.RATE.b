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
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.CALC.FUTURE.RATE(SCHEDULE.LIST)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.CALC.FUTURE.RATE                                   *
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :                                                        *
*                                                                       *
*  Routine to calculate the future rates for all forward 'RR' schedules *
*                                                                       *
*  Arguments returned :                                                 *
*                                                                       *
*  o  SCHEDULE.LIST    Sorted list of all schedules.                    *
*                                                                       *
*     List Format   -  Field 1   Schedule types.                        *
*                      Field 2   Schedule dates.                        *
*                      Field 3   Entry dates of schedules.              *
*                      Field 4   Process dates of schedules.            *
*                      Field 5   Effective dates of schedules.          *
*                      Field 6   Process value of schedules.            *
*                                Amount or interest rate (RR only).     *
*                      Field 7   Schedule narratives.                   *
*                      Field 8   Schedule leg types.                    *
*                      Field 9   Schedule index flags.                  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 23/09/08 - BG_100020085
*            Rating Reduction for SWAP routines.
*
* 30/03/09 - CI_10062021
*            For floating type swap contract FWD.RATE is not taken for
*            calculating Future Cash flows in NPV calculation
*
* 21/09/10 -  Defect 18083 / Task 33157
*             Linear method of NPV revaluation.
*
*************************************************************************
*
******************
*  Insert Files.
******************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MARKET.RATE.TEXT
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_F.SWAP.PARAMETER
    $INSERT I_F.SWAP.REVAL.PARAMETER
    $INSERT I_SW.COMMON
*
*************************************************************************
*
*************
MAIN.PROCESS:
*************
*
    GOSUB INITIALISATION
*
    IDX = 0
    LOOP IDX+=1 UNTIL SCHEDULE.LIST<1,IDX> = ""
*
        SCHEDULE.TYPE = SCHEDULE.LIST<1,IDX>
        SCHEDULE.DATE = SCHEDULE.LIST<2,IDX>
        ENTRY.DATE = SCHEDULE.LIST<3,IDX>
        PROCESS.DATE = SCHEDULE.LIST<4,IDX>
        EFFECTIVE.DATE = SCHEDULE.LIST<5,IDX>
        PROCESS.VALUE = SCHEDULE.LIST<6,IDX>      ;* An amount or rate (RR).
        NARRATIVE = SCHEDULE.LIST<7,IDX>
        SCHED.LEG.TYPE = SCHEDULE.LIST<8,IDX>
        SCHED.IDX = SCHEDULE.LIST<9,IDX>
*
        IF SCHEDULE.TYPE[1,2] MATCHES 'RR':VM:'IP' THEN
            GOSUB PROCESS.SCHEDULE
        END
*
    REPEAT
*
    RETURN
*
*************************************************************************
*
***************
INITIALISATION:
***************
*
    NEXT.END.INT.PERIOD = ''
*
    FN.SWAP.PARAM = 'F.SWAP.PARAMETER'
    F.SWAP.PARAM = ''
    CALL OPF(FN.SWAP.PARAM,F.SWAP.PARAM)
*
    R$SWAP.PARAMETER = ''
    CALL F.READ(FN.SWAP.PARAM,'SYSTEM',R$SWAP.PARAMETER,F.SWAP.PARAM,'')

    R.SWAP.REVAL.PARAMETER = '' ; ER = ''
    CALL CACHE.READ('F.SWAP.REVAL.PARAMETER','SYSTEM',R.SWAP.REVAL.PARAMETER,ER)
*
    RETURN
*
*************************************************************************
*
*****************
PROCESS.SCHEDULE:
*****************
*
* determine future rate if 'RR'
* determine next end.int.period if 'IP'
*
    CALL CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
    IF SCHED.LEG.TYPE = 'A' THEN
        R$SW.BALANCES = R$SW.ASSET.BALANCES
        SHORT.PERIOD.RATE.FIELD = SW.REVAL.PARAM.AS.SHORT.PER.RATE
        LONG.PERIOD.RATE.FIELD = SW.REVAL.PARAM.AS.LONG.PER.RATE
    END ELSE
        R$SW.BALANCES = R$SW.LIABILITY.BALANCES
        SHORT.PERIOD.RATE.FIELD = SW.REVAL.PARAM.LB.SHORT.PER.RATE
        LONG.PERIOD.RATE.FIELD = SW.REVAL.PARAM.LB.LONG.PER.RATE
    END
*
    BEGIN CASE
*
    CASE SCHEDULE.TYPE[1,2] = "RR"
        IF PROCESS.VALUE = "" THEN
            GOSUB GET.FUTURE.RATE
            SCHEDULE.LIST<6,IDX> = FWD.RATE
        END
*
    CASE SCHEDULE.TYPE[1,2] = "IP"
*
* determine next end int period
*
        SWAP.SAVE = R$SWAP
        SCHED.DATE.FREQ = R$SWAP<SWAP$DATE.FREQ,SCHED.IDX>
        IF SCHED.DATE.FREQ[9,5] THEN
            GOSUB SCHED.DATE.FREQ
        END ELSE    ;* IP WITHOUT FREQUENCY
            FOR YI = SWAP$TYPE TO SWAP$PROCESSED
                DEL R$SWAP<YI, SCHED.IDX>
            NEXT YI
        END
        CALL CONV.SW.DETERMINE.END.INT.PERIOD(NEXT.END.INT.PERIOD)
        R$SWAP = SWAP.SAVE
    END CASE
*
    RETURN
*
*************************************************************************
*
*****************
SCHED.DATE.FREQ:
*****************

    IF R$SW.BALANCES<SW.BAL.END.INT.PERIOD> < R$SWAP<SW.MATURITY.DATE> THEN
        COMI = SCHED.DATE.FREQ
        CALL CFQ
        IF COMI[1,8] > R$SWAP<SW.MATURITY.DATE> THEN
            COMI[1,8] = R$SWAP<SW.MATURITY.DATE>
        END
        R$SWAP<SWAP$DATE.FREQ,SCHED.IDX> = COMI
    END

    RETURN
**************************************************************************
****************
GET.FUTURE.RATE:
****************
*
    RATE.KEY = ""
    FWD.ARR = ''
    IF R$SWAP<SWAP$RATE.KEY> THEN
        CALL DBR("MARKET.RATE.TEXT":FM:EB.MRT.RATE.KEY,R$SWAP<SWAP$RATE.KEY>,RATE.KEY)
        IF ETEXT THEN
            GOSUB FATAL.ERROR
        END
*
        INT.BASIS = R$SWAP<SWAP$BASIS>
        CCY = R$SW.BALANCES<SW.BAL.CURRENCY>
        SHORT.PERIOD.RATE.IND = R.SWAP.REVAL.PARAMETER<SHORT.PERIOD.RATE.FIELD>[1,1]
        LONG.PERIOD.RATE.IND = R.SWAP.REVAL.PARAMETER<LONG.PERIOD.RATE.FIELD>[1,1]
*
* determine interest period
*
        START.INT.PERIOD = R$SW.BALANCES<SW.BAL.START.INT.PERIOD>
        END.INT.PERIOD = R$SW.BALANCES<SW.BAL.END.INT.PERIOD>
        IF EFFECTIVE.DATE > START.INT.PERIOD THEN ;* next interest period
            START.INT.PERIOD = END.INT.PERIOD
            END.INT.PERIOD = NEXT.END.INT.PERIOD
        END
    END
*
    FWD.RATE = ""
    IF RATE.KEY AND EFFECTIVE.DATE >= START.INT.PERIOD AND EFFECTIVE.DATE < END.INT.PERIOD THEN
        CALL EB.FUTURE.RATE(START.INT.PERIOD,
        END.INT.PERIOD,
        SHORT.PERIOD.RATE.IND,
        LONG.PERIOD.RATE.IND,
        RATE.KEY,
        INT.BASIS,
        CCY,
        FWD.RATE,
        FWD.ARR)
    END
*
    RETURN
*
*************************************************************************
*
************
FATAL.ERROR:
************
*
    TEXT = ETEXT
    CALL FATAL.ERROR("SW.CALC.FUTURE.RATE")
*
    RETURN
*
*************************************************************************
*
END
