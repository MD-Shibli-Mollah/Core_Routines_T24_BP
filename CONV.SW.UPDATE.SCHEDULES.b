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

* Version 1.0 30/05/05 - GLOBUS Release No. 200507 01/06/05
*-----------------------------------------------------------------------------
* <Rating>-143</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.UPDATE.SCHEDULES(SCHEDULE.LIST,COMP.MNEMONIC,SAVE.FLAG)
*
******************************************************************
* This conversion is used to WRITE SWAP.SCHEDULES/SWAP.SCHEDULES.SAVE record for all the
* existing SWAP contracts. Called from CONV.SW.CREATE.SCHEDULE.200507.
*----------------------------------------------------------------------------
* ARGUMENTS IN:
*           SCHEDULE.LIST - Sorted list of all swap schedules
*           COMP.MNEMONIC - Mnemonic of the company for which the conversion
*                           is currently running
*           SAVE.FLAG     - 0 or 1
*                        0 - WRITE the Schedules record in SWAP.SCHEDULES file
*                        1 - WRITE the Schedules record in SWAP.SCHEDULES.SAVE file
*----------------------------------------------------------------------------
* Modification History:
*
* 02/06/05 - BG_100008848
*            Creation of the Routine
*
* 18/07/05 - CI_10032414
*            RUN.CONVERSION.PGMS is hanging in the cut of 200508 build
*
* 20/07/05 - CI_10032504
*            Revert back the changes done under CI_10032414
*
* 24/07/08 - CI_10056908
*            After upgrading from G13207 to R07.003, the SWAP.SHEDULES are built
*            with PROCESS.DATE beyond MATURITY.DATE
*
* 08/09/08 - BG_100019835
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
    RETURN
*
***********
INITIALISE:
***********
    FN.SWAP.SCHEDULES.SAVE = COMP.MNEMONIC:'SWAP.SCHEDULES.SAVE' ; F.SWAP.SCHEDULES.SAVE = ''
    OPEN FN.SWAP.SCHEDULES.SAVE TO F.SWAP.SCHEDULES.SAVE ELSE
        F.SWAP.SCHEDULES.SAVE = ''
    END

    BUSINESS.CENTRES = R$SWAP<SWAP$BUS.CENTRES>
    DAY.CONVENTION = R$SWAP<SWAP$DAY.CONVENTION>
    PERIOD.ADJUSTMENT = R$SWAP<SWAP$DATE.ADJUSTMENT>
    RETURN
*
**********************
DELETE.SWAP.SCHEDULES:
**********************
    SEL.CMD = '' ; KEY.LIST = '' ; NO.SEL = 0 ; POS = ''
    IF SAVE.FLAG THEN
        SEL.CMD = 'SSELECT ':FN.SWAP.SCHEDULES.SAVE: ' WITH @ID LIKE ':ID.NEW:'...'
        CALL EB.READLIST(SEL.CMD, KEY.LIST, '', NO.SEL, '')
        LOOP
            REMOVE Y.SW.SCHED.ID FROM KEY.LIST SETTING POS
        WHILE Y.SW.SCHED.ID:POS
            DELETE F.SWAP.SCHEDULES.SAVE,Y.SW.SCHED.ID
        REPEAT
    END ELSE
        SEL.CMD = 'SSELECT ':FN.SWAP.SCHEDULES: ' WITH @ID LIKE ':ID.NEW:'...'
        CALL EB.READLIST(SEL.CMD, KEY.LIST, '', NO.SEL, '')
        LOOP
            REMOVE Y.SW.SCHED.ID FROM KEY.LIST SETTING POS
        WHILE Y.SW.SCHED.ID:POS
            DELETE F.SWAP.SCHEDULES,Y.SW.SCHED.ID
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
            IF Y.SCHED.DATE LT TODAY THEN
                CONTINUE
            END
*
            GOSUB GENERATE.SCH.RECORDS
*
        END
    NEXT I
    RETURN
*
**********************
GENERATE.SCH.RECORDS:
**********************
*
    Y.ENTRY.DATE = SCHEDULE.LIST<3,I>
    Y.PROCESS.DATE = SCHEDULE.LIST<4,I>
    Y.EFFECTIVE.DATE = SCHEDULE.LIST<5,I>
    Y.PROCESS.VALUE = SCHEDULE.LIST<6,I>
    Y.NARRATIVE = SCHEDULE.LIST<7,I>
    Y.SCHED.LEG.TYPE = SCHEDULE.LIST<8,I>

