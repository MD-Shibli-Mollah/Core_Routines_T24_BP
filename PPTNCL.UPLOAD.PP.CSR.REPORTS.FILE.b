* @ValidationCode : Mjo4Nzg5MzI2OTY6Q3AxMjUyOjE2MDMyODk4OTgzNDg6c2FybWVuYXM6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjEzMDoxMjU=
* @ValidationInfo : Timestamp         : 21 Oct 2020 19:48:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 125/130 (96.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.UPLOAD.PP.CSR.REPORTS.FILE(ioAction, ioItemNo, ioEbUploadFileId, ioRecord)
*-----------------------------------------------------------------------------
*This API is attached in EB.FILE.UPLOAD.TYPE> ReformatPlugin to upload the non-xml file to PP.CLR.REPORTS.FILE
*-----------------------------------------------------------------------------
* Modification History :
*24/06/2020 - Enhancement 3538850/Task 3816876-Payments-BHTunsian-Issued Direct Debit / Received Direct Debit
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------
    $USING EB.FileUpload
    $USING PP.LocalClearingService
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process
    
RETURN
*-------------------------------------------------------------------------------
initialise:
    cnt = 1
    tempRecord = ioRecord
    ioRecord = ''
RETURN
*-------------------------------------------------------------------------------
process:
    ebFileUploadRec = EB.FileUpload.FileUpload.Read(ioEbUploadFileId, ebFileUploadErr)
    clrType = ebFileUploadRec<EB.FileUpload.FileUpload.UfUploadType>
    filename = ebFileUploadRec<EB.FileUpload.FileUpload.UfSystemFileName>
    headerId = ebFileUploadRec<EB.FileUpload.FileUpload.UfHeaderId>
    
    BEGIN CASE
        CASE SUBSTRINGS(filename,1,5) EQ '14-10'
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfClearing> = "TUNCLGCT"
        CASE SUBSTRINGS(filename,1,5) EQ '14-20'
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfClearing> = "TUNCLGDD"
        CASE (SUBSTRINGS(filename,1,5) EQ '14-30') OR (SUBSTRINGS(filename,1,5) EQ '14-31') OR (SUBSTRINGS(filename,1,5) EQ '14-32') OR (SUBSTRINGS(filename,1,5) EQ '14-33') OR (SUBSTRINGS(filename,1,5) EQ '14-81') OR (SUBSTRINGS(filename,1,5) EQ '14-82') OR (SUBSTRINGS(filename,1,5) EQ '14-83') OR (SUBSTRINGS(filename,1,5) EQ '14-84')
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfClearing> = "TUNCLGCHQ"
        
    END CASE
    
    IF ioAction EQ 'HEADER' THEN
        
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFiletype> = "CRS-":tempRecord[16,2]
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfDatetime> = tempRecord[2,14]
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfInterbanksettlementdate> = tempRecord[18,8]
        
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'RecordType'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'HEADER'
        
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Currency Code'
        IF tempRecord[26,3] EQ '788' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'TND'
        END
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Receiver Bank Code'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[29,2]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Total No. of Records'
        IF TRIM(tempRecord[31,10], '0', 'L') EQ '' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = '0'
        END ELSE
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = TRIM(tempRecord[31,10], '0', 'L')
        END
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Total Amount of Records'
        IF TRIM(tempRecord[41,12], '0', 'L') EQ '' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = '0'
        END ELSE
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  TRIM(tempRecord[41,12], '0', 'L') : '.' :tempRecord[53,3]
        END
    
    END ELSE
    
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFiletype> = "CRS-":tempRecord[20,2]
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfDatetime> = tempRecord[2,14]
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfInterbanksettlementdate> = tempRecord[22,8]
        
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'RecordType'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'DETAILS'
        
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Header Id'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  headerId
        
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Lot number'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[16,4]
        
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Value code'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[30,2]
        
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Currency Code'
        IF tempRecord[32,3] EQ '788' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'TND'
        END
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Sending Bank Code'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[35,2]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Lot date generation'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[37,8]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Lot time generation'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[45,6]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Reception Date and time'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[51,14]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Date and time of Start of process'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[65,14]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Date and time of End of process'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[79,14]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Direction of treated lot'
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  tempRecord[93,1]
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Control Status'
        IF tempRecord[94,1] EQ '1' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'Accepted'
        END ELSE IF tempRecord[94,1] EQ '2' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'Rejected'
        END ELSE IF tempRecord[94,1] EQ '3' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  'Partially accepted'
        END

        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Number of accepted transactions'
        IF TRIM(tempRecord[95,10], '0', 'L') EQ '' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = '0'
        END ELSE
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  TRIM(tempRecord[95,10], '0', 'L')
        END
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'TotalAmount of AcceptedTransactions'
        IF TRIM(tempRecord[105,12], '0', 'L') EQ '' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = '0'
        END ELSE
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  TRIM(tempRecord[105,12], '0', 'L') : '.' :tempRecord[117,3]
        END
    
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'Number of Rejected transactions'
        IF TRIM(tempRecord[120,10], '0', 'L') EQ '' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = '0'
        END ELSE
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  TRIM(tempRecord[120,10], '0', 'L')
        END
        cnt = cnt + 1
        ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,cnt> =  'TotalAmount of RejectedTransactions'
        IF TRIM(tempRecord[130,12], '0', 'L') EQ '' THEN
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> = '0'
        END ELSE
            ioRecord<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,cnt> =  TRIM(tempRecord[130,12], '0', 'L') : '.' :tempRecord[142,3]
        END
    END
    
    CONVERT @FM TO '$' IN ioRecord
    CONVERT @VM TO '@' IN ioRecord
    CONVERT @SM TO '%' IN ioRecord
RETURN
*-------------------------------------------------------------------------------
END
