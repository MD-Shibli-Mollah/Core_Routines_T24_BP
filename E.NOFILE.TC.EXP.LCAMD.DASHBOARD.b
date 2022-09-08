* @ValidationCode : MjotMTI4ODU2NTcwMjpDcDEyNTI6MTU2ODcyODUzNjQ4MzpzbXVnZXNoOjg6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDoxNjg6MTYw
* @ValidationInfo : Timestamp         : 17 Sep 2019 19:25:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 160/168 (95.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-146</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.EXP.LCAMD.DASHBOARD(RET.DATA)

*---------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of Export LetterOfCredit(LC) amendment records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.EXP.LCAMD.DASHBOARD using the Standard selection NOFILE.TC.EXP.LCAMD.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Export LC amendment records details such as Issue bank reference, Transaction reference, TypeOfLC,
*                      Issuing bank, Applicant, Amendment date, Currency, Amount, Application name, Record status, Event status, Amend status(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 30/06/2017  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization
*
* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LC.AMENDMENTS
    $INSERT I_DAS.LC.TYPES

    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING LC.Contract
    $USING LC.Config
    $USING EB.Browser
    $USING EB.ARC
    $USING EB.ErrorProcessing
    

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FETCH.CIB.LISTS ;*Get Export LC Amendment Lists

    RET.DATA = LC.AMD.ARRAY ;*Pass Export LC Amendment Array value to Ret Data
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------
    LC.ID = '';LC.POS = '';LC.AMD.ID = '';LC.AMD.POS = '';LC.AMD.LIST = '';ISS.BANK.REF = '';TRANS.REF = '';TYPE.OF.LC.CODE = '' ;*Initialising the variables
    R.LC.AMD.REC = '';ISS.BANK.REF = '';ISSUING.BANK = '';APPLICANT = '';AMD.DATE = '';CURRENCY = '';AMOUNT = '';APPL.NAME = '' ;*Initialising the variables
    EVENT.STATUS = '';REC.STATUS = '';LC.AMD.ARRAY = '';R.LC.LIVE.REC = '';R.LC.TYPES = '';LC.TYPE.ERR = '';TYPE.OF.LC = '' ;*Initialising the variables
    LC.LIVE.REC.ERR = '';CIB.CUSTOMER = '' ;*Initialising the variables
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>To fetch CIB customers</desc>
FETCH.CIB.LISTS:
*--------------

     LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
     END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    GOSUB LCAMD.LIVE.LISTS ;*Select Export LC Amendment records
    GOSUB LCAMD.UNAUTH.LISTS ;*Select Export LC Amendment unauthorised lists
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= LCAMD.LIVE.LISTS>
*** <desc>Fetch LC.AMENDMENTS record</desc>
LCAMD.LIVE.LISTS:
*---------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = dasLetterOfCreditCIbExpLive  ;*Selection based on Issuing Bank and Beneficiary
    THE.ARGS<1> = "" ;*ISSUING.BANK.NO
    THE.ARGS<2> = CIB.CUSTOMER          ;*BENEFICIARY.CUSTNO
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.LC.LIST<1,-1> = THE.LIST
    THE.ARGS = ''
    THE.LIST = ''
    SELECTION.FIELDS = 'IMPORT.EXPORT':@VM:'DOC.COLLECTION':@VM:'CLEAN.CREDIT':@VM:'CLEAN.COLLECTION'
    SELECTION.OPERAND = 'EQ':@VM:'NE':@VM:'NE':@VM:'NE'
    SELECTION.VALUES = 'E':@VM:'YES':@VM:'YES':@VM:'YES'
    THE.ARGS<1> = SELECTION.FIELDS
    THE.ARGS<2> = SELECTION.OPERAND
    THE.ARGS<3> = SELECTION.VALUES
    THE.LIST = dasLcTypesImportExport ;*Outward Collection records should not displayed
    EB.DataAccess.Das("LC.TYPES",THE.LIST,THE.ARGS,"")
    LC.TYPE.LIST = THE.LIST
    GOSUB FORM.LC.AMD.LISTS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.AMD.LISTS>
*** <desc>form LC amendments lists</desc>
FORM.LC.AMD.LISTS:
*----------------
    LOOP
        REMOVE LC.ID FROM SEL.LIVE.LC.LIST SETTING LC.POS
    WHILE LC.ID:LC.POS
        IF LC.ID NE '' THEN
            GOSUB READ.LC ;*Read LC record
            ISS.BANK.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssBankRef> ;*Iss Bank Ref
            TRANS.REF = LC.ID ;*LC Reference
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
            LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
                GOSUB GET.TYPE.OF.LC ;*Get Description for Type of LC
                ISSUING.BANK = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssuingBankNo> ;*Issuing Bank No
                GOSUB GET.LC.AMEND.ID ;*Get LC Amendment Ids from LC Reference
            END
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LC.AMEND.ID>
*** <desc>Get LC amendments id</desc>
GET.LC.AMEND.ID:
*--------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.ARGS = ''
    THE.LIST = DAS.LC.AMENDMENTS$IDLIKE ;*Select LC Amendments based on LC Id
    THE.ARGS<1> = LC.ID : "..."
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    LC.AMD.LIST = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM LC.AMD.LIST SETTING LC.AMD.POS
    WHILE LC.AMD.ID:LC.AMD.POS
        GOSUB SELECT.EXPORT.LC.AMENDMENTS
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= SELECT.EXPORT.LC.AMENDMENTS>
*** <desc>Select amendments made under export LC</desc>
SELECT.EXPORT.LC.AMENDMENTS:
*--------------------------
    R.LC.AMD.REC = LC.Contract.tableAmendments(LC.AMD.ID, LC.AMD.ERR) ;*Read Live LC Amendment record
    EVENT.STATUS = R.LC.AMD.REC<LC.Contract.Amendments.AmdIbEventStatus> ;*Ib Event Status in LC Amendment
    R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.UNAUTH.ERR) ;*Read LC Amendment Nau record
    GOSUB CHECK.EB.EXTERNAL.USER ;*Read EB External user based on Inputter value
    IF EVENT.STATUS NE 'With Customer' AND NOT(R.EB.EXTERNAL.USER) THEN ;*Form an array when Event Status is other than With Customer and not in Unauth stage inputter by Corporate Inputter
        LC.ID = LC.AMD.ID[1,12] ;*LC Reference
        TRANS.REF = LC.AMD.ID
        ISS.BANK.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssBankRef> ;*Iss Bank Ref
        ISSUING.BANK = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssuingBankNo> ;*Issuing Bank No
        APPLICANT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Applicant
        AMD.DATE = R.LC.AMD.REC<LC.Contract.Amendments.AmdNewAdvExpDate> ;*Advice Expiry Date in LC Amendment
        CURRENCY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency
        AMOUNT = R.LC.AMD.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Amount in LC Amendment
        AMD.STATUS = R.LC.AMD.REC<LC.Contract.Amendments.AmdAmendStatus> ;*Amend Status in LC Amendment
        GOSUB GET.AMEND.STATUS
        IF NOT(EVENT.STATUS) THEN ;*Event Status is updated as Approved for Non CIB LC Amendments
            EVENT.STATUS = "Approved"
        END
        APPL.NAME = "Amendment"
        REC.STATUS = "Live"
        GOSUB FORM.LC.AMD.ARRAY
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= LCAMD.UNAUTH.LISTS>
*** <desc>Select unauthorised amendments made under export LC inputted by External User</desc>
LCAMD.UNAUTH.LISTS:
*-----------------

    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = EB.DataAccess.DasAllIds  ;*Select all Unauthorised LC Amendments
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.LCAMD.LIST<-1> = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM  SEL.UNAUTH.LCAMD.LIST SETTING LCAMD.UANUTH.POS
    WHILE LC.AMD.ID:LCAMD.UANUTH.POS
        IF LC.AMD.ID NE '' THEN
            R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.UNAUTH.ERR) ;*Read LC Amendment Nau record
            GOSUB CHECK.EB.EXTERNAL.USER ;*Read EB External user based on Inputter value
            LC.ID = LC.AMD.ID[1,12]
            GOSUB READ.LC ;*Read LC record
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType> ;*Type of LC record
            LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
                BENE.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno>
                IF R.EB.EXTERNAL.USER AND R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdRecordStatus>[2,2] EQ 'NA' AND BENE.CUSTNO EQ CIB.CUSTOMER THEN ;*Form an array if beneficiary custno is CIB Customer
                    GOSUB GET.TYPE.OF.LC ;*Get Description for Type of LC
                    TRANS.REF = LC.AMD.ID
                    ISS.BANK.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssBankRef> ;*Iss Bank Ref
                    ISSUING.BANK = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssuingBankNo> ;*Issuing Bank No
                    APPLICANT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Applicant
                    AMD.DATE = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdNewAdvExpDate> ;*Advice Expiry Date in LC Amendment
                    CURRENCY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency
                    AMOUNT = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Amount in LC Amendment
                    AMD.STATUS = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdAmendStatus> ;*Amend Status in LC Amendment
                    GOSUB GET.AMEND.STATUS ;*Get Amend Status for the respective LC Amendment
                    EVENT.STATUS = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdIbEventStatus> ;*IB Event Status
                    IF NOT(EVENT.STATUS) THEN
                        EVENT.STATUS = "With Customer"  ;*For first time input of LC Amendments, Event Status is populated as With Customer for filter
                    END
                    APPL.NAME = "Amendment"
                    REC.STATUS = "Unauth"
                    GOSUB FORM.LC.AMD.ARRAY ;*Form Pend Auth Array
                END
            END
        END
    REPEAT
