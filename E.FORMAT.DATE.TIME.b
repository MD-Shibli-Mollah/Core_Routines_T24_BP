* @ValidationCode : MjoyMzA1NjQ2MTU6Q3AxMjUyOjE1NjYzODEzNTkyNjc6YW1vbmlzaGE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzIzLTAyNTE6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Aug 2019 15:25:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amonisha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.SystemTables
SUBROUTINE E.FORMAT.DATE.TIME
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 28/08/12 - Enhancement - 371776, Task - 452007
*            Deleted item history (SAMBA)
*            Formate Date and time
*
* 24/10/18 - Enhancement 2822523 / Task 2826365
*          - Incorporation of  EB_SystemTables component
*
* 21/08/19 - Defect 3285097  / Task 3296708
*            Conversion Routine to be used in TY.BLOTTER enquiry
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $INSERT I_EQUATE

*-----------------------------------------------------------------------------

    GOSUB init ; *initialise the values
    GOSUB formateDateTime ; *formate the DATE and TIME values in milli seconds before display it

RETURN

*
*-----------------------------------------------------------------------------
*
*** <region name= init>
init:
*** <desc>initialise the values </desc>
    
    timeInSec=''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= formateDateTime>
formateDateTime:
*** <desc>formate the DATE and TIME values in milli seconds before display it </desc>

    O.DATA = EB.Reports.getOData() ;* fetch unformatted DATE.TIME value from OData
    timeInSec = O.DATA[7,14]  ;* Time in milli seconds
    timeInSec = timeInSec/1000 ;* Convert it to seconds

    auditDate=O.DATA[1,6]    ;*Date in audit fields

    auditDate=auditDate[3,2]:'-':auditDate[5,2]:'-20':auditDate[1,2] ;* FORMATE IT like DATE-MONTH-YEAR

    O.DATA = OCONV(auditDate,"D4"):' ': OCONV(FIELD(timeInSec,'.',1),'MTS'):':':FMT(FIELD(timeInSec,'.',2),"L%3") ;* Display the formatted value

    EB.Reports.setOData(O.DATA) ;* set formatted DATE.TIME value to OData

RETURN
*** </region>


*-----------------------------------------------------------------------------


END


