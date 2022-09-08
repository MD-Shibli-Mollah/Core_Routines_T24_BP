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

* Version 1 13/05/99  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Security
      SUBROUTINE CONV.USER.G10(YID, YREC, YFILE)
*-----------------------------------------------------------------------------
* This routine populates the new ATTRIBUTES field according to the previous
* rules for a "super user", i.e. if there is not anything in the INIT.APPLICATION
* field then the USER was deemed to be a SUPER.USER
*-----------------------------------------------------------------------------
      IF YREC<14> = "" THEN
         LOCATE "SUPER.USER" IN YREC<54,1> SETTING FOUND.POS ELSE
            INS "SUPER.USER" BEFORE YREC<54,1>
         END
      END
      RETURN
   END
