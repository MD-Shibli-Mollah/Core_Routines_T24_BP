* @ValidationCode : Mjo2NzcxNzc0Nzc6Q3AxMjUyOjE2MDU4ODY4NDc5ODI6c2l2YWNoZWxsYXBwYTo5OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6NTE0OjMzNQ==
* @ValidationInfo : Timestamp         : 20 Nov 2020 21:10:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 335/514 (65.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*--------------------------------------------------------------------------------------------------------------
* <Rating>-99</Rating>
*--------------------------------------------------------------------------------------------------------------
$PACKAGE AA.Channels
SUBROUTINE E.NOFILE.TC.AA.DEPOSIT(DEPOSIT.ARR)
*--------------------------------------------------------------------------------------------------------------
* Description :
*--------------
* This Enquiry(Nofile) routine is to provide a deposit overview details (Term, Schedule, Tax, Charge, Settlement, Interest, Arrangement & Account details)
*--------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.AA.DEPOSIT using the Standard selection NOFILE.TC.AA.DEPOSIT
* IN Parameters      : Arrangement Id
* Out Parameters     : Array of deposit details such as Term, Schedule, Tax, Charge, Settlement, Interest, Arrangement & Account details
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 03/08/16 - Enhancement 1657938 / Task 1827164
*            TCIB Componentization - Deposits improvements
* 06/10/16 - Defect 1883911 / Task 1884213
*            Additional fields are required for deposit overview details for other component dependencies.
* 03/01/17 - Defect 1909424 / Task 1931145
*            Tax detail is wrongly displayed when tax detail is multivalued in T24
* 02/02/17 - Defect 1998922 / Task 2007181
*            Get the renewal date for the Deposit
* 03/08/17 - Defect 2083086 / Task 2092156
*            Adding start date parameter to get arrangement conditions from interest charge schedule API
* 06/04/18 - Defect 2434981 / Task 2538188
*            Get the details of Commitment ,Expected balance in account and term Amount from GetPeriodBalances API
* 01/10/18 - Defect 2783259 / Task 2792187
*            TCIB - Maturity Accrued Interest display for Deposits in TCIB Corporate
* 02/10/18 - Enhancement 2768667 / Task 2768672
*            Flag for withdrawal principal,add funds and withdrawal unspecified credits are added and unspecified credits value is calculated
* 04/03/20 - Enhancement 3492893 / Task 3622075
*            Retrive bic, customer, payment details.
*
* 03/02/2020 - Enhancement 3568228 / Task 3569215
*            Removing reference of that have been moved from ST to CG
*
* 17/07/20 - Enhancement 3492899/ Task 3861124
*            Infinity Retail API new header changes
*
* 14/09/20 - Enhancement 3934727 / Task 3977150
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*
* 20/10/20 - Defect 3195712 / Task 3196084
*            API Privilege escalation
*
* 18/11/20 - Defect 4060863 /  Task 4086755
*           Invalid value in fields START.DATE in enqTcNofAADeposit
*
*---------------------------------------------------------------------------------------------------------------
*** <region name = Inserts>
    $INSERT I_DAS.TAX
    $INSERT I_CustomerService_NameAddress
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.Interest
    $USING AA.ModelBank
    $USING AA.TermAmount
    $USING AA.Fees
    $USING AA.ProductManagement
    $USING AA.Tax
    $USING AA.Customer
    $USING AA.Settlement
    $USING AA.PaymentSchedule
    $USING AA.Channels
    $USING EB.Reports
    $USING EB.API
    $USING EB.DatInterface
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING EB.Security
    $USING EB.Utility
    $USING AC.Channels
    $USING AC.EntryCreation
    $USING AC.SoftAccounting
    $USING AC.HighVolume
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AA.PayoutRules
    $USING EB.Interface
    $USING AC.AccountOpening
    $USING IN.Config
    $USING AR.ModelBank
    $USING ST.CompanyCreation
    $USING EB.ErrorProcessing
    $USING EB.Browser
*** This common varible is used to store all AC.BALANCE.TYPE details when we click the first time
*** subsequent process we will re-use this common.
    COMMON/AAFINSUM/AC$BALANCES.TYPE.DETAILS
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main Process>
    GOSUB INITIALISE                  ;* Initialise variables
    IF SECURITY.ERR THEN
        DEPOSIT.ARR =''
        RETURN
    END
    GOSUB ARRANGEMENT.PROPERTIES      ;* Initialise arrangement property values
    GOSUB BUILD.AC.BALANCES.LIST       ;* Initialise Balance Type
    GOSUB RETRIVE.DEPOSIT.DETAILS     ;* Retrive the deposit details from different arrangement properties and files
    GOSUB GET.PAYOUT.DETAILS          ;* Check if Payout rules property is available for the arrangement
    GOSUB UNSPECIFIED.CREDIT.DETAILS         ;* Retrieve the unspecified credit
    GOSUB ECB.DETAILS           ;* retrieve ecb details
    IF latestEnquiryFlag THEN
        GOSUB RETRIEVE.BIC.FROM.IBAN ;* Retrive interest and charge schedule details
        GOSUB RETRIEVE.CUST.DETAILS ;* Retreive customer details
        GOSUB GET.TOTAL.PAYMENT.DETAILS  ;* Get completed total no. of debits and credits performed
    END
    GOSUB BUILD.DEPOSIT.ARRAY.DETAILS ;* Build final output array

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialise Variables>
INITIALISE:
    DEPOSIT.ARR = '';SECURITY.ERR=''
*****Arrangement Details*****
    ARR.ID = ''; AUTH.ARR.ID = ''; INTEREST.CHARGE.SCHEDULE.ARR='';latestEnquiryFlag=''  ;*(Call routine out array)
    TODAY.DATE = EB.SystemTables.getToday() ;* The user is viewing the enquiry. It is relevant to show the current product as of today
    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getDFields()<1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getDRangeAndValue()<ARRPOS>
    END

    LOCATE "BALANCE.TYPES" IN EB.Reports.getDFields()<2> SETTING BALPOS THEN
        BAL.TYPES = EB.Reports.getDRangeAndValue()<BALPOS>
    END
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID THEN
        EXT.DEPOSITS.LIST      = EB.Browser.SystemGetvariable('EXT.SMS.DEPOSITS.SEE')
        FIND ARR.ID IN EXT.DEPOSITS.LIST SETTING DEPOSITPOS ELSE
            SECURITY.ERR = 'TRUE'
            RETURN
        END
    END
    
    AUTH.ARR.ID = ARR.ID:'//AUTH'  ;*Take the authorised arrangement of the active channel
    
    Today =  EB.SystemTables.getToday() ;*Get the today date value
    
    enquiriesVersionNo = RIGHT(EB.Reports.getEnqSelection()<1>,5)    ;* get enquiry name and then get its version. eg: 1.0.0
    CHANGE '.'TO '' IN enquiriesVersionNo
    IF enquiriesVersionNo GT 100 AND NUM(enquiriesVersionNo) THEN
        latestEnquiryFlag = 1
    END
    
    MATURITY.IN.DAYS = ''; PRIMARY.ACCT.HOLDER = ''; JOINT.ACCT.HOLDER = ''; DIVIDENT.PAID.YTD = ''; LAST.PAID.DIVIDENT = '';
    PERIOD.ENDING = ''; TOTAL.CREDITS = ''; TOTAL.DEBITS = '';
*****Arrangement Details*****
    R.ARRANGEMENT = ''; ARR.ERR = ''; CURRENCY = ''; START.DATE = ''

*****Account Details*****
    R.ACCOUNT.DETAILS  = ''; MATURITY.DATE = ''; MATURES.IN = ''; COOLING.DATE = ''; AC.ERR = ''; ACCOUNT.ID = ''; R.ACCOUNT = '' ; ERR.ACCOUNT = '' ; ACCOUNT.BIC = '' ;

*****Term Amount Property Details*****
    TERM.ERR = ''; TERM = ''; TERM.AMOUNT = ''; TERM.CANCEL.PERIOD = ''

*****Settlement Property Details*****
    SETTLEMENT.ERR = ''; PAYMENT.TYPE = ''; PAYIN.SETTLEMENT = ''; PAYIN.ACCOUNT = ''; PAYOUT.SETTLEMENT = ''; PAYOUT.ACCOUNT = ''; PAYOUT.PROPERTY = ''; PAYOUT.PROPERTY.CLASS = ''

*****Charge Property Details*****
    VAL.ERROR = ''; CHARGE.ERR = ''; CHARGERG.RECORDS = ''; CHARGERG.RECORD = ''; PROPERTY.ID = ''; CHARGE.TYPE = ''; SOURCE.TYPE = '';
    CONSOLIDATE.CHARGE.TYPE = ''; EARLY.REDEMPTION.FEE = ''; SOURCE.CALC.TYPE = ''; WIDTHDRAWAL.FEE = ''

*****Interest Property Details*****
    INTEREST.ERR = ''; INTEREST.RATE = ''; INTEREST.ID.COMP.ONE = ''; INTEREST.ID.COMP.TWO = ''; ID.AA.INTEREST.ACCRUALS = ''; AA.INTEREST.ACCRUALS = '';
    AA.INTEREST.ACCRUALS.ERR = ''; CNT.AA.INTEREST.ACCRUALS = ''; TOT.ACCR.AMOUNT = ''; SCHEDULE.PROJECTOR.DETAILS = ''; TOTAL.PAY = ''

*****Tax Property Details*****
    TAX.DETAILS.ARR = ''

****Deposit Balance Details*****
    EXPECTED.BALANCE='';COMMITMENT.AMOUNT=''; PENDING.DEPOSIT = '';
****Pending Withdrawals Details*****
    PENDING.WITHDRAWALS = '';AVAIL.BALANCE = '';
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialize Arrangement property Details>
ARRANGEMENT.PROPERTIES:
*--------------------------------
*****Initialise the arrangement property details*****
    TERM.PROPERTY.CLASS = 'TERM.AMOUNT'                     ;* Initialise term amount property class
    TERM.PROPERTY.RECORDS = ''                              ;* Initialise term amount property record
    SETTLEMENT.PROPERTY.CLASS = 'SETTLEMENT'                ;* Initialise settlement property class
    SETTLEMENT.PROPERTY.RECORDS = ''                        ;* Initialise settlement property record
    CHARGE.PROPERTY.CLASS = 'CHARGE'                        ;* Initialise charge property class
    CHARGE.PROPERTY.RECORDS = ''                            ;* Initialise charge property record
    INT.PROPERTY.CLASS = 'INTEREST'                         ;* Initialise interest property class
    INT.PROPERTY.RECORDS = ''                               ;* Initialise interest property record
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Retrive Deposit Details>
RETRIVE.DEPOSIT.DETAILS:
*-----------------------
*****Retrive the deposit details*****
    GOSUB ARRANGEMENT.DETAILS                 ;* Get the arrangement details
    GOSUB ACCOUNT.DETAILS                     ;* Get the account details
    GOSUB TERM.AMOUNT.PROPERTY.DETAILS        ;* Get term amount arrangement property details
    GOSUB GET.BALANCE.TYPES
    GOSUB SETTLEMENT.PROPERTY.DETAILS         ;* Get settlement arrangement property details
    GOSUB CHARGE.PROPERTY.DETAILS             ;* Get charge arrangement property details
    GOSUB INTEREST.PROPERTY.DETAILS           ;* Get interest arrangement property details
    GOSUB INTEREST.MATURITY.DETAILS           ;* Get maturity interest details
    GOSUB TAX.PROPERTY.DETAILS                ;* Get tax arrangement property details
    GOSUB INTEREST.CHARGE.SCHEDULE            ;* Get interest and charge schedule details
    GOSUB MATURITY.IN.DAYS                ;* Get the number of days between dates
    GOSUB GET.LAST.PAID.DETAILS
    GOSUB GET.COMMITMENT.AMOUNT
    
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Arrangement Details>
ARRANGEMENT.DETAILS:
*-------------------
*****Get the deposit details from arrangement*****

    IF ARR.ID[1,2] NE 'AA' THEN
        R.ACCOUNT = AC.AccountOpening.Account.Read(ARR.ID, ERR.ACCOUNT) ;* Read account details
        ARR.ID = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>  ;* Get Arrangement ID from ACCOUNT
        AUTH.ARR.ID = ARR.ID:'//AUTH'  ;*Take the authorised arrangement of the active channel
    END
    R.ARRANGEMENT               = AA.Framework.Arrangement.Read(ARR.ID,ARR.ERR)           ;*Read the arragement details
    CURRENCY                    = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>     ;*Get the currecy of the deposit
    CUSTOMER.NUMBER             = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer>     ;*Get the customer number of the deposit
    START.DATE                  = R.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>    ;*Get the start date of the deposit
    ACCT.NO                     = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId> ;*Get the account Number of the deposit
    ARR.STATUS                  = R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>    ;*Get the arrangement status of the deposit
    CUSTOMER.ROLES = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomerRole>
    ROLE.COUNT = DCOUNT(CUSTOMER.ROLES, @VM)
    JOINT.CUSTOMER = ''
    FOR ROLE = 1 TO ROLE.COUNT
        IF (CUSTOMER.ROLES<1,ROLE> EQ "JOINT.OWNER") THEN
            JOINT.CUSTOMER = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer,ROLE>
        END
    NEXT ROLE
    
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Account Details>
ACCOUNT.DETAILS:
*---------------
*****Get the deposit details from account details file*****

    R.ACCOUNT.DETAILS           = AA.PaymentSchedule.AccountDetails.Read(ARR.ID,AC.ERR)                  ;*Read the account details for the arrangement
    MATURITY.DATE               = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdMaturityDate>    ;*Read the maturity date of the deposit
    IF NOT(MATURITY.DATE) THEN
        MATURITY.DATE               = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdRenewalDate>    ;*Read the renewal date of the deposit
    END
    EB.API.MatDateEnrichment(MATURITY.DATE,START.DATE,MATURITY.DAYS)                                     ;*Read the enrichment details for the maturity date
    MATURES.IN                  = MATURITY.DAYS
    COOLING.DATE                = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdCoolingDate>     ;*Read the cooling date of the deposit
  
    IF NOT(R.ACCOUNT) THEN
        R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.NO, ERR.ACCOUNT) ;* Read account details
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Term Amount Property Details>
TERM.AMOUNT.PROPERTY.DETAILS:
*----------------------------
*****Get the deposit details from term amount arrangement property*****
    AA.Framework.GetArrangementConditions(AUTH.ARR.ID,TERM.PROPERTY.CLASS,'','',TERM.PROPERTY.IDS,TERM.PROPERTY.RECORDS,TERM.ERR) ;* Get term amount arrangement condition record
    TERM.PROPERTY.RECORDS       = RAISE(TERM.PROPERTY.RECORDS)                                      ;* Term amount property record
    TERM                        = TERM.PROPERTY.RECORDS<AA.TermAmount.TermAmount.AmtTerm>           ;*Term
    TERM.CANCEL.PERIOD          = TERM.PROPERTY.RECORDS<AA.TermAmount.TermAmount.AmtCancelPeriod>   ;*Term cancel period
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Settlement Property Details>
SETTLEMENT.PROPERTY.DETAILS:
*---------------------------
*****Get the deposit details from settlement arrangement property*****
    AA.Framework.GetArrangementConditions(AUTH.ARR.ID,SETTLEMENT.PROPERTY.CLASS,'','',SETTLEMENT.PROPERTY.IDS,SETTLEMENT.PROPERTY.RECORDS,SETTLEMENT.ERR) ;* Get settlement arrangement condition record
    SETTLEMENT.PROPERTY.RECORDS = RAISE(SETTLEMENT.PROPERTY.RECORDS)                                            ;* Settlement property record
    PAYMENT.TYPE                = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPaymentType>          ;* Settlement payment type
    PAYIN.SETTLEMENT            = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPayinSettlement>      ;* Settlement payin settlement value
    PAYIN.ACCOUNT               = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPayinAccount>         ;* Settlement payin account
    PAYOUT.SETTLEMENT           = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPayoutSettlement>     ;* Settlement payout settlement value
    PAYOUT.ACCOUNT              = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPayoutAccount>        ;* Settlement payout account
    PAYOUT.PROPERTY             = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPayoutProperty>       ;* Settlement payout property
    PAYOUT.PROPERTY.CLASS       = SETTLEMENT.PROPERTY.RECORDS<AA.Settlement.Settlement.SetPayoutPptyClass>      ;* Settlement payout property class
       
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Charge Property Details>
CHARGE.PROPERTY.DETAILS:
*-----------------------
*****Get the deposit details from charge arrangement property*****
    AA.ProductFramework.GetPublishedRecord('PRODUCT', '', PRODUCT.ID, TODAY.DATE, PRODUCT.RECORD, VAL.ERROR)         ;* Get the Published Product definition

    AA.Framework.GetArrangementConditions(AUTH.ARR.ID,CHARGE.PROPERTY.CLASS,'','',CHARGE.PROPERTY.IDS,CHARGE.PROPERTY.RECORDS,CHARGE.ERR) ;* Get term charge arrangement condition record
    CNT.CHARGE.RECORDS        = DCOUNT(CHARGE.PROPERTY.RECORDS,@FM)                       ;* Get the number of avilable records
    FOR CHARGE.RECORD = 1 TO CNT.CHARGE.RECORDS
        CHARGE.PROPERTY.RECORD  = CHARGE.PROPERTY.RECORDS<CHARGE.RECORD>                  ;* Charge record details
        CHARGE.PROPERTY.RECORD  = RAISE(CHARGE.PROPERTY.RECORD)
        PROPERTY.ID             = CHARGE.PROPERTY.RECORD<AA.Fees.Charge.IdComp2>            ;* Charge property ID
        CHARGE.TYPE             = CHARGE.PROPERTY.RECORD<AA.Fees.Charge.ChargeType>         ;* Charge type
        LOCATE PROPERTY.ID IN PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdCalcProperty, 1> SETTING CALC.PROP.POS THEN
            SOURCE.TYPE = PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdSourceType, CALC.PROP.POS>   ;* Source type
        END

        IF CHARGE.TYPE EQ 'FIXED' THEN             ;* If charge type equals to "FIXED" then the display value is "Flat Amount"
            CONSOLIDATE.CHARGE.TYPE<1,-1> = 'Flat Amount'
        END ELSE
            CONSOLIDATE.CHARGE.TYPE<1,-1> = 'Calculated'   ;* If charge type not equals to "FIXED" then the display value is "Calculated"
        END

        IF PROPERTY.ID EQ 'REDEMPTIONFEE' THEN
            EARLY.REDEMPTION.FEE = CHARGE.PROPERTY.RECORD<AA.Fees.Charge.FixedAmount> ;* Charge - Eraly redemption fee
        END

        IF PROPERTY.ID EQ 'WITHDRAWALFEE' THEN
            GOSUB WIDTHDRAWAL.FEE.DETAILS          ;* Get the widthdrawal fee
        END
    NEXT CHARGE.RECORD
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Widthdrawal Fee Details>
WIDTHDRAWAL.FEE.DETAILS:
*-----------------------
*****Get the widthdrawal fee details*****
    AA.Framework.GetSourceTypeDetails(SOURCE.TYPE, SOURCE.CALC.TYPE, SCR.ERR) ;* Get the calculated source type
    IF SOURCE.CALC.TYPE EQ 'TXN.AMOUNT' THEN
        WIDTHDRAWAL.FEE         = 'Activity Amount'                               ;* If source type equals to "TXN.AMOUNT" then the display value is "Activity Amount"
    END ELSE
        WIDTHDRAWAL.FEE         = 'Activity Count'                                ;* If source type not equals to "TXN.AMOUNT" then the display value is "Activity Amount"
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Interest Property Details>
INTEREST.PROPERTY.DETAILS:
*-------------------------
*****Get the deposit details from interest arrangement property*****
    AA.Framework.GetArrangementConditions(AUTH.ARR.ID,INT.PROPERTY.CLASS,'','',INT.PROPERTY.IDS,INT.PROPERTY.RECORDS,INTEREST.ERR) ;* Get interest arrangement condition record
    IF latestEnquiryFlag THEN
        GOSUB INTEREST.RATE.AND.DATE.DETAILS   ;* Get interest rate and last paid date details
    END
    INT.PROPERTY.RECORDS        = RAISE(INT.PROPERTY.RECORDS)                                                              ;* Interest record
    INTEREST.RATE               = INT.PROPERTY.RECORDS<AA.Interest.Interest.IntEffectiveRate>:'%'                          ;* Interest rate

    INTEREST.ID.COMP.ONE        = INT.PROPERTY.RECORDS<AA.Interest.Interest.IntIdCompOne>                                  ;* Interest Id Comp One
    INTEREST.ID.COMP.TWO        = INT.PROPERTY.RECORDS<AA.Interest.Interest.IntIdCompTwo>                                  ;* Interest Id Comp Two
    ID.AA.INTEREST.ACCRUALS     = INTEREST.ID.COMP.ONE:"-":INTEREST.ID.COMP.TWO                                            ;* AA Interest Accruals Id
    AA.INTEREST.ACCRUALS        = AA.Interest.InterestAccruals.Read(ID.AA.INTEREST.ACCRUALS, AA.INTEREST.ACCRUALS.ERR)     ;* Read AA Interest Accrual record
    CNT.AA.INTEREST.ACCRUALS    = DCOUNT(AA.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccPeriodStart>,@VM)         ;* Count of records wit VM separator
    TOT.ACCR.AMOUNT             = AA.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotAccrAmt,CNT.AA.INTEREST.ACCRUALS> ;* Total Accrual Amount
    
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
INTEREST.MATURITY.DETAILS:

    SCHEDULE.PROJECTOR.DETAILS  = AA.PaymentSchedule.ScheduleProjector(ARR.ID, "", "","", TOT.PAYMENT, DUE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Routine to Project complete schedules
    TOT.PAY.TYPE = DCOUNT(DUE.TYPES,@FM)
    STORE.PAY.TYPE = DUE.TYPES ;* Fetching the exact payment type
    FOR PAY.CNT = 1 TO TOT.PAY.TYPE
        PROP.LIST = DUE.PROPS<PAY.CNT>
        PROP.LIST = RAISE(PROP.LIST)
        AA.ProductFramework.GetPropertyClass(PROP.LIST,PROP.CLS.LIST)
        TOT.PROP = DCOUNT(PROP.LIST,@VM)
        FOR PROP.CNT = 1 TO TOT.PROP
            PROP.AMT = DUE.PROP.AMTS<PAY.CNT,PROP.CNT,1>
            IF PROP.CLS.LIST<1,PROP.CNT> EQ 'INTEREST'  THEN
                TOT.INT.PAYM += PROP.AMT
            END
        NEXT PROP.CNT
    NEXT PAY.CNT

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Tax Property Details>
TAX.PROPERTY.DETAILS:
*--------------------
*****Get the deposit details from tax arrangement property*****
    AA.Channels.AaGetTaxConditionsDetails(AUTH.ARR.ID, TAX.DETAILS.ARR) ;* Read the tax property condition details
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Tax Rate>
INTEREST.CHARGE.SCHEDULE:
*-----------------------
    AA.Channels.AaGetInterestChargeSchedule(AUTH.ARR.ID,START.DATE,INTEREST.CHARGE.SCHEDULE.ARR)   ;* Get the interest and charge schedule details of the arrangement
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Days Between Dates>
MATURITY.IN.DAYS:
*-----------------------

*Calculate total maturity period of deposit in days
    IF START.DATE NE '' AND MATURITY.DATE NE '' THEN
        MATURITY.IN.DAYS = 'C'
        EB.API.Cdd("", START.DATE, MATURITY.DATE, MATURITY.IN.DAYS)
    END
*Calculate remaing maturity period of deposit in days from current day
    IF TODAY.DATE NE '' AND MATURITY.DATE NE '' THEN
        REMAINING.MATURITY.IN.DAYS = 'C'
        EB.API.Cdd("", TODAY.DATE, MATURITY.DATE, REMAINING.MATURITY.IN.DAYS)
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
BUILD.DEPOSIT.ARRAY.DETAILS:
*---------------------------
* Build loan array details
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) ELSE
        CHANGE @VM TO "|" IN PAYOUT.SETTLEMENT
        CHANGE @VM TO "|" IN PAYOUT.ACCOUNT
        CHANGE @VM TO "|" IN PAYIN.SETTLEMENT
        CHANGE @VM TO "|" IN PAYIN.ACCOUNT
        CHANGE @VM TO "|" IN CONSOLIDATE.CHARGE.TYPE
        CHANGE @VM TO "|" IN PAYOUT.PROPERTY
        CHANGE @VM TO "|" IN PAYOUT.PROPERTY.CLASS
        CHANGE @VM TO "|" IN DIVIDENT.PAID.YTD
        CHANGE @VM TO "|" IN LAST.PAID.DIVIDENT
        CHANGE @VM TO "|" IN PERIOD.ENDING
    END
    IF latestEnquiryFlag THEN
        DEPOSIT.ARR<-1> = ARR.ID:"*":CURRENCY:"*":START.DATE:"*":MATURITY.DATE:"*":MATURES.IN:"*":COOLING.DATE:"*":TERM:"*":TERM.AMOUNT:"*":TERM.CANCEL.PERIOD:"*":CONSOLIDATE.CHARGE.TYPE:"*":EARLY.REDEMPTION.FEE:"*":WIDTHDRAWAL.FEE:"*":INTEREST.RATE:"*":TOT.ACCR.AMOUNT:"*":TOT.INT.PAYM:"*":TAX.DETAILS.ARR:"*":INTEREST.CHARGE.SCHEDULE.ARR:"*":PAYMENT.TYPE:"*":PAYIN.SETTLEMENT:"*":PAYIN.ACCOUNT:"*":PAYOUT.SETTLEMENT:"*":PAYOUT.ACCOUNT:"*":PAYOUT.PROPERTY:"*":PAYOUT.PROPERTY.CLASS:"*":MATURITY.IN.DAYS:"*":REMAINING.MATURITY.IN.DAYS:"*":COMMITMENT.AMOUNT:"*":EXPECTED.BALANCE:"*":WITHDRAW.FLAG:"*":UNSPECIFIED.CREDIT:"*":FUNDDEPOSIT.FLAG:"*":WITHDRAW.UNC.FLAG:"*":ACCOUNT.BIC:"*":PENDING.DEPOSIT:"*":PRIMARY.ACCT.HOLDER:"*":TOTAL.CREDITS:"*":TOTAL.DEBITS:"*":JOINT.ACCT.HOLDER:"*":DIVIDENT.PAID.YTD:"*":LAST.PAID.DIVIDENT:"*":PERIOD.ENDING:"*":COMMITMENT.BAL:"*":LAST.PAID.AMOUNT:"*":LAST.PAID.DATE:"*":TOTAL.DUE.AMOUNT:"*":PENDING.WITHDRAWALS
    END ELSE
        DEPOSIT.ARR<-1> = ARR.ID:"*":CURRENCY:"*":START.DATE:"*":MATURITY.DATE:"*":MATURES.IN:"*":COOLING.DATE:"*":TERM:"*":TERM.AMOUNT:"*":TERM.CANCEL.PERIOD:"*":CONSOLIDATE.CHARGE.TYPE:"*":EARLY.REDEMPTION.FEE:"*":WIDTHDRAWAL.FEE:"*":INTEREST.RATE:"*":TOT.ACCR.AMOUNT:"*":TOT.INT.PAYM:"*":TAX.DETAILS.ARR:"*":INTEREST.CHARGE.SCHEDULE.ARR:"*":PAYMENT.TYPE:"*":PAYIN.SETTLEMENT:"*":PAYIN.ACCOUNT:"*":PAYOUT.SETTLEMENT:"*":PAYOUT.ACCOUNT:"*":PAYOUT.PROPERTY:"*":PAYOUT.PROPERTY.CLASS:"*":MATURITY.IN.DAYS:"*":REMAINING.MATURITY.IN.DAYS:"*":COMMITMENT.AMOUNT:"*":EXPECTED.BALANCE:"*":WITHDRAW.FLAG:"*":UNSPECIFIED.CREDIT:"*":FUNDDEPOSIT.FLAG:"*":WITHDRAW.UNC.FLAG
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
GET.BALANCE.TYPES:
*-----------------------
*
** Get the list of properties from the arrangement record
** then from the property class get the prefixes
** also get a list of all balance types so that we can look for virtual balances
** and any that are created by soft accounting
*

