* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CL.ModelReport
    SUBROUTINE E.CL.CONV.GET.COLL.CODE
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* Conversion Routine.
* Get the Record of Type of Application Collateral's
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.COLLECTOR.INPUT
* @uses
* @package retaillending.CL
*
*** </doc>
*** </region>
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection Process
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess

*** </region>

*** <region name= PROCESS>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB PROCESS
    RETURN

*** </region>
*** <region name= PROCESS>
*** <desc>Main Process is return Collateral Record</desc>

PROCESS:
********

    OVERDUE.ID = '' ;* Due Reference -PDLD... & PDPD...
    APPLN = ''      ;* PD
    FILE.TO.READ = ''         ;* Ex : LD.COLLATERAL & AZ.COLLATERAL
    FN.FILE = ''


    OVERDUE.ID = EB.Reports.getOData()
    APPLN  = OVERDUE.ID[1,2]
    IF APPLN EQ 'PD' THEN

        FILE.TO.READ = OVERDUE.ID[3,2]:".COLLATERAL"
        FN.FILE = "F.":FILE.TO.READ
        EB.SystemTables.setFFile("")
        FN.FILE = FN.FILE:@FM:"NO.FATAL.ERROR"
        tmp.F.FILE = EB.SystemTables.getFFile()
        EB.DataAccess.Opf(FN.FILE,tmp.F.FILE)
        EB.SystemTables.setFFile(tmp.F.FILE)
        R.FILE = ""
        FILE.ERR = ""
        tmp.F.FILE = EB.SystemTables.getFFile()
        EB.DataAccess.FRead(FN.FILE,OVERDUE.ID,R.FILE,tmp.F.FILE,FILE.ERR)
        EB.SystemTables.setFFile(tmp.F.FILE)
        EB.Reports.setOData(R.FILE)
    END
    RETURN

*** </region>
    END
