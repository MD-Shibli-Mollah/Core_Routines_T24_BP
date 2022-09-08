* @ValidationCode : MjoxMzAzNjAyMTYwOkNwMTI1MjoxNjA3MDU4MjM3OTQzOm1raXJ0aGFuYTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjIwMjAxMTExLTEyMTA6MzY3OjI3Mg==
* @ValidationInfo : Timestamp         : 04 Dec 2020 10:33:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mkirthana
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 272/367 (74.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-321</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.LETTER.OF.CREDIT.LIMIT(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which computes limit amount for LetterOfCredit(LC)
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.LETTER.OF.CREDIT.LIMIT using the Standard selection NOFILE.TC.LETTER.OF.CREDIT.LIMIT
* IN Parameters      : NIL
* Out Parameters     : An Array of limit details such as Utilised Amount,Total Available Amount and Pending Amount(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*
* 29/10/18 - Task : 2831555
*            Componentization II - EB.DataAccess should be used instead of I_DAS.COMMON.
*            Strategic Initiative : 2822484
*
* 27/05/19 - Task 3150096
*            When Global Limit is setup, system does not return limit details
*            Defect 3134224
*
* 01/08/2019 - Enhancement 3272885 / Task 3272886
*              New API should replace the direct read call to retreive the Limit Parameter record

* 13/07/2019  - Enhancement 2875478 / Task 3227602
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer id selection field
*
* 19/10/20 - Task :4031723
*            Limit Overview and Limit Utilisation Graph is not displaying in Trade Finance.
*            Defect : 3843924
*
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LIMIT
    $INSERT I_DAS.LC.TYPES
    $INSERT I_DAS.LC.AMENDMENTS
    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LIMIT.REFERENCE

    $USING LC.Channels
    $USING EB.SystemTables
    $USING LI.Config
    $USING LC.Config
    $USING LC.Contract
    $USING EB.DataAccess
    $USING EB.ARC
    $USING EB.Browser
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING EB.Reports
    $USING EB.ErrorProcessing

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
    GOSUB FORM.ARRAYS
    RET.DATA = FINAL.ARRAY
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables used in this routine </desc>
INITIALISE:
*---------

    LOCATE 'CIB.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        CIB.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    
    EXTERNAL.USER.ID = EB.ErrorProcessing.getExternalUserId() ;*Get external user Id
    
    IF EXTERNAL.USER.ID AND CIB.CUSTOMER EQ "" THEN            ;* To support IRIS1 enquiry
        CIB.CUSTOMER  = EB.Browser.SystemGetvariable('EXT.SMS.CUSTOMERS')
    END
    LIMIT.LOCAL.CCY = EB.SystemTables.getLccy()
    SIGHT.PENDING.AMT = 0;ACCEPT.PENDING.AMT = 0;DEFERRED.PENDING.AMT = 0;NEGO.PENDING.AMT = 0 ;*Initialising the variables
    MIXED.PAY.PENDING.AMT = 0;LC.LIAB.AMT = 0;LC.PENDING.AMT = 0;LC.CCY = '' ;*Initialising the variables
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>To fetch limit details for LetterOfCredit (LC) application</desc>
PROCESS:
*------
    RESERVED1 = ''
    RESERVED2 = ''
    LI.Config.GetLimitParameterRecord('LETTER.OF.CREDIT', R.LIMIT.PARAMETER, RESERVED1, RESERVED2) ;*Read LETTER.OF.CREDIT record of Limit Parameter application

    IF R.LIMIT.PARAMETER THEN ;*Check if Limit parameter exist
        APPL.NAME = R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParApplication> ;*Extract and set application name
        NO.OF.APP = DCOUNT(APPL.NAME,@VM) ;*Count the no of applications
        FOR APP = 1 TO NO.OF.APP ;*Iterate with applications count
            IF R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParApplication,APP> EQ 'LETTER.OF.CREDIT' THEN ;*Check if application is LC
                CATEG.CODE = R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParDecisionFr,APP> ;*Extract and set Category code
                IF CATEG.CODE THEN ;*Check if Category code exist
                    GOSUB CHECK.IMPORT ;*Check LC Type based on the retrieved Category Code
                    GOSUB CALC.PAY.TYPE.BASED.AMOUNT ;*Calculate Amount based on Pay Type field
                END
            END
        NEXT APP
    END
    GOSUB GET.PENDING.AMT ;*Calculate pending amount from LC record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.IMPORT>
*** <desc>To get pay type if LC type is 'Import'</desc>
CHECK.IMPORT:
*-----------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = dasLcTypesCategory ;*Select LC Types based on the Category code
    THE.ARGS = CATEG.CODE ;*CATEGORY.CODE field
    EB.DataAccess.Das("LC.TYPES",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
    LC.TYPES.LIST = THE.LIST
    LC.TYPE.ID = LC.TYPES.LIST<1,1>
    GOSUB READ.LC.TYPES ;*Read LC types record
    IF R.LC.TYPES THEN
        IMP.SET = R.LC.TYPES<LC.Config.Types.TypImportExport> ;*Get Import Export field value
        IF IMP.SET EQ 'I' THEN
            PAY.TYPE = R.LC.TYPES<LC.Config.Types.TypPayType> ;*If Type is Import, get Pay Type value
        END
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CALC.PAY.TYPE.BASED.AMOUNT>
*** <desc>Compute limit amount based on pay type</desc>
CALC.PAY.TYPE.BASED.AMOUNT:
*-------------------------
    BEGIN CASE
        CASE IMP.SET EQ 'I' AND PAY.TYPE EQ 'P' ;*Calcuate Available and Utilised Amount for Sight LC
            TYPE.OF.LC = "Sight"
            GOSUB GET.LIMIT.PRODUCTS ;*Get Limit Products
            LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency>
            GOSUB GET.SIGHT.LIMIT.AMOUNT ;*Compute limit amount for Sight LC
        CASE IMP.SET EQ 'I' AND PAY.TYPE EQ 'A' ;*Calcuate Available and Utilised Amount for Accepance LC
            TYPE.OF.LC = "Acceptance"
            GOSUB GET.LIMIT.PRODUCTS ;*Get Limit Products
            LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency>
            GOSUB GET.ACCEPT.LIMIT.AMOUNT ;*Compute limit amount for Acceptance LC
        CASE IMP.SET EQ 'I' AND PAY.TYPE EQ 'D' ;*Calcuate Available and Utilised Amount for Deferred LC
            TYPE.OF.LC = "Deferred"
            GOSUB GET.LIMIT.PRODUCTS ;*Get Limit Products
            LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency>
            GOSUB GET.DEFERRED.LIMIT.AMOUNT ;*Compute limit amount for Deferred LC
        CASE IMP.SET EQ 'I' AND PAY.TYPE MATCHES 'N':@VM:'NS':@VM:'NA' ;*Calcuate Available and Utilised Amount for Negotiation
            TYPE.OF.LC = "Negotiation"
            GOSUB GET.LIMIT.PRODUCTS ;*Get Limit Products
            LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency>
            GOSUB GET.NEGO.LIMIT.AMOUNT ;*Compute limit amount for Negotiable LC
        CASE IMP.SET EQ 'I' AND PAY.TYPE EQ 'M' ;*Calcuate Available and Utilised Amount for Mixed Payment LC
            TYPE.OF.LC = "Mixed Payment"
            GOSUB GET.LIMIT.PRODUCTS ;*Get Limit Products
            LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency>
            GOSUB GET.MIXED.PAY.LIMIT.AMOUNT ;*Compute limit amount for Mixed LC
    END CASE
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LIMIT.PRODUCTS>
*** <desc>Fetches limit product details</desc>
GET.LIMIT.PRODUCTS:
*-----------------
    PRODUCT = R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParProductNo,APP> ;*Get Limit Product for Letter of Credit Application
    NO.OF.PROD = DCOUNT(PRODUCT,@SM) ;*Compute the no of products
    LIMIT.IDS = '' ;*Initialise variable
    FOR PROD = 1 TO NO.OF.PROD ;*Iterate over no of products
        GOSUB GET.LIMIT.ID ;*Get Limit Id from Product
        GOSUB GET.LIMIT.AMOUNT ;*Calcuate Available and Utilised Amount
    NEXT PROD
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LIMIT.ID>
*** <desc>Get list of limit ids based on the product</desc>
GET.LIMIT.ID:
*-----------
    GLOBAL.LIMIT = ''
    PARENT.LIMIT = ''
    LIMIT.REF = FIELD(PRODUCT,@SM,PROD)
    ORIG.LIMIT.REF = LIMIT.REF
    GOSUB CHECK.PARENT.LIMIT ;* Fetch the Parent Limit to get the Global Limit Id
    GOSUB GET.LIMIT.IDS ;*Select Limit records based on Limit Id
    IF NOT(LIMIT.IDS) THEN
        LIMIT.REF = ORIG.LIMIT.REF
        GOSUB GET.LIMIT.IDS
    END
RETURN

*** </region>
*-------------------------------------------------------------------------------------
*** <region name= CHECK.PARENT.LIMIT>
*******************
CHECK.PARENT.LIMIT:
*******************
    LIMIT.IDS.LIST = ''
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = DAS.LIMIT.REFERENCE$REFERENCE.CHILD ;*Select Limit Reference based on Product
    THE.ARGS = LIMIT.REF ;*Parent Limit
    EB.DataAccess.Das("LIMIT.REFERENCE",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    PARENT.LIMIT = THE.LIST
    IF PARENT.LIMIT THEN
        GOSUB CHECK.GLOBAL.LIMIT
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.GLOBAL.LIMIT>
*******************
CHECK.GLOBAL.LIMIT:
*******************
    LIMIT.IDS.LIST = ''
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.LIST = DAS.LIMIT.REFERENCE$REFERENCE.CHILD ;*Select Limit Reference based on Product
    THE.ARGS = PARENT.LIMIT
    EB.DataAccess.Das("LIMIT.REFERENCE",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    GLOBAL.LIMIT = THE.LIST ;*Global Limit Id
    IF GLOBAL.LIMIT THEN
        LIMIT.REF = GLOBAL.LIMIT[1,1] : PARENT.LIMIT ;*Form Limit Id based on Global Limit Id
    END
RETURN

*** </region>
*-------------------------------------------------------------------------------------
*** <region name= GET.LIMIT.IDS>
**************
GET.LIMIT.IDS:
**************
    TABLE.SUFFIX = ''
    THE.LIST = ''
    IF R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParKeyType> EQ "TXN.REF" THEN		;* fetch limit ids based on new limit structure
        THE.ARGS = ''
        THE.LIST = dasLimitIdsWithCustomerandProduct
        THE.ARGS = CIB.CUSTOMER:@FM:LIMIT.REF
    END ELSE
        FORM.LIMIT.ID = CIB.CUSTOMER : "." : FMT(LIMIT.REF,"7'0'R") ;*Form Limit Id
        THE.LIST = dasLimitIdsLike  ;*Limit with Id like Customer and Limit Ref
        THE.ARGS = FORM.LIMIT.ID:"..."
    END
    EB.DataAccess.Das("LIMIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
    LIMIT.IDS<1,-1> = THE.LIST

RETURN
 
*** </region>
*-------------------------------------------------------------------------------------
*** <region name= GET.LIMIT.AMOUNT>
*** <desc>Fetches limit record details for each limit id</desc>
GET.LIMIT.AMOUNT:
*---------------
    LOOP
        REMOVE LIMIT.ID FROM LIMIT.IDS SETTING LIMIT.ID.POS ;*Remove each limit id and iterate with it
    WHILE LIMIT.ID:LIMIT.ID.POS
        GOSUB READ.LIMIT ;*Read limit record
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.SIGHT.LIMIT.AMOUNT>
*** <desc>Compute limit amount for Sight LC</desc>
GET.SIGHT.LIMIT.AMOUNT:
*---------------------
    IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit record currency is foreign currency, then calculate the amount using Exch Rate Routine
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        SIGHT.AVAILABLE.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Sight Available Amount
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.TotalOs>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        SIGHT.UTILISED.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Sight Utilised Amount
    END ELSE
        SIGHT.AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        SIGHT.UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.ACCEPT.LIMIT.AMOUNT>
*** <desc>Compute limit amount for Acceptance LC</desc>
GET.ACCEPT.LIMIT.AMOUNT:
*----------------------
    IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit record currency is foreign currency, then calculate the amount using Exch Rate Routine
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        ACCEPT.AVAILABLE.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Accept Available Amount
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.TotalOs>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        ACCEPT.UTILISED.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Accept Utilised Amount
    END ELSE
        ACCEPT.AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        ACCEPT.UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.DEFERRED.LIMIT.AMOUNT>
*** <desc>Compute limit amount for Deferred LC</desc>
GET.DEFERRED.LIMIT.AMOUNT:
*------------------------
    IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit record currency is foreign currency, then calculate the amount using Exch Rate Routine
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        DEFERRED.AVAILABLE.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Deferred Available Amount
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.TotalOs>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        DEFERRED.UTILISED.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Deferred Utilised Amount
    END ELSE
        DEFERRED.AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        DEFERRED.UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.NEGO.LIMIT.AMOUNT>
*** <desc>Compute limit amount for Negotiable LC</desc>
GET.NEGO.LIMIT.AMOUNT:
*--------------------
    IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit record currency is foreign currency, then calculate the amount using Exch Rate Routine
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        NEGO.AVAILABLE.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Nego Available Amount
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.TotalOs>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        NEGO.UTILISED.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Nego Utilised Amount
    END ELSE
        NEGO.AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        NEGO.UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MIXED.PAY.LIMIT.AMOUNT>
*** <desc>Compute limit amount for Mixed LC</desc>
GET.MIXED.PAY.LIMIT.AMOUNT:
*-------------------------
    IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit record currency is foreign currency, then calculate the amount using Exch Rate Routine
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        MIXED.PAY.AVAILABLE.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Mixed Payment Available Amoun
        AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.TotalOs>
        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
        MIXED.PAY.UTILISED.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Mixed Payment Utilised Amount
    END ELSE
        MIXED.PAY.AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt>
        MIXED.PAY.UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LIMIT>
*** <desc>Read Limit record</desc>
READ.LIMIT:
*---------
    R.LIMIT.REC = ''
    LIMIT.REC.ERR = ''
    R.LIMIT.REC = LI.Config.Limit.Read(LIMIT.ID, LIMIT.REC.ERR) ;*Read Limit Record

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.PENDING.AMT>
*** <desc>Compute pending amount</desc>
GET.PENDING.AMT:
****************
    GOSUB GET.LC.AMT ;*Get Pending Amount from LC records
    GOSUB GET.LCAMD.AMT ;*Get Pending Amount from LC Amendment records
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LC.AMT>
*** <desc>Compute pending amount for LC records</desc>
GET.LC.AMT:
*---------
    TABLE.SUFFIX = '$NAU'
    GOSUB GET.LCS.PEND.AMT  ;*Calculate Pending Amt for Unauthorised LCs
    TABLE.SUFFIX = ''
    GOSUB GET.LCS.PEND.AMT ;*Calculate Pending Amt for Live LCs
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LCAMD.AMT>
*** <desc>Compute pending amount for LC amendment records</desc>
GET.LCAMD.AMT:
*------------
    TABLE.SUFFIX = '$NAU'
    GOSUB GET.LCAMD.UNAUTH.PEND.AMT  ;*Calculate Pending Amt for Unauthorised LCs
    TABLE.SUFFIX = ''
    GOSUB GET.LCAMD.LIVE.PEND.AMT ;*Calculate Pending Amt for Live LCs
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LCAMD.UNAUTH.PEND.AMTT>
*** <desc>Compute pending amount for LC amendment Nau records</desc>
GET.LCAMD.UNAUTH.PEND.AMT:
*------------------------
    THE.LIST = ''
    THE.LIST = EB.DataAccess.DasAllIds ;*Select all LC Amendments
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch LC amendment records
    PEND.LIMIT.LIST.LCAMD = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM PEND.LIMIT.LIST.LCAMD SETTING PEND.LIMIT.LC.AMD.POS
    WHILE LC.AMD.ID:PEND.LIMIT.LC.AMD.POS
        R.LC.AMENDMENTS = ''
        LC.AMEND.REC.ERR = ''
        R.LC.AMENDMENTS = LC.Contract.tableAmendments(LC.AMD.ID,LC.AMEND.REC.ERR)
        AMD.INPUTTER = R.LC.AMENDMENTS<LC.Contract.Amendments.AmdInputter>
        EB.EXT.USER.ID = FIELD(AMD.INPUTTER,'_',2)
        GOSUB READ.EB.EXTERNAL.USER ;*Read external user record
        IF R.EB.EXTERNAL.USER AND R.LC.AMENDMENTS<LC.Contract.Amendments.AmdRecordStatus>[2,2] EQ 'NA' AND R.LC.AMENDMENTS<LC.Contract.Amendments.AmdIncDecAmount> AND R.LC.AMENDMENTS<LC.Contract.Amendments.AmdIbEventStatus> MATCHES "":@VM:"With Customer" THEN
            GOSUB CALC.LC.AMD.PEND.AMT ;*Compute pending amount for LC amendments
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LCAMD.LIVE.PEND.AMT>
*** <desc>Compute pending amount for LC amendment LIVE records</desc>
GET.LCAMD.LIVE.PEND.AMT:
*----------------------
    THE.LIST = ''
    THE.LIST = EB.DataAccess.DasAllIds
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch LC amendment records
    PEND.LIMIT.LIST.LCAMD = THE.LIST
    LOOP
        REMOVE LC.AMD.ID FROM PEND.LIMIT.LIST.LCAMD SETTING PEND.LIMIT.LC.AMD.POS
    WHILE LC.AMD.ID:PEND.LIMIT.LC.AMD.POS
        R.LC.AMENDMENTS = ''
        LC.AMEND.REC.ERR = ''
        R.LC.AMENDMENTS =  LC.Contract.tableAmendments(LC.AMD.ID,LC.AMEND.REC.ERR)
        IF R.LC.AMENDMENTS AND R.LC.AMENDMENTS<LC.Contract.Amendments.AmdIncDecAmount> AND R.LC.AMENDMENTS<LC.Contract.Amendments.AmdIbEventStatus> MATCHES "With Bank":@VM:"With Customer" AND R.LC.AMENDMENTS<LC.Contract.Amendments.AmdLimitUpdate> EQ 'YES' THEN
            GOSUB CALC.LC.AMD.PEND.AMT ;*Compute pending amount for LC amendments
        END
    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CALC.LC.AMD.PEND.AMT>
*** <desc>Computes pending amount for LC amendment LIVE records</desc>
CALC.LC.AMD.PEND.AMT:
*-------------------
    GOSUB READ.LC ;*Read LC record
    IB.LIMIT = R.LC.REC<LC.Contract.LetterOfCredit.TfLcIbLimit>
    LC.CCY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency>
    IF IB.LIMIT EQ 'NO' AND R.LC.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno> EQ CIB.CUSTOMER THEN
        LC.TYPE = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcType> ;*Get Pay Terms from LC Record
        GOSUB READ.LC.TYPES
        IF R.LC.TYPES AND R.LC.TYPES<LC.Config.Types.TypImportExport> EQ 'I' THEN
            PAY.TYPE = R.LC.TYPES<LC.Config.Types.TypPayType>
            BEGIN CASE
                CASE PAY.TYPE EQ 'P'
                    GOSUB GET.LCAMD.PENDING.AMT
                    SIGHT.PENDING.AMT += LCAMD.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Sight LCs
                CASE PAY.TYPE EQ 'A'
                    GOSUB GET.LCAMD.PENDING.AMT
                    ACCEPT.PENDING.AMT += LCAMD.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Acceptance LC
                CASE PAY.TYPE EQ 'D'
                    GOSUB GET.LCAMD.PENDING.AMT
                    DEFERRED.PENDING.AMT += LCAMD.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Deferred LC
                CASE PAY.TYPE MATCHES 'N':@VM:'NS':@VM:'NA'
                    GOSUB GET.LCAMD.PENDING.AMT
                    NEGO.PENDING.AMT += LCAMD.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Negotiation
                CASE PAY.TYPE EQ 'M'
                    GOSUB GET.LCAMD.PENDING.AMT
                    MIXED.PAY.PENDING.AMT += LCAMD.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Mixed Payment
            END CASE
        END
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LCS.PEND.AMT>
*** <desc>Computes pending amount for LC records based on the LC type</desc>
GET.LCS.PEND.AMT:
*---------------
    THE.LIST = ''
    THE.ARGS<1> = "IO" ;*Operation
    THE.ARGS<2> = "" ;*Limit Reference
    THE.LIST = dasLetterOfCreditInternetLcsLimit ;*Select LC records based on Operation and LIMIT.REFERENCE field
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    PEND.LIMIT.LIST.LCS = THE.LIST
    LOOP
        REMOVE LC.REC.ID FROM PEND.LIMIT.LIST.LCS SETTING PEND.LIMIT.LC.POS
    WHILE LC.REC.ID:PEND.LIMIT.LC.POS
        IF TABLE.SUFFIX NE '' THEN
            GOSUB READ.UNAUTH.LC
        END ELSE
            GOSUB READ.LC
        END
        LC.CCY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency>
        LC.PAY.TERMS = R.LC.REC<LC.Contract.LetterOfCredit.TfLcPayTerms> ;*Get Pay Terms from LC Record
        BEGIN CASE
            CASE LC.PAY.TERMS EQ 'Sight'
                GOSUB GET.LC.PENDING.AMT
                SIGHT.PENDING.AMT += LC.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation
            CASE LC.PAY.TERMS EQ 'Acceptance'
                GOSUB GET.LC.PENDING.AMT
                ACCEPT.PENDING.AMT += LC.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Acceptance LC
            CASE LC.PAY.TERMS EQ 'Deferred'
                GOSUB GET.LC.PENDING.AMT
                DEFERRED.PENDING.AMT += LC.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Deferred LC
            CASE LC.PAY.TERMS MATCHES 'Nego.Sight':@VM:'Nego.Acceptance'
                GOSUB GET.LC.PENDING.AMT
                NEGO.PENDING.AMT += LC.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Negotiation
            CASE LC.PAY.TERMS EQ 'Mixed.Payment'
                GOSUB GET.LC.PENDING.AMT
                MIXED.PAY.PENDING.AMT += LC.PENDING.AMT ;*Sum of Liability Amount which is pending for Limit updation for Mixed Payment
        END CASE
        LC.PENDING.AMT = ''
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LC.PENDING.AMT>
*** <desc>Compute pending amount for LC records</desc>
GET.LC.PENDING.AMT:
*-----------------
    LC.LIAB.AMT = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
    IF LC.CCY NE LIMIT.LOCAL.CCY THEN
        ST.ExchangeRate.Exchrate('1',LC.CCY,LC.LIAB.AMT,LIMIT.LOCAL.CCY,CONVERT.AMT,'','','','','')
        LC.PENDING.AMT = CONVERT.AMT
    END ELSE
        LC.PENDING.AMT = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LCAMD.PENDING.AMT>
*** <desc>Compute pending amount for LC amendment records</desc>
GET.LCAMD.PENDING.AMT:
*--------------------
    LCAMD.LIAB.AMT = R.LC.AMENDMENTS<LC.Contract.Amendments.AmdIncDecAmount>
    IF LC.CCY NE LIMIT.LOCAL.CCY THEN
        ST.ExchangeRate.Exchrate('1',LC.CCY,LCAMD.LIAB.AMT,LIMIT.LOCAL.CCY,CONVERT.AMT,'','','','','')
        LCAMD.PENDING.AMT = CONVERT.AMT
    END ELSE
        LCAMD.PENDING.AMT = R.LC.AMENDMENTS<LC.Contract.Amendments.AmdIncDecAmount>
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.ARRAYS>
*** <desc>Form an array of limit amount details based on the LC type</desc>
FORM.ARRAYS:
*----------
    GOSUB FORM.SIGHT.ARRAY
    GOSUB FORM.ACCEPTANCE.ARRAY
    GOSUB FORM.DEFERRED.ARRAY
    GOSUB FORM.NEGO.ARRAY
    GOSUB FORM.MIXED.PAY.ARRAY
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.SIGHT.ARRAY>
*** <desc>Form an array of limit amount details for Sight LC</desc>
FORM.SIGHT.ARRAY:
*---------------
    FINAL.ARRAY<-1> = "Sight":"*":SIGHT.AVAILABLE.AMT:"*":SIGHT.UTILISED.AMT:"*":SIGHT.PENDING.AMT ;*Form Sight Array which contains Available,Utilised and Pending Amounts
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.ACCEPTANCE.ARRAY>
*** <desc>Form an array of limit amount details for Acceptance LC</desc>
FORM.ACCEPTANCE.ARRAY:
*--------------------
    FINAL.ARRAY<-1> = "Acceptance":"*":ACCEPT.AVAILABLE.AMT:"*":ACCEPT.UTILISED.AMT:"*":ACCEPT.PENDING.AMT ;*Form Acceptance Array which contains Available,Utilised and Pending Amounts
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.DEFERRED.ARRAY>
*** <desc>Form an array of limit amount details for Deferred LC</desc>
FORM.DEFERRED.ARRAY:
*------------------
    FINAL.ARRAY<-1> = "Deferred":"*":DEFERRED.AVAILABLE.AMT:"*":DEFERRED.UTILISED.AMT:"*":DEFERRED.PENDING.AMT ;*Form Deferred Array which contains Available,Utilised and Pending Amounts
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.NEGO.ARRAY>
*** <desc>Form an array of limit amount details for Negotiation LC</desc>
FORM.NEGO.ARRAY:
*--------------
    FINAL.ARRAY<-1> = "Negotiation":"*":NEGO.AVAILABLE.AMT:"*":NEGO.UTILISED.AMT:"*":NEGO.PENDING.AMT ;*Form Negotiation Array which contains Available,Utilised and Pending Amounts
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.MIXED.PAY.ARRAY>
*** <desc>Form an array of limit amount details for Mixed LC</desc>
FORM.MIXED.PAY.ARRAY:
*-------------------
    FINAL.ARRAY<-1> = "Mixed Payment":"*":MIXED.PAY.AVAILABLE.AMT:"*":MIXED.PAY.UTILISED.AMT:"*":MIXED.PAY.PENDING.AMT:"*":LIMIT.ID ;*Form Mixed Payment Array which contains Available,Utilised and Pending Amounts
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CONVERT.LOCAL.CCY.AMT
*** <desc>Converts the amount in foreign currency to local currency</desc>
CONVERT.LOCAL.CCY.AMT:
*--------------------
    ST.ExchangeRate.Exchrate('1',LIMIT.REC.CCY,AMT.TO.CONVERT,LIMIT.LOCAL.CCY,CONVERTED.AMT,'','','','','')
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC.TYPES>
*** <desc>Reads LC types record</desc>
READ.LC.TYPES:
*------------
    R.LC.TYPES = '' ;*Initialising record variable
    LC.TYPE.REC.ERR = '' ;*Initialising error variable
    R.LC.TYPES = LC.Config.Types.Read(LC.TYPE.ID, LC.TYPE.REC.ERR) ;*Read LC Types
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.LC>
*** <desc>Reads LC Nau record</desc>
READ.UNAUTH.LC:
*-------------
    R.LC.REC = '' ;*Initialising record variable
    LC.NAU.REC.ERR = '' ;*Initialising error variable
    R.LC.REC = LC.Contract.LetterOfCredit.ReadNau(LC.REC.ID,LC.NAU.REC.ERR) ;*Read LC Nau record
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>Reads LC record</desc>
READ.LC:
*------
    R.LC.REC = '' ;*Initialising record variable
    LC.REC.ERR = '' ;*Initialising error variable
    R.LC.REC = LC.Contract.tableLetterOfCredit(LC.REC.ID,LC.REC.ERR) ;*Read LC Live record
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.EB.EXTERNAL.USER>
*** <desc>Reads external user record</desc>
READ.EB.EXTERNAL.USER:
*--------------------
    R.EB.EXTERNAL.USER = '' ;*Initialising record variable
    EB.EXT.REC.ERR  = '' ;*Initialising error variable
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(EB.EXT.USER.ID, EB.EXT.REC.ERR) ;*Read EB External User based on Inputter field value
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