* Forcefully append null values into ARR.INFO, so that, values are not picked from common in AA.GET.ARRANGEMENT.PROPERTIES
* This is done to avoid common variables of some other arrangement getting assinged from cache, when multiple arrangment details are accessed within
* the same session
    PROPERTY.LIST = ""
    ARR.INFO = ARR.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    EFF.DATE = EB.SystemTables.getToday()
    IF START.DATE GT EFF.DATE THEN ;* can be true for fwd dated arrangement
        EFF.DATE = START.DATE
    END
    AA.Framework.GetArrangementProperties(ARR.INFO, EFF.DATE, R.ARRANGEMENT, PROPERTY.LIST)     ;* Get properties associated with the arrangement for the effective date
    CHANGE @SM TO @FM IN BAL.TYPES
    BALANCE.LIST = CHANGE(BAL.TYPES,@VM,@FM)
    REQD.BAL.LIST = BAL.TYPES
*
    GOSUB ADD.BALANCES
RETURN
*
*--------------------------------------------------------------------------------------------------------------
GET.PERIOD.BALANCES:
*-----------------------
    REQUEST.TYPE<6> = ""
    AA.Framework.GetPeriodBalances(ACCT.NO,BALANCE.TYPE,REQUEST.TYPE,START.DATE,EFF.DATE,'',BAL.DETAILS,'')
    NO.OF.DT = DCOUNT(BAL.DETAILS<1>,@VM)
    BD.BAL = BAL.DETAILS<4,NO.OF.DT>

