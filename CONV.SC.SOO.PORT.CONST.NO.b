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
    $PACKAGE SC.SctConstraints
      SUBROUTINE CONV.SC.SOO.PORT.CONST.NO(YID,YREC,YFILE)
      EQU SC.SOO.PORT.CONST.NO TO 39
*      EQU SC.SOO.PORT.CONSTRAINT.NO TO 86
      EQU SC.SOO.PORT.CONSTRAINT.NO TO 89
      YREC<SC.SOO.PORT.CONST.NO> = YREC<SC.SOO.PORT.CONSTRAINT.NO>
      YREC<SC.SOO.PORT.CONSTRAINT.NO> = ''
      RETURN
   END
