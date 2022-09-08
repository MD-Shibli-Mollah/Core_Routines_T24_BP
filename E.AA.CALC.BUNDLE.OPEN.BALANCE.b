* @ValidationCode : MjoxOTY2OTQ5MDU5OkNwMTI1MjoxNTAzMzkwOTQ5MTM2OmFyY2hhbmFwcmFzYWQ6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwOC4yMDE3MDcwMy0yMTQ3Oi0xOi0x
* @ValidationInfo : Timestamp         : 22 Aug 2017 14:05:49
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
* <Rating>-55</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AB.ModelBank
SUBROUTINE E.AA.CALC.BUNDLE.OPEN.BALANCE
*** <region name= Description> 
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* This routine returns the opening balance for the period inputted
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc> </desc>
*
* Parameters:
*
* Input
*
*** </region >
*-----------------------------------------------------------------------------
*
*** <region name= Modification history>
***
*
*
*
* 13/06/17 - Enhancement : 2148615
*            Task : 2231452
*            Value markers in BunArrangements in PRODUCT.BUNDLE is changed to SM
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Inserts used by the routine>
***

    $USING AA.Framework
    $USING AA.ProductBundle
    $USING AA.ProductFramework
    $USING AC.ModelBank
    $USING EB.Reports
    $USING EB.SystemTables


*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Main Process>
***
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Initialise local variables>
***
INITIALISE:

    ARRANGEMENT.ID = ""
    PERIOD.START.DATE = ""
    ARR.INFO = ""
    CHECK.DATE = ""
    R.ARRANGEMENT = ""
    PROP.LIST= ""
    PB.PROPERTY = ""
    START.DATE = ""
    END.DATE = ""
    R.PRODUCT.BUNDLE = ""
    PRODUCT.ID = ""
    PERIOD.END.DATE = ""

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Main Process>
***
PROCESS:

    GOSUB GET.SELECTION.DETAILS
    GOSUB FIND.RECIPIENT.ARRANGEMENT.DETAILS

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Get bundle arrangement id and dates>
***
GET.SELECTION.DETAILS:

    ARRANGEMENT.ID = EB.Reports.getOData()

    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING YBOOK.POS THEN
        PERIOD.START.DATE = EB.Reports.getDRangeAndValue()<YBOOK.POS>
        START.DATE = PERIOD.START.DATE<1,1,1>
        END.DATE = PERIOD.START.DATE<1,1,2>
        tmp=EB.Reports.getDRangeAndValue(); tmp<YBOOK.POS>=END.DATE; EB.Reports.setDRangeAndValue(tmp)
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Find recipient arrangement details>
***
FIND.RECIPIENT.ARRANGEMENT.DETAILS:

    CHECK.DATE = EB.SystemTables.getToday()
    ARR.INFO = ARRANGEMENT.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

    LOCATE 'PRODUCT.BUNDLE' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
        PB.PROPERTY = PROP.LIST<1,PROD.POS>
    END
    AA.ProductFramework.GetPropertyRecord('', ARRANGEMENT.ID, PB.PROPERTY, START.DATE, 'PRODUCT.BUNDLE', '', R.PRODUCT.BUNDLE , REC.ERR)
    ARRANGEMENT.IDS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunArrangement>

    TOTAL.AMOUNT = 0
    FOR PRD.CNT = 1 TO DCOUNT(ARRANGEMENT.IDS,@VM);*to fetch the total no of Product Groups
        GOSUB FIND.RECIPIENT.PRD.ARRANGEMENT.DETAILS
    NEXT PRD.CNT

    EB.Reports.setOData(TOTAL.AMOUNT)

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Find recipient arrangement details in each product group>
***
FIND.RECIPIENT.PRD.ARRANGEMENT.DETAILS:
*In PRODUCT.BUNDLE Bundle arrangements are now changed to SM seperated under Each Product-Product Group .
    FOR CNT = 1 TO DCOUNT(ARRANGEMENT.IDS<1,PRD.CNT>,@SM)
        EB.Reports.setOData('')
        R.ARRANGEMENT = ''
        ARR.ERROR = ''
        ARR.ID = ARRANGEMENT.IDS<1,PRD.CNT,CNT>
        AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR)
        ACCT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
        IF ACCT.ID THEN
            tmp=EB.Reports.getEnqSelection(); tmp<4,1>=ACCT.ID; EB.Reports.setEnqSelection(tmp)
            AC.ModelBank.ECalcOpenBalance()
        END
        TOTAL.AMOUNT = TOTAL.AMOUNT + EB.Reports.getOData()
 
    NEXT CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
