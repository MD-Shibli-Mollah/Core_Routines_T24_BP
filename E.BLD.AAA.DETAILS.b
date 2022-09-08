* @ValidationCode : Mjo0NjM3MzI1NTQ6Q3AxMjUyOjE1Njk5MzYxMDUyODM6cmplZXZpdGhrdW1hcjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6ODo4
* @ValidationInfo : Timestamp         : 01 Oct 2019 18:51:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rjeevithkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/8 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.BLD.AAA.DETAILS(ENQ.DATA)
*-----------------------------------------------------------------------------
* Routine Description:
*---------------------
* Build routine for E.CUS.REL.PRICING.ARR enquiry attached to PRICING.PLAN field in
* AA.ARRANGEMENT.ACTIVITY,AA.NEW vesion. This routine gets the PRICING.SELECTION
* field's value.
*
*-----------------------
* Modification History :
*-----------------------
*
* 20-03-2014 - Defect 931975
*              New dropdown enquiry for PRICING.PLAN field
*
* 06-08-18  - Defect -  2691326
*              Task   - 2708761
*              Pricing Plan for the customer is not displayed in E.CUS.REL.PRICING.ARR
*
* 01/10/19  - Defect: 3361759
*             Task  : 3367667
*             Pricing plan not displayed even though pricing linked to bundle customer
*-----------------------------------------------------------------------------

    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Template
    $USING AA.PricingRules

    ARRANGEMENT.ID = ENQ.DATA<4> ;* Arrangement id
    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "PRICING.RULES", "", "", "", PRICING.COND.REC, ReturnError) ;* Get the pricing property condition for given arrangement id
    PRICING.COND.REC = RAISE(PRICING.COND.REC)
    PRICING.SELECTION.VALUE = PRICING.COND.REC<AA.PricingRules.PricingRules.PricePlanSelectMethod> ;* Assign the pricing selection from condition record
       
    ENQ.DATA<2,-1> = 'PRICING.SEL'
    ENQ.DATA<3,-1> = 'EQ'
    ENQ.DATA<4,-1> = PRICING.SELECTION.VALUE
    
RETURN

END
