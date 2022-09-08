* @ValidationCode : MjotMzkxNzQ2NzE4OkNwMTI1MjoxNjA0NjcwMTQ4Mzc0OmRpdnlhc2FyYXZhbmFuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToxMjoxMg==
* @ValidationInfo : Timestamp         : 06 Nov 2020 19:12:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/12 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.DISPLAY.ACCRUAL.DETAILS

*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Task of the sub-routine</desc>
*
** Program Description:
** This enquiry routine will display accrual details of given arrangement id.
*
*** </region>
*-----------------------------------------------------------------------------
*
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @link
* @author divyasaravanan@temenos.com
***
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
* 05/11/20 - Task : 4062192
*            Enhancement : 3164925
*            Conversion routine to display accrual details
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    tmp.O.DATA = EB.Reports.getOData()
    
    IF tmp.O.DATA THEN
        CONVERT '~' TO @VM IN tmp.O.DATA
        TmpVmCount = EB.Reports.getVmCount()
        DataVmCount = DCOUNT(tmp.O.DATA, @VM)
        IF TmpVmCount LT DataVmCount THEN
            EB.Reports.setVmCount(DCOUNT(tmp.O.DATA, @VM))
        END
        EB.Reports.setOData(tmp.O.DATA)
        EB.Reports.setOData(EB.Reports.getOData()<1,EB.Reports.getVc()>)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END
