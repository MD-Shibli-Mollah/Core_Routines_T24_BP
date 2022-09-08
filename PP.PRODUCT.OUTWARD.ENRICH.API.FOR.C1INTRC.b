* @ValidationCode : MjotMjEzNDI2MDU0MjpDcDEyNTI6MTYxODQ4MjA4ODExMzpzdHV0aS5zaW5naDo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6MzA4OjI5NA==
* @ValidationInfo : Timestamp         : 15 Apr 2021 15:51:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stuti.singh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 294/308 (95.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*

*------------------------------------------------------------------------------
$PACKAGE PPCAIC.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.C1INTRC(iPaymentDets, ioIFEmitDets)
*------------------------------------------------------------------------------
*
* Program Description:
* This method is used to enrich the outward messages of Canada Interac
*
*------------------------------------------------------------------------------
* Modification History :
*
* 25/02/2021 - Enh 3988349 / Task 4225895 - added code to enrich IF
* 04/03/2021 - Enh 3988349 / Task 4264848 - updated logic to update Local Ref Field
* 22/03/2021 - Defect 4288396 / task - 4298668 - updated mapping of fields from PSM.BLOB and PRM.BLOB table.
* 24/03/21 - Enhancement 3988389/ Task 4225703  - Assign values for clearing return code and the description
* 30/03/21 - Enhancement 3988389/ Task 4313209  - map charges info and bulksenders reference for RT transactions.
* 15/04/2021 - Enhancement 4328490 / Task - 4339166 - Regression Fix
*------------------------------------------------------------------------------
    $USING PP.PaymentWorkflowDASService
    $USING PP.OutwardMappingFramework
    $USING PP.OutwardInterfaceService
    $USING PP.PaymentFrameworkService
    $USING PP.LocalClearingService
    $USING PP.SwiftOutService
    $USING PP.MessageMappingService
    $USING EB.DataAccess
    $USING PP.MessageAcceptanceService
    $USING EB.SystemTables
    $USING PP.PaymentWorkflowGUI
    $USING EB.Service
    $INSERT I_MessageMappingService_TxnContext
    $INSERT I_DAS.PPT.RECEIVEDBULKDETAILS
    
    GOSUB initialise ; *initialise variables
    GOSUB process ; *
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
    
*** <desc> </desc>
    oUpdatePaymentObject = ''
    oEnrichIFDets = ''
    oChangeHistory = ''
    oReserved1 = ''
    oReserved2 = ''
    oReserved3 = ''
    oReserved4 = ''
    oReserved5 = ''
    iCompanyId = ''
    iCompanyId = FIELD(iPaymentDets,'*',1)
    ftNumber = ''
    ftNumber = FIELD(iPaymentDets,'*',2)
    iPORPmtFlowDetailsList = ''
    iPorTransaction = ''
    iPorTransaction = RAISE(ioIFEmitDets<3>)
    iPORPmtFlowDetailsList = RAISE(ioIFEmitDets<12>)
    clrgTxnType = ''
    originatingChannel=''
    statusCode=''
    outMsgType = ''
    iPORPmtFlowDetailsReq = ''
    iClrRequest = ''
    iUpdatePaymentFlowDetails = ''
    isSvcRunning = PPCAIC.Foundation.getsvcRunningStatus()
    confStatus = ''
    clReturnCode = ''
    iPrtyDbtDetails = ''
    iPrtyDbtDetails = RAISE(ioIFEmitDets<5>)
    iPrtyCdtDetails = RAISE(ioIFEmitDets<4>)
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
    
*** <desc> </desc>

    GOSUB getPaymentRecord ; *get payment record
    GOSUB getPorPmtFlowDets ; * get the supplementary info
    
    clrgTxnType = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    originatingChannel = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingChannel>
    IF clrgTxnType EQ 'DD' THEN
        outMsgType = iPorTransaction<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType>
    END ELSE
        outMsgType = iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.outgoingMessageType>
    END
    
    IF originatingChannel EQ 'C1INTRC' AND clrgTxnType MATCHES 'CT':@VM:'DD':@VM:'RT':@VM:'RV' THEN
        statusCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
        clReturnCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingReturnCode>
*Update instConfStatus based on the status code
        BEGIN CASE
            
            CASE clReturnCode MATCHES '999':@VM:'22':@VM:'40' OR statusCode MATCHES '997':@VM:'998':@VM:'46':@VM:'235' OR isSvcRunning EQ 'Y'
                confStatus = 'RJCT'
            CASE statusCode EQ '999'
                confStatus = 'ACSP'
            CASE 1
                confStatus = 'ACTC'
        END CASE
        
        IF clrgTxnType EQ 'DD' THEN
            LOCATE "instConfStatus" IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING pos1 THEN
                oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,pos1> = confStatus
            END ELSE
                oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = "instConfStatus"
                oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = confStatus
            END
            iPORPmtFlowDetailsList = oPORPmtFlowDetailsList
        END ELSE
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.instConfStatus> = confStatus
        END
        IF clrgTxnType EQ 'RT' THEN
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.paymentMethod> = 'NA'
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.clearingSystemReference> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.RClearingSystemReference>
            IF statusCode EQ '999' THEN
                iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.clgReturnCode>=''
                iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.reasonDescription>=''
            END
            IF clReturnCode EQ '999' AND confStatus EQ 'RJCT' THEN
                iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.clgReturnCode>='999'
                iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.reasonDescription>='Unspecified Application Error'
            END
        END
    END
    
* If Pacs.002 is sent out, capture the sent time in local ref field
    IF outMsgType EQ 'pacs.002' THEN
        GOSUB getTimestamp ; * get the timestamp
* Update the timestamp in the Local Ref Field
        LOCATE "SentOutDateTime" IN oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING pos THEN
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,pos> = oTimestamp
        END ELSE
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = "SentOutDateTime"
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oTimestamp
        END
    END
    
    GOSUB getPRMBlobdets ; *get PRM Blob Details
    GOSUB getPSMBlobdets ; *get PSM Blob Details
    GOSUB getbulksenderref
    GOSUB getdebitpartydetails
    GOSUB mapChargeDetails
    GOSUB updatePorPmtFlowDets ; *update supplementary info
    GOSUB getuniquereference
    GOSUB updateOutParams
    GOSUB updateInvstWorkfileConcat ; *
RETURN
*-----------------------------------------------------------------------------
*** <region name= updateOutParams>
updateOutParams:
    
*** <desc> </desc>
    ioIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)  ;* the updated Payment flow details is used in EmitDetails
    ioIFEmitDets<3> = LOWER(iPorTransaction)
    ioIFEmitDets<5> = LOWER(iPrtyDbtDetails)
    ioIFEmitDets<4> = LOWER(iPrtyCdtDetails)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPaymentRecord>
