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
    $PACKAGE AC.EntryCreation
    SUBROUTINE CONV.RE.SPEC.ENT.TODAY.G12(YID,YREC,YFILE)
***************************************************************
*Version       : G12.2                                      *
*Program Name  : CONV.RE.SPEC.ENT.TODAY.G12
*Description   : This program add the terminal id in the file *
*-------------------------------------------------------------*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

    FN.RE.SPEC.ENT.TODAY = YFILE
    F.RE.SPEC.ENT.TODAY = ''
    CALL OPF(FN.RE.SPEC.ENT.TODAY,F.RE.SPEC.ENT.TODAY)


    NEW.SPEC.ENT.TODAY = YID:'-':TNO

    DELETE F.RE.SPEC.ENT.TODAY,YID
    YID= NEW.SPEC.ENT.TODAY
    RETURN
END
