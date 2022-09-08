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
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.NOF.GET.WRITE.OFF.DETAILS.FORMATTED

*** <region name= Synopsis of the Routine>
***
** Conversion routine to change "*" back to FM in O.DATA for the enquiry
** build routine E.NOF.GET.WRITE.OFF.DETAILS
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Modification History>
***
**
* 12/11/14 - Task 1165744
*            Ref : Defect 1098257
*            Get write-off details for the arrangement from ActivityBalances
*            and Bill details - for both write-off balances, and write-off bill
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

    TEMP.RECORD = EB.Reports.getOData()      ;* Get the current record details
    CONVERT "*" TO @FM IN TEMP.RECORD    ;* Format separated by FM
    EB.Reports.setRRecord(TEMP.RECORD);* Post the routine to enquiry common

    EB.Reports.setVmCount(DCOUNT(TEMP.RECORD<4>, @VM));* Return VM count so that MV will work for the enquiry!!

    RETURN
*** </region>
*-----------------------------------------------------------------------------

END
