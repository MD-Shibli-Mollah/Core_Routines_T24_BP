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

* Version 2 31/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.SC.PARAMETER.G11
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.PARAMETER
*
      F.SC.PARAM = 'F.SC.PARAMETER' ; F.SC.PARAMETER = ''
      CALL OPF(F.SC.PARAM,F.SC.PARAMETER)
*
      SEL = 'SELECT ':F.SC.PARAM
      CALL EB.READLIST(SEL,PARAM.IDS,'','','')
*
      LOOP
         REMOVE SC.PARAM.ID FROM PARAM.IDS SETTING POS
      WHILE SC.PARAM.ID
         READ SC.PARAM.REC FROM F.SC.PARAMETER,SC.PARAM.ID THEN
            IF SC.PARAM.REC<SC.PARAM.ADVICE.DEFAULT> EQ '' THEN
               SC.PARAM.REC<SC.PARAM.ADVICE.DEFAULT> = 'YES'
               WRITE SC.PARAM.REC TO F.SC.PARAMETER,SC.PARAM.ID
            END
         END
      REPEAT
*
      RETURN
*
   END
