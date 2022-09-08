* @ValidationCode : MjotNDQ1NjkwNjgzOkNwMTI1MjoxNjE1ODg5MDAwMjc5OmFiYXJuYS5zZWthcjoxMTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjI4NjoyMTU=
* @ValidationInfo : Timestamp         : 16 Mar 2021 15:33:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abarna.sekar
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 215/286 (75.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.SCHEDULE.PROJECTOR(SCHED.ARR)

*** <region name= Synopsis of the Routine>
***
* NOFILE Enquiry Routine triggered to project Schedules in an Arrangement. The Actual Projection is a Generic process
* handled by a different routine. This routine only acts as a Wrapper to format the data to Enquiry Requirements
*
* Mandatory Input : Arrangement ID
* Optional Inputs : Date ranges
* Return Parameter : SCHED.ARR variable holding the Schedule details according to Enquiry Requirements
*
*** </region>

*** <region name= Modification History>
***
*=======================================================================================================================
* 18/05/06         - EN_10002937
*                    New Module AA - Schedule Projector
*
* 13/02/08         - BG_100017039
*                    AA.ACTIVITY.INITIALISE called from here instead of
*                    AA.SCHEDULE.PROJECTOR
*
* 02/05/08         - EN_10003652
*                    Instead of storing the total payment, split it into 3 values namely
*                    Total Principal, Total Interest & Total Charge amounts.
*
* 16/05/08 - BG_100018434
*            Include a new argument TOT.PAYMENT denoting total due
*            amount for each payment date
*
* 28/11/08 - EN_10003938
*            Ref : SAR-2008-06-03-0007
*            New selection field SIM.REF
*            AA.ACTIVITY.INITIALISE is called from AA.SCHEDULE.PROJECTOR when NO.RESET is not set
*
* 13/01/09 - BG_100021546
*            Field Payment Method is also required for the enquiry.
*
* 03/04/09 - CI_10061648
*            Ref : HD0910278
*            The INFO type bill amounts also added to the Total due amounts not to Tot capital amts.
*
*
* 16/10/09 - CI_10066875
*            Add the Cap amount to the due amount for the last payment date.
*            Ref: HD0935773
*
* 04/09/10 - Task No: 83384 & Defect No: 73825 & Ref No: HD1031818
*            Projected Schedule Enquiry has incorrect figures for Deposits Product Line.
*
* 10/12/12 - Task No 537210 & Defect No 536282
*            While calculating the charges & principal need to add DUE type alone,No need to add PAY type.
*
* 21/03/16 - Task   : 1669742
*            Defect : 1664835
*            PRINCIPAL needs to be displayed to the Schedule When Payment method is PAY
*
* 20/01/17 - Task : 1993030
*            Def  : 1992426
*            System should display the charge amount when the payment method is set to capitalise.
*
* 27/03/17 - Task : 2066519
*            Defect : 2062661
*            The Total Cap Column is showing wrong data in the "Schedule" of AA Deposit overview
*
* 27/06/17 - Task   : 2174800
*            Defect : 2172744
*            PRINCIPAL needs to be displayed to the Schedule When Payment method is INFO because it has been repaid.
*
* 04/07/17 - Task : 2174805
*            Enhancement :2112191
*            Flexible Payment Limit & Excess Payment
*
* 01/09/17 - Task : 2256248
*            Def  : 2233388
*            Lending arrangements schedule projection should display correct output for Charge with TAX capitalisation.
*
* 27/03/18 - Task   : 2524751
*            Defect : 2520190
*            System should display due PERIODIC.CHARGES under CHARGE column in PAYMENT.SCHEDULE in the arrangement overview screen
*
* 10/12/18 - Enhancement : 2873157
*            Task : 2873160
*            Changes to display outstanding amount column with Principal and Profit amount
*
* 08/02/19 - Task   : 2982681
*            Enhan  : 2947685
*            Stop Schedule Projection Processing for info type of Properties
*
* 18/03/19 - Task   : 3040916
*            Def    : 3038688
*            Interest method and accounting mode should be read from Arrangement conditions
*
* 04/05/20 - Task   : 3725450
*            Defect : 3701819
*            System should display pay charge under CHARGE column in schedule projection
*
* 29/06/20 - Task : 3827598
*            Defect : 3808540
*            Changes done to show correct tax property projection based on source balance type for Interest Property
*
* 13/07/20 - Task :   3582604
*            Defect : 3766807
*            Bug fix to display outstanding amount column with Principal and Profit amount if there's some repayment on REC balance
*
* 05/02/21 - Defect :4146755
*            Task   :4215028
*            Projection changes for financial date as base for outstanding amount calculation of past schedules.
*
* 04/02/21 - Enhancement : 4213569
*            Task : 4213572
*            new field called INCLUDE.NON.CUSTOMER introduced in schedules enquiry to include or  exclude NON.CUSTOMER bills and future projection
*
*=======================================================================================================================
*** </region>

*** <region name= Inserts>

    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductManagement
    $USING AC.BalanceUpdates
    
*** </region>
 
  
*** <region name= Main Process>
***
    GOSUB INITIALISE          ;* Initialise Variables here
    GOSUB BUILD.BASIC.DATA    ;* Build the Schedule Details by calling the Projection Routine
    GOSUB BUILD.ARRAY.DETAILS ;* Format the Details according to Enquiry requirements

  
RETURN
*** </region>

RETURN


*** <region name= Initialise Variables>
***
INITIALISE:


    DUE.DATES = ''  ;* Holds the list of Schedule due dates
    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts
    DUE.PROPS = ''  ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   ;* Oustanding Bal for the date
    DUE.METHODS = ""
    PRODUCT.LINE = ""
    SCHED.ARR = ''

    ARR.ID = '' ; DATE.REQD = '' ; CYCLE.DATE = ''
    SIM.REF = ''
    
    ID.TO.CHECK = EB.Reports.getEnqSelection()<1>   ;* Get the name of Enquiry launched in Desktop or Browser or scripts
            
    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END
    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Pick the Simulation Reference
    END
 
    LOCATE 'DATE.FROM' IN EB.Reports.getEnqSelection()<2,1> SETTING DTFR THEN
        CYCLE.DATE = EB.Reports.getEnqSelection()<4,DTFR>        ;* if stated, pick the Start date from when Schedules are required
    END

    LOCATE 'DATE.TO' IN EB.Reports.getEnqSelection()<2,1> SETTING DTTO THEN
        CYCLE.DATE := @FM:EB.Reports.getEnqSelection()<4,DTTO>    ;* If stated, pick the End date till when Schedules are required
    END

    LOCATE 'FINANCIAL.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING FIDT THEN
        FIN.DATE = EB.Reports.getEnqSelection()<4,FIDT>    ;* If Financial date is selected, then get the value entered for the field
    END


    LOCATE 'INCLUDE.EXTERNAL.FEES' IN EB.Reports.getEnqSelection()<2,1> SETTING EXPOS THEN
        INCLUDE.INFO.OPTION = EB.Reports.getEnqSelection()<4,EXPOS>   ;* Get the Selection criteria
        NEW.ARR.ID<2> = INCLUDE.INFO.OPTION ;* Get all the bills for the Arrangement except External bills if arrangement id is given
    END
    
    LOCATE 'INCLUDE.NON.CUSTOMER' IN EB.Reports.getEnqSelection()<2,1> SETTING NONCUTPOS THEN
        INCLUDE.NON.CUSTOMERN.FLAG = EB.Reports.getEnqSelection()<4,NONCUTPOS>   ;* Get the Selection criteria
    END     ;*Get INTERNAL bills for the Arrangement except if include non.customer bill flag is given

    AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR) ;* Get the arrangement details using ARR.ID
    PRODUCT.LINE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine> ;*Get the product line from the arrangement details
    LOCATE "ACCOUNT" IN R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedAppl,1> SETTING POS THEN
        ACCOUNT.NO = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId,POS> ;* Get the account number
    END
        
    AA.Framework.GetSystemDate(SystemDate) ;* to get current system date
    effectiveDate = SystemDate
    
    AA.Framework.GetArrangementProduct(ARR.ID, effectiveDate, "", "", PropertyList) ;* Get arrangement Property list
    
    recBalanceArrangement = '' ;* Initialise variable which identifies REC balance type arrangement
    recInterestProperty = '' ;* Variable contains REC balance type related Interest Property
    setRecProfitAmount = '' ;* Variable used to calculate REC balance before interest schedules are processed
   
    loopCount = 1 ; loopCountFound = 1
    LOOP
    WHILE PropertyList<1,loopCount> AND loopCountFound ;* loop through all properties or till you get Interest property with interestMethod is Fixed and accountingMode is UPFRONT.PROFIT
        propertyClassName = ''
        propertyName = PropertyList<1,loopCount>
        AA.ProductFramework.GetPropertyClass(propertyName, propertyClassName) ;* Get Property class for property
         
        IF propertyClassName EQ "INTEREST" THEN
            propertyRecord = ''
            interestMethod = ''
            accountingMode = ''
            retError = ''
            Returnconditions = ''
            AA.Framework.GetArrangementConditions(ARR.ID, "", propertyName, "", "", Returnconditions, retError)
            propertyRecord = RAISE(Returnconditions)
            interestMethod = propertyRecord<AA.Interest.Interest.IntInterestMethod> ;* Return Interest method
            accountingMode = propertyRecord<AA.Interest.Interest.IntAccountingMode> ;* Return Accounting Mode
            
            IF interestMethod EQ "FIXED" AND accountingMode EQ "UPFRONT.PROFIT" THEN  ;* Condition to identify REC balance contracts
                loopCountFound = 0
                recBalanceArrangement = "YES" ;* Set Flag to identify Islamic REC arrangement
                recInterestProperty = propertyName ;* Store this Property value to avoid multipl calls .
                setRecProfitAmount = "YES" ;* This variable used to calculate total REC profit amount for usage before Interest Schedule is generated
            END
        END
        loopCount += 1
    REPEAT
       
