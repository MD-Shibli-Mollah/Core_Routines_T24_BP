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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE MAP.ARRANGEMENT.ID
*---------------------------------------------------------------------------
* This routine is used to get the pw.af.deposit id and map to the respective activity
* where the same pw.af.deposit versions as id
*---------------------------------------------------------------------------
* Modification History:
* ---------------------
* 14/09/2012 - Defect 481884/Task 481896
*              'Live record not changed ‘ error is thrown on commit of the PW.AF.DEPOSIT record
*              displayed after inputting the Arrangement record.
*
*---------------------------------------------------------------------------
*** <region = Insert files>

    $USING PW.Foundation
    $USING PW.ModelBank
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB MAP.DATA
    RETURN
*** </region>
*---------------------------------------------------------------------------
*** <region = INITIALISE>
INITIALISE:
*---------
*Initialize the variablesand files
    PW.Foundation.setFnPwProcess('F.PW.PROCESS')
    PW.Foundation.setFPwProcess('')
    tmp.F.PW.PROCESS = PW.Foundation.getFPwProcess()
    tmp.FN.PW.PROCESS = PW.Foundation.getFnPwProcess()
    EB.DataAccess.Opf(tmp.FN.PW.PROCESS,tmp.F.PW.PROCESS)
    PW.Foundation.setFnPwProcess(tmp.FN.PW.PROCESS)
    PW.Foundation.setFPwProcess(tmp.F.PW.PROCESS)

    F.PAT = ''

    F.PW.AF.DEPOSIT = ''

    F.AA.ACT = ''
    RETURN

*** </region>
*----------------------------------------------------------------------------
*** <region = MAP.DATA>
MAP.DATA:
*-------
* Read the pw.activity.txn and pw.process and map the ARRANGEMENT id.

    PW.PROCESS = PW.Foundation.getOriginateProcess()
    tmp.F.PW.PROCESS = PW.Foundation.getFPwProcess()
    tmp.FN.PW.PROCESS = PW.Foundation.getFnPwProcess()
    R.PROCESS = PW.Foundation.Process.Read(PW.PROCESS, PW.ERR)
    PW.Foundation.setFnPwProcess(tmp.FN.PW.PROCESS)
    PW.Foundation.setFPwProcess(tmp.F.PW.PROCESS)

    AC.TXN.CNT = DCOUNT(R.PROCESS<PW.Foundation.Process.ProcActivityTxn>,@VM)
    FOR ACTIVITY = 1 TO AC.TXN.CNT
        ACTIVITY.TXN.ID = R.PROCESS<PW.Foundation.Process.ProcActivityTxn,ACTIVITY>
        PW.ACTIVITY =  R.PROCESS<PW.Foundation.Process.ProcActivity,ACTIVITY>
        R.PAT = PW.Foundation.ActivityTxn.Read(ACTIVITY.TXN.ID, PAT.ERR)
        IF PW.ACTIVITY EQ 'CREATE.OPPOR.ARRANGEMENT' THEN
            AA.ARR.ACT.ID = R.PAT<PW.Foundation.ActivityTxn.ActTxnTransactionRef>
            R.AA.ACT = AA.Framework.ArrangementActivity.Read(AA.ARR.ACT.ID, AA.ERR)
            EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoAaArrangement, R.AA.ACT<AA.Framework.ArrangementActivity.ArrActArrangement>)
        END
    NEXT ACTIVITY
    RETURN
*** </region>
*-----------------------------------------------------------------------
    END
