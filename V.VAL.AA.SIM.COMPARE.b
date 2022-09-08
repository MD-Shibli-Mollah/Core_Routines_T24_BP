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
* <Rating>-59</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE V.VAL.AA.SIM.COMPARE
*** <region name= PROGRAM DESCRIPTION>
***
*
** Validation Routine to find duplicate and return error if more than 3 multivalue found
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
*  10/09/13 - Task 737278
*             Enhancement 715620 - Simulation Result and Print on One Screen
*             Validation Routine to find duplicate in simulation runner reference
*             Validation for maximum of three simulation and minimum of two simulation
*             only for comparison
*
*  02/12/13 - Task 852390
*             Duplicate error in wrong position
*             After execution of this routine ETEXT is checked in RECORD.VALIDATION routine and displays error Message with 1st position as default
*             As adviced by browser them ETEXT nullified once validation done.
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>

    $USING AA.ModelBank
    $USING EB.ErrorProcessing
    $USING EB.SystemTables


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

    SIM.SELECTS = ''
    CNT.SIM.SELECT = ''
    TOT.CNT.SIM.SELECTS = ''
    CNT.I = ''
    YCOUNT = ''
    YT.DOUBLE = ''
    TEMP.AV = ''
    YFD = ''
    EB.SystemTables.setEtext('')

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= PROCESS>
***
PROCESS:

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        BEGIN CASE
            CASE EB.SystemTables.getAf() EQ AA.ModelBank.AaSimulationComparison.AaSim4SimSelect
                GOSUB SIM.SELECT.VALIDATION

            CASE EB.SystemTables.getAf() EQ AA.ModelBank.AaSimulationComparison.AaSim4Sim1
                GOSUB SIM.DUPLICATE.VALIDATION
        END CASE
    END

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= SIM.SELECT.VALIDATION>
***
SIM.SELECT.VALIDATION:

    SIM.SELECTS = EB.SystemTables.getRNew(AA.ModelBank.AaSimulationComparison.AaSim4SimSelect)
    CNT.SIM.SELECT = 0
    TOT.CNT.SIM.SELECTS = DCOUNT(SIM.SELECTS,@VM)
    FOR CNT.I = 1 TO TOT.CNT.SIM.SELECTS
        IF SIM.SELECTS<1,CNT.I> EQ "YES" THEN
            CNT.SIM.SELECT++
        END
    NEXT CNT.I
    IF CNT.SIM.SELECT LT 2 THEN
        EB.SystemTables.setEtext("AA-MINIMUM.TWO.CAPTURE.SHOULD.COMPARE")
        EB.ErrorProcessing.StoreEndError()
    END
    IF CNT.SIM.SELECT GT 3 THEN
        EB.SystemTables.setEtext("AA-THREE.SIM.REF.ABLE.TO.INPUT")
        EB.ErrorProcessing.StoreEndError()
    END

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= SIM.DUPLICATE.VALIDATION>
***
SIM.DUPLICATE.VALIDATION:

    YCOUNT = DCOUNT(EB.SystemTables.getRNew(AA.ModelBank.AaSimulationComparison.AaSim4Sim1),@VM)
    YT.DOUBLE = ""
    FOR TEMP.AV = 1 TO YCOUNT
        YFD = EB.SystemTables.getRNew(AA.ModelBank.AaSimulationComparison.AaSim4Sim1)<1,TEMP.AV>
        LOCATE YFD IN YT.DOUBLE<1> SETTING X THEN
        EB.SystemTables.setAv(TEMP.AV)
        EB.SystemTables.setEtext("EB-DUPLICATE")
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        YT.DOUBLE<-1> = YFD
    END
    NEXT TEMP.AV

    RETURN

*** </region>
*-----------------------------------------------------------------------------

    END
