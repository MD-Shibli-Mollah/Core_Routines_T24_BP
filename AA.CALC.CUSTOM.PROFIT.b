* @ValidationCode : MjotNzcwODkyNTM2OkNwMTI1MjoxNTkzMTU1MDIyOTYxOmtjaGFuZHJha2FudGg6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6LTE6LTE=
* @ValidationInfo : Timestamp         : 26 Jun 2020 12:33:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kchandrakanth
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.PaymentSchedule
SUBROUTINE AA.CALC.CUSTOM.PROFIT(ARRANGEMENT.ID, INT.PROPERTY.ID, INTEREST.RECORD, INT.PROPERTY.DATE, TOTAL.PROFIT, CALC.ERR)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* This routine was developed based on a client requirement in which for a contract with Flat rate RTAE.TYPE in the interest
* Condition, when there are multiple disbursemnts and in between disbursements when there is a change in the term, then
* for profit calculation, Change in term should only be considered for the future disbursements . For the already crossed
* disbursements, the orginal term at the time of the respective deisbursemnt should hold for frofit calculation.
*-----------------------------------------------------------------------------
* @class AA.PaymentSchedule
* @package retaillending.AA
* @stereotype subroutine
* @link AA.DETERMINE.PROFIT.AMOUNT
* @author kchandrakanth@temenos.com
*-----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param  ArrangementId  Arrangement id   Arrangement contract id
* @param  IntPropertyId  The interest property name
* @param  InterestRecord  The interest property record
* @param  IntPropertyDate Interest Property effective date
*
* Output
*
* @return TotalProfit  Local calculated profit amount
* @return CalcErr      Error
*
*** </region>
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/06/2020 - Task : 3808414
*              Enh  : 3731573
*              New routine introduced to fetch the DUE/CAP in case of DUE.AND.CAP payment types.
*
*-----------------------------------------------------------------------------

    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AC.Fees
    $USING EB.Service
    $USING EB.DataAccess
    $USING ST.RateParameters
    $USING AA.Customer
    $USING AA.TermAmount
    $USING EB.API
    
    
    GOSUB INITIALISE             ;* Initialise local variables  
    GOSUB CHECK.BASIC.DETAILS    ;* Check for any errors
    IF NOT(CALC.ERR) THEN        ;* Check if required info is present
        GOSUB MAIN.PROCESS           ;* Main process logic
    END  
  
RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise a local variables </desc>
INITIALISE:

    TOTAL.PROFIT = 0    ;* variable to store total profit
    CALC.ERR = ""       ;* Error variable
    CURRENCY = ""       ;* Currency
    RET.ERR = ""  
    
    R.ACCOUNT.DETAILS = AA.Framework.getAccountDetails()    ;* Get the account details record form common
    MATURE.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdMaturityDate>   ;*Arrangement mature date
    ARR.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdValueDate> ;* Arrangement start date
    CURRENCY = AA.Framework.getArrCurrency()
    