RETURN
*--------------------------------------------------------------------------------------------------------------
ADD.BALANCES:
*-----------------------
*
** Now for each balance in the list call EB.GET.ACCT.BALANCE to retrieve
** the balance we want
*
    NEXT.BAL = 0
    IDX = 0
    REQUEST.TYPE<3> = 'ALL'
    REQUEST.TYPE<2> = 'ALL'
    BAL.DETAILS = ''
    BALANCE.TYPE.POS = 50     ;* Balance type field in record
    BALANCE.BK.AMT.POS = 51   ;* Booking dated balance for balance type
    LOOP
        IDX += 1
        BALANCE.TYPE = BALANCE.LIST<IDX>
    WHILE BALANCE.TYPE
        LOCATE BALANCE.TYPE IN AC$BALANCES.TYPE.DETAILS<1,1> SETTING BAL.POS THEN
            VIRTUAL.BALANCES = AC$BALANCES.TYPE.DETAILS<2,BAL.POS>
            IF VIRTUAL.BALANCES THEN    ;* Get the balance from the values we've already calculated
                VIRTUAL.BAL = 'YES'
                SAVE.BALANCE.TYPE =  BALANCE.TYPE
                GOSUB CALCULATE.VIRTUAL.BALANCE
                BALANCE.TYPE = SAVE.BALANCE.TYPE
                BD.BAL = BAL.AMT
            END ELSE
                VIRTUAL.BAL = ''
                GOSUB GET.PERIOD.BALANCES
            END

            IF BD.BAL THEN
                NEXT.BAL +=1
                R.ARRANGEMENT<BALANCE.TYPE.POS, NEXT.BAL> = BALANCE.TYPE
                R.ARRANGEMENT<BALANCE.BK.AMT.POS, NEXT.BAL> = BD.BAL
                LOCATE BALANCE.TYPE IN REQD.BAL.LIST<1> SETTING REQ.POS THEN
                    CURRENT.PROPERTY = ""
                    CURRENT.PROPERTY.CLASS = ""
                    CURRENT.PROPERTY = BALANCE.TYPE[4,20]
                    AA.ProductFramework.GetPropertyClass(CURRENT.PROPERTY, CURRENT.PROPERTY.CLASS)
                    IF CURRENT.PROPERTY.CLASS EQ "TERM.AMOUNT" AND BALANCE.TYPE[1,3] EQ "CUR" AND BD.BAL GT 0 THEN
                        BD.BAL = 0 ;* Shows the available commitment as 0 when the CUR<TERM.AMOUNT> goes in positive for loans
                    END
                    IF BALANCE.TYPE EQ "TOTCOMMITMENT" THEN
                        COMMITMENT.AMOUNT=BD.BAL
                    END
                    IF BALANCE.TYPE EQ "EXPACCOUNT" THEN
                        EXPECTED.BALANCE=BD.BAL
                    END
                    IF BALANCE.TYPE EQ "TOTALPRINCIPAL" THEN
                        TERM.AMOUNT=BD.BAL
                    END
                END
            END
        END

    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
