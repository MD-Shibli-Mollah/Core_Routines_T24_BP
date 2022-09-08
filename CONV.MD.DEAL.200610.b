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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Contract
    SUBROUTINE CONV.MD.DEAL.200610(MD.ID,MD.RECORD,F.MD.DEAL)

* This subroutine converts MD.DEAL>CONVERSION.TYPE to CONVERSION.RATE and assign the value of CONVERSION.RATE
* as NULL.
**********************************************************************
* 29/02/2008 - BG_100017410
*              Field name has been changed to field number for
*              CONVERSION.RATE field.
*              TTS0800738
**********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MD.DEAL

*=======================
* Open files :
*=======================
    FV.MD.DEAL = ""
    CALL OPF(F.MD.DEAL,FV.MD.DEAL)

*===================
* Process records :
*===================
    IF MD.RECORD<62> EQ 'MID' THEN
        MD.RECORD<62> = ''
    END
    RETURN
END