RETURN
*** </region>


*** <region name= Project the Schedule>
***
BUILD.BASIC.DATA:

    IF NEW.ARR.ID<2> NE '' THEN
        ARR.ID<2> = NEW.ARR.ID<2>
    END
    
    IF ID.TO.CHECK EQ "AA.DETAILS.FUTURE.SCHEDULE" THEN
        ARR.ID<4> = 1
    END

* If field INCLUDE.NON.CUSTOMER is set then from schedules enquiry we should include NON.CUSTOMER bills and future projection.
* If this field is blank then exclude NON.CUSTOMER bill and projection as well in schedule projection
    IF INCLUDE.NON.CUSTOMERN.FLAG THEN
        ARR.ID<8> = 'INTERNAL'
    END
    IF FIN.DATE THEN   ;* pass the value entered in the financial date field to the schedule projector to pass the financial date as calcualtion for outstanding amount on past schedules.
        ARR.ID<10> = FIN.DATE
    END
    
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Routine to Project complete schedules
RETURN

*** </region>


*** <region name= Build the Array according to Enquiry requirements>
***
BUILD.ARRAY.DETAILS:

    TOT.DTES = DCOUNT(DUE.DATES,@FM)     ;* Total Number of Schedule dates
    FULL.INT.PAYM.REC = ''  ;* Interest amount for Islamic REC interest
    pendingProfitAmount = '' ;* Pending profit amount
    totalRecProfitAmount = '' ;* Initialise variable
    
    IF ID.TO.CHECK EQ "AA.DETAILS.FUTURE.SCHEDULE" THEN
        AA.ProductFramework.GetPropertyClass(PropertyList, TotPropertyClassName) ;* Get Property class for property
        LOCATE "PAYMENT.SCHEDULE" IN TotPropertyClassName<1,1> SETTING PSPropPos THEN
            PSProperty = PropertyList<1,PSPropPos>
            AA.Framework.GetArrangementConditions(ARR.ID, "", PSProperty, "", "", PSReturnconditions, retError)  ;* Read Payment schedule condition
            PaymentScheduleRecord = RAISE(PSReturnconditions)
            
            RestrictTypes = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsHolRestrictType> ;* Read ther restrict types from payment schedule record
            PSPaymentType = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
            PSBillType    = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsBillType>

            RestrictTypeCnt = DCOUNT(RestrictTypes, @VM) ;* Get the count of restrict types

            RestrictPropertyList = ""  ;* An array which will store all the restrict properties that may be given in terms of PaymentType/BillType/Property/PropertyClass
            FOR Initcnt = 1 TO RestrictTypeCnt
                
                GOSUB GET.HOLIDAY.RESTRICT.PROPERTY.LIST ;* Get the holiday restricted property list from the payment schedule record
              
            NEXT Initcnt
        END
    END
    
    FOR DCNT = 1 TO TOT.DTES
        DUE.DATE = DUE.DATES<DCNT>      ;* Pick each date
        DEFER.DATE = DEFER.DATES<DCNT>
        
        GOSUB SPLIT.AMOUNT    ;*EN_10003652 -S/E
        TOT.PAYM = TOT.PAYMENT<DCNT>    ;* Total Payment for this date
        CURRENT.OS = DUE.OUTS<DCNT>     ;* O/S on this date
        CURRENT.OS.REC = '' ;* Variable to store outstanding balance along with profit amount
        
        IF recBalanceArrangement EQ "YES" OR TOT.INT.PAYM.REC THEN
            IF DUE.DATE GT SystemDate THEN
                pendingProfitAmount = (totalRecProfitAmount - FULL.INT.PAYM.REC) * -1 ;* calculate total pending profit amount
            END ELSE
                pendingProfitAmount = totalRecProfitAmount * -1
            END
            CURRENT.OS.REC = DUE.OUTS<DCNT> + pendingProfitAmount  ;* calculate total O/S amount with Principal and Profit amount
            SCHED.ARR<-1> = DUE.DATE:'^':DEFER.DATE:'^':TOT.DUE.PAYM:'^':TOT.CAP.PAYM:'^':TOT.PRIN.PAYM:'^':TOT.INT.PAYM:'^':TOT.CHG.PAYM:'^':CURRENT.OS:'^':TOT.TAX.PAYM:'^':TOT.PAY.PAYM:'^':STORE.PAY.TYPE:'^':TOT.INT.PAYM.REC:'^':CURRENT.OS.REC:'^':pendingProfitAmount:'^':MIN.DUE.AMT      ;* Build the Array for this date with payment type ;*EN_10003652 -S/E
        END ELSE
            SCHED.ARR<-1> = DUE.DATE:'^':DEFER.DATE:'^':TOT.DUE.PAYM:'^':TOT.CAP.PAYM:'^':TOT.PRIN.PAYM:'^':TOT.INT.PAYM:'^':TOT.CHG.PAYM:'^':CURRENT.OS:'^':TOT.TAX.PAYM:'^':TOT.PAY.PAYM:'^':STORE.PAY.TYPE:'^':MIN.DUE.AMT       ;* Build the Array for this date with payment type ;*EN_10003652 -S/E
             
        END
    NEXT DCNT
