* @ValidationCode : MjoxMzE1NzMzNTQ6Q3AxMjUyOjE2MDM4MTQ1NjExNDM6amF5YXNocmVldDo5OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA3LjIwMjAwNzAxLTA2NTc6NTY6NTI=
* @ValidationInfo : Timestamp         : 27 Oct 2020 21:32:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/56 (92.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------------------------------
$PACKAGE PPNPCT.Foundation
SUBROUTINE PPNPCT.DETERMINE.BULKING.CRITERIA.API(iBulkingCriteriaDetails, oClearingBulking, oBulkingCriteriaResponse)
*-----------------------------------------------------------------------------
*
* iBulkingCriteriaDetails(IN) :IN parameter will hold values required for determining bulking criteria.
* oClearingBulking(OUT) :OUT parameter carries bulk criteria and format.
* oBulkingCriteriaResponse(OUT) :OUT parameter of the routine.
*
* Program Description:
*  This program is used to determine the bulkingCriteria that needs to be created for Nordic CT clearing and will be called from "submitForClearingSettelement" routine.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*23/10/2020 - Enhancement 3852940/Task 4017144 - Nordic CT - Routine designed for determining bulking criteria.
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process

RETURN
*------------------------------------------------------------------------------
initialise:
*
    iClearingTransactionType = ''
    CONVERT @VM TO  @FM IN iBulkingCriteriaDetails
    iClearingTransactionType = iBulkingCriteriaDetails<PPNPCT.Foundation.BulkingCriteriaDetails.clearingTransactionType>
    iOutgoingMessageType = iBulkingCriteriaDetails<PPNPCT.Foundation.BulkingCriteriaDetails.outgoingMessageType>
    iCreditValueDate = iBulkingCriteriaDetails<PPNPCT.Foundation.BulkingCriteriaDetails.creditValueDate>
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
   
    IF iClearingTransactionType EQ 'RI-CA' OR iClearingTransactionType EQ 'RI-CM' OR iClearingTransactionType EQ 'CA' OR iClearingTransactionType EQ 'CM' THEN
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.bulkSendersReference> = 'Y'
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
    END
    IF iClearingTransactionType EQ 'CT' OR iClearingTransactionType EQ 'RT' THEN
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.clearingTransactionType> = 'Y'
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.creditValueDate> = 'Y'
    END
    IF iClearingTransactionType EQ 'RI' OR iClearingTransactionType EQ 'CR' THEN
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
    END
* For pacs.028 if criteria configuration API is configured, the STEP2 API will enrich generic criteria input as bulkReference
* and hence pacs.028 will be bulked based on the bulkreference of the original message.
    IF iClearingTransactionType EQ 'SR-CA' OR iClearingTransactionType EQ 'SR-CM' OR iClearingTransactionType EQ 'SR' THEN
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.outgoingMessageType> = 'Y'
        oClearingBulking<PPNPCT.Foundation.ClearingBulking.genericCriteriaInput1> = 'Y'
    END
    
RETURN
*------------------------------------------------------------------------------
determineFileformat:

    BEGIN CASE
    
        CASE iClearingTransactionType EQ 'CT'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'P27NP#CT'
        CASE iClearingTransactionType EQ 'RT'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'P27NP#RT'
        CASE iClearingTransactionType EQ 'CR'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'P27NP#CR'
        CASE iClearingTransactionType EQ 'RI'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'P27NP#RI'
        CASE iClearingTransactionType EQ 'SR'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'P27NP#SR'
        CASE iClearingTransactionType EQ 'CA'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'IQF#P27NP#CA'
        CASE iClearingTransactionType EQ 'CM'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'IQF#P27NP#CM'
        CASE iClearingTransactionType EQ 'SR-CA'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'IQF#P27NP#SR-CA'
        CASE iClearingTransactionType EQ 'SR-CM'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'IQF#P27NP#SR-CM'
        CASE iClearingTransactionType EQ 'RI-CA'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'IQF#P27NP#RI-CA'
        CASE iClearingTransactionType EQ 'RI-CM'
            oClearingBulking<PPNPCT.Foundation.ClearingBulking.fileFormat> = 'IQF#P27NP#RI-CM'
    END CASE
    
RETURN
*------------------------------------------------------------------------------
END
