* @ValidationCode : MjotMjk3MjExMzIzOkNwMTI1MjoxNTc2MTQyMDk4NTAyOnNtdWdlc2g6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjQxMjozNzA=
* @ValidationInfo : Timestamp         : 12 Dec 2019 14:44:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 370/412 (89.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*---------------------------------------------------------------------------------------------------------------------
$PACKAGE PI.Channels
SUBROUTINE E.NOFILE.TC.GPI.TRACKING(OUT.ARRAY)
*---------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This routine used to retrieve the GPI tracking information details
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TC.GPI.TRACKING
* IN Parameters      : PAYMENT.ID, PAYMENT.METHOD(either payment received or payment sent)
* Out Parameters     : OUT.ARR(PAYMENT.ORDER or POR.TRANSACTION details)
*
*---------------------------------------------------------------------------------------------------------------------
*
*   Modification History :
*
* 14-10-2019  - Enhancement (3343561) - Task (3384625)
*               SWIFT GPI in TCIB
*
* 12-12-2019  - Defect (3483380) - Task (3484118)
*               TAFC Compilation Warning
*---------------------------------------------------------------------------------------------------------------------
 
    $USING EB.Reports
    $USING PI.Contract
    $USING PI.Config
    $USING EB.API
    $USING PP.PaymentWorkflowDASService
    $USING EB.SystemTables
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $USING ST.CompanyCreation
    $USING PP.PaymentFrameworkService
    $USING ST.Config
    $USING PP.BankCodeService
    $USING PP.MessageAcceptanceService
    $USING EB.DataAccess
    $USING PP.SwiftOutService
    $INSERT I_DAS.PSM.BLOB
    $USING PP.InquiryGUI
    $USING PP.PaymentWorkflowGUI
    
    
*Check PP and PI products were installed otherwise return the empty array
    EB.API.ProductIsInCompany("PP", PP.isInstalled) ;*check PP is installed
    EB.API.ProductIsInCompany("PI", PI.isInstalled) ;*check PI is installed
    
    IF NOT(PP.isInstalled) OR NOT(PI.isInstalled) THEN
        OUT.ARRAY =''
        RETURN
    END
    
    GOSUB INITIALISE  ;*Initialise the variables
    
    GOSUB GET.INPUT.DETAILS  ;*Process the input values
    
    IF paymentSystemId NE '' THEN
        GOSUB GET.POR.TRANSACTION.DETAILS ;* Get POR.TRANSACTION details
        GOSUB GET.GPI.TRACKER.DETAILS     ;* Get PI.GPI.TRACKER details
    END
    

    GOSUB PROCESS  ;*Process the other values
    
    GOSUB FINAL.ARRAY.DETAILS        ;*Final Array construction
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables </desc>
    paymentId = ''; paymentMethod = ''; paymentSystemId = ''; uniqueTxnReference = ''; OUT.ARRAY = '';
    transactionAmount = '';endToEndReference = ''; paymentDirection = ''; companyId = ''; sendersReferenceOutgoing = ''; sendersReferenceIncoming = '';
    instructedAmount = ''; instructedCurrencyCode = ''; GPITrackerId = ''; partyIdentifierCode = ''; beneficiaryIdentifierCode = ''; companyBIC = '';
    countryId = '';countryName = ''; companyName = '';completionTime = '';initiationTime = ''; confirmedAmount = '';messageNameIdentification = ''; transactionEventType = '';
    debtorAgent = '';chargeAmount = ''; totalDuration = '';  GPITrackerRecord = ''; oPaymentRecord = '';GPiDateTime = '';localZoneTime = '';
    fromAgent = '';oPaymentRecord = '';creditorAgent = ''; companyMnemonic = ''; companyBICPORTransaction = ''; creationDateTime = ''; finalDuration = '';
    overallStatusCode = '';confirmedAmountCurrency = '';partyCompanyName = '';partyCompanyBIC = '';partyCompanyFlag = '';partyCountryName = '';partyCreationTime = '';partySendersReferenceOutgoing = '';partySendersReferenceIncoming = '';benCompanyName = '';benCompanyBIC = '';benCompanyFlag = '';benCountryName = '';benReceivedDateTime = '';benReceivedDateTime = '';benCompletionTime = '';benDeducts = '';
    
RETURN

*-----------------------------------------------------------------------------
*** <region name= GET.INPUT.DETAILS>
GET.INPUT.DETAILS:
*** <desc>Get input details</desc>
    LOCATE 'ID' IN EB.Reports.getDFields()<1> SETTING AC.POS THEN   ;*Check condition for getting account no
        paymentId = EB.Reports.getDRangeAndValue()<AC.POS>
    END

    LOCATE 'PAYMENT.METHOD' IN EB.Reports.getDFields()<1> SETTING LS.POS THEN    ;*Check condition for getting List type
        paymentMethod = EB.Reports.getDRangeAndValue()<LS.POS>
    END
    
    IF paymentId[1,2] EQ 'PI' THEN
        GOSUB GET.PAYMENT.ORDER.DETAILS  ;*Get payment order details
    END ELSE
        paymentSystemId = paymentId;
    END

RETURN
*-----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PAYENT.ORDER.DETAILS>
GET.PAYMENT.ORDER.DETAILS:
*** <desc>Get payment order details</desc>
    paymentRecord  = PI.Contract.PaymentOrder.Read(paymentId, paymentErr)
    IF NOT(paymentErr) THEN
        uniqueTxnReference = paymentRecord<PI.Contract.PaymentOrder.PoUniqueTxnReference> ;*Fetch unique transaction reference
        paymentSystemId    = paymentRecord<PI.Contract.PaymentOrder.PoPaymentSystemId>    ;* Fetch the Payment System ID
    END
 
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.POR.TRANSACTION.DETAILS>
GET.POR.TRANSACTION.DETAILS:
*** <desc>Get the details of POR.TRANSACTION table </desc>
    
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber>      = paymentSystemId ;*Passing @Id of POR.TRANSACTION
    
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID,oPaymentRecord,oAdditionalPaymentRecord,oReadErr)
     
    
    IF (oReadErr EQ '') AND (oPaymentRecord NE '') THEN
        transactionAmount       = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>          ;*Get Transaction Amount
        endToEndReference       = oAdditionalPaymentRecord<PP.PaymentWorkflowDASService.AdditionalPaymentRecord.endToEndReference>          ;*Get endToEndReference
        paymentDirection        = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.paymentDirection>           ;*Get Payment Direction
        companyMnemonic         = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>                  ;*Get Company ID - BNK
        sendersReferenceOutgoing = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceOutgoing>  ;*Get SendersReference Outgoing
        sendersReferenceIncoming = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.sendersReferenceIncoming>  ;*Get SendersReference Incoming
        instructedAmount        = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.instructedAmount>           ;*Get Instructed Amount
        instructedCurrencyCode  = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.instructedCurrencyCode>     ;*Get Instructed Currency Code
        receivedFileRef         = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.fileReferenceIncoming>
        companyBICPORTransaction= oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyBic>
        
        IF instructedAmount EQ '' THEN
            instructedAmount        = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>           ;*Get Instructed Amount
            instructedCurrencyCode  = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>     ;*Get Instructed Currency Code
        END
        
    END
     
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** </region>
*** <region name= GET.GPI.TRACKER.DETAILS>
GET.GPI.TRACKER.DETAILS:
*** <desc>Get PI.GPI.TRACKER details </desc>
    BEGIN CASE
        CASE paymentMethod EQ 'PAYMENT.RECEIVED'
            GPITrackerId = endToEndReference;
        CASE paymentMethod EQ 'PAYMENT.SENT'
            GPITrackerId = uniqueTxnReference;
    END CASE
    IF GPITrackerId NE '' THEN
        GPITrackerRecord = PI.Config.PiGpiTracker.Read(GPITrackerId, Error) ; *Read PI.GPI.TRACKER record
        completionTime = GPITrackerRecord<PI.Config.PiGpiTracker.CompletionTime> ;*Get Completion Time
        initiationTime = GPITrackerRecord<PI.Config.PiGpiTracker.InitiationTime> ;*Get InitiationTime Time
            
        messageNameIdentification = GPITrackerRecord<PI.Config.PiGpiTracker.MessageNameIdentification> ;*Get Message Name Identification - MT199]MT299]199
        transactionEventType = GPITrackerRecord<PI.Config.PiGpiTracker.TransactionEventType> ;*Get Transaction Event Type CTPT]CTSU]COSU
        overallStatusCode = GPITrackerRecord<PI.Config.PiGpiTracker.OverallStatusCode>
        debtorAgent = GPITrackerRecord<PI.Config.PiGpiTracker.DebtorAgent> ;*Get Debtor Agent
        messageNameIdentificationCount = DCOUNT(messageNameIdentification,@VM)
            