*
RETURN

*** </region>
*------------------------------------------------------
*** <region name= Split the Payment amount into Principal, Interest & Charge components>
***
SPLIT.AMOUNT:

    TOT.DUE.PAYM = ''
    TOT.CAP.PAYM = ''
    TOT.INT.PAYM = ''
    TOT.INT.PAYM.REC = '' ;* variable to hold REC profit amount for each schedule date
    TOT.PRIN.PAYM = ''
    TOT.CHG.PAYM = ''
    TOT.TAX.PAYM = ''
    TOT.PAY.PAYM = ''
    PROP.CLS.LIST = ''
    MIN.DUE.AMT = ''  ;* variable to hold min due amount for each schedule date
    TOT.PAY.TYPE = DCOUNT(DUE.TYPES<DCNT>,@VM)
    STORE.PAY.TYPE = DUE.TYPES<DCNT> ;* Fetching the exact payment type
    FOR PAY.CNT = 1 TO TOT.PAY.TYPE
        GOSUB PROCESS.PAY.TYPE
    NEXT PAY.CNT

RETURN
*** </region>
*------------------------------------------------------
*** <region name= Process Pay Type>
***
PROCESS.PAY.TYPE:
 
    PROP.LIST = DUE.PROPS<DCNT,PAY.CNT>
    PROP.LIST = RAISE(PROP.LIST)
    AA.ProductFramework.GetPropertyClass(PROP.LIST,PROP.CLS.LIST)
    TOT.PROP = DCOUNT(PROP.LIST,@VM)
    FOR PROP.CNT = 1 TO TOT.PROP
        PROP.CLS = ''         ;*Used to save the PC of property for which current tax amt is raised
        TAX.SIGN = 1
        PROP.AMT = DUE.PROP.AMTS<DCNT,PAY.CNT,PROP.CNT>
        TAX.PROP.POS = ''
        
        IF RestrictPropertyList THEN   ;* if there is any property restricted then add that amount to the min due amount for that payment date
            LOCATE PROP.LIST<1,PROP.CNT> IN RestrictPropertyList<1> SETTING RestrictedPos THEN
                MIN.DUE.AMT += PROP.AMT
            END
        END

        IF PROP.CLS.LIST<1,PROP.CNT> EQ '' THEN   ;*May be for Tax amount
            LOCATE PROP.LIST<1,PROP.CNT>['-',1,1] IN PROP.LIST<1,1> SETTING TAX.PROP.POS THEN
                PROP.CLS = PROP.CLS.LIST<1,TAX.PROP.POS>    ;*Store the main property for which tax is raised
                GOSUB CHECK.TAX.SIGN ; *To check for source balance type for adding/deducting tax amount
            END ELSE
                TAX.PROP.POS = ''
            END
        END
 
        fixedUpfrontFlag = ''
        interestProperty = PROP.LIST<1,PROP.CNT>['-',1,1]

        IF interestProperty EQ recInterestProperty OR setRecProfitAmount EQ 'YES' THEN  ;* This processing is only for Islamic Murabaha contract
            IF interestProperty EQ recInterestProperty THEN
                fixedUpfrontFlag = "YES"  ;* set this Flag to identify the schedule which has REC balance
            END
            IF setRecProfitAmount EQ 'YES' THEN ;* Used to calculate the total REC profit amount to show Outstanding Balance with Profit Amount
                interestProperty = recInterestProperty
                setRecProfitAmount = ''  ;* Exceute only once.
            END
            effectiveDate = DUE.DATE
            profitAmount = ''
            interestPropertyRecord = ''
            IF NOT(AdvanceBillFound) THEN
                AA.PaymentSchedule.GetBill(ARR.ID, '', effectiveDate, '', '', '', '', '', '', '', '', '', BillIds, '')  ;* Get Advance bills for the arrangement
                IF BillIds AND effectiveDate GT SystemDate THEN
                    AdvanceBillFound = 1
                END
            END
       
            IF effectiveDate GT SystemDate AND BillIds AND AdvanceBillFound ELSE                     ;* If advanced bill exists, dont get the Period balances
       
                BAL.DETAILS  = ""          ;* The current balance figure
                DATE.OPTIONS = ""
                DATE.OPTIONS<2> = "ALL"
                RecinterestProperty = "REC":interestProperty
                
                AA.Framework.GetPeriodBalances(ACCOUNT.NO, RecinterestProperty, DATE.OPTIONS, effectiveDate, "", "", BAL.DETAILS, ERR.MSG)
                BALANCE.AMOUNT = ABS(BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance>)
                totalRecProfitAmount = BALANCE.AMOUNT
            END
        END
