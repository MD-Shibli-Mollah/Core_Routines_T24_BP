* @ValidationCode : MjoxODY2MTQ5MDE6Q3AxMjUyOjE0OTQ0OTk0OTc1ODk6YnJpbmRoYXI6NjowOi03NjotMTpmYWxzZTpOL0E6REVWXzIwMTcwNC4wOjQ4OjQ4
* @ValidationInfo : Timestamp         : 11 May 2017 16:14:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : brindhar
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -76
* @ValidationInfo : Coverage          : 48/48 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-51</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Fees
SUBROUTINE AA.GET.TERM.PERIOD(ARRANGEMENT.ID, ACTIVITY.ID, PROPERTY, REQUEST.TYPE, PROPERTY.RECORD, FROM.DATE, TO.DATE, RET.BAL, RET.COUNT, RET.TERM)
    
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
* This is a RULE.VAL.RTN designed and released to evaluate period
*
*
*-----------------------------------------------------------------------------
* @uses I_AA.APP.COMMON
* @package retaillending.AA
* @stereotype subroutine
* @author brindhar@temenos.com
*-----------------------------------------------------------------------------
*** </region>
**
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param ARRANGEMENT.ID
* @param ACTIVITY.ID
* @param PROPERTY
* @param REQUEST.TYPE
* @param PROPERTY.RECORD
* @param FROM.DATE
* @param TO.DATE
*
* Ouptut
* @return RET.BAL     - null
* @return RET.COUNT     - null
* @return RET.TERM     - return calculated term
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 05/05/17 - Task - 2113125
*            Enhancement - 2048381
*            New routine to return CHANGE PERIOD/CONTRACT TERM, to use in Term Based Charges
*
*-----------------------------------------------------------------------------
    $USING AA.ProductFramework
    $USING AA.TermAmount
    $USING AA.ChangeProduct
    $USING EB.API
    $USING AA.Framework
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *To initialise variables
    
    GOSUB GET.PERIOD ; *To get period from change product/Term amount property
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>To initialise variables </desc>

    RET.TERM = ""
    ARR.REC = ""
    ARR.REC.ERR = ""

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.PERIOD>
GET.PERIOD:
*** <desc>To get period from change product/Term amount property </desc>

    AA.ProductFramework.GetPropertyClass(PROPERTY, PROPERTY.CLASS) ;*to get property class
    
    GOSUB PROCESS.CHANGE.PRODUCT ; *To retrive term from change product property
    
    IF NOT(RET.TERM) THEN ;* if there is no change product date/period given then return term amount period
        GOSUB PROCESS.TERM.AMOUNT ; *To retrive term from term amount property
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PROPERTY.RECORD>
GET.PROPERTY.RECORD:
*** <desc>To get property record details </desc>

    AA.ProductFramework.GetPropertyRecord("", ARRANGEMENT.ID, "", TO.DATE, PROP.CLASS, "", R.PROPERTY.RECORD, RET.ERROR)       ;*to get property record details
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.CHANGE.PRODUCT>
PROCESS.CHANGE.PRODUCT:
*** <desc>To retrive term from change product property </desc>

    IF PROPERTY.CLASS NE "CHANGE.PRODUCT" THEN  ;*if the given attribute property class is not the CHANGE.PRODUCT, then get CHANGE.PRODUCT details using getpropertyrecord
        PROP.CLASS = "CHANGE.PRODUCT"
        GOSUB GET.PROPERTY.RECORD ; *To get property record details
    END ELSE
        R.PROPERTY.RECORD = PROPERTY.RECORD  ;*if the given attribute property class is CHANGE.PRODUCT, then use the available incoming property record details
    END

    IF R.PROPERTY.RECORD<AA.ChangeProduct.ChangeProduct.CpChangeDate> AND TO.DATE LE R.PROPERTY.RECORD<AA.ChangeProduct.ChangeProduct.CpChangeDate> THEN  ;*If the requested end date falls within the change product change date then calculate that period and return
        CHANGE.DATE = R.PROPERTY.RECORD<AA.ChangeProduct.ChangeProduct.CpChangeDate>
        DIFF.DAYS = "C"
        GOSUB GET.ARRANGEMENT.START.DATE ; *To get arrangement's start date
        EB.API.Cdd("", ARR.START.DATE, CHANGE.DATE, DIFF.DAYS)  ;*to get difference days between effeective date and change product date.
        RET.TERM = DIFF.DAYS:"D"
    END ELSE  ;*If the change date is not available or if the requested end date does not fall within change product change date, then return change period
        RET.TERM = R.PROPERTY.RECORD<AA.ChangeProduct.ChangeProduct.CpChangePeriod>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.TERM.AMOUNT>
PROCESS.TERM.AMOUNT:
*** <desc>To retrive term from terma amount property </desc>

    IF PROPERTY.CLASS NE "TERM.AMOUNT" THEN  ;*if the given attribute property class is not the TERM.AMOUNT, then get TERM.AMOUNT details using getpropertyrecord
        PROP.CLASS = "TERM.AMOUNT"
        GOSUB GET.PROPERTY.RECORD ; *To get property record details
    END ELSE
        R.PROPERTY.RECORD = PROPERTY.RECORD   ;*if the given attribute property class is TERM.AMOUNT, then use the available incoming property record details
    END
    RET.TERM = R.PROPERTY.RECORD<AA.TermAmount.TermAmount.AmtTerm>  ;*fetch and return term period.
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.ARRANGEMENT.START.DATE>
GET.ARRANGEMENT.START.DATE:
*** <desc>To get arrangement's start date </desc>

    AA.Framework.GetArrangement(ARRANGEMENT.ID, ARR.REC, ARR.REC.ERR) ;*get AA.ARRANGEMENT record
    START.DATE = ARR.REC<AA.Framework.Arrangement.ArrStartDate>
    CONTRACT.DATE = ARR.REC<AA.Framework.Arrangement.ArrOrigContractDate>
    
    IF CONTRACT.DATE THEN  ;*For takeover arrangement, get start date from original contract date.
        ARR.START.DATE = CONTRACT.DATE
    END ELSE
        ARR.START.DATE = START.DATE  ;*For normal arrangement, get start date from arrangement start date.
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END
