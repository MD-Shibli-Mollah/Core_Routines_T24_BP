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

*------------------------------------------------------------------------------------------------------
* <Rating>-33</Rating>
*------------------------------------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE V.MB.COMI.PROCESS.IB
*------------------------------------------------------------------------------------------------------
*
* A routine which takes the value of the ID of the CUSTOMER)
* and updates the PW.PROCESS record CUSTOMER field with this number.
*
*------------------------------------------------------------------------------------------------------
* Modification History:
*
* 16/12/2010 - Abinanthan - initial version
*              For Internet Banking User creation
*
*
*17-08-2011 -   En_200523
*               To call the PW related services to replace the PW related code
*
* 28/03/2013 -  Task_635563 : (Defect_626984)
*               Revert the changes done by PW team
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*------------------------------------------------------------------------------------------------------
*
    $USING AI.ModelBank
    $USING EB.SystemTables
    $USING PW.Foundation
*
*------------------------------------------------------------------------------------------------------
*
    IF PW.Foundation.getOriginateProcess() <> "" THEN
        GOSUB INITIALISE      ;* Initialising all common variables
        GOSUB PROCESS         ;* Processing section
    END
    RETURN
*
*------------------------------------------------------------------------------------------------------
INITIALISE:
*------------------------------------------------------------------------------------------------------
*

    RETURN
*
*------------------------------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------------------------------
*
*
    tmp.PW$ORIGINATE.PROCESS = PW.Foundation.getOriginateProcess()
    PW.Foundation.ProcessLock(tmp.PW$ORIGINATE.PROCESS,R.PROCESS,'',"E",'')
*
    IF R.PROCESS <> "" THEN
        R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerCustomerNo)
        *
        tmp.PW$ORIGINATE.PROCESS = PW.Foundation.getOriginateProcess()
        PW.Foundation.ProcessWrite(tmp.PW$ORIGINATE.PROCESS,R.PROCESS,'')
    END
    RETURN
*------------------------------------------------------------------------------------------------------
    END
*------------------------------------------------------------------------------------------------------
