* @ValidationCode : MjoxNjU3NzExNTI2OkNwMTI1MjoxNTk0OTYzNzkzNDUyOnNtdWdlc2g6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4wOjM0NzoyNjg=
* @ValidationInfo : Timestamp         : 17 Jul 2020 10:59:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 268/347 (77.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.Channels
SUBROUTINE AA.GET.INTEREST.DETAILS(ARRANGEMENT.ID,CURRENCY,INTEREST.DETAILS.ARR)
*-----------------------------------------------------------------------------
* Description :
*--------------
* This routine is used to retrive the interest details of an arrangement
*--------------------------------------------------------------------------------------------------------------
* Routine type       : Call routine
* IN Parameters      : Arrangement Id, Currency
* Out Parameters     : Array of interest details
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 04/10/16 - Enhancement 1648970 / Task 1897346
*            TCIB Retail : Account Details
*
* 25/01/19 - Defect 2950710/ Task 2961040
*            Issue with TC.NOF.ACCOUNT enquiry in case of credit interest.
*
* 24/03/19 - Defect 3044903/ Task 3050598
*            IRIS service enqTcNofTxnsList causing java.text.ParseException: Unparseable date error
*
* 17/07/20 - Enhancement 3492899/ Task 3861124
*            Infinity Retail API new header changes
*--------------------------------------------------------------------------------------------------------------
*** <region name = Inserts>
    $USING AA.ProductFramework
    $USING AA.Interest
    $USING AA.Framework
    $USING AA.ModelBank
    $USING ST.RateParameters
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Interface
    $USING EB.Security
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main Process>
    GOSUB INITIALISE                    ;* Initialise variables
    GOSUB VARIABLES.INITIALISE          ;* Initialise routine specific variables
    GOSUB INTEREST.DETAILS              ;* Build the interest details
    GOSUB BUILD.ARRAY.DETAILS           ;* Build the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Initialise Variables>
INITIALISE:
*---------
*****Initialise the variables*****
    INTEREST.DETAILS.ARR = '' ; ExtLang = '' ;
    TODAY = EB.SystemTables.getToday()
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN   ;* If External User Language is not available
        ExtLang = 1         ;* Assigning Default Language position to read language multi value fields
    END
    ARR.ID = FIELD(ARRANGEMENT.ID,"//",1)
    COMPOUND.FREQ = "Compound Frequency"; C.SINGLE = "Single Rate"; C.UPTO ="up to "; C.REMAINDER="remainder"
* Initialise interest arrangement property details
    INT.PROPERTY.CLASS        = 'INTEREST'    ;* Initialise interest property class
    INT.PROPERTY.RECORDS      = ''            ;* Initialise interest property record
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialise routine specific variables>
VARIABLES.INITIALISE:
*--------------------
*****Initialise the routine specific variables*****
    TOT.INT.PROPERTY.RECORDS = ''; CNT.INT.PROPERTY.RECORDS = ''; PROPERTY = ''; R.PROPERTY = ''; PROPERTY.DESC = ''; GRP.PRPTY.DESC = ''; ARR.DATE= ''; COMPOUND.TYPE = ''; COMPOUND.TYPE.VAL = ''; RATE.TIER.TYPE = ''; RATE.TIER.TYPE.DESC = ''; TIER.TYPE = ''

    LINKED.ARRANGEMENT = ''; LINKED.PROPERTY = ''; R.LINKED.PROPERTY = ''; LINKED.PROPERTY.DESC = ''; LINK.DETS = ''; LINK.INDEX = ''; FIXED.RATE.VAL = ''; TOT.FIXED.RATE.CNT = ''; FLOATING.INDEX.VAL = ''; PERIODIC.INDEX.VAL = ''; LINKED = ''; EFF.RATE.VAL = ''
    MARGIN.OPER.VALUE = ''; MARGIN.RATE.VAL = ''; MARGIN.TYPE.VAL = ''; REL.OPR.VALUE = ''; REL.MARGIN.VAL = ''; TIER.AMOUNT.VAL = ''; CNT.FIXED.RATE = ''; FIXED.RATE = ''; FLOATING.INDEX = ''; PERIODIC.INDEX = ''; EFF.RATE = ''; MARGIN.OPER.VAL = ''; MARGIN.RATE = ''; MARGIN.TYPE = ''; REL.OPR.VAL = ''; REL.MARGIN = ''; TIER.AMOUNT = ''

    R.FLOATING.INDEX = ''; DESC.FLOATING.INDEX = ''; PERIODIC.INDEX.ID = ''; R.PERIODIC.INDEX = ''; DESC.PERIODIC.INDEX = ''; DESC.INDEX = ''; LINK.RATE.ID = ''; INDEX.VAL = ''

    FLOAT.RATE.ID = ''; FLOAT.RATE.VAL = ''; LINK.RATE = ''; FLOAT.RATE = ''; FIX.RATE = ''

    MARGIN.OPER = ''; MARGIN = ''; FLOAT.RATE.ADD = ''; FLOAT.RATE.MIN = ''; FLOAT.RATE.MUL = ''; FLOAT.EFF.RATE.VAL = ''; FLOAT.EFF.RATE = ''; EFFECTIVE.RATE.VAL = ''; EFFECTIVE.RATE = ''

    REL.OPR = ''; REL.TOT = ''; TOTMARGIN = ''

    EFFECTIVE.RATE.FIXED = ''; MARGIN.RATE.FIXED = ''; REL.FIX.RATE = ''; EFF.FIX.RATE = ''; FIX.RATE.VALUE = ''; RATE.FIXED = ''; TMP.RATE.FLOAT = ''; RATE.FLOATING = ''; TMP.RATE.LINK = ''; RATE.LINKED = ''; TMP.RATE.PERIOD = ''; RATE.PERIODIC = ''; VALUE.FIXED.RATE = ''; VALUE.FLOATING.RATE = ''; VALUE.LINKED.RATE = ''; VALUE.PERIODIC.RATE = ''

    UPTO.AMOUNT = ''; TYPE.CHK = ''; UPTO = ''; UPTO.VAL = ''; FINAL.UPTO = ''; TOT.INTEREST.COUNT = ''; CNT.INTEREST = ''; RATE.TYPE = ''; RATE = ''; FINAL.UPTO = ''; TOT.RATE.TYPE.CNT = ''; CNT.RATE.TYPE = '';RATE.TYPE.VAL = ''; RATE.VAL = ''; FINAL.UPTO.VAL =''; DETAILS.INTEREST = ''; CONSOLIDATE.INTEREST.DETAILS = ''
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Payment Schedule Property Details>
INTEREST.DETAILS:
*-------------------------
*****Retrive the interest details*****
    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID,INT.PROPERTY.CLASS,'','',INT.PROPERTY.IDS,INT.PROPERTY.RECORDS,INTEREST.ERR) ;* Get interest arrangement condition records
    TOT.INT.PROPERTY.RECORDS       = DCOUNT(INT.PROPERTY.RECORDS,@FM)                                                                 ;* Total number of interest records
    FOR CNT.INT.PROPERTY.RECORDS   = 1 TO TOT.INT.PROPERTY.RECORDS
        PROPERTY                   = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntIdCompTwo>                ;* Interest property
        R.PROPERTY                 = AA.ProductFramework.Property.Read(PROPERTY,INT.ERR)                                              ;* Read property details
        PROPERTY.DESC              = '';         *Reinitialising to avoid variable retaining value from previous iteration
        BEGIN CASE                                                                              ;* Get interest property description
            CASE R.PROPERTY EQ ''                                                                   ;* If the Property Record is Empty Do Nothing
            CASE R.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang> NE ''            ;* Case when description is available in External User Preferred Language
                PROPERTY.DESC = R.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang>   ;* Get the description in External User Language
            CASE 1                                                                                  ;* Case Otherwise executed when description is NOT available in Preferred Language
                PROPERTY.DESC = R.PROPERTY<AA.ProductFramework.Property.PropDescription, 1>         ;* Get the account title in default Language
        END CASE
        GRP.PRPTY.DESC<1,-1>       = PROPERTY.DESC
        ARR.DATE                   = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntIdCompThr>                ;* Arrangement date
        COMPOUND.TYPE              = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntCompoundType>             ;* Compound type
        IF COMPOUND.TYPE EQ "" THEN
            COMPOUND.TYPE.VAL<1,-1>    = ""
        END ELSE
            COMPOUND.TYPE.VAL<1,-1>    = COMPOUND.FREQ
        END
        RATE.TIER.TYPE             = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntRateTierType>            ;* Rate tire type
        GOSUB RATE.TIER.TYPE.DESCRIPTION  ;* Read the tier type description
        GOSUB LINKED.ARRANGEMENT.DETAILS  ;* Read the linked arrangement details
    NEXT CNT.INT.PROPERTY.RECORDS
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
RATE.TIER.TYPE.DESCRIPTION:
*---------------------------
*****Retrive the rate tier type description*****
    IF RATE.TIER.TYPE NE '' THEN
        BEGIN CASE
            CASE RATE.TIER.TYPE EQ 'LEVEL'                           ;* If rate tier type is "LEVEL" then set the description as "Tier Levels"
                RATE.TIER.TYPE.DESC<1,-1> = 'Tier Levels'
            CASE RATE.TIER.TYPE EQ 'BAND'
                RATE.TIER.TYPE.DESC<1,-1> = 'Tier Bands'             ;* If rate tier type is "BAND" then set the description as "Tier Bands"
            CASE RATE.TIER.TYPE EQ 'SINGLE'
                RATE.TIER.TYPE.DESC<1,-1> = 'Single Rate'            ;* If rate tier type is "SINGLE" then set the description as "Single Rate"
        END CASE
        TIER.TYPE = RATE.TIER.TYPE.DESC
    END ELSE
        TIER.TYPE = C.SINGLE
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
LINKED.ARRANGEMENT.DETAILS:
*---------------------------
*****Retrive the linked arrangement details*****
    LINKED.ARRANGEMENT            = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntLinkedArrangement>       ;* Linked arrangement value
    LINKED.PROPERTY               = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntLinkedProperty>          ;* Linked property

    IF LINKED.PROPERTY NE '' THEN
        R.LINKED.PROPERTY         = AA.ProductFramework.Property.Read(LINKED.PROPERTY,LINK.PRPTY.ERR)
        BEGIN CASE                                                                                  ;* Get the Linked property description
            CASE R.LINKED.PROPERTY EQ ''                                                                        ;* If the Property Record is Empty Do Nothing
            CASE R.LINKED.PROPERTY<AA.ProductFramework.Property.PropDescription, ExtLang> NE ''                 ;* Case when description is available in External User Preferred Language
                LINKED.PROPERTY.DESC = R.LINKED.PROPERTY<AA.ProductFramework.Property.PropDescription,ExtLang>  ;* Get the description in External User Language
            CASE 1                                                                                              ;* Case Otherwise executed when description is NOT available in Preferred Language
                LINKED.PROPERTY.DESC = R.LINKED.PROPERTY<AA.ProductFramework.Property.PropDescription,1>        ;* Get the description in default Language
        END CASE                              ;* Get linked property description
        LINK.DETS                 = LINKED.ARRANGEMENT: "~" :LINKED.PROPERTY
        LINK.INDEX                = LINKED.ARRANGEMENT: " " :LINKED.PROPERTY.DESC
    END

    FIXED.RATE.VAL                = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntFixedRate>                ;* Fixed rate value
    TOT.FIXED.RATE.CNT            = DCOUNT(FIXED.RATE.VAL, @SM)
    FLOATING.INDEX.VAL            = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntFloatingIndex>            ;* Float index value
    IF TOT.FIXED.RATE.CNT EQ '0' THEN
        TOT.FIXED.RATE.CNT            = DCOUNT(FLOATING.INDEX.VAL, @SM)
    END
    PERIODIC.INDEX.VAL            = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntPeriodicIndex>            ;* Periodic index value
    IF TOT.FIXED.RATE.CNT EQ '0' THEN
        TOT.FIXED.RATE.CNT            = DCOUNT(PERIODIC.INDEX.VAL, @SM)
    END
    LINKED                        = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntLinkedRate>               ;* Interest Linked Rate
    EFF.RATE.VAL                  = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntEffectiveRate>            ;* Interest Effective Rate
    MARGIN.OPER.VALUE             = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntMarginOper>               ;* Interest Margin Oper
    MARGIN.RATE.VAL               = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntMarginRate>               ;* Interest Margin Rate
    MARGIN.TYPE.VAL               = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntMarginType>               ;* Interest Margin Type
    REL.OPR.VALUE                 = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntRelationshipOperand>      ;* Interest Relationship Operand
    REL.MARGIN.VAL                = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntRelationshipMargin>       ;* Interest Relationship Margin
    TIER.AMOUNT.VAL               = INT.PROPERTY.RECORDS<CNT.INT.PROPERTY.RECORDS, AA.Interest.Interest.IntTierAmount>               ;* Interest Tier Amount

    FOR CNT.FIXED.RATE = 1 TO TOT.FIXED.RATE.CNT                                            ;* Get the first sm value from the above listed variables
        FIXED.RATE                = FIXED.RATE.VAL<1,1,CNT.FIXED.RATE>
        FLOATING.INDEX            = FLOATING.INDEX.VAL<1,1,CNT.FIXED.RATE>
        PERIODIC.INDEX            = PERIODIC.INDEX.VAL<1,1,CNT.FIXED.RATE>
        EFF.RATE                  = EFF.RATE.VAL<1,1,CNT.FIXED.RATE>
        MARGIN.OPER.VAL           = MARGIN.OPER.VALUE<1,1,CNT.FIXED.RATE>
        MARGIN.RATE               = MARGIN.RATE.VAL<1,1,CNT.FIXED.RATE>
        MARGIN.TYPE               = MARGIN.TYPE.VAL<1,1,CNT.FIXED.RATE>
        REL.OPR.VAL               = REL.OPR.VALUE<1,1,CNT.FIXED.RATE>
        REL.MARGIN                = REL.MARGIN.VAL<1,1,CNT.FIXED.RATE>
        TIER.AMOUNT               = TIER.AMOUNT.VAL<1,1,CNT.FIXED.RATE>
        GOSUB RATE.TYPE.DETAILS                                                             ;* Get the rate type descrition details
        GOSUB INDEX.DETAILS                                                                 ;* Get the index value details
        GOSUB RATE.DETAILS                                                                  ;* Get the rate  details
        GOSUB MARGIN.OPER.VAL                                                               ;* Get the margin operator descrition details
        GOSUB RELATIONSHIP.DETAILS                                                          ;* Get the relationship details
        GOSUB RATE.FIXED.DETAILS                                                            ;* Get the rate fixed details
        GOSUB TIER.AMOUNT                                                                   ;* Get the tier amount details
    NEXT CNT.FIXED.RATE
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
RATE.TYPE.DETAILS:
*---------------------------
*****Retrive the rate type details*****
    GRP.FI.RATE.TYPE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    GRP.FR.RATE.TYPE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    GRP.PI.RATE.TYPE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    FI.RATE.TYPE = ''; FR.RATE.TYPE = ''; PI.RATE.TYPE = ''

    IF FLOATING.INDEX NE "" THEN      ;* Fix the floating index rate type
        FI.RATE.TYPE = "Variable"
        R.FLOATING.INDEX     = ST.RateParameters.BasicRateText.Read(FLOATING.INDEX, BRT.ERR)        ;* Retrive the floating index description
        DESC.FLOATING.INDEX = '';
        BEGIN CASE
            CASE R.FLOATING.INDEX EQ ''                                                                             ;* If the Account Record is Empty Do Nothing
            CASE R.FLOATING.INDEX<ST.RateParameters.BasicRateText.EbBrtDescription, ExtLang> NE ''                  ;* Case when description is available in External User Preferred Language
                DESC.FLOATING.INDEX  = R.FLOATING.INDEX<ST.RateParameters.BasicRateText.EbBrtDescription, ExtLang>  ;* Get the description in External User Language
            CASE 1                                                                                                  ;* Case Otherwise executed when description is NOT available in Preferred Language
                DESC.FLOATING.INDEX  = R.FLOATING.INDEX<ST.RateParameters.BasicRateText.EbBrtDescription, 1>        ;* Get the description in default Language
        END CASE
        FLOAT.RATE.ID      = FLOATING.INDEX : "~" : CURRENCY : "~" : ARR.DATE     ;* Form the float rate id
        EB.Reports.setOData(FLOAT.RATE.ID)
        AA.ModelBank.EAaGetFloatRate()                                        ;* Get the float rate value
        FLOAT.RATE.VAL = EB.Reports.getOData()

    END ELSE
        FI.RATE.TYPE = "Linked"
    END
    GRP.FI.RATE.TYPE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = FI.RATE.TYPE  ;* Consolidated floating index rate type
    IF FIXED.RATE NE ""  THEN         ;* Fix the fixed rate type
        FR.RATE.TYPE = "Fixed"
    END ELSE
        FR.RATE.TYPE = FI.RATE.TYPE
    END
    GRP.FR.RATE.TYPE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = FR.RATE.TYPE  ;* Consolidated fixed rate type
    IF PERIODIC.INDEX NE ""  THEN    ;* Fix the periodic index rate type
        PI.RATE.TYPE = "Periodic"
        PERIODIC.INDEX.ID    = PERIODIC.INDEX : CURRENCY : TODAY                                    ;* Form the periodic index id
        R.PERIODIC.INDEX     = ST.RateParameters.PeriodicInterest.Read(PERIODIC.INDEX.ID, BRT.ERR)  ;* Retrive the periodic index description
        DESC.PERIODIC.INDEX  = '';   ;* Periodic index description
        BEGIN CASE
            CASE R.PERIODIC.INDEX EQ ''                                                                             ;* If the Account Record is Empty Do Nothing
            CASE R.PERIODIC.INDEX<ST.RateParameters.PeriodicInterest.PiDescription, ExtLang> NE ''                  ;* Case when description is available in External User Preferred Language
                DESC.PERIODIC.INDEX  = R.PERIODIC.INDEX<ST.RateParameters.PeriodicInterest.PiDescription, ExtLang>  ;* Get the description in External User Language
            CASE 1                                                                                                  ;* Case Otherwise executed when description is NOT available in Preferred Language
                DESC.PERIODIC.INDEX  = R.PERIODIC.INDEX<ST.RateParameters.PeriodicInterest.PiDescription, 1>        ;* Get the description in default Language
        END CASE
        IF LINKED EQ "YES"  THEN                      ;* Define the value for index description & link rate id
            DESC.INDEX       = LINK.INDEX
            LINK.RATE.ID     = LINK.DETS
            EB.Reports.setOData(LINK.RATE.ID)
            AA.ModelBank.EAaGetLinkedRate()                                       ;* Get the linked rate value
            LINK.RATE      = EB.Reports.getOData()
        END ELSE
            DESC.INDEX       = DESC.PERIODIC.INDEX
            LINK.RATE.ID     = ''
        END
    END ELSE
        PI.RATE.TYPE = FR.RATE.TYPE
    END
    GRP.PI.RATE.TYPE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = PI.RATE.TYPE  ;* Consolidated periodic index rate type
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
INDEX.DETAILS:
*---------------------------
*****Retrive the index details*****
    GRP.INDEX.VAL<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    IF DESC.FLOATING.INDEX NE ""  THEN               ;* Define the index value
        INDEX.VAL            = DESC.FLOATING.INDEX
    END ELSE
        INDEX.VAL            = DESC.INDEX
    END
    GRP.INDEX.VAL<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = INDEX.VAL ;* Consolidated index value
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
RATE.DETAILS:
*---------------------------
*****Retrive the rate details*****

    IF LINKED EQ "YES"  THEN                 ;* Define the float rate
        FLOAT.RATE     = LINK.RATE
    END ELSE
        FLOAT.RATE     = FLOAT.RATE.VAL
    END

    IF FIXED.RATE NE "" THEN                 ;* Define the fixed rate
        FIX.RATE       = FIXED.RATE
    END ELSE
        FIX.RATE       = FLOAT.RATE
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
MARGIN.OPER.VAL:
*---------------------------
*Initialising FLOAT.EFF.RATE to Basic Interest(FLOAT.RATE) value
    FLOAT.EFF.RATE = FLOAT.RATE ;* Initialising done to avoid returning NULL Effective rate in case Margin value is not present in the property condition record.
