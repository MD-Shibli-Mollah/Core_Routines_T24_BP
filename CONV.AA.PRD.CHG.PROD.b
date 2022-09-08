* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-122</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE AA.ChangeProduct
    SUBROUTINE CONV.AA.PRD.CHG.PROD(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
**Conversion Routine  for  Loan Renewal SAR.
* Conversion done for payment schedule,term maount,change product and account details
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @ author geolivi@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_AA.APP.COMMON


*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB DO.LEVEL.CHECK
    GOSUB DO.CONVERSION

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise</desc>
INITIALISE:

    R.RECORD.TEMP = R.RECORD
    LEVEL = ""

    RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Do Level Check>
*** <desc>Do Level Cehck</desc>
DO.LEVEL.CHECK:

    LEVEL = FIELDS(FN.FILE, ".", 3)
    PROP.CLASS.ID = ""

    BEGIN CASE
        CASE LEVEL MATCHES  "ARR":VM:"SIM"
            PROP.CLASS.ID = FIELD(FN.FILE, ".",4,99)
        CASE LEVEL EQ "PRD"
            PROP.CLASS.ID = FIELD(FN.FILE, ".",5,99)
        CASE 1

    END CASE

    IF INDEX(PROP.CLASS.ID, '$', 1) THEN ;* for $NAU files
        PROP.CLASS.ID = FIELD(PROP.CLASS.ID, "$", 1)
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:

    BEGIN CASE
        CASE PROP.CLASS.ID EQ "CHANGE.PRODUCT"
            GOSUB  DO.CHG.PRD.CONVERSION
        CASE PROP.CLASS.ID EQ "PAYMENT.SCHEDULE"
            GOSUB  DO.PAY.SCH.CONVERSION
        CASE PROP.CLASS.ID EQ "TERM.AMOUNT"
            GOSUB  DO.TERM.AMOUNT.CONVERSION
        CASE 1
            GOSUB DO.AC.DETAILS.CONVERSION
    END CASE

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Payment Schedule Conversion>
*** <desc>Do Payment Schedule Conversion</desc>
DO.PAY.SCH.CONVERSION:

    R.RECORD<39> = ""         ;*FINAL.RES.AMOUNT removed

IF LEVEL MATCHES "PRD":VM:"PRF":VM:"CAT" THEN
 R.RECORD<3> = ""         ;*BASE.DATE removed
END
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Change Product Conversion>
*** <desc>Do Change Product Conversion</desc>
DO.CHG.PRD.CONVERSION:

    R.RECORD<4> = R.RECORD.TEMP<13>     ;*CHANGE.PERIOD
    R.RECORD<5> = R.RECORD.TEMP<12>     ;*CHANGE.DATE
    R.RECORD<6> = "CHANGE.PRODUCT"      ;*CHANGE.ACTIVITY
    R.RECORD<7> = R.RECORD.TEMP<11>     ;*PRIOR.DAYS
    R.RECORD<8> = R.RECORD.TEMP<8>      ;*CHG.TO.PRODUCT
    R.RECORD<9> = R.RECORD.TEMP<4>      ;*ALLOWED.PRODUCT
    R.RECORD<10> = R.RECORD.TEMP<5>     ;*DATE.CONVERSION
    R.RECORD<11> = R.RECORD.TEMP<6>     ;*BUS.DAY.CENTRE
    R.RECORD<12> = R.RECORD.TEMP<9>     ;*RESERVED.6
    R.RECORD<13> = R.RECORD.TEMP<10>    ;*RESERVED.5


    IF R.RECORD<4> THEN       ;*CHANGE.PERIOD
        R.RECORD<3> = "PERIOD"          ;*CHANGE.DATE.TYPE
    END

    IF R.RECORD<5> AND NOT(R.RECORD<4>) THEN
        R.RECORD<3> = ""          ;*CHANGE.DATE.TYPE
    END


    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Account Details Conversion>
*** <desc>Do Account Details Conversion</desc>
DO.AC.DETAILS.CONVERSION:

    ARRANGEMENT.NO = YID
    ACTIVITY.NAME = 'LENDING':AA$SEP:'CHANGE.PRODUCT':AA$SEP:"ARRANGEMENT"
    ACTIVITY.RUN.DATE = ""
    ACTIVITY.EFF.DATE = ""

** get the next date of change product activity
    CALL AA.GET.SCHEDULED.ACTIVITY.DATE(ARRANGEMENT.NO, ACTIVITY.NAME, "NEXT", ACTIVITY.RUN.DATE , ACTIVITY.EFF.DATE, RET.ERR)

    IF ACTIVITY.RUN.DATE THEN
        R.RECORD<8> =  ACTIVITY.RUN.DATE    ;* RENEWAL.DATE
    END

    R.RECORD<10> = R.RECORD.TEMP<2>         ;** default the value from VALUE.DATE to BASE.DATE

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Term Amount Conversion>
*** <desc>Do Term Amount Conversion</desc>
DO.TERM.AMOUNT.CONVERSION:
**if the payment schedule for the arrangement has value on final res amt then populate the ON.MATURITY field in term amount

    GOSUB GET.PAYMENT.SCH.RECORD  ;**get payment schedule record

    IF R.PAYMENT.SCHED<39> THEN
        R.RECORD<12> = "DUE"      ;*ON.MATURITY
    END


    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get the payment Schedule Record>
*** <desc>Get the Payment Schedule Record</desc>
GET.PAYMENT.SCH.RECORD:

    ARRANGEMENT.ID = FIELD(YID,AA$SEP,1)
    PROP.CLASS = 'PAYMENT.SCHEDULE'
    EFF.DATE = FIELD(YID,AA$SEP,3)
    EFF.DATE = FIELD(EFF.DATE,".",1)

    REC.ERR = ''

* Get the payment schedule record

    CALL AA.GET.PROPERTY.RECORD('', ARRANGEMENT.ID, '', EFF.DATE, PROP.CLASS, '', R.PAYMENT.SCHED, REC.ERR)       ;* Get the effective dated record

    RETURN
*** </region>
*-----------------------------------------------------------------------------


    END
