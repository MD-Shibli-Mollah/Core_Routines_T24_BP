* @ValidationCode : MjotMTQ3Nzk1MjQ0MzpDcDEyNTI6MTYwMjg1MzA0NzAyOTpuYWdhbGFrc2htaXA6MTY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTQtMTM1NzoxNTM6MTQ4
* @ValidationInfo : Timestamp         : 16 Oct 2020 18:27:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nagalakshmip
* @ValidationInfo : Nb tests success  : 16
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 148/153 (96.7%)
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
* 09/10/2020 - Defect 4010620 / Task 4013090 - System will Map InternalSuspenseAccount from Clearing for DEBIN product eventhough with SettlmentType set as GROSS and RTGS set as 'Y'.
*-----------------------------------------------------------------------------

$PACKAGE PP.CreditPartyDeterminationService
SUBROUTINE CreditPartyDeterminationService.CpdPreApi(iPaymentKey, iDetermineCreditParty, oHookApiOutput)

    $INSERT I_PaymentFrameworkService_HookApiOutputDetails
    $INSERT I_PaymentFrameworkService_HookApiResponse
    $INSERT I_CreditPartyDeterminationService_DetermineCreditPartyInput
    $INSERT I_CreditPartyDeterminationService_CreditPartyDetails
    $INSERT I_CreditPartyDeterminationService_TransactionContext
    $INSERT I_CreditPartyDeterminationService_CreditPartyKey
    $INSERT I_F.POR.TRANSACTION
    $USING EB.DataAccess
    $USING PP.LocalClearingService

   
*------------------------------------------------------------------------------

    GOSUB localInitialise
    porID=iPaymentKey<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>
    EB.DataAccess.FRead(FnPorTransaction, porID, RPorTransaction, FPorTransaction, ErPorTransaction)
   
;* For payment which goes to output warehouse queue, api should not be triggered
    IF ErPorTransaction EQ '' THEN
        IF RPorTransaction<PPPTX.StatusCode> NE '660' THEN
            GOSUB process
        END
        ELSE
            oHookApiOutput=''
        END
    END
RETURN

*------------------------------------------------------------------------------
process:
   
    GOSUB getCreditPartyDetails
    creditorName = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1>
    creditorNameSepa = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crName>
    
    
;* Invalid case
    IndexCreditorNameInv=INDEX(creditorName,'CpdDpdApiErrInv',1)
    IndexCreditorNameSepaInv=INDEX(creditorNameSepa,'CpdDpdApiErrInv',1)
    
;* Restricted case
    IndexCreditorNameRes=INDEX(creditorName,'CpdDpdApiWarRes',1)
    IndexCreditorNameSepaRes=INDEX(creditorNameSepa,'CpdDpdApiWarRes',1)
    
;*Valid case
    IndexCreditorName=INDEX(creditorName,'CpdDpdApi',1)
    IndexCreditorNameSepa=INDEX(creditorNameSepa,'CpdDpdApi',1)
    
    
    IF IndexCreditorNameInv GE 1 OR IndexCreditorNameSepaInv GE 1 THEN
        GOSUB determineApiOutputInv
    END
    ELSE
        IF IndexCreditorNameRes GE 1 OR IndexCreditorNameSepaRes GE 1 THEN
            GOSUB determineApiOutputRes
    
        END
        ELSE
            IF IndexCreditorName GE 1 OR IndexCreditorNameSepa GE 1 THEN
                GOSUB determineApiOutput
    
            END
            ELSE
                oHookApiOutput=''
            END
        END
    END
* System will Map InternalSuspenseAccount from Clearing for DEBIN product with SettlmentType set as GROSS and RTGS set as 'Y'.
    IF RPorTransaction<PPPTX.IncomingMessageType> EQ 'DEBIN' AND RPorTransaction<PPPTX.ClearingTransactionType> EQ 'CT' THEN
        GOSUB getClearing
        GOSUB getClearingSetting
        oHookApiOutput<HookApiOutputDetails.accountCompanyID> = oClearingSetting<PP.LocalClearingService.ClearingSetting.clearingAccountCompany>
        oHookApiOutput<HookApiOutputDetails.accountNumber> = oClearingSetting<PP.LocalClearingService.ClearingSetting.suspenseAccountNumber>
        oHookApiOutput<HookApiOutputDetails.accountCurrency> = oClearingSetting<PP.LocalClearingService.ClearingSetting.clearingAccountCurrency>
    END
    
