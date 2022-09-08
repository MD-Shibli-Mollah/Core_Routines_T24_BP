* @ValidationCode : MjotMjk2NTc2NjQ0OkNwMTI1MjoxNjAwMTY0MDMwNzMxOm1hbmltZWdhbGFpazoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6NTc6NTY=
* @ValidationInfo : Timestamp         : 15 Sep 2020 15:30:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manimegalaik
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 56/57 (98.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.ORIGINAL.PAYMENT.ID.API(ioPaymentObject,originalFTNumber,statusCode,errorCode)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
** 20/02/2020 - Enhancement 3454077 /3598782: Task for Code-Bpay Clearing changes
* 22/02/2020 - Task 3604298
* 06/05/2020 - Task 3730032 - Inward cheque return file is handled
*15/09/2020 - Enhancement 3886687 / Task 3949511: Coding Task - Generic cleanup process for Archival read in PP dependent modules
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.InwardMappingFramework
    $USING EB.DataAccess
    
    GOSUB initialise
    GOSUB process
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>
    originalFTNumber = ''
    statusCode = ''
    errorCode = ''
    tempOriginalFTnumber = ''
    
    tempOriginalFTnumber= ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>
    
    IF tempOriginalFTnumber EQ '' THEN
        GOSUB formConcatID
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> </desc>
 
    
    FN.POR.TRANSACTION.CONCAT = 'F.POR.TRANSACTION.CONCAT'
    F.POR.TRANSACTION.CONCAT = ''
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    iOriginatingSource=ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    IDVAL = tempOriginalFTnumber:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
   
    IF R.TRANSACTION.CONCAT EQ '' THEN
        IF chequePmt NE 1 THEN
            ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionCurrencyCode> = 'XAF'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyRole>='BENFCY'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyRoleIndicator>='R'
        END
    END ELSE
        originalFTNumber = R.TRANSACTION.CONCAT<1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,1,PP.MessageMappingService.PORPmtFlowDetailsList.originalOrReturnId> = R.TRANSACTION.CONCAT<1>
        GOSUB getPaymentRecordForOrigFT
        IF oPaymentRecord THEN
            statusCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
        END
    END
    
                    
RETURN
*** </region>
 
getPaymentRecordForOrigFT:
***************************
    iPaymentID =''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''

    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = originalFTNumber
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = originalFTNumber[1,3]

    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr) ;* To read POR.TRANSACTION

RETURN

*-----------------------------------------------------------------------------
formConcatID:
    
    chequeNumber = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.chequeNumber>
    txnAmt = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionAmount>
        
    role = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>
    cnt = DCOUNT(role,@VM)
    intCount = 1
    LOOP
    WHILE intCount LE cnt
        IF role<1,intCount,PP.MessageMappingService.PartyDebit.debitPartyRole> EQ 'DEBTOR' THEN
            debitAct = role<1,intCount,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>
        END
        intCount = intCount + 1
    REPEAT
    tempOriginalFTnumber = chequeNumber:'-':txnAmt:'-':debitAct
    chequePmt = 1
   
RETURN
*-----------------------------------------------------------------------------
END
