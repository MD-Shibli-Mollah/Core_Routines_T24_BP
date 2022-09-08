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
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.SW.DETERMINE.FIELDS(SCHED.LEG.TYPE)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.DETERMINE.FIELDS                                   *
* Duplicate of SW.DETERMINE.FIELDS.
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :  Assign Swap schedule variables held in common         *
*                 (I_SW.COMMON).                                        *
*                                                                       *
*                 Supplied arguments :                                  *
*                                                                       *
*                 o SCHED.LEG.TYPE   Schedule leg type.                 *
*                                    'A'sset or 'L'iability.            *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SW.COMMON
    $INSERT I_F.CONV.SWAP
*
    IF SCHED.LEG.TYPE = "A" THEN
        OFFSET = 0
        GOSUB ASSIGN.FIELDS
    END ELSE
        OFFSET = SW.LB.CURRENCY - SW.AS.CURRENCY
        GOSUB ASSIGN.FIELDS
    END
*
    RETURN
*
**************
ASSIGN.FIELDS:
**************
*
    SWAP$CURRENCY = SW.AS.CURRENCY + OFFSET
    SWAP$PRINCIPAL = SW.AS.PRINCIPAL + OFFSET
    SWAP$INT.EFFECTIVE = SW.AS.INT.EFFECTIVE + OFFSET
    SWAP$FIXED.RATE = SW.AS.FIXED.RATE + OFFSET
    SWAP$TRSY.FIXED.RATE = SW.AS.TRSY.FIXED.RATE + OFFSET   ;* EN_10002630 S/E
    SWAP$RATE.KEY = SW.AS.RATE.KEY + OFFSET
    SWAP$SPREAD = SW.AS.SPREAD + OFFSET
    SWAP$CAP.RATE = SW.AS.CAP.RATE + OFFSET
    SWAP$FLOOR.RATE = SW.AS.FLOOR.RATE + OFFSET
    SWAP$OPTION.DATE = SW.AS.OPTION.DATE + OFFSET
    SWAP$OPTION.NOTICE = SW.AS.OPTION.NOTICE + OFFSET
    SWAP$CURRENT.RATE = SW.AS.CURRENT.RATE + OFFSET
    SWAP$CUR.TRSRY.RATE = SW.AS.CUR.TRSRY.RATE + OFFSET     ;* EN_10002630 S/E
    SWAP$FIXED.INTEREST = SW.AS.FIXED.INTEREST + OFFSET
    SWAP$BASIS = SW.AS.BASIS + OFFSET
    SWAP$DAY.CONVENTION = SW.AS.DAY.CONVENTION + OFFSET
    SWAP$DATE.ADJUSTMENT = SW.AS.DATE.ADJUSTMENT + OFFSET
    SWAP$BUS.CENTRES = SW.AS.BUS.CENTRES + OFFSET
    SWAP$TYPE = SW.AS.TYPE + OFFSET
    SWAP$DATE.FREQ = SW.AS.DATE.FREQ + OFFSET
    SWAP$INT.SET.DATE = SW.AS.INT.SET.DATE + OFFSET
    SWAP$FINAL.SCHED = SW.AS.FINAL.SCHED + OFFSET
    SWAP$AMOUNT = SW.AS.AMOUNT + OFFSET
    SWAP$RATE = SW.AS.RATE + OFFSET
    SWAP$TRSRY.RATE = SW.AS.TRSRY.RATE + OFFSET   ;* EN_10002630 S/E
    SWAP$AMORT.DATE = SW.AS.AMORT.DATE + OFFSET
    SWAP$NARR = SW.AS.NARR + OFFSET
    SWAP$ADVICE.SENT = SW.AS.ADVICE.SENT + OFFSET
    SWAP$PROCESSED = SW.AS.PROCESSED + OFFSET
*
    RETURN
*
END
