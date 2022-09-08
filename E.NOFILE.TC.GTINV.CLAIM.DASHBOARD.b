* @ValidationCode : MjotMTMzMDEwNzAxOkNwMTI1MjoxNTY1Nzk0MTIxNjE0OnNtdWdlc2g6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0OjE5MToxOTA=
* @ValidationInfo : Timestamp         : 14 Aug 2019 20:18:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 190/191 (99.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-260</Rating>
*-----------------------------------------------------------------------------
$PACKAGE MD.Channels

SUBROUTINE E.NOFILE.TC.GTINV.CLAIM.DASHBOARD(RET.DATA)

*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which fetches list of guarantee invocation records
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.GTINV.CLAIM.DASHBOARD using the Standard selection NOFILE.TC.GTINV.CLAIM.DASHBOARD
* IN Parameters      : NIL
* Out Parameters     : An Array of Issued guarantee invocation record details such as Transaction reference, TypeOfMD, Beneficiary, Maturity date,
*                      Currency, Amount, Invocation event status, Application name, Record status, Recent Trans, MDIB id,
*                      MD transaction reference(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Guarantees
*
* 02/01/19 - Task : 2852657
*            Componentization II - Methods and Fields must be called through their respective components
*            Enhancement : 2822499
*
* 13/07/2019  - Enhancement 2875478 / Task 3255847
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.MD.IB.REQUEST

    $USING MD.Channels
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.Config
    $USING ST.Customer
    $USING MD.Contract
    $USING MD.Foundation
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.ARC
    $USING EB.Browser
    $USING EB.ErrorProcessing
    

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FETCH.CIB.LISTS ;*Get MD Deal and MD IB Request Invocation lists

    FINAL.ARRAY = INV.ARRAY
    RET.DATA = FINAL.ARRAY  ;*Pass Final Array value to Ret Data
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine</desc>
INITIALISE:
*---------
    GOSUB RESET.VARIABLES

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FETCH.CIB.LISTS>
*** <desc>Fetches List of guarantee invocation records</desc>
FETCH.CIB.LISTS:
*--------------
    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END

    GOSUB MDIB.INV.LIVE.LISTS ;*Get Pend Bank Approval from MD IB Request and Approved/Rejected from MD Deal lists
    GOSUB MDIB.INV.UNAUTH.LISTS ;*Get Pending Authorisation lists
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.INV.LIVE.LISTS>
*** <desc>Selects List of guarantee invocation LIVE records</desc>
MDIB.INV.LIVE.LISTS:
*------------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    TABLE.NAME = "MD.IB.REQUEST"
    THE.LIST = dasMdIbRequestInvLive  ;*Select MD IB Request based on Customer (Corporate Customer) and IB.INV.STATUS is With Bank
    THE.ARGS<1> = CIB.CUSTOMER
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.MDIB.LIST<-1> = THE.LIST
    GOSUB FORM.PEND.BANK.LISTS

    THE.LIST = ''
    THE.ARGS = ''
    TABLE.NAME = "MD.INVOCATION.HIST"
    THE.LIST = EB.DataAccess.dasAllId
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIVE.MD.INV.LIST<-1> = THE.LIST
    GOSUB FORM.APPROVED.OR.REJ.LISTS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.INV.UNAUTH.LISTS>
*** <desc>Fetches List of guarantee invocation unauthorised records</desc>
MDIB.INV.UNAUTH.LISTS:
*--------------------
    TABLE.SUFFIX = '$NAU'
    THE.LIST = ''
    THE.LIST = dasMdIbRequestsInvWithCustomer ;*Select MD IB Request with IB.INV.STATUS EQ "With Customer"
    THE.ARGS<1> = CIB.CUSTOMER
    THE.ARGS<2> = "With Customer"
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.UNAUTH.MDIB.LIST<1,-1> = THE.LIST
    LOOP
        REMOVE MDIB.ID FROM SEL.UNAUTH.MDIB.LIST SETTING MDIB.POS
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.UNAUTH.MDIB
        MD.ID = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*MD Reference
        GOSUB READ.MD
        MDIB.INPUTTER = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestInputter>
        EB.EXT.USER.ID = FIELD(MDIB.INPUTTER,'_',2) ;*Get Inputter value from Inputter field
        GOSUB READ.EB.EXTERNAL.USER
        IF R.EB.EXTERNAL.USER AND R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestRecordStatus>[2,2] EQ 'NA' THEN
            GOSUB GET.MD.DETAILS
            MATURITY.DATE = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvRegisterDate>  ;*Invocation Register date from MD Deal
            AMOUNT = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvAmount> ;*Invocation amount from MD Deal
            INV.EVENT.STATUS = R.MDIB.UNAUTH.REC<MD.Contract.IbRequest.IbRequestIbInvStatus> ;*Amend Status from MDIB
            APPL.NAME = "MD IB Request"
            REC.STATUS = "Unauth"
            GOSUB FORM.MDIB.INV.UNAUTH.ARRAY
            GOSUB RESET.VARIABLES
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.PEND.BANK.LISTS>
*** <desc>Form list of Guarantee invocation records awaiting bank approval</desc>
FORM.PEND.BANK.LISTS:
*-------------------
    LOOP
        REMOVE MDIB.ID FROM SEL.LIVE.MDIB.LIST SETTING MDIB.POS
    WHILE MDIB.ID:MDIB.POS
        GOSUB READ.MDIB
        TRANS.REF = MDIB.ID
        MD.ID = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestMdReference> ;*Corresponding MD Deal Id is stored in this field.
        IF MD.ID THEN
            GOSUB READ.MD
        END
        GOSUB GET.MD.DETAILS
        MATURITY.DATE = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvRegisterDate>  ;*Invocation Register date from MD Deal
        AMOUNT = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvAmount> ;*Invocation amount from MD Deal
        INV.EVENT.STATUS = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestIbInvStatus> ;*Inv Status from MDIB
        DEAL.DATE.TIME = R.MDIB.LIVE.REC<MD.Contract.IbRequest.IbRequestDateTime,1>[1,6]
        GOSUB GET.RECENT.TRANS
        APPL.NAME = "MD IB Request"
        REC.STATUS = "Live"
        GOSUB FORM.INV.ARRAY ;*Form an array for With Bank record in MD IB Request
        GOSUB RESET.VARIABLES
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.APPROVED.OR.REJ.LISTS>
*** <desc>Form list of Approved/Rejected Guarantee invocation records</desc>
FORM.APPROVED.OR.REJ.LISTS:
*-------------------------
    LOOP
        REMOVE MD.ID FROM SEL.LIVE.MD.INV.LIST SETTING MD.INV.POS
    WHILE MD.ID:MD.INV.POS
        GOSUB READ.MD
        INV.NO = R.MD.LIVE.REC<MD.Contract.Deal.DeaLastInvNo> ;*Last Inv No from MD Deal
        GOSUB READ.MD.INV.HIST ;*Read Invocation hist to get Inv Amount and Event Status
        IF R.MD.LIVE.REC<MD.Contract.Deal.DeaCustomer> EQ CIB.CUSTOMER AND R.MD.LIVE.REC<MD.Contract.Deal.DeaContractType> EQ 'CA' AND R.MD.INV.HIST<MD.Foundation.InvocationHist.InvStatus,NO.OF.INV> MATCHES "EXECUTE":@VM:"CANCEL" THEN  ;*When INV Status is Execute or Cancel and Contract Type of Deal is "CA" then display the list
            GOSUB GET.MD.DETAILS
            GOSUB GET.RECENT.TRANS
            GOSUB FORM.INV.ARRAY
            GOSUB RESET.VARIABLES
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MD.DETAILS>
*** <desc>Fetch MD details</desc>
GET.MD.DETAILS:
*-------------
    GOSUB GET.TRANS.REF ;*Alternate Id or MD Id from MD Deal
    CATEG.CODE = R.MD.LIVE.REC<MD.Contract.Deal.DeaCategory> ;*Category from MD Deal
    GOSUB GET.TYPE.OF.MD
    BEGIN CASE
        CASE R.MD.LIVE.REC<MD.Contract.Deal.DeaInvBeneficiary>
            BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaInvBeneficiary,1> ;*Inv Beneficiary from MD Deal
        CASE R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1>
            BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenefCust1> ;*Benef Cust no from MD Deal
            R.CUSTOMER = ''
            CUST.ERR = ''
            R.CUSTOMER = ST.Customer.tableCustomer(BENEFICIARY,CUST.ERR)
            IF R.CUSTOMER THEN
                BENEFICIARY = R.CUSTOMER<ST.Customer.Customer.EbCusNameOne>
            END
        CASE R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress> ;*Ben Address from MD Deal
            BENEFICIARY = R.MD.LIVE.REC<MD.Contract.Deal.DeaBenAddress,1>
    END CASE
    CURRENCY = R.MD.LIVE.REC<MD.Contract.Deal.DeaCurrency> ;*Currency from MD Deal
    DEAL.DATE.TIME = R.MD.LIVE.REC<MD.Contract.Deal.DeaDateTime,1>[1,6]
    APPL.NAME = "MD Deal"
    REC.STATUS = "Live"
    MD.TRANS.REF = MD.ID ;*To drill down from enquiry to record, MD Reference is passed for front end.
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MD.INV.HIST>
*** <desc>To read invocation history records</desc>
READ.MD.INV.HIST:
*---------------

    R.MD.INV.HIST = ''
    MD.INV.HIST.ERR = ''
    R.MD.INV.HIST = MD.Foundation.tableInvocationHist(MD.ID,MD.INV.HIST.ERR) ;*Read MD Invocation Hist to get amount and status
    IF R.MD.INV.HIST THEN
        INV.STATUS = R.MD.INV.HIST<MD.Foundation.InvocationHist.InvStatus>
        AMOUNT = R.MD.INV.HIST<MD.Foundation.InvocationHist.InvAmount>
        MAT.DATE = R.MD.INV.HIST<MD.Foundation.InvocationHist.InvDrValueDate>
        NO.OF.INV = DCOUNT(INV.STATUS,@VM)
        INV.STATUS = FIELD(INV.STATUS,@VM,NO.OF.INV)
        IF INV.STATUS EQ 'EXECUTE' THEN
            INV.EVENT.STATUS = "Settled"
        END ELSE
            INV.EVENT.STATUS = "Rejected"
        END
        INV.AMOUNT = FIELD(AMOUNT,@VM,NO.OF.INV)
        MATURITY.DATE = FIELD(MAT.DATE,@VM,NO.OF.INV)
    END

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
    IF (DEAL.DATE.TIME GE GET.DATE AND DEAL.DATE.TIME LE EB.SystemTables.getToday()[3,6]) AND INV.EVENT.STATUS THEN
        RECENT.TRANS = INV.EVENT.STATUS : "2D"
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MDIB.INV.UNAUTH.ARRAY>
*** <desc>Form guarantee invocation array for unauthorised records</desc>
FORM.MDIB.INV.UNAUTH.ARRAY:
*-------------------------
    INV.ARRAY<-1> := TRANS.REF:"*":TYPE.OF.MD:"*":BENEFICIARY:"*":MATURITY.DATE:"*":CURRENCY:"*":AMOUNT:"*":INV.EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":"":"*":MDIB.ID:"*":MD.TRANS.REF

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.INV.ARRAY>
*** <desc>Form guarantee invocation array for LIVE records</desc>
FORM.INV.ARRAY:
*-------------
    INV.ARRAY<-1> = TRANS.REF:"*":TYPE.OF.MD:"*":BENEFICIARY:"*":MATURITY.DATE:"*":CURRENCY:"*":AMOUNT:"*":INV.EVENT.STATUS:"*":APPL.NAME:"*":REC.STATUS:"*":RECENT.TRANS:"*":MDIB.ID:"*":MD.TRANS.REF
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MDIB>
*** <desc>To read MD.IB.REQUEST record</desc>
READ.MDIB:
*--------
    R.MDIB.LIVE.REC = '' ;*Initialise record variable
    MDIB.LIVE.REC.ERR = '' ;*Initialise error variable
    R.MDIB.LIVE.REC = MD.Contract.IbRequest.Read(MDIB.ID, MDIB.LIVE.REC.ERR) ;*Read Live MD IB Request

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.MDIB>
*** <desc>To read MB.IB.REQUEST Nau record</desc>
READ.UNAUTH.MDIB:
*---------------
    R.MDIB.UNAUTH.REC = '' ;*Initialise record variable
    MDIB.UNAUTH.REC.ERR = '' ;*Initialise error variable
    R.MDIB.UNAUTH.REC = MD.Contract.IbRequest.ReadNau(MDIB.ID, MDIB.UNAUTH.REC.ERR) ;*Read Nau MD IB Request

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MD>
*** <desc>To read MD record</desc>
READ.MD:
*------
    R.MD.LIVE.REC = '' ;*Initialise record variable
    MD.LIVE.REC.ERR = '' ;*Initialise error variable
    R.MD.LIVE.REC = MD.Contract.Deal.Read(MD.ID, MD.LIVE.REC.ERR) ;*Read Live MD Deal

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
    TYPE.OF.MD = R.CATEGORY<ST.Config.Category.EbCatDescription> ;*Get Description from Category

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
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>Read external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------

    R.EB.EXTERNAL.USER = '' ;*Initialise record variable
    EB.EXT.USER.ERR = '' ;*Initialise error variable
    R.EB.EXTERNAL.USER = EB.ARC.tableExternalUser(EB.EXT.USER.ID,EB.EXT.USER.ERR) ;*Read EB External User record based on inputter field value
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Reset used variables</desc>
RESET.VARIABLES:
*--------------
    TRANS.REF = ''
    TYPE.OF.MD = ''
    BENEFICIARY = ''
    MATURITY.DATE = ''
    CURRENCY = ''
    AMOUNT = ''
    INV.EVENT.STATUS = ''
    APPL.NAME = ''
    REC.STATUS = ''
    RECENT.TRANS = ''
    MDIB.ID = ''
    MD.ID = ''
    DEAL.DATE.TIME = ''
    INV.STATUS = ''
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
