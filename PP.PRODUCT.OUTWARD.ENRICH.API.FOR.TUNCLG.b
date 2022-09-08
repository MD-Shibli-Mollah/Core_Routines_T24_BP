* @ValidationCode : MjotNTE3OTQ4NjAzOkNwMTI1MjoxNjAzMjg0MjYwNjA3OnNhcm1lbmFzOjk6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MToyMjc6MjEy
* @ValidationInfo : Timestamp         : 21 Oct 2020 18:14:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 212/227 (93.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.TUNCLG(iPaymentDets,ioIFEmitDets)
*-----------------------------------------------------------------------------
* This program will enrich sendersReferenceOutgoing value for Outgoing CT,DD,RJ and RT payments and will be called from routine "enrichOutMessageDetails".
*-----------------------------------------------------------------------------
* Modification History :
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentFrameworkService
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $INSERT I_F.PP.CLEARING.RETURNCODE
    $USING EB.SystemTables
    $USING PP.PaymentWorkflowGUI
    $USING AC.DDAService
    $INSERT I_CustomerService_CustomerRecord
    $USING EB.DataAccess
    $USING PP.OutwardInterfaceService
    
*-----------------------------------------------------------------------------

    GOSUB initialise ;
    GOSUB process;
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
*** <desc> </desc>
    clrgTxnType = ''
    iLockingId = ''
    iAgentDigits = ''
    iRandomDigitsLen = ''
    uniqueRef = ''
    sendersRefIncoming = ''
    localFieldName =''
    description =''
    iCompanyId = FIELD(iPaymentDets,'*',1)
    ftNumber = FIELD(iPaymentDets,'*',2)
    iPorTransactionDets = RAISE(ioIFEmitDets<3>)
    iPORPmtFlowDetailsList = RAISE(ioIFEmitDets<12>)
    iPrtyDbtDetails = RAISE(ioIFEmitDets<7>)
    fnPPclearingRetCode = 'F.PP.CLEARING.RETURNCODE'
    fPPclearingRetCode = ''
    EB.DataAccess.Opf(fnPPclearingRetCode, fPPclearingRetCode)
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>
    clrgTxnType = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType>
*   Below condition added to generate unique reference to map for sendersReferenceOutgoing for CT.

    IF clrgTxnType EQ 'CT' THEN
        GOSUB getPaymentRecord
        GOSUB generateUniqueRef
        iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'Ordering Party Residency Flag'
        iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.orderingPartyResidencyFlag>
        GOSUB updateOutParams
    END
*   Below condition added to map sendersReferenceIncoming  of CT to sendersReferenceOutgoing for RT.
    IF clrgTxnType EQ 'RT' THEN
        originalTxnId = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.originalOrReturnId>  ;* FTNumber of original payment
        GOSUB getOriginalTxnOfReturnTxn ; *get Original Transaction if the payment is either RT or RF payment.
        sendersRefIncoming = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceIncoming>
        uniqueRef  = sendersRefIncoming
        GOSUB getPaymentRecord
        GOSUB getPORPaymentFlowDetails
        iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'Processing Date'
        iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.processingDate>
        localFieldName = DCOUNT(oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName>,@VM)
        count = 1
        LOOP
        WHILE count LE localFieldName
            IF oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,count> EQ 'OrginatorResidency' OR oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,count> EQ 'OrginatorAcctType' OR oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,count> EQ 'OrginatorAcctNature' THEN
                iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,count>
                iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,count>
            END
            count++
        REPEAT
        GOSUB updateOutParams ; *; *call gosub to update the sendersReferenceOutgoing value.
    END
    
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'CD' THEN
        GOSUB getPaymentRecord
        clearingReturnCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>
        outputChannel = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outputChannel>
        GOSUB getClearingReturnCode
        IF clearingReturnCode EQ '00000001' OR clearingReturnCode EQ '00000002' OR clearingReturnCode EQ '00000003' OR clearingReturnCode EQ '00000004' OR clearingReturnCode EQ '00000010' OR clearingReturnCode EQ '00000011' OR clearingReturnCode EQ '00000012' THEN
            oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode> = '82'
            oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription> = description
            clearingNatCode = '82'
            iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingNatureCode> = '82'
        END ELSE
            oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode> = '84'
            oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.reasonDescription> = description
            clearingNatCode = '84'
            iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingNatureCode> = '84'
        END
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.reasonDescription> = description
               
        GOSUB mapAdditionalDetails
        GOSUB getSupplementaryInfo ; *
        oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionTypeCode> = transactionTypeCode
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.transactionTypeCode> = transactionTypeCode
        GOSUB updatePaymentRecord ; *updatePaymentRecord
        iLockingId = 'PPTNCL.UNIREF' ;* locking file record id
        iAgentDigits = '2';* length of the seq no from agent's relative position
        iRandomDigitsLen = '5' ;* length of the unique reference number  from locking record
        traceNumP2 = ''
        PPTNCL.Foundation.PptnclGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen,'' ,uniqueRef,'') ;* this api returns a 7 digit unique reference number
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.sendersReferenceOutgoing> =  uniqueRef
        ioIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    END


