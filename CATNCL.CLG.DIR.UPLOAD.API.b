* @ValidationCode : MjotNTkwODc4MDUwOkNwMTI1MjoxNTk3MzEzNzc0NTcxOm1yLnN1cnlhaW5hbWRhcjozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6MTY1OjE0OA==
* @ValidationInfo : Timestamp         : 13 Aug 2020 15:46:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 148/165 (89.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE CATNCL.Foundation
SUBROUTINE CATNCL.CLG.DIR.UPLOAD.API(actionCheck, lineNo, fileId, origLineRecord, rT24UploadRecord, oResponse,oFuture)
*-----------------------------------------------------------------------------
*This routine is used to upload the data into CLEARING.DIRECTORY from the file sent by AFW team.
*-----------------------------------------------------------------------------
* Modification History :
*10/06/2020 : Enhancement -3783859 / Task -3797792
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    $USING EB.FileUpload
    $USING EB.SystemTables
    $USING CA.Contract
    $USING CA.Config
    $USING EB.API
    $USING EB.Security
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
    
RETURN
*-----------------------------------------------------------------------------
initialise:
* initialise local variables
    R.EB.FILE.UPLOAD = ''
    R.EB.FILE.UPLOAD.TYPE = ''
    ebFileUploadErr = ''
    ebFileUploadTypeErr = ''
    Date = ''
    uploadType = ''
    fileName = ''
    paymentChannel = ''
    effectiveDate = ''
    ClearingParamId = ''
    altKeyVal = ''
    newAltKeyVal = ''
    iFileNameExtension = ''
    iNCCValue=''
    systemDate=''
    iAddressVal=''
    iAddressLen=''
    iAddressVal1 = ''
    iAddressVal2 = ''
    Error=''
RETURN
*-----------------------------------------------------------------------------
process:
*   Clearing and File type values can be determined from EB.FILE.UPLOAD record.
*   So, read EB.FILE.UPLOAD with the fieldId and get record
*   Below validation will be done once for Header processing to handle Errors scenarios which might occurs for Record not found cases so that
*   In the EB.FILE.UPLOAD record, Service status will be updated with "ERROR IN PROCESSING" in T24 uplaod process routine.
*   If all validations are success, it returns from the flow and will be skipped for next header records.
*   Similarly below validation will happens for Item action to fetch the values like filename,reachabilityType etc which are required for
*   mapping clearing directory records.
    IF ( actionCheck EQ 'HEADER' AND lineNo EQ 1 ) OR ( actionCheck EQ 'ITEM') THEN
        R.EB.FILE.UPLOAD = EB.FileUpload.FileUpload.Read(fileId, ebFileUploadErr)
        uploadType = FIELD(R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfUploadType>,'.',1)
        IF ebFileUploadErr NE '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Unable to read EB.FILE.UPLOAD'
            RETURN
        END
        uploadTypeId = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfUploadType>
        IF R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfFileName> EQ '' THEN
            fileName = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfSystemFileName>
        END ELSE
            fileName = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfFileName>
        END
*       Get system date
        systemDate = OCONV(DATE(),"D-")[7,4] : OCONV(DATE(),"D-")[1,2] : OCONV(DATE(),"D-")[4,2]
*       To check for incorrect file extension other than .T files should be thrown error
        iFileNameExtension = FIELD(fileName,'.',2)
        IF iFileNameExtension NE 'txt' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Incorrect File Extension not supported'
            RETURN
        END
*       CACHE.READ EB.FILE.UPLOAD.TYPE
        R.EB.FILE.UPLOAD.TYPE = EB.FileUpload.FileUploadType.CacheRead(uploadTypeId, ebFileUploadTypeErr)
        IF ebFileUploadTypeErr NE '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Unable to read EB.FILE.UPLOAD.TYPE'
            RETURN
        END
        paymentChannel = 'TUNCLG'
        GOSUB fromClearingParamID
*       Read the Clearing Directory Param Table to get the data for Effective date Calculation
        R.CLEARING.DIRECTORY.PARAM = CA.Config.ClearingDirectoryParam.Read(ClearingParamId, Error)
        IF Error NE '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Unable to read Clearing Directory Param'
            RETURN
        END
    END
    IF actionCheck EQ 'HEADER' THEN
        oResponse<1> = 'Header Processing Completed for Tunisia Transfers Clearing'
        RETURN
    END
*   Below flow will be executed only for Item processing
    IF ( actionCheck EQ 'ITEM') THEN
        R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastUploadDate> = systemDate
        R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastEffectiveDate> = systemDate
        R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastSourceFileName> = fileName
*   Call the Wrapper routine to update the Clearing Directory Param
        CA.Config.insertClrngDirParam(ClearingParamId, R.CLEARING.DIRECTORY.PARAM)
        GOSUB getUniqueId
        GOSUB updateClrngDir
    END
    
RETURN
*-----------------------------------------------------------------------------
updateEBFileUploadRecord:
*   Set the Error response details and update the EB.FILE.UPLOAD record with error details bez for Item processing, T24.UPLOAD.PROCESS will not update
*   the record with error details.
    oResponse<1> = ''
    oResponse<2> = -1
    oResponse<3> = 'Incorrect data in file'
    iServiceStatus = ''
    iServiceStatus = 'ERROR.IN.PROCESSING'
    EB.FileUpload.UpdateServiceStatus(fileId, iServiceStatus)
    
RETURN
*-----------------------------------------------------------------------------
fromClearingParamID:
*   Form the CLEARING.PARAM.ID
    ClearingParamId = paymentChannel:'.'
    
RETURN
*-----------------------------------------------------------------------------
getUniqueId:
    UNIQUE.KEY = ''
    iPrefix = ''
    saveApplication = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('CA.CLEARING.DIRECTORY')
    saveID = EB.SystemTables.getIdN()
    EB.SystemTables.setIdN('16')
    savePGM = EB.SystemTables.getPgmType()
    EB.SystemTables.setPgmType('L')
*   Call UniqueId Routine to get CLEARING.DIRECTORY ID
    EB.API.UniqueId(UNIQUE.KEY,iPrefix)
    EB.SystemTables.setIdN(saveID)
    EB.SystemTables.setApplication(saveApplication)
    EB.SystemTables.setPgmType(savePGM)
    
RETURN
*-----------------------------------------------------------------------------
getAltKeyVal:
*   Read clearing parameter record to find the reachability key combination.
    REACHABILITY.KEY.FIELD = R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpReachabilityKeyFields>
    keyFieldCount = DCOUNT(REACHABILITY.KEY.FIELD, @VM)
    CONVERT @VM TO @FM IN REACHABILITY.KEY.FIELD
    intCount = 1
    LOOP
    WHILE intCount LE keyFieldCount
        BEGIN CASE
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'NATIONAL CLR CODE'
                nccPresent = 1
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'PAYMENT CHANNEL'
                pmtChannelPresent = 1
        END CASE
        intCount = intCount + 1
    REPEAT
*   Based on the NCC and payment channel, form the alternate key
    altKeyVal = iNCCValue:'-':paymentChannel

RETURN
*-----------------------------------------------------------------------------
updateClrngDir:
*   Map the fields from the file uploaded into Clearing Directory Table
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPaymentChannel> = 'TUNCLG'
    GOSUB getncc
*   To check whether Upload record contains null data. No need to raise any error, if upload record contains null value, return from the method
    IF (iNCCValue EQ '') THEN
        GOSUB updateEBFileUploadRecord
        RETURN
    END
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrNationalClrCode> = iNCCValue
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrIsoNcc> = iNCCValue
    GOSUB getaddress
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrInstitutionName> = iAddressLen
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrScheme> = 'TUNTRF'
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrReachabilityType> = 'D'
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStatus> = 'ENABLED'
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStartDate> = systemDate
    GOSUB getAltKeyVal
    CONVERT @FM TO @VM IN altKeyVal
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAlternateKey,-1> = altKeyVal
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrClearingParameter> = ClearingParamId
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEffectiveDate> = systemDate
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrUploadDate>= systemDate
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrUploadFileName> = fileName
*   To update AUdit fields
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCurrNo> = 1
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrInputter,-1> = EB.SystemTables.getTno():"_":EB.SystemTables.getOperator()
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAuthoriser,-1> = EB.SystemTables.getTno():"_":EB.SystemTables.getOperator()
    EB.SystemTables.setTimeStamp(TIMEDATE())
    XDAT = OCONV(DATE(),"D4-")
    XDAT = XDAT[9,2]:XDAT[1,2]:XDAT[4,2]:EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAuditDateTime> = XDAT
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCoCode> = EB.SystemTables.getIdCompany()
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    GOSUB updateClrngDirList
*   Call the Wrapper routine to update the Clearing Directory
    CA.Contract.insertClearingDirectory(UNIQUE.KEY, R.CA.CLEARING.DIRECTORY)

RETURN
*-----------------------------------------------------------------------------
updateClrngDirList:
*   The gosub will insert the new clearing id in the list file
*   Concatenate Alternate Key and Effective Date to write into CLEARING.DIRECTORY.LIST
    effectiveDate = EB.SystemTables.getToday()
    newAltKeyVal = UNIQUE.KEY :'-':effectiveDate
    R.CA.CLEARING.DIRECTORY.LIST = CA.Contract.ClearingDirectoryList.Read(altKeyVal, clrDirListError)
*   Insert the new entry in the list
    IF R.CA.CLEARING.DIRECTORY.LIST EQ '' THEN
        R.CA.CLEARING.DIRECTORY.LIST = newAltKeyVal
    END ELSE
        R.CA.CLEARING.DIRECTORY.LIST = newAltKeyVal :@FM: R.CA.CLEARING.DIRECTORY.LIST
    END
    CA.Contract.insertClearingDirectoryList(altKeyVal, R.CA.CLEARING.DIRECTORY.LIST)
        
RETURN
*-----------------------------------------------------------------------------
getncc:
*   NCC is derived from first five value of the record to write into CLEARING.DIRECTORY.LIST
    iNCCValue=TRIM(origLineRecord[1,5])
   
RETURN
*-----------------------------------------------------------------------------
getaddress:
*   Address value is trimmed to reduce the total character
    iAddressVal1 = TRIM(SUBSTRINGS(origLineRecord,6,29))
    iAddressVal2 = TRIM(SUBSTRINGS(origLineRecord,35,140))
*   Address value is concatenated to form institution name value to write into CLEARING.DIRECTORY.LIST
    iAddressVal = iAddressVal1:' ':iAddressVal2
    iAddressLen = iAddressVal[1,105] ;* Address value Length is reduced to 105 character
    
RETURN
*-----------------------------------------------------------------------------
END
