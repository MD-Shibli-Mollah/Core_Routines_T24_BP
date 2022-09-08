* @ValidationCode : MjotMTUyMjI4MjMxOkNwMTI1MjoxNjAxNTU1MjIyNjE4Om5hZ2FsYWtzaG1pcDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE0LTEzNTc6MTExOjExMQ==
* @ValidationInfo : Timestamp         : 01 Oct 2020 17:57:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nagalakshmip
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 111/111 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200914-1357
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.INWARD.ENRICH.API.FOR.ARGDDRV(ioPaymentObject,auditTrailLog)
*-----------------------------------------------------------------------------
*This routine is used to change the values in ioPaymentObject for inward Argentina DD Reclaim
*It should be configured in EnrichAPI field of PP.MSGMAPPINGPARAMETER>COELSAACH.ARGDDRV
*-----------------------------------------------------------------------------
* Modification History :
* 29/05/2019 - 3132136: Mapping from DEBIN to PO
*            - Defaulting the DEBTOR account line from original transaction
*15/09/2020 - Enhancement 3886687 / Task 3949511: Coding Task - Generic cleanup process for Archival read in PP dependent modules
* 22/09/2020 - Defect 3978028 / Task 3985324 - ExtendedField is set as 'N' for reclaim payment.
*-----------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING PP.MessageMappingService
    $USING PP.CreditPartyDeterminationService
    $USING PP.InwardMappingFramework
*-----------------------------------------------------------------------------
    GOSUB initialise ; *Initialise local variables used in this method
    GOSUB process ; *Process changes for this method
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Initialise local variables used in this method </desc>
    debitParty = ''
    cnt = ''
    totCnt = ''
    idConcat = ''
    originalFTNumber = ''
    rConcat = ''
    errConcat = ''
    iCreditPartyRole = ''
    oCreditPartyDet = ''
    oGetCreditError = ''
    pos =''
    creditParty = ''
    creditPartyAccountLine = ''
    creditPartyClearingMemberId = ''
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc>Process changes for this method </desc>

    GOSUB determineDebtorAcc ; *determine debit account from original transaction ORDPTY
    GOSUB determineOrdPtyAcc ; *Determine Ordering party account based on CBU


RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= determineDebtorAcc>
determineDebtorAcc:
*** <desc>determine debit account from original transaction ORDPTY </desc>

    cnt = 1
    debitParty = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>
    totCnt = DCOUNT(debitParty,@VM)
    LOOP
    WHILE cnt LE totCnt
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,cnt,PP.MessageMappingService.PartyDebit.debitPartyRole> EQ 'DEBTOR' AND ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,cnt,PP.MessageMappingService.PartyDebit.debitPartyAccountLine> EQ '' THEN
            GOSUB retrieveFromOrigTxn ; *Retrieve account details from original transaction
        END
        cnt++
    REPEAT
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= retrieveFromOrigTxn>
retrieveFromOrigTxn:
*** <desc>Retrieving original transaction details </desc>
*Original transaction ftnumber can be retreived from POR.TRANSACTION.CONCAT, for which id will be return transaction Txnid and source
    idConcat = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>:'-':ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    PP.InwardMappingFramework.getPORTransactionConcat(idConcat, rConcat, errConcat)
    originalFTNumber = rConcat<1>
    
*If original transaction determined, get Account Line from BENFCY role to map it to DEBTOR of return transaction
    IF originalFTNumber NE '' THEN
        iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID> = originalFTNumber[1,3]
        iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber> = originalFTNumber
        iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.crPartyRole> = 'ORDPTY'
        iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.crPartyRoleIndic> = 'R'
        PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole, oCreditPartyDet, oGetCreditError)
        ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,cnt,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>       =  oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= determineOrdPtyAcc>
determineOrdPtyAcc:
*** <desc>Determine Ordering party account based on CBU </desc>
    totCnt = ''
    cnt = 1
    creditParty = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty>
    totCnt = DCOUNT(creditParty,@VM)
    LOOP
    WHILE cnt LE totCnt
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,cnt,PP.MessageMappingService.PartyCredit.creditPartyRole> EQ 'ORDPTY' THEN
            creditPartyAccountLine = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,cnt,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>
            pos = cnt
        END
        cnt++
    REPEAT
    creditPartyClearingMemberId = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.sendersReferenceIncoming>
    
    GOSUB generateVerificationDigitMemId
    GOSUB generateVerificationDigitForAccount
    CBU = creditPartyClearingMemberId:iVerificationDigit:creditPartyAccountLine:iVerificationDigitAcc
    ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos,PP.MessageMappingService.PartyCredit.creditPartyAccountLine> = CBU
    ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.extendedFields> = "N"
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
generateVerificationDigitMemId:
    
    GOSUB localInitilase
    
    creditPartyClearingMemberId = creditPartyClearingMemberId[2,7]
    NCCLen =  LEN(creditPartyClearingMemberId)
    LOOP
    WHILE NCCLen GE totRecCount
        lastVal = creditPartyClearingMemberId[NCCLen,1]
        GOSUB multiplicationResult
        NCCLen = NCCLen -1
    REPEAT
    
    iActualLength= LEN(iSumOfValues)
    iLastDigit = iSumOfValues[iActualLength,1]
    iVerificationDigit =  10 -iLastDigit
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------
generateVerificationDigitForAccount:
    
    GOSUB localInitilase
    
    AccLen =  LEN(creditPartyAccountLine)
    LOOP
    WHILE AccLen GE totRecCount
        lastVal = creditPartyAccountLine[AccLen,1]
        GOSUB multiplicationResult
        AccLen = AccLen -1
    REPEAT

    iActualLength= LEN(iSumOfValues)
    iLastDigit = iSumOfValues[iActualLength,1]
    iVerificationDigitAcc =  10 -iLastDigit
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------
multiplicationResult:
   
    IF i EQ totalWeight THEN
        i =1
        iWeight = SUBSTRINGS(iWeightAge,i,1)
        iSumOfValues =  iSumOfValues + (lastVal*iWeight)
    END ELSE
        i= i +1
        iWeight = SUBSTRINGS(iWeightAge,i,1)
        iSumOfValues =  iSumOfValues + (lastVal*iWeight)
    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------
localInitilase:
*   initialise the local variables here.
    i = 0
    iSumOfValues = 0
    iWeightAge = '3179'
    totalWeight = LEN(iWeightAge)
    totRecCount = 1
    lastVal = ''
    iWeight = ''
    iActualLength = ''
    iLastDigit = ''
    iVerificationDigitAcc = ''
    iVerificationDigit = ''
    AccLen = ''
   
    
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------

END