getPaymentRecord:
    
*** <desc> </desc>
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = iCompanyId
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr) ;*get payment record
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getTimestamp>
getTimestamp:
*** <desc> </desc>
    
    GOSUB getClearingDetails ; *read Clearing detaisl for Timezone
    iTimezoneDetails<PP.PaymentFrameworkService.TimezoneDetails.timezone> = oClrDetails<PP.LocalClearingService.ClrDetails.timeZone>
    PP.PaymentFrameworkService.calculateLocalTimestamp(iTimezoneDetails, oLocalTimestamp, oTimestampResponse)
    oTimestamp = oLocalTimestamp<PP.PaymentFrameworkService.LocalTimestamp.timestamp>
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= getPorPmtFlowDets>
getPorPmtFlowDets:
*** <desc> </desc>
    
    oPORPmtFlowDetailsList = ''
    oPORPmtFlowDetailsGetError = ''
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = iCompanyId
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = ftNumber
    
    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)
        
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= updatePorPmtFlowDets>
updatePorPmtFlowDets:
*** <desc> </desc>

    iUpdatePaymentFlowDetails = oPORPmtFlowDetailsList
    oPORPmtFlowDetailsUpdError = ''
    PP.PaymentFrameworkService.updatePORPaymentFlowDetails(iUpdatePaymentFlowDetails, oPORPmtFlowDetailsUpdError)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= getClearingDetails>
getClearingDetails:
*** <desc>read Clearing detaisl for Timezone </desc>

    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iCompanyId
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = 'C1INTRC'
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    oClrDetails = ""
    oClrError = ""
    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
       
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= getPSMBlobdets>
getPSMBlobdets:
    IF confStatus EQ 'ACTC' THEN
        IF clrgTxnType EQ 'DD' THEN
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = "SendDateTime"
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oTimestamp
            iPORPmtFlowDetailsList = oPORPmtFlowDetailsList
        END ELSE
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.localRefName,-1> = "SendDateTime"
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,-1> = oTimestamp
        END
    END
    IF confStatus EQ 'ACSP' THEN
        IF clrgTxnType EQ 'DD' THEN
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = "ClearingActionStatusDateTime"
            oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = oTimestamp
            iPORPmtFlowDetailsList = oPORPmtFlowDetailsList
        END ELSE
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.localRefName,-1> = "ClearingActionStatusDateTime"
            iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,-1> = oTimestamp
        END
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPRMBlobdets>
getPRMBlobdets:
    
