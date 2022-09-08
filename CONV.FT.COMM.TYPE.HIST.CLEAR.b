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
    $PACKAGE ST.ChargeConfig
    SUBROUTINE CONV.FT.COMM.TYPE.HIST.CLEAR
*************************************************************************
*   Clear the FT.COMM.TYPE.HISTORY file
*-----------------------------------------------------------------------------
* Modifications:
*
* 29/11/07 - BG_100016110
*            New routine - Clear the FT.COMM.TYPE.HISTORY file.
******************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------
*
    
    GOSUB INITIALISE

    EXECUTE "CLEAR.FILE ":FN.FT.COMM.TYPE.HISTORY
    CRT FN.FT.COMM.TYPE.HISTORY:" cleared."
    RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialise files and variables </desc>
*
*
    FN.FT.COMM.TYPE.HISTORY = 'F.FT.COMM.TYPE.HISTORY'
*
    F.FT.COMM.TYPE.HISTORY = ''
    CALL OPF(FN.FT.COMM.TYPE.HISTORY,F.FT.COMM.TYPE.HISTORY)
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
