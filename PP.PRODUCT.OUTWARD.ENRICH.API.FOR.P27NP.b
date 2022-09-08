* @ValidationCode : MjoxMjQyODE2OTA0OkNwMTI1MjoxNjA1ODYxOTg4NzkyOmpheWFzaHJlZXQ6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3OjI5OjI5
* @ValidationInfo : Timestamp         : 20 Nov 2020 14:16:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPNPCT.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.P27NP(iPaymentDets,ioIFEmitDets)
*-----------------------------------------------------------------------------
*This API is attached invoked during OutwardMappingFramework.enrichOutMessageDetails.
* For outgoing pacs.028, bulkReferenceOutgoing is mapped from sentReference of EBQA.
*-----------------------------------------------------------------------------
* Modification History :
*03/11/2020 - Enhancement 3852940/Task 4017144 - Nordic CT-Pacs028 -OrgnlMsgId tag issue - Mapping sentReference of EBQA to bulkReferenceOutgoing for SR,SR-CA,SR-CM transaction
*-----------------------------------------------------------------------------
    $USING PP.OutwardMappingFramework
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

    ftNumber = ''
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
    txnType = iporTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType>
    IF txnType EQ 'SR' OR txnType EQ 'SR-CA' OR txnType EQ 'SR-CM' THEN
        GOSUB getEBQAInformation
        iporTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.bulkReferenceOutgoing> = bulkReferenceOutgoing
    END
    ioIFEmitDets<3> = LOWER(iporTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
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
