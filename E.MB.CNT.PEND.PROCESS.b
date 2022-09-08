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
* A new conversion routine (E.MB.CNT.PEND.PROCESS) has been introduced to Show the cumulative of
* each pending process.This new routine is called from an existing enquiry (PW.PENDING.PROCESS).
*-----------------------------------------------------------------------------
* Incoming:
* ----------------------------------------------------------------------------
* In O.DATA it will get the PW.PROCESS id
*
* Outgoing:
* -----------------------------------------------------------------------------
* In O.DATA it will store the total number of  pending processes.
*
* Modifications
*
* 10/03/16 - Enhancement 1499015
*	       - Task 1654637
*	       - Routine incorporated
*
*------------------------------------------------------------------------------


    $PACKAGE PW.ModelBank
    SUBROUTINE E.MB.CNT.PEND.PROCESS


    $USING PW.Foundation
    $USING EB.Reports


    GOSUB INIT
    GOSUB PROCESS
    RETURN

INIT:

    TOT = 0
    PW.ID = EB.Reports.getOData()


    RETURN

PROCESS:

    R.PW.REC = PW.Foundation.Process.Read(PW.ID, ERR.PW)
    PAT.IDS = R.PW.REC<PW.Foundation.Process.ProcActivityTxn>
    PAT.COMP= R.PW.REC<PW.Foundation.Process.ProcCompleted>
    NO.OF.REC = DCOUNT(PAT.IDS,@VM)
    FOR I = 1 TO NO.OF.REC
        PAT.ID = PAT.IDS<1,I>
        COMP = PAT.COMP<1,I>
        IF COMP NE 'Y' THEN
            R.PW.ACT = PW.Foundation.ActivityTxn.Read(PAT.ID, ERR.PW.TXN)
            CHK.REC = R.PW.ACT<PW.Foundation.ActivityTxn.ActTxnPwActivityStatus>
            IF CHK.REC NE 'ABORTED' THEN
                TOT += 1
            END
        END
    NEXT I
    EB.Reports.setOData(TOT)

    RETURN
