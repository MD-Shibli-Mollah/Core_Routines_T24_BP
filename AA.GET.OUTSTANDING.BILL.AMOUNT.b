* @ValidationCode : Mjo1OTU5OTQwNjY6Q3AxMjUyOjE2MTU5NjE3ODg0MTk6bWFyY2hhbmE6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwNS0wNjM2OjIzMToxMzY=
* @ValidationInfo : Timestamp         : 17 Mar 2021 11:46:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : marchana
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 136/231 (58.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210305-0636
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-89</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Settlement
SUBROUTINE AA.GET.OUTSTANDING.BILL.AMOUNT(ARRANGEMENT.ID, BILL.REFERENCE, BILL.DETAILS, OS.AMT, RET.ERROR)
 
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
** This which should return the outstanding bill amount for the passed bill reference.
** This routine will be called from RC module as pre and post routine to get the outstanding amount for the passed bill reference.
**
**
** INCOMING.ARGUMENTS:
*
** ArrangementId   - Arrangement reference id
** BillReference   - Bill reference id
*
*** OUTGOING.ARGUMENTS:
*
** BillDetails  - Will returns bill details record
** OsAmt        - Outstanding bill amount
** RetError     - Return with error msg if Record not found
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History :
*
* 10/07/13 - Task : 662714
*            Enhancement : 663005
*            This Routine will return the Outstanding bill amount if bill reference is passed.
*
* 27/05/14  - Enhancement : 713751
*             Task : 1003629
*             New arguement CHARGEOFF.TYPE is added in AA.GET.BILL.PROPERTY.AMOUNT.
*
* 12/01/17 - Task : 1981883
*            Defect : 1976620
*            System should return the outstanding amount as summation of current payment type
*            when it has more than one property and os total amount of the bill.
*
* 12/04/19  - Defect : 3057598
*             Task   : 3083997
*             RC credited the loan excess amount when payment schedule bill generated on holiday.
*
* 18/06/20 - Task : 3812866
*            Enhancement : 3443386
*            Combine Bill Settlement throught T24 Account
*
* 12/02/20 - Task   : 4110593
*            Defect  : 4068679
*            Check whether adjust and reaccrue required for accrual by bills property when repayment done through RC.
*
* 04/03/2 - Task    : 4265907
*           Defect  : 4236196
*           Check whether adjust and reaccrue required for accrual by bills property when repayment done through RC for online scenario.
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>
    
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AC.Fees
    $USING EB.API
    $USING EB.Service
    $USING EB.SystemTables
    $USING EB.Utility
    

*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>


    GOSUB INITIALISE          ;* Initialise the local variables here...

    GOSUB GET.BILL.DETAILS    ;* Get bill details

    IF BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1> NE "WRITEOFF" THEN
        GOSUB PROCESS.BILL        ;* Get outstanding amount for the passed bill reference
    END

RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>

INITIALISE:

    OS.AMT = 0
    BILL.PROPERTY.AMOUNT = 0
    RETRY.DATE = ''
    CUR.JOB.NAME = EB.Service.getBatchInfo()<3>
    
    RETRY.DATE = ARRANGEMENT.ID<2> ;* If retry date passed form RC routine get and re-assign

    ARRANGEMENT.ID = ARRANGEMENT.ID<1>
        
    ARR.RECORD = ''
    SOURCE.BALANCE = ''
    R.ARR.PRODUCT = ''
    PRODUCT.ID = ''
    PROCESS.FLAG = 1
    REACCRUE.REQD = 0
    
RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Get the bill details>
*** <desc>Get the details</desc>
GET.BILL.DETAILS:

    BILL.DETAILS = ''
    RET.ERROR = ''
    AA.PaymentSchedule.GetBillDetails(ARRANGEMENT.ID,BILL.REFERENCE,BILL.DETAILS,RET.ERROR)

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= Process>
*** <desc> Process the bill</desc>

PROCESS.BILL:

    IF RET.ERROR THEN
        RETURN      ;* Return with error msg if Record not found
    END ELSE
        IF BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType> EQ 'COMBINE.BILL' THEN ;* get total outstanding amount from combined bill if payment type is COMBINE.BILL
            GOSUB GET.COMBINE.BILL.OS.AMT
        END ELSE
            OS.AMT = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount>        ;* Outstanding bill amount if any
    
            GOSUB GET.CURRENT.AMOUNT        ;* Get PE amount if any
            OS.AMT + = BILL.PROPERTY.AMOUNT
        END
    END

RETURN

*--------------------------------------------------------------------------
*** <region name= Get the COMBINE bill property amount>
*** <desc>Get the COMBINE bill property amount</desc>
GET.COMBINE.BILL.OS.AMT:
** get the linked bill details from Bill details and retrieve the current amount of each bill reference
** sum the current amounts of all the bills and return the combined bill amount as outstanding bill amount

    BILL.REF.LIST = ''
    BILL.REF.LIST =  BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdLinkedBillId> ;* get the drawing bill references of the combine bill
    
    COMBINE.BILL.DETAILS = BILL.DETAILS ;* store the combine bill details to temporary variable to get accrue by bill amount if any
    COMBINE.BILL.REFERENCE = BILL.REFERENCE ;*  store the combine bill reference  to temporary variable  to get accrue by bill amount if any
    
    LOOP
        REMOVE BILL.ID FROM BILL.REF.LIST SETTING BillRefPos
    WHILE BILL.ID
        BILL.REFERENCE = BILL.ID
        GOSUB GET.BILL.DETAILS  ;* get bill details
        OS.AMT += BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> ;* get the os amount of each bill reference
    REPEAT
    
    
    BILL.REF.LIST = BILL.REF.LIST
    LOOP
        REMOVE LINKED.BILL.ID FROM BILL.REF.LIST SETTING pos
    WHILE LINKED.BILL.ID
        BILL.REFERENCE = LINKED.BILL.ID
        GOSUB GET.BILL.DETAILS  ;* get bill details of linked drawing bill
        GOSUB GET.CURRENT.AMOUNT        ;* Get PE amount if any
        OS.AMT + = BILL.PROPERTY.AMOUNT
    REPEAT
    
    BILL.DETAILS = COMBINE.BILL.DETAILS ;* retain the combine bill details from temporary variable to get accrue by bill amount if any
    BILL.REFERENCE = COMBINE.BILL.REFERENCE ;*  retain the combine bill reference from temporary variable to get accrue by bill amount if any
    
RETURN
*--------------------------------------------------------------------------
*** <region name= Get the CURRENT bill property amount>
*** <desc>Get the CURRENT bill property amount</desc>

GET.CURRENT.AMOUNT:

    PROCESS.TYPE = 'DUE'
    CURRENT.TYPE.FOUND = ''
    
    GOSUB GET.PAYMENT.TYPE.POSITION
    
    IF CURRENT.TYPE.FOUND THEN
        GOSUB GET.BILL.PROPERTY.AMOUNT
    END

RETURN
*** </region>
*--------------------------------------------------------------------------

*** <region name= Payment Type position>
*** <desc>Locate payment type position</desc>
GET.PAYMENT.TYPE.POSITION:

    CURRENT.TYPE.FOUND = ''
    PROPERTIES  = ''
    
    LOCATE 'CURRENT' IN BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType, 1> SETTING PAY.POS THEN    ;* Is it found in the Bill
        PROPERTIES = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPayProperty, PAY.POS>    ;* ACCRUE.BY.BILLS property would updated under CURRENT payment type in the bill.
        CURRENT.TYPE.FOUND = 1
    END ELSE
        GOSUB GET.CURRENT.INT.PROPERTIES
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Current Int Properties>
*** <desc>Get Current Interest properties from product</desc>
GET.CURRENT.INT.PROPERTIES:

*** Look in the arrangement record to find the properties for the arrangement
*
    PROP.LIST = ''
    PROP.CLASS.LIST = ''
    AA.Framework.GetArrangementProperties(ARRANGEMENT.ID, RETRY.DATE, R.ARRANGEMENT, PROP.LIST)

    AA.ProductFramework.GetPropertyClass(PROP.LIST, PROP.CLASS.LIST)  ;* get list of property classes
    LOOP
        REMOVE PROPERTY.CLASS FROM PROP.CLASS.LIST SETTING CLASS.POS
        REMOVE PROPERTY FROM PROP.LIST SETTING PROP.POS
    WHILE PROPERTY.CLASS
        IF PROPERTY.CLASS EQ "INTEREST" THEN
            R.PROPERTY.REC = ''
            AA.Framework.LoadStaticData('F.AA.PROPERTY', PROPERTY, R.PROPERTY.REC, RET.ERROR)
            LOCATE "ACCRUAL.BY.BILLS" IN R.PROPERTY.REC<AA.ProductFramework.Property.PropPropertyType,1> SETTING ABB.POS THEN
                CURRENT.TYPE.FOUND = 1  ;* Fetch the accrue by bill related properties of the arrangement
                PROPERTIES<1,1,-1> =  PROPERTY
            END
        END
    REPEAT

RETURN
** </region>
*-----------------------------------------------------------------------------

*** <region name= Get the bill property amount>
*** <desc>Get the bill property amount</desc>

GET.BILL.PROPERTY.AMOUNT:

    GOSUB CHECK.REACCRUE.REQD
    GOSUB STORE.BASE.DETAILS
    
    LOOP
        REMOVE PROPERTY FROM PROPERTIES SETTING PROP.POS
    WHILE PROPERTY

        PROPERTY.AMOUNT = 0
        GOSUB GET.INTEREST.ACCRUALS
        IF REACCRUE.REQD THEN
            GOSUB FIND.CONTRIBUTION.BILL
        END
        IF RETRY.DATE AND REACCRUE.REQD THEN    ;*  Called from RC.PREP.AA, adjust and reaccrue logic required to get the ACCRUE.BY.BILLS property amount.
            GOSUB GET.PROPERTY.AMOUNT
        END ELSE    ;* This call is from RC.POST.AA, Since bill details would have updated during apply payment, we do not need any special calculation to get the penalty interest amount.
            AA.PaymentSchedule.GetBillPropertyAmount(PROCESS.TYPE, '', 'CURRENT', PROPERTY, '', BILL.DETAILS, PROPERTY.AMOUNT, PROPERTY.AMOUNT.LCY, ERR.MSG)         ;*Get the property amount
        END
        BILL.PROPERTY.AMOUNT += PROPERTY.AMOUNT
    REPEAT

    GOSUB RESTORE.BASE.DETAILS

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= Re accrue required>
*** <desc>Check re accrue required</desc>
CHECK.REACCRUE.REQD:

    PREV.WORKING.DAY = EB.SystemTables.getToday()
    COB.EOD = ""    ;* Flag to indicate COB EOD process
    COB.SOD = ""    ;* Flag to indicate COB SOD process
    SPLIT.MONTH.END.ACCRUALS = ""       ;* Split month end flag

    GOSUB CHECK.RC.RUNNING.STATUS       ;* Check whetehr RC is running in COB

** This logic is to check whether the reaccrual required to get the penalty interest contribution when the contribution split
** into more than one bill and also it is in reverse and replay.
** During EOD the PERIOD.END DATE indicates the close of business date which is a next working day minus one calendar date.
** If the period end date is equal to the today, system doesn't have any activity to process RR and there is no need to re-accrue.

    IF CUR.JOB.NAME EQ 'RC.CYCLER' THEN
        BEGIN CASE

            CASE COB.EOD
*        IF (EB.SystemTables.getToday() NE EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)) OR SPLIT.MONTH.END.ACCRUALS THEN
                REACCRUE.REQD = 1
