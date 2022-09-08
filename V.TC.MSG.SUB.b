* @ValidationCode : MjoxNjY4MzcwODkwOmNwMTI1MjoxNTUyMzIzNjY4NDc3OnNtdWdlc2g6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4xOjE4OjE1
* @ValidationInfo : Timestamp         : 11 Mar 2019 22:31:08
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/18 (83.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE EB.Channels
SUBROUTINE V.TC.MSG.SUB
*-----------------------------------------------------------------------------
* This routine is attached to the version EB.SECURE.MESSAGE,TC.REPLY to update
* subject and parent message id while replying to a secure message
*------------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
* Modification history:
*-----------------------
* 24/05/16 - Enhancement 1694532 / Task 1741992
*            Populate the parent message id field
* 10/03/19 - Enhancement 2875480  / Task 3018245
*            Adding Parent Message Id constion for reply messages
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>

    $USING EB.ARC
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    $USING EB.ErrorProcessing

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>
*-----------------------------------------------------------------------------

    ParentMsgId = EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmParentMessageId)
    IF ParentMsgId NE '' THEN
        RecEsm = EB.ARC.SecureMessage.Read(ParentMsgId,ER)
	    IF RecEsm THEN
	        RecEsm<EB.ARC.SecureMessage.SmToStatus> = "READ" ;* Set message status of previous message to READ
	        IF RecEsm<EB.ARC.SecureMessage.SmSubject>[1,3] NE "Re:"  THEN ;* Set subject for the current message
	            EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmSubject, "Re: ":EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmSubject))
	        END
	        IF RecEsm<EB.ARC.SecureMessage.SmParentMessageId> THEN ;* Set parent message id for the current message
	            EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmParentMessageId, RecEsm<EB.ARC.SecureMessage.SmParentMessageId>)
	        END ELSE
	            RecEsm<EB.ARC.SecureMessage.SmParentMessageId> = ParentMsgId
	            EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmParentMessageId, ParentMsgId)
	        END
	        EB.ARC.SecureMessageWrite(ParentMsgId,RecEsm,'')
	    END
    END
RETURN
*** </region>
*----------------------------------------------------------------------------
