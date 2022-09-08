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
* <Rating>24</Rating>
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : ENQUIRY record AI.AA.PRODUCT.CATALOG-PRODUCTS
* Attached as     : Build Routine
*--------------------------------------------------------------------------------------------------------------
*Description:
*  Selection criteria for the record in AA.PRD.CAT.INTEREST.
*--------------------------------------------------------------------------------------------------------------
*Modification History
*---------------------------------------------------------------------------------------------------------------

    $PACKAGE AD.ModelBank
    SUBROUTINE E.MB.BUILD.AA.CATALOG(ENQ.DATA)

    $USING AA.PaymentSchedule
    $USING EB.DataAccess
    $USING AA.ProductFramework
    $USING EB.SystemTables

    $INSERT I_DAS.AA.PRODUCT

*** </region>
*************************
*
    GOSUB INIT
    GOSUB PROCESS

    CONVERT @FM TO " " IN PRO.ID

    ENQ.DATA<2,-1>="PRODUCT"
    ENQ.DATA<3,-1>="NE"
    ENQ.DATA<4,-1>=PRO.ID

    RETURN

*************************
*** <region=Initialise>
*** <desc>Intialise Paragraph</desc>

INIT:
**********

    THE.LIST=DAS.AA.PRODUCT$ACTIVE.PRODUCT

    THE.ARGS=EB.SystemTables.getToday():@FM:'':@FM:"DEPOSITS":@FM:EB.SystemTables.getToday()

    TABLE.SUFFIX=''

    RETURN

*** </region>

***********************
*** <region=Main Processing Para>
*** <desc>Main Processing Paragraph</desc>


PROCESS:
***********


* Select AA.PRODUCT WITH (CAT.EXPIRY.DATE GE TODAY ) OR (CAT.EXPIRY.DATE = '') + PRODUCT.LINE = DEPOSIT + CAT.AVAILABLE.DATE LE TODAY

    EB.DataAccess.Das('AA.PRODUCT',THE.LIST,THE.ARGS,TABLE.SUFFIX)

    LOOP

        REMOVE PRODUCT.ID FROM THE.LIST SETTING POS

    WHILE PRODUCT.ID:POS

        AA.ProductFramework.GetPublishedRecord('PRODUCT', '', PRODUCT.ID, PERIOD.START.DATE, R.ARR.PRODUCT, RET.ERROR)

        CURRENCY.ALL = R.ARR.PRODUCT<5>

        LOOP

            REMOVE CURRENCY FROM CURRENCY.ALL SETTING CCY.POS

        WHILE CURRENCY:CCY.POS

            tmp.TODAY = EB.SystemTables.getToday()
            AA.ProductFramework.GetProductConditionRecords(PRODUCT.ID,CURRENCY,tmp.TODAY,OUT.PROPERTY.LIST,OUT.PROPERTY.CLASS.LIST,OUT.ARRANGEMENT.LINK.TYPE,OUT.PROPERTY.CONDITION.LIST,RET.ERR)
            LOCATE "SCHEDULE" IN OUT.PROPERTY.LIST SETTING PROPERTY.FND THEN

            PROD.PROPERTY.RECORD = RAISE(OUT.PROPERTY.CONDITION.LIST<PROPERTY.FND>)

            PAY.TYPE=PROD.PROPERTY.RECORD< AA.PaymentSchedule.PaymentSchedule.PsPaymentType>

            IF PAY.TYPE EQ '' THEN

                PRO.ID<-1>=PRODUCT.ID

            END
        END

    REPEAT

    REPEAT

    RETURN

*** </region>
**********************

    END
