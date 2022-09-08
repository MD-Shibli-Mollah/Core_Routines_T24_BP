* @ValidationCode : MjoxNzEyNDg4MTI1OmNwMTI1MjoxNTg1MjkwNzgyNzA4OnlnYXlhdHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Oi0xOi0x
* @ValidationInfo : Timestamp         : 27 Mar 2020 12:03:02
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : ygayatri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-59</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.NOFILE.CUS.REL.PRICING.ARR(REL.PRICE.ARRAY)
*-----------------------------------------------------------------------------
* Routine Description:
*---------------------
* Nofile routine for E.CUS.REL.PRICING.ARR enquiry attached for dropdown in
* AA.ARRANGEMENT.ACTIVITY,AA.NEW version. This routine displays all the
* RELATIONSHIP.PRICING product line arrangements for the customer selected.
*
*-----------------------
* Modification History :
*-----------------------
*
* 20-03-2014 - Defect 931975
*              New dropdown enquiry for PRICING.PLAN field
*
* 10-06-2015 - Defect 1368653
*              Error while deploying the versions through design studio. Backpatching 979400 task to dev.
*              Dropdown enquiry included for PRICING.PLAN field in AAA,AA.DRILL.CP AAA,,AA.DRILL.PR and AAA,AA.DRILL versions
*              As these drill down versions do not have customer we get the arrangement id and fecth Customer in this routine.
*
* 05/03/20 - Defect : 3380493
*            Task   : 3616915
*            Display the Pricing plan dropdown for BUNDLE-PLAN.RESET activity as the
*            PricingSelection for it will be defaulted by system as MANUAL later.
*
*-----------------------------------------------------------------------------

    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INIT
    GOSUB ENQ.SELECTION.VALUES

** The dropdown will display value only when PRICING.SELECTION is "MANUAL"
** and for plan reset activity as pricing selection will be defaulted to MANUAL by system
    IF PRICING.SEL.VALUE EQ 'MANUAL' OR ACTIVITY EQ "BUNDLE-PLAN.RESET" THEN
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

* Initialising variables
    ARR.CUS = ""
    ALL.CUS.ARR = ""
    CUR.ARR.ID = ''
    R.ARRANGEMENT = ''

    REL.PRICE.ARRAY = ""
    REL.PRICE.ARR.IDS = ""
    REL.PRICE.ARR.CNT = ""

    EFF.DATE = EB.SystemTables.getToday()          ;* To show the current product as of today

    F.AA.CUSTOMER.ARRANGEMENT = ''
    
    ACTIVITY = FIELD(EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActActivity),"-",1,2)

RETURN

*-----------------------------------------------------------------------------
ENQ.SELECTION.VALUES:
*-----------------------------------------------------------------------------
* Fetching CUSTOMER and PRICING.SELECTION values from AA.ARRANGEMENT.ACTIVITY
* For drill versions we get ARRANGEMENT ID from enquiry selection and fetch customer here

    LOCATE 'CUSTOMER' IN EB.Reports.getDFields()<1> SETTING CUST.ID.POS THEN
        ARR.CUS = EB.Reports.getDRangeAndValue()<CUST.ID.POS>
    END

    LOCATE 'PRICING.SEL' IN EB.Reports.getDFields()<1> SETTING PRICING.SEL.POS THEN
        PRICING.SEL.VALUE = EB.Reports.getDRangeAndValue()<PRICING.SEL.POS>
    END

* For drilling versions which will not have value in CUSTOMER we user ARRANGEMENT ID to get CUSTOMER.

    IF ARR.CUS EQ '' THEN
        LOCATE 'ARRANGEMENT' IN EB.Reports.getDFields()<1> SETTING CURR.ARR.ID.POS THEN
            CUR.ARR.ID = EB.Reports.getDRangeAndValue()<CURR.ARR.ID.POS>
            AA.Framework.GetArrangement(CUR.ARR.ID,R.ARRANGEMENT, RET.ERROR)
            ARR.CUS = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer>
        END
    END

RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    R.AA.CUSTOMER.ARRANGEMENT = AA.Framework.CustomerArrangement.Read(ARR.CUS, ERR.CUS.ARR)
    ALL.CUS.PROD.LINE = R.AA.CUSTOMER.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrProductLine>

    LOCATE "RELATIONSHIP.PRICING" IN ALL.CUS.PROD.LINE<1,1> SETTING PROD.POS THEN         ;* Only arrangements under RELATIONSHIP.PRICING product line for this CUSTOMER
        ALL.CUS.ARR = R.AA.CUSTOMER.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrArrangement>
        REL.PRICE.ARR.IDS = ALL.CUS.ARR<1,PROD.POS>
        LOOP
            REMOVE ARR.ID  FROM REL.PRICE.ARR.IDS SETTING ARR.ID.POS
        WHILE ARR.ID : ARR.ID.POS
            GOSUB GET.AA.PROD.DETS
            REL.PRICE.ARRAY<-1> = PRODUCT.ID
        REPEAT
    END

RETURN

*-----------------------------------------------------------------------------
GET.AA.PROD.DETS:
*-----------------------------------------------------------------------------

    ARR.RECORD = ''
    AA.Framework.GetArrangementProduct(ARR.ID, EFF.DATE, ARR.RECORD, PRODUCT.ID, PROPERTY.LIST)

RETURN

*-----------------------------------------------------------------------------
END
*-----------------------------------------------------------------------------
