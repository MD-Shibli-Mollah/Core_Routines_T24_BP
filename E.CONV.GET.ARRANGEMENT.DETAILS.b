* @ValidationCode : MjotMTM4OTIwNjYxMzpDcDEyNTI6MTUzOTA2MTc1NTk0NzpuaWxvZmFycGFydmVlbjoyOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMC4yMDE4MDkxNC0wMjM5OjMyOjMy
* @ValidationInfo : Timestamp         : 09 Oct 2018 10:39:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nilofarparveen
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 32/32 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180914-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AI.ModelBank
SUBROUTINE  E.CONV.GET.ARRANGEMENT.DETAILS
*-----------------------------------------------------------------------------
*
* Conversion routine gets Arrangement ID in O.DATA and
* returns the ExternalUserId, ProxyCustomerIds, ProxyArrangementIds
* Routine attached to Enquiry AI.MANAGE.INTERNET.ARRANGEMENT, AI.MANAGE.INTERNET.ARRANGEMENT.SEE
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 06/10/2018 - Def-2788599 / Task 2799853
*              2799853: Optimisation of AI.MANAGE.INTERNET.ARRANGEMENT enquiry
*
*-----------------------------------------------------------------------------
*********************************************************

    $USING AA.ARC
    $USING AA.ProductFramework
    $USING ST.Customer
    $USING EB.Reports
    $INSERT I_DAS.EB.EXTERNAL.USER

    GOSUB Init ;* Initialise the variable used
    GOSUB ReadDetails   ;* Get the External User Id, Allowed customer and Proxy arrangement details
    GOSUB ReturnDetails ;* Return the O.DATA

RETURN
    
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise the variables used </desc>

Init:

    ARRANGEMENT.ID = EB.Reports.getOData()  ;* Get the Internet services ARRANGEMENT.ID from O.DATA

    THE.ARGS = "" ;* Assign the variables used to null

    RESULT.ARR= ""
    
    CUS.NAME = ''

    REC.ERR = ""
    
    TABLE.SUFFIX = ''

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= ReadDetails>
*** <desc>Read the Externaluser and Allowed Customer details </desc>

ReadDetails:

    THE.LIST=DAS.EXT$ARRANGEMENT    ;* Assigning Input for the DAS call to find the External User Id
    
    THE.ARGS = ARRANGEMENT.ID   ;* Assigning Input Parameter for the DAS to find the External User Id
    
    CALL DAS('EB.EXTERNAL.USER',THE.LIST,THE.ARGS,TABLE.SUFFIX) ;* DAS call to find the External User Id
    
    EXT.USER.ID=THE.LIST
    
    PROPERTY = 'USERRIGHTS' ;* Assigning Property value
    
    AA.ProductFramework.GetPropertyRecord(TEMPLATE, ARRANGEMENT.ID, PROPERTY, PROPERTY.DATE, PROP.CLASS, BASE.ARR.REC,PROPERTY.RECORD, REC.ERR) ;* Get the UserRights Property record
    
    ALLOW.CUST = PROPERTY.RECORD<AA.ARC.UserRights.UsrRgtAllowedCustomer>   ;* Find the list of allowed customer
    
    CUST.COUNT=DCOUNT(ALLOW.CUST,@VM)   ;* Count the number of allowed customer
    
    FOR I=1 TO CUST.COUNT   ;* For each customer
        
        ALLOW.CUST.ID=ALLOW.CUST<1,I>
        
        REC.CUS = ST.Customer.Customer.Read(ALLOW.CUST.ID,CUS.ERROR)
        
        CUS.NAME<1,-1>=REC.CUS<ST.Customer.Customer.EbCusShortName> ;* Find the short name of the Ith allowed customer
    
    NEXT I
    
    PROXY.ARR.ID=PROPERTY.RECORD<AA.ARC.UserRights.UsrRgtProxyArrangement>  ;* Get the Proxy Arrangement ID

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= ReturnDetails>
*** <desc>Returns the ExternalUserId, ProxyCustomer and ProxyArrangement </desc>

ReturnDetails:

    CONVERT @VM TO "~" IN CUS.NAME  ;* Converting @VM to ~ , ~ is converted back to process @VM in the conversion routine E.CONV.TO.PROCESS.DELIMIT
    
    CONVERT @VM TO "~" IN PROXY.ARR.ID  ;* Converting @VM to ~ , ~ is converted back to process @VM in the conversion routine E.CONV.TO.PROCESS.DELIMIT
    
    RESULT.ARR<-1>=EXT.USER.ID:"*":PROXY.ARR.ID:"*":CUS.NAME    ;* Assigning Result to RESULT.ARR
    
    EB.Reports.setOData(RESULT.ARR) ;* Assinging Result value to O.DATA

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
