* @ValidationCode : MjotODM2Mjk2MDA6Q3AxMjUyOjE1NjMwMTQ4Mzc2NzY6c211Z2VzaDoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNTMxLTAzMTQ6MTQ4OjE0Mg==
* @ValidationInfo : Timestamp         : 13 Jul 2019 16:17:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 142/148 (95.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-130</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.IMP.LCAMD.DASHBOARD(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of Import LetterOfCredit(LC) amendment records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.IMP.LCAMD.DASHBOARD using the Standard selection NOFILE.TC.IMP.LCAMD.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Import LC amendment records details such as LC id, LC amendment id, Beneficiary, Amendment date,
*                      Currency, Amount, Event Status, Application name, Record status, Recent Trans, LcAmdNauBkUser(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*
* 29/10/18 - Task : 2831555
*			 Componentization II - EB.DataAccess should be used instead of I_DAS.COMMON.
*		     EB.DataAccess.DasAllIds should be used instead of DAS$ALL.IDS
*		     Strategic Initiative : 2822484
*
* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LC.AMENDMENTS
    $INSERT I_DAS.LC.TYPES

    $USING LC.Channels
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Foundation
    $USING EB.DataAccess
    $USING LC.Contract
    $USING LC.Config
    $USING EB.ARC
    $USING EB.Browser
    $USING EB.API
    $USING EB.ErrorProcessing

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FETCH.CIB.LISTS ;*Get Import LC Amendment lists

    RET.DATA = LC.AMD.ARRAY ;*Pass LC AMD Array to Ret Data
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine </desc>
INITIALISE:
*---------
    
    LC.AMEND.NO = 0;CIB.CUSTOMER = '';SEL.LIVE.LC.LIST = '';SEL.UNAUTH.LCAMD.LIST = '';LC.AMD.ID = '';LCAMD.UANUTH.POS = '' ;*Initialising variables
    R.LC.AMD.UNAUTH.REC = '';R.LC.AMD.REC = '';LC.AMD.ERR = '';LC.AMD.UNAUTH.ERR = '';LC.AMD.INPUT = '';LC.AMD.EXT.USER = '' ;*Initialising variables
    LC.ID = '';LC.POS = '';APPLICANT.CUSTNO = '';BENEFICIARY = '';AMD.DATE = '';CURRENCY = '';AMOUNT = '';EVENT.STATUS = '' ;*Initialising variables
    REC.STATUS = '';LC.AMD.LIST = '';LC.AMD.POS = '';GET.DATE = '';TRANS.DATE.TIME = '';RECENT.TRANS = '';R.LC.LIVE.REC = '' ;*Initialising variables
    LC.LIVE.REC.ERR = '';LC.AMD.ARRAY = '';RET.DATA = '';LC.TYPE.LIST = '';LC.TYPE.POS = '' ;*Initialising variables

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>Fetches List of LC amendment records</desc>
FETCH.CIB.LISTS:
*--------------

    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    GOSUB LCAMD.LIVE.LISTS ;*Get LC Amendment Live Lists which contains Pend Bank Approval, Approved and Rejected
    GOSUB LCAMD.UNAUTH.LISTS ;*Get LC Amendment Pending Authorisation lists

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= LCAMD.LIVE.LISTS>
*** <desc>Selects List of LC amendment LIVE records</desc>
LCAMD.LIVE.LISTS:
*---------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    TABLE.NAME = "LETTER.OF.CREDIT"
    THE.LIST = dasLetterOfCreditCibLive ;*Select Import LC's based on Applicant Custno
    THE.ARGS<1> = CIB.CUSTOMER ;*Applicant Custno
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.LC.LIST<1,-1> = THE.LIST
    GOSUB FORM.LC.AMD.LISTS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= LCAMD.UNAUTH.LISTS>
*** <desc>Fetches List of LC amendment unauthorised records</desc>
LCAMD.UNAUTH.LISTS:
*-----------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = EB.DataAccess.DasAllIds ;*Select all Unauthorised LC Amendments
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.LCAMD.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM  SEL.UNAUTH.LCAMD.LIST SETTING LCAMD.UANUTH.POS
    WHILE LC.AMD.ID:LCAMD.UANUTH.POS
        IF LC.AMD.ID NE '' THEN
            R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.UNAUTH.ERR) ;*Read LC Amendment Nau record
            GOSUB CHECK.EB.EXTERNAL.USER
            LC.ID = LC.AMD.ID[1,12]
            GOSUB READ.LC
            APPLICANT.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno>
            IF R.EB.EXTERNAL.USER AND R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdRecordStatus>[2,2] EQ 'NA' AND APPLICANT.CUSTNO EQ CIB.CUSTOMER THEN ;*Form an array if applicant custno is CIB Customer(For Import) and Inputter should be an External User
                BENEFICIARY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Beneficiary in LC
                AMD.DATE = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdNewAdvExpDate> ;*Advice Expiry Date in LC Amendment
                CURRENCY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency in LC
                AMOUNT = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Amount in LC Amendment
                EVENT.STATUS = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdIbEventStatus>
                IF NOT(EVENT.STATUS) THEN
                    EVENT.STATUS = "With Customer"  ;*For first time input of LC Amendments, Event Status is populated as With Customer for filter
                END
                APPL.NAME = "Amendment"
                REC.STATUS = "Unauth"
                GOSUB FORM.LC.AMD.UNAUTH.ARRAY ;*Form Pend Auth Array
            END
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.AMD.LISTS>
*** <desc>Fetches List of LC amendment LIVE records</desc>
FORM.LC.AMD.LISTS:
*----------------
    LOOP
        REMOVE LC.ID FROM SEL.LIVE.LC.LIST SETTING LC.POS
    WHILE LC.ID:LC.POS
        IF LC.ID NE '' THEN
            GOSUB READ.LC ;*Read LC
            GOSUB CHECK.LC.TYPES.LIST
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
            LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
                GOSUB GET.LC.AMEND.ID ;*Get LC Amendment Ids based on LC id
            END
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LC.AMEND.ID>
*** <desc>Fetches List of LC amendment LIVE records based on LC id</desc>
GET.LC.AMEND.ID:
*--------------
    TABLE.NAME = "LC.AMENDMENTS"
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = DAS.LC.AMENDMENTS$IDLIKE ;*Select LC Amendment records based on LC Id
    THE.ARGS<1> = LC.ID
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    LC.AMD.LIST = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM LC.AMD.LIST SETTING LC.AMD.POS
    WHILE LC.AMD.ID:LC.AMD.POS
        GOSUB SELECT.IMPORT.LC.AMENDMENTS
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= SELECT.IMPORT.LC.AMENDMENTS>
*** <desc>Read LC amendment record</desc>
SELECT.IMPORT.LC.AMENDMENTS:
*--------------------------
    R.LC.AMD.REC = ''
    LC.AMD.ERR = ''
    R.LC.AMD.REC = LC.Contract.tableAmendments(LC.AMD.ID,LC.AMD.ERR) ;*Read Live LC Amendment record
    R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.ERR) ;*Read Nau LC Amendment record
    LC.ID = LC.AMD.ID[1,12]
    GOSUB CHECK.EB.EXTERNAL.USER
    IF R.LC.AMD.REC<LC.Contract.Amendments.AmdIbEventStatus> NE 'With Customer' AND NOT(R.EB.EXTERNAL.USER) THEN   ;*With Customer should not get listed in Import Listing page
        BENEFICIARY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Beneficiary in LC
        AMD.DATE = R.LC.AMD.REC<LC.Contract.Amendments.AmdNewAdvExpDate> ;*Advice Expiry Date in LC Amendment
        CURRENCY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency in LC
        AMOUNT = R.LC.AMD.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Amount in LC Amendment
        EVENT.STATUS = R.LC.AMD.REC<LC.Contract.Amendments.AmdIbEventStatus> ;*Ib Event Status in LC Amendment
        GET.DATE = EB.SystemTables.getToday()
        EB.API.Cdt('',GET.DATE,"-2C")
        GET.DATE = GET.DATE[3,6] ;*Calcuate date to check if records are created recently(2 days) to show the status with Image in front end enquiry output.
        TRANS.DATE.TIME = R.LC.AMD.REC<LC.Contract.Amendments.AmdDateTime,1>[1,6]
        IF (TRANS.DATE.TIME GE GET.DATE AND TRANS.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND EVENT.STATUS THEN
            RECENT.TRANS = EVENT.STATUS : "2D" ;*Append 2D for recent transactions
        END
        IF NOT(EVENT.STATUS) THEN ;*For Non CIB Amendments, IB status field will not contain any value, hence default as Approved in enquiry output
            EVENT.STATUS = "Approved"
        END
        APPL.NAME = "Amendment"
        REC.STATUS = "Live"
        GOSUB FORM.LC.AMD.ARRAY ;*Form LC Amendment array for Pend Bank Approval,Approved and Rejected
        RECENT.TRANS = ''
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.AMD.UNAUTH.ARRAY>
*** <desc>Build final array of unauthorised LC amendment record details</desc>
FORM.LC.AMD.UNAUTH.ARRAY:
*-----------------------
    LC.AMD.ARRAY<-1> := LC.ID:"*":LC.AMD.ID:"*":BENEFICIARY:"*":AMD.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.AMD.ARRAY>
*** <desc>Build final array of LC amendment LIVE record details</desc>
FORM.LC.AMD.ARRAY:
*----------------
    LC.AMD.ARRAY<-1> = LC.ID:"*":LC.AMD.ID:"*":BENEFICIARY:"*":AMD.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>Read LC record</desc>
READ.LC:
*------
    R.LC.LIVE.REC = '' ;*Initialise record variable
    LC.LIVE.REC.ERR = '' ;*Initialise error variable
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.LIVE.REC.ERR) ;*Read Live LC Record

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.LC>
*** <desc>Read unauthorised LC record</desc>
READ.UNAUTH.LC:
*-------------
    R.LC.UNAUTH.REC = '' ;*Initialise record variable
    LC.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.LC.UNAUTH.REC = LC.Contract.LetterOfCredit.ReadNau(LC.ID,LC.UNAUTH.REC.ERR) ;*Read Nau LC record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.EB.EXTERNAL.USER>
*** <desc>Extracts the external user id from the Inputter field of the record</desc>
CHECK.EB.EXTERNAL.USER:
*---------------------

    LC.AMD.INPUT = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdInputter>
    EB.EXT.USER.ID = FIELD(LC.AMD.INPUT,'_',2) ;*Get Inputter value from Inputter field
    GOSUB READ.EB.EXTERNAL.USER ;*Read EB External USER
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>Reads external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = ''
    EB.EXT.USER.ERR = ''
    R.EB.EXTERNAL.USER = EB.ARC.tableExternalUser(EB.EXT.USER.ID,EB.EXT.USER.ERR) ;*Read EB External User
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.LC.TYPES.LIST>
*** <desc>Fetches list of records from LC types application</desc>
CHECK.LC.TYPES.LIST:
*------------------
    THE.ARGS = ''
    THE.LIST = ''
    SELECTION.FIELDS = 'IMPORT.EXPORT':@VM:'DOC.COLLECTION':@VM:'CLEAN.CREDIT':@VM:'CLEAN.COLLECTION'
    SELECTION.OPERAND = 'EQ':@VM:'NE':@VM:'NE':@VM:'NE'
    SELECTION.VALUES = 'I':@VM:'YES':@VM:'YES':@VM:'YES'
    THE.ARGS<1> = SELECTION.FIELDS
    THE.ARGS<2> = SELECTION.OPERAND
    THE.ARGS<3> = SELECTION.VALUES
    THE.LIST = dasLcTypesImportExport ;*Outward Collection records should not displayed
    EB.DataAccess.Das("LC.TYPES",THE.LIST,THE.ARGS,"")
    LC.TYPE.LIST = THE.LIST
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
