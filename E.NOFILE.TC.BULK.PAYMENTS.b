* @ValidationCode : MjotMTQxNDMxNDE5NzpjcDEyNTI6MTYwNjgyMDcxMjAyMjpzYWlrdW1hci5tYWtrZW5hOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MjktMTIxMDoxNDU6MTEx
* @ValidationInfo : Timestamp         : 01 Dec 2020 16:35:12
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 111/145 (76.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>219</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.Channels
SUBROUTINE E.NOFILE.TC.BULK.PAYMENTS(OUT.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which returns a list of bulk payments
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.BULK.PAYMENTS using the Standard selection NOFILE.TC.BULK.PAYMENTS
* IN Parameters      : NIL
* Out Parameters     : Array of Bulk payment details such as Payment Id, Description, Category, Active Account,
*                      Currency,Total Value Uploaded,Payment Value Date, Total Amount, Status, Record Status, Total Items,
*                      Value Date, Wash Account, Credit Debit, File Reference, EB File Reference, Date (OUT.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2410871
*               TCIB2.0 Corporate - Advanced Functional Components - Bulk payments
*
* 23/06/2018  - Defect 2623872 / Task 2645959
*               MB201804-SG-18 TCIB Corporate - bulk files
*
* 28/10/20 - Enhancement 3958209/Task 4021151 - change of reference of FT.BULK.MASTER from FT to BU
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $USING FT.Channels
    $USING AC.AccountOpening
    $USING EB.Browser
    $USING EB.DataAccess
    $USING EB.Reports
    $USING BU.Contract
    $USING ST.Config
    $USING EB.SystemTables

    $INSERT I_DAS.EB.FILE.UPLOAD
    $INSERT I_DAS.EB.FILE.UPLOAD.NOTES
*** </region>
*---------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing logic. </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine </desc>
INITIALISE:
*----------
    CustomerId='';OUT.DATA = ''; MasterId = '';RecordStatus='';FileReference='';Description='' ;*Initialising the variables used in this routine
    ActiveAccount='';RAccount='';CategoryId='';RCategory='';ShortTitle='';Currency='';TotalValueUploaded='';ProcessingDate='' ;*Initialising the variables used in this routine
    PaymentValueDate='';WashAccount='';DebitCredit='';TotalAmount='';BulkMasterRecordStatus='';NoOfErrorItems='';NoOfSuccessItems='';Status='';TotalNoOfItems= '' ;BulkMasterId='';UploadId='';FileUploadId='' ;*Initialising the variables used in this routine
        
    FN.FT.BULK.MASTER = 'F.FT.BULK.MASTER' ;*Assigning the file descriptor for FT.BULK.MASTER table
    F.FT.BULK.MASTER = ''
    EB.DataAccess.Opf(FN.FT.BULK.MASTER,F.FT.BULK.MASTER) ;*Call OPF to open file for access

    FN.FT.BULK.MASTER$NAU = 'F.FT.BULK.MASTER$NAU' ;*Assigning the file descriptor for FT.BULK.MASTER.NAU table
    F.FT.BULK.MASTER$NAU = ''
    EB.DataAccess.Opf(FN.FT.BULK.MASTER$NAU,F.FT.BULK.MASTER$NAU) ;*Call OPF to open file for access

RETURN
*** </region>
*------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>This has the main processing logic to appropriately select the bulk payment records </desc>
PROCESS:
*-------

    CustomerId = EB.Browser.SystemGetvariable("EXT.CUSTOMER") ;*Reading the customer id of the user logged in
    LOCATE 'RECORD.STATUS' IN EB.Reports.getDFields()<1> SETTING FieldPosition THEN ;*Locate the field RECORD.STATUS in the enquiry criteria
        RecordStatus = EB.Reports.getDRangeAndValue()<FieldPosition>   ;* Get the record status from enquiry selection.
    END
 
    BEGIN CASE

        CASE RecordStatus EQ  'LIVE' ;*Check if RecordStatus is LIVE
            GOSUB  SELECT.AUTHORISED.RECORDS ;*Select the bulk payment records in LIVE table
        CASE RecordStatus EQ 'INAU' OR  RecordStatus EQ 'IHLD' ;*Check if RecordStatus is INAU or IHLD
            GOSUB SELECT.UNAUTHORISED.RECORDS ;*Select the bulk payment records in NAU table
        CASE 1  ;*Default case
            GOSUB DEFAULT.SELECTION ;*Default selection of all the bulk payment records (LIVE/NAU)
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= DEFAULT.SELECTION>
*** <desc>This block selects the bulk payment records in LIVE and NAU table. </desc>
DEFAULT.SELECTION:
*----------------

    AccountsList = EB.Browser.SystemGetvariable("EXT.SMS.ACCOUNTS") ;*Read the list of accounts linked with the corporate customer id
    LOOP
        REMOVE AccountId FROM AccountsList SETTING FieldPosition ;*Remove each account in the AccountsList and iterate with it
    WHILE AccountId:FieldPosition
        BulkMasterSelect = "SELECT ":FN.FT.BULK.MASTER:" WITH ACTIVE.ACCOUNT EQ ":AccountId ;* Select all the bulk master records irrespective of status from the LIVE file
        EB.DataAccess.Readlist(BulkMasterSelect,SelectedMasterList,"",SelectedMasterListCount,BulkMasterError) ;*Read the list of bulk master records from LIVE file

        BulkMasterNauSelect = "SELECT ":FN.FT.BULK.MASTER$NAU:" WITH ACTIVE.ACCOUNT EQ ":AccountId:" AND RECORD.STATUS EQ 'IHLD' 'INAO' 'INAU'" ;* Select the bulk master records from the NAU file with RecordStatus as INAU/IHLD/INAO
        EB.DataAccess.Readlist(BulkMasterNauSelect,SelectedMasterNauList,"",SelectedMasterNauListCount,BulkMasterNauError) ;*Read the list of bulk master records from NAU file
        GOSUB PROCESS.UNAUTH.RECORDS ;*Process the records selected from NAU file
        GOSUB PROCESS.AUTH.RECORDS ;*Process the records selected from LIVE file
    REPEAT

RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name= SELECT.UNAUTHORISED.RECORDS>
*** <desc>This block selects the bulk payment records in NAU table. </desc>
SELECT.UNAUTHORISED.RECORDS:
*--------------------------
    AccountsList = EB.Browser.SystemGetvariable("EXT.SMS.ACCOUNTS") ;*Read the list of accounts linked with the corporate customer id

    LOOP
        REMOVE AccountId FROM AccountsList SETTING FieldPosition ;*Remove each account in the AccountsList and iterate with it
    WHILE AccountId:FieldPosition
        IF RecordStatus EQ 'INAU' THEN ;*Check if RecordStatus is INAU
            BulkMasterNauSelect = "SELECT ":FN.FT.BULK.MASTER$NAU:" WITH ACTIVE.ACCOUNT EQ ":AccountId:" AND STATUS EQ 'READY' AND RECORD.STATUS EQ 'INAU' 'INAO'" ;* Select the bulk master records from the NAU file with Status as 'READY' and RecordStatus as INAU/INAO
            EB.DataAccess.Readlist(BulkMasterNauSelect,SelectedMasterNauList,"",SelectedMasterNauListCount,BulkMasterNauError) ;*Read the list of bulk master records from NAU file
        END ELSE
            BulkMasterNauSelect = "SELECT ":FN.FT.BULK.MASTER$NAU:" WITH ACTIVE.ACCOUNT EQ ":AccountId:" AND STATUS NE 'REJECTED' AND RECORD.STATUS EQ 'IHLD'" ;* Select the bulk master records from the NAU file with Status as 'REJECTED' and RecordStatus as INAU/INAO
            EB.DataAccess.Readlist(BulkMasterNauSelect,SelectedMasterNauList,"",SelectedMasterNauListCount,BulkMasterNauError) ;*Read the list of bulk master records from NAU file
        END
        GOSUB PROCESS.UNAUTH.RECORDS ;*Process the records selected from NAU file

    REPEAT

RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name= SELECT.AUTHORISED.RECORDS>
*** <desc>This block selects the bulk payment records in LIVE table. </desc>
SELECT.AUTHORISED.RECORDS:
*------------------------
    AccountsList = EB.Browser.SystemGetvariable("EXT.SMS.ACCOUNTS") ;*Read the list of accounts linked with the corporate customer id
    LOOP
        REMOVE AccountId FROM AccountsList SETTING FieldPosition ;*Remove each account in the AccountsList and iterate with it
    WHILE AccountId:FieldPosition

        BulkMasterSelect = "SELECT ":FN.FT.BULK.MASTER:" WITH ACTIVE.ACCOUNT EQ ":AccountId:" AND STATUS EQ 'READY'" ;* Select the bulk master records from the LIVE file with Status as 'READY'
        EB.DataAccess.Readlist(BulkMasterSelect,SelectedMasterList,"",SelectedMasterListCount,BulkMasterError) ;*Read the list of bulk master records from LIVE file

        GOSUB PROCESS.AUTH.RECORDS ;*Process the records selected from LIVE file
    REPEAT

RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name= PROCESS.UNAUTH.RECORDS>
*** <desc>This block process the bulk payment records selected from NAU table. </desc>
PROCESS.UNAUTH.RECORDS:
*---------------------
    LOOP
        REMOVE RecordId FROM SelectedMasterNauList SETTING FieldPosition ;*Remove each record in the SelectedMasterNauList and iterate with it
    WHILE RecordId:FieldPosition
        RFtBulkMaster = '' ; RFtBulkMasterError = ''
        RFtBulkMaster= BU.Contract.BulkMaster.ReadNau(RecordId, RFtBulkMasterError) ;*Read Bulk master NAU table to fetch the record details
        Signatory = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasSignatory> ;*Extract signatory field value from the bulk master record
        IF RFtBulkMaster AND (CustomerId NE Signatory) THEN ;*Check if Bulk master record is fetched and CustomerId NE Signatory
            GOSUB SET.BULK.MASTER.DETAILS ;*Set the Bulk master record details to appropriate variables
            IF BulkMasterRecordStatus EQ 'IHLD' AND Status EQ 'Ready' THEN ;*Check if BulkMasterRecordStatus is 'IHLD' and Status is 'Ready'
                Status = 'Created' ;*Set Status as 'Created'
            END
* Status changed to "Pending" for INAO/INAU records.
            IF ( BulkMasterRecordStatus EQ 'INAU' OR BulkMasterRecordStatus EQ 'INAO' ) AND Status EQ 'Ready' THEN         ;*Check if BulkMasterRecordStatus is 'INAU/IHLD' and Status is 'Ready'
                Status = 'Pending' ;*Set Status as 'Pending'
            END
            GOSUB BUILD.PAYMENTS.LIST ;*Build the final list of Bulk payments to be displayed to the user
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------
*** <region name= PROCESS.AUTH.RECORDS>
*** <desc>This block processes the bulk payment records selected from LIVE table. </desc>
PROCESS.AUTH.RECORDS:
*-------------------
    LOOP
        REMOVE RecordId FROM SelectedMasterList SETTING FieldPosition ;*Remove each record in the SelectedMasterList and iterate with it
    WHILE RecordId:FieldPosition
        RFtBulkMaster = '' ; RFtBulkMasterError = ''
        RFtBulkMaster =  BU.Contract.BulkMaster.Read(RecordId,RFtBulkMasterError) ;*Read Bulk master LIVE table to fetch the record details

        IF RFtBulkMaster THEN ;*Check if Bulk master record is fetched
            GOSUB SET.BULK.MASTER.DETAILS ;*Set the Bulk master record details to appropriate variables
            GOSUB BUILD.PAYMENTS.LIST ;*Build the final list of Bulk payments to be displayed to the user
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------
*** <region name= GET.FILE.UPLOAD.ID>
*** <desc>Read the uploaded file details from EB.FILE.UPLOAD application </desc>
GET.FILE.UPLOAD.ID:
*-----------------

* To get details of EB.FILE.UPLOAD record
    THE.LIST = dasEbFileUploadEqFtBulkMasterId       ;* Setting values for DAS Arguments
    THE.ARGS= BulkMasterId ;*Set the DAS criteria value
    TABLE.SUFFIX=''
    EB.DataAccess.Das("EB.FILE.UPLOAD",THE.LIST,THE.ARGS,TABLE.SUFFIX)  ;* Call DAS to read record/s from EB.FILE.UPLOAD application
    IF THE.LIST THEN
        UploadId = THE.LIST ;*Set the list of records returned by DAS
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------
*** <region name= SET.BULK.MASTER.DETAILS>
*** <desc>This extracts the detail from the bulk master record and sets them to variables appropriately. </desc>
SET.BULK.MASTER.DETAILS:
*----------------------
    
    FileReference = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasUploadReference> ;*Extract and Set FileReference
    Description = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasDescription> ;*Extract and Set Description
    IF Description EQ '' THEN
        Description = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasDescription> ;*Extract and Set Description
    END
    ActiveAccount = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasActiveAccount> ;*Extract and Set ActiveAccount
    IF ActiveAccount NE '' THEN ;*Check if ActiveAccount is fetched
        RAccount = AC.AccountOpening.Account.Read(ActiveAccount, AccountError) ;*Read account record
        CategoryId = RAccount<AC.AccountOpening.Account.Category> ;*Extract Category from Account record
        RCategory = ST.Config.Category.Read(CategoryId,CategoryError) ;*Read Category record
        IF RCategory THEN
            ShortTitle = RCategory<ST.Config.Category.EbCatDescription> ;*Extract CategoryDescription from Category record
        END
        ActiveAccount = ActiveAccount : '-' : ShortTitle ;*Set ActiveAccount
    END
      
* To get details of total Bulk Items uploaded and its value based on the file upload source (Upload /  Manual)
    SourceFileUpload = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasSource> ;*Extract source for file upload
    IF SourceFileUpload EQ 'UPLOAD' THEN
        TotalValueUploaded = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasTotValueUploaded> ;*Extract and Set TotalValueUploaded
        NoOfErrorItems = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasItemsStatusErr> ;*Extract and Set NoOfErrorItems
        NoOfSuccessItems = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasItemsUploaded> ;*Extract and Set NoOfSuccessItems
        TotalNoOfItems = NoOfSuccessItems + NoOfErrorItems ;*Compute total no of items
    END ELSE
        TotalValueUploaded = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasValueManualItems> ;*Extract and set TotalValueUploaded for manual items
        TotalNoOfItems = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasManualItems> ;*Extract and set no of items for manual items
        IF TotalNoOfItems EQ '' THEN
            TotalNoOfItems = 0
        END

    END
    Currency = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasCurrency> ;*Extract and Set Currency
    ProcessingDate = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasProcessingDate> ;*Extract and Set ProcessingDate
    PaymentValueDate = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasPaymentValueDate> ;*Extract and Set PaymentValueDate
    WashAccount = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasWashAccount> ;*Extract and Set WashAccount
    DebitCredit = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasDebitCredit> ;*Extract and Set DebitCredit
    TotalAmount = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasTotalAmount> ;*Extract and Set TotalAmount
    BulkMasterRecordStatus = RFtBulkMaster<BU.Contract.BulkMaster.BlkMasRecordStatus> ;* Extract and Set BulkMasterRecordStatus
    Status = OCONV(RFtBulkMaster<BU.Contract.BulkMaster.BlkMasStatus>,"MCT") ;*Extract and Set Status
    BulkMasterId = RecordId       ;*Set BulkMasterId
    GOSUB GET.FILE.UPLOAD.ID ;*Get File upload id
    FileUploadId = UploadId ;*Set FileUploadId
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------
*** <region name= BUILD.PAYMENTS.LIST>
*** <desc>This builds the final list of payments to be displayed to the user. </desc>
BUILD.PAYMENTS.LIST:
*------------------

    LOCATE RecordId IN MasterId SETTING FieldPosition ELSE
        OUT.DATA<-1> = RecordId:"*":Description:"*":ActiveAccount:"*":Currency:"*":TotalValueUploaded:"*":ProcessingDate:"*":TotalAmount:"*":Status:"*":BulkMasterRecordStatus:"*":TotalNoOfItems:"*":PaymentValueDate:"*":WashAccount:"*":DebitCredit:"*":FileReference:"*":FileUploadId ;*Final Array with bulk master record details
    END
    MasterId<-1> = RecordId ;*Array with Bulk master record ids
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------
END
