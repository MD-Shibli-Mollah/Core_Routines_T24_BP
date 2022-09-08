* @ValidationCode : MjoyMDM5NzI2MzkwOkNwMTI1MjoxNjA1MDY3MjE3NjAxOnVtYW1haGVzd2FyaS5tYjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Nov 2020 09:30:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPISIP.Foundation
SUBROUTINE PPISIP.ORIGINAL.PAYMENT.ID.API(ioPaymentObject,originalFTNumber,statusCode,errorCode)
*-----------------------------------------------------------------------------
*  Original Payment Identification API for SA INST incoming reversals.
*  Attached in PP.MSGMAPPINGPARAMETER>SAINST.camt.056
*  OriginalFTnumber and statusCode are updated and sent out.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 27/09/2020 - Enhancement 3675355 / Task 3929661 - SAINST
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.InwardMappingFramework
    
    
    GOSUB initialise    ; *Initialise the variables
    GOSUB process       ; *Find the original FTNumber
    CALL TPSLogging("DB Input","PPISIP.ORIGINAL.PAYMENT.ID.API.SAINSTCHECK"," Task 2980186 02 SEP 2020 : <originalFTNumber:":originalFTNumber:':':statusCode:">","")
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>initialise the variables </desc>
 
    originalFTNumber = ''
    statusCode = ''

    
    originalFTNumber = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>
    CALL TPSLogging("DB Input","PPISIP.ORIGINAL.PAYMENT.ID.API.SAINSTCHECK"," Task 2980186 02 SEP 2020 : <concatId:":originalFTNumber:">","")
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc>Find the original FTNumber </desc>
    GOSUB getPaymentRecord
    IF oPaymentRecord THEN                  ;* Status code
        errorCode  = ''
        statusCode = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= getPaymentRecord>
getPaymentRecord:
*** <desc>Get the payment record </desc>
    iPaymentID = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = originalFTNumber
    IF originalFTNumber THEN
        PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    END
RETURN
*** </region>
END


