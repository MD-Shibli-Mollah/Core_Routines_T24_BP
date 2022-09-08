* @ValidationCode : MjotMjEwODE0OTMyMzpDcDEyNTI6MTYxMjQzMzg3OTU2NDpqYXlhY2hhbmQua2F0cmFnYWRkYToxOjA6MDoxOmZhbHNlOk4vQTpSMThfU1A0Ny4wOjQ4OjQ3
* @ValidationInfo : Timestamp         : 04 Feb 2021 15:47:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayachand.katragadda
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/48 (97.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R18_SP47.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank

SUBROUTINE E.BUILD.AA.ENQ.CP.LIST(ENQ.DATA)

* Modification History
*
* 22/06/15 - Defect : 1380347
*            Task   : 1386706
*            System issues with the listing of products when using the 'Change Product' activity.
*
* 30/09/15 - Defect : 1459012
*            Task   : 1484964
*            201510 - Unable to EB.COMPILE the routine E.BUILD.AA.ENQ.CP.LIST
*
* 12/05/20 - Defect : 4085265
*            Task   : 4117968
*            System should display only all PRODUCTs of the same PRODUCT.GROUP for which Change Product option is triggered.
*

    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Browser

    AAA.ACTIVITY = EB.Browser.SystemGetvariable("CURRENT.AA.ACTIVITY")
    AA.ProductFramework.GetActivityClass(AAA.ACTIVITY, AAA.ACTIVITY.CLASS, ACT.CLASS.RECORD)

    IF FIELD(AAA.ACTIVITY.CLASS,"-",2) EQ "CHANGE.PRODUCT" THEN
        GOSUB INIT
        GOSUB PROCESS
        GOSUB FORM.FINAL.ARRAY
    END
    
RETURN
*-----------------------------------------------------------------------------
INIT:
*----

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT = ''
    EB.DataAccess.Opf(FN.AA.PRODUCT,F.AA.PRODUCT)

    FINAL.SEL.LIST = ''

RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-------
    ARR.ID = EB.Browser.SystemGetvariable("CURRENT.AA.ARRANGEMENT")
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARR.ID, ERR.ARR)

    CURRENT.PRD.GRP = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductGroup>

    GOSUB GET.PRODUCT.BY.PRODUCT.GROUP
    
RETURN
*-----------------------------------------------------------------------------
GET.PRODUCT.BY.PRODUCT.GROUP:
*----------------------------
    
    TheList = AA.ProductManagement.dasAaProductCatalogIdByProductGroup
    TheArgs = CURRENT.PRD.GRP
    TableSuffix = ''
    
    EB.DataAccess.Das('AA.PRODUCT.CATALOG', TheList, TheArgs, TableSuffix)
    PRODUCT.IDS.WITH.DATE = TheList

RETURN
*-----------------------------------------------------------------------------
FORM.FINAL.ARRAY:
*----------------

    PRODUCT.LIST = ''
    LOOP
        REMOVE PRODUCT.ID.WITH.DATE FROM PRODUCT.IDS.WITH.DATE SETTING YD
    WHILE PRODUCT.ID.WITH.DATE:YD
        PRODUCT.REC = ''
        PROD.ID = FIELDS(PRODUCT.ID.WITH.DATE,'-',1)
        
        PRODUCT.REC = AA.ProductManagement.Product.Read(PROD.ID, "")
        
        BEGIN CASE
            CASE PRODUCT.REC<AA.ProductManagement.Product.PdtCatExpiryDate> LE EB.SystemTables.getToday() AND PRODUCT.REC<AA.ProductManagement.Product.PdtCatExpiryDate>   ;* Expired ignore
            CASE 1
                PRODUCT.CAT.REC = ''
                READ.ERR = ''
                tmp.TODAY = EB.SystemTables.getToday()
                AA.ProductFramework.GetProductPropertyRecord("PRODUCT", "", PROD.ID, "", "", "","", tmp.TODAY, PRODUCT.CAT.REC, READ.ERR)

                IF PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdInheritanceOnly> NE "YES" THEN
                    PRODUCT.LIST<-1> = PROD.ID
                END
        END CASE
    REPEAT

    CHANGE @FM TO ' ' IN PRODUCT.LIST
    ENQ.DATA<2,1> = '@ID'
    ENQ.DATA<3,1> = 'EQ'
    ENQ.DATA<4,1> = PRODUCT.LIST

RETURN
*-----------------------------------------------------------------------------
END
