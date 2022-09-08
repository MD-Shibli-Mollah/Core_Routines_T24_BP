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

* Version 1 01/11/99  GLOBUS Release No. G10.2.00 01/12/99
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Utility
      SUBROUTINE CONV.DATES.G13.1(YID, YREC, YFILE)
*------------------------------------------------------------------------
* This routine sets the CO.BATCH.STATUS field to NULL. This field used to
* be a reserved field but contained data = RUN
*------------------------------------------------------------------------
*
$INSERT I_F.DATES
*
        YREC<EB.DAT.CO.BATCH.STATUS> = ""
*
      RETURN
   END