CALCULATE.VIRTUAL.BALANCE:
*-------------------------
*
** We'll calculate this from the balances that we will have already extracted
** We do this as although EB.GET.ACCT.BALANCE handles virtual balances it only
** does so if the balance is in ACCT.ACTIVITY which may not always be the case
** for some balances
*
    BAL.AMT = ''
    LOOP
        REMOVE BAL.NAME FROM VIRTUAL.BALANCES SETTING YD
    WHILE BAL.NAME:YD
        LOCATE BAL.NAME IN R.ARRANGEMENT<BALANCE.TYPE.POS,1> SETTING BAL.POS THEN
            BAL.AMT += R.ARRANGEMENT<BALANCE.BK.AMT.POS, BAL.POS>
        END ELSE
            BALANCE.TYPE = BAL.NAME
            BD.BAL = 0.00
            GOSUB GET.PERIOD.BALANCES
            BAL.AMT + = BD.BAL
        END
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
GET.PAYOUT.DETAILS:
*------------------
*
*   Check whether there is property condition that apply to arrangement

    PAYOUT.PROPERTY.CLASS = 'PAYOUT.RULES'
    PAYOUT.PROPERTY.RECORD = ''
    PAYOUT.PROPERTY.IDS = ''
    WITHDRAW.FLAG = ''
    WITHDRAW.UNC.FLAG = ''
    
    ACCOUNT.BALANCE.TYPE='CURACCOUNT':@FM:'UNCACCOUNT'
    AA.Framework.GetArrangementConditions(ARR.ID,PAYOUT.PROPERTY.CLASS,'',START.DATE,PAYOUT.PROPERTY.IDS,PAYOUT.PROPERTY.RECORD,RET.ERR)      ;* Get arrangement condition for PAYOUT.RULES Property class
    TOT.PAYOUT.PROPERTY.RECORD = DCOUNT(PAYOUT.PROPERTY.RECORD, @FM)  ;* Get count of property record with PAYOUT.RULES Property class
    FOR PAYOUT.PROPERTY.RECORD.CNT = 1 TO TOT.PAYOUT.PROPERTY.RECORD  ;* Repeat the property record
        CUR.PAYOUT.PROPERTY.RECORD = PAYOUT.PROPERTY.RECORD<PAYOUT.PROPERTY.RECORD.CNT>  ;* Read property record
        CUR.PAYOUT.PROPERTY.RECORD = RAISE(CUR.PAYOUT.PROPERTY.RECORD)

        LOCATE ACCOUNT.BALANCE.TYPE<1> IN CUR.PAYOUT.PROPERTY.RECORD<AA.PayoutRules.PayoutRules.PayoutBalanceType,1> SETTING BALPOS THEN  ;*Search for CURACCOUNT in property record
            IF ARR.STATUS EQ 'CURRENT' THEN  ;* Set withdraw flag if arrangement status is current
                WITHDRAW.FLAG = 'Y'
            END
        END
    
        LOCATE ACCOUNT.BALANCE.TYPE<2> IN CUR.PAYOUT.PROPERTY.RECORD<AA.PayoutRules.PayoutRules.PayoutBalanceType,1> SETTING BALPOS THEN  ;*Search for CURACCOUNT in property record
            IF ARR.STATUS EQ 'CURRENT' THEN  ;* Set withdraw flag if arrangement status is current
                WITHDRAW.UNC.FLAG = 'Y'
            END
        END
    NEXT PAYOUT.PROPERTY.RECORD.CNT
 
