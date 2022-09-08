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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE V.AUTH.SIM.POPUP
*** <region name= PROGRAM DESCRIPTION>
***
*
** Auth routine used to trigger next enquiry to show the status
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
*             Auth routine used to trigger next enquiry to show the status
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***
    $USING EB.API
    $USING EB.SystemTables


*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MAIN PROCESS>
***

    NEXT.TASK = "ENQ AA.SIM.COMPARE.MONITOR ARRANGEMENT.ID EQ ":EB.SystemTables.getIdNew()
    EB.API.SetNextTask(NEXT.TASK)    ;*To launch the ENQ

    RETURN

*** </region>
*-----------------------------------------------------------------------------

    END
