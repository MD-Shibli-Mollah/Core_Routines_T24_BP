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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.SIMULATIONS
*****************************************
*23/11/10 - Ref: 32880
*           Task: 110954
*           The query that has to be performed against AA.SIMULATION.RUNNER is added into DAS.AA.SIMULATION.RUNNER
*
*
*****************************************
    $INSERT I_DAS.AA.SIMULATION.RUNNER

    $USING EB.DataAccess
    $USING EB.Reports

*****************************************
*
    GOSUB INITIALISE
    GOSUB GET.SIM.RUN.IDS

*
    RETURN
*****************************************
INITIALISE:
*************
*
    ARR.ID = EB.Reports.getOData()
*
    FV.AA.SIM = ''
*
    RET.ARR = ''
*
    RETURN
******************************************
GET.SIM.RUN.IDS:
*
*   *Select records based on ARRANGEMENT.REF and EXECUTE.SIMULATION NE "YES"
    TABLE.NAME='AA.SIMULATION.RUNNER'
    THE.LIST=dasAaSimulationRunnerWithArrRefAndExecuteSimNeYes
    THE.ARGS=''
    THE.ARGS<1>=ARR.ID
    THE.ARGS<2>='YES'
    TABLE.SUFFIX=''
*
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
*
    CONVERT @FM TO @VM IN THE.LIST
    EB.Reports.setOData(THE.LIST)
*
    RETURN
******************************************
