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
* <Rating>452</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ProductFramework
    SUBROUTINE CONV.AA.DES.AL.PRP.CLAS.200808(YID, R.RECORD, FN.FILE)

********************************************************************************
* 21/05/08 - EN_10003680
* Conversion routine for all property class at designer level. This routine will
* default the corresponding value to the field APP.METHOD and DEFAULT.RESET.
* Also to append 'D' to values in BILL.PRODUCED field in PAYMENT.SCHEDULE
* as BILL.PRODUCED field is changed to type PERIOD
*
********************************************************************************-
*** <region name= Modification History>
***
* 18/05/06 - BG_100020047
*            Change has been done to default the "DUE" value into the field
*            APP.METHOD only if the charge Property is inputted.
*
*
* 23/04/09 - EN_10004042
*            Enhancement for re-modelling PRODUCT.ACCESS for ARC-IB.
*            Fields of PRODUCT.ACCESS are changed. Also referrences of the Property Class
*            ARRANGEMENT.PREFERENCES is completely removed
*            SAR Ref : SAR-2008-09-15-0009
*
***</region>
*-----------------------------------------------------------------------------
* !** Simple SUBROUTINE template
* @author sivall@temenos.com
* @stereotype subroutine
* @package infra.eb
*!
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONVERSION.DETAILS
    $INSERT I_F.AA.AC.GROUP.INTEREST
    $INSERT I_F.AA.PROPERTY.CLASS
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.PAYMENT.SCHEDULE

*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
PROCESS:

    LEVEL = FIELDS(FN.FILE, ".", 3)

    IF LEVEL EQ "ARR" THEN
        PROP.CLASS.ID = FIELD(FIELD(FN.FILE,"$",1),".",4,99)
    END ELSE
        PROP.CLASS.ID = FIELD(FIELD(FN.FILE,"$",1),".",5,99)
    END

    GOSUB GET.PROPERTY.CLASS.REC        ;*Get Property Class Record

    GOSUB GET.FIELD.NO        ;*Get the field number

    GOSUB DEFAULT.APPLICATION.METHOD    ;*Default the application method

    IF PROP.CLASS.ID EQ "PAYMENT.SCHEDULE" THEN
        GOSUB UPDATE.BILL.PRODUCED      ;*append 'D' to values in BILL.PRODUCED field in PAYMENT.SCHEDULE
    END


    RETURN
*-----------------------------------------------------------------------------
INITIALISE:

    FILE.NAME = ""
    PROP.CLASS.ID = ""
    R.PROPERTY.CLASS = ""
    RET.ERROR = ""
    DEFAULT.RESET.FIELD.NO = ""
    PR.ATTRIBUTE.FIELD.NO = ""
    PR.ATTRIBUTE = ""
    APP.METHOD.FIELD.NO = ""
    PR.ATTRIBUTE.FIELD.NO = ""
    POS = ""
    PR.COUNT = ""
    PR.CNT = ""
    NO.ACTIVITY = ""
    ACT.CNT = ""
    NO.OF.ACTIVITY = ""

    TOTAL.BILL.PRODUCED  = '' ;** BILL.PRODUCED fld count
    IS.VALUE = ''   ;**flag to denote whether value is there


    RETURN

*-----------------------------------------------------------------------------
*** <region name= GET.PROPERTY.CLASS.REC>
*** <desc>Get Property Class Record </desc>
GET.PROPERTY.CLASS.REC:

    CALL F.READ("F.AA.PROPERTY.CLASS", PROP.CLASS.ID, R.PROPERTY.CLASS, "", RET.ERROR)

    IF  RET.ERROR THEN
        ETEXT =  RET.ERROR
        CALL STORE.END.ERROR
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DEFAULT.APPLICATION.METHOD>
*** <desc>Default the application method </desc>
DEFAULT.APPLICATION.METHOD:

    PR.CHARGE.FIELD.NO = PR.ATTRIBUTE.FIELD.NO + 4
    PR.ATTRIBUTE.CHARGE = R.RECORD<PR.CHARGE.FIELD.NO>

    PR.COUNT = DCOUNT(PR.ATTRIBUTE.CHARGE, @VM)

    FOR PR.CNT = 1 TO PR.COUNT

        R.RECORD<APP.METHOD.FIELD.NO, PR.CNT> = "DUE"

    NEXT PR.CNT

