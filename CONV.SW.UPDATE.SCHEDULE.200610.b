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

* Version 1.0 25/05/05 - GLOBUS Release No. 200507 01/06/05
*-----------------------------------------------------------------------------
* <Rating>52</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.UPDATE.SCHEDULE.200610(SWAP.ID, SWAP.REC, LOC.FN.SWAP)
*
******************************************************************************
* This conversion is used to update SWAP.SCHEDULES field ORIG.SCHED.DATE.
* for existing SWAP contracts.
******************************************************************************
* MODIFICATIONS:
****************
*
* 24/08/06 - EN_10002968
*            Day conversion & adjustment not working in Swap.
*
* 08/09/08 - BG_100019835
*            Rating Reduction
*
* 20/07/11 - Defect-243149/Task-248479
*            During conversion the ORIG.SCHED.DATE for activity schedules
*            are written with the Date of the activity itself and not with that of the
*            date of the schedule.
*
* 08/06/15 - Defect 1360481/Task 1370643
*		     Compilation errors since FN.SWAP used both as local and common variable.
******************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.SWAP
    $INSERT I_SW.COMMON
*
    GOSUB CHECK.FILE.TYPE
    IF Y.PROCESS.FLAG THEN
        GOSUB INITIALISATION
        GOSUB CHECK.LIVE.INAU.EXISTS
        GOSUB UPDATE.SWAP.SCHEDULES
    END
    RETURN
*
****************
CHECK.FILE.TYPE:
****************
    Y.PROCESS.FLAG = 1 ; Y.LIVE.RECORD = 1
    Y.FILE.TYPE = RIGHT(LOC.FN.SWAP,4)      ;* To get the File type

    BEGIN CASE
        CASE Y.FILE.TYPE EQ '$HIS' OR Y.FILE.TYPE EQ '$ARC'
            Y.PROCESS.FLAG = 0    ;* Skip processing for $HIS and $ARC file types
        CASE Y.FILE.TYPE EQ '$NAU'
            Y.LIVE.RECORD = 0
    END CASE
    RETURN
*
***************
INITIALISATION:
***************
*
    Y.COMPANY = FIELD(LOC.FN.SWAP, '.', 1)  ;* Get the Company Mnemonic
    Y.COMPANY := '.'
*
    FN.SWAP.SCHEDULES = Y.COMPANY:'SWAP.SCHEDULES' ; F.SWAP.SCHEDULES = ''
    OPEN FN.SWAP.SCHEDULES TO F.SWAP.SCHEDULES ELSE
        F.SWAP.SCHEDULES = ''
    END
*
    FN.SWAP.SCHEDULES.SAVE = Y.COMPANY:'SWAP.SCHEDULES.SAVE' ; F.SWAP.SCHEDULES.SAVE = ''
    OPEN FN.SWAP.SCHEDULES.SAVE TO F.SWAP.SCHEDULES.SAVE ELSE
        F.SWAP.SCHEDULES.SAVE = ''
    END
*
    C$SWAP.ID = SWAP.ID ; R$SWAP = SWAP.REC
    ENQUIRY.MODE = 1 ; Y.UPDATE.FLAG = 0
    Y.SCHEDULE.LIST = ''
*
    RETURN
*
***********************
CHECK.LIVE.INAU.EXISTS:
***********************
    R$SWAP.NAU = ''
    IF Y.LIVE.RECORD THEN
        FN.SWAP.NAU = Y.COMPANY:'SWAP$NAU' ; F.SWAP.NAU = ''
        OPEN FN.SWAP.NAU TO F.SWAP.NAU THEN
            READ R$SWAP.NAU FROM F.SWAP.NAU, SWAP.ID THEN
                Y.UPDATE.FLAG = 1       ;* Need to write in SWAP.SCHEDULES.SAVE
            END
        END
    END
    RETURN
