* @ValidationCode : MjoxMDQzODU3MjQyOkNwMTI1MjoxNjA5OTI3MzI4NDQzOnJqZWV2aXRoa3VtYXI6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgxMi0wNDM5OjE5OjE5
* @ValidationInfo : Timestamp         : 06 Jan 2021 15:32:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rjeevithkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/19 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200812-0439
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.PRODUCT.VARIATION.DETAILS(EnqData)
*-----------------------------------------------------------------------------
* <region name= subroutine Description>
* <desc>To Give the Purpose of the subroutine </desc>

* This build routine returns variations for given product
*
* </region>
*-----------------------------------------------------------------------------
*@access       : Public
*@stereotype   : subroutine
*@author       : rjeevithkumar@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 06/01/21 -  Task   : 4164923
*             Defect : 4123555
*             New build routine to return the product variations
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name = inserts>
   
    $USING EB.Reports
    $USING AA.ProductManagement
    $USING AA.ProductFramework
       
*** </region>
*-----------------------------------------------------------------------------
*** <region name = MainProcess>

    GOSUB Initialise
    IF ProductId THEN
        GOSUB MainProcess
    END
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>To initialise the required variables </desc>
Initialise:
    
    LOCATE "PRODUCT" IN EnqData<2,1> SETTING ProductPos THEN
        ProductId = EnqData<4,ProductPos> ;* Get product id
    END
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MainProcess>
*** <desc>To return the product variation </desc>
MainProcess:
    
    PublishedRecord = ""
    AA.ProductFramework.GetPublishedRecord('PRODUCT', "", ProductId, "", PublishedRecord, ValError)

    Variations = PublishedRecord<AA.ProductManagement.ProductCatalog.PrdVariation> ;* Get product variations
    GOSUB FormReturnData ;* To form the output Enqdata
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FormReturnData>
*** <desc>To form the output Enqdata</desc>
FormReturnData:
    
    CHANGE @VM TO " " IN Variations
    EnqData<2,-1> = "@ID"
    EnqData<3,-1> = "EQ"
    EnqData<4,-1> = Variations ;* return the variations to ENQ.DATA separated by spaces
        
RETURN
*** </region>
*---------------------------------------------------------------------------------
END