*Get Charge Amount
        messageTypes = "GetPaymentTransactionDetails":@VM:"MT199":@VM:"UpdatePaymentStatus"
        eventType = "CTSU"
        messageTypesCount = DCOUNT(messageTypes, @VM)
        FOR CNT=1 TO messageTypesCount
            LOCATE messageTypes<1,CNT> IN messageNameIdentification<1,1> SETTING MSG.FOUND THEN
                rEventTypes = GPITrackerRecord<PI.Config.PiGpiTracker.TransactionEventType,MSG.FOUND>
                LOCATE eventType IN rEventTypes<1,1,1> SETTING EVENT.FOUND THEN
                    chargeAmount = GPITrackerRecord<PI.Config.PiGpiTracker.ChargeAmount,MSG.FOUND,EVENT.FOUND>
                    GOSUB PROCESS.CHARGE.AMOUNT
                    finalChargeAmount = fChargeAmount
                    confirmedAmount = GPITrackerRecord<PI.Config.PiGpiTracker.ConfirmedAmount,MSG.FOUND,EVENT.FOUND> ;*Get Confirmed Amount
                    confirmedAmountCurrency = GPITrackerRecord<PI.Config.PiGpiTracker.ConfirmedAmountCurrency,MSG.FOUND,EVENT.FOUND>
                END
            END
        NEXT CNT