*        END
    
** During SOD, LAST.PERIOD.END indicates the period end date of the EOD section of the previous COB.
            CASE  COB.SOD
        
                EB.API.Cdt('',PREV.WORKING.DAY,'-1C')
                IF PREV.WORKING.DAY NE EB.SystemTables.getRDates(EB.Utility.Dates.DatLastPeriodEnd) THEN
                    REACCRUE.REQD = 1
                END
        
            CASE 1 ;* during online service also, penaltyinterest should be recalculated if retry.date is less than today
   
                IF  EB.SystemTables.getRunningUnderBatch() AND RETRY.DATE LT PREV.WORKING.DAY THEN
                    REACCRUE.REQD = 1
                END
        
        END CASE

    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check RC Running Status>
*** <desc>Check RC job is running as part of COB</desc>
CHECK.RC.RUNNING.STATUS:

*** Re accrued is rquired in below cases
** 1. only when RC job is running UNDER COB
** 2. In case of Split Month End EOD
**    Ex - Scenarios like 13-Dec is working day 1, 2, 3 jan are holiday. when COB ran from 31 to 4th SOD accruals
**    will not come. So as part of RC setlement Re accrue should happen during EOD of 5th Jan

    IF EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ "B" THEN

        IF EB.Service.getCBatchStartDate() NE EB.SystemTables.getToday() THEN
            COB.SOD = 1
        END ELSE
            COB.EOD = 1
        END

