* @ValidationCode : MjotOTg3ODEzODY3OkNwMTI1MjoxNTg1MTM0Mjc4NjUxOm1yLnN1cnlhaW5hbWRhcjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjIwMjAwMjEyLTA2NDY6Mjc6Mjc=
* @ValidationInfo : Timestamp         : 25 Mar 2020 16:34:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPUFPS.Foundation
SUBROUTINE PPUFPS.GET.BULK.REF.API(iCompanyDetails,iClearingDetails,oUFPSBulkRef)
** Generated Service Adaptor
* @author gmamatha@temenos.com
* @stereotype subroutine
* @package infra.eb
*
* In/out parameters:
* iCompanyBIC - String, IN
* iCompanyID - String, IN
* oRPSSCLBulkRef - RPCQBulkRef, OUT

*
* Program Description:
*  This program is used to generate file and bulk reference based on maxBulksPerFile and maxFilesPerCycle.
*-----------------------------------------------------------------------------
* Modification History :
*
*-----------------------------------------------------------------------------
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentFrameworkService
    $USING EB.API
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB setInputLog
    GOSUB process
    GOSUB setOutputLog

RETURN
*-----------------------------------------------------------------------------
process:

    clearingTxnType = FIELD(iClearingDetails,'*',1)
    msgType = FIELD(iClearingDetails,'*',2)
    ftnumber = FIELD(iClearingDetails,'*',3)
    dateVal = EB.SystemTables.getToday()

    dateValReq = dateVal[3,8]
    
    IF msgType EQ 'pacs.008' THEN
        firstPos ='9200'
    END
    
    IF msgType EQ 'pacs.002' THEN
        firstPos ='9210'
    END
    
    secondPos = '102010'
    
    fourthPos = dateValReq
    thirdPos = ftnumber:'00'
 
    fileReference = ''
    bulkReference = firstPos:secondPos:thirdPos:fourthPos

    oUFPSBulkRef<PP.OutwardMappingFramework.ClrgReference.bulkFileReference> = bulkReference

RETURN
*----------------------------------------------------------------------------------
setInputLog:
* Logging to see input
    CALL TPSLogging('Input Parameter', 'PPUFPS.GET.BULK.REF.API', 'iCompanyDetails  : <':iCompanyDetails:'>', '')
    CALL TPSLogging('Input Parameter', 'PPUFPS.GET.BULK.REF.API', 'iClearingDetails : <':iClearingDetails:'>', '')

RETURN
*-----------------------------------------------------------------------------
setOutputLog:
* Logging to see output
    CALL TPSLogging('Output Parameter', 'OutwardMappingFramework.getBulkFileRef', 'oUFPSBulkRef  : <':oUFPSBulkRef:'>', '')

RETURN
*-----------------------------------------------------------------------------
END
