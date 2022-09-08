* @ValidationCode : MjotMjAwMjY0MDU1NjpjcDEyNTI6MTYwNjgyMDg1MTE5ODpzYWlrdW1hci5tYWtrZW5hOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MjktMTIxMDoxNjQ6MTMw
* @ValidationInfo : Timestamp         : 01 Dec 2020 16:37:31
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 130/164 (79.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>219</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T4.ModelBank
SUBROUTINE E.NOF.TCIB.BULK.PAY.DET(OUT.DATA)
*-------------------------------------------------------------------------------------------------------
* Developed By : Temenos Application Management
* Program Name : E.NOF.TCIB.BULK.PAY.DET
*-----------------------------------------------------------------------------------------------------------------
* Description        : It's a Nofile Enquiry used to Display the List of Bulk Master.
* Linked With        : Standard.Selection for the Enquiry
* @Author            : jayaramank@temenos.com
* In Parameter       : NILL
* Out Parameter      : OUT.DATA
* Enhancement        : 696318
*-----------------------------------------------------------------------------------------------------------------
* Modification Details:
*=====================
* 08/01/2015- Defect 1187960 Task 1220168
*            Bulk Master INAO record status is wrongly displaying when record listed for Manager approval.
*
* 02/06/15 - Defect 1360133 / Task 1362283
*            Bulk payments enquiry not listing all the unauthorised Bulk Payments

* 10/08/15 - Defect - 1427082/ Task - 1428046
*         Extract Upload id in which Header id field in upload id record matches with FT.BULK.MASTER
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*            Incorporation of T components
*
* 10/03/16 - Defect 1658548 / Task 1659881
*            All Bulk Master records are not listed.
*
* 18/03/16 - Defect 1666210 / Task 1667427
*            Rejected item is not displayed in manager/Clerk login
*
* 14/10/20 - Enhancement 3958209/Task 4021149
*          - change of reference of FT.BULK.MASTER from FT to BU
*-----------------------------------------------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING EB.Browser
    $USING EB.DataAccess
    $USING EB.Reports
    $USING BU.Contract
    $USING ST.Config
    $USING EB.SystemTables

    $INSERT I_DAS.EB.FILE.UPLOAD
    $INSERT I_DAS.EB.FILE.UPLOAD.NOTES

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------------------------
INITIALISE:
***********
    DEFFUN System.getVariable()

    FN.FT.BULK.MASTER = 'F.FT.BULK.MASTER'
    F.FT.BULK.MASTER = ''
    EB.DataAccess.Opf(FN.FT.BULK.MASTER,F.FT.BULK.MASTER)

    FN.FT.BULK.MASTER$NAU = 'F.FT.BULK.MASTER$NAU'
    F.FT.BULK.MASTER$NAU = ''
    EB.DataAccess.Opf(FN.FT.BULK.MASTER$NAU,F.FT.BULK.MASTER$NAU)

RETURN
*------------------------------------------------------------------------------------------------
PROCESS:
********

    LOGIN.CUS.ID = System.getVariable("EXT.CUSTOMER")
    LOCATE 'RECORD.STATUS' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        REC.STATUS = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the record status from enquiry selection.
    END

    BEGIN CASE

        CASE REC.STATUS EQ  'LIVE'
            GOSUB  AUTH.PROCESS
        CASE REC.STATUS EQ 'INAU' OR  REC.STATUS EQ 'IHLD'
            GOSUB UNAUTH.PROCESS
        CASE 1
            GOSUB MAINPROCESS
    END CASE

RETURN

*-----------------------------------------------------------------------------------------------
MAINPROCESS:
************

    OUT.DATA = ''; MASTER.ID = ''
    ACCOUNT.LIST = System.getVariable('EXT.SMS.ACCOUNTS')
    LOOP
        REMOVE ACCT.ID FROM ACCOUNT.LIST SETTING POS.ACC
    WHILE ACCT.ID:POS.ACC
        SEL.REC1 = "SELECT ":FN.FT.BULK.MASTER:" WITH ACTIVE.ACCOUNT EQ ":ACCT.ID ;* Show all the bulk master items irrespective of status
        EB.DataAccess.Readlist(SEL.REC1,SEL.MAS.LIST,"",SEL.MAS.NO,ERR.MAS)

        SEL.REC2 = "SELECT ":FN.FT.BULK.MASTER$NAU:" WITH ACTIVE.ACCOUNT EQ ":ACCT.ID:" AND RECORD.STATUS EQ 'IHLD' 'INAO' 'INAU'" ;* Show all the bulk master items irrespective of status
        EB.DataAccess.Readlist(SEL.REC2,SEL.MAS.UNAUTH.LIST,"",SEL.MAS.UNAUTH.NO,ERR.MAS.UNAUTH)

        GOSUB UNAUTH.RECORD.PROCESS
        GOSUB AUTH.RECORD.PROCESS
    REPEAT

RETURN
*-------------------------------------------------------------------------------------------------
UNAUTH.PROCESS:
***************
    OUT.DATA = ''; MASTER.ID = ''
    ACCOUNT.LIST = System.getVariable('EXT.SMS.ACCOUNTS')

    LOOP
        REMOVE ACCT.ID FROM ACCOUNT.LIST SETTING POS.ACC
    WHILE ACCT.ID:POS.ACC
        IF REC.STATUS EQ 'INAU' THEN
            SEL.REC2 = "SELECT ":FN.FT.BULK.MASTER$NAU:" WITH ACTIVE.ACCOUNT EQ ":ACCT.ID:" AND STATUS EQ 'READY' AND RECORD.STATUS EQ 'INAU' 'INAO'"
            EB.DataAccess.Readlist(SEL.REC2,SEL.MAS.UNAUTH.LIST,"",SEL.MAS.UNAUTH.NO,ERR.MAS.UNAUTH)
        END ELSE
            SEL.REC2 = "SELECT ":FN.FT.BULK.MASTER$NAU:" WITH ACTIVE.ACCOUNT EQ ":ACCT.ID:" AND STATUS NE 'REJECTED' AND RECORD.STATUS EQ 'IHLD'"
            EB.DataAccess.Readlist(SEL.REC2,SEL.MAS.UNAUTH.LIST,"",SEL.MAS.UNAUTH.NO,ERR.MAS.UNAUTH)
        END
        GOSUB UNAUTH.RECORD.PROCESS

    REPEAT

RETURN

*-------------------------------------------------------------------------------------------------
AUTH.PROCESS:
*****************
    OUT.DATA = ''; MASTER.ID = ''
    ACCOUNT.LIST = System.getVariable('EXT.SMS.ACCOUNTS')
    LOOP
        REMOVE ACCT.ID FROM ACCOUNT.LIST SETTING POS.ACC
    WHILE ACCT.ID:POS.ACC

        SEL.REC1 = "SELECT ":FN.FT.BULK.MASTER:" WITH ACTIVE.ACCOUNT EQ ":ACCT.ID:" AND STATUS EQ 'READY'"
        EB.DataAccess.Readlist(SEL.REC1,SEL.MAS.LIST,"",SEL.MAS.NO,ERR.MAS)

        GOSUB AUTH.RECORD.PROCESS
    REPEAT

RETURN

*-------------------------------------------------------------------------------------------------
UNAUTH.RECORD.PROCESS:
********************
    LOOP
        REMOVE REC.ID FROM SEL.MAS.UNAUTH.LIST SETTING POS
    WHILE REC.ID:POS
        R.BULK.MASTER = '' ; BULK.MAS.ERR = ''
        R.BULK.MASTER= BU.Contract.BulkMaster.ReadNau(REC.ID, BULK.MAS.ERR)
        SIGNATORY = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasSignatory>
        IF R.BULK.MASTER AND (LOGIN.CUS.ID NE SIGNATORY) THEN
            FILE.REF = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasUploadReference>
            DESC = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasDescription>
            IF DESC EQ '' THEN
                DESC = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasDescription>
            END
            ACTIVE.ACCT = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasActiveAccount>
            IF ACTIVE.ACCT NE '' THEN
                R.ACCOUNT = AC.AccountOpening.Account.Read(ACTIVE.ACCT, ACC.ERR)
                CATEGORY.ID = R.ACCOUNT<AC.AccountOpening.Account.Category>
                R.CATEGORY = ST.Config.Category.Read(CATEGORY.ID,ERR.CAT)
                IF R.CATEGORY THEN
                    SHORT.TITLE = R.CATEGORY<ST.Config.Category.EbCatDescription>
                END
                ACTIVE.ACCT = ACTIVE.ACCT : '-' : SHORT.TITLE
            END
            CCY = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasCurrency>
            TOT.VAL.UPLOAD = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasTotValueUploaded>
            PAYMENT.DATE = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasProcessingDate>
            VALUE.DATE = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasPaymentValueDate>
            WASH.ACCT = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasWashAccount>
            CRDR = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasDebitCredit>
            TOT.AMT = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasTotalAmount>
            BULK.REC.STATUS = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasRecordStatus> ;* Assign Bulk Master record status
            ERROR.ITEMS = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasItemsStatusErr>
            SUCCESS.ITEMS = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasItemsUploaded>
            STATUS1 = OCONV(R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasStatus>,"MCT")
            IF BULK.REC.STATUS EQ 'IHLD' AND STATUS1 EQ 'Ready' THEN
                STATUS1 = 'Created'
            END
* Status changed to "Pending" for INAO/INAU records.
            IF ( BULK.REC.STATUS EQ 'INAU' OR BULK.REC.STATUS EQ 'INAO' ) AND STATUS1 EQ 'Ready' THEN         ;* Record Status mapped to pending for "INAU" and "INAO" records
                STATUS1 = 'Pending'
            END
            TOTAL.ITEMS = SUCCESS.ITEMS + ERROR.ITEMS
            BULK.MASTER.ID = REC.ID       ;*Input FT Bulk Master Id and extract File Upload Id
            GOSUB GET.FILE.UPLOAD.ID
            FILE.UPLOAD.ID = UPLOAD.ID
            GOSUB BUILD.ARRAY
        END
    REPEAT
RETURN
*---------------------------------------------------------------------------------------------------
AUTH.RECORD.PROCESS:
********************
    LOOP
        REMOVE REC.ID FROM SEL.MAS.LIST SETTING POS1
    WHILE REC.ID:POS1
        R.BULK.MASTER = '' ; BULK.MAS.ERR = ''
        R.BULK.MASTER =  BU.Contract.BulkMaster.Read(REC.ID,BULK.MAS.ERR)
*   SIGNATORY = R.BULK.MASTER<FT.BLK.MAS.SIGNATORY>
        IF R.BULK.MASTER THEN
            FILE.REF = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasUploadReference>
            DESC = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasDescription>
            IF DESC EQ '' THEN

                DESC = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasDescription>
            END
            ACTIVE.ACCT = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasActiveAccount>
            IF ACTIVE.ACCT NE '' THEN
                R.ACCOUNT = AC.AccountOpening.Account.Read(ACTIVE.ACCT, ACC.ERR)
                CATRY.ID = R.ACCOUNT<AC.AccountOpening.Account.Category>
                R.CATRY = ST.Config.Category.Read(CATRY.ID,ER.CAT)
                IF R.CATRY THEN
                    SHORT.TITLE = R.CATRY<ST.Config.Category.EbCatDescription>
                END
                ACTIVE.ACCT = ACTIVE.ACCT : '-' : SHORT.TITLE
            END
            CCY = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasCurrency>
            TOT.VAL.UPLOAD = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasTotValueUploaded>
            PAYMENT.DATE = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasProcessingDate>
            VALUE.DATE = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasPaymentValueDate>
            WASH.ACCT = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasWashAccount>
            CRDR = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasDebitCredit>
            TOT.AMT = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasTotalAmount>
            STATUS1 = OCONV(R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasStatus>,"MCT")
            BULK.REC.STATUS = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasRecordStatus> ;* Assign Bulk Master record status
            ERROR.ITEMS = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasItemsStatusErr>
            SUCCESS.ITEMS = R.BULK.MASTER<BU.Contract.BulkMaster.BlkMasItemsUploaded>
            TOTAL.ITEMS = SUCCESS.ITEMS + ERROR.ITEMS
            BULK.MASTER.ID = REC.ID     ;*Input FT Bulk Master Id and extract File Upload Id
            GOSUB GET.FILE.UPLOAD.ID
            FILE.UPLOAD.ID = UPLOAD.ID
            GOSUB BUILD.ARRAY
        END
    REPEAT
RETURN
*---------------------------------------------------------------------------------------------------
GET.FILE.UPLOAD.ID:
*-----------------

* To get details of EB.FILE.UPLOAD record
    THE.LIST = dasEbFileUploadEqFtBulkMasterId       ;* Setting values for DAS Arguments
    THE.ARGS= BULK.MASTER.ID
    TABLE.SUFFIX=''
    EB.DataAccess.Das("EB.FILE.UPLOAD",THE.LIST,THE.ARGS,TABLE.SUFFIX)  ;* To read File Upload Id with HeaderId equal to Bulk Master id
    IF THE.LIST THEN
        UPLOAD.ID = THE.LIST
    END
RETURN
*---------------------------------------------------------------------------------------------------
BUILD.ARRAY:
************

    LOCATE REC.ID IN MASTER.ID SETTING POS1 ELSE
        OUT.DATA<-1> = REC.ID:"*":DESC:"*":ACTIVE.ACCT:"*":CCY:"*":TOT.VAL.UPLOAD:"*":PAYMENT.DATE:"*":TOT.AMT:"*":STATUS1:"*":BULK.REC.STATUS:"*":TOTAL.ITEMS:"*":VALUE.DATE:"*":WASH.ACCT:"*":CRDR:"*":FILE.REF:"*":FILE.UPLOAD.ID
    END
    MASTER.ID<-1> = REC.ID
RETURN
*---------------------------------------------------------------------------------------------------------
END