**calculate time between two times
        GOSUB CALCULATE.TIME.DIFFERENCE
        
    END
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS the values>
PROCESS:
*** <desc>Process the values</desc>
    languagePosition = EB.SystemTables.getLngg()        ;*Fetch the ompany Name
    
;*Get POR.SUPPLEMENTARY.INFO account information details
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.ACCOUNTINFO',paymentSystemId,'',PORSupplementaryRecord,'')
    PORSupplementaryRecord = FIELD(PORSupplementaryRecord,@FM,3,999)
    mainOrChargeAccountType = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdMainOrChargeAccountType> ;*Main or charge account Type - D- debit, C- Credit
    
    GOSUB GET.PARTY.IDENTIFIER.DETAILS ;*
    GOSUB GET.BENEFICIARY.IDENTIFIER.DETAILS ;*
       
RETURN

*-----------------------------------------------------------------------------
*** <region name= PROCESS.PARTY.IDENTIFIER.DETAILS>
GET.PARTY.IDENTIFIER.DETAILS:
*** <desc>Process outward direction values</desc>
    
*Get Company name : bank of china - payment Direction = Incoming
    IF paymentDirection EQ 'O' THEN
        GOSUB GET.COMPANY.DETAILS ;*Get company details from companyBIC
        partyCompanyName = companyName ;*fetch the company name BNK-GB0010001
        
*Get BIC number for party : BIC BANKUS33
        PP.PaymentFrameworkService.getCompanyProperties(companyMnemonic, companyPropertiesRecord, CompPropsError) ;* Get PP.COMPANY.PROPERTIES id with mnemnic : BNK
        IF NOT(CompPropsError) THEN
            poCompanyBIC = companyPropertiesRecord<PP.PaymentFrameworkService.CompanyProperties.companyBIC> ;*Get CompanyBIC
        END
        IF poCompanyBIC EQ '' THEN
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = companyMnemonic
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = paymentSystemId
            oPrtyDbtDetails  = ""
            oGetPrtyDbtError = ""
            PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
            debitPartyRoles = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>;
            partyRole = "ORDINS";
            LOCATE partyRole IN debitPartyRoles<1,1> SETTING debitPartyFound THEN
                poCompanyBIC = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyIdentifierCode,debitPartyFound>
            END
        END
        partyCompanyBIC = poCompanyBIC
        partyCompanyFlag = SUBSTRINGS(poCompanyBIC,5,2) ;*Extract country code - (ABNRNLNL - NL)
        companyBIC = poCompanyBIC;
        GOSUB GET.COUNTRY.DETAILS ;*Get country details from companyBIC
        partyCountryName = countryName ;*Party company name
