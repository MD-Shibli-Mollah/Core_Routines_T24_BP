* @ValidationCode : MjoyNzY4NzEwMzE6Q3AxMjUyOjE1ODQwOTk3MDY3MzQ6cnZhcmFkaGFyYWphbjo3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6MTI3OjEyMw==
* @ValidationInfo : Timestamp         : 13 Mar 2020 17:11:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 123/127 (96.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-45</Rating>
*-----------------------------------------------------------------------------
* Input : Tax Code or Tax Property from AA.DETAILS.TAX enquiry
* Output : Tax rate from the TAX application
*
* 05/08/10 - Task 61126
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 11/03/11 - Task 184094
*            Made changes in the logic of the routine.
*
* 31/01/14 - Task 902195
*            Defect 854537 & 817402
*            Removed sequence part from incoming value to read TAX.TYPE.
*            Change the argument passed to select tax ids based on id separator "."
*
* 09/09/15 - Task : 1447056
*            Enhancement : 1434821
*            Get the GL Custoemr by calling AA.GET.ARRANGEMENT.CUSTOMER routine.
*
* 08/06/16 - Task   : 1758904
*            Defect : 1745262
*            No data displayed on Tax on OVERVIEW screen for AR.Logic for banded tax rate is included
*
* 28/07/16 - Task   : 1809129
*            Defect : 1745262
*            No data displayed on Tax on OVERVIEW screen for AR IF banded tax rate is different currency other than arrangement ccy
*
* 01/22/18 - Enhancement : 2388930
*            Task        : 2388933
*            removal of null values from CURRENT.COND.CODE.ID array
*
* 22/03/18 - Task   : 2505947
*            Defect : 2477291
*            TAX displayed with errors in core enquiry
*
* 29/05/18 - Task : 2609025
*            Defect : 2604636
*            Get Customer Property record by calling AA.GET.ARRANGEMENT.CONDITIONS routine
*
* 30/1/19 - Task:2967666
*           Defect:2961746
*           TAX rate present in overview screen was wrong.
*
* 10/02/20 - Enhancement 3568228  / Task 3580449
*            Changing reference of routines that have been moved from ST to CG
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.GET.TAX.RATE

    $INSERT I_DAS.TAX
    $INSERT I_DAS.TAX.NOTES

    $USING CG.ChargeConfig
    $USING AA.Framework
    $USING AA.Customer
    $USING EB.DataAccess
    $USING EB.Reports
    $USING AA.Tax
 
    GOSUB INIT
    IF CURRENT.COND.CODE.ID THEN
        GOSUB FETCH.TAX.RECORD
    END
    
RETURN
    
INIT:

*** Combine both tax condition and tax code! and get the tax details based on tax code!
    CURRENT.COND.CODE.ID = EB.Reports.getRRecord()<AA.Tax.Tax.TaxTaxCondition>
    CURRENT.COND.CODE.ID<1,-1> = EB.Reports.getRRecord()<AA.Tax.Tax.TaxTaxCode>
    CURRENT.COND.CODE.ID<1,-1> = EB.Reports.getRRecord()<AA.Tax.Tax.TaxPropTaxCond>
    CURRENT.COND.CODE.ID<1,-1> = EB.Reports.getRRecord()<AA.Tax.Tax.TaxPropTaxCode>
    CURRENT.COND.CODE.ID = CHANGE(CURRENT.COND.CODE.ID,@SM,@VM) ;* All markers are changed to VM since we are not bothered whether tax code/condition is a subvalue/multivalue
    GOSUB REMOVE.NULL.VALUES;*remove null values from CURRENT.COND.CODE.ID array
    
    CURRENT.COND.CODE.ID = CURRENT.COND.CODE.ID<1,EB.Reports.getVc()>           ;* Each tax condition is processed at a time.

    tmp.ID = EB.Reports.getId()
    ARR.ID = FIELD(tmp.ID,"-",1)
    EB.Reports.setId(tmp.ID)
    R.ARR.RECORD = AA.Framework.Arrangement.Read(ARR.ID, Y.ARR.ERROR)
    ARR.CCY = R.ARR.RECORD<AA.Framework.Arrangement.ArrCurrency>

RETURN

*****************************************************
REMOVE.NULL.VALUES:
*****************************************************
   
    TOTAL.TAX.COUNT = DCOUNT(CURRENT.COND.CODE.ID,@VM)
    
    FOR I = 1 TO TOTAL.TAX.COUNT
        IF  CURRENT.COND.CODE.ID<1,I> EQ '' THEN;*if there is a null item
            DEL CURRENT.COND.CODE.ID<1,I>;*removing the null value
            I = I -1;*decresing the counter to check the value of next item that has same index as the one deleted one now
            TOTAL.TAX.COUNT = DCOUNT(CURRENT.COND.CODE.ID,@VM);*updating total number to avoid infinite loop
        END
    NEXT I
    
RETURN

*****************************************************
FETCH.TAX.RECORD:
*****************************************************

* Initialise the variables and open the necessary files

    F.TAX = ''

    F.TAX.TYPE = ''

    REC.TAX.TYPE = ''
    ERR.TAX.TYPE = ''

    TAX.ID = ''
    Y.TAX.ID = ''
    ERR.TAX = ''
    TAX.R.ID = ''
    REC.TAX = ''

    CURRENT.COND.CODE.ID = TRIM(CURRENT.COND.CODE.ID,'',"D")
    TAX.TYPE.ID = CURRENT.COND.CODE.ID    ;* Variable used to read a CURRENT.COND.CODE.ID.CONDITION
    CURRENT.COND.CODE.ID = FIELD(CURRENT.COND.CODE.ID,'-',1)    ;* Removed sequence part from the incoming value to read CURRENT.COND.CODE.ID
    
    REC.TAX.TYPE = CG.ChargeConfig.TaxType.Read(CURRENT.COND.CODE.ID, ERR.TAX.TYPE)

    IF REC.TAX.TYPE EQ '' THEN
        TAX.ID = CURRENT.COND.CODE.ID
        GOSUB GET.TAX.RATE
    END ELSE
        GOSUB TAX.PROP.INIT
        GOSUB PROCESS
    END

RETURN

*****************************************************
TAX.PROP.INIT:
*****************************************************

    F.ARRANGEMENT.LOC = ''

    F.CUS.CHARGE=''

    F.TAX.TYPE.CONDITION=''

RETURN

*****************************************************
PROCESS:
*****************************************************

* Extract the arrangement from the id.
    
    AA.Framework.GetArrangementConditions(ARR.ID, "CUSTOMER", "", "", returnIds, returnConditions, returnError);*To get property conditions for CUSTOMER property class
    RCustomer = RAISE(returnConditions);*Since Record returned is LOWERed raise it
    
    AA.Customer.GetArrangementCustomer(ARR.ID, "", RCustomer, "", "", CUSTOMER, RET.ERROR)
 
    R.CUS.CHARGE = CG.ChargeConfig.CustomerCharge.Read(CUSTOMER, Y.ERR)

    CUS.TAX.TYPE = R.CUS.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxType>
    CUS.ACT.GROUP = R.CUS.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxActGroup>

    FIND CURRENT.COND.CODE.ID IN CUS.TAX.TYPE SETTING AP,VP THEN
        CUS.TAX.TYPE = CUS.ACT.GROUP<1,VP>
    END
 
    REC.TYPE = CG.ChargeConfig.TaxTypeCondition.Read(TAX.TYPE.ID, ERR.TAX.TYPE)
    CUS.TAX.GRP = REC.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcCustTaxGrp>

    FIND CUS.TAX.TYPE IN CUS.TAX.GRP SETTING TP,TV THEN
        IF REC.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcContractGrp,TV,1> EQ "" THEN ;* Since ContractGroup is not used in AA, pick the Tax code attached in Tax Type Condition from the first position when contract group is null
            TAX.ID = REC.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcTaxCode,TV,1>
        END ELSE
            TAX.ID = REC.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcTaxCode,TV>
        END
        GOSUB GET.TAX.RATE
    END

RETURN
 
 
*****************************************************
GET.TAX.RATE:
*****************************************************

    THE.LIST = dasTaxIdLikeById
    THE.ARGS = TAX.ID : '....'          ;* added '.' to get appropriate TAX Id as the ids are in the format <ID>.<YYYYMMDD>

    EB.DataAccess.Das("TAX",THE.LIST,THE.ARGS,"")
    AA.Framework.GetSystemDate(EFFECTIVE.DATE) ;* Fetch the report run date

    TAX.DATE = FIELDS(THE.LIST,'.',2) ;* To build an array only with the effective dates of tax records.

    LOCATE EFFECTIVE.DATE IN TAX.DATE BY 'AR' SETTING T.POS THEN ;* Check the report run date in the dates array
        TAX.R.ID=FIELD(THE.LIST,@FM,T.POS) ;* Fetch the tax id with effective date as report run date.
    END ELSE
        IF T.POS GT 1 THEN
            TAX.R.ID=FIELD(THE.LIST,@FM,T.POS-1);*If report run date is not located fetch the nearest date
        END ELSE
            TAX.R.ID=FIELD(THE.LIST,@FM,T.POS) ;* Fetch the tax id with effective date as report run date.
        END
    END
    REC.TAX = CG.ChargeConfig.Tax.Read(TAX.R.ID, ERR.TAX)
    TAX.RATE = REC.TAX<CG.ChargeConfig.Tax.EbTaxRate>

    BEGIN CASE
        CASE NOT(TAX.RATE)                  ;* Banded rate can be defined at TAX
            GOSUB GET.BANDED.RATE
            EB.Reports.setOData(TAX.RATE<1,EB.Reports.getS()>)              ;* Each band rate is returned to enquiry results separately to display in separate lines
        CASE 1
            IF TAX.RATE<1,EB.Reports.getS()> THEN
                EB.Reports.setOData(TAX.RATE<1,EB.Reports.getS()> : '%')    ;* Normal tax rate without band is returned
            END
    END CASE
    
    TOTAL.RATE.COUNT = DCOUNT(TAX.RATE,@VM)
    IF EB.Reports.getSmCount() AND EB.Reports.getSmCount() LT TOTAL.RATE.COUNT THEN ;* SM.COUNT should always have maximum count of all the conditons to display all values properly
        EB.Reports.setSmCount(TOTAL.RATE.COUNT)
    END
    
RETURN
    
*****************************************************
GET.BANDED.RATE:
*****************************************************

    RATE.COUNT = 1
    CURRENCY.POS = ""
    TAX.CCY = ""
    TAX.CCY = ARR.CCY
    GOSUB GET.CURRENCY.POSITON
    
    IF NOT(CURRENCY.POS) THEN ; **if currency not located check for default currency
        TAX.CCY = REC.TAX<CG.ChargeConfig.Tax.EbTaxDefaultCcy>
  
        GOSUB GET.CURRENCY.POSITON
    END
    
   
    IF CURRENCY.POS THEN
        RATE.COUNT = DCOUNT(REC.TAX<CG.ChargeConfig.Tax.EbTaxBandedRate,CURRENCY.POS>,@SM)
        IF RATE.COUNT GT 1 THEN
            FOR LOOP.COUNT=1 TO RATE.COUNT-1
                TAX.RATE<1,-1> = REC.TAX<CG.ChargeConfig.Tax.EbTaxBandedRate,CURRENCY.POS,LOOP.COUNT>:"% up to ":REC.TAX<CG.ChargeConfig.Tax.EbTaxUptoAmt,CURRENCY.POS,LOOP.COUNT>
            NEXT LOOP.COUNT
        END
        TAX.RATE<1,-1> = REC.TAX<CG.ChargeConfig.Tax.EbTaxBandedRate,CURRENCY.POS,RATE.COUNT>:"% remainder" ;* Except final band, all other banded rate will have upto amount
    END

RETURN

*****************************************************
GET.CURRENCY.POSITON:
*****************************************************
    LOCATE TAX.CCY IN REC.TAX<CG.ChargeConfig.Tax.EbTaxCurrency, 1> SETTING CURRENCY.POS ELSE   ;* Get the respective banded rate for arrangement currency

        CURRENCY.POS = ""

    END
RETURN

END
