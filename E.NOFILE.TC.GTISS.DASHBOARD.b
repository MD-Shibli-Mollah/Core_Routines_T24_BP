* @ValidationCode : Mjo2NTA1NjMyNDI6Q3AxMjUyOjE1NjU3OTAwNjAxMzA6c211Z2VzaDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNTMxLTAzMTQ6MjIwOjIxOA==
* @ValidationInfo : Timestamp         : 14 Aug 2019 19:11:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 218/220 (99.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>328</Rating>
*-----------------------------------------------------------------------------
$PACKAGE MD.Channels

SUBROUTINE E.NOFILE.TC.GTISS.DASHBOARD(RET.DATA)

*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of guarantee records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.GTISS.DASHBOARD using the Standard selection NOFILE.TC.GTISS.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Issued guarantee record details such as Transaction reference, TypeOfMDIB, Beneficiary, Maturity date,
*                      Currency, Amount, Event status, Application name, Record status, Recent Trans, MDReference,
*                      MDReferenceUnauth, MDIB reference, Amendment status(RET.DATA)
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
    GOSUB FETCH.CIB.LISTS ;*Get MD IB Request lists

    FINAL.ARRAY = MDIB.ARRAY
    RET.DATA = FINAL.ARRAY ;*Pass Final Array value to Ret Data
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine </desc>
INITIALISE:
*---------
    CIB.CUSTOMER = ''
    MDIB.ARRAY = ''
    FINAL.ARRAY = ''
    RET.DATA = ''
    SEL.LIVE.MDIB.LIST = ''
    SEL.LIVE.MDS.LIST = ''
    SEL.UNAUTH.MDIB.LIST = ''
    GOSUB RESET.VARIABLES
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>Fetches List of guarantee records</desc>
FETCH.CIB.LISTS:
*--------------

    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    GOSUB MDIB.LIVE.LISTS  ;*Get Pend Bank Approval,Approved and Rejected records from MD IB Request Live lists
    GOSUB MDIB.UNAUTH.LISTS ;*Get Pending Authorisation lists
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.LIVE.LISTS>
*** <desc>Selects List of guarantee LIVE records</desc>
MDIB.LIVE.LISTS:
*--------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    TABLE.NAME = "MD.IB.REQUEST"
    THE.LIST = dasMdIbRequestLive  ;*Select MD IB Request
    THE.ARGS<1> = CIB.CUSTOMER
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.MDIB.LIST<-1> = THE.LIST

    THE.LIST = ''
    THE.ARGS = ''
    TABLE.NAME = "MD.DEAL"
    THE.LIST = dasMdDealCibLive  ;*Select MD Deal - Non Cib Initiated MD Deals for Cib Customer
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = "CA"
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.MDS.LIST<-1> = THE.LIST
    GOSUB FORM.MDIB.LISTS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.UNAUTH.LISTS>
*** <desc>Fetches List of guarantee unauthorised records</desc>
MDIB.UNAUTH.LISTS:
*----------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasMdIbRequestNau ;*Select unauthorised MD IB Requests based on Customer
    THE.ARGS<1> = CIB.CUSTOMER
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS based on THE.ARGS
    SEL.UNAUTH.MDIB.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE MDIB.ID FROM SEL.UNAUTH.MDIB.LIST SETTING MDIB.POS
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.UNAUTH.MDIB ;*Read Unauthorised MD IB Request
        GOSUB CHECK.EB.EXTERNAL.USER
        IF R.EB.EXTERNAL.USER AND R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestRecordStatus>[2,2] EQ 'NA' AND NOT(R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestAmendmentDetails>) THEN
            TRANS.REF = MDIB.ID  ;*MD IB Request Id
            GTEE.REFERENCE = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestClientReference> ;*Client Reference in MD IB Request
            CATEG.CODE = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestCategory> ;*Category Code
            GOSUB GET.TYPE.OF.MD ;*Get Description of Category
            BENEFICIARY = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> ;*Beneficiary
            MATURITY.DATE = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMaturityDate> ;*Maturity Date
            CURRENCY = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestCurrency> ;*Currency
            AMOUNT = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount> ;*Amount
            EVENT.STATUS = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestIbEventStatus> ;*Ib Event Status
            IF NOT(EVENT.STATUS) THEN
                EVENT.STATUS = "With Customer"
            END
            APPL.NAME = "MD IB Request"
            REC.STATUS = "Unauth"
            GOSUB FORM.MDIB.UNAUTH.ARRAY ;*Form Pend Auth Array
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.LISTS>
*** <desc>Fetches List of guarantee LIVE records</desc>
FORM.MDIB.LISTS:
*--------------
    LOOP
        REMOVE MDIB.ID FROM SEL.LIVE.MDIB.LIST SETTING MDIB.POS
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.MDIB ;*Read MD IB Request
        TRANS.REF = MDIB.ID
        GOSUB READ.UNAUTH.MDIB
        GOSUB CHECK.EB.EXTERNAL.USER
        IF R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbEventStatus> NE 'With Customer' AND R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestAuthoriser> AND NOT(R.EB.EXTERNAL.USER) THEN  ;*With Customer should not get listed
            MD.ID = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Corresponding MD Deal Id is stored in this field.
            EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbEventStatus>
            IF MD.ID THEN
                GOSUB READ.MD ;*Read MD
            END
            IF R.MD.LIVE.REC AND MD.ID AND EVENT.STATUS EQ 'Approved' THEN
                GOSUB GET.MD.DETAILS ;*When Event Status is approved and MD record is in Live, get details of MD
                GOSUB FORM.MDIB.OR.MD.ARRAY ;*Form an array with MD Details instead of MD IB Details
            END ELSE
                TRANS.REF = MDIB.ID  ;*MD IB Request Id
                GTEE.REFERENCE = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestClientReference> ;*Client Reference in MD IB Request
                CATEG.CODE = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestCategory>
                GOSUB GET.TYPE.OF.MD
                BENEFICIARY = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1>
                MATURITY.DATE = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestMaturityDate>
                CURRENCY = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestCurrency>
                AMOUNT = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount>
                EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbEventStatus>
                IF EVENT.STATUS EQ 'Approved' THEN ;*When Event Status is approved and MD is in IHLD/INAU then populate text in MD.REFERENCE for front end approved page
                    MD.REF.UNAUTH = "YES"
                END
                APPL.NAME = "MD IB Request"
                DEAL.DATE.TIME = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestDateTime,1>[1,6]
                GOSUB GET.RECENT.TRANS
                IF NOT(EVENT.STATUS) THEN ;*For Non CIB LC's, IB Event status field will not contain any value, hence default as Approved in enquiry output
                    EVENT.STATUS = "Approved"
                END
                REC.STATUS = "Live"
                GOSUB FORM.MDIB.OR.MD.ARRAY ;*Form an array for With Bank,Approved and Rejected.For Approved records, form an MD Array instead of MD IB Request
            END
        END
        GOSUB RESET.VARIABLES
    REPEAT
    GOSUB GET.NON.CIB.MDS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.NON.CIB.MDS>
*** <desc>Fetches List of Non CIB guarantee LIVE records</desc>
GET.NON.CIB.MDS:
*--------------
    LOOP
        REMOVE MD.ID FROM SEL.LIVE.MDS.LIST SETTING MD.POS
    WHILE MD.ID:MD.POS
        GOSUB READ.MD
        GOSUB GET.MD.DETAILS
        IF NOT(MDIB.EVENT.STATUS) THEN  ;*When Event status does not contain any value, then this MD can be referred as Non CIB MD
            EVENT.STATUS = "Approved"
            GOSUB FORM.MDIB.OR.MD.ARRAY
        END
        GOSUB RESET.VARIABLES
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MD.DETAILS>
*** <desc>Fetches guarantee LIVE record details</desc>
GET.MD.DETAILS:
*-------------
    GOSUB GET.TRANS.REF
    GTEE.REFERENCE = R.MD.LIVE.REC<MD.Contract.Deal.DeaReference2> ;*Client Reference in MD IB Request
    CATEG.CODE = R.MD.LIVE.REC<MD.Contract.Deal.DeaCategory>
    GOSUB GET.TYPE.OF.MD
    IF R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> THEN
        BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> ;*Benef Cust no from MD Deal
        R.CUSTOMER = ''
        CUST.ERR = ''
        R.CUSTOMER = ST.Customer.tableCustomer(BENEFICIARY,CUST.ERR)
        IF R.CUSTOMER THEN
            BENEFICIARY = R.CUSTOMER<ST.Customer.Customer.EbCusNameOne>
        END
    END ELSE
        IF R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress> THEN;*Ben Address from MD Deal
            BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress,1>
        END
    END
    MATURITY.DATE = R.MD.LIVE.REC<MD.Contract.Deal.DeaAdviceExpiryDate> ;*Advice Expiry date
    CURRENCY = R.MD.LIVE.REC<MD.Contract.Deal.DeaCurrency> ;*Currency
    AMOUNT = R.MD.LIVE.REC<MD.Contract.Deal.DeaPrincipalAmount> ;*Amount
    APPL.NAME = "MD Deal"
    DEAL.DATE.TIME = R.MD.LIVE.REC<MD.Contract.Deal.DeaDateTime,1>[1,6]
    MDIB.ID = R.MD.LIVE.REC<MD.Contract.Deal.DeaIbRequestId>
    IF MDIB.ID THEN
        GOSUB READ.MDIB
        MDIB.EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbEventStatus>  ;*When Event Status contains value, already this MD details will be available in the enquiry output
    END
    REC.STATUS = "Live"
    MD.REFERENCE = MD.ID
    AMEND.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus>
    MDIB.REF = MDIB.ID
    GOSUB GET.RECENT.TRANS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TRANS.REF>
*** <desc>Retrieve transaction reference</desc>
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
*** <region name= GET.RECENT.TRANS>
*** <desc>Retrieve recent transaction details</desc>
GET.RECENT.TRANS:
*---------------
    GET.DATE = EB.SystemTables.getToday()
    EB.API.Cdt('',GET.DATE,"-2C")
    GET.DATE = GET.DATE[3,6]
    IF (DEAL.DATE.TIME GE GET.DATE AND DEAL.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND EVENT.STATUS THEN
        RECENT.TRANS = EVENT.STATUS : "2D"
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.UNAUTH.ARRAY>
*** <desc>Build final array of unauthorised guarantee record details</desc>
FORM.MDIB.UNAUTH.ARRAY:
*---------------------
    MDIB.ARRAY<-1> := TRANS.REF:"*":TYPE.OF.MDIB:"*":BENEFICIARY:"*":MATURITY.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.OR.MD.ARRAY>
*** <desc>Build final array of guarantee LIVE record details</desc>
FORM.MDIB.OR.MD.ARRAY:
*--------------------
    MDIB.ARRAY<-1> = TRANS.REF:"*":TYPE.OF.MDIB:"*":BENEFICIARY:"*":MATURITY.DATE:"*":CURRENCY:"*":AMOUNT:"*":EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS:"*":MD.REFERENCE:"*":MD.REF.UNAUTH:"*":MDIB.REF:"*":AMEND.STATUS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MDIB>
*** <desc>Read MDIB request LIVE record</desc>
READ.MDIB:
*--------
    R.MDIB.LIVE.REC = '' ;*Initialise record variable
    MDIB.LIVE.REC.ERR = '' ;*Initialise error variable
    R.MDIB.LIVE.REC = MD.Contract.IbRequest.Read(MDIB.ID, MDIB.LIVE.REC.ERR) ;*Read Live MD IB Request

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.MDIB>
*** <desc>Read MDIB request Nau record</desc>
READ.UNAUTH.MDIB:
*---------------
    R.MDIB.UNAUTH.REC = '' ;*Initialise record variable
    MDIB.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.MDIB.UNAUTH.REC = MD.Contract.IbRequest.ReadNau(MDIB.ID, MDIB.UNAUTH.REC.ERR) ;*Read Nau MD IB Request

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MD>
*** <desc>Read MD record</desc>
READ.MD:
*------
    R.MD.LIVE.REC  = '' ;*Initialise record variable
    MD.LIVE.REC.ERR = '' ;*Initialise error variable
    R.MD.LIVE.REC = MD.Contract.Deal.Read(MD.ID, MD.LIVE.REC.ERR) ;*Read Live MD Deal record

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
    R.EB.EXTERNAL.USER  = '' ;*Initialise record variable
    EB.EXT.USER.REC.ERR  = '' ;*Initialise error variable
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(EB.EXT.USER.ID, EB.EXT.USER.REC.ERR) ;*Read EB External User record based on inputter field value

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TYPE.OF.MD>
*** <desc>Read Category record and set appropriate description, based on the category code</desc>
GET.TYPE.OF.MD:
*-------------
    R.CATEGORY = '' ;*Initialise record variable
    CATEG.ERR = '' ;*Initialise error variable
    R.CATEGORY = ST.Config.tableCategory(CATEG.CODE,CATEG.ERR)
    TYPE.OF.MDIB = R.CATEGORY<ST.Config.Category.EbCatDescription> ;*Get description from Category

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Reset variables</desc>
RESET.VARIABLES:
*--------------
    TRANS.REF = ''
    GTEE.REFERENCE = ''
    CATEG.CODE = ''
    BENEFICIARY = ''
    MATURITY.DATE = ''
    EVENT.STATUS = ''
    MD.ID = ''
    MDIB.REF = ''
    AMEND.STATUS = ''
    MD.REFERENCE = ''
    RECENT.TRANS = ''
    DEAL.DATE.TIME = ''
    MDIB.EVENT.STATUS = ''
    TYPE.OF.MDIB = ''
    MD.REF.UNAUTH = ''
    R.MDIB.LIVE.REC = ''
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
