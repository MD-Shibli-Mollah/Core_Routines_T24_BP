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
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE V.TC.EXT.ARR.CHANNEL
*--------------------------------------------------------------------------------------------------------------------
* Routine type       : Conversion Routine
* Attached To        : ENQUIRY>AA.ARRANGEMENT.LIST.TCIB
* Purpose            : This routine is used to list the channel for arrangement
*--------------------------------------------------------------------------------------------------------------------
* Modification History
*--------------------
* 19/05/15 - Enhancement 1207209/ Task 1278019
*            Validation for External User Channel and Arrangement Channel
***-----------------------------------------------------------------------------

    $USING AA.ARC
    $USING AA.Framework
    $USING EB.Reports
*
    GOSUB INITIALISE
    GOSUB PROCESS
    EB.Reports.setOData(PROP.ALLOWED.CHNL);* Assign the channel details to O.DATA
*
    RETURN
*-----------------------------------------------------------------------------
*** <region name=INITIALISE >
INITIALISE:
*** <desc> Initialise required variables</desc>
    ARR.ID = EB.Reports.getOData():'//AUTH'  ;*Get the arrangement Id
    PROPERTY.CLASS = 'USER.RIGHTS'      ;* Property class name
    R.USER.RIGHTS.REC=''      ;* Initialise the User Rights record
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Get the arrangement list for the particular customer</desc>
    AA.Framework.GetArrangementConditions(ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,PROPERTY.RECORD,RET.ERR)    ;* Get arrangement condition record
    IF NOT(RET.ERR) THEN
        R.USER.RIGHTS.REC = RAISE(PROPERTY.RECORD)          ;* Raise the Position of the record
        PROP.ALLOWED.CHNL = R.USER.RIGHTS.REC<AA.ARC.UserRights.UsrRgtAllowedChannel>       ;*Allowed channel of arrangement in user rights property
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
