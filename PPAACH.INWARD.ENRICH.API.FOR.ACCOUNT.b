* @ValidationCode : MjotMTAzOTE1OTk2ODpDcDEyNTI6MTYxNDY3NTY5Mzk2NTpzaGFybWFkaGFzOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoxODU6MTI4
* @ValidationInfo : Timestamp         : 02 Mar 2021 14:31:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sharmadhas
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 128/185 (69.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.INWARD.ENRICH.API.FOR.ACCOUNT(ioPaymentObject,orAuditTrailLogFields)
*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : gmamatha@temenos.com
* Program Name   : PPAACH.INWARD.ENRICH.API.FOR.ACCOUNT
* Module Name    : PPAACH
* Component Name : PPAACH_ClearingFramework
*-----------------------------------------------------------------------------
* Description    : New api to form the CBU from NCC and account retreived from the incoming msg.
* In Parameter   :ioPaymentObject
* Out Parameter  :orAuditTrailLogFields
*-----------------------------------------------------------------------------

* Modification Details:
* ---------------------
* 22/05/2019 - Enhancement 3131179 / Task 3149366
*              Payments-Openbank-Local Transfer - CT
*              New api to form the CBU which is required for actual T24 account retreival.
* 17/06/2019 - Enhancement 2959615/Task 3183022 - Payments-Openbank-DD Mandates
*            - Retrieves the customer name using account and maps the name to creditPartyName
* 31/07/2019 - Task 3265157 - BENFCY account line for RT is enriched from Original Txn.
* 07/04/2020 - Defect 3677943 / Task 3681605: Subtraction of 500 for USD handled at xslt level itself.
*15/09/2020 - Enhancement 3886687 / Task 3949511: Coding Task - Generic cleanup process for Archival read in PP dependent modules
*08/02/2021 - Enhancement 3912084/ Task 4189158: MismoTitular Calculation Scenarios - NACHA payments processing
*02/03/2021 - Enhancement 3912044 / Task 4260649 -Outward Mapping issue.
*-----------------------------------------------------------------------------

*** <region name= inserts>
*** <desc>Insert Files </desc>
    $USING PP.MessageMappingService
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING ST.CustomerService
    $USING PP.InboundCodeWordService
    $USING EB.DataAccess
    $USING PP.PaymentWorkflowGUI
    $USING PP.DebitPartyDeterminationService
    $USING PP.InwardMappingFramework
    $USING PP.PaymentFrameworkService
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
    creditPartyClearingMemberId = ''
    iVerificationDigit = ''
    creditPartyAccountLine = ''
    NCCLen = ''
    auditTrailLogFieldsName = ''
    auditTrailLogFieldsOldValue = ''
    auditTrailLogFieldsNewValue = ''
    auditTrailCount = ''
    creditPartyDets = ''
    clrTxnType = ''

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Para for main process </desc>
    creditPartyDets = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty>
    totalRoles = DCOUNT(creditPartyDets,@VM)
    j=1
    LOOP
    WHILE j LE totalRoles
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,j,PP.MessageMappingService.PartyCredit.creditPartyRole> EQ 'ACWINS' THEN
            creditPartyClearingMemberId = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,j,PP.MessageMappingService.PartyCredit.creditPartyClearingMemberId>
        END
    
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,j,PP.MessageMappingService.PartyCredit.creditPartyRole> EQ 'BENFCY' THEN
            auditTrailLogFieldsOldValue = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,j,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>
            creditPartyAccountLine = ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,j,PP.MessageMappingService.PartyCredit.creditPartyAccountLine>
            pos = j
        END
    
        j = j +1
    REPEAT
    
    GOSUB generateVerificationDigit
    
    CBU = creditPartyClearingMemberId:iVerificationDigit:creditPartyAccountLine
    
    GOSUB getAccountDetails ; * to get the account details
    
    ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos,PP.MessageMappingService.PartyCredit.creditPartyAccountLine> = CBU
    IF ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos,PP.MessageMappingService.PartyCredit.creditPartyName> EQ '' THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos,PP.MessageMappingService.PartyCredit.creditPartyName> = customerName
    END
    clrTxnType = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.clearingTransactionType>
    IF clrTxnType NE 'RV' THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.extendedFields> = "N"
    END
    IF ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.clearingTransactionType> EQ 'RT' THEN
        GOSUB findAccountLine
    END
    auditTrailLogFieldsName = "CreditPartyAccountLine - BENFCY"
    auditTrailLogFieldsNewValue = CBU
    GOSUB updateAuditTrailFields ;* Update the AuditTrailLog with the field name and its enrich values
    
       
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
findAccountLine:
    iPaymentID = ''
    R.POR.SUPPLEMENTARY.INFO = ''
    OriginalFTNo = ''
    informationLine = ''
    
    informationLine = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>
    
    IF informationLine THEN
        ireadConcat = informationLine :"-":ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
        PP.InwardMappingFramework.getPORTransactionConcat(ireadConcat, Rec, Er)
       
        OriginalFTNo = Rec<1>
        IF OriginalFTNo THEN
            GOSUB getPartyDebitDetails
        END
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------------
getPartyDebitDetails:

* Credit party informations
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber> = OriginalFTNo
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.dbtPartyRole> = 'ORDPTY'
    iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.dbtPartyRoleIndic> = 'R'
* Get POR.PARTYCREDIT record

    PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole, oDebitPartyDet, oGetCreditError)
    CBU = oDebitPartyDet<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,1>
    ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,pos,PP.MessageMappingService.PartyCredit.creditPartyAccountLine> = CBU

