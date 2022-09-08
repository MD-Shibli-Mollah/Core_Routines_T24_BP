* @ValidationCode : Mjo4Njc2NTI4OTU6Y3AxMjUyOjE2MTUyOTA2NTAxNjE6bXNzaHJ1dGhpOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDoxODM6MTYx
* @ValidationInfo : Timestamp         : 09 Mar 2021 17:20:50
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : msshruthi
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 161/183 (87.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.TXN.HIST.CONVERSION
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* New conversion routine introduced to determine the transaction details
* and beneficiary details from an underlying transaction (transaction is
* determined from STMT.ENTRY record).
*-----------------------------------------------------------------------------
*
* @uses EB.SystemTables
* @uses EB.ErrorProcessing
* @uses EB.Reports
* @uses EB.Browser
* @uses AC.AccountOpening
* @uses AC.StmtPrinting
* @uses AC.EntryCreation
* @uses AC.API
* @uses PZ.ModelBank
* @uses AC.ModelBank
* @package PZ.ModelBank
* @class E.PZ.TXN.HIST.CONVERSION
* @stereotype subroutine
* @author rdhepikha@temenos.com
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* Required values are obtained from O.DATA, D.FIELDS, D.RANGE.AND.VALUE
*
* Outgoing Arguments:
*
* OutputArray<1>    -   Account Reference
* OutputArray<2>    -   Account ID
* OutputArray<3>    -   IBAN
* OutputArray<4>    -   Booking Date
* OutputArray<5>    -   Value Date
* OutputArray<6>    -   Transaction Type
* OutputArray<7>    -   Account currency
* OutputArray<8>    -   Transaction currency
* OutputArray<9>    -   Exchange Rate
* OutputArray<10>   -   Amount in AC Currency
* OutputArray<11>   -   Amount in Txn Currency
* OutputArray<12>   -   Payee Account Identification(Creditor account)
* OutputArray<13>   -   Payee Identification
* OutputArray<14>   -   Transaction Reference
* OutputArray<15>   -   Closing Balance
* OutputArray<16>   -   Time Stamp
* OutputArray<17>   -   Skip Token
* OutputArray<18>   -   Debtor account
* OutputArray<19>   -   Debtor name
* OutputArray<20>   -   Remittance information unstructed

*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*-----------------------------------------------------------------------------
*
* 06/09/17 - Enhancement 2140052 / Task 2261830
*            Transaction History API - PSD2
*            New conversion routine is introduced.
*
* 20/10/17 - Enhancement 2140052 / Task 2312405
*            Common variable EndDate is removed.
*            End date is obtained from the enquiry common D.RANGE.AND.VALUE
*
* 06/11/17 - Defect 2329696 / Task 2332416
*            The APIs to fetch the narrative from STMT.NARR.FORMAT and format
*            the same is called directly from the enquiry. Hence the
*            calls to the routines are removed.
*
* 14/12/17 - Defect 2377888 / Task 2379048
*            Unique delimiter is used as seperator in the output array
*            passed through O.DATA
*
* 07/01/19 - Defect 2922622 / Task 2934907
*            Mismatching of Time in updated and execute time end in ENQUIRY has been resolved.
*
* 22/01/19  Enhancement 2741263 / Task 2978712
*            Performance improvement changes
*            To determine closing balance date is fetched from STMT.ENTRY
*            SkipToken is returned in O.DATA
*            Changes made to return debit account and debitor name of the underlying FT transaction
*
* 09/09/19 - Enhancement 3308494 / Task 3308495
*            TI Changes - Component moved from ST to AC.
*
* 29/08/19 - Task 3312891
*            Return the currency details of the transaction
*
* 03/02/20 - Task 4211045
*            Changed process of fetching other leg of stmt entry record to avoid TAFC error.
*
* 09/02/21 - Task 3879095
*            Remittance Information returned for PO transactions
*
*-----------------------------------------------------------------------------
*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING EB.Browser
    $USING AC.API
    $USING PZ.ModelBank
    $USING AC.ModelBank
    $USING ST.Customer
    $USING ST.Config
    $USING EB.DataAccess
    $USING IN.IbanAPI
    $USING PI.Contract
    $USING EB.API
*** </region>

*-----------------------------------------------------------------------------

*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    GOSUB initialise ;* Initialise the required values
    GOSUB process ;* Main process

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initialise the required values </desc>

    stmtEntryId = EB.Reports.getOData()
    stmtEntryRec = EB.Reports.getRRecord()
    txnReference = stmtEntryRec<AC.EntryCreation.StmtEntry.SteTransReference>[";",1,1]
    outNarrative = ""
    remittanceInformationStructured = ''
    currentSkipToken = PZ.ModelBank.getSkipToken()
    IF currentSkipToken THEN
        PZ.ModelBank.setSkipToken("")
    END
    
    LOCATE "ACCT.ID" IN EB.Reports.getDFields()<1> SETTING accountIdPos THEN
        AccountId = EB.Reports.getDRangeAndValue()<accountIdPos>
    END
    
    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING bookingDatePos THEN
        bookingDate = EB.Reports.getDRangeAndValue()<bookingDatePos>
    END

    outValue = ""

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> Main process </desc>

    GOSUB getIBANFromAccount ;* To obtain the IBAN Id from the account ID provided
    GOSUB determineTxnDetails ;* To determine the transaction details and beneficiary details of the underlying transaction
    GOSUB getClosingBalance ;* To determine the closing Balance
    GOSUB amountInAccCurrency ;* To determine the debit amount of a transaction
    GOSUB CheckTime ;* To determine the API execution time
    GOSUB getDebtorCreditorDetails
    GOSUB getExchangeCurrency ;* To determine exchange currency
    GOSUB getRemittanceInfo ;* To get the remittance Information
    GOSUB formOutputArray ;* To form the output array

* To avoid conflicts with the delimiters which are used as a part of record Id's
* in T24, the delimiter used to seperate the values in the output array
* is made unique - changed from "*" to "^~^"
    CHANGE @FM TO "^~^" IN outValue

* the values in the output array is seperated by "^~^"
    EB.Reports.setOData(outValue)

RETURN

*-----------------------------------------------------------------------------

*** <region name= CheckTime>
CheckTime:
*** <desc> To determine the API execution time </desc>

    ApiDateTime = ""
    ApiDate = OCONV(LOCALDATE(TIMESTAMP(),'UTC'),'D4-')
    ApiTime = OCONV(LOCALTIME(TIMESTAMP(),'UTC'),'MTS')
    ApiDateTime = ApiDate['-',3,1]:'-': ApiDate['-',1,1]:'-': ApiDate['-',2,1]:'T': ApiTime    ;* date time separated by '-'
 
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getIBANFromAccount>
getIBANFromAccount:
*** <desc> To obtain the IBAN Id from the account ID provided </desc>

    iBan = ""
    rAccount = ""
    errAccount = ""
    rAccount = AC.AccountOpening.Account.Read(AccountId,errAccount)  ;* Get the account record
    IF NOT(rAccount) THEN
        F.ACCOUNT$HIS = ''
        rAccount = ''
        errAccount = ''
        EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
        EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS,AccountId,rAccount, errAccount)
        AccountId = FIELD(AccountId ,';' ,1)
    END
    IN.IbanAPI.IbanserviceGetiban(AccountId, rAccount, iBan, ErrorCode)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getClosingBalance>
