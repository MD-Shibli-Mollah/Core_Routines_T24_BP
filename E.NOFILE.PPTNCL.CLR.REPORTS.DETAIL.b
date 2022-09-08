* @ValidationCode : MjotNDM3MjQxNjcxOkNwMTI1MjoxNTk5NzU5Mzg1OTM1OnNrYXlhbHZpemhpOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo2MTo2MQ==
* @ValidationInfo : Timestamp         : 10 Sep 2020 23:06:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 61/61 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE E.NOFILE.PPTNCL.CLR.REPORTS.DETAIL(OUT.ARRAY)
*-----------------------------------------------------------------------------
** This API is attached in Enquiry to display the Detail Record from PP.CLR.REPORTS.FILE
*-----------------------------------------------------------------------------
* Modification History :
*24/06/2020 - Enhancement 3538850/Task 3816876-Payments-BHTunsian-Issued Direct Debit / Received Direct Debit
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
    OUT.ARRAY<-1> = 'File Generation Date Time**':recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfDatetime>
    LOCATE 'Lot number' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Lot Number**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    OUT.ARRAY<-1> = 'Registration Code**':recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFiletype>
    OUT.ARRAY<-1> = 'Clearing Date**':recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfInterbanksettlementdate>
    
    LOCATE 'Value code' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Value Code of Lot**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Currency Code' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Currency Code**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Sending Bank Code' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Sending Bank Code**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Lot date generation' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Lot Date Generation**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    
    LOCATE 'Lot time generation' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Lot Time Generation**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
   
    LOCATE 'Reception Date and time' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Reception Date Time**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Date and time of Start of process' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Start of process DateTime**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Date and time of End of process' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'End of process DateTime**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    
    LOCATE 'Direction of treated lot' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Direction of lot**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    
    LOCATE 'Control Status' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Control Status**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Number of accepted transactions' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Number of accepted transactions**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'TotalAmount of AcceptedTransactions' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Total Amount of Accepted Transactions**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'Number of Rejected transactions' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Number of Rejected transactions**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    LOCATE 'TotalAmount of RejectedTransactions' IN recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldname,1> SETTING pos THEN
        OUT.ARRAY<-1> = 'Total Amount of Rejected Transactions**' : recDetails<PP.LocalClearingService.PpClrReportsFile.PpcrfFieldcontent,pos>
    END
    
RETURN
*-----------------------------------------------------------------------------
END