* If Property Class equals "ACTIVITY.CHARGES" then update the APP.METHOD to "DUE"

    IF PROP.CLASS.ID EQ "ACTIVITY.CHARGES" THEN

        NO.ACTIVITY = DCOUNT(R.RECORD<NO.OF.ACTIVITY>, @VM)

        FOR ACT.CNT = 1 TO NO.ACTIVITY

            R.RECORD<ACT.CHARGE.APP.METHOD.FIELD.NO, ACT.CNT> = "DUE"

        NEXT ACT.CNT

    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.BILL.PRODUCED>
*** <desc>append 'D' to values in BILL.PRODUCED field in PAYMENT.SCHEDULE </desc>
UPDATE.BILL.PRODUCED:

    BP.CNT = 0
    TOTAL.BILL.PRODUCED = DCOUNT(R.RECORD<AA.PS.BILL.PRODUCED>, VM)
    LOOP
        BP.CNT += 1
    WHILE BP.CNT LE TOTAL.BILL.PRODUCED
        BILL.PR = R.RECORD<AA.PS.BILL.PRODUCED, BP.CNT>
        TERM.TYPE = BILL.PR[LEN(BILL.PR), 1]
        IF BILL.PR AND NOT (TERM.TYPE  MATCHES 'D': VM : 'W' : VM : 'M' : VM : 'Y') THEN  ;*If field contains value and does not contain d,w,y,m then append 'd'
            BILL.PR =  BILL.PR : 'D'
        END
        R.RECORD<AA.PS.BILL.PRODUCED, BP.CNT> = BILL.PR
    REPEAT

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.FIELD.NO>
*** <desc>Get the field number </desc>
GET.FIELD.NO:

    BEGIN CASE

    CASE PROP.CLASS.ID EQ "OFFICERS"

        APP.METHOD.FIELD.NO = 26
        PR.ATTRIBUTE.FIELD.NO = 18

    CASE PROP.CLASS.ID EQ "ACTIVITY.MAPPING"

        APP.METHOD.FIELD.NO = 23
        PR.ATTRIBUTE.FIELD.NO = 15

    CASE PROP.CLASS.ID EQ "AC.ACCT.GROUP.CONDN"

        APP.METHOD.FIELD.NO = 63
        PR.ATTRIBUTE.FIELD.NO = 55

    CASE PROP.CLASS.ID EQ "CHARGE"

        APP.METHOD.FIELD.NO = 40
        PR.ATTRIBUTE.FIELD.NO = 32

    CASE PROP.CLASS.ID EQ "AC.GROUP.CAP"

        APP.METHOD.FIELD.NO = 28
        PR.ATTRIBUTE.FIELD.NO = 20

    CASE PROP.CLASS.ID EQ "AZ.LOAN"

        APP.METHOD.FIELD.NO = 30
        PR.ATTRIBUTE.FIELD.NO = 22

    CASE PROP.CLASS.ID EQ "ACCOUNT"

        APP.METHOD.FIELD.NO = 28
        PR.ATTRIBUTE.FIELD.NO = 20

    CASE PROP.CLASS.ID EQ "AZ.SAVINGS"

        APP.METHOD.FIELD.NO = 24
        PR.ATTRIBUTE.FIELD.NO = 16

    CASE PROP.CLASS.ID EQ "TERM.AMOUNT"

        APP.METHOD.FIELD.NO = 26
        PR.ATTRIBUTE.FIELD.NO = 18

    CASE PROP.CLASS.ID EQ "ACCOUNTING"

        APP.METHOD.FIELD.NO = 22
        PR.ATTRIBUTE.FIELD.NO = 14

    CASE PROP.CLASS.ID EQ "OVERDUE"

        APP.METHOD.FIELD.NO = 36
        PR.ATTRIBUTE.FIELD.NO = 28

    CASE PROP.CLASS.ID EQ "PROTECTION.LIMIT"

        APP.METHOD.FIELD.NO = 30
        PR.ATTRIBUTE.FIELD.NO = 22

