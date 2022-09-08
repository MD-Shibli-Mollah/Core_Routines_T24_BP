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

* Version 9 5/11/00  GLOBUS Release No. G11.1.01 11/12/00
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.ONSTOP.ACCT.OFF.CHK.RTN(ENQ.DATA)
******************************************************************
* This program extracts the id of the USER who is trying to authorise the record using the enquiry
* ONE.STOP.PENDING.ACTIVITIES. It checks the DEPARTMENT.CODE of the user and compares it with the
* ACCT.OFFICER field of the corresponding record in the PW.PARTICIPANT
*-----------------------------------------------------------------------------
* Modification History:
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Security
    $USING EB.DataAccess

    $INSERT I_DAS.PW.PARTICIPANT

*************************************************************************

    GOSUB INITIALISE
    GOSUB ACCT.OFF.CHECK


INITIALISE:

    THE.ARGS = ""; THE.LIST = ""

    THE.ARGS<1> = ""
    RETURN

ACCT.OFF.CHECK:

    Y.DEPARTMENT.CODE = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>

    THE.LIST = dasPwParticipantDao
    THE.ARGS = Y.DEPARTMENT.CODE
    TABLE.SUFFIX = ""

    EB.DataAccess.Das("PW.PARTICIPANT",THE.LIST,THE.ARGS,TABLE.SUFFIX)

    LOCATE "OWNER" IN ENQ.DATA<2,1> SETTING OWNER.POS THEN
    ENQ.DATA<4,OWNER.POS> = THE.LIST
    END ELSE
    ENQ.DATA<4,OWNER.POS> = ""
    END

    RETURN
