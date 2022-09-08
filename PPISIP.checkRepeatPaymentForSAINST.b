* @ValidationCode : MjotMTU0MjkzMjEzOTpDcDEyNTI6MTYwNjIyMDEwNjYyMDpkaW5lc2guYnI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjgwOjc2
* @ValidationInfo : Timestamp         : 24 Nov 2020 17:45:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dinesh.br
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 76/80 (95.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPISIP.Foundation
SUBROUTINE PPISIP.checkRepeatPaymentForSAINST(ioPaymentObject,ftNumber,statusCode,errorCode)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 27/09/2020 - Enhancement 3675355 / Task 3929661 - SAINST
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentWorkflowDASService
    $USING PP.DebitPartyDeterminationService
    $USING PP.PaymentWorkflowGUI
    $USING PP.PaymentGenerationService
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentFrameworkService
    $USING EB.DataAccess

*** <region name= Routine flow>
*** <desc>Routine to check incoming duplicates and generate pacs.002 as DUPL </desc>
    CALL TPSLogging("DB Input","checkRepeatPaymentForSAINST.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <ioPaymentObject:":ioPaymentObject:">","")
    GOSUB init
    GOSUB readConcatAndPaymentRecs ;*Get the FT number for this Repeat message
    IF errConcat EQ '' THEN
        CALL TPSLogging("DB Input","checkRepeatPaymentForSAINST.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <ioPaymentObject:INSIDE send inst >","")
        GOSUB sendInstMsg ;*Send Confirmation message if it same payment
    END ELSE
        CALL TPSLogging("DB Input","checkRepeatPaymentForSAINST.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <ioPaymentObject:INSIDE exit flow >","")
        ftNumber = 'Exit' ;*Send signal to executemessagelevel to not throw any original payment error
    END
    CALL TPSLogging("DB Input","checkRepeatPaymentForSAINST.SAINSTCHECK","ioFileData Task 2980186 02 SEP 2020 : <ftNumber:":ftNumber:">","")
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Initialise>
init:
*** <desc>Initialise the variables </desc>

    originalPaymentRecord = ''
    ftNumber = ''
RETURN

*** </region>
*------------------------------------------------------------------------------
*** <region name= read concat and fetch ft number>
readConcatAndPaymentRecs:
*** <desc>Read concat table using paymentIdentificationNumber and get the existing FT number </desc>

    FN.POR.TRANSACTION.CONCAT = 'F.POR.TRANSACTION.CONCAT'
    F.POR.TRANSACTION.CONCAT = ''
    R.TRANSACTION.CONCAT = ''
    errConcat = ''
    orgAdditionalPaymentRecord = ''
    originalPaymentRecord = ''
    orgReadErr = ''
    txnId = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.sendersReferenceIncoming>
    
    concatId = txnId:'-':ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
   
    EB.DataAccess.FRead(FN.POR.TRANSACTION.CONCAT,concatId,R.TRANSACTION.CONCAT,F.POR.TRANSACTION.CONCAT,errConcat)
    ftNumber = R.TRANSACTION.CONCAT<1>
   
    GOSUB readSupplementaryInfo ; *Read supplementary info and extract local field name and value to check for duplicate indicator.
    locFldName = PorInfoRecord<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname>
   
    LOCATE 'DUPL' IN locFldName<1,1> SETTING dupPos THEN
        IF PorInfoRecord<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue,dupPos> NE 'Y' THEN
            errConcat = 'Return'
        END
    END
    
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= send instant message>
sendInstMsg:
*** <desc>Send positive or negative pacs.002 without creating duplicate payment record </desc>

    iMapCreditTransfer = ''
    oMapCreditError = ''
    ioAdditionalPaymentRecord = ''
    iPaymentId = ''
    iPaymentId<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = ftNumber
    iPaymentId<PP.PaymentWorkflowDASService.PaymentID.companyID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentId, originalPaymentRecord, orgAdditionalPaymentRecord, orgReadErr)
    GOSUB setProcessingDate
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.companyID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.ftNumber> = ftNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.currentBusinessDate> = processingDate
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileReference> = 'SFD-':ftNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.bulkReference> = 'SBD-':ftNumber
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.fileFormat>= 'ICF' ;* For CT
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingID> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.date> = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.creditValueDate>
*iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.LocalRefName> = 'DUPL'
    ReadWithLock = ''
    PorInfoRecord = ''
    Error = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo("POR.PAYMENTFLOWDETAILS", ftNumber, ReadWithLock, PorInfoRecord, Error)
    CALL TPSLogging("test Parameter","PPISIP.checkRepeatPaymentforSAINST","PorInfoRecord:":PorInfoRecord,"")
    PorInfoRecord<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname, -1> = 'DUPL'
    PorInfoRecord<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue, -1> = 'DUPL'
    PP.PaymentWorkflowGUI.updateSupplementaryInfo('POR.PAYMENTFLOWDETAILS', ftNumber, PorInfoRecord, '', Error)
    IF originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.statusCode> MATCHES '656':@VM:'658' THEN
        iMapCreditTransfer<PP.OutwardMappingFramework.MapCreditTransfer.clearingTransactionType> = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.clearingTransactionType>
    END
    GOSUB updatePORHistoryLog ;*Update Audit trail that repeat Pacs.002 confimation is being sent
    PP.PaymentGenerationService.sendInstEventToClearing(iMapCreditTransfer,originalPaymentRecord,ioAdditionalPaymentRecord,oMapCreditError)
      
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= set processing date>
setProcessingDate:
*** <desc>map business date to processing date </desc>
  
    iCompanyKey = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    PP.PaymentFrameworkService.getCurrBusinessDate(iCompanyKey, oBusinessDate, oGetCurDateError)
    processingDate = oBusinessDate<PP.PaymentFrameworkService.BusinessDate.currBusinessDate>
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= update log>
updatePORHistoryLog:
*** <desc>update history log with status response messages and ft number </desc>
   
    iPORHistoryLog = ''
    oPORHistoryLogErr = ''
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.companyID> = originalPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.companyID>
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.ftNumber> = ftNumber
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.additionalInfo> = ftNumber
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventType> = 'INF'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.eventDescription> = 'Status response sent to Clearing for the repeat payment message received'
    iPORHistoryLog<PP.PaymentFrameworkService.PORHistoryLog.errorCode> = ''
    PP.PaymentFrameworkService.insertPORHistoryLog(iPORHistoryLog, oPORHistoryLogErr)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= readSupplementaryInfo>
readSupplementaryInfo:
*** <desc>Read supplementary info and extract local field name and value to check for duplicate indicator. </desc>

    PP.PaymentWorkflowGUI.getSupplementaryInfo("POR.PAYMENTFLOWDETAILS", ftNumber, ReadWithLock, PorInfoRecord, Error)
RETURN
*** </region>
*-----------------------------------------------------------------------------
END

