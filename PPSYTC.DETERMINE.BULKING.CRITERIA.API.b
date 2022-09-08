* @ValidationCode : MjotMTE3NzYxMDY2OTpDcDEyNTI6MTYwMjc1MzgyNjEwMDpza2F5YWx2aXpoaTo4OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE5LTA0NTk6NDY6NDY=
* @ValidationInfo : Timestamp         : 15 Oct 2020 14:53:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 46/46 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.DETERMINE.BULKING.CRITERIA.API(iBulkingCriteriaDetails, oClearingBulking, oBulkingCriteriaResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History
* 2/3/2020 - Enhancement 3131018/ Task 3130941 - Routine to determine bulk print and file format
* 24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
* 6/4/2020 - Enhancement 3457582/Task 3457545 - Payments-Afriland - SYSTAC (CEMAC) - Cheque payments
* 3/8/2020 - Enhancement 3614846/Task 3854892 -Afriland - SYSTAC (CEMAC) - Resubmission of Direct Debits - Clearing
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PPSYTC.ClearingFramework
*------------------------------------------------------------------------------

    GOSUB setInputLog
    GOSUB initialise
    GOSUB process
    GOSUB setOutputLog

RETURN
*------------------------------------------------------------------------------
initialise:
*
    iClearingTransactionType = ''
    CONVERT @VM TO  @FM IN iBulkingCriteriaDetails
    iClearingTransactionType = iBulkingCriteriaDetails<PPSYTC.ClearingFramework.BulkingCriteriaDetails.clearingTransactionType>
    iOutgoingMessageType = iBulkingCriteriaDetails<PPSYTC.ClearingFramework.BulkingCriteriaDetails.outgoingMessageType>
    clearingNatureCode = iBulkingCriteriaDetails<PPSYTC.ClearingFramework.BulkingCriteriaDetails.genericCriteriaInput1>
    oClearingBulking = ''
    oBulkingCriteriaResponse = ''

RETURN
*------------------------------------------------------------------------------
process:

    GOSUB determineBulkPrint
    GOSUB determineFileformat


RETURN
*---------------------------------------------------------------------------------------
determineBulkPrint:

    IF iClearingTransactionType EQ 'CT' OR iClearingTransactionType EQ 'RT' OR iClearingTransactionType EQ 'DD' OR iClearingTransactionType EQ 'RJ' OR iClearingTransactionType EQ 'CC' OR iClearingTransactionType EQ 'RF' THEN
        oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.outgoingMessageType> = 'Y'

    END
    IF clearingNatureCode EQ 'REP' THEN
        oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.clearingNatureCode> = 'Y'
    END
RETURN
*------------------------------------------------------------------------------
determineFileformat:

    BEGIN CASE
        CASE iClearingTransactionType EQ 'CT'
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = 'SYSTAC#CT'

        CASE iClearingTransactionType EQ 'RT'
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = 'SYSTAC#RT'
    
        CASE iClearingTransactionType EQ 'DD' AND iOutgoingMessageType EQ 'SYSTACDD' AND clearingNatureCode EQ ''
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = 'SYSTAC#DD'
    
        CASE iClearingTransactionType EQ 'RJ' AND iOutgoingMessageType EQ 'SYSTACDDRJ'
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = 'SYSTAC#RJ'
    
        CASE iClearingTransactionType EQ 'CC' OR  iClearingTransactionType EQ 'RF'
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = iOutgoingMessageType
* bulking criteria for resubmitted DD
        CASE iClearingTransactionType EQ 'DD' AND iOutgoingMessageType EQ 'SYSTACDD' AND clearingNatureCode EQ 'REP'
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = 'SYSTACR#DD'
    
        CASE iClearingTransactionType EQ 'RJ' AND iOutgoingMessageType EQ 'SYTCRDDR'
            oClearingBulking<PPSYTC.ClearingFramework.ClearingBulking.fileFormat> = 'SYSTACR#RJ'
    END CASE
    
RETURN

*------------------------------------------------------------------------------S

setInputLog:
* Logging to see input

    CALL TPSLogging("Input Parameter", "PPSYTC.DETERMINE.BULKING.CRITERIA.API", "iBulkingCriteriaDetails : <":iBulkingCriteriaDetails:">", "")
*
RETURN

*------------------------------------------------------------------------------
setOutputLog:
* Logging to see output
    CALL TPSLogging("Output Parameter", "PPSYTC.DETERMINE.BULKING.CRITERIA.API", "oClearingBulking : <":oClearingBulking:">", "")
    CALL TPSLogging("Output Parameter", "PPSYTC.DETERMINE.BULKING.CRITERIA.API", "oBulkingCriteriaResponse : <":oBulkingCriteriaResponse:">", "")

*
RETURN

*------------------------------------------------------------------------------

END

