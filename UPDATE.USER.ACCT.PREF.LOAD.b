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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE EB.ARC
    SUBROUTINE UPDATE.USER.ACCT.PREF.LOAD
*-----------------------------------------------------------------------------
* This is the load routine of the service UPDATE.USER.ACCT.PREF.LOAD
*-----------------------------------------------------------------------------
* Modifications:
* 18/05/15 - Enhancement - 1226758 / Task: 1347374
*            Create and update account groups based on channel permission
*
* 13/07/15 - Enhancement - 1326996 / Task 1399931
*			 Incorporation of EB_ARC component
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Service
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*--------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*
    RETURN
***</region>
*--------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*
    RETURN
***</region>
*-------------------------------------------------------------------------
END