*
**********************
UPDATE.SWAP.SCHEDULES:
**********************
*
    ID.NEW = C$SWAP.ID ; SW.SCH.REC = ''

    SEL.CMD = "SELECT ":Y.COMPANY:"SWAP.SCHEDULES WITH @ID LIKE ":ID.NEW:"..."
    EXECUTE SEL.CMD
    READLIST SWAP.LIST ELSE
    SWAP.LIST = ""
    END
    LOOP
        REMOVE SW.SCH.ID FROM SWAP.LIST SETTING SWPOS
    WHILE SW.SCH.ID:SWPOS
        CALL CONV.SW.BUILD.SCHEDULE.LIST(Y.SCHEDULE.LIST, '')
        READ SW.SCH.REC FROM F.SWAP.SCHEDULES, SW.SCH.ID ELSE
            SW.SCH.REC = ""
        END
        IF SW.SCH.REC THEN
            Y.SCHED.COUNT = DCOUNT(SW.SCH.REC<1>,VM)
            FOR I = 1 TO Y.SCHED.COUNT
                Y.SCHED.TYPE = SW.SCH.REC<1,I>
                IF Y.SCHED.TYPE NE 'CM' THEN
                    Y.ACTIVITY.CODE = SW.SCH.REC<8,I>
                    Y.ACTIVITY.DATE = SW.SCH.REC<9,I>
                    Y.ENTRY.DATE = SW.SCH.REC<2,I>
                    Y.PROCESS.DATE = SW.SCH.REC<3,I>
                    Y.EFFECTIVE.DATE = SW.SCH.REC<4,I>
                    Y.PROCESS.VALUE = SW.SCH.REC<5,I>
                    LEG.TYPE = SW.SCH.REC<7,I>
                    IF Y.ACTIVITY.CODE  AND Y.ACTIVITY.DATE THEN
                        GOSUB GET.Y.SCH.DATE
                        SW.SCH.REC<10,I> =Y.SCH.DATE
                    END ELSE
                        SW.SCH.REC<10,I> = FIELD(SW.SCH.ID,'.',2)
                    END
                    Y.UPDATE.FLAG = 1
                END
            NEXT I
            IF Y.UPDATE.FLAG THEN
                WRITE SW.SCH.REC TO F.SWAP.SCHEDULES.SAVE, SW.SCH.ID ON ERROR NULL
            END ELSE
                WRITE SW.SCH.REC TO F.SWAP.SCHEDULES,SW.SCH.ID ON ERROR NULL
            END
        END
    REPEAT
    RETURN
GET.Y.SCH.DATE:

    IF SW.SCH.REC<7,I> = "A" THEN
        SW.DAY.CONV = SW.AS.DAY.CONVENTION
        SW.DATE.ADJ = SW.AS.DATE.ADJUSTMENT
    END ELSE
        SW.DAY.CONV=SW.LB.DAY.CONVENTION
        SW.DATE.ADJ = SW.LB.DATE.ADJUSTMENT
    END
    IF SWAP.REC<SW.DAY.CONV> AND (SWAP.REC<SW.DATE.ADJ> EQ "PERIOD") THEN

        Y.SCHED.TYPE = SW.SCH.REC<1,I>
        Y.KEY.CHECK = Y.SCHED.TYPE:SW.SCH.REC<2,I>:SW.SCH.REC<3,I>:SW.SCH.REC<4,I>:SW.SCH.REC<7,I>
        TOT.LIST = DCOUNT(Y.SCHEDULE.LIST<1>,VM)
        FOR I.LIST = 1 TO TOT.LIST
            Y.SEARCH.KEY = Y.SCHEDULE.LIST<1,I.LIST>:Y.SCHEDULE.LIST<3,I.LIST>:Y.SCHEDULE.LIST<4,I.LIST>:Y.SCHEDULE.LIST<5,I.LIST>
            Y.SEARCH.KEY := Y.SCHEDULE.LIST<8,I.LIST>
            IF Y.KEY.CHECK = Y.SEARCH.KEY THEN
                Y.SCH.DATE = Y.SCHEDULE.LIST<12,I.LIST>
                EXIT
            END

        NEXT I.LIST
    END ELSE
        * If no day convention involved take the ORIG.SCHED.DATE as the effective.date itself.
        * Also for day convention without adj as period.
        Y.SCH.DATE = SW.SCH.REC<4,I>    ;* Effective Date
    END


    RETURN
*
    END
