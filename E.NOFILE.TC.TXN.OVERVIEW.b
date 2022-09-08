* @ValidationCode : MjoxOTY2MzgwMzQ5OkNwMTI1MjoxNjAxMjkyNzI3NzAxOnNtdWdlc2g6MTI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMDoyOTA6Mjc0
* @ValidationInfo : Timestamp         : 28 Sep 2020 17:02:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 12
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : 393
* @ValidationInfo : Coverage          : 274/290 (94.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AC.Channels
SUBROUTINE E.NOFILE.TC.TXN.OVERVIEW(TXN.ARR)
*-----------------------------------------------------------------------------
* Description
*------------
* This routine used to display the transactions details along with the payment details of the particular transaction.
* Payment details are retrieved from the applications such as POA, FT, PAYMENT.STOP, TELLER, DIRECT.DEBITS, FOREX and cheque collection
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TC.TXNS.OVERVIEW, ENQUIRY>TC.NOF.TXN.OVERVIEW
* IN Parameters      : Statement reference
* Out Parameters     : TXN.ARR(StmtId,BookingDate,Narrative,StmtCurrency,ExposureDate,ValueDate,TransReference,TransDesc,DebitAccountCurrency,CreditAccountCurrency,BaseCurrency,AmountDebited,AmountCredited,ChargeType,ChargeAmount,DebitValueDate,CreditValueDate,AuthorisationDate,ProcessingDate,DebitAccountNumber,CreditAccountNubmer,IbanDebit,IbanCredit,IbanBeneficiary,BeneficiaryAccountNumber,BeneficiaryCustomer,BeneficiaryBank,ChequeNumber,ChequeDrawn,DrawnAccount and CustomerRate)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*-------------------------
* 26/05/16 - Enhancement - 1648966 / Task - 1843348
*            TCIB Retail : Transactions Detail (Recent Transaction )
*
* 14/05/18 - Defect - 2892749/ Task - 2903778
*            The enquiry TC.NOF.TXNS.OVERVIEW is not returning the all values if the FT record is moved to history.
*
* 20/03/19 - Defect - 3034138 / Task - 3044426
*          - IRIS service enqTcNofTxnsList causing java.text.ParseException: Unparseable date error
*
* 01/10/19 - Defect - 3367195 / Task - 3367522
*          - CQ product installation check.
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING AC.ModelBank
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING EB.Security
    $USING ST.CompanyCreation
    $USING FT.Contract
    $USING FT.Config
    $USING AC.StandingOrders
    $USING PI.Contract
    $USING PI.Config
    $USING PP.PaymentWorkflowDASService
    $USING DD.Contract
    $USING FX.Contract
    $USING FX.Config
    $USING TT.Contract
    $USING TT.Config
    $USING CQ.ChqPaymentStop
    $USING CQ.ChqSubmit
    $USING EB.DataAccess
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB GET.INPUTS
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*----------

    TransactionType =''; DebitAccountCurrency = ''; CreditAccountCurrency = ''; BaseCurrency = '';AmountDebited = '';
    AmountCredited = ''; ChargeType = ''; ChargeAmount = ''; DebitValueDate = ''; CreditValueDate = ''; AuthorisationDate = '';
    ProcessingDate = ''; DebitAccountNumber = ''; CreditAccountNubmer = ''; IbanDebit = ''; IbanCredit = ''; IbanBeneficiary = '';
    BeneficiaryAccountNumber = ''; BeneficiaryCustomer = ''; BeneficiaryBank = ''; ChequeNumber = ''; ChequeDrawn = '';
    DrawnAccount = ''; CustomerRate = ''; StmtId = '';Yerror='';  ExtLang = ''
    
    CQInstalled = ''
    EB.API.ProductIsInCompany('CQ', CQInstalled)   ;* Checks if CQ product is installed

RETURN
*------------------------------------------------------------------------------
*** <region name= GET.INPUTS>
*** <desc>Get the input parameters from the enquiry selection</desc>
GET.INPUTS:

    LOCATE 'STMT.ID' IN EB.Reports.getDFields()<1> SETTING AC.POS THEN  ;*To get the statement entry Id
        StmtId = EB.Reports.getDRangeAndValue()<AC.POS>
    END

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get the transaction and payment details</desc>
PROCESS:
*-------

    StmtRec = ''; BookingDate = ''; Narrative = '';  AmtLcy = ''; AmtFcy = ''; StmtAmount = ''; StmtCurrency = ''; ErrStmt = '';
    StmtAccount = ''; AccRec = ''; AcctTitle = ''; CompBranchCode = ''; ErrAcct = ''; ExposureDate = ''; TransReference = ''; ValueDate = '';
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN                                                       ;* If External User Language is not available
        ExtLang =1                                                              ;* Assigning Default Language position to read language multi value fields
    END
    StmtRec = AC.EntryCreation.StmtEntry.Read(StmtId,ErrStmt)      ;* To read statement entry Id
    IF StmtRec NE '' THEN
        BookingDate= StmtRec<AC.EntryCreation.StmtEntry.SteBookingDate>   ;* To get booking date
        Narrative = StmtRec<AC.EntryCreation.StmtEntry.SteNarrative,1>      ;*To get the narrative value
        StmtCurrency = StmtRec<AC.EntryCreation.StmtEntry.SteCurrency>      ;*To get the statemnet currency
        ExposureDate = StmtRec<AC.EntryCreation.StmtEntry.SteExposureDate> ;*To read exposure date
        ValueDate = StmtRec<AC.EntryCreation.StmtEntry.SteValueDate>        ;*To get the value date
        SystemId = StmtRec<AC.EntryCreation.StmtEntry.SteSystemId>          ;*To get the System Id
        TransReference = StmtRec<AC.EntryCreation.StmtEntry.SteTransReference>  ;*To get the payment reference
        GOSUB GET.PAYMENT.DETAILS       ;*To get the payment details of the transaction
        TXN.ARR = StmtId:"*":BookingDate:"*":Narrative:"*":StmtCurrency:"*":ExposureDate:"*":ValueDate:"*":TransReference:"*":TransDesc:"*":DebitAccountCurrency:"*":CreditAccountCurrency:"*":BaseCurrency:"*":AmountDebited:"*":AmountCredited:"*":ChargeType:"*":ChargeAmount:"*":DebitValueDate:"*":CreditValueDate:"*":AuthorisationDate:"*":ProcessingDate:"*":DebitAccountNumber:"*":CreditAccountNubmer:"*":IbanDebit:"*":IbanCredit:"*":IbanBeneficiary:"*":BeneficiaryAccountNumber:"*":BeneficiaryCustomer:"*":BeneficiaryBank:"*":ChequeNumber:"*":ChequeDrawn:"*":DrawnAccount:"*":CustomerRate
    END

RETURN
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= GET.PAYMENT.DETAILS>
*** <desc>Initialise variables used in this routine</desc>
GET.PAYMENT.DETAILS:
*-------------------

    BEGIN CASE
        CASE SystemId EQ 'PP'           ;*Case for Payment order
            GOSUB PAYMENT.ORDER
        CASE SystemId EQ 'FT' AND (TransReference[1,2] EQ 'FT')     ;*Case for Funds transfer
            GOSUB FUNDS.TRANSFER
        CASE SystemId EQ 'FT' AND (TransReference[1,2] NE 'FT')     ;*Case for standing order
            GOSUB STANDING.ORDER
        CASE SystemId EQ 'DD'               ;*Case for Direct debits
            GOSUB DIRECT.DEBITS
        CASE SystemId EQ 'FX'               ;*Case for Forex
            GOSUB FOREX
        CASE SystemId EQ 'TT'               ;*Case for Teller
            GOSUB TELLER
        CASE SystemId EQ 'PS'               ;*Case for payment stop
            IF CQInstalled THEN
                GOSUB PAYMENT.STOP
            END
        CASE SystemId EQ 'CC'               ;*Case for cheque collection
            IF CQInstalled THEN
                GOSUB CHEQUE.COLLECTION
            END
    END CASE

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= PAYMENT.ORDER>
*** <desc>To get the Payment details of payment order for the transaction</desc>
PAYMENT.ORDER:
*--------------
    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = ''; RPorTransaction = ''; PoaReference = ''; iPaymentID = ''
*
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = TransReference
    iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = EB.SystemTables.getIdCompany()
    RPorTransaction = PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    PoaReference = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.fileSendersReference>      ;*Get the poa reference
*
    PaymentRec = PI.Contract.PaymentOrder.Read(PoaReference, PayError)
    
    IF PaymentRec EQ "" THEN ;* If the record is not found in the Live file
        FN.FileName= 'F.PAYMENT.ORDER$HIS'
        F.FileName = ''
        EB.DataAccess.Opf(FN.FileName,F.FileName) ;* Opening the History file
        MatId = PoaReference ;* After ReadHistory call MatID will have the ID of the record in History file.
        EB.DataAccess.ReadHistoryRec(F.FileName,MatId,PaymentRec, Yerror) ;* Reading the record from History file
    END
    
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<PI.Contract.PaymentOrder.PoPaymentOrderProduct>    ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<PI.Contract.PaymentOrder.PoDebitCcy>      ;*Get the Debit currency
        CreditAccountCurrency = PaymentRec<PI.Contract.PaymentOrder.PoPaymentCurrency>  ;*Get the credit currency
        BaseCurrency = PaymentRec<PI.Contract.PaymentOrder.PoDebitCcy>                  ;*Get the base currency
        AmountDebited = PaymentRec<PI.Contract.PaymentOrder.PoPaymentAmount>            ;*Get the debit amount
        ChargeType = PaymentRec<PI.Contract.PaymentOrder.PoChargeBearer>                ;*Get the charge type
        DebitValueDate = PaymentRec<PI.Contract.PaymentOrder.PoDebitValueDate>          ;*Get the Debit value date
        CreditValueDate = PaymentRec<PI.Contract.PaymentOrder.PoPaymentExecutionDate>    ;*Get the Credit value date
        DebitAccountNumber = PaymentRec<PI.Contract.PaymentOrder.PoDebitAccount>            ;*Get the debit account number
        CreditAccountNubmer = PaymentRec<PI.Contract.PaymentOrder.PoCreditAccount>          ;*Get the credit account number
        IbanBeneficiary = PaymentRec<PI.Contract.PaymentOrder.PoBeneficiaryIban>            ;*Get the Iban number
        BeneficiaryAccountNumber = PaymentRec<PI.Contract.PaymentOrder.PoBeneficiaryAccountNo>  ;*Get the beneficiary account no
        BeneficiaryCustomer = PaymentRec<PI.Contract.PaymentOrder.PoBeneficiaryCustomer>        ;*Get the beneficiary customer
        CustomerRate = PaymentRec<PI.Contract.PaymentOrder.PoIndicativeRate>                    ;*Get the indicative rate
    END

    IF TransactionType THEN
        TransRec = PI.Config.PaymentOrderProduct.Read(TransactionType, TxnError)    ;*Read the payment order product
        BEGIN CASE
            CASE TransRec EQ ''                                                             ;* If Transaction Record is Null Do Nothing
            CASE TransRec<PI.Config.PaymentOrderProduct.PopDescription, ExtLang>  NE ''     ;* Check if description is present in the External User Language
                TransDesc = TransRec<PI.Config.PaymentOrderProduct.PopDescription, ExtLang> ;* Read the description in the External User Language
            CASE 1                                                                          ;* If Description is not available in the External User Preferred Language
                TransDesc = TransRec<PI.Config.PaymentOrderProduct.PopDescription, 1>       ;* Read the Description in the default language.
        END CASE
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= STANDING.ORDER>
*** <desc>To get the Payment details of Standing order for the transaction</desc>
STANDING.ORDER:
*--------------

    PaymentRec = ''; PayError = '';

    PaymentRec = AC.StandingOrders.StandingOrder.Read(TransReference, PayError)
    
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<AC.StandingOrders.StandingOrder.StoPayMethod>  ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<AC.StandingOrders.StandingOrder.StoCurrency>  ;*Get the Debit currency
        BaseCurrency = PaymentRec<AC.StandingOrders.StandingOrder.StoBaseCurrency>      ;*Get the base currency
        AmountDebited = PaymentRec<AC.StandingOrders.StandingOrder.StoCurrentAmountBal>  ;*Get the debit amount
        ChargeType = PaymentRec<AC.StandingOrders.StandingOrder.StoChargeType>              ;*Get the charge type
        DebitValueDate = PaymentRec<AC.StandingOrders.StandingOrder.StoCurrentFrequency>     ;*Get the Debit value date
        DebitAccountNumber = FIELD(TransReference,'.',1)                    ;*Get the debit account number
        CreditAccountNubmer = PaymentRec<AC.StandingOrders.StandingOrder.StoCptyAcctNo>     ;*Get the credit account number
        IbanBeneficiary = PaymentRec<AC.StandingOrders.StandingOrder.StoIbanBen>        ;*Get the Iban number
        BeneficiaryAccountNumber = PaymentRec<AC.StandingOrders.StandingOrder.StoBenAcctNo>     ;*Get the beneficiary account no
        BeneficiaryCustomer = PaymentRec<AC.StandingOrders.StandingOrder.StoBeneficiary>        ;*Get the beneficiary customer
        BeneficiaryBank = PaymentRec<AC.StandingOrders.StandingOrder.StoBenBank>            ;*Get the beneficiary bank
    END
*
    GOSUB TRANSACTION.DESC

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= TRANSACTION.DESC>
*** <desc>To get the transaction description from FT.TXN.TYPE.CONDITION</desc>
TRANSACTION.DESC:
*------------------
    TxnError = ''; TransRec = ''; TransDesc = '';

    IF TransactionType THEN
        TransRec = FT.Config.TxnTypeCondition.Read(TransactionType, TxnError)   ;*Read the FT.TXN.TYPE.CONDITION
        BEGIN CASE
            CASE TransRec EQ ''                                                             ;* If Transaction Record is Null Do Nothing
            CASE TransRec<FT.Config.TxnTypeCondition.FtSixDescription, ExtLang>  NE ''      ;* Check if description is present in the External User Language
                TransDesc = TransRec<FT.Config.TxnTypeCondition.FtSixDescription, ExtLang>  ;* Read the description in the External User Language
            CASE 1                                                                          ;* If Description is not available in the External User Preferred Language
                TransDesc = TransRec<FT.Config.TxnTypeCondition.FtSixDescription, 1>        ;* Read the Description in the default language.
        END CASE
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= FUNDS.TRANSFER>
*** <desc>To get the Payment details of Funds transfer for the transaction</desc>
FUNDS.TRANSFER:
*---------------

    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = '';

    PaymentRec = FT.Contract.FundsTransfer.Read(TransReference, PayError)

    IF PaymentRec EQ "" THEN ;* If the PaymentRec is not found in Live file
        FN.FileName= 'F.FUNDS.TRANSFER$HIS'
        F.FileName = ''
        EB.DataAccess.Opf(FN.FileName,F.FileName)   ;* Open History file
        MatId = TransReference ;* After ReadHistory call MatID will have the ID of the record in History file.
        EB.DataAccess.ReadHistoryRec(F.FileName,MatId, PaymentRec, Yerror) ;* Reading the record from History file
    END
    
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<FT.Contract.FundsTransfer.TransactionType>         ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<FT.Contract.FundsTransfer.DebitCurrency>          ;*Get the Debit currency
        CreditAccountCurrency = PaymentRec<FT.Contract.FundsTransfer.CreditCurrency>        ;*Get the credit currency
        BaseCurrency = PaymentRec<FT.Contract.FundsTransfer.BaseCurrency>               ;*Get the base currency
        AmountDebited = PaymentRec<FT.Contract.FundsTransfer.AmountDebited>             ;*Get the debit amount
        AmountCredited = PaymentRec<FT.Contract.FundsTransfer.AmountCredited>           ;*Get the credit amount
        ChargeType = PaymentRec<FT.Contract.FundsTransfer.ChargeType>                   ;*Get the charge type
        ChargeAmount = PaymentRec<FT.Contract.FundsTransfer.ChargeAmt>                  ;*Get the charge amount
        DebitValueDate = PaymentRec<FT.Contract.FundsTransfer.DebitValueDate>           ;*Get the debit value date
        CreditValueDate = PaymentRec<FT.Contract.FundsTransfer.CreditValueDate>         ;*Get the credit value date
        AuthorisationDate = PaymentRec<FT.Contract.FundsTransfer.AuthDate>              ;*Get the authorisation date
        ProcessingDate = PaymentRec<FT.Contract.FundsTransfer.ProcessingDate>           ;*Get the processing date
        DebitAccountNumber = PaymentRec<FT.Contract.FundsTransfer.DebitAcctNo>          ;*Get the debit account no
        CreditAccountNubmer = PaymentRec<FT.Contract.FundsTransfer.CreditAcctNo>        ;*Get the credit account no
        IbanDebit = PaymentRec<FT.Contract.FundsTransfer.IbanDebit>                     ;*Get the IBAN debit
        IbanCredit = PaymentRec<FT.Contract.FundsTransfer.IbanCredit>                   ;*Get the IBAN credit
        IbanBeneficiary = PaymentRec<FT.Contract.FundsTransfer.IbanBen>                 ;*Get the IBAN ben
        BeneficiaryAccountNumber = PaymentRec<FT.Contract.FundsTransfer.BenAcctNo>      ;*Get the beneficiary account no
        BeneficiaryCustomer = PaymentRec<FT.Contract.FundsTransfer.BenCustomer>     ;*Get the beneficiary customer
        BeneficiaryBank = PaymentRec<FT.Contract.FundsTransfer.BenBank>             ;*Get the beneficiary bank
        ChequeNumber = PaymentRec<FT.Contract.FundsTransfer.ChequeNumber>           ;*Get the cheque number
        ChequeDrawn = PaymentRec<FT.Contract.FundsTransfer.ChequeDrawn>             ;*Get the cheque drawn
        DrawnAccount = PaymentRec<FT.Contract.FundsTransfer.DrawnAccount>           ;*Get the drawn account
        CustomerRate = PaymentRec<FT.Contract.FundsTransfer.CustomerRate>           ;*Get the customer rate
    END
*
    GOSUB TRANSACTION.DESC

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= DIRECT.DEBITS>
*** <desc>To get the Payment details of Direct Debits for the transaction</desc>
DIRECT.DEBITS:
*--------------

    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = ''; DDTransReference = ''
    DDTransReference = TRIM(TransReference, "D", "L")
    PaymentRec = DD.Contract.Ddi.Read(DDTransReference, PayError)             ;*Read Direct debits
    
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<DD.Contract.Ddi.DdiDirection>          ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<DD.Contract.Ddi.DdiCurrency>      ;*Get the Debit currency
        BaseCurrency = PaymentRec<DD.Contract.Ddi.DdiCurrency>              ;*Get the base currency
        AmountCredited = PaymentRec<DD.Contract.Ddi.DdiStandAloneAmt>       ;*Get the credit amount
        DebitValueDate = PaymentRec<DD.Contract.Ddi.DdiStatusDate>          ;*Get the debit value date
        DebitAccountNumber = FIELD(TransReference,".",1)                    ;*Get the debit account no
        CreditAccountNubmer = PaymentRec<DD.Contract.Ddi.DdiDestAcctNo>     ;*Get the credit account no
        IbanDebit = PaymentRec<DD.Contract.Ddi.DdiIbanInwardAcct>           ;*Get the IBAN debit
        IbanCredit = PaymentRec<DD.Contract.Ddi.DdiIbanDestAcct>            ;*Get the IBAN credit
        BeneficiaryAccountNumber = PaymentRec<DD.Contract.Ddi.DdiDestAcctNo>        ;*Get the beneficiary account no
        BeneficiaryCustomer = PaymentRec<DD.Contract.Ddi.DdiCustomerNo>             ;*Get the beneficiary customer
    END

    IF TransDesc EQ '' THEN
        TransDesc = TransactionType ;*Assign transaction type to transaction desc
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= FOREX>
*** <desc>To get the Payment details of Forex for the transaction</desc>
FOREX:
*-----
    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = '';

    PaymentRec = FX.Contract.Forex.Read(TransReference, PayError)           ;*Read Forex
      
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<FX.Contract.Forex.TransactionType>         ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<FX.Contract.Forex.CurrencyBought>      ;*Get the Debit currency
        CreditAccountCurrency = PaymentRec<FX.Contract.Forex.CurrencySold>       ;*Get the credit currency
        BaseCurrency = PaymentRec<FX.Contract.Forex.BaseCcy>                     ;*Get the base currency
        AmountDebited = PaymentRec<FX.Contract.Forex.AmountBought>                ;*Get the debit amount
        AmountCredited = PaymentRec<FX.Contract.Forex.AmountSold>                ;*Get the credit amount
        DebitValueDate = PaymentRec<FX.Contract.Forex.ValueDateBuy>               ;*Get the debit value date
        CreditValueDate = PaymentRec<FX.Contract.Forex.ValueDateSell>                ;*Get the credit value date
        ProcessingDate = PaymentRec<FX.Contract.Forex.DealDate>                     ;*Get the processing date
        DebitAccountNumber = PaymentRec<FX.Contract.Forex.OurAccountPay>            ;*Get the debit account no
        CreditAccountNubmer = PaymentRec<FX.Contract.Forex.Counterparty>            ;*Get the credit account no
        BeneficiaryAccountNumber = PaymentRec<FX.Contract.Forex.OurAccountRec>       ;*Get the beneficiary account no
    END

    IF TransactionType THEN
        TransRec = FX.Config.TransactionType.Read(TransactionType, TxnError)   ;*Read the FX.TRANSACTION.TYPE
        BEGIN CASE
            CASE TransRec EQ ''                                                         ;* If Transaction Record is Null Do Nothing
            CASE TransRec<FX.Config.TransactionType.TtDescription, ExtLang>   NE ''     ;* Check if description is present in the External User Language
                TransDesc = TransRec<FX.Config.TransactionType.TtDescription, ExtLang>  ;* Read the description in the External User Language
            CASE 1                                                                      ;* If Description is not available in the External User Preferred Language
                TransDesc = TransRec<FX.Config.TransactionType.TtDescription, 1>        ;* Read the Description in the default language.
        END CASE
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= TELLER>
*** <desc>To get the Payment details of Teller for the transaction</desc>
TELLER:
*------

    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = '';

    PaymentRec = TT.Contract.Teller.Read(TransReference, PayError)      ;*Read Teller
    
    IF PaymentRec EQ "" THEN ;* If the record is not in Live file
        FN.FileName= 'F.TELLER$HIS'
        F.FileName = ''
        EB.DataAccess.Opf(FN.FileName,F.FileName)  ;* Opening the history file
        MatId = TransReference ;* After ReadHistory call MatID will have the ID of the record in History file.
        EB.DataAccess.ReadHistoryRec(F.FileName,MatId,PaymentRec, Yerror) ;* Reading the record from History file
    END
    
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<TT.Contract.Teller.TeTransactionCode>          ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<TT.Contract.Teller.TeCurrencyOne>         ;*Get the Debit currency
        BaseCurrency = PaymentRec<TT.Contract.Teller.TeCurrencyOne>                 ;*Get the base currency
        AmountDebited = PaymentRec<TT.Contract.Teller.TeAmountLocalOne>             ;*Get the debit amount
        AmountCredited = PaymentRec<TT.Contract.Teller.TeNetAmount>                 ;*Get the credit amount
        DebitValueDate = PaymentRec<TT.Contract.Teller.TeValueDateOne>              ;*Get the debit value date
        CreditValueDate = PaymentRec<TT.Contract.Teller.TeExposureDateOne>           ;*Get the credit value date
        AuthorisationDate = PaymentRec<TT.Contract.Teller.TeAuthDate>                ;*Get the authorisation date
        DebitAccountNumber = PaymentRec<TT.Contract.Teller.TeAccountOne>            ;*Get the debit account no
    END

    IF TransactionType THEN
        TransRec = TT.Config.TellerTransaction.Read(TransactionType, TxnError)   ;*Read the TELLER.TRANSACTION
        BEGIN CASE
            CASE TransRec EQ ''                                                         ;* If Transaction Record is Null Do Nothing
            CASE TransRec<TT.Config.TellerTransaction.TrShortDesc, ExtLang> NE ''       ;* Check if description is present in the External User Language
                TransDesc = TransRec<TT.Config.TellerTransaction.TrShortDesc, ExtLang>  ;* Read the description in the External User Language
            CASE 1                                                                      ;* If Description is not available in the External User Preferred Language
                TransDesc = TransRec<TT.Config.TellerTransaction.TrShortDesc, 1>        ;* Read the Description in the default language.
        END CASE
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= PAYMENT.STOP>
*** <desc>To get the Payment details of payment stop for the transaction</desc>
PAYMENT.STOP:
*------------
    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = ''; PayStopRecId = ""; StmtNos = "";
    StmtEntryId = ""; HisId = ""; MatId = "";
    
    PayStopRecId = FIELDS(TransReference,".",2) ;* PS.AccountNumber should be split to get AccountNumber
    PaymentRec = CQ.ChqPaymentStop.PaymentStop.Read(PayStopRecId, PayError)       ;*Read Payment stop Live file
    StmtNos = FIELDS(PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayStmtNos>,".",1) ;* Getting StmtEntryNos from PaymentRec
    StmtEntryId = FIELDS(StmtId,".",1) ;* Splitting to get the first half of StmtEntry Id
        
    IF StmtEntryId NE StmtNos<1,1>THEN    ;* If they dont match it means that the corresponding PaymentStop Record has been moved to History file
        HisId =  StmtRec<AC.EntryCreation.StmtEntry.SteTheirReference> ;* Getting TheirReference from Stmt Entry record as ID of PaymentStop record in History File
        IF HisId NE "" THEN ;* Check is done to avoid passing Null value in ReadHis call
            MatId = FIELDS(HisId,".",2) ;* PS.AccountNumber;CurrNo should be split to get AccountNumber;CurrNo
            PaymentRec = CQ.ChqPaymentStop.PaymentStop.ReadHis(MatId, PayError)  ;* Reading PaymentStop record from the History file
        END
    END
       
    IF PaymentRec NE ""  THEN
        TransactionType = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayPaymStopType>            ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayCurrency>      ;*Get the Debit currency
        BaseCurrency = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayCurrency>              ;*Get the base currency
        AmountDebited = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayAmountFrom>           ;*Get the debit amount
        DebitValueDate = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayApplyDate>           ;*Get the credit value date
        CreditValueDate = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayStopDate>           ;*Get the authorisation date
        AuthorisationDate = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayRevAuthDate>      ;*Get the authorisation date
        ProcessingDate = PaymentRec<CQ.ChqPaymentStop.PaymentStop.AcPayDateOfIssue>         ;*Get the processing date
        DebitAccountNumber = FIELDS(PayStopRecId,";",1)
    END
    
    IF TransactionType THEN
        TransRec = CQ.ChqPaymentStop.PaymentStopType.Read(TransactionType, TxnError) ;* Read the Payment Stop Description
        BEGIN CASE
            CASE TransRec EQ ''                                                                    ;* If Transaction Record is Null Do Nothing
            CASE TransRec<CQ.ChqPaymentStop.PaymentStopType.AcPatDescription, ExtLang> NE ''       ;* Check if description is present in the External User Language
                TransDesc = TransRec<CQ.ChqPaymentStop.PaymentStopType.AcPatDescription, ExtLang>  ;* Read the description in the External User Language
            CASE 1                                                                                 ;* If Description is not available in the External User Preferred Language
                TransDesc = TransRec<CQ.ChqPaymentStop.PaymentStopType.AcPatDescription, 1> ;      ;* Read the Description in the default language.
        END CASE
    END
RETURN
*------------------------------------------------------------------------------------------------------------------------
*** <region name= CHEQUE.COLLECTION>
*** <desc>To get the Payment details of Cheque collection for the transaction</desc>
CHEQUE.COLLECTION:
*------------------
    PaymentRec = ''; PayError = ''; TxnError = ''; TransRec = ''; TransDesc = '';

    PaymentRec = CQ.ChqSubmit.ChequeCollection.Read(TransReference, PayError)               ;*Read Cheque collection
    
    IF PaymentRec NE '' THEN
        TransactionType = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColTxnCode>           ;*Get the transaction type
        DebitAccountCurrency = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColCurrency>     ;*Get the Debit currency
        BaseCurrency = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColCurrency>             ;*Get the base currency
        AmountDebited = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColAmount>              ;*Get the debit amount
        CreditValueDate = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColStatusDate>        ;*Get the credit value date
        ProcessingDate = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColExposureDate>       ;*Get the processing date
        CreditAccountNubmer = PaymentRec<CQ.ChqSubmit.ChequeCollection.ChqColCreditAccNo>   ;*Get the credit account no
    END

RETURN
*-------------------------------------------------------------------------------------------------------------------------
END
