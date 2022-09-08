* @ValidationCode : MjotMTU5NjgzNDY5NzpDcDEyNTI6MTU0MzkyMzI1Mjc2Mjpza2F5YWx2aXpoaTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6NTI6NTI=
* @ValidationInfo : Timestamp         : 04 Dec 2018 17:04:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/52 (100.0%)
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

$PACKAGE PP.DebitPartyDeterminationService
SUBROUTINE DebitPartyDeterminationService.dpdPostApiError(iTransactionContext, iAdditionalContext, oHookApiResponse)
    $INSERT I_PaymentFrameworkService_HookApiOutputDetails
    $INSERT I_PaymentFrameworkService_HookApiResponse
    $INSERT I_DebitPartyDeterminationService_PartyDebitDetails
    $INSERT I_DebitPartyDeterminationService_DpdAdditionalContext
    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
    $INSERT I_DebitPartyDeterminationService_TransactionContext
    
    GOSUB localInitialise
    GOSUB process
RETURN
*-----------------------------------------------------------------------------
    
process:
    
    GOSUB getDebitPartyDetails
    debtorName = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1>
    debtorNameSepa = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName>

    IndexDebtorNameInv=INDEX(debtorName,'CpdDpdApiErrInv',1)
    IndexDebtorNameSepaInv=INDEX(debtorNameSepa,'CpdDpdApiErrInv',1)
   
    IndexDebtorName=INDEX(debtorName,'CpdDpdApiImp',1)
    IndexDebtorNameSepa=INDEX(debtorNameSepa,'CpdDpdApiImp',1)
    
    IndexDebtorNameVal=INDEX(debtorName,'CpdDpdApi',1)
    IndexDebtorNameSepaVal=INDEX(debtorNameSepa,'CpdDpdApi',1)
  
    IF IndexDebtorNameInv GE 1 OR IndexDebtorNameSepaInv GE 1 THEN
        GOSUB determineResponseInv
    END
    ELSE
   
        IF IndexDebtorName GE 1 OR IndexDebtorNameSepa GE 1 THEN
            GOSUB determineApiResponse
        END
        ELSE
   
            IF IndexDebtorNameVal GE 1 OR IndexDebtorNameSepaVal GE 1 THEN
                GOSUB determineApiResponseVal
            END
        END
    END
RETURN
     
*-----------------------------------------------------------------------------

localInitialise:
    debtorName = ''
    debtorNameSepa=''
RETURN

*-----------------------------------------------------------------------------

getDebitPartyDetails:
*-------
*** <desc>Call Debit party determination service to get Party Debit details </desc>
    iDebitPartyRole = ''
    oPrtyDbtDetails = ''
    oGetDbtPrtyError = ''
*
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID> = iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.companyId>
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber> = iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.ftNumber>
    
    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetDbtPrtyError)

RETURN
 
*-----------------------------------------------------------------------------
 
determineApiResponse:
    
    IF iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.debitMainAccountImposedFlag> EQ 'Y' THEN
        oHookApiResponse<HookApiResponse.responseText> = 'Debit Account Should not be imposed'
        oHookApiResponse<HookApiResponse.responseType> = 'ERR'
    END
   
RETURN
    
 
*-----------------------------------------------------------------------------
    
determineResponseInv:
    IF iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.debitMainAccount> EQ '10024303401' THEN
        oHookApiResponse<HookApiResponse.responseText> = 'Invalid Debit Account'
        oHookApiResponse<HookApiResponse.responseType> = 'ERR'
    END
    
RETURN
  
*-----------------------------------------------------------------------------
        
determineApiResponseVal:
    oHookApiResponse= ''
    
RETURN
    
*-----------------------------------------------------------------------------
        
END


  