*** In this scenario TODAY = 20100105 and LST.PERIOD.END = 20091231
        IF EB.SystemTables.getToday()[5,2] NE EB.SystemTables.getRDates(EB.Utility.Dates.DatLastPeriodEnd)[5,2] THEN
            SPLIT.MONTH.END.ACCRUALS = 1
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Find Contributted Bill>
*** <desc>Find Contributed Bill</desc>
FIND.CONTRIBUTION.BILL:
    
* To ignore non-contributed bill for penalty interest adjust/reaccrue calculation
    IF PROCESS.FLAG THEN
        PERIOD.START.DATE = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
        AA.Framework.GetArrangementProduct(ARRANGEMENT.ID, PERIOD.START.DATE, ARR.RECORD, PRODUCT.ID, '')        ;* Get product ID
        AA.ProductFramework.GetPublishedRecord('PRODUCT', '', PRODUCT.ID, PERIOD.START.DATE, R.ARR.PRODUCT, RET.ERROR) ;* Get the published product record
        PROCESS.FLAG = ''
    END
    AA.Framework.GetPropertyBalance(PROPERTY, R.ARR.PRODUCT, SOURCE.BALANCE)   ;*Get source balance of property
    AA.Framework.GetRealBalance(SOURCE.BALANCE, BALANCE.TO.CHECK)    ;*Resolve virtual balance if any
        
    PRIN.DATA = ''
    ARRANGEMENT.DATA = ARRANGEMENT.ID
    ARRANGEMENT.DATA<2> = "UPDATE"  ;* REVERSE,UPDATE etc.
    ARRANGEMENT.DATA<3> = PROPERTY  ;* Current property.
    AA.Interest.GetBillBalances(ARRANGEMENT.DATA, BILL.REFERENCE, BILL.DETAILS, BALANCE.TO.CHECK, PRIN.DATA, '', RET.ERR) ;* Get PRIN.DATA
 
    IF SUM(PRIN.DATA<AC.Fees.EbAcpPrinAmount>) ELSE
        REACCRUE.REQD = 0
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Store base details>
*** <desc>Store base details</desc>
STORE.BASE.DETAILS:
    
    SAVE.R.ARRANGEMENT = AA.Framework.getRArrangement()
    SAVE.AA.LINKED.ACCOUNT = AA.Framework.getLinkedAccount()
    SAVE.CURRENCY = AA.Framework.getArrCurrency()
        
    R.ARRANGEMENT = ''
    AA.Framework.GetArrangement(ARRANGEMENT.ID, R.ARRANGEMENT, ARR.ERROR)       ;* Load Arrangement record
    AA.Framework.setRArrangement(R.ARRANGEMENT)

    
    AA.Framework.setArrCurrency(R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>)
    LOCATE "ACCOUNT" IN R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedAppl,1> SETTING POS THEN
        AA.Framework.setLinkedAccount(R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId,POS>);* Assign the common to get account id
    END
    
    RECORD.START.DATE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>
  
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Restore base details>
*** <desc>Restore base details</desc>
RESTORE.BASE.DETAILS:
    
    AA.Framework.setRArrangement(SAVE.R.ARRANGEMENT)
    AA.Framework.setLinkedAccount(SAVE.AA.LINKED.ACCOUNT)
    AA.Framework.setArrCurrency(SAVE.CURRENCY)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = GET.INTEREST.ACCRUALS>
