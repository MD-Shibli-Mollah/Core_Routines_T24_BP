* @ValidationCode : MjotMTcxMDg1ODcwMjpDcDEyNTI6MTU2NDQwNjI5NjE3ODpzbXVnZXNoOjQ6MjowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDoyOTU6MjUx
* @ValidationInfo : Timestamp         : 29 Jul 2019 18:48:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 2
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 251/295 (85.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------------
* <Rating>135</Rating>
*------------------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.DASHBOARD.MSGS(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches records in 'With Customer' status from LC and MD applications
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.DASHBOARD.MSGS using the Standard selection NOFILE.TC.DASHBOARD.MSGS
* IN Parameters      : NIL
* Out Parameters     : An Array of 'With Customer' status record details such as Product,Date time,Counterparty,Bank reference, Customer reference,Currency,
*                      Amount,Bank To Customer Info and MD Transaction reference(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*
* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>Insert files</desc>

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LC.TYPES
    $INSERT I_DAS.DRAWINGS
    $INSERT I_DAS.LC.AMENDMENTS
    $INSERT I_DAS.MD.IB.REQUEST

    $USING LC.Channels
    $USING LC.Contract
    $USING LC.Config
    $USING LC.ModelBank
    $USING MD.Contract
    $USING EB.DataAccess
    $USING EB.Browser
    $USING EB.Reports
    $USING EB.ErrorProcessing

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main Processing</desc>

    GOSUB INITIALISE
    GOSUB LC.LIST
    GOSUB LC.AMD.LIST
    GOSUB DR.LIST
    GOSUB MD.IB.REQ.LIST

    RET.DATA = FINAL.ARRAY ;*Set out parameter with final array of 'With Customer' records

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------

    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    RET.DATA = '';FINAL.ARRAY = '';R.LC.REC = '';COLL.TYPE.LIST = '';R.DR.REC = '';R.LC.TYPES = '';R.LC.AMD.REC = '' ;*Initialising the variables

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= LC.LIST>
*** <desc>Fetches 'With Customer' status records from LC application</desc>
LC.LIST:
********
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = dasLetterOfCreditWithCustomer ;*Select LC records with IB.STATUS as 'With Customer'
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = 'With Customer' ;*IB.STATUS
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch LC records
    SEL.LC.LIST<-1> = THE.LIST

    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = dasOutwardCollectionsCib ;*Select Outward Collections with IB.STATUS as "With Customer"
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = 'With Customer'
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch outward collection records
    IF THE.LIST THEN
        SEL.LC.LIST<-1> = THE.LIST
    END

    GOSUB GET.LC.DETAILS ;*Get LC record details
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= LC.AMD.LIST>
*** <desc>Fetches 'With Customer' status records from LC amendments application</desc>
LC.AMD.LIST:
*----------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = dasLcAmendmentsWithCustomer ;*Select LC amendment records with IB.EVENT.STATUS as 'With Customer'
    THE.ARGS<1> = 'With Customer'          ;*IB.EVENT.STATUS
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch LC amendment records
    SEL.LC.AMD.LIST<-1> = THE.LIST
    GOSUB GET.LC.AMD.DETAILS ;*Get LC amendment record details
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= DR.LIST>
*** <desc>Fetches 'With Customer' status records from Drawings application</desc>
DR.LIST:
*------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = dasDrawingsWithCustomer
    THE.ARGS<1> = 'With Customer'          ;*IB.EVENT.STATUS
    EB.DataAccess.Das("DRAWINGS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.DR.LIST<-1> = THE.LIST
    GOSUB GET.DR.DETAILS ;*Read drawing details
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= MD.IB.REQ.LIST>
*** <desc>Fetches 'With Customer' status records from MDIB request application</desc>
MD.IB.REQ.LIST:
*-------------
    TABLE.SUFFIX = ''
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = 'With Customer'

    THE.LIST = ''
    THE.LIST = dasMdIbRequestsWithCustomer ;*IB.EVENT.STATUS
    GOSUB CALL.DAS.MD.IB.REQUEST ;*Call DAS for fetching MDIB request records
    SEL.MDIB.LIST<-1> = THE.LIST

    THE.LIST = ''
    THE.LIST = dasMdIbRequestsAmdWithCustomer ;*IB.AMEND.STATUS
    GOSUB CALL.DAS.MD.IB.REQUEST ;*;*Call DAS for fetching MDIB request records
    SEL.MDIB.LIST<-1> = THE.LIST

*Select Guarantee Issuance records for Invocation

    THE.LIST = ''
    THE.LIST = dasMdIbRequestsInvWithCustomer ;*IB.INV.STATUS
    GOSUB CALL.DAS.MD.IB.REQUEST ;*;*Call DAS for fetching MDIB request records
    SEL.MDIB.LIST<-1> = THE.LIST

*Select Guarantee Received records for Invocation

    THE.LIST = ''
    THE.LIST = dasMdIbRequestInwardGteeInv
    GOSUB CALL.DAS.MD.IB.REQUEST ;*;*Call DAS for fetching MDIB request records
    SEL.MDIB.LIST<-1> = THE.LIST

    GOSUB GET.MDIB.DETAILS ;*Read MDIB request record details
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= GET.LC.DETAILS>
*** <desc>Fetches LC record details</desc>
GET.LC.DETAILS:
*-------------
    LOOP
        REMOVE LC.ID FROM SEL.LC.LIST SETTING LC.POS ;*Remove each LC id and iterate with it
    WHILE LC.ID:LC.POS
        GOSUB READ.LC.UNAUTH.REC ;*Check if LC is available in Unauth status
        IF NOT(R.LC.UNAUTH.REC) THEN
            GOSUB READ.LC.REC ;*Read LC record
            IF R.LC.REC THEN
                TYPE.OF.LC.CODE = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcType> ;*Extract and set Type of LC
                LC.ModelBank.LcCheckCollection(TYPE.OF.LC.CODE,INWARD.COLL,OUTWARD.COLL) ;*Check if record is LC,Inward or Outward Collection
                GOSUB GET.PRODUCT ;*Get product details
                GET.DATE.TIME = R.LC.REC<LC.Contract.LetterOfCredit.TfLcDateTime> ;*Extract and set Date and Time
                GET.TIME = GET.DATE.TIME[7,4]
                IF GET.DATE.TIME THEN
                    GOSUB CONVERT.DATE ;*Convert T24 date for display
                END
                BANK.REF = LC.ID ;*Extract and set Bank reference
                CURRENCY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Extract and set Currency
                AMOUNT = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcAmount> ;*Extract and set Amount
                BANK.TO.CUST.INFO = R.LC.REC<LC.Contract.LetterOfCredit.TfLcIbReason,1,1> ;*Extract and set BankToCustomer info
                GOSUB FORM.ARRAY ;*Append 'With Customer' LC records to final array
                INW.COLL.REC = ''
            END
        END
    REPEAT
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= GET.LC.AMD.DETAILS>
*** <desc>Fetches LC amendment record details</desc>
GET.LC.AMD.DETAILS:
*-----------------
    LOOP
        REMOVE LC.AMD.ID FROM SEL.LC.AMD.LIST SETTING LC.AMD.POS ;*Remove each LC amendment id and iterate with it
    WHILE LC.AMD.ID:LC.AMD.POS
        GOSUB READ.LC.AMD.UNAUTH.REC ;*Read LC amendment Nau record
        IF NOT(R.LC.AMD.UNAUTH.REC) THEN
            GOSUB READ.LC.AMD.REC ;*Read LC amendment record
            IF R.LC.AMD.REC THEN
                LC.ID = LC.AMD.ID[1,12] ;*LC Reference
                GOSUB READ.LC.REC ;*Read LC record
                IF R.LC.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno> EQ CIB.CUSTOMER THEN
                    PRODUCT = "Import LC Amendment"
                    COUNTERPARTY = R.LC.AMD.REC<LC.Contract.Amendments.AmdBeneficiary,1> ;*Extract and set Counterparty
                    CUSTOMER.REF = R.LC.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Extract and set Customer Reference of LC
                END ELSE
                    PRODUCT = "Export LC Amendment"
                    COUNTERPARTY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Extract and set Counterparty
                    CUSTOMER.REF = R.LC.REC<LC.Contract.LetterOfCredit.TfLcExternalReference> ;*Extract and set External Reference of LC
                END
                GET.DATE.TIME = R.LC.AMD.REC<LC.Contract.Amendments.AmdDateTime> ;*Extract and set Date and Time
                GET.TIME = GET.DATE.TIME[7,4]
                IF GET.DATE.TIME THEN
                    GOSUB CONVERT.DATE ;*Convert T24 date for display
                END
                BANK.REF = LC.AMD.ID ;*Extract and set Bank reference
                CURRENCY = R.LC.AMD.REC<LC.Contract.Amendments.AmdLcCurrency> ;*Extract and set Currency
                AMOUNT = R.LC.AMD.REC<LC.Contract.Amendments.AmdLcAmount> ;*Extract and set Amount
                BANK.TO.CUST.INFO = R.LC.AMD.REC<LC.Contract.Amendments.AmdIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
                GOSUB FORM.ARRAY ;*Append 'With Customer' LC amendment records to final array
            END
        END
    REPEAT
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= GET.DR.DETAILS>
*** <desc>Fetches Drawing record details</desc>
GET.DR.DETAILS:
*-------------
    LOOP
        REMOVE DR.ID FROM SEL.DR.LIST SETTING DR.POS
    WHILE DR.ID:DR.POS
        GOSUB READ.DR.UNAUTH.REC ;*Read drawing Nau record
        IF NOT(R.DR.UNAUTH.REC) THEN
            GOSUB READ.DR.REC ;*Read drawing record
            IF R.DR.REC THEN
                LC.ID = DR.ID[1,12]
                GOSUB READ.LC.REC ;*Read LC record
                IF R.LC.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno> EQ CIB.CUSTOMER OR R.LC.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno> EQ CIB.CUSTOMER THEN ;*Check if ApplicantCustNo or BeneficiaryCustNo is same as Corporate Customer id
                    LC.TYPE = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcType> ;*Extract and set LC type
                    GOSUB READ.LC.TYPES ;*Read LC types record
                    CHECK.IMP.EXP = R.LC.TYPES<LC.Config.Types.TypImportExport> ;*Extract and set ImportExport field value
                    IF CHECK.IMP.EXP EQ "I" THEN
                        PRODUCT = "Import LC Drawings"
                        COUNTERPARTY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Extract and set Counterparty
                        CUSTOMER.REF = R.LC.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Extract and set Customer Reference
                    END ELSE
                        PRODUCT = "Export LC Drawings"
                        COUNTERPARTY = R.DR.REC<LC.Contract.Drawings.TfDrPresentor,1> ;*Extract and set Counterparty
                        CUSTOMER.REF = R.DR.REC<LC.Contract.Drawings.TfDrPresentorRef> ;*Extract and set Customer Reference
                    END
                    GET.DATE.TIME = R.DR.REC<LC.Contract.Drawings.TfDrDateTime> ;*Extract and set Date and Time
                    GET.TIME = GET.DATE.TIME[7,4]
                    IF GET.DATE.TIME THEN
                        GOSUB CONVERT.DATE ;*Convert T24 date for display
                    END
                    BANK.REF = DR.ID ;*Bank Ref
                    CURRENCY = R.DR.REC<LC.Contract.Drawings.TfDrDrawCurrency> ;*Extract and set Currency
                    AMOUNT = R.DR.REC<LC.Contract.Drawings.TfDrDocumentAmount> ;*Extract and set Amount
                    BANK.TO.CUST.INFO = R.DR.REC<LC.Contract.Drawings.TfDrIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
                    GOSUB FORM.ARRAY ;*Append 'With Customer' drawing records to final array
                END
            END
        END
    REPEAT

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= GET.MDIB.DETAILS>
*** <desc>Fetches MDIB request record details</desc>
GET.MDIB.DETAILS:
*---------------
    LOOP
        REMOVE MDIB.ID FROM SEL.MDIB.LIST SETTING MDIB.POS ;*Remove each MDIB record id and iterate with it
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.MDIB.UNAUTH.REC ;*Read MDIB request Nau record
        IF NOT(R.MDIB.UNAUTH.REC) THEN
            GOSUB READ.MDIB.REC ;*Read MDIB request record
            MD.ID = R.MDIB.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Extract and set MD reference
            IF MD.ID THEN
                GOSUB READ.MD ;*Read MD record
            END
            IF R.MDIB.REC THEN
                GOSUB GET.PRODUCT.AND.AMOUNT ;*Get product and amount details
                GET.DATE.TIME = R.MDIB.REC<MD.Contract.IbRequest.IbRequestDateTime> ;*Extract and set Date and Time
                GET.TIME = GET.DATE.TIME[7,4]
                IF GET.DATE.TIME THEN
                    GOSUB CONVERT.DATE ;*Convert T24 date for display
                END
                IF R.MDIB.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> EQ CIB.CUSTOMER THEN
                    COUNTERPARTY = R.MDIB.REC<MD.Contract.IbRequest.IbRequestCustomer> ;*Extract and set Counterparty
                END ELSE
                    COUNTERPARTY = R.MDIB.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> ;*Extract and set Counterparty
                END
                BANK.REF = MDIB.ID ;*Bank Ref
                CUSTOMER.REF = R.MDIB.REC<MD.Contract.IbRequest.IbRequestClientReference> ;*Extract and set Customer Reference
                IF AMOUNT THEN
                    CURRENCY = R.MDIB.REC<MD.Contract.IbRequest.IbRequestCurrency> ;*Extract and set Currency
                END
                BANK.TO.CUST.INFO = R.MDIB.REC<MD.Contract.IbRequest.IbRequestIbBkToCust,1,1> ;*Extract and set BankToCustomerInfo
                MD.TRANS.REF = R.MDIB.REC<MD.Contract.IbRequest.IbRequestMdReference>
                GOSUB FORM.ARRAY ;*Append 'With Customer' MDIB request records to final array
                GOSUB RESET.VARIABLES ;*Reset variables
            END
        END
    REPEAT
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= FORM.ARRAY>
*** <desc>Builds final array of 'With Customer' record details</desc>
FORM.ARRAY:
*---------
    FINAL.ARRAY<-1> = PRODUCT:"*":DATE.TIME.REC:"*":COUNTERPARTY:"*":BANK.REF:"*":CUSTOMER.REF:"*":CURRENCY:"*":AMOUNT:"*":BANK.TO.CUST.INFO:"*":MD.TRANS.REF ;*Set record details in final array
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.LC.REC>
*** <desc>To Read record from LC LIVE table</desc>
READ.LC.REC:
************
    R.LC.REC = '' ;*Initialise record variable
    LC.LIVE.REC.ERR = '' ;*Initialise error variable
    R.LC.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.LIVE.REC.ERR) ;*Read LC LIVE record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.LC.UNAUTH.REC>
*** <desc>To Read record from LC NAU table</desc>
READ.LC.UNAUTH.REC:
*******************
    R.LC.UNAUTH.REC = '' ;*Initialise record variable
    LC.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.LC.UNAUTH.REC = LC.Contract.LetterOfCredit.ReadNau(LC.ID,LC.UNAUTH.REC.ERR) ;*Read LC Nau record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.LC.AMD.REC>
*** <desc>To Read record from LC Amendment LIVE table</desc>
READ.LC.AMD.REC:
*--------------
    R.LC.AMD.REC = '' ;*Initialise record variable
    LC.AMD.REC.ERR = '' ;*Initialise error variable
    R.LC.AMD.REC = LC.Contract.tableAmendments(LC.AMD.ID,LC.AMD.REC.ERR) ;*Read LC Amendments LIVE record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.LC.AMD.UNAUTH.REC>
*** <desc>To Read record from LC Amendment NAU table</desc>
READ.LC.AMD.UNAUTH.REC:
*---------------------
    R.LC.AMD.UNAUTH.REC = '' ;*Initialise record variable
    LC.AMD.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.LC.AMD.UNAUTH.REC = LC.Contract.Amendments.ReadNau(LC.AMD.ID,LC.AMD.UNAUTH.REC.ERR) ;*Read LC Amendments Nau record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.DR.REC>
*** <desc>To Read record from Drawings LIVE table</desc>
READ.DR.REC:
*----------
    R.DR.REC = '' ;*Initialise record variable
    DR.REC.ERR = '' ;*Initialise error variable
    R.DR.REC = LC.Contract.tableDrawings(DR.ID,DR.REC.ERR) ;*Read Drawings LIVE record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.DR.UNAUTH.REC>
*** <desc>To Read record from Drawings NAU table</desc>
READ.DR.UNAUTH.REC:
*-----------------
    R.DR.UNAUTH.REC = '' ;*Initialise record variable
    DR.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.DR.UNAUTH.REC = LC.Contract.Drawings.ReadNau(DR.ID,DR.UNAUTH.REC.ERR) ;*Read Drawings Nau record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.MDIB.REC>
*** <desc>To Read record from MDIB request LIVE table</desc>
READ.MDIB.REC:
*------------
    R.MDIB.REC = '' ;*Initialise record variable
    MDIB.REC.ERR = '' ;*Intialise error variable
    R.MDIB.REC = MD.Contract.IbRequest.Read(MDIB.ID, MDIB.REC.ERR) ;*Read MDIB request LIVE record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.MDIB.UNAUTH.REC>
*** <desc>To Read record from MDIB request NAU table</desc>
READ.MDIB.UNAUTH.REC:
*-------------------
    R.MDIB.UNAUTH.REC = '' ;*Initialise record variable
    MDIB.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.MDIB.UNAUTH.REC = MD.Contract.IbRequest.ReadNau(MDIB.ID,MDIB.UNAUTH.REC.ERR) ;*Read MDIB request Nau record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.MD>
*** <desc>To Read record from MD LIVE table</desc>
READ.MD:
*------
    R.MD.LIVE.REC = '' ;*Initialise record variable
    MD.REC.ERR = '' ;*Initialise error variable
    R.MD.LIVE.REC = MD.Contract.Deal.Read(MD.ID, MD.REC.ERR) ;*Read MD Live record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= READ.LC.TYPES>
*** <desc>To Read record from LC TYPES table</desc>
READ.LC.TYPES:
*------------
    R.LC.TYPES = '' ;*Initialise record variable
    LC.TYPE.REC.ERR = '' ;*Initialise error variable
    R.LC.TYPES = LC.Config.Types.Read(LC.TYPE, LC.TYPE.REC.ERR) ;*Read LC Types record

RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= CALL.DAS.MD.IB.REQUEST>
*** <desc>Fetches list of MDIB request records</desc>
CALL.DAS.MD.IB.REQUEST:
*---------------------
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch a list of MDIB request records
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= GET.PRODUCT>
*** <desc>Get product details for LC records</desc>
GET.PRODUCT:
*----------
    BEGIN CASE
        CASE INWARD.COLL
            PRODUCT = "Inward Collections"
            CUSTOMER.REF = R.LC.REC<LC.Contract.LetterOfCredit.TfLcExternalReference> ;*Extract and set Customer Reference
            COUNTERPARTY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Extract and set Counterparty
        CASE OUTWARD.COLL
            PRODUCT = "Outward Collections"
            CUSTOMER.REF = R.LC.REC<LC.Contract.LetterOfCredit.TfLcExternalReference> ;*Extract and set Customer Reference
            COUNTERPARTY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Extract and set Counterparty
        CASE NOT(INWARD.COLL) AND NOT(OUTWARD.COLL)
            PRODUCT = "Import LC"
            CUSTOMER.REF = R.LC.REC<LC.Contract.LetterOfCredit.TfLcClientRef> ;*Extract and set Customer Reference
            COUNTERPARTY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Extract and set Counterparty
    END CASE
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= CONVERT.DATE>
*** <desc>Convert T24 record date time to user readable format</desc>
CONVERT.DATE:
*-----------
    GET.DATE.TIME = OCONV(ICONV(GET.DATE.TIME[1,6], 'D2'),'D2') ;*Extract the Date time part
    DATE.TIME.REC = GET.DATE.TIME : " " : GET.TIME[1,2] : ":" : GET.TIME[3,2] ;*Form the Date time string for display
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= GET.PRODUCT.AMOUNT>
*** <desc>Get product and amount details for MD records</desc>
GET.PRODUCT.AND.AMOUNT:
*---------------------

    BEGIN CASE
        CASE R.MDIB.REC<MD.Contract.IbRequest.IbRequestIbEventStatus> EQ "With Customer"
            PRODUCT = "Guarantees"
            AMOUNT = R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount> ;*Principal Amount from MD IB Request
        CASE R.MDIB.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus> EQ "With Customer"
            PRODUCT = "Amendment to Guarantee"
            AMOUNT = R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrinMovement> ;*Prin Movement from MD IB Request
        CASE R.MDIB.REC<MD.Contract.IbRequest.IbRequestIbInvStatus> EQ "With Customer"
            IF R.MDIB.REC<MD.Contract.IbRequest.IbRequestBeneficiary,1> EQ CIB.CUSTOMER THEN
                AMOUNT = R.MDIB.REC<MD.Contract.IbRequest.IbRequestInvAmount> ;*Inv Amount from MD IB Request
                PRODUCT = "Claim under Received Guarantee"  ;*Invocation Claim Guarantees Received
            END ELSE
                AMOUNT = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvAmount> ;*Invocation amount from MD Deal
                PRODUCT = "Claim under Guarantee"  ;*Invocation Claim Guarantees Issued
            END
    END CASE
RETURN

*** </region>
*--------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Reset the variables used in this routine</desc>
RESET.VARIABLES:
****************
    MD.TRANS.REF = ''
    COUNTERPARTY = ''
    PRODUCT = ''
    CURRENCY = ''
    AMOUNT = ''
    DATE.TIME.REC = ''
    BANK.REF = ''
    CUSTOMER.REF = ''
    BANK.TO.CUST.INFO = ''
    MD.ID = ''
RETURN

*** </region>
*--------------------------------------------------------------------
END
