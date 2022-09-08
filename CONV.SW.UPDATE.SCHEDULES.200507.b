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
* <Rating>-157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.UPDATE.SCHEDULES.200507(SCHEDULE.LIST,DEL.FLAG)
******************************************************************
* This routine is used to Create/Update SWAP.SCHEDULES file
* Duplicate of SW.UPDATE.SCHEDULES.
*----------------------------------------------------------------------------
* ARGUMENTS IN:
*           SCHEDULE.LIST - Sorted list of all swap schedules
*           DEL.FLAG   - 0 or 1
*                        0 - Update SWAP.SCHEDULES without deleting the existing record
*                        1 - Delete and Create a new record with the SCHEDULE.LIST
*----------------------------------------------------------------------------
* Modification History:
*
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 22/09/08 - BG_100019970
*            Rating Reduction
*
* 06/11/08 - CI_10058722
*            Swap schedules built wrongly while upgrading from G13 to R06
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SW.COMMON
    $INSERT I_F.SWAP
    $INSERT I_F.SWAP.SCHEDULES
    $INSERT I_F.SWAP.BALANCES
*
    GOSUB INITIALISE
    GOSUB DELETE.SWAP.SCHEDULES
    GOSUB BUILD.SCHEDULE
    GOSUB WRITE.SWAP.SCHEDULES

    IF DEL.FLAG THEN
        GOSUB CLEAR.SCHEDULE.FIELDS
        Y.SCHED.LEG.TYPE = "A"
        LEG.STATUS.FIELD = SW.ASSET.STATUS
* Get the Net CM amount from Full Asset Balances record which is available
* in common variable(assigned in SW.SCHEDULE.PROCESSING).
        Y.PROCESS.VALUE = Y.FULL.AS.BALANCES<SW.BAL.PRINCIPAL,1>
        GOSUB PROCESS.SYS.GEN.SCHEDS

        GOSUB CLEAR.SCHEDULE.FIELDS
        Y.SCHED.LEG.TYPE = "L"
        LEG.STATUS.FIELD = SW.LIABILITY.STATUS
* Get the Net CM amount from Full Liability Balances record which is available
* in common variable(assigned in SW.SCHEDULE.PROCESSING).
        Y.PROCESS.VALUE = Y.FULL.LB.BALANCES<SW.BAL.PRINCIPAL,1>
        GOSUB PROCESS.SYS.GEN.SCHEDS
    END
    RETURN
*
***********
INITIALISE:
***********
    BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
    DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
    PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>

    EOD.SCHEDULES = 'IP,AP,RX,CM'       ;* BG_100008719 - S
    CONVERT ',' TO VM IN EOD.SCHEDULES  ;* BG_100008719 - E
    RETURN
*
**********************
DELETE.SWAP.SCHEDULES:
**********************
    IF DEL.FLAG THEN
        SEL.CMD = '' ; KEY.LIST = '' ; NO.SEL = 0 ; POS = ''
        SEL.CMD = 'SSELECT ':FN.SWAP.SCHEDULES: ' WITH @ID LIKE ':ID.NEW:'...'
        CALL EB.READLIST(SEL.CMD, KEY.LIST, '', NO.SEL, '')
        LOOP
            REMOVE Y.SW.SCHED.ID FROM KEY.LIST SETTING POS
        WHILE Y.SW.SCHED.ID:POS
            CALL F.DELETE("F.SWAP.SCHEDULES",Y.SW.SCHED.ID)
        REPEAT
    END
    RETURN
*
***************
BUILD.SCHEDULE:
***************
    Y.SCHED.COUNT = 0 ; Y.SW.SCHED.REC.TMP = ''
    Y.SCHED.COUNT = DCOUNT(SCHEDULE.LIST<1>,VM)
    FOR I = 1 TO Y.SCHED.COUNT
        GOSUB CLEAR.SCHEDULE.FIELDS
        Y.SCHED.TYPE = SCHEDULE.LIST<1,I>
        IF Y.SCHED.TYPE NE 'CM' THEN
            Y.SCHED.DATE = SCHEDULE.LIST<2,I>
            IF NOT(Y.SCHED.TYPE MATCHES EOD.SCHEDULES) AND (Y.SCHED.DATE LE TODAY) THEN   ;* BG_100008719 S/E
                CONTINUE
            END
            Y.ENTRY.DATE = SCHEDULE.LIST<3,I>
            Y.PROCESS.DATE = SCHEDULE.LIST<4,I>
            Y.EFFECTIVE.DATE = SCHEDULE.LIST<5,I>
            Y.PROCESS.VALUE = SCHEDULE.LIST<6,I>
            Y.NARRATIVE = SCHEDULE.LIST<7,I>
            Y.SCHED.LEG.TYPE = SCHEDULE.LIST<8,I>