RETURN  
       
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Check basic details </desc>
CHECK.BASIC.DETAILS:

    BEGIN CASE
        CASE NOT(ARRANGEMENT.ID)    ;* Arrangement Id is mandatory
            CALC.ERR = 1
            
        CASE NOT(INT.PROPERTY.ID)   ;* Property name is mandatory
            CALC.ERR = 1
            
        CASE INTEREST.RECORD EQ ""  ;* Interest property record is mandatory
            CALC.ERR = 1
    END CASE

    
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Main process </desc>
MAIN.PROCESS:
    
    FLAT.RATE = INTEREST.RECORD<AA.Interest.Interest.IntEffectiveRate> ;* Rate taken from effective rate of interest record
    INT.DATA = ""
    AC.Fees.EbUpdateIntBalances(INT.DATA, ARR.DATE, FLAT.RATE, "", "")
    
    GOSUB GET.INTEREST.ACCRUALS          ;* Get the interest accrulas details
    GOSUB BUILD.SCHEDULE.RECORD          ;* Build the payment schedule record
    GOSUB ADD.DISBURSEMENTS.TILL.DATE    ;* Calculate the flat profit amount for the past disbursments
    
    IF CALCULATE.FULL.PROFIT THEN        ;* For NEW-ARRANGEMENT or when include prin amounts flag is set in PS, consder the future disbursements also for flat rate profit calculation in addation to the past deisbursemnts
        
        GOSUB ADD.FUTURE.DISBURSEMENTS   ;* Get the future disbursement details from projection
        MATURE.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdMaturityDate>   ;*Arrangement mature date
        GOSUB GET.PROFIT.FOR.DISBURSEMENTS    ;* Calculate the profit for future disbursments
        TOTAL.PROFIT += TOTAL.INTEREST
                     
    END
    CALC.PROFIT.AMT = ABS(TOTAL.PROFIT) ;* calculate profit amount
    AMOUNT = CALC.PROFIT.AMT
    GOSUB ROUND.AMOUNT      ;* round off calculated amount
    CALC.PROFIT.AMT = AMOUNT
   
    TOTAL.PROFIT = CALC.PROFIT.AMT
        
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Get the inerest accruals </desc>
GET.INTEREST.ACCRUALS:

    R.ACCRUAL.DETAILS = ''
    R.ACCRUAL.DATA = ''
 
** Get the accrual details from interest accruals.
    AA.Interest.GetInterestAccruals("VAL", ARRANGEMENT.ID, INT.PROPERTY.ID, "", R.ACCRUAL.DATA, R.ACCRUAL.DETAILS, "", "")
    
    FOR YFLD = AC.Fees.EbAcFromDate TO AC.Fees.EbAcCompoundYield   ;* Silly code, EB.PERFORM.ACCRUAL crashes out if null!!
        R.ACCRUAL.DATA<YFLD> = ""       ;* Create a null marker
    NEXT YFLD
        
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Build the Payment schedule record </desc>
BUILD.SCHEDULE.RECORD:

*** Project the future schedules to look for disbursement schedules
    SCHEDULE.INFO = ""
    SCHEDULE.INFO<1> = ARRANGEMENT.ID
    SCHEDULE.INFO<2> = INT.PROPERTY.DATE

    PAY.SCHED.PROPERTY = ""
    AA.PaymentSchedule.BuildPaymentScheduleRecord(SCHEDULE.INFO, ARRANGEMENT.ID, "", "", R.PAYMENT.SCHEDULE, RET.ERROR)  ;* build the payment schedule record
    
    CALCULATE.FULL.PROFIT = ""
    IF AA.Framework.getNewArrangement() OR R.PAYMENT.SCHEDULE<AA.PaymentSchedule.PaymentSchedule.PsIncludePrinAmounts> THEN
        CALCULATE.FULL.PROFIT = 1   ;* For NEW-ARRANGEMENT or when include prin amounts flag is set in PS, consder the future disbursements also for flat rate profit calculation in addation to the past deisbursemnts
    END
        
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Get the profit for disbursements </desc>
GET.PROFIT.FOR.DISBURSEMENTS:

*** In this para we will accrue and calculate the interest amount from disbursement date to maturity date.
*** For future disbursements the maturity date will be the current existing maturity date in account details.
*** For past disbursements the maturity date will be the maturity date on the corresponding past disbursement date.
    TOTAL.INTEREST = 0  
    ACCRUE.TO.DATE = MATURE.DATE  
    AA.Customer.GetArrangementCustomer(ARRANGEMENT.ID, "", "", "", "", CONT.CUSTOMER, RET.ERROR)
    DAY.BASIS = INTEREST.RECORD<AA.Interest.Interest.IntDayBasis> ;*Get day basis
    ACCRUAL.RULE = INTEREST.RECORD<AA.Interest.Interest.IntAccrualRule> ;*Get accrual rule
