* @ValidationCode : MjoxMzYzNDYyMzY1OkNwMTI1MjoxNjAzODE0NTYxMDg3OmpheWFzaHJlZXQ6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3OjQxOjM3
* @ValidationInfo : Timestamp         : 27 Oct 2020 21:32:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 37/41 (90.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------------------------------
$PACKAGE PPNPCT.Foundation
SUBROUTINE PPNPCT.PHYSICAL.FILENAME.API(iPaymentRecord,iAdditionalPaymentRecord,iGenericInfo,oFileName)
*---------------------------------------------------------------------------------------------------------------
* Implementation of PPNPCT.Foundation.ppnpctPhysicalFilenameApi
*
* iPaymentRecord(IN) :In parameter contains payment details.
* iAdditionalPaymentRecord(IN) :In parameter holds additional payment details.
* iGenericInfo(IN) :In parameter of the routine
* oFileName(OUT) :Out parameter of the routine will carry the filename of the file which is going to be generated for outgoing payments.
*
*Program Description:
* Program used to get the file name for the outgoing payments of the Nordic CT clearing and will be called from routine "mapCreditTransfer" of the OutwardMappingFramework component.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*23/10/2020 - Enhancement 3852940/Task 4017144 - For determining Physical File name
*-----------------------------------------------------------------------------
 
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    $INSERT I_CLEARING.SETTLEMENT.SERVICE.COMMON
*------------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
    GOSUB finalise
    
RETURN
*------------------------------------------------------------------------------
initialise:
***********

    CHANGE @VM TO @FM IN iPaymentRecord
    CHANGE @VM TO @FM IN iAdditionalPaymentRecord
    CHANGE @VM TO @FM IN iGenericInfo

    serviceIdentifer = ''
    oFileName = ''
    txnType = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.clearingTransactionType>
    fileReference = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileReference>
    IF iGenericInfo<PP.OutwardMappingFramework.GenericInfo.outMsgType> NE '' THEN
        outMsgTyp = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.outMsgType>
    END ELSE
        outMsgTyp = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    END

RETURN
*------------------------------------------------------------------------------
process:
 
    GOSUB getCompanyBic
    
    PP.OutwardMappingFramework.ppGetSentfileFilename(fileReference, outFileName)
    IF outFileName<1> NE '' THEN
        oFileName = outFileName<1>
    END ELSE
*file type should be updated as I or Q based on the outgoing message type
        IF (outMsgTyp EQ 'pacs.008') OR (outMsgTyp EQ 'camt.056') OR (outMsgTyp EQ 'camt.029' AND txnType EQ 'RI') OR  (outMsgTyp EQ 'pacs.004') OR (outMsgTyp EQ 'pacs.028' AND txnType EQ 'SR') THEN
            typeOfFile = 'I'
        END
        IF (outMsgTyp EQ 'camt.087') OR (outMsgTyp EQ'camt.027') OR (outMsgTyp EQ 'camt.029'AND (txnType EQ 'RI-CA' OR txnType EQ 'RI-CM')) OR (outMsgTyp EQ 'pacs.028' AND (txnType EQ 'SR-CA' OR txnType EQ 'SR-CM')) THEN
            typeOfFile = 'Q'
        END
        oFileName = 'NP02NCT': companyBic: fileReference[1,15]: '.':typeOfFile
    END
    
RETURN
*------------------------------------------------------------------------------
getCompanyBic:
****************
    companyBic      = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyBic>
* If Company BIC does not have value, then assign the value from Common variable TPS.COMPANY.BIC
    IF companyBic EQ '' THEN
        companyBic = TPS.COMPANY.BIC
    END
RETURN
*------------------------------------------------------------------------------
finalise:
**********
    CHANGE @FM TO @VM IN iPaymentRecord
    CHANGE @FM TO @VM IN iGenericInfo
    CHANGE @FM TO @VM IN iAdditionalPaymentRecord
    
RETURN
*------------------------------------------------------------------------------
END
