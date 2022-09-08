* @ValidationCode : MjotMTE2OTcwODU2MzpDcDEyNTI6MTU3MTA3OTExMDYxMzp2a3ByYXRoaWJhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzozODozOA==
* @ValidationInfo : Timestamp         : 15 Oct 2019 00:21:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 38/38 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.PRODUCT.COMPANY.MNEMONIC
*-----------------------------------------------------------------------------
*<region name= subroutine Description>
*<desc>To Give the Purpose of the subroutine </desc>
*
* This routine will accept a Product Id from the OData of Product Id and
* return the Company Mnemonic to the Available Company OData.
*
* @uses I_ENQUIRY.COMMON
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @author vkprathiba@temenos.com
*
*</region>
*-----------------------------------------------------------------------------
* Modification History :
*
*  14/10/19 - Task  : 3341684
*             Enhan : 3341681
*             Conversion routine to Return the company mnemonic of the available company for a product
*-----------------------------------------------------------------------------
** <region name = inserts>
    
    $USING EB.Reports
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name = MainProcess>

    GOSUB Initialise                    ;* To initialise the required variables
    GOSUB GetProductDetails             ;* Get the Product information
      
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>To initialise the required variables</desc>
Initialise:
    
    ProductId = EB.Reports.getOData()   ;* Get the Product Id
    RProduct = ''
    AvailableCompany = ''
    CompanyId = ''
    CompanyMnemonic = ''
    Err = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetProductDetails>
*** <desc>To get the product details</desc>
GetProductDetails:
    
    AA.ProductFramework.GetPublishedRecord('PRODUCT', "", ProductId, "", RProduct, "")    ;* fetch the published product record
   
    IF RProduct THEN
        AvailableCompany = RProduct<AA.ProductManagement.ProductDesigner.PrdAvailableCompany>   ;* Fetch the Available Company
        IF AvailableCompany THEN
            GOSUB GetMnemonic   ;* Get the Mnemonic for the listed available company
        END ELSE    ;* Else, get all the company's Mnemonic
            FN.SOURCE.FILE.NAME = 'F.COMPANY'
            F.SOURCE.FILE.NAME = ''
            SelectStatement = ''
            EB.DataAccess.Opf(FN.SOURCE.FILE.NAME, F.SOURCE.FILE.NAME)
            RCompany = ''
            SelectStatement = 'SELECT ': FN.SOURCE.FILE.NAME ;* Select statement to fetch the all the company
            EB.DataAccess.Readlist(SelectStatement, AvailableCompany, '', '', Err)  ;* Fetch the companies
            CHANGE @FM TO @VM IN AvailableCompany
            GOSUB GetMnemonic   ;* Get the Mnemonic for the selected company
        END
    END

    EB.Reports.setOData(CompanyMnemonic)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetMnemonic>
*** <desc>To get the Mnemonic of the Company</desc>
GetMnemonic:
    
    TotAvailCmpy = DCOUNT(AvailableCompany, @VM)
    
    LOOP
        REMOVE CompanyId FROM AvailableCompany SETTING CPos
    WHILE CompanyId:CPos
        RCompany = ''
        RCompany = ST.CompanyCreation.Company.CacheRead(CompanyId, Err)     ;* Read the company record
        CompanyMnemonic<1,-1> = RCompany<ST.CompanyCreation.Company.EbComMnemonic>  ;* Fetch the Mnemonic
    REPEAT
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
