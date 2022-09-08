* @ValidationCode : MjoxMDI3NDk1NzgxOkNwMTI1MjoxNTY1NzkwMDYwNTQ0OnNtdWdlc2g6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0OjIyODoyMTg=
* @ValidationInfo : Timestamp         : 14 Aug 2019 19:11:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 218/228 (95.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>289</Rating>
*-----------------------------------------------------------------------------
$PACKAGE MD.Channels

SUBROUTINE E.NOFILE.TC.GTISS.AMD.DASHBOARD(RET.DATA)

*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of guarantee amendment records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.GTISS.AMD.DASHBOARD using the Standard selection NOFILE.TC.GTISS.AMD.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Issued guarantee amendment record details such as Transaction reference, TypeOfMD, Beneficiary, Maturity date,
*                      Currency, Amount, Amendment event status, Application name, Record status, Recent Trans, MDReference,
*                      MDReferenceUnauth, MD Transaction reference, MDIB id and New Amend flag(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Guarantees
*
* 13/07/2019  - Enhancement 2875478 / Task 3255847
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.MD.DEAL
    $INSERT I_DAS.MD.IB.REQUEST

    $USING MD.Channels
    $USING EB.SystemTables
    $USING ST.Config
    $USING ST.Customer
    $USING MD.Contract
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.ARC
    $USING EB.Browser
    $USING EB.ErrorProcessing
    $USING EB.Reports

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FETCH.CIB.LISTS ;*Get MD IB Request Amendment lists

    FINAL.ARRAY = MDIB.AMD.ARRAY
    RET.DATA = FINAL.ARRAY ;*Pass Final Array value to Ret Data
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------
    SEL.LIVE.MDIB.LIST = '';SEL.LIVE.MD.AMD.LIST = '';SEL.UNAUTH.MDIB.LIST = '';MDIB.POS = '';MD.AMD.POS = '';CIB.CUSTOMER = '' ;*Initialising the variables
    GOSUB RESET.VARIABLES
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
    GOSUB MDIB.AMD.UNAUTH.LISTS  ;*Get Pending Authorisation lists
    GOSUB MDIB.AMD.LIVE.LISTS ;*Get Pend Bank Approval,Approved and Rejected records from MD IB Request(Amendment) Live lists

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.AMD.LIVE.LISTS
*** <desc>To read amendment live records</desc>
MDIB.AMD.LIVE.LISTS:
*------------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    TABLE.NAME = "MD.IB.REQUEST"
    THE.LIST = dasMdIbRequestAmdLive  ;*Select MD IB Request based on Customer (Corporate Customer) and IB.AMEND.STATUS will contain value
    THE.ARGS<1> = CIB.CUSTOMER
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.MDIB.LIST<-1> = THE.LIST

    THE.LIST = ''
    THE.ARGS = ''
    TABLE.NAME = "MD.DEAL"
    THE.LIST = dasMdDealCibAmdLive  ;*Select MD Deal - Non Cib Initiated MD Amendments for Cib Customer based on AMENDMENT.NO and CUSTOMER fields
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = "CA"
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.MD.AMD.LIST<-1> = THE.LIST
    GOSUB FORM.MDIB.LISTS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.AMD.UNAUTH.LISTS>
*** <desc>Select amendment records in INAU</desc>
MDIB.AMD.UNAUTH.LISTS:
*--------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasMdIbRequestAmdNau ;*Select MD IB Request based on Customer and Amendment Details
    THE.ARGS<1> = CIB.CUSTOMER
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.MDIB.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE MDIB.ID FROM SEL.UNAUTH.MDIB.LIST SETTING MDIB.POS
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.UNAUTH.MDIB ;*Read Unauth MD IB Request
        MD.ID = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*MD Reference
        GOSUB READ.MD
        GOSUB CHECK.EB.EXTERNAL.USER ;*Get Inputter value and read EB External User
        IF R.EB.EXTERNAL.USER AND R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestRecordStatus>[2,2] EQ 'NA' THEN
            GOSUB GET.TRANS.REF ;*Alternate Id or MD Id from MD Deal
            CATEG.CODE = R.MD.LIVE.REC<MD.Contract.Deal.DeaCategory> ;*Category from MD Deal
            GOSUB GET.TYPE.OF.MD
            GOSUB GET.BENEFICIARY
            MATURITY.DATE = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestNewExpiryDate>  ;*New Expiry date from MDIB
            CURRENCY = R.MD.LIVE.REC<MD.Contract.Deal.DeaCurrency> ;*Currency from MD Deal
            AMOUNT = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestPrinMovement> ;*Movement amount from MDIB
            AMD.EVENT.STATUS = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus> ;*Amend Status from MDIB
            IF NOT(AMD.EVENT.STATUS) THEN
                AMD.EVENT.STATUS = "With Customer" ;*Event status is populated as "With Customer" for front end filter
                NEW.AMEND = "YES"  ;*For first time input screen, setting NEW.AMEND Flag as "YES" for front end drilldown
            END
            MD.TRANS.REF = MD.ID
            APPL.NAME = "MD IB Request"
            REC.STATUS = "Unauth"
            GOSUB FORM.MDIB.UNAUTH.ARRAY
        END
        GOSUB RESET.VARIABLES
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.LISTS>
*** <desc>Fetches List of  LIVE records</desc>
FORM.MDIB.LISTS:
*--------------
    LOOP
        REMOVE MDIB.ID FROM SEL.LIVE.MDIB.LIST SETTING MDIB.POS
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.MDIB ;*Read MD IB Request
        TRANS.REF = MDIB.ID
        GOSUB READ.UNAUTH.MDIB
        GOSUB CHECK.EB.EXTERNAL.USER  ;*Get Inputter value and read EB External User
        IF R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus> NE 'With Customer' AND R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestAuthoriser> AND NOT(R.EB.EXTERNAL.USER) THEN  ;*With Customer should not get listed
            MD.ID = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Corresponding MD Deal Id is stored in this field.
            AMD.EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus>
            IF MD.ID THEN
                GOSUB READ.MD
                GOSUB READ.UNAUTH.MD
            END
            IF R.MD.LIVE.REC AND MD.ID AND AMD.EVENT.STATUS EQ 'Approved' AND NOT(R.MD.UNAUTH.REC) THEN
                GOSUB GET.MD.AMD.DETAILS ;*Get values from MD Deal record when amendment request is approved and corresponding MD Deal is authorised by Bank User
                GOSUB FORM.MDIB.OR.MD.ARRAY
            END ELSE
                GOSUB GET.TRANS.REF
                CATEG.CODE = R.MD.LIVE.REC<MD.Contract.Deal.DeaCategory> ;*Category code from MD Deal
                GOSUB GET.TYPE.OF.MD
                GOSUB GET.BENEFICIARY
                MATURITY.DATE = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestNewExpiryDate>  ;*New Expiry date from MDIB
                CURRENCY = R.MD.LIVE.REC<MD.Contract.Deal.DeaCurrency> ;*Currency from MD Deal
                AMOUNT = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestPrinMovement> ;*Movement amount from MDIB
                AMD.EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus>
                IF AMD.EVENT.STATUS EQ 'Approved' THEN ;*When Event Status is approved and MD is in IHLD/INAU then populate text in MD.REFERENCE for front end approved page
                    MD.REF.UNAUTH = "YES"
                END
                APPL.NAME = "MD IB Request"
                DEAL.DATE.TIME = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestDateTime,1>[1,6]
                GOSUB GET.RECENT.TRANS
                IF NOT(AMD.EVENT.STATUS) THEN ;*For Non CIB LC's, IB Event status field will not contain any value, hence default as Approved in enquiry output
                    AMD.EVENT.STATUS = "Approved"
                END
                MD.TRANS.REF = MD.ID
                REC.STATUS = "Live"
                GOSUB FORM.MDIB.OR.MD.ARRAY ;*Form an array for With Bank,Approved and Rejected.For Approved records, form an MD Array instead of MD IB Request
            END
        END
        GOSUB RESET.VARIABLES
    REPEAT
    GOSUB GET.NON.CIB.MD.AMD
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.NON.CIB.MD.AMD>
*** <desc>Fetch non CIB customer amendment records</desc>
GET.NON.CIB.MD.AMD:
*-----------------
    LOOP
        REMOVE MD.ID FROM SEL.LIVE.MD.AMD.LIST SETTING MD.AMD.POS
    WHILE MD.ID:MD.AMD.POS
        GOSUB READ.MD
        GOSUB GET.MD.AMD.DETAILS
        IF NOT(AMD.EVENT.STATUS) THEN  ;*When Event status does not contain any value, then this MD can be referred as Non CIB MD
            GOSUB FORM.MDIB.OR.MD.ARRAY
            GOSUB RESET.VARIABLES
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MD.AMD.DETAILS>
*** <desc>Get MD amendment details</desc>
GET.MD.AMD.DETAILS:
*-----------------
    GOSUB GET.TRANS.REF
    CATEG.CODE = R.MD.LIVE.REC<MD.Contract.Deal.DeaCategory>
    GOSUB GET.TYPE.OF.MD
    GOSUB GET.BENEFICIARY
    MATURITY.DATE = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestNewExpiryDate>  ;*New Expiry date from MD.IB.REQUEST
    CURRENCY = R.MD.LIVE.REC<MD.Contract.Deal.DeaCurrency>
    AMOUNT = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestPrinMovement>  ;*Movement amount from MD.IB.REQUEST
    APPL.NAME = "MD Deal"
    DEAL.DATE.TIME = R.MD.LIVE.REC<MD.Contract.Deal.DeaDateTime,1>[1,6]
    MDIB.ID = R.MD.LIVE.REC<MD.Contract.Deal.DeaIbRequestId>
    IF MDIB.ID THEN
        GOSUB READ.MDIB
        AMD.EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus>  ;*When Event Status contains value, already this MD details will be available in the enquiry output
    END
    MD.REFERENCE = MD.ID
    MD.TRANS.REF = MD.ID
    REC.STATUS = "Live"
    GOSUB GET.RECENT.TRANS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.RECENT.TRANS>
*** <desc>Get recent transaction details</desc>
GET.RECENT.TRANS:
*---------------
    GET.DATE = EB.SystemTables.getToday()
    EB.API.Cdt('',GET.DATE,"-2C")
    GET.DATE = GET.DATE[3,6]
    IF (DEAL.DATE.TIME GE GET.DATE AND DEAL.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND AMD.EVENT.STATUS THEN
        RECENT.TRANS = AMD.EVENT.STATUS : "2D"
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.UNAUTH.ARRAY>
*** <desc>Form unathorised IB request array</desc>
FORM.MDIB.UNAUTH.ARRAY:
*---------------------
    MDIB.AMD.ARRAY<-1> := TRANS.REF:"*":TYPE.OF.MD:"*":BENEFICIARY:"*":MATURITY.DATE:"*":CURRENCY:"*":AMOUNT:"*":AMD.EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":"":"*":"":"*":"":"*":MD.TRANS.REF:"*":MDIB.ID:"*":NEW.AMEND
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.OR.MD.ARRAY>
*** <desc>Form authorised IB request array</desc>
FORM.MDIB.OR.MD.ARRAY:
*--------------------
    IF NOT(AMD.EVENT.STATUS) THEN ;*For Non CIB MD Deals, IB status field will not contain any value, hence default as Approved in enquiry output
        AMD.EVENT.STATUS = "Approved"
    END
    MDIB.AMD.ARRAY<-1> = TRANS.REF:"*":TYPE.OF.MD:"*":BENEFICIARY:"*":MATURITY.DATE:"*":CURRENCY:"*":AMOUNT:"*":AMD.EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS:"*":MD.REFERENCE:"*":MD.REF.UNAUTH:"*":MD.TRANS.REF:"*":MDIB.ID
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MDIB>
*** <desc>To read MD.IB.REQUEST record</desc>
READ.MDIB:
*--------
    R.MDIB.LIVE.REC = '' ;*Initialising record variable
    MDIB.LIVE.REC.ERR = '' ;*Initialising error variable
    R.MDIB.LIVE.REC = MD.Contract.IbRequest.Read(MDIB.ID, MDIB.LIVE.REC.ERR) ;*Read Live MD IB Request

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.MDIB>
*** <desc>To read records in INAU</desc>
READ.UNAUTH.MDIB:
*---------------
    R.MDIB.UNAUTH.REC = '' ;*Initialising record variable
    MDIB.UNAUTH.REC.ERR = '' ;*Initialising error variable
    R.MDIB.UNAUTH.REC = MD.Contract.IbRequest.ReadNau(MDIB.ID, MDIB.UNAUTH.REC.ERR) ;*Read Nau MD IB Request

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MD>
*** <desc>To read MD record</desc>
READ.MD:
*------
    R.MD.LIVE.REC = '' ;*Initialising record variable
    MD.LIVE.REC.ERR = '' ;*Initialising error variable
    R.MD.LIVE.REC = MD.Contract.Deal.Read(MD.ID, MD.LIVE.REC.ERR) ;*Read Live MD Deal record

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.MD>
*** <desc>To read MD Nau record</desc>
READ.UNAUTH.MD:
*-------------
    R.MD.UNAUTH.REC = '' ;*Initialising record variable
    MD.UNAUTH.REC.ERR = '' ;*Initialising error variable
    R.MD.UNAUTH.REC = MD.Contract.Deal.ReadNau(MD.ID, MD.UNAUTH.REC.ERR) ;*Read Nau MD Deal

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TYPE.OF.MD>
*** <desc>Fetch MD category</desc>
GET.TYPE.OF.MD:
*-------------
    R.CATEGORY = '' ;*Initialising record variable
    CATEG.ERR = '' ;*Initialising error variable
    R.CATEGORY = ST.Config.tableCategory(CATEG.CODE,CATEG.ERR)
    TYPE.OF.MD = R.CATEGORY<ST.Config.Category.EbCatDescription>

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TRANS.REF>
*** <desc>Fetch guarantee record ID</desc>
GET.TRANS.REF:
*------------
    IF R.MD.LIVE.REC<MD.Contract.Deal.DeaAlternateId> THEN
        TRANS.REF = R.MD.LIVE.REC<MD.Contract.Deal.DeaAlternateId> ;*Display Alternate Id if it is available, else display MD Reference
    END ELSE
        TRANS.REF = MD.ID
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.BENEFICIARY>
*** <desc>Fetch beneficiary details</desc>
GET.BENEFICIARY:
*--------------
    IF R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> THEN
        BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> ;*Benef Cust no from MD Deal
        R.CUSTOMER = ''
        CUST.ERR = ''
        R.CUSTOMER = ST.Customer.tableCustomer(BENEFICIARY,CUST.ERR)
        IF R.CUSTOMER THEN
            BENEFICIARY = R.CUSTOMER<ST.Customer.Customer.EbCusNameOne>
        END
    END ELSE
        IF R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress> THEN ;*Ben Address from MD Deal
            BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress,1>
        END
    END

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.EB.EXTERNAL.USER>
*** <desc>Extracts the external user id from the Inputter field of the record</desc>
CHECK.EB.EXTERNAL.USER:
*---------------------

    MDIB.INPUTTER = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestInputter>
    EB.EXT.USER.ID = FIELD(MDIB.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
    GOSUB READ.EB.EXTERNAL.USER ;*Read EB External User
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>Reads external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = ''
    EB.EXT.USER.REC.ERR = ''
    R.EB.EXTERNAL.USER = EB.ARC.tableExternalUser(EB.EXT.USER.ID,EB.EXT.USER.REC.ERR)

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>To reset variables</desc>
RESET.VARIABLES:
*--------------
    RECENT.TRANS = ''
    AMD.EVENT.STATUS = ''
    BENEFICIARY = ''
    TYPE.OF.MD = ''
    MATURITY.DATE = ''
    CURRENCY = ''
    AMOUNT = ''
    TRANS.REF = ''
    NEW.AMEND = ''
    MD.REF.UNAUTH = ''
    R.MD.LIVE.REC = ''
    R.MD.UNAUTH.REC = ''
    MD.TRANS.REF = ''
    MD.REFERENCE = ''
    MDIB.ID = ''
    MD.ID = ''
    DEAL.DATE.TIME = ''
    R.MDIB.UNAUTH.REC = ''
    R.MDIB.LIVE.REC = ''
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
