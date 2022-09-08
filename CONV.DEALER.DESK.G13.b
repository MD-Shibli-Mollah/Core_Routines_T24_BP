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
    $PACKAGE FX.Contract
    SUBROUTINE CONV.DEALER.DESK.G13(YID,YREC,YFILE)

**************************************************************************
*-----Conversion routine for DEALER.DESK------*

*28/05/02 - GLOBUS_EN_10000680
*         - Field 11 should be updated with YES in all the existing records

****************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    IF YREC<11> EQ '' THEN
        YREC<11> = 'YES'
    END

    RETURN
END