*
    CALC.PERIOD = ""
    CALC.PERIOD<AC.Fees.EbAcdRecordStart> = ARR.DATE
    CALC.PERIOD<AC.Fees.EbAcdAccrStart> = ARR.DATE
    CALC.PERIOD<AC.Fees.EbAcdAccrEnd> = MATURE.DATE
    CALC.PERIOD<AC.Fees.EbAcdContractId> = ARRANGEMENT.ID
    CALC.PERIOD<AC.Fees.EbAcdAccrualParam> = ACCRUAL.RULE
    
    FOR YFLD = AC.Fees.EbAcFromDate TO AC.Fees.EbAcCompoundYield   ;* Silly code, EB.PERFORM.ACCRUAL crashes out if null!!
        R.ACCRUAL.DATA<YFLD> = ""         ;* Create a null marker
    NEXT YFLD
    
*** Accrue and calculat the interest for the period specified.
    AC.Fees.EbPerformAccrual(R.ACCRUAL.DATA, PRIN.DATA, INT.DATA, CALC.PERIOD, CURRENCY, CONT.CUSTOMER, DAY.BASIS,  ACCRUE.TO.DATE, "", "", "", TOTAL.INTEREST)
        
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Calculate the profit for all the disbursements till now </desc>
ADD.DISBURSEMENTS.TILL.DATE:
       
    BILL.DATES = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillPayDate>
    TOT.BILL.DATE.CNT = DCOUNT(BILL.DATES, @VM)
    FOR BILL.DATE.CNT = 1 TO TOT.BILL.DATE.CNT      ;* Loop through the account details to check for past disbursemnt dates.
    
        DATE.BILLS = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId, BILL.DATE.CNT>   ;* get the bills for this date
        DATE.BILL.TYPES = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillType, BILL.DATE.CNT>
        TOT.BILL.TYPE.CNT = DCOUNT(DATE.BILL.TYPES, @SM)
        FOR BILL.TYPE.CNT = 1 TO TOT.BILL.TYPE.CNT
            GOSUB CHECK.FOR.DISBURSEMENT            ;* Check if there is a disbursement bill
        NEXT BILL.TYPE.CNT
                    
    NEXT BILL.DATE.CNT
                  
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Get the maturity date as on disbursemnt date </desc>
GET.ACTUAL.MATURITY.DATE:

*** For past disbursements, metch the maturity date as on the past disbursement date (Based on client requirement)
    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "TERM.AMOUNT", "", CHECK.DATE, "", R.TERM.AMOUNT, Y.ERR)
    R.TERM.AMOUNT = RAISE(R.TERM.AMOUNT)
    ACTUAL.MATURE.DATE = R.TERM.AMOUNT<AA.TermAmount.TermAmount.AmtMaturityDate>
        
RETURN
      
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Check for future disbursements </desc>
ADD.FUTURE.DISBURSEMENTS:

*** Project the future schedule to get the future disbursement dates
    FUTURE.PAYMENT.DATES = ''
    FUTURE.PAYMENT.TYPES = ''
    FUTURE.PAYMENT.METHODS = ''
    FUTURE.PAYMENT.PROPERTIES = ''
    FUTURE.PAYMENT.PROPERTIES.AMOUNTS = ''
    FUTURE.BILL.TYPES = ""
    PRIN.DATA = "" ;* reset the prin data as we have already accrued for past profit amount

