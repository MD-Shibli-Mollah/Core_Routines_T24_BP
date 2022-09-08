* @ValidationCode : MjotMTI0OTc2NzE5OmNwMTI1MjoxNTkxMzM2MzIzNDQxOnZyYWphbGFrc2htaTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA1LjIwMjAwNTA1LTA0MjY6NjE6NjA=
* @ValidationInfo : Timestamp         : 05 Jun 2020 11:22:03
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : vrajalakshmi
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 60/61 (98.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200505-0426
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.GET.ACC.SINGLE.TXN(AccData)
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*New NOFILE enquiry routine to return values for single transaction enquiry.
*-----------------------------------------------------------------------------
* Modification History :
* 1/2/19 - Enhancement 2741274 / Task 2948253
*          New routine introduced to return statement entry and FT Details.
*
* 29/08/19 - Task 3312891
*            Return the currency details of the transaction
*
* 04/06/2020 - Defect 3780928 / Task 3782848
*              Fix to display credit IBAN and debit IBAN separately in enquiry output
*-----------------------------------------------------------------------------
*
*In/OutParam:
*=========
*AccData         -   Input/Output for the enquiry
*
*-----------------------------------------------------------------------------
*  <region name= Inserts>
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

* </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>Program control</desc>
*
;*product installation check
    products = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)
    LOCATE 'AC' IN products<1,1> SETTING pos ELSE
        EB.SystemTables.setEtext('')
        EnqError = "PZ-PRODUCT.AC.NOT.INSTALLED"        ;* EB.ERROR record
        EB.Reports.setEnqError(EnqError)                ;* If AC product not installed set error
        RETURN
    END

    GOSUB Initialise                                ;* Initialise the variables
    GOSUB fetchValues                               ;*Fetch values from GET.STMT.ENT.DETS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:

    txnPos = ''
    acPos = ''
    stmtdets = ''
    bankTransactionCode=''

;* Get the transaction ID
    LOCATE 'TRANSACTION.ID' IN EB.Reports.getDFields()<1> SETTING txnPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        transactionId = EB.Reports.getDRangeAndValue()<txnPos>                           ;* Get the account id using the position
    END

;* Get the Account ID
    LOCATE 'ACCOUNT.ID' IN EB.Reports.getDFields()<1> SETTING acPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        accountId = EB.Reports.getDRangeAndValue()<acPos>                           ;* Get the account id using the position
    END

RETURN
*-----------------------------------------------------------------------------

fetchValues:

    PZ.ModelBank.getStmtEntDets(transactionId, stmtdets) ;*call routine to fetch values from stmt entry
    returnedError = EB.Reports.getEnqError() ;*Invalid transaction ID
    IF returnedError THEN
        RETURN
    END
    accId = stmtdets<1>
    IF accountId AND accountId NE accId THEN ;* If Account does not belong to stmt entry, set error
        EB.SystemTables.setEtext('')
        EnqError = "PZ-ACCOUNT.DOES.NOT.BELONG.TO.ENTRY"    ;* EB.ERROR record
        EB.Reports.setEnqError(EnqError)
        RETURN    ;*return if account does not match
    END
    iBan = stmtdets<2>
    ultimateCreditor = stmtdets<4>
    ultimateDebtor = stmtdets<6>
    amountInLcy = stmtdets<7>
    entryRef = stmtdets<8>
    chequeId = stmtdets<9>
    bookingDate = stmtdets<10>
    valueDate = stmtdets<11>
    exchangeRate = stmtdets<12>
    txnCode= stmtdets<13>
    accountCcy = stmtdets<14>
    transactionAmt = stmtdets<15>
    remittanceInformationUnstructured = stmtdets<16>
    endToEndId = stmtdets<17>
    mandateId = stmtdets<18>
    creditorId = stmtdets<19>
    remittanceInformationStructured = stmtdets<20>
    creditAccount = stmtdets<21>
    creditorName = stmtdets<22>
    debtorName = stmtdets<23>
    debtorAccount = stmtdets<24>
    creditCcy = stmtdets<25>
    purposeCode = stmtdets<26>
    debitCurrency = stmtdets<28>
    creditCurrency = stmtdets<29>
    creditIban = stmtdets<30>

    AccData = accId:'*':iBan:'*':transactionId:'*':entryRef:'*':endToEndId:'*':mandateId:'*':chequeId:'*':creditorId:'*':bookingDate:'*':valueDate:'*':accountCcy:'*':creditCcy:'*':exchangeRate:'*':amountInLcy:'*':transactionAmt:'*':creditorName:'*':creditAccount:'*':ultimateCreditor:'*':debtorName:'*':debtorAccount:'*':ultimateDebtor:'*':remittanceInformationUnstructured:'*':remittanceInformationStructured:'*':purposeCode:'*':bankTransactionCode:'*':txnCode:'*':debitCurrency:'*':creditCurrency:'*':creditIban    ;* Form the enquiry output

RETURN
*-----------------------------------------------------------------------------

*** </region>

END
