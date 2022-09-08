* @ValidationCode : MjoxMTY3ODU5NTQzOkNwMTI1MjoxNTAzMzg1NTkwODY1OmFyY2hhbmFwcmFzYWQ6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwOC4yMDE3MDcwMy0yMTQ3Oi0xOi0x
* @ValidationInfo : Timestamp         : 22 Aug 2017 12:36:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaprasad
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.20170703-2147
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AB.ModelBank
    SUBROUTINE E.GET.BUNDLE.BALANCE.SCV
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
*
* Nofile routine used to return bundle arrangement participant account balances
*
* @uses I_ENQUIRY.COMMON
* @class
* @package retaillending.AA
* @stereotype subroutine
* @author sivakumark@temenos.com
*
**
*** </region>
*------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*
* 05/09/2014 - Task : 1077380
*              Enhancement 1052773
*              New Routine
*
* 11-06-2015 - Task : 1374858
*              Defect : 1364696
*              The Combine Group Balance enquiry in the Bundle Arrangement
*              overview is not displaying the Bundle balance.
*
*
* 13/06/17 - Enhancement : 2148615
*            Task : 2231452
*            Value markers in BunArrangements in PRODUCT.BUNDLE is changed to SM
*
*** <desc>Changes done in the sub-routine<</desc>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.ProductBundle
    $USING AA.Framework
    $USING EB.API
    $USING AA.ProductFramework
    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports


*** </region>
*----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB PROCESS

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Main Process>
*** <desc>Main Process</desc>
PROCESS:

    ARR.ID = EB.Reports.getOData()

    CHECK.DATE = EB.SystemTables.getToday()
    ARR.INFO = ARR.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    OVERDRAWN = ''
    AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

    LOCATE 'PRODUCT.BUNDLE' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
    PB.PROPERTY = PROP.LIST<1,PROD.POS>
    END
    AA.ProductFramework.GetPropertyRecord('', ARR.ID, PB.PROPERTY, CHECK.DATE, 'PRODUCT.BUNDLE', '', R.PRODUCT.BUNDLE , REC.ERR)
    
    PRD.BUNDLE.PRODUCT.GRP  = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunProductGroup>   ;* Shared accounts product group
        TOT.PRODUCT.GRP.CNT = DCOUNT(PRD.BUNDLE.PRODUCT.GRP, @VM);*to fetch the total no of Product Groups
        FOR CNT.PRODUCT.GRP = 1 TO  TOT.PRODUCT.GRP.CNT 
        *In each Product Group -Product section, arrangements are now seperated by SM           
            GOSUB PROCESS.ARRANGEMENTS 
   
NEXT CNT.PRODUCT.GRP
  RETURN
*** </region>
 *------------------------------------------------------------------------------------------------------------

*** <region name= Process Arrangements>
*** <desc>Main Process</desc>   
  PROCESS.ARRANGEMENTS:  
    
    ARRANGEMENT.IDS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunArrangement,CNT.PRODUCT.GRP>

    EB.Reports.setOData('')
    FOR CNT = 1 TO DCOUNT(ARRANGEMENT.IDS,@SM)
        R.ARRANGEMENT = ''
        ARR.ID = ARRANGEMENT.IDS<1,CNT.PRODUCT.GRP,CNT>
        AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR)
        ACCT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
        IF ACCT.ID THEN
            * As operand 1 is passed E.CALC.OPEN.BALANCE routine takes the previous day. Hence next day is passed.
            * The routine E.CALC.OPEN.BALANCE does not assign ENQ.SELECTION to O.DATA from defect 1217415. Hence account id is passed to O.DATA.
            Y.DATE = EB.SystemTables.getToday()
            EB.API.Cdt("",Y.DATE,"+01C")
            tmp=EB.Reports.getDFields(); tmp<1>="BOOKING.DATE"; EB.Reports.setDFields(tmp)
            tmp=EB.Reports.getDLogicalOperands(); tmp<1>="1"; EB.Reports.setDLogicalOperands(tmp)
            tmp=EB.Reports.getDRangeAndValue(); tmp<1>=Y.DATE; EB.Reports.setDRangeAndValue(tmp)
            tmp=EB.Reports.getEnqSelection(); tmp<4,1>=ACCT.ID; EB.Reports.setEnqSelection(tmp)
            EB.Reports.setOData(ACCT.ID)
            AC.ModelBank.ECalcOpenBalance()
            OVERDRAWN+ = EB.Reports.getOData()
        END
    NEXT CNT

    EB.Reports.setOData(OVERDRAWN)

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------

    END
