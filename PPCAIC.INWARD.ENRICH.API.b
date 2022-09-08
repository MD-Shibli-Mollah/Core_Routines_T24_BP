* @ValidationCode : MjoxNzE2MDgwODgxOkNwMTI1MjoxNjE1OTYyNzExNTI1OmxhdmFueWFzdDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6MzI6MzI=
* @ValidationInfo : Timestamp         : 17 Mar 2021 12:01:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lavanyast
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 32/32 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPCAIC.Foundation
SUBROUTINE PPCAIC.INWARD.ENRICH.API(ioPaymentObject, orAuditTrailLogFields)
*-----------------------------------------------------------------------------
* Modification History :
* 11/02/2021 - Enhancement 3988349/Task 3817811- Enrich API for C1INTRC clearing
* 17/03/2021 - Enhancement-3988349 /Task - 4225703- Update localFieldName when return transaction is processed.
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentFrameworkService
    $USING PP.PaymentWorkflowDASService
    $USING PP.OutwardMappingFramework
    $USING EB.SystemTables
    $USING PP.PaymentSTPFlowService
    $USING PP.LocalClearingService
    $USING PP.PaymentGenerationService
    
    GOSUB initialise ; *initialise variables
    GOSUB process ; *
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
    
*** <desc> </desc>
    returnId=''
    clrgTxnType=''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
    
*** <desc> </desc>
    IF ioPaymentObject NE '' THEN
        returnId= ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,1,PP.MessageMappingService.PORPmtFlowDetailsList.originalOrReturnId>
        IF returnId NE '' THEN
            GOSUB getSupplementaryInfo
            IF oPORPmtFlowDetailsGetError EQ '' THEN
                LOCATE "RETURN RECEIVED" IN oPaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,1> SETTING pos  ELSE
                    oPaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'RETURN RECEIVED'     ;* Update the POR.SUPPLEMENTARY.INFO in Local Field Name and Value fields
                    oPaymentFlowDetails<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = 'Y'
                    GOSUB updateSupplementaryInfo
                END
            END
        END
    END
    
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= getSupplementaryInfo>
getSupplementaryInfo:
    
*** <desc>Get Ssupplementary info of the payment </desc>
   
    oPaymentFlowDetails         = ''
    oPORPmtFlowDetailsGetError  = ''
    iPORPmtFlowDetailsReq       = ''
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID>    = returnId[1,3]
    iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber>     = returnId
    PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPaymentFlowDetails, oPORPmtFlowDetailsGetError)
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= updateSupplementaryInfo>
updateSupplementaryInfo:
    
*** <desc> </desc>
* Update the supplementary table of original payment.
    iUpdatePaymentFlowDetails = ''
    oPORPmtFlowDetailsUpdError = ''
    iUpdatePaymentFlowDetails = oPaymentFlowDetails
    PP.PaymentFrameworkService.updatePORPaymentFlowDetails(iUpdatePaymentFlowDetails, oPORPmtFlowDetailsUpdError)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
