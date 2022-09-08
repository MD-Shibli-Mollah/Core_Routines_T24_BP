* @ValidationCode : MjotMTA1Mzg1MzUxNTpDcDEyNTI6MTU5NzMyMDI5NTczNzptci5zdXJ5YWluYW1kYXI6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjIwOjE5
* @ValidationInfo : Timestamp         : 13 Aug 2020 17:34:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/20 (95.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.CRITERIA.CONFIGURATION.API(iCriteriaConfAPIInput, oCriteriaDets)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*13/08/2020 - Enhancement 3538767/Task 3808258-Payments-BHTunsian-Clearing specific API
*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowDASService
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process

RETURN
*------------------------------------------------------------------------------
initialise:
*
    CHANGE @VM TO @FM IN iCriteriaConfAPIInput
    oCriteriaDets = ''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    ftNumber = ''
    ftNumber = iCriteriaConfAPIInput<PPTNCL.Foundation.CriteriaConfAPIInput.ftNumber>
*
RETURN
*------------------------------------------------------------------------------
process:
    GOSUB getPaymentRecord
    IF iCriteriaConfAPIInput<PPTNCL.Foundation.CriteriaConfAPIInput.clearingTransactionType> EQ 'DD' THEN
        oCriteriaDets<PPTNCL.Foundation.CriteriaConfDet.genericCriteriaInput1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.processingDate>
    END
    CHANGE @FM TO @VM IN iCriteriaConfAPIInput
    
RETURN
*------------------------------------------------------------------------------
getPaymentRecord:
* Read Payment Record
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
    
RETURN
*-------------------------------------------------------------------------------------------
END
