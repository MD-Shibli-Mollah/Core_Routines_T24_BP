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

* Version n dd/mm/yy  GLOBUS Release No. G12.1.00 30/10/01
*-----------------------------------------------------------------------------
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Foundation
      SUBROUTINE CONV.MD.PARAMETER.G12.2(MD.ID,MD.REC,MD.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*******************************************************************

      EQU MD.PAR.EVENTS.PROCESSING TO 30,
         MD.PAR.TR.INV.CODE.DR TO 31, MD.PAR.TR.INV.CODE.CR TO 32

      IF FILE.TYPE NE 1 THEN RETURN
*
*
      MD.REC<MD.PAR.EVENTS.PROCESSING> = 'END OF DAY'
      MD.REC<MD.PAR.TR.INV.CODE.DR> = ''
      MD.REC<MD.PAR.TR.INV.CODE.CR> = ''
      RETURN
************************************************************************
   END
