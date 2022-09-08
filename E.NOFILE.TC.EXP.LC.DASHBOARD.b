* @ValidationCode : MjotMTEyNzgzNzI0MDpDcDEyNTI6MTU2MzAxNDgzODEyMDpzbXVnZXNoOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDo4Mjo4Mg==
* @ValidationInfo : Timestamp         : 13 Jul 2019 16:17:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/82 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-116</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.EXP.LC.DASHBOARD(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of Export LetterOfCredit(LC) records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.EXP.LC.DASHBOARD using the Standard selection NOFILE.TC.EXP.LC.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Export LC records details such as Issue bank reference, Transaction reference, TypeOfLC,
*                      Issuing bank, Applicant, Expiry date, Currency, Amount, Application name, Record status(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*
* 29/10/18 - Task : 2831555
*			 Componentization II - EB.DataAccess should be used instead of I_DAS.COMMON.
*		     Strategic Initiative : 2822484
*
* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LC.TYPES

    $USING LC.Channels
    $USING EB.SystemTables
    $USING EB.Reports
    $USING LC.Contract
    $USING LC.Config
    $USING EB.Browser
    $USING EB.DataAccess
    $USING EB.ErrorProcessing

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FETCH.CIB.LISTS ;*Get Export LC Lists

    RET.DATA = LC.ARRAY ;*Pass Export LC Array value to Ret Data
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------
    SEL.LIVE.LC.LIST = '';CIB.CUSTOMER = '';LC.ID = '';LC.POS = '';ISS.BANK.REF = '';TRANS.REF = '';TYPE.OF.LC.CODE = '';ISSUING.BANK = '' ;*Initialising variables
    APPLICANT = '';EXPIRY.DATE = '';CURRENCY = '';AMOUNT = '';APPL.NAME = '';EVENT.STATUS = '';REC.STATUS = '';LC.ARRAY = '';R.LC.LIVE.REC = '' ;*Initialising variables
    R.LC.TYPES = '';LC.TYPE.ERR = '';TYPE.OF.LC = '';LC.LIVE.REC.ERR = '';RET.DATA = '' ;*Initialising variables
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>Fetch CIB customers</desc>
FETCH.CIB.LISTS:
*--------------
    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    GOSUB EXPORT.LIVE.LISTS ;*Select Export LC records
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= EXPORT.LIVE.LISTS>
*** <desc>Select LC based issuing bank and beneficiary</desc>
EXPORT.LIVE.LISTS:
*----------------
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
    GOSUB FORM.LC.LISTS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.LISTS>
*** <desc>Get LC details</desc>
FORM.LC.LISTS:
*------------
    LOOP
        REMOVE LC.ID FROM SEL.LIVE.LC.LIST SETTING LC.POS
    WHILE LC.ID:LC.POS
        IF LC.ID NE '' THEN
            GOSUB READ.LC ;*Read LC record
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
            LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
                ISS.BANK.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssBankRef> ;*Iss Bank Ref
                TRANS.REF = LC.ID
                GOSUB GET.TYPE.OF.LC ;*Get Description for Type of LC
                ISSUING.BANK = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssuingBankNo> ;*Issuing Bank No
                APPLICANT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Applicant
                EXPIRY.DATE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcExpiryDate> ;*Expiry Date
                CURRENCY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency
                AMOUNT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcAmount> ;*Amount
                APPL.NAME = "Letter of Credit"
                EVENT.STATUS = "Approved" ;*All Export LCs for the respective corporate customer will be always in Approved List
                REC.STATUS = "Live"
                GOSUB FORM.LC.ARRAY ;*Form an array with all values.
            END
        END
    REPEAT

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LC.ARRAY>
*** <desc>Form LC array</desc>
FORM.LC.ARRAY:
*------------
    LC.ARRAY<-1> = ISS.BANK.REF:"*":TRANS.REF:"*":TYPE.OF.LC:"*":ISSUING.BANK:"*":APPLICANT:"*":EXPIRY.DATE:"*":CURRENCY:"*":AMOUNT:"*":APPL.NAME:"*":REC.STATUS

RETURN

*** </region>
*-----------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>To read LC record</desc>
READ.LC:
*------
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID, LC.LIVE.REC.ERR) ;*Read LC record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TYPE.OF.LC>
*** <desc>Get LC pay record</desc>
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
END
