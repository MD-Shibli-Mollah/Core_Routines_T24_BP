* @ValidationCode : MTo4NjA3NzI0MjQ6VVRGLTg6MTQ3MDA2MzQ3MjEyNDprYW5hbmQ6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYwNy4x
* @ValidationInfo : Timestamp         : 01 Aug 2016 20:27:52
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : kanand
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Channels
    SUBROUTINE E.TC.CONV.ACT.TRANS.RIGHTS
*-----------------------------------------------------------------------------
* Description
*--------------------
* This conversion routine is used to find the trans rights for the account of this external user
*-------------------
* Routine type       : Conversion Routine.
* IN Parameters      : ACCT.ID
* Out Parameters     : TRANS.VAR(YES/NO)
*
*-----------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1694533 / Task - 1748326
*            TCIB16 Product Development
*
*-----------------------------------------------------------------------------
    $USING EB.Reports

*-----------------------------------------------------------------------------
    DEFFUN System.getVariable()
    GOSUB PROCESS
    RETURN
*-------------------------------------------------------------------------------------------------
PROCESS:
*-------
    ACCT.ID = ''; TRANS.VAR = ''; R.ACCOUNT = '' ; ERR.ACCOUNT = '';*Initialising variables

    ACCT.ID = EB.Reports.getOData() ;*current id

    TRANS.ACCOUNTS = System.getVariable("EXT.SMS.ACCOUNTS") ;*getting the trans accounts
    CONVERT @SM TO @VM IN TRANS.ACCOUNTS
    LOCATE ACCT.ID IN TRANS.ACCOUNTS<1,1> SETTING VAR.POS THEN
    TRANS.VAR = "YES"       ;*Setting trans variable as Yes
    END ELSE
    TRANS.VAR = "NO"        ;*Setting trasn variable as No for false scenario
    END
*
    IF TRANS.VAR NE '' THEN
        EB.Reports.setOData(TRANS.VAR);*Assigning the result variable to the enquiry output
    END

    RETURN
*--------------------------------------------------------------------------------------------------

    END
