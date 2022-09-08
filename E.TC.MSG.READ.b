* @ValidationCode : MTotMjMwODczMDIxOlVURi04OjE0NzAwNjI5NjM1MTk6cnN1ZGhhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDcuMQ==
* @ValidationInfo : Timestamp         : 01 Aug 2016 20:19:23
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE EB.Channels
    SUBROUTINE E.TC.MSG.READ(ENQ.DATA)
*-----------------------------------------------------------------------------
* Attached to     : Enquiry TC.EB.SECURE.MESSAGE.READ
* Attached as     : BUILD Routine
* Incoming        : ENQ.DATA Common varible
* outgoing        : ENQ.DATA
* Purpose         : To change the Message status to "READ"
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
* Modification history:
*-----------------------
* 24/05/16 - Enhancement 1694532 / Task 1741992
*            Change the status of the message to READ
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>

    $USING EB.ARC
    $USING EB.Reports
    $USING EB.SystemTables


*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and required varaibles </desc>
INITIALISE:
*---------
* Assign message id
    MSG.ID = ENQ.DATA<4,1>
    FnEsm = 'F.EB.SECURE.MESSAGE'
    FEsm = ''
    DEFFUN System.getVariable()
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Converting the message status </desc>
PROCESS:
*------
* Change the status of the message to READ while reading the message and set on which date it has been read
    OPEN FnEsm TO F.ESM THEN
        READ RecEsm FROM F.ESM,MSG.ID THEN
            RecEsm<EB.ARC.SecureMessage.SmToStatus> = "READ"
            IF (RecEsm<EB.ARC.SecureMessage.SmToStatus> = "READ" AND RecEsm<EB.ARC.SecureMessage.SmDateRead> = '') THEN
                RecEsm<EB.ARC.SecureMessage.SmDateRead> = System.getVariable("!SYSTEM.DATE")
            END
            WRITE RecEsm TO F.ESM,MSG.ID
            END
        END
        RETURN
*** </region>
        *-----------------------------------------------------------------------------
    END
