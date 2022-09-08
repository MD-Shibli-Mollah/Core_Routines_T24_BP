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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE E.MB.EXTERNALUSER.ID
*----------------------------------------------------------------------------
* Routine will populate the customer id as a EB.EXTERNAL.USER record id
*----------------------------------------------------------------------------
* Modification History:
* ------------------------------------------------------------------------
*
* 18/05/15 - Enhancement-1326996/Task-1399903
*			 Incorporation of AI components
*-----------------------------------------------------------------------------
*** <region name= Insert>
*** <desc>Insert Region </desc>

    $USING EB.SystemTables
    $USING PW.API
    $USING PW.Foundation

*** </region>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*** <region name= INITIALISE>
INITIALISE:
****************************

    PW.PROCESS.ID = ''        ;* pw process id
    PROCESS.TXN.ID = PW.Foundation.getActivityTxnId() ;* common variable contains the PW.ACTIVITY.TXN id
    RETURN

*** </region>
*-----------------------------------------------------------------------------


*** <region name=PROCESS>
PROCESS:
************************

    IF PW.Foundation.getActivityTxnId() THEN

        PW.API.FindProcess(PROCESS.TXN.ID,PW.PROCESS.ID)  ;* get the PW.PROCESS name
        ER = ''
        R.PW.PROCESS = ''
        R.PW.PROCESS = PW.Foundation.Process.Read(PW.PROCESS.ID, ER)   ;* try to read the PW.PROCESS rec
        EB.SystemTables.setComi(R.PW.PROCESS<PW.Foundation.Process.ProcCustomer>);* Customer id

    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