* Property Class ARRANGEMENT.PREFERENCES is made OB

    CASE PROP.CLASS.ID EQ "PAYMENT.RULES"

        APP.METHOD.FIELD.NO = 30
        PR.ATTRIBUTE.FIELD.NO = 22

    CASE PROP.CLASS.ID EQ "INTEREST"

        APP.METHOD.FIELD.NO = 44
        PR.ATTRIBUTE.FIELD.NO = 36

    CASE PROP.CLASS.ID EQ "UI.APPEARANCE"

        APP.METHOD.FIELD.NO = 25
        PR.ATTRIBUTE.FIELD.NO = 17

    CASE PROP.CLASS.ID EQ "PAYMENT.SCHEDULE"

        APP.METHOD.FIELD.NO = 57
        PR.ATTRIBUTE.FIELD.NO = 49

    CASE PROP.CLASS.ID EQ "MG.OTH.COND"

        APP.METHOD.FIELD.NO = 25
        PR.ATTRIBUTE.FIELD.NO = 17

    CASE PROP.CLASS.ID EQ "ACTIVITY.API"

        APP.METHOD.FIELD.NO = 24
        PR.ATTRIBUTE.FIELD.NO = 16

    CASE PROP.CLASS.ID EQ "ACTIVITY.MESSAGING"

        APP.METHOD.FIELD.NO = 20
        PR.ATTRIBUTE.FIELD.NO = 12

    CASE PROP.CLASS.ID EQ "CUSTOMER"

        APP.METHOD.FIELD.NO = 22
        PR.ATTRIBUTE.FIELD.NO = 14

    CASE PROP.CLASS.ID EQ "ACTIVITY.RESTRICTION"

        APP.METHOD.FIELD.NO = 49
        PR.ATTRIBUTE.FIELD.NO = 18

    CASE PROP.CLASS.ID EQ "ACTIVITY.CHARGES"

        APP.METHOD.FIELD.NO = 23
        ACT.CHARGE.APP.METHOD.FIELD.NO = 6
        PR.ATTRIBUTE.FIELD.NO = 19
        NO.OF.ACTIVITY = 3

    CASE PROP.CLASS.ID EQ "ACTIVITY.PRESENTATION"

        APP.METHOD.FIELD.NO = 27
        PR.ATTRIBUTE.FIELD.NO = 19


    CASE PROP.CLASS.ID EQ "UI.BEHAVIOUR"

        APP.METHOD.FIELD.NO = 30
        PR.ATTRIBUTE.FIELD.NO = 22

    CASE PROP.CLASS.ID EQ "CHANGE.PRODUCT"

        APP.METHOD.FIELD.NO = 26
        PR.ATTRIBUTE.FIELD.NO = 18

    CASE PROP.CLASS.ID EQ "LD.OTH.COND"

        APP.METHOD.FIELD.NO = 32
        PR.ATTRIBUTE.FIELD.NO = 24

* Fields of the Property Class PRODUCT.ACCESS are changed.
    CASE PROP.CLASS.ID EQ "PRODUCT.ACCESS"

        APP.METHOD.FIELD.NO = 40
        PR.ATTRIBUTE.FIELD.NO = 32

    CASE PROP.CLASS.ID EQ "AZ.DEPOSIT"

        APP.METHOD.FIELD.NO = 34
        PR.ATTRIBUTE.FIELD.NO = 26

    CASE PROP.CLASS.ID EQ "AZ.ACCOUNTING"

        APP.METHOD.FIELD.NO = 45
        PR.ATTRIBUTE.FIELD.NO = 37

    CASE PROP.CLASS.ID EQ "BALANCE.MAINTENANCE"

        APP.METHOD.FIELD.NO = 51
        PR.ATTRIBUTE.FIELD.NO = 43

    CASE PROP.CLASS.ID EQ "AC.GROUP.INTEREST"

        APP.METHOD.FIELD.NO = 59
        PR.ATTRIBUTE.FIELD.NO = 51

    CASE PROP.CLASS.ID EQ "LIMIT"

        APP.METHOD.FIELD.NO = 25
        PR.ATTRIBUTE.FIELD.NO = 17

    CASE PROP.CLASS.ID EQ "USER.RIGHTS"

        APP.METHOD.FIELD.NO = 28
        PR.ATTRIBUTE.FIELD.NO = 20

    CASE PROP.CLASS.ID EQ "PROXY.PERMISSIONS"

        APP.METHOD.FIELD.NO = 27
        PR.ATTRIBUTE.FIELD.NO = 19

    CASE PROP.CLASS.ID EQ "AZ.CR.CARD"

        APP.METHOD.FIELD.NO = 24
        PR.ATTRIBUTE.FIELD.NO = 16

    END CASE

    RETURN

*** </region>

END
