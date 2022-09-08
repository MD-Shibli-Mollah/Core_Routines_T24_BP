* @ValidationCode : MjotMTg5NzgxODk1OTpDcDEyNTI6MTYwMjg1Mzc3NjQ1OTpzYXJtZW5hczoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6Mzg6Mzc=
* @ValidationInfo : Timestamp         : 16 Oct 2020 18:39:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 37/38 (97.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE E.NOFILE.PPTNCL.CLR.REPORTS.HEADER(OUT.ARRAY)
*-----------------------------------------------------------------------------
* This API is attached in Enquiry to display the Header Record from PP.CLR.REPORTS.FILE
*-----------------------------------------------------------------------------
* Modification History :
*24/06/2020 - Enhancement 3538850/Task 3816876-Payments-BHTunsian-Issued Direct Debit / Received Direct Debit
* 16/10/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $USING PP.LocalClearingService
    
    $INSERT I_DAS.PP.CLR.REPORTS.FILE
    $INSERT I_DAS.PP.CLR.REPORTS.FILE.NOTES
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
RETURN
*-----------------------------------------------------------------------------
initialise:
    SELECTION.FIELDS = EB.Reports.getEnqSelection()<2>
    DATA.LIST = EB.Reports.getEnqSelection()<4>
RETURN
*-----------------------------------------------------------------------------
process:
    LOCATE '@ID' IN SELECTION.FIELDS<1,1> SETTING idPos THEN
        recId = DATA.LIST<1,idPos>
    END
    recDetails = PP.LocalClearingService.PpClrReportsFile.Read(recId, error)
    LOCATE "HEADER" IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,1> SETTING POS THEN
        headerRecord = recDetails
    END ELSE
        LOCATE "Header Id" IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING POS THEN
            headerId = recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,POS>
        END
    END
    headerRecord = PP.LocalClearingService.PpClrReportsFile.Read(headerId, error)
    OUT.ARRAY<-1> = 'Clearing**':headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfClearing>
    OUT.ARRAY<-1> = 'FileType**':headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFiletype>
    OUT.ARRAY<-1> = 'File Generation Date Time**':headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfDatetime>
    OUT.ARRAY<-1> = 'Interbank Settlement Date**':headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfInterbanksettlementdate>
    OUT.ARRAY<-1> = 'Registration code**':headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFiletype>
    LOCATE 'Currency Code' IN headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Currency Code**' : headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Receiver Bank Code' IN headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Receiver Bank Code**' : headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Total No. of Records' IN headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Total No. of Records**' : headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Total Amount of Records' IN headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Total Amount of Records**' : headerRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    
RETURN
*-----------------------------------------------------------------------------
END
