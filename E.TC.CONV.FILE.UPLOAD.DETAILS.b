* @ValidationCode : MjotODk2OTIwMjk4OkNwMTI1MjoxNTE4NTA2MDA5NjMwOnZwZGlsaXBrdW1hcjo0OjA6LTU1Oi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjIwMTcxMjIzLTAxNTE6NDI6NDI=
* @ValidationInfo : Timestamp         : 13 Feb 2018 12:43:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vpdilipkumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -55
* @ValidationInfo : Coverage          : 42/42 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171223-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-65</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Channels

SUBROUTINE E.TC.CONV.FILE.UPLOAD.DETAILS
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To record log details for EB.FILE.UPLOAD records
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Conversion routine
* Attached To        : Enquiry > TC.EB.FILE.UPLOAD
* IN Parameters      : Upload Id (@ID) and Service Status (SERVICE.STATUS)
* Out Parameters     : Array of error log details
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2410871
*             TCIB2.0 Corporate - Advanced Functional Components - Bulk payments File upload
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the subroutine. </desc>
*Inserts

    $USING EB.Channels
    $USING EB.Logging
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess
    $INSERT I_DAS.EB.LOGGING
    $INSERT I_DAS.EB.LOGGING.NOTES

*** </region>
*---------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing logic. </desc>

    GOSUB INITIALISE
    IF ServiceStatus EQ "ERROR.IN.PROCESSING" THEN
        GOSUB PROCESS
    END

RETURN
*** </region>
*---------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine. </desc>
INITIALISE:
*----------
*Initialise required variables
    UploadId=FIELD(EB.Reports.getOData(),'*',1)  ;* Retrieve the Upload Id
    ServiceStatus=FIELD(EB.Reports.getOData(),'*',2) ;* Retrieve the Service status
    EB.Reports.setOData('') ;*Reset the Odata value
    ErrorItem='' ;*Initialise variable
    LogFileId='' ;*Initialise variable
RETURN
*** </region>
*------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>This processes the error message and formats accordingly. </desc>
PROCESS:
*-------
* To get error details for the EB.FILE.UPLOAD record

    THE.LIST = dasEbFileLoggingId       ;* Setting values for DAS Arguments
    THE.ARGS=UploadId
    TABLE.SUFFIX=''
    EB.DataAccess.Das("EB.LOGGING",THE.LIST,THE.ARGS,TABLE.SUFFIX) ;* To read Log file with record key like upload ID
    IF THE.LIST THEN
        LogFileId=THE.LIST
        REbLogging = EB.Logging.Logging.Read(LogFileId, ErrorItem) ;* Read logging file
        LogInfo=REbLogging<EB.Logging.Logging.LogLogDetails>     ;* To get logging details
        LogDetails=FIELD(LogInfo,"|",2)       ;*Retrieve error response
        IF LogDetails THEN
            GOSUB GET.FORMAT.MESSAGE    ;*To format the error response
        END ELSE
            LogDetails=LogInfo      ;*Assign the log info as it is if it's not in request response format
        END
        EB.Reports.setOData(LogDetails)          ;* Assign logging details to Odata
    END ELSE
        EB.Reports.setOData('') ;*Reset the Odata if DAS call doesn't return any response
    END
RETURN
*** </region>
*------------------------------------------------------------------------------------------------
*** <region name= GET.FORMAT.MESSAGE>
*** <desc>This has the logic to format the error message. </desc>
GET.FORMAT.MESSAGE:
*-----------------
*To format the error message

    CompleteLogDetails = FIELD(LogDetails,"/",4)   ;* Get full error message response
    IF CompleteLogDetails THEN  ;* format if the response returned
        StringLength=LEN(CompleteLogDetails)          ;* get length of the message
        StringIndex=INDEX(CompleteLogDetails,",",1)       ;* Index position of "'" separator
        CHANGE @VM TO "*" IN CompleteLogDetails    ;* convert VM to "*" marker to avoid truncation
        LogDetails=SUBSTRINGS(CompleteLogDetails,StringIndex+1,StringLength)   ;* Get the formatted error message
        CHANGE "*" TO @VM IN LogDetails
        CHANGE ',' TO ' ' IN LogDetails
    END
RETURN
*** </region>
*------------------------------------------------------------------------------------------------
END
