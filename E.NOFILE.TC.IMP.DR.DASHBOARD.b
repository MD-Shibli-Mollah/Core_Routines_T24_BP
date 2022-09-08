* @ValidationCode : MjotNzc0MTM3MjIyOkNwMTI1MjoxNTYzMDE0ODM3MjE4OnNtdWdlc2g6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0OjE5NToxMzY=
* @ValidationInfo : Timestamp         : 13 Jul 2019 16:17:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 136/195 (69.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-146</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.IMP.DR.DASHBOARD(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of Import Drawing records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.IMP.DR.DASHBOARD using the Standard selection NOFILE.TC.IMP.DR.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Import drawing records details such as LC id, TypeOfLC, Transaction reference, Beneficiary,
*                      Document status, Drawing date, Currency, Amount, Event status, Application name, Record status(RET.DATA)
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
*
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

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
    GOSUB FETCH.CIB.LISTS ;*Get Import Drawings lists

    FINAL.ARRAY = DR.ARRAY
    RET.DATA = FINAL.ARRAY ;*Pass Final Array value to Ret Data
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine </desc>
INITIALISE:
*---------

    DRAWING.CNT = 0;INP.USER = '';CIB.CUSTOMER = '';SEL.LIVE.LC.LIST = '';SEL.UNAUTH.DR.LIST = '';LC.ID = '';DR.ID = '' ;*Initialising the variables
    DR.UANUTH.POS = '';DR.POS = '';DR.INPUT = '';DR.EXT.USER = '';TRANS.REF = '';APPLICANT.CUSTNO = '';BENEFICIARY = '';ISSUE.DATE = '' ;*Initialising the variables
    EXPIRY.DATE = '';CURRENCY = '';AMOUNT = '';EVENT.STATUS = '';DR.DATE = '';REC.STATUS = '';GET.DATE = '';TRANS.DATE.TIME = '';RECENT.TRANS = '' ;*Initialising the variables
    EVENT.STATUS = '';R.LC.LIVE.REC = '';LC.LIVE.REC.ERR = '';RET.DATA = '';TYPE.OF.LC.CODE = '';TYPE.OF.LC = '';DR.ARRAY = '';FINAL.ARRAY = '';DR.DOC.STATUS = '';LC.TYPE.POS = '';LC.TYPE.LIST = '' ;*Initialising the variables

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>Fetches List of drawing records</desc>
FETCH.CIB.LISTS:
*--------------
     LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    GOSUB DR.LIVE.LISTS ;*Get Pend Bank Approval,Approved and Rejected records from Drawings Live lists
    GOSUB DR.UNAUTH.LISTS ;*Get Pending Authorisation lists

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= DR.LIVE.LISTS>
*** <desc>Selects List of drawing LIVE records</desc>
DR.LIVE.LISTS:
*------------
    TABLE.NAME = "DRAWINGS"
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = EB.DataAccess.DasAllIds ;*Select all drawings records and filter import drawings based on Type of LC and Applicant field
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    DR.LIST = THE.LIST
    LOOP
        REMOVE DR.ID FROM DR.LIST SETTING DR.POS
    WHILE DR.ID:DR.POS
        GOSUB FORM.DR.LISTS ;*Form Live lists of different statuses.
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= DR.UNAUTH.LISTS>
*** <desc>Fetches List of drawing unauthorised records</desc>
DR.UNAUTH.LISTS:
*--------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = EB.DataAccess.DasAllIds ;;*Select all drawings records and filter import drawings based on Applicant field
    EB.DataAccess.Das("DRAWINGS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.DR.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE DR.ID FROM  SEL.UNAUTH.DR.LIST SETTING DR.UANUTH.POS
    WHILE DR.ID:DR.UANUTH.POS
        IF DR.ID NE '' THEN
            R.DR.UNAUTH.REC = ''
            DR.UNAUTH.ERR = ''
            R.DR.UNAUTH.REC = LC.Contract.Drawings.ReadNau(DR.ID,DR.UNAUTH.ERR) ;*Read Nau Drawings record
            GOSUB CHECK.EB.EXTERNAL.USER
            TRANS.REF = DR.ID
            LC.ID = DR.ID[1,12] ;*Get LC reference
            GOSUB READ.LC ;*Read LC
            APPLICANT.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno>
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
            GOSUB CHECK.LC.TYPES.LIST
            LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
                IF R.EB.EXTERNAL.USER AND R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrRecordStatus>[2,2] EQ 'NA' AND APPLICANT.CUSTNO EQ CIB.CUSTOMER THEN ;*Form an array for Unauthorised Import drawings
                    GOSUB GET.TYPE.OF.LC ;*Get Description for Type of LC
                    BENEFICIARY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Beneficiary in LC
                    CON.DISCREPANT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrConDiscrepancy>
                    IF R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawingType> NE 'RD' THEN
                        GOSUB GET.DOC.STATUS ;*Get Document Status based on Con Discrepancy field
                    END
                    GOSUB GET.UNAUTH.DR.DATE
                    CURRENCY = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawCurrency> ;*Currency
                    AMOUNT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDocumentAmount> ;*Document Amount
                    EVENT.STATUS = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrIbEventStatus> ;*IB Event Status
                    APPL.NAME = "Drawings"
                    REC.STATUS = "Unauth"
                    GOSUB FORM.DR.UNAUTH.ARRAY ;*Form Pend Auth Array
                END
            END
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DR.LISTS>
*** <desc>Fetches List of drawing LIVE records</desc>
FORM.DR.LISTS:
*------------
    R.DR.LIVE.REC = ''
    DR.LIVE.REC.ERR = ''
    R.DR.LIVE.REC = LC.Contract.tableDrawings(DR.ID,DR.LIVE.REC.ERR) ;*Read drawings record
    LC.ID = DR.ID[1,12]
    GOSUB READ.LC
    TRANS.REF = DR.ID
    R.DR.UNAUTH.REC = LC.Contract.Drawings.ReadNau(DR.ID,DR.UNAUTH.ERR) ;*Read Nau Drawings record
    GOSUB CHECK.EB.EXTERNAL.USER
    TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
    GOSUB CHECK.LC.TYPES.LIST
    LOCATE TYPE.OF.LC.CODE IN LC.TYPE.LIST SETTING LC.TYPE.POS THEN
        IF R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno> EQ CIB.CUSTOMER AND R.DR.LIVE.REC<LC.Contract.Drawings.TfDrIbEventStatus> NE 'With Customer' AND NOT(R.EB.EXTERNAL.USER) THEN   ;*With Customer should not get listed in Import Listing page
            TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
            GOSUB GET.TYPE.OF.LC
            BENEFICIARY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1>
            CON.DISCREPANT = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrConDiscrepancy>
            GOSUB GET.DOC.STATUS
            GOSUB GET.DR.DATE
            CURRENCY = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawCurrency>
            AMOUNT = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDocumentAmount>
            EVENT.STATUS = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrIbEventStatus>
            GET.DATE = EB.SystemTables.getToday()
            EB.API.Cdt('',GET.DATE,"-2C")
            GET.DATE = GET.DATE[3,6] ;*Calcuate date to check if records are created recently(2 days) to show the status with Image in front end enquiry output.
            TRANS.DATE.TIME = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDateTime,1>[1,6]
            IF (TRANS.DATE.TIME GE GET.DATE AND TRANS.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND EVENT.STATUS THEN
                RECENT.TRANS = EVENT.STATUS : "2D"
            END
            IF NOT(EVENT.STATUS) THEN ;*For Non CIB Drawings, IB status field will not contain any value, hence default as Approved in enquiry output
                EVENT.STATUS = "Approved"
            END
            APPL.NAME = "Drawings"
            REC.STATUS = "Live"
            GOSUB FORM.DR.ARRAY
            GOSUB RESET.VARIABLES
        END
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DR.UNAUTH.ARRAY>
*** <desc>Build final array of unauthorised drawing record details</desc>
FORM.DR.UNAUTH.ARRAY:
*-------------------
    DR.ARRAY<-1> := LC.ID:"*":TYPE.OF.LC:"*":TRANS.REF:"*":BENEFICIARY:"*":DOC.STATUS:"*":DR.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DR.ARRAY>
*** <desc>Build final array of drawing LIVE record details</desc>
FORM.DR.ARRAY:
*------------
    DR.ARRAY<-1> = LC.ID:"*":TYPE.OF.LC:"*":TRANS.REF:"*":BENEFICIARY:"*":DOC.STATUS:"*":DR.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>Read LC record</desc>
READ.LC:
*------

    R.LC.LIVE.REC = '' ;*Initialising record variable
    LC.LIVE.REC.ERR = '' ;*Initialising error variable
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.LIVE.REC.ERR) ;*Read LC Record

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TYPE.OF.LC>
*** <desc>Read LC types record and set appropriate LC type description based on the pay type</desc>
GET.TYPE.OF.LC:
*-------------
    R.LC.TYPES = ''
    LC.TYPE.ERR = ''
    R.LC.TYPES = LC.Config.tableTypes(TYPE.OF.LC.CODE, LC.TYPE.ERR) ;*Read LC Types
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
*** <region name= GET.UNAUTH.DR.DATE>
*** <desc>Set drawing date for unauthorised record based on drawing type</desc>
GET.UNAUTH.DR.DATE:
*-----------------
    IF R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawingType> MATCHES 'AC':@VM:'MA':@VM:'DP':@VM:'MD' THEN
        DR.DATE = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrMaturityReview> ;*Maturity Date for Acceptance and Deferred Payment Drawings
    END ELSE
        IF R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'SP' THEN
            DR.DATE = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrValueDate> ;*Value date for Sight drawings
        END
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.DR.DATE>
*** <desc>Set drawing date for LIVE record based on drawing type</desc>
GET.DR.DATE:
*----------
    IF R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> MATCHES 'AC':@VM:'MA':@VM:'DP':@VM:'MD' THEN
        DR.DATE = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrMaturityReview> ;*Maturity Date for Acceptance and Deferred Payment Drawings
    END ELSE
        IF R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'SP' THEN
            DR.DATE = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrValueDate> ;*Value date for Sight drawings
        END
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.DOC.STATUS>
*** <desc>Set document status based on consolidated discrepancy field</desc>
GET.DOC.STATUS:
***************
    BEGIN CASE
        CASE R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'DC' OR R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'DC' ;*For draw type DC, display clean or discrepant based on Con discrepancy
            IF CON.DISCREPANT NE '' THEN ;*If Con discrepancy is null, display Clean else Discrepant
                DOC.STATUS = "Discrepant"
            END ELSE
                DOC.STATUS = "Clean"
            END
        CASE R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> MATCHES 'SP':@VM:'AD' ;*For draw type SP/AD, display Doc status as Paid
            DOC.STATUS = "Paid"
        CASE R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'AC' ;*For draw type AC, display Doc status as Accepted
            DOC.STATUS = "Accepted"
        CASE R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'DP' ;*For draw type DP, display Doc status as Deferred
            DOC.STATUS = "Deferred Payment"
        CASE R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> MATCHES 'MA':@VM:'MD' ;*For draw type MA/MD, display Doc status as Settled
            DOC.STATUS = "Settled"
        CASE R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> MATCHES 'CR':@VM:'FR' ;*For draw type CR/FR, display Doc status as Rejected
            DOC.STATUS = "Rejected"
    END CASE
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Reset variables</desc>
RESET.VARIABLES:
*--------------
    DOC.STATUS = ''
    DR.DATE = ''
    RECENT.TRANS = ''
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.EB.EXTERNAL.USER>
*** <desc>Extracts the external user id from the Inputter field of the record</desc>
CHECK.EB.EXTERNAL.USER:
*---------------------

    DR.INPUT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrInputter>
    EB.EXT.USER.ID = FIELD(DR.INPUT,'_',2) ;*Get Inputter value from Inputter field
    GOSUB READ.EB.EXTERNAL.USER ;*Read EB External User
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
END
