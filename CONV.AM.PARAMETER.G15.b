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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
    SUBROUTINE CONV.AM.PARAMETER.G15(AM.PARAMETER.ID,R.AM.PARAMETER,F.AM.PARAMETER)
* Conversion routine to clear HIST.YEAR,HIST.PERIODIC,HIST.BACKUP,HIST.DURATION and HIST.PERIOD
    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQU AM.PAR.HIST.PERIOD TO 49,
    AM.PAR.HIST.YEAR TO 50,
    AM.PAR.HIST.PERIODIC TO 51,
    AM.PAR.HIST.BACKUP TO 52,
    AM.PAR.HIST.DURATION TO 53

    R.AM.PARAMETER<AM.PAR.HIST.PERIOD> = ""
    R.AM.PARAMETER<AM.PAR.HIST.YEAR> = ""
    R.AM.PARAMETER<AM.PAR.HIST.PERIODIC> = ""
    R.AM.PARAMETER<AM.PAR.HIST.BACKUP> = ""
    R.AM.PARAMETER<AM.PAR.HIST.DURATION> = ""


    RETURN
END