*Initialising Margin Rate to Zero in case Margin value is not present in the property condition record.
    IF MARGIN.RATE EQ "" THEN
        MARGIN.RATE = "0"
    END
* Define the static values (Effective rate = Basic Interest +/-/* Margin Interest)
    FLOAT.RATE.ADD         = FLOAT.RATE + MARGIN.RATE
    FLOAT.RATE.MIN         = FLOAT.RATE - MARGIN.RATE
    FLOAT.RATE.MUL         = FLOAT.RATE * MARGIN.RATE

*****Retrive the margin operator value*****
    IF MARGIN.OPER.VAL NE '' THEN                             ;* Define the values for margin operator & margin value with rate
        BEGIN CASE
            CASE MARGIN.OPER.VAL EQ 'ADD' OR MARGIN.OPER.VAL EQ ''
                MARGIN.OPER = '+'
                MARGIN      = " +" : " " : MARGIN.RATE :"%"
                FLOAT.EFF.RATE     = FLOAT.RATE.ADD
            CASE MARGIN.OPER.VAL EQ 'SUB'
                MARGIN.OPER = '-'
                MARGIN      = " -" : " " : MARGIN.RATE :"%"
                FLOAT.EFF.RATE = FLOAT.RATE.MIN
            CASE MARGIN.OPER.VAL EQ 'MUL'
                MARGIN.OPER = '*'
                MARGIN      = " *" : " " : MARGIN.RATE :"%"
                FLOAT.EFF.RATE = FLOAT.RATE.MUL
        END CASE
    END

    IF FIXED.RATE NE ""  THEN                       ;* Effective rate for fixed rate
        EFFECTIVE.RATE.VAL = EFF.RATE
    END ELSE
        EFFECTIVE.RATE.VAL = FLOAT.EFF.RATE
    END

    IF PERIODIC.INDEX NE "" THEN                    ;* Effective rate for periodic index
        EFFECTIVE.RATE    = EFF.RATE
    END ELSE
        EFFECTIVE.RATE    = EFFECTIVE.RATE.VAL
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
RELATIONSHIP.DETAILS:
*---------------------------
*****Retrive the relationship details with margin*****
    GRP.REL.TOT<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    IF REL.OPR.VAL NE '' THEN               ;* Defind the values for relationship operator
        BEGIN CASE
            CASE REL.OPR.VAL EQ 'ADD' OR REL.OPR.VAL EQ ''
                REL.OPR = '+'
            CASE REL.OPR.VAL EQ 'SUB'
                REL.OPR = '-'
            CASE REL.OPR.VAL EQ 'MUL'
                REL.OPRR = '*'
        END CASE
    END
    REL.TOT             = MARGIN : " " : REL.OPR : " " : REL.MARGIN : "%"  ;* Form the total relationship details
    IF REL.MARGIN EQ ""  THEN       ;* Defind the total margin value
        TOTMARGIN       = MARGIN
    END ELSE
        TOTMARGIN       = REL.TOT
    END
    GRP.REL.TOT<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = TOTMARGIN    ;* Consolidated relationship total value
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
RATE.FIXED.DETAILS:
*---------------------------
*****Retrive the rate fixed details with margin*****
    GRP.FI.RATE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    GRP.FR.RATE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    GRP.PI.RATE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
* Form the margin rate fixed
    EFFECTIVE.RATE.FIXED = EFFECTIVE.RATE : "%"
    MARGIN.RATE.FIXED = EFFECTIVE.RATE.FIXED : "(" : FIX.RATE : "%" : " " : TOTMARGIN : ")"
* Form the effective rate fixed
    REL.FIX.RATE = FIX.RATE : "%" : " " : REL.OPR : " " : REL.MARGIN : "%"
    EFF.FIX.RATE = EFFECTIVE.RATE.FIXED : "(" : REL.FIX.RATE : ")"

    TMP.RATE.FLOAT = EFFECTIVE.RATE : "%" : "(" : INDEX.VAL : " " : MARGIN : ")"    ;* Temporary variable for float rate
    TMP.RATE.LINK = EFFECTIVE.RATE : "%" : "(" : INDEX.VAL : " " : MARGIN : ")"     ;* Temporary variable for link rate
    TMP.RATE.PERIOD = EFFECTIVE.RATE : "%" : "(" : INDEX.VAL : " " : MARGIN : ")"   ;* Temporary variable for periodic rate

    IF REL.MARGIN EQ ""  THEN
        FIX.RATE.VALUE = EFFECTIVE.RATE.FIXED
    END ELSE
        FIX.RATE.VALUE = EFF.FIX.RATE
    END

    IF MARGIN.TYPE EQ ""  THEN
        RATE.FIXED = FIX.RATE.VALUE
        RATE.FLOATING = EFFECTIVE.RATE.FIXED
        RATE.LINKED = EFFECTIVE.RATE.FIXED
        RATE.PERIODIC = EFFECTIVE.RATE.FIXED
    END ELSE
        RATE.FIXED = MARGIN.RATE.FIXED
        RATE.FLOATING = TMP.RATE.FLOAT
        RATE.LINKED = TMP.RATE.LINK
        RATE.PERIODIC = TMP.RATE.PERIOD
    END

    IF FIXED.RATE NE "" THEN                        ;* Define fixed rate
        VALUE.FIXED.RATE = EFFECTIVE.RATE.FIXED
    END ELSE
        VALUE.FIXED.RATE = ''
    END
    GRP.FR.RATE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = VALUE.FIXED.RATE      ;* Consolidated fixed rate

    IF FLOATING.INDEX NE ""  THEN                   ;* Define floating rate
        VALUE.FLOATING.RATE = RATE.FLOATING
    END ELSE
        VALUE.FLOATING.RATE = VALUE.FIXED.RATE
    END
    GRP.FI.RATE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = VALUE.FLOATING.RATE   ;* Consolidated floating index rate

    IF LINKED EQ "YES"  THEN                        ;* Define linked rate
        VALUE.LINKED.RATE =TMP.RATE.LINK
    END ELSE
        VALUE.LINKED.RATE = VALUE.FLOATING.RATE
    END

    IF PERIODIC.INDEX NE ""  THEN                   ;* Define periodic rate
        VALUE.PERIODIC.RATE = RATE.PERIODIC
    END ELSE
        VALUE.PERIODIC.RATE = VALUE.LINKED.RATE
    END
    GRP.PI.RATE<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = VALUE.PERIODIC.RATE   ;* Consolidated periodic rate
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
TIER.AMOUNT:
*---------------------------
*****Retrive the tier amount*****
    GRP.FINAL.UPTO<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = ""
    UPTO.AMOUNT= C.UPTO : TIER.AMOUNT       ;* Define upto amount value

    IF PI.RATE.TYPE EQ "" THEN
        TYPE.CHK =""
    END ELSE
        TYPE.CHK = C.REMAINDER
    END

    IF TIER.AMOUNT NE ""  THEN              ;* Define the upto amount
        UPTO = UPTO.AMOUNT
    END ELSE
        UPTO = TYPE.CHK
    END

    TIER.AMOUNT.V1 = TIER.AMOUNT.VAL<1,1,1>
    IF TIER.AMOUNT.V1 EQ ""  THEN
        UPTO.VAL = ""
    END ELSE
        UPTO.VAL = UPTO
    END

    IF TIER.TYPE EQ C.SINGLE THEN           ;* Define the final upto value
        FINAL.UPTO=""
    END ELSE
        FINAL.UPTO = UPTO.VAL
    END
    GRP.FINAL.UPTO<CNT.INT.PROPERTY.RECORDS,CNT.FIXED.RATE,-1> = FINAL.UPTO  ;* Consolidated upto value
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
BUILD.ARRAY.DETAILS:
*---------------------------
*****Form build array*****
* Form the interest details
    CHANGE @VM TO @FM IN GRP.PRPTY.DESC
    CHANGE @VM TO @FM IN TIER.TYPE
    TOT.INTEREST.COUNT = DCOUNT(GRP.PRPTY.DESC,@FM)
    FOR CNT.INTEREST = 1 TO TOT.INTEREST.COUNT          ;*Concate the results to achieve the expected format output
        RATE.TYPE = GRP.PI.RATE.TYPE<CNT.INTEREST>
        RATE = GRP.PI.RATE<CNT.INTEREST>
        FINAL.UPTO = GRP.FINAL.UPTO<CNT.INTEREST>
        TIER.TYPE.VAL = TIER.TYPE<CNT.INTEREST>
        TOT.RATE.TYPE.CNT = DCOUNT(RATE.TYPE,@VM)
        DETAILS.INTEREST = ''
        FOR CNT.RATE.TYPE = 1 TO TOT.RATE.TYPE.CNT      ;*Concate the interest rate values with upto amount
            RATE.TYPE.VAL = RATE.TYPE<1,CNT.RATE.TYPE>
            RATE.VAL = RATE<1,CNT.RATE.TYPE>
            FINAL.UPTO.VAL = FINAL.UPTO<1,CNT.RATE.TYPE>
            DETAILS.INTEREST<1,1,-1> = RATE.VAL:" ":RATE.TYPE.VAL:" ":TIER.TYPE.VAL:" ":FINAL.UPTO.VAL
        NEXT CNT.RATE.TYPE
        CONSOLIDATE.INTEREST.DETAILS<1,-1> = DETAILS.INTEREST  ;* Consolidated interest details
    NEXT CNT.INTEREST
    CHANGE @FM TO @VM IN GRP.PRPTY.DESC
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) ELSE
        CHANGE @SM TO "#" IN CONSOLIDATE.INTEREST.DETAILS          ;* Convert the markers into specific special characters for easy mainpulation in front end
        CHANGE @VM TO "|" IN CONSOLIDATE.INTEREST.DETAILS
        CHANGE @VM TO "|" IN GRP.PRPTY.DESC
	END
	
    INTEREST.DETAILS.ARR<-1> = GRP.PRPTY.DESC:"*":COMPOUND.TYPE:"*":COMPOUND.TYPE.VAL:"*":CONSOLIDATE.INTEREST.DETAILS ;*Result array
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
END