*PPT.SENTFILEDETAILS
        GOSUB GET.SEND.DATE.TIME; *Get Party Creation Date Time
*Get sender account number and customer id

        LOCATE 'D' IN mainOrChargeAccountType<1,1> SETTING debitAccountFound THEN
            partyAccountNumber = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdAccountNumber,debitAccountFound> ;* Debit party account number
            partyCustomerName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdCustomerName,debitAccountFound> ;* Debit party customer name
        END
    
    
*Get senders reference :
        partySendersReferenceOutgoing = sendersReferenceOutgoing ;
    END ELSE
        IF paymentDirection EQ 'I' THEN
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID>   = companyMnemonic
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber>    = paymentSystemId
            oPrtyDbtDetails  = ""
            oGetPrtyDbtError = ""
            PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole,oPrtyDbtDetails,oGetPrtyDbtError)
            debitPartyRoles = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyRole>;
            partyRole = "ORDINS";
            LOCATE partyRole IN debitPartyRoles<1,1> SETTING debitPartyFound THEN
                debitPartyIdentifierCode = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyIdentifierCode,debitPartyFound>
            END
            IF debitPartyIdentifierCode EQ '' THEN
                partyRole = "SENDER";
                LOCATE partyRole IN debitPartyRoles<1,1> SETTING debitPartyFound THEN
                    debitPartyIdentifierCode = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyIdentifierCode,debitPartyFound>
                END
            END
;*Get Incoming party account name and customer number
        
            partyRole = "ORDPTY";
            LOCATE partyRole IN debitPartyRoles<1,1> SETTING debitPartyFound THEN
                partyCustomerName = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyName,debitPartyFound> ;*Incoming party name
                partyAccountNumber = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine,debitPartyFound>;*Incoming customer number
                
                IF partyCustomerName EQ '' THEN
                    partyCustomerName = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyFreeLine1,debitPartyFound> ;*Incoming party name is null then take party free line
                END
            END
                
*Read the party Financial Identifier name Incoming
            inputBICTable<PP.BankCodeService.BICContext.bicCode> = debitPartyIdentifierCode
            inputBICTable<PP.BankCodeService.BICContext.companyID> =  companyMnemonic
            PP.BankCodeService.getBICDetails(inputBICTable, BICTableRecord, BICTableError)
            IF NOT(BICTableError) THEN
                partyCompanyName = BICTableRecord<PP.BankCodeService.BICTableDetails.finInstitutionName>
            END
            partyCompanyBIC = debitPartyIdentifierCode
            partyCompanyFlag = SUBSTRINGS(debitPartyIdentifierCode,5,2) ;*Extract country code - (ABNRNLNL - NL)
            companyBIC = debitPartyIdentifierCode
            GOSUB GET.COUNTRY.DETAILS ;*Get country details from companyBIC
            partyCountryName = countryName ;*Party company name : CHINA
*Get the initial time for incoming
            messageType = "GetPaymentTransactionDetails"
            transactionType = "CTPT"
            LOCATE messageType IN messageNameIdentification<1,1> SETTING MPOS THEN
                rTransactionEventType = GPITrackerRecord<PI.Config.PiGpiTracker.TransactionEventType,MPOS>
                LOCATE transactionType IN rTransactionEventType<1,1,1> SETTING EPOS THEN
                    fromAgent = GPITrackerRecord<PI.Config.PiGpiTracker.FromAgent,MPOS,EPOS> ;*Get From Agent
                    IF fromAgent EQ partyCompanyBIC THEN
                        partyCreationDateTime = GPITrackerRecord<PI.Config.PiGpiTracker.SenderAckReceipt,MPOS,EPOS> ;* get send time from sender ack receipt
                    END
                END
            END
*senders refence outgoing
            partySendersReferenceIncoming = sendersReferenceIncoming;
        END
    END
    
*End of party
 
