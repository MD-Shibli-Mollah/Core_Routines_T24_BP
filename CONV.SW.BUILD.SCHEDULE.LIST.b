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
* <Rating>-103</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.BUILD.SCHEDULE.LIST(SCHEDULE.LIST,FILTER.LIST)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.BUILD.SCHEDULE.LIST                                *
* Duplicate of SW.BUILD.SCHEDULE.LIST for conversion purposes.
*
*************************************************************************
*                                                                       *
*  Description :                                                        *
*                                                                       *
*  Routine to build a list of all the schedules for a swap contract.    *
*  Schedules are sorted into ascending effective date and schedule      *
*  order.                                                               *
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
*                                (Amount or interest rate (RR only).    *
*                      Field 7   Schedule narratives.                   *
*                      Field 8   Schedule leg types.                    *
*                      Field 9   Schedule index flags.                  *
*                                                                       *
*  o  FILTER.LIST      Filter list to build the schedules for a specific*
*                      Period or Leg or Schedule Type                   *
*       Format      -  <Build from>.<Build to>.<Leg>.<Schedule type>    *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 24/07/08 - CI_10056908
*            After upgrading from G13207 to R07.003, the SWAP.SHEDULES are built
*            with PROCESS.DATE beyond MATURITY.DATE
*
* 23/09/08 - BG_100020085
*            Rating Reduction for SWAP routines.
*
* 20/07/11 - Defect-243149/Task-248479
*            During conversion the ORIG.SCHED.DATE for activity schedules
*            are written with the Date of the activity itself and not with that of the
*            date of the schedule.
*************************************************************************
*
******************
*  Insert Files.
******************
*
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
*  Note : CALL CONV.SW.DETERMINE.FIELDS to assign swap schedule variables
*         held in common (I_SW.COMMON).
*
    GOSUB INITIALISATION
*
*  Determine leg input
*  Must be one-legged swap if leg currency is not known at this stage
*
    IF Y.PROCESS.LEG <> 'L' THEN        ;* To build only for ASSET LEG
        IF R$SWAP<SW.AS.CURRENCY> THEN
            SCHED.LEG.TYPE = "A"        ;* Asset legs.
            CALL CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
            R$SW.BALANCES = R$SW.ASSET.BALANCES
            LEG.STATUS.FIELD = SW.ASSET.STATUS
            GOSUB BUILD.SCHED.ARRAY
        END
    END
*
    IF Y.PROCESS.LEG <> 'A' THEN        ;* To build only for LIABILITY LEG
        IF R$SWAP<SW.LB.CURRENCY> THEN
            SCHED.LEG.TYPE = "L"        ;* Liability legs.
            CALL CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
            R$SW.BALANCES = R$SW.LIABILITY.BALANCES
            LEG.STATUS.FIELD = SW.LIABILITY.STATUS
            GOSUB BUILD.SCHED.ARRAY
        END
    END
*
* GB9700602
* populate future rate
    IF R$SWAP<SW.REVALUATION.TYPE> AND NOT(SW$.NPV.CALCULATION) THEN
        CALL CONV.SW.CALC.FUTURE.RATE(SCHEDULE.LIST)
    END
*
    RETURN
*
*************************************************************************
*
***************
INITIALISATION:
***************
*
    Y.BUILD.FROM.DATE = '' ; Y.BUILD.TO.DATE = ''
    Y.SCHEDULE.TYPE = '' ; Y.PROCESS.LEG = ''

* To handle filter related build
    IF FILTER.LIST THEN
        Y.BUILD.FROM.DATE = FIELD(FILTER.LIST,'.',1)
        Y.BUILD.TO.DATE = FIELD(FILTER.LIST,'.',2)
        Y.PROCESS.LEG = FIELD(FILTER.LIST,'.',3)
        Y.SCHEDULE.TYPE = FIELD(FILTER.LIST,'.',4)

        IF NOT(Y.BUILD.TO.DATE) THEN
            Y.BUILD.TO.DATE = Y.BUILD.FROM.DATE
        END
    END
*
    R$SW.BALANCES = ""
    SCHED.INDEX = ""
    PROCESS.ONLY.DURING.DEL = ''
    IF SCHEDULE.LIST EQ 'DEL' THEN
        PROCESS.ONLY.DURING.DEL = 1
        SCHEDULE.LIST = ''
    END
    SCHEDULE.LIST = ""
    SCHED.TYPE.ORDER = "CI,PX,IS,IP,AP,RR,PI,NI,PD,ND,PM,RV,CC,RX,CM"
    CONVERT "," TO VM IN SCHED.TYPE.ORDER
*
    Y.BUS.VM = ''
    IF R$SWAP<SW.AS.BUS.CENTRES> AND R$SWAP<SW.LB.BUS.CENTRES> THEN
        Y.BUS.VM = VM
    END
*
    RETURN
*
*************************************************************************
*
*************************************************
*  Build a list of all schedules (both asset    *
*  and liability) and determine their process   *
*  and value dates.                             *
*  The schedules are sorted into ascending      *
*  value date order and schedule type order.    *
*************************************************
*
******************
BUILD.SCHED.ARRAY:
******************
*
    BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
    DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
    PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>
*
    IDX = 0
    LOOP IDX+=1 UNTIL R$SWAP<SWAP$TYPE,IDX> = ""
        *
        SCHEDULE.DATE = R$SWAP<SWAP$DATE.FREQ,IDX>[1,8]
        SCHEDULE.TYPE = R$SWAP<SWAP$TYPE,IDX>[1,2]
        *
        IF RUNNING.UNDER.BATCH AND SCHEDULE.TYPE EQ 'RR' AND SCHEDULE.DATE LT TODAY AND R$SWAP<SWAP$RATE,IDX> = '' THEN
            CONTINUE
        END

        * To handle filter related build
        IF Y.SCHEDULE.TYPE AND Y.SCHEDULE.TYPE <> SCHEDULE.TYPE THEN
            CONTINUE
        END
        IF Y.BUILD.FROM.DATE AND Y.BUILD.FROM.DATE > SCHEDULE.DATE THEN
            CONTINUE
        END
        IF Y.BUILD.TO.DATE AND Y.BUILD.TO.DATE < SCHEDULE.DATE THEN
            CONTINUE
        END

        SCHEDULE.TYPE.FULL = R$SWAP<SWAP$TYPE,IDX>
        SCHED.NARR = R$SWAP<SWAP$NARR,IDX>
        PROCESS.DATE = ""
        ENTRY.DATE = ""
        EFFECTIVE.DATE = ""
        *
        IF SCHEDULE.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN
            BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>
        END ELSE
            BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
        END
        CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
        *
        * When the process date is greater than the maturity date(based on DAY.CONVENTION and DATE.ADJUSTMENT) then
        * ignore these DAY.CONVENTION and DATE.ADJUSTMENT to find out the process date once again.
        * Since contract cant be processed beyond the maturity date(termination date)
        *
        IF PROCESS.DATE GT R$SWAP<SW.MATURITY.DATE> THEN
            Y.MAT.DAY.CONVENTION = "" ;  Y.MAT.PERIOD.ADJUSTMENT = ""
            PROCESS.DATE = "" ; ENTRY.DATE = "" ; EFFECTIVE.DATE = ""
            CALL EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,Y.MAT.DAY.CONVENTION,Y.MAT.PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
        END

        IF SCHEDULE.TYPE EQ "IP" AND R$SWAP<SWAP$INT.SET.DATE,IDX> THEN
            ENTRY.DATE = R$SWAP<SWAP$INT.SET.DATE,IDX>
            PROCESS.DATE = R$SWAP<SWAP$INT.SET.DATE,IDX>
        END

        GOSUB DETERMINE.SCHED.PROCESS.VALUE
        GOSUB ADD.TO.LIST
        *
    REPEAT
*
    IDX = ""
*
    IF PROCESS.ONLY.DURING.DEL THEN
        SW.BAL.SCHD.COUNT = DCOUNT(R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE>,VM)
        FOR I = SW.BAL.SCHD.COUNT TO 1 STEP -1
            PAST.PAYMENT.AMORT.SCHED = 0
            BEGIN CASE
                CASE R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,I> EQ "PX" AND (V$FUNCTION = 'R' OR R$SWAP<SW.RECORD.STATUS>[1,1] EQ 'R') OR R.OLD(1)
                    SCHEDULE.DATE = R$SW.BALANCES<SW.BAL.SCHEDULE.DATE,I>[1,8]
                    SCHEDULE.TYPE = R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,I>[1,2]
                    SCHEDULE.TYPE.FULL = R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,I>
                    PAST.PAYMENT.AMORT.SCHED = 1
                CASE R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,I>[1,2] MATCHES 'PI':VM:'PD':'NI':'ND'
                    SCHEDULE.DATE = R$SW.BALANCES<SW.BAL.SCHEDULE.DATE,I>[1,8]
                    SCHEDULE.TYPE = R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,I>[1,2]
                    SCHEDULE.TYPE.FULL = R$SW.BALANCES<SW.BAL.SCHEDULE.TYPE,I>
                    PAST.PAYMENT.AMORT.SCHED = 1
            END CASE
            GOSUB DETERMINE.BUSINESS.CENTRE
        NEXT I
    END
    IDX = ''
    GOSUB PROCESS.SYS.GEN.SCHEDS
*
    RETURN
*
*************************************************************************
*
*******************************
DETERMINE.BUSINESS.CENTRE:    *
*******************************

    IF PAST.PAYMENT.AMORT.SCHED THEN
        SCHED.NARR = ""
        PROCESS.DATE = ""
        ENTRY.DATE = ""
        EFFECTIVE.DATE = ""
        IF SCHEDULE.TYPE MATCHES 'PX':VM:'PD':VM:'PI' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN
            BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>
        END ELSE
            BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
        END
        CALL CONV.EB.DETERMINE.PROCESS.DATE (SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
        GOSUB DETERMINE.SCHED.PROCESS.VALUE
        IDX = I
        GOSUB ADD.TO.LIST
    END

    RETURN

**************************************************************************
*
*************************************************
*  Determine schedule process values.           *
*  An interest rate is determined for schedule  *
*  type 'RR' and an amount for other schedule   *
*  types.                                       *
*************************************************
*
******************************
DETERMINE.SCHED.PROCESS.VALUE:
******************************
*
    PROCESS.VALUE = ''
*
    BEGIN CASE
            *
        CASE SCHEDULE.TYPE = "PX"
            PROCESS.VALUE = R$SW.BALANCES<SW.BAL.PRINCIPAL,1>
            *
        CASE SCHEDULE.TYPE = "RR"
            PROCESS.VALUE = R$SWAP<SWAP$RATE, IDX>
            IF PROCESS.VALUE EQ '' AND NOT(SW$.NPV.CALCULATION) THEN      ;* CI_10032150 - S
                PROCESS.VALUE = R$SWAP<SWAP$CURRENT.RATE>
                IF R$SWAP<SWAP$SPREAD> THEN
                    PROCESS.VALUE -= R$SWAP<SWAP$SPREAD>
                END
            END
            *
        CASE SCHEDULE.TYPE = "IS"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "AP"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "PI"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "NI"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "PD"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "ND"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "IP"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>  ;* Fixed interest amount only
            *
        CASE SCHEDULE.TYPE = "PM"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "RV"
            PROCESS.VALUE = R$SWAP<SWAP$AMOUNT, IDX>
            *
        CASE SCHEDULE.TYPE = "RX"
            PROCESS.VALUE = R$SW.BALANCES<SW.BAL.PRINCIPAL,1>
            *
    END CASE
*
    RETURN
*
*************************************************************************
*
*************************************************
*  Process system generated schedules.          *
*  Contract Initiation (CI) and Contract        *
*  Maturity (CM).                               *
*************************************************
*
***********************
PROCESS.SYS.GEN.SCHEDS:
***********************
*
    SCHEDULE.TYPE = "CI"
    SCHEDULE.TYPE.FULL = "CI"
*
    IF R$SWAP<LEG.STATUS.FIELD> = "" THEN
        *
        SCHEDULE.DATE = R$SWAP<SWAP$INT.EFFECTIVE>
        SCHED.NARR = R$SWAP<SWAP$NARR,1>
        PROCESS.VALUE = R$SWAP<SWAP$PRINCIPAL>
        PROCESS.DATE = ""
        ENTRY.DATE = ""
        EFFECTIVE.DATE = ""
        *
        IF SCHEDULE.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN
            BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>
        END
        CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
        *
        * When the process date is greater than the maturity date(based on DAY.CONVENTION and DATE.ADJUSTMENT) then
        * ignore these DAY.CONVENTION and DATE.ADJUSTMENT to find out the process date once again.
        * Since contract cant be processed beyond the maturity date(termination date)
        *
        IF PROCESS.DATE GT R$SWAP<SW.MATURITY.DATE> THEN
            Y.MAT.DAY.CONVENTION = "" ;  Y.MAT.PERIOD.ADJUSTMENT = ""
            PROCESS.DATE = "" ; ENTRY.DATE = "" ; EFFECTIVE.DATE = ""
            CALL EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,Y.MAT.DAY.CONVENTION,Y.MAT.PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
        END
        GOSUB ADD.TO.LIST
        *
    END
*
    SCHEDULE.TYPE = "CM"
    SCHEDULE.TYPE.FULL = "CM"
*
    IF R$SWAP<LEG.STATUS.FIELD> = "CUR" THEN
        *
        LOCATE "RX" IN R$SWAP<SWAP$TYPE,1> SETTING RX.IDX ELSE
            RX.IDX = 0
        END
        *
        IF (R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES") OR RX.IDX EQ 0 THEN
            SCHEDULE.DATE = R$SWAP<SW.MATURITY.DATE>
            SCHED.NARR = R$SWAP<SWAP$NARR,1>
            PROCESS.VALUE = R$SW.BALANCES<SW.BAL.PRINCIPAL,1>
            PROCESS.DATE = ""
            ENTRY.DATE = ""
            EFFECTIVE.DATE = ""
            *
            IF SCHEDULE.TYPE MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN
                BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>
            END
            CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
            *
            GOSUB ADD.TO.LIST
            *
        END
        *
    END
*
    RETURN
*
*************************************************************************
*
*************************************************
*  Update schedule list (SCHEDULE.LIST).        *
*************************************************
*
************
ADD.TO.LIST:
************
*
* To handle filter related build
    IF Y.BUILD.TO.DATE THEN
        IF (SCHEDULE.DATE LT Y.BUILD.FROM.DATE) OR (SCHEDULE.DATE GT Y.BUILD.TO.DATE) THEN
            RETURN
        END
    END
*
    LOCATE SCHEDULE.TYPE IN SCHED.TYPE.ORDER<1,1> SETTING TYP.IDX ELSE
        RETURN      ;* ignore invalid schedule type
    END
*
    SORT.KEY = EFFECTIVE.DATE:FMT(TYP.IDX,"2'0'R")
*
    LOCATE SORT.KEY IN SCHED.INDEX<1,1> BY "AR" SETTING POS ELSE
        NULL
    END
*
    INS SORT.KEY BEFORE SCHED.INDEX<1,POS>
*
    INS SCHEDULE.TYPE.FULL BEFORE SCHEDULE.LIST<1,POS>
    INS SCHEDULE.DATE BEFORE SCHEDULE.LIST<2,POS>
    INS ENTRY.DATE BEFORE SCHEDULE.LIST<3,POS>
    INS PROCESS.DATE BEFORE SCHEDULE.LIST<4,POS>
    INS EFFECTIVE.DATE BEFORE SCHEDULE.LIST<5,POS>
    INS PROCESS.VALUE BEFORE SCHEDULE.LIST<6,POS>
    INS SCHED.NARR BEFORE SCHEDULE.LIST<7,POS>
    INS SCHED.LEG.TYPE BEFORE SCHEDULE.LIST<8,POS>
    INS IDX BEFORE SCHEDULE.LIST<9,POS>
    INS SCHEDULE.DATE BEFORE SCHEDULE.LIST<12,POS>

*
    RETURN
*
*************************************************************************
*
*  Physical end of routine.
*
    END
