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
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE E.TC.FILTER.EXT.ARRANGEMENT(ENQ.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Routine type       : Build Routine
* Attached To        : ENQUIRY>AA.ARRANGEMENT.LIST.TCIB
* Purpose            : This routine used to form the selection criteria for arrangement based on Channel and Customer
*--------------------------------------------------------------------------------------------------------------------
* Modification History
*--------------------
* 19/05/15 - Enhancement 1207209/ Task 1278019
*            Validation for External User Channel and Arrangement Channel
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
***-----------------------------------------------------------------------------
    $USING AA.ARC
    $USING AA.Framework
    $USING EB.ARC
    $USING EB.SystemTables
    $INSERT I_DAS.AA.ARRANGEMENT

    GOSUB INITIALISE
    GOSUB PROCESS
*
    CONVERT @VM TO ' ' IN RESULT.ARRAY
    ENQ.DATA<2,1>='@ID'       ;* include the @ID field in the selection
    ENQ.DATA<3,1>='EQ'        ;* include the operand
    ENQ.DATA<4,1>= RESULT.ARRAY         ;* include the data
*
    RETURN
*-----------------------------------------------------------------------------
*** <region name=INITIALISE >
INITIALISE:
*** <desc> Initialise required variables</desc>
    EXT.CHANNEL=EB.SystemTables.getRNew(EB.ARC.ExternalUser.XuChannel)    ;* To get the EXTERNAL USER channel
    THE.LIST=DAS.AA.ARRANGEMENT$CUSTOMER          ;* Argument to get the arrangement for appropriate customer
    THE.ARGS=EB.SystemTables.getRNew(EB.ARC.ExternalUser.XuCustomer)
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Get the arrangement list for the particular customer</desc>
    CALL DAS('AA.ARRANGEMENT',THE.LIST,THE.ARGS,'')         ;* Get the arrangement list for the customer
    LOOP
        REMOVE ARR.ID FROM THE.LIST SETTING ARR.POS         ;* Remove the arrangement Id from the list
    WHILE ARR.ID:ARR.POS
        EXT.ARR.ID = ARR.ID:'//AUTH'    ;*Take the authorised arrangement of the active channel
        PROPERTY.CLASS = 'USER.RIGHTS'  ;* Property class name
        R.USER.RIGHTS.REC=''  ;* Initialise the User Rights record
        AA.Framework.GetArrangementConditions(EXT.ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,PROPERTY.RECORD,RET.ERR)        ;* Get arrangement condition record
        IF NOT(RET.ERR) THEN
            R.USER.RIGHTS.REC = RAISE(PROPERTY.RECORD)      ;* Raise the Position of the record
            PROP.ALLOWED.CHNL = R.USER.RIGHTS.REC<AA.ARC.UserRights.UsrRgtAllowedChannel>   ;*Allowed channel of arrangement in user rights property
            LOCATE EXT.CHANNEL IN PROP.ALLOWED.CHNL<1,1> SETTING CHNL.POS THEN  ;* Locate the current channel in User rights allowed channel list and then form RESULT array
            RESULT.ARRAY<1,-1>=ARR.ID
        END
    END
    REPEAT
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