* Mapping sendersReferenceOutgoing for CT and RJ transaction
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'DD' THEN
        GOSUB generateUniqueRef
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.sendersReferenceOutgoing> =  uniqueRef
        ioIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    END
    
*Mapping SendersReferenceOutgoing For CC trasactions
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'CC' THEN
        GOSUB getPayeeAccount
        GOSUB getPayerAccount
        GOSUB getPaymentRecord
        chequeNo = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.chequeNumber>
        uniqueRef = chequeNo:payerAccount:payeeAccount
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.sendersReferenceOutgoing> =  uniqueRef
        ioIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
getPayerAccount:
*---------------

    iDebitPartyRole                             = ""
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = iCompanyId
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = ftNumber
    oPrtyDbtDetails                             = ""
    oGetPrtyDbtError                            = ""
    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
    
    noOfTypes = DCOUNT(oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>,@VM)
    FOR type=1 TO noOfTypes
            
        IF oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole,type> EQ 'DEBTOR' THEN
            payerAccount = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,type>
        END
    NEXT type
                    
RETURN

getPayeeAccount:
*----------------
    iCreditPartyRole = ""
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>  = iCompanyId
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>   = ftNumber
    oCreditPartyDet = ""
    oGetCreditError = ""
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)
    
    noOfTypes = DCOUNT(oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>,@VM)
      
    FOR type=1 TO noOfTypes
        partyRole = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,type>
        
        IF partyRole EQ 'ORDPTY' THEN
            payeeAccount = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,type>
        END
        
    NEXT type

RETURN

*** <region name= getOriginalTxnOfReturnTxn>
getOriginalTxnOfReturnTxn:
*   To get original transaction details.
    
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = originalTxnId
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
updateOutParams:
*** <desc> </desc>
    iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.sendersReferenceOutgoing> = uniqueRef
    ioIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    ioIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)  ;* the updated POR.SUPPLEMENTARY.INFO is used in EmitDetails
*    oEnrichIFDets =  '':@FM:iIFEmitDets<2>:@FM:iIFEmitDets<3>:@FM:iIFEmitDets<4>:@FM:iIFEmitDets<5>:@FM:iIFEmitDets<6>:@FM:iIFEmitDets<7>:@FM:iIFEmitDets<8>:@FM:iIFEmitDets<9>:@FM:iIFEmitDets<10>:@FM:iIFEmitDets<11>:@FM:iIFEmitDets<12>

RETURN
*** </region>
*-----------------------------------------------------------------------------
getPaymentRecord:
    
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
RETURN
*------------------------------------------------------------------------------
getPORPaymentFlowDetails:

    iPORPmtFlowDetailsReq = ''
    oPORPmtFlowDetailsList = ''
    oPORPmtFlowDetailsGetError = ''
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = iCompanyId
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.originalOrReturnId>

    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)

RETURN
*------------------------------------------------------------------------------

getClearingReturnCode:
*---------------------
    clearingRetID = ''
    clearingRetRec = ''
    Er = ''
    clearingRetID = outputChannel:'.':clearingReturnCode

    EB.DataAccess.FRead(fnPPclearingRetCode, clearingRetID, clearingRetRec, fPPclearingRetCode, Er)

    IF Er EQ '' THEN
        description = clearingRetRec<PP.CGR.ReturnCodeDescription>
    END