RETURN
*-----------------------------------------------------------------------------
generateVerificationDigit:
*   Rules for generating verification digit -
*   Check Digit (Control Digit with 3179 weightage)
*   - To control digit ARACCT.CBU.ALGORITHM.FIRST.BLOCK routine will be created. Therefore, a number calculates this control as multiply each number in turn, from right to left. The first digit is multiplied with 3, the second by 1, the third by 7, the fourth by 9 and the process is repeated until the last digit of the first block.
*   - Sum all of the 7 answers
*   - Get the last digit of the result
*   - Subtract the last digit from 10 to get the Check Digit1
    GOSUB localInitilase
    
    NCCLen =  LEN(creditPartyClearingMemberId)

*The substraction of 500 for USD currency is handled at xslt level itself.
    
    LOOP
    WHILE NCCLen GE totRecCount
        lastVal = SUBSTRINGS(creditPartyClearingMemberId,NCCLen,1)
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
    legalId = ''
    documentName = ''
    totalLocalFields = ''
    
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
    jointholder = ''
    customerIds = ''
    R.ALTERNATE.ACCOUNT = ''
    R.ALTERNATE.ACCOUNT = AC.AccountOpening.AlternateAccount.Read(CBU,CBU.ERR)
    debitAccount = R.ALTERNATE.ACCOUNT<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber>
    rAccount =  AC.AccountOpening.Account.Read(debitAccount, accountErr) ;* read the account record
    IF accountErr EQ '' THEN
        customerId = rAccount<AC.AccountOpening.Account.Customer>
        jointholder = rAccount<AC.AccountOpening.Account.JointHolder>
    END
    GOSUB GetCustomerName
    customerIds = customerId:@FM:jointholder
    total.cnt = DCOUNT(customerIds,@FM)
    FOR cnt =  1 TO total.cnt
        GOSUB getCreditorLegalId
    NEXT cnt
    total.cr.legalid= DCOUNT(legalIds,@FM)
    IF total.cr.legalid GT 1 THEN
        multiple.cr.legalidflg =1
    END
    
    GOSUB getDebtorLegalId
    IF ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.incomingMessageType> EQ 'ARGCT' THEN
        GOSUB CompareLegalId
    END
 
    
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
*------------------------------------------------------------------------------------------------------------------------------------------------------------
getDebtorLegalId:
* Gets Debitor Legal id-->
    pos2 = ''
    debitPartyRole = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>
    LOCATE 'ORDPTY' IN debitPartyRole<1,1,1> SETTING pos2 THEN
        prvidotherid = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,pos2,PP.MessageMappingService.PartyDebit.debitPartyPrvIdOtherId>
    END
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------
getCreditorLegalId:
*Gets Creditor Legal id from customer table--->
    customerDet=''
    customerID = customerIds<cnt>
    ST.CustomerService.getLegalIdentificationDetails(customerID, customerDet)  ;* To get legalID list multivalue set for that customer id
    total.count = DCOUNT(customerDet,@FM)
    FOR count =  1 TO total.count
        documentName = customerDet<count,ST.CustomerService.LegalIDDetails.documentName>
        IF documentName MATCHES 'CUIT' THEN ;*
            legalId = customerDet<count,ST.CustomerService.LegalIDDetails.identification>
        END
        legalIds<-1> = legalId
    NEXT count
RETURN

*------------------------------------------------------------------------------------------------------------------------------------------------------------
CompareLegalId:
* Compares debtor and creditor legal ids-->
    IF (prvidotherid NE '') AND (legalIds NE '') THEN
        totalLocalFields = DCOUNT(ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails>,@VM) ;* Get the count of local field
        totalLocalFields = totalLocalFields + 1
        LOCATE prvidotherid IN legalIds<-1> SETTING pos1 THEN
            IF multiple.cr.legalidflg THEN
                ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,totalLocalFields,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName> = 'MismotitularValue'
                ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,totalLocalFields,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue> = 2
            END ELSE
                ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,totalLocalFields,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName> = 'MismotitularValue'
                ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,totalLocalFields,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue> = 1
            END
        END ELSE
            ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,totalLocalFields,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName> = 'MismotitularValue'
            ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,totalLocalFields,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue> = 0
        END
    END
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------
END
