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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.NOF.AA.SIM.POPUP(OUT.DATA)
*** <region name= PROGRAM DESCRIPTION>
***
*
** Nofile routine returning status details
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
*             Nofile routine returning status details
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***

    $USING AA.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports


*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MAIN PROCESS>
***
    GOSUB PROCESS

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= PROCESS>
***
PROCESS:

    SIM.REF.IDS = ''

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
    ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END

    F.AA.SIMULATION.COMPARISON = ''

    R.AA.SIMULATION.COMPARISON = AA.ModelBank.AaSimulationComparison.Read(ARR.ID, ERR.CODE)

    SIM.REFERENCES = R.AA.SIMULATION.COMPARISON<AA.ModelBank.AaSimulationComparison.AaSim4Sim1>
    SIM.SELECTS = R.AA.SIMULATION.COMPARISON<AA.ModelBank.AaSimulationComparison.AaSim4SimSelect>

    FOR I =1 TO DCOUNT(SIM.REFERENCES,@VM)
        IF SIM.SELECTS<1,I> EQ "YES" THEN
            SIM.REF.IDS<1,-1> = SIM.REFERENCES<1,I>
        END
    NEXT I

    SIM.REF.1 = SIM.REF.IDS<1,1>
    SIM.REF.2 = SIM.REF.IDS<1,2>
    SIM.REF.3 = SIM.REF.IDS<1,3>

    OUT.DATA = ARR.ID:'*':EB.SystemTables.getToday():'*':'Simulation Comparison':'*':'Completed - Successfully':'*':SIM.REF.1:'*':SIM.REF.2:'*':SIM.REF.3

    CHANGE @FM TO @VM IN OUT.DATA

    RETURN

*** </region>
*-----------------------------------------------------------------------------

    END
