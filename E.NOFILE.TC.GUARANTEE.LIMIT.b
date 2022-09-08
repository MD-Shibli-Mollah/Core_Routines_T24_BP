* @ValidationCode : MjotMTY4ODk4MTc2NzpDcDEyNTI6MTYwNzA1ODEzNDcxNDpta2lydGhhbmE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4yMDIwMTExMS0xMjEwOjIwMDoxOTk=
* @ValidationInfo : Timestamp         : 04 Dec 2020 10:32:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mkirthana
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 199/200 (99.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-215</Rating>
*-----------------------------------------------------------------------------
$PACKAGE MD.Channels

SUBROUTINE E.NOFILE.TC.GUARANTEE.LIMIT(RET.DATA)

*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which computes limit amount for LetterOfCredit(LC)
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.GUARANTEE.LIMIT using the Standard selection NOFILE.TC.GUARANTEE.LIMIT
* IN Parameters      : NIL
* Out Parameters     : An Array of limit details such as Category description, Available Amount, Utilised Amount and Pending Amount(RET.DATA)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Guarantees
*
* 13/07/2019  - Enhancement 2875478 / Task 3255847
*             TCIB2.0 Corporate - IRIS R18 API's - Adding customer selection field
*
* 19/10/20 - Task :4031723
*            Limit Overview and Limit Utilisation Graph is not displaying in Trade Finance.
*            Defect : 3843924
*
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine. </desc>

    $INSERT I_DAS.LIMIT
    $INSERT I_DAS.MD.DEAL
    $INSERT I_DAS.MD.IB.REQUEST

    $USING MD.Channels
    $USING LI.Config
    $USING ST.Config
    $USING MD.Contract
    $USING EB.DataAccess
    $USING EB.Browser
    $USING EB.SystemTables
    $USING ST.ExchangeRate
    $USING EB.ErrorProcessing
    $USING EB.Reports

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAINPROCESSING>
*** <desc>Main Processing logic. </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
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
    RESERVED1 = ''
    RESERVED2 = ''
    LI.Config.GetLimitParameterRecord('MD.DEAL', R.LIMIT.PARAMETER, RESERVED1, RESERVED2) ;*Read MD.DEAL record of Limit Parameter application
    
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>To fetch limit details for Miscellaneous deals (MD) application</desc>
PROCESS:
*------

    GOSUB GET.PENDING.AMT ;*Calcuate Pending Amount from MD IB Request

    TABLE.SUFFIX = ''
    THE.LIST = ''
    THE.ARGS = ''
    THE.LIST = dasMdDealCib  ;*Select MD Deal based on Customer and Contract Type
    THE.ARGS<1> = CIB.CUSTOMER ;*CUSTOMER field in MD Deal
    THE.ARGS<2> = "CA" ;*Contract Type in MD Deal
    EB.DataAccess.Das("MD.DEAL",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call Das routine to select MD Deal records based on THE.ARGS
    SEL.LIVE.MD.LIST<-1> = THE.LIST ;*Selected record Ids will be available in THE.LIST
    LOOP
        REMOVE MD.ID FROM SEL.LIVE.MD.LIST SETTING MD.POS  ;*Loop for each MD record from the selected list
    WHILE MD.ID:MD.POS
        GOSUB READ.MD ;*Read MD Deal
        MD.CATEG.CODE = R.MD.REC<MD.Contract.Deal.DeaCategory> ;*Get Category of MD Deal
        LOCATE MD.CATEG.CODE IN MD.CATEG.LISTS<1,1> SETTING MD.CATEG.CODE.POS ELSE ;*Locate category code to remove duplicate
            MD.CATEG.LISTS<1,-1> = MD.CATEG.CODE ;*Form an array for category codes
        END
    REPEAT

    NO.OF.MD.CATEG = DCOUNT(MD.CATEG.LISTS,@VM) ;*Count the category codes in the list
    FOR MD.CATEG = 1 TO NO.OF.MD.CATEG
        CATEG.CODE = FIELD(MD.CATEG.LISTS,@VM,MD.CATEG) ;*Get category code from the Category list
        GOSUB READ.CATEGORY ;*Read Category record
        CATEG.DESC = R.CATEGORY<ST.Config.Category.EbCatDescription>
        TABLE.SUFFIX = ''
        GOSUB MD.CATEG.LISTS;*Get Live MD IB Request records for the category
        LOOP
            REMOVE MD.ID FROM MD.RECS.LIST SETTING MD.RECS.POS
        WHILE MD.ID:MD.RECS.POS
            GOSUB READ.MD
            MD.LIMIT.REF = FIELD(R.MD.REC<MD.Contract.Deal.DeaLimitReference>,'.',1) ;*Get MD Limit Reference from MD Deal
            IF R.LIMIT.PARAMETER<LI.Config.LimitParameter.ParKeyType> EQ "TXN.REF" THEN		;* fetch limit ids based on new limit structure
                TABLE.SUFFIX = ''
                THE.ARGS = ''
                THE.LIST = dasLimitIdsWithCustomerandProduct
                THE.ARGS = CIB.CUSTOMER:@FM:MD.LIMIT.REF
                EB.DataAccess.Das("LIMIT",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
                LIMIT.ID = THE.LIST
            END ELSE
                MD.LIMIT.REF = FMT(MD.LIMIT.REF,"7'0'R") ;*Format Limit Reference
                LIMIT.ID = CIB.CUSTOMER : "." : MD.LIMIT.REF : "." : FIELD(R.MD.REC<MD.Contract.Deal.DeaLimitReference>,'.',2) ;*Form Limit Id based on Customer and Limit Reference
            END
            LOCATE LIMIT.ID IN LIMIT.IDS.LISTS<1,1> SETTING LIMIT.EXISTS.POS ELSE  ;*Populate limit ids in limit list to remove duplication
                GOSUB READ.LIMIT ;*Read Limit record
                LIMIT.REC.CCY = R.LIMIT.REC<LI.Config.Limit.LimitCurrency>
                IF R.LIMIT.REC<LI.Config.Limit.LimitCurrency> NE LIMIT.LOCAL.CCY THEN
                    AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.AvailAmt> ;*Get Available Amount from Limit Record
                    GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                    AVAILABLE.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Available Amount
                    AMT.TO.CONVERT = R.LIMIT.REC<LI.Config.Limit.TotalOs> ;*Get Utilised Amount from Limit Record
                    GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
                    UTILISED.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Utilised Amount
                END ELSE
                    AVAILABLE.AMT += R.LIMIT.REC<LI.Config.Limit.AvailAmt> ;*Get Available Amount from Limit Record
                    UTILISED.AMT += R.LIMIT.REC<LI.Config.Limit.TotalOs> ;*Get Utilised Amount from Limit Record
                    LIMIT.IDS.LISTS<1,-1> = LIMIT.ID ;*Form Limit Ids in list
                END
            END
        REPEAT
        LOCATE CATEG.CODE IN PENDING.LIMIT.CATEG<1,1> SETTING CATEG.LIST.POS THEN ;*Locate the category in the pending array and get pending amount to form an array
            PENDING.AMT = PENDING.LIMIT.AMT<1,CATEG.LIST.POS>
        END
        GOSUB FORM.ARRAY ;*Form an array for the respective category code
        GOSUB RESET.VARIABLES ;*Reset all variables to Null
    NEXT MD.CATEG
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MD.CATEG.LISTS>
*** <desc>To fetch list of categories related to MD application</desc>
MD.CATEG.LISTS:
*-------------
    THE.LIST = ''
    THE.ARGS = ''
    THE.ARGS<1> = CIB.CUSTOMER ;*Customer field in MD Deal
    THE.ARGS<2> = "CA" ;*Limit Reference
    THE.ARGS<3> = CATEG.CODE ;*Category Code in MD Deal
    THE.LIST = dasMdDealCategory  ;*Selection based on Customer,Limit Reference and Category
    EB.DataAccess.Das("MD.DEAL",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call Das routine to select the records based on THE.ARGS
    MD.RECS.LIST<-1> = THE.LIST ;*Populate the retrieved list in MD.RECS.LIST
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.PENDING.AMT>
*** <desc>Compute pending amount</desc>
GET.PENDING.AMT:
*--------------
    TABLE.SUFFIX = '$NAU'
    GOSUB GET.MDIB.LISTS  ;*Calculate Pending Amt for Unauthorised MD IB Request
    TABLE.SUFFIX = ''
    GOSUB GET.MDIB.LISTS ;*Calculate Pending Amt for Live MD IB Request
    GOSUB GET.MDIB.PEND.AMT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MDIB.LISTS>
*** <desc>Fetch list of MDIB request records based on customer and limit reference</desc>
GET.MDIB.LISTS:
*-------------
    THE.LIST = ''
    THE.ARGS<1> = CIB.CUSTOMER ;*Customer field in MD IB Request
    THE.ARGS<2> = "" ;*Limit Reference
    THE.LIST = dasMdIbRequestInternetLimit  ;*Selection based on Customer and Limit Reference
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    PEND.LIMIT.LIST.MDIB<-1> = THE.LIST ;*Lists contains Nau and Live records of MD IB Request
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.MDIB.PEND.AMT>
*** <desc>Computes pending amount for MDIB request records</desc>
GET.MDIB.PEND.AMT:
*----------------
    LOOP
        REMOVE MDIB.ID FROM PEND.LIMIT.LIST.MDIB SETTING PEND.LIMIT.MDIB.POS
    WHILE MDIB.ID:PEND.LIMIT.MDIB.POS
        GOSUB READ.UNAUTH.MDIB ;*Check if MD IB Request record exists in Nau File
        IF MDIB.NAU.REC.ERR THEN
            GOSUB READ.MDIB ;*Read Live file
        END
        MDIB.CATEG.CODE = R.MDIB.REC<MD.Contract.IbRequest.IbRequestCategory>
        LOCATE MDIB.CATEG.CODE IN CATEG.LISTS<1,1> SETTING CATEG.CODE.EXISTS.POS ELSE
            CATEG.LISTS<1,-1> = MDIB.CATEG.CODE
        END
    REPEAT

    NO.OF.CATEG = DCOUNT(CATEG.LISTS,@VM)
    FOR CATEG = 1 TO NO.OF.CATEG
        CATEG.CODE = FIELD(CATEG.LISTS,@VM,CATEG)
        GOSUB READ.CATEGORY
        TABLE.SUFFIX = '$NAU' ;*Get Unauth MD IB Request records for the category
        GOSUB MDIB.CATEG.LISTS ;*Select Unauthorise MDIB's with Limit Reference is Null for CIB Customer
        TABLE.SUFFIX = ''
        GOSUB MDIB.CATEG.LISTS;*Select Unauthorise MDIB's with Limit Reference is Null for CIB Customer
        LOOP
            REMOVE MDIB.ID FROM MDIB.RECS.LIST SETTING MDIB.RECS.POS
        WHILE MDIB.ID:MDIB.RECS.POS
            GOSUB READ.UNAUTH.MDIB ;*Check if MD IB Request record exists in Nau File
            IF MDIB.NAU.REC.ERR THEN
                GOSUB READ.MDIB ;*Read Live file
            END
            MDIB.CCY = R.MDIB.REC<MD.Contract.IbRequest.IbRequestCurrency>
            GOSUB GET.LOCAL.CCY.PEND.AMT
        REPEAT
        PENDING.LIMIT.CATEG<1,-1> = CATEG.CODE
        PENDING.LIMIT.AMT<1,-1> = PENDING.AMT
        CATEG.CODE = ''
        PENDING.AMT = ''
    NEXT CATEG
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.LOCAL.CCY.PEND.AMT>
*** <desc>Computes pending amount in local currency</desc>
GET.LOCAL.CCY.PEND.AMT:
*---------------------
    IF R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrinMovement> AND R.MDIB.REC<MD.Contract.IbRequest.IbRequestIbAmendStatus> THEN
        IF MDIB.CCY NE LIMIT.LOCAL.CCY THEN ;*When MD IB Request record currency is foreign currency, then calculate the amount using Exch Rate Routine
            AMT.TO.CONVERT = R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrinMovement>
            LIMIT.REC.CCY = MDIB.CCY
            GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
            PENDING.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Pending Amt
        END ELSE
            PENDING.AMT += R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrinMovement>
        END
    END ELSE
        IF MDIB.CCY NE LIMIT.LOCAL.CCY THEN ;*When MD IB Request record currency is foreign currency, then calculate the amount using Exch Rate Routine
            AMT.TO.CONVERT = R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount>
            LIMIT.REC.CCY = MDIB.CCY
            GOSUB CONVERT.LOCAL.CCY.AMT ;*Call Exch Rate and calculate Local Ccy amount
            PENDING.AMT += CONVERTED.AMT ;*Set converted Local Ccy amount to Pending Amt
        END ELSE
            PENDING.AMT += R.MDIB.REC<MD.Contract.IbRequest.IbRequestPrincipalAmount>
        END
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MDIB.CATEG.LISTS>
*** <desc>Fetches category lists related to MDIB request application based on customer, limit reference and category</desc>
MDIB.CATEG.LISTS:
*---------------
    THE.LIST = ''
    THE.ARGS<1> = CIB.CUSTOMER ;*Customer field in MD IB Request
    THE.ARGS<2> = "" ;*Limit Reference
    THE.ARGS<3> = FIELD(CATEG.LISTS,@VM,CATEG) ;*Category Code in MD IB Request
    THE.LIST = dasMdIbRequestCibCategory  ;*Selection based on Customer,Limit Reference and Category
    EB.DataAccess.Das("MD.IB.REQUEST",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    MDIB.RECS.LIST<-1> = THE.LIST
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= FORM.ARRAY>
*** <desc>Form an array of limit amount details</desc>
FORM.ARRAY:
*---------
    FINAL.ARRAY<-1> = CATEG.DESC:"*":AVAILABLE.AMT:"*":UTILISED.AMT:"*":PENDING.AMT ;*Pass all values into FINAL.ARRAY
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.UNAUTH.MDIB>
*** <desc>Reads MDIB request Nau record</desc>
READ.UNAUTH.MDIB:
*---------------
    R.MDIB.REC = '' ;*Initialise record variable
    MDIB.NAU.REC.ERR = '' ;*Initialise error variable
    R.MDIB.REC = MD.Contract.IbRequest.ReadNau(MDIB.ID,MDIB.NAU.REC.ERR) ;*Read Unauthorised MD IB Request

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MDIB>
*** <desc>Reads MDIB request LIVE record</desc>
READ.MDIB:
*--------
    R.MDIB.REC = '' ;*Initialise record variable
    MDIB.REC.ERR ='' ;*Initialise error variable
    R.MDIB.REC = MD.Contract.IbRequest.Read(MDIB.ID,MDIB.REC.ERR) ;*Read Live MD IB Request

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.MD>
*** <desc>Reads MD record</desc>
READ.MD:
*------
    R.MD.REC = '' ;*Initialise record variable
    MD.REC.ERR = '' ;*Initialise error variable
    R.MD.REC = MD.Contract.Deal.Read(MD.ID, MD.REC.ERR) ;* Read MD Deal

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.LIMIT>
*** <desc>Reads Limit record</desc>
READ.LIMIT:
*---------
    R.LIMIT.REC = '' ;*Initialise record variable
    LIMIT.REC.ERR = '' ;*Initialise error variable
    R.LIMIT.REC = LI.Config.Limit.Read(LIMIT.ID, LIMIT.REC.ERR) ;*Read Limit

RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= READ.CATEGORY>
*** <desc>Reads Category record</desc>
READ.CATEGORY:
*------------
    R.CATEGORY = '' ;*Initialise record variable
    CATEG.ERR = '' ;*Initialise error variable
    R.CATEGORY = ST.Config.tableCategory(CATEG.CODE,CATEG.ERR) ;*Read Category
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= CONVERT.LOCAL.CCY.AMT
*** <desc>Converts the amount in foreign currency to local currency</desc>
CONVERT.LOCAL.CCY.AMT:
*--------------------
    ST.ExchangeRate.Exchrate('1',LIMIT.REC.CCY,AMT.TO.CONVERT,LIMIT.LOCAL.CCY,CONVERTED.AMT,'','','','','')
RETURN

*---------------------------------------------------------------------------------------------------------------------
*** <region name= RESET.VARIABLES>
*** <desc>Reset variables</desc>
RESET.VARIABLES:
*--------------
    AVAILABLE.AMT = ''
    UTILISED.AMT = ''
    PENDING.AMT = ''
    CATEG.DESC = ''
    LIMIT.IDS.LISTS = ''
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
