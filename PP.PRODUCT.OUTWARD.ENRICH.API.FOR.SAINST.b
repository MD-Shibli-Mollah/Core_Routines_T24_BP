* @ValidationCode : MjoxMzgzMDY2OTY4OkNwMTI1MjoxNjA5ODU1MzgxNTIyOmd2YWl0aGlzaHdhcmFuOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMToxMDM6ODQ=
* @ValidationInfo : Timestamp         : 05 Jan 2021 19:33:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gvaithishwaran
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 84/103 (81.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPISIP.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.SAINST(iPaymentDets, ioIFEmitDets)
*----------------------------------------------------------------------------------------------------------------------------------------
** This API returns the Instruction ID which should be mapped to SendersReferenceOutgoing of POR.Transaction table.
* and a 34 digit Unique Trace number to uniquely identify each transaction. This API will be attached in the EnrichOutMessageAPI field of PP.CLEARING - SAINST
*-----------------------------------------------------------------------------
*
* Parameters:
*
* INOUT     iPaymentDets            string     incoming Payment Details
* INOUT     ioIFEmitDets             string     incoming IF Details
 
*    iPaymentDetailsA = ioIFEmitDets<2>
*    iPorTransaction = ioIFEmitDets<3>
*    iCancelReqRec = ioIFEmitDets<4>
*    iDebitAuthInfo = ioIFEmitDets<5>
*    iCreditPartyDet = ioIFEmitDets<6>
*    iPrtyDbtDetails = ioIFEmitDets<7>
*    iPaymentInformation = ioIFEmitDets<8>
*    iAdditionalInfDetails = ioIFEmitDets<9>
*    iAccInfoDetails = ioIFEmitDets<10>
*    iRemittanceInfo = ioIFEmitDets<11>
*    iPaymentFlowDets = ioIFEmitDets<12>
*    iRegulatoryRepDets = ioIFEmitDets<13>
*    iPorRelatedRemittanceInfo = ioIFEmitDets<14>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 27/09/2020 - Enhancement 3675355 / Task 3929661 - SAINST

* 05/01/2021 - Task 4163919 - added code to generate unique reference
*-----------------------------------------------------------------------------
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowGUI
    $USING PP.LocalClearingService
    $USING PP.OutwardInterfaceService
    $USING PP.SwiftOutService
    $USING EB.API
    $USING EB.SystemTables
    $USING PP.PaymentWorkflowDASService
    $USING PP.InwardMappingFramework
    $USING PP.DebitPartyDeterminationService
    $USING PP.OutwardMappingFramework
    
    
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <iPaymentDets:":iPaymentDets:">","")
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <ioIFEmitDets:":ioIFEmitDets:">","")
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <iPorTransactionDets:":iPorTransactionDets:">","")
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <senderRefoutgoing:":iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.sendersReferenceOutgoing>:">","")
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process ; *Generate a unique reference number based on the incoming parameters
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <iPaymentDets:":iPaymentDets:">","")
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <ioIFEmitDets:":ioIFEmitDets:">","")
    
RETURN
*-------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= Initialise Variables>
Initialise:
*** <desc>The variables are initialised </desc>
  
    companyID = ''
    ftNumber = ''
    
    companyID = FIELDS(iPaymentDets,'*',1)
    ftNumber = FIELDS(iPaymentDets,'*',2)
    
    iPorTransactionDets = RAISE(ioIFEmitDets<3>)
    iSupplementaryInfo = RAISE(ioIFEmitDets<12>)
    paymentChannelList = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefName>
        
    Record = ''
    readError = ''
  
    iLockingId = ''
    iAgentDigits = ''
    iRandomDigitsLen = ''
      
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= process>
Process:
*** <desc>generate 34 digit Instruction ID </desc>
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <iPorTransactionDets:":iPorTransactionDets:">","")
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <senderRefoutgoing:":iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.sendersReferenceOutgoing>:">","")

    IF iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.sendersReferenceOutgoing> EQ '' THEN
        GOSUB getScreeningDetails ; *Get the payment status from POR screening requests table
        GOSUB formInstructionID ;*Instruction ID which should be mapped to SendersReferenceOutgoing of POR.Transaction table
        GOSUB insertPsmBlob
        GOSUB outputParams ; *Send the required output parameters
    END
RETURN

*** </region>
*-------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= formInstructionID>
formInstructionID:
*** <desc>Instruction ID  generation for Saudi IPS clearing </desc>
*   UniqueTime = ''
* allocate unique time returns a 12 digit value unique across multiple sessions
*   EB.API.AllocateUniqueTime(UniqueTime)
*    CHANGE '.' TO '' IN UniqueTime
    
    oTimestamp = ''
    oTimestampResponse = ''
    PP.PaymentFrameworkService.createTimestamp(oTimestamp, oTimestampResponse)
    todayDate = oTimestamp[1,8]
    time = oTimestamp[9,4]
   
* generate unique reference

    iLockingId = 'PPISIP.UNIQUE.REF' ;* locking file record id
    iAgentDigits = '2';* length of the seq no from agent's relative position
    iRandomDigitsLen = '4' ;* length of the unique reference number  from locking record
    oUniqueReference = ""
    PP.OutwardMappingFramework.generateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen, "", oUniqueReference, "")
    uniqueId = oUniqueReference
    participantIdentifier =  iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.sendingNcc>
    channelcnt = 0
    LOOP
        REMOVE paymentChannel FROM paymentChannelList SETTING channelpos
    WHILE paymentChannel:channelpos
        channelcnt = channelcnt + 1
        BEGIN CASE
            CASE paymentChannel EQ 'Online Banking'
                channelid = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,channelcnt>
            CASE paymentChannel EQ 'Mobile Banking'
                channelid = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,channelcnt>
            CASE paymentChannel EQ 'Phone Banking'
                channelid = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,channelcnt>
            CASE paymentChannel EQ 'Branch'
                channelid = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,channelcnt>
            CASE paymentChannel EQ 'Kiosk/ATM'
                channelid = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,channelcnt>
            CASE paymentChannel EQ 'Corporate'
                channelid = iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,channelcnt>
        END CASE
    REPEAT
    IF channelid EQ '' THEN
        channelid = 1
    END
    oInstructionID = todayDate:participantIdentifier:'0000':channelid:'B':companyID:'1':time:uniqueId
                  
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update POR.TRANSACTION>
updatePORTables:
*** <desc>Update Sender's Reference Outgoing of POR.TRANSACTION </desc>

         
    iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.sendersReferenceOutgoing> = oInstructionID ;* update Senders reference outgoing in POR.TRANSACTION
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Output params>
outputParams:
*** <desc>Send the required output parameters </desc>
   
    ioIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    ioIFEmitDets<12> = LOWER(iSupplementaryInfo) ;* to update screening details
    
    oEnrichIFDets =  ioIFEmitDets
    
    oChangeHistory = 'Updated Senders Reference Outgoing and Unique Trace Number by Outward Mapping'  ;* to be updated in History Log
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Output params>
insertPsmBlob:
*** <desc>Send the required output parameters </desc>

    iPSMBlobDetails = ''
    iTransactionContext = ''
    responseDetails = ''
    
    GOSUB updatePORTables
    iTransactionContext<PP.LocalClearingService.TransactionContext.companyID> = companyID
    iTransactionContext<PP.LocalClearingService.TransactionContext.ftNumber> = ftNumber
    iPSMBlobDetails<PP.LocalClearingService.PSMRecordDetails.sendersReference>= oInstructionID
    iPSMBlobDetails<PP.LocalClearingService.PSMRecordDetails.messageType> = iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.outgoingMessageType>
    iPSMBlobDetails<PP.LocalClearingService.PSMRecordDetails.sendDateTime> = oTimestamp
    iPSMBlobDetails<PP.LocalClearingService.PSMRecordDetails.bulkReference> = 'SBD-':ftNumber
    iPSMBlobDetails<PP.LocalClearingService.PSMRecordDetails.fileReference> = 'SFD-':ftNumber
