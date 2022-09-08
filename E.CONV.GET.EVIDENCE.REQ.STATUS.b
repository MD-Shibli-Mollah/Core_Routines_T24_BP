* @ValidationCode : MjotMTc3NjcyNTkwNDpDcDEyNTI6MTU4OTM2MTEyMTUwODpvaHZpeWFqOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Oi0xOi0x
* @ValidationInfo : Timestamp         : 13 May 2020 14:42:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ohviyaj
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------

$PACKAGE AA.ModelBank
SUBROUTINE E.CONV.GET.EVIDENCE.REQ.STATUS
*-----------------------------------------------------------------------------
*
* New enquiry routine to get the latest Requirements status.
*
* Modification History
*
* 5/5/2020 - Task   : 3728089
*            Defect : 3679672
*            New enquiry routine to get the latest Requirements status.
*-----------------------------------------------------------------------------
*

    $USING EB.Reports
    $USING EB.SystemTables
    $USING EV.Framework

    GOSUB Initialize
    GOSUB Process

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialize>
*** <desc>Initialize</desc>
*----------*
Initialize:
*----------*
   
    ArrangementId = EB.Reports.getOData()   ;* get the arrangement id
    EvidenceRequirementStatus = ''
    EvidenceRequirementList = ''
    RetError = ''
    EffectiveDate = EB.SystemTables.getToday()
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Process</desc>
*-------*
Process:
*-------*

    EV.Framework.GetEvidenceRequirementStatusDetails(ArrangementId, '', '', EvidenceRequirementStatus, '', '', '', RetError)
    EB.Reports.setOData(EvidenceRequirementStatus<1,EB.Reports.getVc()>)
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
