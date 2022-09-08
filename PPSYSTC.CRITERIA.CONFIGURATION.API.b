* @ValidationCode : Mjo1NjQ4NTg5NTU6Q3AxMjUyOjE1OTcyMzkzOTk5ODc6c2theWFsdml6aGk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjIwOjIw
* @ValidationInfo : Timestamp         : 12 Aug 2020 19:06:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/20 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYSTC.CRITERIA.CONFIGURATION.API(iCriteriaConfAPIInput, oCriteriaDets)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
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
    ftNumber = iCriteriaConfAPIInput<PPSYTC.ClearingFramework.CriteriaConfAPIInput.ftNumber>

*
RETURN
*------------------------------------------------------------------------------
process:
    
    GOSUB getPaymentRecord
    IF iCriteriaConfAPIInput<PPSYTC.ClearingFramework.CriteriaConfAPIInput.clearingTransactionType> EQ 'DD' THEN
        oCriteriaDets<PPSYTC.ClearingFramework.CriteriaConfDet.genericCriteriaInput1> = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingNatureCode>
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
