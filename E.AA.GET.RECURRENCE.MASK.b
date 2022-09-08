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
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.RECURRENCE.MASK

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* It requires RECURRENCE value in O.DATA and returns relevant mask in the same variable

*-----------------------------------------------------------------------------
* @uses I_ENQUIRY.COMMON
* @package retaillending.AA
* @stereotype subroutine
* @link EB.BUILD.RECURRENCE.MASK
* @author smakrinos@temenos.com
*-----------------------------------------------------------------------------
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* None
*
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

    $USING EB.Utility
    $USING EB.Reports

*** </region>

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    RECURRENCE = EB.Reports.getOData() ;* Pick the recurrence from enquiry variable
    IN.DATE = ''
    OUT.MASK = ''

    EB.Utility.BuildRecurrenceMask(RECURRENCE, IN.DATE, OUT.MASK)

    EB.Reports.setOData(OUT.MASK)

    RETURN
*** </region>
    END
