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
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE V.MB.AI.MSG.SUB
*-----------------------------------------------------------------------------
* This routine is used to update original parent message id & parent message id
* while creating a new secure message
*------------------------------------------------------------------------------
*                        M O D I F I C A T I O N S
*
* 26/06/13 - Enhancement 590517
*            TCIB support- original parent message id populated for the message
*
* 24/04/14 - Task 983288 / Defect 982274
*            ORIG.PARENT.MSG.ID field should be removed in EB.SECURE.MESSAGE application.
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*-----------------------------------------------------------------------------

    $USING EB.ARC
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:

    RETURN

PROCESS:
    ParentMsgId = EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmParentMessageId)
    RecEsm = EB.ARC.SecureMessage.Read(ParentMsgId,ER)
    IF RecEsm THEN
        RecEsm<EB.ARC.SecureMessage.SmToStatus> = "READ"
        IF RecEsm<EB.ARC.SecureMessage.SmSubject>[1,3] NE "Re:"  THEN
            EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmSubject, "Re: ":EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmSubject))
        END
        IF RecEsm<EB.ARC.SecureMessage.SmParentMessageId> THEN
            EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmParentMessageId, RecEsm<EB.ARC.SecureMessage.SmParentMessageId>)
        END ELSE
            RecEsm<EB.ARC.SecureMessage.SmParentMessageId> = ParentMsgId
            EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmParentMessageId, ParentMsgId)
        END
        EB.ARC.SecureMessageWrite(ParentMsgId,RecEsm,'')
    END

    RETURN
