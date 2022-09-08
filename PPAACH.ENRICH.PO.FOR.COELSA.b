* @ValidationCode : MjoyOTE1NDY0NTc6Q3AxMjUyOjE2MTUyMTQ0MzA2MjU6bW1pdGhpbGE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjE3NToxMTM=
* @ValidationInfo : Timestamp         : 08 Mar 2021 20:10:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mmithila
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 113/175 (64.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework

SUBROUTINE PPAACH.ENRICH.PO.FOR.COELSA(ioPaymentObject,orAuditTrailLogFields)

*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : gmamatha@temenos.com
* Program Name   : PPAACH.ENRICH.PO.FOR.COELSA
* Module Name    : PPAACH
* Component Name : PPAACH_Clearing
*-----------------------------------------------------------------------------
* Description    :
* Linked with    :
* In Parameter   :
* Out Parameter  :
*-----------------------------------------------------------------------------
* This is a new api which will be called from PO/STO application for enrichment of Message priority
* and debit party details.
* Modification Details:
* ---------------------
* 15/05/2019 - Enhancement 3131179 / Task 3132163
*              New enrich api to fetch PrvtOtherId for debit party and message Priority.
* 18/06/2019 - Enhancement 2959503 / Task 3140225 Payments-Openbank Local Transfer and Domestic Payments
*              Code fixes
* 19/06/2020 - Defect 3803308 / Task 3810241 - Ordering customer CUIT/CUIL not mapped into the outgoing domestic transfer file - 202006
* 31/10/2020 - Defect 4051179 / Task 4054416: The Credit Party Identifier (BIC / National ID) could not be determined for the payment
* 19/01/2021 - Defect 4154810 / Task 4185829 - ARG Domestic payment CUIT mapping only for Payments to suppliers and Returns and not for other payment types
* 04/02/2021 - Defect 4203454 / Task 4212432 - ARG Domestic payment CUIT mapping required for corporate customers
*-----------------------------------------------------------------------------

*** <region name= inserts>
*** <desc>Insert Files </desc>

    $USING PP.InwardCreditTransferInitiationService
    $USING PP.MessageMappingService
    $USING ST.CustomerService
    $USING AC.AccountOpening
    
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= methodStart>
*** <desc>Start Of the Program </desc>

    GOSUB initialise   ;* Para for initialise variable used by this method.
    GOSUB process      ;* Para for main process.

RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Para for initialise variable used by this method </desc>

    orAuditTrailLogFields = ''
    count = ''
    count1 = ''
    legalId = ''
    documentName = ''
    total.count = ''
    total.altAccType = ''
    customerDetails = ''
    altAccTypeVal = ''
    localInstrProp = ''
    auditTrailCount = ''
    debtRole = ''
    cdtRole = ''
    
    noOfDbtRls = DCOUNT(ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>,@VM)
    noOfCdtRls = DCOUNT(ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty>,@VM)
    
    FOR debtRole = 1 TO noOfDbtRls
        debitPartyRole<1,-1> = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,debtRole,PP.MessageMappingService.PartyDebit.debitPartyRole>
    NEXT debtRole
    
    FOR cdtRole = 1 TO noOfCdtRls
        creditPartyRole<1,-1> = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,cdtRole,PP.MessageMappingService.PartyCredit.creditPartyRole>
    NEXT cdtRole
    
RETURN
*** </region>


*---------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Para for main process </desc>
    GOSUB enrichDebitPartyDets
    GOSUB enrichMessagePriority
    GOSUB enrichCreditAccountLine
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
initialiseAuditFields:
*   initialise local variables here
    auditTrailLogFieldsName = ''
    auditTrailLogFieldsOldValue = ''
    auditTrailLogFieldsNewValue = ''
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------
enrichDebitPartyDets:
    
    GOSUB initialiseAuditFields
    pos = ''
    pos3 = ''
    debitAccount = ''
    debitAccountLine = ''
    debitPartyAccLine = ''
    debitPartyClearingMemberId = ''

    
    LOCATE 'ORDPTY' IN debitPartyRole<1,1> SETTING pos THEN
        
        customerID = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyOrgIdOtherId>
        auditTrailLogFieldsOldValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyPrvIdOtherId>
        customerKey = ''
        customerRecord = ''
        customerKey  = customerID
        ST.CustomerService.getRecord(customerKey, customerRecord) ;* To read CUSTOMER record
        customerStatus = customerRecord<ST.CustomerService.CustomerRecord.customerStatus>
        IF customerRecord NE ''  THEN
            GOSUB getLegalId
            GOSUB getTransferType ; *
            
*ARG Domestic payment CUIT mapping has to be done only for Payments to suppliers (transferType '2')
*and Payment Returns to Suppliers(transferType '7') and Corporate customer who are determined based on the customer status 22 and not for other payment types
            IF legalId NE '' AND (transferType EQ '2' OR transferType EQ '7' OR customerStatus EQ '22') THEN
                ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyRole>            = 'ORDPTY'
                ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyRoleIndicator>   = 'R'
                ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyPrvIdOtherId>    =  legalId
            END
        END
        debitAccount = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>
        GOSUB getAccountDetails
        debitAccountLine = altAccId[1,7]
        IF altAccId THEN
            ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyAccountLine> = '/':altAccId
        END
    END
    LOCATE 'ASVINS' IN debitPartyRole<1,1> SETTING pos3 THEN
        debitPartyClearingMemberId = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyClearingMemberId>
        debitPartyAccLine = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyClearingMemberId> = debitAccountLine
        ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyAccountLine> = '//':debitAccountLine
        ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyNationalId> = 'Y'
    END

    IF transferType EQ '2' OR transferType EQ '7' OR customerStatus EQ '22' THEN
        auditTrailLogFieldsName = "DebitPartyPrvIdOtherId - ORDPTY"
        auditTrailLogFieldsNewValue = legalId
        GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
    END
    
    auditTrailLogFieldsName = "DebitPartyClearingMemberId - ASVINS"
    auditTrailLogFieldsOldValue = debitPartyClearingMemberId
    auditTrailLogFieldsNewValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyClearingMemberId>
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
     
    auditTrailLogFieldsName = "DebitPartyAccountLine - ASVINS"
    auditTrailLogFieldsOldValue = debitPartyAccLine
    auditTrailLogFieldsNewValue =  ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos3,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
     
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------------
enrichMessagePriority:
*   To update Message priority based on localInstrumentpropiertary value.
    GOSUB initialiseAuditFields
    localInstrProp = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.bankOperationCode>
    auditTrailLogFieldsOldValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.messagePriority>
    BEGIN CASE
        CASE localInstrProp EQ 'CTX-220'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.messagePriority> = '5'
        
        CASE localInstrProp EQ 'CCD-220'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.messagePriority> = '1'
    END CASE
    
    auditTrailLogFieldsName = "MessagePriority"
    auditTrailLogFieldsNewValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.messagePriority>
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
    
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------------------------
enrichCreditAccountLine:
    
    pos1 = ''
    pos2 = ''
    beneficiaryAccount = ''
    creditAccountLine = ''
    creditPartyClearingMemberId = ''
    creditPartyAccLine = ''
    GOSUB initialiseAuditFields

    LOCATE 'BENFCY' IN creditPartyRole<1,1> SETTING pos1 THEN
        beneficiaryAccount = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos1,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>
        
        creditAccountLine = beneficiaryAccount[1,7]
        LOCATE 'ACWINS' IN creditPartyRole<1,1> SETTING pos2 THEN
            creditPartyAccLine = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>
            creditPartyClearingMemberId = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyClearingMemberId>
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyClearingMemberId> = creditAccountLine
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>    = '//':creditAccountLine
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyNationalId> = 'Y'
        END ELSE
* when locate fails pos2 will be set to one position past the end of the searched dimension.
* if ACWINS role could not be located, insert a new role as ACWINS with credit party account line and clearing member id as first 7 characters of the beneficiary account.
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyRole>                           = 'ACWINS'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyRoleIndicator>    = 'R'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyClearingMemberId> = creditAccountLine
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>    = '//':creditAccountLine
            ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyNationalId> = 'Y'
        END
    END
    
    creditPartyRole1 =''
    creditPartyRole1 = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty>
   
    auditTrailLogFieldsName = "CreditPartyClearingMemberId - ACWINS"
    auditTrailLogFieldsOldValue = creditPartyClearingMemberId
    auditTrailLogFieldsNewValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyClearingMemberId>
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
     
    auditTrailLogFieldsName = "CreditPartyAccountLine - ACWINS"
    auditTrailLogFieldsOldValue = creditPartyAccLine
    auditTrailLogFieldsNewValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos2,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
    
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------------------------
getAccountDetails:
*   Read Account table, to fetch ALT.ACCT.ID for the given debit account.
    accountErr = ''
    rAccount = ''
    altAccId = ''
    altAccType = ''
    rAccount =  AC.AccountOpening.Account.Read(debitAccount, accountErr) ;* read the account record
    IF accountErr EQ '' THEN
        altAccType = rAccount<AC.AccountOpening.Account.AltAcctType>
        total.altAccType = DCOUNT(altAccType,@VM)
        FOR count1 =  1 TO total.altAccType
            altAccTypeVal = rAccount<AC.AccountOpening.Account.AltAcctType,count1>
            IF altAccTypeVal MATCHES 'CBU' THEN
                altAccId = rAccount<AC.AccountOpening.Account.AltAcctId,count1>
            END
        NEXT count1
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------
getLegalId:
*   To fetch particular legal Id from multivalue set of Customer application.
    customerDet=''
    ST.CustomerService.getLegalIdentificationDetails(customerID, customerDet)  ;* To get legalID list multivalue set for that customer id
    total.count = DCOUNT(customerDet,@FM)
    FOR count =  1 TO total.count
        documentName = customerDet<count,ST.CustomerService.LegalIDDetails.documentName>
        IF documentName MATCHES 'CUIT' :@VM: 'CUIL' THEN ;* removed CDI as legal id should be mapped only for CUIT/CUIL
            legalId = customerDet<count,ST.CustomerService.LegalIDDetails.identification>
        END
    NEXT count
                
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= updateAuditTrailFields>
updateAuditTrailFields:
*** <desc>Update the AuditTrailLog with the field name and its enrich values </desc>
    IF auditTrailLogFieldsName THEN
        auditTrailCount = auditTrailCount + 1
        orAuditTrailLogFields<auditTrailCount,1> = auditTrailLogFieldsName
        orAuditTrailLogFields<auditTrailCount,2> = auditTrailLogFieldsOldValue
        orAuditTrailLogFields<auditTrailCount,3> = auditTrailLogFieldsNewValue
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= getTransferType>
getTransferType:
*** <desc> </desc>

    transferType = ''
    informationDetails = ''
    informationDetails = ioPaymentObject<PP.MessageMappingService.PaymentObject.information>
    CHANGE @VM TO @FM IN informationDetails
    CHANGE @SM TO @VM IN informationDetails
    
    FIND 'CYPURPPY' IN informationDetails SETTING posTP1,posTP2 THEN
        transferType = ioPaymentObject<PP.MessageMappingService.PaymentObject.information,posTP1,PP.MessageMappingService.Information.informationLine>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------------------------------------------
END


