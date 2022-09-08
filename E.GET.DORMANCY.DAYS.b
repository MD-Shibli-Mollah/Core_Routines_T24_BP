* @ValidationCode : Mjo1NTExNjgxMDQ6Q3AxMjUyOjE1NDM4MzIyMzExNTU6amFiaW5lc2g6MjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjoxMDoxMA==
* @ValidationInfo : Timestamp         : 03 Dec 2018 15:47:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 10/10 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.DormancyMonitor
SUBROUTINE E.GET.DORMANCY.DAYS
*-----------------------------------------------------------------------------
*** <region name= Desc>
*** <desc>It describes the routine </desc>
* E.GET.DORMANCY.DAYS is a consversion routine which gets the DATE.OF.RESET in O.DATA and
* returns the No of Days Since Dormancy
*
*-----------------------------------------------------------------------------
* @uses EB.Reports
* @uses EB.SystemTables
* @uses EB.API
* @package ST.ModelBank
* @class E.GET.DORMANCY.DAYS
* @stereotype subroutine
* @author jabinesh@temenos.com
*** </region>
* Modifications
*
* 03/12/2018 - Enhancement 2857429   / Task 2883248
*              Consversion routine which gets the DATE.OF.RESET or DATE.OF.DORMANCY in O.DATA and
*              returns the days difference based on the current date
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.API
*** </region>
*-----------------------------------------------------------------------------
    GOSUB Process ;* process
RETURN
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc> </desc>
Process:
    
    updatedDate = EB.Reports.getOData()
    IF updatedDate THEN
        CurrentDate = EB.SystemTables.getToday()
        Days = 'C'
        EB.API.Cdd('', updatedDate, CurrentDate, Days)
        EB.Reports.setOData(Days)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
