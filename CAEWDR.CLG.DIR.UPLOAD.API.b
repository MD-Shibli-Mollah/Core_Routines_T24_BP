* @ValidationCode : MjotMTgzMTk2MTE5OkNwMTI1MjoxNjAwNTA0NDEyMzc4Om1yLnN1cnlhaW5hbWRhcjoxMDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjQzNzozNjg=
* @ValidationInfo : Timestamp         : 19 Sep 2020 14:03:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 368/437 (84.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE CAEWDR.Foundation
SUBROUTINE CAEWDR.CLG.DIR.UPLOAD.API(actionCheck, lineNo, fileId, origLineRecord, rT24UploadRecord, oResponse,oFuture)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*31/08/2020 - Enhancement Id-3831793/Task-3910568 - Clearing Directory upload and reachability Coding
*10/09/2020 - Task 3959757 Mapping Issues in CA.CLEARING.DIRECTORY
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING CA.ClearingReachability
    $USING EB.FileUpload
    $USING EB.SystemTables
    $USING CA.Contract
    $USING CA.Config
    $USING EB.API
    $USING EB.Security
    DEFFUN CHARX()
*-----------------------------------------------------------------------------
*This routine is used to upload the XML file recieved from EQUEN
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
    paymentChannel = 'EWSEPA'
    scheme = ''
    bic = ''
    effectivedate = ''
    ClearingParamId = ''
    fileValidityDate = ''
    altKeyVal = ''
    newAltKeyVal = ''
    participantType = ''
    iFileNameValue = ''
    iFileNameExtension = ''
    iNm = ''
    iMsgId=''

RETURN
*-----------------------------------------------------------------------------
parseEquensFile:
*Parsing te XML file tags into T24 varaibles
    messageContent = FIELD(rT24UploadRecord, '<rocs.001.001.06>',2)
    
    rviContent = messageContent
    messageContent = TRIM(messageContent)
    LOOP UNTIL messageContent EQ '' DO
        SPOS = INDEX(messageContent,'<',1)
        EPOS = INDEX(messageContent,'>',1)
        tag = messageContent[SPOS+1,EPOS-SPOS-1]
        oldIncomingMsg = messageContent
        messageContent = messageContent[EPOS+1,LEN(messageContent)-EPOS]

        IF INDEX(tag,'/',1) NE 0 THEN
            IF tag = '/GrpHdr' THEN
                GOSUB mapHeader
            END
            IF tag = '/RchEntry' THEN
                GOSUB getEffectiveDate
                GOSUB updateClrngDir
                oMessageData = ''
            END
            FIND headTag IN tags SETTING outputPos THEN
                IF oMessageData<outputPos> NE '' THEN
                    GOSUB assignOut
                END ELSE
                    oMessageData<outputPos,1> = FIELD(oldIncomingMsg,'<':tag,1)
                END
            END
            tag = tag[2,LEN(tag)-1]
            count = DCOUNT(headTag,'_')
            IF count GT 1 THEN
                headTag = headTag[1,LEN(headTag)-1-LEN(tag)]
            END ELSE
                headTag = ''
            END
            CONTINUE
        END
        IF headTag EQ '' THEN
            headTag = tag
        END ELSE
            GOSUB assignIndices
            headTag = headTag:'_':tag
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
assignIndices:
    iHeadTag = FIELD(headTag,'_',1)
    IF iHeadTag EQ 'GrpHdr' THEN
        
        tags<CA.ClearingReachability.ClearingUpload.msgId> = headTag:'_MsgId'
    
        tags<CA.ClearingReachability.ClearingUpload.creationDtTm> = headTag:'_CreDtTm'

        tags<CA.ClearingReachability.ClearingUpload.BICOrBEI> = headTag:'_BICOrBEI'
    
        tags<CA.ClearingReachability.ClearingUpload.prtryId> = headTag:'_PrtryId'
    
        tags<CA.ClearingReachability.ClearingUpload.prtryIdNm> = headTag:'_Nm'
    
        tags<CA.ClearingReachability.ClearingUpload.prtryIdAddress> = headTag:'_Adr'
    
        tags<CA.ClearingReachability.ClearingUpload.fullTable> = headTag:'_FullTable'
    
        tags<CA.ClearingReachability.ClearingUpload.fileValidityDate> = headTag:'_FileValidityDate'
    END

    IF iHeadTag EQ 'RchEntry' THEN
  
        tags<CA.ClearingReachability.ClearingUpload.status> = headTag:'_Status'
    
        tags<CA.ClearingReachability.ClearingUpload.fromDtTm> = headTag:'_FrDtTm'
    
        tags<CA.ClearingReachability.ClearingUpload.toDtTm> = headTag:'_ToDtTm'
    
        tags<CA.ClearingReachability.ClearingUpload.BIC> = headTag:'_BIC'
    
        tags<CA.ClearingReachability.ClearingUpload.serviceType> = headTag:'_SvcTp'
    
        tags<CA.ClearingReachability.ClearingUpload.localInstrument> = headTag:'_LclInstrm'
           
        tags<CA.ClearingReachability.ClearingUpload.csmBICOrBEI> = headTag:'_BICOrBEI'
    
        tags<CA.ClearingReachability.ClearingUpload.csmPrtryId> = headTag:'_PrtryId'
    
        tags<CA.ClearingReachability.ClearingUpload.preferredIndicator> = headTag:'_PreferredIndicator'
    
        tags<CA.ClearingReachability.ClearingUpload.amount> = headTag:'_Amount'
    
        tags<CA.ClearingReachability.ClearingUpload.ccy> = headTag:'_Ccy'
        
        tags<CA.ClearingReachability.ClearingUpload.rchCutOffTime> = headTag:'_Time'
        
        tags<CA.ClearingReachability.ClearingUpload.rchCutOffRelDays> = headTag:'_RelDays'
        
        tags<CA.ClearingReachability.ClearingUpload.productName> = headTag:'_ProductName'
        
    
        IF headTag EQ 'RchEntry_Participant_NmAndAdr' THEN
        
            tags<CA.ClearingReachability.ClearingUpload.nm> = headTag:'_Nm'
            
        END
        IF headTag EQ 'RchEntry_Participant_NmAndAdr_Adr_Strd' THEN
        
            tags<CA.ClearingReachability.ClearingUpload.ctry> = headTag:'_Ctry'
        END
       
        IF headTag EQ 'RchEntry_CSM_PtyId_NmAndAdr' THEN
            
            tags<CA.ClearingReachability.ClearingUpload.csmPrtryIdNm> = headTag:'_Nm'
            
            tags<CA.ClearingReachability.ClearingUpload.csmPrtryIdAddress> = headTag:'_Adr'
        END
    
        IF headTag EQ 'RchEntry_CutOff' THEN
            tags<CA.ClearingReachability.ClearingUpload.cutOffTimeZone> = headTag:'_TimeZone'
        END
    
        IF headTag EQ 'RchEntry_SettlmConfirm' THEN
            tags<CA.ClearingReachability.ClearingUpload.guaranteeTime> = headTag:'_GuaranteedTime'
        
            tags<CA.ClearingReachability.ClearingUpload.daysDelay> = headTag:'_DaysDelay'
        
            tags<CA.ClearingReachability.ClearingUpload.settleTimeZone> = headTag:'_TimeZone'
        END
    
        IF headTag EQ 'RchEntry_SupportedAOS' THEN
            
            tags<CA.ClearingReachability.ClearingUpload.AOS> = headTag:'_AOSId'
            
        END

    END
       
RETURN
*------------------------------------------------------------------------------
assignOut:
    temp = oMessageData<outputPos>
    vmCount = DCOUNT(temp,@VM)
    oMessageData<outputPos,vmCount+1> = FIELD(oldIncomingMsg,'<':tag,1)
    
RETURN
*-----------------------------------------------------------------------------
process:
* Clearing and File type values can be determined from EB.FILE.UPLOAD record.
* So, read EB.FILE.UPLOAD with the fieldId and get record
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
    
*   Get fileName from EB.FILE.UPLOAD record
    uploadTypeId = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfUploadType>
    IF R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfFileName> EQ '' THEN
        fileName = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfSystemFileName>
    END ELSE
        fileName = R.EB.FILE.UPLOAD<EB.FileUpload.FileUpload.UfFileName>
    END
    
*       To check for incorrect file extension other than .T files should be thrown error
    iFileNameExtension = FIELD(fileName,'.',5)
    IF iFileNameExtension NE 'xml' THEN
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
    GOSUB fromClearingParamID
*Read the Clearing Directory Param Table to get the data for Effective date Calculation
    R.CLEARING.DIRECTORY.PARAM = CA.Config.ClearingDirectoryParam.Read(ClearingParamId, Error)
    IF Error NE '' THEN
        oResponse<1> = ''
        oResponse<2> = -1
        oResponse<3> = 'Unable to read Clearing Directory Param'
        RETURN
    END
    GOSUB parseEquensFile
    R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastUploadDate> = systemDate
    R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastEffectiveDate> = effectivedate
    R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpLastSourceFileName> = fileName
*Call the Wrapper routine to update the Clearing Directory Param
    CA.Config.insertClrngDirParam(ClearingParamId, R.CLEARING.DIRECTORY.PARAM)
*this is to update the EB.FILE.UPLOAD table status.
    IF actionCheck EQ '' THEN
        oResponse<1> = 'Header is not required for EQUENS Clearing'
        RETURN
    END
    
RETURN
*-----------------------------------------------------------------------------
fromClearingParamID:
*Form the CLEARING.PARAM.ID from the file name.
    ClearingParamId = paymentChannel:'.'
    
RETURN
*-----------------------------------------------------------------------------
getEffectiveDate:
    creationDate = fileValidityDate
    iCreationDate = FIELD(creationDate,'T',1)
    IF iCreationDate NE '' THEN
        year = FIELD(iCreationDate,'-',1)
        month = FIELD(iCreationDate,'-',2)
        date = FIELD(iCreationDate,'-',3)
        finalCreationDate = year:month:date
    END

*   Get system date
    systemDate = OCONV(DATE(),"D-")[7,4] : OCONV(DATE(),"D-")[1,2] : OCONV(DATE(),"D-")[4,2]

*   If effective date is equal or less than system date, then set effective date next working day
    IF finalCreationDate LE systemDate THEN
        getToday = EB.SystemTables.getToday()
        DAY.COUNT = +1
        EB.API.Cdt('', getToday, DAY.COUNT)
        effectivedate = getToday
    END ELSE
        effectivedate =  finalCreationDate
    END

RETURN
*-----------------------------------------------------------------------------
getAltKeyVal:
    bic = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrBIC>
    altKeyVal = ''
* Read clearing parameter record to find the reachability key combination.
    preReachKeyFields = 'PAYMENT CHANNEL' : @FM : 'SCHEME' : @FM : 'BIC'
    preReachKeyValues = paymentChannel : @FM : scheme : @FM : bic
    reachKeyField = R.CLEARING.DIRECTORY.PARAM<CA.Config.ClearingDirectoryParam.CacdpReachabilityKeyFields>
    CONVERT @VM TO @FM IN reachKeyField
    keyFieldCount = DCOUNT(preReachKeyFields, @FM)
    configKeyFieldCount = DCOUNT(reachKeyField, @FM)
    intCount = 1        ;   intConfKeyCount = 1
    LOOP
    WHILE intCount LE configKeyFieldCount
        LOCATE reachKeyField<intCount> IN preReachKeyFields SETTING fieldPos THEN
            IF intConfKeyCount EQ configKeyFieldCount THEN
                altKeyVal = altKeyVal:preReachKeyValues<fieldPos>
            END ELSE
                altKeyVal = altKeyVal:preReachKeyValues<fieldPos>  : '-'
            END
            intConfKeyCount = intConfKeyCount + 1
        END
        intCount = intCount + 1
    REPEAT

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
*for each BIC from XML, mapping other required fields and writing into clearing directory
    R.CA.CLEARING.DIRECTORY = ''
    R.CA.CLEARING.DIRECTORY = R.CA.CLEARING.DIRECTORY1
    GOSUB getUniqueId
    IF oMessageData<CA.ClearingReachability.ClearingUpload.BIC> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrBIC> = oMessageData<CA.ClearingReachability.ClearingUpload.BIC>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.ctry> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCountry> = oMessageData<CA.ClearingReachability.ClearingUpload.ctry>
    END
    
    GOSUB getScheme
    GOSUB getAltKeyVal
    GOSUB getInstitution
    GOSUB getStartDate
    GOSUB getENDDate
    GOSUB getAOS
    GOSUB mapAuditFields
    GOSUB mapCommon
    GOSUB updateClrngDirList
    
RETURN
*-----------------------------------------------------------------------------
getScheme:
* forming the Scheme value by concatenating :DD with Localinstrument type
    IF oMessageData<CA.ClearingReachability.ClearingUpload.productName> NE '' THEN
        scheme = oMessageData<CA.ClearingReachability.ClearingUpload.productName>
        BEGIN CASE
            CASE scheme EQ 'SCT'
                scheme = 'SCT'
            CASE scheme EQ 'SDD core'
                scheme = 'SDDCORE'
            CASE scheme EQ 'SDD b2b'
                scheme = 'SDDB2B'
        END CASE
    END
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrScheme> = scheme

RETURN
*-----------------------------------------------------------------------------
getInstitution:
*for each BIC, Mapping the Institution name read from the XML file
    IF oMessageData<CA.ClearingReachability.ClearingUpload.nm> NE '' THEN
        iNm = oMessageData<CA.ClearingReachability.ClearingUpload.nm>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrInstitutionName> = iNm[1,140]
    END
    
RETURN
*-----------------------------------------------------------------------------
getStartDate:
*for each BIC, Mapping the Start date read from the XML file
    IF oMessageData<CA.ClearingReachability.ClearingUpload.fromDtTm> NE '' THEN
        iStartDate = oMessageData<CA.ClearingReachability.ClearingUpload.fromDtTm>
        startDate = FIELD(iStartDate,'T',1)
        IF startDate NE '' THEN
            year = FIELD(startDate,'-',1)
            month = FIELD(startDate,'-',2)
            date = FIELD(startDate,'-',3)
            newStartDate = year:month:date
                
            IF newStartDate LE systemDate THEN
                getToday = EB.SystemTables.getToday()
                DAY.COUNT = +1
                EB.API.Cdt('', getToday, DAY.COUNT)
                actualStartDate = getToday
            END ELSE
                actualStartDate =  newStartDate
            END
        END
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStartDate> = actualStartDate
    END
    
RETURN
*-----------------------------------------------------------------------------
getENDDate:
*for each BIC, Mapping the End date read from the XML file
    IF oMessageData<CA.ClearingReachability.ClearingUpload.toDtTm> NE '' THEN
        iEndDate = oMessageData<CA.ClearingReachability.ClearingUpload.toDtTm>
        endDate = FIELD(iEndDate,'T',1)
        IF endDate NE '' THEN
            year = FIELD(endDate,'-',1)
            month = FIELD(endDate,'-',2)
            date = FIELD(endDate,'-',3)
            actualEndDate = year:month:date
        END
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEndDate> = actualEndDate
    END
    
RETURN
*-----------------------------------------------------------------------------
getAOS:
*for each BIC, Mapping the AOS read from the XML file
    IF oMessageData<CA.ClearingReachability.ClearingUpload.AOS> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAos> = oMessageData<CA.ClearingReachability.ClearingUpload.AOS>
    END
    
RETURN
*-----------------------------------------------------------------------------
mapAuditFields:
*       To update AUdit fields
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCurrNo> = 1
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrInputter> = EB.SystemTables.getTno():"_":EB.SystemTables.getOperator()
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAuthoriser> = EB.SystemTables.getTno():"_":EB.SystemTables.getOperator()
        
    EB.SystemTables.setTimeStamp(TIMEDATE())
    XDAT = OCONV(DATE(),"D4-")
    XDAT = XDAT[9,2]:XDAT[1,2]:XDAT[4,2]:EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAuditDateTime> = XDAT
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrCoCode> = EB.SystemTables.getIdCompany()
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>

RETURN
*-----------------------------------------------------------------------------
mapHeader:
    IF oMessageData<CA.ClearingReachability.ClearingUpload.fileValidityDate> NE '' THEN
        fileValidityDate = oMessageData<CA.ClearingReachability.ClearingUpload.fileValidityDate>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.msgId> NE '' THEN
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Message Identification'
        iMsgId = oMessageData<CA.ClearingReachability.ClearingUpload.msgId>
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = iMsgId[1,35]
    END

    IF oMessageData<CA.ClearingReachability.ClearingUpload.creationDtTm> NE '' THEN
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Creation Date and Time'
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.creationDtTm>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.BICOrBEI> NE '' THEN
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Party Identification BICorBEI'
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.BICOrBEI>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.prtryId> NE '' THEN
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Party Identification Proprietary Idetification'
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.prtryId>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.prtryIdNm> NE '' THEN
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Party Identification Name'
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.prtryIdNm>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.prtryIdAddress> NE '' THEN
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Party Identification Address'
        R.CA.CLEARING.DIRECTORY1<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.prtryIdAddress>
    END
    
RETURN
*-----------------------------------------------------------------------------
mapCommon:
*Mapping the Fixed values to the Clearing directory
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrReachabilityType> = 'D'
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPaymentChannel> = paymentChannel
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrModifiactionFlag> = ''
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStatus> = 'ENABLED'
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPreferred> = 'NO'
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPurgeEligibility> = 'Yes'
                            
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrUploadDate> = systemDate
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEffectiveDate> = effectivedate
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrUploadFileName> = fileName
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrClearingParameter> = ClearingParamId
    R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAlternateKey> = altKeyVal
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.address> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'PSP Address'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.address>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.localInstrument> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Local Instrument'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.localInstrument>
    END
    
* getting context name-value pair for serviceType type
    IF oMessageData<CA.ClearingReachability.ClearingUpload.serviceType> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Service Type'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.serviceType>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.csmBICOrBEI> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'CSM Party Identification BICorBEI'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.csmBICOrBEI>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.csmPrtryId> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'CSM Party Identification Proprietary Idetification'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.csmPrtryId>
    END
    IF oMessageData<CA.ClearingReachability.ClearingUpload.csmPrtryIdNm> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'CSM Party Identification Name'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.csmPrtryIdNm>
    END
    IF oMessageData<CA.ClearingReachability.ClearingUpload.csmPrtryIdAddress> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'CSM Party Identification Address'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.csmPrtryIdAddress>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.preferredIndicator> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Preferred Indicator'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = '1'
    END
      
    IF oMessageData<CA.ClearingReachability.ClearingUpload.amount> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Fee per Transaction Amount'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.amount>
    END

    IF oMessageData<CA.ClearingReachability.ClearingUpload.ccy> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Fee per Transaction Currency'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.ccy>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.rchCutOffTime> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Cut Off Time'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.rchCutOffTime>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.rchCutOffRelDays> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Cut Off Rel Days'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.rchCutOffRelDays>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.cutOffTimeZone> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Cut Off Time Zone'
        iCutOffTimeZone = oMessageData<CA.ClearingReachability.ClearingUpload.cutOffTimeZone>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = iCutOffTimeZone[1,16]
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.guaranteeTime> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Gauranteed Time'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.guaranteeTime>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.daysDelay> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Days Delay'
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = oMessageData<CA.ClearingReachability.ClearingUpload.daysDelay>
    END
    
    IF oMessageData<CA.ClearingReachability.ClearingUpload.settleTimeZone> NE '' THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextName,-1> = 'Settlement Confirmation Time Zone'
        iStlTimeZone = oMessageData<CA.ClearingReachability.ClearingUpload.settleTimeZone>
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrContextValue,-1> = iStlTimeZone[1,16]
    END
    
*Call the Wrapper routine to update the Clearing Directory
    CA.Contract.insertClearingDirectory(UNIQUE.KEY, R.CA.CLEARING.DIRECTORY)

RETURN
*-----------------------------------------------------------------------------
updateClrngDirList:
*Update the Clearing Directory List only if the below condition matches
    recStatus = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStatus>
    recEndDate = R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEndDate>
    IF recEndDate LT EB.SystemTables.getToday() THEN
        R.CA.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrPurgeEligibility> = 'YES'
    END
    GOSUB writeClrngDirList
    
RETURN
*-----------------------------------------------------------------------------
writeClrngDirList:
*Concatenate Alternate Key and Effective Date to write into CLEARING.DIRECTORY.LIST
    newAltKeyVal = UNIQUE.KEY :'-':effectivedate
* The gosub will insert the new clearing id in the list file
    R.CA.CLEARING.DIRECTORY.LIST = CA.Contract.ClearingDirectoryList.Read(altKeyVal, Error)
    totRec = DCOUNT(R.CA.CLEARING.DIRECTORY.LIST,@FM)
* if already there is a preferred entry present then avoid insertion of the new entry.
    IF totRec EQ '1' THEN
        secondPosVal = FIELDS(R.CA.CLEARING.DIRECTORY.LIST<totRec>,'-',2)
    END
* if there is no preferred entry present then insert the new entry in the list
    IF R.CA.CLEARING.DIRECTORY.LIST EQ '' THEN
        R.CA.CLEARING.DIRECTORY.LIST1 = newAltKeyVal
    END ELSE
        R.CA.CLEARING.DIRECTORY.LIST1 = newAltKeyVal :@FM: R.CA.CLEARING.DIRECTORY.LIST
    END
    CA.Contract.insertClearingDirectoryList(altKeyVal, R.CA.CLEARING.DIRECTORY.LIST1)

RETURN
*-----------------------------------------------------------------------------
END

