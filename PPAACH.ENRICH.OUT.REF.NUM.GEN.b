* @ValidationCode : MjotMTg0NzE0MTE0NDpDcDEyNTI6MTYxNDA5NTE3OTcxODpzaGFybWFkaGFzOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoxMzY6MTE0
* @ValidationInfo : Timestamp         : 23 Feb 2021 21:16:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sharmadhas
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 114/136 (83.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.ENRICH.OUT.REF.NUM.GEN(iPaymentDets,iIFEmitDets,oUpdatePaymentObject,oEnrichIFDets, oChangeHistory, ioReserved1, ioReserved2, ioReserved3, ioReserved4, ioReserved5)
*----------------------------------------------------------------------------------------------------------------------------------------
** This API returns the Uni vocal trans reference which should be mapped to SendersReferenceOutgoing of POR.Transaction table.
* and a 15 digit Unique Trace number to uniquely identify each transaction. This API will be attached in the EnrichOutMessageAPI field
* of PP.CLEARING.
*
* Parameters:
*
* IN     iPaymentDets            string     incoming Payment Details
* IN     iIFEmitDets             string     incoming IF Details
 
*    iPaymentDetailsA = iIFEmitDets<2>
*    iPorTransaction = iIFEmitDets<3>
*    iCancelReqRec = iIFEmitDets<4>
*    iDebitAuthInfo = iIFEmitDets<5>
*    iCreditPartyDet = iIFEmitDets<6>
*    iPrtyDbtDetails = iIFEmitDets<7>
*    iPaymentInformation = iIFEmitDets<8>
*    iAdditionalInfDetails = iIFEmitDets<9>
*    iAccInfoDetails = iIFEmitDets<10>
*    iRemittanceInfo = iIFEmitDets<11>
    
* OUT   oUpdatePaymentObject     string     details of the POR Tables to be updated
* OUT   oEnrichIFDets            string     modified IF details
* OUT   oChangeHistory           string     change history to be updated in history log.
* OUT   Reserved                 string     Reserved for future use


*----------------------------------------------------------------------------------------------------------------------------------------
* Modification History :
*----------------------------------------------------------------------------------------------------------------------------------------
* 13/05/2019 - Enhancement 2959657 / Task 2959618
*              API to return the Unique Batch Number using which a Batch in a file can be uniquely identified
*              in a NACHA payment
* 18/06/2019 - Defect 3181716 / Task 3184180
*              Added the changes for SendersReferenceOutging for CT COELSA.
* 26/06/2019 - Defect / task 3198333
*              For Reversal, the unique trace number of Original transaction should be retrieved.
* 04/07/2019 - Task 3213708  - Updating SendersReferenceOutgoing for CT and RT transactions
* 31/07/2019 - Task 3261627 - Unique Trace Number for ARGCTRJ is mapped.
* 15/05/2020 - Defect 3745387/Task 3751386 - Bank ID is not sent in outgoing file
* 11/02/2021 - Enhancement 3912044 / Task 4211439: Updation of Audit trail for outgoingMessageType ARGRSRJ
* 23/02/2021 - Enhancement 3912044 / Task 4240143 - Reverting changes related to removal of OrginalorReturnId.
*----------------------------------------------------------------------------------------------------------------------------------------
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentWorkflowGUI
    $USING PP.LocalClearingService
    $USING EB.DataAccess
    $USING PP.OutwardMappingFramework
    $USING PP.OutwardInterfaceService
    
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process ; *Generate a unique reference number based on the incoming parameters

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables used </desc>

    companyID = ''
    ftNumber = ''
    
    companyID = FIELDS(iPaymentDets,'*',1)
    ftNumber = FIELDS(iPaymentDets,'*',2)
    
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    iPorTransactionDets = RAISE(iIFEmitDets<3>)
    iPORPmtFlowDetailsList = RAISE(iIFEmitDets<12>)
    iPaymentDetailsA = RAISE(iIFEmitDets<2>)
    iPORPmtFlowDetailsReq = ''
    oPORPmtFlowDetailsGetError = ''
    OrgOrRetId = ''
    
RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc>Generate 7 digit unique reference number </desc>

    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType> EQ 'ARGDDRJ' THEN
        RETURN
    END
* Updation of Audit trail for outgoingMessageType ARGRSRJ
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType> EQ 'ARGRSRJ' THEN
        eventDescription = 'Reversal request rejected with'
        iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = companyID
        iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = ftNumber
        iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'INF'
        iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = eventDescription
        iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clgReturnCode>
        iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = ftNumber

        PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogError)
       
        iPaymentID = ''
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = companyID
        GOSUB getPaymentRecord ; * GOSUB Call method to get transaction details
        IF oReadErr EQ '' THEN
            senderAddress = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderAddress>
            iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'Sender Address'
            iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = senderAddress
            iIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)  ;* the updated POR.TRANSACTION is used in EmitDetails
            oEnrichIFDets =  '':@FM:iIFEmitDets<2>:@FM:iIFEmitDets<3>:@FM:iIFEmitDets<4>:@FM:iIFEmitDets<5>:@FM:iIFEmitDets<6>:@FM:iIFEmitDets<7>:@FM:iIFEmitDets<8>:@FM:iIFEmitDets<9>:@FM:iIFEmitDets<10>:@FM:iIFEmitDets<11>:@FM:iIFEmitDets<12>
        END
        RETURN
    END
    GOSUB formUniVocalTransRef ;*Uni vocal trans reference which should be mapped to SendersReferenceOutgoing of POR.Transaction table
    GOSUB formUniqueTraceNumber ;* forming a 15 digit Unique Trace number to uniquely identify each transaction
    GOSUB updatePORTables ; *Update Sender's Reference Outgoing of POR.TRANSACTION
    GOSUB outputParams ; *Send the required output parameters