*
RETURN
*
*-----------------------------------------------------------------------------
UNSPECIFIED.CREDIT.DETAILS:
*--------------------------
*
* Get Unspecified Credit from EB.CONTRACT.BALANCES

    UNSPECIFIED.CREDIT = ''
    ECB.RECORD = ''
    ONLINE.CLEARED.BALANCE = ''
    ONLINE.ACTUAL.BALANCE = ''
    AC.HighVolume.EbReadHvt('EB.CONTRACT.BALANCES',ACCT.NO,ECB.RECORD,'')   ;* Read eb contract balance for the account number passed
    UNSPEC.CREDIT.BAL.TYPE = 'UNCACCOUNT'
    ECB.BALANCE.TYPES = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbCurrAssetType>    ;* Read asset type of contract balance
    ECB.CREDIT.MVMT   = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt>   ;* Read credit mvmt of contract balance
    ECB.DEBIT.MVMT   = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt>     ;* Read debit mvmt of contract balance
    ONLINE.CLEARED.BALANCE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineClearedBal>    ;*Assign the output value for online cleared balance to a variable
    ONLINE.ACTUAL.BALANCE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineActualBal>    ;*Assign the output value for online actual balance to a variable
    PENDING.DEPOSIT = ONLINE.ACTUAL.BALANCE - ONLINE.CLEARED.BALANCE
    AVAIL.BALANCE   = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>      ;*Assign the output value for available balance to a variable
    
