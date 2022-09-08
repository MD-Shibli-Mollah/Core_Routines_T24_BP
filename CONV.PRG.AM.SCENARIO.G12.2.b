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
    $PACKAGE AM.ModellingScenario
      SUBROUTINE CONV.PRG.AM.SCENARIO.G12.2(YID, YREC, YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU AM.SCE.LOCAL.REF TO 41
      EQU AM.SCE.OVERRIDE TO 42
      EQU OLD.OVERRIDE TO 41
      EQU OLD.LOCAL.REF TO 42

      STORE.OLD.LOCAL.REF = YREC<OLD.LOCAL.REF>
      STORE.OLD.OVERRIDE = YREC<OLD.OVERRIDE>

      YID = '1.':YID
      YREC<AM.SCE.OVERRIDE> = STORE.OLD.OVERRIDE
      YREC<AM.SCE.LOCAL.REF> = STORE.OLD.LOCAL.REF

      RETURN
   END