getClosingBalance:
*** <desc> To determine the closing Balance </desc>

* only the closing balance of the first entry will be determined.
* Balance for the remaining entries will be determined in the enquiry.
    
    CHANGE @SM TO @FM IN bookingDate
    balanceDate = bookingDate<2>
    accountBalance = ""
    outError = ""

* API called to determine the closing balance
    AC.API.EbGetAcctBalance(AccountId, "", "BOOKING", balanceDate, "", accountBalance, "", "", outError)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= determineTxnDetails>
determineTxnDetails:
*** <desc> To determine the transaction details and beneficiary details of the underlying transaction </desc>

* This API will inturn invoke the API's attached to STMT.ENTRY record
* attached to the STMT.NARR.FORMAT record.

    txnDetails = ""
    summaryOpt = PZ.ModelBank.getSummaryOption()
    IF summaryOpt NE 'D' THEN
        LOCATE "SUM.OR.DETAIL" IN EB.Reports.getDFields()<1> SETTING summaryPos THEN ;*If it is given in fixed selection
            summaryOpt = EB.Reports.getDRangeAndValue()<summaryPos>
            PZ.ModelBank.setSummaryOption(summaryOpt)
        END
    END
    
    PZ.ModelBank.ePzTxnHistNarrative(stmtEntryId, stmtEntryRec, txnDetails)
    

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= formOutputArray>
formOutputArray:
*** <desc> To form the output array </desc>

    outValue<-1> = PZ.ModelBank.getAccountReference()                           ;* Account reference as defined in the enquiry selection
    outValue<-1> = AccountId                                                    ;* Account Id
    outValue<-1> = iBan                                                         ;* IBAN specific to the account
    outValue<-1> = stmtEntryRec<AC.EntryCreation.StmtEntry.SteBookingDate>      ;* Booking date of the transaction
    outValue<-1> = stmtEntryRec<AC.EntryCreation.StmtEntry.SteValueDate>        ;* Value date of the transaction
    outValue<-1> = txnCode                                                      ;* Transaction code -  Transaction Type
    outValue<-1> = stmtEntryRec<AC.EntryCreation.StmtEntry.SteCurrency>         ;* Account Currency
    outValue<-1> = txnDetails<1>                                                ;* Transaction currency
    outValue<-1> = stmtEntryRec<AC.EntryCreation.StmtEntry.SteExchangeRate>     ;* Exchange rate
    outValue<-1> = amtAcctCcy                                                   ;* Amount in account currency
    outValue<-1> = txnDetails<2>                                                ;* Amount in transaction currency
    outValue<-1> = txnDetails<3>                                                ;* Payee Account Identification
    outValue<-1> = txnDetails<4>                                                ;* Payee Identification
    outValue<-1> = stmtEntryRec<AC.EntryCreation.StmtEntry.SteTransReference>   ;* Transaction reference
    outValue<-1> = accountBalance                                               ;* Closing Balance of the first entry. Balance for the remaining entries are determined in the enquiry
    outValue<-1> = ApiDateTime                                                  ;* Date and Time of API execution (enquiry execution)
    outValue<-1> = currentSkipToken                                             ;*skip token
    outValue<-1> = txnDetails<5>                                                ;*credit account
    outValue<-1> = txnDetails<6>                                                ;*credit customer
    outValue<-1> = remittanceInformationStructured                              ;*remittance information
    outValue<-1> = drCrindicator                                                ;*debit credit indicator
    outValue<-1> = debitCurrency
    outValue<-1> = creditCurrency