* DetermineProfitAmount is a generic routine which wil consider the past due/repaid amounts and return the remaining profit amount. Remaining profit amount is always be the current REC Balance hence for past schedules we can't use the same remaining amount hence we used GetPeriodBalance which will return the balance on the schedule date.
* If it's a past schedule then it can be directly taken as an outstanding balance for the schedule date
* If the schedule date is future date then the property amount should be subtracted with the balance amount


        BEGIN CASE
            CASE (PROP.CLS.LIST<1,PROP.CNT> EQ 'ACCOUNT' AND (DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'DUE' OR DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'PAY' OR DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'INFO'))  ;*Add to Principal for DUE and PAY payment Methods
                TOT.PRIN.PAYM += PROP.AMT
  
            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'INTEREST'        ;*Add to Interest
                IF fixedUpfrontFlag EQ "YES" THEN
                    TOT.INT.PAYM.REC += PROP.AMT ;* REC profit amount for each schedule date
                    IF DUE.DATE GT SystemDate THEN
                        FULL.INT.PAYM.REC += PROP.AMT ;* Total REC profit amount calculated till this schedule date
                    END
                END ELSE
                    TOT.INT.PAYM += PROP.AMT
                END
        
            CASE ((PROP.CLS.LIST<1,PROP.CNT> MATCHES 'CHARGE':@VM:'PERIODIC.CHARGES') AND DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> MATCHES 'DUE':@VM:'CAPITALISE':@VM:'PAY')          ;*Add both Charge and Periodic Charge for DUE/CAPITALISE/PAY Type
                TOT.CHG.PAYM += PROP.AMT

            CASE PROP.CLS NE ''   ;*Add to Tax
                TOT.TAX.PAYM += PROP.AMT

        END CASE

        DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT, PROP.CNT>

        IF PRODUCT.LINE MATCHES 'DEPOSITS':@VM:'LENDING' AND PROP.CLS.LIST<1,PROP.CNT> EQ 'CHARGE' AND DUE.METHOD EQ 'CAPITALISE' THEN ;*For Deposits,Lending the capitalised charge amount needs to be subtracted
            TOT.CAP.PAYM -= PROP.AMT * TAX.SIGN
            DUE.METHOD = ''
        END