RETURN
*-----------------------------------------------------------------------------
*** <region name= GET.BENEFICIARY.IDENTIFIER.DETAILS>
GET.BENEFICIARY.IDENTIFIER.DETAILS:
*** <desc>Process beneficiary values</desc>
 
    IF paymentDirection EQ 'I' THEN
        GOSUB GET.COMPANY.DETAILS ;*Get company details from companyBIC
        benCompanyName = companyName;
            
        PP.PaymentFrameworkService.getCompanyProperties(companyMnemonic, companyPropertiesRecord, CompPropsError) ;* Get PP.COMPANY.PROPERTIES id with mnemnic : BNK
        IF NOT(CompPropsError) THEN
            benCompanyBIC = companyPropertiesRecord<PP.PaymentFrameworkService.CompanyProperties.companyBIC> ;*Get CompanyBIC
            benCompanyBIC = benCompanyBIC
            benCompanyFlag = SUBSTRINGS(benCompanyBIC,5,2) ;*Extract country code - (ABNRNLNL - NL)
            companyBIC = benCompanyBIC
            GOSUB GET.COUNTRY.DETAILS ;*Get country details from companyBIC
            benCountryName = countryName ;*Party company name
        END
        
*Read PPT.RECEIVEDFILEDETAILS and get received sate field
        RecPptReceivedFileDetails = ""
        FnPptReceivedFileDetails = 'F.PPT.RECEIVEDFILEDETAILS'
        FPptReceivedFileDetails = ''
        EB.DataAccess.Opf(FnPptReceivedFileDetails, FPptReceivedFileDetails)
        EB.DataAccess.FRead(FnPptReceivedFileDetails,receivedFileRef,RecPptReceivedFileDetails,FPptReceivedFileDetails,Error)
        IF NOT(Error) THEN
            benReceivedDateTime = RecPptReceivedFileDetails<PP.MessageAcceptanceService.PptReceivedFileDetails.PprfdReceiveddatetime>
        END
;*Get Incoming beneficiary account number and customer name
        LOCATE 'C' IN mainOrChargeAccountType<1,1> SETTING creditAccountFound THEN
            beneficiaryAccountNumber = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdAccountNumber,creditAccountFound> ;* Debit party account number
            beneficiaryCustomerName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdCustomerName,creditAccountFound> ;* Debit party customer name
        END
        
    END ELSE
        IF paymentDirection EQ 'O' THEN
            iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID>   = companyMnemonic
            iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber>    = paymentSystemId
            oPrtyCreditDetails  = ""
            oGetPrtyCreditError = ""
            PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole,oPrtyCreditDetails,oGetPrtyCreditError)
            noOfTypes = DCOUNT(oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>,@VM)
            FOR type=1 TO noOfTypes
                BEGIN CASE
                    CASE oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,type> EQ 'ACWINS'
                        beneficiaryIdentifierCode = oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode,type>
                    CASE oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole,type> EQ 'BENFCY'
                        beneficiaryCustomerName = oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crName,type>
                        beneficiaryAccountNumber = oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine,type>
                        IF beneficiaryCustomerName EQ '' THEN
                            beneficiaryCustomerName = oPrtyCreditDetails<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyFreeLine1,type>;* Debit party customer name is null then take free line
                        END
                END CASE
            NEXT type
            
;*Get Outgoing beneficiary account number and customer name
                
            inputBICTable<PP.BankCodeService.BICContext.companyID> =  companyMnemonic
            inputBICTable<PP.BankCodeService.BICContext.bicCode> = beneficiaryIdentifierCode
            PP.BankCodeService.getBICDetails(inputBICTable, BICTableRecord, BICTableError)
            IF NOT(BICTableError) THEN
                beneficiaryFinancialInstitutionName = BICTableRecord<PP.BankCodeService.BICTableDetails.finInstitutionName>
            END
            benCompanyName = beneficiaryFinancialInstitutionName;
            benCompanyBIC = beneficiaryIdentifierCode
            benCompanyFlag = SUBSTRINGS(benCompanyBIC,5,2) ;*Extract country code - (ABNRNLNL - NL)
            companyBIC = benCompanyBIC
            GOSUB GET.COUNTRY.DETAILS ;*Get country details from companyBIC
            benCountryName = countryName ;*Party company name
                    
