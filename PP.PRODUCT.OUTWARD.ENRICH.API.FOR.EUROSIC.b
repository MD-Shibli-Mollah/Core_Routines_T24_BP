* @ValidationCode : MjoxMTk1Mjk5MDA0OkNwMTI1MjoxNjExOTA0MjA0NjY4OnNoYXJtYWRoYXM6OTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjI5NjoyMjk=
* @ValidationInfo : Timestamp         : 29 Jan 2021 12:40:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sharmadhas
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 229/296 (77.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE PPESIC.Foundation
SUBROUTINE PP.PRODUCT.OUTWARD.ENRICH.API.FOR.EUROSIC(iPaymentDets,ioIFEmitDets)
*-----------------------------------------------------------------------------
**This is a new Wrapper API routine introduced to enhance cover information for EUROSIC cover payments.
*It is called from PP.OutwardMappingFramework.enrichOutMessageDetails routine.
*-----------------------------------------------------------------------------
* Modification History :
*30/11/2020 - Enhancement 3777154 / Task 4043972 - API added as a part of EUROSIC Clearing.
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.OutwardInterfaceService
    $USING PP.PaymentWorkflowGUI
    $USING PP.OutwardMappingFramework
    $USING EB.SystemTables
    $USING PP.PaymentFrameworkService
    $USING PP.LocalClearingService
    $USING EB.API
    $USING PP.SwiftOutService
    $USING PP.CountryIBANStructureService
    $USING EB.DataAccess
    $USING PP.PaymentWorkflowDASService
    $USING DE.API
    $USING PP.InwardMappingFramework
    $USING DE.Messaging
    
    $INSERT I_DAS.ISO.CLEARING.SYSTEM.ID
    $INSERT I_DAS.ISO.CLEARING.SYSTEM.ID.NOTES
*-----------------------------------------------------------------------------

    GOSUB initialise ; *Initialise the local variables used
    IF clearingTransactionType MATCHES 'RT':@VM:'RI' THEN
        GOSUB updateSvcTypeIdentifier
    END
    GOSUB updateBulkReferenceOutgoing
    GOSUB enrichCoverInfo
    GOSUB enrichCamt.029
RETURN

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Initialise the local variables used. </desc>
    companyID = ''
    ftNumber = ''
    iporTransactionDets = ''
    noOfSplits = ''
    splitTxnAmount = ''
    POS = ''
    POS1 = ''
    sequenceNo = ''
    count = ''
    fileReference = ''
    oBulkRef = ''
    coverflag = ''
    
    companyID = FIELDS(iPaymentDets,'*',1)
    ftNumber = FIELDS(iPaymentDets,'*',2)
    
    iPaymentDetails = RAISE(ioIFEmitDets<2>)
    iporTransactionDets = RAISE(ioIFEmitDets<3>)
    iCreditPartyDet = RAISE(ioIFEmitDets<4>)
    iPrtyDbtDetails = RAISE(ioIFEmitDets<5>)
    iPaymentInformation = RAISE(ioIFEmitDets<6>)
    iAdditionalInfDetails = RAISE(ioIFEmitDets<7>)
    iAccInfoDetails = RAISE(ioIFEmitDets<8>)
    iRemittanceInfo = RAISE(ioIFEmitDets<9>)
    iCanReq = RAISE(ioIFEmitDets<10>)
    iCoverinfo = RAISE(ioIFEmitDets<11>)
    iPaymentFlowDets = RAISE(ioIFEmitDets<12>)
    iRegulatoryRepDets = RAISE(ioIFEmitDets<13>)
    iPorRelatedRemittanceInfo = RAISE(ioIFEmitDets<14>)
    iOutboundInfDetails = RAISE(ioIFEmitDets<15>)
    
    IF iporTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.clearingTransactionType> NE '' THEN
        clearingTransactionType = iporTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.clearingTransactionType>
    END ELSE
        clearingTransactionType = iPaymentDetails<PP.LocalClearingService.PaymentDetailsA.clearingTransactionType>
    END
    iCompanyBIC = iporTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.companyBIC>
    cancelReqId = iCanReq<PP.LocalClearingService.PpCanReq.canReqCancelReqId>
    
    pmtOutMsgType = ''
   
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= enrichCoverInfo>
enrichCoverInfo:
*** <desc></desc>
    coverInfo = RAISE(ioIFEmitDets<11>)
    porTransactionDets = RAISE(ioIFEmitDets<3>)
    
    creditPartyDets = RAISE(ioIFEmitDets<4>)
    debitPartyDets = RAISE(ioIFEmitDets<5>)
      
    iPaymentId=''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    GOSUB setCoverFlag  ;* set cover Flag as Y when Validation Flag is COV
    GOSUB updateLclInstPrty ; * If LclInstPrty is not provided, update the default value
    GOSUB mapCoverInfo ; *map Cover details based on the value in free line
 
RETURN
*** </region>
*-------------------------------------------------------------------------------

*** <region name= setCoverFlag>
setCoverFlag:
*** <desc>set Cover Flag as Y in Por transaction details when the Validation Flag is COV </desc>
 
    iPaymentId<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    iPaymentId<PP.PaymentWorkflowDASService.PaymentID.companyID> = companyID

* get the POR.TRANSACTION record
    
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentId, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
    ctrBtrIndicator = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ctrBtrIndicator>
    ValidationFlag = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.validationFlag>
    coverflag = oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.coverFlag>
    IF ValidationFlag EQ 'COV' THEN
        porTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.coverFlag> = 'Y' ;* set Cover Flag to Y as only Validation Flag will be set for redirected cover payments
    END
    
    ioIFEmitDets<3> = LOWER(porTransactionDets) ;* assign to the output variable
 
RETURN
*** </region>
*-------------------------------------------------------------------------------
updateBulkReferenceOutgoing:
    IF clearingTransactionType EQ 'SR' OR clearingTransactionType EQ 'SR-CA' OR clearingTransactionType EQ 'SR-CM' THEN
        porTransactionDets = RAISE(ioIFEmitDets<3>)
        GOSUB getEBQAInformation
        porTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.bulkReferenceOutgoing> = bulkReferenceOutgoing
        ioIFEmitDets<3> = LOWER(porTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
getEBQAInformation:
*** <desc>Paragraph to get details from EBQA </desc>
    oriEBQAid = iCanReq<PP.LocalClearingService.PpCanReq.ebQaId>
    IF oriEBQAid NE '' THEN
        getEBQARecord = DE.Messaging.EbQueriesAnswers.Read(oriEBQAid, errCamtInfomation)
        IF errCamtInfomation EQ '' THEN
            bulkReferenceOutgoing = getEBQARecord<DE.Messaging.EbQueriesAnswers.EbQaSentReference>
            bulkReferenceOutgoing = FIELDS(bulkReferenceOutgoing,'##',2)
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= mapCoverInfo>
mapCoverInfo:
*** <desc>map Cover details based on the value in free line </desc>
*
* roles for which the value in free line has to be validated and determined if it is a valid IBAN or other identification


    IF oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.incomingMessageType> NE '202' OR oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType> NE 'pacs.009' THEN
        RETURN
    END
    
    msgRoleList = coverInfo<PP.SwiftOutService.CoverDetails.coverInformationCode>
    roleList = 'ORDPTY':@VM:'ORDINS':@VM:'INTINS':@VM:'ACWINS':@VM:'BENFCY'

    LOOP
    
        REMOVE eachRole FROM msgRoleList SETTING roleExists
    
    WHILE eachRole MATCHES roleList
    
        LOCATE eachRole IN coverInfo<PP.SwiftOutService.CoverDetails.coverInformationCode,1> SETTING rolePos THEN ;* locate each role in POR.COVERINF and retrive value in FreeLine
 
* check if the value in free line is a valid IBAN, if so map the value in IBAN field. If the value is not a valid IBAN, map in Other id field
* when the value in FreeLine doesnot start with a '/' , and if the tag is 50A, map in Bic field
        
            IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[1,1] EQ '/' AND coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[2,1] NE '/' THEN

                accountLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[2,37] ;* value in freeline without '/'
                GOSUB checkValidIban
 
                IF oDetIBANResponse<PP.CountryIBANStructureService.PaymentResponse.returnCode> EQ '' THEN
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfIban,rolePos> =  coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[2,37] ;* if the value is a valid IBAN
                END ELSE

                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfOtherId,rolePos> =  coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[2,37] ;* if the value is not a IBAN
                END
                addChck1 = 'Y'
            END ELSE

                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[1,1] NE '/' AND (coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '50A' OR coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '52A' OR coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '56A' OR coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '57A' OR coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '59A') THEN
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfBic,rolePos> = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos> ;* identifier code
                END
            END

* For the below mentioned roles, when the coverinfofreeline begins with //, the first two chars after the // is the clearing system code. Using ISO.CLEARING.SYSTEM.ID table,
* get the corresponding ISO Swift Code and map in the ClearingSystemCode variable. The rest of the characters must be mapped in ClearingSystemMemberId variable
*
* For example, if CoverInfFreeLine1 of ORDINS contains '//BL5007001' , and the SwiftPrefix BL belongs to ISO.CLEARING.SYSTEM.ID of 'DEBLZ'
* then, ClearingSystemCode will be 'DEBLZ' and ClearingMemberId will be '5007001'
    
            IF eachRole MATCHES 'ORDINS':@VM:'INTINS':@VM:'ACWINS' THEN
                
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[1,2] EQ '//' THEN
                    tableName = 'ISO.CLEARING.SYSTEM.ID'
                    theList = dasSelSwiftPrefix
                    tableSuffix= ''
                    theArgs<1> = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[3,2]
                    EB.DataAccess.Das(tableName,theList,theArgs,tableSuffix)
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfClrSysCd,rolePos> =  theList<1>
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfClrSysMmbId,rolePos> = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[5,32]
                END
            END

* When the CoverInfFreeLine1 of 50F ORDPTY contains a valid schemeCode, Check if the Scheme code is one of the following : 'ARNU','CCPT','NIDN','SOSE','TXID','CUST','DRLC','EMPL'
* if the value is one of the above mentioned, map it to the SchemeCode variable (PrvtIdCd).

* If the Scheme code is among 'ARNU','CCPT','NIDN','SOSE','TXID' , Issuer will be next two chars after first '/'

* If the Scheme code is among 'CUST','DRLC','EMPL', Issuer will be the next two characters after the first "/", concatenated with the value between the 2nd and 3rd "/"

* The value after the last '/' should be mapped to OtherId variable.

* Example: 50F:CUST/GB/123455/98765
* So the tag <Issr> must be populated with the value "GB123455"
* Tag Othr/Id (OtherId) must be populated with the value "98765"
     
            IF eachRole EQ 'ORDPTY' AND coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '50F' AND coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[1,1] NE '/' THEN
            
                schemeCount = DCOUNT(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/')
                IF FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',1) MATCHES 'ARNU':@VM:'CCPT':@VM:'NIDN':@VM:'SOSE':@VM:'TXID':@VM:'CUST':@VM:'DRLC':@VM:'EMPL' THEN
                    
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfPrvtIdCd,rolePos> = FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',1)
                    
                    IF FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',1) MATCHES 'ARNU':@VM:'CCPT':@VM:'NIDN':@VM:'SOSE':@VM:'TXID' THEN
                        coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfPrvtIdIssr,rolePos> =  FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',2)[1,2]
                    END
                
                    IF FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',1) MATCHES 'CUST':@VM:'DRLC':@VM:'EMPL' THEN
                        coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfPrvtIdIssr,rolePos> = FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',2):FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',3)
                        
                    END
                
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfPrvtIdOthId,rolePos> = FIELD(coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>,'/',schemeCount)
                    addChck2 = 'Y'
                END
            END

;* When the freeline consists of Name, it begins with 1/. If the length of the name is more than 35 chars, then the next freeline also will have the name continued with 1/.
;* So when the freeline value begins with 1/, store in a variable and keep appending.

;* for example, the name 'J.P. Morgan & Co. and The Chase Manhattan Corporation' will be split and updated as
;* "1/J.P. Morgan & Co. and The Chase Man " in coverInfFreeLine1   and "1/hattan Corporation" in coverInfFreeLine2

            IF (eachRole EQ 'ORDPTY' AND coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '50F') OR (eachRole EQ 'BENFCY' AND coverInfo<PP.SwiftOutService.CoverDetails.coverInfTag,rolePos> EQ '59F') THEN
            
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[1,2] EQ '1/' THEN
                    dbCrName = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[3,35]
                END
            
                IF  coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine2,rolePos>[1,2] EQ '1/' THEN
                    dbCrName := coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine2,rolePos>[3,35]
                END
            
                IF  coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine3,rolePos>[1,2] EQ '1/' THEN
                    dbCrName := coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine3,rolePos>[3,35]
                END
            
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine4,rolePos>[1,2] EQ '1/' THEN
                    dbCrName := coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine4,rolePos>[3,35]
                END
            
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine5,rolePos>[1,2] EQ '1/' THEN
                    dbCrName := coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine5,rolePos>[3,35]
                END
            
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine6,rolePos>[1,2] EQ '1/' THEN
                    dbCrName := coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine6,rolePos>[3,35]
                END
        
;* the splitted Name is concatenated and will be printed in the generated outward file
                IF dbCrName NE '' THEN
                    coverInfo<PP.OutwardInterfaceService.PorCoverInfo.coverInfNm,rolePos> = dbCrName
                END
;* the free line whose value doesnt begin with 1/ has to be mapped to the addressline.

;* as only max of 3 addressline occurence is allowed, each freeline is checked for addressline while maintaining the max count of 3.
           
                addCnt = '1'
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>[1,2] NE '1/' AND addChck1 EQ '' AND addChck2 EQ '' AND addCnt LE '3' THEN
                    addLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine1,rolePos>
                    addCnt =  addCnt+1
                END
            
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine2,rolePos>[1,2] NE '1/' AND addCnt LE '3' THEN
                    IF addLine EQ '' THEN
                        addLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine2,rolePos>
                    END ELSE
                        addLine = addLine : '$$&&' : coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine2,rolePos>
                    END
                    addCnt =  addCnt+1
                END
            
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine3,rolePos>[1,2] NE '1/' AND addCnt LE '3' THEN
                    IF addLine EQ '' THEN
                        addLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine3,rolePos>
                    END ELSE
                        addLine = addLine : '$$&&' : coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine3,rolePos>
                    END
                    addCnt =  addCnt+1
                END
 
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine4,rolePos>[1,2] NE '1/' AND addCnt LE '3' THEN
                    IF addLine EQ '' THEN
                        addLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine4,rolePos>
                    END ELSE
                        addLine = addLine : '$$&&' : coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine4,rolePos>
                    END
                    addCnt =  addCnt+1
                END
                
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine5,rolePos>[1,2] NE '1/' AND addCnt LE '3' THEN
                    IF addLine EQ '' THEN
                        addLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine5,rolePos>
                    END ELSE
                        addLine = addLine : '$$&&' : coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine5,rolePos>
                    END
                    addCnt =  addCnt+1
                END
                
                IF coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine6,rolePos>[1,2] NE '1/' AND addCnt LE '3' THEN
                    IF addLine EQ '' THEN
                        addLine = coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine6,rolePos>
                    END ELSE
                        addLine = addLine : '$$&&' : coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine6,rolePos>
                    END
                    addCnt =  addCnt+1
                END
                IF addLine NE '' THEN
                    coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine4,rolePos> = FIELD(addLine,'$$&&',1)
                    coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine5,rolePos> = FIELD(addLine,'$$&&',2)
                    coverInfo<PP.SwiftOutService.CoverDetails.coverInfFreeLine6,rolePos> = FIELD(addLine,'$$&&',3)
                END
            END
        END
    REPEAT
     
    coverInfo =  LOWER(coverInfo)
    
    ioIFEmitDets<11> = coverInfo ;* assign the enriched cover info to the output variable
    
RETURN
*** </region>
*-------------------------------------------------------------------------------------------
*** <region name= checkValidIban>
checkValidIban:
*** <desc>Check if the given value is a valid IBAN </desc>

    iPotentialIBAN = ''
    iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = companyID ;* company Id
    iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = accountLine ;* value to be checked
    oIBANDetail = ''
    oDetIBANResponse = ''

    PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
        
RETURN
*** </region>
*-------------------------------------------------------------------------------------------
*** <region name= updateLclInstPrty>
updateLclInstPrty:
*** <desc> </desc>
* if Local Instr Prop is available, then skip the updation
    LOCATE 'LCLINSPY' IN iPaymentInformation SETTING pos THEN
    END ELSE
        GOSUB getPorInformation ; * get por.Information details
        cnt = 1
        insFound = ''
        instCdCount = 1
        infoLine = ''
        BEGIN CASE
            CASE ctrBtrIndicator EQ 'C' AND coverflag EQ 'Y'
                infoLine = 'COVPMT'
            CASE ctrBtrIndicator EQ 'C'
                infoLine = 'CSTPMT'
            CASE ValidationFlag EQ 'COV'
                infoLine = 'COVPMT'
            CASE 1
                infoLine = 'F2FPMT'
        END CASE
* calculate the no. of Information codes available.
* If no information code is available then assign the default values rightaway
* If Information Codes are available, then check for INSBNK.
        infCount =DCOUNT( R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorInformation.Informationcode> , @VM)
        IF infCount GT 0 THEN
            LOOP
            WHILE cnt LE infCount
                IF R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorInformation.Informationcode, cnt> EQ 'INSBNK' THEN
                    insFound = 'Y'
*If INSBNK is found, then check for the available Instruction codes and assign inthe appropriate position
                    instCdCount = DCOUNT(R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorInformation.Instructioncode, cnt> , @SM) + 1
                END
                IF insFound EQ 'Y' THEN
                    BREAK
                END
                cnt += 1
            REPEAT
        END
* if set POR.INFORMATION params
        GOSUB setPorInfo ; *
        
        Error =''
        PP.PaymentWorkflowGUI.updateSupplementaryInfo('POR.INFORMATION', ftNumber, R.POR.SUPPLEMENTARY.INFO, '', Error)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getPorInformation>
getPorInformation:
*** <desc> </desc>
    R.POR.SUPPLEMENTARY.INFO = ''
    Error = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.INFORMATION',ftNumber,'',R.POR.SUPPLEMENTARY.INFO,Error)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= setPorInfo>
setPorInfo:
*** <desc> </desc>
    LOCATE 'INSBNK' IN iPaymentInformation SETTING pos1 THEN
    END ELSE
        R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorInformation.Informationcode, cnt> = 'INSBNK'
    END
    R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorInformation.Instructioncode, cnt, instCdCount> = 'LCLINSPY'
    R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorInformation.Informationline, cnt, instCdCount> = infoLine
                    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getSupplementaryInfo>
getSupplementaryInfo:
*** <desc>Paragraph to get details from POR.SUPPLEMENTARY.INFO </desc>
    R.POR.SUPPLEMENTARY.INFO = ''
    Error = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS',ftNumber,'',R.POR.SUPPLEMENTARY.INFO,Error)
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= updateSvcTypeIdentifier>
updateSvcTypeIdentifier:
*** <desc> </desc>
    servicetypeidentifier = ''
    GOSUB getSupplementaryInfo ; *Paragraph to get details from POR.SUPPLEMENTARY.INFO
    IF clearingTransactionType EQ 'RT' THEN
        pmtFtNum = ftNumber
        ftNumber = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.OrgnlOrReturnId>
        GOSUB getSupplementaryInfo ; *Paragraph to get details from POR.SUPPLEMENTARY.INFO
        ftNumber = pmtFtNum
    END

*logic to update GPI / UET payment Ids
*Service Identifier is updated only for GPI payments
*So if Service Identifier is provided it is added in local field
    IF R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Servicetypeidentifier> NE '' THEN
        servicetypeidentifier = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Servicetypeidentifier>
        iPaymentFlowDets = ''
        iPaymentFlowDets<PP.OutwardInterfaceService.PorPaymentFlowDetails.locFieldName,-1> = 'Service Type Identifier'
        iPaymentFlowDets<PP.OutwardInterfaceService.PorPaymentFlowDetails.locFieldValue,-1> = servicetypeidentifier
    END
    
    ioIFEmitDets<12> = LOWER(iPaymentFlowDets)
RETURN
*** </region>
*-----------------------------------------------------------------------------
enrichCamt.029:
    IF porTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.outgoingMessageType> EQ 'camt.029' THEN
        IDVAL = ''
        ERR.CONCAT = ''
        R.TRANSACTION.CONCAT = ''
        IDVAL = iCanReq<PP.LocalClearingService.PpCanReq.origMsgRef>:'-':'EUROSIC'
*        CALL TPSLogging("Input Parameter","Transaction details IDVAL ","IDVAL:<":IDVAL:">","")
        PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
        R.TRANSACTION.CONCAT<-1> = iCanReq<PP.LocalClearingService.PpCanReq.canReqRelRef>
        PPESIC.Foundation.insertPorTransactionConcat('PP.InwardMappingFramework.insertPORTranConcatEuro', IDVAL, R.TRANSACTION.CONCAT)
*        CALL TPSLogging("Input Parameter","Transaction concat details ","R.TRANSACTION.CONCAT:<":R.TRANSACTION.CONCAT:">","")

    END
RETURN
*----------------------------------------------------------------------------


END