*Get pending Withdrawals
    PENDING.WITHDRAWALS = ONLINE.CLEARED.BALANCE - AVAIL.BALANCE
    
    ECB.BALANCE.TYPES = RAISE(ECB.BALANCE.TYPES)
    LOCATE UNSPEC.CREDIT.BAL.TYPE IN ECB.BALANCE.TYPES SETTING BAL.POS THEN  ;* Search for UNCACCOUNT property record
        UNSPECIFIED.CREDIT = ECB.CREDIT.MVMT<1,BAL.POS> + ECB.DEBIT.MVMT<1,BAL.POS>  ;* add the credit and debit mvmt for UNCACCOUNT property record
    END
*
RETURN
*
*-----------------------------------------------------------------------------
ECB.DETAILS:
*------------
*
* Search for Current balance Type SysDate and merge them
*
    FUNDDEPOSIT.FLAG = ''
    BALANCE.COUNT = 0
    MergedBalanceDetails = ''
    LOOP
        BALANCE.COUNT += 1 ;*Loop through each TypeSysDate
        BALANCE.TYPE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate, BALANCE.COUNT>["-",1,1] ;*Extract the balances
    WHILE BALANCE.TYPE ;*Process when we have a valid balance type
        IF BALANCE.TYPE EQ 'CURACCOUNT' THEN
            FUNDDEPOSIT.FLAG = ''
            MOVEMENT.COUNT = 0
            LOOP
                MOVEMENT.COUNT += 1 ;*Loop through each Movements sub-value
                DR.MVMT = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt, BALANCE.COUNT, MOVEMENT.COUNT> ;*And debit movement
            WHILE DR.MVMT NE ""
                BALANCE.AMOUNT =  DR.MVMT ;*Get Consolidated movement for the type
