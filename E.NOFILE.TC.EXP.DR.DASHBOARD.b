* @ValidationCode : MjoxMDY2NTc5NjEyOkNwMTI1MjoxNTYzMDE0ODM3NTcyOnNtdWdlc2g6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0OjE5NjoxNDY=
* @ValidationInfo : Timestamp         : 13 Jul 2019 16:17:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 146/196 (74.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-180</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.EXP.DR.DASHBOARD(RET.DATA)

*---------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of Export LetterOfCredit(LC) drawing records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.EXP.DR.DASHBOARD using the Standard selection NOFILE.TC.EXP.DR.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Export LC drawing records details such as Issue bank reference, TypeOfLC, Transaction reference,
*                      Applicant, Document status, Drawing date, Currency, Amount, Event status, Application name, Record status, Recent Trans(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 30/06/2017  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization
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

    $USING EB.SystemTables
    $USING EB.Reports
    $USING LC.Contract
    $USING LC.Config
    $USING EB.ARC
    $USING EB.DataAccess
    $USING EB.Browser
    $USING EB.API
    $USING EB.ErrorProcessing

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FETCH.CIB.LISTS ;*Get Export Drawings Lists

    FINAL.ARRAY = DR.ARRAY ;*Pass Drawings Live records and unauthorised records into Final Array
    RET.DATA = FINAL.ARRAY ;*Pass Final Array value to Ret Data
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------
    
    LC.ID = '';LC.POS = '';DR.ID = '';DR.UNAUTH.POS = '';SEL.UNAUTH.DR.LIST = '';DR.INPUT = '';DR.EXT.USER = '';BENEFICIARY.CUSTNO = '' ;*Initialising the variables
    ISS.BANK.REF = '';TRANS.REF = '';TYPE.OF.LC.CODE = '';R.LC.AMD.REC = '';ISS.BANK.REF = '';ISSUING.BANK = '';APPLICANT = '';GET.DATE = '' ;*Initialising the variables
    TRANS.DATE.TIME = '';RECENT.TRANS = '';CURRENCY = '';AMOUNT = '';APPL.NAME = '';EVENT.STATUS = '';REC.STATUS = '';LC.AMD.ARRAY = '' ;*Initialising the variables
    R.LC.LIVE.REC = '';R.LC.TYPES = '';LC.TYPE.ERR = '';TYPE.OF.LC = '';LC.LIVE.REC.ERR = '';NO.OF.DOC = '';DOC = '';CON.DISCREPANT = '' ;*Initialising the variables
    DOC.STATUS.VAL = '';DOC.STATUS = '';DR.DATE = '';INP.USER = '';CIB.CUSTOMER = '';DR.ARRAY = '';FINAL.ARRAY = '';RET.DATA = '' ;*Initialising the variables

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>Fetch CIB customer list</desc>
FETCH.CIB.LISTS:
*--------------
    
    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    
    GOSUB DR.LIVE.LISTS ;*Get Drawings live lists
    GOSUB DR.UNAUTH.LISTS ;*Get Drawings Unauthorised lists

RETURN
* </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= DR.LIVE.LISTS>
*** <desc>Select drawings based on beneficary</desc>
DR.LIVE.LISTS:
*------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    TABLE.NAME = "DRAWINGS"
    THE.LIST = EB.DataAccess.DasAllIds ;*Select all drawing records and filter based on Beneficiary field value in LC
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    DR.LIST<-1> = THE.LIST
    LOOP
        REMOVE DR.ID FROM DR.LIST SETTING DR.POS
    WHILE DR.ID:DR.POS
        GOSUB FORM.DR.LISTS
    REPEAT

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= DR.UNAUTH.LISTS>
*** <desc>Form unauthorised drawings list</desc>
DR.UNAUTH.LISTS:
*--------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.ARGS = ''
    TABLE.NAME = "DRAWINGS"
    THE.LIST = EB.DataAccess.DasAllIds
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.DR.LIST<-1> = THE.LIST
    LOOP
        REMOVE DR.ID FROM  SEL.UNAUTH.DR.LIST SETTING DR.UANUTH.POS
    WHILE DR.ID:DR.UANUTH.POS
        IF DR.ID NE '' THEN
            GOSUB READ.UNAUTH.DRAW
            TRANS.REF = DR.ID
            GOSUB CHECK.EB.EXTERNAL.USER
            LC.ID = DR.ID[1,12]
            GOSUB READ.LC
            BENEFICIARY.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno>
            IF R.EB.EXTERNAL.USER AND R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrRecordStatus>[2,2] EQ 'NA' AND BENEFICIARY.CUSTNO EQ CIB.CUSTOMER THEN
                ISS.BANK.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssBankRef> ;*Iss Bank Ref
                TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
                GOSUB GET.TYPE.OF.LC ;*Get Description for Type of LC
                APPLICANT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Applicant in LC
                IF R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawingType> NE 'RD' THEN
                    CON.DISCREPANT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrConDiscrepancy>
                    GOSUB GET.DOC.STATUS ;*Get Document Status based on Con Discrepancy field
                END
                GOSUB GET.UNAUTH.DR.DATE
                CURRENCY = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawCurrency> ;*Currency
                AMOUNT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDocumentAmount> ;*Amount
                EVENT.STATUS = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrIbEventStatus>
                IF NOT(EVENT.STATUS) THEN
                    EVENT.STATUS = 'With Customer'  ;*With Customer is populated in Event Status for front end filter
                END
                APPL.NAME = "Drawings"
                REC.STATUS = "Unauth"
                GOSUB FORM.DR.UNAUTH.ARRAY
                GOSUB RESET.VARIABLES
            END
        END
    REPEAT

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DR.LISTS>
*** <desc>Form drawings list</desc>
FORM.DR.LISTS:
*------------
    R.DR.LIVE.REC = LC.Contract.tableDrawings(DR.ID, DR.LIVE.REC.ERR) ;*Read Drawings record
    LC.ID = DR.ID[1,12]
    GOSUB READ.LC
    TRANS.REF = DR.ID
    GOSUB READ.UNAUTH.DRAW
    BENEFICIARY.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno>
    TYPE.OF.LC.CODE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
    GOSUB GET.TYPE.OF.LC ;*Get Description for Type of LC
    GOSUB CHECK.COLLECTION
    GOSUB CHECK.EB.EXTERNAL.USER
    IF R.DR.LIVE.REC<LC.Contract.Drawings.TfDrIbEventStatus> NE 'With Customer' AND BENEFICIARY.CUSTNO EQ CIB.CUSTOMER AND R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssuingBankNo> AND NOT(R.EB.EXTERNAL.USER) AND LC.FLAG THEN   ;*With Customer should not get listed in Import Listing page
        ISS.BANK.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcIssBankRef> ;*Iss Bank Ref
        APPLICANT = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Applicant
        IF R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> NE 'RD' THEN
            CON.DISCREPANT = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrConDiscrepancy>
            GOSUB GET.DOC.STATUS ;*Get Document Status based on Con Discrepancy
        END
        GOSUB GET.DR.DATE
        CURRENCY = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawCurrency> ;*Currency
        AMOUNT = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDocumentAmount> ;*Amount
        EVENT.STATUS = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrIbEventStatus> ;*IB Event Status
        GET.DATE = EB.SystemTables.getToday()
        EB.API.Cdt('',GET.DATE,"-2C")
        GET.DATE = GET.DATE[3,6] ;*Calcuate date to check if records are created recently(2 days) to show the status with Image in front end enquiry output.
        TRANS.DATE.TIME = R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDateTime,1>[1,6]
        IF (TRANS.DATE.TIME GE GET.DATE AND TRANS.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND EVENT.STATUS THEN
            RECENT.TRANS = EVENT.STATUS : "2D" ;*Append 2D to show the status with image in front end
        END
        IF NOT(EVENT.STATUS) THEN ;*For Non CIB Drawings, IB status field will not contain any value, hence default as Approved in enquiry output
            EVENT.STATUS = "Approved"
        END
        APPL.NAME = "Drawings"
        REC.STATUS = "Live"
        GOSUB FORM.DR.ARRAY
        GOSUB RESET.VARIABLES
    END

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DR.UNAUTH.ARRAY> 
*** <desc>Form unauthorised drawings array</desc>
FORM.DR.UNAUTH.ARRAY:
*-------------------
    DR.ARRAY<-1> = ISS.BANK.REF:"*":TYPE.OF.LC:"*":TRANS.REF:"*":APPLICANT:"*":DOC.STATUS:"*":DR.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS
RETURN

*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DR.ARRAY>
*** <desc>Form drawings array</desc>
FORM.DR.ARRAY:
*------------
    DR.ARRAY<-1> = ISS.BANK.REF:"*":TYPE.OF.LC:"*":TRANS.REF:"*":APPLICANT:"*":DOC.STATUS:"*":DR.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS

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
*** <desc>Fetch LC pay type</desc>
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
*** <region name= GET.DOC.STATUS>
*** <desc>Check document status</desc>
GET.DOC.STATUS:
***************
    BEGIN CASE
        CASE R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawingType> OR R.DR.LIVE.REC<LC.Contract.Drawings.TfDrDrawingType> EQ 'DC' ;*For draw type DC, display clean or discrepant based on Con discrepancy
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
*** <region name= GET.DR.DATE>
*** <desc>Get drawings maturity date and value date</desc>
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
*** <region name= GET.UNAUTH.DR.DATE>
*** <desc>Get drawings maturity date and value date</desc>
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
*** <region name= READ.UNAUTH.DRAW>
*** <desc>To read drawings in INAU</desc>
READ.UNAUTH.DRAW:
*---------------
    R.DR.UNAUTH.REC = '' ;*Initialising record variable
    DR.UNAUTH.ERR = '' ;*Initialising error variable
    R.DR.UNAUTH.REC = LC.Contract.Drawings.ReadNau(DR.ID,DR.UNAUTH.ERR) ;*Read Unauthorised drawing record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.COLLECTION>
*** <desc>To check collection</desc>
CHECK.COLLECTION:
*---------------

    IF R.LC.TYPES<LC.Config.Types.TypDocCollection> NE 'YES' AND R.LC.TYPES<LC.Config.Types.TypCleanCollection> NE 'YES' AND R.LC.TYPES<LC.Config.Types.TypCleanCredit> NE 'YES' THEN
        LC.FLAG = 1
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Reset variables</desc>
RESET.VARIABLES:
*--------------
    BENEFICIARY.CUSTNO = ''
    ISS.BANK.REF = ''
    TYPE.OF.LC.CODE = ''
    APPLICANT = ''
    EVENT.STATUS = ''
    TYPE.OF.LC = ''
    DOC.STATUS = ''
    DR.DATE = ''
    RECENT.TRANS = ''
    LC.FLAG = ''
    CON.DISCREPANT = ''
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.EB.EXTERNAL.USER>
*** <desc>To read external user record</desc>
CHECK.EB.EXTERNAL.USER:
*---------------------
    DR.INPUT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrInputter>
    EB.EXT.USER.ID = FIELD(DR.INPUT,'_',2) ;*Get Inputter value from Inputter field
    GOSUB READ.EB.EXTERNAL.USER ;*Read EB External User
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>To read external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = ''
    EB.EXT.USER.ERR = ''
    R.EB.EXTERNAL.USER = EB.ARC.tableExternalUser(EB.EXT.USER.ID,EB.EXT.USER.ERR) ;*Read EB External User record based on inputter field value
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
