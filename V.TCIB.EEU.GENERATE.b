* @ValidationCode : MjotNDUzNDg0ODAyOkNwMTI1MjoxNTMzNTQxMzg5MjYyOmpleWFsYXZhbnlhajoyOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwOC4wOjEwMDo2Mg==
* @ValidationInfo : Timestamp         : 06 Aug 2018 13:13:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jeyalavanyaj
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 62/100 (62.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------
* <Rating>-49</Rating>
*--------------------------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE V.TCIB.EEU.GENERATE
*--------------------------------------------------------------------------------------------
* Attached to     : AA.ARRANGEMENT.ACTIVITY,TCIB.NEW Version as a Before Auth Routine
* Incoming        : N/A
* Outgoing        : External User Id
*---------------------------------------------------------------------------------------------
* Description:
* Will upon creation of an internet Service Arrangement create an EB.EXTERNAL.USER
*---------------------------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 1001222/Task 1001223
*            TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 24/07/17 - Defect 2351700 / Task 2355392
*            Status assigned as " okay" with space in SUB.SEND.OFS.LOCAL.REQUEST which fails in IF condition
*
* 26/02/18 - Defect 2416361 /Task 2477356
*            While creating an online services arrangement using version AAA,TCIB.NEW, the system throws an error �AGENT.ARR.ID.1.1 TCIB External user creation failed"
*            handled all product line.
*
* 06/08/18 - Defect 2703810 / Task 2710170
*            Using Create Online banking Arrangement menu, while creating External user arrangement error is thrown
*-------------------------------------------------------------------------------------------------------------------
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.API
    $USING EB.ARC
    $USING EB.Interface
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING ST.Customer
    $USING T2.ModelBank
*
*-------------------------------------------------------------------------------------------------

    IF (EB.Interface.getOfsOperation() NE "PROCESS") THEN RETURN   ;*This check is used to filter during validation and to proceed only at process time

    GOSUB CHECK.AUTO.ID
*
    IF APP.AVAIALBILITY NE '' THEN      ;*Checking whether auto id start is available
        GOSUB INITIALISE
        GOSUB OPEN.FILES
        GOSUB MAIN.PROCESS
    END

RETURN

*--------------------------------------------------------------------------------------------------
CHECK.AUTO.ID:
*--------------

    APP.AVAIALBILITY = ''     ;*Initialising variable for application availability
    R.AUTO.ID = ''  ;*initialising array
    ERR.ID = ''     ;*initialising variable
    AUTO.ID = 'EB.EXTERNAL.USER';       ;*Application
    R.AUTO.ID = EB.SystemTables.AutoIdStart.Read(AUTO.ID, ERR.ID)

    IF R.AUTO.ID THEN
        APP.AVAIALBILITY = 'YES'        ;*Setting value as auto id application available
    END
RETURN

*---------------------------------------------------------------------------------------------------
INITIALISE:
*-----------

    Y.END.DATE = '';*Initialising variable
    ID_PRODUCT = ''
    R.AA.PRODUCT = ''
    R.AA.PRODUCT.GROUP = ''
    AA.PRODUCT.LINE = ''
        
    Y.TODAY = OCONV(DATE(),"D4*")       ;* Data variable to bring the today date
    Y.TODAY = FIELD(Y.TODAY,"*",3):FIELD(Y.TODAY,"*",1):FIELD(Y.TODAY,"*",2)    ;*formatting as per t24 date format
    Y.END.DATE = Y.TODAY

    ID_ARR     = EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActArrangement)    ;*Arrangement id is assigned to the variable
    ID_CUSTOMER  = EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActCustomer)     ;*Arrangement customer id is assigned to the variable


    ID_PRODUCT = EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActProduct)        ;*Product id is assigned to a variable ID_PRODUCT
    R.AA.PRODUCT = AA.ProductManagement.Product.Read(ID_PRODUCT, Error)                         ;*geting record with help of ID_PRODUCT
    AA.PRODUCT.GROUP = R.AA.PRODUCT<AA.ProductManagement.Product.PdtProductGroup>               ;*geting product group using AA.PRODUCT.REC record
    R.AA.PRODUCT.GROUP = AA.ProductFramework.ProductGroup.Read(AA.PRODUCT.GROUP, Error)         ;*geting product group record in AA.PRODUCT.GROUP.REC
    AA.PRODUCT.LINE = R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgProductLine>        ;*geting product line from product group
    EB.API.Cdt('',Y.END.DATE,'+180C')

 
RETURN
*
*--------------------------------------------------------------------------------------------------
OPEN.FILES:
*------------
    R.CUST = ""
    ERR.CUSTOMER = ""

RETURN          ;*Opf return
*-------------------------------------------------------------------------------------------------
MAIN.PROCESS:
*-----------

