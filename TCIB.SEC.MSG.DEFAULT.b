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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE TCIB.SEC.MSG.DEFAULT
*-----------------------------------------------------------------------------
* Attached to     : IM.DOCUMENT.IMAGE,TCIB.CAPTURE Version as a Check Record Routine.
* Incoming        : PW.ACTIVITY.TXN id value.
* Outgoing        : Defaulted applciation name in IM.DOC.IMAGE.APPLICATION
*-----------------------------------------------------------------------------
* Description:
* Subroutine to default the applciation name in IM.DOC.IMAGE.APPLICATION.
*-----------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 956564/Task 1039722
*            TCIB : Retail (Secure Message Attachments)
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING IM.Foundation
    $USING PW.Foundation

*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*
*************************************************************************************
INITIALISE:
*************************************************************************************
*

    RETURN
*
**************************************************************************************
PROCESS:
**************************************************************************************
*
    R.PW.ACTIVITY.TXN = '' ; ERR.PW.ACTIVITY.TXN = ''

    R.PW.ACTIVITY.TXN = PW.Foundation.ActivityTxn.Read(PW.Foundation.getActivityTxnId(), ERR.PW.ACTIVITY.TXN) ;* get the activity txn id
    IF R.PW.ACTIVITY.TXN <> "" THEN
        Y.PW.ORG.PROCESS = R.PW.ACTIVITY.TXN<PW.Foundation.ActivityTxn.ActTxnOriginateProcess>
        R.PROCESS = ''
        R.PROCESS = PW.Foundation.Process.Read(Y.PW.ORG.PROCESS, "E")
        IF (R.PROCESS<1> EQ "SECURE.MESSAGE.FLOW") OR (R.PROCESS<1> EQ "SECURE.MSG.REPLY.FLOW") THEN
            EB.SystemTables.setRNew(IM.Foundation.DocumentImage.DocImageApplication, "EB.SECURE.MESSAGE");* Default the application name based on the above condition.
        END
    END
    RETURN
*
    END
