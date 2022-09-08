* @ValidationCode : MjotMTkwMzcwMjM3MDpDcDEyNTI6MTYwNTg3ODA4OTM3MjpqYXlhc2hyZWV0OjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA3MDEtMDY1Nzo0ODo0OA==
* @ValidationInfo : Timestamp         : 20 Nov 2020 18:44:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 48/48 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPEWSP.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.EWSEPA(iPaymentDets,ioIFEmitDets)
*-----------------------------------------------------------------------------
*This API is attached invoked during OutwardMappingFramework.enrichOutMessageDetails.
* For outgoing pacs.007, bulkSendersReference is mapped from bulkRefOutgoing.
*-----------------------------------------------------------------------------
* Modification History :
*03/11/2020 - Task 4061359 - EWSEPA-Pacs007 -OrgnlMsgId tag issue - Mapping bulkReferenceOutgoing of original pacs.003 to bulkSendersReference for RV transaction
*20/11/2020 - Task 4085642 - Nordic CT-Pacs028 -OrgnlMsgId tag issue - Mapping sentReference of EBQA to bulkReferenceOutgoing for SR,SR-CA,SR-CM transaction
*-----------------------------------------------------------------------------
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentWorkflowGUI
    $USING PP.LocalClearingService
    $USING DE.Messaging
*-----------------------------------------------------------------------------
    GOSUB initialise ; *Initialise the local variables used.
    GOSUB process ; *Paragraph to split the payment into multiple IF emit based on conditions.
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Initialise the local variables used. </desc>
    
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    R.POR.SUPPLEMENTARY.INFO = ''
    Error = ''
    ftNumber = ''
    origFTNumber = ''
    oriEBQAid = ''
    bulkReferenceOutgoing= ''
    getEBQARecord = ''
    errCamtInfomation = ''
    txnType = ''
    
    ftNumber = FIELDS(iPaymentDets,'*',2)
    iporTransactionDets = RAISE(ioIFEmitDets<3>)
    iCanReq = RAISE(ioIFEmitDets<10>)
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Paragraph to split the payment into multiple IF emit based on conditions. </desc>
    
    IF iporTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'RV' THEN
        GOSUB getSupplementaryInfo
        GOSUB getPaymentRecord ; *Paragraph to get the payment record details
        iporTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.bulkSendersReference> = oAdditionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.bulkReferenceOutgoing>
    END
    
    txnType = iporTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType>
    IF txnType EQ 'SR' OR txnType EQ 'SR-CA' OR txnType EQ 'SR-CM' THEN
        GOSUB getEBQAInformation
        iporTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.bulkReferenceOutgoing> = bulkReferenceOutgoing
    END
    ioIFEmitDets<3> = LOWER(iporTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
RETURN
*** </region>

*-----------------------------------------------------------------------------
getSupplementaryInfo:
*** <desc>Paragraph to get details from POR.SUPPLEMENTARY.INFO </desc>
    
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS',ftNumber,'',R.POR.SUPPLEMENTARY.INFO,Error)
RETURN
*** </region>
*-----------------------------------------------------------------------------
getPaymentRecord:
*** <desc>Paragraph to get the payment record details </desc>
* Initialise variables for PP.PaymentWorkflowDASService.getPaymentRecord routine
    origFTNumber = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.OrgnlOrReturnId>
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = origFTNumber[1,3]    ;* Company ID
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = origFTNumber          ;* FT Number

* If the OriginalBahMessageID tag contains FT Number, then we can get the Payment Record details for the particular company ID and respective FT Number
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
RETURN
*** </region>
*-----------------------------------------------------------------------------
getEBQAInformation:
*** <desc>Paragraph to get details from EBQA </desc>
    oriEBQAid = iCanReq<PP.LocalClearingService.PpCanReq.ebQaId>
    IF oriEBQAid NE '' THEN
        getEBQARecord = DE.Messaging.EbQueriesAnswers.Read(oriEBQAid, errCamtInfomation)
        IF errCamtInfomation EQ '' THEN
            bulkReferenceOutgoing = getEBQARecord<DE.Messaging.EbQueriesAnswers.EbQaSentReference>
            bulkReferenceOutgoing = FIELDS(bulkReferenceOutgoing,'##',2)
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