RETURN
*** </region>
getDebtorCreditorDetails:


    txnCode = stmtEntryRec<AC.EntryCreation.StmtEntry.SteTransactionCode>
    txnError = ''
    transactionRecord = ''
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
    drCrindicator = debitCreditInd ;*This value is the indicator of the transaction
    
;*Check for reversal marker and reverse the entries accordingly
    reversalMarker = stmtEntryRec<AC.EntryCreation.StmtEntry.SteReversalMarker>
    IF reversalMarker THEN
        IF debitCreditInd = "DEBIT" THEN
            debitCreditInd = "CREDIT"
        END ELSE
            debitCreditInd = "DEBIT"
        END
    END
    
;*if values are not obtained from stmt.narrative. i.e., from routine ePzTxnHistNarrative
    IF txnDetails = '' THEN
        stmtCusNum = stmtEntryRec<AC.EntryCreation.StmtEntry.SteCustomerId>
        CustomerRec = ST.Customer.Customer.Read(stmtCusNum, cusError)
        BEGIN CASE
            CASE debitCreditInd = "DEBIT" ;*populate debit details in case of debit entry
                txnDetails<5> = AccountId ;*debit account
                txnDetails<6> = CustomerRec<ST.Customer.Customer.EbCusNameOne> ;*debit customer
            CASE debitCreditInd = "CREDIT" ;*populate credit details in case of credit entry
                txnDetails<3> = AccountId ;*credit account
                txnDetails<4> = CustomerRec<ST.Customer.Customer.EbCusNameOne> ;*credit customer
        END CASE
    END
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= amountInAccCurrency>
amountInAccCurrency:
*** <desc> To determine the debit amount of a transaction </desc>

