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
    $PACKAGE AA.ClassicProducts
    SUBROUTINE CONV.AA.AC.GROUP.INTEREST.R08(REC.ID, PROP.REC, YFILE)


********************************************************************************
* 10/09/07 - BG_100015135
*            Conversion routine to reuse the field START.OF.DAY.CAP field
*            to BAL.CALC.ROUTINE in AC.GROUP.INTEREST property class
*
********************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.AC.GROUP.INTEREST

    PROP.REC<AA.GI.BAL.CALC.ROUTINE> = ''

    RETURN
END
