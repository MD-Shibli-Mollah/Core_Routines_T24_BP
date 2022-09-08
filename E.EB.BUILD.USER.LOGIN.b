* @ValidationCode : MjotMTY2MDg5MDEwOTpDcDEyNTI6MTU1MzE4NDI1MTI5OTpkbWF0ZWk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4xOjE0OjEw
* @ValidationInfo : Timestamp         : 21 Mar 2019 18:04:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 10/14 (71.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
* 26/02/19- New Development
* Purpose - The routine is used to get the ID for the current user.
*-----------------------------------------------------------------------------
$PACKAGE EB.Channels
SUBROUTINE E.EB.BUILD.USER.LOGIN(ENQ.DATA)
*-----------------------------------------------------------------------------
* Modification History
*
* 12/02/2019 - Enhancement 2875458 / Task 3025789 - Migration to IRIS R18
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*--------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables</desc>
INITIALISE:
    USER.ID = ''
    
RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>the main process</desc>
PROCESS:

    DEFFUN 	System.getVariable()
    USER.ID = ENQ.DATA<4,1>    ;* get the user ID sent from selection
    IF USER.ID EQ '' THEN
		USER.ID = EB.SystemTables.getOperator()   ;* get the current user ID logged in
	    ENQ.DATA<2,-1> = "@ID"
	    ENQ.DATA<3,-1> = "EQ"
	    ENQ.DATA<4,-1> = USER.ID   ;* set the output for the build routine
    END

RETURN
*** </region>
*--------------------------------------------------------------------------
END
