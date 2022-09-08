* @ValidationCode : MjotNzM5MTY2OTA6Y3AxMjUyOjE2MTI4MjY1MDEwNzU6Y2dlcmVhOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDIuMjAyMTAyMDItMTkxMjoyMDQ6MTk0
* @ValidationInfo : Timestamp         : 09 Feb 2021 01:21:41
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : cgerea
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 194/204 (95.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210202-1912
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>80</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels
 
SUBROUTINE E.NOFILE.TC.IMP.LC.DASHBOARD(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of Import LetterOfCredit(LC) records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.IMP.LC.DASHBOARD using the Standard selection NOFILE.TC.IMP.LC.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Import LC records details such as Transaction reference, TypeOfLC, Beneficiary, Issue date, Expiry date,
*                      Currency, Amount, Event status, Application name, Record status, Recent Trans, LcAmdNauBkUser(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*
* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*
* 11/03/20 - Task : 3634155
*            Updated arguments for call to LC.CHECK.SWIFT.LICENSE
*            Enhancement : 3584352
*
* 13/03/20 - Task : 3638875
*            Updated arguments for call to LC.CHECK.SWIFT.LICENSE
*            Enhancement : 3584352
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LC.TYPES
    $INSERT I_DAS.DRAWINGS

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
    GOSUB GET.CIB.LISTS ;*Get Import LC lists

    FINAL.ARRAY = LC.ARRAY
    RET.DATA = FINAL.ARRAY ;*Pass Final Array value to Ret Data
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine </desc>
INITIALISE:
*---------
    CIB.CUSTOMER = '';SEL.LIVE.LC.LIST = '';SEL.UNAUTH.LC.LIST = '';LC.ID = '';LC.POS = '';APPLICANT.CUSTNO = '' ;*Initialising the variables
    BENEFICIARY = '';ISSUE.DATE = '';EXPIRY.DATE = '';CURRENCY = '';AMOUNT = '';EVENT.STATUS = '';REC.STATUS = '';GET.DATE = '' ;*Initialising the variables
    LC.DATE.TIME = '';RECENT.TRANS = '';EVENT.STATUS = '';R.LC.LIVE.REC = '';LC.LIVE.REC.ERR = '';RET.DATA = '';TYPE.OF.LC.CODE = '';TYPE.OF.LC = '' ;*Initialising the variables
    LC.ARRAY = '';FINAL.ARRAY = '';TRANS.REF = '';LC.TYPE.POS = '';LC.TYPE.LIST = '' ;*Initialising the variables
    
    CUSTOMER.NO = 0;
    CIB.CUSTOMER.LIST = '';
    
    L8.INSTALLED = "2018"
    LC.Contract.LcCheckSwiftLicense(L8.INSTALLED) ;* Check if SWIFT 2018 license is installed
    
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.CIB.LISTS>
*** <desc>Fetches List of LC records</desc>
GET.CIB.LISTS:
*------------

    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER.LIST = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER.LIST EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER.LIST = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    
    CUSTOMER.NO = DCOUNT(CIB.CUSTOMER.LIST<1>,@SM)
    
    GOSUB IMPORT.LIVE.LISTS ;*Get Pend Bank Approval,Approved and Rejected records from LC Live lists
    GOSUB IMPORT.UNAUTH.LISTS ;*Get Pending Authorisation lists
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= IMPORT.LIVE.LISTS>
*** <desc>Selects List of LC LIVE records</desc>
IMPORT.LIVE.LISTS:
*----------------
    FOR CUSTOMER.INDEX = 1 TO CUSTOMER.NO
        CIB.CUSTOMER = CIB.CUSTOMER.LIST<1,1,CUSTOMER.INDEX>
        TABLE.SUFFIX = ''
        THE.LIST = ''
        TABLE.NAME = "LETTER.OF.CREDIT"
        THE.LIST = dasLetterOfCreditCibLive ;*Select Import LC's based on Applicant Custno field
        THE.ARGS<1> = CIB.CUSTOMER ;*Applicant Custno
        EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
        SEL.LIVE.LC.LIST<1,-1> = THE.LIST
    NEXT CUSTOMER.INDEX
    GOSUB FORM.LC.LISTS ;*Form Live lists of different statuses.
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= IMPORT.UNAUTH.LISTS>
*** <desc>Fetches List of LC unauthorised records</desc>
IMPORT.UNAUTH.LISTS:
*------------------
    FOR CUSTOMER.INDEX = 1 TO CUSTOMER.NO
        CIB.CUSTOMER = CIB.CUSTOMER.LIST<1,1,CUSTOMER.INDEX>
        TABLE.SUFFIX = '$NAU'
        THE.LIST = ''
        THE.LIST = dasLetterOfCreditCIbNau ;*Select Import LC's based on Applicant Custno field
        THE.ARGS<1> = CIB.CUSTOMER ;*Applicant Custno
        EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
        SEL.UNAUTH.LC.LIST<1,-1> = THE.LIST
    NEXT CUSTOMER.INDEX
    LOOP
        REMOVE LC.ID FROM SEL.UNAUTH.LC.LIST SETTING LC.POS
    WHILE LC.ID:LC.POS
        IF LC.ID NE '' THEN
            GOSUB READ.UNAUTH.LC ;*Read LC Nau record
            GOSUB CHECK.EB.EXTERNAL.USER ;*Check if external user
            IF R.EB.EXTERNAL.USER AND R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcRecordStatus>[2,2] EQ 'NA' THEN ;*Form an array only if record is available in External User
                TRANS.REF = LC.ID ;*LC Reference
                TYPE.OF.LC.CODE = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcLcType> ;*Type of LC
                TYPE.OF.LC = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcPayTerms> ;*Get Type of LC from Payment terms field when LC is initiated through CIB and not approved
                BENEFICIARY = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Beneficiary
                ISSUE.DATE = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcIssueDate> ;*Issue Date
                EXPIRY.DATE = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcAdviceExpiryDate> ;*Advice Expiry Date
                CURRENCY = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency
                AMOUNT = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcLcAmount> ;*Amount
                EVENT.STATUS = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcIbStatus>
                IF NOT(EVENT.STATUS) THEN
                    EVENT.STATUS = "With Customer"
                END
                APPL.NAME = "Letter of Credit"
                REC.STATUS = "Unauth"
                GOSUB FORM.LC.UNAUTH.ARRAY ;*Form Pend Auth Array
            END
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.LISTS>
*** <desc>Fetches List of LC LIVE records</desc>
FORM.LC.LISTS:
*------------
    LOOP
        REMOVE LC.ID FROM SEL.LIVE.LC.LIST SETTING LC.POS
    WHILE LC.ID:LC.POS
        IF LC.ID NE '' THEN
            GOSUB READ.LC ;*Read LC
            TRANS.REF = LC.ID ;*LC Reference
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
            GOSUB CHECK.LC.TYPES.LIST
            GOSUB READ.UNAUTH.LC
            GOSUB CHECK.EB.EXTERNAL.USER
            LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
                IF R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIbStatus> NE 'With Customer' AND NOT(R.EB.EXTERNAL.USER) THEN  ;*With Customer should not get listed in Import Listing page
                    IF R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIbStatus> EQ 'Approved' OR NOT(R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIbStatus>) THEN ;*For approved LCs and Non CIB LCs, get type of LC based on LC Type
                        GOSUB GET.TYPE.OF.LC ;*Get description for Type of LC
                    END ELSE
                        TYPE.OF.LC = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcPayTerms> ;*Get Type of LC from Payment terms field when LC is initiated through CIB and not approved
                    END
                    BENEFICIARY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Beneficiary
                    ISSUE.DATE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssueDate> ;*Issue Date
                    EXPIRY.DATE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcAdviceExpiryDate> ;*Advice Expiry Date
                    CURRENCY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency
                    AMOUNT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcAmount> ;*Amount
                    APPL.NAME = "Letter of Credit"
                    EVENT.STATUS = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIbStatus>
                    GET.DATE = EB.SystemTables.getToday()
                    EB.API.Cdt('',GET.DATE,"-2C")
                    GET.DATE = GET.DATE[3,6] ;*Calcuate date to check if records are created recently(2 days) to show the status with Image in front end enquiry output.
                    LC.DATE.TIME = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcDateTime,1>[1,6]
                    IF (LC.DATE.TIME GE GET.DATE AND LC.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND EVENT.STATUS THEN
                        RECENT.TRANS = EVENT.STATUS : "2D"
                    END
                    IF NOT(EVENT.STATUS) THEN ;*For Non CIB LC's, IB status field will not contain any value, hence default as Approved in enquiry output
                        EVENT.STATUS = "Approved"
                    END
                    REC.STATUS = "Live"
                    IF EVENT.STATUS EQ 'Approved' THEN
                        GOSUB CHECK.BANK.USER.AMD.UNAUTH ;*Check any LC Amendments are inputted by Bank User and kept in INAU
                        GOSUB CHECK.DRAWINGS.UNAUTH ;*Check any drawing record related to LC is in INAU
                    END
                    GOSUB FORM.LC.ARRAY ;*Form an array for With Bank,Approved and Rejected
                END
                RECENT.TRANS = ''
                LC.AMD.NAU.BK.USER = ''
                SEL.UNAUTH.DR.LIST = ''
            END
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.UNAUTH.ARRAY>
*** <desc>Build final array of unauthorised LC record details</desc>
FORM.LC.UNAUTH.ARRAY:
*-------------------
    LC.ARRAY<-1> := TRANS.REF:"*":TYPE.OF.LC:"*":BENEFICIARY:"*":ISSUE.DATE:"*":EXPIRY.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.ARRAY>
*** <desc>Build final array of LC LIVE record details</desc>
FORM.LC.ARRAY:
*------------
    LC.ARRAY<-1> = TRANS.REF:"*":TYPE.OF.LC:"*":BENEFICIARY:"*":ISSUE.DATE:"*":EXPIRY.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS:"*":LC.AMD.NAU.BK.USER
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>Read LC record</desc>
READ.LC:
*------
    R.LC.LIVE.REC = '' ;*Initialise record variable
    LC.LIVE.REC.ERR = '' ;*Initialise error variable
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.LIVE.REC.ERR) ;*Read LC Live record

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC.AMENDMENT>
*** <desc>Read LC amendment record</desc>
READ.LC.AMENDMENT.NAU:
*--------------------
    R.LC.AMD.UNAUTH.REC = '' ;*Initialise record variable
    LC.AMD.NAU.REC.ERR = '' ;*Initialise error variable
    R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.NAU.REC.ERR) ;*Read LC Amendment Live record

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.LC>
*** <desc>Read LC Nau record</desc>
READ.UNAUTH.LC:
*-------------
    R.LC.UNAUTH.REC = '' ;*Initialise record variable
    LC.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.LC.UNAUTH.REC = LC.Contract.LetterOfCredit.ReadNau(LC.ID,LC.UNAUTH.REC.ERR) ;*Read Nau LC record

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TYPE.OF.LC>
*** <desc>Read LC types record and set appropriate LC type description based on the pay type</desc>
GET.TYPE.OF.LC:
*-------------
    R.LC.TYPES = ''
    LC.TYPE.ERR = ''
    R.LC.TYPES = LC.Config.tableTypes(TYPE.OF.LC.CODE, LC.TYPE.ERR) ;*Read LC types
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
*** <region name= CHECK.EB.EXTERNAL.USER>
*** <desc>Extracts the external user id from the Inputter field of the record</desc>
CHECK.EB.EXTERNAL.USER:
*---------------------
    LC.INPUTTER = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcInputter>
    EB.EXT.USER.ID = FIELD(LC.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
    GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>Reads external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = '' ;*Initialise record variable
    EB.EXT.USER.ERR = '' ;*Initialise error variable
    R.EB.EXTERNAL.USER = EB.ARC.tableExternalUser(EB.EXT.USER.ID,EB.EXT.USER.ERR) ;*Read EB External User record based on inputter field value
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
*** <region name= CHECK.BANK.USER.AMD.UNAUTH>
*** <desc>Checks if a LC amendment is inputted by bank user</desc>
CHECK.BANK.USER.AMD.UNAUTH:
*-------------------------

    AMND.NO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcAmendmentNo> + 1 ;* Amendment No
    IF L8.INSTALLED EQ "YES" AND AMND.NO GT 99 THEN
        LC.AMD.NO = FMT(AMND.NO,'3"0"R')
    END ELSE
        LC.AMD.NO = FMT(AMND.NO,'2"0"R')
    END
    LC.AMD.ID = LC.ID : "A" : LC.AMD.NO ;*Form LC Amendment Id
    GOSUB READ.LC.AMENDMENT.NAU ;*Read LC Amendment
    IF R.LC.AMD.UNAUTH.REC THEN
        LC.AMD.INPUTTER = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdInputter>
        EB.EXT.USER.ID = FIELD(LC.AMD.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
        GOSUB READ.EB.EXTERNAL.USER ;* Read EB External User
        IF NOT(R.EB.EXTERNAL.USER) THEN ;*If Unauth record is not inputted by External User then set flag not to display the amend button in LC Record page
            LC.AMD.NAU.BK.USER = 1 ;* When LC Amendment is inputted by Bank User and kept in INAU, set this flag to restrict amendment of LC from LC Listing
        END
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.DRAWINGS.UNAUTH>
*** <desc>Checks if any unauthorised drawing exist</desc>
CHECK.DRAWINGS.UNAUTH:
*--------------------

    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = DAS.DRAWINGS$IDLIKE ;*Select Unauthorised Drawings under LC
    THE.ARGS<1> = LC.ID
    EB.DataAccess.Das("DRAWINGS",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
    SEL.UNAUTH.DR.LIST = THE.LIST
    IF NOT(LC.AMD.NAU.BK.USER) AND SEL.UNAUTH.DR.LIST THEN ;*Set flag if any unauthorised drawings exists under LC.
        LC.AMD.NAU.BK.USER = 1
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