*When sending out Return for received DD transaction, PP.OUT.MAPPING.CONCAT should be updated with the Id of PPT.SENTBULKDETAILS created for Return transaction
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType> EQ 'ARGDDRV' THEN
        GOSUB updateBulkRefConcat
    END
    
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = formUniVocalTransRef>
formUniVocalTransRef:
*** <desc> Uni vocal trans reference which should be mapped to SendersReferenceOutgoing of POR.Transaction table </desc>
;   * remove the 4th character from the current transction reference
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType> EQ 'CT' OR iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType> EQ 'RT' THEN
        R.POR.Information = ''
        Error = ''
        PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.INFORMATION', ftNumber, '', R.POR.Information, Error)
        infCodeRec = R.POR.Information<PP.PaymentWorkflowGUI.PorInformation.Informationcode>
        instructionCodeRec = R.POR.Information<PP.PaymentWorkflowGUI.PorInformation.Instructioncode>
        infCode = ''
        infPos = ''
        iPos = 1
        LOOP
            REMOVE infCode FROM infCodeRec SETTING infPos
        WHILE infCode:infPos
            IF infCode EQ 'INSSDR' AND instructionCodeRec<1,iPos> EQ 'TXPURPPY' THEN
                oUniVocTransRef = R.POR.Information<PP.PaymentWorkflowGUI.PorInformation.Informationline,iPos>[1,3]:ftNumber[5,16]
            END
            iPos = iPos + 1
        REPEAT
             
    END ELSE
        oUniVocTransRef = ftNumber[1,3]:ftNumber[5,16]  ;* gives a 15 digit unique reference number
    END
        
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = formuniqueTraceNumber>
formUniqueTraceNumber:
***<desc>forming a 15 digit Unique Trace number to uniquely identify each transaction</desc>

    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType> EQ 'ARGDDRV' OR iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.outgoingMsgType> EQ 'ARGCTRJ' THEN
        GOSUB RetrieveOrgUniqTraceNo ;* get the Unique Trace number from the Original transaction
        RETURN
    END
      
    CompanyNcc = iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.companyNcc>  ;* Company NCC code
   
    IF LEN(CompanyNcc) GE 8 THEN  ;* if the NCC is greater than 8 digits, retrieve the first 8 digits.
        traceNumP1 = CompanyNcc[1,8]
    END ELSE
        MaskCode = "8'0'R"  ;* if it is less than 8 digits, say 6, then pad 2 0s before the NCC to make it of length 8.
        traceNumP1 = FMT(CompanyNcc,MaskCode)  ;* Company NCC formatted to 8 digits.
    END
    
    traceNumP2 = ''
    
    iLockingId = 'UNIREF' ;* locking file record id
    iAgentDigits = '2';* length of the seq no from agent's relative position
    iRandomDigitsLen = '5' ;* length of the unique reference number  from locking record
    
    PPAACH.ClearingFramework.PPAACHGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen,'' ,traceNumP2,'') ;* this api returns a 7 digit unique reference number
    
    oUniqueTraceNum = traceNumP1:traceNumP2 ;* concat the 8 digit Company NCC and the 7 digit unique reference returned by the Generic API.

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------------------
RetrieveOrgUniqTraceNo:
    
    OrgOrRetId = iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>  ;* FTNumber of original payment
    
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.outgoingMsgType> EQ 'ARGCTRJ' THEN
        OrgOrRetId = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.originalOrReturnId>
    END
    
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = companyID ;* Company Id
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = OrgOrRetId ;* Original FtNumber
    
    
    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)
    
