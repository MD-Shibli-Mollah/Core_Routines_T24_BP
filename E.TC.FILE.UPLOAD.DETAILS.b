* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-65</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T4.ModelBank

    SUBROUTINE E.TC.FILE.UPLOAD.DETAILS
*-----------------------------------------------------------------------------------------------------------------
* Description      : Conversion routine to find log details for EB.FILE.UPLOAD records.
* Linked With      : ENQUIRY>TC.FILE.UPLOAD.DETAILS
*-----------------------------------------------------------------------------------------------------------------
* Modification Details:
* 08/07/15 - Defect 1381689 / Task 1399374
*                  To display error details from EB.FILE.UPLOAD IN TCIB
* 02/03/16 - Defect 1649450 / Task 1650440
*            Missing Insert files for DAS.EB.LOGGING
*=============================================================================================================
*
    $USING EB.Logging
    $USING EB.Reports
    $USING EB.SystemTables
    $INSERT I_DAS.EB.LOGGING
    $INSERT I_DAS.EB.LOGGING.NOTES


*
    GOSUB INIT
    IF SERVICE.STATUS EQ "ERROR.IN.PROCESSING" THEN
        GOSUB OPENFILES
        GOSUB PROCESS
    END
*
    RETURN
*---------------------------------------------------------------------------------------------
INIT:
*----
*Initialise required variables
    UPLOAD.ID=FIELD(EB.Reports.getOData(),'*',1)  ;* Assign upload record Id
    SERVICE.STATUS=FIELD(EB.Reports.getOData(),'*',2)
    EB.Reports.setOData('')
    ERR.ITEM=''
    LOG.FILE.ID=''
    RETURN
*---------------------------------------------------------------------------------------------
OPENFILES:
*---------
*Open required files
*
    RETURN
*------------------------------------------------------------------------------------------------
PROCESS:
*------
* To get error details for the EB.FILE.UPLOAD record
    THE.LIST = dasEbFileLoggingId       ;* Setting values for DAS Arguments
    THE.ARGS=UPLOAD.ID
    TABLE.SUFFIX=''
    CALL DAS("EB.LOGGING",THE.LIST,THE.ARGS,TABLE.SUFFIX)   ;* To read Log file with record key like upload ID
    IF THE.LIST THEN
        LOG.FILE.ID=THE.LIST
        R.EB.LOGGING = EB.Logging.Logging.Read(LOG.FILE.ID, ERR.ITEM) ;* Read logging file
        LOG.DETAIL=R.EB.LOGGING<EB.Logging.Logging.LogLogDetails>     ;* To get logging details
        LOG.DETAILS=FIELD(LOG.DETAIL,"|",2)       ;* Split error response
        IF LOG.DETAILS THEN
            GOSUB GET.FORMAT.MESSAGE    ;*To read formatted error message
        END ELSE
            LOG.DETAILS=LOG.DETAIL      ;*To get full LOG.DET if it is not in the form of request and response
        END
        EB.Reports.setOData(LOG.DETAILS)          ;* Assign logging details to current Data
    END ELSE
        EB.Reports.setOData('')
    END
*
    RETURN
*------------------------------------------------------------------------------------------------
GET.FORMAT.MESSAGE:
*-----------------
    FULL.LOG.DETAILS = FIELD(LOG.DETAILS,"/",4)   ;* Get full error message response
    IF FULL.LOG.DETAILS THEN  ;* format if the response returned
        STRING.LEN=LEN(FULL.LOG.DETAILS)          ;* get length of the message
        INDEX.OF.STRING=INDEX(FULL.LOG.DETAILS,",",1)       ;* index position of "'" separator
        CONVERT @VM TO "*" IN FULL.LOG.DETAILS    ;* convert VM to "*" marker to avoid truncation
        LOG.DETAILS=SUBSTRINGS(FULL.LOG.DETAILS,INDEX.OF.STRING+1,STRING.LEN)   ;* Get the formatted error message
        CONVERT "*" TO @VM IN LOG.DETAILS
        CONVERT ',' TO ' ' IN LOG.DETAILS
    END
    RETURN
*------------------------------------------------------------------------------------------------
END
*------------------------------------------------------------------------------------------------
