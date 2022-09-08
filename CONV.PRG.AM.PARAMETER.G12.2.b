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
    $PACKAGE AM.Foundation
      SUBROUTINE CONV.PRG.AM.PARAMETER.G12.2(YID, YREC, YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU AM.PAR.MAIN.ENQUIRY TO 1
      EQU AM.PAR.MAIN.DISP.FMT TO 2
      EQU AM.PAR.SUB.ENQUIRY TO 3
      EQU AM.PAR.SUB.DISP.FMT TO 4
      EQU AM.PAR.LOCK.SCE.ORDER TO 16

      YREC<AM.PAR.MAIN.ENQUIRY> = 'AM.GRID.MASTER'
      YREC<AM.PAR.MAIN.DISP.FMT> = 'DEFAULT'
      YREC<AM.PAR.SUB.ENQUIRY> = 'AM.GRID'
      YREC<AM.PAR.SUB.DISP.FMT> = 'DEFAULT'
      YREC<AM.PAR.LOCK.SCE.ORDER> = 'YES'

      RETURN
   END
