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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.SIM.CAP.REF.DETAIL(RET.DATA)
*** <region name= PROGRAM DESCRIPTION>
***
*
** Nofile routine returning simulation capture reference, description and activity
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
*  10/09/13 - Task 737278
*             Enhancement 715620
*             Nofile routine returning simulation capture reference, description and activity
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***
    $INSERT I_DAS.AA.SIMULATION.RUNNER
    $INSERT I_System

    $USING AA.Framework
    $USING EB.DataAccess


*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MAIN PROCESS>
***

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= INITIALISE>
***
INITIALISE:

    ARR.ID = System.getVariable("CURRENT.ARR.ID")

    F.AA.SIMULATION.RUNNER = ""

    CAP.REF = ''
    GB.DESCRIPTION = ''
    ACTIVITY = ''
    RET.DATA = ''
    R.AA.SIMULATION.RUNNER = ''

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= PROCESS>
***
PROCESS:

    DAS.ID = 'AA.SIMULATION.RUNNER'
    REQD.ARGS<1> = ARR.ID
    ID.LIST = dasAaSimulationRunnerWithArrRef
    EB.DataAccess.Das(DAS.ID, ID.LIST, REQD.ARGS, "")

    LOOP
        REMOVE RUN.ID FROM ID.LIST SETTING RUN.POS
    WHILE RUN.ID:RUN.POS
        R.AA.SIMULATION.RUNNER = AA.Framework.SimulationRunner.Read(RUN.ID, ERR)
        IF R.AA.SIMULATION.RUNNER THEN
            CAP.REF<-1> = RUN.ID
            GB.DESCRIPTION<-1> = R.AA.SIMULATION.RUNNER<AA.Framework.SimulationRunner.SimDescription>
            ACTIVITY<-1> = R.AA.SIMULATION.RUNNER<AA.Framework.SimulationRunner.SimUActivity>
        END
    REPEAT

    RET.DATA = CAP.REF:"*":GB.DESCRIPTION:"*":ACTIVITY
    CHANGE @FM TO @VM IN RET.DATA

    RETURN

*** </region>
*-----------------------------------------------------------------------------
    END