;*Get received date from POR.TRANSACTION
            messageType = "GetPaymentTransactionDetails"
            transactionType = "CTPT"
    
            LOCATE messageType IN messageNameIdentification<1,1> SETTING MPOS THEN
                rTransactionEventType = GPITrackerRecord<PI.Config.PiGpiTracker.TransactionEventType,MPOS>
                LOCATE transactionType IN rTransactionEventType<1,1,1> SETTING EPOS THEN
                    creditorAgent = GPITrackerRecord<PI.Config.PiGpiTracker.CreditorAgent,MPOS,EPOS> ;*Get From Agent
                    IF creditorAgent EQ '' THEN
                        benReceivedDateTime = GPITrackerRecord<PI.Config.PiGpiTracker.ReceivedDate,MPOS,EPOS> ;*Get Sender acnowledgement receipt
                    END
                END
            END
        END
    END
    benCompletionTime = completionTime ;*Beneficiary Completion Time
    
*20191023124610643
    IF benReceivedDateTime NE '' THEN
        benReceivedCompletionDate = benReceivedDateTime[1,8]
        benReceivedCompletionTime = benReceivedDateTime[9,2]:":":benReceivedDateTime[11,2]
        benReceivedDate = ICONV(benReceivedCompletionDate,"D")        ;* convert date to milliseconds - 20091224 - 10985
        benReceivedTime = ICONV(benReceivedCompletionTime,"MTS")
        bTotalDuration = TIMEDIFF(MAKETIMESTAMP(CompletionDate, eCompletionTimeMinutes, ''), MAKETIMESTAMP(benReceivedDate,benReceivedTime, '') , 0)
        IF benReceivedDateTime NE '' THEN
            benReceivedDateTime = OCONV(benReceivedDate, "D4") :" ":benReceivedCompletionTime
        END
    
        IF bTotalDuration EQ '' THEN
            benTotalDuration = ""
        END ELSE
            CHANGE @FM TO ':' IN bTotalDuration
            benTotalDuration = bTotalDuration
        END
    END
*Need to take senders's deducts
*Do your code here
    benDeducts = '';
    chargeAmount = ''
    senderChargeAmount1 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeAmount1>
    IF senderChargeAmount1 NE '' THEN
        senderChargeAmountCurrency1 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeCurrencyCode1>
        chargeAmount<-1> = senderChargeAmountCurrency1:senderChargeAmount1
        senderChargeAmount2 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeAmount2>
        IF senderChargeAmount2 NE '' THEN
            senderChargeAmountCurrency2 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeCurrencyCode2>
            chargeAmount<-1> = senderChargeAmountCurrency2:senderChargeAmount2
            senderChargeAmount3 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeAmount3>
            IF senderChargeAmount3 NE '' THEN
                senderChargeAmountCurrency3 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeCurrencyCode3>
                chargeAmount<-1> = senderChargeAmountCurrency3:senderChargeAmount3
                senderChargeAmount4 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeAmount4>
                IF senderChargeAmount4 NE '' THEN
                    senderChargeAmountCurrency4 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeCurrencyCode5>
                    chargeAmount<-1> = senderChargeAmountCurrency4:senderChargeAmount4
                    senderChargeAmount5 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeAmount5>
                    IF senderChargeAmount5 NE '' THEN
                        senderChargeAmountCurrency5 = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.senderChargeCurrencyCode5>
                        chargeAmount<-1> = senderChargeAmountCurrency5:senderChargeAmount5
                    END
                END
            END
        END
    END
    GOSUB PROCESS.CHARGE.AMOUNT
    benDeducts = fChargeAmount
RETURN
*-----------------------------------------------------------------------------
*** <region name= GET.COUNTRY.DETAILS>
GET.COUNTRY.DETAILS:
*** <desc>Get country details</desc>
    IF companyBIC NE '' THEN
        countryId = SUBSTRINGS(companyBIC,5,2) ;*Extract country code - (ABNRNLNL - NL)
        countryRecord = ST.Config.Country.Read(countryId, cntryerr)
        IF NOT(cntryerr) THEN
            countryName = countryRecord<ST.Config.Country.EbCouCountryName,languagePosition>
            IF NOT(companyName) THEN
                countryName = countryRecord<ST.Config.Country.EbCouCountryName,1>
            END
        END
    END
     
RETURN