* Get the Net RX amount from Full Balances record which is available
* in common variable(assigned in SW.SCHEDULE.PROCESSING).
            GOSUB CHECK.SCH.TYPE.RX
            GOSUB CHECK.SCH.TYPE.EOD.SCH

            Y.ACTIVITY.CODE = SCHEDULE.LIST<10,I>
            Y.ACTIVITY.DATE = SCHEDULE.LIST<11,I>

* To skip the PI/PD schedules for IRS contracts
            Y.PROCESS.MSG = 1 ;* BG_100008719 - S
            IF Y.ACTIVITY.DATE AND NOT(Y.ACTIVITY.CODE) THEN
                Y.PROCESS.MSG = 0
                Y.ACTIVITY.CODE = ''
                Y.ACTIVITY.DATE = ''
            END     ;* BG_100008719 - E

            Y.SWAP.SCHEDULE.ID = ID.NEW:".":Y.SCHED.DATE
            IF (Y.ACTIVITY.DATE <> Y.SCHED.DATE) AND Y.PROCESS.MSG THEN
                Y.SWAP.SCHEDULE.ID.TMP = ID.NEW:".":Y.ACTIVITY.DATE
                Y.ACTIVITY.CODE = ''
                Y.ACTIVITY.DATE = ''
            END
            GOSUB CREATE.SCHEDULE.REC
            GOSUB HANDLE.MSG.SCHEDULE   ;* To handle Message related Schedule
        END
    NEXT I
    RETURN
*
**********************
CLEAR.SCHEDULE.FIELDS:
**********************
    Y.SCHED.TYPE = ''
    Y.SCHED.DATE = ''
    Y.ENTRY.DATE = ''
    Y.PROCESS.DATE = ''
    Y.EFFECTIVE.DATE = ''
    Y.PROCESS.VALUE = ''
    Y.NARRATIVE = ''
    Y.SCHED.LEG.TYPE = ''
    Y.ACTIVITY.CODE = ''
    Y.ACTIVITY.DATE = ''
    Y.SWAP.SCHEDULE.ID.TMP = ''
    RETURN
*
********************
CREATE.SCHEDULE.REC:
********************
    Y.FIELD.POSN = 0 ; Y.VALUE.POSN = 0
    FIND Y.SWAP.SCHEDULE.ID IN Y.SW.SCHED.REC.TMP SETTING Y.FIELD.POSN, Y.VALUE.POSN THEN
        INS Y.SCHED.TYPE:',':Y.ENTRY.DATE:',':Y.PROCESS.DATE:',':Y.EFFECTIVE.DATE:',':Y.PROCESS.VALUE:',':Y.NARRATIVE:',':Y.SCHED.LEG.TYPE:',':Y.ACTIVITY.CODE:',':Y.ACTIVITY.DATE BEFORE Y.SW.SCHED.REC.TMP<Y.FIELD.POSN,2>
    END ELSE
        IF Y.SW.SCHED.REC.TMP THEN
            Y.SW.SCHED.REC.TMP = Y.SW.SCHED.REC.TMP:FM:Y.SWAP.SCHEDULE.ID:VM:Y.SCHED.TYPE:',':Y.ENTRY.DATE:',':Y.PROCESS.DATE:',':Y.EFFECTIVE.DATE:',':Y.PROCESS.VALUE:',':Y.NARRATIVE:',':Y.SCHED.LEG.TYPE:',':Y.ACTIVITY.CODE:',':Y.ACTIVITY.DATE
        END ELSE
            Y.SW.SCHED.REC.TMP = Y.SWAP.SCHEDULE.ID:VM:Y.SCHED.TYPE:',':Y.ENTRY.DATE:',':Y.PROCESS.DATE:',':Y.EFFECTIVE.DATE:',':Y.PROCESS.VALUE:',':Y.NARRATIVE:',':Y.SCHED.LEG.TYPE:',':Y.ACTIVITY.CODE:',':Y.ACTIVITY.DATE
        END
    END
    RETURN
