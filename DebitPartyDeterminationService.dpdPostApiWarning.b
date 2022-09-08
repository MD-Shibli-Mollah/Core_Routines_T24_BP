* @ValidationCode : MjoxNjAwMzYyNTE5OkNwMTI1MjoxNjA0OTAwOTI1NDQ3Om5hZ2FsYWtzaG1pcDoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE0LTEzNTc6NTI6NTI=
* @ValidationInfo : Timestamp         : 09 Nov 2020 11:18:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nagalakshmip
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/52 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200914-1357
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
* 30/10/2020 - Defect 4041948 / Task 4053262 -  System will debit InternalSuspenseAccount from Clearing for DEBIN product.
*-----------------------------------------------------------------------------

$PACKAGE PP.DebitPartyDeterminationService
SUBROUTINE DebitPartyDeterminationService.dpdPostApiWarning(iTransactionContext, iAdditionalContext, oHookApiResponse)
    $INSERT I_PaymentFrameworkService_HookApiOutputDetails
    $INSERT I_PaymentFrameworkService_HookApiResponse
    $INSERT I_DebitPartyDeterminationService_PartyDebitDetails
    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
    $INSERT I_DebitPartyDeterminationService_TransactionContext
    $USING PP.PaymentWorkflowDASService
    $USING EB.DataAccess
    $USING PP.LocalClearingService
    
    
    GOSUB localInitialise
    GOSUB process
RETURN
*---------------------------------------------------------------------------------------------------------------------------
process:
    
    GOSUB getDebitPartyDetails
    debtorName = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1>
    debtorNameSepa = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName>

    IndexDebtorName=INDEX(debtorName,'CpdDpdApiWarRes',1)
    IndexDebtorNameSepa=INDEX(debtorNameSepa,'CpdDpdApiWarRes',1)
  
   
    IF IndexDebtorName GE 1 OR IndexDebtorNameSepa GE 1 THEN
        GOSUB determineApiResponse
    
    END
    porID=iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.ftNumber>
    EB.DataAccess.FRead(FnPorTransaction, porID, RPorTransaction, FPorTransaction, ErPorTransaction)
    
* System will debit InternalSuspenseAccount from Clearing for DEBIN product with SettlmentType set as GROSS and RTGS set as 'Y'
    IF RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxOriginatingsource> EQ 'DEBIN' AND RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxClearingtransactiontype> EQ 'CT' THEN
        GOSUB getClearingSetting
        oHookApiResponse<HookApiOutputDetails.accountCompanyID> = oClearingSetting<PP.LocalClearingService.ClearingSetting.clearingAccountCompany>
        oHookApiResponse<HookApiOutputDetails.accountNumber>  = oClearingSetting<PP.LocalClearingService.ClearingSetting.suspenseAccountNumber>
        oHookApiResponse<HookApiOutputDetails.accountCurrency> = oClearingSetting<PP.LocalClearingService.ClearingSetting.clearingAccountCurrency>
    END

RETURN
*---------------------------------------------------------------------------------------------------------------------------
getClearingSetting:
*--------------
    iClearingSetting = ''
    oClearingSetting = ''
    oClearingSettingErr = ''

    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.companyID> = iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.companyId>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingID> = RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxOriginatingsource>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingCurrency> = RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxTransactioncurrencycode>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.messageDirection> = 'R'
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.messagePaymentType> = RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxIncomingmessagetype>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingNatureCode> = RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxClearingnaturecode>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingTransactionType> =  RPorTransaction<PP.PaymentWorkflowDASService.PorTransaction.PpptxClearingtransactiontype>
    PP.LocalClearingService.getClearingSetting(iClearingSetting, oClearingSetting, oClearingSettingErr)
RETURN
*------------------------------------------------------------------------------
localInitialise:
    debtorName = ''
    debtorNameSepa=''
    FnPorTransaction = 'F.POR.TRANSACTION'                                      ;* Open the POR.TRANSACTION
    FPorTransaction = ''
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------
*** <region name= getDebitPartyDetails>
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
*---------------------------------------------------------------------------------------------------------------------------
determineApiResponse:
  
    oHookApiResponse<HookApiResponse.responseText> = 'Account Restriction has been Set'
    oHookApiResponse<HookApiResponse.responseType> = 'WAR'
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------
     
    
    

END
