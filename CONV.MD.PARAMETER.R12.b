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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Config
    SUBROUTINE CONV.MD.PARAMETER.R12(MD.PARAM.ID,MD.PARAM.REC,MD.PARAM.FILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* 13/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
* Modifications
*** </region>
*****************************************************************************

*** <region name= INSERTS>
*** <desc>Insert files </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU MD.PAR.RETURN.COMM TO 36
    EQU MD.PAR.RATE.CHANGE TO 37
*** </region>
********************************************************************************
*** <region name= MAIN.PROGRAM>
*** <desc>MAIN.PROGRAM </desc>

MAIN.PROGRAM:
*============
    IF NOT(MD.PARAM.REC<MD.PAR.RETURN.COMM>) THEN
        MD.PARAM.REC<MD.PAR.RETURN.COMM> = 'YES'
    END
    IF NOT(MD.PARAM.REC<MD.PAR.RATE.CHANGE>) THEN
        MD.PARAM.REC<MD.PAR.RATE.CHANGE> = 'NO'
    END
    RETURN

*** </region>
********************************************************************************
    END