RETURN
*** </region>
*----------------------------------------------------------------------------------------
*** <region name= FORM.LC.AMD.ARRAY>
*** <desc>Form LC amendment array</desc>
FORM.LC.AMD.ARRAY:
*----------------
    LC.AMD.ARRAY<-1> = ISS.BANK.REF:"*":TRANS.REF:"*":TYPE.OF.LC:"*":ISSUING.BANK:"*":APPLICANT:"*":AMD.DATE:"*":CURRENCY:"*":AMOUNT:"*":APPL.NAME:"*":REC.STATUS:"*":EVENT.STATUS:"*":AMEND.STATUS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>To read LC record</desc>
READ.LC:
*------
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID, LC.LIVE.REC.ERR) ;*Read Live LC Record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TYPE.OF.LC>
*** <desc>Get LC pay type</desc>
GET.TYPE.OF.LC:
*-------------
    R.LC.TYPES = LC.Config.tableTypes(TYPE.OF.LC.CODE, LC.TYPE.ERR)
    IF R.LC.TYPES THEN
        BEGIN CASE
            CASE R.LC.TYPES<LC.Config.Types.TypPayType> EQ 'P' ;*Description can be given based on pay type
                TYPE.OF.LC = "Sight"
            CASE R.LC.TYPES<LC.Config.Types.TypPayType> EQ 'A'
                TYPE.OF.LC = "Acceptance"
            CASE R.LC.TYPES<LC.Config.Types.TypPayType> EQ 'D'
                TYPE.OF.LC = "Deferred"
            CASE R.LC.TYPES<LC.Config.Types.TypPayType> MATCHES 'N':@VM:'NS':@VM:'NA'
                TYPE.OF.LC = "Negotiation"
            CASE R.LC.TYPES<LC.Config.Types.TypPayType> EQ 'M'
                TYPE.OF.LC = "Mixed Payment"
        END CASE
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.AMEND.STATUS>
*** <desc>Get Amend Status</desc>
GET.AMEND.STATUS:
*---------------
    BEGIN CASE
        CASE AMD.STATUS EQ 'PENDING'
            AMEND.STATUS = "Pending" ;*Display Amend Status as "Pending" in Front End enquiry
        CASE AMD.STATUS EQ 'APPROVED'
            AMEND.STATUS = "Approved" ;*Display Amend Status as "Approved" in Front End enquiry
        CASE AMD.STATUS EQ 'REJECTED'
            AMEND.STATUS = "Rejected" ;*Display Amend Status as "Rejected" in Front End enquiry
    END CASE
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.EB.EXTERNAL.USER>
*** <desc>Read EB External User</desc>
CHECK.EB.EXTERNAL.USER:
***********************
    R.EB.EXTERNAL.USER = ''
    EB.EXT.USER.REC.ERR = ''
    LC.AMD.INPUT = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdInputter> ;*Get Inputter value
    EB.EXT.USER.ID = FIELD(LC.AMD.INPUT,'_',2) ;*Get Inputter value from Inputter field
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(EB.EXT.USER.ID, EB.EXT.USER.REC.ERR) ;*Read EB External user based on Inputter field value
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
