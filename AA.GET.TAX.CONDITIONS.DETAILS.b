* @ValidationCode : MjoxMTg1OTM3NjEwOkNwMTI1MjoxNTk0OTYzNzkzMDk4OnNtdWdlc2g6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4wOjEzMDo4Mw==
* @ValidationInfo : Timestamp         : 17 Jul 2020 10:59:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 83/130 (63.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.Channels
SUBROUTINE AA.GET.TAX.CONDITIONS.DETAILS(ARRANGEMENT.ID,TAX.DETAILS.ARR)
*------------------------------------------------------------------------------
* Description :
*--------------
* This routine is used to retrive the tax details of an arrangement
*--------------------------------------------------------------------------------------------------------------
* Routine type       : Call routine
* IN Parameters      : Arrangement Id
* Out Parameters     : Array of tax details
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 04/10/16 - Enhancement 1648970 / Task 1897346
*            TCIB Retail : Account Details
* 21/11/16 - Defect 1909424 / Task 1931145
*            Tax detail is wrongly displayed when tax detail is multivalued in T24
* 24/03/19 - Defect 3044903/ Task 3050598
*            IRIS service enqTcNofTxnsList causing java.text.ParseException: Unparseable date error
*
* 10/02/20 - Enhancement 3568228  / Task 3580449
*            Changing reference of routines that have been moved from ST to CG
*
* 17/07/20 - Enhancement 3492899/ Task 3861124
*            Infinity Retail API new header changes
*--------------------------------------------------------------------------------------------------------------
*** <region name = Inserts>
    $INSERT I_DAS.TAX
    $USING AA.Framework
    $USING AA.Tax
    $USING CG.ChargeConfig
    $USING AA.Customer
    $USING EB.DataAccess
    $USING EB.Security
    $USING EB.SystemTables
    $USING EB.Interface
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main Process>
    GOSUB INITIALISE                    ;* Initialise Variables here
    GOSUB TAX.PROPERTY.DETAILS          ;* Build the interest Details
    GOSUB BUILD.ARRAY.DETAILS           ;* Build the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Initialise Variables>
INITIALISE:
*---------
*Initialise the variables*
    TAX.PROPERTY.CLASS = 'TAX'                              ;* Initialise tax property class
    TAX.PROPERTY.RECORDS = ''                               ;* Initialise tax property record
    ExtLang = ''                                            ;* Initialise External User Language value
    ARR.CCY = ''
    ARR.ID = FIELD(ARRANGEMENT.ID,"//",1)
    R.ARR.RECORD = AA.Framework.Arrangement.Read(ARR.ID, Y.ARR.ERROR)
    ARR.CCY = R.ARR.RECORD<AA.Framework.Arrangement.ArrCurrency>
    ExtLang = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>          ;* Get the External Users Language as Priority to read language multi value fields
    IF ExtLang EQ '' THEN   ;* If External User Language is not available
        ExtLang = 1         ;* Assigning Default Language position to read language multi value fields
    END
*****Tax Property Details*****
    TAX.ERR = ''; TAX.PROPERTY.COND = ''; TAX.TYPE = ''; TAX.TYPE.ID = ''; R.TAX.TYPE = ''; TAX.TYPE.ERR = ''; TAX.ID = ''; CUSTOMER.DETAILS = '';
    CUSTOMER.DETAILS.ERR = ''; R.CUSTOMER.CHARGE = ''; CUSTOMER = ''; CUSTOMER.TAX.TYPE = ''; CUSTOMER.ACCOUNT.GROUP = ''; R.TAX.TYPE.COND = '';
    TAX.TYPE.COND.ERR = ''; CUSTOMER.TAX.GROUP = ''; THE.LIST = ''; THE.ARGS = ''; TAX.CNT = ''; FORMATTED.TAX.ID = ''; R.TAX =''; TAX.RATE = '';
    R.TAX.TYPE = ''; TAX.ERR = ''; TAX.PROPERTIES = ''; TOT.TAX.REC = ''; CNT.TOT.TAX.REC = ''; TAX.TYPE.VAL = ''; CURRENCY.POS = '';
    CONSOLIDATE.TAX.RATE = ''
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Tax Property Details>
TAX.PROPERTY.DETAILS:
*--------------------
*****Get the deposit details from tax arrangement property*****
    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID,TAX.PROPERTY.CLASS,'','',TAX.PROPERTY.IDS,TAX.PROPERTY.RECORDS,TAX.ERR) ;* Get tax arrangement condition record
    TAX.PROPERTY.RECORDS         = RAISE(TAX.PROPERTY.RECORDS)                           ;* Tax record
    TAX.PROPERTIES               = TAX.PROPERTY.RECORDS<AA.Tax.Tax.TaxPropTaxCond>       ;* Tax property condition
    TAX.PROPERTIES<1,-1>         = TAX.PROPERTY.RECORDS<AA.Tax.Tax.TaxPropTaxCode>       ;* Tax code condition
    TOT.TAX.REC                  = DCOUNT(TAX.PROPERTIES,@VM)
    FOR CNT.TOT.TAX.REC = 1 TO TOT.TAX.REC
        TAX.RATE.DETAILS = ''; TAX.TYPE.DETAILS = ''
        TAX.PROPERTY.COND.VAL    = TAX.PROPERTIES<1,CNT.TOT.TAX.REC>
        IF TAX.PROPERTY.COND.VAL NE '' THEN
            GOSUB GET.TAX.DETAILS
            CONSOLIDATE.TAX.DETAILS<-1> = TAX.DETAILS
        END
    NEXT CNT.TOT.TAX.REC
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Tax Id>
GET.TAX.DETAILS:
*---------------
    TOT.TAX.PROPERTY.COND   = DCOUNT(TAX.PROPERTY.COND.VAL,@SM)
    TAX.DETAILS = ''
    FOR CNT.TAX.PROPERTY.COND = 1 TO TOT.TAX.PROPERTY.COND
        TAX.PROPERTY.COND           = TAX.PROPERTY.COND.VAL<1,1,CNT.TAX.PROPERTY.COND>
        TAX.TYPE                    = TRIM(TAX.PROPERTY.COND,'',"D")                        ;* Tax type
        TAX.TYPE.ID                 = TAX.TYPE                                              ;* Variable used to read a TAX.TYPE.CONDITION
        TAX.TYPE                    = FIELD(TAX.TYPE,'-',1)                                 ;* Removed sequence part deom the incoming value to read TAX.TYPE
        R.TAX.TYPE                  = CG.ChargeConfig.TaxType.Read(TAX.TYPE,TAX.TYPE.ERR)   ;* Read tax type
        IF R.TAX.TYPE EQ '' THEN
            TAX.ID = TAX.TYPE
            GOSUB GET.TAX.RATE      ;* Get tax rate
        END ELSE
            GOSUB GET.TAX.ID        ;* Get tax id then get tax rate
        END
        TAX.RATE.DETAILS<1,-1> = TAX.RATE
        TAX.TYPE.DETAILS<1,-1> = TAX.TYPE.VAL
        TAX.DETAILS<1,-1> = TAX.RATE : " " : TAX.TYPE.VAL
    NEXT CNT.TAX.PROPERTY.COND
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Tax Id>
GET.TAX.ID:
*----------
    CUSTOMER.DETAILS            = AA.Customer.GetArrangementCustomer(ARR.ID, "", "", "", "", CUSTOMER, CUSTOMER.DETAILS.ERR)  ;*Read the customer for the arrangement

    R.CUSTOMER.CHARGE           = CG.ChargeConfig.CustomerCharge.Read(CUSTOMER, Y.ERR)                   ;* Read the customer details
    CUSTOMER.TAX.TYPE           = R.CUSTOMER.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxType>         ;* Customer tax type
    CUSTOMER.ACCOUNT.GROUP      = R.CUSTOMER.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxActGroup>     ;* Customer tax account group

    FIND TAX.TYPE IN CUSTOMER.TAX.TYPE SETTING AP,VP THEN
        CUSTOMER.TAX.TYPE           = CUSTOMER.ACCOUNT.GROUP<1,VP>
    END

    R.TAX.TYPE.COND             = CG.ChargeConfig.TaxTypeCondition.Read(TAX.TYPE.ID, TAX.TYPE.COND.ERR)
    CUSTOMER.TAX.GROUP          = R.TAX.TYPE.COND<CG.ChargeConfig.TaxTypeCondition.TaxTtcCustTaxGrp>

    FIND CUSTOMER.TAX.TYPE IN CUSTOMER.TAX.GROUP SETTING TP,TV THEN
        TAX.ID                      = R.TAX.TYPE.COND<CG.ChargeConfig.TaxTypeCondition.TaxTtcTaxCode,TV>
        GOSUB GET.TAX.RATE
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Tax Rate>
GET.TAX.RATE:
*------------
    THE.LIST                 = dasTaxIdLikeById                                      ;* Das call
    THE.ARGS                 = TAX.ID : '....'                                       ;* Arguments for Das call
    EB.DataAccess.Das("TAX",THE.LIST,THE.ARGS,"")
    CHANGE @FM TO '*' IN THE.LIST
    TAX.CNT                  = DCOUNT(THE.LIST,'*')
    FORMATTED.TAX.ID         = FIELD(THE.LIST,'*',TAX.CNT)
    R.TAX                    = CG.ChargeConfig.Tax.Read(FORMATTED.TAX.ID, TAX.ERR)
    TAX.RATE                 = R.TAX<CG.ChargeConfig.Tax.EbTaxRate>

    IF NOT(TAX.RATE) THEN
        GOSUB GET.BANDED.RATE ;* Banded rate can be defined at TAX
    END ELSE
        TAX.RATE = TAX.RATE:"%"
    END

    R.TAX.TYPE               = CG.ChargeConfig.TaxTypeCondition.Read(TAX.PROPERTY.COND, TAX.TYPE.ERR)
    TAX.TYPE.VAL = '' ;* Initialing to avoid variable retaining from previous iteration
    BEGIN CASE
        CASE (R.TAX.TYPE EQ '') AND (R.TAX EQ '')                                                  ;* When neither of Tax Records are available do nothing
        CASE R.TAX.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcDescription, ExtLang> NE ''         ;* Priority 1
            TAX.TYPE.VAL = R.TAX.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcDescription, ExtLang> ;* Read Description from TAX.TYPE record in Ext User Language
        CASE R.TAX.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcDescription, 1> NE ''               ;* Priority 2
            TAX.TYPE.VAL = R.TAX.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcDescription, 1>       ;* Read Description from TAX.TYPE record in default Language
        CASE R.TAX<CG.ChargeConfig.Tax.EbTaxDescription, ExtLang> NE ''                            ;* Priority 3
            TAX.TYPE.VAL = R.TAX<CG.ChargeConfig.Tax.EbTaxDescription, ExtLang>                    ;* Read Description from TAX record in Ext User Language
        CASE 1                                                                                     ;* Case Otherwise
            TAX.TYPE.VAL = R.TAX<CG.ChargeConfig.Tax.EbTaxDescription, 1>                          ;* Read Descrition from TAX record in default language
    END CASE
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Banded Rate>
GET.BANDED.RATE:
*---------------
    RATE.COUNT = 1
    CURRENCY.POS = ""
    TAX.CCY = ""
    TAX.CCY = ARR.CCY
    GOSUB GET.CURRENCY.POSITON

    IF NOT(CURRENCY.POS) THEN ;**if currency not located check for default currency
        TAX.CCY = R.TAX<CG.ChargeConfig.Tax.EbTaxDefaultCcy>
        GOSUB GET.CURRENCY.POSITON
    END
    IF CURRENCY.POS THEN
        RATE.COUNT = DCOUNT(R.TAX<CG.ChargeConfig.Tax.EbTaxBandedRate,CURRENCY.POS>,@SM)
        IF RATE.COUNT GT 1 THEN
            FOR LOOP.COUNT=1 TO RATE.COUNT-1
                TAX.RATE<1,1,-1> = R.TAX<CG.ChargeConfig.Tax.EbTaxBandedRate,CURRENCY.POS,LOOP.COUNT>:"% up to ":R.TAX<CG.ChargeConfig.Tax.EbTaxUptoAmt,CURRENCY.POS,LOOP.COUNT>
            NEXT LOOP.COUNT
        END
        TAX.RATE<1,1,-1> = R.TAX<CG.ChargeConfig.Tax.EbTaxBandedRate,CURRENCY.POS,RATE.COUNT>:"% remainder" ;* Except final band, all other banded rate will have upto amount
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Get Currency Position>
GET.CURRENCY.POSITON:
*--------------------
    LOCATE TAX.CCY IN R.TAX<CG.ChargeConfig.Tax.EbTaxCurrency, 1> SETTING CURRENCY.POS ELSE   ;* Get the respective banded rate for arrangement currency
        CURRENCY.POS = ""
    END
RETURN
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
BUILD.ARRAY.DETAILS:
*---------------------------
* Build interest array details
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) ELSE
        CHANGE @SM TO "#" IN CONSOLIDATE.TAX.DETAILS
        CHANGE @VM TO "#" IN CONSOLIDATE.TAX.DETAILS
        CHANGE @FM TO "|" IN CONSOLIDATE.TAX.DETAILS
    END
    IF (('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) OR ('INFINITY' EQ EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>)) THEN
	    CHANGE @VM TO @SM IN CONSOLIDATE.TAX.DETAILS
        CHANGE @FM TO @VM IN CONSOLIDATE.TAX.DETAILS
	END
    TAX.DETAILS.ARR<-1> = CONSOLIDATE.TAX.DETAILS
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
END
