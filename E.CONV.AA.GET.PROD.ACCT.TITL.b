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
* <Rating>13670</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE AA.ModelBank
    SUBROUTINE E.CONV.AA.GET.PROD.ACCT.TITL
*-----------------------------------------------------------------------------
*
* New enquiry routine to get account title of a product from the cataloged condition 
* O.DATA should have the arrangement ID and will return the account title.
*
* Modification History
*
* 31/12/15 - Task   : 1585963
*            Defect : 1580518
*            Conversion routine attached to the enquiry
*            Retuns account title description from product condition
*-----------------------------------------------------------------------------
*

    $USING AA.Framework
    $USING AA.Account
    $USING EB.Reports
    $USING EB.SystemTables
    
*
    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INITIALIZE:
*-------

    ARRANGEMENT.ID = EB.Reports.getOData()
    EFFECTIVE.DATE = EB.SystemTables.getToday()

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-------

    AA.Framework.GetArrangement(ARRANGEMENT.ID, R.ARR.REC, ARR.ERR)  ;* Get arrangement to find the currency
    ARR.CCY = R.ARR.REC<AA.Framework.Arrangement.ArrCurrency>

    PRODUCT.ID = ""
    AA.Framework.GetArrangementProduct(ARRANGEMENT.ID,EFFECTIVE.DATE,'',PRODUCT.ID,'') ;* To get the current product of the arrangement

    IF PRODUCT.ID THEN        ;* Get account condition defined at product level
        OUT.PROPERTY.LIST = "" ; OUT.PROPERTY.CLASS.LIST = ""
        OUT.ARRANGEMENT.LINK.TYPE = "" ; OUT.PROPERTY.CONDITION.LIST = "" ; RET.ERR = ""

        CALL AA.GET.PRODUCT.CONDITION.RECORDS(PRODUCT.ID, ARR.CCY, EFFECTIVE.DATE, OUT.PROPERTY.LIST, OUT.PROPERTY.CLASS.LIST, OUT.ARRANGEMENT.LINK.TYPE,OUT.PROPERTY.CONDITION.LIST,RET.ERR)

        LOCATE 'ACCOUNT' IN OUT.PROPERTY.CLASS.LIST<1> SETTING ACCT.POS THEN
            PROD.PROPERTY.RECORD = RAISE(OUT.PROPERTY.CONDITION.LIST<ACCT.POS>)
            EB.Reports.setOData(PROD.PROPERTY.RECORD<AA.Account.Account.AcAccountTitleOne>)
        END
    END


    RETURN
*-----------------------------------------------------------------------------

END