*
*********************
WRITE.SWAP.SCHEDULES:
*********************
    Y.SCHED.COUNT = 0
    Y.SCHED.COUNT = DCOUNT(Y.SW.SCHED.REC.TMP,FM)
    FOR I = 1 TO Y.SCHED.COUNT
        Y.SW.SCHED.ID.LIST = '' ; Y.SWAP.SCHEDULE.ID = ''
        Y.SW.SCHED.ID.LIST = Y.SW.SCHED.REC.TMP<I>
        Y.SWAP.SCHEDULE.ID = Y.SW.SCHED.ID.LIST<1,1>
        DEL Y.SW.SCHED.ID.LIST<1,1>
        IF Y.SW.SCHED.ID.LIST THEN
            GOSUB REBUILD.SCHEDULES.REC
            IF NOT(DEL.FLAG) THEN
                GOSUB READ.SWAP.SCHEDULES
            END
            CALL F.WRITE("F.SWAP.SCHEDULES",Y.SWAP.SCHEDULE.ID,SWAP.SCHEDULES.REC)
        END
    NEXT I
    RETURN
*
**********************
REBUILD.SCHEDULES.REC:
**********************
    Y.REC.TMP = '' ; SWAP.SCHEDULES.REC = ''
    Y.REC.COUNT = DCOUNT(Y.SW.SCHED.ID.LIST,VM)
    FOR J = 1 TO Y.REC.COUNT
        Y.REC.TMP = Y.SW.SCHED.ID.LIST<1,J>
        CONVERT "," TO VM IN Y.REC.TMP

        SWAP.SCHEDULES.REC<SW.SCHED.TYPE,-1> = Y.REC.TMP<1,1>
        SWAP.SCHEDULES.REC<SW.SCHED.ENTRY.DATE,-1> = Y.REC.TMP<1,2>
        SWAP.SCHEDULES.REC<SW.SCHED.PROCESS.DATE,-1> = Y.REC.TMP<1,3>
        SWAP.SCHEDULES.REC<SW.SCHED.EFFECTIVE.DATE,-1> = Y.REC.TMP<1,4>
        INS Y.REC.TMP<1,5> BEFORE SWAP.SCHEDULES.REC<SW.SCHED.PROCESS.VALUE,J>
        SWAP.SCHEDULES.REC<SW.SCHED.NARRATIVE,-1> = Y.REC.TMP<1,6>
        SWAP.SCHEDULES.REC<SW.SCHED.LEG.TYPE,-1> = Y.REC.TMP<1,7>
        INS Y.REC.TMP<1,8> BEFORE SWAP.SCHEDULES.REC<SW.SCHED.ACTIVITY.CODE,J>
        INS Y.REC.TMP<1,9> BEFORE SWAP.SCHEDULES.REC<SW.SCHED.ACTIVITY.DATE,J>
    NEXT J
    RETURN
*
********************
READ.SWAP.SCHEDULES:
********************
    IDX = 0
    CALL F.READ("F.SWAP.SCHEDULES",Y.SWAP.SCHEDULE.ID,R.SW.SCHEDULES,F.SWAP.SCHEDULES,"")
    IF R.SW.SCHEDULES THEN
        LOOP
            IDX += 1
        UNTIL SWAP.SCHEDULES.REC<1,IDX> = '' DO
            R.SW.SCHEDULES<SW.SCHED.TYPE,-1> = SWAP.SCHEDULES.REC<1,IDX>
            R.SW.SCHEDULES<SW.SCHED.ENTRY.DATE,-1> = SWAP.SCHEDULES.REC<2,IDX>
            R.SW.SCHEDULES<SW.SCHED.PROCESS.DATE,-1> = SWAP.SCHEDULES.REC<3,IDX>
            R.SW.SCHEDULES<SW.SCHED.EFFECTIVE.DATE,-1> = SWAP.SCHEDULES.REC<4,IDX>
            R.SW.SCHEDULES<SW.SCHED.PROCESS.VALUE,-1> = SWAP.SCHEDULES.REC<5,IDX>
            R.SW.SCHEDULES<SW.SCHED.NARRATIVE,-1> = SWAP.SCHEDULES.REC<6,IDX>
            R.SW.SCHEDULES<SW.SCHED.LEG.TYPE,-1> = SWAP.SCHEDULES.REC<7,IDX>
            R.SW.SCHEDULES<SW.SCHED.ACTIVITY.CODE,-1> = SWAP.SCHEDULES.REC<8,IDX>
            R.SW.SCHEDULES<SW.SCHED.ACTIVITY.DATE,-1> = SWAP.SCHEDULES.REC<9,IDX>
        REPEAT
        SWAP.SCHEDULES.REC = R.SW.SCHEDULES
    END
    RETURN
