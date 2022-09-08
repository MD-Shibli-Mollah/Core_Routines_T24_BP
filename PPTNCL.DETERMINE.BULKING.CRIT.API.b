* @ValidationCode : MjoxNDUxMjMxOTc4OkNwMTI1MjoxNjA0MTM2MzcyODk1OmdtYW1hdGhhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMjAyMDAyMTItMDY0Njo1ODo0MQ==
* @ValidationInfo : Timestamp         : 31 Oct 2020 14:56:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gmamatha
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/58 (70.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.DETERMINE.BULKING.CRIT.API(iBulkingCriteriaDetails, oClearingBulking, oBulkingCriteriaResponse)
*-----------------------------------------------------------------------------
* Modification History :
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*31/10/2020 - Task 4054039 - Merged the CT/DD code changes from Criteria API.
*
*-----------------------------------------------------------------------------
    GOSUB logInput ; *
    GOSUB initialise ; *
    GOSUB process ; *
    GOSUB logOutput ; *
     
RETURN
*-------------------------------------------------------------------------------
*** <region name= logInput>
logInput:
*** <desc> </desc>
    CALL TPSLogging("Input Parameter", "PPTNCL.DETERMINE.BULKING.CRIT.API", "iBulkingCriteriaDetails : <":iBulkingCriteriaDetails:">", "")
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>
    clrgTxnType = ''
    outgoingMsgType = ''
    incomingMsgType = ''
    CONVERT @VM TO  @FM IN iBulkingCriteriaDetails
    clrgTxnType = iBulkingCriteriaDetails<PPTNCL.Foundation.BulkingCriteriaDetails.clearingTransactionType>
    outgoingMsgType = iBulkingCriteriaDetails<PPTNCL.Foundation.BulkingCriteriaDetails.outgoingMessageType>
    clearingCCY = iBulkingCriteriaDetails<PPTNCL.Foundation.BulkingCriteriaDetails.clearingCurrency>
    creadtiValDate = iBulkingCriteriaDetails<PPTNCL.Foundation.ClearingBulking.creditValueDate>
    
    
    oClearingBulking = ''
    oBulkingCriteriaResponse = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>
    GOSUB determineBulkPrint
    GOSUB determineFileformat
    
    IF clrgTxnType EQ 'CC' OR (clrgTxnType EQ 'CD' AND (outgoingMsgType EQ 'TUCGCQ84' OR outgoingMsgType EQ 'TUCGCQ82') ) THEN
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.creditValueDate> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.clearingNatureCode> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.fileFormat> = 'PPTNCL#':clrgTxnType:'#':outgoingMsgType:'#':clearingCCY:'#':creadtiValDate
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
determineBulkPrint:

    IF clrgTxnType EQ 'DD' AND outgoingMsgType EQ 'TUNCLGDD' THEN
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.genericCriteriaInput1> = 'Y'
    END
    IF clrgTxnType EQ 'DD' AND outgoingMsgType EQ 'TNCGDDRJ' THEN
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.creditValueDate> = 'Y'
    END
    IF clrgTxnType MATCHES 'CT':@VM:'RT' THEN
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPTNCL.Foundation.ClearingBulking.creditValueDate> = 'Y'
    END
    
RETURN
*------------------------------------------------------------------------------
determineFileformat:

    BEGIN CASE
        CASE clrgTxnType EQ 'DD' AND outgoingMsgType EQ 'TUNCLGDD'
            oClearingBulking<PPTNCL.Foundation.ClearingBulking.fileFormat> = 'TUNCLG#DD'
        CASE clrgTxnType EQ 'DD' AND outgoingMsgType EQ 'TNCGDDRJ'
            oClearingBulking<PPTNCL.Foundation.ClearingBulking.fileFormat> = 'TUNCLG#RJ'
        CASE clrgTxnType EQ 'CT'
            oClearingBulking<PPTNCL.Foundation.ClearingBulking.fileFormat> = 'TUNCLG#CT'
        CASE clrgTxnType EQ 'RT'
            oClearingBulking<PPTNCL.Foundation.ClearingBulking.fileFormat> = 'TUNCLG#RT'
    END CASE
    
RETURN
*------------------------------------------------------------------------------
*** <region name= logOutput>
logOutput:
*** <desc> </desc>
    CALL TPSLogging("Output Parameter", "PPTNCL.DETERMINE.BULKING.CRIT.API", "oClearingBulking : <":oClearingBulking:">", "")
    CALL TPSLogging("Output Parameter", "PPTNCL.DETERMINE.BULKING.CRIT.API", "oBulkingCriteriaResponse : <":oBulkingCriteriaResponse:">", "")
RETURN
*** </region>
*------------------------------------------------------------------------------
END
