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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.SW.DETERMINE.END.INT.PERIOD(EARLIEST.DATE)
*
************************************************************************
*                                                                      *
*  Routine     :  CONV.SW.DETERMINE.END.INT.PERIOD                          *
* Duplicate of SW.DETERMINE.END.INT.PERIOD for conversion process.
*                                                                      *
************************************************************************
*                                                                      *
*  Description :  Routine to determine the end date of the next        *
*                 interest period.                                     *
*                                                                      *
*                 The date returned will be either the effective date  *
*                 of the earliest interest payment schedule or the     *
*                 effective date of the maturity/principal re-exchange *
*                 schedule, whichever is the earliest.                 *
*                                                                      *
*                 Returned argument EARLIEST.DATE.                     *
*                                                                      *
************************************************************************
*                                                                      *
*  Modifications :                                                     *
*                                                                      *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*                                                                       *
************************************************************************
*
*  Insert files.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONV.SWAP
    $INSERT I_SW.COMMON
*
************************************************************************
*
*  Determine effective.date of IP/AP and RX schedules.
*
    EARLIEST.DATE = "99999999"          ;* CI_10022510 S/E
    MATURITY.SCHED = 0
    MATURITY.DATE = R$SWAP<SW.MATURITY.DATE>
*
    Y.BUS.VM = ''
    IF R$SWAP<SW.AS.BUS.CENTRES> AND R$SWAP<SW.LB.BUS.CENTRES> THEN
        Y.BUS.VM = VM
    END
*
    IDX = 0
    LOOP IDX+=1 UNTIL R$SWAP<SWAP$TYPE,IDX> = ""
        IF R$SWAP<SWAP$TYPE,IDX>[1,2] MATCHES "IP":VM:"AP" THEN
            GOSUB DETERMINE.EFFECTIVE.DATE
*
* It is possible to have PROCESS.DATE GT EFFECTIVE.DATE
* if 'FOLLOWING' is used.  But when PROCESS.DATE = MATURITY.DATE
* this will cause a problem where the system will not process
* the newly cycled IP schedule.
* If this is the case, change EFFECTIVE.DATE to MATURITY.DATE
* so that the IP schedule will not be cycled.
*
            IF PROCESS.DATE = MATURITY.DATE AND EFFECTIVE.DATE < MATURITY.DATE THEN
                EFFECTIVE.DATE = MATURITY.DATE
            END
*
            IF EFFECTIVE.DATE < EARLIEST.DATE THEN
                EARLIEST.DATE = EFFECTIVE.DATE
            END
        END
*
        IF R$SWAP<SWAP$TYPE,IDX>[1,2] = 'RX' THEN
            GOSUB DETERMINE.EFFECTIVE.DATE
            IF EFFECTIVE.DATE < EARLIEST.DATE THEN
                EARLIEST.DATE = EFFECTIVE.DATE
            END
        END
    REPEAT
*
*  Determine effective.date of maturity schedule.
*
    MATURITY.SCHED = 1
    GOSUB DETERMINE.EFFECTIVE.DATE

    IF EFFECTIVE.DATE < EARLIEST.DATE THEN
        EARLIEST.DATE = EFFECTIVE.DATE
    END
*
    RETURN
*
************************************************************************
*
*************************
DETERMINE.EFFECTIVE.DATE:
*************************
*
    IF NOT(MATURITY.SCHED) THEN
        SCHEDULE.DATE = R$SWAP<SWAP$DATE.FREQ,IDX>[1,8]
    END ELSE
        SCHEDULE.DATE = MATURITY.DATE
    END
*
    BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
    DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
    PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>
    PROCESS.DATE = ""
    ENTRY.DATE = ""
    EFFECTIVE.DATE = ""
*
* CI_10014611-S
    IF R$SWAP<SWAP$TYPE,IDX>[1,2] MATCHES 'PX':VM:'RX':VM:'PD':VM:'PI':VM:'PM' AND R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES" THEN     ;* CI_10016799 S/E
        BUSINESS.CENTRES = R$SWAP<SW.AS.BUS.CENTRES>:Y.BUS.VM:R$SWAP<SW.LB.BUS.CENTRES>   ;* CI_10035793 - S/E
    END
* CI_10014611-E
    CALL CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
*
    RETURN
*
END
