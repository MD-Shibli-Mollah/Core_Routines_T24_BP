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
    $PACKAGE MI.Entries
    SUBROUTINE CONV.MI.PARAM.G14.1(ID,REC,FILE)
*******************************************************
* 10/09/03 - EN_10001974
*            Conversion routine for populating values to the newly
*            added fields
*******************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MI.PARAMETER

    REC<MI.PARAM.POST.DATE.BAL.UPD> = 'YES'
    REC<MI.PARAM.ADJ.DATE.BAL.UPD> = 'YES'
    REC<MI.PARAM.VAL.DATE.BAL.UPD> = 'YES'
    REC<MI.PARAM.BAL.MVMT.APPS> = 'ALL'

    RETURN
*
END