;*Merge the values against the balance type
                LOCATE BALANCE.TYPE IN MergedBalanceDetails<1,1> SETTING BAL.POS THEN ;*Ok Balance Type already exist
                    MergedBalanceDetails<2, BAL.POS> += BALANCE.AMOUNT ;*Add the signed amount in the corresponding position
                END ELSE ;*New Balance Type
                    MergedBalanceDetails<1, -1> = BALANCE.TYPE ;*Append the Balance Type
                    MergedBalanceDetails<2, -1> = BALANCE.AMOUNT + 0 ;*Ensure nothing is there as NULL
                END
            REPEAT
        END ELSE
            IF (ARR.STATUS NE 'EXPIRED' AND TERM.AMOUNT EQ '') THEN
                FUNDDEPOSIT.FLAG = 'Y'
            END
        END
    REPEAT
    
* Subtract the debit mvmt value from term amount
    MergedBalanceDetails<2> = ABS(MergedBalanceDetails<2>)
    MergedBalanceDetails<2> = TERM.AMOUNT + MergedBalanceDetails<2>
    
* Check if the calculated value is less than commitment amount or it is zero
    IF ((MergedBalanceDetails<2> LT COMMITMENT.AMOUNT) OR (MergedBalanceDetails<2> EQ 0)) AND (ARR.STATUS NE 'EXPIRED') THEN    ;* if the mvmt values is less than commitment amount or 0, set the flag
        FUNDDEPOSIT.FLAG = 'Y'
    END
*
RETURN
*
*-----------------------------------------------------------------------------
BUILD.AC.BALANCES.LIST:
*-----------------------
*
** Get a list AC.BALANCE.TYPES and store a separate list of virtual balances
*
    F.AC.BALANCE.TYPE = ''
    EB.DataAccess.Opf("F.AC.BALANCE.TYPE", F.AC.BALANCE.TYPE)
*
    SELECT F.AC.BALANCE.TYPE
    BAL.IDX = ''
    LOOP
        READNEXT BALANCE.NAME ELSE
            BALANCE.NAME = ''
        END
    WHILE BALANCE.NAME
        BALANCE.TYPE.REC = ''
        BALANCE.TYPE.REC = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.NAME, "")
        BAL.IDX += 1
        AC$BALANCES.TYPE.DETAILS<1,BAL.IDX> = BALANCE.NAME
        AC$BALANCES.TYPE.DETAILS<2,BAL.IDX> = LOWER(BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtVirtualBal>)
        AC$BALANCES.TYPE.DETAILS<3,BAL.IDX> = BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtActivityUpdate>
    REPEAT
*
    IF AC$BALANCES.TYPE.DETAILS = '' THEN
        AC$BALANCES.TYPE.DETAILS = "NONE"       ;* Stop repeated selection
    END
*
RETURN
*
*--------------------------------------------------------------------------------------------------------------
RETRIEVE.BIC.FROM.IBAN:
*------------------------
*****Retrive the BIC id details for the IBAN number attached with the Account*****
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) THEN
        IBAN.VAR = "T24.IBAN" ;*Initialise the account variable
            
****Get the Iban Id from Arrangement*****
        ALT.ACCT.TYPE = R.ACCOUNT<AC.AccountOpening.Account.AltAcctType>    ;*Account type

        LOCATE IBAN.VAR IN ALT.ACCT.TYPE<1,1> SETTING POS THEN
            IBAN.ID = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId,POS>
            IF IBAN.ID NE '' THEN
                ACCOUNT.IBAN = IBAN.ID;*Re-assigning the IBAN account number as result data
            END ELSE
                ACCOUNT.IBAN = "NA"
            END
        
            IF ACCOUNT.IBAN NE "NA" THEN
                IN.Config.Getbicfromiban(ACCOUNT.IBAN,RET.DATA,RET.CODE)
                ACCOUNT.BIC = RET.DATA
            END ELSE
                ACCOUNT.BIC = "NA"
            END
        END
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get customer details>
RETRIEVE.CUST.DETAILS:
*------------------------
*****Retrive the interest and charge schedule details*****

    LANG = EB.SystemTables.getLngg()
    CUST.NAME.ADDR = ''
    CALL CustomerService.getNameAddress(CUSTOMER.NUMBER,LANG,CUST.NAME.ADDR)
    PRIMARY.ACCT.HOLDER = CUST.NAME.ADDR<NameAddress.shortName>
    
    CUST.NAME.ADDR = ''
    CALL CustomerService.getNameAddress(JOINT.CUSTOMER,LANG,CUST.NAME.ADDR)
    JOINT.ACCT.HOLDER = CUST.NAME.ADDR<NameAddress.shortName>
            
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= GET.TOTAL.PAYMENT.DETAILS>
*** <desc>To get the Completed account transactions list ignoring future and pending transactions</desc>
GET.TOTAL.PAYMENT.DETAILS:
*-----------------
    ID.LIST = ''
    START.DATE = Today
    EB.API.Cdt('',START.DATE,'-30C') ;*Minus 30 calendar days to set Start date
*Call routine to retrieve the Credit payment statement entry id's based on the account no, start date and end date
    AC.Channels.GetAccountTxnsIds(ACCT.NO, 'SEARCH', '', 'PAIDOUT', START.DATE, '', '', '', '', '', ID.LIST)
    GOSUB TOTAL.PAYMENT.DETAILS
    TOTAL.CREDITS = totalPayment
    
*Call routine to retrieve the Debit payment statement entry id's based on the account no, start date and end date
    ID.LIST = ''
    AC.Channels.GetAccountTxnsIds(ACCT.NO, 'SEARCH', '', 'PAIDIN', START.DATE, '', '', '', '', '', ID.LIST)
    GOSUB TOTAL.PAYMENT.DETAILS
    TOTAL.DEBITS = totalPayment
*
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= TOTAL.PAYMENT.DETAILS>
*** <desc>Get the total Credit payment details and total Debit payment details</desc>
TOTAL.PAYMENT.DETAILS:
*---------------
    totalPayment = 0; StmtRec = ''; BookingDate = ''; ErrStmt = ''; ExposureDate = '';
    IF ID.LIST NE '' THEN
        LOOP
            REMOVE StmtId FROM ID.LIST SETTING LIST.POS  ;*Loop statement to get the transaction details
        WHILE StmtId:LIST.POS
