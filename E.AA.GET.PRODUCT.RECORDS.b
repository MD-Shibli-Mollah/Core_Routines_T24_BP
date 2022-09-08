* @ValidationCode : MjotMTk4NDAwNjI5ODpjcDEyNTI6MTU4MDg4Mzk2ODQ1Njp5Z2F5YXRyaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAxLjIwMTkxMjI0LTE5MzU6MjQ6MjQ=
* @ValidationInfo : Timestamp         : 05 Feb 2020 11:56:08
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : ygayatri
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ProductManagement
SUBROUTINE E.AA.GET.PRODUCT.RECORDS(ReturnData)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/01/19 - Enhancement : 3544263
*            Task        : 3544266
*            Enquiry to get the related product records   
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>

    $USING EB.Reports
    $USING AA.ProductManagement
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>

    GOSUB Initalise ;* Initialising local variables
    GOSUB GetEnquiryInput ;* Get the enquiry inputs
    GOSUB GetProductRecords ;* Get the Product records for the input record
      
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initalise>
Initalise:
*** <desc>Initialising local variables </desc>

    Company = ""    ;* get the input company
    TableName = ""  ;* get the input table name
    ProductId = ""  ;* get the input product id
    ReturnData = "" ;* return data

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GetEnquiryInput>
GetEnquiryInput:
*** <desc>Get the enquiry inputs </desc>

    EnquirySelection = EB.Reports.getEnqSelection()
    
    LOCATE "COMPANY.CODE" IN EnquirySelection<2,1> SETTING CPos THEN       ;* Determine the requested company
        Company = EnquirySelection<4,CPos>
    END

    LOCATE "APPLICATION.ID" IN EnquirySelection<2,1> SETTING APos THEN       ;* Determine the requested company
        TableName = EnquirySelection<4,APos>
    END
    
    LOCATE "RECORD.ID" IN EnquirySelection<2,1> SETTING RPos THEN       ;* Determine the requested company
        RecordId = EnquirySelection<4,RPos>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GetProductRecords>
GetProductRecords:
*** <desc>Get the Product records for the input record </desc>

    DataRecords = ""
    AA.ProductManagement.AaBuildProductRecords(Company, TableName, RecordId, "", DataRecords)

    ReturnData = DataRecords ;* Pass it back to the enquiry ID list

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
