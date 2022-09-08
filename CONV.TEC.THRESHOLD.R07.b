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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Logging
    SUBROUTINE CONV.TEC.THRESHOLD.R07(YID,YREC,YFILE)
* Since 5th field RAISE.EVENT is converted into a no-input reserved field
* any value init is Nullified.
*-----------------------------------------------------------------------------
* Modification History :
* -------------
* 27/09/06 - EN_10003086
*            Creation
*            Ref: SAR-2005-08-18-0008
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------

    YREC<5> = ''    ;* previously RAISE.EVENT
    RETURN
*-----------------------------------------------------------------------------
END
