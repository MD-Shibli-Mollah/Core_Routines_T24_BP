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
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : ENQUIRY record AA.PRD.INTEREST.RATE
* Attached as     : Build Routine
*--------------------------------------------------------------------------------------------------------------
*Description:
*  Selection criteria for the record in AA.PRD.CAT.INTEREST.
*--------------------------------------------------------------------------------------------------------------
*Modification History
*---------------------------------------------------------------------------------------------------------------

    $PACKAGE AD.ModelBank
    SUBROUTINE E.MB.AA.PRODUCT.INTEREST(ENQ.DATA)

    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING AA.Framework
    $INSERT I_System


*** </region>
*************************
*
    GOSUB INITIALISE
    GOSUB PROCESS

*
    ENQ.DATA<2,-1> = "@ID"

    ENQ.DATA<3,-1> = "EQ"

    ENQ.DATA<4,-1> = CAT.INT.ID

    RETURN
*************************
*** <region=Initialise>
*** <desc>Intialise Paragraph</desc>


INITIALISE:
******************

    PRODUCT.ID = System.getVariable('CURRENT.PRODUCT')

    OUT.PROPERTY.LIST      = ''

    RET.ERROR = ''

    EFFECTIVE.DATE =EB.SystemTables.getToday()


    F.AA.PRD.CAT = ''

    RETURN

*** </region>

***********************
*** <region=Main Processing Para>
*** <desc>Main Processing Paragraph</desc>


PROCESS:
************

    PERIOD.START.DATE= EB.SystemTables.getToday()

    SAVE.PROPERTY.CLASS.LIST = AA.Framework.getAaPropertyClassList()	;* save the common variable value

    AA.Framework.setAaPropertyClassList('')

    AA.ProductFramework.GetPublishedRecord('PRODUCT', '', PRODUCT.ID, PERIOD.START.DATE, R.ARR.PRODUCT, RET.ERROR)      ;* Get the published product record

    CURRENCY.ALL = R.ARR.PRODUCT<AA.ProductManagement.ProductCatalog.PrdCurrency>

    AA.ProductFramework.GetPropertyName(R.ARR.PRODUCT, 'INTEREST', OUT.PROPERTY.LIST)

    AA.Framework.setAaPropertyClassList(SAVE.PROPERTY.CLASS.LIST);* restore the common variable value

    LOOP

        REMOVE PROPERTY FROM OUT.PROPERTY.LIST SETTING PROPERTY.POS

    WHILE PROPERTY:PROPERTY.POS


        GOSUB GET.CURRENCY.POSITION

    REPEAT

    CONVERT @FM TO " " IN CAT.INT.ID

    RETURN

GET.CURRENCY.POSITION:
*********************

    FOR CCY.CNT = 1 TO DCOUNT(CURRENCY.ALL,@VM)

        XREF.ID=PRODUCT.ID:'-':PROPERTY:'-':CURRENCY.ALL<1,CCY.CNT>

        R.XREF = AA.ProductFramework.PrdCatDatedXref.Read(XREF.ID, '')

        CAT.INT.ID<-1>= XREF.ID:'--':R.XREF<2>

    NEXT CCY.CNT

    RETURN

*** </region>
**********************

    END
