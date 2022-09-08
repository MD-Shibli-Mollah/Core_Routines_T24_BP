* @ValidationCode : MjotMTk5MDAwNjU4OTpjcDEyNTI6MTYxNTI5MDY0OTkxMzptc3NocnV0aGk6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjMxMToyODc=
* @ValidationInfo : Timestamp         : 09 Mar 2021 17:20:49
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : msshruthi
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 287/311 (92.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE PZ.ModelBank
SUBROUTINE GET.STMT.ENT.DETS(transactionId,stmtdets)
*-----------------------------------------------------------------------------
* Routine to fetch details from statement entry.
* Check for the system id of the statement entry and returns values based on transaction
* Statement details are passed back to the enquiry routine and inturn to the enquiry output.
*
*Incoming Argumets :
* transactionId - ID of STMT.ENTRY record
*
*Outgoing Arguments :
*stmtdets which contains the data from stmt entry and funds transfer.

*-----------------------------------------------------------------------------
* Modification History :
* 1/2/19 - Enhancement 2741274 / Task 2948253
*          New routine introduced to return statement entry and FT Details.
*
* 29/08/19 - Task 3312891
*            Return the currency details of the transaction
*
* 02.01.20 - Credit account number and name are changed to fetch from ben name and ben acct no
*
* 04/06/2020 - Defect 3780928 / Task 3782848
*              Fix to display credit IBAN and debit IBAN separately in enquiry output
* 03/02/20 - Task 4211045
*            Changed process of fetching other leg of stmt entry record to avoid TAFC error.
*
* 09/02/21 - Task 3879095
*            Remittance Information returned for PO transactions
*
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING ST.Customer
    $USING ST.Config
    $USING EB.LocalReferences
    $USING FT.Contract
    $USING AC.EntryCreation
    $USING ST.CompanyCreation
    $USING EB.Updates
    $USING PZ.ModelBank
    $USING IN.IbanAPI
    $USING PI.Contract
*-----------------------------------------------------------------------------
    GOSUB initialise                ;*initialise variables
    GOSUB readStmtEntry             ;*Read statement entry
    GOSUB determineTxnDetails       ;* To determine the transaction details and beneficiary details of the underlying transaction
    GOSUB amountInAccCurrency       ;* To determine the debit amount of a transaction
    GOSUB getDebtorCreditorDetails  ;* Get creditor debitor details
    GOSUB fetchStmtEntryValues      ;*To fetch values from stmt entry
    BEGIN CASE
        CASE stmtRec<AC.EntryCreation.StmtEntry.SteSystemId> = "FT"
            GOSUB fetchFtDetails    ;*Fetch FT Details
        CASE stmtRec<AC.EntryCreation.StmtEntry.SteSystemId> = "PP"
            GOSUB fetchPoDetails    ;*Fetch PO Details
    END CASE
    IF InisInstalled THEN
        GOSUB getIBANFromAccount        ;* To obtain the IBAN Id from the account ID provided
    END
    
    GOSUB getExchangeCurrency       ;* To determine exchange currency
    GOSUB formOutputValues          ;*Form final output array
RETURN
*-----------------------------------------------------------------------------

initialise:

    ultimateCreditor = ''
    ultimateDebtor = ''
    bankTransactionCode = ''
    remittanceInformationUnstructured = ''
    remittanceInformationStructured = ''
    acPos = ''
    stmtRec = ''
    errStmt = ''
    errDet = ''
    txnPos = ''
    AcisInstalled = ''
    compError = ''
    ftError = ''
    ftRecord = ''
    ftErrorHis = ''
    acError = ''
    cusError = ''
    txnError = ''
    pos = ''
    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    FN.FUNDS.TRANSFER.HIS = 'F.FUNDS.TRANSFER$HIS'
    stmtdets = ''
    
    InisInstalled = ''
    EB.API.ProductIsInCompany('IN', InisInstalled)

RETURN
*-----------------------------------------------------------------------------

readStmtEntry:

    stmtRec = AC.EntryCreation.StmtEntry.Read(transactionId,errStmt) ;*Read stmt entry
    accId = stmtRec<AC.EntryCreation.StmtEntry.SteAccountNumber> ;*what if it is an automatically created account ?
    IF NOT(stmtRec) THEN
        stmtRec = AC.EntryCreation.StmtEntryDetail.Read(transactionId, errDet) ;*if there is no record in stmt.entry, read stmt.entry.detail
        accId = stmtRec<AC.EntryCreation.StmtEntry.SteAccountNumber>
    END
    IF errDet THEN
        EB.Reports.setEnqError("PZ-INVALID.TXN.ID")
        RETURN
    END
    
RETURN
*-----------------------------------------------------------------------------

formOutputValues:

    stmtdets<-1> = accId                                ;*1 Account number
    stmtdets<-1> = debitIban                            ;*2 Account Iban
    stmtdets<-1> = txnDetails<3>                        ;*3 ultimatecreditor/creditaccount
    stmtdets<-1> = txnDetails<4>                        ;*4 ultimate creditor name
    stmtdets<-1> = txnDetails<5>                        ;*5 ultimate debitor account
    stmtdets<-1> = txnDetails<6>                        ;*6 ultimate debitor name
    stmtdets<-1> = amtAcctCcy                           ;*7 amount in LCY/FCY
    stmtdets<-1> = entryRef                             ;*8 entry ref
    stmtdets<-1> = chequeId                             ;*9 cheque id
    stmtdets<-1> = bookingDate                          ;*10 booking date
    stmtdets<-1> = valueDate                            ;*11 value date
    stmtdets<-1> = exchangeRate                         ;*12 Exchange Rate
    stmtdets<-1> = txnCode                              ;*13 Transaction code
    stmtdets<-1> = accountCcy                           ;*14 Account currency
    stmtdets<-1> = transactionAmt                       ;*15 Transaction amount
    stmtdets<-1> = remittanceInformationUnstructured    ;*16 Remittance information
    stmtdets<-1> = endToEndId                           ;*17 End to end reference
    stmtdets<-1> = mandateId                            ;*18 Sepa Mandate Id
    stmtdets<-1> = creditorId                           ;*19 Creditor Id
    stmtdets<-1> = remittanceInformationStructured      ;*20 Remittance information
    stmtdets<-1> = creditAccount                        ;*21 Credit Account
    stmtdets<-1> = creditorName                         ;*22 Creditor name
    stmtdets<-1> = debtorName                           ;*23 Debtor name
    stmtdets<-1> = debitAccount                         ;*24 Debit account
    stmtdets<-1> = creditCcy                            ;*25 Credit currency
    stmtdets<-1> = sepaPurpose                          ;*26 Purpose code
    stmtdets<-1> = indicator                            ;*27 debit credit indicator
    stmtdets<-1> = debitCurrency                        ;*28 debit currency
    stmtdets<-1> = creditCurrency                       ;*29 credit currency
    stmtdets<-1> = creditIban                           ;*30 credit iban

RETURN
*-----------------------------------------------------------------------------

*** <region name= getIBANFromAccount>
getIBANFromAccount:
*** <desc> To obtain the IBAN Id from the account ID provided </desc>

    iBan = ""
    iBanErrCode = ''
    rAccount = ''
    
    ibanAcc = debitAccount
    IN.IbanAPI.IbanserviceGetiban(ibanAcc, rAccount, iBan, iBanErrCode);* API called to determine the IBAN reference specific to an account
    debitIban = iBan
    
    iBan = ""
    iBanErrCode = ''
    rAccount = ''
       
    ibanAcc = creditAccount
    IN.IbanAPI.IbanserviceGetiban(ibanAcc, rAccount, iBan, iBanErrCode)
    creditIban = iBan

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= determineTxnDetails>
determineTxnDetails:
*** <desc> To determine the transaction details and beneficiary details of the underlying transaction </desc>

* This API will inturn invoke the API's attached to STMT.ENTRY record
* attached to the STMT.NARR.FORMAT record.

    txnDetails = ""
    PZ.ModelBank.setSummaryOption("D")
    PZ.ModelBank.ePzTxnHistNarrative(transactionId, stmtRec, txnDetails)
    PZ.ModelBank.setSummaryOption("")

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= amountInAccCurrency>
amountInAccCurrency:
*** <desc> To determine the debit amount of a transaction </desc>

* Amount in account currency is determined based on the local currency
* and account currency
    localCcy = EB.SystemTables.getLccy()
    acctCcy = stmtRec<AC.EntryCreation.StmtEntry.SteCurrency>

    IF localCcy EQ acctCcy THEN
        amtAcctCcy = stmtRec<AC.EntryCreation.StmtEntry.SteAmountLcy>
    END ELSE
        amtAcctCcy = stmtRec<AC.EntryCreation.StmtEntry.SteAmountFcy>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** </region>
getDebtorCreditorDetails:

    txnError = ''
    transactionRecord = ''
    txnCode = stmtRec<AC.EntryCreation.StmtEntry.SteTransactionCode>
    transactionRecord = ST.Config.Transaction.Read(txnCode, txnError)
    debitCreditInd = ''
    debitCreditInd = transactionRecord<ST.Config.Transaction.AcTraDebitCreditInd> ;*get indicator from transaction record
    IF NOT(debitCreditInd) THEN ;*get debit credit indicator wrt amount if debit credit indicator is null in the entry
        IF amtAcctCcy AND amtAcctCcy < 0 THEN
            debitCreditInd = "DEBIT" ;*negative amount
        END ELSE
            debitCreditInd = "CREDIT"
        END
    END
    indicator = debitCreditInd ;*assign indicator before checking for reversal marker.

;*Check for reversal marker and reverse the entries accordingly
    reversalMarker = stmtRec<AC.EntryCreation.StmtEntry.SteReversalMarker>
    IF reversalMarker THEN
        IF debitCreditInd = "DEBIT" THEN
            debitCreditInd = "CREDIT"
        END ELSE
            debitCreditInd = "DEBIT"
        END
    END

;*if values are not obtained from stmt.narrative. i.e., from routine ePzTxnHistNarrative
    IF txnDetails = '' THEN
        stmtCusNum = stmtRec<AC.EntryCreation.StmtEntry.SteCustomerId>
        CustomerRec = ST.Customer.Customer.Read(stmtCusNum, cusError)
        BEGIN CASE
            CASE debitCreditInd = "DEBIT" ;*populate debit details in case of debit entry
                txnDetails<5> = accId ;*debit account
                txnDetails<6> = CustomerRec<ST.Customer.Customer.EbCusNameOne> ;*debit customer
            CASE debitCreditInd = "CREDIT" ;*populate credit details in case of credit entry
                txnDetails<3> = accId ;*credit account
                txnDetails<4> = CustomerRec<ST.Customer.Customer.EbCusNameOne> ;*credit customer
        END CASE
    END

RETURN

*-----------------------------------------------------------------------------
fetchStmtEntryValues:

;*Determine entryRef
    entryRef = stmtRec<AC.EntryCreation.StmtEntry.SteTransReference>
    IF entryRef = '' THEN
        entryRef = stmtRec<AC.EntryCreation.StmtEntry.SteOurReference>
    END


;*Fetch values from stmt.entry
    chequeId = stmtRec<AC.EntryCreation.StmtEntry.SteChequeNumber>
    bookingDate = stmtRec<AC.EntryCreation.StmtEntry.SteBookingDate>
    valueDate = stmtRec<AC.EntryCreation.StmtEntry.SteValueDate>
    accountCcy = stmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
    exchangeRate = stmtRec<AC.EntryCreation.StmtEntry.SteExchangeRate>
    amountLcy = stmtRec<AC.EntryCreation.StmtEntry.SteAmountLcy>
    amountFcy = stmtRec<AC.EntryCreation.StmtEntry.SteAmountFcy>
    accountCcy = stmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
    

RETURN

*---------------------------------------------------------------------------------
fetchFtDetails:

;*Fetch values from FT
    ftRecord = FT.Contract.FundsTransfer.Read(entryRef, ftError)
    IF NOT(ftRecord) THEN
        FN.FUNDS.TRANSFER.HIS = 'F.FUNDS.TRANSFER$HIS'
        F.FUNDS.TRANSFER.HIS = ''
        EB.DataAccess.Opf(FN.FUNDS.TRANSFER.HIS,F.FUNDS.TRANSFER.HIS)
        entryRefTemp = entryRef
        EB.DataAccess.ReadHistoryRec(F.FUNDS.TRANSFER.HIS, entryRefTemp, ftRecord, ftErrorHis)      ;* Pass the local variable 'F.FUNDS.TRANSFER.HIS' to fetch details from FUNDS.TRANSFER$HIS files using EB.READ.HISTORY.REC.
    END
    
;*Fetch values from FT
    CompMne = FIELD(entryRef, '\', 2)
    entryRef = FIELD(entryRef, '\', 1)
    IF CompMne THEN
        FN.FUNDS.TRANSFER = 'F':CompMne:'.FUNDS.TRANSFER'
        FN.FUNDS.TRANSFER.HIS = 'F':CompMne:'.FUNDS.TRANSFER$HIS'
    END
    EB.DataAccess.Opf(FN.FUNDS.TRANSFER, F.FUNDS.TRANSFER)
    EB.DataAccess.FRead(FN.FUNDS.TRANSFER, entryRef, ftRecord, F.FUNDS.TRANSFER, ftEr)
    IF NOT(ftRecord) THEN
        F.FUNDS.TRANSFER$HIS = ''
        EB.DataAccess.Opf(FN.FUNDS.TRANSFER.HIS,F.FUNDS.TRANSFER$HIS)
        entryRefTemp = entryRef
        EB.DataAccess.ReadHistoryRec(F.FUNDS.TRANSFER$HIS, entryRefTemp, ftRecord, ftErrorHis)
    END

    transactionAmt = ftRecord<FT.Contract.FundsTransfer.AmountCredited>
    creditAcctNumber = ftRecord<FT.Contract.FundsTransfer.CreditAcctNo>
    inBenAcctNumber = ftRecord<FT.Contract.FundsTransfer.BenAcctNo>
    inBenName = ftRecord<FT.Contract.FundsTransfer.BenName>
    txnType = ftRecord<FT.Contract.FundsTransfer.TransactionType>
    debitAccount = ftRecord<FT.Contract.FundsTransfer.DebitAcctNo>
    creditCcy = ftRecord<FT.Contract.FundsTransfer.CreditCurrency>
    creditorId = ftRecord<FT.Contract.FundsTransfer.AcctWithBank>
	remittanceInformationUnstructured = ftRecord<FT.Contract.FundsTransfer.PaymentDetails>
    
;*Determine local reference values from FT

    ApplArr = "FUNDS.TRANSFER"
    FieldnameArr = "END.TO.END.ID":@VM:"SEPA.MANDATE.ID":@VM:"SEPA.THEIR.BANK":@VM:"SEPA.CLR.HOUSE":@VM:"SEPA.THEIR.ACCT":@VM:"SEPA.THEIR.NAME":@VM:"SEPA.PURPOSE":@VM:"SEPA.PAYMENT.REF"
    PosArr = ''
    EB.Updates.MultiGetLocRef(ApplArr, FieldnameArr, PosArr)
    endToEndIdPos = PosArr<1,1>
    mandateIdPos = PosArr<1,2>
    creditorPos = PosArr<1,3>
    clrHsePos = PosArr<1,4>
    thrAcctPos = PosArr<1,5>
    thrNamePos = PosArr<1,6>
    purposePos = PosArr<1,7>
    remPos = PosArr<1,8>

    IF endToEndIdPos THEN
        endToEndId = ftRecord<FT.Contract.FundsTransfer.LocalRef,endToEndIdPos>
    END
    IF mandateIdPos THEN
        mandateId = ftRecord<FT.Contract.FundsTransfer.LocalRef,mandateIdPos>
    END
    IF creditorPos AND NOT(creditorId) THEN
        creditorId = ftRecord<FT.Contract.FundsTransfer.LocalRef,creditorPos>
    END
    IF clrHsePos THEN
        sepaClrHouse = ftRecord<FT.Contract.FundsTransfer.LocalRef,clrHsePos>
    END
    IF thrAcctPos THEN
        sepaThrAccount = ftRecord<FT.Contract.FundsTransfer.LocalRef,thrAcctPos>
    END
    IF thrNamePos THEN
        sepaThrName = ftRecord<FT.Contract.FundsTransfer.LocalRef,thrNamePos>
    END
    IF purposePos THEN
        sepaPurpose = ftRecord<FT.Contract.FundsTransfer.LocalRef,purposePos>
    END
    IF remPos THEN
        remittanceInformationStructured = ftRecord<FT.Contract.FundsTransfer.LocalRef,remPos>
    END

;*Determine creditor name and creditor account
    IF sepaClrHouse THEN
        creditAccount = sepaThrAccount
        creditorName = sepaThrName
    END ELSE
        BEGIN CASE
            CASE txnType[1,2] = 'AC'
                creditAccount = creditAcctNumber
                creditAccRecord = AC.AccountOpening.Account.Read(creditAccount, acError)
                IF NOT(creditAccRecord) THEN
                    F.ACCOUNT$HIS = ''
                    acErrorHis = ''
                    EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
                    creditAccTemp = creditAccount
                    EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS, creditAccTemp, creditAccRecord, acErrorHis)
                END
                creditorCus = creditAccRecord<AC.AccountOpening.Account.Customer>
                customerRecord = ST.Customer.Customer.Read(creditorCus, cusError)
                creditorName = customerRecord<ST.Customer.Customer.EbCusNameOne>
            CASE 1
                creditAccount = inBenAcctNumber
                creditorName = inBenName
        END CASE
    END


;*Determine debtor name
    debitAccRecord = AC.AccountOpening.Account.Read(debitAccount, acError)
    IF NOT(debitAccRecord) THEN
        F.ACCOUNT$HIS = ''
        acErrorHis = ''
        EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
        debitAccountTemp = debitAccount
        EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS, debitAccountTemp, debitAccRecord, acErrorHis)
    END
    debitCustomer = debitAccRecord<AC.AccountOpening.Account.Customer>
    customerRecord = ST.Customer.Customer.Read(debitCustomer, cusError)
    debtorName = customerRecord<ST.Customer.Customer.EbCusNameOne>

RETURN
*---------------------------------------------------------------------------------
fetchPoDetails:

    PPInstalled = ""
    EB.API.ProductIsInCompany("PP",PPInstalled) ;* check if PP product is installed
    IF NOT(PPInstalled) THEN ;* donot fetch values if PP not installed
        RETURN
    END

* Creditor and Debtor details for PO and SWIFT transactions
    creditAccount = txnDetails<3>
    creditorName = txnDetails<4>
    debitAccount = txnDetails<5>
    debtorName = txnDetails<6>
        
* For now only remittance Info is returned from PO and not for SWIFT
    PoRec = ""
    PoErr = ""
    PoId = stmtRec<AC.EntryCreation.StmtEntry.SteTheirReference> ;* get PAYMENT.ORDER Id
    PoRec = PI.Contract.PaymentOrder.Read(PoId, PoErr) ;* get PAYMENT.ORDER record
    IF NOT(PoRec) THEN ;* check for history record if LIVE record is missing
        FN.PAYMENT.ORDER.HIS = "F.PAYMENT.ORDER$HIS"
        F.PAYMENT.ORDER.HIS = ""
        EB.DataAccess.Opf(FN.PAYMENT.ORDER.HIS, F.PAYMENT.ORDER.HIS)
        PoIdHis = PoId
        EB.DataAccess.ReadHistoryRec(F.PAYMENT.ORDER.HIS, PoIdHis, PoRec, PoErr)
    END
    
    remittanceInformationStructured = PoRec<PI.Contract.PaymentOrder.PoRemittanceInformation>
        
RETURN
*---------------------------------------------------------------------------------
getExchangeCurrency:
** Get the currency of the other leg of stmt entry

    stmtEntryId = transactionId
    creditCurrency = ""
;* check if the currency of the existing entry is debit or credit
    currency = stmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
    IF debitCreditInd = "CREDIT" THEN
        creditCurrency = currency
    END ELSE
        debitCurrency = currency
    END

;* Read the other leg of stmt entry
    stmtNos = stmtRec<AC.EntryCreation.StmtEntry.SteStmtNo,2>
    IF FIELD(stmtNos,'-',2) THEN
        stmtEntryPart = FIELD(stmtEntryId,".",2)
        lastValue = stmtEntryPart[-1,1]
;* form other leg entry
        IF lastValue = 1 THEN
            lastValue = lastValue + 1
        END ELSE
            lastValue = lastValue - 1
        END
        lenValue = LEN(stmtEntryPart)
        stmtEntryPart = stmtEntryPart[1,lenValue-1]:lastValue
        otherLegEntry = FIELD(stmtEntryId,".",1):'.':stmtEntryPart ;* form the other leg id
        otherStmtRec = AC.EntryCreation.StmtEntry.Read(otherLegEntry,errStmt)
;* get the currency of the other leg
        IF creditCurrency THEN
            debitCurrency =  otherStmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
        END ELSE
            creditCurrency = otherStmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
        END
    END

RETURN
*-----------------------------------------------------------------------------------------------------------------
END
