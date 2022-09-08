* @ValidationCode : MjoyMDcyODkyMzA0OkNwMTI1MjoxNTQzOTkyNTE0ODY1Om5kaXZ5YTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTE4LTE1MTA6ODg6ODg=
* @ValidationInfo : Timestamp         : 05 Dec 2018 12:18:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ndivya
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 88/88 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181118-1510
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-95</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.REPAY.DETS(REPAY.ARR)
*** <region name= Program Description>
*** <desc> </desc>
*** This NOFILE enquiry will build the repaid details for an arrangement.
*** Mandatory Input : Arrangement Id
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc> </desc>
*** MODIFICATION HISTORY:
*
* 21/05/07 - BG_100013938
*            New enquiry to display repayment details
*
* 25/10/09 - EN_10004396
*            Ref : SAR-2008-11-06-0019
*            New argument PROPERTY.AMOUNT.LCY added in AA.GET.BILL.PROPERTY.AMOUNT routine.
*
* 27/05/14  - Enhancement : 713751
*             Task : 1003629
*             New arguement CHARGEOFF.TYPE is added in AA.GET.BILL.PROPERTY.AMOUNT.
*
* 25/09/18  - Defect : 2779808
*             Task : 2783242
*             AA.REPAY.DETAILS enquiry is not giving any results even though Loan arrangement has recovered bills
*
* 25/10/18 - Task   : 2827411
*            Defect : 2819857
*            AA.REPAY.DETAILS enquiry is not showing the repayment amounts when multiple properties defined for same payment type
*
* 28/11/18 - Task   :2876049
*            Defect :2819857
*            When more than one repayment is used to settle the bills, repayment amounts displayed wrongly.
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
 
    $USING AA.PaymentSchedule
    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Logic>
*** <desc> </desc>

    GOSUB INITIALISE
    GOSUB GET.REQUIRED.INFO

    IF ARR.ID THEN
        GOSUB BUILD.BASIC.DATA
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise Variables>
*** <desc> </desc>
INITIALISE:
*---------

*** Initialise arrangement variables
    ARR.ID = ''
    ARR.POS = ''

*** Initialise account detail variables

    FV.AA.ACT.DET = ''
    AA.ACT.REC = ''
    AA.ACT.ERR = ''

*** Initialise Bill variables

    REP.BILL.ID = ''
    REP.BILL.IDS = ''
    BILL.DETAILS = ''
    REP.BILL.POS = ''
    REPAY.REFERENCE = ''
    REP.POS = ''
    REP.REF = ''
    REP.DATE = ''

*** Initialise local variables

    RET.ERROR = ''
    PAYMENT.TYPE.LOC = ''
    PAYMENT.TYPES = ''
    PROPERTY = ''
    NO.OF.PAY.TYPE = ''
    PAY.TYPE = ''
    PAY.TYPE.I = ''
    PROP.AMOUNT = ''
    NO.OF.PROP = ''
    REPAY.ARR = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Required Information>
*** <desc> </desc>
GET.REQUIRED.INFO:
*-----------------

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END

    FV.AA.ACT.DET = ''

    AA.ACT.REC = AA.PaymentSchedule.AccountDetails.Read(ARR.ID, AA.ACT.ERR)

    REPAY.REFERENCE = AA.ACT.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
    CONVERT @VM TO @FM IN REPAY.REFERENCE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Build Basic data>
*** <desc> </desc>
BUILD.BASIC.DATA:
*----------------

*** Loop through repay reference and for every bill id for the repay reference,
*** get the bill details. Build property amounts from bill details by calling
*** AA.GET.BILL.PROPERTY.AMOUNT with process type as REPAY.

