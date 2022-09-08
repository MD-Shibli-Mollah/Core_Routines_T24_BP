* @ValidationCode : MjoxNzU1NjkzODQ5OkNwMTI1MjoxNTc2MzA1ODEwMDk2OnlnYXlhdHJpOjExOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTExLjIwMTkxMDIyLTA4MzQ6ODY6NzI=
* @ValidationInfo : Timestamp         : 14 Dec 2019 12:13:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygayatri
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 72/86 (83.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.20191022-0834
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-84</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ACTIVE.PRODUCTS(PRODUCT.LIST)
*
** Arguments:
**  PRODUCT.LIST = list of products returned for the enquiry.
** Uses
**  Selection File - AA.PRODUCT
**  ENQ.SELECTION - fixed selection criteria which need to be defined in SS for AA.PRODUCT
**   ACTIVE.PRODUCTS - mandatory to invoke this routine. A value of PRODUCT.GROUP
**                     will result in one product per product group only being returned
**   PUBLISH.STAGE   - allows the stage of products to be specifed. Can be:
**                     CATALOG (default) - published products
**                     PROOF - proofed products
**                     DESIGNER - designed products
**   PRODUCT.DATE    - Date view of products is required for default is TODAY
**************
** Processing
** Returns the active products as at the specifed PRODUCT.DATE
** Does not return inheritance only products
** Does not return expired products
** For published or proofed products does not return products yet to be published or proofed
** Notes:
**  Sorting of products will be managed in the ENQUIRY using the sort options
**  Additional inclusion/exclusion of products will be managerd in enquiry based on selection of AA.PRODUCT
**
**************
* 29/02/08 - BG_100017314
*            Changes done to return one item per product group
*            if ACTIVE.PRODUCTS EQ 'PRODUCT.GROUP'
*            for packaging.
*
* 19/06/08 - CI_10056197
*           Ref : HD0812952
*            Don't show proudct in catlog which is not available for the date
*
* 25/09/08 - BG_100020118
*            SELECT command modified to cater LIKE scenario properly for AA id's.
*
* 14/10/09 - CI_10066825
*            Ref : HD0939488
*            SELECT command modified to be compatible with SQL.
*
* 20/10/09 - CI_10067083
*            Performance improvement to display PRODUCT.GROUPS menu.
*
* 10/04/13 - Task   : 646268
*            Defect : 642385
*            Product has been displayed on that exipiry day.
*
* 15/03/16 - Task   : 1663729
*            Defect : 1312305
*            Inherited products shouldn't added into the product list
*
* 08/11/16 - Task : 1882799
*            Enhancement : 1882450
*            Product Eligibility - only products with AVAIALBLE.COMPANY containing current company
*            should be returned
*
* 01/08/18 - Task : 2699028
*            Enhancement : 2612813
*            Product Eligibility - only products eligible for the channel has to be displayed.
*
* 04/01/19 - Enhancement :
*            Task        :
*            only products which are not default product should be displayed
*
* 10/09/19 - Enhancement : 3309351
*            Task        : 3309355
*            only products which are not memo product should be displayed
*
*18/09/19 - Enhancement : 3309342
*            Task : 3342265
*            EB.READLIST is changed to DAS routine for increasing performance
*
***************

    $USING AA.ProductManagement
    $USING AA.Framework
    $USING EB.DataAccess
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CompanyCreation

************
    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
***********************************
INITIALISE:
*****************
*
** A value of "PRODUCT.GROUP" in ACTIVE.PRODUCTS will result in a list of parent level
** records only
*
    LOCATE 'ACTIVE.PRODUCTS' IN EB.Reports.getEnqSelection()<2,1> SETTING ACT.POS THEN
        ACT.PROD = EB.Reports.getEnqSelection()<4,ACT.POS>
    END ELSE
        ACT.PROD = ""
    END
*
** In future this enquiry routine could be used by the product builder and the stage
** would be required
*
    LOCATE "PUBLISH.STAGE" IN EB.Reports.getEnqSelection()<2,1> SETTING PUB.POS THEN
        PUBLISH.STAGE = EB.Reports.getEnqSelection()<4,PUB.POS>
    END ELSE
        PUBLISH.STAGE = "CATALOG"
    END
    GOSUB DETERMINE.FILE.STAGE
*
** Allow selection date to be supplied. We can use this to show products as at a specified date
*
    LOCATE "PRODUCT.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING DATE.POS THEN
        ENQ.DATE = EB.Reports.getEnqSelection()<4,DATE.POS>
    END ELSE
        ENQ.DATE = EB.SystemTables.getToday()      ;* Show as of today
    END
*
    FN.AA.PRD = 'F.AA.PRODUCT'
    FV.AA.PRD = ''
    EB.DataAccess.Opf(FN.AA.PRD,FV.AA.PRD)
*
RETURN
*
DETERMINE.FILE.STAGE:
*
    BEGIN CASE
        CASE PUBLISH.STAGE = "CATALOG"
            PUBLISH.FILE.STAGE = AA.Framework.Publish
        CASE PUBLISH.STAGE = "PROOF"
            PUBLISH.FILE.STAGE = AA.Framework.Proof
        CASE PUBLISH.STAGE = "DESIGNER"
            PUBLISH.FILE.STAGE = AA.Framework.Product
        CASE 1
            PUBLISH.FILE.STAGE = AA.Framework.Publish
    END CASE
*
RETURN
*
****************************************
PROCESS:
*****************
*Since no DAS routines are there for AA products, call EB.READLIST for now
* and perform a simple select on all products (there won;t be very many of them)
*
** We could CACHE.READ the product and the selection of the product as the new arrangement
** activity will used the cached records only
*
    ID.LIST = EB.DataAccess.DasAllIds    ;* Fetch all products
    EB.DataAccess.Das("AA.PRODUCT", ID.LIST, "", "")
*
** Go through the list of products and filter out:
** Not published (for the catalog)
** Expired products
** Inherticance only - to get this value we need the current product record
** Forward dated
*
    PRODUCT.LIST = ''
    PRODUCT.GROUP.LIST = ''   ;* Used to build a list of product groups
    S.CURR.COMP = EB.SystemTables.getIdCompany() ;* Current logged on company
    RCOMPANY = ST.CompanyCreation.Company.CacheRead(S.CURR.COMP, Error) ;* Company record
    LOCAL.COUNTRY = RCOMPANY<ST.CompanyCreation.Company.EbComLocalCountry>  ;* local country
    LOCAL.REGION = RCOMPANY<ST.CompanyCreation.Company.EbComLocalRegion>    ;* local region
    
    LOOP
        REMOVE PROD.ID FROM ID.LIST SETTING YD
    WHILE PROD.ID:YD
        PRODUCT.REC = ''
        PRODUCT.REC = AA.ProductManagement.Product.Read(PROD.ID, "")
        BEGIN CASE
            CASE PRODUCT.REC<AA.ProductManagement.Product.PdtCatAvailableDate> = '' AND PUBLISH.STAGE = "CATALOG"    ;* Not published ignore
            CASE PRODUCT.REC<AA.ProductManagement.Product.PdtCatExpiryDate> LE ENQ.DATE AND PRODUCT.REC<AA.ProductManagement.Product.PdtCatExpiryDate> AND PUBLISH.STAGE = "CATALOG"          ;* Expired ignore
            CASE PRODUCT.REC<AA.ProductManagement.Product.PdtPrfAvailableDate> = '' AND PUBLISH.STAGE = "PROOF"      ;* Not proofed ignore
            CASE PRODUCT.REC<AA.ProductManagement.Product.PdtPrfExpiryDate> LE ENQ.DATE AND PRODUCT.REC<AA.ProductManagement.Product.PdtPrfExpiryDate> AND PUBLISH.STAGE = "PROOF"  ;* Expired ignore
            CASE ACT.PROD = "PRODUCT.GROUP" AND PRODUCT.REC<AA.ProductManagement.Product.PdtProductGroup> MATCHES PRODUCT.GROUP.LIST      ;* Already in the list
            CASE 1
                PRODUCT.CAT.REC = ''
                READ.ERR = ''
                AA.ProductFramework.GetProductPropertyRecord("PRODUCT", PUBLISH.FILE.STAGE, PROD.ID, "", "", "","", ENQ.DATE, PRODUCT.CAT.REC, READ.ERR)
                IF PRODUCT.CAT.REC AND PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdInheritanceOnly> NE "YES" AND PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdDefaultProduct> NE "YES" AND PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdMemo> NE "YES"  THEN  ;* Memo product should not be displayed
                    AVAILABLE.COMP = PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdAvailableCompany>
                    AVAILABLE.COUNTRY = PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdAvailableCountry>
                    AVAILABLE.REGION = PRODUCT.CAT.REC<AA.ProductManagement.ProductDesigner.PrdAvailableRegion>
                    
                    BEGIN CASE
   
                        CASE AVAILABLE.COMP   ;* If available company is defined check agains current company
                            FIND S.CURR.COMP IN AVAILABLE.COMP SETTING I.POS.FM,I.POS.VM THEN
                                PRODUCT.LIST<-1> = PROD.ID
                                PRODUCT.GROUP.LIST<1,-1> = PRODUCT.REC<AA.ProductManagement.Product.PdtProductGroup>
                            END
                        
                        CASE AVAILABLE.COUNTRY  ;* if Available country is given check against available country
                            FIND LOCAL.COUNTRY IN AVAILABLE.COUNTRY SETTING I.POS.FM,I.POS.VM THEN
                                PRODUCT.LIST<-1> = PROD.ID
                                PRODUCT.GROUP.LIST<1,-1> = PRODUCT.REC<AA.ProductManagement.Product.PdtProductGroup>
                            END
                        
                        CASE AVAILABLE.REGION   ;* if available region is given check against available region
                            FIND LOCAL.REGION IN AVAILABLE.REGION SETTING I.POS.FM,I.POS.VM THEN
                                PRODUCT.LIST<-1> = PROD.ID
                                PRODUCT.GROUP.LIST<1,-1> = PRODUCT.REC<AA.ProductManagement.Product.PdtProductGroup>
                            END
                        
                        CASE 1
                            PRODUCT.LIST<-1> = PROD.ID
                            PRODUCT.GROUP.LIST<1,-1> = PRODUCT.REC<AA.ProductManagement.Product.PdtProductGroup>
                    END CASE
                END
                
        END CASE
    REPEAT
    AA.ModelBank.EAaGetActiveChannels(PRODUCT.LIST)   ;* Get Product Available Channels in available company
*
RETURN
***********************
