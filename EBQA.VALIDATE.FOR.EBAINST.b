* @ValidationCode : MjoxODAzNTA0MjYyOmNwMTI1MjoxNTcxOTk1NzMyOTkwOmdtYW1hdGhhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMjAxOTA3MDUtMDI0Nzo0NTo0NQ==
* @ValidationInfo : Timestamp         : 25 Oct 2019 14:58:52
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : gmamatha
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/45 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190705-0247
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------------------------------
$PACKAGE PPIEBA.Foundation
SUBROUTINE EBQA.VALIDATE.FOR.EBAINST
*-------------------------------------------------------------------------------------------------------------
*
* This is a new api to perform clearing specific validation for EBAINST payments.
* Validation checked for outgoing camt.056 and camt.029 messages.
*
*-------------------------------------------------------------------------------------------------------------
* Modification History :
*--------------------------------------------------------------------------------------------------------------
* 30/09/2019 - Enh 3268239 / Task 3268242 - Payments - Clearing Specific Validations on EBQA
*              New clearing specific api to validate outgoing camt.056/camt.09 messages for EBAINST payments
*
*-------------------------------------------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING DE.Messaging
    
    GOSUB initialise ; *Initialise the variables used
    GOSUB process    ; *Generate a unique reference number

RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
initialise:
*** <desc>Initialise the variables used </desc>
    rejAddtlInfCount = ''
    iISOMessageType = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaISOMessageType)
    iCancelReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReasonCode)
    iISOReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaISOCancelReasonCode)
    iRejectAddlInfo = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
    iISORejectReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaISORejectReasonCode)
    iRejectReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectReasonCode)
    iAcceptReject = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaAcceptReject)
    directionVAL = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaDirection)
    iCancelAddlInfo = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelAddlInfo)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
process:
*** <desc> </desc>
    BEGIN CASE
        CASE iISOMessageType EQ 'camt.056' AND directionVAL EQ 'OUTWARD'   ;* For Outgoing camt.056 message
            GOSUB validateCamt056
        
        CASE iISOMessageType EQ 'camt.056' AND iAcceptReject EQ 'REJECT'   ;* For Outgoing camt.029 message
            GOSUB validateCamt029
        
    END CASE
    
RETURN
*** </region>
*-------------------------------------------------------------------------------
validateCamt056:
*   To validate CancelAddlInfo field wrt IsoReasonCode and Reason proprietary codes for outgoing camt.056 message.
    IF (iCancelAddlInfo NE '') AND (iISOReasonCode NE 'CUST') AND (iCancelReasonCode NE 'AM09' AND iCancelReasonCode NE 'AC03' AND iCancelReasonCode NE 'FRAD') THEN
        EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaCancelAddlInfo)
        EB.SystemTables.setEtext("CancelAddtlInfo can be inputted for ISO Cancel Code-CUST/Cancel Code-AM09 or AC03 or FRAD")
        EB.ErrorProcessing.StoreEndError()
    END
    
RETURN
*-------------------------------------------------------------------------------
validateCamt029:
*   To validate RejectAddtlInfo field wrt IsoReasonCode for outgoing camt.029 message.
    rejAddtlInfCount = DCOUNT(iRejectAddlInfo,@VM)
    BEGIN CASE
        CASE iISORejectReasonCode EQ 'LEGL'
            IF rejAddtlInfCount GT 2 THEN
                EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                EB.SystemTables.setAv(rejAddtlInfCount)
                EB.SystemTables.setEtext("Reject Addtl info is allowed only twice for the ISORejectReasonCode LEGL")
                EB.ErrorProcessing.StoreEndError()
            END
  
        CASE (iISORejectReasonCode EQ 'CUST') OR (iRejectReasonCode MATCHES 'ARDT':@VM:'AM04':@VM:'NOAS')
            IF rejAddtlInfCount GT 11 THEN
                EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                EB.SystemTables.setAv(rejAddtlInfCount)
                EB.SystemTables.setEtext("Occurrences of RejectAddlInfo cannot be more than 11 for given Reason Code")
                EB.ErrorProcessing.StoreEndError()
            END
    END CASE
    
RETURN
*--------------------------------------------------------------------------------
END