*** If no payment type or property is supplied then the routine will return
*** the property amount with payment type wise split up.

    FOR REP.POS = 1 TO DCOUNT(REPAY.REFERENCE,@FM)
        REP.REF = FIELD(REPAY.REFERENCE<REP.POS>,'-',1)
        REP.DATE = FIELD(REPAY.REFERENCE<REP.POS>,'-',2)
        REP.BILL.IDS = AA.ACT.REC<AA.PaymentSchedule.AccountDetails.AdRpyBillId,REP.POS>

        LOOP
            REMOVE REP.BILL.ID FROM REP.BILL.IDS SETTING REP.BILL.POS
        WHILE REP.BILL.ID:REP.BILL.POS

            AA.PaymentSchedule.GetBillDetails(ARR.ID,REP.BILL.ID,BILL.DETAILS,RET.ERROR)

*** Clear out the details since we are inside loop and property amount can be found
*** only when payment type and property is null.

            PAYMENT.TYPE.LOC = ''
            PROPERTY = ''
            PROP.AMOUNT = ''
            PROP.POS = ''
            PAY.POS = ''
            PAY.TYP = ''
            GOSUB BUILD.PROPERTY.AMOUNTS
        REPEAT

    NEXT REP.POS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Build Property amounts>
*** <desc> </desc>
BUILD.PROPERTY.AMOUNTS:
*----------------------

*** Once the property amount is got for the bill, update the repay array for
*** the enquiry to pick up and display.

* Locate Repay-Ref in the bill details array and get the corresponding property and property amount
    
    FIND REPAY.REFERENCE<REP.POS> IN BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayRef> SETTING FM.POS,VM.POS,SM.POS THEN
        PROPERTY = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>
        PROP.AMOUNT = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayAmount>
        PAY.TYP = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType>
        PROP.REF = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayRef>
        GOSUB BUILD.REPAY.ARRAY
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Build Repay array>
*** <desc> </desc>
BUILD.REPAY.ARRAY:
*-----------------

*** Repay array is build
* Get the count of payment types and loop through for each payment type
    NO.OF.PAY.TYPE = DCOUNT(PAY.TYP,@VM)
    FOR PAY.COUNT = 1 TO NO.OF.PAY.TYPE
* Get the count og pay property and loop through and locate each property in pay property
        PAY.PROP = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPayProperty,PAY.COUNT>
        NO.OF.PROP = DCOUNT(PROPERTY,@VM)
        FOR PROP.TYPE.I = 1 TO NO.OF.PROP
* Build the array only when repay amount is not null
            IF PROP.AMOUNT<1,PROP.TYPE.I> THEN
* When multiple properties defined under same payment type, each property need to be located in pay property.
                LOCATE PROPERTY<1,PROP.TYPE.I> IN PAY.PROP<1,1,1> SETTING PAY.POS THEN
                    GOSUB GET.PROPERTY.AMOUNTS     ;* To get the repayment amount and build the repay array.
                END
            END
        NEXT PROP.TYPE.I
    NEXT PAY.COUNT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get repayment amounts>
*** <desc>Get the repayment amount and build the repay array</desc>
GET.PROPERTY.AMOUNTS:
    
* Get the repay reference count and loop through for each repay reference
    REPAY.COUNT = DCOUNT(PROP.REF<1,PROP.TYPE.I>,@SM)
    FOR RPY.CNT = 1 TO REPAY.COUNT
        IF REPAY.REFERENCE<REP.POS> EQ PROP.REF<1,PROP.TYPE.I,RPY.CNT> THEN
            PROP.AMT = PROP.AMOUNT<1,PROP.TYPE.I,RPY.CNT>
            PAY.TYPE = PAY.TYP<1,PAY.COUNT>
            PROP.TYPE = PROPERTY<1,PROP.TYPE.I>
            REPAY.ARR<-1> = REP.REF:'*':REP.DATE:'*':REP.BILL.ID:'*':PAY.TYPE:'*':PROP.TYPE:'*':PROP.AMT
            REP.REF = '' ; REP.DATE = '' ; PAY.TYPE = '' ; PROP.TYPE = '' ; PROP.AMT = '' ; REP.BILL.ID = ''
        END
    NEXT RPY.CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
