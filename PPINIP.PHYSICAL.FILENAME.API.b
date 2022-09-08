* @ValidationCode : Mjo1NjY2MTI4Njc6Q3AxMjUyOjE2MDgwMTkyMjc4NTg6dW1hbWFoZXN3YXJpLm1iOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDo2Njo1OQ==
* @ValidationInfo : Timestamp         : 15 Dec 2020 13:30:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 59/66 (89.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPINIP.Foundation
SUBROUTINE PPINIP.PHYSICAL.FILENAME.API(iPaymentRecord,iAdditionalPaymentRecord,iGenericInfo,oFileName)
*-----------------------------------------------------------------------------
* Program Description:
*  This program is used to generate physical File Name
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*   16/10/2020 - Enhancement - 3852895   /Task - 3852900  - Initial Draft
*-----------------------------------------------------------------------------

    $USING PP.OutwardMappingFramework
    $USING EB.SystemTables
    $USING PP.PaymentFrameworkService
    $USING ST.CompanyCreation
    $USING PP.StaticDataGUI
    $USING PP.PaymentWorkflowDASService
    
    GOSUB setInputLog
    GOSUB initialise
    GOSUB process
    GOSUB finalise
    GOSUB setOutputLog

RETURN
*------------------------------------------------------------------------------

setInputLog:
************
* Logging to see input
    CALL TPSLogging("Start", "PPINIP.PHYSICAL.FILENAME.API", "", "")
    CALL TPSLogging('Version        ', 'PPINIP.PHYSICAL.FILENAME.API', 'Date - 16 Oct 20', '')
    CALL TPSLogging("Input Parameter", "PPINIP.PHYSICAL.FILENAME.API", "iPaymentRecord : <":iPaymentRecord:">", "")
    CALL TPSLogging("Input Parameter", "PPINIP.PHYSICAL.FILENAME.API", "iAdditionalPaymentRecord : <":iAdditionalPaymentRecord:">","")
    CALL TPSLogging("Input Parameter", "PPINIP.PHYSICAL.FILENAME.API", "iGenericInfo : <":iGenericInfo:">", "")
    
RETURN
*-------------------------------------------------------------------------------------------------------------------------------------

initialise:
***********
    CHANGE @VM TO @FM IN iPaymentRecord
    CHANGE @VM TO @FM IN iGenericInfo
    CHANGE @VM TO @FM IN iAdditionalPaymentRecord
   
    serviceIdentifier = ''
    oFileName = ''
    
    IF iGenericInfo<PP.OutwardMappingFramework.GenericInfo.clearingTransactionType> NE '' THEN
        txnType = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.clearingTransactionType>
    END ELSE
        txnType = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    END
*iTPSFileReference = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.ftNumber>
    iClearingId = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.clearingId>
    iFormatVersion = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.formatVersion>
    FileReference = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.fileReference>
    IF FIELD(FileReference,'-',2) THEN
        iTPSFileReference = FIELD(FileReference,'-',2)
    END ELSE
        iTPSFileReference = FileReference
    END
    IF iGenericInfo<PP.OutwardMappingFramework.GenericInfo.outMsgType> NE '' THEN
        outMsgTyp = iGenericInfo<PP.OutwardMappingFramework.GenericInfo.outMsgType>
    END ELSE
        outMsgTyp = iPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.outgoingMessageType>
    END
 
RETURN
*------------------------------------------------------------------------------------------
process:
**************
    IF iClearingId EQ 'P27NIP' THEN

        serviceIdentifier = 'NIP'
            
        GOSUB getCompanyBic

        IF (outMsgTyp EQ 'pacs.008') OR (outMsgTyp EQ 'camt.056') OR (outMsgTyp EQ 'camt.029' AND txnType EQ 'RI') OR  (outMsgTyp EQ 'pacs.004') OR (outMsgTyp EQ 'pacs.028' AND txnType EQ 'SR') THEN
            typeOfFile = 'I'
        END

        IF (outMsgTyp EQ 'camt.087') OR (outMsgTyp EQ'camt.027') OR (outMsgTyp EQ 'camt.029' AND (txnType EQ 'RI-CA' OR txnType EQ 'RI-CM')) OR (outMsgTyp EQ 'pacs.028' AND (txnType EQ 'SR-CA' OR txnType EQ 'SR-CM')) THEN
            typeOfFile = 'Q'
        END
        IF outMsgTyp EQ 'pacs.002' THEN
            typeOfFile = 'V'
        END
       
        IF typeOfFile NE '' THEN
            oFileName = 'NI02': serviceIdentifier: companyBic[1,8]: iTPSFileReference[1,15]: '.':typeOfFile
        END ELSE
            oFileName = 'NI02': serviceIdentifier: companyBic[1,8]: iTPSFileReference[1,15]
        END
    END
    
RETURN
*-------------------------------------------------------------------------------------------------------------------

getCompanyBic:
**************
   
    companyMnemonic = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
    PP.PaymentFrameworkService.getCompanyProperties(companyMnemonic, oCompanyProperties, oGetCompPropsError)
    companyBic = oCompanyProperties<PP.PaymentFrameworkService.CompanyProperties.companyBIC>
    
RETURN
*-------------------------------------------------------------------------------------------------------------------

finalise:
**********
    CHANGE @FM TO @VM IN iPaymentRecord
    CHANGE @FM TO @VM IN iGenericInfo
    CHANGE @FM TO @VM IN iAdditionalPaymentRecord
    
RETURN
*-------------------------------------------------------------------------------------------------------------------

setOutputLog:
**************
* Logging to see output
    CALL TPSLogging("Output Parameter", "PPINIP.PHYSICAL.FILENAME.API", "oFileName : <":oFileName:">", "")
    CALL TPSLogging("End", "PPINIP.PHYSICAL.FILENAME.API", "", "")

RETURN
*--------------------------------------------------------------------------------------------------------------------

END

