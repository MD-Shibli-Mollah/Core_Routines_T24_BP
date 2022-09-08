* @ValidationCode : MjotNjQ5NjY0NTE4OkNwMTI1MjoxNTk5NjM0NDkxOTQ2Om1yLnN1cnlhaW5hbWRhcjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6NzE6NjY=
* @ValidationInfo : Timestamp         : 09 Sep 2020 12:24:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 66/71 (92.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.MATCH.ORIGINAL.TXN.API(iCompanyID, iFTNumber, oResponseStatus, oPaymentStatusCode, oOriginalTrnFTNumber)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*13/08/2020 - Enhancement 3538767/Task 3808258-Payments-BHTunsian-Clearing specific API
*-----------------------------------------------------------------------------

*----------------------------------------------------------------------------
    $USING PP.InboundCodeWordService
    $USING PP.PaymentWorkflowGUI
    $USING PP.PaymentWorkflowDASService
    $USING PP.MessageMappingService
    $USING PP.InwardMappingFramework
    $USING PP.PaymentWorkflowService
*----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
    
RETURN
*-----------------------------------------------------------------------------
initialise:
    ftNumber = ''
    iPaymentID = ''
    IDVAL = ''
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    transactionType = ''
    oChannel = ''
    iOriginatingSource = ''
    clearingTxnType = ''
    iOriginatingSource = ''
    sendersReferenceIncoming = ''
    creditMainAcc =  ''
    txnAmtRet = ''
    sendersReferenceOutgoing=''
    statusCode=''
    debitMainAcc=''
    txnAmtOrg=''
    
RETURN
*-----------------------------------------------------------------------------
process:
    GOSUB retrieveOriginalTxnInfo
    orgTxnDetails = oChannel :@VM: sendersReferenceOutgoing :@VM: debitMainAcc
    retTxnDetails = iOriginatingSource :@VM: sendersReferenceIncoming :@VM: creditMainAcc
*   Conditions to identify the original CT transaction that was sent out for an incoming return(RT).
    IF ((clearingTxnType EQ 'RT'AND transactionType EQ 'CT') AND (statusCode NE '996':@VM:'997') AND (orgTxnDetails EQ retTxnDetails) AND (txnAmtOrg EQ txnAmtRet)) THEN
        GOSUB setOuput ; *set output details for successfully matched scenario
    END ELSE
        GOSUB setNoOuput
    END
    
RETURN
*-----------------------------------------------------------------------------
retrieveOriginalTxnInfo:
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = iFTNumber
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = iCompanyID
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
*   Read the Payment Details for the Transaction of RT
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    oPaymentRecordCurr = oPaymentRecord
    clearingTxnType = oPaymentRecordCurr<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    iOriginatingSource = oPaymentRecordCurr<PP.PaymentWorkflowDASService.PaymentRecord.originatingSource>
    sendersReferenceIncoming =oPaymentRecordCurr<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceIncoming>
    creditMainAcc =  oPaymentRecordCurr<PP.PaymentWorkflowDASService.PaymentRecord.creditMainAccount>
    txnAmtRet = oPaymentRecordCurr<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>
*   Form id and read concat table
    IDVAL = sendersReferenceIncoming:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
    IF ERR.CONCAT NE '' THEN
        GOSUB setNoOuput ; *
        RETURN
    END
*   If record present
    IF R.TRANSACTION.CONCAT THEN
        iOrgPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = R.TRANSACTION.CONCAT<1>
        iOrgPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = R.TRANSACTION.CONCAT<1>[1,3]
*   Read the Payment Details for the Transaction
        PP.PaymentWorkflowDASService.getPaymentRecord(iOrgPaymentID, oPaymentRecordOrg, oAdditionalPaymentRecord, oReadErr)
        IF oPaymentRecordOrg NE '' THEN
            transactionType =  oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
            statusCode = oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
            oChannel = oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.outputChannel>
            sendersReferenceOutgoing = oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceOutgoing>
            debitMainAcc = oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.debitMainAccount>
            txnAmtOrg =  oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>
        END ELSE
            GOSUB setNoOuput ; *
            RETURN
        END
    END
   
RETURN
*-----------------------------------------------------------------------------
*** <region name= setOuput>
setOuput:
*** <desc>set output details for successfully matched scenario </desc>
    oResponseStatus = 'OK' ;* OK
    oPaymentStatusCode = oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
    oOriginalTrnFTNumber = oPaymentRecordOrg<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= setNoOuput>
setNoOuput:
*** <desc>set output details for failure scenario </desc>
    oResponseStatus = 'NOK' ;* Not OK
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
