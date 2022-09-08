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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Config
    SUBROUTINE CONV.PM.PARAMETER.G14.1
*==========================================================================
* CONV.PM.PARAMETER.G14.1 - This routine is used to set the field COL
*                           in PM.PARAMETER to 25, which is used to define
*                           the dimension of the MAT.ACTIVITY array.
*
*==========================================================================
*
* 08/10/2003 - BG_100005353
*              New coversion routine
*
*===========================================================================
*                     Insert Files
*===========================================================================
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PM.PARAMETER
*
*===========================================================================
*                     Main Section
*===========================================================================
*
    GOSUB INITIALISE
    GOSUB OPEN.FILE.AND.PROCESS
*
    RETURN
*
*===========================================================================
*                     Subroutines
*===========================================================================
INITIALISE:
*==========
*Initialise the variables
    FN.PM.PARAM = 'F.PM.PARAMETER'
    F.PM.PARAM = ''
    R.PM.PARAM = ''
    PM.PARAM.ID = 'SYSTEM'
    ERR = ''
*
    RETURN
*
*===========================================================================
OPEN.FILE.AND.PROCESS:
*=====================
*Open the PM.PARAMETER file and Assign the field COL as 25 here
    CALL OPF(FN.PM.PARAM,F.PM.PARAM)
    CALL F.READ(FN.PM.PARAM,PM.PARAM.ID,R.PM.PARAM,F.PM.PARAM,ERR)
*
    IF ERR = '' THEN
        R.PM.PARAM<PM.PP.COL> = 25
    END
*
    WRITE R.PM.PARAM TO F.PM.PARAM,PM.PARAM.ID
*
    RETURN
*
*===========================================================================
END