*For tax property has not individual due methods it will take from user defined whatever they want to collect the tax.
*For example they want to collect the tax for a interest property, they take due method from interest property.
        IF TAX.PROP.POS THEN
            DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT,TAX.PROP.POS>
        END

        BEGIN CASE
            CASE DUE.METHOD MATCHES 'DUE':@VM:'INFO'
                TOT.DUE.PAYM += PROP.AMT
            CASE DUE.METHOD EQ 'CAPITALISE'
                TOT.CAP.PAYM += PROP.AMT * TAX.SIGN
            CASE DUE.METHOD EQ 'PAY'
                TOT.PAY.PAYM += PROP.AMT * TAX.SIGN
        END CASE

    NEXT PROP.CNT
*
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.TAX.SIGN>
CHECK.TAX.SIGN:
*** <desc>To check for source balance type for adding/deducting tax amount </desc>
    PROPERTY = PROP.LIST<1,PROP.CNT>
    SOURCE.BALANCE.TYPE = ''
    RET.ERR = ''
    IF PRODUCT.LINE EQ 'LENDING' AND PROP.CLS EQ 'INTEREST' THEN ;* For Lending, interest property check Source Balance Type
        AA.Framework.GetSourceBalanceType(PROPERTY, '', '', SOURCE.BALANCE.TYPE, RET.ERR)
        IF SOURCE.BALANCE.TYPE EQ "CREDIT" THEN  ;* Add the adjustment amount with the accrual amount
            TAX.SIGN = -1
        END ELSE   ;* Subtract the adjustment amount with the accrual amount
            TAX.SIGN = 1
        END
    END ELSE
