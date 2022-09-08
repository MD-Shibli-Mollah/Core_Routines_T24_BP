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

* Version 1 01/11/99  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.STANDARD.SELECTION.G10.2(YID, YREC, YFILE)
*------------------------------------------------------------------------
* This routine sets the SINGLE.MULT field to M for DATE.TIME fields
*------------------------------------------------------------------------
      LOCATE "DATE.TIME" IN YREC<1,1> SETTING FOUND.POS THEN
         YREC<10,FOUND.POS> = "M"
      END
      RETURN
   END
