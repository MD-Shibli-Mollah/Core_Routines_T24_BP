* @ValidationCode : MjoxMzIwNDYwNDQ3OkNwMTI1MjoxNjA3NDQ5MTU2NTI5Om1yLnN1cnlhaW5hbWRhcjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjE6MzA5OjI1OQ==
* @ValidationInfo : Timestamp         : 08 Dec 2020 23:09:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 259/309 (83.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE CAESIC.Foundation
SUBROUTINE CAESIC.CLG.DIR.UPLOAD.API(actionCheck, lineNo, fileId, origLineRecord, rT24UploadRecord, oResponse,oFuture)
*-----------------------------------------------------------------------------
*This routine is used to upload the data into CLEARING.DIRECTORY from the file sent by AFW team.
*-----------------------------------------------------------------------------
* Modification History :
* 30/11/2020 : Enhancement 4088414/ Task 4036154 EuroSIC Upload changes
*
*-----------------------------------------------------------------------------
* In this routine, we are uploading CA.CLEARING.DIRECTORY with the EUROSIC record recieved as CSV file.
* The new Version CA.CLEARING.DIRECTORY,UPLOADEUROSIC is built to extract data from the file and the mapping is done as per the fields in csv file.
*-----------------------------------------------------------------------------
    $USING EB.FileUpload
    $USING EB.SystemTables
    $USING EB.Utility
    $USING CA.Contract
    $USING CA.Config
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.TransactionControl
    $USING EB.Security
    $INSERT I_PaymentFrameworkService_DateRequest
*-----------------------------------------------------------------------------
* This routine is used to upload only ITEM and not the HEADER. First line is header in the file recieved.
* Hence the below condition
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
    uploadType = ''
    fileName = ''
    paymentChannel = ''
    scheme = ''
    bic = ''
    effectivedate = ''
    maxDaysInAdvance = ''
    ClearingParamId = ''
    altKeyVal = ''
    newAltKeyVal = ''
    participantType = ''
    iFileNameValue = ''
    iFileNameExtension = ''
    intCount = 1
    intConfKeyCount = 1
           
RETURN
*-----------------------------------------------------------------------------
process:
* Clearing and File type values can be determined from EB.FILE.UPLOAD record.
* So, read EB.FILE.UPLOAD with the fieldId and get record
*   Below validation will be done once for Header processing to handle Errors scenarios which might occurs for Record not found cases so that
*   In the EB.FILE.UPLOAD record, Service status will be updated with "ERROR IN PROCESSING" in T24 uplaod process routine.
*   If all validations are success, it returns from the flow and will be skipped for next header records.
*   Similarly below validation will happens for Item action to fetch the values like filename,reachabilityType etc which are required for
*   mapping clearing directory records.
    IF ( actionCheck EQ 'HEADER' AND lineNo EQ 1 ) OR ( actionCheck EQ 'ITEM' AND lineNo GE 2 ) THEN
        R.EB.FILE.UPLOAD = EB.FileUpload.FileUpload.Read(fileId, ebFileUploadErr)
        uploadType = FIELD(R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfUploadType>,'.',1)
        IF ebFileUploadErr NE '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Unable to read EB.FILE.UPLOAD'
            RETURN
        END
        recId= fileId:'-':'PURGE'
       
*Read CLEARING.DIRECTORY.LIST with Id as PURGE, to find out whether a record is available for PURGE
        R.CA.CLEARING.DIRECTORY.LIST = CA.Contract.ClearingDirectoryList.Read(recId, Error)
        IF R.CA.CLEARING.DIRECTORY.LIST EQ '' THEN
            R.CA.CLEARING.DIRECTORY.LIST = fileId
        END
        CA.Contract.insertClearingDirectoryList(recId, R.CA.CLEARING.DIRECTORY.LIST)
        uploadTypeId = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfUploadType>
        IF R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfFileName> EQ '' THEN
            fileName = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfSystemFileName>
        END ELSE
            fileName = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfFileName>
        END

*       To check whether Upload record contains null data.
        IF rT24UploadRecord EQ '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Incorrect data in file'
            RETURN
        END
    
*       To check for incorrect file extension other than .T files should be thrown error
        iFileNameExtension = FIELD(fileName,'.',2)
        IF iFileNameExtension NE 'csv' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Incorrect File Extension not supported'
            RETURN
        END
        
* CACHE.READ EB.FILE.UPLOAD.TYPE
        R.EB.FILE.UPLOAD.TYPE = EB.FileUpload.FileUploadType.CacheRead(uploadTypeId, ebFileUploadTypeErr)
        IF ebFileUploadTypeErr NE '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Unable to read EB.FILE.UPLOAD.TYPE'
            RETURN
        END
        
        paymentChannel = 'EUROSIC'
        scheme = 'CT'
        GOSUB fromClearingParamID
    
*Read the Clearing Directory Param Table to get the data for Effective date Calculation
        R.CLEARING.DIRECTORY.PARAM = CA.Config.ClearingDirectoryParam.Read(ClearingParamId, Error)
        IF Error NE '' THEN
            oResponse<1> = ''
            oResponse<2> = -1
            oResponse<3> = 'Unable to read Clearing Directory Param'
            RETURN
        END
    END
    IF actionCheck EQ 'HEADER' THEN
        oResponse<1> = 'Header Processing Completed for SIC'
        RETURN
    END
    
*   Below flow will be executed only for Item processing
    IF ( actionCheck EQ 'ITEM' AND lineNo GE 2 ) THEN
        offsetdate = R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpValidityOffsetDays>
        GOSUB getEffectiveDate
        GOSUB getEndDate
        R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastUploadDate> = EB.SystemTables.getToday()
        R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastEffectiveDate> = effectivedate
        R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastSourceFileName> = fileName
*Call the Wrapper routine to update the Clearing Directory Param
        CA.Config.insertClrngDirParam(ClearingParamId, R.CLEARING.DIRECTORY.PARAM)
        GOSUB getUniqueId
        GOSUB updateClrngDir
    END
    
RETURN
*-----------------------------------------------------------------------------
fromClearingParamID:
*Form the CLEARING.PARAM.ID
    ClearingParamId = paymentChannel:'.':scheme
    
RETURN
*-----------------------------------------------------------------------------
getEffectiveDate:
*   EB.API.Cdt(creationDate, maxDaysInAdvance,'')
    systemDate = OCONV(DATE(),"D-")[7,4] : OCONV(DATE(),"D-")[1,2] : OCONV(DATE(),"D-")[4,2]
    DAY.COUNT = +1
    EB.API.Cdt('', systemDate, DAY.COUNT)
    effectivedate = systemDate
    
RETURN
*-----------------------------------------------------------------------------
getEndDate:
    startDate = effectivedate
    date = effectivedate
    days = '30'
    GOSUB calculateDate
    endDate = oDate
    
RETURN
*-----------------------------------------------------------------------------
calculateDate:
*Calculating date based on the days and sign
    iDate = ''
    oDate = ''
    oDateResponse = ''
    iDate<DateRequest.serviceCode> = "MODC"                                                                 ;* Since calender date needs to be added sending MODC
    iDate<DateRequest.companyID> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
    iDate<DateRequest.beginDate> = date
    iDate<DateRequest.calcDays> = days
    iDate<DateRequest.calcSign> = "+"
    CALL PaymentFrameworkService.calculateDates(iDate,oDate,oDateResponse)
                  
RETURN
*-----------------------------------------------------------------------------
getAltKeyVal:
*   Reachability key fields are already predefined in field level itself.
*   So form an array with the Pre defined Reachablity fields and get the value for those fields in different array but in same positions
*   Loop through each reachablity key in the array and find whether that key is configured in REACHABILITY.KEY.FIELD in CA.CLEARING.DIRECTORY.PARAM
*   If that configured in PARAM table, get the value of that reachability key and form an Alternate key value
*   If more than one key configured in CA.CLEARING.DIRECTORY.PARAM table, concatenate values of those fields with the '-' and form Alternate key
*  preReachKeyFields = 'BIC' : @FM : 'SCHEME' : @FM : 'PAYMENT CHANNEL' : @FM : 'NATIONAL CLR CODE' :@FM: 'BIC/NATIONAL CLR CODE'
*  preReachKeyValues = bic : @FM : scheme : @FM : paymentChannel :@FM: ncc :@FM: BICNCC
    preReachKeyFields =  'SCHEME' : @FM : 'PAYMENT CHANNEL' :@FM: 'BIC/NATIONAL CLR CODE'
    preReachKeyValues =  scheme : @FM : paymentChannel :@FM: BICNCC
    reachKeyField = R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpReachabilityKeyFields>
    CONVERT @VM TO @FM IN reachKeyField
    keyFieldCount = DCOUNT(preReachKeyFields, @FM)
    configKeyFieldCount = DCOUNT(reachKeyField, @FM)
    FLAG = '1'
    altKeyVal1 = ''
    LOOP
    WHILE intCount LE configKeyFieldCount
        LOCATE reachKeyField<intCount> IN preReachKeyFields SETTING fieldPos THEN
*generate two alternate keys when both BIC and NCC are present
            key1 = ''
*count BICNCC value, if both BIC and NCC are present ie count 2, then generate two alternate keys (updating to variable altKeyVal1 and altKey)
*if only BIC or NCC then generate only one alternate key
            IF preReachKeyFields<fieldPos> = 'BIC/NATIONAL CLR CODE' THEN
                CNT = DCOUNT(preReachKeyValues<fieldPos> ,@VM)
*if count two then BIC and NCC updated to key1 and altKey
                IF CNT EQ 2 THEN
                    key1 = preReachKeyValues<fieldPos,2>
                    altKey  = preReachKeyValues<fieldPos,1>
                    FLAG = ''
                END ELSE
                    altKey = preReachKeyValues<fieldPos>
                    key1 = preReachKeyValues<fieldPos>
                END
            END ELSE
*case when preReachKeyFields not eual to BIC/NATIONAL CLR CODE
                altKey = preReachKeyValues<fieldPos>
                key1 = preReachKeyValues<fieldPos>
            END
*generating alternate keys
            IF intConfKeyCount EQ configKeyFieldCount THEN
                altKeyVal = altKeyVal:altKey
                IF key1 THEN
                    altKeyVal1 = altKeyVal1:key1
                END
            END ELSE
                altKeyVal = altKeyVal:altKey  : '-'
                IF key1 THEN
                    altKeyVal1 = altKeyVal1:key1 : '-'
                END
            END
            intConfKeyCount = intConfKeyCount + 1
        END
        intCount = intCount + 1
    REPEAT
*insert the generated alternate keys
    IF FLAG NE '1' THEN
        altKeyVal<1,-1> = altKeyVal1
    END
    
RETURN
*-----------------------------------------------------------------------------
getBicNcc:
* If BIC is present, then BIC has to considered to form alternate key
* If NCC is present, then BIC has to considered to form alternate key
* If BIC and NCC both are present, then both has to considered to form alternate key
    bic = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrBIC>
    nccvalue = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrNationalClrCode>
    NCCLength=LEN(nccvalue)
    IF NCCLength LT '6' THEN
        MaskCode = "6'0'R"  ;* if it is less than 6 digits, say 4, then pad 2 0s before the NCC to make it of length 3.
        traceNumP1 = FMT(nccvalue,MaskCode)  ;* NCC formatted to 7 digits.
        ncc =traceNumP1 ;*Ncc Value is a combination of BC No and Branch ID
    END
    BEGIN CASE
        CASE bic NE '' AND ncc NE ''
            BICNCC = bic
            BICNCC<-1> = ncc
            CONVERT @FM TO @VM IN BICNCC
        CASE bic EQ '' AND ncc NE ''
            BICNCC = ncc
        CASE bic NE '' AND ncc EQ ''
            BICNCC = bic
    END CASE
    
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
*Call UniqueId Routine to get CLEARING.DIRECTORY ID
    EB.API.UniqueId(UNIQUE.KEY,iPrefix)
    EB.SystemTables.setIdN(saveID)
    EB.SystemTables.setApplication(saveApplication)
    EB.SystemTables.setPgmType(savePGM)
    
RETURN
*-----------------------------------------------------------------------------
updateClrngDir:
*Map the fields from the file uploaded into Clearing Directory Table
    IF actionCheck EQ 'ITEM' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrBIC> = rT24UploadRecord<4>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrInstitutionName> = rT24UploadRecord<7>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrNationalClrCode> = rT24UploadRecord<5>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStatus> = 'ENABLED'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCity> = rT24UploadRecord<8>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCountry> = rT24UploadRecord<9>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStartDate> = effectivedate
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEndDate> = endDate
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrReachabilityType> = 'D'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPreferred> = 'NO'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPurgeEligibility> = 'NO'
        GOSUB getBicNcc
        GOSUB getAltKeyVal
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPaymentChannel> = paymentChannel
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrScheme> = scheme
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrUploadDate> = EB.SystemTables.getToday()
        IF startDate LT EB.SystemTables.getToday() THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEffectiveDate> = effectivedate
        END ELSE
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEffectiveDate> = startDate
        END
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrUploadFileName> = fileName
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrClearingParameter> = ClearingParamId
        CONVERT @FM TO @VM IN altKeyVal
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAlternateKey,-1> = altKeyVal
        IF rT24UploadRecord<2> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Groupe'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<2>
        END
        IF rT24UploadRecord<3> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'BC No'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<3>
        END
        IF rT24UploadRecord<30> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Branch ID'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<30>
        END
        IF rT24UploadRecord<6> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'New BC No'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<6>
        END
        IF rT24UploadRecord<10> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Head Office'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<10>
        END
        IF rT24UploadRecord<11> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'BC Type'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<11>
        END
        IF rT24UploadRecord<13> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'euroSIC'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<13>
        END
        IF rT24UploadRecord<14> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Language'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<14>
        END
        IF rT24UploadRecord<15> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Short Name'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<15>
        END
        address = rT24UploadRecord<16>
        postalAddress = rT24UploadRecord<17>
        zipCode = rT24UploadRecord<18>
        phone = rT24UploadRecord<19>
        fax = rT24UploadRecord<20>
        dialingCode = rT24UploadRecord<23>
*  Map only when any of the tags values are present for address.
        IF address  NE ' ' OR postalAddress NE ' ' OR zipCode NE ' ' OR phone NE ' '  OR fax NE ' ' OR dialingCode NE ' ' THEN
            iAddress = address:',':postalAddress:',':zipCode:',':phone:',':fax:',':dialingCode
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Address'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = iAddress
        END
        IF rT24UploadRecord<27> NE '' THEN
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Sight Deposit Account'
            R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = rT24UploadRecord<27>
        END
*       To update AUdit fields
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
*Call the Wrapper routine to update the Clearing Directory
        CA.Contract.insertClearingDirectory(UNIQUE.KEY, R.CA.CLEARING.DIRECTORY)
      
    END

RETURN
*-----------------------------------------------------------------------------
updateClrngDirList:
*Update the Clearing Directory List only if the below condition matches
    recStatus = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStatus>
    recEndDate = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEndDate>
    Today = ''
    IF recEndDate LT EB.SystemTables.getToday() THEN
        Today = EB.SystemTables.getToday()
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPurgeEligibility> = 'YES'
    END
    GOSUB writeClrngDirList;* did this to ensure the new Purge logic to work for past records as well.
    
RETURN
*-----------------------------------------------------------------------------
writeClrngDirList:
*Concatenate Alternate Key and Effective Date to write into CLEARING.DIRECTORY.LIST
    newAltKeyVal = UNIQUE.KEY :'-':effectivedate
* The gosub will insert the new clearing id in the list file
    totalAltk = ''
    altKeyCount = 1
    totalAltk = DCOUNT(altKeyVal,@VM)
*insert the alternate keys to CA.CLEARING.DIRECTORY.LIST
    LOOP
    WHILE altKeyCount LE totalAltk
        R.CA.CLEARING.DIRECTORY.LIST1 = ''
        listID = altKeyVal<1,altKeyCount>
        R.CA.CLEARING.DIRECTORY.LIST = CA.Contract.ClearingDirectoryList.Read(listID, Error)
* if there is no preferred entry present then insert the new entry in the list
        IF R.CA.CLEARING.DIRECTORY.LIST EQ '' THEN
            R.CA.CLEARING.DIRECTORY.LIST1 = newAltKeyVal
        END ELSE
            R.CA.CLEARING.DIRECTORY.LIST1 = newAltKeyVal :@FM: R.CA.CLEARING.DIRECTORY.LIST
        END
        CA.Contract.insertClearingDirectoryList(listID, R.CA.CLEARING.DIRECTORY.LIST1)
        altKeyCount = altKeyCount + 1
    REPEAT
    
RETURN
*------------------------------------------------------------------------------
END