RETURN
*------------------------------------------------------------------------------
getClearing:
*-------
* Read Clearing to get Outgoing MessageType.
    iClrRequest = ''
    oClrDetails = ''
    oClrError = ''

    iClrRequest<PP.LocalClearingService.ClrRequest.companyID> = iPaymentKey<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingID> = RPorTransaction<PPPTX.IncomingMessageType>
    iClrRequest<PP.LocalClearingService.ClrRequest.clearingCurrency> = RPorTransaction<PPPTX.TransactionCurrencyCode>

    PP.LocalClearingService.getPPTClearing(iClrRequest, oClrDetails, oClrError)
    clrTxnTypeVal = oClrDetails<PP.LocalClearingService.ClrDetails.clearingTransactionType>
    clearingOutgoingMsgType = oClrDetails<PP.LocalClearingService.ClrDetails.outgoingMessageType>
    multiSetCount = DCOUNT(clrTxnTypeVal,@VM)
    iterator = 1
    LOOP
    WHILE iterator LE multiSetCount ;*Loop through ClearingTransactiontype to get outgoingMsgType
        IF clrTxnTypeVal<1,iterator> EQ RPorTransaction<PPPTX.ClearingTransactionType> THEN
            outgoingMsgTypeVal = clearingOutgoingMsgType<1,iterator>
        END
        iterator = iterator+1
    REPEAT
RETURN
*------------------------------------------------------------------------------
getClearingSetting:
*--------------
    iClearingSetting = ''
    oClearingSetting = ''
    oClearingSettingErr = ''

    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.companyID> = iPaymentKey<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingID> = RPorTransaction<PPPTX.IncomingMessageType>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingCurrency> = RPorTransaction<PPPTX.TransactionCurrencyCode>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.messageDirection> = 'S'
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.messagePaymentType> = outgoingMsgTypeVal
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingNatureCode> = RPorTransaction<PPPTX.ClearingNatureCode>
    iClearingSetting<PP.LocalClearingService.ClearingSettingRequest.clearingTransactionType> =  RPorTransaction<PPPTX.ClearingTransactionType>
    PP.LocalClearingService.getClearingSetting(iClearingSetting, oClearingSetting, oClearingSettingErr)
RETURN
    
 

*------------------------------------------------------------------------------
localInitialise:
   
    FnPorTransaction = 'F.POR.TRANSACTION'                                      ;* Open the POR.TRANSACTION
    FPorTransaction = ''
    creditorName = ''
    creditorNameSepa = ''
    
RETURN

*------------------------------------------------------------------------------
getCreditPartyDetails:
*** <desc>Call Credit party determination service to get Party Credit details </desc>
    iCreditPartyRole = ''
    oCreditPartyDet = ''
    oGetCreditError = ''
    
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID> = iPaymentKey<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>
    iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber> = iPaymentKey<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>
    PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oCreditPartyDet,oGetCreditError)
    
RETURN

*------------------------------------------------------------------------------

determineApiOutput:
    
    
    BEGIN CASE
        CASE iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.originatingSource> EQ 'SWIFT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302001'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
        CASE iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.incomingMessageType> EQ 'RFDD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302701'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.originatingSource> EQ 'OE'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302402'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'CT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302701'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'CD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302901'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'DD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103205'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'CC'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302801'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
            
    END CASE
        
   
RETURN
 
*------------------------------------------------------------------------------
 
determineApiOutputInv:
    oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
    oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024303201'
    oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
    
    
RETURN
   
 
*------------------------------------------------------------------------------
   
determineApiOutputRes:
    BEGIN CASE
        CASE iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.originatingSource> EQ 'SWIFT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '10024302101'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'GBP'
        CASE iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.originatingSource> EQ 'OE'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103205'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'CT'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103205'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'CD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103205'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'DD'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103205'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
        CASE  iDetermineCreditParty<PP.CreditPartyDeterminationService.DetermineCreditPartyInput.clearingTransactionType> EQ 'CC'
            oHookApiOutput<HookApiOutputDetails.accountCompanyID> = 'BNK'
            oHookApiOutput<HookApiOutputDetails.accountNumber> = '01001103205'
            oHookApiOutput<HookApiOutputDetails.accountCurrency> = 'EUR'
            
    END CASE
        
  
RETURN

*------------------------------------------------------------------------------
END

