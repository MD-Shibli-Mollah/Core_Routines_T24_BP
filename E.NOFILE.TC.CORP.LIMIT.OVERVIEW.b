* @ValidationCode : Mjo4MTkzMDc5Mzk6Q3AxMjUyOjE2MDcwNTgyMzgzNTM6bWtpcnRoYW5hOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMTEtMTIxMDoyNTQ6MjIw
* @ValidationInfo : Timestamp         : 04 Dec 2020 10:33:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mkirthana
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 220/254 (86.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-112</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels

SUBROUTINE E.NOFILE.TC.CORP.LIMIT.OVERVIEW(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which computes limit amount for LetterOfCredit(LC) and Miscellaneous Deals(MD)
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.CORP.LIMIT.OVERVIEW using the Standard selection NOFILE.TC.CORP.LIMIT.OVERVIEW
* IN Parameters      : NIL
* Out Parameters     : An Array of limit details such as Application Name,Total Sanctioned Amount,Total Utilised Amount,
*                      Total Available Amount and Pending Amount(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
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
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LIMIT
    $INSERT I_DAS.LC.TYPES
    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LIMIT.REFERENCE
    $INSERT I_DAS.LC.AMENDMENTS
    $INSERT I_DAS.MD.IB.REQUEST

    $USING LC.Channels
    $USING LC.Contract
    $USING MD.Contract
    $USING EB.DataAccess
    $USING EB.Browser
    $USING EB.SystemTables
    $USING LC.Config
    $USING LI.Config
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING EB.Reports
    $USING EB.ErrorProcessing
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing logic. </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
    
    OVERALL.LIMIT = LC.SANCTIONED.AMT + MD.SANCTIONED.AMT ;*Overall limit is sum of LC and MD Sanctioned Amount
    FINAL.ARRAY := "*":OVERALL.LIMIT
    RET.DATA = FINAL.ARRAY ;*Pass the final array values to Ret Data
    
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
    LIMIT.LOCAL.CCY = EB.SystemTables.getLccy() ;*Get Local Ccy
    
    LC.SANCTIONED.AMT = 0;MD.SANCTIONED.AMT = 0;OVERALL.LIMIT = 0;TOT.AVAILABLE.AMT = 0;TOT.SANCTIONED.AMT = 0 ;*Initialising variables
    TOT.UTILISED.AMT = 0;STORE.LIMIT.ID = '';APPL.NAME='';RET.DATA = '';FINAL.ARRAY = '' ;*Initialising variables
    
    GOSUB RESET.VARIABLES ;*Reset variables
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>This has the main processing logic to appropriately select the bulk payment records </desc>
PROCESS:
*------
    R.LIMIT.LIAB = ''
    LIMIT.LIAB.ERR = ''
    RESERVED1 = ''
    RESERVED2 = ''
    R.LIMIT.LIAB = LI.Config.tableLimitLiability(CIB.CUSTOMER,LIMIT.LIAB.ERR)  ;*Check if limit is available for CIB Customer
    IF R.LIMIT.LIAB THEN
        LI.Config.GetLimitParameterRecord('LETTER.OF.CREDIT', R.LIMIT.PARAMETER, RESERVED1, RESERVED2) ;*Read LETTER.OF.CREDIT record of limit parameter application
        IF R.LIMIT.PARAMETER THEN
            APPL.NAME = R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParApplication>
            NO.OF.APP = DCOUNT(APPL.NAME,@VM)
            GOSUB GET.LC.LIMIT.AMOUNT ;*Form Limit Ids and calculate LC limit amount
            IF TOT.AVAILABLE.AMT THEN
                GOSUB GET.LC.PENDING.AMT ;*Calculate Pending amt from LC and LC Amendment records
                GOSUB FORM.LIMIT.ARRAY ;*Form array for Letter of Credit
            END
        END
        GOSUB RESET.VARIABLES ;*Reset variables
        LI.Config.GetLimitParameterRecord('MD.DEAL', R.LIMIT.PARAMETER, RESERVED1, RESERVED2) ;*Read MD.DEAL record of limit parameter application
        IF R.LIMIT.PARAMETER THEN
            APPL.NAME = R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParApplication>
            NO.OF.APP = DCOUNT(APPL.NAME,@VM)
            GOSUB GET.MD.LIMIT.AMOUNT ;*;*Form Limit Ids and calculate Guarantees limit amount
            IF TOT.AVAILABLE.AMT THEN
                GOSUB GET.MD.PENDING.AMT ;*Calculate Pending amt from MD.IB.REQUEST
                GOSUB FORM.LIMIT.ARRAY ;*Form array for Guarantees
            END
        END
        GOSUB RESET.VARIABLES ;*Reset variables
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LC.LIMIT.AMOUNT>
*** <desc>Computes Total sanctioned amount for Letter of credit</desc>
GET.LC.LIMIT.AMOUNT:
*------------------
    
    FOR APP.NAME = 1 TO NO.OF.APP
        IF R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParApplication,APP.NAME> EQ 'LETTER.OF.CREDIT' THEN ;*Loop should continue in LIMIT.PARAMETERS only if Application is "Letter of credit"
            APPL.NAME = "Letter of credit" ;*Set Appl Name to form LC array
            GOSUB GET.LIMIT.PROD
        END
    NEXT APP.NAME
    LC.SANCTIONED.AMT = TOT.SANCTIONED.AMT ;*Total Sanctioned amount of LC will be available in LC.SANCTIONED.AMT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MD.LIMIT.AMOUNT>
*** <desc>Computes Total sanctioned amount for Guarantees</desc>
GET.MD.LIMIT.AMOUNT:
*------------------

    FOR APP.NAME = 1 TO NO.OF.APP
        IF R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParApplication,APP.NAME> EQ 'MD.DEAL' THEN ;*Loop should continue in LIMIT.PARAMETERS only if Application is "MD Deal"
            APPL.NAME = "Guarantees" ;*Set Appl Name to form Guarantees array
            GOSUB GET.LIMIT.PROD
        END
    NEXT APP.NAME
    MD.SANCTIONED.AMT = TOT.SANCTIONED.AMT ;*Total Sanctioned amount of Guarantees will be available in MD.SANCTIONED.AMT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LIMIT.PROD>
*** <desc>Fetches Limit details based on the product</desc>
GET.LIMIT.PROD:
*-------------
    PRODUCT = R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParProductNo,APP.NAME>
    NO.OF.PROD = DCOUNT(PRODUCT,@SM) ;*Get Limit Product from Limit Parameter
    FOR PROD = 1 TO NO.OF.PROD
        GOSUB GET.PARENT.LIMIT ;*Based on the product, get parent limit Id
        IF LIMIT.IDS.LIST THEN ;*For retrieved Limit Ids, calculate limit amount
            GOSUB GET.LIMIT.AMOUNT
        END
    NEXT PROD
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.PARENT.LIMIT>
*** <desc>Fetches parent limit details based on the product</desc>
GET.PARENT.LIMIT:
*---------------
    LIMIT.REF = FIELD(PRODUCT,@SM,PROD)
    LIMIT.IDS.LIST = ''
    TABLE.SUFFIX = ''
    THE.ARGS=''
    THE.LIST = ''
    THE.LIST = DAS.LIMIT.REFERENCE$REFERENCE.CHILD ;*Select Limit Reference based on Product
    THE.ARGS = LIMIT.REF
    EB.DataAccess.Das("LIMIT.REFERENCE",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    IF THE.LIST THEN
        IF  R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParKeyType> NE "TXN.REF" THEN   ;* skip for new limit structure
            LIMIT.REF = THE.LIST  ;*Get Parent Limit reference based on the reference from Parameter record
        END
        THE.ARGS=''
        IF R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParKeyType> EQ "TXN.REF" THEN  ;* fetch limit ids for new limit structure
            DAS.LIST = dasLimitIdsWithCustomerandProduct
            THE.ARGS = CIB.CUSTOMER:@FM:LIMIT.REF
        END ELSE
            DAS.LIST = dasLimitIdsLike
            THE.ARGS = CIB.CUSTOMER:".":"...":LIMIT.REF:"..."
        END
        EB.DataAccess.Das("LIMIT",DAS.LIST,THE.ARGS,TABLE.SUFFIX)  ;*Get Limit Ids based on the customer and limit reference
        IF DAS.LIST THEN
            LIMIT.IDS.LIST<1,-1> = DAS.LIST ;*Array of Limit references
        END
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LIMIT.AMOUNT>
*** <desc>Computes sanctioned,utilised and available limit amounts</desc>
GET.LIMIT.AMOUNT:
*---------------

    LOOP
        REMOVE LIMIT.ID FROM LIMIT.IDS.LIST SETTING LIMIT.ID.POS
    WHILE LIMIT.ID:LIMIT.ID.POS
        LOCATE LIMIT.ID IN STORE.LIMIT.ID<1,1> SETTING LIMIT.ID.EXISTS ELSE ;*Loop should not continue for same limit which is already calcuated.
            IF NOT(FIELD(LIMIT.ID,".",4)) THEN
                GOSUB READ.LIMIT ;*Read Limit
                LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency> ;*Get Limit Currency
                PRD.ALWD = R.LIMIT.REC<LI.Config.Limit.ProductAllowed>
                IF PRD.ALWD OR R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParKeyType> EQ "TXN.REF" THEN ;*Check if Product Allowed contains value, then calculate amounts
                    IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit rec currency is foreign currency, then calculate the amounts calling Exch Rate
                        SANCTIONED.AMT = R.LIMIT.REC<LI.Config.Limit.InternalAmount> ;*Internal amount value is set in Sanctioned Amount
                        AMT.TO.CONVERT = SANCTIONED.AMT
                        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                        TOT.SANCTIONED.AMT += CONVERTED.AMT ;*Set converted amount in Tot Sanctioned amt
                        UTILISED.AMT = R.LIMIT.REC<LI.Config.Limit.TotalOs> ;*Total Os Amount value is set in Utilised Amount
                        AMT.TO.CONVERT = UTILISED.AMT
                        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                        TOT.UTILISED.AMT += CONVERTED.AMT ;*Set converted amount in Tot Utilised amt
                        AVAILABLE.AMT = R.LIMIT.REC<LI.Config.Limit.AvailAmt> ;*Avail Amount value is set in Available Amount
                        AMT.TO.CONVERT = AVAILABLE.AMT
                        GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                        TOT.AVAILABLE.AMT += CONVERTED.AMT ;*Set converted amount in Tot Available amt
                    END ELSE
                        TOT.SANCTIONED.AMT += R.LIMIT.REC<LI.Config.Limit.InternalAmount> ;*Internal amount value is set in Tot Sanctioned Amount
                        TOT.UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs> ;*Total Os Amount value is set in Tot Utilised Amount
                        TOT.AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt> ;*Avail Amount value is set in Tot Available Amount
                    END
                    STORE.LIMIT.ID<1,-1> = LIMIT.ID ;*Store the limit ids to avoid duplicate
                    SANCTIONED.AMT = 0 ;*Reset the value for next iteration
                    UTILISED.AMT = 0 ;*Reset the value for next iteration
                    AVAILABLE.AMT = 0 ;*Reset the value for next iteration
                    AMT.TO.CONVERT = 0 ;*Reset the value for next iteration
                    CONVERTED.AMT = 0 ;*Reset the value for next iteration
                END
            END
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LIMIT>
*** <desc>Reads Limit record</desc>
READ.LIMIT:
*---------
    R.LIMIT.REC = ''
    LIMIT.REC.ERR = ''
    R.LIMIT.REC = LI.Config.Limit.Read(LIMIT.ID, LIMIT.REC.ERR) ;*Read Limit Record

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LC.PENDING.AMT>
*** <desc>Computes pending limit amount for LC</desc>
GET.LC.PENDING.AMT:
*-----------------
*LC Pending Amount
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.ARGS=''
    THE.ARGS = CIB.CUSTOMER
    THE.LIST = dasLetterOfCreditWithIbLimit  ;*Select Lc's with applicant cust is CIB and IB.LIMIT is No and Operation is "IO"
    EB.DataAccess.Das("LETTER.OF.CREDIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch LC records associated with the Corporate customer
    LC.LIST = THE.LIST
    LOOP
        REMOVE LC.ID FROM LC.LIST SETTING LC.REC.POS ;*Remove each LC id and iterate with it
    WHILE LC.ID:LC.REC.POS
        GOSUB READ.LC ;*Read LC record
        IF R.LC.REC THEN
            LC.LIAB.AMT = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt> ;*Extract LC liability amount and set it to a variable
            IF R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit rec currency is foreign currency, then calculate the amounts calling Exch Rate
                LC.CCY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> ;*Extract currency value and set it to a variable
                LIMIT.REC.CCY = LC.CCY
                AMT.TO.CONVERT = LC.LIAB.AMT
                GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                TOT.LC.LIAB.AMT += CONVERTED.AMT ;*Set converted amount in Tot LC Liability amt
            END ELSE
                TOT.LC.LIAB.AMT += R.LC.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt> ;*Sum of Liability amount is stored in Tot LC Liab Amt
            END
        END
    REPEAT

*LC Amendment Pending Amount
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.ARGS=''
    THE.ARGS<1> = "With Bank"
    THE.ARGS<2> = "With Customer"
    THE.LIST = dasLcAmendmentsEventStatus  ;*Select Lc's with applicant cust is CIB and IB.LIMIT is No and Operation is "IO"
    EB.DataAccess.Das("LC.AMENDMENTS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    LCAMD.LIST = THE.LIST
    LOOP
        REMOVE LCAMD.ID FROM LCAMD.LIST SETTING LCAMD.REC.POS ;*Remove each LC amendment id and iterate with it
    WHILE LCAMD.ID:LCAMD.REC.POS
        R.LCAMD.REC = '' ;*Initialise record variable
        LCAMD.REC.ERR = '' ;*Initialise error variable
        R.LCAMD.REC = LC.Contract.tableAmendments(LCAMD.ID,LCAMD.REC.ERR) ;*Read LC Amendments
        LC.ID = LCAMD.ID[1,12]
        GOSUB READ.LC
        IF R.LCAMD.REC AND R.LC.REC<LC.Contract.LetterOfCredit.TfLcIbLimit> EQ 'NO' THEN ;*Calculate Pending Amount only when Ib Limit is set as 'No'
            LCAMD.INC.DEC.AMT = R.LCAMD.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Get Inc Dec Amount from LC Amendments
            LIMIT.REC.CCY = R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency>
            IF R.LC.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit rec currency is foreign currency, then calculate the amounts calling Exch Rate
                AMT.TO.CONVERT = LCAMD.INC.DEC.AMT
                GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                TOT.LCAMD.INC.DEC.AMT += CONVERTED.AMT ;*Set converted amount in Tot LC Liability amt
            END ELSE
                TOT.LCAMD.INC.DEC.AMT += R.LCAMD.REC<LC.Contract.Amendments.AmdIncDecAmount> ;*Sum of Inc Dec amount is stored in Tot LC Amd Inc Dec Amt
            END
        END
    REPEAT
    PENDING.AMT = TOT.LC.LIAB.AMT + TOT.LCAMD.INC.DEC.AMT ;*Pending Amount is sum of LC Liability Amount and LC Amd Inc Dec Amount
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MD.PENDING.AMT>
*** <desc>Computes pending amount for miscellaneous deals</desc>
GET.MD.PENDING.AMT:
*-----------------
*MD Pending Amount
    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.ARGS=''
    THE.ARGS<1> = "With Bank"
    THE.ARGS<2> = "With Customer"
    THE.LIST = dasMdIbRequestsEventStatus
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call DAS to fetch MD records associated with the corporate customer
    MD.IB.LIST = THE.LIST ;*Set the list of MD records
    LOOP
        REMOVE MD.IB.ID FROM MD.IB.LIST SETTING MD.IB.REC.POS ;*Remove each MD record and iterate with it
    WHILE MD.IB.ID:MD.IB.REC.POS
        R.MD.IB.REC = '' ;*Initialising the record variable
        MD.IB.REC.ERR = '' ;*Initialising the error variable
        R.MD.IB.REC = MD.Contract.tableIbRequest(MD.IB.ID, MD.IB.REC.ERR) ;*Read MDIB request record
        IF R.MD.IB.REC AND R.MD.IB.REC<MD.Contract.IbRequest.IbRequestCustomer> EQ CIB.CUSTOMER THEN ;*Check if MDIB request exist and is mapped to Corporate customer
            PENDING.AMT = R.MD.IB.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount> ;*Set Principal amount
            LIMIT.REC.CCY = R.MD.IB.REC<MD.Contract.IbRequest.IbRequestCurrency> ;*Set currency
            IF R.MD.IB.REC<MD.Contract.IbRequest.IbRequestCurrency> NE LIMIT.LOCAL.CCY THEN ;*When limit rec currency is foreign currency, then calculate the amounts calling Exch Rate
                AMT.TO.CONVERT = PENDING.AMT
                GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                TOT.PENDING.AMT += CONVERTED.AMT ;*Set converted amount in Tot Pending Amt
            END ELSE
                TOT.PENDING.AMT += R.MD.IB.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount> ;*Add pending amounts
            END
        END
    REPEAT
    PENDING.AMT = TOT.PENDING.AMT ;*Set total pending amount
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CONVERT.LOCAL.CCY.AMT
*** <desc>Converts the amount in foreign currency to local currency value</desc>
CONVERT.LOCAL.CCY.AMT:
*--------------------
    CONVERTED.AMT = 0
    IF AMT.TO.CONVERT THEN
        ST.ExchangeRate.Exchrate('1',LIMIT.REC.CCY,AMT.TO.CONVERT,LIMIT.LOCAL.CCY,CONVERTED.AMT,'','','','','') ;*Call Exch Rate to covert FCY amount to LCY equivalent
    END
RETURN

*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.LIMIT.ARRAY>
*** <desc>Builds the final list of Limit details for LC and MD</desc>
FORM.LIMIT.ARRAY:
*---------------
    FINAL.ARRAY<-1> = APPL.NAME:"*":TOT.SANCTIONED.AMT:"*":TOT.UTILISED.AMT:"*":TOT.AVAILABLE.AMT:"*":PENDING.AMT ;*Form Limit Array for Letter of credit and Guarantees
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LC>
*** <desc>Read LC record</desc>
READ.LC:
********
    R.LC.REC = '' ;*Initialise record variable
    LC.REC.ERR = '' ;*initialise error variable
    R.LC.REC = LC.Contract.tableLetterOfCredit(LC.ID,LC.REC.ERR) ;*Read Live LC record

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Initialise variables</desc>
RESET.VARIABLES:
*------------
    SANCTIONED.AMT = 0
    AVAILABLE.AMT = 0
    UTILISED.AMT = 0
    TOT.SANCTIONED.AMT = 0
    TOT.UTILISED.AMT = 0
    TOT.AVAILABLE.AMT = 0
    PENDING.AMT = 0
    LIMIT.ID = ''
    LIMIT.ID.POS = ''
    LIMIT.ID.EXISTS = ''
    R.LIMIT.PARAMETER = ''
    RESERVED1 = ''
    RESERVED2 = ''
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
