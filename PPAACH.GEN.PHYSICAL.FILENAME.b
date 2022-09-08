* @ValidationCode : Mjo5OTY3MTE0MDE6Q3AxMjUyOjE2MTMwMzEwMTU5NDE6c2hhcm1hZGhhczozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjIwMjAxMTI4LTA2MzA6Njg6NTE=
* @ValidationInfo : Timestamp         : 11 Feb 2021 13:40:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sharmadhas
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/68 (75.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.GEN.PHYSICAL.FILENAME(iPaymentRecord,iAdditionalPaymentRecord,iGenericInfo,oFileName)
*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : skayalvizhi@temenos.com
* Program Name   : PPAACH.GEN.PHYSICAL.FILENAME
* Module Name    : PPAACH
* Component Name : PPAACH_Clearing
*-----------------------------------------------------------------------------
* Description    :
* Linked with    :
* In Parameter   :
* Out Parameter  :
*-----------------------------------------------------------------------------
* This is a new api which will be called from PP.Clearing PhysicalFileNameAPI to generate the outgoing fileName for CT and DD.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 11/07/2019 - Enhancement 3198007/Task 3226651 - Local Transfer - Domestic Payments - Standing Orders
* 24/07/2019 - Enhancement 3198007/Task 3244399 - Local Transfer - Domestic Payments - Standing Orders
*             - FileName for DD reclaim flow
* 11/05/2020 - 3733700:  Outgoing domestic payments files generated with .bco extension instead of actual bank code .072 -202003
* 23/09/2020 - 3982174: Outward Nacha file created with extension .072 instead of .159 - 202009
* 11/02/2021 - Enhancement 3912044 / Task 4211439: Added prefix value for outgoingMessageType ARGRSRJ - DD Reversal.
*                                                  Mapping of clearingID with originatingSource incase of outgoingMessageType is ARGRSRJ
*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowDASService
    $USING EB.SystemTables
    $USING PP.OutwardMappingFramework
    $USING PP.LocalClearingService
    
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process
    GOSUB finalise ;* Finalise the output value
RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables used </desc>
    
    CHANGE @VM TO @FM IN iPaymentRecord
    CHANGE @VM TO @FM IN iGenericInfo
    CHANGE @VM TO @FM IN iAdditionalPaymentRecord
    
    prefixValue = ''
    clearingNatureCode = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode>
    clearingTxnType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    currency = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    outgoingMessageType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    fileReference = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileName>
    clearingID = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outputChannel>
    companyId = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    currentDate = EB.SystemTables.getToday() ;* get TODAY date
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc></desc>
    GOSUB getPrefix
    GOSUB getClearingDetails
*Extension should be first 3 digits of sendingncc from PP.CLEARING record
    IF prefixValue NE '' AND fileReference NE '' THEN
        oFileName = prefixValue:currentDate[5,8]:fileReference:'.':oClrDetails<PP.LocalClearingService.ClrDetails.sendingNcc>[1,3]
    END ELSE
        oFileName = ''
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
getClearingDetails:
* Read Clearing details for Outgoing Payments to get the enrich API
    iClrRequest = ''
    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = companyId
*Mapping of clearingID with originatingSource incase of outgoingMessageType is ARGRSRJ
    IF iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType> EQ 'ARGRSRJ' THEN
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
    END ELSE
        iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = clearingID
    END
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    oClrDetails = ''
    oClrError = ''
    
    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
    
RETURN
*** <region name= getPrefix>
getPrefix:
*** <desc></desc>
    BEGIN CASE
        CASE clearingTxnType EQ 'CT' AND clearingNatureCode EQ 'CCD-220' AND currency EQ 'ARS'
            prefixValue = 'SPP'
        CASE clearingTxnType EQ 'CT' AND clearingNatureCode EQ 'CTX-220' AND currency EQ 'ARS'
            prefixValue = 'MPP'
        CASE clearingTxnType EQ 'CT' AND clearingNatureCode EQ 'CTX-220' AND currency EQ 'USD'
            prefixValue = 'MPD'
        CASE clearingTxnType EQ 'RT' AND clearingNatureCode EQ 'CCD-220' AND currency EQ 'ARS'
            prefixValue = 'SPP'
        CASE clearingTxnType EQ 'RT' AND clearingNatureCode EQ 'CTX-220' AND currency EQ 'ARS'
            prefixValue = 'MPP'
        CASE clearingTxnType EQ 'RT' AND clearingNatureCode EQ 'CTX-220' AND currency EQ 'USD'
            prefixValue = 'MRD'
        CASE clearingTxnType EQ 'DD' AND clearingNatureCode EQ 'PPD-200' AND currency EQ 'ARS'
            IF outgoingMessageType EQ 'ARGDDRJ' THEN
                prefixValue = 'DRP'
            END ELSE
                prefixValue = 'DPP'
            END
        CASE clearingNatureCode EQ 'PPD-200' AND currency EQ 'ARS' AND outgoingMessageType EQ 'ARGDDRVRJ'
            prefixValue = 'RRR'
*Added prefix value for outgoingMessageType ARGRSRJ - DD Reversal.
        CASE clearingTxnType EQ 'RV' AND currency EQ 'ARS' AND outgoingMessageType EQ 'ARGRSRJ'
            prefixValue = 'DRP'
        CASE (clearingTxnType EQ 'RF' OR clearingTxnType EQ 'RD') AND clearingNatureCode EQ 'PPD-200' AND currency EQ 'ARS'
            prefixValue = 'RRP'
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
finalise:
********
    CHANGE @FM TO @VM IN iPaymentRecord
    CHANGE @FM TO @VM IN iGenericInfo
    CHANGE @FM TO @VM IN iAdditionalPaymentRecord
RETURN
*------------------------------------------------------------------------------
END
