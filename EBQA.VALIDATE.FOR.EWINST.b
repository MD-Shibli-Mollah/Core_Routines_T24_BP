* @ValidationCode : MjotMzE3ODY5MjE4OmNwMTI1MjoxNTczMDQxNDQ0MTU5OmdtYW1hdGhhOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMjAxOTA3MDUtMDI0Nzo5Mjo3Nw==
* @ValidationInfo : Timestamp         : 06 Nov 2019 17:27:24
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : gmamatha
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 77/92 (83.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190705-0247
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------------------------------
$PACKAGE PPINCT.Foundation
SUBROUTINE EBQA.VALIDATE.FOR.EWINST
*-------------------------------------------------------------------------------------------------------------
*
* This is a new api to perform clearing specific validation for EWINST payments.
* Validation checked for outgoing camt.056 and camt.029 messages.
*
*-------------------------------------------------------------------------------------------------------------
* Modification History :
*--------------------------------------------------------------------------------------------------------------
* 30/09/2019 - Enh 3268239 / Task 3268242 - Payments - Clearing Specific Validations on EBQA
*              New clearing specific api to validate outgoing camt.056/camt.09 messages for EWINST payments
* 04/11/2019 - Defect 3420907 / Task 3381984 - ISOCancelReason code AC03 should be checked rejectAddl mapping for camt.029 message.
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
    iRejectCount = ''
    iRejectInfoVal = ''
    iFirstRejectAddlInfo = ''
    iISOMessageType = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaISOMessageType)
    iCancelReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReasonCode)
    iISOReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaISOCancelReasonCode)
    iRejectAddlInfo = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
    iRecvAddr = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaRecvAddr)
    iOriginatorBIC = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaOriginatorBIC)
    iISORejectReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaISORejectReasonCode)
    iAcceptReject = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaAcceptReject)
    directionVAL = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaDirection)
    iCancelAddlInfo = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelAddlInfo)
    iRejectReasonCode = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectReasonCode)
    cancelRecID = EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReqId)
    recallCount = DCOUNT(cancelRecID,@VM)
    
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
*   To validate RejectAddtlInfo field wrt IsoReasonCode and Reason proprietary codes for outgoing camt.056 message.
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
*   If the recall request was initiated by the bank.
    IF (iRecvAddr EQ '') AND (iOriginatorBIC NE '') THEN
        BEGIN CASE
            CASE iISORejectReasonCode EQ 'LEGL'
                IF rejAddtlInfCount GT 2 THEN
                    EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                    EB.SystemTables.setAv(rejAddtlInfCount)
                    EB.SystemTables.setEtext("Reject Addtl info is allowed only twice for the ISORejectReasonCode LEGL")
                    EB.ErrorProcessing.StoreEndError()
                END
            CASE 1
                IF (iRejectAddlInfo NE '') AND (iRejectReasonCode EQ '') THEN
                    EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                    EB.SystemTables.setAv(rejAddtlInfCount)
                    EB.SystemTables.setEtext("Reject Addtl Info not allowed for given Reason Code")
                    EB.ErrorProcessing.StoreEndError()
                END
        END CASE
    END
    
*   If the recall request was initiated by the originator (Customer).
    IF (iRecvAddr NE '') AND (iOriginatorBIC EQ '') THEN
        iFirstRejectAddlInfo = 'AT53':cancelRecID<1,recallCount>
        IF (iRejectAddlInfo<1,1> NE '') AND (iRejectAddlInfo<1,1> NE iFirstRejectAddlInfo) THEN
            EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
            EB.SystemTables.setEtext("First Occurrences should hold 'AT53' followed by Cancellation Id value")
            EB.ErrorProcessing.StoreEndError()
        END
    
*       First occurrence should start with AT53 followed by cancellation id (AT53201811182084633). Only if it is blank, we need to default the value.
        IF iRejectAddlInfo<1,1> EQ '' THEN
            iRejectAddlInfoVal = 'AT53':EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReqId)
            iRejectAddlInfo<1,1> = iRejectAddlInfoVal
            EB.SystemTables.setRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo, iRejectAddlInfo)
        END
    
*       If the Cancel reason code was AC03 in the recall request (camt.056) initiated by the originator
*       then first occurrence will be defaulted with AT53 followed by cancellation id
*       and the remaining ten occurrences starting with AT59 followed by any related information (free text)
        iRejectCount = 2
        IF iCancelReasonCode EQ 'AC03' THEN
            LOOP
            WHILE iRejectCount LE rejAddtlInfCount
                iRejectInfoVal = iRejectAddlInfo<1,iRejectCount>
                IF (iRejectInfoVal[1,4] NE '') AND iRejectInfoVal[1,4] NE 'AT59' THEN
                    EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                    EB.SystemTables.setAv(iRejectCount)
                    EB.SystemTables.setEtext("Occurrences of RejectAddlInfo should always begins with AT59 followed by User Free text")
                    EB.ErrorProcessing.StoreEndError()
                END ELSE
                    IF iRejectInfoVal[1,4] EQ '' THEN
                        iRejectAddlInfo<1,iRejectCount> = 'AT59'
                        EB.SystemTables.setRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo, iRejectAddlInfo)
                    END
                END
                iRejectCount = iRejectCount + 1
            REPEAT
        END
    
        IF rejAddtlInfCount GT 11 THEN
            EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
            EB.SystemTables.setAv(rejAddtlInfCount)
            EB.SystemTables.setEtext("Occurrences of RejectAddlInfo cannot be more than 11")
            EB.ErrorProcessing.StoreEndError()
        END
    END
       
RETURN
*--------------------------------------------------------------------------------
END

