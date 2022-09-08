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
    $PACKAGE FT.Contract
      SUBROUTINE CONV.FT.CHARGE.FOR(YID,YREC,YFILE)
      * This is the conversion routine which is called from the
      * conversion detail CONV.FUNDS.TRANSFER.CHARGE.FOR
      * Modification history
      ***********************
      * 27/08/03 - CI_10012037
      *            The field CUSTOMER.SPREAD is not converted correctly.
      ******************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
      * It checks the CHARGE.FOR field. If the value is other than null, SENDER and
      * RECEIVER, it assigns the value to CUSTOMER.SPREAD.
      IF (YREC<52,1> NE '') AND (YREC<52,1> NE 'SENDER') AND (YREC<52,1> NE 'RECEIVER') THEN
         YREC<53> = YREC<52,1>
         YREC<52,1> = ''
      END
      RETURN
   END
