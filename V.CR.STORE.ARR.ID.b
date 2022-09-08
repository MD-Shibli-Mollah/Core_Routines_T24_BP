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
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE V.CR.STORE.ARR.ID
*** <region name= PROGRAM DESCRIPTION>
***
*
** Check record routine assign arrangmenet Id into the variable CURRENT.ARR.ID
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
*             Check record routine contains CURRENT.ARR.ID value
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***

    $USING EB.Browser
    $USING EB.SystemTables


*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MAIN PROCESS>
***

    VA.ID = EB.SystemTables.getIdNew()
    EB.Browser.SystemSetvariable("CURRENT.ARR.ID",VA.ID)

    RETURN

*** </region>
*-----------------------------------------------------------------------------
    END
