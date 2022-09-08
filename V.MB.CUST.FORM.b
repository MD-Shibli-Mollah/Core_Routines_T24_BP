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
*Subroutine to map Customer id into EB.MORTGAGE.FORM1 application from customer application in Process Workflow

    $PACKAGE OP.ModelBank
    SUBROUTINE V.MB.CUST.FORM

    $USING OP.ModelBank
    $USING ST.Customer
    $USING PW.Foundation
    $USING EB.SystemTables

*
    IF PW.Foundation.getOriginateProcess() = "" THEN
        EB.SystemTables.setRNew(ST.Customer.Customer.EbCusPastimes, "PW$ORIGINATE.PROCESS IS null")
    END ELSE
        GOSUB PROCESS
    END
*
    RETURN

PROCESS:

    PW$ORIGINATE.PROCESS.VAL = PW.Foundation.getOriginateProcess()
    R.PROCESS = PW.Foundation.Process.Read(PW$ORIGINATE.PROCESS.VAL, PW.ERR)
    Y.ACTIVITY = DCOUNT(R.PROCESS<PW.Foundation.Process.ProcActivity>,@VM)
    FOR I = 1 TO Y.ACTIVITY
        PW.ACTIVITY = R.PROCESS<PW.Foundation.Process.ProcActivity><1,I>
        IF PW.ACTIVITY EQ 'CHECK.BASIC.ELIGIBILITY1' THEN
            PW.ACTIVITY.TXN = R.PROCESS<PW.Foundation.Process.ProcActivityTxn>
            GOSUB CUST.ID
        END
    NEXT I
    RETURN
CUST.ID:
    R.ACTIVITY = PW.Foundation.ActivityTxn.Read(PW.ACTIVITY.TXN, TXN.ERR)
    Y.APP.FORM.ID = R.ACTIVITY<PW.Foundation.ActivityTxn.ActTxnTransactionRef>
    CRT "Y.APP.FORM.ID ":Y.APP.FORM.ID
    R.FORM = OP.ModelBank.EbMortgageFormOne.ReadU(Y.APP.FORM.ID, '', FORM.ERR)
    R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId> = EB.SystemTables.getIdNew()
    OP.ModelBank.EbMortgageFormOne.Write(Y.APP.FORM.ID, R.FORM)
    RETURN
    END
