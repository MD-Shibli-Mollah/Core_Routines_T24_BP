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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE BX.ModelBank
    SUBROUTINE E.CONV.AA.SDB.BOX.LIST

*** <region name= Program Description>
***
* Program Description
*
* This enquiry routine convert the enquiry data. it will convert * to FM and SM to FM.
*
* of given property.
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
*
*  22/02/2016 - Enhancement : 1033356
*               Task : 1638897
*               New Routine for SDB Enquiry.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc> </desc>

    $USING EB.Reports
    
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main processing Logic>

    CurrentRecord = EB.Reports.getOData()          ;*Locate the position
    CONVERT '*' TO @FM IN CurrentRecord            
    CONVERT @SM TO @VM IN CurrentRecord     ;* Conver all sub value markers to value markers.

    GOSUB GET.HIGHEST.VM.COUNT    ;* Get the max VMs count from the field values
    
    EB.Reports.setVmCount(MaxVmCount)
    EB.Reports.setRRecord(CurrentRecord);*Details were lowered.

    RETURN
*-----------------------------------------------------------------------------

*** <region name= Get Highest VM Count>
*** <desc> </desc>

GET.HIGHEST.VM.COUNT:

    MaxVmCount = 0

    NoValues = DCOUNT(CurrentRecord, @FM)
    FOR ValCnt = 1 TO NoValues
        NoVms = COUNT(CurrentRecord<ValCnt>, @VM)  + 1
        IF NoVms GT MaxVmCount THEN
            MaxVmCount = NoVms
        END
    NEXT ValCnt

    RETURN
*** </region>    
*-----------------------------------------------------------------------------

    END
