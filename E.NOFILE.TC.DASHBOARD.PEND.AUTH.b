* @ValidationCode : Mjo0Nzc1OTQ0Mzc6Q3AxMjUyOjE1NjQ0MDYyOTU4OTY6c211Z2VzaDo5OjE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNTMxLTAzMTQ6MzY0OjI2Nw==
* @ValidationInfo : Timestamp         : 29 Jul 2019 18:48:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 1
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 267/364 (73.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-118</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.DASHBOARD.PEND.AUTH(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches unauthorised records from LC and MD applications
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.DASHBOARD.PEND.AUTH using the Standard selection NOFILE.TC.DASHBOARD.PEND.AUTH
* IN Parameters      : NIL
* Out Parameters     : An Array of unauthorised record details such as Product,Date time,Counterparty,Bank reference, Customer reference,Currency,
*                      Amount,Bank To Customer Info and MD Transaction reference,Application name(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*
* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Insert files</desc>

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LC.TYPES
    $INSERT I_DAS.DRAWINGS
    $INSERT I_DAS.MD.IB.REQUEST
    $INSERT I_DAS.MD.DEAL

    $USING LC.Channels
    $USING LC.Contract
    $USING LC.Config
    $USING LC.ModelBank
    $USING ST.Customer
    $USING MD.Contract
    $USING EB.DataAccess
    $USING EB.ARC
    $USING EB.Browser
    $USING EB.Reports
    $USING EB.ErrorProcessing

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main Processing</desc>
    
    GOSUB INITIALISE
    GOSUB FETCH.CIB.PEND.AUTH.LISTS ;*Get the lists of unauthorised records which are inputted by External User and kept it in INAU

    RET.DATA = FINAL.ARRAY ;*Pass Final Array to RET DATA

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------

    GOSUB RESET.VARIABLES ;*Initialising the variables

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised records from LC and MD applications</desc>
FETCH.CIB.PEND.AUTH.LISTS:
*------------------------
    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END

    GOSUB IMPORT.LC.PEND.AUTH.LISTS ;*Form Import LC Pending Authorisation lists
    GOSUB IMPORT.LCAMD.PEND.AUTH.LISTS ;*Form Import LC Amendment Pending Authorisation lists
    GOSUB DRAWINGS.PEND.AUTH.LISTS ;*Form Import and Export Drawings Pending Authorisation lists
    GOSUB MD.GTISS.PEND.AUTH.LISTS ;*Form Guarantee Issuance Pending Authorisation lists
    GOSUB MD.GTAMD.PEND.AUTH.LISTS ;*Form Guarantee Amendment Pending Authorisation lists
    GOSUB MD.INV.PEND.AUTH.LISTS ;*Form Guarantee Invocation Pending Authorisation lists

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= IMPORT.LC.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised LC records</desc>
IMPORT.LC.PEND.AUTH.LISTS:
*------------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasLetterOfCreditCIbNau ;*Select unauthorised LC's based on Applicant Custno
    THE.ARGS<1> = CIB.CUSTOMER ;*Applicant Custno
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch list of LC records
    SEL.UNAUTH.LC.LIST<1,-1> = THE.LIST

    THE.LIST = ''
    THE.LIST = dasLetterOfCreditListWithBen ;*Select unauthorised LC's based on Beneficiary Custno
    THE.ARGS<1> = CIB.CUSTOMER ;*Beneficiary Custno
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch list of LC records
    SEL.UNAUTH.LC.LIST<1,-1> = THE.LIST

    LOOP
        REMOVE LC.ID FROM SEL.UNAUTH.LC.LIST SETTING LC.POS ;*Remove each LC id and iterate with it
    WHILE LC.ID:LC.POS
        IF LC.ID NE '' THEN ;*Check if LC id is not blank
            R.LC.UNAUTH.REC = '' ;*Initialise record variable
            LC.UNAUTH.REC.ERR = '' ;*Initialise error variable
            R.LC.UNAUTH.REC = LC.Contract.LetterOfCredit.ReadNau(LC.ID,LC.UNAUTH.REC.ERR) ;*Read Nau LC record
            LC.INPUTTER = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcInputter>
            EB.EXT.USER.ID = FIELD(LC.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
            GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
            IF R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcRecordStatus>[2,2] EQ 'NA' AND R.EB.EXTERNAL.USER THEN ;*Form an array if record is inputted by External User and kept in INAU
                TYPE.OF.LC.CODE =R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcLcType> ;*Extract and set LC type
                LC.ModelBank.LcCheckCollection(TYPE.OF.LC.CODE,INWARD.COLL,OUTWARD.COLL) ;*Call api check if the selected record is a collection
                GOSUB GET.PRODUCT ;*Get product details
                TRANS.REF = LC.ID ;*Extract and set LC Reference
                GET.DATE.TIME = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcDateTime> ;*Extract and set Date Time field
                GET.TIME = GET.DATE.TIME[7,4]
                IF GET.DATE.TIME THEN
                    GOSUB CONVERT.DATE ;*Convert T24 date for display
                END
                BANK.REF = LC.ID ;*Extract and set Bank reference
                CURRENCY = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Extract and set Currency
                AMOUNT = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcLcAmount> ;*Extract and set Amount
                BANK.TO.CUST.INFO = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcIbReason,1,1> ;*Extract and set BankToCustomerInfo
                APPL.NAME = "Letter of Credit"
                REC.STATUS = "Unauth"
                GOSUB FORM.PEND.AUTH.ARRAY ;*Append unauthorised LC records to final array
                GOSUB RESET.VARIABLES ;*Reset variables
            END
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= IMPORT.LCAMD.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised LC amendment records</desc>
IMPORT.LCAMD.PEND.AUTH.LISTS:
*---------------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.ARGS = ''
    THE.LIST = EB.DataAccess.DasAllIds ;*Select all Unauthorised LC Amendments
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to list of LC amendment records
    SEL.UNAUTH.LCAMD.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM  SEL.UNAUTH.LCAMD.LIST SETTING LCAMD.UANUTH.POS ;*Remove each LC amendment id and iterate with it
    WHILE LC.AMD.ID:LCAMD.UANUTH.POS
        R.LC.AMD.UNAUTH.REC = '' ;*Initialise record variable
        LC.AMD.UNAUTH.ERR = '' ;*Initialise error variable
        R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.UNAUTH.ERR) ;*Read unauthorised LC Amendment record
        LC.AMD.INPUT = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdInputter>
        EB.EXT.USER.ID = FIELD(LC.AMD.INPUT,'_',2) ;*Get Inputter value from Inputter field
        GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
        LC.ID = LC.AMD.ID[1,12]
        GOSUB READ.LC ;*Read LC record
        APPLICANT.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno>
        IF R.EB.EXTERNAL.USER AND R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdRecordStatus>[2,2] EQ 'NA' THEN ;*Form an array if record is inputted by External User and kept in INAU
            IF APPLICANT.CUSTNO EQ CIB.CUSTOMER THEN
                PRODUCT = "Import LC Amendment"
                COUNTERPARTY = R.LC.LIVE.REC<R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Counterparty
                CUSTOMER.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Customer Reference of LC
            END ELSE
                PRODUCT = "Export LC Amendment"
                COUNTERPARTY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Counterparty
                CUSTOMER.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcExternalReference> ;*External Reference of LC
            END
            GET.DATE.TIME = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdDateTime> ;*Date
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert T24 date for display
            END
            BANK.REF = LC.AMD.ID ;*Extract and set Bank reference
            CURRENCY = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdLcCurrency> ;*Extract and set Currency
            AMOUNT = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Extract and set Amount
            BANK.TO.CUST.INFO = R.LC.AMD.UNAUTH.REC<LC.Contract.Amendments.AmdIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
            APPL.NAME = "Amendment"
            REC.STATUS = "Unauth"
            GOSUB FORM.PEND.AUTH.ARRAY ;*Append list of LC amendment records to final array
            GOSUB RESET.VARIABLES ;*Reset variables
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= DRAWINGS.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised drawing records</desc>
DRAWINGS.PEND.AUTH.LISTS:
*-----------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.ARGS = ''
    THE.LIST = EB.DataAccess.DasAllIds ;*Select all unauthorised drawings
    EB.DataAccess.Das("DRAWINGS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.DR.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE DR.ID FROM  SEL.UNAUTH.DR.LIST SETTING DR.UANUTH.POS ;*Remove each drawing id and iterate with it
    WHILE DR.ID:DR.UANUTH.POS
        IF DR.ID NE '' THEN ;*Check if drawing id is not blank
            R.DR.UNAUTH.REC = '' ;*Initialising record variable
            DR.UNAUTH.ERR = '' ;*Initialising error variable
            R.DR.UNAUTH.REC = LC.Contract.Drawings.ReadNau(DR.ID,DR.UNAUTH.ERR) ;*Read Unauthorised drawing record
            DR.INPUT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrInputter>
            EB.EXT.USER.ID = FIELD(DR.INPUT,'_',2) ;*Get Inputter value from Inputter field
            GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
            TRANS.REF = DR.ID
            LC.ID = DR.ID[1,12] ;*Get LC Reference from Drawings Id
            GOSUB READ.LC ;*Read LC record
            IF R.EB.EXTERNAL.USER AND R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrRecordStatus>[2,2] EQ 'NA' THEN ;*Form an array if record is inputted by External User and kept in INAU
                LC.TYPE = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcLcType>
                GOSUB READ.LC.TYPES ;*Read LC Types to check if LC is Import or Export
                CHECK.IMP.EXP = R.LC.TYPES<LC.Config.Types.TypImportExport>
                GOSUB GET.IMP.EXP.VALUES ;*Get Import or Export drawing specific values
                IF APPLICANT.CUSTNO EQ CIB.CUSTOMER OR BENEFICIARY.CUSTNO EQ CIB.CUSTOMER THEN ;*Import - Applicant should be a CIB Customer and for Export - Beneficiary should be a CIB Customer
                    GET.DATE.TIME = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDateTime> ;*Extract and set Date and Time
                    GET.TIME = GET.DATE.TIME[7,4]
                    IF GET.DATE.TIME THEN
                        GOSUB CONVERT.DATE ;*Convert T24 date for display
                    END
                    BANK.REF = DR.ID ;*Extract and set Bank reference
                    CURRENCY = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDrawCurrency> ;*Extract and set Currency
                    AMOUNT = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrDocumentAmount> ;*Extract and set Amount
                    BANK.TO.CUST.INFO = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
                    APPL.NAME = "Drawings"
                    REC.STATUS = "Unauth"
                    GOSUB FORM.PEND.AUTH.ARRAY ;*Append drawing records to final array
                    GOSUB RESET.VARIABLES ;*Reset variables
                END
            END
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MD.GTISS.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised issued guarantee records</desc>
MD.GTISS.PEND.AUTH.LISTS:
*-----------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasMdIbRequestNau ;*Select MD Ib Request based on Customer
    THE.ARGS<1> = CIB.CUSTOMER ;*Customer field
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS for fetching MDIB request records
    SEL.UNAUTH.MDIB.LIST<-1> = THE.LIST
    LOOP
        REMOVE MDIB.ID FROM SEL.UNAUTH.MDIB.LIST SETTING MDIB.POS ;*Remove each MDIB request id and iterate with it
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.UNAUTH.MDIB ;*Read MDIB request record
        MDIB.INPUTTER = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestInputter>
        EB.EXT.USER.ID = FIELD(MDIB.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
        GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
        IF R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestRecordStatus>[2,2] EQ 'NA' AND R.EB.EXTERNAL.USER THEN ;*Form an array if record is inputted by External User and kept in INAU
            TRANS.REF = MDIB.ID  ;*MD IB Request Id
            PRODUCT = "Guarantees"
            GET.DATE.TIME = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestDateTime> ;*Date
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert T24 date for display
            END
            COUNTERPARTY = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> ;*Extract and set Counterparty
            BANK.REF = MDIB.ID ;*Extract and set Bank reference
            CUSTOMER.REF = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestClientReference> ;*Extract and set Customer Reference
            CURRENCY = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestCurrency> ;*Extract and set Currency
            AMOUNT = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount> ;*Extract and set Amount
            BANK.TO.CUST.INFO = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
            APPL.NAME = "MD IB Request"
            REC.STATUS = "Unauth"
            GOSUB FORM.PEND.AUTH.ARRAY ;*Append MDIB request records to final array
            GOSUB RESET.VARIABLES ;*Reset variables
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MD.GTAMD.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised guarantee amendment records</desc>
MD.GTAMD.PEND.AUTH.LISTS:
*-----------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasMdIbRequestAmdNau ;*Select unauthorised amendment records of MD IB Request
    THE.ARGS<1> = CIB.CUSTOMER ;*Customer field in MDIB Request
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS for fetching MDIB request records
    SEL.UNAUTH.MDIB.AMD.LIST<-1> = THE.LIST
    LOOP
        REMOVE MDIB.ID FROM SEL.UNAUTH.MDIB.AMD.LIST SETTING MDIB.POS ;*Remove each MDIB request id and iterate with it
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.UNAUTH.MDIB ;*Read MDIB request record
        MD.ID = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Get MD Reference from MDIB Record
        GOSUB READ.MD ;*Read MD record
        MDIB.INPUTTER = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestInputter>
        EB.EXT.USER.ID = FIELD(MDIB.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
        GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
        IF R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestRecordStatus>[2,2] EQ 'NA' AND R.EB.EXTERNAL.USER THEN ;*Form an array if record is inputted by External User and kept in INAU
            PRODUCT = "Amendment to Guarantee"  ;*Guarantee Amendment Pend Auth List
            GET.DATE.TIME = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestDateTime> ;*Date
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert T24 date for display
            END
            GOSUB GET.COUNTERPARTY ;*Get Counterparty details
            BANK.REF = MDIB.ID ;*Extract and set Bank reference
            CUSTOMER.REF = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestClientReference> ;*Extract and set Customer Reference
            CURRENCY = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestCurrency> ;*Extract and set Currency
            AMOUNT = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestPrinMovement> ;*Extract and set Movement amount
            BANK.TO.CUST.INFO = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
            MD.TRANS.REF = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Extract and set MD Reference
            APPL.NAME = "MD IB Request"
            REC.STATUS = "Unauth"
            GOSUB FORM.PEND.AUTH.ARRAY ;*Append guarantee record details to final array
            GOSUB RESET.VARIABLES ;*Reset variables
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MD.INV.PEND.AUTH.LISTS>
*** <desc>Fetches list of unauthorised guarantee invocation records</desc>
MD.INV.PEND.AUTH.LISTS:
*---------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasMdIbRequestsInvWithCustomer ;*For Invocation, IB.EVENT.STATUS and Customer field can be checked since Invocation is initiated by Bank User
    THE.ARGS<1> = CIB.CUSTOMER ;*CUSTOMER
    THE.ARGS<2> = "With Customer" ;*IB.EVENT.STATUS
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS for fetching MDIB request records
    SEL.UNAUTH.MDIB.INV.LIST<-1> = THE.LIST

    THE.LIST = ''
    THE.LIST = dasMdIbRequestsGteeInwardInvNau ;*For Invocation, IB.EVENT.STATUS and Customer field can be checked since Invocation is initiated by Bank User
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = ""
    THE.ARGS<3> = ""
    THE.ARGS<4> = "With Customer"
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS for fetching MDIB request records
    SEL.UNAUTH.MDIB.INV.LIST<-1> = THE.LIST

    LOOP
        REMOVE MDIB.ID FROM SEL.UNAUTH.MDIB.INV.LIST SETTING MDIB.POS ;*Remove each MDIB request id and iterate with it
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.UNAUTH.MDIB ;*Read MDIB request record
        MD.ID = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*MD Reference
        GOSUB READ.MD ;*Read MD record
        MDIB.INPUTTER = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestInputter>
        EB.EXT.USER.ID = FIELD(MDIB.INPUTTER,'_',2)
        GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
        IF R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestRecordStatus>[2,2] EQ 'NA' AND R.EB.EXTERNAL.USER THEN ;*Form an array if record is inputted by External User and kept in INAU
            IF R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestCustomer> EQ CIB.CUSTOMER THEN
                PRODUCT = "Claim under Guarantee"  ;*Invocation Claim Guarantees Issued
            END ELSE
                PRODUCT = "Claim under Received Guarantee"  ;*Invocation Claim Guarantees Received
            END
            BANK.REF = MDIB.ID ;*Bank Ref
            GET.DATE.TIME = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestDateTime> ;*Date
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert T24 date for display
            END
            IF R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> EQ CIB.CUSTOMER THEN
                COUNTERPARTY = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestCustomer> ;*Extract and set Counterparty
            END ELSE
                GOSUB GET.COUNTERPARTY ;*Get Counterparty details
            END
            CUSTOMER.REF = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestClientReference> ;*Extract and set Customer Reference
            CURRENCY = R.MD.LIVE.REC<MD.Contract.Deal.DeaCurrency> ;*Extract and set Currency from MD Deal record
            IF R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> EQ CIB.CUSTOMER THEN
                AMOUNT = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestInvAmount> ;*Extract and set Inv Amount from MD IB Request
            END ELSE
                AMOUNT = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvAmount> ;*Extract and set Invocation amount from MD Deal record
            END
            BANK.TO.CUST.INFO = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
            MD.TRANS.REF = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Extract and set MD Reference
            APPL.NAME = "MD IB Request"
            GOSUB FORM.PEND.AUTH.ARRAY ;*Append guarantee invocation records to final array
            GOSUB RESET.VARIABLES ;*Reset variables
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.PEND.AUTH.ARRAY>
*** <desc>Forms an array of unauthorised records from LC and MD applications</desc>
FORM.PEND.AUTH.ARRAY:
*-------------------
    FINAL.ARRAY<-1> = PRODUCT:"*":DATE.TIME.REC:"*":COUNTERPARTY:"*":BANK.REF:"*":CUSTOMER.REF:"*":CURRENCY:"*":AMOUNT:"*":BANK.TO.CUST.INFO:"*":MD.TRANS.REF:"*":APPL.NAME ;*Form an array of unauthorised records for all applications

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.COUNTERPARTY>
*** <desc>Get counterparty details</desc>
GET.COUNTERPARTY:
*---------------
    BEGIN CASE
        CASE R.MD.LIVE.REC<MD.Contract.Deal.DeaInvBeneficiary> ;*Check if Inv Beneficiary field has value
            COUNTERPARTY = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvBeneficiary,1> ;*Extract and set Inv Beneficiary from MD Deal record
        CASE R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> ;*Check Benef Cust field has value
            COUNTERPARTY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> ;*Extract Benef Cust no from MD Deal record
            R.CUSTOMER = '' ;*Initialise record variable
            CUST.ERR = '' ;*Initialise error variable
            R.CUSTOMER = ST.Customer.tableCustomer(COUNTERPARTY,CUST.ERR) ;*Read customer record
            IF R.CUSTOMER THEN
                COUNTERPARTY = R.CUSTOMER<ST.Customer.Customer.EbCusNameOne> ;*Extact and set customer name to counterparty
            END
        CASE R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress> ;*Check if Ben Address field has value in MD Deal record
            COUNTERPARTY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress,1> ;*Extract and set Ben address to counterparty
    END CASE
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.IMP.EXP.VALUES>
*** <desc>Fetches Import and Export drawing details</desc>
GET.IMP.EXP.VALUES:
*-----------------
    IF CHECK.IMP.EXP EQ "I" THEN
        APPLICANT.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno> ;*Extract and set Applicant customer no
        PRODUCT = "Import LC Drawings"
        COUNTERPARTY = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Extract and set Counterparty from LC record
        CUSTOMER.REF = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Extract and set Customer Reference from LC record
    END ELSE
        BENEFICIARY.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno> ;*Extract and set Beneficiary customer no
        PRODUCT = "Export LC Drawings"
        COUNTERPARTY = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrPresentor,1> ;*Extract and set Counterparty from Drawings record
        CUSTOMER.REF = R.DR.UNAUTH.REC<LC.Contract.Drawings.TfDrPresentorRef> ;*Extract and set Customer Reference from Drawings record
    END

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.PRODUCT>
*** <desc>Fetches Product details</desc>
GET.PRODUCT:
*----------
    BEGIN CASE
        CASE INWARD.COLL
            PRODUCT = "Inward Collections"
            CUSTOMER.REF = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcExternalReference> ;*Extract and set Customer Reference
            COUNTERPARTY = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Extract and set Counterparty
        CASE OUTWARD.COLL
            PRODUCT = "Outward Collections"
            CUSTOMER.REF = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Extract and set Customer Reference
            COUNTERPARTY = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Extract and set Counterparty
        CASE NOT(INWARD.COLL) AND NOT(OUTWARD.COLL)
            PRODUCT = "Import LC"
            CUSTOMER.REF = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Extract and set Customer Reference
            COUNTERPARTY = R.LC.UNAUTH.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Extract and set Counterparty
    END CASE
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= CONVERT.DATE>
*** <desc>Convert T24 date for display</desc>
CONVERT.DATE:
*-----------
    GET.DATE.TIME = OCONV(ICONV(GET.DATE.TIME[1,6], 'D2'),'D2')
    DATE.TIME.REC = GET.DATE.TIME : " " : GET.TIME[1,2] : ":" : GET.TIME[3,2] ;*Convert Date and Time in readability format
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>To Read LC record</desc>
READ.LC:
*------
    R.LC.LIVE.REC = '' ;*Initialise record variable
    LC.LIVE.REC.ERR = '' ;*Initialise error variable
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.LIVE.REC.ERR) ;*Read LC Live Record

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.MDIB>
*** <desc>To Read MDIB request record</desc>
READ.UNAUTH.MDIB:
*---------------
    R.MDIB.UNAUTH.REC = '' ;*Initialise record variable
    MDIB.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.MDIB.UNAUTH.REC = MD.Contract.IbRequest.ReadNau(MDIB.ID,MDIB.UNAUTH.REC.ERR) ;*Read MDIB Nau Record

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MD>
*** <desc>To Read MD record</desc>
READ.MD:
*------
    R.MD.LIVE.REC = '' ;*Initialise record variable
    MD.REC.ERR = '' ;*Initialise error variable
    R.MD.LIVE.REC = MD.Contract.Deal.Read(MD.ID, MD.REC.ERR) ;*Read MD Live record

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC.TYPES>
*** <desc>To Read LC types record</desc>
READ.LC.TYPES:
*------------
    R.LC.TYPES = '' ;*Initialise record variable
    LC.TYPE.REC.ERR = '' ;*Initialise error variable
    R.LC.TYPES = LC.Config.Types.Read(LC.TYPE, LC.TYPE.REC.ERR) ;*Read LC Types

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>To Read external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = '' ;*Initialise record variable
    EB.EXT.USER.REC.ERR = '' ;*Initialise error variable
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(EB.EXT.USER.ID, EB.EXT.USER.REC.ERR) ;*Read EB External user based on Inputter field value
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLEST>
*** <desc>Reset variables</desc>
RESET.VARIABLES:
*--------------
    EB.EXT.USER.ID = ''
    R.EB.EXTERNAL.USER = ''
    EB.EXT.USER.REC.ERR = ''
    BANK.REF = ''
    PRODUCT = ''
    DATE.TIME.REC = ''
    COUNTERPARTY = ''
    CUSTOMER.REF = ''
    CURRENCY = ''
    AMOUNT = ''
    BANK.TO.CUST.INFO = ''
    APPL.NAME = ''
    MD.TRANS.REF = ''
    APPLICANT.CUSTNO = ''
    BENEFICIARY.CUSTNO = ''
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
