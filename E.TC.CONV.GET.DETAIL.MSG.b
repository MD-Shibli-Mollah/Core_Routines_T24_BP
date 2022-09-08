* @ValidationCode : MTotOTAyODI1NjIwOlVURi04OjE0NzAwNjI5NjM0NTI6cnN1ZGhhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDcuMQ==
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
    SUBROUTINE E.TC.CONV.GET.DETAIL.MSG
*-----------------------------------------------------------------------------
* Subroutine to get the full message from a EB.SECURE.MESSAGE and returns the
* message by replacing VM with a separator '|'. This routine attached as a
* conversion routine to the enquiry TC.EB.SECURE.MESSAGE
*-----------------------------------------------------------------------------
* *** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
*
* Modification History:
*---------------------
* 24/05/16 - Enhancement 1694532 / Task 1741992
*            Populate the parent message id field
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
    MSG.ID = EB.Reports.getOData()
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Converting the message </desc>
PROCESS:
*------
* Get message details and replace the marker with "|" to send as a string
    R.MSG = EB.ARC.SecureMessage.Read(MSG.ID,MSG.ERR)
    IF NOT(MSG.ERR) THEN
        OUT.MSG = R.MSG<EB.ARC.SecureMessage.SmMessage>
        CONVERT @VM TO "|" IN OUT.MSG
        EB.Reports.setOData(OUT.MSG)
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
