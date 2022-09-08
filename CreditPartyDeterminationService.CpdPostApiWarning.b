* @ValidationCode : MjotNTkyMzgzMjM2OkNwMTI1MjoxNTQzOTIzMzAxMDIwOnNrYXlhbHZpemhpOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjozMDozMA==
* @ValidationInfo : Timestamp         : 04 Dec 2018 17:05:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/30 (100.0%)
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
** 16/11/2018 - Enhancement 2822509/Task 2856019- Componentization changes
*-----------------------------------------------------------------------------

$PACKAGE PP.CreditPartyDeterminationService
SUBROUTINE CreditPartyDeterminationService.CpdPostApiWarning(iTransactionContext, iDetermineCreditParty, oHookApiResponse)
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
    
    IndexCreditorName=INDEX(creditorName,'CpdDpdApiWarRes',1)
    IndexCreditorNameSepa=INDEX(creditorNameSepa,'CpdDpdApiWarRes',1)
  
   
    IF IndexCreditorName GE 1 OR IndexCreditorNameSepa GE 1 THEN
        GOSUB determineApiResponse
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
    
    oHookApiResponse<HookApiResponse.responseText> = 'Account Restriction has been Set'
    oHookApiResponse<HookApiResponse.responseType> = 'WAR'
    
  

*------------------------------------------------------------------------------
RETURN
     



END