RETURN
*-------------------------------------------------------------------------------------------------
*** <region name= getSupplementaryInfo>
getSupplementaryInfo:
*** <desc> </desc>
  
    iUpdatePaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.companyID> = ftNumber[1,3]
    iUpdatePaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.ftNumber> = ftNumber
    iUpdatePaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.clearingSystemIdCode> = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.bulkReference>
    oPORPmtFlowDetailsUpdError = ""
    PP.PaymentFrameworkService.updatePORPaymentFlowDetails(iUpdatePaymentFlowDetails, oPORPmtFlowDetailsUpdError)    ;*Update POR.PAYMENTFLOWDETAILS
    iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.clearingSystemIdCode> = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.bulkReference>

    ioIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)
    
RETURN

*** </region>
*-------------
mapAdditionalDetails:
*--------------------
    Record = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PARTYDEBIT', ftNumber, ReadWithLock, R.POR.PartyDebit, Error)

    debitPartyRoleRec = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyrole>
    debitPartyRoleIndRec = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyroleindicator>

    roleEach=''
    rolPos=''
    rPos = 1
    LOOP
        REMOVE roleEach FROM debitPartyRoleRec SETTING rolPos
    WHILE roleEach:rolPos
        IF roleEach EQ 'DEBTOR' AND debitPartyRoleIndRec<1,rPos> EQ 'R' THEN
            debitPartyAccoutline = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaccountline,rPos>
            GOSUB getAccountCustomerInfo
            R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyname,rPos> = name
            R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddressline1,rPos> = street
            R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddressline2,rPos> = Address
            R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactothr,rPos> = postalCode

            iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyName,rPos> = name
            iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddressLine1,rPos> = street
            iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddressLine2,rPos> = Address
            iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyContactOthr,rPos> = postalCode
            
            updateError = ''
            PP.PaymentWorkflowGUI.updateSupplementaryInfo('POR.PARTYDEBIT', ftNumber, R.POR.PartyDebit, '', updateError) ;* call to update Debit Party details additional
        END
        rPos = rPos + 1
    REPEAT
    ioIFEmitDets<7> = LOWER(iPrtyDbtDetails)

RETURN

getAccountCustomerInfo:
*---------------------
    customerId = ''
    inAccountDetails = ''
    inAccountDetails<AC.DDAService.InAccountDetails.accountNumber> = debitPartyAccoutline
    inAccountDetails<AC.DDAService.InAccountDetails.accountCompany> = ftNumber[1,3]

    AC.DDAService.getAccountDetails(inAccountDetails, accountDetails)

    customerId = accountDetails<AC.DDAService.AccountDetails.customerNumber>

    CALL CustomerService.getRecord(customerId, customerRecord) ;* To read CUSTOMER record

    name = customerRecord<CustomerRecord.name1>
    street = customerRecord<CustomerRecord.street>[1,5]
    Address = customerRecord<CustomerRecord.address>[1,50]
    postalCode = customerRecord<CustomerRecord.postCode>[1,4]
    customeRole = customerRecord<CustomerRecord.role>

    BEGIN CASE
        CASE customeRole EQ '10'
            transactionTypeCode = '2'
        CASE customeRole EQ '30'
            transactionTypeCode = '1'
        CASE 1
            transactionTypeCode = '3'
    END CASE

RETURN
*-----------------------------------------------------------------------------
updatePaymentRecord:
*** <desc>updatePaymentRecord </desc>

    iServiceName = 'OutwardMappingFramework'
    ioPaymentRecord = oPaymentRecord
    ioAdditionalPaymentRecord = oAdditionalPaymentRecord
    CALL TPSLogging("Input Parameter", "PP.PRODUCT.OUTWARD.ENRICH.API.FOR.TUNCLG", "oPaymentRecord : <":oPaymentRecord:">", "")
    
    PP.PaymentWorkflowDASService.updatePaymentRecord(iServiceName,ioPaymentRecord, ioAdditionalPaymentRecord,oTxnWriteErr)
    CALL TPSLogging("Input Parameter", "PP.PRODUCT.OUTWARD.ENRICH.API.FOR.TUNCLG", "oTxnWriteErr : <":oTxnWriteErr:">", "")

RETURN
*-----------------------------------------------------------------------------
generateUniqueRef:
*   This api returns a 7 digit unique reference number
    iLockingId = 'UNIREF' ;* locking file record id
    iAgentDigits = '2';* length of the seq no from agent's relative position
    iRandomDigitsLen = '5' ;* length of the unique reference number  from locking record
    uniqueRef = ''
    PPTNCL.Foundation.PptnclGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen,'' ,uniqueRef,'') ;*
        
RETURN
*------------------------------------------------------------------------------
END
