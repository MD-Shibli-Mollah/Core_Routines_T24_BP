* @ValidationCode : MjoxNDEwMDY5NTE3OkNwMTI1MjoxNjEwNDQ4NDI5MTM5OnB1bml0aGt1bWFyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDEuMToxMzoxMw==
* @ValidationInfo : Timestamp         : 12 Jan 2021 16:17:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : punithkumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE RE.ModelBank
SUBROUTINE E.GET.REP.HEADER.DATE
*-----------------------------------------------------------------------------
* Conversion routine attached in ENQUIRY CRB.REPORT under field LAST WORKING DAY to have proper header date returned
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 12/01/21 - Defect 4161121 // Task 4173378
*            New conversion routine introduce to return the proper header date to print in CRB report.
*            Case handled for both online(Last working date is returned) and COB (TODAY date is returned)report generation
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Service
    
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
******************************************************************
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the required variables </desc>

    HEADER.DATE = ''
RETURN

******************************************************************
*** <region name= PROCESS>
PROCESS:
*** <desc>Return the exact header date depending on the report generated in online or as part of COB </desc>

    IF EB.SystemTables.getRunningUnderBatch() AND ( EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfOpMode> = 'B' ) AND ( EB.Service.getCBatchStartDate() EQ EB.SystemTables.getToday() ) THEN
        HEADER.DATE = EB.SystemTables.getToday() ;*Return today's date when report generated as part of cob in R satge
    END ELSE
        HEADER.DATE =  EB.Reports.getOData()    ;*when generated in online return the LAST WORKING DAY.
    END
    HEADER.DATE = OCONV(ICONV(HEADER.DATE,"D4"),"D4E") ;* convert to DD MMM YYYY format
    EB.Reports.setOData(HEADER.DATE)
    
RETURN
******************************************************************
END
