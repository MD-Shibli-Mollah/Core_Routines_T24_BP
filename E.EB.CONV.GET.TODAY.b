* @ValidationCode : MjotMTE1MDI3ODgzMDpDcDEyNTI6MTU1MzE4NDI0OTY0NDpkbWF0ZWk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4xOjg6OA==
* @ValidationInfo : Timestamp         : 21 Mar 2019 18:04:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/8 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE EB.Channels
SUBROUTINE E.EB.CONV.GET.TODAY
*-----------------------------------------------------------------------------
* *** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
*
* Modification History:
*---------------------
* 12/02/2019 - Enhancement 2875458 / Task 3025789 - Migration to IRIS R18
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.ARC
    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and do OPF </desc>
INITIALISE:
*---------
* Assign message id from common variable
    todayDate = ''
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Converting the message </desc>
PROCESS:
*------
* Get message details and replace the marker with "|" to send as a string

    todayDate = OCONV(DATE(),'D-')
    todayDate = todayDate[7,4]:todayDate[1,2]:todayDate[4,2]
    EB.Reports.setOData(todayDate)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
