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

* Version 1 22/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventCapture
      SUBROUTINE CONV.SC.DIARY.PORT.NO.G10.2(PARAM.ID, R.DIARY, F.DIARY)

      EQU SC.DIA.LOCAL.REF TO 114
      EQU SC.DIA.OLD.LOCAL.REF TO 97
*
      R.DIARY<SC.DIA.LOCAL.REF> = R.DIARY<SC.DIA.OLD.LOCAL.REF>
      R.DIARY<SC.DIA.OLD.LOCAL.REF> = ''
*
      RETURN
   END
