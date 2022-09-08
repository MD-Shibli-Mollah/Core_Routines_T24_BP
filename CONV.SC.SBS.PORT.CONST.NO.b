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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctConstraints
    SUBROUTINE CONV.SC.SBS.PORT.CONST.NO(YID,YREC,YFILE)
* 18/08/03 - CI_10011881
*          - The assigned field number was wrong.
*
    EQU SC.SBS.PORT.CONST.NO TO 74
* CI_10011881 - S      EQU SC.SBS.PORT.CONSTRAINT.NO TO 129
    EQU SC.SBS.PORT.CONSTRAINT.NO TO 131          ;* CI_10011881 - E
    YREC<SC.SBS.PORT.CONST.NO> = YREC<SC.SBS.PORT.CONSTRAINT.NO>
    YREC<SC.SBS.PORT.CONSTRAINT.NO> = ''
    RETURN
END
