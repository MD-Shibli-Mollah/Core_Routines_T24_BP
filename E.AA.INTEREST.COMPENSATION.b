* @ValidationCode : Mjo0NTY0MjcyOTk6Q3AxMjUyOjE1NTE2NzUxMjc5MzY6c3VkaGFyYW1lc2g6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAxLjIwMTgxMjIzLTAzNTM6LTE6LTE=
* @ValidationInfo : Timestamp         : 04 Mar 2019 10:22:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-44</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AB.ModelBank
SUBROUTINE E.AA.INTEREST.COMPENSATION(RETURN.ARRAY)
*-------------------------------------------------------------------------------
* No file enquiry routine which will return interest compensation property details
*--------------------------------------------------------------------------------
* MODIFICATION HISTORY
*----------------------
* 22/07/14 - Defect 1051584
*            Task - 1063995
*            No file enquiry routine which will return interest compensation property details
*
* 25-02-19 - Task       - 3005936
*            Enhancement- 2998297
*            Do'not display interest compensation if not linked to bundle
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File Inserts that are used </desc>

    $USING AA.InterestCompensation
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.Reports



*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main Logic>
*** <desc>Process Charge due</desc>


    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables</desc>
INITIALISE:
*----------

    ARR.ID =  ""
    R.INT.COMP = ""
    R.ERR = ""
    PROPERTY.NAME = ""
    RECIPIENT.PRODUCT = ""
    RECIPIENT.PROPERTY = ""
    DONOR.PRODUCT = ""
    DONOR.PROPERTY = ""
    DONOR.ACCRUAL  = ""
    RETURN.ARRAY = ""
    RET.ERR = ""
    EFFECTIVE.DATE = ""

    LOCATE "@ID" IN EB.Reports.getDFields()<1> SETTING ARR.POS THEN
        ARR.ID = EB.Reports.getDRangeAndValue()<ARR.POS>
    END

    EFFECTIVE.DATE = EB.SystemTables.getToday()

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Input process>
*** <desc>Process</desc>
PROCESS:
*------

    AA.Framework.GetArrangementConditions(ARR.ID, "INTEREST.COMPENSATION", "" , "" , "" , R.INT.COMP, R.ERR)

    IF NOT(R.ERR) THEN
        GOSUB GET.CONDITION.VALUES
    END ELSE
        AA.ProductFramework.GetPropertyRecord("", ARR.ID, "", EFFECTIVE.DATE, "INTEREST.COMPENSATION", "", R.INT.COMP, RET.ERR)
        GOSUB GET.CONDITION.VALUES
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Condition Values>
*** <desc>Get Condition Values</desc>
GET.CONDITION.VALUES:
*--------------------

    IF (R.INT.COMP) THEN
        
        R.INT.COMP = RAISE(R.INT.COMP)

        PROPERTY.NAME = "INTEREST.COMPENSATION"
        RECIPIENT.PRODUCT = R.INT.COMP<AA.InterestCompensation.InterestCompensation.IcompRecipientProduct>
        RECIPIENT.PROPERTY = R.INT.COMP<AA.InterestCompensation.InterestCompensation.IcompRecipientProperty>
        DONOR.PRODUCT = R.INT.COMP<AA.InterestCompensation.InterestCompensation.IcompDonorProduct>
        DONOR.PROPERTY = R.INT.COMP<AA.InterestCompensation.InterestCompensation.IcompDonorProperty>
        DONOR.ACCRUAL  = R.INT.COMP<AA.InterestCompensation.InterestCompensation.IcompDonorAccrual>
 

        RETURN.ARRAY = PROPERTY.NAME:'*':RECIPIENT.PRODUCT:'*':RECIPIENT.PROPERTY:'*':DONOR.PRODUCT:'*':DONOR.PROPERTY:'*':DONOR.ACCRUAL
    
    END ELSE ;*If Interest compensation is not present return null
        RETURN
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
