* @ValidationCode : MjotOTA5MTE1NDk5OkNwMTI1MjoxNjE0MTY4MzUwMTU4OnN1ZGhhcmFtZXNoOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzo4Mzo4MQ==
* @ValidationInfo : Timestamp         : 24 Feb 2021 17:35:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 81/83 (97.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ProductFramework
SUBROUTINE E.AA.CONV.PRODUCT.LINE.FEATURE.DETAILS
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Task of the sub-routine</desc>
*
** Program Description:
** This conversion routine will return the details of the Product line ids and mandatory details for the incoming feature
*  based on the details defined in the product line
*
*** </region>
*-----------------------------------------------------------------------------
*
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @link
* @author ndivya@temenos.com
***
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
* 11/12/20 - Task : 4126368
*            Enhancement : 3342925
*            Conversion routine to return the mandatory and Productline details for the incoming feature
*
*23/12/2020 - Task        : 4147716
*             Enhancement : 4114689
*             Routine modified to exlcude the product line details if the feature defined as part of exclude feature field in the product line
*
*08/02/2021 - Task        : 428115
*             Enhancement : 4209483
*             Get the Feature Details from the Product Group for Bundle Product Line
*
*05/02/2021 - Task        : 4201164
*             Enhancement : 4209483
*             Update the Productline as NA.PRODUCT.LINE when feature not part of any of the product lines.
*** </region>
*-----------------------------------------------------------------------------
*** <region name = inserts>
   
    $USING EB.Reports
    $USING EB.DataAccess
    $USING AA.ProductFramework
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name = MainProcess>

    GOSUB Initialise                                                    ;* Get the Feature id

    GOSUB GetListOfProductLines                                         ;* Get the required balance based on the options passed.
    GOSUB CheckFeatureAvailable                                         ;* Check if the feature exists in the Product line
    
    IF ProductLineId THEN
        ReturnData = ProductLineId:"*":MandatoryDetails                     ;* Add the data with ProductLineId*mandatoryDetails
    END ELSE
        ReturnData = "NA.PRODUCT.LINE":"*":MandatoryDetails                     ;* Add the data with ProductLineId*mandatoryDetails
    END
    
    EB.Reports.setOData(ReturnData)                                     ;* Return the details

 
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>To initialise the required variables </desc>
Initialise:
    
    Feature   = EB.Reports.getOData()       ;* Get the feature id
   
RETURN
*** </region>
**-----------------------------------------------------------------------------
*** <region name= GetListOfProductLines>
*** <desc>GetListOfProductLines</desc>
GetListOfProductLines:
    
    ProductLines = ""
    TheList = EB.DataAccess.DasAllIds                      ;* Fetch all product lines
    EB.DataAccess.Das("AA.PRODUCT.LINE", TheList, "", "")  ;* Select product line
    ProductLines = TheList                                 ;* Get the list of product lines
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckFeatureAvailable>
*** <desc>CheckFeatureAvailable</desc>
CheckFeatureAvailable:
    
    ProductLineCount= DCOUNT(ProductLines,@FM)  ;* Loop through each product line and read the product line record
    ProductLineId = ""
    MandatoryDetails = ""
    FOR Cnt = 1 TO ProductLineCount
        Mandatory = ""
        ExcludeFeature = ""
        FeatureExists = ""
        CurrProductLine = ProductLines<Cnt>
        FeatureRec = AA.ProductFramework.Property.CacheRead(Feature, Error)
        FeatureClass = FeatureRec<AA.ProductFramework.Property.PropPropertyClass>
*** For the Bundle product Line we need to fetch the Feature details from the Product Group record rather than Product line Record.
        IF CurrProductLine EQ "BUNDLE" THEN
            GOSUB GetFeatureFromGroup
        END ELSE
            GOSUB GetFeatureFromLine
        END
      
    NEXT Cnt
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFeatureFromGroup>
*** <desc>Get Feature Details from the Product Group Record for Bundle</desc>
GetFeatureFromGroup:
    
    GroupErr = ""
    GroupRec =  AA.ProductFramework.ProductGroup.CacheRead("PACKAGES", GroupErr)
*** As part of EPP, we have introduced "PACKAGES" Product group for the Bundle product line. In this product Group, we have Attached all the Feature Property Class and Feature Property Record for the
*** Particular PACKAGE Product Group. So, fetch the feature details from Group Record.
    LOCATE FeatureClass IN GroupRec<AA.ProductFramework.ProductGroup.PgPropertyClass,1> SETTING ClassPos THEN
        LOCATE Feature IN GroupRec<AA.ProductFramework.ProductGroup.PgProperty,ClassPos,1> SETTING PropPos THEN
            Mandatory = GroupRec<AA.ProductFramework.ProductGroup.PgMandatory,ClassPos,PropPos>
            GOSUB UpdateMandatoryDetails
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFeatureFromLine>
*** <desc>Get Feature Details from Product Line Record</desc>
GetFeatureFromLine:
    
    ProductLineRec = AA.ProductFramework.ProductLine.CacheRead(ProductLines<Cnt>, Error)    ;* Read the product line record
** Check if the feature is exist in the excludefeature in the product line, if so then ignore the product line id and mandatory details.
** If not exists, then get the mandatory details if feature is defined in the product line. If not read the feature class of the feature and check if
** the feature class exists in the product line
      
    LOCATE FeatureClass IN ProductLineRec<AA.ProductFramework.ProductLine.PlFeatureClass,1> SETTING FeatureClassPos THEN
        LOCATE Feature IN ProductLineRec<AA.ProductFramework.ProductLine.PlExcludeFeature,FeatureClassPos,1> SETTING ExcludePos THEN
            ExcludeFeature = "1"
        END
        IF NOT(ExcludeFeature) THEN
            GOSUB GetFeatureMandatoryDetails
            GOSUB UpdateMandatoryDetails
        END
    END ELSE
        GOSUB GetFeatureMandatoryDetails
        IF FeatureExists THEN
            GOSUB UpdateMandatoryDetails
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFeatureMandatoryDetails>
*** <desc>GetFeatureMandatoryDetails</desc>
GetFeatureMandatoryDetails:
    
    LOCATE Feature IN ProductLineRec<AA.ProductFramework.ProductLine.PlFeature,1> SETTING FeaturePos THEN
        Mandatory = ProductLineRec<AA.ProductFramework.ProductLine.PlFeatureMandatory,FeaturePos>
        FeatureExists = "1"
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UpdateMandatoryDetails>
*** <desc>UpdateMandatoryDetails</desc>
UpdateMandatoryDetails:

*** Set as Boolean values True or false based on the mandatory details

    BEGIN CASE
        CASE Mandatory EQ "YES"
            FeatureMandatory = "True"
        CASE Mandatory EQ "NO" OR Mandatory EQ ""
            FeatureMandatory = "False"
    END CASE
 
    IF NOT(MandatoryDetails) THEN
        MandatoryDetails = FeatureMandatory
    END ELSE
        MandatoryDetails := " ":FeatureMandatory
    END
    
    GOSUB AppendProductLineIds
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AppendProductLineIds>
*** <desc>AppendProductLineIds</desc>
AppendProductLineIds:
    
    IF NOT(ProductLineId) THEN
        ProductLineId = ProductLines<Cnt>
    END ELSE
        ProductLineId := " ":ProductLines<Cnt>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