* Amount in account currency is determined based on the local currency
* and account currency
    localCcy = EB.SystemTables.getLccy()
    acctCcy = stmtEntryRec<AC.EntryCreation.StmtEntry.SteCurrency>

    IF localCcy EQ acctCcy THEN
        amtAcctCcy = stmtEntryRec<AC.EntryCreation.StmtEntry.SteAmountLcy>
    END ELSE
        amtAcctCcy = stmtEntryRec<AC.EntryCreation.StmtEntry.SteAmountFcy>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
getExchangeCurrency:
** Get the currency of the other leg of stmt entry

;*check if the currency of the existing entry is debit or credit
    currency = stmtEntryRec<AC.EntryCreation.StmtEntry.SteCurrency>
    creditCurrency = ""
    IF debitCreditInd = "CREDIT" THEN
        creditCurrency = currency
    END ELSE
        debitCurrency = currency
    END

;* Read the other leg of stmt entry
    stmtNos = stmtEntryRec<AC.EntryCreation.StmtEntry.SteStmtNo,2>
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
        otherLegEntry = FIELD(stmtEntryId,".",1):'.':stmtEntryPart ;* Form the other leg id
        otherStmtRec = AC.EntryCreation.StmtEntry.Read(otherLegEntry,errStmt)
;* Get the currency of the other leg
        IF creditCurrency THEN
            debitCurrency =  otherStmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
        END ELSE
            creditCurrency = otherStmtRec<AC.EntryCreation.StmtEntry.SteCurrency>
        END
    END

RETURN
*-----------------------------------------------------------------------------
getRemittanceInfo:

    PPInstalled = ""
    EB.API.ProductIsInCompany("PP",PPInstalled) ;* check if PP product is installed
    IF NOT(PPInstalled) THEN ;* donot fetch values if PP not installed
        RETURN
    END

* For now only remittance Info is returned for PO requests
    systemId = stmtEntryRec<AC.EntryCreation.StmtEntry.SteSystemId>
    IF systemId EQ 'PP' THEN  ;* if the request is for PO
        PoRec = ""
        PoErr = ""
        PoId = stmtEntryRec<AC.EntryCreation.StmtEntry.SteTheirReference> ;* get PAYMENT.ORDER Id
        PoRec = PI.Contract.PaymentOrder.Read(PoId, PoErr) ;* get PAYMENT.ORDER record
        IF NOT(PoRec) THEN ;* check for history record if LIVE record is missing
            FN.PAYMENT.ORDER.HIS = "F.PAYMENT.ORDER$HIS"
            F.PAYMENT.ORDER.HIS = ""
            EB.DataAccess.Opf(FN.PAYMENT.ORDER.HIS, F.PAYMENT.ORDER.HIS)
            PoIdHis = PoId
            PoErr = ""
            EB.DataAccess.ReadHistoryRec(F.PAYMENT.ORDER.HIS, PoIdHis, PoRec, PoErr)
        END
        remittanceInformationStructured = PoRec<PI.Contract.PaymentOrder.PoRemittanceInformation>
    END

RETURN
*-----------------------------------------------------------------------------
END
