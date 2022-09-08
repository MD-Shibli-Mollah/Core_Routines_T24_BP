* @ValidationCode : MToxODE0MDQ1NjYzOkNwMTI1MjoxNDcwODEyNTkyMTU5OmNhYmludToxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTYwOC4w
* @ValidationInfo : Timestamp         : 10 Aug 2016 12:33:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : cabinu
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.DATE.DIFFERENCE

*** <region name= Synopsis of the Routine>
***
** Conversion routine to return days between two dates
*
*** </region>

*----------------------------------------------------------------------------- 
*** <region name= Modification History>
***
**
* 13/11/14 Task 1131074
*          Ref : Defect 1105150
*          Generic routine to return days between two dates
*
* 10/08/16 - Task   : 1822869
*            Defect : 1822201
*            Routine should return number of calendar days between two dates. 
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>

    $USING EB.API
    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------

*
*** <region name= Main Process>
***

    DAYS = "C" ;* to calculate the calendar days between first and second date.
    tmp.O.DATA = EB.Reports.getOData()
    DATE1 = FIELD(tmp.O.DATA,"*",1) ;* Get first date
    EB.Reports.setOData(tmp.O.DATA)
    tmp.O.DATA = EB.Reports.getOData()
    DATE2 = FIELD(tmp.O.DATA,"*",2) ;* Get second date
    EB.Reports.setOData(tmp.O.DATA)
    EB.API.Cdd("", DATE1, DATE2, DAYS)

    EB.Reports.setOData(ABS(DAYS))

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
