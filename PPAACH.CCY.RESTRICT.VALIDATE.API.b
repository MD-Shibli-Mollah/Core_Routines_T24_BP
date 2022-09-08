* @ValidationCode : MjotMTQ1MjkxOTEyOkNwMTI1MjoxNTYxMjA4ODAwMjk3OmVzb29yeWE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNC4yMDE5MDQxMC0wMjM5OjM5OjM5
* @ValidationInfo : Timestamp         : 22 Jun 2019 18:36:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : esoorya
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 39/39 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.CCY.RESTRICT.VALIDATE.API(iMessageContent, oValidationDetails, oValResponse)
*----------------------------------------------------------------------------------------------------------------
* Argentina Direct Debit should only be processed when originating customers account currency (Creditor account curreny) and Transaction currency are in ARS
* This API validate if the Customer account currency and Transaction currency is ARS. This will be attached in the Validate API field on PP.MSG.ACCEPTANCE.PARAM.
*
* Parameters
*
* IN iMessageContent  Transformed transaction as incoming parameter.
* OUT oValidationDetails
* OUT oValResponse  response to be updated after validation
*----------------------------------------------------------------------------------------------------------------
* Modification History :
*----------------------------------------------------------------------------------------------------------------
* 13/05/2019 - Enhancement 2959657 / Task 2959618
*              Argentina DD payments are restricted to ARS currency. Reject the incoming payment if either of the currency is not ARS
*----------------------------------------------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING PP.MessageAcceptanceService
    $USING PP.InwardMappingFramework
        
    GOSUB initialise
    GOSUB process
    
RETURN
*-----------------------------------------------------------------------------------------------------------------
*** <region name= Initialise>
initialise:
*** <desc>Initialise the variables used </desc>
   
    pos = ''
    tag = '<BulkHeader>'  ;* the Creditor Account currency and transaction currency is present in bulk header.
    pos = 2
    Content = ''
    Content = FIELD(iMessageContent,tag,pos)
    oValidationDetails = ''

    
RETURN
*------------------------------------------------------------------------------------------------------------------
*** <region name= ValidateCcy>
process:
*-------
*** <desc> validating the creditor currency and instructed amount currency </desc>

    GOSUB extractCreditorAcctCcy ;* extract the value in the tag CreditorACcountCurency
 
    GOSUB extractIntructedAmtCcy ;* extract the transaction currency from the tag instructed amount
    
    GOSUB ValidateCcy ;* If either of the currency is not ARS, the payment should be rejected.
       
RETURN

*-----------------------------------------------------------------------------
*** <region name= ValidateCcy>
ValidateCcy:
*----------
*** <desc>If either of the currency is not ARS, the payment should be rejected*** </desc>

    IF ((CredAcctCcy NE '' AND CredAcctCcy NE 'ARS') OR IntructedAmtCcy NE 'ARS') THEN
  
        oValResponse<PPAACH.ClearingFramework.PaymentResponse.returnCode>='FAILURE'
        oValResponse<PPAACH.ClearingFramework.PaymentResponse.serviceName>='InwardMappingFramework'
        oValResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageCode> = 'ARG10001'
        oValResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageInfo> = 'REJECTED'
        oValResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageText> = 'Only ARS currency transactions are allowed'
        oValResponse<PPAACH.ClearingFramework.PaymentResponse.responseMessages,1,PPAACH.ClearingFramework.ResponseMessage.messageType> = 'NON_FATAL_ERROR'
    
    END
   
RETURN
*-------------------------------------------------------------------------------------------------------------------
*** <region name= extractCreditorAcctCcy>
extractCreditorAcctCcy:
*--------------------
*** <desc>extract the value in the tag CreditorACcountCurency</desc>

    tag = '<CreditorAccountCurrency>'
    tagContent = ""
    tagValue = ""
    tagContent = FIELD(Content,tag,pos)
    CredAcctCcy = FIELD(tagContent,'</CreditorAccountCurrency>',1,1)
    
RETURN
*-------------------------------------------------------------------------------------------------------------------
*** <region name= extractIntructedAmtCcy>
extractIntructedAmtCcy:
*---------------------
*** <desc>extract the transaction currency from the tag instructed amount</desc>

    tag = '<InstructedAmount>'
    tagContent = ""
    tagValue = ""
    tagContent = FIELD(Content,tag,pos)
    tagValue = FIELD(tagContent,'</InstructedAmount>',1,1)
    
    tag = '<Currency>'
    tagContent = ""
    tagContent = FIELD(tagValue,tag,pos)
    IntructedAmtCcy = FIELD(tagContent,'</Currency>',1,1)
    
RETURN

;*------------------------------------------------------------------------------------------------------------------------
