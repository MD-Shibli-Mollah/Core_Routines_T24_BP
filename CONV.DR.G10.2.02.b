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

* Version 3 24/08/00  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
      SUBROUTINE CONV.DR.G10.2.02(DR.ID, R.DR, F.DR)
*
* This conversion will backout the LIVEDB and PL entries of
* discount drawings, since the new discount process will only
* use DOCUMENT.AMOUNT rather than REIMBURSE.AMOUNT. Hence,
* the charge will be only booked at maturity.
*
* 07/08/00 - GB0001996/G00020146
*            Due to the problem raised under HD9901938, the LIVEDB
*            entry using the REIMBURSE.AMOUNT but in DOCUMENT ccy.
*            This routine will update the VOC to flag that this
*            This program will update VOC with G102FIX ID. This
*            will help us identify later, if any other conversion
*            need.
*
      RETURN

   END