;* Unique trace number from the Original Transaction
    
    LOCATE 'Unique Trace Number' IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING TracePos THEN
        oUniqueTraceNum = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,TracePos>
    END
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.outgoingMsgType> EQ 'ARGCTRJ' THEN
        LOCATE 'UniqueTraceNumber' IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING TracePos THEN
            oUniqueTraceNum = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,TracePos>
        END
    END
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= updatePORTables>
updatePORTables:
*** <desc>Update Sender's Reference Outgoing of POR.TRANSACTION </desc>
   
    oPorTransaction = ''
    IF (iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType> EQ 'CT') OR (iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType> EQ 'RT') THEN
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.sendersReferenceOutgoing> = oUniVocTransRef ;* update Senders reference outgoing in POR.TRANSACTION for CT RT transactions
    END ELSE
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.sendersReferenceOutgoing> = oUniVocTransRef ;* update Senders reference outgoing in POR.TRANSACTION for DD RV transactions
    END
    EB.DataAccess.FRead('F.POR.SUPPLEMENTARY.INFO',ftNumber,oPorSuppInfo,'', oReadErr) ;* get the POR.SUPPLEMENTARY.INFO record
     
    oPorSuppInfo<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdLocFieldName,-1> = 'Unique Trace Number' ;* Update the Unique Trace number in POR.SUPPLEMENTARY.INFO in Local Field Name and Value fields
    oPorSuppInfo<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdLocFieldValue,-1> = oUniqueTraceNum
 
    iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'Unique Trace Number'
    iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oUniqueTraceNum
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= outputParams>
outputParams:
*** <desc>Send the required output parameters </desc>

    oUpdatePaymentObject = 'POR.SUPPLEMENTARY.INFO#':oPorSuppInfo ;* Each table name is separated by /*?*/ ; Table and its contents are separated by #
    
    iIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    iIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)  ;* the updated POR.TRANSACTION is used in EmitDetails
    
    oEnrichIFDets =  '':@FM:iIFEmitDets<2>:@FM:iIFEmitDets<3>:@FM:iIFEmitDets<4>:@FM:iIFEmitDets<5>:@FM:iIFEmitDets<6>:@FM:iIFEmitDets<7>:@FM:iIFEmitDets<8>:@FM:iIFEmitDets<9>:@FM:iIFEmitDets<10>:@FM:iIFEmitDets<11>:@FM:iIFEmitDets<12>
    
    oChangeHistory = 'Updated Senders Reference Outgoing and Unique Trace Number by Outward Mapping'  ;* to be updated in History Log
    
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------------------------------------------

updateBulkRefConcat:
* BulkReference is updated in PP.OUT.MAPPING.CONCAT file
    iInsOutMappingConcat = ''
    oInsOutMappingConcatError = ''
    iMappingID = "BLKREF":iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.bulkReferenceIncoming>
    iInsOutMappingConcat<PP.OutwardMappingFramework.InsOutMappingConcat.id> = iMappingID
    iInsOutMappingConcat<PP.OutwardMappingFramework.InsOutMappingConcat.content> = iPaymentDetailsA<PP.LocalClearingService.PaymentDetailsA.bulkReferenceId>
    PP.OutwardMappingFramework.insertOutMappingConcat(iInsOutMappingConcat, oInsOutMappingConcatError)
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= getPaymentRecord>
getPaymentRecord:
*** <desc>Call method to get transaction details </desc>

    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''

* Read the Payment Details for the Transaction
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    
RETURN
*** </region>
END
