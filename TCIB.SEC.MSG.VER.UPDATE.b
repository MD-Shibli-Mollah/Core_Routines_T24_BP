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
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE TCIB.SEC.MSG.VER.UPDATE
*-----------------------------------------------------------------------------
* Attached to     : IM.DOCUMENT.IMAGE,TCIB.CAPTURE Version as a Check Record Routine
* Incoming        : PW.ACTIVITY.TXN id value
* Outgoing        : Defaulted applciation name in IM.DOC.IMAGE.APPLICATION
*-----------------------------------------------------------------------------
* Description:
* Subroutine to default the applciation name in IM.DOC.IMAGE.APPLICATION
*-----------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 956564/Task 1039722
*            TCIB : Retail (Secure Message Attachments)
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*-----------------------------------------------------------------------------
*
    $USING EB.ARC
    $USING EB.SystemTables
*
    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS
*
    RETURN
*************************************************************************************
INITIALISE:
*Initialise required fields

    RETURN
*************************************************************************************
OPENFILE:
*Open Required Files


    RETURN
**************************************************************************************
PROCESS:
* Update Upload and Subject details

    MSG.SUB = EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmSubject)
    UPLOAD.CHECK=FIELD(MSG.SUB,'*',2)
    ORIGINAL.SUBJECT=FIELD(MSG.SUB,'*',1)
    EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmUploadId, UPLOAD.CHECK)
    EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmSubject, ORIGINAL.SUBJECT)
*
    RETURN
***************************************************************************************
    END