*-----------------------------------------------------------------------------
*** <region name= GET.COMPANY.DETAILS>
GET.COMPANY.DETAILS:
*** <desc>Get company details</desc>
*Get Company name @ID from company Mnemonic - BNK
    R.CompanyMnemonic = ST.CompanyCreation.MnemonicCompany.Read(companyMnemonic, companyError)
    companyId = R.CompanyMnemonic<ST.CompanyCreation.MnemonicCompany.AcMcoCompany> ;*BNK to GB0010001
        
    companyRecord = ST.CompanyCreation.Company.Read(companyId,error)
    companyName = companyRecord<ST.CompanyCreation.Company.EbComCompanyName,languagePosition>
    
    IF NOT(companyName) THEN
        companyName = companyRecord<ST.CompanyCreation.Company.EbComCompanyName,1>
    END
     
RETURN
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*** <region name= PROCESS.CHARGE.AMOUNT>
PROCESS.CHARGE.AMOUNT:
*** <desc>Get charge details</desc>
*calculate charge details from : GBP15,||GBP15,||USD30,
    Amount = chargeAmount;
    CHANGE '||' TO @FM IN Amount ; * Convert the demiliter double pipe to field marker
    CURRENCY.ARRAY = ""
    AMOUNT.ARRAY = ""
    LOOP
        REMOVE AMT.VAL FROM Amount SETTING AmtFound
    WHILE AMT.VAL:AmtFound
        AMT.CURR = AMT.VAL[1,3]
        AmountValue = AMT.VAL[4,10]
        CONVERT ',' TO '.' IN AmountValue
                    
        LOCATE AMT.CURR IN CURRENCY.ARRAY SETTING CCY.FOUND THEN
            Total = ""
            Total = AMOUNT.ARRAY<CCY.FOUND> + AmountValue
            AMOUNT.ARRAY<CCY.FOUND> = Total
        END ELSE
* First Time
            CURRENCY.ARRAY<-1> = AMT.CURR

            AMOUNT.ARRAY<-1> = AmountValue
        END
    REPEAT
    OUTPUT.DATA = ""
    NUMBER.OF.CURRENCIES = DCOUNT(CURRENCY.ARRAY,@FM)
    FOR CURR.CNT = 1 TO NUMBER.OF.CURRENCIES
        IF OUTPUT.DATA EQ "" THEN
            OUTPUT.DATA = CURRENCY.ARRAY<CURR.CNT>:AMOUNT.ARRAY<CURR.CNT>
        END ELSE
            OUTPUT.DATA = OUTPUT.DATA:",":CURRENCY.ARRAY<CURR.CNT>:AMOUNT.ARRAY<CURR.CNT>
        END
            
    NEXT CURR.CNT
    fChargeAmount = OUTPUT.DATA
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= CALCULATE.TIME.DIFFERENCE>
CALCULATE.TIME.DIFFERENCE:
*** <desc>Calculate time difference</desc>
*convert UTC time into timestamp in milliseconds
    InitialDate = FIELD(initiationTime,'T',1)
    CONVERT '-' TO '' IN InitialDate        ;*extracted initial date - sample : 2009-12-24T14:04Z - 20091224
    eInitialTime = FIELD(FIELD(initiationTime,'T',2),'Z',1)  ;*extracted initial time - sample : 2009-12-24T14:04Z - 14:02
    
    CompletionDate = FIELD(completionTime,'T',1)
    CONVERT '-' TO '' IN CompletionDate        ;*extracted initial date - sample : 2009-12-24T14:04Z - 20091224
    eCompletionTime = FIELD(FIELD(completionTime,'T',2),'Z',1)  ;*extracted initial time - sample : 2009-12-24T14:04Z - 14:02
        
    InitialDate = ICONV(InitialDate,"D")        ;* convert date to milliseconds - 20091224 - 10985
    eInitialTimeMinutes = ICONV(eInitialTime,"MTS")    ;* convert time to milliseconds - 14:02 - 18907
        
    CompletionDate = ICONV(CompletionDate,"D")
    eCompletionTimeMinutes = ICONV(eCompletionTime,"MTS")
        
    TotalDurationArray = TIMEDIFF(MAKETIMESTAMP(InitialDate, eInitialTimeMinutes, ''), MAKETIMESTAMP(CompletionDate,eCompletionTimeMinutes, '') , 0) ;* 30?22?2?0?0
    IF TotalDurationArray NE '' THEN
        CHANGE @FM TO ':' IN TotalDurationArray
        totalDuration = TotalDurationArray
    END ELSE
        totalDuration = ""
    END
    
