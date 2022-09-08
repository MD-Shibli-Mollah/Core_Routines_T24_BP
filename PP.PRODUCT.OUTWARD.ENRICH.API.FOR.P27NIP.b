* @ValidationCode : MjotNDkzMTE2NTpDcDEyNTI6MTYxODQ4MDIzMTk1OTpzdHV0aS5zaW5naDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6MzY6MzY=
* @ValidationInfo : Timestamp         : 15 Apr 2021 15:20:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stuti.singh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPINIP.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.P27NIP(iPaymentDets, ioIFEmitDets)
*----------------------------------------------------------------------------------------------------------------------------------------
** This API returns the unique ID which should be mapped to SendersReferenceOutgoing of POR.Transaction table.
* and a 34 digit Unique trace number.
*-----------------------------------------------------------------------------
*
* Parameters:
*
* INOUT     iPaymentDets            string     incoming Payment Details
* INOUT     ioIFEmitDets             string     incoming IF Details

*    iPaymentDetailsA = ioIFEmitDets<2>
*    iPorTransaction = ioIFEmitDets<3>
*    iCancelReqRec = ioIFEmitDets<4>
*    iDebitAuthInfo = ioIFEmitDets<5>
*    iCreditPartyDet = ioIFEmitDets<6>
*    iPrtyDbtDetails = ioIFEmitDets<7>
*    iPaymentInformation = ioIFEmitDets<8>
*    iAdditionalInfDetails = ioIFEmitDets<9>
*    iAccInfoDetails = ioIFEmitDets<10>
*    iRemittanceInfo = ioIFEmitDets<11>
*    iPaymentFlowDets = ioIFEmitDets<12>
*    iRegulatoryRepDets = ioIFEmitDets<13>
*    iPorRelatedRemittanceInfo = ioIFEmitDets<14>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 27/09/2020 - Enhancement 2852895 / Task 4148535 - P27NIP - Enrich unique ref
* 12/04/2021 - Defect - 4333141 / Task - 4339084 - Regression Fix
*-----------------------------------------------------------------------------

    $USING PP.OutwardMappingFramework
    $USING PP.OutwardInterfaceService
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowGUI

    CALL TPSLogging("DB Output","outward enrich api.P27NIP","ioFileData Task  23 DEC 2020 : <ioIFEmitDets:":ioIFEmitDets:">","")
    GOSUB initialise ; *
    GOSUB process ; *
    CALL TPSLogging("DB Output","outward enrich api.P27NIP","ioFileData Task  23 DEC 2020 : <iPaymentDets:":iPaymentDets:">","")
    CALL TPSLogging("DB Output","outward enrich api.P27NIP","ioFileData Task  23 DEC 2020 : <ioIFEmitDets:":ioIFEmitDets:">","")
RETURN

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>

    iPorTransaction     = RAISE(ioIFEmitDets<3>)
    iPaymentFlowDets    = RAISE(ioIFEmitDets<12>)
    companyID           = FIELD(iPaymentDets,'*',1)
    fTNumber            = FIELD(iPaymentDets,'*',2)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> </desc>

    iLockingId = 'PPINIP.UNIQREF' ;* locking file record id
    iAgentDigits = '3';* length of the seq no from agent's relative position
    iRandomDigitsLen = '10' ;* length of the unique reference number  from locking record
    iReserved = ''
    oTimestamp = ''
    oTimestampResponse = ''
    PP.PaymentFrameworkService.createTimestamp(oTimestamp, oTimestampResponse)
    
    PPINIP.Foundation.ppinipGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen, iReserved, oUniqueReference, oReserved)

    iPaymentFlowDets<PP.OutwardInterfaceService.PaymentFlowDets.localRefName> = 'Unique.id'
    iPaymentFlowDets<PP.OutwardInterfaceService.PaymentFlowDets.localRefValue> = 'NPCT':oTimestamp:oUniqueReference
    GOSUB updateSupplementaryInfo
    ioIFEmitDets<12> = LOWER(iPaymentFlowDets)

RETURN
*-----------------------------------------------------------------------------

*** </region>

*** <region>
updateSupplementaryInfo:
*** <desc>Paragraph to update the POR.SUPPLEMENTARY.INFO </desc>
    R.POR.SUPPLEMENTARY.INFO = ''
    Error = ''
    
    GOSUB getSupplementaryInfo ; *Paragraph to get details from POR.SUPPLEMENTARY.INFO
    R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname> = 'Unique.id'
    R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue> = 'NPCT':oTimestamp:oUniqueReference
    Error =''
    PP.PaymentWorkflowGUI.updateSupplementaryInfo('POR.PAYMENTFLOWDETAILS', fTNumber, R.POR.SUPPLEMENTARY.INFO, '', Error)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region>
getSupplementaryInfo:
*** <desc>Paragraph to get details from POR.SUPPLEMENTARY.INFO </desc>
    R.POR.SUPPLEMENTARY.INFO = ''
    Error = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS',fTNumber,'',R.POR.SUPPLEMENTARY.INFO,Error)
RETURN
*** </region>
*-----------------------------------------------------------------------------

END
