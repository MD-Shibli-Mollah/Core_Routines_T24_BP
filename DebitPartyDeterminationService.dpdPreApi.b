* @ValidationCode : MjoxMDIzMDYxMzk5OkNwMTI1MjoxNTQzOTIzMjUyNjE1OnNrYXlhbHZpemhpOjE2OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6MTE1OjExNQ==
* @ValidationInfo : Timestamp         : 04 Dec 2018 17:04:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 16
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 115/115 (100.0%)
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
SUBROUTINE DebitPartyDeterminationService.dpdPreApi(iTransactionContext, iAdditionalContext, oHookApiOutput)

    $INSERT I_PaymentFrameworkService_HookApiOutputDetails
    $INSERT I_PaymentFrameworkService_HookApiResponse
    $INSERT I_DebitPartyDeterminationService_DpdAdditionalContext
    $INSERT I_DebitPartyDeterminationService_PartyDebitDetails
    $INSERT I_DebitPartyDeterminationService_TransactionContext
    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
    $INSERT I_F.POR.TRANSACTION
    $USING EB.DataAccess
   
   
    
    
    GOSUB localInitialise
    porID=iTransactionContext<PP.DebitPartyDeterminationService.TransactionContext.ftNumber>
    
    EB.DataAccess.FRead(FnPorTransaction, porID, RPorTransaction, FPorTransaction, ErPorTransaction)
    
    IF ErPorTransaction EQ '' THEN
;* For payment which goes to output warehouse queue, api should not be triggered
        IF RPorTransaction<PPPTX.StatusCode> NE '660' THEN

            GOSUB process
    
        END
        ELSE
            oHookApiOutput= ''
        END
    END
RETURN
    
*-----------------------------------------------------------------------------
process:
    
    GOSUB getDebitPartyDetails
   
    debtorName = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1>
    debtorNameSepa = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName>

;* Invalid case
    IndexDebtorNameInv=INDEX(debtorName,'CpdDpdApiErrInv',1)
    IndexDebtorNameSepaInv=INDEX(debtorNameSepa,'CpdDpdApiErrInv',1)
  
;* Restricted case
    IndexDebtorNameRes=INDEX(debtorName,'CpdDpdApiWarRes',1)
    IndexDebtorNameSepaRes=INDEX(debtorNameSepa,'CpdDpdApiWarRes',1)
   
;*Valid case
    IndexDebtorName=INDEX(debtorName,'CpdDpdApi',1)
    IndexDebtorNameSepa=INDEX(debtorNameSepa,'CpdDpdApi',1)
     
    
    IF IndexDebtorNameInv GE 1 OR IndexDebtorNameSepaInv GE 1 THEN
        GOSUB determineApiOutputInv
    END
    ELSE
        IF IndexDebtorNameRes GE 1 OR IndexDebtorNameSepaRes GE 1 THEN
            GOSUB determineApiOutputRes
    
        END ELSE
            IF IndexDebtorName GE 1 OR IndexDebtorNameSepa GE 1 THEN
                GOSUB determineApiOutput
    
            END
            ELSE
                oHookApiOutput = ''
            END
        END
    END
RETURN
    
*-----------------------------------------------------------------------------

localInitialise:
    
    FnPorTransaction = 'F.POR.TRANSACTION'                                      ;* Open the POR.TRANSACTION
    FPorTransaction = ''
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

determineApiOutput:
    
   
    BEGIN CASE
        
        CASE  iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.originatingSource> EQ 'SWIFT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024303101' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
        
        CASE  iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.incomingMessageType> EQ 'RFDD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = 'EUR1400900010001' ;*nee to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
            
        CASE  iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.originatingSource> EQ 'OE'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302401' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
    
        
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'CT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = 'EUR1000100010001' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
     
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'DD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024303001' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'CC'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302901' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'CD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302901' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'USD'
 
    END CASE
 
RETURN


*-----------------------------------------------------------------------------
    
determineApiOutputInv:
    oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
    oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024303401'
    oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
   
RETURN
   
*-----------------------------------------------------------------------------
    
determineApiOutputRes:
    BEGIN CASE
        
        CASE  iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.originatingSource> EQ 'SWIFT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024303301' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
        
        CASE  iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.originatingSource> EQ 'OE'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103107' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'CT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = 'EUR1000100010001' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
     
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'DD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = 'EUR1000100010001' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'CC'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = 'EUR1000100010001' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        
        CASE iAdditionalContext<PP.DebitPartyDeterminationService.DpdAdditionalContext.clearingTransactionType> EQ 'CD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = 'EUR1000100010001' ;*need to get input from chandru
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
    END CASE


RETURN

*-----------------------------------------------------------------------------
END

