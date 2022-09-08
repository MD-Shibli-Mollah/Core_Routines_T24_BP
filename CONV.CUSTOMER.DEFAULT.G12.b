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

* Version 1 25/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Customer
      SUBROUTINE CONV.CUSTOMER.DEFAULT.G12(YID,YREC,YFILE)

* 21/05/01 - GB0101286
*            Conversion program for CUSTOMER.DEFAULT

$INSERT I_COMMON
$INSERT I_EQUATE

      YREC<8> = ''
      YREC<9> = ''
      YREC<10> = ''
      YREC<11> = ''
      YREC<12> = ''
      YREC<13> = ''

      RETURN
   END
