* @ValidationCode : MjoxMzExMDUzODI0OkNwMTI1MjoxNTY0NTcyMzY0MjkxOnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:56:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 13/06/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE CQ.ChqPaymentStop
      SUBROUTINE CONV.PAYMENT.STOP.G12(YID,YREC,YFILE)

*GB0101243 --------------------------------------
*      Conversion routine for PAYMENT.STOP
*
*GB0101730 --------------------------------------
* Changes to conversion routine
* Field 10 - updated with a 'YES' for all authorised records
* New fields within the multivalue set are set to null
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_PaymentStop as ST_ChqPaymentStop and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
$INSERT I_COMMON
$INSERT I_EQUATE

*GB0101730 S
      REC.COUNT = DCOUNT(YREC<10>,VM)
      FOR AV = 1 TO REC.COUNT
         YREC<2,AV> = YREC<10,AV>
         IF YREC<53> EQ '' THEN
            YREC<10,AV> = 'YES'
         END ELSE
            YREC<10,AV> = ''
         END
         YREC<5,AV> = ''
         YREC<11,AV> = ''
         YREC<12,AV> = ''
         YREC<13,AV> = ''
         YREC<14,AV> = ''
         YREC<17,AV> = ''
         YREC<18,AV> = ''
         YREC<19,AV> = ''
         YREC<20,AV> = ''
         YREC<21,AV> = ''
         YREC<22,AV> = ''
         YREC<23,AV> = ''
         YREC<24,AV> = ''
         YREC<25,AV> = ''
         YREC<26,AV> = ''
         YREC<27,AV> = ''
      NEXT AV
*GB0101730 E
      RETURN
   END