*Format Initiation and Completion Time
    
    IF initiationTime NE '' THEN
        GPiDateTime = ''
        GPiDateTime = initiationTime
        GOSUB FORMAT.TIME.ZONE;
        initiationTime = localZoneTime
    END
    IF completionTime NE '' THEN
        GPiDateTime = ''
        GPiDateTime = completionTime
        GOSUB FORMAT.TIME.ZONE;
        completionTime = localZoneTime
    END
RETURN

*-----------------------------------------------------------------------------
*** <region name= FORMAT.TIME.ZONE>
FORMAT.TIME.ZONE:
*** <desc>Format Date Time</desc>
    GPiDateTime = GPiDateTime[3,2]:GPiDateTime[6,2]:GPiDateTime[9,2]:GPiDateTime[12,2]:GPiDateTime[15,2]
    localZoneTime = ''
    PP.InquiryGUI.CalculateLocalZoneTime(GPiDateTime,localZoneTime)

RETURN
*-----------------------------------------------------------------------------
*** <region name= GET.SEND.DATE.TIME>
GET.SEND.DATE.TIME:
*** <desc>Get the party Creation Date Time</desc>
    iPsmBlobDetails<PP.SwiftOutService.BlobRecID.companyID> = companyMnemonic
    iPsmBlobDetails<PP.SwiftOutService.BlobRecID.ftNumber> = paymentSystemId
    iSelectionCriteria = dasPSM.findByCompanyAndFt
    PP.SwiftOutService.getPSMBlobListDetails(iPsmBlobDetails, iSelectionCriteria, oPsmBlobList, oPsmBlobError)
    IF oPsmBlobList THEN
* Loop through PSM.BLOB records to get the GPI msg sent time
        LOOP
            REMOVE RecId FROM oPsmBlobList SETTING PSM.POS
        WHILE RecId:PSM.POS
            REC.PSM.BLOB = ""
            FN.PSM.BLOB = 'F.PSM.BLOB'
            F.PSM.BLOB = ''
            EB.DataAccess.Opf(FN.PSM.BLOB, F.PSM.BLOB)
            EB.DataAccess.FRead(FN.PSM.BLOB,RecId,REC.PSM.BLOB,F.PSM.BLOB,Error)
            IF REC.PSM.BLOB<PP.SwiftOutService.PsmBlob.PpsmbMessageType>[1,3] EQ 'GPI' THEN
                partySendDateTime = REC.PSM.BLOB<PP.SwiftOutService.PsmBlob.PpsmbSendDateTime>
                BREAK ;* We've got tha value get out
            END
        REPEAT
    END
    IF partySendDateTime NE '' THEN
        partyCreationDate = partySendDateTime[1,8]
        partyCreationTime = partySendDateTime[9,2]:":":partySendDateTime[11,2]
        partyCreationDate = ICONV(partyCreationDate,"D")
        partyCreationDateTime = OCONV(partyCreationDate, "D4") :" ":partyCreationTime
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= FINAL.ARRAY.DETAILS>
FINAL.ARRAY.DETAILS:
*** <desc>Final Array construction</desc>
    CONVERT ',' TO '.' IN instructedAmount
    CONVERT ',' TO '.' IN confirmedAmount
    OUT.ARRAY<-1> = uniqueTxnReference:"*":paymentSystemId:"*":transactionAmount:"*":endToEndReference:"*":paymentDirection:"*":companyId:"*":instructedAmount:"*":instructedCurrencyCode:"*":completionTime:"*":initiationTime:"*":confirmedAmount:"*":confirmedAmountCurrency:"*":finalChargeAmount:"*":messageNameIdentification:"*":transactionEventType:"*":debtorAgent:"*":totalDuration:"*":overallStatusCode:"*":partyCompanyName:"*":partyCompanyBIC:"*":partyCompanyFlag:"*":partyCountryName:"*":partyCreationDateTime:"*":partySendersReferenceOutgoing:"*":partySendersReferenceIncoming:"*":benCompanyName:"*":benCompanyBIC:"*":benCompanyFlag:"*":benCountryName:"*":benReceivedDateTime:"*":benCompletionTime:"*":benDeducts:"*":benTotalDuration:"*":partyAccountNumber:"*":partyCustomerName:"*":beneficiaryAccountNumber:"*":beneficiaryCustomerName

RETURN
*-----------------------------------------------------------------------------
