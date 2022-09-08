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
    $PACKAGE DD.Contract
    SUBROUTINE CONV.DD.PARAMETER.R06(PARAM.ID,PARAM.REC,PARAM.FILE)
***********************************************************************
* Conversion routine to select DD.PARAMETERs. Process those records which
* does not contain any CURRENCY information.
* Update CURRENCY  with LOCAL.CURRENCY in DD.PARAMETER.
***********************************************************************
* 23/05/05 - BG_100008760
*            Initial Version
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
***********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DD.PARAMETER


    IF PARAM.REC<DD.PAR.CURRENCY,1> = '' THEN
        PARAM.REC<DD.PAR.CURRENCY,1> = LCCY
    END

    RETURN

END
