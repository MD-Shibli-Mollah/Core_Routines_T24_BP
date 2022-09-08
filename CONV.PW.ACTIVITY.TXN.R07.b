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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PW.Foundation
    SUBROUTINE CONV.PW.ACTIVITY.TXN.R07(TXN.ID,R.PW.ACT.TXN,FILE)
*
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PW.PROCESS
*------------------------------------------------------------------------------------------------------------------
* MODIFICATION LOG
*
* 24/09/06 - New conversion rtn. for populating the 2 new fields
*            PARENT.PROCESS and ORIGINATE.PROCESS
*            REF : SAR-2006-09-19-0003
*------------------------------------------------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB POPULATE.NEW.FIELDS
    RETURN

*------------------------------------------------------------------------------------------------------------------
INITIALISE:
*----------
    EQU PW.ACT.TXN.PROCESS TO 1,
    PW.ACT.TXN.PARENT.PROCESS TO 21,
    PW.ACT.TXN.ORIGINATE.PROCESS TO 22


    FN.PW.PROCESS = 'F.PW.PROCESS'
    F.PW.PROCESS = ''

    CALL OPF(FN.PW.PROCESS,F.PW.PROCESS)
    READ.ERR = ''

    PW.PROCESS.ID = R.PW.ACT.TXN<PW.ACT.TXN.PROCESS>

    RETURN
*------------------------------------------------------------------------------------------------------------------
POPULATE.NEW.FIELDS:
*------------------
* populate PARENT.PROCESS
    CALL F.READ(FN.PW.PROCESS,PW.PROCESS.ID,R.PW.PROCESS,F.PW.PROCESS,READ.ERR)
    IF NOT(READ.ERR) THEN
        PARENT.PROCESS = R.PW.PROCESS<PW.PROC.PARENT.PROCESS>
        IF PARENT.PROCESS THEN
            R.PW.ACT.TXN<PW.ACT.TXN.PARENT.PROCESS> = PARENT.PROCESS
        END ELSE
            R.PW.ACT.TXN<PW.ACT.TXN.ORIGINATE.PROCESS> = PW.PROCESS.ID
        END
    END
* populate ORIGINATE.PROCESS

    LOOP WHILE (NOT(READ.ERR)  AND PARENT.PROCESS NE '')

        CALL F.READ(FN.PW.PROCESS,PARENT.PROCESS,R.PW.PROCESS,F.PW.PROCESS,READ.ERR)

        IF NOT(R.PW.PROCESS<PW.PROC.PARENT.PROCESS>) THEN
            R.PW.ACT.TXN<PW.ACT.TXN.ORIGINATE.PROCESS> = PARENT.PROCESS
            PARENT.PROCESS = ''
        END ELSE
            PARENT.PROCESS = R.PW.PROCESS<PW.PROC.PARENT.PROCESS>
        END
    REPEAT

    RETURN
*------------------------------------------------------------------------------------------------------------------

END
