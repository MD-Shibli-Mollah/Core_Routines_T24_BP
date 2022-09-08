* @ValidationCode : MjoyMjI2NjI0MTI6Q3AxMjUyOjE1ODYxNzE4NDA4Mzg6a3ZlbmthdGVzaDo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAzLjIwMTkwMjE5LTEyNDE6MzIzOjI5OA==
* @ValidationInfo : Timestamp         : 06 Apr 2020 16:47:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kvenkatesh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 298/323 (92.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190219-1241
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------------
$PACKAGE   T2.ModelBank
SUBROUTINE E.NOFILE.TC.USER.PROFILE(FINAL.ARRAY)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This routine used to validate license modules and user right operations and also get the permissions &  privileges
* values of the logged in user
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TC.USER.PROFILE
* IN Parameters      : NA
* Out Parameters     : FINAL.ARRAY
*                      TC.INITIAL, AALD.FLAG, CR.FLAG, PAYMENT.FLAG, LOCAL.CURRENCY, MF.FLAG, DX.FLAG, TC.OPERATION,
*                      EXT.SMS.SERVICES, EXT.SMS.OPERATIONS, PRIVILEGES.CHECK, CHNL.ID, CHNL.ARR.ID, NO.OF.ARRANGEMENTS, EXT.USER.NAME, EXT.USER.CUSTOMER, EXT.USER.TXN.SIGN, EXT.USER.LANGUAGE,
*                      EXT.USER.CUS.NAME, EXT.USER.CUS.GENDER, CHANNEL.STATUS, CHANNEL.TC.ACCEPTED, CHANNEL.USER.TYPE, CHANNEL.LOGIN.METHOD, CHANNEL.DATE.LAST.USE, CHANNEL.TIME.LAST.USE, PRODUCT,
*                      PRODUCT.DESCRIPTION, TODAY.DATE, CHNL.POS, COMPANY, EXT.USER.CUS.PHONE.1, EXT.USER.CUS.SMS.1, EXT.USER.CUS.EMAIL.1, EXT.USER.SMS.CUS, CHANNEL.START.DATE, CHANNEL.CUS.ID, CHANNEL.CUS.NAME, SUPPORTED.MODULES
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/07/17 - Enhancement 2004865 / Task 2198209
*            TCUA - TCIB Integration
*
* 28/08/17 - Enhancement 2161898 / Task 2244717
*            Authentication solution support w.r.t Multiple Arrangement set-up
*
* 05/10/17 - Defect 2291917 / Task 2295561
*            Replacing cacheRead with F.READ for EEU record reading
*
* 28/12/17 - Defect 2389247 / Task 2394975
*            Reading comapny form EEU record and passing itin final array.
* 16/02/18 - Enhancement 2462955 / Task 2462958
*            Remove the last login update and add to the FINAL.ARRAY informations from the customer
*
* 05/04/18 - Defect 2536509 / Task 2536636
*            Rolename and Customer name are not shown properly
*
* 22/08/18 - Defect 2735754 / Task 2736137
*            Exposing few more info used for TCUA as a BC development

* 10/03/19 - Enhancement 2875480 / Task 3018257
*            IRIS-R18 T24 changes - Adding fields for external user
*
* 18/03/19  - Enhancement - 2867757 / Task 3039079
*               AAG Module check has been introduced
*
*---------------------------------------------------------------------------------------------------------------------
*
    $USING AA.Framework
    $USING AA.ARC
    $USING AA.ProductManagement
    $USING EB.ARC
    $USING EB.API
    $USING EB.Browser
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING T2.ModelBank
    $USING EB.Interface
    $USING AA.ProductFramework
*
    GOSUB INTIALISE
    
RETURN
*---------------------------------------------------------------------------------------------------------------------
INTIALISE:
*---------
** Initialise all variables
    DEFFUN System.getVariable()
    
    TODAY.DATE = EB.SystemTables.getToday()
    
    CHNL.ARR.ID = ''; CHNL.SUBARR.ID = ''; CHANNEL = ''; CHANNEL.POSITION = ''; CHNL.POS = ''; PRODUCT = ''; PRODUCT.DESCRIPTION = ''; ROLE.NAME = ''; SUBARR.PRODUCT.DESCRIPTION = ''
    CHANNEL.STATUS = ''; CHANNEL.TC.ACCEPTED = ''; CHANNEL.USER.TYPE = ''; CHANNEL.LOGIN.METHOD = ''; CHANNEL.DATE.LAST.USE = ''; CHANNEL.TIME.LAST.USE = ''; EXT.USER.COMPANY = ''; EXT.USER.CUS.NAME='';
    EXT.USER.SMS.CUS = ''; CHANNEL.START.DATE = ''; CHANNEL.CUS.ID = ''; CHANNEL.CUS.NAME = '';SUPPORTED.MODULES = ''; EXT.USER.CURR.NO = '';
 
    EXT.USER.ID    = EB.ErrorProcessing.getExternalUserId()      ;*Get the external user id from selection
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(EXT.USER.ID, EXT.USER.ERR)       ;* Read the External user record for logged user
    EXT.USER.CHANNEL      = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuChannel>      ;* External user channels
    EXT.USER.ARRANGEMENTS = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuArrangement>  ;* External user arrangements
    EXT.USER.SUBARRANGEMENTS = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuSubArrangement>  ;* External user subarrangements
    
    LOCATE "CHANNEL.ID" IN EB.Reports.getDFields()<1> SETTING CHNLPOS THEN
        CHANNEL.ID = EB.Reports.getDRangeAndValue()<CHNLPOS>          ;*Get the channel id from selection
    END
    
    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getDFields()<1> SETTING ARRPOS THEN
        ARRANGEMENT.ID = EB.Reports.getDRangeAndValue()<ARRPOS>       ;*Get the arrangement id from selection
    END
    
  
    IF ARRANGEMENT.ID NE '' THEN
        LOCATE ARRANGEMENT.ID IN EXT.USER.ARRANGEMENTS<1,1> SETTING CHNL.POS THEN ;*To find out the exact position of the selected arrangement to get the complete details
        END
    END
    
    GOSUB CHANNELS.LIST     ;* Available channels for the logged in user
       
RETURN
*---------------------------------------------------------------------------------------------------------------------
CHANNELS.LIST:
*--------------
*List the allowed channels for the logged in user
    IF ARRANGEMENT.ID EQ '' THEN  ;* If no arrangement id is null then this call will be first call from TCxB X.0
        NO.OF.CHANNEL = DCOUNT(EXT.USER.CHANNEL,@VM)
        IF NO.OF.CHANNEL EQ '1' THEN  ;* If no of channel equals to one then system automatically picks that
            CHNL.ID     = CHANNEL.ID             ;* Set channel id value to genric varible which is used in final array
            LOCATE CHNL.ID IN EXT.USER.CHANNEL<1,1> SETTING CHL.POS THEN
                CHNL.ARR.ID = EXT.USER.ARRANGEMENTS<1,CHL.POS>  ;* Set channel arrangement value to genric varible which is used in final array
                IF EXT.USER.SUBARRANGEMENTS<1,CHL.POS> THEN
                    CHNL.SUBARR.ID<1,-1> = EXT.USER.SUBARRANGEMENTS<1,CHL.POS> ;* Set channel sub arrangement value to genric varible which is used in final array
                END ELSE
                    CHNL.SUBARR.ID<1,-1> = "null"
                END
            END
            
            LOCATE CHNL.ARR.ID IN EXT.USER.ARRANGEMENTS<1,1> SETTING CHNL.POS THEN ;*To find out the exact position of the selected arrangement to get the complete details of external user
            END
        END ELSE
            FOR CHANNEL.RECORD = 1 TO NO.OF.CHANNEL        ;* If no of channel more then one, list all the arrangements belongs to the same channel
                CHANNEL = EXT.USER.CHANNEL<1,CHANNEL.RECORD>
                IF CHANNEL.ID EQ CHANNEL THEN                ;* Check the channel against the enquiry selection
                    CHNL.ARR.ID<1,-1> = EXT.USER.ARRANGEMENTS<1,CHANNEL.RECORD>
                    IF EXT.USER.SUBARRANGEMENTS<1,CHANNEL.RECORD> THEN
                        CHNL.SUBARR.ID<1,-1> = EXT.USER.SUBARRANGEMENTS<1,CHANNEL.RECORD>
                    END ELSE
                        CHNL.SUBARR.ID<1,-1> = "null"
                    END
                    CHNL.ID<1,-1>     = CHANNEL
                    CHNL.POS<1,-1>    = CHANNEL.RECORD
                END
            NEXT CHANNEL.RECORD
        END
    END ELSE
        CHNL.ID     = CHANNEL.ID        ;* Set channel id value to genric varible which is used in final array
        CHNL.ARR.ID = ARRANGEMENT.ID    ;* Set arrangement id to genric varible which is used in final array
    END
*
    NO.OF.ARRANGEMENTS    = DCOUNT(CHNL.ARR.ID,@VM)        ;* Count the number of arrangements belongs to the same channel
    IF NO.OF.ARRANGEMENTS EQ '1' THEN
        GOSUB COMMON.PROCESS           ;* Common Call for both internet services and online services
        GOSUB EXTERNAL.USER.DETAILS    ;* Read the external user details
        GOSUB ARRANGEMENT.DETAILS      ;* Read Arrangement Details
        GOSUB SERVICE.FLOW             ;* Based on external user arrangement, Navigate the system to INTERNET / ONLINE process
    END ELSE
        GOSUB EXTERNAL.USER.DETAILS    ;* Read the external user details
        GOSUB ARRANGEMENT.DETAILS      ;* Read Arrangement Details
        IF ('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) ELSE
      
            CHANGE @VM TO "|" IN CHNL.ARR.ID  ;* Convert @VM into | for channel arrangement id
            CHANGE @VM TO "|" IN CHNL.SUBARR.ID  ;* Convert @VM into | for channel subarrangement id
            CHANGE @VM TO "|" IN CHNL.ID      ;* Convert @VM into | for channel id
            CHANGE @VM TO "|" IN CHNL.POS      ;* Convert @VM into | for channel position
            CHANGE @VM TO "|" IN PRODUCT      ;* Convert @VM into | for product
            CHANGE @VM TO "|" IN PRODUCT.DESCRIPTION  ;* Convert @VM into | for product description
            CHANGE @VM TO "|" IN ROLE.NAME      ;* Convert @VM into | for product role name
            CHANGE @VM TO "|" IN EXT.USER.CUS.NAME  ;* Convert @VM into | for customer name from Arrangement record
            CHANGE @VM TO "|" IN SUBARR.PRODUCT.DESCRIPTION ;* Convert @VM into | for sub product description
            CHANGE @VM TO "|" IN CHANNEL.STATUS       ;* Convert @VM into | for channel status
            CHANGE @VM TO "|" IN CHANNEL.TC.ACCEPTED  ;* Convert @VM into | for channel tc accepted
            CHANGE @VM TO "|" IN CHANNEL.USER.TYPE    ;* Convert @VM into | for channel user type
            CHANGE @VM TO "|" IN CHANNEL.LOGIN.METHOD   ;* Convert @VM into | for channel login method
            CHANGE @VM TO "|" IN CHANNEL.CUS.ID         ;* Convert @VM into | for channel customer ID
            CHANGE @VM TO "|" IN CHANNEL.CUS.NAME       ;* Convert @VM into | for channel customer Name
            CHANGE @VM TO "|" IN CHANNEL.START.DATE     ;* Convert @VM into | for channel start date
            CHANGE @VM TO "|" IN CHANNEL.DATE.LAST.USE  ;* Convert @VM into | for channel date last used
            CHANGE @SM TO "#" IN CHANNEL.DATE.LAST.USE  ;* Convert @SM into # for channel date last used
            CHANGE @VM TO "|" IN CHANNEL.TIME.LAST.USE  ;* Convert @VM into | for channel time last used
            CHANGE @SM TO "#" IN CHANNEL.TIME.LAST.USE  ;* Convert @SM into # for channel time last used
        END
        FINAL.ARRAY<-1> = "":'*':"":'*':"":'*':"":'*':"":"*":"":"*":"":'*':"":'*':"":'*':"":'*':"":'*':"":'*':CHNL.ID:'*':CHNL.ARR.ID:'*':CHNL.SUBARR.ID:'*':NO.OF.ARRANGEMENTS:'*':EXT.USER.NAME:'*':EXT.USER.CUSTOMER:'*':EXT.USER.TXN.SIGN:'*':EXT.USER.LANGUAGE:'*':EXT.USER.CUS.NAME:'*':EXT.USER.CUS.GENDER:'*':CHANNEL.STATUS:'*':CHANNEL.TC.ACCEPTED:'*':CHANNEL.USER.TYPE:'*':CHANNEL.LOGIN.METHOD:'*':CHANNEL.DATE.LAST.USE:'*':CHANNEL.TIME.LAST.USE:'*':PRODUCT:'*':PRODUCT.DESCRIPTION:'*':ROLE.NAME:'*':SUBARR.PRODUCT.DESCRIPTION:'*':TODAY.DATE:'*':CHNL.POS:'*':EXT.USER.COMPANY:'*':EXT.USER.CUS.EMAIL.1:'*':EXT.USER.CUS.SMS.1:'*':EXT.USER.CUS.PHONE.1:'*':EXT.USER.SMS.CUS:'*':CHANNEL.START.DATE:'*':CHANNEL.CUS.ID:'*':CHANNEL.CUS.NAME:'*':""
        RETURN
    END
RETURN
*----------------------------------------------------------------------------------------------------------------------
EXTERNAL.USER.DETAILS:
*---------------------
** Logged in external user details
    EXT.USER.NAME      = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuName>        ;* Name of the external user
    EXT.USER.CUSTOMER  = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuCustomer>    ;* Customer of the external user
    EXT.USER.TXN.SIGN  = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTxnSign>     ;* Transaction signature of the external user
    EXT.USER.LANGUAGE  = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuLanguage>    ;* language of the external user
    EXT.USER.COMPANY   = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuCompany>     ;* Company of the external user defined in the EEU record
    EXT.USER.CURR.NO   = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuCurrNo >     ;* To get the external user curr number
    GOSUB EXT.USER.CUSTOMER.DETAILS
    
    NO.OF.CHNL.POS = DCOUNT(CHNL.POS,@VM)
    FOR EXT.CHNL.POS = 1 TO NO.OF.CHNL.POS
        CHANNEL.STATUS<1,-1>        = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuStatus,CHNL.POS<1,EXT.CHNL.POS>>       ;* Status of the external user
*
        CHNL.TC.ACPT = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTCAccepted,CHNL.POS<1,EXT.CHNL.POS>>   ;* Terms & Conditions
        IF CHNL.TC.ACPT EQ '' THEN                      ;* The current tc accepted value is null then add "null" as value else store the back end value itself
            CHANNEL.TC.ACCEPTED<1,-1> = "null"
        END ELSE
            CHANNEL.TC.ACCEPTED<1,-1> = CHNL.TC.ACPT
        END
*
        CHNL.USER.TYPE = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuUserType,CHNL.POS<1,EXT.CHNL.POS>>     ;* User type of the external user
        IF CHNL.USER.TYPE EQ '' THEN                    ;* The current user type value is null then add "null" as value else store the back end value itself
            CHANNEL.USER.TYPE<1,-1> = "null"
        END ELSE
            CHANNEL.USER.TYPE<1,-1> = CHNL.USER.TYPE
        END
*
        CHNL.LOGIN.METHOD = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuLoginMethod,CHNL.POS<1,EXT.CHNL.POS>>  ;* Login method of the external user
        IF CHNL.LOGIN.METHOD EQ '' THEN                 ;* The current login method value is null then add "null" as value else store the back end value itself
            CHANNEL.LOGIN.METHOD<1,-1> = "null"
        END ELSE
            CHANNEL.LOGIN.METHOD<1,-1> = CHNL.LOGIN.METHOD
        END
*
        CHNL.DATE.LAST.USE = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuDateLastUse,CHNL.POS<1,EXT.CHNL.POS>>  ;* Last login date of the external user
        IF CHNL.DATE.LAST.USE EQ '' THEN                ;* The current date last use value is null then add "null" as value else store the back end value itself
            CHANNEL.DATE.LAST.USE<1,-1> = "null"
        END ELSE
            CHANNEL.DATE.LAST.USE<1,-1> = CHNL.DATE.LAST.USE
        END
*
        CHNL.TIME.LAST.USE = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTimeLastUse,CHNL.POS<1,EXT.CHNL.POS>>  ;* Last login time of the external user
        IF CHNL.TIME.LAST.USE EQ '' THEN                ;* The current time last use value is null then add "null" as value else store the back end value itself
            CHANNEL.TIME.LAST.USE<1,-1> = "null"
        END ELSE
            CHANNEL.TIME.LAST.USE<1,-1> = CHNL.TIME.LAST.USE
        END
        
        CHANNEL.START.DATE<1,-1> = R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuStartDate,CHNL.POS<1,EXT.CHNL.POS>>  ;* Get the Start date of profile
    NEXT EXT.CHNL.POS
        
RETURN
*----------------------------------------------------------------------------------------------------------------------
*LAST.LOGIN.UPDATE:
*-----------------
**Update the user logged in time & date in external user template
*    T2.ModelBank.TcLastLoginUpdate(CHANNEL.POSITION)  ;* api call to update the login time & date
    
*RETURN
*----------------------------------------------------------------------------------------------------------------------
EXT.USER.CUSTOMER.DETAILS:
*-------------------------
** Read the customer details of the logged in external user
    R.CUSTOMER = ST.Customer.Customer.CacheRead(EXT.USER.CUSTOMER, EXT.CUS.ERR) ;* Read the customer record for logged in EEU

    EXT.USER.CUS.NAME      = R.CUSTOMER<ST.Customer.Customer.EbCusNameOne> ;* External User's Customer name
    EXT.USER.CUS.GENDER    = R.CUSTOMER<ST.Customer.Customer.EbCusGender>  ;* Customer gender
    EXT.USER.CUS.PHONE.1      = R.CUSTOMER<ST.Customer.Customer.EbCusPhoneOne> ;* Customer phone
    EXT.USER.CUS.SMS.1      = R.CUSTOMER<ST.Customer.Customer.EbCusSmsOne> ;* Customer mobile
    EXT.USER.CUS.EMAIL.1      = R.CUSTOMER<ST.Customer.Customer.EbCusEmailOne> ;* Customer email
    IF ('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) ELSE
 
        CHANGE @VM TO "|" IN EXT.USER.CUS.PHONE.1   ;* Convert @VM into | for customer phone number
        CHANGE @VM TO "|" IN EXT.USER.CUS.SMS.1     ;* Convert @VM into | for customer sms number
        CHANGE @VM TO "|" IN EXT.USER.CUS.EMAIL.1   ;* Convert @VM into | for customer email id
    END
RETURN
*---------------------------------------------------------------------------------------------------------------------
ARRANGEMENT.DETAILS:
*------------
*Navigate to internet services or online services based on product line of the arrangement
    FOR ARR.RECORD = 1 TO NO.OF.ARRANGEMENTS
        R.ARRANGEMENT  = AA.Framework.Arrangement.Read(CHNL.ARR.ID<1,ARR.RECORD>,ARR.ERR)   ;*Read the arragement details
        PRODUCT.LINE   = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>  ;*Get the product line of the arrangement
        ARR.PRODUCT    = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProduct> ;* Product
        PRODUCT<1,-1> = ARR.PRODUCT ;* Consolidate product output for final array if multiple channel available
        
        R.AA.PRODUCT   = AA.ProductManagement.Product.CacheRead(ARR.PRODUCT, AAPRD.ERR) ;* Read the aa product
        PRODUCT.DESCRIPTION<1,-1>    = R.AA.PRODUCT<AA.ProductManagement.ProductDesigner.PrdDescription>  ;* Product description
        ARR.CUS.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer> ;* Get the Arrangment customer ID
        CHANNEL.CUS.ID<1,-1> = ARR.CUS.ID     ;*Get the Arrangement customer ID
        R.ARR.CUSTOMER = ST.Customer.Customer.CacheRead(ARR.CUS.ID, ARR.CUS.ERR) ;* Read customer record for arrangement's customer ID
        CHANNEL.CUS.NAME<1,-1> = R.ARR.CUSTOMER<ST.Customer.Customer.EbCusNameOne> ;* Arrangement Customer name
        
        
        IF CHNL.SUBARR.ID<1,ARR.RECORD> NE "null" THEN
            R.SUBARRANGEMENT  = AA.Framework.Arrangement.Read(CHNL.SUBARR.ID<1,ARR.RECORD>,ARR.ERR)   ;*Read the arragement details
            SUB.PRODUCT.LINE   = R.SUBARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>  ;*Get the product line of the arrangement
            SUB.ARR.PRODUCT    = R.SUBARRANGEMENT<AA.Framework.Arrangement.ArrProduct> ;* Product
            SUB.PRODUCT<1,-1> = SUB.ARR.PRODUCT ;* Consolidate product output for final array if multiple channel available
            IF R.SUBARRANGEMENT<AA.Framework.Arrangement.ArrRemarks> NE '' THEN
                ROLE.NAME<1,-1> = R.SUBARRANGEMENT<AA.Framework.Arrangement.ArrRemarks> ;* get the remarks from the subArrangement and fill the role name var
            END ELSE
                ROLE.NAME<1,-1> = "null"
            END
            R.AA.SUB.PRODUCT   = AA.ProductManagement.Product.CacheRead(SUB.ARR.PRODUCT, AAPRD.ERR) ;* Read the aa product
            SUBARR.PRODUCT.DESCRIPTION<1,-1>    = R.AA.SUB.PRODUCT<AA.ProductManagement.ProductDesigner.PrdDescription>  ;* Product description
        END ELSE
            SUBARR.PRODUCT.DESCRIPTION<1,-1>    = "null"
            ROLE.NAME<1,-1> = "null"   ;* Return the value as null, if sub arrangement ID is not present
        END
    
    NEXT ARR.RECORD

RETURN
*---------------------------------------------------------------------------------------------------------------------
SERVICE.FLOW:
*------------
*Navigate to internet services or online services based on product line of the arrangement
    IF PRODUCT.LINE EQ 'ONLINE.SERVICES' THEN  ;* Check the external user product line
        GOSUB ONLINE.SERVICES.PROCESS    ;* Online services user flow
    END ELSE
        GOSUB INTERNET.SERVICES.PROCESS  ;* Internet services user flow
    END
    
RETURN
*---------------------------------------------------------------------------------------------------------------------
COMMON.PROCESS:
*--------------
*Check the SPF product license, CR license, company, country and channel parameter details
    GOSUB CHECK.SPF.PRD.LICENSE
    GOSUB CHECK.CR.INSTALLED
    GOSUB CHECK.EXTERNAL.PRD.LINE
    LOCAL.CURRENCY = EB.SystemTables.getLccy()                                 ;* Get the local currecy
    COMPANY        = System.getVariable("!COMPANY")                            ;* Get the company
    
    R.COMPANY      = ST.CompanyCreation.Company.Read(COMPANY,COMPANY.ERR)      ;* Read the company record
    LOCAL.COUNTRY  = R.COMPANY<ST.CompanyCreation.Company.EbComLocalCountry>   ;* Read the local country
    
*** Reading the channel parameter table for the cache expiry
    CH.ERR = ''
    R.CHANNEL.PARAMETER = EB.ARC.ChannelParameter.CacheRead("SYSTEM", CH.ERR)
    PRIVILEGES.CHECK = R.CHANNEL.PARAMETER<EB.ARC.ChannelParameter.CprPrivilegesCheck>
    EXT.USER.SMS.CUS = System.getVariable("EXT.SMS.CUSTOMERS")                ;* Get the EXT SMS CUSTOMERS
    
RETURN
*----------------------------------------------------------------------------------------------------------------------
ONLINE.SERVICES.PROCESS:
*-----------------------
*Online services - To get the permissions and privileges details from TC.PERMISSIONS & TC.PRIVILEGES properties
    EXT.SMS.SERVICES   = EB.Browser.SystemGetvariable('EXT.SMS.SERVICES')        ;* Read ext sms services from IRIS header
    EXT.SMS.OPERATIONS = EB.Browser.SystemGetvariable('EXT.SMS.OPERATIONS')      ;* Read ext sms operations from IRIS header
    EXT.SMS.ACCOUNTS.SEE = EB.Browser.SystemGetvariable('EXT.SMS.ACCOUNTS.SEE')  ;*Read ext sms accounts from IRIS header. If no accounts for customer the same input is returned
    EXT.SMS.LOANS.SEE = EB.Browser.SystemGetvariable('EXT.SMS.LOANS.SEE')        ;*Read ext sms loans from IRIS header. If no loans for customer the same input is returned
    EXT.SMS.DEPOSITS.SEE = EB.Browser.SystemGetvariable('EXT.SMS.DEPOSITS.SEE')  ;*Read ext sms deposits from IRIS header. If no deposits for customer the same input is returned
    
*Check the customer has atleast one product
    IF EXT.SMS.ACCOUNTS.SEE EQ 'EXT.SMS.ACCOUNTS.SEE' AND EXT.SMS.LOANS.SEE EQ 'EXT.SMS.LOANS.SEE' AND EXT.SMS.DEPOSITS.SEE EQ 'EXT.SMS.DEPOSITS.SEE' THEN
        HOLDINGS.AVAILABLE = 'NO'
    END ELSE
        HOLDINGS.AVAILABLE = 'YES'
    END
    
*Change @VM and @SM to "|" and "#" respectively

    IF ('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) ELSE

        CHANGE @VM TO "|" IN EXT.SMS.SERVICES
        CHANGE @VM TO "|" IN EXT.SMS.OPERATIONS
        CHANGE @FM TO "|" IN SUPPORTED.MODULES
        CHANGE @SM TO "#" IN EXT.SMS.OPERATIONS
        CHANGE @SM TO "#" IN CHANNEL.DATE.LAST.USE  ;* Convert @SM into | for channel date last used
        CHANGE @SM TO "#" IN CHANNEL.TIME.LAST.USE  ;* Convert @SM into | for channel date last used
    END
    IF ('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) THEN
        CONVERT @FM TO @VM IN SUPPORTED.MODULES
    END
    FINAL.ARRAY<-1> = "":'*':"":'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:"*":MF.FLAG:'*':DX.FLAG:'*':LOCAL.COUNTRY:'*':EXT.SMS.SERVICES:'*':EXT.SMS.OPERATIONS:'*':PRIVILEGES.CHECK:'*':CHNL.ID:'*':CHNL.ARR.ID:'*':CHNL.SUBARR.ID:'*':NO.OF.ARRANGEMENTS:'*':EXT.USER.NAME:'*':EXT.USER.CUSTOMER:'*':EXT.USER.TXN.SIGN:'*':EXT.USER.LANGUAGE:'*':EXT.USER.CUS.NAME:'*':EXT.USER.CUS.GENDER:'*':CHANNEL.STATUS:'*':CHANNEL.TC.ACCEPTED:'*':CHANNEL.USER.TYPE:'*':CHANNEL.LOGIN.METHOD:'*':CHANNEL.DATE.LAST.USE:'*':CHANNEL.TIME.LAST.USE:'*':PRODUCT:'*':PRODUCT.DESCRIPTION:'*':ROLE.NAME:'*':SUBARR.PRODUCT.DESCRIPTION:'*':TODAY.DATE:'*':CHNL.POS:'*':EXT.USER.COMPANY:'*':EXT.USER.CUS.EMAIL.1:'*':EXT.USER.CUS.SMS.1:'*':EXT.USER.CUS.PHONE.1:'*':EXT.USER.SMS.CUS:'*':CHANNEL.START.DATE:'*':CHANNEL.CUS.ID:'*':CHANNEL.CUS.NAME:'*':SUPPORTED.MODULES:'*':HOLDINGS.AVAILABLE:'*':EXT.USER.CURR.NO
RETURN
*----------------------------------------------------------------------------------------------------------------------
INTERNET.SERVICES.PROCESS:
*-------------------------
*Get Home screen,Operations and LD,CR flag
    TC.INITIAL = ''; TC.OPERATION = '';
    PROP.CLASS = "USER.RIGHTS"
    GOSUB CHECK.PROPERTY.CONDITIONS ;* Check there is property conditions defined for User rights
    USER.RIGHT.REC = R.PROPERTY.CLASS.COND
    TC.INITIAL = USER.RIGHT.REC<AA.ARC.UserRights.UsrRgtTcInitial>
    TC.OPERATION = USER.RIGHT.REC<AA.ARC.UserRights.UsrRgtTcOperations>
    IF ('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) ELSE
  
        CHANGE @SM TO "#" IN CHANNEL.DATE.LAST.USE  ;* Convert @SM into | for channel date last used
        CHANGE @SM TO "#" IN CHANNEL.TIME.LAST.USE  ;* Convert @SM into | for channel date last used
    END
*
    TC.OPERATIONS.DCOUNT = DCOUNT(TC.OPERATION,@VM)
    BEGIN CASE
        CASE TC.OPERATIONS.DCOUNT GE '1'
            FINAL.ARRAY<-1>  = TC.INITIAL:'*':TC.OPERATION<1,1>:'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:"*":MF.FLAG:'*':DX.FLAG:'*':LOCAL.COUNTRY:'*':"":'*':"":'*':PRIVILEGES.CHECK:'*':CHNL.ID:'*':CHNL.ARR.ID:'*':CHNL.SUBARR.ID:'*':NO.OF.ARRANGEMENTS:'*':EXT.USER.NAME:'*':EXT.USER.CUSTOMER:'*':EXT.USER.TXN.SIGN:'*':EXT.USER.LANGUAGE:'*':EXT.USER.CUS.NAME:'*':EXT.USER.CUS.GENDER:'*':CHANNEL.STATUS:'*':CHANNEL.TC.ACCEPTED:'*':CHANNEL.USER.TYPE:'*':CHANNEL.LOGIN.METHOD:'*':CHANNEL.DATE.LAST.USE:'*':CHANNEL.TIME.LAST.USE:'*':PRODUCT:'*':PRODUCT.DESCRIPTION:'*':ROLE.NAME:'*':SUBARR.PRODUCT.DESCRIPTION:'*':TODAY.DATE:'*':CHNL.POS:'*':EXT.USER.COMPANY:'*':EXT.USER.CUS.EMAIL.1:'*':EXT.USER.CUS.SMS.1:'*':EXT.USER.CUS.PHONE.1:'*':EXT.USER.SMS.CUS:'*':CHANNEL.START.DATE:'*':CHANNEL.CUS.ID:'*':CHANNEL.CUS.NAME:'*':SUPPORTED.MODULES:'*':HOLDINGS.AVAILABLE:'*':EXT.USER.CURR.NO
        CASE TC.OPERATIONS.DCOUNT EQ '0'
            FINAL.ARRAY<-1> = TC.INITIAL:'*':"":'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:"*":MF.FLAG:'*':DX.FLAG:'*':LOCAL.COUNTRY:'*':"":'*':"":'*':PRIVILEGES.CHECK:'*':CHNL.ID:'*':CHNL.ARR.ID:'*':CHNL.SUBARR.ID:'*':NO.OF.ARRANGEMENTS:'*':EXT.USER.NAME:'*':EXT.USER.CUSTOMER:'*':EXT.USER.TXN.SIGN:'*':EXT.USER.LANGUAGE:'*':EXT.USER.CUS.NAME:'*':EXT.USER.CUS.GENDER:'*':CHANNEL.STATUS:'*':CHANNEL.TC.ACCEPTED:'*':CHANNEL.USER.TYPE:'*':CHANNEL.LOGIN.METHOD:'*':CHANNEL.DATE.LAST.USE:'*':CHANNEL.TIME.LAST.USE:'*':PRODUCT:'*':PRODUCT.DESCRIPTION:'*':ROLE.NAME:'*':SUBARR.PRODUCT.DESCRIPTION:'*':TODAY.DATE:'*':CHNL.POS:'*':EXT.USER.COMPANY:'*':EXT.USER.CUS.EMAIL.1:'*':EXT.USER.CUS.SMS.1:'*':EXT.USER.CUS.PHONE.1:'*':EXT.USER.SMS.CUS:'*':CHANNEL.START.DATE:'*':CHANNEL.CUS.ID:'*':CHANNEL.CUS.NAME:'*':SUPPORTED.MODULES:'*':HOLDINGS.AVAILABLE:'*':EXT.USER.CURR.NO
    END CASE
*
    IF TC.OPERATION GT '1' THEN
        FOR OPERATION.CNT = 2 TO TC.OPERATIONS.DCOUNT     ;* Get the remaining operation values and add in the final array
            FINAL.ARRAY<-1> = "*":TC.OPERATION<1,OPERATION.CNT>:"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*"
        NEXT OPERATION.CNT
    END
** tcmb internet service process
    
RETURN
*---------------------------------------------------------------------------------------------------------------------
CHECK.PROPERTY.CONDITIONS:
*------------------------
* Check whether there is property conditions that apply to arrangement
    R.PROPERTY.CLASS.COND = ""
    ARR.ID = ""
    NEW.ARRANGEMENT.ID = CHNL.ARR.ID:'//AUTH'  ;*read the AUTH record directly
    AA.Framework.GetArrangementConditions(NEW.ARRANGEMENT.ID,PROP.CLASS,'','',ARR.ID,R.PROPERTY.CLASS.COND,ERR.MSG)
    EB.SystemTables.setEtext(ERR.MSG)
    R.PROPERTY.CLASS.COND = RAISE(R.PROPERTY.CLASS.COND)    ;* Raise the Position of the record
RETURN
*--------------------------------------------------------------------------------------------------------------
CHECK.SPF.PRD.LICENSE:
*-------------------
*To check the LD,AL,AD,FT and PI modules in SPF
*
    LD.INSTALLED = ''
    EB.API.ProductIsInCompany('LD', LD.INSTALLED) ;* LD product instalation check
    IF LD.INSTALLED THEN
        LD.FLAG = "LD"          ;* If LD moudle is available in COMPANY, then set the LD flag
        SUPPORTED.MODULES<-1> = LD.FLAG
    END
*
    PI.INSTALLED = ''
    EB.API.ProductIsInCompany('PI', PI.INSTALLED) ;* PI product instalation check
    IF PI.INSTALLED THEN
        PI.FLAG = "PI"          ;* If PI moudle is available in COMPANY, then set the PI flag
        SUPPORTED.MODULES<-1> = PI.FLAG
    END
*
    FT.INSTALLED = ''
    EB.API.ProductIsInCompany('FT', FT.INSTALLED) ;* FT product instalation check
    IF FT.INSTALLED THEN
        FT.FLAG = "FT"          ;* If FT moudle is available in COMPANY, then set the FT flag
        SUPPORTED.MODULES<-1> = FT.FLAG
    END
*
    AL.INSTALLED = ''
    EB.API.ProductIsInCompany('AL', AL.INSTALLED) ;* AL product instalation check
    IF AL.INSTALLED THEN
        AL.FLAG = "AL"          ;* If AL moudle is available in COMPANY, then set the AL flag
        SUPPORTED.MODULES<-1> = AL.FLAG
    END
*
    AD.INSTALLED = ''
    EB.API.ProductIsInCompany('AD', AD.INSTALLED) ;* AD product instalation check
    IF AD.INSTALLED THEN
        AD.FLAG = "AD"          ;* If AD moudle is available in COMPANY, then set the AD flag
        SUPPORTED.MODULES<-1> = AD.FLAG
    END
*
    DX.INSTALLED = ''
    EB.API.ProductIsInCompany('DX', DX.INSTALLED) ;* DX product instalation check
    IF DX.INSTALLED THEN
        DX.FLAG = "DX"          ;* If DX moudle is available in COMPANY, then set the DX flag
        SUPPORTED.MODULES<-1> = DX.FLAG
    END
*
    MF.INSTALLED = ''
    EB.API.ProductIsInCompany('MF', MF.INSTALLED) ;* MF product instalation check
    IF MF.INSTALLED THEN
        MF.FLAG = "MF"          ;* If MF moudle is available in COMPANY, then set the MF flag
        SUPPORTED.MODULES<-1> = MF.FLAG
    END
*
    IM.INSTALLED = ''
    EB.API.ProductIsInCompany('IM', IM.INSTALLED) ;* IM product instalation check
    IF IM.INSTALLED THEN
        SUPPORTED.MODULES<-1> = "IM"   ;* If IM moudle is available in COMPANY, then set the IM flag
    END
*
    BEGIN CASE
        CASE LD.FLAG AND (AL.FLAG OR AD.FLAG)
            AALD.FLAG = 'BOTH'    ;* Assign Both flag
        CASE LD.FLAG AND (AL.FLAG EQ '' OR AD.FLAG EQ '')
            AALD.FLAG = 'LD'      ;* Assign LD flag
        CASE LD.FLAG EQ '' AND (AL.FLAG OR AD.FLAG)
            AALD.FLAG = 'AA'      ;* Assign AA flag
    END CASE
*
    BEGIN CASE
        CASE PI.FLAG AND FT.FLAG
            PAYMENT.FLAG = 'BOTH'       ;*Assign both flag
        CASE PI.FLAG AND (FT.FLAG EQ '')
            PAYMENT.FLAG = 'PI'
        CASE FT.FLAG AND (PI.FLAG EQ '')
            PAYMENT.FLAG = 'FT'
    END CASE
*
RETURN
*--------------------------------------------------------------------------------------------------------------
CHECK.CR.INSTALLED:
*-----------------
* To check CR product installed

    CR.INSTALLED = ''
    EB.API.ProductIsInCompany('CR', CR.INSTALLED) ;* CR product instalation check
    IF CR.INSTALLED THEN
        CR.FLAG = "CR"          ;* If CR moudle is available in COMPANY, then set the CR flag
        SUPPORTED.MODULES<-1> = CR.FLAG;
    END


RETURN
*---------------------------------------------------------------------------------------------------------------
CHECK.EXTERNAL.PRD.LINE:
*----------------------
* To check external accounts product line installed for account aggregation
    EXTERNAL.PRD.LINE = AA.ProductFramework.ProductLine.Read('XEXTERNAL.ACCOUNTS', Error)
    IF EXTERNAL.PRD.LINE THEN
        SUPPORTED.MODULES<-1> = "AAG"   ;* If XEXTERNAL.ACCOUNTS product line available set flag for account aggregation
    END
RETURN
*---------------------------------------------------------------------------------------------------------------
END