*** <desc>Get Interest Accruals </desc>
GET.INTEREST.ACCRUALS:
 
    R.ACCRUAL.DATA = ""
    R.ACCRUAL.DETAILS = ""
    AA.Interest.GetInterestAccruals("VAL", ARRANGEMENT.ID, PROPERTY, "", R.ACCRUAL.DATA, R.ACCRUAL.DETAILS, "", "") ;*Get Accrual details
    TOT.ACCR.AMT = R.ACCRUAL.DETAILS<AA.Interest.InterestAccruals.IntAccTotAccrAmt>
    ABB.NEW.METHOD = R.ACCRUAL.DETAILS<AA.Interest.InterestAccruals.IntAccAbbNewMethod> ;* Accrue by bills - new method flag
    LAST.ACCRUE.DATE = R.ACCRUAL.DATA<AC.Fees.EbAcToDate,1>
    IF ABB.NEW.METHOD THEN
        IF NOT(LAST.ACCRUE.DATE) THEN
            R.BILLACCRUAL.DATA = ""
            ARRANGEMENT.ID<2> = BILL.REFERENCE
            AA.Interest.GetInterestAccruals("VAL", ARRANGEMENT.ID, PROPERTY, "", R.BILLACCRUAL.DATA, '', '', '')    ;* Fetch live interest accrual record
            LAST.ACCRUE.DATE = R.BILLACCRUAL.DATA<AC.Fees.EbAcToDate,1> ;* for accrue by bills property we need to check accruals bill wise
        END
    END ELSE
        REACCRUE.REQD = 0   ;* We are doing the reaccrual processing only for Accrue by bills - new method
    END
    
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= Property Amount>
*** <desc>Get propery amount for the payment type </desc>
GET.PROPERTY.AMOUNT:

    AA.ProductFramework.PropertyGetBalanceName(ARRANGEMENT.ID, PROPERTY, "ACC", "", "", BALANCE.TYPE) ;* Get property balance name

    R.ADJUST.ACCRUAL.DATA = ""
    R.REACCRUAL.DETAILS = ""

    ACCRUE.TO.DATE = RETRY.DATE
    PERIOD.END.DATE = ACCRUE.TO.DATE
    IF ACCRUE.TO.DATE MATCHES "8N" THEN
        EB.API.Cdt('', ACCRUE.TO.DATE, '-1C')   ;*Accrue before the suspension date
    END
    ADJUST.DATE = ACCRUE.TO.DATE
    ADJUST.INT = ""
