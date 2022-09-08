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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.AA.GET.BILL.DETAILS.FORMATTED

*** <region name= Synopsis of the Routine>
***
** Conversion routine to change "*" back to FM in O.DATA for the enquiry
** build routine E.MB.AA.GET.BILL.DETAILS
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Modification History>
***
**
* 13/11/14 Task 1131074
*          Ref : Defect 1105150
*          New enquiry routine to return Bill Details record
**
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
***
    
    $USING EB.Reports
    
*** </region>
*-----------------------------------------------------------------------------

*
*** <region name= Main Process>
***
    TEMP.RECORD = EB.Reports.getOData() ;* Get the current record details
    CONVERT "*" TO @FM IN TEMP.RECORD ;* Format separated by FM
    EB.Reports.setRRecord(TEMP.RECORD);* Post the routine to enquiry common
    
tmp.R.RECORD = EB.Reports.getRRecord()
    EB.Reports.setVmCount(DCOUNT(tmp.R.RECORD, @VM))
EB.Reports.setRRecord(tmp.R.RECORD)
tmp.R.RECORD = EB.Reports.getRRecord()
    EB.Reports.setSmCount(DCOUNT(tmp.R.RECORD, @SM))
EB.Reports.setRRecord(tmp.R.RECORD)

    RETURN
*** </region>
*-----------------------------------------------------------------------------

END
