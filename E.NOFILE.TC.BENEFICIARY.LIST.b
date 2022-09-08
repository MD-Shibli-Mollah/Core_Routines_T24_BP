* @ValidationCode : MjoxNDk4OTM1MTc2OkNwMTI1MjoxNjA4Mjk3MTU0MjAzOnNjaGFuZGluaToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjE6ODM6Nzk=
* @ValidationInfo : Timestamp         : 18 Dec 2020 18:42:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 79/83 (95.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*--------------------------------------------------------------------------------------------------------------------
$PACKAGE ST.Channels
SUBROUTINE E.NOFILE.TC.BENEFICIARY.LIST(FINAL.ARRAY)
*--------------------------------------------------------------------------------------------------------------------
* Description
*--------------
*
* To list the available beneficiaries beloning to that customer based on a concat file
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.BENEFICIARY using the Standard selection NOFILE.TC.BENEFICIARY
* IN Parameters      : Customer Id (CUSTOMER.NO)
* Out Parameters     : Array of beneficiary values such as Beneficiary Id, Nick name, Category, Beneificiary Account no, Beneficiary Customer, Transaction type desc,
*                      Transaction type, Sort code, Bic value, IBAN value, Link beneficiary, Beneficiary, Beneficiary customer nick name, Customer reference,
*                      Comment, Account with bank, Payment currency, Preferred payment amount, Ben our charges, Beneficiary payment country, Preferred payment amount,
*                      Preferred payment product (FINAL.ARRAY)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*
* 01/05/2018 - Defect 2572563 /Task 2591329
*               NCC payemnt with channels trasnparecy is not going through. Intoducing new field AcctWithBkSortCode.

* 10/03/2019 - Enhancement 2875480 /Task 3018252
*               IRIS-R18 T24 Changes - Adding Curr.No field
*
* 18/03/2019  - Enhancement - 2867757 / Task 3034702
*               External Beneficiary listing is handled
*
* 04/03/2020 - Enhancement 3492893 / Task 3622075
*              Add beneficiary creation date.
*
* 09/12/2020 - Defect 4098219/ Task 4123942
*              T24 Beneficiary list Issue
*
* 10/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING EB.Reports
    $USING FT.Config
    $USING ST.Channels
    $USING BY.Payments
    $USING ST.Customer

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*----------
*
    R.BENEFICIARY.DETAILS = ''; CATEGORY = ''; BENEFICIARY.ACCOUNT.NO = ''; BENEFICIARY.CUSTOMER = ''; TRANSACTION.TYPE = ''; BANK.SORT.CODE = '' ;*Initialising variables
    BIC = ''; IBAN = ''; COMMENT = ''; CUSTOMER.REFERENCE = ''; ACCOUNT.WITH.BANK = ''; PAYMENT.CURRENCY = ''; PREFERRED.PAYMENT.AMOUNT = '' ;*Initialising variable
    BEN.OUR.CHARGES = ''; BEN.PAYMENT.COUNTRY = ''; PREFERRED.PAYMENT.PRODUCT = ''; BENEFICIARY.NICK.NAME = ''; TRANSACTION.DESC = '' ;*Initialising variables
    BEN.CUSTOMER.NICK.NAME = ''; LINK.BENEFICIARY = '' ; BENEFICIARY.ID = '' ; POS = ''; R.TRANSACTION.TYPE = ''; BENEFICIARY.CURR.NO = '' ;BEN.CREATION.DATE=''; TOT.CUSTOMER.NO=''; CNT.CUST=''; CURR.CUSTOMER.NO=''; *Initialising variables

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*--------
*
    LOCATE 'CUSTOMER.NO' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
    
        CUSTOMER.NO = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    LOCATE 'EXTERNAL.BENEFICIARY' IN EB.Reports.getDFields()<1> SETTING BEN.POS THEN
        EXTERNAL.BENEFICIARY = EB.Reports.getDRangeAndValue()<BEN.POS>   ;* Get the customer value from enquiry selection.
    END
    LOCATE 'PAYMENT.SCHEME' IN EB.Reports.getDFields()<1> SETTING PAYMENT.POS THEN
        PAYMENT.SCHEME = EB.Reports.getDRangeAndValue()<PAYMENT.POS>   ;* Get the customer value from enquiry selection.
    END
    TOT.CUSTOMER.NO = DCOUNT(CUSTOMER.NO,@SM)
    FOR CNT.CUST = 1 TO TOT.CUSTOMER.NO
        CURR.CUSTOMER.NO= CUSTOMER.NO<1,1,CNT.CUST>
        R.BENEFICIARY.DETAILS = ST.Channels.TcCustomerBeneficiary.Read(CURR.CUSTOMER.NO, ERR.BEN.CONCAT) ;*Read the beneficiary concat file
        IF R.BENEFICIARY.DETAILS THEN
            GOSUB READ.BENEFICIARY.DETAILS  ;*Get the beneficiary details
        END
    NEXT CNT.CUST
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= READ.BENEFICIARY.DETAILS>
*** <desc>Get beneficiary details by reading the beneficiary record</desc>
READ.BENEFICIARY.DETAILS:
*-------------------------
*
    LOOP
        REMOVE BENEFICIARY.ID FROM R.BENEFICIARY.DETAILS SETTING POS    ;*Looping from multiple beneficiary by reading concat file
    WHILE BENEFICIARY.ID:POS
        BENEFICIARY.ID = FIELD(BENEFICIARY.ID,'.',1)    ;*Beneficiary Id
        R.BENEFICIARY = BY.Payments.Beneficiary.Read(BENEFICIARY.ID, ERR.BEN)
        IF R.BENEFICIARY THEN
            BENEFICIARY.NICK.NAME = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenNickname>   ;*Get the beneficiary nick name
            CATEGORY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCategory>    ;*Get beneficiary category value
            BENEFICIARY.ACCOUNT.NO = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenAcctNo> ;*Get beneficiary account no
            BENEFICIARY.CUSTOMER = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenCustomer> ;*Get beneficiary customer
            
            IF ISDIGIT(BENEFICIARY.CUSTOMER) THEN
                GOSUB GET.CUSTOMER.NAME
            END
            
            TRANSACTION.TYPE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType> ;*Get transaction type
            BANK.SORT.CODE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBankSortCode> ;*Get bank sort code
            BIC = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBic> ;*Get Bic code
            IBAN = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenIbanBen> ;*Get IBAN value
            COMMENT = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenDefaultNarrative> ;*Get comment value
            CUSTOMER.REFERENCE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCustomerRef> ;*Get customer reference
            ACCOUNT.WITH.BANK = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenAcctWithBank> ;*Get account with bank value
            PAYMENT.CURRENCY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenPaymentCcy> ;*Get preferred payment currency
            PREFERRED.PAYMENT.AMOUNT = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenPrefPymtAmount> ;*Get preferred payment amount
            BEN.OUR.CHARGES = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenOurCharges> ;*Get ben our charges
            BEN.CREATION.DATE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenDateTime>; *get audit date time
            BEN.PAYMENT.COUNTRY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenPymtCountry> ;*Get beneficiary payment country
            PREFERRED.PAYMENT.PRODUCT = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenPrefPymtProduct> ;*Get preferred payment product
            LINK.BENEFICIARY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenLinkToBeneficiary> ;*Get link beneficiary
            ACCT.WITH.BANK.SORT.CODE=R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenAcctWithBkSortCode> ;*Get Account with bank Sort Code
            GOSUB GET.CUSTOMER.NICK.NAME
            R.TRANSACTION.TYPE = FT.Config.TxnTypeCondition.CacheRead(TRANSACTION.TYPE, ERR.TR) ;*Read FT.TXN.TYPE.CONDITION record for the transaction type
            TRANSACTION.DESC = R.TRANSACTION.TYPE<FT.Config.TxnTypeCondition.FtSixDescription> ;*Get transaction description
            BENEFICIARY.CURR.NO = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCurrNo> ;* To get the beneficiary curr number
            IF EXTERNAL.BENEFICIARY EQ 'Y' THEN         ;* if external beneficiary flag is set and beneficiary is stored through external payment order creation
                IF PREFERRED.PAYMENT.PRODUCT EQ 'EXTERNAL' AND BENEFICIARY.CUSTOMER EQ PAYMENT.SCHEME THEN
                    FINAL.ARRAY<-1> = BENEFICIARY.ID:"*":BENEFICIARY.NICK.NAME:"*":CATEGORY:"*":BENEFICIARY.ACCOUNT.NO:"*":BENEFICIARY.CUSTOMER:"*":TRANSACTION.DESC:"*":TRANSACTION.TYPE:"*":BANK.SORT.CODE:"*":BIC:"*":IBAN:"*":LINK.BENEFICIARY:"*":BEN.CUSTOMER.NICK.NAME:"*":CUSTOMER.REFERENCE:"*":COMMENT:"*":ACCOUNT.WITH.BANK:"*":PAYMENT.CURRENCY:"*":PREFERRED.PAYMENT.AMOUNT:"*":BEN.OUR.CHARGES:"*":BEN.PAYMENT.COUNTRY:"*":PREFERRED.PAYMENT.PRODUCT:"*":ACCT.WITH.BANK.SORT.CODE:"*":BENEFICIARY.CURR.NO:"*":BEN.CREATION.DATE
                END
                
            END ELSE
                IF PREFERRED.PAYMENT.PRODUCT NE 'EXTERNAL' THEN
                    FINAL.ARRAY<-1> = BENEFICIARY.ID:"*":BENEFICIARY.NICK.NAME:"*":CATEGORY:"*":BENEFICIARY.ACCOUNT.NO:"*":BENEFICIARY.CUSTOMER:"*":TRANSACTION.DESC:"*":TRANSACTION.TYPE:"*":BANK.SORT.CODE:"*":BIC:"*":IBAN:"*":LINK.BENEFICIARY:"*":BEN.CUSTOMER.NICK.NAME:"*":CUSTOMER.REFERENCE:"*":COMMENT:"*":ACCOUNT.WITH.BANK:"*":PAYMENT.CURRENCY:"*":PREFERRED.PAYMENT.AMOUNT:"*":BEN.OUR.CHARGES:"*":BEN.PAYMENT.COUNTRY:"*":PREFERRED.PAYMENT.PRODUCT:"*":ACCT.WITH.BANK.SORT.CODE:"*":BENEFICIARY.CURR.NO:"*":BEN.CREATION.DATE
                END
            END
        END
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= GET.CUSTOMER.NICK.NAME>
*** <desc>Get beneficiary details for process</desc>
GET.CUSTOMER.NICK.NAME:
*------------------------

    BEGIN CASE
        CASE ((BENEFICIARY.CUSTOMER NE '') AND (BENEFICIARY.NICK.NAME NE '')) ;*Case for availability of nick name and customer name
            BEN.CUSTOMER.NICK.NAME = BENEFICIARY.CUSTOMER:" ":"(":BENEFICIARY.NICK.NAME:")" ;*Concating nick name values
        CASE BENEFICIARY.CUSTOMER EQ '' ;*Case for defaulting customer name
            BEN.CUSTOMER.NICK.NAME = BENEFICIARY.NICK.NAME
        CASE BENEFICIARY.NICK.NAME EQ '' ;*Case for defaulting beneficiary nick name
            BEN.CUSTOMER.NICK.NAME = BENEFICIARY.CUSTOMER
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------


*-----------------------------------------------------------------------------

*** <region name= GET.CUSTOMER.NAME>
GET.CUSTOMER.NAME:
*** <desc>To get the customer mnemonic instead of customer id </desc>
    CUSTOMER.RECORD = ''
    CUSTOMER.RECORD = ST.Customer.Customer.Read(BENEFICIARY.CUSTOMER, ERR.CUS);   *Read records from customer
    BENEFICIARY.CUSTOMER = CUSTOMER.RECORD<ST.Customer.Customer.EbCusMnemonic>;   *Get mnemonic from customer assigning to bencustomer
RETURN
*** </region>

END