*
***********************
PROCESS.SYS.GEN.SCHEDS:
***********************
    Y.SWAP.SCHEDULE.ID = '' ; Y.SCHED.TYPE = "CM"
    LOCATE "RX" IN R$SWAP<SWAP$TYPE,1> SETTING RX.IDX ELSE
        RX.IDX = 0
    END
    IF (R$SWAP<SW.FLEX.PRIN.PAYMENT> EQ "YES") OR RX.IDX EQ 0 THEN
        Y.SCHED.DATE = R$SWAP<SW.MATURITY.DATE>
        Y.NARRATIVE = R$SWAP<SWAP$NARR,1>
        CALL CONV.EB.DETERMINE.PROCESS.DATE(Y.SCHED.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,Y.PROCESS.DATE,Y.ENTRY.DATE,Y.EFFECTIVE.DATE)
        Y.SWAP.SCHEDULE.ID = ID.NEW:".":Y.SCHED.DATE

        GOSUB CREATE.SCHEDULE.REC
        GOSUB WRITE.SWAP.SCHEDULES
    END
    RETURN
*
***********************
GET.EFF.DATE:
***********************
* Only called for MKT EXCH Scenarios and when Effective date falls in between an IP.
* Change the Y.EFF.DATE to the start.int.per for that period, so that this will get
* reflected in SWAP.SCHEDULES.


    TOT.CNT = DCOUNT(ST.INT.PER,VM)
    FOR MV.CNT = 1 TO TOT.CNT
        IF SCH.PER<1,MV.CNT> = "IP" THEN
            IF ( Y.EFFECTIVE.DATE GE ST.INT.PER<1,MV.CNT> AND Y.EFFECTIVE.DATE LT END.INT.PER<1,MV.CNT>) THEN
                Y.EFFECTIVE.DATE = ST.INT.PER<1,MV.CNT>
                EXIT
            END
        END
    NEXT MV.CNT


    RETURN
*
***********************
CHECK.SCH.TYPE.RX:
***********************
    IF Y.SCHED.TYPE EQ 'RX' THEN
        IF Y.SCHED.LEG.TYPE EQ 'A' THEN
            Y.PROCESS.VALUE = Y.FULL.AS.BALANCES<SW.BAL.PRINCIPAL,1>
        END ELSE
            Y.PROCESS.VALUE = Y.FULL.LB.BALANCES<SW.BAL.PRINCIPAL,1>
        END
    END

    RETURN
*
***********************
CHECK.SCH.TYPE.EOD.SCH:
***********************

    IF NOT(Y.SCHED.TYPE MATCHES EOD.SCHEDULES) THEN
        IF Y.SCHED.LEG.TYPE EQ 'A' THEN
            IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SW.AS.FIXED.RATE> THEN
                SCH.PER = Y.FULL.AS.BALANCES<SW.BAL.SCHEDULE.TYPE>
                ST.INT.PER = Y.FULL.AS.BALANCES<SW.BAL.PERIOD.START>
                END.INT.PER = Y.FULL.AS.BALANCES<SW.BAL.PERIOD.END>

                GOSUB GET.EFF.DATE
            END
        END ELSE
            IF R$SWAP<SW.TREASURY.CUSTOMER> AND R$SWAP<SW.LB.FIXED.RATE> THEN
                SCH.PER = Y.FULL.LB.BALANCES<SW.BAL.SCHEDULE.TYPE>
                ST.INT.PER = Y.FULL.LB.BALANCES<SW.BAL.PERIOD.START>
                END.INT.PER = Y.FULL.LB.BALANCES<SW.BAL.PERIOD.END>
                GOSUB GET.EFF.DATE
            END
        END
    END

    RETURN
*
************************
HANDLE.MSG.SCHEDULE:
************************

    IF Y.SWAP.SCHEDULE.ID.TMP THEN
        Y.SWAP.SCHEDULE.ID = Y.SWAP.SCHEDULE.ID.TMP
        Y.ACTIVITY.CODE = SCHEDULE.LIST<10,I>
        Y.ACTIVITY.DATE = SCHEDULE.LIST<11,I>
        IF Y.ACTIVITY.DATE GE TODAY THEN
            GOSUB CREATE.SCHEDULE.REC
        END
    END

    RETURN
*
END