*Get the common transaction details from statement entry and IM applications
            StmtId = FIELD(StmtId, '*', 2)
            AC.HighVolume.EbReadHvt('STMT.ENTRY',StmtId,StmtRec,'')    ;* To read statement entry Id
            IF StmtRec NE '' THEN
                BookingDate= StmtRec<AC.EntryCreation.StmtEntry.SteBookingDate>   ;* To get booking date
                ExposureDate = StmtRec<AC.EntryCreation.StmtEntry.SteExposureDate> ;*To read exposure date
            END
            IF BookingDate NE '' AND ExposureDate <= Today THEN   ;*Check to ignore the future dated and pending transactions
                totalPayment += 1   ;*Form Total credit payments
            END
        REPEAT
    END
    
RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = Get interest rate and last paid date details>
INTEREST.RATE.AND.DATE.DETAILS:
*-------------------------
*****Retrive the interest details*****
    ODATAVAL = ''
    LAST.YEAR = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLastYearEnd)
    TOT.INT.PROPERTY.RECORDS = DCOUNT(INT.PROPERTY.RECORDS,@FM)                                                                 ;* Total number of interest records
    FOR CNT.INT.PROPERTY.RECORDS = 1 TO TOT.INT.PROPERTY.RECORDS
        PROPERTY = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntIdCompTwo>                ;* Interest property
        CO.CODE = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntCoCode>
        ODATA.VAL = ARR.ID:'-':PROPERTY:'~':LAST.YEAR
        GOSUB GET.ACCRUED.INTEREST
        DIVIDENT.PAID.YTD<1,-1> = FIELD(ODATA.VAL,'*',1)
        
        ODATA.VAL = ''
        ODATA.VAL = ARR.ID:'-':PROPERTY:'~':'PREVIOUS'
        GOSUB GET.ACCRUED.INTEREST
        LAST.PAID.DIVIDENT<1,-1> = FIELD(ODATA.VAL,'*',1)
        PERIOD.ENDING<1,-1> = FIELD(ODATA.VAL,'*',3)
    NEXT CNT.INT.PROPERTY.RECORDS
    
RETURN
*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name = Interest calculation Details>
GET.ACCRUED.INTEREST:
*-------------------------

    EB.Reports.setOData(ODATA.VAL)
    AR.ModelBank.EAaAccruedInterest()
    ODATA.VAL = EB.Reports.getOData()
    
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get customer details>
GET.LAST.PAID.DETAILS:
*------------------------
*****Retrive the interest and charge schedule details*****
    FUTURE.SCHD.COUNT = 0; PAID.SCHD.COUNT = 0; DUE.SCHD.COUNT = 0; ARR.START.DATE = ''; DEFER.DATES = ''; SIM.REF = ''
    DUE.TYPES = ''; DUE.METHODS = ''; DUE.TYPE.AMTS = ''; DUE.PROPS = ''; DUE.PROP.AMTS = ''; DUE.OUTS = ''
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, '',START.DATE, FUTR.PAY.AMOUNT, FUTURE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Call routine to get the list of schedules to be paid from the date given
    FUTR.SCHD.COUNT = DCOUNT(FUTURE.DATES,@FM)     ;* Total Number of Schedule dates
    SAVE.FUTR.SCHD.COUNT = FUTR.SCHD.COUNT
    BILL.ID = ''
    FOR FUT.SCHD = 1 TO SAVE.FUTR.SCHD.COUNT
        PAYMENT.DATE = FUTURE.DATES<FUT.SCHD>      ;* Read the payment date for the schedule dates
        BILL.STATUS = 'SETTLED'
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the settled bill generated
    NEXT FUT.SCHD
    R.BILL.DETAILS = AA.PaymentSchedule.BillDetails.Read(BILL.ID, BILL.DET.ERR)
    LAST.PAID.AMOUNT=R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
    LAST.PAID.DATE=R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
    
    BILL.ID = ''; TOTAL.DUE.AMOUNT = 0;
    LAST.PAYMENT.DATE =  FUTURE.DATES<SAVE.FUTR.SCHD.COUNT>   ;* Read the last payment date of the future schedule date
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",PAID.DATE, PAID.AMOUNT, PAID.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Call routine to get paid out schedules till the date given
    PAID.SCHEDULES = DCOUNT(PAID.DATES,@FM)     ;* Total Number of Schedule dates
    FOR SCHD = 1 TO PAID.SCHEDULES
        PAYMENT.DATE = PAID.DATES<SCHD>
        BILL.STATUS = "AGING":@VM:"DUE":@VM:"DEFER"
        GOSUB GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT  ;* Count the aged bill generated
        IF SCHD.COUNT THEN
            R.BILL.DETAILS = AA.PaymentSchedule.BillDetails.Read(BILL.ID, BILL.DET.ERR)
            TOTAL.DUE.AMOUNT += R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
        END
    NEXT SCHD
    
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Get overdue schedule count by reading the aged bills>
GET.OVERDUE.FUTR.SETTLED.SCHD.COUNT:
*----------------------------------
*Get the Bill Id which has status as AGING for a date lt today/ SETTLED for a date gt today

    BILL.REFERENCES = ''; SCHD.COUNT = 0;
    AA.PaymentSchedule.GetBill(ARR.ID,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)        ;* Call routine to get bill details based on status
    IF BILL.REFERENCES THEN
        BILL.ID = BILL.REFERENCES
        SCHD.COUNT = DCOUNT(BILL.REFERENCES,@VM)   ;* Count of bill ids
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------
*** <region name = Get customer details>
GET.COMMITMENT.AMOUNT:
*------------------------
*****Retrive the interest and charge schedule details*****
    BALANCE.DETAILS = ''; COMMITMENT.BAL = ''; NO.OF.DETAILS = '';
    REQUEST.TYPE = ''; REQUEST.TYPE<3> = 'ALL'; REQUEST.TYPE<2> = 'ALL'
    AA.Framework.GetPeriodBalances(ACCOUNT.NUMBER,"TOTCOMMITMENT",REQUEST.TYPE,START.DATE,'','',BALANCE.DETAILS,'')
    NO.OF.DETAILS = DCOUNT(BALANCE.DETAILS<1>,@VM)
    COMMITMENT.BAL = BALANCE.DETAILS<4,NO.OF.DETAILS>
    IF COMMITMENT.BAL LT 0 THEN
        COMMITMENT.BAL = FIELD(COMMITMENT.BAL,'-',2)
    END
            
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------

END

