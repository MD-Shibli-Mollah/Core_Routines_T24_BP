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
* <Rating>-58</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T4.ModelBank
    SUBROUTINE E.NOF.TCIB.BULK.ITEM.DET(OUT.DATA)
*-------------------------------------------------------------------------------------------------------
* Developed By : Temenos Application Management
* Program Name : E.NOF.TCIB.BULK.ITEM.DET
*-----------------------------------------------------------------------------------------------------------------
* Description      : It's a Nofile Enquiry used to Display the List of Bulk Items for the perticular Bulk Master.
* Linked With      : Standard.Selection for the Enquiry
* @Author          : jayaramank@temenos.com
* In Parameter     : NILL
* Out Parameter    : OUT.DATA
* Enhancement      : 696318
*-----------------------------------------------------------------------------------------------------------------
* Modification Details:
*=====================
* 22/04/14 - Task 980812 / Defect 910238
*           Bulk items are not displayed for some bulk master even bulk master has bulk items.
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
*-----------------------------------------------------------------------------------------------------------------

    $INSERT I_DAS.FT.BULK.ITEM
    $INSERT I_DAS.FT.BULK.ITEM.NOTES

    $USING EB.Reports
    $USING EB.SystemTables
    $USING FT.Clearing

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*---------------------------------------------------------------------------------------------
INITIALISE:
***********

    RETURN
*------------------------------------------------------------------------------------------------
PROCESS:
********

    OUT.DATA = '' ; R.BULK.ITEM = '' ; ERR.ITEM = '' ; ITEM.LIST = ''

    Y.LOCAL.CURRENCY = EB.SystemTables.getLccy();

    LOCATE 'ITEM.ID' IN EB.Reports.getDFields()<1> SETTING ITEM.POS THEN
    EB.Reports.setId(EB.Reports.getDRangeAndValue()<ITEM.POS>)
    END

* For Live record

    THE.LIST = dasFtBulkItemLikeMasterId          ;* Setting values for DAS Arguments
    THE.ARGS=EB.Reports.getId()
    TABLE.SUFFIX=''
    CALL DAS("FT.BULK.ITEM",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.ITEM.LIST=THE.LIST

* For Unauth record

    THE.LIST = dasFtBulkItemLikeMasterId          ;* Setting values for DAS Arguments
    THE.ARGS=EB.Reports.getId()
    TABLE.SUFFIX='$NAU'
    CALL DAS("FT.BULK.ITEM",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.ITEM.UNAUTH.LIST=THE.LIST

    ITEM.LIST = SEL.ITEM.LIST:@FM:SEL.ITEM.UNAUTH.LIST

    GOSUB PROCESS.ITEM
    RETURN
*------------------------------------------------------------------------------------------------------
PROCESS.ITEM:
*************
    LOOP
        REMOVE ITEM FROM ITEM.LIST SETTING POS1
    WHILE ITEM:POS1
        IF ITEM NE '' THEN
            R.BULK.ITEM = FT.Clearing.BulkItem.Read(ITEM,ERR.ITEM)
            IF R.BULK.ITEM EQ '' THEN
                R.BULK.ITEM = FT.Clearing.BulkItem.ReadNau(ITEM, ERR.ITEM)
            END
            REFERENCE = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItReference>
            ACCT.NO = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItAccountNo>
            SORTCODE = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItSortCode>
            CCY = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItCurrency>
            AMT = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItAmount>
            ITEM.DATE = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItValueDate>
            ITEM.STATUS = OCONV(R.BULK.ITEM<FT.Clearing.BulkItem.BlkItStatus>,"MCT")
            BENEFICIARY.ID = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItBeneficiaryId>
            REC.STATUS = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItRecordStatus>
            CUST.NO = R.BULK.ITEM<FT.Clearing.BulkItem.BlkItCustomer>
            IF REC.STATUS EQ 'IHLD' AND ITEM.STATUS EQ 'Created' THEN
                ITEM.STATUS = 'Created'
            END
            IF REC.STATUS EQ 'INAU' AND ITEM.STATUS EQ 'Ready' THEN
                ITEM.STATUS = 'Pending'
            END

            GOSUB BUILD.ARRAY
        END
    REPEAT
    RETURN
*----------------------------------------------------------------------------------------------------
BUILD.ARRAY:
************
    OUT.DATA<-1> = ITEM:"*":REFERENCE:"*":ACCT.NO:"*":SORTCODE:"*":CCY:"*":AMT:"*":ITEM.DATE:"*":ITEM.STATUS:"*":BENEFICIARY.ID:"*":Y.LOCAL.CURRENCY:"*":CUST.NO
    REC.STATUS = '' ; ITEM.STATUS = '';REFERENCE = '';ACCT.NO = ''; SORTCODE = ''; CCY = ''; AMT = ''; ITEM.DATE = ''; BENEFICIARY.ID = ''
    RETURN
*-----------------------------------------------------------------------------------------------------
    END
