* @ValidationCode : MjotMTk3MTY1ODEwOTpDcDEyNTI6MTYxNzg1ODMwNzUxNzprZWVydGhhbmFwczoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6MTIxOjg5
* @ValidationInfo : Timestamp         : 08 Apr 2021 10:35:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : keerthanaps
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 89/121 (73.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------

$PACKAGE PPAACH.ClearingFramework

SUBROUTINE PPAACH.INWARD.ENRICH.API.DD.ACCOUNT(ioPaymentObject,orAuditTrailLogFields)

*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : gmamatha@temenos.com
* Program Name   : PPAACH.INWARD.ENRICH.API.DD.ACCOUNT
* Module Name    : PPAACH
* Component Name : PPAACH_ClearingFramework
*-----------------------------------------------------------------------------
* Description    :
* Linked with    :
* In Parameter   :
* Out Parameter  :
*-----------------------------------------------------------------------------

* Modification Details:
* ---------------------
* 22/05/2019 - Enhancement 2959615/Task 3160065
*              New api to form the CBU which is required for actual T24 account retreival.
* 22/05/2019 - Enhancement 2959615/3184597 - Secondary Compilation Error in TAFC
*            - expVal variable is unassigned caused secondary Compilation error in TAFC. Removed the variable since its no longed needed.
* 17/06/2019 - Enhancement 2959615/Task 3183022 - Payments-Openbank-DD Mandates
*            - Retrieves the customer name using account and maps the name to debitPartyName
* 02/08/2019 - Enhancment 3236459/Task 3236458: [WT] Task for Code -Handling DD Mandates
*05/03/2021 - Enhancement 4266794/Task 4266497 -PACS00923242 - ARG - CBU in NACHA inward file is not being mapped properly in T24
*             Mandatereference=TransactionDescription+CBU
*-----------------------------------------------------------------------------

*** <region name= inserts>
*** <desc>Insert Files </desc>

    $USING PP.MessageMappingService
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING ST.CustomerService
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
    pos = ''
    debitPartyClearingMemberId = ''
    iVerificationDigit = ''
    debitPartyAccountLine = ''
    NCCLen = ''
    auditTrailLogFieldsName = ''
    auditTrailLogFieldsOldValue = ''
    auditTrailLogFieldsNewValue = ''
    auditTrailCount = ''
    debitPartyDets = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>
    flag=''
    countRec=''
    cntRFLD=''
    TxnDescription=''
    mandateReference=''

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Para for main process </desc>

    totalRoles = DCOUNT(debitPartyDets,@VM)
    j=1
    LOOP
    WHILE j LE totalRoles
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,j,PP.MessageMappingService.PartyDebit.debitPartyRole> EQ 'DBTAGT' THEN
            debitPartyClearingMemberId = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,j,PP.MessageMappingService.PartyDebit.debitPartyClearingMemberId>
        END
    
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,j,PP.MessageMappingService.PartyDebit.debitPartyRole> EQ 'DEBTOR' THEN
            debitPartyAccountLine = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,j,PP.MessageMappingService.PartyDebit.debitPartyAccountLine>
            pos = j
        END
    
        j = j +1
    REPEAT
    
    GOSUB getTransactiondescription
    GOSUB generateVerificationDigit
    
    CBU = debitPartyClearingMemberId:iVerificationDigit:debitPartyAccountLine
    
    GOSUB getAccountDetails ; * to get the account details
    
    ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyAccountLine> = CBU
    
    IF ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyName> EQ '' THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos,PP.MessageMappingService.PartyDebit.debitPartyName> = customerName
    END
    
    ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.extendedFields> = "N"
* Added for handling DD Mandates
*Mapping for Mandate Reference is changed as Transaction+CBU inorder to uniquely locate DD.DDI for each service
    mandateReference=TRIM(TxnDescription):CBU
    
    ioPaymentObject<PP.MessageMappingService.PaymentObject.debitAuthInfo,1,PP.MessageMappingService.DebitAuthInfo.mandateReference> = mandateReference
    ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.mandateReference> = mandateReference
    auditTrailLogFieldsName = "DebitPartyAccountLine - DEBTOR"
    auditTrailLogFieldsNewValue = CBU
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
generateVerificationDigit:
    
    GOSUB localInitilase
    
    NCCLen =  LEN(debitPartyClearingMemberId)
    LOOP
    WHILE NCCLen GE totRecCount
        lastVal = SUBSTRINGS(debitPartyClearingMemberId,NCCLen,1)
        GOSUB multiplicationResult
        NCCLen = NCCLen -1
    REPEAT
    
    iActualLength= LEN(iSumOfValues)
    iLastDigit = SUBSTRINGS(iSumOfValues,iActualLength,1)
    iVerificationDigit =  10 -iLastDigit
    
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
   
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------
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
getAccountDetails:
*   Read Alternate Account table, to fetch account number.
    accountErr = ''
    rAccount = ''
    altAccId = ''
    altAccType = ''
    CBU.ERR = ''
    customerId = ''
    R.ALTERNATE.ACCOUNT = ''
    R.ALTERNATE.ACCOUNT = AC.AccountOpening.AlternateAccount.Read(CBU,CBU.ERR)
    debitAccount = R.ALTERNATE.ACCOUNT<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber>
    rAccount =  AC.AccountOpening.Account.Read(debitAccount, accountErr) ;* read the account record
    IF accountErr EQ '' THEN
        customerId = rAccount<AC.AccountOpening.Account.Customer>
    END
    GOSUB GetCustomerName
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------
GetCustomerName:
*** <desc>Gets customer name from Customer table</desc>

    customerKey = customerId
    customerNameAddress = ''
    customerName = ''
    prefLang = EB.SystemTables.getLngg()
    ST.CustomerService.getNameAddress(customerId,prefLang,customerNameAddress)
    IF customerNameAddress NE '' THEN
        customerName = customerNameAddress<ST.CustomerService.NameAddress.shortName>
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= getTransactiondescription>
getTransactiondescription:
*** <desc>To get Transaction description from additionalInf </desc>
  
    flag = 1
    countRec = ioPaymentObject<PP.MessageMappingService.PaymentObject.additionalInf>
    cntRFLD = DCOUNT(countRec,@VM)
    LOOP
    WHILE flag LE cntRFLD
*Get additionalInfLine for the additionalInformationCode 'Txn Description'
        IF  ioPaymentObject<PP.MessageMappingService.PaymentObject.additionalInf,flag,PP.MessageMappingService.AdditionalInf.additionalInformationCode> EQ 'Txn Description' THEN
            TxnDescription = ioPaymentObject<PP.MessageMappingService.PaymentObject.additionalInf,flag,PP.MessageMappingService.AdditionalInf.additionalInfLine>
            BREAK
        END
        flag = flag + 1
    REPEAT
    
RETURN
*** </region>

END