* set up the input parameter
    iTxnContext = ''
    iTxnContext<PP.MessageMappingService.TxnContext.companyID> = iCompanyId
    iTxnContext<PP.MessageMappingService.TxnContext.ftNumber> = ftNumber
* initialize the output parameters
    oReceivedTxnDet = ''
    oReceivedTxnError = ''

* call the routine
    PP.MessageMappingService.getReceivedTxnContent(iTxnContext, oReceivedTxnDet, oReceivedTxnError)
    prmBlobrecvdDateTime = oReceivedTxnDet<PP.MessageMappingService.ReceivedTxnDet.receivedDateTime>
    
    IF clrgTxnType EQ 'DD' THEN
        oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.acceptedDateTimeStamp> = prmBlobrecvdDateTime
        iPORPmtFlowDetailsList = oPORPmtFlowDetailsList
    END ELSE
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.acceptedDateTimeStamp> = prmBlobrecvdDateTime
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= getbulksenderref>
getbulksenderref:
    IF statusCode EQ '999' THEN
        IF confStatus EQ 'ACSP' OR  confStatus EQ 'RJCT' THEN
            SentBulkDetailsId = ''
            iAdditionalPaymentRecord = oAdditionalPaymentRecord
            SentBulkDetailsId = iAdditionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.bulkSendersReference>
            tableName = 'PPT.RECEIVEDBULKDETAILS'
            tableSuffix = ""
            theList = dasGetRecordswithOrgBulkReference
            theArgs = ''

            theArgs<1> = SentBulkDetailsId

            EB.DataAccess.Das(tableName,theList,theArgs,tableSuffix)
            IF theList NE "" THEN
                iBulkReference = theList
                PP.MessageAcceptanceService.getReceivedBulkDetails(iBulkReference, oReceivedBulkDetails, oReceivedBulkError)
                bulksendersref = oReceivedBulkDetails<PP.MessageAcceptanceService.ReceivedBulkDetails.bulkReferenceIncoming>
            END
            IF clrgTxnType NE 'RT' THEN
                IF clrgTxnType EQ 'DD' THEN
                    iPorTransaction<PP.OutwardMappingFramework.PorTransactionForDD.bulkSendersReference> = bulksendersref
                END ELSE
                    iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.bulkSendersReference> = bulksendersref
                END
            END
        END
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= getuniquereference>
getuniquereference:

    FnLocking = 'F.LOCKING'
    FLocking = ''
    
    sessionID = ''
    sessionID = EB.Service.getSessionNo()
    LockingId = 'PPCAIC.Uniqref.pas002':'.':sessionID
    rLocking = ''
    RecEr = ''
    Retry = ''
    
    CurrentDate = EB.SystemTables.getToday() ;* get TODAY date

    EB.DataAccess.FReadu(FnLocking, LockingId,rLocking, FLocking, RecEr, Retry)  ;* read the Locking table with the id formed
    
    IF rLocking EQ '' THEN  ;* if there is no record, write a new one with the sequence number and today date
        SeqNo = '1' ;* sequence number
        rLocking<2> = SeqNo
    END ELSE
        IF rLocking<2> EQ '9999999' THEN  ;* If value reaches 999999 then start the sequence again
            RSuffix = ''
            SeqNo = '1' ;* sequence number
            rLocking<2> = SeqNo
        END ELSE
            SeqNo = rLocking<2> + 1 ;* if the record is present , then update the existing record
            rLocking<2> = SeqNo
        END
    END
    iRandomDigitsLen = '7'
    MaskCode = iRandomDigitsLen:"'0'R" ;* mask the output with the required no of 0s.
    LockingSeqNo = FMT(SeqNo,MaskCode) ;* formatting to the required no of digits
    rLocking<1> = ftNumber[6,17]:LockingSeqNo
   
    RSuffix = ''
    EB.SystemTables.LockingWrite(LockingId, rLocking, RSuffix) ;* Update the Locking record
    
    IF clrgTxnType EQ 'DD' THEN
        oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = "UniqueReference"
        oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = rLocking<1>
        iPORPmtFlowDetailsList = oPORPmtFlowDetailsList
    END ELSE
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.localRefName,-1> = "UniqueReference"
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue,-1> = rLocking<1>
    END
RETURN


