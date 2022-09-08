* @ValidationCode : Mjo0ODEzNDk5MjQ6Q3AxMjUyOjE1NjQ0MDYyOTY3MDk6c211Z2VzaDozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNTMxLTAzMTQ6MjI1OjE2NA==
* @ValidationInfo : Timestamp         : 29 Jul 2019 18:48:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 164/225 (72.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>3</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.DASHBOARD.DRAFTS(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches records in IHLD status from LC and MD applications
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.DASHBOARD.DRAFTS using the Standard selection NOFILE.TC.DASHBOARD.DRAFTS
* IN Parameters      : NIL
* Out Parameters     : An Array of IHLD record details such as Product,Transaction reference,Counterparty,Currency,
*                      Amount,Creation date, Date time and Completion percentage(RET.DATA)
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

    $INSERT I_DAS.MD.IB.REQUEST
    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.DRAWINGS

    $USING LC.Channels
    $USING LC.Contract
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
    GOSUB FETCH.CIB.LISTS

    RET.DATA = FIN.ARRAY ;*Pass Final array value to RET DATA
    
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------

    FIN.ARRAY = '';SEL.IHLD.LC.LIST = '';LC.ID = '';R.LC.REC.HLD = '';LC.HLD.ERR = '';SEL.IHLD.DR.LIST = '';DR.ID = '' ;*Initialising the variables
    R.DR.REC.HLD = '';DR.HLD.ERR = '';SEL.IHLD.MDIB.LIST = '';MDIB.ID = '';R.MDIB.REC.HLD = '';MDIB.HLD.ERR = '';LC.POS = '' ;*Initialising the variables
    DR.POS = '';MDIB.POS = '';PRODUCT = '';TRANS.REFERENCE = '';CREATION.DATE = '';DATE.TIME.REC = '';COMPLETE.PERCENT = '' ;*Initialising the variables

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>To fetch list of IHLD records associated with TCIB Corporate customer from LC and MD applications</desc>
FETCH.CIB.LISTS:
*--------------

    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    GOSUB SELECT.IHLD.RECORDS ;*Select IHLD records from LC,Drawings and MD IB request applications
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= SELECT.IHLD.RECORDS>
*** <desc>To select records in IHLD</desc>
SELECT.IHLD.RECORDS:
*------------------
    GOSUB SELECT.LC.RECORDS   ;*Import LC's which are in 'IHLD' status which is inputted by Proxy User of the Corporate Customer
    GOSUB SELECT.EXP.DR.RECORDS         ;*Export Drawings which are in 'IHLD' status which is inputted by Proxy User of the Corporate Customer
    GOSUB SELECT.GTEE.RECORDS ;*MD Ib Request which are in 'IHLD' status which is inputted by Proxy User of the Corporate Customer
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= SELECT.LC.RECORDS>
*** <desc>To select LC records</desc>
SELECT.LC.RECORDS:
*----------------
    THE.LIST = ''
    TABLE.SUFFIX = '$NAU'
    THE.LIST = dasLetterOfCreditHldCib ;*Select LC's  which are inputted by External User and put on Hold
    THE.ARGS<1> = CIB.CUSTOMER ;*Applicant Custno Field
    THE.ARGS<2> = 'IHLD' ;*Record Status
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS based on THE.ARGS
    SEL.IHLD.LC.LIST<-1> = THE.LIST ;*Form LC list from THE.LIST

    THE.LIST = dasCollectionsHldCib ;*Select LC's  which are inputted by External User and put on Hold
    THE.ARGS<1> = CIB.CUSTOMER ;*Beneficiary Custno Field
    THE.ARGS<2> = 'IHLD' ;*Record Status
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS based on THE.ARGS
    SEL.IHLD.LC.LIST<-1> = THE.LIST ;*Form LC list from THE.LIST

    LC.CIB.FIELDS = LC.Contract.LetterOfCredit.TfLcIssueDate:@VM:LC.Contract.LetterOfCredit.TfLcClientRef:@VM:LC.Contract.LetterOfCredit.TfLcLcCurrency:@VM:LC.Contract.LetterOfCredit.TfLcLcAmount:@VM:LC.Contract.LetterOfCredit.TfLcExpiryPlace:@VM:LC.Contract.LetterOfCredit.TfLcAdviceExpiryDate
    LC.CIB.FIELDS<1,-1> = LC.Contract.LetterOfCredit.TfLcConfirmInst:@VM:LC.Contract.LetterOfCredit.TfLcTransferable:@VM:LC.Contract.LetterOfCredit.TfLcPayTerms:@VM:LC.Contract.LetterOfCredit.TfLcStandBy:@VM:LC.Contract.LetterOfCredit.TfLcIncoTerms:@VM:LC.Contract.LetterOfCredit.TfLcAddAmtCovered
    LC.CIB.FIELDS<1,-1> = LC.Contract.LetterOfCredit.TfLcShipDespatch:@VM:LC.Contract.LetterOfCredit.TfLcOtherDespatchDet:@VM:LC.Contract.LetterOfCredit.TfLcTransportation:@VM:LC.Contract.LetterOfCredit.TfLcFinalDestination
    LC.CIB.FIELDS<1,-1> = LC.Contract.LetterOfCredit.TfLcTransshipments:@VM:LC.Contract.LetterOfCredit.TfLcPartShipText:@VM:LC.Contract.LetterOfCredit.TfLcModeOfShipment:@VM:LC.Contract.LetterOfCredit.TfLcDescGoods:@VM:LC.Contract.LetterOfCredit.TfLcDocumentsReq:@VM:LC.Contract.LetterOfCredit.TfLcClausesText:@VM:LC.Contract.LetterOfCredit.TfLcAdditionlConds:@VM:LC.Contract.LetterOfCredit.TfLcNarrativeChrgs

    LOOP
        REMOVE LC.ID FROM SEL.IHLD.LC.LIST SETTING LC.POS ;*Loop for each LC record from the List
    WHILE LC.ID:LC.POS
        R.LC.REC.HLD = ''
        LC.HLD.ERR = ''
        R.LC.REC.HLD = LC.Contract.LetterOfCredit.ReadNau(LC.ID,LC.HLD.ERR) ;*Read LC record
        LC.INPUT = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcInputter> ;*Get Inputter of LC
        EB.EXT.USER.ID = FIELD(LC.INPUT,'_',2)
        APPLICANT = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcApplicantCustno> ;*Get Applicant Cust No
        BENEFICIARY = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno> ;*Get Beneficiary Cust No
        GOSUB READ.EB.EXTERNAL.USER ;*If Inputter is External User then form an array
        IF R.EB.EXTERNAL.USER THEN
            IF APPLICANT EQ CIB.CUSTOMER THEN ;*For Import LC Issuance, Applicant is a Corproate Customer
                PRODUCT = "Letter of Credit"
                COUNTERPARTY = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcBeneficiary,1> ;*Counterparty
            END ELSE
                PRODUCT = "Collection" ;*For Outward Collections, Beneficiary is a Corporate Customer
                COUNTERPARTY = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcApplicant,1> ;*Counterparty
            END
            TRANS.REFERENCE = LC.ID ;*LC Reference
            CURRENCY = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Currency
            AMOUNT = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcLcAmount> ;*Amount
            CREATION.DATE = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcIssueDate> ;*Issue Date of LC
            GET.DATE.TIME = R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcDateTime> ;*Saved Date and Time from DATE.TIME field
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert date and time in readability format
            END
            GOSUB CALC.LC.COMPLETE.PERCENT ;*Calculate completion percentage for each record based on the mandatory fields count
            GOSUB FORM.ARRAY ;*Form an Array based on the retrieved values for LC
            COMPLETE.FIELD = ''
            COMPLETE.PERCENT = ''
            R.LC.REC.HLD = ''
        END
    REPEAT
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= SELECT.EXP.DR.RECORDS>
*** <desc>To select drawings record</desc>
SELECT.EXP.DR.RECORDS:
*--------------------

    THE.LIST = ''
    TABLE.SUFFIX = '$NAU'
    THE.LIST = dasDrawingsHldCib ;*Select Drawing records which are in Hold Status
    THE.ARGS<1> = 'IHLD' ;*Record Status
    EB.DataAccess.Das("DRAWINGS",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to Das routine based on THE.ARGS
    SEL.IHLD.DR.LIST = THE.LIST
    DR.CIB.FIELDS = LC.Contract.Drawings.TfDrDrawCurrency:@VM:LC.Contract.Drawings.TfDrDocumentAmount:@VM:LC.Contract.Drawings.TfDrPaymentAccount:@VM:LC.Contract.Drawings.TfDrIbCustToBk:@VM:LC.Contract.Drawings.TfDrDocumentName
    LOOP
        REMOVE DR.ID FROM SEL.IHLD.DR.LIST SETTING DR.POS ;*Loop for each drawing id in the list
    WHILE DR.ID:DR.POS
        R.DR.REC.HLD = ''
        DR.HLD.ERR = ''
        R.DR.REC.HLD = LC.Contract.Drawings.ReadNau(DR.ID,DR.HLD.ERR) ;*Read Drawings record
        DR.INPUT = R.DR.REC.HLD<LC.Contract.Drawings.TfDrInputter>
        EB.EXT.USER.ID = FIELD(DR.INPUT,'_',2)
        GOSUB READ.EB.EXTERNAL.USER
        LC.ID = DR.ID[1,12]
        GOSUB READ.LC
        BENEFICIARY.CUSTNO = R.LC.LIVE.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno> ;*Get Bene Custno to check if drawings is export
        IF R.EB.EXTERNAL.USER AND BENEFICIARY.CUSTNO EQ CIB.CUSTOMER THEN ;*If Inputter is External User and export drawings then form an array
            PRODUCT = "Export Drawings"
            TRANS.REFERENCE = DR.ID ;*Drawings Reference
            COUNTERPARTY = R.DR.REC.HLD<LC.Contract.Drawings.TfDrPresentor,1> ;*Counterparty
            CURRENCY = R.DR.REC.HLD<LC.Contract.Drawings.TfDrDrawCurrency> ;*Currency
            AMOUNT = R.DR.REC.HLD<LC.Contract.Drawings.TfDrDocumentAmount> ;*Amount
            CREATION.DATE = R.DR.REC.HLD<LC.Contract.Drawings.TfDrBookingDate> ;*Booking Date
            GET.DATE.TIME = R.DR.REC.HLD<LC.Contract.Drawings.TfDrDateTime> ;*Saved Date and Time from DATE.TIME field
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert date and time in readability format
            END
            GOSUB CALC.DR.COMPLETE.PERCENT ;*Calculate completion percentage for each record based on the mandatory fields count
            GOSUB FORM.ARRAY ;*Form an Array based on the retrieved values for Drawings
            COMPLETE.FIELD = ''
            COMPLETE.PERCENT = ''
            R.DR.REC.HLD = ''
        END
    REPEAT
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= SELECT.GTEE.RECORDS>
*** <desc>To select MD records</desc>
SELECT.GTEE.RECORDS:
*------------------
    THE.LIST = ''
    TABLE.SUFFIX = '$NAU'
    THE.LIST = dasMdIbRequestHldCib ;*Select MD IB Request records which are inputted by External User and put on Hold
    THE.ARGS<1> = CIB.CUSTOMER ;*Customer field in MD IB Request
    THE.ARGS<2> = 'IHLD' ;*Record Status
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
    SEL.IHLD.MDIB.LIST = THE.LIST
;*Form an array with the list of fields of MD IB Request application, used for Internet banking
    MDIB.CIB.FIELDS = MD.Contract.IbRequest.IbRequestCategory:@VM:MD.Contract.IbRequest.IbRequestCurrency:@VM:MD.Contract.IbRequest.IbRequestBeneficiary:@VM:MD.Contract.IbRequest.IbRequestGteeDetails
    MDIB.CIB.FIELDS<1,-1> = MD.Contract.IbRequest.IbRequestChargeDrAccount:@VM:MD.Contract.IbRequest.IbRequestStartDate:@VM:MD.Contract.IbRequest.IbRequestMaturityDate:@VM:MD.Contract.IbRequest.IbRequestPrincipalAmount:@VM:MD.Contract.IbRequest.IbRequestClientReference
    MDIB.CIB.FIELDS<1,-1> = MD.Contract.IbRequest.IbRequestProvDrAccount:@VM:MD.Contract.IbRequest.IbRequestCommDrAccount:@VM:MD.Contract.IbRequest.IbRequestInvDrAccount:@VM:MD.Contract.IbRequest.IbRequestSgIssued
    MDIB.CIB.FIELDS<1,-1> = MD.Contract.IbRequest.IbRequestLcReference:@VM:MD.Contract.IbRequest.IbRequestDocumentName:@VM:MD.Contract.IbRequest.IbRequestIbCustToBk:@VM:MD.Contract.IbRequest.IbRequestOtherInformation
    
    LOOP
        REMOVE MDIB.ID FROM SEL.IHLD.MDIB.LIST SETTING MDIB.POS ;*Loop for each MD IB request id in the list
    WHILE MDIB.ID:MDIB.POS
        R.MDIB.REC.HLD = ''
        MDIB.HLD.ERR = ''
        R.MDIB.REC.HLD = MD.Contract.IbRequest.ReadNau(MDIB.ID, MDIB.HLD.ERR) ;*Read MD IB Request record
        MDIB.INPUT = R.MDIB.REC.HLD<MD.Contract.IbRequest.IbRequestInputter>
        EB.EXT.USER.ID = FIELD(MDIB.INPUT,'_',2)
        GOSUB READ.EB.EXTERNAL.USER ;*Read EB.EXTERNAL.USER appplication record
        IF R.EB.EXTERNAL.USER THEN
            PRODUCT = "Guarantees"
            TRANS.REFERENCE = MDIB.ID ;*MDIB Reference
            COUNTERPARTY = R.MDIB.REC.HLD<MD.Contract.IbRequest.IbRequestBeneficiary,1> ;*Counterparty
            CURRENCY = R.MDIB.REC.HLD<MD.Contract.IbRequest.IbRequestCurrency> ;*Currency
            AMOUNT = R.MDIB.REC.HLD<MD.Contract.IbRequest.IbRequestPrincipalAmount> ;*Amount
            CREATION.DATE = R.MDIB.REC.HLD<MD.Contract.IbRequest.IbRequestBookingDate> ;*Booking Date
            GET.DATE.TIME = R.MDIB.REC.HLD<MD.Contract.IbRequest.IbRequestDateTime> ;*Saved Date and Time from DATE.TIME field
            GET.TIME = GET.DATE.TIME[7,4]
            IF GET.DATE.TIME THEN
                GOSUB CONVERT.DATE ;*Convert date and time in readability format
            END
            GOSUB CALC.MDIB.COMPLETE.PERCENT ;*Calculate completion percentage for each record based on the mandatory fields count
            GOSUB FORM.ARRAY ;*Form an Array based on the retrieved values of MD IB Request
            COMPLETE.FIELD = ''
            COMPLETE.PERCENT = ''
            R.MDIB.REC.HLD = ''
        END
    REPEAT
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= FORM.ARRAY>
*** <desc>Build the final array of IHLD records</desc>
FORM.ARRAY:
*---------
    FIN.ARRAY<-1> = PRODUCT:"*":TRANS.REFERENCE:"*":COUNTERPARTY:"*":CURRENCY:"*":AMOUNT:"*":CREATION.DATE:"*":DATE.TIME.REC:"*":COMPLETE.PERCENT ;*Final Array which contains all the values which are retrieved from LC,Drawings and MD IB Request
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= CONVERT.DATE>
*** <desc>Convert date and time</desc>
CONVERT.DATE:
*-----------
    GET.DATE.TIME = OCONV(ICONV(GET.DATE.TIME[1,6], 'D2'),'D2')
    DATE.TIME.REC = GET.DATE.TIME : " " : GET.TIME[1,2] : ":" : GET.TIME[3,2] ;*Date and time in readability format
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>To read external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = ''
    EB.EXT.USER.ERR = ''
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(EB.EXT.USER.ID, EB.EXT.USER.ERR) ;*Read EB External User based on the Inputter field value
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>To read LC record</desc>
READ.LC:
*------
    R.LC.LIVE.REC = ''
    LC.REC.ERR = ''
    R.LC.LIVE.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.REC.ERR) ;*Read LC Record
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= CALC.LC.COMPLETE.PERCENT>
*** <desc>Calcuate LC Completion Percentage</desc>
CALC.LC.COMPLETE.PERCENT:
*-----------------------
    NO.OF.LC.CIB.FIELDS = DCOUNT(LC.CIB.FIELDS,@VM) ;*Count of Import LC Issuance fields
    FOR LC.FIELD = 1 TO NO.OF.LC.CIB.FIELDS
        LC.FLD.NO = FIELD(LC.CIB.FIELDS,@VM,LC.FIELD)
        IF R.LC.REC.HLD<LC.FLD.NO> THEN ;*If field contains value in IHLD record then calculate the perecentage
            COMPLETE.FIELD += 1
        END
    NEXT LC.FIELD
    IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcPayTerms> AND NOT(R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcPayTerms> MATCHES 'Sight':@VM:'Nego.Sight') THEN
        IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcTenor> OR R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcDeferredPay> THEN
            COMPLETE.FIELD +=1
        END
    END

    IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcBeneficiary> THEN ;*For Beneficiary, completion % gets calculated based on multivalues
        NO.OF.BENE.VALUES = DCOUNT(R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcBeneficiary>,@VM)
        COMPLETE.FIELD += NO.OF.BENE.VALUES
    END

    IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcAdvisingBk> THEN  ;*For Advising Bk field, completion % gets calculated based on multivalues
        NO.OF.ADVBK.VALUES = DCOUNT(R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcAdvisingBk>,@VM)
        COMPLETE.FIELD += NO.OF.ADVBK.VALUES
    END

    IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcAvailableWith> THEN ;*For Available With field, completion % gets calculated based on multivalues
        NO.OF.AVAIL.WITH.VALUES = DCOUNT(R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcAvailableWith>,@VM)
        COMPLETE.FIELD += NO.OF.AVAIL.WITH.VALUES
    END

    IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcPercentageDrAmt> OR R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcPercentageCrAmt> OR R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcMaximumCrAmt> THEN ;*Debit Tolerance, Credit tolerance or maximum cr amt field contains values then complete field variable to be added
        COMPLETE.FIELD += 1
    END

    IF R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcLatestShipment> OR R.LC.REC.HLD<LC.Contract.LetterOfCredit.TfLcPresentPeriod> THEN ;*These fields are mutually exclusive fields
        COMPLETE.FIELD += 1
    END

    NO.OF.LC.CIB.FIELDS += 13
    COMPLETE.PERCENT = DROUND((COMPLETE.FIELD/NO.OF.LC.CIB.FIELDS)*100,2) ;*Calcuate the percentage based on count and complete field count
    GOSUB ROUND.COMPLETE.PERCENT
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= CALC.DR.COMPLETE.PERCENT>
*** <desc>Calcuate Drawings Completion Percentage</desc>
CALC.DR.COMPLETE.PERCENT:
*-----------------------
    NO.OF.DR.CIB.FIELDS = DCOUNT(DR.CIB.FIELDS,@VM) ;*Count of Drawings mandatory fields
    FOR DR.FIELD = 1 TO NO.OF.DR.CIB.FIELDS
        DR.FLD.NO = FIELD(DR.CIB.FIELDS,@VM,DR.FIELD)
        IF R.DR.REC.HLD<DR.FLD.NO> THEN ;*If field contains value in IHLD record then calculate the perecentage
            COMPLETE.FIELD += 1
        END
    NEXT DR.FIELD
    COMPLETE.PERCENT = DROUND((COMPLETE.FIELD/NO.OF.DR.CIB.FIELDS)*100,2) ;*Calcuate the percentage based on count and complete field count
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= CALC.MDIB.COMPLETE.PERCENT>
*** <desc>Calcuate MD IB Request Completion Percentage</desc>
CALC.MDIB.COMPLETE.PERCENT:
*-------------------------

    NO.OF.MDIB.CIB.FIELDS = DCOUNT(MDIB.CIB.FIELDS,@VM) ;*Count of MD IB Request mandatory fields
    FOR MDIB.FIELD = 1 TO NO.OF.MDIB.CIB.FIELDS
        MDIB.FLD.NO = FIELD(MDIB.CIB.FIELDS,@VM,MDIB.FIELD)
        IF R.MDIB.REC.HLD<MDIB.FLD.NO> THEN ;*If field contains value in IHLD record then calculate the perecentage
            COMPLETE.FIELD += 1
        END
    NEXT MDIB.FIELD
    COMPLETE.PERCENT = DROUND((COMPLETE.FIELD/NO.OF.MDIB.CIB.FIELDS)*100,2) ;*Calcuate the percentage based on count and complete field count
    GOSUB ROUND.COMPLETE.PERCENT
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------
*** <region name= ROUND.COMPLETE.PERCENT>
*** <desc>Rounding off the completion Percentage</desc>
ROUND.COMPLETE.PERCENT:
*---------------------
    IF COMPLETE.PERCENT > 100 THEN
        COMPLETE.PERCENT = 100
    END
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------
END