*Adjust & Reaccrue till a day prior to effective date
    
    GOSUB DETERMINE.REACCRUE.ADJUST     ;* To check if the reaccrue and readjust is needed based on past accrual date and RC retry date
    
    IF ACCRUE.TO.DATE OR ADJUST.DATE THEN
        ARR.ID = ARRANGEMENT.ID:@FM:BILL.REFERENCE:@FM:"RC.OS.AMT"
        AA.Interest.GetReaccrueDetails(ARR.ID, PROPERTY, RECORD.START.DATE, ADJUST.DATE, ACCRUE.TO.DATE, '','', PERIOD.START.DATE, PERIOD.END.DATE, R.ADJUST.ACCRUAL.DATA, R.REACCRUAL.DETAILS, ADJUST.INT, COMMITTED.INT, RET.ERROR)
        PROPERTY.AMOUNT = COMMITTED.INT<1>
    
        IF PROPERTY.AMOUNT < 0 THEN
            PROPERTY.AMOUNT = 0
        END

    END ELSE
        AA.PaymentSchedule.GetBillPropertyAmount(PROCESS.TYPE, '', '', PROPERTY, '', BILL.DETAILS, PROPERTY.AMOUNT, PROPERTY.AMOUNT.LCY, ERR.MSG)         ;*Get the property amount
    END
   
RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= DETERMINE.REACCRUE.ADJUST>
*** <desc>Check when the system should do reaccrue and readjust </desc>
DETERMINE.REACCRUE.ADJUST:

    BEGIN CASE

* If no accrual has happed in T24 then we need to capture the amount directly from bill. So if EB.ACCRUAL.TO.DATE is not availabe then we do not accrue or adjust the amount during RC transaction.

        CASE PERIOD.END.DATE LE LAST.ACCRUE.DATE      ;* If the retry date is less than last accrual date then system will do both readjust and reaccrue
            ACCRUE.TO.DATE = ADJUST.DATE    ;* Accrual is required with Accrue To Date -1C
            ADJUST.DATE = PERIOD.END.DATE   ;* Adjustment is required with Adjust Date as Retry Date
        
        CASE ADJUST.DATE GT LAST.ACCRUE.DATE AND LAST.ACCRUE.DATE         ;* If the retry date -1C is greater than last accrual date then system will do only accrue
            ACCRUE.TO.DATE = ADJUST.DATE    ;* Accruals is required with Accrue To Date as Retry Date -1C
            EB.API.Cdt('',LAST.ACCRUE.DATE, "+1C")   ;*We need to stop the adjustment, even if the adjustment date is null, Wipe off the accruals happens for the full period.
* so, adjustment date is passed as a accrual date +1c . If the Adjustment date is greater than or equals to the Accrue to date then adjustment will be ignored.
            ADJUST.DATE = LAST.ACCRUE.DATE
        
        CASE ADJUST.DATE AND NOT(TOT.ACCR.AMT) AND NOT(LAST.ACCRUE.DATE)
            ACCRUE.TO.DATE = ADJUST.DATE    ;* Accrual is required with Accrue To Date -1C
            ADJUST.DATE = PERIOD.END.DATE   ;* Adjustment is required with Adjust Date as Retry Date
                        
        CASE 1
            ACCRUE.TO.DATE = ''
            ADJUST.DATE = ''
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
