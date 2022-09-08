* @ValidationCode : MjoxMjg1NzI5MDU6Q3AxMjUyOjE2MTYwNjQ0MTU0Nzk6a2FydGhpa2V5YW5rYW5kYXNhbXk6LTE6LTE6MDotMTp0cnVlOk4vQTpERVZfMjAyMTAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Mar 2021 16:16:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : karthikeyankandasamy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.Framework
SUBROUTINE DAS.AA.ARRANGEMENT.ACTIVITY(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Service for AA.ARRANGEMENT.ACTIVITY
* Implements the query definition for all queries that can be used against
* the AA.ARRANGEMENT.ACTIVITY table.
*-----------------------------------------------------------------------------
* Modifications:
*
* 28/03/11 - Defect-177466/Task-179786
*            Ref :HD1048584
*
* 06/08/12 - Enhancement 385711 / Task 385872
*            Enquiry for internet service arrangement.
*
** 06/04/17- Defect 2080033 / Task 2080452
*            Unauth - Arrangements & External User counts are not displaying in home screen
*
* 31/01/19 - Enh 2875458 / Task 2907647
*            IRIS R18 TCUA - Add query to extract only INAU activities of the arrangement
*
* 7/4/2020 - Task:3682159
*            Das to select all IHLD records of AAA of FACILITY-NEW-ARRANGEMENT.
*            Defect :3674691
*
* 16/03/2021 - Defect:4263580
*              Task:4287769
*              Changes to select all IHLD records of AAA-FACILITY-NEW.OFFER-ARRANGEMENT.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_DAS.AA.ARRANGEMENT.ACTIVITY.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
BUILD.DATA:
    MY.TABLE = "AA.ARRANGEMENT.ACTIVITY" : TABLE.SUFFIX
    BEGIN CASE

        CASE MY.CMD = ""
        
        CASE MY.CMD = DasHold ;*Select all IHLD records of AAA- Facility new and offer arrangements
            MY.FIELDS = "RECORD.STATUS":FM:"ACTIVITY"
            MY.FIELDS = "RECORD.STATUS":FM:"ACTIVITY":FM:"ACTIVITY"
            MY.OPERANDS = "EQ":FM:"EQ":FM:"EQ"
            MY.DATA = "IHLD":FM:"FACILITY-NEW-ARRANGEMENT":FM:"FACILITY-NEW.OFFER-ARRANGEMENT"
            MY.JOINS = "AND":FM:"OR"
            
        CASE MY.CMD = DAS$STATUS.HOLD       ;* Only IHLD activities for the arrangement
            MY.FIELDS = "ARRANGEMENT"
            MY.OPERANDS = "EQ"
            MY.DATA = THE.ARGS<1>
            MY.JOINS = "AND"
            MY.FIELDS<-1> = "RECORD.STATUS"
            MY.OPERANDS<-1> = "EQ"
            MY.DATA<-1> = "IHLD"

        CASE MY.CMD = DAS$MANAGE.ARRANGEMENT       ;* List of Internet Service Arrangement
            MY.FIELDS = "ACTIVITY"
            MY.OPERANDS = "EQ"
            MY.DATA ="INTERNET.SERVICES-NEW-ARRANGEMENT"

        CASE MY.CMD = DAS$CUSARRANGEMENT    ;* List of Internet Service Arrangement for specific customer
            MY.FIELDS = "ACTIVITY":FM:"CUSTOMER"
            MY.OPERANDS = "EQ":FM:"EQ"
            MY.DATA ="INTERNET.SERVICES-NEW-ARRANGEMENT":FM:THE.ARGS<1>
            MY.JOINS = "AND"

        CASE MY.CMD = DAS$PROXYARRANGEMENT  ;* List of proxy arrangement
            MY.FIELDS = "ACTIVITY":FM:"ARRANGEMENT"
            MY.OPERANDS = "EQ":FM:"EQ"
            MY.DATA ="PROXY.SERVICES-NEW-ARRANGEMENT":FM:THE.ARGS<1>
            MY.JOINS = "AND"
     
        CASE MY.CMD = DAS$COUNT.AUTH.UNAUTH.ARRANGEMENTS   ;* Count the number of auth and unauth arrangements
            MY.FIELDS = "PRODUCT"
            MY.OPERANDS = "LK"
            MY.DATA =THE.ARGS<1>:'...'

        CASE MY.CMD = DAS$STATUS.NAU       ;* Only INAU activities for the arrangement
            MY.FIELDS = "MASTER.ARRANGEMENT":FM:"@ID":FM:"RECORD.STATUS":FM:"ACTIVITY"
            MY.OPERANDS = THE.ARGS<1>:FM:"UL":FM:"EQ":FM:"LK"
            MY.DATA = THE.ARGS<2>:FM:"...VIEW-ARRANGEMENT":FM:"INAU":FM:"ONLINE.SERVICES..."
            MY.JOINS = "AND":FM:"AND":FM:"AND"
 
        CASE OTHERWISE
            ERROR.MSG = "UNKNOWN.QUERY"
        
    END CASE

RETURN
*-----------------------------------------------------------------------------

END
