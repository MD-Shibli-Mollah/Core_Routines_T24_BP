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
    $PACKAGE ST.ModelBank

    SUBROUTINE V.MB.COMI.PROCESS
*-------------------------------------------------------------------------
*
* A routine which takes the value of the ID of the CUSTOMER)
* and updates the PW.PROCESS record CUSTOMER field with this number.
*
*-------------------------------------------------------------------------
* 25 October 2008 - woody - initial version
* 04 Febrauary 2010 - Abinanthan K B - For Account Opening process, Loan process and
*                                      Complaint proces
*-------------------------------------------------------------------------

    $USING PW.Foundation
    $USING AC.ModelBank
    $USING CR.Analytical
    $USING DD.Contract
    $USING AI.ModelBank
    $USING EB.DataAccess
    $USING ST.ModelBank
    $USING EB.SystemTables

*
    IF PW.Foundation.getOriginateProcess()<> "" THEN
        GOSUB INITIALISE
        GOSUB PROCESS
    END
*
    RETURN
*
**************************************************************************
INITIALISE:
**************************************************************************
*

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
    PW.Foundation.ProcessLock(PW$ORIGINATE.PROCESS.VAL, R.PROCESS,'', "E",'')

    IF R.PROCESS <> "" THEN
        BEGIN CASE
            CASE EB.SystemTables.getApplication() EQ 'DD.DDI'
                R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getRNew(DD.Contract.Ddi.DdiCustomerNo)
            CASE EB.SystemTables.getApplication() EQ 'AC.ACCOUNT.OPENING'
                R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivCustomer)
            CASE EB.SystemTables.getApplication() EQ 'CR.CONTACT.LOG'
                R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getRNew(CR.Analytical.ContactLog.ContLogContactClient)
            CASE EB.SystemTables.getApplication() EQ 'EB.MB.IBUSER.FORM'
                R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerCustomerNo)
        END CASE
        *
        PW$ORIGINATE.PROCESS.VAL = PW.Foundation.getOriginateProcess()
        PW.Foundation.ProcessWrite(PW$ORIGINATE.PROCESS.VAL, R.PROCESS,'')
    END
    RETURN
    END