* For Charges/Periodic Charges, changes yet to done to handle cap amount
        TAX.SIGN = -1
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.HOLIDAY.RESTRICT.PROPERTY.LIST>
*** <desc>Get the holiday restricted property list from the payment schedule record </desc>
GET.HOLIDAY.RESTRICT.PROPERTY.LIST:
    
    RestrictType = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsHolRestrictType,Initcnt>
    BEGIN CASE
        CASE RestrictType EQ 'PAYMENT.TYPE'
            HolRestPaymentType = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsHolRestrictItem,Initcnt>
            TotRestPayTypeCnt = DCOUNT(HolRestPaymentType,@SM) ;* SM field get the holiday restrict items
            FOR RestPayTypeCnt = 1 TO TotRestPayTypeCnt
                LOCATE HolRestPaymentType<1,1,RestPayTypeCnt> IN PSPaymentType<1,1> SETTING PayTypePos THEN
                    PSProperty = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsProperty,PayTypePos>
                    CHANGE @SM TO @FM IN PSProperty
                    RestrictPropertyList<-1> = PSProperty
                END
            NEXT RestPayTypeCnt
        
        CASE RestrictType EQ 'BILL.TYPE'
            HolRestBillType = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsHolRestrictItem,Initcnt>
            TotRestBillTypeCnt = DCOUNT(HolRestBillType,@SM) ;* SM field get the holiday restrict items
            FOR RestBillTypeCnt = 1 TO TotRestBillTypeCnt
                LOCATE HolRestBillType<1,1,RestBillTypeCnt> IN PSBillType<1,1> SETTING BillTypePos THEN
                    PSProperty = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsProperty,BillTypePos>
                    CHANGE @SM TO @FM IN PSProperty
                    RestrictPropertyList<-1> = PSProperty
                END
            NEXT RestBillTypeCnt
    
        CASE RestrictType EQ 'PROPERTY'
            HolRestProperty = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsHolRestrictItem,Initcnt>
            CHANGE @SM TO @FM IN HolRestProperty
            RestrictPropertyList<-1> = HolRestProperty ;* To know the property type restriction
    
        CASE RestrictType EQ 'PROPERTY.CLASS'  ;* For property class restriction
            HolRestPropClass = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsHolRestrictItem,Initcnt>
            TotRestPropClassCnt = DCOUNT(HolRestPropClass,@SM) ;* SM field get the holiday restrict items
            FOR RestPropClassCnt = 1 TO TotRestPropClassCnt
                PSProperty = PaymentScheduleRecord<AA.PaymentSchedule.PaymentSchedule.PsProperty>
                CHANGE @SM TO @VM IN PSProperty
                PropertyClass = ""
                AA.ProductFramework.GetPropertyClass(PSProperty, PropertyClass)
                LOCATE HolRestPropClass<1,1,RestPropClassCnt> IN PropertyClass<1,1> SETTING PropClassPos THEN
                    RestrictPropertyList<-1> = PSProperty<1,PropClassPos>
                END
            NEXT RestPropClassCnt
                    
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
END