*    PP.LocalClearingService.updateMessagePsmBlob(iTransactionContext, iPSMBlobDetails)
    PP.SwiftOutService.ppPSMBLOBWrapperAuth(iTransactionContext, iPSMBlobDetails, responseDetails)
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getScreeningDetails>
getScreeningDetails:
*** <desc>Get the payment status from POR screening requests table </desc>

    RecordID = ftNumber
    TableName = 'POR.SCREENINGREQUESTS'
    ReadWithLock = ''
    RScreeningRequest = ''
    errorResponse = ''
    paymentStatus = ''
    
    PP.PaymentWorkflowGUI.getInterfaceAndRequestResponse(TableName,RecordID,ReadWithLock,RScreeningRequest,errorResponse)
    paymentStatus = RScreeningRequest<PP.PaymentWorkflowGUI.PorScreeningrequests.Paymentstatus>
    
    IF paymentStatus EQ 'POSSIBLE' THEN
        locFldcnt = DCOUNT(iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefName>,@VM)
        iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefName,locFldcnt + 1> = 'Screening Status'
        iSupplementaryInfo<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,locFldcnt + 1> = 'POSSIBLE'
    END
    CALL TPSLogging("DB Input","outward enrich api.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <RScreeningRequest:":RScreeningRequest:">","")
    
RETURN
*** </region>


*-----------------------------------------------------------------------------



END