*** Fetch the future schedule dates
    AA.PaymentSchedule.BuildPaymentScheduleSchedules(SCHEDULE.INFO, "", "", "", FUTURE.PAYMENT.DATES, FUTURE.PAYMENT.TYPES, FUTURE.PAYMENT.METHODS, "", FUTURE.PAYMENT.PROPERTIES, FUTURE.PAYMENT.PROPERTIES.AMOUNTS, "" , "", "", "", "", "", FUTURE.BILL.TYPES, "", RETURN.ERROR)
    TOT.PAY.DATE.CNT = DCOUNT(FUTURE.PAYMENT.DATES, @FM)
    FOR PAY.DATE.CNT = 1 TO TOT.PAY.DATE.CNT    ;* loop through the future payment dates to find disbursment schedules
               
        SYS.BILL.TYPE = ""
        TOT.BILL.TYPES = DCOUNT(FUTURE.BILL.TYPES<PAY.DATE.CNT>, @VM) ;* look for disbursement bills
        FOR BILL.TYPE.CNT = 1 TO TOT.BILL.TYPES
            GOSUB CHECK.ADD.DISBURSEMENT.AMOUNT    ;* check and add disbursemnt amount
        NEXT BILL.TYPE.CNT
             
    NEXT PAY.DATE.CNT
                
RETURN
          
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Round amount>
*** <desc>Calculate rounded amount</desc>
ROUND.AMOUNT:
   
** Round the calculated amount
    EB.API.RoundAmount(CURRENCY, AMOUNT, '', '')

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.FOR.DISBURSEMENT>
*** <desc>Check if there is a disbursemnt on this date</desc>
CHECK.FOR.DISBURSEMENT:
   
    SYS.BILL.TYPE = ""
    AA.PaymentSchedule.GetSysBillType(DATE.BILL.TYPES<1,1,BILL.TYPE.CNT>, SYS.BILL.TYPE, TYP.ERR)
    IF SYS.BILL.TYPE EQ "DISBURSEMENT" THEN
                
        BILL.REF = DATE.BILLS<1,1,BILL.TYPE.CNT>
        AA.PaymentSchedule.GetBillDetails(ARRANGEMENT.ID, BILL.REF, R.BILL.DETAILS, BILL.ERR)
        IF R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus, 1> EQ "SETTLED" THEN

*** If there was a past disbursement, then calculate the profit amount for that disbursement amount.
*** The maturity date for this amount should be the maturity date as on the past disbursement date.
            PRIN.DATA = ""
            ADD.AMT = R.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPropAmount>
            AC.Fees.EbUpdatePrinBalances(PRIN.DATA, BILL.DATES<1, BILL.DATE.CNT>, ADD.AMT)
            CHECK.DATE = BILL.DATES<1, BILL.DATE.CNT>
            GOSUB GET.ACTUAL.MATURITY.DATE    ;* get the maturity date as on the past disbursemnt date
            MATURE.DATE = ACTUAL.MATURE.DATE
            GOSUB GET.PROFIT.FOR.DISBURSEMENTS   ;* calculate the flat rate profit for disbursement amount.
            TOTAL.PROFIT += TOTAL.INTEREST
                        
        END
                    
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.ADD.DISBURSEMENT.AMOUNT>
*** <desc>Check and add the disbursement amount for profit calculation</desc>
CHECK.ADD.DISBURSEMENT.AMOUNT:

    SYS.BILL.TYPE = ""
    AA.PaymentSchedule.GetSysBillType(FUTURE.BILL.TYPES<PAY.DATE.CNT, BILL.TYPE.CNT>, SYS.BILL.TYPE, TYP.ERR)
    IF SYS.BILL.TYPE EQ "DISBURSEMENT" THEN
 
*** If a disbursemnt date is found, consider this amount for interst calculation.
        DISBURSEMENT.DATE = FUTURE.PAYMENT.DATES<PAY.DATE.CNT>
        DISBURSEMENT.AMT = FUTURE.PAYMENT.PROPERTIES.AMOUNTS<PAY.DATE.CNT, BILL.TYPE.CNT>
        AC.Fees.EbUpdatePrinBalances(PRIN.DATA,DISBURSEMENT.DATE,DISBURSEMENT.AMT)
                   
    END


RETURN
*** </region>
*-----------------------------------------------------------------------------
    
END

    
