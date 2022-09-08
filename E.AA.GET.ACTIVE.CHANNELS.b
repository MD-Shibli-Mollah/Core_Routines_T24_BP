* @ValidationCode : MjoxNTc1NDI2MDcyOkNwMTI1MjoxNTQyMDA3OTc3OTY1OnJ2YWlzaGFsaTo3OjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMC4yMDE4MDkwNi0wMjMyOjE0OToxNDM=
* @ValidationInfo : Timestamp         : 12 Nov 2018 13:02:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaishali
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 143/149 (95.9%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ACTIVE.CHANNELS(PRODUCT.LIST)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** This routine introduced to get the product list which contains the Available Channel defined in the Enquiry Selection CHANNEL
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         : AA.Framework.GetProductChannels
* @access       : module
* @stereotype   : subroutine
* @author       : rvaishali@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
*** Arguments
*
* @PRODUCT.LIST   -  Return the Product list which has Available Channels [Input/Output]
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 01/08/18 - Task : 2699028
*            Enhancement : 2612813
*            Product Eligibility - only products eligible for the channel has to be displayed.
*
* 31/10/18 - Task : 2835659
*            Enhancement : 2743166
*            Product Eligibility - only products eligible for the channel,Line of Business and Organization Level specified has to be displayed.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AA.ModelBank
    $USING EB.Reports
    $USING EB.Interface
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AA.ProductFramework
    $USING AA.ProductManagement
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise ;* Initialise Variables

    GOSUB GetChannelSelection ; *To fetch the selection criteria of CHANNEL

    GOSUB VerifyAvailableChannel ; *To verify if the product is available for the logged in channel
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise Variables </desc>
Initialise:

** Allow selection date to be supplied. We can use this to show products as at a specified date
*
    LOCATE "PRODUCT.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING DATE.POS THEN
        EnqDate = EB.Reports.getEnqSelection()<4,DATE.POS>
    END ELSE
        EnqDate = EB.SystemTables.getToday()      ;* Show as of today
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetChannelSelection>
*** <desc>To fetch the selection criteria of CHANNEL </desc>
GetChannelSelection:
    
    ChannelId = ""
    ChannelFixedSelection = 0
** Initialise variables for Line of Business
    LOBFixedSelection = 0
    LOBSelectionValue = ""
** Initialise variables for Organization Level
    OrganizationLevelFixedSelection = 0
    OrganizationLevelValue = ""
    EnquiryRecord = EB.Reports.getREnq() ;* Get the enquiry record.

    SelectionCount = DCOUNT(EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection>,@VM)
    FOR MvPos = 1 TO SelectionCount ;* For each Fixed Selection given
        BEGIN CASE
            CASE EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection,MvPos>[1,7] EQ 'CHANNEL' ;* If a selection specified for channel
                ChannelFixedSelection = 1
                SelectionValue = FIELD(EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection,MvPos>," ",3,99) ;* Get the selection value
                
            CASE EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection,MvPos>[1,16] EQ 'LINE.OF.BUSINESS' ;* If a selection specified for Line of Business
                LOBFixedSelection = 1
                LOBSelectionValue = FIELD(EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection,MvPos>," ",3,99) ;* Get the selection value
                
            CASE EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection,MvPos>[1,18] EQ 'ORGANIZATION.LEVEL' ;* If a selection specified for Organization Level(AREA,BRANCH,DIVISION,STATE,REGION)
                OrganizationLevelFixedSelection = 1
                OrganizationLevelValue = FIELD(EnquiryRecord<EB.Reports.Enquiry.EnqFixedSelection,MvPos>," ",3,99) ;* Get the selection value
                
        END CASE
        
    NEXT MvPos
 
** For Channel,Get the selection value if the fixed selection is not given
    IF NOT(ChannelFixedSelection) THEN
        ChannelSelection = "CHANNEL"
        ChannelPos = ""
        LOCATE ChannelSelection IN EB.Reports.getEnqSelection()<2,1> SETTING ChannelPos THEN ;* Get the selection value of the channel criteria
            SelectionValue = EB.Reports.getEnqSelection()<4,ChannelPos>
        END
    END
    
    IF SelectionValue EQ '' THEN
        ChannelId = EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcChannel>   ;* Get the Current Channel being used
    END ELSE
        ChannelId = SelectionValue
    END

** For Line of Business,Get the selection value if the fixed selection is not given
    IF NOT(LOBFixedSelection) THEN
        LOBSelection = "LINE.OF.BUSINESS"
        LOBPos = ""
        LOCATE LOBSelection IN EB.Reports.getEnqSelection()<2,1> SETTING LOBPos THEN ;* Get the selection value of the LINE.OF.BUSINESS criteria
            LOBSelectionValue = EB.Reports.getEnqSelection()<4,LOBPos>
        END
    END
 
** For Organization level,Get the selection value if the fixed selection is not given
    IF NOT(OrganizationLevelFixedSelection) THEN
        OrganizationLevelSelection = "ORGANIZATION.LEVEL"
        LevelPos = ""
        LOCATE OrganizationLevelSelection IN EB.Reports.getEnqSelection()<2,1> SETTING LevelPos THEN ;* Get the selection value of the ORGANIZATION.LEVEL criteria
            OrganizationLevelValue = EB.Reports.getEnqSelection()<4,LevelPos>
        END
    END
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VerifyAvailableChannel>
VerifyAvailableChannel:
*** <desc>To verify if the product is available for the logged in channel </desc>
    
    AvailableProductList = ""
    ProductListCnt = DCOUNT(PRODUCT.LIST, @FM)
    FOR ProductCnt = 1 TO ProductListCnt
        ProductId = PRODUCT.LIST<ProductCnt>
        ChannelAllowed = 0
        IF ChannelId EQ "" THEN  ;* Enter condition if all channel is available
            ChannelAllowed = 1
        END ELSE
            AvailableChannels = ""
            RestrictedChannels = ""
            ErrorDetails = ""
            AA.Framework.GetProductChannels(AA.Framework.Publish, EnqDate, ProductId, "", "", AvailableChannels, RestrictedChannels, ErrorDetails) ;* Get channels of the product
            GOSUB RestrictedChannel                     ;* Validate restricted channel
        END
    
        GOSUB CheckforLOBAvailability                   ;* Check for the Line Of Business specified in selection is available for Product
        
        GOSUB CheckForOrganizationLevelAvailability     ;* Check for the Organization level specified in selection is available for Product
            
        IF ChannelAllowed AND LOBAllowed AND OrgLevelAllowed THEN   ;* Add the Product to ProductList if Channel,Line Of Business and Organization Level is available for Product
            AvailableProductList<-1> = ProductId
        END
        
    NEXT ProductCnt

    PRODUCT.LIST = AvailableProductList
     
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get the published product record>
*** <desc> </desc>
RestrictedChannel:

    IF NOT(ChannelAllowed) THEN    ;* Enter if NoRestriction comon variable is NULL
        BEGIN CASE
            CASE AvailableChannels EQ 'ALL'
                ChannelAllowed = 1
                
            CASE AvailableChannels     ;* Verify available channel list
                LOCATE ChannelId IN AvailableChannels<1,1> SETTING AvailPos THEN
                    ChannelAllowed = 1
                END
            CASE RestrictedChannels    ;* Verify if channel is restricted
                LOCATE ChannelId IN RestrictedChannels<1,1> SETTING RestrictPos ELSE
                    ChannelAllowed = 1
                END
        END CASE
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckforLOBAvailability>
*** <desc>Check for the Line Of Business specified in selection is available for Product </desc>
CheckforLOBAvailability:
    
    LOBAllowed = 0
    
    IF LOBSelectionValue EQ "" THEN      ;* Enter condition if all Line of Business is available for the Product
        LOBAllowed = 1
    END ELSE
        GOSUB GetPublishedRecord         ;* Get the Product published record
                
        IF NOT(LineOfBusiness) AND NOT(LineOfBusinessExclude) THEN  ;* If Line of Business is not specified for the product,then the product can use all available Line of Business defined.
            LOBAllowed = 1
        END
            
        IF NOT(LOBAllowed) THEN          ;* Enter condition only if LOBAllowed flag is not set
            GOSUB VerifyAvailableLOB     ;* Verify if the line of business given in selection is avilable for Product
        END
                
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetPublishedRecord>
*** <desc>Get the Product published record </desc>
GetPublishedRecord:
    
    RProduct = ""    ;* Product record
    RetError = ""    ;* return error if any
    AA.ProductFramework.GetPublishedRecord("PRODUCT", AA.Framework.Publish, ProductId, EnqDate, RProduct, RetError) ;* Get the Product published record
** Get the Required details of field values to check
    LineOfBusiness        = RProduct<AA.ProductManagement.ProductDesigner.PrdLineOfBusiness>         ;* Get LineOfBusiness specified for Product
    LineOfBusinessExclude = RProduct<AA.ProductManagement.ProductDesigner.PrdLineOfBusinessExclude>  ;* Get LineOfBusinessExclude if specified for Product
    OrganizationLevel     = RProduct<AA.ProductManagement.ProductDesigner.PrdOrganizationLevel>      ;* Get Organization level(BRANCH,REGION,STATE,AREA,DIVISION) specified for Product
    OrganizationExclude   = RProduct<AA.ProductManagement.ProductDesigner.PrdOrganisationExclude>    ;* Get OrganisationExclude if specified for Product
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VerifyAvailableLOB>
*** <desc>Verify if the line of business given in selection is avilable for Product </desc>
VerifyAvailableLOB:

** Check if LOB specified as selection value is present in Product.If it is present,then check whether it is restricted in the Product
    LOCATE LOBSelectionValue IN LineOfBusiness<1,1> SETTING LOBPos THEN
        IF LineOfBusinessExclude<1,LOBPos> NE "YES" THEN
            LOBAllowed = 1
        END
    END ELSE
** If the LOB specified as selection value is not present in Product,check if any restiction is specified in Product.
** If there is any restriction,then the LOB given in selection value is available for Product
        LOCATE "YES" IN LineOfBusinessExclude<1,1> SETTING ExcludePos THEN
            LOBAllowed = 1
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckForOrganizationLevelAvailability>
*** <desc>Check for the Organization level specified in selection is available for Product </desc>
CheckForOrganizationLevelAvailability:
    
    OrgLevelAllowed = 0
    
    IF OrganizationLevelValue EQ "" THEN  ;* Enter condition if all Organization Level is available for the Product
        OrgLevelAllowed = 1
    END ELSE
        GOSUB GetPublishedRecord ;* Get the Product published record
           
                
        IF NOT(OrganizationLevel) AND NOT(OrganizationExclude) THEN  ;* If Level is not specified for the product,then the product can use all available levels(BRANCH,REGION,DIVISION,STATE,AREA) defined.
            OrgLevelAllowed = 1
        END
            
        IF NOT(OrgLevelAllowed) THEN               ;* Enter condition only if OrgLevelAllowed flag is not set
            GOSUB VerifyAvailableOrganizationLevel ;* Verify if the Level given in selection is available for Product
        END
            
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VerifyAvailableOrganizationLevel>
*** <desc>Verify if the Level given in selection is available for Product </desc>
VerifyAvailableOrganizationLevel:

** Check if Level specified as selection value is present in Product.If it is present,then check whether it is restricted in the Product
    LOCATE OrganizationLevelValue IN OrganizationLevel<1,1> SETTING LevelPos THEN
        IF OrganizationExclude<1,LevelPos> NE "YES" THEN
            OrgLevelAllowed = 1
        END
    END ELSE
** If the Level specified as selection value is not present in Product,check if any restiction is specified in Product.
** If there is any restriction,then the Level given in selection value is available for Product
        LOCATE "YES" IN OrganizationExclude<1,1> SETTING ExcludePos THEN
            OrgLevelAllowed = 1
        END
    END
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
