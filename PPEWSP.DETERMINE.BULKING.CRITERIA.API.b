* @ValidationCode : MjoxMzI0MTQ5NDk5OkNwMTI1MjoxNjAyNzUxOTMwNTEyOnNrYXlhbHZpemhpOjE0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE5LTA0NTk6Nzk6NzE=
* @ValidationInfo : Timestamp         : 15 Oct 2020 14:22:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 14
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 71/79 (89.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPEWSP.Foundation
SUBROUTINE PPEWSP.DETERMINE.BULKING.CRITERIA.API(iBulkingCriteriaDetails, oClearingBulking, oBulkingCriteriaResponse)
*-----------------------------------------------------------------------------
*
* iBulkingCriteriaDetails(IN) :IN parameter will hold values required for determining bulking criteria.
* oClearingBulking(OUT) :OUT parameter carries bulk criteria and format.
* oBulkingCriteriaResponse(OUT) :OUT parameter of the routine.
*
* Program Description:
*  This program is used to determine the bulkingCriteria that needs to be created for EWSEPA clearing and will be called from "submitForClearingSettelement" routine.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 01/09/2020 - Enhancement 3831744 / Task 3910362 - EWSEPA - Routine designed for determining bulking criteria.
*01/10/2020 - Enhancement 3831888/Task 4000154 - Payments- NN bank - Equens DD � Cancellation and R-messages
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process

RETURN
*------------------------------------------------------------------------------
initialise:
*
    iClearingTransactionType = ''
    CONVERT @VM TO  @FM IN iBulkingCriteriaDetails
    iClearingTransactionType = iBulkingCriteriaDetails<PPEWSP.Foundation.BulkingCriteriaDetails.clearingTransactionType>
    iOutgoingMessageType = iBulkingCriteriaDetails<PPEWSP.Foundation.BulkingCriteriaDetails.outgoingMessageType>
    iCreditValueDate = iBulkingCriteriaDetails<PPEWSP.Foundation.BulkingCriteriaDetails.creditValueDate>
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
    
    IF iClearingTransactionType EQ 'DD' AND iOutgoingMessageType EQ 'pacs.002' THEN
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.bulkSendersReference> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.debitValueDate> = 'Y'
    END

    IF (iClearingTransactionType EQ 'DD'AND iOutgoingMessageType NE 'pacs.002') OR iClearingTransactionType EQ 'RF' OR iClearingTransactionType EQ 'RD' OR iClearingTransactionType EQ 'RJ' OR iClearingTransactionType EQ 'RV' OR iClearingTransactionType EQ 'CR-DD' THEN
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.bankOperationCode> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.debitValueDate> = 'Y'
    END
    IF iClearingTransactionType EQ 'RI-CA' OR iClearingTransactionType EQ 'RI-CM' OR iClearingTransactionType EQ 'CA' OR iClearingTransactionType EQ 'CM' THEN
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.bulkSendersReference> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
    END
    IF iClearingTransactionType EQ 'CT' OR iClearingTransactionType EQ 'RT' THEN
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.creditValueDate> = 'Y'
    END
    IF iClearingTransactionType EQ 'RI' OR iClearingTransactionType EQ 'CR'  THEN
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
    END
* For pacs.028 if criteria configuration API is configured, the STEP2 API will enrich generic criteria input as bulkReference
* and hence pacs.028 will be bulked based on the bulkreference of the original message.
    IF iClearingTransactionType EQ 'SR-CA' OR iClearingTransactionType EQ 'SR-CM' OR iClearingTransactionType EQ 'SR' THEN
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPEWSP.Foundation.ClearingBulking.genericCriteriaInput1> = 'Y'
    END

RETURN
*------------------------------------------------------------------------------
determineFileformat:

    BEGIN CASE
    
        CASE iClearingTransactionType EQ 'CT'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#CT'
        CASE iClearingTransactionType EQ 'RT'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#RT'
        CASE iClearingTransactionType EQ 'CR'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#CR'
        CASE iClearingTransactionType EQ 'RI'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#RI'
        CASE iClearingTransactionType EQ 'RI-CA'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'IQF#EWSEPA#RI-CA'
        CASE iClearingTransactionType EQ 'RI-CM'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'IQF#EWSEPA#RI-CM'
        CASE iClearingTransactionType EQ 'SR'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#SR'
        CASE iClearingTransactionType EQ 'CA'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'IQF#EWSEPA#CA'
        CASE iClearingTransactionType EQ 'CM'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'IQF#EWSEPA#CM'
        CASE iClearingTransactionType EQ 'DD' AND iOutgoingMessageType NE 'pacs.002'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#DD'
        CASE iClearingTransactionType EQ 'RV'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#RV'
        CASE iClearingTransactionType EQ 'RF'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#RF'
        CASE iClearingTransactionType EQ 'RD'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#RD'
        CASE iClearingTransactionType EQ 'DD' AND iOutgoingMessageType EQ 'pacs.002'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#RJ'
        CASE iClearingTransactionType EQ 'CR-DD'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'EWSEPA#CR-DD'
        CASE iClearingTransactionType EQ 'SR-CA'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'IQF#EWSEPA#SR-CA'
        CASE iClearingTransactionType EQ 'SR-CM'
            oClearingBulking<PPEWSP.Foundation.ClearingBulking.fileFormat> = 'IQF#EWSEPA#SR-CM'
    END CASE
    
RETURN

*------------------------------------------------------------------------------S
END