*----------Initialise OFS Message--------------

    GOSUB SUB.INIT.OFS.MESSAGE
    var_ofsApplication = "EB.EXTERNAL.USER"       ;*application defaulted with external user

    R.CHANNEL.PARAMETER = ''
    ERR.PARAM = ''
    R.CHANNEL.PARAMETER = EB.ARC.ChannelParameter.CacheRead("SYSTEM", ERR.PARAM)       ;*read channel parameter
    IF R.CHANNEL.PARAMETER THEN
        Y.VERSION = R.CHANNEL.PARAMETER<EB.ARC.ChannelParameter.CprVersionName,1> ;*pick the version name from the channel parameter table
        var_ofsVersion     = Y.VERSION  ;*assign it to the ofs variable
        var_ofsSourceId = R.CHANNEL.PARAMETER<EB.ARC.ChannelParameter.CprOfsSource>         ;*ofs type taken from the channel parameter table
    END

    IF Y.VERSION THEN    ;*Version if available in channel parameter , allow creation of external user
        var_inApp = "EB.EXTERNAL.USER"      ;*Retrieve next User ID
        GOSUB SUB.BUILD.NEXT.ID
        var_ofsTxnId = var_outID  ;* Returns the unique External user id

        GOSUB SUB.READ.CUSTOMER   ;*Read Customer Name

*-------Create the External User record via OFS
        GOSUB SUB.BUILD.OFS.EXTERNAL.USER   ;*builds up var_ofsMessage
        GOSUB SUB.SEND.OFS.LOCAL.REQUEST    ;*Adds in the ofs request queue

*-------Display Errors and exit in case of Error

        IF status NE "OKAY" THEN  ;*check for success
            EB.SystemTables.setEtext("EB-EXT.USER.FAILURE");*failure message
            GOSUB DISPLAY.ERROR
            RETURN
        END
    END

RETURN
*--------------------------------------------------------------------------------------------------------------------------------
SUB.INIT.OFS.MESSAGE:
*--------------------------

*    Initailising default variables for Ofs request

    var_ofsHeader        = ""
    var_ofsBody          = ""
    var_ofsSourceId      = ""
    var_ofsTxnId         = ""
    var_ofsApplication   = ""
    var_ofsVersion       = ""
    var_ofsFunction      = "I"          ;*ofs function to be used
    var_ofsProcess       = "PROCESS"    ;*ofs request formed with process
    var_ofsGtsmode       = 1            ;*ERROR = $NAU file with status set to HLD. Override accepted automatically transaction committed
    var_ofsNoOfAuth      = "1"          ;*Setting the no of auth always to 1 as it needs to be amended or authorised by another user.
    var_ofsError         = ""
    var_ofsCompany       = ""
    var_record           = ""
    var_ofsOptions      = EB.SystemTables.getOperator()      ;*operator passes the login values

RETURN
*-------------------------------------------------------------------------------------------------
SUB.BUILD.NEXT.ID:
*--------------------------
    var_outID = ""
    T2.ModelBank.TcibAiGetNextId(var_inApp, var_outID)          ;*call routine to fetch the next id of the external user application
    var_inApp = ""  ;*nullfying the incoming variable
*
RETURN
*
*------------------------------------------------------------------------------------------------
SUB.READ.CUSTOMER:
*-------------------

    R.CUST = ST.Customer.Customer.Read(ID_CUSTOMER, ERR.CUSTOMER)

    VAR_NAME1 = R.CUST<ST.Customer.Customer.EbCusNameOne,1>       ;*read the customer name to default in the external user short name by default

RETURN
*----------------------------------------------------------------------------------------------
SUB.BUILD.OFS.EXTERNAL.USER:
*--------------------------

    var_record<EB.ARC.ExternalUser.XuName>             = VAR_NAME1          ;*external user short name
    var_record<EB.ARC.ExternalUser.XuCustomer>    = ID_CUSTOMER   ;*external user customer name
    var_record<EB.ARC.ExternalUser.XuArrangement>       = ID_ARR  ;*external user arrangement name
    var_record<EB.ARC.ExternalUser.XuStartDate> = Y.TODAY        ;*today value in start date
    var_record<EB.ARC.ExternalUser.XuEndDate> = Y.END.DATE       ;*Setting end date

    IF AA.PRODUCT.LINE EQ 'INTERNET.SERVICES' THEN
        var_record<EB.ARC.ExternalUser.XuAllowedCustomer> = ID_CUSTOMER        ;*allowed customer is external user
    END
    EB.Foundation.OfsBuildRecord(var_ofsApplication,var_ofsFunction,var_ofsProcess,var_ofsVersion,var_ofsGtsmode,var_ofsNoOfAuth,var_ofsTxnId,var_record,var_ofsMessage)

RETURN
*---------------------------------------------------------------------------------------------------
SUB.SEND.OFS.LOCAL.REQUEST:
*------------------------------

    EB.Interface.OfsAddlocalrequest(var_ofsMessage,"txn",var_ofsError)       ;*Add ofs local request for external user creation
    status = "OKAY"          ;*variable for success
    IF var_ofsError NE "" THEN
        status = " ":var_ofsError;      ;*if error add the error in the variable
    END
RETURN
*---------------------------------------------------------------------------------------------------
DISPLAY.ERROR:
*------------------------------
    V$ERROR=1

END
