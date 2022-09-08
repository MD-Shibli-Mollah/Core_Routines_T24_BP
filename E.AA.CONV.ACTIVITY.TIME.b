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
    SUBROUTINE E.AA.CONV.ACTIVITY.TIME
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 28/08/12 - Enhancement - 371776, Task - 452007
*            Deleted item history (SAMBA)
*            Formate Date and time
*
*-----------------------------------------------------------------------------

    $USING EB.Reports

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
       
    OUT.O.DATA = ''        ;* Converted Time
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= formateDateTime>
formateDateTime:
*** <desc>formate the DATE and TIME values in milli seconds before display it </desc>

    IN.O.DATA = EB.Reports.getOData()
    Hours = IN.O.DATA[7,2]  ;* Time in milli seconds
    Minutes = IN.O.DATA[9,2] ;* Convert it to seconds

    IF Hours OR Minutes THEN
        OUT.O.DATA = Hours :':': Minutes
    END
    
    EB.Reports.setOData(OUT.O.DATA);* Assign Converted time back to O.DATA.

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
