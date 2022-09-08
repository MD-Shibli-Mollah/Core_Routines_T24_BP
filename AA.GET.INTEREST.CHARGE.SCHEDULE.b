* @ValidationCode : MjotMTIyODIyNzA0MzpDcDEyNTI6MTU5NDk2Mzc5Mjk4MDpzbXVnZXNoOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMDoxNTk6MTE1
* @ValidationInfo : Timestamp         : 17 Jul 2020 10:59:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 115/159 (72.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.Channels
SUBROUTINE AA.GET.INTEREST.CHARGE.SCHEDULE(ARRANGEMENT.ID,ARR.START.DATE,PAYMENT.SCHEDULE.ARR)
*-----------------------------------------------------------------------------
* Description:
*-------------
* This routine is used to retrive the interest and charge schedule details of an arrangement
*--------------------------------------------------------------------------------------------------------------
* Routine type       : Call routine
* IN Parameters      : Arrangement Id , Arrangement Start date
* Out Parameters     : Array of interest and charge schedule details such as Payment Frequency, Payment Type, Property, Payment Method, Start Date Description, Percentage
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 09/09/16 - Defect 1853290 / Task 1853826
*            Reusable call routine for Interest and charge schedule
*
* 03/08/17 - Defect 2083086 / Task 2092156
*            Adding start date parameter to get arrangement conditions
*
* 24/03/19 - Defect 3044903/ Task 3050598
*            IRIS service enqTcNofTxnsList causing java.text.ParseException: Unparseable date error
*
* 17/07/20 - Enhancement 3492899/ Task 3861124
*            Infinity Retail API new header changes
*--------------------------------------------------------------------------------------------------------------
*** <region name = Inserts>
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.Utility
    $USING EB.Interface
    $USING EB.Security
    $USING EB.SystemTables
    
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main Process>
    GOSUB INITIALISE                ;* Initialise Variables here
    GOSUB PAYMENT.SCHEDULE.DETAILS    ;* Build the Schedule Details by calling the Projection Routine
    GOSUB BUILD.PAYMENT.SCHEDULE.ARRAY.DETAILS ;* Format the Details according to Enquiry requirements
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Initialise Variables>
INITIALISE:
*---------
    PAYMENT.SCHEDULE.ARR=''
*****Payment Schedule Property Details*****
    PAYMENT.SCHEDULE.TYPE = ''; PROPERTY.PAYMENT.SCHEDULE = ''; PAYMENT.METHOD = ''; PAYMENT.FREQ = ''; PAYMENT.SCHEDULE.START.DATE = ''; R.PAYMENT.DETAILS = ''; PAYMENT.TYPE.DESCRIPTION = ''; R.PROPERTY.DESCRIPTION = ''; PROPERTY.DESCRIPTION = ''; RECURRENCE = ''; IN.DATE = ''; OUT.MASK = ''; PAYMENT.FREQ = ''; SD.TYPE = ''; SD.TYPE.DEFINITION = ''; SD.VALUE = ''; SD.TYPE.DESC.DATE = ''; SD.TYPE.DESC.RELATIVE = ''; SD.TYPE.VALUE = ''; PAYMENT.SCHEDULE.SD.DATE.DESC = ''; SD.DATE = ''
    PAYMENT.SCHEDULE.SD.RELATIVE.DESC = ''; CONSOLIDATE.PAYMENT.FREQ = ''; CONSOLIDATE.PAY.TYPE.DESC = ''; CONSOLIDATE.PROP.DESC = ''; PAYMENT.SCHEDULE.SD.RECORD = '';  PROPERTY.PAYMENT.SCHEDULE.RECORD = ''; PAYMENT.SCHEDULE.TYPE.RECORD = ''; PAYMENT.FREQ.VALUE = ''; PAYMENT.METHOD.VALUE = ''; CONSOLIDATE.PAYMENT.METHOD = ''; CALC.PAYMENT.VALUE = ''; PERCENTAGE = ''; START.DATE =''; PROPERTY.ID = ''; PROP = ''; R.SCHD.PROPERTY = ''; SCHD.PROP.LIST = ''

    PAYMENT.SCHEDULE.PROPERTY.CLASS = 'PAYMENT.SCHEDULE'    ;* Initialise payment schedule property class
    PAYMENT.SCHEDULE.PROPERTY.RECORDS = ''                  ;* Initialise payment schedule property record
    
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN   ;* If External User Language is not available
        ExtLang = 1         ;* Assigning Default Language position to read language multi value fields
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Payment Schedule Property Details>
PAYMENT.SCHEDULE.DETAILS:
*-------------------------
*****Get the deposit details from payment schedule arrangement property*****
    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID,PAYMENT.SCHEDULE.PROPERTY.CLASS,'',ARR.START.DATE,PAYMENT.SCHEDULE.PROPERTY.IDS,PAYMENT.SCHEDULE.PROPERTY.RECORDS,RET.ERR) ;* Get payment schedule arrangement condition record
    PAYMENT.SCHEDULE.PROPERTY.RECORDS = RAISE(PAYMENT.SCHEDULE.PROPERTY.RECORDS)

    PAYMENT.SCHEDULE.TYPE.RECORDS     = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>     ;* PS payment type
    TOT.CNT.PAYMENT.SCHED.TYPE        = DCOUNT(PAYMENT.SCHEDULE.TYPE.RECORDS,@VM)
    FOR CNT.PAYMENT.SCHED.TYPE  = 1 TO TOT.CNT.PAYMENT.SCHED.TYPE
        PAYMENT.SCHEDULE.TYPE         = PAYMENT.SCHEDULE.TYPE.RECORDS<1,CNT.PAYMENT.SCHED.TYPE>
        R.PAYMENT.DETAILS             = AA.PaymentSchedule.PaymentType.Read(PAYMENT.SCHEDULE.TYPE, REC.ERR)                     ;* Read payment type details
        CALC.TYPE                     = R.PAYMENT.DETAILS<AA.PaymentSchedule.PaymentType.PtCalcType>                            ;* Clac type
        PAYMENT.TYPE.DESCRIPTION      = '';                     ;* Payment type description
        BEGIN CASE
            CASE R.PAYMENT.DETAILS EQ ''                                                                            ;* If Record is Empty Do Nothing
            CASE R.PAYMENT.DETAILS<AA.PaymentSchedule.PaymentType.PtDescription, ExtLang>  NE ''                    ;* Case when description is available in External User Preferred Language
                PAYMENT.TYPE.DESCRIPTION = R.PAYMENT.DETAILS<AA.PaymentSchedule.PaymentType.PtDescription, ExtLang> ;* Get the description in External User Language
            CASE 1                                                                                                  ;* Case Otherwise executed when description is NOT available in Preferred Language
                PAYMENT.TYPE.DESCRIPTION = R.PAYMENT.DETAILS<AA.PaymentSchedule.PaymentType.PtDescription, 1>       ;* Get the description title in default Language
        END CASE
        CONSLIDATE.PAY.TYPE.DESC<1,-1>= PAYMENT.TYPE.DESCRIPTION

        CALC.AMOUNT                   = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsCalcAmount,CNT.PAYMENT.SCHED.TYPE>      ;* Clac amount
        ACTUAL.AMT                    = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsActualAmt,CNT.PAYMENT.SCHED.TYPE>       ;* Actual amount
        PERCENTAGE                    = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsPercentage,CNT.PAYMENT.SCHED.TYPE>      ;* PS percentage
        GOSUB GET.PAYMENT.AMOUNT

        PROPERTY.PAYMENT.SCHEDULE     = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsProperty,CNT.PAYMENT.SCHED.TYPE>        ;* PS property
        GOSUB GET.SCHEDULE.PROPERTY

        PAYMENT.SCHEDULE.START.DATE   = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsStartDate,CNT.PAYMENT.SCHED.TYPE>       ;* PS start date
        IF  PAYMENT.SCHEDULE.START.DATE THEN
            GOSUB PAYMENT.SCHEDULE.CONDITIONS
        END

        PAYMENT.FREQ                  = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq,CNT.PAYMENT.SCHED.TYPE>     ;* PS payment frequency
        IF PAYMENT.FREQ THEN
            GOSUB PAYMENT.SCHEDULE.FREQ.CONDITION
        END
        IF PAYMENT.FREQ THEN
            CONSOLIDATE.PAYMENT.FREQ<1,-1> = PAYMENT.FREQ
        END ELSE
            CONSOLIDATE.PAYMENT.FREQ<1,-1> = START.DATE
        END

        PAYMENT.METHOD                = PAYMENT.SCHEDULE.PROPERTY.RECORDS<AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod,CNT.PAYMENT.SCHED.TYPE>   ;* PS payment method
        GOSUB PAYMENT.SCHEDULE.METHOD.CONDITION

    NEXT CNT.PAYMENT.SCHED.TYPE
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Payment Amount>
GET.PAYMENT.AMOUNT:
*-------------------------
*****Get the Payment Amount*****
    IF ACTUAL.AMT NE '' THEN
        PAYMENT.AMOUNT = ACTUAL.AMT
    END ELSE
        PAYMENT.AMOUNT = CALC.AMOUNT
    END
    IF CALC.TYPE EQ 'ACTUAL' THEN
        CALC.PAYMENT.VALUE = ACTUAL.AMT
    END ELSE
        CALC.PAYMENT.VALUE = PAYMENT.AMOUNT
    END

    IF PERCENTAGE NE '' THEN                        ;* Payment value
        PAYMENT.VALUE<1,-1> = PERCENTAGE:'%'
    END ELSE
        PAYMENT.VALUE<1,-1> = CALC.PAYMENT.VALUE
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Get Schedule Property>
GET.SCHEDULE.PROPERTY:
*---------------------
*****Get the Payment Schedule Property*****
    PROP.LIST = DCOUNT(PROPERTY.PAYMENT.SCHEDULE,@SM)
    FOR PROP = 1 TO PROP.LIST
        PROPERTY.ID            = PROPERTY.PAYMENT.SCHEDULE<1,1,PROP>
        R.SCHD.PROPERTY        = AA.ProductFramework.Property.Read(PROPERTY.ID,INT.ERR)
        BEGIN CASE                                                                                            ;* Get interest property description
            CASE R.SCHD.PROPERTY EQ ''                                                                          ;* If the Property Record is Empty Do Nothing
            CASE R.SCHD.PROPERTY <AA.ProductFramework.Property.PropDescription, ExtLang> NE ''                  ;* Case when description is available in External User Preferred Language
                SCHD.PROP.LIST<1,1,-1>  = R.SCHD.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang> ;* Get the description in External User Language
            CASE 1                                                                                              ;* Case Otherwise executed when description is NOT available in Preferred Language
                SCHD.PROP.LIST<1,1,-1>  = R.SCHD.PROPERTY <AA.ProductFramework.Property.PropDescription, 1>      ;* Get the description in default Language
        END CASE
    NEXT PROP
    CONSOLIDATE.PRPTY.DESC<1,-1> = SCHD.PROP.LIST
    SCHD.PROP.LIST = ''
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name= Payment Schedule Conditions>
PAYMENT.SCHEDULE.CONDITIONS:
*-------------------------
*****Get the Payment Schedule Conditions*****
    CHANGE " " TO "_" IN PAYMENT.SCHEDULE.START.DATE
    SD.TYPE = FIELD(PAYMENT.SCHEDULE.START.DATE,'_',1)                               ;* Find the type of start date value "R", "D"
    SD.TYPE.DEFINITION = FIELD(PAYMENT.SCHEDULE.START.DATE,'_',2)                    ;* Find the definition "Renewal", "Maturity"
    SD.VALUE = FIELD(PAYMENT.SCHEDULE.START.DATE,'_',3)
    CHANGE '_' TO '' IN SD.VALUE

    IF SD.TYPE NE '' THEN
        IF SD.TYPE EQ "D" THEN
            SD.TYPE.DESC.DATE = "CONTROL.DATE"
        END ELSE
            SD.TYPE.DESC.DATE = "DATE"
        END

        IF SD.TYPE EQ "R" THEN
            SD.TYPE.DESC.RELATIVE = "RELATIVE"
        END ELSE
            SD.TYPE.DESC.RELATIVE = SD.TYPE.DESC.DATE
        END

        GOSUB PAYMENT.SCHEDULE.START.DATE.DESCRIPTION
    END ELSE
        START.DATE = PAYMENT.SCHEDULE.START.DATE
    END

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Payment Schedule Type Conditions>
PAYMENT.SCHEDULE.START.DATE.DESCRIPTION:
*-------------------------
*****Get the Payment SchedulE Property Conditions*****
    IF SD.TYPE EQ 'D' THEN
        BEGIN CASE
            CASE SD.TYPE.DESC.RELATIVE EQ 'CONTROL.DATE'                           ;* If SD.TYPE.DEFINITION value is "START" then the display value is "on the Start Date"
                PAYMENT.SCHEDULE.SD.DATE.DESC<1,-1> = SD.TYPE.DEFINITION
            CASE SD.TYPE.DESC.RELATIVE NE 'CONTROL.DATE'
                PAYMENT.SCHEDULE.SD.DATE.DESC<1,-1> = SD.TYPE
        END CASE
        START.DATE = "On ":PAYMENT.SCHEDULE.SD.DATE.DESC                          ;* Concate the value for SD date
        PAYMENT.SCHEDULE.SD.DATE.DESC = ''
    END
    IF SD.TYPE EQ 'R' THEN
        BEGIN CASE
            CASE SD.TYPE.DEFINITION EQ 'START'                           ;* If SD.TYPE.DEFINITION value is "START" then the display value is "on the Start Date"
                PAYMENT.SCHEDULE.SD.RELATIVE.DESC<1,-1> = 'on the Start Date'
            CASE SD.TYPE.DEFINITION EQ 'MATURITY'
                PAYMENT.SCHEDULE.SD.RELATIVE.DESC<1,-1> = 'at Maturity'              ;* If SD.TYPE.DEFINITION value is "MATURITY" then the display value is "at Maturity"
            CASE SD.TYPE.DEFINITION EQ 'RENEWAL'
                PAYMENT.SCHEDULE.SD.RELATIVE.DESC<1,-1> = 'on the Renewal Date'
            CASE SD.TYPE.DEFINITION EQ 'ARRANGEMENT'
                PAYMENT.SCHEDULE.SD.RELATIVE.DESC<1,-1> = 'at Arrangement Creation'  ;* If SD.TYPE.DEFINITION value is "ARRANGEMENT" then the display value is "at Arrangement Creation"
        END CASE
        START.DATE = PAYMENT.SCHEDULE.SD.RELATIVE.DESC :' ': SD.VALUE         ;* Concate the value for SD relative
        PAYMENT.SCHEDULE.SD.RELATIVE.DESC = ''
    END

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= Payment Schedule Frequency Conditions>
PAYMENT.SCHEDULE.FREQ.CONDITION:
*-------------------------
*****Get the Payment Schedule Frequency Conditions*****
    RECURRENCE = PAYMENT.FREQ                                       ;* Pick the recurrence from payment frequency
    EB.Utility.BuildRecurrenceMask(RECURRENCE, IN.DATE, OUT.MASK)
    IF OUT.MASK EQ 'Monthly on the last day of the month' THEN      ;* If the output value is matched with "Monthly on the last day of the month" then
        PAYMENT.FREQ = 'Monthly on the last day'                    ;* "Monthly on the last day" should be the display value else the same o/p value will be displayed
    END ELSE
        PAYMENT.FREQ = OUT.MASK
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Payment Schedule Type Conditions>
PAYMENT.SCHEDULE.METHOD.CONDITION:
*-------------------------
*****Get the Payment Schedule Type Conditions*****
    BEGIN CASE                                      ;* Payment menthod
        CASE PAYMENT.METHOD EQ 'DUE'                ;* If payment menthod is "DUE" then the display value is "Due"
            CONSOLIDATE.PAYMENT.METHOD<1,-1> = 'Due'
        CASE PAYMENT.METHOD EQ 'CAPITALISE'         ;* If payment menthod is "CAPITALISE" then the display value is "Capitalise"
            CONSOLIDATE.PAYMENT.METHOD<1,-1> = 'Capitalise'
        CASE PAYMENT.METHOD EQ 'PAY'                ;* If payment menthod is "PAY" then the display value is "Payment"
            CONSOLIDATE.PAYMENT.METHOD<1,-1> = 'Payment'
        CASE PAYMENT.METHOD EQ 'MAINTAIN'                ;* If payment menthod is "PAY" then the display value is "Maintain"
            CONSOLIDATE.PAYMENT.METHOD<1,-1> = 'MAINTAIN'
    END CASE
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
BUILD.PAYMENT.SCHEDULE.ARRAY.DETAILS:
*---------------------------
* Build loan array details
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) ELSE
        CHANGE @VM TO "|" IN CONSOLIDATE.PAYMENT.FREQ
        CHANGE @VM TO "|" IN CONSLIDATE.PAY.TYPE.DESC
        CHANGE @VM TO "|" IN CONSOLIDATE.PRPTY.DESC
        CHANGE @VM TO "|" IN CONSOLIDATE.PAYMENT.METHOD
        CHANGE @VM TO "|" IN PAYMENT.VALUE
    END
    PAYMENT.SCHEDULE.ARR<-1> = CONSOLIDATE.PAYMENT.FREQ:"*":CONSLIDATE.PAY.TYPE.DESC:"*":CONSOLIDATE.PRPTY.DESC:"*":CONSOLIDATE.PAYMENT.METHOD:"*":PAYMENT.VALUE
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
END