*** </region>
*-----------------------------------------------------------------------------
*** <region name= mapChargeDetails>
mapChargeDetails:
    
    R.POSTING.AND.CONFIRMATION = ''
    oReadErr = ''
   
    EB.DataAccess.FRead('F.POR.POSTING.AND.CONFIRMATION',ftNumber,R.POSTING.AND.CONFIRMATION,'', oReadErr)
   
    chargeAmount = SUM(R.POSTING.AND.CONFIRMATION<PP.PaymentWorkflowGUI.PorPostingAndConfirmation.PorPdChargeAmount>)
    IF clrgTxnType EQ 'DD' THEN
        iPorTransaction<PP.OutwardMappingFramework.PorTransactionForDD.senderChargeAmount1> = chargeAmount
        iPorTransaction<PP.OutwardMappingFramework.PorTransactionForDD.senderChargeCurrencyCode1> = R.POSTING.AND.CONFIRMATION<PP.PaymentWorkflowGUI.PorPostingAndConfirmation.PorPdChargeAmountCurrency>
    END
    IF clrgTxnType EQ 'RT' THEN
        iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.senderChargeAmount1> = chargeAmount
        iPorTransaction<PP.OutwardInterfaceService.PorTransactionRTGS.senderChargeCurrencyCode1> = R.POSTING.AND.CONFIRMATION<PP.PaymentWorkflowGUI.PorPostingAndConfirmation.PorPdChargeAmountCurrency>
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= getdebitpartydetails>
getdebitpartydetails:
    
    IF clrgTxnType EQ 'RT' THEN
        Record = ''
        OriginalFt = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.orgnlOrReturnId>
        PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PARTYDEBIT', OriginalFt, ReadWithLock, R.POR.PartyDebit, Error)

        debitPartyRoleRec = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyrole>
        debitPartyRoleIndRec = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyroleindicator>
        roleCount = DCOUNT(iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyRole>,@FM)+1
        roleEach=''
        rolPos=''
        rPos = 1
        LOOP
            REMOVE roleEach FROM debitPartyRoleRec SETTING rolPos
        WHILE roleEach:rolPos
            IF roleEach EQ 'DBTAGT' AND debitPartyRoleIndRec<1,rPos> EQ 'R' THEN
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyRole,roleCount> = 'DBTAGT'
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyRoleIndicator,roleCount> = 'R'
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyNationalId,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartynationalid,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAccountLine,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaccountline,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAccName,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyname,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrTypeCode,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrtypecode,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrDept,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrdept,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrSubdept,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrsubdept,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrStreetName,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrstreetname,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrBldgNo,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrbldgno,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrBldgName,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrbldgname,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrPostCode,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrpostcode,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrTownName,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrtownname,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddrCountrySubDiv,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddrcountrysubdiv,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyCountry,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycountry,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAddressLine1,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddressline1,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyOrgIdOtherId,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyorgidotherid,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyIdentifierCode,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyidentifiercode,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyClearingMemberId,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyclearingmemberid,rPos>
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyName,roleCount> = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyname,rPos>
                dbtClearingId = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyclearingmemberid,rPos>
            END
            IF roleEach EQ 'DEBTOR' AND debitPartyRoleIndRec<1,rPos> EQ 'R' THEN
                debtorAliasType = R.POR.PartyDebit<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaliastype,rPos>
            END
            rPos = rPos + 1
        REPEAT
        LOCATE 'BENFCY' IN iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyRole> SETTING cPos THEN
            iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crAliasType,cPos> = debtorAliasType
        END
    
        LOCATE 'ACWINS' IN iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyRole> SETTING cPos THEN
            iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyClearingMemberId,cPos> = dbtClearingId
        END ELSE
            cdtRoleCount = DCOUNT(iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyRole>,@FM)+1
            iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyRole,cdtRoleCount> = 'ACWINS'
            iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyRoleIndicator,cdtRoleCount> = 'R'
            iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyNationalId,cdtRoleCount> = 'Y'
            iPrtyCdtDetails<PP.OutwardInterfaceService.PorPartyCredit.crPtyClearingMemberId,cdtRoleCount> = dbtClearingId
        END
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= updateInvstFileConcat>
updateInvstWorkfileConcat:
*** <desc> </desc>

    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode> MATCHES "629":@VM:"656" AND oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource> EQ 'C1INTRC' THEN
        Fileid = "F.PP.INVST.WORKFILE"
        recConcat = ''
        recIdForConcat  = ''
        recIdForConcat =   ftNumber:'*':oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
        PPCAIC.Foundation.insertPPInvstWorkFileConcat("PP.LocalClearingService.insertPPInvstWorkFileConcat", recIdForConcat, recConcat)
    END
RETURN
*** </region>

END