* Get the Net RX amount from Full Balances record which is available
* in common variable(assigned in SW.SCHEDULE.PROCESSING).
    GOSUB GET.NET.RX
    Y.ACTIVITY.CODE = SCHEDULE.LIST<10,I>
    Y.ACTIVITY.DATE = SCHEDULE.LIST<11,I>

* To skip the PI/PD schedules for IRS contracts
    Y.PROCESS.MSG = 1
    IF Y.ACTIVITY.DATE AND NOT(Y.ACTIVITY.CODE) THEN
        Y.PROCESS.MSG = 0
        Y.ACTIVITY.CODE = ''
        Y.ACTIVITY.DATE = ''
    END

    Y.SWAP.SCHEDULE.ID = ID.NEW:".":Y.SCHED.DATE
    IF (Y.ACTIVITY.DATE <> Y.SCHED.DATE) AND Y.PROCESS.MSG THEN
        Y.SWAP.SCHEDULE.ID.TMP = ID.NEW:".":Y.ACTIVITY.DATE
        Y.ACTIVITY.CODE = ''
        Y.ACTIVITY.DATE = ''
    END
    GOSUB CREATE.SCHEDULE.REC

    IF Y.SWAP.SCHEDULE.ID.TMP THEN      ;* To handle Message related Schedule
        Y.SWAP.SCHEDULE.ID = Y.SWAP.SCHEDULE.ID.TMP
        Y.ACTIVITY.CODE = SCHEDULE.LIST<10,I>
        Y.ACTIVITY.DATE = SCHEDULE.LIST<11,I>
        IF Y.ACTIVITY.DATE GE TODAY THEN
            GOSUB CREATE.SCHEDULE.REC
        END
    END
*
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
            IF SAVE.FLAG THEN
                WRITE SWAP.SCHEDULES.REC ON F.SWAP.SCHEDULES.SAVE, Y.SWAP.SCHEDULE.ID
            END ELSE
                WRITE SWAP.SCHEDULES.REC ON F.SWAP.SCHEDULES, Y.SWAP.SCHEDULE.ID
            END
        END
    NEXT I
    RETURN
*
***********
GET.NET.RX:
***********
    IF Y.SCHED.TYPE[1,2] EQ 'RX' THEN
        IF Y.SCHED.LEG.TYPE EQ 'A' THEN
            Y.PROCESS.VALUE = Y.FULL.AS.BALANCES<SW.BAL.PRINCIPAL,1>
        END ELSE
            Y.PROCESS.VALUE = Y.FULL.LB.BALANCES<SW.BAL.PRINCIPAL,1>
        END
    END
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
        CALL EB.DETERMINE.PROCESS.DATE(Y.SCHED.DATE,BUSINESS.CENTRES,DAY.CONVENTION,PERIOD.ADJUSTMENT,Y.PROCESS.DATE,Y.ENTRY.DATE,Y.EFFECTIVE.DATE)

* When the process date is greater than the maturity date(based on DAY.CONVENTION and DATE.ADJUSTMENT) then
* ignore these DAY.CONVENTION and DATE.ADJUSTMENT to find out the process date once again.
* Since contract cant be processed beyond the maturity date(termination date)
*
        IF Y.PROCESS.DATE GT R$SWAP<SW.MATURITY.DATE> THEN
            Y.MAT.DAY.CONVENTION = "" ;  Y.MAT.PERIOD.ADJUSTMENT = ""
            Y.PROCESS.DATE = "" ; Y.ENTRY.DATE = "" ; Y.EFFECTIVE.DATE = ""
            CALL CONV.EB.DETERMINE.PROCESS.DATE(Y.SCHED.DATE,BUSINESS.CENTRES,Y.MAT.DAY.CONVENTION,Y.MAT.PERIOD.ADJUSTMENT,Y.PROCESS.DATE,Y.ENTRY.DATE,Y.EFFECTIVE.DATE)
        END
        Y.SWAP.SCHEDULE.ID = ID.NEW:".":Y.SCHED.DATE

        GOSUB CREATE.SCHEDULE.REC
        GOSUB WRITE.SWAP.SCHEDULES
    END
    RETURN
END
