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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Config
      SUBROUTINE CONV.PM.LD.PARAM.G7.1(YID, YREC, PM.FILE)
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
** This routine will:
** Move the contents of POS.INT.CAP(11) to POS.FWD.FWD.FIX.CAP(9) and POS.FWD.VAR.CAP(8)
** which were previoulsy POS.INT (9) and POS.INT.DISC (10)
** Clear POS.FEE no longer used
*
      IF PM.FILE["$",2,1] NE "HIS" THEN
*
         YREC<9> = YREC<11>
         YREC<10> = YREC<11>
         YREC<13> = ""
*
      END
*
      RETURN
*
   END
