* @ValidationCode : MjotNTAyODE1NTM4OkNwMTI1MjoxNjA2ODMzNjgwMjI3OnVtYW1haGVzd2FyaS5tYjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Dec 2020 20:11:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPINIP.Foundation
SUBROUTINE EBQA.VALIDATE.FOR.P27NIP
*-----------------------------------------------------------------------------
*
* This is a new api to perform clearing specific validation for P27NP payments.
* Validation checked for outgoing messages.
*
*-------------------------------------------------------------------------------------------------------------
* Modification History :
*--------------------------------------------------------------------------------------------------------------
*
* 30-Oct-2020 - Enhancement -385289 / task 3852900 - EBQA validation for P27NIP clearing
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

    IF  (iRecvAddr EQ '') AND (iOriginatorBIC NE '') THEN
        IF (iCancelReasonCode NE 'FRAD' AND iCancelAddlInfo NE '') THEN
            EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaCancelAddlInfo)
            EB.SystemTables.setEtext("CancelAddtlInfo can be input for ISO Cancel Code-CUST/Cancel Code FRAD")
            EB.ErrorProcessing.StoreEndError()
        END
    END
RETURN
*-------------------------------------------------------------------------------
validateCamt029:
*   To validate RejectAddtlInfo field wrt IsoReasonCode for outgoing camt.029 message.
    rejAddtlInfCount = DCOUNT(iRejectAddlInfo,@VM)
    
*   If the recall request was initiated by the originator (Customer).
    IF (iRecvAddr NE '') AND (iOriginatorBIC EQ '') THEN
        IF rejAddtlInfCount GT 11 THEN
            EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
            EB.SystemTables.setAv(rejAddtlInfCount)
            EB.SystemTables.setEtext("Maximum 11 occurances allowed")
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
*       First occurrence should start with AT53 followed by cancellation id (AT53201811182084633). Only if it is blank, we need to default the value.
        IF iRejectAddlInfo<1,1> EQ '' THEN
*IF iCancelReasonCode EQ 'AC03' THEN
*    iRejectAddlInfoVal = 'AT59':EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReqId)
*END ELSE
            iRejectAddlInfoVal = 'AT53':EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReqId)
            iRejectAddlInfo<1,1> = iRejectAddlInfoVal
*END
        END ELSE
*            BEGIN CASE
*                CASE iRejectAddlInfo<1,1> NE 'AT59':EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReqId) AND iCancelReasonCode EQ 'AC03'
*                    EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
*                    EB.SystemTables.setEtext("First Occurrences should hold 'AT59' followed by Cancellation Id value")
*                    EB.ErrorProcessing.StoreEndError()
*CASE
            IF (iRejectAddlInfo<1,1> NE '') AND (iRejectAddlInfo<1,1> NE 'AT53':EB.SystemTables.getRNew(DE.Messaging.EbQueriesAnswers.EbQaCancelReqId)) THEN
                EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("First Occurrences should hold 'AT53' followed by Cancellation Id value")
                EB.ErrorProcessing.StoreEndError()
            END
                
*            END CASE
        END

        IF iCancelReasonCode EQ 'AC03' THEN
            iRejectCount = 2
            LOOP
            WHILE iRejectCount LE rejAddtlInfCount
                iRejectAddlInfoLine = iRejectAddlInfo<1,iRejectCount>
                IF (iRejectAddlInfoLine[1,4] NE '') AND iRejectAddlInfoLine[1,4] NE 'AT59' THEN
                    iRejectAddlInfo<1,iRejectCount> = 'AT59':iRejectAddlInfo<1,iRejectCount>
*EB.SystemTables.setRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo, iRejectAddlInfo)
                END
                iRejectCount = iRejectCount + 1
            REPEAT
        END
         
            
        EB.SystemTables.setRNew(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo, iRejectAddlInfo)
    END

*   If the recall request was initiated by the bank (bank).
    IF (iRecvAddr EQ '') AND (iOriginatorBIC NE '') THEN
        IF iISORejectReasonCode EQ 'LEGL' THEN
            IF rejAddtlInfCount GT 2 THEN
                EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                EB.SystemTables.setAv(rejAddtlInfCount)
                EB.SystemTables.setEtext("Reject Addtl info is allowed only twice for the ISORejectReasonCode LEGL")
                EB.ErrorProcessing.StoreEndError()
            END
        END ELSE
            IF iRejectAddlInfo NE '' THEN
                EB.SystemTables.setAf(DE.Messaging.EbQueriesAnswers.EbQaRejectAddlInfo)
                EB.SystemTables.setAv(rejAddtlInfCount)
                EB.SystemTables.setEtext("Reject Addtl info is allowed only for the ISORejectReasonCode is LEGL")
                EB.ErrorProcessing.StoreEndError()
            END
        END
        
    END

RETURN
*--------------------------------------------------------------------------------
END

