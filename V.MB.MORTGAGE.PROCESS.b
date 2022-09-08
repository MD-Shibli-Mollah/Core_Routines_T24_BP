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

    $PACKAGE OP.ModelBank
    SUBROUTINE V.MB.MORTGAGE.PROCESS


    $USING PW.Foundation
    $USING OP.ModelBank
    $USING EB.DataAccess
    $USING EB.SystemTables

    IF PW.Foundation.getOriginateProcess() NE "" THEN
        GOSUB INITIALISE
        GOSUB PROCESS
    END

    RETURN
*
**************************************************************************
INITIALISE:
**************************************************************************

    tmp.F.PW.PROCESS = ''
    tmp.FN.PW.PROCESS = "F.PW.PROCESS"
    EB.DataAccess.Opf(tmp.FN.PW.PROCESS,tmp.F.PW.PROCESS)
    PW.Foundation.setFnPwProcess(tmp.FN.PW.PROCESS)
    PW.Foundation.setFPwProcess(tmp.F.PW.PROCESS)
*
    RETURN
*
**************************************************************************
PROCESS:
**************************************************************************
*

    PW$ORIGINATE.PROCESS.VAL = PW.Foundation.getOriginateProcess()
    PW.Foundation.ProcessLock(PW$ORIGINATE.PROCESS.VAL, R.PROCESS, '', "E",'')

*
    IF R.PROCESS NE "" THEN
        R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId)
        PW$ORIGINATE.PROCESS.VAL = PW.Foundation.getOriginateProcess()
        PW.Foundation.ProcessWrite(PW$ORIGINATE.PROCESS.VAL, R.PROCESS,'')

    END
    RETURN
    END
