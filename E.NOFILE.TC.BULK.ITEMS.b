* @ValidationCode : Mjo3Njk0MDMyOTA6Q3AxMjUyOjE1MTg1MDc2MDg2NjA6dnBkaWxpcGt1bWFyOjM6MDotNzQ6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDEuMjAxNzEyMjMtMDE1MTo1Nzo1Nw==
* @ValidationInfo : Timestamp         : 13 Feb 2018 13:10:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vpdilipkumar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -74
* @ValidationInfo : Coverage          : 57/57 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171223-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-58</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.Channels
SUBROUTINE E.NOFILE.TC.BULK.ITEMS(OUT.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which returns a list of bulk items related to a bulk payment
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.BULK.ITEMS using the Standard selection NOFILE.TC.BULK.ITEMS
* IN Parameters      : Item Id(ITEM.ID)
* Out Parameters     : Array of Bulk item details such as Item Id, Reference, Account No, Sort Code, Currency,
*                      Amount, Value Date, Status, Beneficiary Nickname, Local Currency, Customer No (OUT.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* * 11/01/2018  - Enhancement 2389785 / Task 2410871
*             TCIB2.0 Corporate - Advanced Functional Components - Bulk payments
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the subroutine. </desc>
*Inserts

    $INSERT I_DAS.FT.BULK.ITEM
    $INSERT I_DAS.FT.BULK.ITEM.NOTES

    $USING FT.Channels
    $USING EB.Reports
    $USING EB.SystemTables
    $USING FT.Clearing
    $USING EB.DataAccess
    
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing logic. </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine </desc>
INITIALISE:
*----------

    OUT.DATA = '' ;LocalCurrency=''; RFtBulkItem = '' ; ErrorItem = '' ; ItemList = '';LiveItemsList='';UnauthorisedItemsList='' ;*Initialising the variables
    Item = '' ; AccountNo = '' ; SortCode = '' ; Currency = '';Amount='';ItemDate='';ItemStatus='';BeneficiaryId='';RecordStatus='';CustomerNo='' ;*Initialising the variables
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>This has the main processing logic to appropriately select Bulk item records. </desc>
PROCESS:
*-------

    LocalCurrency = EB.SystemTables.getLccy();

    LOCATE 'ITEM.ID' IN EB.Reports.getDFields()<1> SETTING ItemPosition THEN
        EB.Reports.setId(EB.Reports.getDRangeAndValue()<ItemPosition>)
    END

* For retrieving Live records

    THE.LIST = dasFtBulkItemLikeMasterId          ;* Setting values for DAS Arguments
    THE.ARGS=EB.Reports.getId() ;*Retrieve Bulk item id
    TABLE.SUFFIX='' ;*Set Blank for LIVE table
    EB.DataAccess.Das("FT.BULK.ITEM",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch live records
    LiveItemsList=THE.LIST ;*Set the Live items list returned by DAS

* For retrieving Unauth record details

    THE.LIST = dasFtBulkItemLikeMasterId          ;* Setting values for DAS Arguments
    THE.ARGS=EB.Reports.getId() ;*Retrieve Bulk item id
    TABLE.SUFFIX='$NAU' ;*Set the suffix to refer INAU table
    EB.DataAccess.Das("FT.BULK.ITEM",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch INAU records
    UnauthorisedItemsList=THE.LIST ;*Set the Unauthorised items list returned by DAS

    ItemList = LiveItemsList:@FM:UnauthorisedItemsList

    GOSUB PROCESS.ITEM
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS.ITEM>
*** <desc>This has the logic to process the Bulk items selected for display. </desc>
PROCESS.ITEM:
*------------
    LOOP
        REMOVE Item FROM ItemList SETTING Position
    WHILE Item:Position
        IF Item NE '' THEN
            RFtBulkItem='';ErrorItem='' ;*Initialising the variables
            RFtBulkItem = FT.Clearing.BulkItem.Read(Item,ErrorItem) ;*Read FT.BULK.ITEM record for each item
            IF RFtBulkItem EQ '' THEN
                RFtBulkItem = FT.Clearing.BulkItem.ReadNau(Item, ErrorItem) ;*Read Unauthorised record if LIVE record doesn't exist
            END
            Reference = RFtBulkItem<FT.Clearing.BulkItem.BlkItReference> ;*Retrieve item reference
            AccountNo = RFtBulkItem<FT.Clearing.BulkItem.BlkItAccountNo> ;*Retrieve item account number
            SortCode = RFtBulkItem<FT.Clearing.BulkItem.BlkItSortCode> ;*Retrieve item sort code
            Currency = RFtBulkItem<FT.Clearing.BulkItem.BlkItCurrency> ;*Retrieve item currency
            Amount = RFtBulkItem<FT.Clearing.BulkItem.BlkItAmount> ;*Retrieve item amount
            ItemDate = RFtBulkItem<FT.Clearing.BulkItem.BlkItValueDate> ;*Retrieve item value date
            ItemStatus = OCONV(RFtBulkItem<FT.Clearing.BulkItem.BlkItStatus>,"MCT") ;*Retrieve item status
            BeneficiaryId = RFtBulkItem<FT.Clearing.BulkItem.BlkItBeneficiaryId> ;*Retrieve item beneficiary id
            RecordStatus = RFtBulkItem<FT.Clearing.BulkItem.BlkItRecordStatus> ;*Retrieve item record status
            CustomerNo = RFtBulkItem<FT.Clearing.BulkItem.BlkItCustomer> ;*Retrieve item customer
            IF RecordStatus EQ 'IHLD' AND ItemStatus EQ 'Created' THEN ;*Check for items created in IHLD status
                ItemStatus = 'Created' ;*Set the staus value for display
            END
            IF RecordStatus EQ 'INAU' AND ItemStatus EQ 'Ready' THEN ;*Check for items created in INAU status
                ItemStatus = 'Pending' ;*Set the staus value for display
            END

            GOSUB BUILD.ITEMS.LIST ;*Build final list of bulk items
        END
    REPEAT
RETURN
*** </region>
*----------------------------------------------------------------------------------------------------
*** <region name= BUILD.ITEMS.LIST>
*** <desc>This forms the final list of Bulk items to be displayed to the user. </desc>
BUILD.ITEMS.LIST:
*----------------
    OUT.DATA<-1> = Item:"*":Reference:"*":AccountNo:"*":SortCode:"*":Currency:"*":Amount:"*":ItemDate:"*":ItemStatus:"*":BeneficiaryId:"*":LocalCurrency:"*":CustomerNo
    RecordStatus = '' ; ItemStatus = '';Reference = '';AccountNo = ''; SortCode = ''; Currency = ''; Amount = ''; ItemDate = ''; BeneficiaryId = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------
END
