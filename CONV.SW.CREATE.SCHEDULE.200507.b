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
* <Rating>-140</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Schedules
    SUBROUTINE CONV.SW.CREATE.SCHEDULE.200507(SWAP.ID, SWAP.REC, LOC.FN.SWAP)
*
******************************************************************************
* SWAP.SCHEDULES file is introduced in SAR-2004-10-28-0002(SWAP CLEAN UP - II)
* which is used to store all the unprocessed schedules of a SWAP contract.
*
* This conversion is used to create SWAP.SCHEDULES record for all the
* existing SWAP contracts.
******************************************************************************
* MODIFICATIONS:
****************
*
* 02/06/05 - BG_100008848
*            Creation of the Routine
*
* 05/08/05 - BG_100009217
*            System hangs while processing the unprocessed RR schedule
*
* 19/02/07 - BG_100013039
*            Change Calls to SW core routines with CONV.SW routines.
*
* 29/05/08 - CI_10055724
*            MAT entries are duplicated after upgrade due to CM schedules
*            created by conversion for matured deals
*
* 08/06/15 - Defect 1360480/Task 1370662
*		     Compilation errors since FN.SWAP used both as local and common variable.
******************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.CONV.SWAP
    $INSERT I_SW.COMMON
*
    GOSUB CHECK.FILE.TYPE
* check for matured deals, since no need to update schedules
    GOSUB MATURED.DEALS
    IF Y.PROCESS.FLAG THEN
        GOSUB INITIALISATION
        GOSUB CHECK.LIVE.INAU.EXISTS
        GOSUB CREATE.SWAP.SCHEDULES
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
*-------------
MATURED.DEALS:
*-------------

    IF SWAP.REC<SW.CONTRACT.STATUS> = 'MAT' THEN
        Y.PROCESS.FLAG = 0
    END
    RETURN

***************
INITIALISATION:
***************
*
    Y.COMPANY = FIELD(LOC.FN.SWAP, '.', 1)  ;* Get the Company Mnemonic
    Y.COMPANY := '.'
*
    FN.SWAP.BALANCES = Y.COMPANY:'SWAP.BALANCES' ; F.SWAP.BALANCES = ''
    OPEN FN.SWAP.BALANCES TO F.SWAP.BALANCES ELSE
        F.SWAP.BALANCES = ''
    END

    FN.SWAP.BALANCES.SAVE = Y.COMPANY:'SWAP.BALANCES.SAVE' ; F.SWAP.BALANCES.SAVE = ''
    OPEN FN.SWAP.BALANCES.SAVE TO F.SWAP.BALANCES.SAVE ELSE
        F.SWAP.BALANCES.SAVE = ''
    END

    FN.SWAP.SCHEDULES = Y.COMPANY:'SWAP.SCHEDULES' ; F.SWAP.SCHEDULES = ''
    OPEN FN.SWAP.SCHEDULES TO F.SWAP.SCHEDULES ELSE
        F.SWAP.SCHEDULES = ''
    END
*
    Y.FULL.AS.BALANCES = '' ; Y.FULL.LB.BALANCES = ''
    C$SWAP.ID = SWAP.ID ; R$SWAP = SWAP.REC
    ENQUIRY.MODE = 1 ; Y.UPDATE.FLAG = 0
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
                FN.SWAP.BALANCES = FN.SWAP.BALANCES.SAVE
                F.SWAP.BALANCES = F.SWAP.BALANCES.SAVE
                Y.UPDATE.FLAG = 1       ;* Need to write in SWAP.SCHEDULES.SAVE
            END
        END
    END
    RETURN
*
**********************
CREATE.SWAP.SCHEDULES:
**********************
*
* To write the unprocessed schedules in SWAP.SCHEDULES file
*
    ID.NEW = C$SWAP.ID ; Y.SCHEDULE.LIST = ''
    GOSUB READ.SWAP.BALANCES

    CALL CONV.SW.BUILD.SCHEDULE.LIST(Y.SCHEDULE.LIST, '')
    CALL CONV.SW.SCHEDULE.PROCESSING(Y.SCHEDULE.LIST, 1)
    GOSUB BUILD.FULL.SCHEDULE.LIST

    CALL CONV.SW.DETERMINE.ACTIVITY(Y.SCHEDULE.LIST)
    CALL CONV.SW.UPDATE.SCHEDULES(Y.SCHEDULE.LIST, Y.COMPANY, Y.UPDATE.FLAG)
    RETURN
*
*******************
READ.SWAP.BALANCES:
*******************
*
    R$SW.ASSET.BALANCES = '' ; R$SW.LIABILITY.BALANCES = ''
    READ.ERR = ''
    Y.SW.BAL.ID = C$SWAP.ID:'.A'
    READ R$SW.ASSET.BALANCES FROM F.SWAP.BALANCES, Y.SW.BAL.ID ELSE
        R$SW.ASSET.BALANCES = ""
    END
*
    Y.SW.BAL.ID = C$SWAP.ID:'.L' ; READ.ERR = ''
    READ R$SW.LIABILITY.BALANCES FROM F.SWAP.BALANCES, Y.SW.BAL.ID ELSE
        R$SW.LIABILITY.BALANCES = ""
    END
    RETURN
*
*************************
BUILD.FULL.SCHEDULE.LIST:
*************************
* Cycle the schedules to ensure that all future events are available
* in the balances record
*
    R$SWAP.SAVE = R$SWAP
    R$SW.ASSET.BALANCES.SAVE = R$SW.ASSET.BALANCES
    R$SW.LIABILITY.BALANCES.SAVE = R$SW.LIABILITY.BALANCES
    Y.SCHED.LIST = '' ; Y.PROCESS.SCHEDULES = 1   ;* BG_100009217 - S
*
    LOOP
    WHILE (Y.SCHED.LIST OR Y.PROCESS.SCHEDULES)
        Y.SCHED.LIST = '' ; Y.PROCESS.SCHEDULES = 0         ;* BG_100009217 - E
        CALL CONV.SW.CYCLE.SCHEDULES(ENQUIRY.MODE)
        CALL CONV.SW.BUILD.SCHEDULE.LIST(Y.SCHED.LIST,'')
        CALL CONV.SW.SCHEDULE.PROCESSING(Y.SCHED.LIST, ENQUIRY.MODE)
    REPEAT
*
    Y.FULL.AS.BALANCES = R$SW.ASSET.BALANCES
    Y.FULL.LB.BALANCES = R$SW.LIABILITY.BALANCES

    R$SW.ASSET.BALANCES = R$SW.ASSET.BALANCES.SAVE
    R$SW.LIABILITY.BALANCES = R$SW.LIABILITY.BALANCES.SAVE
    R$SWAP = R$SWAP.SAVE
*
    RETURN
END
