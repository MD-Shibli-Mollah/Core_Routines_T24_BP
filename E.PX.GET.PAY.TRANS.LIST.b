* @ValidationCode : Mjo2OTUyNDA0OTpDcDEyNTI6MTU2OTQxMzk3Nzc2NTpzaGFzaGlkaGFycmVkZHlzOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMjAxOTA3MjMtMDI1MToxODk6MTM3
* @ValidationInfo : Timestamp         : 25 Sep 2019 17:49:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shashidharreddys
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 137/189 (72.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-111</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.ModelBank
SUBROUTINE E.PX.GET.PAY.TRANS.LIST(FT.DATA)
*-----------------------------------------------------------------------------
* Enquiry build routine to return FT data
* Incoming
* FT.DATA - Null
* Outgoing
* FT.DATA - Returns FT record Ids
*-----------------------------------------------------------------------------
* Modification History :
* 17/11/17 - EN 2191148 / Task 2357550
*          - No File enquiry routine for transfer list enquiry
*
* 19/12/17 - Defect 2384122 / Task 2384566
*          - Return error when no record selected
*
* 21/12/17 = SI 2191126 / Task 2389194
*          - Correct the logic of extracting beneficiary account for SEPA transaction
*
* 25/09/19 - Defect 3356299 / Task 3356690
*          - Correct the logic of extracting SEPA.THEIR.ACCT value from Record variable instead of RNew.
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING EB.Template
    $USING EB.LocalReferences
    $USING ST.CompanyCreation
    $INSERT I_DAS.FUNDS.TRANSFER
    $INSERT I_DAS.FUNDS.TRANSFER.NOTES
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    IF NOT(EB.Reports.getEnqError()) THEN
        GOSUB CHECK.SELECTION.CRITERIA
    END
    IF EB.Reports.getEnqError() THEN
        RETURN
    END
    GOSUB GET.FT.RECORDS
    
    IF NOT(FT.DATA) THEN
        EB.SystemTables.setEtext('') ;* Clear ETEXT
        EB.Reports.setEnqError("FT-NO.FT.RECORDS") ;* Set ETEXT as no payment orders found.
    END
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
**<region = INITIALISE>
**<des = initialise variables>
    PX.INSTALLED = ''
    LOCATE 'PX' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POSN ELSE
        PX.INSTALLED = 0
        EB.Reports.setEnqError('FT-PX.NOT.INSTALLED')
        RETURN
    END
    EB.Reports.setEnqError('')  ;* set enquiry error as null
    AccountReference = ''  ;* holds incoming Account id
    AcPos = ''  ;* position of Account id
    R.FT.REC = ''  ;* payment record variables
    ER = '' ;* read error variable
    StartPos = ''
    EndPos = ''
    StatusPos = ''
    CntPos = ''
	SEPA.OPE.CODE  = ''
	SEPA.CODE = ''
	SEPA.ACCT = ''
	SepaTheirAcct = ''
    LOCATE 'ACCOUNTREFERENCE' IN EB.Reports.getDFields()<1> SETTING AcPos THEN    ;* locate AccountReference in enquiry data and get position
        AccountReference = EB.Reports.getDRangeAndValue()<AcPos>
    END

    LOCATE 'STARTDATE' IN EB.Reports.getDFields()<1> SETTING StartPos THEN  ;* locate start date
        StartDate = EB.Reports.getDRangeAndValue()<StartPos>
    END

    LOCATE 'ENDDATE' IN EB.Reports.getDFields()<1> SETTING EndPos THEN  ;* locate end date
        EndDate = EB.Reports.getDRangeAndValue()<EndPos>
    END
 
    LOCATE 'LISTTYPE' IN EB.Reports.getDFields()<1> SETTING StatusPos THEN  ;* locate listtype
        ListType = EB.Reports.getDRangeAndValue()<StatusPos>
    END

    LOCATE 'NOOFORDERS' IN EB.Reports.getDFields()<1> SETTING CntPos THEN  ;* locate no of orders input
        NoOfOrders = EB.Reports.getDRangeAndValue()<CntPos>
    END
RETURN

**</region>
*-----------------------------------------------------------------------------
CHECK.SELECTION.CRITERIA:
**<region = CHECK.SELECTION.CRITERIA>
    SAVE.COMI = EB.SystemTables.getComi()     ;* save comi
    REQ.ACCT.NUM = AccountReference  ;* get account id input
    GOSUB VALIDATE.ACCOUNT
    IF NOT(EndDate) THEN
        EndDate = EB.SystemTables.getToday()
    END

    IF NOT(StartDate) THEN
        StartDate = EndDate
        EB.API.Cdt('', StartDate, '-30C')
    END

    IF ListType EQ '' THEN
        ListType = 'APPROVED'
    END

    IF NOT(ListType EQ 'APPROVED' OR ListType EQ 'PENDING') THEN
        EB.Reports.setEnqError('FT-INVALID.LIST.TYPE')
        RETURN
    END

    IF NOT(NoOfOrders) THEN
        NoOfOrders = '10'
    END
RETURN
**</region>
*-----------------------------------------------------------------------------
VALIDATE.ACCOUNT:
**<region = CHECK.SELECTION.CRITERIA>
    EB.SystemTables.setComi(AccountReference)
    EB.Template.In2ant('', '') ;* get alternate account
    ACCT.REF = EB.SystemTables.getComi()
    EB.SystemTables.setComi(SAVE.COMI)
    ErrCode = ''
    CHECK.DATA = ''
    CHECK.DATA<AC.AccountOpening.AccountValidity> = 'Y'
    CHECK.DATA<AC.AccountOpening.AccountIban> = 'Y'
    CHECK.DATA.RESULT = ''
    AC.AccountOpening.CheckAccount(ACCT.REF,'',CHECK.DATA,'ONLINE','',CHECK.DATA.RESULT,'',ErrCode)  ;* check if account valid
    IF CHECK.DATA.RESULT<AC.AccountOpening.AccountValidity,1> EQ 'INVALID' THEN  ;* if invalid throw error
        EB.Reports.setEnqError('FT-INVALID.AC.ID')
        RETURN
    END
    AccountIban = CHECK.DATA.RESULT<AC.AccountOpening.AccountIban> ;* fetch iban

RETURN
**</region>
*-----------------------------------------------------------------------------
GET.FT.RECORDS:
**<region = CHECK.SELECTION.CRITERIA>
    BEGIN CASE
        CASE ListType EQ 'PENDING'
            TheList = dasFundsTransferProcessingDate
            TheArgs<1> = EndDate
            TheArgs<2> = StartDate
            TheArgs<3> = ACCT.REF
            TableSuffix = '$NAU' ;* get NAU records with date range
            EB.DataAccess.Das('FUNDS.TRANSFER', TheList, TheArgs, TableSuffix)
            FT.NAU.LIST = TheList

            NAU.CNT = DCOUNT(FT.NAU.LIST, @FM)

            IF NoOfOrders LE NAU.CNT THEN
                FT.CNT = NoOfOrders  ;* return orders requested
            END ELSE
                FT.CNT = NAU.CNT ;* return all NAU records
            END
            NAU.FLG = '1'
            IF FT.NAU.LIST THEN
                GOSUB FETCH.FT ;* return data
            END
        CASE ListType EQ 'APPROVED'
            TheList = dasFundsTransferProcessingDate
            TheArgs<1> = EndDate
            TheArgs<2> = StartDate
            TheArgs<3> = ACCT.REF
            TableSuffix = '' ;* get live records with date range
            EB.DataAccess.Das('FUNDS.TRANSFER', TheList, TheArgs, TableSuffix)
            FT.LIVE.LIST = TheList
            LIVE.CNT = DCOUNT(FT.LIVE.LIST, @FM)
            IF NoOfOrders LE LIVE.CNT THEN
                FT.CNT = NoOfOrders  ;* return orders requested
            END ELSE
                FT.CNT = LIVE.CNT ;* return all live records
            END
            LIVE.FLG = '1'
            IF FT.LIVE.LIST THEN
                GOSUB FETCH.FT ;* return data
            END
    END CASE

RETURN
**</region>
*-----------------------------------------------------------------------------
FETCH.FT:
**<region = CHECK.SELECTION.CRITERIA>
    BEGIN CASE
        CASE NAU.FLG  ;* exception
            FOR CNT = 1 TO FT.CNT
                FT.ID = FT.NAU.LIST<CNT>
                R.FT.REC = FT.Contract.FundsTransfer.ReadNau(FT.ID,ER)
                GOSUB BUILD.DATA
            NEXT CNT
            NAU.FLG = ''
        CASE LIVE.FLG  ;* live
            FOR CNT = 1 TO FT.CNT
                FT.ID = FT.LIVE.LIST<CNT>
                R.FT.REC = FT.Contract.FundsTransfer.Read(FT.ID,ER)
                GOSUB BUILD.DATA
            NEXT CNT
            LIVE.FLG = ''
    END CASE
RETURN
**</region>
*-----------------------------------------------------------------------------
BUILD.DATA:
**<region = CHECK.SELECTION.CRITERIA>
    GOSUB CHECK.SEPA.FT
    IbanBen = R.FT.REC<FT.Contract.FundsTransfer.IbanBen>
    BenAcctNo = R.FT.REC<FT.Contract.FundsTransfer.BenAcctNo>
    IbanCredit = R.FT.REC<FT.Contract.FundsTransfer.IbanCredit>
    CreditAcctNo = R.FT.REC<FT.Contract.FundsTransfer.CreditAcctNo>
    RecordStatus = R.FT.REC<FT.Contract.FundsTransfer.RecordStatus>
;* determine payment status
    BEGIN CASE
        CASE RecordStatus EQ ''
            PaymentTransStatus = 'Completed'
        CASE RecordStatus EQ 'INAU' OR RecordStatus EQ 'IHLD'
            PaymentTransStatus = 'Waiting Submit'
        CASE 1
            PaymentTransStatus = 'In Progress'
    END CASE
;* detmerine beneficiary account to be returned
    BEGIN CASE
        CASE SepaTheirAcct
            BenificaryAcct = SepaTheirAcct
        CASE IbanBen
            BenificaryAcct = IbanBen
        CASE BenAcctNo
            BenificaryAcct = BenAcctNo
        CASE IbanCredit
            BenificaryAcct = IbanCredit
        CASE CreditAcctNo
            BenificaryAcct = CreditAcctNo
    END CASE

    FT.DATA.ARRAY = ''
    FT.DATA.ARRAY<1> = FT.ID
    FT.DATA.ARRAY<2> = REQ.ACCT.NUM
    FT.DATA.ARRAY<3> = ACCT.REF
    FT.DATA.ARRAY<4> = AccountIban
    FT.DATA.ARRAY<5> = BenificaryAcct
    FT.DATA.ARRAY<6> = R.FT.REC<FT.Contract.FundsTransfer.CreditAmount>
    FT.DATA.ARRAY<7> = R.FT.REC<FT.Contract.FundsTransfer.CreditCurrency>
    FT.DATA.ARRAY<8> = R.FT.REC<FT.Contract.FundsTransfer.DebitTheirRef>
    FT.DATA.ARRAY<9> = R.FT.REC<FT.Contract.FundsTransfer.CreditTheirRef>
    FT.DATA.ARRAY<10> = R.FT.REC<FT.Contract.FundsTransfer.PaymentDetails>
    FT.DATA.ARRAY<11> = PaymentTransStatus
    FT.DATA.ARRAY<12> = ''
    CONVERT @FM TO '*' IN FT.DATA.ARRAY
    FT.DATA<-1> = FT.DATA.ARRAY

 
RETURN
**</region>
*-----------------------------------------------------------------------------
CHECK.SEPA.FT:
**<region = CHECK.SEPA.FT>

    LocalRef = R.FT.REC<FT.Contract.FundsTransfer.LocalRef>
    EB.LocalReferences.GetLocRef('FUNDS.TRANSFER','SEPA.THEIR.ACCT',SEPA.ACCT)
    SepaTheirAcct = LocalRef<1,SEPA.ACCT>
RETURN
**</region>
*-----------------------------------------------------------------------------
END
