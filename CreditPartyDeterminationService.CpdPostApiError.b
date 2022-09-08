* @ValidationCode : Mjo1MDA0NjcxMzE6Q3AxMjUyOjE1NDM5MjMwMzczOTI6c2theWFsdml6aGk6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2OjUxOjUx
* @ValidationInfo : Timestamp         : 04 Dec 2018 17:00:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/51 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
*author : nandhinisiva@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*This is the dummy api routine which simulates the bank's logic to determine credit party
*and debit party determination. This code is configured in the PP.COMPONENT.API.HOOK table
*
* 16/11/2018 - Enhancement 2822509/Task 2856019- Componentization changes
*-----------------------------------------------------------------------------

$PACKAGE PP.CreditPartyDeterminationService
SUBROUTINE CreditPartyDeterminationService.CpdPostApiError(iTransactionContext, iDetermineCreditParty, oHookApiResponse)
    $INSERT I_PaymentFrameworkService_HookApiResponse
    $INSERT I_CreditPartyDeterminationService_DetermineCreditPartyInput
    $INSERT I_CreditPartyDeterminationService_CreditPartyDetails
    $INSERT I_DebitPartyDeterminationService_TransactionContext
    $INSERT I_CreditPartyDeterminationService_CreditPartyKey
    $USING PP.DebitPartyDeterminationService
    
    
*------------------------------------------------------------------------------
 
    GOSUB localInitialise
    GOSUB process
   
  
RETURN

*------------------------------------------------------------------------------

process:
    
    GOSUB getCreditPartyDetails
    creditorName = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1>
    creditorNameSepa = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crName>
    
    IndexCreditorNameInv=INDEX(creditorName,'CpdDpdApiErrInv',1)
    IndexCreditorNameSepaInv=INDEX(creditorNameSepa,'CpdDpdApiErrInv',1)
    
    IndexCreditorName=INDEX(creditorName,'CpdDpdApiImp',1)
    IndexCreditorNameSepa=INDEX(creditorNameSepa,'CpdDpdApiImp',1)
    
    IndexCreditorNameVal=INDEX(creditorName,'CpdDpdApi',1)
    IndexCreditorNameSepaVal=INDEX(creditorNameSepa,'CpdDpdApi',1)
    
   
    IF IndexCreditorNameInv GE 1 OR IndexCreditorNameSepaInv GE 1 THEN
        GOSUB determineApiResponseInv
    END
    ELSE
        IF IndexCreditorName GE 1 OR IndexCreditorNameSepa GE 1 THEN
            GOSUB determineApiResponse
        END
        ELSE
            IF IndexCreditorNameVal GE 1 OR IndexCreditorNameSepaVal GE 1 THEN
                GOSUB determineApiResponseVal
            END
        END
    END
RETURN
    
    


*------------------------------------------------------------------------------
localInitialise:
        
  
    creditorName = ''
    creditorNameSepa = ''

RETURN
    
*------------------------------------------------------------------------------
        
getCreditPartyDetails:
*** <desc>Call Credit party determination service to get Party Credit details </desc>
    iCreditPartyRole = ''
    oCreditPartyDet = ''
    oGetCreditError = ''
    
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID> = iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.companyId>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber> =iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.ftNumber>
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)
    
RETURN
        
*------------------------------------------------------------------------------
    
determineApiResponse:
    
    IF iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.crMainAccImpFlag> EQ 'Y' THEN
        oHookApiResponse<HookApiResponse.responseText> = 'Credit Account Should not be imposed'
        oHookApiResponse<HookApiResponse.responseType> = 'ERR'
    END
    
    
RETURN
     
*------------------------------------------------------------------------------

determineApiResponseInv:
    
    IF iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.crMainAccNumber> EQ '10024303201' THEN
        oHookApiResponse<HookApiResponse.responseText> = 'Invalid Credit Account'
        oHookApiResponse<HookApiResponse.responseType> = 'ERR'
    END
    
   
RETURN

*------------------------------------------------------------------------------

determineApiResponseVal:
    oHookApiResponse= ''
    
RETURN

*------------------------------------------------------------------------------

END
