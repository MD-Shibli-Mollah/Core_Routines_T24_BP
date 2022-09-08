* @ValidationCode : MjoxMDkyMjE5Njc6Q3AxMjUyOjE2MDgxMjA4MDMzMDY6bmRpdnlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3Oi0xOi0x
* @ValidationInfo : Timestamp         : 16 Dec 2020 17:43:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ndivya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ProductFramework
SUBROUTINE E.AA.CONV.DISPLAY.MULTI.VALUE
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Task of sub-routine</desc>
*
** Program Description:
**
* This routine displays multi value details from List of features enquiry
*** </region>
*-----------------------------------------------------------------------------
*
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @link
* @author ndivya@temenos.com
***
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
** 11/12/20 - Task : 4126368
*            Enhancement : 3342925
*            Conversion routine to return the mandatory and Productline details for the incoming feature
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING EB.Reports
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    tmp.O.DATA = EB.Reports.getOData()
    
    IF tmp.O.DATA THEN
        EB.SystemTables.ConvertSpaceWithinString('CONVERT', tmp.O.DATA)
        CONVERT " " TO @VM IN tmp.O.DATA
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

